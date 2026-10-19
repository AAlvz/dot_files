# emacsclient inside vterm deadlocks the Emacs daemon

## Symptom

Inside a vterm running Claude Code, the screen shows
`Save and close editor to continue...` and the whole Emacs (every frame) stops
responding to keys. `emacsclient -e t` from another terminal hangs too.

## What triggers it

Claude Code's `chat:externalEditor` action opens the prompt in `$EDITOR`
(a temp file like `/tmp/claude-<uid>/claude-prompt-<uuid>.md`). In
`~/.claude/keybindings.json` that action is bound to `ctrl+g` and
`ctrl+x ctrl+e`. In vterm, `C-c C-x` forwards a raw `C-x`, so
`C-c C-x C-e` reaches Claude as `ctrl+x ctrl+e` and opens the editor. Other
programs that run `$EDITOR` from a vterm (`git commit`, `kubectl edit`,
`crontab -e`) would hit the same trap.

## Why it deadlocks

The process chain is Emacs in Emacs:

```
Emacs daemon ── vterm buffer ── pty /dev/ttysNNN ── zsh ── claude
     ^                                                       │
     └──────── emacsclient -nw (EDITOR) ◄────────────────────┘
```

`emacsclient -nw` asks the daemon to open a **tty frame on the client's
terminal**, which is the vterm's own pty. While setting that terminal up the
daemon calls `tcdrain()` on the pty (stack: `server-create-tty-frame` →
`make-frame` → `set-keyboard-coding-system` → `reset_sys_modes` → `tcdrain`).
`tcdrain` waits until the pty's output has been read from the master side, and
the only reader of the master is the daemon's own vterm process filter, which
cannot run while the daemon is blocked. It sits in that wait for ever, at 0%
CPU.

Killing the inner `emacsclient` does **not** help: the daemon has already
opened the tty and is still stuck in the syscall.

## Unsticking it without losing vterm

Flush the pty's pending output from outside so `tcdrain` returns. Find the
pty from the stuck `emacsclient -nw ... claude-prompt` process (`ps -o tty`)
or from `lsof -p <daemon-pid> | grep ttys`, then:

```bash
python3 -c 'import os,termios,time
fd=os.open("/dev/ttys001",os.O_RDWR|os.O_NOCTTY|os.O_NONBLOCK)
for _ in range(160): termios.tcflush(fd,termios.TCOFLUSH); time.sleep(.05)'
```

Run it from a terminal outside Emacs (or from Claude in another
terminal). Then kill the inner client if it is still around:
`pkill -f 'emacsclient -nw -a "" /tmp/claude'`. The daemon answers
`emacsclient -e '(frame-list)'` again, the stray frame disappears, and vterm
and the `claude` session in it survive. Only some escape sequences meant for
vterm are dropped. `C-l` or a resize redraws.

To confirm the diagnosis before acting: `sample <daemon-pid> 1` should show
the main thread in `tcdrain`.

## The fix

Inside Emacs, `EDITOR` must be plain `emacsclient` (no `-nw`), so the file
opens as a buffer in the existing frame. Finish with `C-x #`.

Two places set it, and **both are needed**:

- `.emacs`: `vterm-environment` sets `EDITOR=emacsclient` for new vterms.
  On its own this does nothing, because the shell the vterm starts sources
  `.shell_common` afterwards and overrides it.
- `.shell_common`: `[ -n "$INSIDE_EMACS" ] && EDITOR='emacsclient'`.
  vterm (and `M-x shell`/`term`) set `INSIDE_EMACS`, so this is the one that
  wins.

Existing vterm buffers keep the old value until a new vterm is opened or
`source ~/.shell_common` is run in them.

Verify inside a vterm: `echo $EDITOR` should print `emacsclient`.
