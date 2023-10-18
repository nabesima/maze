#!/usr/bin/env ruby
require './robot'

class RandomRobot < Robot
  def solve
    until goal?
      # 現在位置から移動可能な方向をランダムに１つ選択
      dir = get_pos_dirs.sample 
      # その方向に１マス移動する
      goto(dir)                 
    end
  end
end

init
maze = Maze.new($input)
robot = RandomRobot.new(maze)
robot.solve
robot.print(true)

