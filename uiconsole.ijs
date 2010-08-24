NB. Console user interface for Minesweeper game

Note 'Example commands to run'
  fld=: MinesweeperCon ''
  fld=: MinesweeperCon 6 6
)
MinesweeperCon_z_=: conew&'mineswpcon'

AddonPath=. jpath '~addons/games/minesweeper/'

load AddonPath,'minefield.ijs'
NB. require 'games/minesweeper/minefield'
require 'media/platimg viewmat'
coclass 'mineswpcon'
coinsert 'mineswp'

TextDisplay=: 1     NB. set to zero to display minefield using viewmat
TilesG26=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles26.png'
TilesA=: ' 12345678**.?'

NB. Methods
NB. =========================================================

create=: 3 : 0
  smoutput Instructions
  mscon_startnew y
)
destroy=: codestroy
quit=: destroy

mscon_startnew=: mscon_update@newMinefield

mscon_update=: 3 : 0
  'isend msg'=. eval ''
  IsEnd=: isend
  smoutput msg
  tiles=. TextDisplay{:: TilesG26;TilesA
  display tiles showField isend
  if. isend do. 
    msg=. ('K'={.msg) {:: 'won';'lost'
    smoutput 'You ',msg,'! Try again?'
    destroy ''
  end.
  empty''
)

clear=: mscon_update@clearTiles
mark=: mscon_update@markTiles

display=: 3 : 0
  if. TextDisplay do.
    smoutput@< y
  else.
    closeall_jviewmat_ :: ] ''
    ([: viewrgb@; ,.&.>/"1) y
  end.
  empty''
)

NB. Text Nouns
NB. =========================================================

Instructions=: 0 : 0
=== MineSweeper ===
Object: 
   Uncover (clear) all the tiles that are not mines.

How to play:
 - start a game using the command:
      fld=: MineSweeperCon <num columns> <num rows>
 - the top, left tile is: 1 1
 - clear an uncleared tile (.) using the command:
      clear__fld <column index> <row index>
 - mark and uncleared tile (?) as a suspected mine using the command:
      mark__fld <column index> <row index>
 - if you uncover a number, that is the number of mines adjacent 
   to the tile
 - if you uncover a mine (*) the game ends (you lose)
 - if you uncover all tiles that are not mines the game ends (you win).
 - quit a game before winning or losing using the command:
      quit__fld ''
)
