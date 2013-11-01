class Point < Complex
  class << self
    alias :new :rectangular
  end
end

class Boggle
  require 'set'

  attr_reader :words

  def initialize(str, dict = '/usr/share/dict/words')
    @str = str.dup
    @dict = dict

    @side = Math.sqrt(@str.length).round

    raise 'Invalid Board' unless @side ** 2 == @str.length

    @positions = Hash.new { |h,k| h[k] = [] }
    @str.each_char.with_index do |c, i|
      @positions[c] << Point.new(i / @side, i % @side)
    end

    @possible = Regexp.new("^[#{@positions.keys.join}]{3,#{@str.length}}$")

    @visited ||= Set.new
  end

  def solve
    if !@words
      @words = []
      File.new(@dict, 'r').each_line do |word|
        word.chomp!
        @words << word if has_word?(word)
      end
    end

    self
  end

  private

  def has_word?(word)
    return false unless word =~ @possible

    @positions[word[0]].each do |position|
      return true if find(word, position)
    end

    false
  end

  def find(word, position, idx = 1, visited = @visited.clear)
    return true if idx == word.length

    visited << position

    @positions[word[idx]].each do |position2|
      if (position - position2).abs < 2 && !visited.include?(position2)
        return true if find(word, position2, idx + 1, visited)
      end
    end

    visited.delete(position)

    false
  end
end

require 'pp'

pp Boggle.new('fxieamloewbxastu').solve.words.group_by(&:length)
