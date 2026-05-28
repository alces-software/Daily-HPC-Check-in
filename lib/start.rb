# frozen_string_literal: true

require 'json'

module Daily
  class Start
    def initialize
      steps_file = File.open "#{__dir__}/../data/shared/steps.json"
      self.class.instance_variable_set(:@step_data, JSON.parse(steps_file.read))
      results_template_file = File.open "#{__dir__}/../data/templates/results.json"
      self.class.instance_variable_set(:@results, JSON.parse(results_template_file.read))
      run
    end

    private

    def run
      steps_data = self.class.instance_variable_get(:@step_data)
      results = self.class.instance_variable_get(:@results)

      results['start-time'] = Time.new.utc
      sleep(50)
      results['end-time'] = Time.new.utc

      puts steps_data
    end
  end
end
