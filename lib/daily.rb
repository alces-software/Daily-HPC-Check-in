# frozen_string_literal: true

require 'bundler/setup'
require 'dry/cli'

require_relative 'start'
require_relative 'scheduler'
require_relative 'results'
require_relative 'remove'
require_relative 'export'
require_relative 'daily/version'

module Daily
  module CLI
    extend Dry::CLI::Registry

    class Version < Dry::CLI::Command
      desc 'Prints the CLI version'

      def call(*)
        puts Daily::VERSION
      end
    end

    class Start < Dry::CLI::Command
      desc 'Starts daily wizard'

      def call(*)
        Daily::Start.new
      end
    end

    class Who < Dry::CLI::Command
      desc 'Outputs the name of the person responsible for HPC check-in today'

      def call(*)
        scheduler = Daily::Scheduler.new
        puts scheduler.person
      end

      class New < Dry::CLI::Command
        desc 'Picks a new person for today'

        def call(*)
          puts 'Picking new person...'
          scheduler = Daily::Scheduler.new
          scheduler.generate_new_person
          puts scheduler.person
        end
      end
    end

    class Results < Dry::CLI::Command
      desc 'Displays test details and results'

      argument :date, required: false, desc: 'Filter results by date (DD-MM-YYYY)'

      def call(date: nil, **)
        Daily::Results.new(date: date)
      end

      class Remove < Dry::CLI::Command
        desc 'Removes the result for a specific date'

        argument :date, required: false, desc: 'Date for which to remove results (DD-MM-YYYY)'

        def call(date: nil, **)
          Daily::Remover.new.remove_result(date: date)
        end
      end

      class Export < Dry::CLI::Command
        desc 'Creates a text copy of the results.json file'

        argument :date, required: false, desc: 'Date for which to remove results (DD-MM-YYYY)'

        def call(date: nil, **)
          Daily::Export.new(date: date)
        end
      end
    end

    register 'version', Version, aliases: ['v', '-v', '--version']

    register 'start', Start, aliases: ['s', '-s', '--start']

    register 'who', Who, aliases: ['w', '-w', '--who']
    register 'who new', Who::New, aliases: ['we', '-we', '--who new']

    register 'results', Results, aliases: ['r', '-r', '--results']
    register 'results remove', Results::Remove, aliases: ['rr', '-rr', '--results remove']
    register 'results export', Results::Export, aliases: ['re', '-re', '--results export']
  end
end
