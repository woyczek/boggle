#!/usr/bin/env ruby

@lang="fr"
DEFLANG="fr"

MIN_SIZE = 2
ENG = 'anglais.txt'
FRA = 'france2.txt'
#DICO = '/usr/share/dict/words'
DICO=FRA

def help
#
# SPECS
#
print '
script_name.rb <grid> <bonus> [-g|--grid] [-w|--word WORD] [-l|--lang LANG]

grid is a square grid transformed in string of letters. It may include any char from [.-_()+@/]
  --> It will be verified nxn sized.
  aeio | ae.io | (ae)(io) | ae_io 


bonus is a square grid transformed in string. It may include any char from [.-_()+@/]
  --> It will be verified nxn sized but by "grid" method
  1113 | 11.13 | 1.13.1 
  Bonus may be n, T, D, B for "n x letter value", "triple word", "double word", "bonus word"
  
-g|--grid displays the grid, but dont solve it

-w|--word word displays the word on the grid

-l|--lang changes the dictionnary and the scoring matrix curently (fr|en)
'
end


class Point < Complex
  class << self
    alias :new :rectangular
  end
end

class Case 
#class Case < Complex

  attr_accessor :visited 
  attr_accessor :valeur 
  attr_accessor :multi
  attr_accessor :numorder

  def visited
    @visited=true
  end

  def point 
    @c
  end

  def pointH
    @point
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

  def initialize(c,valeur,multi,numorder=0)
    @multi=1
    @valeur=1
    @numorder=numorder
    @c=c
    @point=c
    @valeur=valeur unless (valeur==nil || valeur=='')
    @multi=multi unless (multi==nil || multi=='')
#    puts c.to_s + " - " + valeur.to_s + " - " + multi.to_s
    self
  end

  def self.c_create(c,valeur,multi,numorder)
    self.new(c,valeur,multi)
  end

  def self.new(*args,valeur,multi,numorder)
    if args.count > 1 then
      super(Complex.rect(args[0].to_i,args[1].to_i),valeur,multi,numorder)
    else
      super(c,valeur,multi,numorder)
    end
  end

  def self.r_create(x,y,valeur,multi,numorder)
    self.c_create(Complex.rect(x,y),valeur,multi,numorder)
  end

  def pretty_print(inst)
    puts @numorder.to_s + " " + @point.to_s + " : " + @valeur.to_s + " x " + @multi.to_s + ( @visited ? " V" : " -")
    return @point.to_s + " : " + @valeur.to_s + " x " + @multi.to_s
  end

end

