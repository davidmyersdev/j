# j

Quickly navigate your filesystem with the power of fzf (inspired by autojump)

![](j.svg)

## Usage

```sh
Usage: j [-h] [--help] <pattern>

Quickly navigate your filesystem with the power of fzf.

Options

  -h, --help  View options and examples

Examples

  j -h
  j somedir
  j ../relative/path/to/dir
```

`j` does not index your filesystem. Instead, it automatically tracks and ranks the directories you visit in a local database (a text file at `~/.j/db`).

## Installation

To get started, clone this repository.

```sh
git clone https://github.com/voracious/j && cd j
```

Next, source `j.sh` in your `~/.zshrc`.

```sh
echo "source $(pwd)/j.sh" >> ~/.zshrc
```
