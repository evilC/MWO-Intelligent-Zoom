; MWO Intelligent Zoom

; Create an instance of the library
ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

; Set up vars
zooming := 0
calib_list := Array("Basic","Five","Three")

; ============================================================================================
; CONFIG SECTION - Configure ADHD

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "MWO Zoom", version: 1.0, author: "evilC", link: "<a href=""http://evilc.com/proj/adhd"">ADHD Homepage</a>"})
; The default application to limit hotkeys to.
; Starts disabled by default, so no danger setting to whatever you want
ADHD.config_default_app("CryENGINE")

; GUI size
ADHD.config_size(375,300)

; Defines your hotkeys 
; subroutine is the label (subroutine name - like MySub: ) to be called on press of bound key
; uiname is what to refer to it as in the UI (ie Human readable, with spaces)
ADHD.config_hotkey_add({uiname: "Zoom In", subroutine: "ZoomIn"})
ADHD.config_hotkey_add({uiname: "Zoom Out", subroutine: "ZoomOut"})

; Hook into ADHD events
; First parameter is name of event to hook into, second parameter is a function name to launch on that event
ADHD.config_event("app_active", "app_active_hook")
ADHD.config_event("app_inactive", "app_inactive_hook")
ADHD.config_event("option_changed", "option_changed_hook")

ADHD.init()

ADHD.create_gui()

; The "Main" tab is tab 1
Gui, Tab, 1
; ============================================================================================
; GUI SECTION

Gui, Add, Text, x50 yp+25 W50 center, X
Gui, Add, Text, xp+50 yp W50 center, Y
Gui, Add, Text, xp+55 yp W50 center, Colour
Gui, Add, Text, xp+55 yp W50 center, Tol
Gui, Add, Text, xp+55 yp W50 center, Current
Gui, Add, Text, xp+55 yp W50 center, State

Gui, Add, Text, x5 yp+25, Basic
ADHD.gui_add("Edit", "BasicX", "xp+50 yp-3 W40", "", 0)
ADHD.gui_add("Edit", "BasicY", "xp+50 yp W40", "", 0)
ADHD.gui_add("Edit", "BasicCol", "xp+50 yp W50", "", "36ADF5")
ADHD.gui_add("Edit", "BasicTol", "xp+60 yp W40", "", 10)
Gui, Add, Edit, xp+50 yp W50 vBasicCurrent
Gui, Add, Text, xp+60 yp+3 W40 center vBasicState,

Gui, Add, Text, x5 yp+25, 1.5
ADHD.gui_add("Edit", "FiveX", "xp+50 yp-3 W40", "", 0)
ADHD.gui_add("Edit", "FiveY", "xp+50 yp W40", "", 0)
ADHD.gui_add("Edit", "FiveCol", "xp+50 yp W50", "", "36ADF5")
ADHD.gui_add("Edit", "FiveTol", "xp+60 yp W40", "", 10)
Gui, Add, Edit, xp+50 yp W50 vFiveCurrent
Gui, Add, Text, xp+60 yp+3 W40 center vFiveState,

Gui, Add, Text, x5 yp+25, 3.0
ADHD.gui_add("Edit", "ThreeX", "xp+50 yp-3 W40", "", 0)
ADHD.gui_add("Edit", "ThreeY", "xp+50 yp W40", "", 0)
ADHD.gui_add("Edit", "ThreeCol", "xp+50 yp W50", "", "36ADF5")
ADHD.gui_add("Edit", "ThreeTol", "xp+60 yp W40", "", 10)
Gui, Add, Edit, xp+50 yp W50 vThreeCurrent
Gui, Add, Text, xp+60 yp+3 W40 center vThreeState,

Gui, Add, Text, x5 yp+30 vDetZoomLab, Detected Zoom: 
Gui, Add, Text, xp+100 yp W80 vCurrentZoom,

Gui, Add, Text, x5 yp+25, MWO Zoom Key
ADHD.gui_add("Edit", "ZoomKey", "xp+90 yp-3 W40", "", "z")

ADHD.gui_add("CheckBox", "AlwaysOnTop", "x5 yp+40", "Always On Top", 0)

Gui, Add, CheckBox, x5 yp+25 vCalibMode gCalibModeChanged, Calibration Mode
CalibMode_TT := "Use this mode to help you find correct values`nTURN OFF when playing to save CPU time"
; End GUI creation section
; ============================================================================================


