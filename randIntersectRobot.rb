#!/usr/bin/env ruby
require './robot'

class RandIntersectionRobot < Robot
  def solve
    until goal?
      # 現在位置から移動可能な方向をランダムに１つ選択
      dir = get_pos_dirs.sample 
      # 交差点に出会うまで進む
      gotoNextIntersection(dir)                 
    end
  end
end

init
maze = Maze.new($input)
robot = RandIntersectionRobot.new(maze)
robot.solve
robot.print(true)
