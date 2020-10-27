# frozen_string_literal: true

require 'betabot' # loads as a lib for access to structures
require 'nokogiri'
require_relative '../yshiannounce'

describe Bot::Plugin::Yshiannounce do
  test_chunk = File.read('spec/example/chunk.txt')

  it 'parses a chunk' do
    plugin = Bot::Plugin::Yshiannounce.new(nil)
    reply = plugin.process_feed_item(test_chunk)
    expect(reply).to include('Video title')
    expect(reply).to include('Channel name')
    # shortened
    expect(reply).to include('https://youtu.be/z4BB-oUmT5A')
  end
end