class Boggle
  require 'set'

  attr_reader :words

  #def initialize(str, dict = '/usr/share/dict/words')
  def initialize(str, score = '' , dict = "", lang="en" )
    if dict == "" then
      dict = FRA if lang == "fr"
      dict = ENG if lang == "en"
    end
    @fra = {
      "a" => 1,  "b" => 4,  "c" => 4,  "d" => 5,  "e" => 1,
      "f" => 5,  "g" => 3,  "h" => 4,  "i" => 1,  "j" => 8,
      "k" => 10, "l" => 2,  "m" => 3,  "n" => 2,  "o" => 1,
      "p" => 4,  "q" => 8,  "r" => 2,  "s" => 1,  "t" => 1,
      "u" => 1,  "v" => 5,  "w" => 10, "x" => 10, "y" => 10,
      "z" => 10
    }
    @eng = {
      "a" => 1,  "b" => 3,  "c" => 4,  "d" => 2,  "e" => 1,
      "f" => 4,  "g" => 2,  "h" => 5,  "i" => 1,  "j" => 8,
      "k" => 6,  "l" => 2,  "m" => 2,  "n" => 2,  "o" => 2,
      "p" => 4,  "q" => 8,  "r" => 2,  "s" => 2,  "t" => 2,
      "u" => 1,  "v" => 4,  "w" => 5,  "x" => 5,  "y" => 5,
      "z" => 5 
    }
    @scores=@fra if lang == "fr"
    @scores=@eng if lang == "en"

    #def initialize(str, dict = DICO ) 
    # Ouverture du dictionnaire
    @str = str.dup
    @dict = dict.dup

    @score_str=score.dup

    @side = Math.sqrt(@str.length).round

    raise 'Invalid Board' unless @side ** 2 == @str.length

    @positions = Hash.new { |h,k| h[k] = [] }
    @positionsC = Hash.new { |h,k| h[k] = [] }
    @str.each_char.with_index do |c, i|
      @positionsC[c] << Case.new(i / @side, i % @side, @scores[c], score.chars[i], i)
      @positions[c] << Point.new(i / @side, i % @side )
    end

    @possible = Regexp.new("^[#{@positionsC.keys.join}]{3,#{@str.length}}$")

    @visited ||= Set.new
    @v_cells ||= Array.new
    self
  end

  def solve(display=false,word="")
    if !@words
      @words = []
      #puts @dict
      if word != "" then
        #puts word
        search_for_word(word,display)
      else
        File.new(@dict, 'r').each_line do |word|
          search_for_word(word,display)
        end
      end
    end

    self
  end

  def show_grid(word='')
  #  require 'pp'
    # Displays grid, with the first found word if any
    @rows = Array.new
    rownum = 0
    row = ""
    r = 0
    @str.each_char.with_index do |c, i|
  #  @positionsC.each do |pos|
  #    c=pos[0]
  #    pos[1].each do |p|
  #      pp p
  #      i=p.numorder
        # divide total positions by side
        s = " [2;"
        b='44;' if @v_cells[i]
        b='40;' unless @v_cells[i]
        if @score_str[i].to_i > 0 then
          if @score_str[i].to_i > 1 then
            f="33;"
            s = s + b + "5;" + f + "m"
          else
            f="37;"
            s = s + b + "5;" + f + "m"
          end
          s = s +(@score_str[i].to_i * @scores[c].to_i ).to_s.rjust(2)
        else
          if @score_str[i].downcase == "d" then
            f="31;"
            s = s + "0;" + b + f + "m"
          elsif @score_str[i].downcase == "t" then
            f="32;"
            s = s + "0;" + b + f + "m"
          elsif @score_str[i].downcase == "b" then
            f="35;"
            s = s + "0;" + b + f + "m"
          end
          s = s + @scores[c].to_s.rjust(2)
        end
        row = row + s + "[0;" + b + f + "1m" + c.upcase + "[0m"
        # If next position is on next row, 
        r = (i+1) / @side
        if r != rownum then
          @rows[ r ] = row
          row = ""
          rownum = r
        end
  #    end
    end
    #puts DICO
    @rows.each do | s |
      puts s
    end
    show_best(1) if defined?(@words)
  end

  def Boggle.display_words(arr)
    # Display an array of word/size/score
    arr.each do | w |
      puts w[1].to_s + " : " + w[0] + " " + w[0].length.to_s 
    end
  end

  def show_best(number)
    arr=@words.sort { |a,b| a[1] <=> b[1] }.last(number)
    #Boggle.display_words(arr)
    arr
  end

  def show_longuest(number)
    arr=@words.sort { |a,b| a[0].length <=> b[0].length }.last(number)
    #Boggle.display_words(arr)
    arr
  end

  private

  def has_word?(word)
    # OK if the cell is the starting of a dictionnary word
    unless word =~ @possible
      return 0
    end

    @positionsC[word[0]].each do |position|
      # List cells for every char from the word

      # Switch cell bonus into word/letter multiplier
      l_multi=1
      w_multi=1
      if position.multi == "" then
        l_multi=1
      elsif position.multi == nil then
        l_multi=1
      elsif position.multi == "D" then
        l_multi=w_multi*2
      elsif position.multi == "T" then
        l_multi=w_multi*3
      elsif position.multi == "B" then
        l_multi=w_multi*1
      else
        l_multi=position.multi.to_i
      end
      #l_multi=1 if l_multi<1

      # if a word is found, return the word score
      if (local_score=find(word, position, position.valeur.to_i * l_multi, 1 , @visited.clear, w_multi)) != 0
        # The score is only multipiled by word multiplier at the time the end of the dictionnary word is reached
        return local_score 
      end
    end

    0
  end

  def search_for_word(word,display=false)
    # Search for a word in the tree, and display if needed
      #puts word
    if @words then
      word=word.chomp.downcase
      local_score = has_word?(word)
      if local_score != 0
        @words << [ word, local_score ]
        puts "-- " + word + " : " + local_score.to_s if display
      end
    end
  end

  def find(word, position, score=0, idx = 1, visited = @visited.clear, w_multi_local=1)
    # Recursive search method to find a word in the tree previously built

    if idx == word.length
      # Word is found. The score is multiplied by word multiplier.
      visited.each do |v|
        @v_cells[v.numorder]=true
      end
      @v_cells[position.numorder]=true
      return score * w_multi_local
    end

    # Add cell to visited positions
    visited << position

    @positionsC[word[idx]].each do |position2|
      w_multi=w_multi_local
      l_multi=1
      if position2.multi == "D" then
        w_multi=w_multi*2
      elsif position2.multi == "T" then
        w_multi=w_multi*3
      else
        l_multi=position2.multi.to_i
      end
      if (position.point - position2.point).abs < 2 && !visited.include?(position2)
        if (local_score=find(word, position2, score+position2.valeur.to_i * l_multi, idx + 1, 
                             visited, w_multi)) != 0
        #  puts local_score.to_s + " - " + w_multi.to_s
          return local_score # * w_multi
        end
      end
    end

    # Remove cell to visited positions if the word is still uncomplete
    # If not, the function has been breaked by "return" so this line is not executed
    visited.delete(position)

    0
  end

end

board = ""
scores = ""

puts "Boggle solver -- v2016.2"

word=""
lang=DEFLANG

begin
# Options parser
  while ARGV.size > 0 do
    arg=ARGV.shift
    if (arg == "-g") || (arg == "--grid")
      action="grid"
    elsif (arg == "-w") || (arg == "--word")
      action="word"
      word=ARGV.shift.to_s
    elsif (arg == "-l") || (arg == "--lang")
      lang=ARGV.shift.to_s
    elsif arg =~ /^[a-z]+$/i    ################# BOARD
      puts arg
      board = arg.downcase.tr('.-/@+_()=','')
      scores = scores.ljust(board.size,'1')
    elsif arg =~ /^[0-9dt]+$/i  ################# SCORES
      scores = arg.tr('.-/@+_()=','').ljust(board.size,'1')
    else
      raise "Invalid parameter #{arg}"
    end
  end

  raise "Invalid empty board" if board == ''

  grille = Boggle.new(board,scores,"",lang)

  if action == "grid" then
    puts "GRILLE"
    grille.show_grid
  elsif word != ""
    grille.solve(true,word)
    grille.show_grid(word)
  else
    grille.solve(false)
    arr=grille.show_best(10)
    arr.push(*grille.show_longuest(10))
    Boggle.display_words(arr.sort { |a,b| a[1] <=> b[1] })
  end
  puts ""
rescue Exception => e
  help
  raise e
end
