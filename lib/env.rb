require 'tty-prompt'
require 'dotenv'

module Daily
  class Env
    def initialize
      run
    end

    private

    def run
      env_file_location = File.expand_path('../.env', __dir__)
      prompt = TTY::Prompt.new
      env_data = File.exist?(env_file_location) ? Dotenv.load(env_file_location) : ''
      puts
      testers = prompt.ask('What are you\'re testers name (names must be comma separated e.g. name1,name2)? ',
                           value: env_data['TESTERS'].nil? ? '' : env_data['TESTERS']) do |q|
        q.required true
        q.modify :strip
      end
      puts
      hpcs = prompt.ask(
        'What\'s the names of the HPC\'s (names must be comma seperated e.g. hpc1,hpc2)? ', value: env_data['HPCS'].nil? ? '' : env_data['HPCS']
      ) do |q|
        q.required true
        q.modify :strip
      end
      puts
      webhook_key = prompt.ask('What\'s the webhook api key you would like to use?') do |q|
        q.required true
        q.modify :strip
      end
      puts
      puts 'Your .env has been saved'
      puts
      File.write(env_file_location, "TESTERS=#{testers}\nHPCS=#{hpcs}\nWEBHOOK_API_KEY=#{webhook_key}")
    end
  end
end
