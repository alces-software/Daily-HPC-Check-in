# frozen_string_literal: true

require 'bundler/setup'
require 'dry/cli'

require_relative 'start'
require_relative 'scheduler'
require_relative 'results'

module Daily
  module CLI
    extend Dry::CLI::Registry

    class Version < Dry::CLI::Command
      desc 'Prints the CLI version'

      def call(*)
        puts '1.0.0'
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

      argument :date, required: false, desc: 'Filter results by date (YYYY-MM-DD)'

      def call(date: nil, **)
        Daily::Results.new(date: date)
      end
    end

    register 'version', Version, aliases: ['v', '-v', '--version']
    register 'start', Start, aliases: ['s', '-s', '--start']
    register 'who', Who, aliases: ['w', '-w', '--who']
    register 'who new', Who::New, aliases: ['we', '-we', '--who new']
    register 'results', Results, aliases: ['r', '-r', '--results']
  end
end
