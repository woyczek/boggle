#!/usr/bin/env ruby

MIN_SIZE = 2
DICO = 'france2.txt'
#DICO = '/usr/share/dict/words'

class Point < Complex
  class << self
    alias :new :rectangular
  end
end

class Case 
#class Case < Complex

  def point 
    @c
  end

  def pointH
    @point
  end

  def valeur
    @valeur
  end

  def multi
    @multi
  end

  def abs
    @c.abs
  end

  def pretty_print(inst)
    puts "PP"
    return inst.point.to_s + " : " + inst.valeur.to_s + " x " 
  end

  def -(arg)
    @c-arg
  end

  def initialize(c,valeur,multi)
    @c=c
    @point=c
    @valeur=valeur
    @multi=multi
    puts c.to_s + " - " + valeur.to_s + " - " + multi.to_s
    self
  end

  def self.c_create(c,valeur,multi)
    self.new(c,valeur,multi)
  end

  def self.new(*args,valeur,multi)
    if args.count > 1 then
      super(Complex.rect(args[0].to_i,args[1].to_i),valeur,multi)
    else
      super(c,valeur,multi)
    end
  end

  def self.r_create(x,y,valeur,multi)
    self.c_create(Complex.rect(x,y),valeur,multi)
  end

  def pretty_print(inst)
    puts @point.to_s + " : " + @valeur.to_s + " x " + @multi.to_s
    return @point.to_s + " : " + @valeur.to_s + " x " + @multi.to_s
  end

end

class Boggle
  require 'set'

  attr_reader :words

  #def initialize(str, dict = '/usr/share/dict/words')
  def initialize(str, score = '' , dict = DICO )
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

    #def initialize(str, dict = DICO ) 
    # Ouverture du dictionnaire
    @str = str.dup
    @dict = dict.dup

    @side = Math.sqrt(@str.length).round

    raise 'Invalid Board' unless @side ** 2 == @str.length

    @positions = Hash.new { |h,k| h[k] = [] }
    @positionsC = Hash.new { |h,k| h[k] = [] }
    @str.each_char.with_index do |c, i|
      @positionsC[c] << Case.new(i / @side, i % @side, @scores[c], score.chars[i])
      @positions[c] << Point.new(i / @side, i % @side )
    end

    @possible = Regexp.new("^[#{@positionsC.keys.join}]{3,#{@str.length}}$")

    @visited ||= Set.new
  end

  def solve
    if !@words
      @words = []
      puts @dict
      File.new(@dict, 'r').each_line do |word|
        word.chomp!.downcase
        local_score = has_word?(word)
        if local_score != 0
          @words << word 
          puts "-- " + word + " : " + local_score.to_s
        end
      end
    end

    self
  end

  private

  def has_word?(word)
    unless word =~ @possible
      return 0
    end

    # pp @positions[word][0]
    @positionsC[word[0]].each do |position|
#      pp position

    multi=1
    local_multi=1
    if position.multi == "D" then
      multi=multi*2
    elsif position.multi == "T" then
      multi=multi*3
    else
      local_multi=position.multi
    end

      if (local_score=find(word, position, position.valeur.to_i * local_multi.to_i, multi )) != 0
        return local_score
      end
    end

    0
  end

  def find(word, position, score=0, idx = 1, visited = @visited.clear, multi=1)
#    pp position

    if idx == word.length
      return score
    end

    visited << position
    #:score = score + @scores[word]

    @positionsC[word[idx]].each do |position2|
    local_multi=1
    if position2.multi == "D" then
      multi=multi*2
    elsif position2.multi == "T" then
      multi=multi*3
    else
      local_multi=position2.multi.to_i
    end
      if (position.point - position2.point).abs < 2 && !visited.include?(position2)
        if (local_score=find(word, position2, score+position2.valeur.to_i*local_multi.to_i, idx + 1, visited,multi)) != 0
          puts multi.to_s + " - " + local_multi.to_s
          return local_score
        end
      end
    end

    #:score = score - @scores[@positions[word][idx]]
    visited.delete(position)

    0
  end
end

require 'pp'
#pp Boggle.new('fxieamloewbxastu').solve.words.group_by(&:length)
#
board = ARGV.shift.downcase
scores = ARGV.shift
puts board
#pp Point.new(1,2)
#
t=Case.new(1,2,4,5)
pp t
puts t.abs
puts "toto"

#pp Boggle.new(board).solve.words.group_by(&:length)
Boggle.new(board,scores).solve.words.group_by(&:length)
#pp Boggle.new(board,scores).solve.words.group_by(&:length)
#pp Boggle.new('cretepoeniaialsurteesaint').solve.words.group_by(&:length)
##pp Boggle.new('crEtepoenIaIaLsurtEesAint').solve.words.group_by(&:length)
#puts 'Fin finale'
