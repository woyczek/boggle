Dictionnaries from :
English :
twl06.txt 
Francais :
http://www.pallier.org/ressources/dicofr/liste.de.mots.francais.frgut.txt

#
# SPECS
#
# script_name.rb <grid> <bonus> [-g|--grid] [-w|--word WORD] [-l|--lang LANG]
#
# grid is a square grid transformed in string of letters. It may include any char from [.-_()+@/]
#   --> It will be verified nxn sized.
#   aeio | ae.io | (ae)(io) | ae_io
#
#
# bonus is a square grid transformed in string. It may include any char from [.-_()+@/]
#   --> It will be verified nxn sized but by "grid" method
#   1113 | 11.13 | 1.13.1
#   Bonus may be n, T, D, B for "n x letter value", "triple word", "double word", "bonus word"
#
# -g|--grid displays the grid, but dont solve it
#
# -w|--word word displays the word on the grid
#
# -l|--lang changes the dictionnary and the scoring matrix curently (fr|en)

