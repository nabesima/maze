#!/usr/bin/env ruby
require './robot'

class BacktrackRobot < Robot
  def solve
    solve_aux(@x, @y)
  end

  def solve_aux(x, y)    
    return :success if goal?(x, y)                      # ゴールなら成功
    dirs = get_pos_dirs_except_back(x, y).shuffle       # 背面以外の移動可能な方向を取得
    return :fail if dirs.empty?                         # 行き止まりなら失敗（１つ手前に戻る）
    
    while not dirs.empty?                               # 調べていない方向がある？
      new_dir = dirs.shift                              # 調べていない方向へ移動
      nx, ny = get_next(x, y, new_dir)
      return :success if solve_aux(nx, ny) == :success  # 再帰的に迷路を解き，ゴールすれば成功
      backtrack(nx, ny, x, y)                           # １つ手前に戻る  
    end

    return :fail                                        # どの方向も行き止まりの場合失敗
  end
end

init
maze = Maze.new($input)
robot = BacktrackRobot.new(maze)
robot.solve
robot.print(true)

if $revert
  robot.revert
  robot.solve
  robot.print(true)
end
