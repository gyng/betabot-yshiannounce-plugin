# betabot-example-plugin

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
rake install_plugin[https://raw.githubusercontent.com/gyng/betabot-example-plugin/master/manifest.json]
```

## Update

```
rake update_plugin[pong]
```

## Use

```
<user> ~pong
<betabot> peng
```
