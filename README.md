<div align="center">

# asdf-godot [![Build](https://github.com/mkungla/asdf-godot/actions/workflows/build.yml/badge.svg)](https://github.com/mkungla/asdf-godot/actions/workflows/build.yml) [![Lint](https://github.com/mkungla/asdf-godot/actions/workflows/lint.yml/badge.svg)](https://github.com/mkungla/asdf-godot/actions/workflows/lint.yml)

[godot](https://github.com/mkungla/asdf-godot/documentation) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add godot
# or
asdf plugin add godot https://github.com/mkungla/asdf-godot.git
```

godot:

```shell
# Show all installable versions
asdf list-all godot

# Install specific version
asdf install godot latest

# Set a version globally (on your ~/.tool-versions file)
asdf global godot latest

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
