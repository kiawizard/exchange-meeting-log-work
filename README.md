# exchange-meeting-log-work
Logs work in JIRA using Microsoft Exchange Meetings time and description

Installation (Windows)

1) Install Chocolatey (https://chocolatey.org/install)
2) > choco install ruby --version '2.6.5.1'
3) go to the project folder
4) > bundle install
5) edit sync.rb to make sure all variables in CONFIG section are correct
6) configure your scheduler to run "ruby sync.rb" at the end of each day