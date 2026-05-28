# frozen_string_literal: true

require 'bundler/setup'
require 'dry/cli'
require "json"
require "time"

require_relative '../lib/start'

require "pastel"
require "terminal-table"

module Daily
  class Results 
        

        def call(date: nil)

        

          file_path = File.expand_path('../data/templates/results_test.json', __dir__)
          data = JSON.parse(File.read(file_path))
          pastel = Pastel.new

          date ||= Time.now.utc.to_date.to_s

          entry = false
        
          
          data.each do |run|

            run_date = Time.iso8601(run['start-time']).utc.to_date.to_s
            next if run_date != date

            start_time = Time.iso8601(run['start-time'])
            end_time   = Time.iso8601(run['end-time'])

            diff = end_time - start_time

            hours   = (diff / 3600).to_i
            minutes = (diff % 3600) / 60
            seconds = diff % 60

            entry = true

            rows = []
            rows << ["Tester", run['tester']]
            rows << ["Date", Time.parse(run["start-time"]).utc.to_date]
            rows << ["Start", start_time.utc.strftime("%H:%M:%S")]
            rows << ["End", end_time.utc.strftime("%H:%M:%S")]
            rows << ["Duration", format('%02d:%02d:%02d', hours, minutes, seconds)]

            details_table = Terminal::Table.new :title => "Test details", :rows => rows

            puts details_table

            tasks = []

            run['results'].each do |result|
              status = result['passed'] ? "PASS" : "FAIL"
              if status == "PASS"
                tasks << [pastel.green(status), pastel.green(result['title']), result['notes']]
              else
                tasks << [pastel.bold.red(status), pastel.bold.red(result['title']), result['notes']]
              end
            end
            results_table = Terminal::Table.new :title => "Results for #{date}", :headings => ['Outcome', 'Task', 'Notes'], :rows => tasks
            puts results_table
          end
          puts "Today's system check pending..." unless entry
        end
      end
    end
  

