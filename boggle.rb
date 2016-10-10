#!/usr/bin/env ruby
class Point < Complex
  # Derivee de matrice (2D) aka complexe
#  def initialize(x,y,score)
#    @score = score
#    @point = super(x,y)
#  end

  #def self.new (x,y,score)
  #  @score = score
  #  @point = self.rectangular(x,y)
  #  self
  #end

#  alias oldNew new
  def score
    @score
  end

  class << self
    def score
      @score
    end

    def create (complexe,sc=1)
      @score = sc
      @c_point=complexe
      self
    end

    def new (reel,imag,sc=1)
      @score = sc
      @c_point=rectangular(reel,imag)
      self
    end

    def to_s(*args)
      super(*args) + " : " + @score.to_s
    end

    def to_x(*args)
      @c_point
    end

    def -(other)
      puts @c_point.to_s
      puts other.to_s
      result=@c_point-other.to_x
      Point.create(result,@score)
    end

    def abs
      @c_point.abs 
    end

    def pretty_print(inst)
      return inst.to_s + " : " + @score.to_s
    end

  end
  alias :inspect :to_s

end

MIN_SIZE = 2
DICO = 'france2.txt'
#DICO = '/usr/share/dict/words'

@scores = {
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
  # Parametres : AEIOTESTB, 123456789, DICO.txt
  def initialize(str, score = '' , dict = DICO )
    # Ouverture du dictionnaire
    @str = str.dup
    @dict = dict
    @score = score

    @side = Math.sqrt(@str.length).round

    raise 'Invalid Board' unless @side ** 2 == @str.length

    # Matrice carree
    @positions = Hash.new { |h,k| h[k] = [] }
    @str.each_char.with_index do |c, i|
      # Creation du point de la matrice de jeu
      @positions[c] << Point.new(i / @side, i % @side, score)
      puts @positions
    end

    # Tableau des mots possibles : toutes les lettres, entre N et length fois.
    @possible = Regexp.new("^[#{@positions.keys.join}]{#{MIN_SIZE},#{@str.length}}$")

    @visited ||= Set.new
  end

  def solve
    if !@words
      @words = []
      File.new(@dict, 'r').each_line do |word|
        word.chomp!.downcase
        @words << word if has_word?(word)
      end
    end

    puts 'Fin solve'
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
#      puts "P:" + position.to_s
#      puts "P2:" + position2.to_s
#      puts position.score
      if (position - position2).abs < 2 && !visited.include?(position2)
        return true if find(word, position2, idx + 1, visited)
      end
    end

    visited.delete(position)

    false
  end
  puts 'Fin init class'
end

require 'pp'
#pp Boggle.new('fxieamloewbxastu').solve.words.group_by(&:length)
#
board = ARGV.shift.downcase
scores = ARGV.shift
puts board
      pp Point.new(1,2,4)
      puts "--- toto"

pp Boggle.new(board,scores).solve.words.group_by(&:length)
#pp Boggle.new('cretepoeniaialsurteesaint').solve.words.group_by(&:length)
#pp Boggle.new('crEtepoenIaIaLsurtEesAint').solve.words.group_by(&:length)
puts 'Fin finale'
