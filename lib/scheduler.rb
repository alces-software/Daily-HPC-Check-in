# frozen_string_literal: true

module Daily
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
      tmp_person = @person
      pick_new while tmp_person == @person
    end

    def loadschedule
      require 'json'
      require 'date'

      path = schedule_path
      generate_new_schedule unless File.exist?(path)

      @schedule = JSON.parse(File.read(path))
    end

    def generate_new_schedule
      require 'json'
      require 'date'
      template_path = File.expand_path('../data/templates/schedule.json', __dir__)
      config_path = File.expand_path('../data/config.json', __dir__)

      template = JSON.parse(File.read(template_path))
      config = JSON.parse(File.read(config_path))

      @schedule = template
      @schedule['people'] = config['people'].map { |name| { 'name' => name, 'completed' => false } }
      save_schedule
    end

    def generated_today
      today_str = Date.today.strftime('%d-%m-%Y')
      return unless @schedule.is_a?(Hash) && @schedule['today'].is_a?(Hash) && @schedule['today']['date']

      @schedule['today']['date'] == today_str
    end

    def pick_person
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
      people = @schedule['people']
      return unless people.is_a?(Array)

      people.each do |person|
        next unless person.is_a?(Hash)

        person['completed'] = false
      end

      @schedule['people'] = people
    end

    def save_schedule
      require 'json'

      File.write(schedule_path, JSON.pretty_generate(@schedule))
    end

    def schedule_path
      File.expand_path('../data/schedule.json', __dir__)
    end
  end
end
