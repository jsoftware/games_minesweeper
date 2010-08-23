NB. Gtk user interface for Minesweeper game
NB. works with J7 gui/gtk addon (either from GtkIDE or console).

Note 'Example command to run'
  MinesweeperGtk 12 12
)
MinesweeperGtk_z_=: conew&'mineswpgtk'

NB. =========================================================
NB. Temporary hacks to make stuff work

require 'gui/gtk'
cocurrent 'jgtk'

NB. gtkgraph changes not yet in released gui/gtk
glpaintx_jgtkgraph_=: 3 : 0 "1
  glclear''
  paint''
  gdk_draw_drawable gtkwin,gtkdagc,gtkpx,0 0 0 0 _1 _1
)

configure_event_jgtkgraph_=: 3 : 0
'widget event data'=. y
if. 0=gtkwin do. gtkwin=: getGtkWidgetWindow gtkda end.
if. 0=gtkdagc do. gtkdagc=: getdagc gtkda end.
gtkwh=: 2 3{gtkxywh=: getGtkWidgetAllocation gtkda
if. gtkpx do. g_object_unref gtkpx end.
gtkpx=: gdk_pixmap_new gtkwin,gtkwh,_1
if. 0=gtkgc do. gtkgc=: gdk_gc_new gtkwin end.
0
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
(IFWIN{libgdk,libpixbuf) cddef each <;._2 [ 0 : 0
gdk_pixbuf_new_from_file > x *c x
gdk_pixbuf_new_from_file_utf8 > x *c x
gdk_pixbuf_add_alpha > x x i x x x
)

NB. new verb for reading file images to rgba matrix using gtk.
readimg=: 3 : 0
  if. -.IFGTK do. gtkinit'' end.
  if. 0= buf=. gdk_pixbuf_new_from_file y;0 do. 0 0$0 return. end.
  img=. gdk_pixbuf_add_alpha buf;0;0;0;0
  g_object_unref buf
  ad=. gdk_pixbuf_get_pixels img
  w=. gdk_pixbuf_get_width img
  h=. gdk_pixbuf_get_height img
  s=. gdk_pixbuf_get_rowstride img
  assert. s=4*w
  if. IF64 do.
    r=. _2 ic memr ad,0,(w*h*4),JCHAR
  else.
    r=. memr ad,0,(w*h),JINT
  end.
  g_object_unref img
  (h,w)$r
)
cocurrent 'base'
NB. End Hacks
NB. =========================================================

AddonPath=. jpath '~addons/games/minesweeper/'

load AddonPath,'minefield.ijs'
NB. require 'games/minesweeper/minefield'
require 'gui/gtk'
coclass 'mineswpgtk'
coinsert 'mineswp';'jgtk'

gettext=: ]

Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles26.png'

create=: 3 : 0
  if. -.IFGTK do. gtkinit'' end.
  y=. (0=#y){:: y ; 9 9
  newMinefield y
  IsEnd=: 0  
  newwindow 'Minesweeper'
  consig window;'destroy';'window_destroy'
  box1=. gtk_vbox_new 0 0
  gtk_container_add window, box1
  menu_init''
  mb=. edit_menu''
  gtk_box_pack_start box1, mb, 0 0 0
  locGB=: ((#>{.Tiles)*y) conew 'jgtkgraph'
  locWN=: coname''
  ('jgtkgraph';locWN,copath locWN) copath >locGB
  gtk_box_pack_start box1, gtkbox__locGB, 1 1 0
  GtkSbar=: gtk_statusbar_new ''
  SbarContxt=: gtk_statusbar_get_context_id GtkSbar;'msg'
  gtk_box_pack_start box1, GtkSbar, 1 1 0
  windowfinish''
  msgtk_update''
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
  glpaint__locGB''
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

NB. Event Handlers
NB. =========================================================

paint=: 3 : 0
  glpixels 0 0,((#>{.Tiles)*$Map), , ; ,.&.>/"1 Tiles showField IsEnd
)

window_delete=: 0:

window_destroy=: 3 : 0
  if. -.IFGTK do. gtk_main_quit '' end.
  ((#~ _999 = _999 ". >) copath >locGB) copath >locGB  NB. avoid locale error in Win/GtkIDE
  destroy ''
  0
)


NB. mouse events
NB. ---------------------------------------------------------
mbldown=: 3 : 0
  if. +./ ((#>{.Tiles)*$Marked) <: 2{.".sysdata do. return. end.
  clearTiles__locWN getTileIdx sysdata
  msgtk_update__locWN ''
)

mbrdown=: 3 : 0
  if. +./ ((#>{.Tiles)*$Marked) <: 2{.".sysdata do. return. end.
  markTiles__locWN getTileIdx sysdata
  msgtk_update__locWN ''
)

NB. menu events
NB. ---------------------------------------------------------
gamenew_activate=: 3 : 0
  msgtk_startnew $Map
)

gameoption_activate=: 0:

gamequit_activate=: 3 : 0
  gtk_widget_destroy window
)

helphelp_activate=: mbinfo bind ((gettext 'Minesweeper Instructions');Instructions)
helpabout_activate=: mbinfo bind ((gettext 'About Minesweeper');About)

NB. Text Nouns
NB. =========================================================

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
Authors: Ric Sherlock, Bill Lam

Uses J7 graphics/gtk for GUI
)


NB. Menu bar
NB. =========================================================

NB. replace nb. by NB.
fixNB=: 3 : 0
  x=. I. 'nb.' E. y
  'NB' (0 1 +/~ x) } y
)

getmenu=: 3 : 0
  ndx=. MENUIDS i. <y
  if. ndx=#MENUIDS do.
    ((gettext 'menu not found: '),y) assert 0
  end.
  ndx pick MENUDEF
)

menu_init=: 3 : 0
  f=. < @ (<;._1) @ (','&,)
  j=. f;._2 Menus
  MENUIDS=: {.&> j
  MENUDEF=: }.each j
  0
)

Menus=: fixNB 0 : 0
gamenew,,_New Game,,,gamenew_activate
gameoption,,_Options,,,gameoption_activate
gamequit,gtk-quit,_Quit,cQ,Quit the program,gamequit_activate

help,,_Help,,Help,helphelp_activate
helpabout,gtk-about,_About,,Help About,helpabout_activate
)

edit_menu=: 3 : 0
  mb=. gtk_menu_bar_new''
  game_menu mb
  help_menu mb
  gtk_widget_show_all mb
  mb
)

game_menu=: 3 : 0
  pop=. create_menu_popup y;gettext '_Game'
  con=. create_menu_container pop
  con ccmenu 'gamenew'
  con ccmenu 'gameoption'
  create_menu_sep con
  con ccmenu 'gamequit'
)

help_menu=: 3 : 0
  pop=. create_menu_popup y;gettext '_Help'
  con=. create_menu_container pop
  con ccmenu 'help'
  con ccmenu 'helpabout'
)
