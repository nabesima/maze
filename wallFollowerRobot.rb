#!/usr/bin/env ruby
require './robot'

class WallFollowerRobot < Robot
    def solve
      until goal?
        # 左手が空いているならば左へ進む
        if get(:left) != :block
            turn_left
            forward
        # 前が空いているならば前へ進む
        elsif get(:fore) != :block
            forward
        # 右を向く            
        else
            turn_right
        end
      end
    end
end

init
maze = Maze.new($input)
robot = WallFollowerRobot.new(maze)
robot.solve
robot.print(true)

if $revert
  robot.revert
  robot.solve
  robot.print(true)
end
