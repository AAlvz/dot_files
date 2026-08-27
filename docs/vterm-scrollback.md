# vterm scrollback debugging log

Symptom, as first reported: *"I cannot scroll back to see previous history"* in
terminal Emacs (`emacs -nw`) under WSL / Windows Terminal, with Claude Code
running inside a vterm buffer. Nothing worked — not the wheel, not any key.

Started 2026-08-26. Keep this file updated if the problem comes back.

## The five faults

They stacked. Any one of them alone was enough to leave scrollback unreachable,
which is why fixing them one at a time kept looking like no progress.

| # | Fault | Fixed in |
|---|-------|----------|
| 1 | Wheel bound to GUI-only event names | `8c1061a` |
| 2 | Every keyboard route swallowed before Emacs saw it | `8c1061a` |
| 3 | Redraw dragged the window back on every byte of output | `0b7d95c` |
| 4 | `vterm-copy-mode` could not hold the screen either | `0b7d95c` |
| 5 | Reloading `.emacs` from a vterm broke that buffer's `major-mode` | `docs commit` |

### 1. Wheel bound to event names a tty never sends

`.emacs` bound `<wheel-up>` / `<wheel-down>`. Those exist only under a GUI. On a
text terminal `xt-mouse` decodes a wheel tick into `mouse-4` / `mouse-5`:

    xt-mouse.el:  btn = (+ (logand code 3) (if wheel 4 1))   ; -> mouse-4 / mouse-5

Both naming schemes are now bound, so the same config works on the Mac too.

### 2. Every keyboard route swallowed

Confirmed by `lookup-key` against a live `vterm-mode-map`:

    C-v    -> vterm--self-insert        (sent to the shell)
    M-v    -> vterm--self-insert-meta   (sent to the shell)
    prior  -> vterm--self-insert        (sent to the shell)
    S-prior-> scroll-down-command       (never arrives: Windows Terminal keeps it)

Windows Terminal binds `shift+pgup` / `shift+pgdn` to its own `scrollUpPage` /
`scrollDownPage` and does not forward them. `M-PageUp` / `M-PageDown` were added
because Windows Terminal leaves those alone and vterm does not forward them.

### 3. The redraw undoes every scroll

vterm moves point back to the cursor on every byte of output. With a program
that repaints — Claude Code, htop, a spinner — the window snapped back to the
prompt the instant it was scrolled.

### 4. `vterm-copy-mode` could not hold the screen either — the deep one

This is the one that made the whole thing feel unfixable, and it is worth
understanding before touching any of this again.

The only thing `vterm-copy-mode` does to freeze the screen is send XOFF down the
pty (`vterm-send-stop`, vterm.el:1088). A program in raw mode runs with IXON
off, so XOFF is never honoured. Output keeps arriving, `vterm--filter` keeps
calling `vterm--update` (vterm.el:1615, no `vterm-copy-mode` check anywhere in
that path), and every redraw resets point.

Fix: advise `vterm--delayed-redraw` to restore `window-start` and point after
each redraw while copy mode is on. Output still streams into the buffer
underneath; the view just stops chasing it.

### 5. Reloading `.emacs` from inside a vterm broke the buffer

`.emacs` had `(setq major-mode 'text-mode)`. `major-mode` is permanently
buffer-local, so a plain `setq` sets it for whatever buffer is current. On a
fresh start that is `*scratch*` and nobody notices. Reloading with
`M-x load-file` from inside a vterm sets **that** buffer's `major-mode` to
`text-mode` while everything else about it stays a terminal.

`vterm-copy-mode` then refuses to start:

    (if (or (equal major-mode 'vterm-mode) (derived-mode-p 'vterm-mode)) ...
      (user-error "You cannot enable vterm-copy-mode outside vterm buffers"))

which takes every scrollback command down with it. Now `setq-default`.

A scan of the whole file found `major-mode` to be the only buffer-local `setq`,
so this hazard is not lurking anywhere else — but check again before adding one:

    (local-variable-if-set-p 'some-var)   ; non-nil means don't plain-setq it

## Dead ends — already ruled out, don't re-tread

- **Mouse events not reaching Emacs.** They do. `xterm-mouse-mode` is on, the
  terminal parameter is set, and `xterm-mouse-last-click` showed live
  `mouse-movement` events arriving from Windows Terminal.
- **Windows Terminal blocking mouse reporting.** Its `settings.json` has nothing
  that would.
- **No scrollback in the buffer.** A plain `seq 1 300` in a vterm produced 303
  buffer lines. Scrollback accumulation works fine.
- **Claude Code using the alternate screen.** Its binary contains `\e[?1049h`,
  but a fresh session's small buffer was just a fresh session, not altscreen.

## Gotchas worth remembering

- **`M-:` does not work inside a vterm.** It is bound to
  `vterm--self-insert-meta`, so it types into the running program instead of
  opening `eval-expression`. `M-x` *does* work — it is in
  `vterm-keymap-exceptions` along with `C-c C-x C-u C-g C-h C-l M-o C-y M-y`.
- **A running Emacs can be inspected directly**, which beats guessing:

      emacsclient --eval '(lookup-key vterm-mode-map [mouse-4])'

  Only the instance that won the race to `server-start` answers. If several
  `emacs -nw` are running, the others are unreachable.
- **Reloading `.emacs` is idempotent** — advice count and hook lengths stay at 1
  across repeated loads. Verified.
- Mouse tracking is now `1000h / 1002h / 1006h`. Emacs asks for `1003h`
  (any-motion) by default, which floods it with events on idle mouse movement.

## Verification performed

Against a vterm printing a line every 50 ms, standing in for a repainting TUI:

- Treatment: scroll back, 3 s of output → `window-start` held exactly.
- **Control, advice removed**: drifted `4390 -> 4525`. The bug, on demand.
- `vterm-copy-mode` + `previous-line` ×30 + 3 s of output → view and point held.
- Reload path: a vterm rolled back to the old bindings, left streaming, then
  reloaded — scrolling that pre-existing buffer held at `1609`.
- Finally in the real session (pid 3167): 229 lines of scrollback, scrolled back
  to `window-start 2769`, held across 3 s of streaming output.

## Still open

- **The wheel is unproven.** Every keyboard route is verified; the wheel is not,
  because there was never a way to observe what Windows Terminal actually emits
  on a wheel tick from inside this setup. If it still does nothing, the next
  step is a throwaway probe that logs the decoded event on each tick.
- **`S-PageUp` needs a Windows Terminal change** to ever arrive: two
  `"id": null` entries for `shift+pgup` / `shift+pgdn` in `settings.json`. Not
  done — it costs Windows Terminal's own paging in non-Emacs tabs.

## Current keys

| Key | Action |
|-----|--------|
| Wheel up / down | Scroll 3 lines, entering copy mode on the way back |
| `M-PageUp` / `M-PageDown` | Scroll a screenful |
| `S-PageUp` / `S-PageDown` | Same, once Windows Terminal is told to let them through |
| `C-c C-t` | Toggle copy mode by hand |
| `q` | Leave copy mode (`RET` leaves and copies the selection) |
| scroll to the bottom | Leaves copy mode and reattaches to live output |
