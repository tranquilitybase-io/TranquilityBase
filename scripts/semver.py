#!/usr/bin/env python

import json
import sys

if len(sys.argv) > 1:
  branch = sys.argv[1]
  branch = branch.lower()
else:
  branch = "patch"

# expected branch prefixes: major/*, feature/*, patch/*, hotfix/*.
# Everything else will be deemed a patch

release_type = "minor"
if branch.startswith("feature/"):
    release_type = "minor"
elif branch.startswith("hotfix/"):
    release_type = "patch"
elif branch.startswith("patch/"):
    release_type = "patch"
elif branch.startswith("major/"):
    release_type = "major"
else:
    release_type = "patch"


default_version_data = \
"""
{
	"version": { "major": 0, "minor": 0, "patch": 0 }
}
"""

# supported types
types = ['major', 'minor', 'patch']


def get_version(release_type_):
	if release_type_ not in types:
		print("Invalid release type: {}!".format(release_type_))
		exit(1)
	try:
		with open("version.json", "r") as fh:
			version = json.load(fh)
	except FileNotFoundError:
		#print("Version file not found, starting from v1.0.0!")
		version = json.loads(default_version_data)
		#print(version)
	except IOError:
		print("IO error, don't know how to deal with this!")
		exit(1)

	if release_type.lower() == "patch":
		version['version']['patch'] = version['version']['patch'] + 1
	elif release_type.lower() == "minor":
		version['version']['minor'] = version['version']['minor'] + 1
		# Patch version MUST be reset to 0 when minor version is incremented.
		version['version']['patch'] = 0
	elif release_type.lower() == "major":
		version['version']['major'] = version['version']['major'] + 1
		# Minor and patch version MUST be reset to 0 when major version is incremented.
		version['version']['minor'] = 0
		version['version']['patch'] = 0

	# write the version file
	try:
		with open("version.json", "w") as fh:
			json.dump(version, fh)
	except IOError:
		print("IO error, don't know how to deal with this!")
		exit(1)
	return version


def as_string(version_):
	return "{0}.{1}.{2}".format(
		version_['version']['major'],
		version_['version']['minor'],
		version_['version']['patch']
	)

v = get_version(release_type_=release_type)
print("{0}".format(as_string(version_=v)))
