# frozen_string_literal: true

require 'betabot' # loads as a lib for access to structures
require_relative '../pong'

describe Bot::Plugin::Pong do
  it 'changes the reply message' do
    plugin = Bot::Plugin::Pong.new(nil)

    m = Bot::Core::Message.new
    m.text = 'trigger warrrgh'
    expect(m).to receive(:reply).with("Changed to #{m.args[0]}")
    plugin.change_reply(m)

    m2 = Bot::Core::Message.new
    expect(m2).to receive(:reply).with('warrrgh')
    plugin.method_to_call(m2)

    m3 = Bot::Core::Message.new
    m3.text = 'trigger peng'
    expect(m3).to receive(:reply).with("Changed to #{m3.args[0]}")
    plugin.change_reply(m3)

    m4 = Bot::Core::Message.new
    expect(m4).to receive(:reply).with('peng')
    plugin.method_to_call(m4)
  end
end
