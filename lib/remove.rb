# frozen_string_literal: true

require 'fileutils'
require 'tty-prompt'

module Daily
  class Remover
    def remove_result(date: nil)
      prompt = TTY::Prompt.new

      date = Date.today.strftime('%d-%m-%Y') if date.nil?

      if prompt.no?("Are you sure you want to remove the result for #{date}? This action cannot be undone.",
                    default: false)
        puts 'Operation cancelled.'
        return
      end

      path = File.expand_path("../data/results/#{date}", __dir__)

      if Dir.exist?(path)
        puts "Removing result for #{date}..."
        FileUtils.rm_rf(path)
        puts "Result for #{date} removed successfully."
      else
        puts "No result found for #{date}."
      end
    end
  end
end
