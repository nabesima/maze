require 'optparse'
require 'io/console'
require './maze'

$color = true
$scale = 1
$sleep = 500
$skip = 1
$input = nil
$revert = false

$sleep_vals = [ 0, 1, 5, 10, 100, 500, 1000 ]
$sleep_idx = 5
$skip_vals  = [ 1, 5, 10, 100, 500, 1000, 5000, 10000, 50000, 100000 ]
$skip_idx = 0

def init
  opt = OptionParser.new
  opt.banner += ' INPUT [SCALE]'
  opt.on('-c',     "colorize output") { $color = true }
  opt.on('-w NUM', "sleep time") { |v| $sleep = v.to_f }
  opt.on('-s NUM', "skip print maze") { |v| $skip = v.to_i }
  opt.on('-r',     "revert robot after goal") { $revert = true }
  opt.parse!(ARGV)
  
  if ARGV.empty?
    puts opt.help
    exit
  end
  
  $input = ARGV.shift
  $scale = ARGV.shift.to_i unless ARGV.empty?

  # キー入力で速度調整処理
  Thread.new {
    loop {
      while c = STDIN.getch
        case c
        when ?\C-c
          exit
        when 'u'
          $sleep_idx -= 1 if $sleep_idx > 0
        when 'i'
          $sleep_idx += 1 if $sleep_idx+1 < $sleep_vals.size
        when 's'
          $skip_idx += 1 if $skip_idx+1 < $skip_vals.size
        when 'd'
          $skip_idx -= 1 if $skip_idx > 0
        end
        $sleep = $sleep_vals[$sleep_idx]
        $skip  = $skip_vals[$skip_idx]
      end
    }
  }
end

class Robot
    attr_accessor :maze, :x, :y
    @@rel_dir = {
      north: { fore:  [0, -1], right: [+1, 0], back:  [0, +1], left:  [-1, 0] },
      east:  { left:  [0, -1], fore:  [+1, 0], right: [0, +1], back:  [-1, 0] },
      south: { back:  [0, -1], left:  [+1, 0], fore:  [0, +1], right: [-1, 0] },
      west:  { right: [0, -1], back:  [+1, 0], left:  [0, +1], fore:  [-1, 0] },
    }
    @@turn_back  = { fore: :back, back: :fore, right: :left, left: :right,
                     north: :south, south: :north, west: :east, east: :west }
    @@turn_right = { north: :east, east: :south, south: :west, west: :north }
    @@turn_left  = @@turn_right.invert

    def initialize(maze)
      @maze  = maze
      @x, @y = maze.start
      @dir   = :north
      @steps = 0
      @reverse = false
    end
  
    def goto(d)
      addFootmark(x, y)
      dx, dy = @@rel_dir[@dir][d]
      @x += dx
      @y += dy
      @steps += 1
      sleep($sleep / 1000.0) if $sleep > 0
      print
    end

    def get_next(x, y, d)
      addFootmark(x, y)
      dx, dy = @@rel_dir[@dir][d]
      x += dx
      y += dy
      @x = x
      @y = y
      @steps += 1
      sleep($sleep / 1000.0) if $sleep > 0
      print
      return [x, y]
    end    

    def gotoNextIntersection(d)
      loop do
        addFootmark(x, y)
        dx, dy = @@rel_dir[@dir][d]
        @x += dx
        @y += dy
        @steps += 1
        sleep($sleep / 1000.0) if $sleep > 0
        print      
        # 次に移動可能な方向
        dirs = get_pos_dirs        
        if goal? or dirs.size >= 3 # 三叉路以上なら終了
          break
        elsif dirs.size == 1  # 行き止まりなら，戻る
          d = dirs.first
        else
          d = dirs.filter { |e| e != @@turn_back[d] }.first
        end
      end
    end  

    def revert
      # ロボットを反転
      @dir = @@turn_back[@dir]
      # 迷路のスタートとゴールを入れ替え
      @maze.swap
      @reverse = true
      @maze.set(x, y, :footmark)
    end

    def forward
      addFootmark(x, y)
      dx, dy = @@rel_dir[@dir][:fore]
      @x += dx
      @y += dy
      @steps += 1
      sleep($sleep / 1000.0) if $sleep > 0
      print
    end

    def backward
      @maze.set(x, y, :space) 
      dx, dy = @@rel_dir[@dir][:back]
      @x += dx
      @y += dy
      @steps += 1
    end

    def addFootmark(x, y)
      unless @reverse
        @maze.set(x, y, :footmark) 
      else
        case @maze.get(x, y)
        when :footmark
          @maze.set(x, y, :footmark_d) 
        when :footmark_d
          @maze.set(x, y, :footmark_d) 
        else
          @maze.set(x, y, :footmark_r)           
        end
      end      
    end

    def backtrack(nx, ny, x, y)
      @maze.set(nx, ny, :space) 
      @x = x
      @y = y
      @steps += 1
      sleep($sleep / 1000.0) if $sleep > 0
      print
    end

    def get(d)
      dx, dy = @@rel_dir[@dir][d]
      maze.get(x+dx, y+dy)
    end

    def turn_left
      @dir = @@turn_left[@dir]
    end

    def turn_right
      @dir = @@turn_right[@dir]
    end

    def turn_to(d)
      case d
      when :right
        turn_right
      when :left
        turn_left
      when :back
        turn_right
        turn_right
      end
    end

    def get_pos_dirs
      @@rel_dir[@dir].each_pair.map { |dir, (dx, dy)|
        [dir, maze.get(x + dx, y + dy)]  # 向きと２マス先のオブジェクトを取得
      }.filter { |dir, e| 
        e != :block                      # 通路のみを残す
      }.map { |dir, e|  
        dir                              # 方向のみ抽出
      }
    end

    def get_pos_dirs_except_back(x=@x, y=@y)
      @@rel_dir[@dir].each_pair.map { |d, (dx, dy)|
        [d, maze.get(x + dx, y + dy)]  # 向きと１マス先のオブジェクトを取得
      }.filter { |d, e| 
        e != :block && e != :footmark  # 後ろ以外の通路のみを残す
      }.map { |d, e|  
        d                              # 方向のみ抽出
      }
    end

    def print(force = false)
      return if @steps % $skip != 0 and !force
      puts "\e[H\e[2J"
      puts "#{@steps} steps (wait: #{$sleep}msec, skip: #{$skip})\r"
      puts maze.to_s($scale, x, y)
    end

    def goal?(x = @x, y = @y)
      maze.goal?(x, y)
    end
  end
  