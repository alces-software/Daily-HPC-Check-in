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

      loop do
        index = choose_step(prompt)
        break if index == -1

        edit_step(prompt, index)
      end
    end

    def choose_step(prompt)
      clear_screen
      prompt.select('Which would you like to edit?', get_ids(@steps), per_page: get_ids(@steps).length)
    end

    def edit_step(prompt, index)
      loop do
        clear_screen
        key = choose_property(prompt, index)
        break if key == 'exit'

        edit_step_property(prompt, index, key)
      end
    end

    def choose_property(prompt, index)
      prompt.select("Which property of #{@steps[index]['id']} would you like to edit",
                    @steps[index].keys + ['exit'], per_page: @steps[index].keys.length + 1)
    end

    def edit_step_property(prompt, index, key)
      if key == 'procedures'
        edit_procedures(prompt, index)
      else
        edit_property_value(prompt, index, key)
      end
    end

    def edit_property_value(prompt, index, key)
      clear_screen
      value = prompt.ask("Enter a new value for the #{key} of #{@steps[index]['id']}\n>",
                         value: @steps[index][key])
      @steps[index][key] = value
      persist_steps
    end

    def edit_procedures(prompt, index)
      procedures = @steps[index]['procedures']

      loop do
        clear_screen
        cluster = prompt.select('Which cluster would you like to edit the procedures for?',
                                procedures.keys + ['exit'], per_page: procedures.keys.length + 1)
        break if cluster == 'exit'

        edit_cluster_procedure(prompt, procedures[cluster])
      end
    end

    def edit_cluster_procedure(prompt, procedures)
      loop do
        clear_screen
        procedure_index = prompt.select('Which procedure would you like to edit?', get_ids(procedures),
                                        per_page: get_ids(procedures).length)
        break if procedure_index == -1

        edit_cluster_procedure_props(prompt, procedures[procedure_index])
      end
    end

    def edit_cluster_procedure_props(prompt, procedure_index)
      loop do
        clear_screen
        prop = prompt.select('Which property would you like to edit',
                             procedure_index.keys + ['exit'], per_page: procedure_index.keys.length + 1)
        break if prop == 'exit'

        edit_procedure_prop(prompt, prop, procedure_index)
      end
    end

    def edit_procedure_prop(prompt, prop, procedure)
      if prop == 'outcomes'
        edit_outcomes(prompt, procedure)
      else
        edit_procedure_property(prompt, prop, procedure)
      end
    end

    def edit_outcomes(prompt, procedure)
      outcomes = procedure['outcomes'] || {}

      loop do
        clear_screen
        choice = prompt.select('Which outcomes field would you like to edit?',
                               outcomes.keys + ['exit'], per_page: outcomes.keys.length + 1)
        break if choice == 'exit'

        value = prompt.ask("Enter a new value for outcomes #{choice} of #{procedure['id']}\n>",
                           value: outcomes[choice])
        outcomes[choice] = value
        procedure['outcomes'] = outcomes
        persist_steps
      end
    end

    def edit_procedure_property(prompt, prop, procedure)
      clear_screen

      value = if prop == 'necessary'
                prompt.select("Set #{procedure['id']} necessary?", %w[true false], per_page: 2) == 'true'
              else
                prompt.ask("Enter a new value for #{prop} of #{procedure['id']}\n>",
                           value: procedure[prop])
              end

      procedure[prop] = value
      persist_steps
    end

    def persist_steps
      File.write(@path, JSON.pretty_generate(@steps))
    end

    def clear_screen
      print "\e[H\e[2J"
    end

    def get_ids(obj)
      ids = {}
      obj.each_with_index { |step, i| ids[step['id']] = i }
      ids['exit'] = -1
      ids
    end
  end
end
