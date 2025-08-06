#!/usr/bin/env ruby
# usage: ruby show_queens_unicode.rb < queens_output.txt

# クイーン記号と盤面の装飾
QUEEN = "Ｑ"
WHITE = "⬜"
BLACK = "⬛"

# queen/2 を含む行ごとに1モデルとする
ARGF.read.split(/^Answer: \d+/).each_with_index do |block, idx|
  queens = block.scan(/queen\((\d+),(\d+)\)/).map { |r, c| [r.to_i, c.to_i] }
  next if queens.empty?

  # 盤面サイズを自動推定
  n = queens.map(&:max).max

  puts "\n=== 解 #{idx} ==="
  (1..n).each do |r|
    row = (1..n).map do |c|
      if queens.include?([r, c])
        QUEEN
      else
        (r + c).even? ? WHITE : BLACK
      end
    end
    puts row.join("")
  end
end
