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
		sed 's/^v//' |
		grep -E 'alpha|beta'
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
	local version
	version="$1"

	platform=$(uname | tr '[:upper:]' '[:lower:]')
	# platform="darwin"

	if [ "${platform}" == 'darwin' ]; then
		echo "Godot_v${version}_macos.universal.zip"
		exit 0
	fi
	arch=$(uname -m)

	echo "Godot_v${version}_${platform}.${arch}.zip"
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
		cp -r "${ASDF_DOWNLOAD_PATH}/*" "$install_path"

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
