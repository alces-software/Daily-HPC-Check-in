# frozen_string_literal: true

require 'bundler/setup'
require 'dry/cli'
require 'json'
require 'time'
require 'pastel'
require 'terminal-table'
require 'tty-prompt'

require 'net/http'
require 'uri'

module Daily
  class Results
    def initialize(date: nil)
      @date = date || Date.today.strftime('%d-%m-%Y')
      @WEBHOOK_URL = "https://chat.googleapis.com/v1/spaces/AAQAflTaMjQ/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=-RQg2koh_yYkbtsm7mMuH4uDHep_sGQnsUWeW8KLLkg"
      @failed = false
      if Dir.exist?(File.expand_path('../data/results', __dir__))

        @base_path = File.expand_path('../data/results', __dir__)
        run
      else
        puts 'No data to display. Perform checks to display results.'
      end
    end

    def run
      today = Time.now.utc.to_date
      parsed_date = begin
        Date.strptime(@date, '%d-%m-%Y')
      rescue StandardError
        nil
      end

      unless parsed_date
        puts 'Enter a valid date (DD-MM-YYYY)'
        return
      end

      if parsed_date > Date.today
        puts 'Invalid: cannot enter a future date'
        return
      end

      file_path = File.join(@base_path, @date, 'results.json')

      unless File.exist?(file_path)
        if parsed_date == today
          puts "Today's system check pending..."
        else
          puts "No entry found for #{@date}"
        end
        return
      end

      def load_data(file_path)
        file_path = File.expand_path("../data/results/#{@date}/results.json", __dir__)
        @data = JSON.parse(File.read(file_path))
      end

      def render_results

        start_time = Time.parse(@data['start-time'])
        end_time   = Time.parse(@data['end-time'])

        diff = end_time - start_time

        hours   = (diff / 3600).to_i
        minutes = (diff % 3600) / 60
        seconds = diff % 60

        pastel = Pastel.new(enabled: STDOUT.tty?)

        rows = []
        rows << ['Tester', @data['tester']]
        rows << ['Date', @date]
        rows << ['Start', start_time.utc.strftime('%H:%M:%S')]
        rows << ['End', end_time.utc.strftime('%H:%M:%S')]
        rows << ['Duration', format('%02d:%02d:%02d', hours, minutes, seconds)]

        details_table = Terminal::Table.new title: 'Test details', rows: rows

        puts details_table

        tasks = []


        @data['results'].each do |result|
          if result['passed']
            tasks << [
              pastel.green('PASS'),
              pastel.green(result['title']),
              result['notes']
            ]
          else
            @failed = true
            
            tasks << [
              pastel.bold.red('FAIL'),
              pastel.bold.red(result['title']),
              result['notes']
            ]
          end
        end


        results_table = Terminal::Table.new title: "Results for #{@date}",
                                            headings: %w[Outcome Task Notes], rows: tasks
        puts results_table
        prompt = TTY::Prompt.new

        export = prompt.yes?("Export to file?")

        if @failed && Date.strptime(@date, '%d-%m-%Y') == Time.now.utc.to_date
         send_results(details_table, results_table)
        end
        

        if export
          Dir.mkdir(File.expand_path('../data/results_text', __dir__)) unless Dir.exist?(File.expand_path('../data/results_text',__dir__))
          File.write(File.expand_path("../data/results_text/#{@date}.txt", __dir__), "#{details_table}\n\n#{results_table}".gsub(/\e\[[0-9;]*m/, ''))
          puts "Results exported to /data/results_text/#{@date}.txt"
        end
      end

      def send_results(details, results)
         uri = URI(@WEBHOOK_URL)
          
          message = {
            text: "```!URGENT!\n\n#{details}\n\n#{results}```".gsub(/\e\[[0-9;]*m/, '')
          }
          
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
        
          request = Net::HTTP::Post.new(uri)
          request['Content-Type'] = 'application/json'
          request.body = message.to_json
        
          response = http.request(request)
        
          puts "Response: #{response.code}"
      end

      load_data(file_path)
      render_results

    end
  end
end
