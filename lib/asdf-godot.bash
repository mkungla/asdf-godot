#!/usr/bin/env bash
# shellcheck disable=SC1090

# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2025 Marko Kungla
# See the LICENSE file for full licensing details.

# This file is subject to the Apache License Version 2.0, as stated in the LICENSE file
# at the time of creation. Check Git history for further details.

# -----------------------------------------------------------------------------
# Script Information
# -----------------------------------------------------------------------------
# Description: Godot plugin script
# Usage: ./asdf-godot.bash
# Author: Marko Kungla
# Created: 2025-02-02
# Dependencies:
# ScriptType: Source
# Notes:

# -----------------------------------------------------------------------------
# Example Usage
# -----------------------------------------------------------------------------
# ./asdf-godot.bash
#
# -----------------------------------------------------------------------------

set -euo pipefail

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
	awk '
  {
    version = $0
    if (index(version, "-")) {
      pos = index(version, "-")
      base = substr(version, 1, pos - 1)
      suffix = substr(version, pos + 1)
    } else {
      base = version
      suffix = ""
    }
    num_parts = split(base, parts, ".")
    major = (num_parts >= 1 ? parts[1] + 0 : 0)
    minor = (num_parts >= 2 ? parts[2] + 0 : 0)
    patch = (num_parts >= 3 ? parts[3] + 0 : 0)
    type_num = (suffix == "" || suffix == "stable" ? 5 : 0)
    if (type_num == 0) {
      if (match(suffix, /^dev/)) type_num = 1
      else if (match(suffix, /^alpha/)) type_num = 2
      else if (match(suffix, /^beta/)) type_num = 3
      else if (match(suffix, /^rc/)) type_num = 4
      else type_num = 6  # Unknown (post-stable)
    }
    subnum = 0
    if (type_num != 5) {
      temp = suffix
      if (match(temp, /[0-9]+$/)) {
        subnum = substr(temp, RSTART) + 0
      }
    }
    key = sprintf("%02d%02d%02d%01d%03d", major, minor, patch, type_num, subnum)
    print key "|" version
  }
  ' | LC_ALL=C sort -t'|' -k1,1 | awk -F'|' '{print $2}'
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
	# grep -E 'alpha|beta'
}

# Versions from the official Godot Engine GitHub pre-releases repository
list_preleases_versions() {
	list_preleases_github_tags
}

list_all_versions() {
	list_stable_github_tags
	list_preleases_github_tags
}

get_download_filename() {
	local version platform arch join_char
	version="$1"

	platform=$(uname | tr '[:upper:]' '[:lower:]')
	arch=$(uname -m)
	join_char="."

	if [ "${platform}" == 'darwin' ]; then
		platform="macos"
		arch="universal"
	fi

	if [[ "$version" =~ -mono$ ]]; then
		version="${version%-mono}"
		platform="mono_${platform}"

		# MacOS always uses '.' for separator, even for mono
		if [ "$arch" != 'universal' ]; then
			join_char="_"
		fi
	fi

	echo "Godot_v${version}_${platform}${join_char}${arch}.zip"
}

download_stable_release() {
	local version dl_filename dl_url
	version="$1"
	dl_filename="$2"
	dl_url="${GODOT_STABLE_REPO}/releases/download/${version}/${dl_filename}"

	echo "* Downloading Godot release ${version}... ($dl_filename)"
	curl "${curl_opts[@]}" -o "${ASDF_DOWNLOAD_PATH}/${dl_filename}" -C - "$dl_url" || fail "Failed to download Godot from $dl_url"
}

download_prerelease() {
	local version dl_filename dl_url
	version="$1"
	dl_filename="$2"
	dl_url="${GODOT_PRERELEASE_REPO}/releases/download/${version}/${dl_filename}"

	echo "* Downloading Godot pre-release ${version}... ($dl_filename)"
	curl "${curl_opts[@]}" -o "${ASDF_DOWNLOAD_PATH}/${dl_filename}" -C - "$dl_url" || fail "Failed to download Godot from $dl_url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "${ASDF_DOWNLOAD_PATH}"/* "$install_path"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"

		platform=$(uname | tr '[:upper:]' '[:lower:]')
		if [ "${platform}" == "darwin" ]; then
			ln -s "${install_path}/Godot.app/Contents/MacOS/Godot" "$install_path/${tool_cmd}"
		fi

		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."
		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)

}

post_install() {
	platform=$(uname | tr '[:upper:]' '[:lower:]')
	if [ "$platform" != "linux" ]; then
		return
	fi

	# Potentially we could install these something like "Godot (asdf)"
	# install -D -m644 icon.svg \
	#     %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/%{name}.svg
	# install -D -m644 misc/dist/linux/%{rdnsname}.desktop \
	#     %{buildroot}%{_datadir}/applications/%{rdnsname}.desktop
	# install -D -m644 misc/dist/linux/%{rdnsname}.appdata.xml \
	#     %{buildroot}%{_datadir}/metainfo/%{rdnsname}.appdata.xml
	# install -D -m644 misc/dist/linux/%{rdnsname}.xml \
	#     %{buildroot}%{_datadir}/mime/packages/%{rdnsname}.xml
	# install -D -m644 misc/dist/linux/%{name}.6 \
	#     %{buildroot}%{_mandir}/man6/%{name}.6
	# install -D -m644 misc/dist/shell/%{name}.bash-completion \
	#     %{buildroot}%{_datadir}/bash-completion/completions/%{name}
	# install -D -m644 misc/dist/shell/%{name}.fish \
	#     %{buildroot}%{_datadir}/fish/vendor_completions.d/%{name}.fish
	# install -D -m644 misc/dist/shell/_%{name}.zsh-completion \
	#     %{buildroot}%{_datadir}/zsh/site-functions/_%{name}

}
