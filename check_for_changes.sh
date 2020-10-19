#!/bin/bash

## Das wäre der $DRONE_COMMIT_AFTER
commit=$(git rev-parse --verify HEAD)

PLUGIN_START=$1

changed_files=$(git diff-tree --no-commit-id --name-only -r $commit)

tmpfile=$(mktemp /tmp/abc-script.XXXXXX)

for i in ${changed_files[@]}
do
 printf "%s\n" "$(echo $i | cut -d '/' -f 1)" >> "$tmpfile"
done

IFS=$'\r\n' GLOBIGNORE='*' command eval  'a=($(cat "$tmpfile"))'

rm "$tmpfile"

echo ${#a[@]}

if [[ ${PLUGIN_START} == "base" ]] || [[ ${PLUGIN_START} == "nginx" ]]
then
    UPSTREAM_IMAGE=
elif [[ ${PLUGIN_START} == "r-3.6.1" ]]
then
    UPSTREAM_IMAGE+=("base")
elif [[ ${PLUGIN_START} == "rpkg" ]]
then
    UPSTREAM_IMAGE=("base" "r-3.6.1")
elif [[ ${PLUGIN_START} == "rstudio-server-pro" ]] || [[ ${PLUGIN_START} == "rsconnect" ]]
then
    UPSTREAM_IMAGE=("base" "r-3.6.1" "rpkg")
fi

iscontained() {
  for i in "$1"
  do
    if [[ "$i" =~ "$2"* ]] ; then
      echo 0;
      else echo 1
    fi
  done
  }

C=($(comm -12 <(printf '%s\n' "${a[@]}" | LC_ALL=C sort) <(printf '%s\n' "${UPSTREAM_IMAGE[@]}" | LC_ALL=C sort)))

echo ${#C[@]}

if [[ "$(iscontained "${changed_files}" "${PLUGIN_START}")" != 0 ]] || [[ "$(echo ${#C[@]})" > 0 ]]; then
  exit 78
  else echo "${PLUGIN_START} is contained in the changed files an no upstream image has changed"
fi
