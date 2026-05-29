# frozen_string_literal: true

require 'json'
require 'date'

module Daily
  # Scheduler is responsible for loading the daily check-in roster from
  # data/schedule.json, choosing a random person whose completed state is
  # false, and updating the schedule to reflect the selected person and
  # today's date. If all people have been completed, it resets the
  # completed flags and retries selection.
  class Scheduler
    attr_reader :person

    def initialize
      loadschedule

      if !generated_today
        pick_new
      else
        @person = @schedule['today']['name']
      end
    end

    def pick_new
      # Picks a new person and updates the schedule file. If all people have been completed,
      # it resets the completion flags and tries again.
      tmp_person = pick_person
      if tmp_person.nil?
        reset_people_completion
        @person = pick_person
      else
        @person = tmp_person
      end
      save_schedule
    end

    def generate_new_person
      # Keeps picking a new person until it's different from the current one.
      tmp_person = @person
      pick_new while tmp_person == @person
    end

    def loadschedule
      # Loads the schedule from the JSON file. If the file doesn't exist, it generates a new schedule.

      path = schedule_path
      generate_new_schedule unless File.exist?(path)

      @schedule = JSON.parse(File.read(path))
    end

    def generate_new_schedule
      # Generates a new schedule based on the template and config files.
      # The template defines the structure of the schedule, while the
      # config provides the list of people. It initializes all people
      # with completed = false.
      template_path = File.expand_path('../data/templates/schedule/schedule.json', __dir__)
      config_path = File.expand_path('../data/shared/config.json', __dir__)

      template = JSON.parse(File.read(template_path))
      config = JSON.parse(File.read(config_path))

      @schedule = template
      @schedule['people'] = config['people'].map { |name| { 'name' => name, 'completed' => false } }
      save_schedule
    end

    def generated_today
      # Checks if the schedule has already been generated for today by
      # comparing the date in the schedule with today's date.
      today_str = Date.today.strftime('%d-%m-%Y')
      return unless @schedule.is_a?(Hash) && @schedule['today'].is_a?(Hash) && @schedule['today']['date']

      @schedule['today']['date'] == today_str
    end

    def pick_person
      # Picks a random person from the list of incomplete people.
      people = @schedule['people']
      return nil unless people.is_a?(Array)

      incomplete = people.select do |person|
        person.is_a?(Hash) && person['completed'] == false
      end

      selected = incomplete.sample
      return nil unless selected

      name = selected.fetch('name', nil)
      today_str = Date.today.strftime('%d-%m-%Y')

      @schedule['people'][people.index(selected)]['completed'] = true
      @schedule['today']['name'] = name
      @schedule['today']['date'] = today_str

      name
    end

    def reset_people_completion
      # Resets the completed flag for all people in the schedule to false.
      people = @schedule['people']
      return unless people.is_a?(Array)

      people.each do |person|
        next unless person.is_a?(Hash)

        person['completed'] = false
      end

      @schedule['people'] = people
    end

    def save_schedule
      # Saves the current schedule to the JSON file.

      File.write(schedule_path, JSON.pretty_generate(@schedule))
    end

    def schedule_path
      # Returns the file path to the schedule JSON file.
      File.expand_path('../data/shared/schedule.json', __dir__)
    end
  end
end
