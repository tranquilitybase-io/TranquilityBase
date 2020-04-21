#/bin/bash
# parameters: 
# 1: repo
# 2: existing tag
# 3: new tag

repo=${1}
existing_tag=${2}
new_tag=${3}
mkdir -p workspace
cd workspace
git clone https://github.com/tranquilitybase-io/${repo}
cd ${repo}
git checkout -b ${existing_tag}
git tag -a "${new_tag}" -m "Tagged by create_git_tag.sh script"
git push --set-upstream origin "${new_tag}"
git merge master 
git checkout master
cd --
rm -r workspace
