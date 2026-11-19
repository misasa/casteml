# casteml

[![GPL-3.0-or-later](https://img.shields.io/badge/license-GPL--3.0--or--later-green.svg)](LICENSE.txt)

Command-line utilities for CASTEML datasets. Convert, combine, and split
datasets locally, and transfer analyses to and from Medusa.

## Requirements

- Ruby 2.6 through 4.0. See the compatibility notes below for individual commands.
- [medusa_rest_client](https://github.com/misasa/medusa_rest_client) 1.5.4 or later in the 1.x series.
- For plotting, R on your PATH. For PDF tables, `pdflatex` and the `pmlatex` LaTeX package.

### Compatibility notes

- `casteml plot` cannot load its R template on Ruby 3.2 or later because it calls
  `File.exists?`, which Ruby removed.
- `casteml spots` cannot initialize its command-line options on Ruby 4.0 because
  it calls `Object#=~` on an option type.
- The gem uses CSV 0.0.1 and ERB below 5 because its existing calls pass options
  positionally. Gems that require a different CSV version need a separate bundle.

## Installation

Download the gem from [GitHub Releases](https://github.com/misasa/casteml/releases).
From a checkout, run the download script to verify the SHA-256 manifest before
saving the files:

```sh
bash script/download_release.sh --version 1.1.3
```

Download `medusa_rest_client-1.5.4.gem` from its
[v1.5.4 release](https://github.com/misasa/medusa_rest_client/releases/tag/v1.5.4)
and install it before installing Casteml:

```sh
gem install ./medusa_rest_client-1.5.4.gem
gem install ./casteml-1.1.3.gem
```

For commands that connect to Medusa, put the server URL and your credentials in
`~/.orochirc`:

```yaml
---
uri: https://medusa.example.org
user: YOUR_USERNAME
password: YOUR_PASSWORD
```

## Commands

| Command | Description |
| --- | --- |
| `casteml convert` | Convert PML, CSV, TSV, Org, or ISORG input to another format. |
| `casteml spots` | Write a LaTeX overlay for spots and isocircles. |
| `casteml join` | Combine acquisitions from PML files into one PML file. |
| `casteml split` | Write one PML file per acquisition alongside the input file. |
| `casteml upload` | Save analyses and their measurements to Medusa. |
| `casteml download` | Download analyses for one or more Medusa records. |
| `casteml plot` | Generate a data table and R script, then run R. |

Run `casteml --help` for an overview or `casteml convert --help` for a
command's options and examples.

## Development

The Gemfile uses the public GitHub tag for `medusa_rest_client`. Use Bundler
2.4.22 on Ruby 2.6 or 2.7.

```sh
bundle install
bundle exec rspec
bundle exec rake build
bundle exec ruby script/verify_package.rb
```

Package verification installs the archive in a temporary gem directory, checks
the installed CLI and version, and converts a sample PML file to CSV offline.

## CI and releases

GitHub Actions runs the test suite on Ruby 2.6.10, 2.7.8, 3.2, 3.3, 3.4, and
4.0. The workflow builds and verifies the gem, then uploads the
`casteml-gem` artifact.

Pushing a stable tag such as `v1.1.3` on a commit in `master` starts the
Release job. The tag must match the gem version. The job checks for an
existing release, uploads the gem and its SHA-256 manifest to a draft,
and publishes only after downloading and comparing both assets.