ADHD.finish_startup()

return

ZoomIn:
	do_zoom(1)
	return
	
ZoomOut:
	do_zoom(0)
	return

CalibModeChanged:	
	calib_mode_changed()
	return

CalibModeTimer:
	if WinActive("ahk_class CryENGINE"){
		Loop, % calib_list.MaxIndex()
		{
			tmpx := calib_list[A_Index] "X"
			tmpy := calib_list[A_Index] "Y"
			tmpx := %tmpx%
			tmpy := %tmpy%
			PixelGetColor, col, %tmpx%, %tmpy%
			StringSplit, col, col, x
			ctrl := calib_list[A_Index] "Current"
			GuiControl,,%ctrl%, %col2%

			tol := calib_list[A_Index] "Tol"
			tol := %tol%
			
			col := calib_list[A_Index] "Col"
			col := %col%
			
			state := pixel_check(tmpx,tmpy,col,10)
			ctrl := calib_list[A_Index] "State"
			if (state){
				GuiControl,,%ctrl%, YES
			} else {
				GuiControl,,%ctrl%, NO
			}
			
			zoom := get_zoom()
			
			if (zoom == 0){
				str := "Unknown"
			} else {
				str := zoom
			}
			GuiControl,, CurrentZoom, %str%

			;get_zoom()
		}
	}
	return

do_zoom(dir){
	Global zooming
	Global ZoomKey
	
	if (zooming){
		return
	}
	zooming := 1
	zoom := get_zoom()
	if (zoom){
		if (dir){
			; zoom in
			if (zoom <= 1.5){
				Send {z}
			}
			
		} else {
			; zoom out
			if (zoom > 1){
				if (zoom == 3.0){
					Send {%ZoomKey%}
				} else {
					Send {%ZoomKey%}{%ZoomKey%}
				}
			}
		}
	} else {
		soundbeep, 100, 100
		soundbeep, 100, 100
	}
	sleep, 100
	zooming := 0
}

get_zoom(){
	zoom := 0
	if (mult_visible()){
		if (!is_3()){
			if (!is_5()){
				zoom := 1.0
			} else {
				zoom := 1.5
			}
		} else {
			zoom := 3.0
		}
	}
	return zoom
}

; Detects if x is present (is 1.0x, 1.5x or 3.0x likely to be visible?)
; 1920x1200 = 1322,839
mult_visible(){
	global BasicX
	global BasicY
	global BasicCol
	global BasicTol
	
	return (pixel_check(BasicX,BasicY,BasicCol,BasicTol))
}

; Detects between 1.5x and 1.0x
; 1920x1200 = 1314,837
is_5(){
	global FiveX
	global FiveY
	global FiveCol
	global FiveTol
	
	return (pixel_check(FiveX,FiveY,FiveCol,FiveTol))
}

; Detects if 3.0
; 1920x1200 = 1305,835
is_3(){
	global ThreeX
	global ThreeY
	global ThreeCol
	global ThreeTol
	
	return (pixel_check(ThreeX,ThreeY,ThreeCol,ThreeTol))
}

; Default colour is 0x36adf5
pixel_check(x,y,col,tol){
	col := "0x" col
	PixelSearch, outx, outy, %x%, %y%, %x%, %y%, %col% , %tol%, Fast
	if Errorlevel {
		return 0
	} else {
		return 1
	}
}
	
app_active_hook(){
	
}

app_inactive_hook(){

}

option_changed_hook(){
	global ADHD
	
	set_always_on_top()
	calib_mode_changed()
}

calib_mode_changed(){
	global CalibMode
	gui, submit, nohide
	
	if (CalibMode){
		Guicontrol, -hidden, DetZoomLab
		Guicontrol, -hidden, CurrentZoom
		SetTimer, CalibModeTimer, 100
	} else {
		Guicontrol, +hidden, DetZoomLab
		Guicontrol, +hidden, CurrentZoom
		SetTimer, CalibModeTimer, Off
		GuiControl,,BasicState,
		GuiControl,,FiveState,
		GuiControl,,ThreeState,

	}
}

set_always_on_top(){
	global AlwaysOnTop
	
	if (AlwaysOnTop){
		Gui,+AlwaysOnTop
	} else {
		Gui,-AlwaysOnTop
	}
}

; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this
