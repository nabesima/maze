#!/usr/bin/env ruby
require 'optparse'

opt = OptionParser.new
$color = false
$scale = 1
opt.banner += ' INPUT [SCALE]'
opt.on('-c',     "colorize output") { $color = true }
opt.parse!(ARGV)
if ARGV.empty?
  puts opt.help
  exit
end

$input = ARGV.shift
$scale = ARGV.shift.to_i unless ARGV.empty?

require './maze'
maze = Maze.new($input)
puts maze.to_s($scale)
