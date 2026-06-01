# frozen_string_literal: true

require 'json'
require 'time'
require 'dotenv'
require 'pastel'
require 'terminal-table'
require 'tty-prompt'
require 'net/http'
require 'uri'

module Daily
  class Results
    def initialize(date: nil, target_hpc: nil)
      env = Dotenv.load(File.expand_path('../.env', __dir__))
      @WEBHOOK_URL = env['WEBHOOK_API_KEY']
      @date = date || Date.today.strftime('%d-%m-%Y')
      @target_hpc = target_hpc

      if Dir.exist?(File.expand_path('../data/results', __dir__))
        @base_path = File.expand_path('../data/results', __dir__)
        run
      else
        puts 'No data to display. Perform checks to display results.'
      end
    end

    private

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

      def load_data
        @data = JSON.parse(File.read(File.expand_path("../data/results/#{@date}/results.json", __dir__)))
      end

      def render_results
        output = []
        failed_results = []

        if !@target_hpc.nil? && @data[@target_hpc].nil?
          puts 'The target HPC you requested has no results available for it'
          return
        end

        results = @target_hpc.nil? ? @data : { @target_hpc => @data[@target_hpc] }

        if results.nil? || results.empty?
          puts 'No data can be found'
          return
        end

        results.each do |hpc, result|
          failed = false
          start_time = Time.parse(result['start-time'])
          end_time   = Time.parse(result['end-time'])

          diff = end_time - start_time

          hours   = (diff / 3600).to_i
          minutes = (diff % 3600) / 60
          seconds = diff % 60

          pastel = Pastel.new(enabled: $stdout.tty?)

          rows = []
          rows << ['Tester', result['tester']]
          rows << ['HPC', result['hpc']]
          rows << ['Date', @date]
          rows << ['Start', start_time.utc.strftime('%H:%M:%S')]
          rows << ['End', end_time.utc.strftime('%H:%M:%S')]
          rows << ['Duration', format('%02d:%02d:%02d', hours, minutes, seconds)]

          details_table = Terminal::Table.new title: 'Test details', rows: rows

          output.push(details_table)

          tasks = []

          result['results'].each do |step|
            if step['passed']
              tasks << [
                pastel.green('PASS'),
                pastel.green(step['title']),
                step['notes']
              ]
            else
              failed = true

              tasks << [
                pastel.bold.red('FAIL'),
                pastel.bold.red(step['title']),
                step['notes']
              ]
            end
          end

          results_table = Terminal::Table.new title: "#{hpc} results for #{@date}",
                                              headings: %w[Outcome Task Notes], rows: tasks

          output.push(results_table)

          failed_results.push([details_table, results_table]) if failed
        end

        output.each do |out|
          puts out
        end

        export = TTY::Prompt.new.yes?('Export to file?')

        if !failed_results.empty? && Date.strptime(@date, '%d-%m-%Y') == Time.now.utc.to_date && !@WEBHOOK_URL.nil?
          failed_results.each do |hpc|
            send_results(hpc[0], hpc[1])
          end
        end

        return unless export

        Dir.mkdir(File.expand_path('../data/results_text', __dir__)) unless Dir.exist?(File.expand_path(
                                                                                         "../data/results/#{@date}", __dir__
                                                                                       ))
        File.write(File.expand_path("../data/results/#{@date}/results.txt", __dir__),
                   output.join("\n").gsub(/\e\[[0-9;]*m/, ''))
        puts "Results exported to /data/results/#{@date}/results.txt"
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

      load_data
      render_results
    end
  end
end
