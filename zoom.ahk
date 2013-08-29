﻿; MWO Intelligent Zoom

; Create an instance of the library
ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

#MaxThreadsBuffer on
#MaxHotkeysPerInterval 999

; Set up vars
desired_zoom := 0
last_zoom := 0
tried_zoom := 0
calib_list := Array("Basic","Five","Three")
zoom_rates := Array(1.0,1.5,3.0)
default_colour := "F7AF36"
zoom_tick_time := 0
zoom_tick_dir := 0

; ============================================================================================
; CONFIG SECTION - Configure ADHD

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "MWO Zoom", version: 2.0, author: "evilC", link: "<a href=""http://mwomercs.com/forums/topic/133370-"">Homepage</a>"})
; The default application to limit hotkeys to.
; Starts disabled by default, so no danger setting to whatever you want
ADHD.config_default_app("CryENGINE")

; GUI size
ADHD.config_size(375,310)

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



Gui, Add, Text, x30 yp+25 W100 center, Coordinates
Gui, Add, Text, xp+110 yp W100 center, Colours
Gui, Add, Text, xp+103 yp W100 center, Tolerance
Gui, Add, Text, xp+90 yp W30 center, State

Gui, Add, Text, x30 yp+25 W50 center, X
Gui, Add, Text, xp+50 yp W50 center, Y
Gui, Add, Text, xp+65 yp W50 center, Target
Gui, Add, Text, xp+65 yp W50 center, Current
Gui, Add, Text, xp+60 yp W50 center, 0-255
;Gui, Add, Text, xp+65 yp W30 center, Y/N


Gui, Add, Text, x5 yp+25, Basic
ADHD.gui_add("Edit", "BasicX", "xp+30 yp-3 W40", "", 1322)
ADHD.gui_add("Edit", "BasicY", "xp+50 yp W40", "", 779)
ADHD.gui_add("Edit", "BasicCol", "xp+50 yp W50", "", default_colour)
Gui, Add, Text, xp+50 yp W20 center vBasicSetCol, ■
Gui, Add, Edit, xp+20 yp W50 vBasicCurrent
Gui, Add, Text, xp+50 yp W20 center vBasicCurrentCol,
ADHD.gui_add("Edit", "BasicTol", "xp+20 yp W40", "", 10)
Gui, Add, Text, xp+50 yp+3 W40 center vBasicState,

Gui, Add, Text, x5 yp+25, 1.5
ADHD.gui_add("Edit", "FiveX", "xp+30 yp-3 W40", "", 1314)
ADHD.gui_add("Edit", "FiveY", "xp+50 yp W40", "", 777)
ADHD.gui_add("Edit", "FiveCol", "xp+50 yp W50", "", default_colour)
Gui, Add, Text, xp+50 yp W20 center vFiveSetCol, ■
Gui, Add, Edit, xp+20 yp W50 vFiveCurrent
Gui, Add, Text, xp+50 yp W20 center vFiveCurrentCol,
ADHD.gui_add("Edit", "FiveTol", "xp+20 yp W40", "", 10)
Gui, Add, Text, xp+50 yp+3 W40 center vFiveState,

Gui, Add, Text, x5 yp+25, 3.0
ADHD.gui_add("Edit", "ThreeX", "xp+30 yp-3 W40", "", 1305)
ADHD.gui_add("Edit", "ThreeY", "xp+50 yp W40", "", 775)
ADHD.gui_add("Edit", "ThreeCol", "xp+50 yp W50", "", default_colour)
Gui, Add, Text, xp+50 yp W20 center vThreeSetCol, ■
Gui, Add, Edit, xp+20 yp W50 vThreeCurrent
Gui, Add, Text, xp+50 yp W20 center vThreeCurrentCol,
ADHD.gui_add("Edit", "ThreeTol", "xp+20 yp W40", "", 10)
Gui, Add, Text, xp+50 yp+3 W40 center vThreeState,

Gui, Add, Text, x5 yp+30 vDetZoomLab, Detected Zoom: 
Gui, Add, Text, xp+100 yp W80 vCurrentZoom,

Gui, Add, Text, x5 yp+25, MWO Zoom Key
ADHD.gui_add("Edit", "ZoomKey", "xp+90 yp-3 W40", "", "z")
ZoomKey_TT := "The key bound to Zoom in MWO"

Gui, Add, Text, xp+60 yp, Zoom repeat delay (ms)
ADHD.gui_add("Edit", "ZoomDelay", "xp+120 yp-3 W40", "", 150)
ZoomDelay_TT := "How long after zooming to wait before allowing another zoom`nIf you have a custom wide FOV, you may need to set this higher"

