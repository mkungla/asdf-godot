<div align="center">

# asdf-godot 

[Godot](https://godotengine.org/) plugin for the [asdf version manager](https://asdf-vm.com).

[![Build](https://github.com/mkungla/asdf-godot/actions/workflows/main.yml/badge.svg)](https://github.com/mkungla/asdf-godot/actions/workflows/main.yml)


Plugin enables you to manage and install multiple versions of Godot Game Engine. You can install both stable and pre-releases of Godot Game Engine
</div>

# Contents

- [asdf-godot](#asdf-godot)
- [Contents](#contents)
- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `unzip`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).


# Install

Plugin:

```shell
asdf plugin add godot
# or
asdf plugin add godot https://github.com/mkungla/asdf-godot.git
```

**godot:**

```shell
# Show all installable versions
asdf list all godot

# Install specific version
asdf install godot latest

# Set a version globally (on your ~/.tool-versions file)
asdf set -u godot latest

# Now godot commands are available
godot --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/mkungla/asdf-godot/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Marko Kungla](https://github.com/mkungla/)
