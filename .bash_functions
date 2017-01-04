#!/bin/bash


# fzf checkout to branch
co() {
    git checkout "$(git branch --sort=-committerdate -vv  | fzf | xargs | cut -d " " -f1)"
}


function display_notification () {
    osascript -e "display notification \"${1}\" with title \"${2:-Terminal notification}\" sound name \"/System/Library/Sounds/Submarine.aiff\""
}

decode_base64_url() {
  local len=$((${#1} % 4))
  local result="$1"
  if [ $len -eq 2 ]; then result="$1"'=='
  elif [ $len -eq 3 ]; then result="$1"'='
  fi
  echo "$result" | tr '_-' '/+' | base64 -d
}

decode_jwt(){
   decode_base64_url $(echo -n $2 | cut -d "." -f $1) | jq .
}

# Decode JWT header
alias jwth="decode_jwt 1"

# Decode JWT Payload
alias jwtp="decode_jwt 2"

# branch
function br() {
  GIT_BRANCH=$(git symbolic-ref --short HEAD 2> /dev/null)
  if [[ ! -z $GIT_BRANCH ]]; then
      echo "$GIT_BRANCH"
  fi
}

# test environment ssh: Scalr

DEFAULT_TEST_ENV_HOST="test-env.scalr.com"
TE=$DEFAULT_TEST_ENV_HOST
LAST_TE_PORT_FILE=~/.test-env-port

te(){
    if [[ -z "$1" ]] ; then
        if [[ -f $LAST_TE_PORT_FILE ]] ; then
            TE_PORT=$(cat $LAST_TE_PORT_FILE)
            echo "[INFO] Connecting to port: $TE_PORT"
        else
            echo "[ERROR] You must specify port number as a first argument!"
	    return 1
        fi
    else
        TE_PORT=$1
        echo -n "Do you want to save port $TE_PORT? (y/n):"
        read answer
        if [[ "$answer" == "y" ]] ; then
           echo $TE_PORT > $LAST_TE_PORT_FILE
               echo "[INFO] Port $TE_PORT successfuly saved!"
        fi
    fi
    shift;
    set -x
    ssh -i ~/.ssh/scalr_id_rsa -l root -p $TE_PORT ${2:-$DEFAULT_TEST_ENV_HOST} -t 'bash --rcfile ~/.dark_customrc -i' $@
    set +x
}

sync(){
    TE_PORT=$(cat $LAST_TE_PORT_FILE)
    FAM_PATH=/opt/scalr-server/embedded/scalr/app/python/fatmouse
    set -x
    ssh -q -i ~/.ssh/scalr_id_rsa -l root -p $TE_PORT $DEFAULT_TEST_ENV_HOST mkdir -p $FAM_PATH/$(dirname "$1")
    rsync --progress -avz -e "ssh -q -i ~/.ssh/scalr_id_rsa -l root -p $TE_PORT" $PWD/${1:-"server/terraform"} $DEFAULT_TEST_ENV_HOST:$FAM_PATH/${1:-"server/terraform"}
    set +x
}


# Kubernetes functions: Newfire


function exec_pod {
    namespace=$1; shift
    echo "namespace: $namespace"
    pod_name_regexp=${1-'backend-app'}; shift
    echo "pod-regex: $pod_name_regexp"
    pod_name=$(kubectl -n $namespace get pods | grep $pod_name_regexp | grep Running | tail -1 | cut -d " " -f1)
    comm=${@-'bash'}
    echo "executing $comm at $pod_name"
    kubectl -n $namespace exec -it $pod_name $comm
}

function ctail {
	path_=${1-"/opt/scalr-server/var/log/service/tf-*.log"}
	tail -f $path_ | sed -e 's/\(.*FATAL.*\)/\o033[1;31m\1\o033[0;39m/' -e 's/\(.*ERROR.*\)/\o033[31m\1\o033[39m/' -e 's/\(.*WARNING.*\)/\o033[33m\1\o033[39m/' -e 's/\(.*INFO.*\)/\o033[32m\1\o033[39m/' -e 's/\(.*DEBUG.*\)/\o033[34m\1\o033[39m/' -e 's/\(.*Traceback.*\)/\o033[1;39m\1\o033[0;39m/'
}

function paste() {
  local file=${1:-/dev/stdin}
  curl --data-binary @${file} https://paste.rs
}

# mint only
fix_audio () {
  rm -rf ~/.config/pulse && pulseaudio -k
}

function jump_pod () {
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ikova-jump-pod
spec:
  containers:
  - name: shell
    image: ${1:-ubuntu:latest}
    args:
    - sleep
    - "3600"
EOF
}

prune_git_branches() {
    git fetch -p ; git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -d
}
