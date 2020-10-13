# frozen_string_literal: true

require 'betabot' # loads as a lib for access to structures
require_relative '../pong'

describe Bot::Plugin::Pong do
  subject { Bot::Plugin::Pong.new(nil) }

  it 'responds to pong with peng' do
    m = Bot::Core::Message.new
    expect(m).to receive(:reply).with('peng')
    subject.method_to_call(m)
  end
end
