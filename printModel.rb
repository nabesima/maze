#!/usr/bin/env ruby
require 'optparse'

opt = OptionParser.new
$color = true
opt.banner += ' [SCALE]'
opt.on('-c',     "colorize output") { $color = true }
opt.parse!(ARGV)

$scale = 1
$scale = ARGV.shift.to_i unless ARGV.empty?

require './maze.rb'

def parse(model)
  map = Hash.new { |h,k| h[k] = {} }
  lits = model.split(" ")
  lits.each { |lit|
    if lit =~ /(\w+)\((\d+),(\d+)\)/
      name = $1
      x = $2.to_i
      y = $3.to_i
      case name
      when "block"
        map[y][x] = :block
      when "space"        
        map[y][x] = :space
      when "start"
        map[y][x] = :start
      when "goal"
        map[y][x] = :goal
      end
    end
  }
  lits.each { |lit|
    if lit =~ /(\w+)\((\d+),(\d+)\)/
      name = $1
      x = $2.to_i
      y = $3.to_i
      case name
      when "path"
        map[y][x] = :footmark
      when "deadend"        
        map[y][x] = :deadend if map[y][x] != :block
      end
    end
  }
  Maze.new(map)
end

while line = gets
  if line =~ /^Answer/
    maze =  parse(gets) 
    puts maze.to_s($scale)
  end
end

