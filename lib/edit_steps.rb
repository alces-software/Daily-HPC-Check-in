# frozen_string_literal: true

require 'json'
require 'tty-prompt'

module Daily
  class Editor
    def initialize
      @path = File.expand_path('../data/shared/steps.json', __dir__)
      @steps = JSON.parse(File.read(@path))
    end

    def run
      wizard
    end

    def wizard
      prompt = TTY::Prompt.new

      ids = get_ids
      print "\e[H\e[2J"
      index = prompt.select('Which would you like to edit? Press Ctrl-C to exit', ids, per_page: ids.length)

      print "\e[H\e[2J"
      key = prompt.select("Which property of #{@steps[index]['id']} would you like to edit", @steps[index].keys)

      print "\e[H\e[2J"
      value = prompt.ask("Enter a new value for the #{key} of #{@steps[index]['id']}\n>", value: @steps[index][key])

      @steps[index][key] = value

      File.write(@path, JSON.pretty_generate(@steps))
    end

    def get_ids
      ids = {}
      @steps.each_with_index { |step, i| ids[step['id']] = i }
      ids
    end
  end
end
