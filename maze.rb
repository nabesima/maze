require 'paint'
Paint.mode = 256 

class Maze
    @@fchara = {
      space:  '0',
      block:  '1',
      start:  'S',
      goal:   'G',
    }
    
    @@dir = {
      up:    [ 0, -1],  # 上
      right: [+1,  0],  # 右
      down:  [ 0, +1],  # 下
      left:  [-1,  0],  # 左
    }

    def initialize(arg)

      # $color の値に応じて定義したいのでメソッド内部で定義
      @@chara = {
        space:      '  ',
        block:      $color ? Paint['  ', nil, :white] : '##',
        start:      '  ',
        goal:       '  ',
        up:         '上',
        right:      '右',
        down:       '下',
        left:       '左',
        robot:      Paint["  ", nil, :red],
        footmark:   $color ? Paint['  ', nil, :cyan] : '//',
        footmark_r: $color ? Paint['  ', nil, :green] : '\\\\',
        footmark_d: $color ? Paint['  ', nil, :magenta] : 'XX',
        deadend:    $color ? Paint['  ', nil, [169, 169, 169]] : '..',
      }
  
      if arg.is_a?(Integer)
        size = arg
        @map = Array.new(size) { Array.new(size, :space)}
        @size = size
        # 外周に壁を作成し，内部に柱を作成
        size.times { |x|
          size.times { |y|
            if x == 0 or x == size-1 or y == 0 or y == size-1   # 外周
              set(x, y, :block)
            elsif x % 2 == 0 and y % 2 == 0                     # 柱
              set(x, y, :block)
            end
          }
        }
        # 仮のスタートを置く
        set(size - 2, 1, :start)
        # 迷路作成
        make(size - 2, 1)
        # 経路変換
        conv()
      elsif arg.is_a?(String)
        fchara = @@fchara.invert
        @map = open(arg).read.split.each_with_index.map { |line, y|
          line.chars.each_with_index.map { |e, x|
            @start = [x, y] if fchara[e] == :start
            @goal  = [x, y] if fchara[e] == :goal
            fchara[e]
          }
        }
        @size = @map.size
      else
        @size = arg.keys.size
        @map = Array.new(@size) { Array.new(@size, :space) }
        arg.keys.sort.each { |y|
          arg[y].keys.sort.each { |x|
            @map[y][x] = arg[y][x]
            @start = [x, y] if arg[y][x] == :start
            @goal  = [x, y] if arg[y][x] == :goal
          }
        }
      end
    end

    def set(x, y, c)
      @map[y][x] = c
    end
  
    def get(x, y)
      return @map[y][x] if 0 <= x and x < @size and 0 <= y and y < @size
      return :block
    end

    def start
      return @start
    end

    def goal
      return @goal
    end

    # スタートとゴールを入れ替える
    def swap 
      sx, sy = @start
      gx, gy = @goal
      @start = [gx, gy]
      @goal  = [sx, sy]
      set(sx, sy, :goal)
      set(gx, gy, :start)
    end

    def goal?(x, y)
      gx, gy = goal
      x == gx && y == gy
    end
  
    def make(x, y)
      dir = pos_dir(x, y).sample
      if dir.nil?
        # 開始位置まで戻ってくれば終了
        return if x == @size - 2 and y == 1   
        # 元の位置に戻る
        dx, dy = @@dir[get(x, y)]
        x -= dx * 2
        y -= dy * 2
      else
        # ランダムに選択した向きに移動
        dx, dy = @@dir[dir]
        x += dx
        y += dy
        set(x, y, dir)
        x += dx
        y += dy
        set(x, y, dir)
      end 
      #puts to_s
      #sleep(1)
      make(x, y)
    end
  
    def pos_dir(x, y)
      @@dir.each_pair.map { |dir, d|
        [dir, get(x + d[0]*2, y + d[1]*2)]  # 向きと２マス先のオブジェクトを取得
      }.filter { |dir, e| 
        e == :space                         # 通路のみを残す
      }.map { |dir, e|  
      dir                                   # 方向のみ抽出
      }
    end
  
    def conv() 
      @map = @map.map { |line|
        line.map { |e|
          if e == :block or e == :space
            :block
          else
            :space
          end
        }
      }
      # スタート
      @start = [1, @size-1]
      set(1, @size-1, :start)
      # ゴール
      @goal = [@size-2, 0]
      set(@size-2, 0, :goal)
    end
  
    def to_s(scale = 1, x = nil, y = nil)
      if x
        org = get(x, y)
        set(x, y, :robot)
        str = to_s(scale)
        set(x, y, org)
        return str
      end
      @map.map { |line|
        scale.times.map { 
          line.map { |e| 
            @@chara[e] * scale }.join
        }.join("\r\n")
      }.join("\r\n")
    end
  
    def write(out)
      @map.each { |line|
        line = line.map { |e| 
          @@fchara[e]
        }
        out.puts line.join
      }
    end

    def to_facts
      @map.each_with_index.map { |line, y|
        line = line.each_with_index.map { |e, x| 
          case e
          when :block
            "block(#{x}, #{y})."
          when :space
            "space(#{x}, #{y})."
          when :start
            "start(#{x}, #{y})."
          when :goal
            "goal(#{x}, #{y})."
          end
        }
      }.flatten
    end

    def size
      @size
    end
  end