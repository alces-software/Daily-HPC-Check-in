[![RuboCop Auto Fix](https://github.com/alces-software/Daily-HPC-Check-in/actions/workflows/rubocop.yml/badge.svg)](https://github.com/alces-software/Daily-HPC-Check-in/actions/workflows/rubocop.yml)

# Daily-HPC-Check-in
CLI tool to assist with tasks related to checking clusters

## Usage
- `daily --help` for information about how the commands work
- `daily version` for information about the tool
- `daily start` starts the checklist wizard
- `daily env` starts a wizard to set up environment variables for the tool
- `daily edit` starts a wizard to edit the steps
- `daily who` outputs the person whose turn it is to complete the checklist
- `daily who new` picks a new person in the event the previous person was unavailable
- `daily results <date|target_hpc>` outputs the results for the specified date or a specific HPC if only one value is provided
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

And `bundle install`

Add daily to the $PATH

Add the following to the end of ~/.bashrc: `export PATH="$PATH:~/<PATH_TO_REPO>/bin/"`

And reload the bashrc `source .bashrc`

The program can also be run from `<PATH_TO_REPO>/bin/daily`

### Instructions for obtaining Google Chat Api Key
Daily-HPC-Check-in includes a feature that will automatically send the table of results if a FAILURE has occured.

It will send the results to a specified google chat using a webhook.

To obtain the webhook api key:

1) Navigate to desired google chat
2) Click on the dropdown menu of the chat name (expand chat if dropdown not showing)
3) Select `Apps and integrations`
4) Press `+ Add webhooks`
5) Name webhook and then save
6) Copy generated api key into `.env` file

### ENV file example
You can setup you're .env file using the daily env command or you can create the file yourself and add the following variables:
```env
<!-- Required -->
TESTERS=name1,name2
CLUSTERS=cluster1,cluster2
CLUSTERS_PER_DAY=1
<!-- Optional -->
WEBHOOK_API_KEY=key 
```