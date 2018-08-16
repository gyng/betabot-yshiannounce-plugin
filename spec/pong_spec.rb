# Right now, the test can only be run after it's installed
# This will hopefully be improved in the future if/when
# betabot structures are exposed as a library

require 'spec_helper'
require_relative '../pong.rb'

describe Bot::Plugin::Pong do
  subject { Bot::Plugin::Pong.new(nil) }

  it 'responds to pong with peng' do
    m = Bot::Core::Message.new
    expect(m).to receive(:reply).with('peng')
    subject.method_to_call(m)
  end
end
