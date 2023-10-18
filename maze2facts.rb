#!/usr/bin/env ruby
require './maze'

if ARGV.empty?
  puts "Usage: #{$0} INPUT"
  exit
end

$input = ARGV.shift
maze = Maze.new($input)
puts "size(#{maze.size})."
puts maze.to_facts.join("\n")
