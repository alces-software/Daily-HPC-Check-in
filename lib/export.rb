# frozen_string_literal: true

require 'stringio'

require_relative 'results'

module Daily
  class Export
    def initialize(date: nil, target: nil)
      self.class.instance_variable_set(:@date, date || Date.today.strftime('%d-%m-%Y'))
      self.class.instance_variable_set(:@target, target)
      run
    end

    private

    def run
      date = self.class.instance_variable_get(:@date)

      unless File.exist?(File.expand_path("../data/results/#{date}/results.json", __dir__))
        puts
        puts "Today's system check pending..."
        puts
        return
      end

      pastel = Pastel.new

      output = capture_stdout do
        Results.new(date: date, target: self.class.instance_variable_get(:@target))
      end

      file_path = File.expand_path("../data/results/#{date}/results.txt", __dir__)

      File.write(file_path, pastel.strip(output))

      puts "The path to you're txt file is: #{file_path}"
    end

    def capture_stdout
      old_stdout = $stdout
      $stdout = StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end
end
