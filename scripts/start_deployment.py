#!/usr/bin/env python
# pre-requisites: docker should be initialized with the Google Container registry.
# This script is re-runnable, if you get any docker errors and there are tags missing, you can rerun the script.
# Ensure the script runs in the root folder of the TranquilityBase-io repo.
# Run script, to see what docker commands will be run:
# scripts/start_deployment.py -f config/deployment.ini -b feature/houston-91 
# When you want to commit the changes, add --commit to the command and run:
#scripts/start_deployment.py -f config/deployment.ini -b feature/houston-91 --commit

import os
import sys
import configparser
import argparse
import json
from pprint import pprint
from semver import Semver

def apply_new_tag(tag, next_version, commit=False):
    print(f"processing tag: {tag}")
    #print(f"versioned: {config.get(s, 'versioned')}")
    #print(f"images: {config.get(s, 'images')}")
    images = json.loads(config.get(s, 'images'))
    for img in images:
        (repo, t) = img.split(":")
        sv = ""
        if config.get(s, 'versioned').lower() == 'true':
          sv = next_version
        pull_cmd = f"docker pull {img}"
        print(pull_cmd)
        if commit:
            os.system(pull_cmd)
        tag_cmd = f"docker tag {img} {repo}:{tag}{sv}"
        print(tag_cmd)
        if commit:
            os.system(tag_cmd)
        push_cmd = f"docker push {repo}:{tag}{sv}"
        print(push_cmd)
        if commit:
            os.system(push_cmd)
        git_cmd = f"scripts/create_git_tag.sh {repo} {tag}{sv}"
        print(git_cmd)
        if commit:
            os.system(git_cmd)
        print("")

def purge_image_with_tag(tag):
    images = json.loads(config.get(s, 'images'))


ap = argparse.ArgumentParser()
ap.add_argument('-f', '--filename', metavar='<filename>', type=str, required=True, help="The deployment config file.") 
ap.add_argument('-b', '--branch_name', metavar='<branch_name>', type=str, required=True, help="The branch name.") 
ap.add_argument('-c', '--commit', action='store_true', help="Commit changes.") 
args = ap.parse_args()
print(f"Using config ini file: {args.filename}")
print(f"Using branch: {args.branch_name}")
# The type of args.commit is boolean
print(f"commit: {args.commit}")

sv = Semver()
nver = sv.get_next_version_from_branch(args.branch_name)
next_ver = f"{sv.as_string()}"

config = configparser.ConfigParser()
config.read(args.filename)

for s in config.sections():
    if config.get(s, 'active') == 'true':
        apply_new_tag(s, next_ver, commit=args.commit)
        if args.commit:
            sv.commit()
        purge_image_with_tag(s)
