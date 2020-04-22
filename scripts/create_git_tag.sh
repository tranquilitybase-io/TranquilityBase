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
git checkout -b temp
# remove the "new tag" if it already exists, to allow the script to be rerunable
git tag --list
if [[ ! $(git tag --list | egrep -q "^{new_tag} >/dev/null 2>&1") ]]; then
  echo "Tag ${new_tag} found, deleting..."
  git tag -d "${new_tag}"
  git push --tag origin  :"${new_tag}"
fi
echo "${repo}"
cat version.json
# Now create the new tag
git tag -a "${new_tag}" -m "Tagged by create_git_tag.sh script"
git merge temp
# checkout master so that we can delete the temp branch
git checkout master
git branch --delete temp
cd --
