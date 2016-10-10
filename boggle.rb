#!/usr/bin/env ruby
class Point < Complex
  class << self
    alias :new :rectangular
  end
end

@scores = hash.new {
  "a" => 1,
  "b" => 3,
  "c" => 3,
  "d" => 2,
  "e" => 1,
  "f" => 4,
  "g" => 2,
  "h" => 4,
  "i" => 1,
  "j" => 8,
  "k" => 10,
  "l" => 2,
  "m" => 2,
  "n" => 2,
  "o" => 1,
  "p" => 4,
  "q" => 8,
  "r" => 2,
  "s" => 1,
  "t" => 1,
  "u" => 1,
  "v" => 4,
  "w" => 10,
  "x" => 10,
  "y" => 10,
  "z" => 10
}

class Boggle
  require 'set'

  attr_reader :words

  #def initialize(str, dict = '/usr/share/dict/words')
  def initialize(str, dict = './france2.txt')
    # Ouverture du dictionnaire
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
#pp Boggle.new('fxieamloewbxastu').solve.words.group_by(&:length)
pp Boggle.new('cretepoeniaialsurteesaint').solve.words.group_by(&:length)
