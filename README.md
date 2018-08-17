# betabot-example-plugin

[![Build Status](https://travis-ci.org/gyng/betabot-example-plugin.svg?branch=master)](https://travis-ci.org/gyng/betabot-example-plugin)

```
<gyng> ~install https://raw.githubusercontent.com/gyng/betabot-example-plugin/master/manifest.json save
<betabot> 🎉 Plugin pong installed.
<betabot> Reloaded.
<betabot> Configuration saved.

<gyng> ~pong
<betabot> peng
```

This is an example plugin for [betabot](https://github.com/gyng/betabot/).

The name (in `manifest.json`), filename and classname have to follow conventions.

|||
|-|-|
|name|pong|
|filename|pong.rb|
|classname|Pong|

You will also have to fill out the keys in `manifest.json`. `manifest.json` will be passed down to `rake install_plugin`.

## Install

```
~install https://raw.githubusercontent.com/gyng/betabot-example-plugin/master/manifest.json save
```

## Update

```
~update pong
```

## Use

```
<user> ~pong
<betabot> peng
```

## Test

```
bundle install
bundle exec rspec
```
