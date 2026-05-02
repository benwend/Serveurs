# LS
#alias ls='ls ${COLOR_OPTION}'
alias ls='eza'
#alias l='ls -C --classify --human-readable' # short options = -F -h
alias l='ls -F -h -g' # short options = -F -h
alias la='l -a'
alias ll='l -l'
alias llt='ll -t'
alias lla='ll -a'

alias ccze='ccze -A'
alias less='less -R'

# GREP
alias grep='grep ${COLOR_OPTION}'
alias egrep='egrep ${COLOR_OPTION}'
alias fgrep='fgrep ${COLOR_OPTION}'

# SYSTEME
alias df='df -h'
alias du='du -h'
alias dpkgg='dpkg -l | grep -e $1'
alias pip-update-user='pip list -o --user|tail -n+3 |cut -d" " -f1 |xargs -n1 pip install -U'
alias pip-update='pip list -o |tail -n+3 |cut -d" " -f1 |xargs -n1 pip install -U'

alias rebash='source $HOME/.bashrc'
alias edbash='vim $HOME/.bashrc'
alias edalias='vim $HOME/.bash_aliases'

# PERSO
alias dd_corsair='time sudo dd if=/dev/sdc1 of=/srv/data/corsair.iso bs=8k conv=notrunc,sync status=progress'
alias start-vm-ansible='vboxmanage startvm "$(vboxmanage list vms | egrep -i ansible | cut -d"{" -f2 | sed "s/}//g")"'
alias start-vm-symfony='vboxmanage list vms | egrep -vi ansible | cut -d"{" -f2 | sed "s/}//g" | xargs vboxmanage startvm'

# DEV
alias venv='source .venv/bin/activate'
