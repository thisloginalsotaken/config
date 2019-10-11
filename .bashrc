# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
else
		color_prompt=
fi

# define colors
fg_color='\[\033[00m\]'
black='\[\033[0;30m\]'  
blue='\[\033[0;34m\]'  
green='\[\033[0;32m\]'  
cyan='\[\033[0;36m\]'  
red='\[\033[0;31m\]'  
purple='\[\033[0;35m\]'  
brown='\[\033[0;33m\]'  
light_gray='\[\033[0;37m\]'  
dark_gray='\[\033[1;30m\]'  
light_blue='\[\033[1;34m\]'  
light_green='\[\033[1;32m\]'  
light_cyan='\[\033[1;36m\]'  
light_red='\[\033[1;31m\]'  
light_purple='\[\033[1;35m\]'  
yellow='\[\033[1;33m\]'  
white='\[\033[1;37m\]'  

H=$HOSTNAME

if ([ "$H" = "yb-0" ] || [ "$H" = "xps13" ] ); then
	host_color=$brown
elif ( [ "$H" = "web21" ] || [ "$H" = "web14" ] ); then
	host_color=$yellow
else
	host_color=$light_red
fi

if [ "$UID" = "0" ]; then
	user_color=$light_red
else
	user_color=$light_green
fi

git_prompt ()
{
	if ! git rev-parse --git-dir > /dev/null 2>&1; then
    	return 0
	fi
	git_branch=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')

	if git diff --quiet 2>/dev/null >&2; then
    	echo "-"
	else
    	echo "*" 
	fi
}

if [ "$color_prompt" = yes ]; then
#	set_bash_prompt(){
#		PS1="[${user_color}\u${fg_color}@${host_color}\h${fg_color}: \[\033[01;34m\]\w\[\033[00m\]]$(git_prompt)\$ "
#	}
	PS1="\$(git_prompt)[${user_color}\u${fg_color}@${host_color}\h${fg_color}: \[\033[01;34m\]\w\[\033[00m\]]\$ "
else
    PS1='$\u@\h:\w\$ '
fi

# if this is an xterm set the title to user@host:dir
case "$term" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac



# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export LANG=en_US.UTF-8

# функция для поиска штук типа .git и venv
function upsearch {
    pattern=$1
    activate_script=`find ${pattern}  2>/dev/null`
    if [ $? == 0 ]
    then
        echo ${activate_script}
        return 0
    fi

    if [ "/" == "$PWD" ]
    then
        return 1
    else
        pushd .. > /dev/null 2>&1
        result=`upsearch $@`
        success=$?
        popd +0 > /dev/null 2>&1
        if [ ${success} == 0 ]
        then
            echo "../${result}"
            return 0
        else
            return 1
        fi
    fi
}

function activate {
	if [ "`type -t deactivate`" == "function" ]; then
		deactivate
	fi

	if [ "$1" != "" ]; 	then
    	activator=`upsearch ${1}/bin/activate`
    else
        activator=`upsearch */bin/activate`
    fi

	if [ "$activator" != "" ];  then
		source ${activator}
	else
		echo "no venv here!"
	fi

}

function set_term_title {
	echo -en "\033]0;$1\a"
}




export HISTSIZE="pewpew"
export HISTSIZEFILE=-1
export HISTCONTROL=ignoreboth:erasedups
export PROMPT_COMMAND='echo -en "\033]0;[win] $(dirs)\a"'
# export PROMPT_COMMAND='history -a'

# ssh agent

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }


env=~/.ssh/agent.env
agent_load_env
# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
set_term_title 'loading ssh agent'
if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi
unset env


function ssh {
	set_term_title "$@"
	/usr/bin/ssh $@
}


export EDITOR="vim"

