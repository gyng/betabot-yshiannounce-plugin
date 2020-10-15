# frozen_string_literal: true

# rubocop:disable all

class Bot::Plugin::Yshiannounce < Bot::Plugin
  def initialize(bot)
    @s = {
      trigger: {
        yt: [:parse_cmd, 0, '<feed list|feed add <tag channel_id>|feed rm <tag>|feed import replace <json>|feed import-url replace <url>|feed export|dest list|dest add <address>|dest rm <address>|start|stop|endpoint|endpoint set <url>>']
      },
      subscribe: false,
      announce_targets: [],
      watchlist: {},
      endpoint: ""
    }

    @seen = {}
    @bot = bot

    super(bot)
  end

  def on_connect(adapter=nil, conn=nil)
    start_listen
  end

  def parse_cmd(m)
    case m.args
    in ['feed', 'add', tag, id]
      found = @s[:watchlist][id]
      if found
        m.reply "(#{id}, #{found[0]}) is already being watched."
        return
      end
      @s[:watchlist][id] = tag
      save_settings
      m.reply "Added (#{id}, #{tag})"
    in ['feed', 'rm', id]
      found = @s[:watchlist][id]
      if found
        @s[:watchlist].delete(id)
        save_settings
        m.reply "Removed #{id}"
      else
        m.reply "ID #{id} not found"
      end
    in ['feed', 'import', 'replace', *rest]
      @s[:watchlist] = JSON.parse(rest.join(" "))
      m.reply "Updated."
    in ['feed', 'import-url', 'replace', url]
      json = JSON.parse(RestClient.get(url).body)
      @s[:watchlist] = json
      m.reply "Updated. (pls no hax)"
    in ['feed', 'export'] | ['feed', 'list']
      m.reply @s[:watchlist].to_json
    in ['dest', 'list']
      m.reply @s[:announce_targets]
    in ['dest', 'add', addr]
      @s[:announce_targets].push(addr).uniq!
      save_settings
      m.reply "Added #{addr}."
    in ['dest', 'rm', addr]
      found = @s[:announce_targets].delete(addr)
      if found
        save_settings
        m.reply("Deleted #{addr}.")
      else
        m.reply("Not deleted (not in list).")
      end
    in ['start']
      start_listen(m)
    in ['stop']
      stop_listen(m)
    in ['endpoint']
      m.reply "Feed URL: #{@s[:endpoint]}"
    in ['endpoint', 'set', url]
      @s[:endpoint] = url
      save_settings
      m.reply "Feed set to #{url}"
    else
      m.reply "Unknown command."
    end
  end

  def stop_listen(m = nil)
    @thread.kill if @thread
    m.reply("Stopped.") if m
  end

  def start_listen(m=nil)
    if !@s[:endpoint] || @s[:endpoint].empty?
      m.reply 'Endpoint not specified; cannot start watching.' if m
      Bot.log.info "#{self.class.name}: Endpoint not specified; cannot start watching"
      return
    end

    @thread.kill if @thread
    @thread = Thread.new do
      buf = ""
      chunks = []

      block = proc { |response|
        sep = /--[0-9a-f]{60}\r?\n?/

        response.read_body do |chunk|
          buf = buf + chunk
          tmp_chunks = buf.split(sep)
          chunks.concat(tmp_chunks[0..-1])
          chunks = [tmp_chunks[-1]]

          while chunks.length > 0
            reply = process_chunk(chunks.pop)
            operation = proc {
              if reply
                @s[:announce_targets].each do |address|
                  msg = @bot.address_str(address)&.reply(reply)
                end
              end
            }
            EM.defer(operation, nil, nil)
          end
        end
      }
      begin
        payload = @s[:watchlist]
          .keys
          .map { |id| {"hub": "https://pubsubhubbub.appspot.com/subscribe", "topic": "https://www.youtube.com/xml/feeds/videos.xml?channel_id=#{id}"}}
          .map { |it| it.to_json }
          .join("\n")
        m.reply 'Started.' if m
        RestClient::Request.execute(method: :post, payload: payload, url: @s[:endpoint], block_response: block, read_timeout: nil)
      rescue RestClient::Exception => err
        Bot.log.info "#{self.class.name}: Failed to read feed, retrying in 60s"
        EM.add_timer(60) {
          Bot.log.info "#{self.class.name}: Retrying..."
          start_listen(m)
        }
      end
    end
  end

  # Chunk header
  # ----58c56b4bb1a11494b0877075b47400b334c0f215ea9cd463091323638c32\r\nContent-Type: application/vnd.yshi.feed.item\r\n\r\n
  # or
  # ----58c56b4bb1a11494b0877075b47400b334c0f215ea9cd463091323638c32\r\nContent-Type: application/vnd.yshi.feed.timeout\r\n\r\n"
  #
  # <?xml version='1.0' encoding='UTF-8'?>
  # <feed xmlns:yt="http://www.youtube.com/xml/schemas/2015" xmlns="http://www.w3.org/2005/Atom">
  #   <link rel="hub" href="https://pubsubhubbub.appspot.com"/>
  #   <link rel="self" href="https://www.youtube.com/xml/feeds/videos.xml?channel_id=UC1opHUrw8rvnsadT-iGp7Cg"/>
  #   <title>YouTube video feed</title>
  #   <updated>2020-10-13T08:06:12.229398109+00:00</updated>
  #   <entry>
  #     <id>yt:video:gcA2KNNYt5g</id>
  #     <yt:videoId>gcA2KNNYt5g</yt:videoId>
  #     <yt:channelId>UC1opHUrw8rvnsadT-iGp7Cg</yt:channelId>
  #     <title>【マリオ35】 一 位 以 外 で 即 終 了 ！ 【湊あくあ/ホロライブ】</title>
  #     <link rel="alternate" href="https://www.youtube.com/watch?v=gcA2KNNYt5g"/>
  #     <author>
  #       <name>Aqua Ch. 湊あくあ</name>
  #       <uri>https://www.youtube.com/channel/UC1opHUrw8rvnsadT-iGp7Cg</uri>
  #     </author>
  #     <published>2020-10-13T08:05:04+00:00</published>
  #     <updated>2020-10-13T08:06:12.229398109+00:00</updated>
  #   </entry>
  # </feed>
  def process_chunk(chunk)
    item_content_type = 'Content-Type: application/vnd.yshi.feed.item'
    if chunk.start_with?(item_content_type)
      stripped = chunk.gsub(/^#{item_content_type}/, '').to_s
      item = Nokogiri.XML(stripped).remove_namespaces!

      id = item.xpath('//entry/id').first&.content
      
      if id
        @seen[id] = @seen[id] ? @seen[id] + 1 : 1
        if @seen[id] == 1
          vid_title = item.xpath('//entry/title').first&.content
          vid_id = item.xpath('//entry/videoId').first&.content
          vid_author = item.xpath('//entry/author/name').first&.content
          vid_href = "https://youtu.be/#{vid_id}"

          if vid_title && vid_id && vid_author
            separator = '►►►'.gray
            return "📣 #{vid_author.red} #{separator} #{vid_title.blue} #{separator} #{vid_href.gray}"
          else
            Bot.log.info "#{self.class.name} Skipped feed item: missing one of #{vid_title} #{vid_id} #{vid_author}..."
          end
        end
      end
    else
      # Don't log
      # Bot.log.info "#{self.class.name} Skipped feed item: #{chunk[0..62]}..."
    end

    nil
  rescue StandardError => e
    Bot.log.info "#{self.class.name} Bad feed item: #{e}"
    nil
  end
end

# rubocop:enable all
