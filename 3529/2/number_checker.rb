require 'yaml'
require 'redis'
require 'redis-activesupport'
require 'redis-rails'
require 'redis-namespace'
require 'redis-rack-cache'

class NumberChecker
  def initialize(file_path)
    @file_path = file_path
    @file = YAML.safe_load(File.read(@file_path))
  end

  def handle_number(number, payload)
    resp = ''
    @file['participents'].each do |participant|
      resp = checker_id(participant, payload, number) if number == participant.keys.first.to_s
    end
    update_file
    resp
  end

  def checker_id(participant, payload, number)
    new_part = "You've just signed in your camp database. We are watching you!!!"
    resp = if participant['telegram_id']
             "I'm sorry, but someone already have signed in with #{number} number"
           else
             new_part
           end
    participant['telegram_id'] = payload['from']['id'] if resp.eql?(new_part)
    resp
  end

  def update_file
    data_base = Redis::Namespace.new('telegram-bot-app', redis: Redis.new)
    @file['participents'].each do |participant|
      data_base.set(participant.keys.first.to_s, participant['telegram_id'].to_s)
    end
    File.open(@file_path, 'w') do |smth|
      smth.write @file.to_yaml
    end
  end
end