NB. wd GUI for Minesweeper game

Note 'Example commands to run'
  MinesweeperWd ''
  MinesweeperWd 12 12
)

MinesweeperWd_z_=: 3 : 0
  a=. conew 'mineswpwd'
BSIZE__a=: y
create__a`start_droidwd__a@.(('Android'-:UNAME)>IFQT) a
)

3 : 0''
  require 'gl2 droidwd'
  require 'games/minesweeper/minefield'
  coclass 'mineswpwd'
  coinsert 'mineswp jgl2 wdbase'
  droidwd_run=: create

  AddonPath=. jpath '~addons/games/minesweeper/'
  if. IFQT do.
    mswd_isifld_mbldbl=: mswd_isifld_mbrup  NB. android does not have right click

NB. Tiles=: ,((2 2 $ #) <;._3 ]) readimg_jqtide_ AddonPath,'tiles18.png'
    Tiles=: ,((2 2 $ #) <;._3 ]) readimg_jqtide_ AddonPath,'tiles26.png'
  elseif. 'Android'-:UNAME do.
    mswd_isifld_mbldbl=: mswd_isifld_mbrup  NB. android does not have right click

NB. Tiles=: ,((2 2 $ #) <;._3 ]) readimg_ja_ AddonPath,'tiles18.png'
    Tiles=: ,((2 2 $ #) <;._3 ]) readimg_ja_ AddonPath,'tiles26.png'
  end.
  empty''
)

NB. Form definition
MSWD=: 0 : 0
pc mswd;pn "Minesweeper";
menupop "Game";
menu new "&New Game" "" "" "";
menu options "&Options" "" "" "";
menusep;
menu exit "&Quit" "" "" "";
menupopz;
menupop "Help";
menu help "&Instructions" "" "" "";
menu about "&About" "" "" "";
menupopz;

wh 118 118; cc isifld isigraph;
set isifld stretch 1;
wh 118 14; cc sbar statusbar;
set sbar stretch 0;
rem form end;
)

NB. Methods
NB. =========================================================

create=: 3 : 0
  y=. BSIZE
  wd MSWD
  newMinefield y
  'isend msg'=. eval''
  wd 'set sbar show "',msg,'"'
  wd 'pshow'
  mswd_update@resizeFrm ''
  evtloop''
)

destroy=: 3 : 0
  wd 'pclose'
  codestroy ''
)

mswd_startnew=: mswd_update@newMinefield

mswd_update=: 3 : 0
  'isend msg'=. eval ''
  IsEnd=: isend
  wd 'set sbar show "',msg,'"'
  if. isend do. 
    sminfo 'Game Over';msg 
    msg=. ('K'={.msg) {:: 'won';'lost'
    wd 'set sbar show " You ',msg,'! Try again?"'
  end.
  wd 'set isifld invalid'
  empty''
)

resizeFrm=: 3 : 0
  isisz=. (#>{.Tiles)*$Map
  frmsz=. (0 40 + isisz + 23 6) ,~ 2{. wdqformx''
  wd 'pmovex ',": frmsz
)

getTileIdx=: [: >:@:<. (#>{.Tiles) %~ 2 {. 0&".

NB. Event Handlers
NB. =========================================================

mswd_new_button=: 3 : 0
  mswd_startnew $Map
)

mswd_exit_button=: destroy
mswd_close=: destroy
mswd_cancel=: destroy

mswd_isifld_paint=: 3 : 0
  imgpixels=. ; ,.&.>/"1 Tiles showField IsEnd  NB. get matrix of argb values to paint
  glpixels 0 0,((#>{.Tiles)*$Map), , imgpixels  NB. the real "paint"
  glpaint''
)

mswd_isifld_mblup=: 3 : 0
  if. +./ IsEnd , ($Map)<idx=. getTileIdx sysdata do. return. end.
  mswd_update@clearTiles idx
)

mswd_isifld_mbrup=: 3 : 0
  if. +./ IsEnd , ($Map)<idx=. getTileIdx sysdata do. return. end.
  mswd_update@markTiles idx
)

mswd_about_button=: 3 : 0
  sminfo 'About Minesweeper';About
)

mswd_help_button=: 3 : 0
  sminfo 'Minesweeper Instructions';Instructions
)

NB. Text Nouns
NB. =========================================================

Instructions=: 0 : 0
Object: 
   Uncover (clear) all the tiles that are not mines.

How to play:
 - click on a tile to clear it
 - right-click/long-click on a tile to mark it as a suspected mine
 - if you uncover a number, that is the number of mines adjacent 
    to the tile
 - if you uncover a mine the game ends (you lose)
 - if you uncover all tiles that are not mines the game ends (you win).
)

About=: 0 : 0
Minesweeper Game
Author: Ric Sherlock

Uses Window Driver for GUI
)

NB. Auto-run UI
NB. =========================================================
cocurrent 'base'
MinesweeperWd''
