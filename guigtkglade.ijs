NB. Gtk GUI (Glade) for Minesweeper game
Note 'Example command to run'
  MinesweeperGtkGlade 12 12
)
MinesweeperGtkGlade_z_=: conew&'mineswpgtkglade'

NB. =========================================================
NB. Temporary hacks to make stuff work

NB. media/platimg not published in addons yet.
SystemFolders_j_=: (<jpath '~Addons') (<0 1)}SystemFolders_j_

require 'gui/gtk'
cocurrent 'jgtk'

NB. control error fix in gtkglade not yet in released gui/gtk
gtkglade=: 4 : 0
builder=. gtk_builder_new''
if. 0=builder do. 0 0 return. end.
r=. ''
gerr=: ,-0
if. L.y do.
  rc=. gtk_builder_add_from_string builder;(>y);_1;gerr
else.
  rc=. gtk_builder_add_from_file builder;y;gerr
end.
if. 0= rc do.
  smoutput memr (memr gerr,8 1 4),0 _1
  builder, 0 return.
end.
window=. gtk_builder_get_object builder;x
if. 0=window do. builder, 0 return. end.
GLADESIGNALS=: 0 5$'' NB. global in object locale
h=. cbreg 'gladecallback_',(>coname''),'_'
gtk_builder_connect_signals_full builder,cb7,h
NB. GLADESIGNALS has all glade signal/handler info
gladeconsig GLADESIGNALS
builder,window
)

NB. gtk functions not yet declared in released gui/gtk
libgtk cddef each <;._2 [ 0 : 0
gtk_statusbar_get_context_id > x x *c
gtk_statusbar_get_has_resize_grip > i x
gtk_statusbar_get_type > x
gtk_statusbar_new > x
gtk_statusbar_pop > n x x
gtk_statusbar_push > x x x *c
gtk_statusbar_remove > n x x x
gtk_statusbar_set_has_resize_grip > n x i
)
cocurrent 'base'
NB. End Hacks
NB. =========================================================

AddonPath=. jpath '~addons/games/minesweeper/'

load AddonPath,'minefield.ijs'
require 'gui/gtk'
('jgtkgraph';'jgtk';'z') copath 'jgl2'
coclass 'mineswpgtkglade'
coinsert 'mineswp';'jgtk'

NB. Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles18.png'
Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles26.png'
APath=: AddonPath

create=: 3 : 0
  if. -.IFGTK do. gtkinit'' end.
  'GtkBuilder GtkWin'=: 'window' gtkglade APath,'guigtk.glade'
  assert. 0~:GtkBuilder
  assert. 0~:GtkWin
  GtkDA=: gtk_builder_get_object GtkBuilder;'drawingarea1'
  GtkSbar=: gtk_builder_get_object GtkBuilder;'statusbar1'    NB. get statusbar widget from builder
  SbarContxt=: gtk_statusbar_get_context_id GtkSbar;'status updates' NB. get context id to use for all msgs

NB.   smoutput gladereport''    NB. display gladereport
  msgtk_startnew y
  
  gtk_widget_show GtkWin
  if. -.IFGTK do. gtk_main'' end.
)

destroy=: 3 : 0
  NB.! remove cbreg entries
  cbfree''
  codestroy''
)

msgtk_startnew=: msgtk_update@newMinefield

msgtk_update=: 3 : 0
  'isend msg'=. eval ''
  IsEnd=: isend
  NB.!! repaint gtk form
  updateStatusbar msg
  if. isend do.
    mbinfo 'Game Over';msg
    msg=. ('K'={.msg) {:: 'won';'lost'
    updateStatusbar 'You ',msg,'! Try again?'
  end.
)

updateStatusbar=: 3 : 0
  gtk_statusbar_pop GtkSbar;SbarContxt   NB. clear last msg
  gtk_statusbar_push GtkSbar;SbarContxt;y
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

Uses J7 graphics/gtk for GUI
)

NB. Event Handlers
on_window_delete_event=: 0:

on_exit_activate=: 3 : 0
  gtk_widget_destroy GtkWin
)

on_window_destroy=: 3 : 0
  g_object_unref GtkBuilder
  if. -.IFGTK do. gtk_main_quit '' end.
  destroy ''
)

on_newgame_activate=: msgtk_startnew

on_help_activate=: mbinfo bind ('Minesweeper Instructions';Instructions)
on_about_activate=:  mbinfo bind ('About Minesweeper';About)
on_drawingarea1_expose_event=: 3 : 0
  'drawingarea1' glimgrgb_jgl2_ ; ,.&.>/"1 Tiles showField IsEnd
)

on_drawingarea1_button_release_event=: 3 : 0
  isleftbtn=. 1  NB. determine left or right mouse button
  markTiles`clearTiles@.isleftbtn getTileIdx sysdata
  msgtk_update ''
)
