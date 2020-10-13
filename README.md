# betabot-yshiannounce-plugin

This is a plugin for [betabot](https://github.com/gyng/betabot/) that relays a streaming pubsub feed.

## Install

```
~install https://raw.githubusercontent.com/gyng/betabot-yshiannounce-plugin/master/manifest.json save
```

## Update

```
~update yshiannounce
```

## Use

```
~watchfeed https://myfeed.tld
~watchdestadd irc:::server.#channel
```

Restart or `~watchstart` as needed.

## Test

```
bundle install
bundle exec rspec
```
