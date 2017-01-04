. ~/.bash_functions
. ~/.bash_aliases
. ~/.env_vars

export PS1="\[\033[32m\]\u@\h\[\033[00m\] \w\[\033[33m\]\[\033[00m\] $ "
export PATH=$HOME/bin:$PATH
export PATH=$PATH:/usr/local/go/bin:${HOME}/go/bin

if [[ `uname` == "Darwin" ]]; then
    PREFIX=$(brew --prefix)
    export PATH=$PATH:/Applications/calibre.app/Contents/console.app/Contents/MacOS
else
    export PATH=/snap/bin:$PATH
    PREFIX=""
fi

# bash completion
if [ -f $PREFIX/etc/bash_completion ]; then
. $PREFIX/etc/bash_completion
fi

# git autocompletion
if [ -f $PREFIX/etc/bash_completion.d/git-completion.bash ]; then
  . $PREFIX/etc/bash_completion.d/git-completion.bash
fi

# kubectl autocompletion
if [ -f $PREFIX/etc/bash_completion.d/kubectl ]; then
  . $PREFIX/etc/bash_completion.d/kubectl
fi


# aws autocompletion
if command -v aws &> /dev/null; then
    complete -C 'aws_completer' aws
fi


# terraform completion
if command -v terraform &> /dev/null; then
    complete -C 'terraform' terraform
fi

source /Users/ikovalkovskyi/.docker/init-bash.sh || true # Added by Docker Desktop
