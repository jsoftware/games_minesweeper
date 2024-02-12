NB. Qt wd GUI for Minesweeper game

Note 'Example commands to run'
  MinesweeperWd ''
  MinesweeperWd 10 15    NB. 10 rows, 15 cols
)

MinesweeperWd_z_=: 3 : 0
  a=. conew 'mineswpwd'
  create__a y
)

require 'gl2'
require 'games/minesweeper/minefield'
coclass 'mineswpwd'
coinsert 'mineswp jgl2'

3 : 0''
  if. IFQT do.
    readimg=: readimg_jqtide_
  elseif. IFJA do.
    readimg=: readimg_ja_
  elseif. IFJNET do.
    readimg=: readimg_jnet_
  elseif. do.
    require 'png'
    readimg=: readpng
  end.
  empty''
)

AddonPath=: jpath '~addons/games/minesweeper/'
NB. Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles18.png'
Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles26.png'
MFSizes=: ;:'small medium nonsquare large'
MFSize_vals=: 9 9, 12 12, 12 15,: 20 20

NB. Android screen has high dpi
3 : 0''
  if. IFJA do.
    imgstretch=. (i.@[ <.@* #@] % [) { ]
    imgresize=. ([: |: ([: {. [) imgstretch("0 _) [: ] [: |: ([: {: [) imgstretch("0 _) [: ] ])
    android_getdisplaymetrics 0
    Tiles=: ,((2 2 $ #) <;._3 ]) setalpha (imgresize~ ([: <. DM_density_ja_ * |.@$)) 0&setalpha readimg AddonPath,'tiles26.png'
  end.
  empty''
)

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

minwh 234 234; cc isifld isigraph flush;
set isifld stretch 1;
minwh 234 20; cc sbar statusbar;
set sbar stretch 0;
pas 0 0 0 0; pcenter;
rem form end;
)

MSWDJA=: 0 : 0
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

bin v;
bin v;
wh _1 234; cc isifld isigraph flush;
bin zv;
wh _1 _2; cc sbar static;cn "status";
bin z;
bin z;
pas 0 0 0 0; pcenter;
rem form end;
)

MSWDJN=: 0 : 0
pc6j mswd nosize nomax;pn "Minesweeper";
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
sbar 1;sbarshow 1;
xywh 0 0 90 90;cc isifld isigraph rightmove bottommove;
pas 0 0;pcenter;
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

MSOPTSJN=: 0 : 0
pc6j msopts dialog owner closeok;pn "Minesweeper Options";
xywh 10 5 70 70;cc groupbox groupbox;cn "Minefield size";
xywh 20 15 50 12;cc small radiobutton;
xywh 20 30 50 12;cc medium radiobutton group;
xywh 20 45 50 12;cc nonsquare radiobutton group;
xywh 20 60 50 12;cc large radiobutton group;
xywh 20 78 50 12;cc apply button;cn "Apply";
pas 0 0;pcenter;
rem form end;
)


NB. Methods
NB. =========================================================

onStart=: 3 : 0
  y=. ''
  wd MSWDJA
  NB. need unique handle for mswd window to handle multiple instances of class
  MSWD_hwnd=: wd 'qhwndp'  NB. assign hwnd this for mswd in instance locale
  mswd_startnew y
  wd 'pshow'
)

create=: 3 : 0
  if. IFJA do.
    wd 'activity ', >coname''
    return.
  end.
  wd IFQT{::MSWD;~MSWDJN
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
    if. IFJA do.
      wd 'set sbar text "',msg,'"'
      wd 'set isifld invalid'
    elseif. IFQT do.
      wd 'set sbar show "',msg,'"'
      wd 'set isifld invalid'
    elseif. do.
      wd 'sbarset status 80 *',msg
      wd 'setinvalid isifld'
    end.
    empty''
  end.
)

mswd_gameover=: 3 : 0
  result=. ('K'={.y) {:: 'won';'lost'
  msg=. y,LF,LF,' You ',result,'! Try again?'
  if. IFJA do.
    wd 'mb query dialog "Game Over" "',msg,'"'
    return.
  elseif. IFQT do.
    playagain=. wd 'mb query mb_yes mb_no "Game Over" "',msg,'"'
  elseif. do.
    playagain=. (;:'yes no') {~ 2 wdquery 'Game Over';msg
  end.
  select. playagain
    case. 'yes' do. mswd_startnew |.$Map
    case. 'no'  do. destroy''
  end.
)

mswd_qmessagebox_button=: 3 : 0
  select. '*' taketo wd'getp sysdata'
    case. 'yes' do. mswd_startnew |.$Map
    case. 'no'  do. destroy''
  end.
)

mswd_dialog_positive=: 3 : 0
  mswd_startnew |.$Map
)

mswd_dialog_negative=: destroy

mswd_resize=: 3 : 0
  isisz=. ($>{.Tiles)*$Map
  wd 'psel ', MSWD_hwnd
  if. IFQT+.IFJA do.
  wd 'set isifld minwh ',": isisz
  wd^:(-.IFJA) 'pmove _1 _1 1 1'
  else.
  wd 'setxywhx isifld ',": 0 0, isisz
  end.
)

getTileIdx=: [: >:@:<. ($>{.Tiles) %~ 2 {. 0&".

NB. Event Handlers
NB. =========================================================

mswd_new_button=: 3 : 0
  mswd_startnew |.$Map
)

mswd_options_button=: 3 : 0
  if. IFJA do. return. end.
  wd IFQT{::MSOPTS;~MSOPTSJN
  sz=. ;(MFSizes,<'small') {~ MFSize_vals i. |.$Map
  wd 'set ',sz,(IFQT#' value'),' 1'
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
  glpaintx^:IFJA ''
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
  if. IFJA do.
    wd'mb info *',About
  else.
    sminfo 'About Minesweeper';About
  end.
)

mswd_help_button=: 3 : 0
  if. IFJA do.
    wd'mb info *',Instructions
  else.
    sminfo 'Minesweeper Instructions';Instructions
  end.
)

NB. Text Nouns
NB. =========================================================

Instructions=: 0 : 0
Object:
   Uncover (clear) all the tiles that are not mines.

How to play:
 - click on a tile to clear it
 - right-click/long-click on a tile to mark it as a suspected mine
 - if you uncover a number, that is the number of mines adjacent to the tile
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
