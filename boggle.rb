require 'pp'

class Boggle
  require 'set'

  attr_reader :words

  def self.solve(str)
    new(str).solve
  end

  def initialize(str)
    @str = str.dup
    @side = Math.sqrt(@str.length).round
    
    raise 'Invalid Board' unless @side ** 2 == @str.length

    @positions = {}
    @str.each_char.with_index do |c, i|
      @positions[c] ||= []
      @positions[c] << [i / @side, i % @side]
    end

    @possible = Regexp.new("^[#{@positions.keys.join}]{3,#{@str.length}}$")

    @seen ||= Set.new
  end

  def solve
    if !@words
      @words = []
      File.new('/usr/share/dict/words', 'r').each_line do |word|
        word.chomp!
        @words << word if has_word?(word)
      end
    end
      
    self
  end

  private

  def has_word?(word)
    return false unless word =~ @possible

    @positions[word[0]].each do |x, y|
      return true if find(word, x, y)
    end

    false
  end

  def find(word, x, y, idx = 1, seen = @seen.clear)
    return true if idx == word.length

    seen << coord = x * @side + y

    @positions[word[idx]].each do |i, j|
      if (x-i).abs <= 1 && (y-j).abs <= 1 && !seen.include?(i * @side + j)
        return true if find(word, i, j, idx + 1, seen)
      end
    end

    seen.delete(coord)

    false
  end
end

b = Boggle.solve('fxieamloewbxastu')
pp b.words.group_by(&:length)
