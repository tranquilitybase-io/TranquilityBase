#/bin/bash -x
# parameters: 
# 1: repo
# 2: existing tag
# 3: new tag
#
# Delete a remote tag
# git push --delete origin v0.0.1

clean_branch () {
	remote_name=$1
	branch_name=$2
	git push -d $remote_name $branch_name
	git branch -d $branch_name
}

repo=${1}
existing_tag=${2}
new_tag=${3}

mkdir -p deployment_workspace 
cd deployment_workspace
rm -fr "${repo}"

if [[ ! $(git ls-remote "https://github.com/tranquilitybase-io/${repo}") ]]; then
  echo "exit..."
  exit 0
fi

git clone https://github.com/tranquilitybase-io/${repo}
cd ${repo}
git fetch
git checkout ${existing_tag}
# remove the "new tag" if it already exists, to allow the script to be rerunable
if [[ ! $(git rev-parse --verify "${new_tag}") ]]; then
  git branch --delete "${new_tag}"
fi
# Now create the new tag
git tag -a "${new_tag}" -m "Tagged by create_git_tag.sh script"
git push --set-upstream origin "${new_tag}"
git merge master 
git checkout master
if [[ ! $(git rev-parse --verify "${new_tag}") ]]; then
  git branch --delete "${new_tag}"
fi
cd --
