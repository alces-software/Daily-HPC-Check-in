require 'bundler/setup'
require 'dry/cli'

module Foo
  module CLI
    module Commands
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
          puts 'started'
        end
      end

      class Who < Dry::CLI::Command
        desc ''

        def call(*)
          puts ''
        end
      end

      class Results <Dry::CLI::Command
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
end

Dry::CLI.new(Foo::CLI::Commands).call
