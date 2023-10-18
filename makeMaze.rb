#!/usr/bin/env ruby
require 'optparse'
require './maze'

opt = OptionParser.new
$size = 9
$scale = 1
$output = nil
opt.banner += ' SIZE [SCALE]'
opt.on('-o FILE',     "output to FILE") { |v| $output = v }

opt.parse!(ARGV)
if ARGV.empty?
  puts opt.help
  exit
end

$size = ARGV.shift.to_i
$size = $size + 1 if $size % 2 == 0   # 迷路サイズを奇数化
$scale = ARGV.shift.to_i unless ARGV.empty?

maze = Maze.new($size)

puts maze.to_s($scale)

if $output
  open($output, "w") { |out|
    maze.write(out)
  }
end