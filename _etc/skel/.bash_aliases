### VAR ENV
# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
# Colored MAN
export MANPAGER='/usr/bin/most -s'
# Editeur de texte
export EDITOR=/usr/bin/vim

# GREP
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# LS
alias l='ls -CF'
alias al='ls -ACF'
alias ll='ls -lhF'
alias la='ls -lhFA'
alias lt='ls -lhFtr'

# SYSTEME
alias df='df -h'
alias du='du -h'
alias sag='ssh-agent /bin/bash'
alias sad='ssh-add <PATH/MY_KEY>'
alias ipy='ipython'
