# Daily-HPC-Check-in
CLI tool to assist with tasks related to checking clusters

## Usage
- `daily --help` for information about how the commands work
- `daily version` for information about the tool
- `daily start` starts the checklist wizard
- `daily who` outputs the person whose turn it is to complete the checklist
- `daily who new` picks a new person in the event the previous person was unavailable
- `daily results <date>` outputs the results for the specified date or today's results if no date is specified

## Instalation

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

Run `bundle install`

The project can be run from `./run.sh`