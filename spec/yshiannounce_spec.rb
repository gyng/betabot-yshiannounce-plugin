# frozen_string_literal: true

require 'betabot' # loads as a lib for access to structures
require 'nokogiri'
require_relative '../yshiannounce'

# rubocop:disable Metrics/BlockLength
describe Bot::Plugin::Yshiannounce do
  test_chunk = %(Content-Type: application/vnd.yshi.feed.item\r\n\r\n
   <?xml version='1.0' encoding='UTF-8'?>
   <feed xmlns:yt="http://www.youtube.com/xml/schemas/2015" xmlns="http://www.w3.org/2005/Atom">
     <link rel="hub" href="https://pubsubhubbub.appspot.com"/>
     <link rel="self" href="https://www.youtube.com/xml/feeds/videos.xml?channel_id=UC1opHUrw8rvnsadT-iGp7Cg"/>
     <title>YouTube video feed</title>
     <updated>2020-10-13T08:06:12.229398109+00:00</updated>
     <entry>
       <id>yt:video:gcA2KNNYt5g</id>
       <yt:videoId>gcA2KNNYt5g</yt:videoId>
       <yt:channelId>UC1opHUrw8rvnsadT-iGp7Cg</yt:channelId>
       <title>【マリオ35】 一 位 以 外 で 即 終 了 ！ 【湊あくあ/ホロライブ】</title>
       <link rel="alternate" href="https://www.youtube.com/watch?v=gcA2KNNYt5g"/>
       <author>
         <name>Aqua Ch. 湊あくあ</name>
         <uri>https://www.youtube.com/channel/UC1opHUrw8rvnsadT-iGp7Cg</uri>
       </author>
       <published>2020-10-13T08:05:04+00:00</published>
       <updated>2020-10-13T08:06:12.229398109+00:00</updated>
     </entry>
   </feed>
  )

  it 'parses a chunk' do
    plugin = Bot::Plugin::Yshiannounce.new(nil)
    reply = plugin.process_chunk(test_chunk)
    expect(reply).to include('【マリオ35】 一 位 以 外 で 即 終 了 ！ 【湊あくあ/ホロライブ】')
    expect(reply).to include('Aqua Ch. 湊あくあ')
    # shortened
    expect(reply).to include('https://youtu.be/gcA2KNNYt5g')
  end
end
# rubocop:enable Metrics/BlockLength
