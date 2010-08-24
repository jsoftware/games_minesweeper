NB. Gtk GUI (Glade) for Minesweeper game
NB. works with J7 gui/gtk addon (either from GtkIDE or console).

Note 'Example command to run'
  MinesweeperGtkGlade 12 12
)
MinesweeperGtkGlade_z_=: conew&'mineswpgtkglade'

NB. =========================================================
NB. Temporary hacks to make stuff work

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
(IFWIN{libgdk,libpixbuf) cddef each <;._2 [ 0 : 0
gdk_pixbuf_new_from_file > x *c x
gdk_pixbuf_new_from_file_utf8 > x *c x
gdk_pixbuf_add_alpha > x x i x x x
)

NB. =========================================================
NB. pixbuf utilities
NB. =========================================================
NB. new verb for reading file images to argb matrix using gtk.
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

OR=: 23 b./
NB. gtk pixels (int) are ABGR with A 255
NB. opengl (and normal folk?) are ARGB with A 0
NB. glpixels and glqpixels need to make these adjustments
3 : 0''
if. IF64 do.
  ALPHA=: 0{_3 ic 0 0 0 255 255 255 255 255{a.
else.
  ALPHA=: 0{_2 ic 0 0 0 255{a.
end.
''
)
NOTALPHA=: 0{_2 ic 255 255 255 0{a.

NB. =========================================================
pixbuf_setpixels=: 4 : 0
gtkpx=. x
'a b w h'=. 4{.y
d=. 4}.y
NB. d=. flip_rgb d
d=. d OR ALPHA
if. IF64 do. d=. 2 ic d end.
NB. create new pixbuf from data
NB. ad,cmap,alpha,bits,w,h,rowstride,destroyfn,fndata
buf=. gdk_pixbuf_new_from_data (15!:14<'d'),GDK_COLORSPACE_RGB,1,8,w,h,(4*w),0,0
NB. bufreport buf
if. buf do.
  gdk_draw_pixbuf gtkpx,0,buf,0,0,a,b,w,h,0,0,0
end.
g_object_unref buf
)

NB. =========================================================
NB. mouse event utilities
NB. =========================================================
get_button=: 3 : 0
256#.endian a.i.memr y,GdkEventButton_button,4
)

NB. event type - distinguish between button 2button 3button
get_type=: 3 : 0
memr y,0 1,JINT
)

get_button_event_data=: 3 : 0
mousepos=. <.2 3{;gdk_event_get_coords y;(,0.0);,0.0
state=. 2{;gdk_event_get_state y;,0
(get_button y),(get_type y),mousepos,(2 3{getGtkWidgetAllocation gtkda),state
)

cocurrent 'base'
NB. End Hacks
NB. =========================================================

require '~addons/games/minesweeper/minefield.ijs'
NB. require 'games/minesweeper/minefield'  NB. use once published
require 'gui/gtk'
coclass 'mineswpgtkglade'
coinsert 'mineswp';'jgtk'

AddonPath=: jpath '~addons/games/minesweeper/'
Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles26.png'

NB. Methods
NB. =========================================================

create=: 3 : 0
  if. -.IFGTK do. gtkinit'' end.
  y=. (0=#y){:: y ; 9 9
  newMinefield y
  IsEnd=: 0
  newwindow 'Minesweeper'
  'GtkBuilder window'=: 'window' gtkglade AddonPath,'uigtk.glade'
  assert. 0~:GtkBuilder
  assert. 0~:window
  gtkda=: gtk_builder_get_object GtkBuilder;'drawingarea1'
  gtk_widget_set_size_request gtkda,((#>{.Tiles)*y)
  GtkSbar=: gtk_builder_get_object GtkBuilder;'statusbar1'    NB. get statusbar widget from builder
  SbarContxt=: gtk_statusbar_get_context_id GtkSbar;'status updates' NB. get context id to use for all msgs

NB.   smoutput gladereport''    NB. display gladereport
  gtk_window_set_type_hint window,GDK_WINDOW_TYPE_HINT_NORMAL
  msgtk_update''
  
  gtk_widget_show window
  if. -.IFGTK do. gtk_main'' end.
)

destroy=: 3 : 0
  cbfree''
  codestroy''
)

msgtk_startnew=: msgtk_update@newMinefield

msgtk_update=: 3 : 0
  'isend msg'=. eval ''
  IsEnd=: isend
  gtk_widget_queue_draw gtkda
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
gettext=: ]

NB. Event Handlers
NB. =========================================================

on_window_delete_event=: 0:

on_window_destroy=: 3 : 0
  g_object_unref GtkBuilder
  if. -.IFGTK do. gtk_main_quit '' end.
  destroy ''
  0
)

NB. drawing area expose events
NB. ---------------------------------------------------------
NB. gtkwin      gtkda window
NB. gtkpx       offscreen pixmap
NB. gtkwh
on_drawingarea1_expose_event=: 3 : 0
  'widget event data'=. y
NB. house keeping
  gtkwin=. getGtkWidgetWindow widget
  gtkdagc=. getdagc widget
  gtkwh=. 2 3{getGtkWidgetAllocation widget
  gtkpx=. gdk_pixmap_new gtkwin,gtkwh,_1
NB. reset background
  gtkpx pixbuf_setpixels 0 0,gtkwh,(*/gtkwh)#0
NB. paint
  gtkpx pixbuf_setpixels 0 0,((#>{.Tiles)*$Map), , ; ,.&.>/"1 Tiles showField IsEnd
NB. render on drawable
  gdk_draw_drawable gtkwin,gtkdagc,gtkpx,0 0 0 0 _1 _1
NB. clean up
  g_object_unref gtkpx
)

NB. drawing area mouse events
NB. ---------------------------------------------------------
on_drawingarea1_button_release_event=: 3 : 0
'widget event data'=. y
  'button type x1 y1 w h state'=. get_button_event_data event
  if. +./ ($Map) < idx=. getTileIdx ":x1,y1 do. return. end.
  select. button
    case. 1 do. msgtk_update@clearTiles idx
    case. 3 do. msgtk_update@markTiles idx
  end.
)

NB. menu events
NB. ---------------------------------------------------------
on_newgame_activate=: 3 : 0
  msgtk_startnew $Map
)

on_options_activate=: 0:

on_exit_activate=: 3 : 0
  gtk_widget_destroy window
)

on_help_activate=: 3 : 0
  mbinfo ('Minesweeper Instructions';Instructions)
)

on_about_activate=: 3 : 0
  mbinfo ('About Minesweeper';About)
)

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
