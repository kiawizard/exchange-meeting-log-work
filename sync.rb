#require 'pry'

require 'viewpoint'
require 'jira-ruby'
include Viewpoint::EWS
require_relative 'time_range'

#########################################################
# CONFIG #
##########
exchange_url = 'https://owa.luxoft.com/EWS/Exchange.asmx'
jira_url = 'https://luxproject.luxoft.com'

user = 'ikokorev@luxoft.com'
user_jira = 'ikokorev'
pass = 'somesupersecurepassword'

jira_project = 'SOMEPROJECT'
jira_task = '1234'
#########################################################

exchange = Viewpoint::EWSClient.new(exchange_url, user, pass)
events = exchange.find_items({folder_id: :calendar, calendar_view: {start_date: Date.today, end_date: Date.today+1}}).reject(&:cancelled?)
puts "Total non-cancelled events in calendar today: #{events.size}"
return if events.size == 0

ranges = events.map{|e| TimeRange.new(e.start.to_time, e.end.to_time)}

puts "Calculating total time spent"

some_merges_happened = true
while some_merges_happened
  some_merges_happened = false
  ranges.each do |r1|
    ranges.each do |r2|
      if r1 && r2 && r1 != r2 && r1.overlaps?(r2)
        r1.consume(r2)

        puts "Merged events #{r1} and #{r2}"
        puts "Result is #{r1}"

        ranges.delete(r2)

        some_merges_happened = true
      end
    end
  end
end

total_minutes = ranges.map(&:length_minutes).sum
puts "= #{total_minutes} minutes total"

description = events.map(&:subject).uniq.join(', ')
puts "Work description: #{description}"

if total_minutes > 0
  jira = JIRA::Client.new(username: user_jira, password: pass, site: jira_url, auth_type: :basic)
  task_key = "#{jira_project}-#{jira_task}"
  task = jira.Issue.find(task_key)
  if task.key != task_key
    raise "Failed to find task #{task_key} in JIRA"
  end
  worklog = task.worklogs.build
  worklog.save!(comment: description, timeSpent: "#{total_minutes}m")
  puts "Time logged successfully"
else
  puts "Failed to find any meetings today"
end
