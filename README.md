# gem package -- casteml
[![GPL v3](https://img.shields.io/badge/license-GPL_v3-green.svg)](http://www.gnu.org/licenses/gpl-3.0.txt)

A series of comprehensive utilities that handles CASTEML.

# Description

A series of comprehensive utilities that handles CASTEML.  The
utilities download/upload datasets from/to Medusa.  The utilities
join, split, and convert datasets.

# Dependency

## [Ruby](https://www.ruby-lang.org "follow instruction")
Ruby 2.5, 2.6, or 2.7.

## [gem package -- medusa_rest_client](https://github.com/misasa/medusa_rest_client "follow instruction")

# Installation

Install it yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/
    $ gem install casteml

The program reads a configuration file `~/.orochirc`.  The file should look like below.

    ---
    uri: https://dream.misasa.okayama-u.ac.jp/demo
    user: admin
    password: admin

# Commands

Commands are summarized as:

| command          | description                                 | note                       |
|------------------|---------------------------------------------|----------------------------|
| casteml convert  | Transform CSV, TSV, ORG, ISORG, and pmlfile |                            |
| casteml spots    | Create a LaTeX file with spots from pmlfile | isocircle option available |
| casteml join     | Create a multi-pmlfile from single pmlfiles |                            |
| casteml split    | Create single pmlfiles from a multi-pmlfile |                            |
| casteml upload   | Upload pmlfile to Medusa                    |                            |
| casteml download | Download pmlfile from Medusa                |                            |
| casteml plot     | Make a plot using pmlfile                   |                            |

# Usage

See online document with option `--help`.

# Developer's guide

1. Run test as shown below.

```
$ cd ~/devel-godigo/gems/casteml
$ bundle install --path vendor/bundle
$ bundle exec rspec spec/casteml/command_manager_spec.rb
$ bundle exec rspec spec/casteml/commands/convert_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/spots_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/join_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/split_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/upload_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/download_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/plot_command_spec.rb --tag show_help:true
```

2. Push to the Git server.

3. Access to Jenkins server http://devel.misasa.okayama-u.ac.jp/jenkins/job/Casteml/ and run a job.  This is scheduled and if you are not in hurry, skip further steps.

4. Uninstall and install local gem module as shown below.

```
$ sudo gem uninstall casteml
$ sudo gem install casteml
```
