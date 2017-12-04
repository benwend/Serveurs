#!/usr/bin/env zsh
#   _________  _   _ ____   ____ 
#  |__  / ___|| | | |  _ \ / ___|
#    / /\___ \| |_| | |_) | |    
# _ / /_ ___) |  _  |  _ <| |___ 
#(_)____|____/|_| |_|_| \_\\____|
#

# Complétion
autoload -U compinit
compinit

#Insensible à la casse
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

#compinstall
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                             /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
# Crée un cache des complétion possibles
# très utile pour les complétion qui demandent beaucoup de temps
# comme la recherche d'un paquet aptitude install moz<tab>
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh_cache
# des couleurs pour la complétion
# faites un kill -9 <tab><tab> pour voir :)
zmodload zsh/complist
setopt extendedglob
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=31"

# Correction des commandes
setopt correctall

# Liste des plugins
# Git
source $HOME/.git-flow-completion/git-flow-completion.zsh

### VAR ENV
# Prompt ROOT :
# export PS1="#%B%{$fg[red]%}%m%b%{$reset_color%}:%~%B#%b "
# Prompt USER :
autoload colors; colors
export PS1="%B[%{$fg[green]%}%n%{$reset_color%}%b%B%{@$fg[cyan]%}%m%b%{$reset_color%}:%~%B]%b "
# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
# Colored MAN
export MANPAGER='/usr/bin/most -s'
# Editeur de texte
export EDITOR=/usr/bin/vim
# Display TIME
export TIME="\t%E,\t%k"
# Historique des commandes:
HISTFILE=~/.history
#HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
export HISTFILE SAVEHIST
export PATH="/sbin:/usr/sbin:"$PATH
###

### ALIAS
# DD
alias dd='dcfldd'
alias ddkey='sudo time dcfldd of=/srv/data/backup_key.dd if=/dev/sdc1 bs=4096 conv=notrunc,noerror'
# LS
alias ls='ls --color=auto'
alias l='ls -CF'
alias al='ls -ACF'
alias ll='ls -lhF'
alias la='ls -lhFA'
alias lt='ls -lhFtr'
# GREP
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
# SYSTEM
alias psf='ps faux'
alias df='df -h'
alias du='du -h'
# DIVERS
alias upPy='pip list --outdated|cut -d " " -f 1|sudo xargs -n1 pip install -U'
alias upPy3='pip3 list --outdated|cut -d " " -f 1|sudo xargs -n1 pip3 install -U'
alias ipy='ipython'
alias g11='gcc -std=c11 -Wall'
# CORRECTION
alias xs='cd'
alias sl='ls'
# SSH
alias sag='ssh-agent /bin/zsh'
alias sal='ssh-add -l'
alias sad-g='ssh-add /media/veracrypt1/Documents/Trousseau/github.key'
alias sad-o='ssh-add /media/veracrypt1/Documents/Trousseau/ob_rsa'
alias sad-r='ssh-add /media/veracrypt1/Documents/Trousseau/ovhr'
alias sad-a='ssh-add /media/veracrypt1/Documents/Trousseau/Adexgroup-Securite/id_rsa_wolverine'
# RSYNC
alias tsync='time rsync -ahvz --del --progress'
alias rsync_key='tsync /srv/data/backup_key.dd /media/sharky/Rafale/backup_key.dd'
alias rsync_zic='tsync /srv/data/Musiques/ /media/sharky/Rafale/Musiques/'
###

####
# PLUGINS : Oh-my-Zsh
#

# HISTORY
alias h='history'
function hs
{
    history | grep $*
}
alias hsi='hs -i'
