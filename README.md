[![RuboCop Auto Fix](https://github.com/alces-software/Daily-HPC-Check-in/actions/workflows/rubocop.yml/badge.svg)](https://github.com/alces-software/Daily-HPC-Check-in/actions/workflows/rubocop.yml)

# Daily-HPC-Check-in
CLI tool to assist with tasks related to checking clusters

## Usage
- `daily --help` for information about how the commands work
- `daily version` for information about the tool
- `daily start` starts the checklist wizard
- `daily who` outputs the person whose turn it is to complete the checklist
- `daily who new` picks a new person in the event the previous person was unavailable
- `daily results <date>` outputs the results for the specified date or today's results if no date is specified
- `daily results remove <date>` removes the results for the specified date or today's results if no date is specified
- `daily results export <date>` exports the results for the specified date or today's results if no date is specified to a txt file

## Installation

### On Almalinux
Clone the repository

`git clone https://github.com/alces-software/Daily-HPC-Check-in`

Make sure the development tools are installed

`dnf groupinstall "Development Tools"`

Make sure ruby and ruby-devel are installed with a version >= 3.2.0

`dnf install ruby ruby-devel`

If ruby is installing an older version, reset the module stream with

`dnf module reset ruby`

`dnf module enable ruby:3.3`

Run `cd Daily-HPC-Check-in`

and `bundle install`

add daily to the $PATH

add the following to the end of ~/.bashrc: `export PATH="$PATH:~/<PATH_TO_REPO>/bin/`

the program can also be run from `<PATH_TO_REPO>/bin/daily`
