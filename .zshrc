#!/bin/zsh
export OKTA_TEAM=devops-sso
# TURNOFF dockerbox
# source $HOME/.dev_environment/bash_functions

## GOLANG setup
export GOPATH=$HOME/go-projects
export PATH=$PATH:$GOPATH/bin

# ## Make ENVKEY WORK
# export SE_AWS_PRODUCTION_ENVKEY=ek2RHQAPnsX9LRjpE3rxbRLV-pAbt4hfYFyRR7ahajL3jKa

# ENVKEY=ek2RHQAPnsX9LRjpE3rxbRLV-pAbt4hfYFyRR7ahajL3jKa

#export PS1="%n@%m %~ %# "
#export PS1="%* %1~ # "
#export PS1=$'\n%* %1~ # '


# export PS1="%* # %# "

cd() {
    builtin cd "$@" && ls -la --color
}

export TERM=xterm-256color

alias c='claude'
alias e='emacsclient -a emacs'
alias k='kubectl'

# Use emacsclient for everything — opens in running Emacs, falls back to new Emacs
export EDITOR="emacsclient -a emacs"
export VISUAL="emacsclient -a emacs"
export KUBE_EDITOR="emacsclient -a emacs"
alias tp='terragrunt plan'
export LS_OPTIONS='--color=auto'
alias ls='ls $LS_OPTIONS'
export OKTA_TEAM=devops-sso
source $HOME/.dev_environment/bash_functions
alias emacsu='$(/Applications/Emacs.app/Contents/MacOS/Emacs "$@")'


alias stage='k8s_se_stage_2'
alias prod='k8s_se_prod_2'
alias ops='k8s_zgny_ops'
alias oestage='k8s_oe_stage'
alias oes='k8s_oe_stage'
alias oeprod='k8s_oe_prod'
alias oep='k8s_oe_prod'

# k8s aliases:

alias kga='kubectl get all -n'
alias kgn='kubectl get ns'
alias kg='kubectl get ns | grep '
alias kgp='kubectl get pods'
alias knotrunning='kubectl get pods --all-namespaces --field-selector=status.phase!=Running -o wide'
alias kn='kubectl config set-context --current --namespace '

# Added by Antigravity
export PATH="/Users/alfonsoa/.antigravity/antigravity/bin:$PATH"
eval "$(rbenv init -)"

alias dk='se dk'

export PATH="$HOME/.local/bin:$PATH"
