#!/usr/bin/env bash

TOOL_NAME="godot"
TOOL_TEST="godot --version"

GODOT_STABLE_REPO="https://github.com/godotengine/godot"
GODOT_PRERELEASE_REPO=https://github.com/godotengine/godot-builds

curl_opts=(-fsSL)
# NOTE: You might want to remove this if godot is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

# Get tags from the official Godot Engine GitHub repository
list_stable_github_tags() {
	git ls-remote --tags --refs "$GODOT_STABLE_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

# Versions from the official Godot Engine GitHub repository
list_stable_versions() {
	list_stable_github_tags
}

# Get tags from the official Godot Engine GitHub pre-releases repository
list_preleases_github_tags() {
	git ls-remote --tags --refs "$GODOT_PRERELEASE_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

# Versions from the official Godot Engine GitHub pre-releases repository
list_preleases_versions() {
	list_preleases_github_tags
}

list_all_versions() {
	list_stable_github_tags
	list_preleases_github_tags
}
