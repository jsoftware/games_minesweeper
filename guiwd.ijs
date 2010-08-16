NB. wd GUI for Minesweeper game
Note 'Example command to run'
  MinesweeperWd 12 12
)
MinesweeperWd_z_=: conew&'mineswpwd'

AddonPath=. jpath '~addons/games/minesweeper/'

load AddonPath,'minefield.ijs'
require 'media/platimg gl2'
coclass 'mineswpwd'
coinsert 'mineswp';'pplatimg';'jgl2'

NB. Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles18.png'
Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles26.png'

MSWD=: 0 : 0
pc mswd nosize nomax;pn "Minesweeper";
menupop "Game";
menu new "&New Game" "" "" "";
menu options "&Options" "" "" "";
menusep;
menu exit "&Exit" "" "" "";
menupopz;
menupop "Help";
menu help "&Instructions" "" "" "";
menu about "&About" "" "" "";
menupopz;
sbar 1;sbarset status 80 "";sbarshow;
xywh 0 0 90 90;cc isifld isigraph rightmove bottommove;
pas 0 0;pcenter;
rem form end;
)

create=: 3 : 0
  wd MSWD
  mswd_startnew y
  wd 'pshow;'
)

destroy=: 3 : 0
  wd 'pclose'
  codestroy ''
)

mswd_startnew=: mswd_update@resizeFrm@newMinefield

mswd_update=: 3 : 0
  'isend msg'=. eval ''
  IsEnd=: isend
  wd 'psel mswd; setinvalid isifld'
  wd 'sbarset status -1 "',msg,'"'
  if. isend do. 
    wdinfo 'Game Over';msg 
    msg=. ('K'={.msg) {:: 'won';'lost'
    wd 'sbarset status -1 "You ',msg,'! Try again?"'
  end.
  empty''
)

resizeFrm=: 3 : 0
  isisz=. (#>{.Tiles)*$Map
  frmsz=. (10 72 + isisz) ,~ 2{. 0". wd 'qformx'
  wd 'pmovex ',": frmsz
)

getTileIdx=: [: >:@:<. (#>{.Tiles) %~ 2 {. 0&".

Instructions=: 0 : 0
Object: 
   Uncover (clear) all the tiles that are not mines.

How to play:
 - click on a tile to clear it
 - right-click on a tile to mark it as a suspected mine
 - if you uncover a number, that is the number of mines adjacent 
    to the tile
 - if you uncover a mine the game ends (you lose)
 - if you uncover all tiles that are not mines the game ends (you win).
)

About=: 0 : 0
Minesweeper Game
Author: Ric Sherlock

Uses J6 Window Driver for GUI
)

NB. Event Handlers
mswd_new_button=: mswd_startnew
mswd_exit_button=: destroy
mswd_close=: destroy
mswd_cancel=: destroy

mswd_isifld_paint=: 3 : 0
  'isifld' glimgrgb ; ,.&.>/"1 Tiles showField IsEnd
)

mswd_isifld_mblup=: 3 : 0
  clearTiles getTileIdx sysdata
  mswd_update ''
)

mswd_isifld_mbrup=: 3 : 0
  markTiles getTileIdx sysdata
  mswd_update ''
)

mswd_about_button=: 3 : 0
  wdinfo 'About Minesweeper';About
)

mswd_help_button=: 3 : 0
  wdinfo 'Minesweeper Instructions';Instructions
)
