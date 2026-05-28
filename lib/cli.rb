# frozen_string_literal: true

require 'bundler/setup'
require 'dry/cli'

require_relative '../lib/start'

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
        desc ''

        def call(*)
          puts ''
        end
      end

      class Results < Dry::CLI::Command
        desc ''

        def call(*)
          puts ''
        end
      end

    register 'version',    Version, aliases: ['v', '-v', '--version']
    register 'start',      Start
    register 'who',        Who
    register 'results',    Results
  end
end

