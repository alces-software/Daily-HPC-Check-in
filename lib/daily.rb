# frozen_string_literal: true

require 'bundler/setup'
require 'dry/cli'

require_relative 'start'
require_relative 'scheduler'
require_relative 'results'
require_relative 'remove'
require_relative 'export'
require_relative 'daily/version'
require_relative 'edit_steps'
require_relative 'env'

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

    class Env < Dry::CLI::Command
      desc 'Sets up the environment variables for daily'

      def call(*)
        Daily::Env.new
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

      option :date, required: false, aliases: ['-d'], desc: 'Filter results by date (DD-MM-YYYY)'
      option :target, required: false, aliases: ['-t'], desc: 'Get the results specific to a HPC server'

      def call(date: nil, target_hpc: nil, **)
        Daily::Results.new(date: date, target_hpc: target_hpc)
      end

      class Remove < Dry::CLI::Command
        desc 'Removes the result for a specific date'

        option :date, required: false, aliases: ['-d'], desc: 'Filter results by date (DD-MM-YYYY)'

        def call(date: nil, **)
          Daily::Remover.new.remove_result(date: date)
        end
      end

      class Export < Dry::CLI::Command
        desc 'Creates a text copy of the results.json file'

        option :date, required: false, aliases: ['-d'], desc: 'Filter results by date (DD-MM-YYYY)'

        def call(date: nil, **)
          Daily::Export.new(date: date)
        end
      end
    end

    class Edit < Dry::CLI::Command
      desc 'Opens the step editing wizard'

      def call(*)
        Daily::Editor.new.run
      end
    end

    register 'version', Version, aliases: ['v', '-v', '--version']

    register 'start', Start, aliases: ['s', '-s', '--start']

    register 'env', Env, aliases: ['ev', '-ev', '--env']

    register 'edit', Edit, aliases: ['e', '-e', '--edit']

    register 'who', Who, aliases: ['w', '-w', '--who']
    register 'who new', Who::New, aliases: ['we', '-we', '--who new']

    register 'results', Results, aliases: ['r', '-r', '--results']
    register 'results remove', Results::Remove, aliases: ['rr', '-rr', '--results remove']
    register 'results export', Results::Export, aliases: ['re', '-re', '--results export']
  end
end
