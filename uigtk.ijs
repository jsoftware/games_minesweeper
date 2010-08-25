NB. Gtk user interface for Minesweeper game
NB. works with J7 gui/gtk addon (either from GtkIDE or console).

Note 'Example commands to run'
  MinesweeperGtk ''
  MinesweeperGtk 12 12
)
MinesweeperGtk_z_=: conew&'mineswpgtk'

NB. =========================================================
NB. Temporary hacks to make stuff work

require 'gui/gtk'
cocurrent 'jgtk'

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
gtk_tooltips_new > x
gtk_tooltips_set_tip > n x x *c *c
)
(IFWIN{libgdk,libpixbuf) cddef each <;._2 [ 0 : 0
gdk_pixbuf_new_from_file > x *c x
gdk_pixbuf_new_from_file_utf8 > x *c x
gdk_pixbuf_add_alpha > x x i x x x
)
libgobject cddef each <;._2 [ 0 : 0
g_object_ref_sink > x x
)

create_menu_command=: 3 : 0
'menu id icon text letter tip cb'=. y
NB. TODO i18n accel/letter
text=. gettext text
tip=. gettext tip
if. #icon do.
  if. 'check' -: 5{.icon do.
    cb_item=. gtk_check_menu_item_new_with_mnemonic <text
    gtk_check_menu_item_set_active cb_item,{. 0 ". 5 }. icon
  else.
    cb_item=. gtk_image_menu_item_new_with_mnemonic <text
    gtk_image_menu_item_set_image cb_item;gtk_image_new_from_stock icon;1
  end.
else.
  cb_item=. gtk_menu_item_new_with_mnemonic <text
end.
if. #letter do.
  msk=. +/('cs'e.letter)#GDK_CONTROL_MASK,GDK_SHIFT_MASK
  letter=. letter-.'cs'
  if. 1=#letter do.
    key=. a.i.{.letter
  elseif. 'F'={.letter do.
    key=. GDK_F1 + <:0 ". }.letter
  elseif. 6=#letter do.
    key=. GDK_Return
  elseif. 1 do.
    key=. a.i.{:letter
  end.
  create_menu_accel window;cb_item;id;key;msk
end.
if. #tip do.
  if. 0=nc <'menutooltips' do.
    gtk_tooltips_set_tip menutooltips;cb_item;tip;<<0
  end.
end.
if. #cb do.
  consig cb_item;'activate';cb
end.
gtk_menu_shell_append menu,cb_item
cb_item
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

require 'games/minesweeper/minefield'
require 'gui/gtk'
coclass 'mineswpgtk'
coinsert 'mineswp';'jgtk'

AddonPath=. jpath '~addons/games/minesweeper/'
Tiles=: ,((2 2 $ #) <;._3 ]) readimg AddonPath,'tiles26.png'

NB. Methods
NB. =========================================================

create=: 3 : 0
  if. -.IFGTK do. gtkinit'' end.
  newMinefield y
  IsEnd=: 0

  newwindow 'Minesweeper GTK'                         NB. create new window with Title
  consig window;'destroy';'window_destroy'            NB. assign event handler for event
  box1=. gtk_vbox_new 0 0                             NB. create vertical box container for widgets
  gtk_container_add window, box1                      NB. Add the container to the window
NB. tooltips group
  menutooltips=: gtk_tooltips_new''                   
NB. menu bar
  menu_init''
  mb=. edit_menu''
  gtk_box_pack_start box1, mb, 0 0 0                  NB. pack menubar in the vertical box
NB. drawing area
  gtkda=: gtk_drawing_area_new''
  gtk_widget_set_size_request gtkda,((#>{.Tiles)*$Map)
  NB. GDK_LEAVE_NOTIFY_MASK,GDK_POINTER_MOTION_HINT_MASK
  events=. GDK_EXPOSURE_MASK,GDK_BUTTON_PRESS_MASK,GDK_BUTTON_RELEASE_MASK,GDK_POINTER_MOTION_MASK
  gtk_widget_add_events gtkda, OR events
  consig3 gtkda;'expose_event';'gtkda_minefld_expose_event'
  consig3 gtkda;'button_release_event';'gtkda_minefld_button_release_event'
  gtk_box_pack_start box1, gtkda, 1 1 0               NB. pack drawing area in the vertical box
NB. status bar
  GtkSbar=: gtk_statusbar_new ''
  SbarContxt=: gtk_statusbar_get_context_id GtkSbar;'msg'
  gtk_box_pack_start box1, GtkSbar, 0 0 0             NB. pack statusbar in the vertical box
  windowfinish''

  msgtk_update''
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

window_delete=: 0:

window_destroy=: 3 : 0
  g_object_ref_sink menutooltips
  if. -.IFGTK do. gtk_main_quit '' end.
  destroy ''
  0
)

NB. drawing area expose events
NB. ---------------------------------------------------------
NB. gtkwin      gtkda window
NB. gtkpx       offscreen pixmap
NB. gtkwh
gtkda_minefld_expose_event=: 3 : 0
  'widget event data'=. y
  NB. house keeping
  gtkwin=. getGtkWidgetWindow widget
  gtkdagc=. getdagc widget
  gtkwh=. 2 3{getGtkWidgetAllocation widget
  gtkpx=. gdk_pixmap_new gtkwin,gtkwh,_1
  gtkpx pixbuf_setpixels 0 0,gtkwh,(*/gtkwh)#0                 NB. reset background
  imgpixels=. ; ,.&.>/"1 Tiles showField IsEnd                 NB. get matrix of argb values to paint
  gtkpx pixbuf_setpixels 0 0,((#>{.Tiles)*$Map), , imgpixels   NB. the real 'paint'
  gdk_draw_drawable gtkwin,gtkdagc,gtkpx,0 0 0 0 _1 _1         NB. render on drawable
  g_object_unref gtkpx                                         NB. clean up
)

NB. drawing area mouse events
NB. ---------------------------------------------------------
gtkda_minefld_button_release_event=: 3 : 0
'widget event data'=. y
  'button type x1 y1 w h state'=. get_button_event_data event
  if. +./ IsEnd , ($Map)<idx=. getTileIdx ":x1,y1 do. return. end.
  select. button
    case. 1 do. msgtk_update@clearTiles idx
    case. 3 do. msgtk_update@markTiles idx
  end.
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

helphelp_activate=: 3 : 0
  mbinfo ((gettext 'Minesweeper Instructions');Instructions)
)

helpabout_activate=: 3 : 0
  mbinfo ((gettext 'About Minesweeper');About)
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
gamenew,gtk-new,_New Game,,Start a new game,gamenew_activate
gameoption,gtk-preferences,_Options,,Not implemented,gameoption_activate
gamequit,gtk-quit,_Quit,cQ,Quit the program,gamequit_activate

helphelp,gtk-help,_Instructions,,,helphelp_activate
helpabout,gtk-about,_About,,,helpabout_activate
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
  con ccmenu 'helphelp'
  con ccmenu 'helpabout'
)
