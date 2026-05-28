# frozen_string_literal: true

require 'json'
require 'date'
require 'tty-prompt'

module Daily
  class Start
    def initialize
      steps_file = File.open File.expand_path('data/shared/steps.json')
      self.class.instance_variable_set(:@step_data, JSON.parse(steps_file.read))

      results_template_file = File.open File.expand_path('data/templates/results.json')
      self.class.instance_variable_set(:@results, JSON.parse(results_template_file.read))

      test_template_file = File.open File.expand_path('data/templates/test.json')
      self.class.instance_variable_set(:@test_template, JSON.parse(test_template_file.read))
      run
    end

    private

    def run
      date = Date.today.strftime('%d-%m-%Y')

      if File.exist?(File.expand_path("data/results/#{date}/results.json"))
        puts
        puts 'A daily check-in has already been performed for today use results to view it'
        puts
        return
      end

      steps = self.class.instance_variable_get(:@step_data)
      results = self.class.instance_variable_get(:@results)
      results['start-time'] = Time.new.utc
      test_template = self.class.instance_variable_get(:@test_template)
      prompt = TTY::Prompt.new

      steps.each do |step|
        test = test_template.dup
        test['title'] = step['title']

        print "\e[H\e[2J"
        puts
        puts '-------------------------------------------------------------------------------'
        puts "Title: #{step['title']}"
        puts "est:   (#{step['estimated-time']})"
        puts '-------------------------------------------------------------------------------'
        puts step['procedures'][0]['text']
        puts '-------------------------------------------------------------------------------'
        puts "Healthy: #{step['procedures'][0]['outcomes']['good']}"
        puts "Red:     #{step['procedures'][0]['outcomes']['bad']}"
        puts

        test['passed'] = prompt.yes?('Did this test pass?') do |q|
          q.required true
        end

        results['results'].push(test)
      end

      print "\e[H\e[2J"
      puts
      puts '-------------------------------------------------------------------------------'
      puts 'Title: Final Notes / Escalation'
      puts '-------------------------------------------------------------------------------'
      puts 'Green day → Log: "Daily user check complete – no issues"'
      puts 'Any RED item → Report immediately to OPS with exact command output'
      puts

      prompt.yes?('Are you finished?') do |q|
        q.required true
      end

      results['end-time'] = Time.new.utc

      Dir.mkdir(File.expand_path('data/results')) unless Dir.exist?(File.expand_path('data/results'))
      Dir.mkdir(File.expand_path("data/results/#{date}")) unless Dir.exist?(File.expand_path("data/results/#{date}"))

      puts
      puts "Saving the check-in results to #{File.expand_path("data/results/#{date}/results.json")}"
      puts

      File.write(File.expand_path("data/results/#{date}/results.json"),
                 JSON.pretty_generate(results, max_nesting: false))
    end
  end
end
