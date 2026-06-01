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
      self.class.instance_variable_set(:@results_template,
                                       JSON.parse(File.open(File.expand_path('../data/templates//results/results.json',
                                                                             __dir__)).read))
      # Loads test template from file
      self.class.instance_variable_set(:@test_template,
                                       JSON.parse(File.open(File.expand_path('../data/templates/results/test.json',
                                                                             __dir__)).read))
      run
    end

    private

    # Runs the wizard
    def run
      # Gets today's date in the correct formatting for the file structure
      date = Date.today.strftime('%d-%m-%Y')
      target_hpc = 'cognition'
      results_path = File.expand_path("../data/results/#{date}/results.json", __dir__)

      # Loads the previous
      results = File.exist?(results_path) ? JSON.parse(File.open(results_path).read) : {}

      if results[target_hpc].nil?
        results[target_hpc] =
          JSON.parse(JSON.generate(self.class.instance_variable_get(:@results_template)))
      else
        puts
        puts 'A daily check-in has already been performed for today use results to view it'
        puts
        return
      end

      # Creates new prompt class
      prompt = TTY::Prompt.new

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
      results[target_hpc]['tester'] = Daily::Scheduler.new.person
      results[target_hpc]['start-time'] = Time.new.utc

      # Gets the steps data
      steps = self.class.instance_variable_get(:@step_data)

      steps = steps.filter do |step|
        !step['procedures'][target_hpc].nil?
      end

      # Get the amount of steps and. current step
      steps_size = steps.length + 1
      step_position = 1

      # Gets the test template
      test_template = self.class.instance_variable_get(:@test_template)

      # Loops through the steps and displays the data that is in the file for the user
      steps.each do |step|
        next if step['procedures'][target_hpc].nil?

        # Select required and optional procedures using the 'necessary' flag
        required_procedure = step['procedures'][target_hpc].filter do |procedure|
          procedure['necessary']
        end

        optional_procedures = step['procedures'][target_hpc].filter do |procedure|
          !procedure['necessary']
        end

        test = test_template.dup
        test['title'] = step['title']

        print "\e[H\e[2J"
        puts
        puts "Step: #{step_position}/#{steps_size}"
        puts '-------------------------------------------------------------------------------'
        puts "Title: #{step['title']}"
        puts "est:   (#{step['estimated-time']})"
        puts '-------------------------------------------------------------------------------'
        puts required_procedure[0]['text']
        puts '-------------------------------------------------------------------------------'
        puts "Healthy: #{required_procedure[0]['outcomes']['good']}"
        puts "Red:     #{required_procedure[0]['outcomes']['bad']}"
        unless optional_procedures.empty?
          selected_procedure = optional_procedures.sample
          puts
          puts '-------------------------------------------------------------------------------'
          puts 'Alternative method'
          puts '-------------------------------------------------------------------------------'
          puts selected_procedure['text']
          puts '-------------------------------------------------------------------------------'
          puts "Healthy: #{selected_procedure['outcomes']['good']}"
          puts "Red:     #{selected_procedure['outcomes']['bad']}"
        end
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

        step_position += 1

        # Push the test result to the results
        results[target_hpc]['results'].push(test)
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
      results[target_hpc]['end-time'] = Time.new.utc

      # Checks whether the results and the current date directory exists and if not creates them
      unless Dir.exist?(File.expand_path('../data/results',
                                         __dir__))
        Dir.mkdir(File.expand_path('../data/results',
                                   __dir__))
      end
      unless Dir.exist?(File.expand_path(
                          "../data/results/#{date}", __dir__
                        ))
        Dir.mkdir(File.expand_path("../data/results/#{date}",
                                   __dir__))
      end

      # Outputs a message telling the user that the results have been saved and where
      puts
      puts "Saving the check-in results to #{results_path}"
      puts

      # Writes the data to the file
      File.write(results_path, JSON.pretty_generate(results))
    end
  end
end
