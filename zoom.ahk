; MWO Intelligent Zoom

; Create an instance of the library
ADHD := New ADHDLib

zooming := 0

; ============================================================================================
; CONFIG SECTION - Configure ADHD

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "MWO Zoom", version: 0.1, author: "evilC", link: "<a href=""http://evilc.com/proj/adhd"">ADHD Homepage</a>"})
; The default application to limit hotkeys to.
; Starts disabled by default, so no danger setting to whatever you want
ADHD.config_default_app("CryENGINE")

; GUI size
ADHD.config_size(375,335)

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
ADHD.gui_add("Edit", "BasicX", "xp+50 yp W40", "", 0)
ADHD.gui_add("Edit", "BasicY", "xp+50 yp W40", "", 0)
ADHD.gui_add("Edit", "BasicCol", "xp+50 yp W50", "", "36ADF5")
ADHD.gui_add("Edit", "BasicTol", "xp+60 yp W40", "", 10)
Gui, Add, Edit, xp+50 yp W50
Gui, Add, Text, xp+60 yp W40 center, OK

ADHD.gui_add("CheckBox", "AlwaysOnTop", "x5 yp+25", "Always On Top", 0)

Gui, Add, CheckBox, x5 yp+25 vCalibrationMode gcalib_mode_changed, Calibration Mode
CalibrationMode_TT := "Use this mode to help you find correct values"
; End GUI creation section
; ============================================================================================


ADHD.finish_startup()

ZoomIn:
	do_zoom(1)
	return
	
ZoomOut:
	do_zoom(0)
	return

calib_mode_changed:
	soundbeep
	return


do_zoom(dir){
	Global zooming
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
					Send {z}
				} else {
					Send {z}{z}
				}
			}
		}
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
mult_visible(){
	return (pixel_check(1322,839))
}

; Detects between 1.5x and 1.0x
is_5(){
	return (pixel_check(1314,837))
}

; Detects if 3.0
is_3(){
	return (pixel_check(1305,835))
}

pixel_check(x,y){
	PixelSearch, outx, outy, %x%, %y%, %x%, %y%, 0x36adf5 , 10, Fast
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
