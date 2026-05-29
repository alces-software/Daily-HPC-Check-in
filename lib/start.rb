# frozen_string_literal: true

require 'json'
require 'date'
require 'tty-prompt'
require_relative 'scheduler'

module Daily
  class Start
    # Initializes the wizard class
    def initialize
      # Loads step data from file
      self.class.instance_variable_set(:@step_data,
                                       JSON.parse(File.open(File.expand_path('../data/shared/steps.json',
                                                                             __dir__)).read))
      # Loads results template from file
      self.class.instance_variable_set(:@results,
                                       JSON.parse(File.open(File.expand_path('../data/templates/results.json',
                                                                             __dir__)).read))
      # Loads test template from file
      self.class.instance_variable_set(:@test_template,
                                       JSON.parse(File.open(File.expand_path('../data/templates/test.json',
                                                                             __dir__)).read))
      run
    end

    private

    # Runs the wizard
    def run
      # Gets today's date in the correct formatting for the file structure
      date = Date.today.strftime('%d-%m-%Y')

      # Checks if the result file exists from today and if it does displays and error message
      if File.exist?(File.expand_path("../data/results/#{date}/results.json", __dir__))
        puts
        puts 'A daily check-in has already been performed for today use results to view it'
        puts
        return
      end

      # Gets all the relevant data for the tests
      steps = self.class.instance_variable_get(:@step_data)
      results = self.class.instance_variable_get(:@results)
      test_template = self.class.instance_variable_get(:@test_template)

      # Creates new prompt class
      prompt = TTY::Prompt.new

      # Get the amount of steps and. current step
      steps_size = steps.length + 1
      step_position = 1

      # Displays a message to user to ask if they are ready to start
      print "\e[H\e[2J"
      puts
      puts '-------------------------------------------------------------------------------'
      puts 'Connect to cognition HPC using: ssh cognition'
      puts '-------------------------------------------------------------------------------'
      puts

      unless prompt.yes?('Are you ready to start the wizard?')
        puts
        puts 'Ok closing out of the wizard start again when you are ready'
        puts
        return
      end

      # Adds the name of the tester and the current data and time to the results
      results['tester'] = Daily::Scheduler.new.person
      results['start-time'] = Time.new.utc

      # Loops through the steps and displays the data that is in the file for the user
      steps.each do |step|
        test = test_template.dup
        test['title'] = step['title']

        print "\e[H\e[2J"
        puts
        puts "Step: #{step_position}/#{steps_size}"
        puts '-------------------------------------------------------------------------------'
        puts "Title: #{step['title']}"
        puts "est:   (#{step['estimated-time']})"
        puts '-------------------------------------------------------------------------------'
        puts step['procedures'][0]['text']
        puts '-------------------------------------------------------------------------------'
        puts "Healthy: #{step['procedures'][0]['outcomes']['good']}"
        puts "Red:     #{step['procedures'][0]['outcomes']['bad']}"
        puts

        # Gathers passed information from user and adds it to the test result
        test['passed'] = prompt.yes?('Did this test pass?')

        # If user wants to add notes to the test collect them and add them to the test result
        if prompt.yes?('Do you have any notes?', default: false)
          input = prompt.multiline('Enter your notes here:') do |q|
            q.required true
            q.modify :strip
          end
          test['notes'] = input.join('')
        end

        # Push the test result to the results
        results['results'].push(test)
        step_position += 1
      end

      # Display final message to user
      print "\e[H\e[2J"
      puts
      puts "Step: #{step_position}/#{steps_size}"
      puts '-------------------------------------------------------------------------------'
      puts 'Title: Final Notes / Escalation'
      puts '-------------------------------------------------------------------------------'
      puts 'Green day → Log: "Daily user check complete - no issues"'
      puts 'Any RED item → Report immediately to OPS with exact command output'
      puts

      prompt.ask('Press enter to save check results and exit out')

      # Adds the current time and date once finished to the results file
      results['end-time'] = Time.new.utc

      # Checks whether the results and the current date directory exists and if not creates them
      Dir.mkdir(File.expand_path('../data/results', __dir__)) unless Dir.exist?(File.expand_path('../data/results',
                                                                                                 __dir__))
      Dir.mkdir(File.expand_path("../data/results/#{date}", __dir__)) unless Dir.exist?(File.expand_path(
                                                                                          "../data/results/#{date}", __dir__
                                                                                        ))

      # Outputs a message telling the user that the results have been saved and where
      puts
      puts "Saving the check-in results to #{File.expand_path("data/results/#{date}/results.json")}"
      puts

      # Writes the data to the file
      File.write(File.expand_path("../data/results/#{date}/results.json", __dir__),
                 JSON.pretty_generate(results, max_nesting: false))
    end
  end
end