;ADHD.gui_add("CheckBox", "MaxZoomOnly", "x5 yp+30", "Max Zoom Only", 0)
Gui, Add, Text, x5 yp+30, Zoom Mode
ADHD.gui_add("DropDownList", "ZoomMode", "xp+80 yp-3 W120", "Normal||Max Only|Toggle Min/Max", "None")
ZoomMode_TT := "Max only skips 1.5 zoom, Toggle lets you use Zoom In to toggle Min/Max"

Gui, Add, CheckBox, x5 yp+30 vCalibMode gCalibModeChanged, Calibration Mode
CalibMode_TT := "Use this mode to help you find correct values`nTURN OFF when playing to save CPU time"

ADHD.gui_add("CheckBox", "AlwaysOnTop", "xp+120 yp", "Always On Top", 0)

ADHD.gui_add("CheckBox", "PlayDebugSounds", "xp+100 yp", "Play Debug Sounds", 0)

; End GUI creation section
; ============================================================================================


ADHD.finish_startup()

return

ZoomIn:
	do_zoom(1)
	return
	
ZoomOut:
	do_zoom(-1)
	return

CalibModeChanged:	
	calib_mode_changed()
	return

CalibModeTimer:
	if WinActive("ahk_class CryENGINE"){
		Loop, % calib_list.MaxIndex(){
			tmpx := calib_list[A_Index] "X"
			tmpy := calib_list[A_Index] "Y"
			tmpx := %tmpx%
			tmpy := %tmpy%
			PixelGetColor, col, %tmpx%, %tmpy%, RGB
			
			StringSplit, col, col, x
			col := col2
			ctrl := calib_list[A_Index] "Current"
			GuiControl,,%ctrl%, %col%

			; Set swatches
			swatch := calib_list[A_Index] "CurrentCol"
			tmp := "+c" col
			GuiControl, %tmp%, %swatch%
			GuiControl,, %swatch%, ■
			
			
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
	Global ZoomKey
	Global ZoomDelay
	Global ZoomMode
	Global PlayDebugSounds
	Global zoom_rates
	Global desired_zoom
	Global last_zoom
	Global tried_zoom
	Global zoom_tick_time
	Global zoom_tick_dir
	
	; Eliminate wobble - after a zoom, block zooms in the opposite direction for a while
	; Useful as the mouse wheel is prone to wobble
	if (zoom_tick_time && (zoom_tick_time > A_TickCount)){
		if (zoom_tick_dir != dir){
			return
		}
	}
	zoom_tick_time := A_TickCount + 250
	zoom_tick_dir := dir
	
	; Use a loop, so we can keep trying to acheive desired result
	Loop, {
		; Do the Pixel Detection to try and work out what zoom we are in now
		zoom := which_zoom(get_zoom())
		
		if (zoom){
			; Zoom Readout read OK, proceed
			if (desired_zoom){
				; Zoom already in progress
				if (zoom == last_zoom){
					; Same zoom as when we last pressed the zoom button
					if (tried_zoom <= 3){
						; Keep waiting for change
						tried_zoom += 1
						; Wait another 50ms and try again
						sleep, 50
						continue
					} else {
						; Tried 3 times and failed, give up.
						desired_zoom := 0
						tried_zoom := 0
						if (PlayDebugSounds){
							soundbeep, 100, 100
						}
						; Stop trying
						break
					}
				} else {
					; Detected zoom change since zoom button last pressed
					if (zoom == desired_zoom){
						; Desired zoom reached
						desired_zoom := 0
						tried_zoom := 0
						break
					} else {
						; New zoom reached, but not the one we want. Zoom again.
						last_zoom := zoom
						send_zoom()
						continue
					}
				}
			} else {
			
				; Start a new zoom
				; Stop anything happening if zoom in at full zoom or out at no zoom
				if (dir == 1){
					; Zoom In
					if (ZoomMode != "Normal"){
						if (ZoomMode == "Max Only"){
							desired_zoom := 3
						} else {
							if (zoom < 3){
								desired_zoom := 3
							} else {
								desired_zoom := 1
							}
						}
					} else {
						desired_zoom := zoom + 1
					}		
				} else {
					; Zoom Out
					desired_zoom := 1
				}
				if (desired_zoom > 3){
					desired_zoom := 3
				} else if (desired_zoom < 1){
					desired_zoom := 1
				}
				; Destination zoom decided, do we need to do anything? (Could be trying to zoom in at full zoom)
				if (desired_zoom != zoom){
					last_zoom := zoom
					send_zoom()
					continue
				}
			}
		} else {
			; Zoom Readout not read OK
			if (tried_zoom <= 3){
				tried_zoom += 1
				; Wait another 50ms and try again
				sleep, 50
				continue
			} else {
				desired_zoom := 0
				tried_zoom := 0
				if (PlayDebugSounds){
					soundbeep, 100, 100
				}
				; Stop trying
				break
			}

		}
		; Sleep in case the code manages to get to the end of the loop - Saves CPU hit just in case
		sleep, 50
	}
	
	/*
	zoom := which_zoom(get_zoom())

	if (zoom){
		if (desired_zoom){
			; Zoom already in progress
			
			; If the current zoom hasn't changed since last run...
			if (zoom == last_zoom){
				; Re-fire do_zoom to check again
				retry_zoom(dir)
				if (zoom == last_zoom){
					; Failed to get to desired zoom - give up
					desired_zoom := 0
					zooming := 0
				}
				return
			}
			if (zoom == desired_zoom){
				; Reach desired zoom, stop
				desired_zoom := 0
				zooming := 0
				if (queued_zoom != 0){
					tmp := queued_zoom
					queued_zoom := 0
					do_zoom(tmp)
				}
				return
			} else {
				; Different zoom to start zoom, but not the one we want, keep zooming...
				soundbeep, 500, 100
				last_zoom := zoom ; save last_zoom to current value, so script can tell when next zoom has taken effect
				send_zoom()
				do_zoom(dir)
			}
		} else {
			; Start a new zoom
			; Stop anything happening if zoom in at full zoom or out at no zoom
			if (dir == -1){
				desired_zoom := 1
			} else {
				if (ZoomMode != "Normal"){
					desired_zoom := 3
				} else {
					desired_zoom := zoom + dir
				}
				
			}
			if (desired_zoom > 3){
				desired_zoom := 3
			} else if (desired_zoom < 1){
				desired_zoom := 1
			}
			if (desired_zoom != zoom){
				last_zoom := zoom
				send_zoom()
				do_zoom(dir)
			} else {
				; turn off desired mode
				desired_zoom := 0
			}
			
			
			
		}
	} else {
		; Could not detect zoom at start
		retry_zoom(dir)
	}
	*/
	/*
	if (zooming){
		;soundbeep, 200, 200
		; Allow two zoom ins to be queued
		if (ZoomMode != "Normal"){
			queued_zoom := 1
		}
		return
	}
	zooming := 1
	zoom := get_zoom()
	if (zoom == 3.0 && ZoomMode == "Toggle Min/Max" && queued_zoom != 1){
		dir := 0
	}
	if (zoom){
		if (dir){
			; zoom in
			if (zoom <= 1.5){
				if (ZoomMode != "Normal" && zoom == 1.0){
					queued_zoom := 1
				}
				Send {%ZoomKey%}
			}
		} else {
			; zoom out
			if (zoom > 1){
				Send {%ZoomKey%}
				if (zoom != 3.0){
					queued_zoom := 1
				}
			}
		}
	} else {
		if (PlayDebugSounds){
			;Try again
			if (tried_zoom <= 3){
				tried_zoom := tried_zoom + 1
				zooming := 0
				do_zoom(dir)
				return
			}
			soundbeep, 100, 100
		}
	}
	tried_zoom := 0
	sleep, %ZoomDelay%
	zooming := 0
	if (queued_zoom == 1){
		queued_zoom := 0
		do_zoom(dir)
	}
	*/
}

send_zoom(){
	Global ZoomKey
	Global ZoomDelay
	
	;soundbeep, 1000, 100
	Send {%ZoomKey%}
	Sleep, %ZoomDelay%
}

which_zoom(zm){
	Global zoom_rates
	
	Loop, % zoom_rates.MaxIndex() {
		if (zm == zoom_rates[A_Index]){
			return %A_Index%
		}
	}
	return 0
}

/*
retry_zoom(dir){
	Global PlayDebugSounds
	Global tried_zoom
	
	if (PlayDebugSounds){
		soundbeep, 100, 100
	}
	if (tried_zoom <= 3){
		tried_zoom += 1
		do_zoom(dir)
	}
	return
}
*/

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

; Default colour is 0xF7AF36
pixel_check(x,y,col,tol){
	col := "0x" col
	PixelSearch, outx, outy, %x%, %y%, %x%, %y%, %col% , %tol%, Fast RGB
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
	global calib_list
	
	Loop, % calib_list.MaxIndex(){
		swatch := calib_list[A_Index] "SetCol"
		cont := calib_list[A_Index] "Col"
		GuiControlGet, tmp,, %cont%
		tmp := "+c" tmp
		GuiControl, %tmp%, %swatch%
		GuiControl,, %swatch%, ■
	}
			
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
