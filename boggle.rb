require 'pp'

class Boggle
  require 'set'

  def initialize(str)
    @raw = str.dup
    @side = Math.sqrt(@raw.length).round
    
    raise "Invalid Board" unless @side ** 2 == @raw.length

    @board = @raw.chars.each_slice(@side).to_a

    @starts = {}
    @board.each_with_index do |row, i|
      row.each_with_index do |c, j|
        @starts[c] ||= Set.new
        @starts[c] << [i, j]
      end
    end

    @possible = Regexp.new("^[#{@raw.split('').uniq!.join}]{3,#{@raw.length}}$")
  end

  def solve
    results = []
    File.new("/usr/share/dict/words", "r").each_line do |w|
      word = w.chomp
      results << word if has_word?(word)
    end
    results
  end

  private

  def has_word?(word)
    return false unless word =~ @possible

    @starts[word[0]].each do |x, y|
      return true if dfs(word, x, y)
    end

    false
  end

  def dfs(word, x, y, idx = 1, seen = Set.new)
    coord = :"#{x}#{y}"
    seen.add(coord)

    return true if idx == word.length

    x_min = [x-1, 0].max
    x_max = [x+1, @side-1].min
    y_min = [y-1, 0].max
    y_max = [y+1, @side-1].min

    x_min.upto(x_max) do |i|
      y_min.upto(y_max) do |j|
        if @board[i][j] == word[idx] && !seen.include?(:"#{i}#{j}")
          return true if dfs(word, i, j, idx + 1, seen)
        end
      end
    end

    seen.delete(coord)

    false
  end
end

b = Boggle.new('gautprmrdolaesic')
pp b
p b.solve
