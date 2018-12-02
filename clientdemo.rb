#!/usr/bin/env ruby

require 'json'
require './aocclient'

secrets = JSON.parse File.read "./aoc_data.json"
c = AOCClient.new("bradyaturner/aocclient", "0.1", secrets)
puts c.get_leaderboard
puts c.join_leaderboard(ARGV[0])
