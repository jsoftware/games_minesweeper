NB. Qt wd GUI for Minesweeper game

Note 'Example commands to run'
  MinesweeperWd ''
  MinesweeperWd 10 15    NB. 10 rows, 15 cols
)

MinesweeperWd_z_=: 3 : 0
  a=. conew 'mineswpwd'
  create__a`start_droidwd__a@.IFJCDROID y
)

require 'gl2 droidwd'
require 'games/minesweeper/minefield'
coclass 'mineswpwd'
coinsert 'mineswp jgl2'
droidwd_run=: create

3 : 0''
  if. IFQT do.
    readimg=: readimg_jqtide_
  elseif. 'Android'-:UNAME do.
    readimg=: readimg_ja_
  end.
  empty''
)

AddonPath=. jpath '~addons/games/minesweeper/'
NB. Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles18.png'
Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles26.png'
MFSizes=: ;:'small medium nonsquare large'
MFSize_vals=: 9 9, 12 12, 12 15,: 20 20

NB. Form definitions
NB. =========================================================
MSWD=: 0 : 0
pc mswd nosize;pn "Minesweeper";
menupop "&Game";
menu new "&New Game";
menu options "&Options";
menusep;
menu exit "&Quit";
menupopz;
menupop "&Help";
menu help "&Instructions";
menu about "&About";
menupopz;

wh 234 234; cc isifld isigraph;
set isifld stretch 1;
wh 234 20; cc sbar statusbar;
set sbar stretch 0;
pas 0 0 0 0; pcenter;
rem form end;
)

MSOPTS=: 0 : 0
pc msopts dialog owner closeok escclose closebutton;pn "Minesweeper Options";
bin h;
groupbox "Minefield size";
cc small radiobutton;
cc medium radiobutton group;
cc nonsquare radiobutton group;
cc large radiobutton group;
groupboxend;
bin vs1;
cc apply button; cn "Apply";
bin zz;
pas 0 0;pcenter;
)


NB. Methods
NB. =========================================================

create=: 3 : 0
  wd MSWD
  NB. need unique handle for mswd window to handle multiple instances of class
  MSWD_hwnd=: wd 'qhwndp'  NB. assign hwnd this for mswd in instance locale
  mswd_startnew y
  wd 'pshow'
)

destroy=: 3 : 0
  wd 'pclose'
  codestroy ''
)

mswd_startnew=: mswd_update@mswd_resize@newMinefield

mswd_update=: 3 : 0
  'isend msg'=. eval ''
  IsEnd=: isend
  if. isend do.
    mswd_gameover msg
  else.
    wd 'set sbar show "',msg,'"'
    wd 'set isifld invalid'
    empty''
  end.
)

mswd_gameover=: 3 : 0
  result=. ('K'={.y) {:: 'won';'lost'
  msg=. y,LF,LF,' You ',result,'! Try again?'
  playagain=. wd 'mb query mb_yes mb_no "Game Over" "',msg,'"'
  select. playagain
    case. 'yes' do. mswd_startnew |.$Map
    case. 'no'  do. destroy''
  end.
)

mswd_resize=: 3 : 0
  isisz=. ($>{.Tiles)*$Map
  wd 'psel ', MSWD_hwnd
  wd 'set isifld minwh ',": isisz
  wd 'pmove _1 _1 1 1'
)

getTileIdx=: [: >:@:<. ($>{.Tiles) %~ 2 {. 0&".

NB. Event Handlers
NB. =========================================================

mswd_new_button=: 3 : 0
  mswd_startnew |.$Map
)

mswd_options_button=: 3 : 0
  wd MSOPTS
  sz=. ;(MFSizes,<'small') {~ MFSize_vals i. |.$Map
  wd 'set ',sz,' value 1'
  wd 'pshow'
)

msopts_apply_button=: 3 : 0
  sz=. ,MFSize_vals #~ 0 ". ".&> MFSizes
  wd 'pclose'
  mswd_startnew sz
)

mswd_exit_button=: destroy
mswd_close=: destroy
mswd_cancel=: destroy

mswd_isifld_paint=: 3 : 0
  imgpixels=. ; ,.&.>/"1 Tiles showField IsEnd  NB. get matrix of argb values to paint
  glpixels 0 0,(($>{.Tiles)*$Map), , imgpixels  NB. the real "paint"
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

mswd_isifld_mbldbl=: mswd_isifld_mbrup  NB. android does not have right click

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

Uses Qt Window Driver for GUI
)

NB. Auto-run UI
NB. =========================================================
cocurrent 'base'
MinesweeperWd''
