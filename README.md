SMS REST INFRASTRUCTURE
===

This repositoy contains the following tools: 

  - Ruby 2.3.3 with Rails Framework

It will take up to **10 minutes to finish the first config**

When the process is done, you can view your project in your browser in: `192.168.33.10`.

This will create a synced folder with your host machine `./tinker_share_files/`.
All the files will be placed there ready to be modified.

HAPPY CODING!


Usage
===

## With [tinker-cli](https://github.com/thetonymaster/tinker-cli/releases/download/v0.1/tinker-cli)
[Download it!](https://github.com/thetonymaster/tinker-cli/releases/download/v0.1/tinker-cli)

Fetch project: 
```
  tinker create rest-sms-infrastructure
```

Initialize a new dev env.
```
  tinker run
```

Apply new configurations: 
```
  tinker update
```

CLI HELP project: 
```
  tinker help
```

## USING GIT AND VAGRANT

For new repos, clone including submodules.

```
  git clone --recursive https://github.com/Tinker-Ware/rest-sms-infrastructure.git
```

For already cloned repos, just update the submodules.
```
  git submodule update --init --recursive
```

Start working with the created Vagrant machine:
```
  vagrant up
```

Apply new configurations
```
  vagrant provision
```


Support
===

Please contact Tinkerware if any request or modification.

email: alfonso@tinkerware.io
Slack: tinkerware-support.slack.com/signin
