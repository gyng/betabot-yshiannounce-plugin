# The reponame should match the supplied name

# The class name has to be a single capitalized name
# and should match the filename
class Bot::Plugin::Pong < Bot::Plugin
  def initialize(bot)
    # Defaults. Settings are persistent. A settings file is created if it does not exist
    # in lib/settings/ping.json. See: #save_settings and #load_settings
    #
    # Required plugin settings:
    #
    # trigger: A hash of trigger mappings
    #   {
    #     trigger1: [:method_to_call, auth_level, 'Optional help text for this trigger'],
    #     trigger2: [:method2, 3]
    #   }
    #
    # subscribe: bool
    #   Subscribe to Bot publish? (ie. usually all non-sensitive messages)
    #
    # help: A string, optional
    #   Not required, but useful to have. This means you can have
    #
    # You can add custom settings for the bot as a key in the settings object @s

    @s = {
      trigger: { pong: [:method_to_call, 0, 'Pongs the bot.'] },
      subscribe: false
    }

    super(bot)
  end

  def method_to_call(m = nil)
    m.reply('peng')
  end

  # This method receives published (=broadcasted) messages.
  # Since @s[:subscribe] is false, it is never called and is actually not required.
  def receive(m)
    # Receiving a published message!
  end
end
