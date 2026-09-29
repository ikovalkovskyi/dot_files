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


function paste() {
  local file=${1:-/dev/stdin}
  curl --data-binary @${file} https://paste.rs
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
