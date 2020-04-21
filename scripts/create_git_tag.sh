#/bin/bash
# parameters: 
# 1: repo
# 2: existing tag
# 3: new tag

clean_branch () {
	remote_name=$1
	branch_name=$2
	git push -d $remote_name $branch_name
	git branch -d $branch_name
}

repo=${1}
existing_tag=${2}
new_tag=${3}

if [[ -d workspace ]]; then
	rm -r workspace 
fi

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
