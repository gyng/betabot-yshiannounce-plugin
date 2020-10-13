#!/bin/sh

set -euo pipefail

ruby --version
bundle version

bundle exec rubocop
bundle exec rspec
