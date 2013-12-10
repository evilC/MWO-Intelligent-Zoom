﻿; MWO Intelligent Zoom

; Create an instance of the library
ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

; Buffer hotkeys - important, required so rolling mouse wheel up while already zooming queues a zoom
#MaxThreadsBuffer on
; Just in case I spin my mouse wheel in free-spinning mode ;)
#MaxHotkeysPerInterval 999

; Set up vars
tried_zoom := 0
calib_list := Array("Basic","Five","Three","Four")
zoom_rates := Array(1.0,1.5,3.0,4.0)
zoom_sequence := Array(1,2,3,1,2)
default_colour := "F7AF36"
zoom_tick_time := 0		; time at which input was last processed
zoom_tick_dir := 0		; last zoom direction	
zoom_waiting := 0		; whether a zoom is queued, and in which direction.
current_zoom := 1		; the zoom level the code thinks it is currently in
desired_zoom := 0 		; the zoom level we are trying to get to (0 = not zooming)

; ============================================================================================
; CONFIG SECTION - Configure ADHD

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "MWO Zoom", version: 4.0, author: "evilC", link: "<a href=""http://mwomercs.com/forums/topic/133370-"">Homepage</a>"})
; The default application to limit hotkeys to.
; Starts disabled by default, so no danger setting to whatever you want
ADHD.config_default_app("CryENGINE")

; GUI size
ADHD.config_size(375,350)

; Configure update notifications:
ADHD.config_updates("http://evilc.com/files/ahk/mwo/mwozoom.au.txt")

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
ADHD.gui_add("Edit", "ThreeX", "xp+30 yp-3 W40", "", 1302)
ADHD.gui_add("Edit", "ThreeY", "xp+50 yp W40", "", 777)
ADHD.gui_add("Edit", "ThreeCol", "xp+50 yp W50", "", default_colour)
Gui, Add, Text, xp+50 yp W20 center vThreeSetCol, ■
Gui, Add, Edit, xp+20 yp W50 vThreeCurrent
Gui, Add, Text, xp+50 yp W20 center vThreeCurrentCol,
ADHD.gui_add("Edit", "ThreeTol", "xp+20 yp W40", "", 10)
Gui, Add, Text, xp+50 yp+3 W40 center vThreeState,

Gui, Add, Text, x5 yp+25, Adv
ADHD.gui_add("Edit", "FourX", "xp+30 yp-3 W40", "", 1300)
ADHD.gui_add("Edit", "FourY", "xp+50 yp W40", "", 778)
ADHD.gui_add("Edit", "FourCol", "xp+50 yp W50", "", default_colour)
Gui, Add, Text, xp+50 yp W20 center vFourSetCol, ■
Gui, Add, Edit, xp+20 yp W50 vFourCurrent
Gui, Add, Text, xp+50 yp W20 center vFourCurrentCol,
ADHD.gui_add("Edit", "FourTol", "xp+20 yp W40", "", 10)
Gui, Add, Text, xp+50 yp+3 W40 center vFourState,

Gui, Add, Text, x5 yp+30 vDetZoomLab, Detected Zoom: 
Gui, Add, Text, xp+100 yp W80 vCurrentZoom,

Gui, Add, Text, x5 yp+25, MWO Keys: Zoom
ADHD.gui_add("Edit", "ZoomKey", "xp+90 yp-3 W30", "", "z")
ZoomKey_TT := "The key bound to Zoom in MWO"

Gui, Add, Text, xp+35 yp+3, Adv Zoom:
ADHD.gui_add("Edit", "AdvZoomKey", "xp+50 yp-3 W30", "", "v")
ZoomKey_TT := "The key bound to Advance Zoom (Module) in MWO"

Gui, Add, Text, xp+40 yp+3, Zoom repeat delay (ms)
ADHD.gui_add("Edit", "ZoomDelay", "xp+120 yp-3 W30", "", 150)
ZoomDelay_TT := "How long to leave between zooms.`nWARNING! You need to adjust this figure in an actual game!`nTesting Grounds does not require a delay, BUT A MATCH DOES!"

;ADHD.gui_add("CheckBox", "MaxZoomOnly", "x5 yp+30", "Max Zoom Only", 0)
Gui, Add, Text, x5 yp+30, Zoom Mode
ADHD.gui_add("DropDownList", "ZoomMode", "xp+80 yp-3 W120", "Normal||Max Only|Toggle Min/Max", "None")
ZoomMode_TT := "Max only skips 1.5 zoom, Toggle lets you use Zoom In to toggle Min/Max"

ADHD.gui_add("CheckBox", "AdvZoom", "xp+125 yp-5", "Enable Adv Zoom Module", 0)
AdvZoom_TT := "If you might be using the Advanced Zoom module, check this box.`nOtherwise, leave it unchecked to improve performance."

ADHD.gui_add("CheckBox", "AdvZoomMinMax", "xp yp+15", "Zoom Out sends Adv Zoom`n in Min/Max mode", 0)
AdvZoom_TT := "If you might be using the Advanced Zoom module, check this box.`nOtherwise, leave it unchecked to improve performance."

Gui, Add, CheckBox, x5 yp+40 vCalibMode gCalibModeChanged, Calibration Mode
CalibMode_TT := "Use this mode to help you find correct values`nTURN OFF when playing to save CPU time"

ADHD.gui_add("CheckBox", "AlwaysOnTop", "xp+120 yp", "Always On Top", 0)

ADHD.gui_add("CheckBox", "PlayDebugSounds", "xp+100 yp", "Play Debug Sounds", 0)

; End GUI creation section
; ============================================================================================


ADHD.finish_startup()

; kick off the heartbeat
start_heartbeat()
return

ZoomIn:
	process_input(1)
	;zoom_waiting := 1
	;do_zoom(1, A_TickCount)
	return
	
ZoomOut:
	process_input(-1)
	;zoom_waiting := -1
	;do_zoom(-1, A_TickCount)
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
		}
	}
	return

; Called on zoom in/out keystroke and sets a variable when one is pressed.
; Main use is preventing jitter and unwanted multiple zoom requests when zoom is bound to the mouse wheel
; Because input is buffered (A second press is not executed until the processing of the first press is finished)...
; ... normally you cannot tell how long there is between key presses.
; By simply setting a variable and then exiting, the buffer empties very quickly.
process_input(dir){
	Global zoom_tick_time
	Global zoom_tick_dir
	Global zoom_waiting
	Global ZoomMode
	Global current_zoom
	Global desired_zoom
	
	if (zoom_tick_time){
		if (((zoom_tick_time + 250) > A_TickCount)){
			; Eliminate wobble - after a zoom, block zooms in the opposite direction for 250ms
			; Useful as the mouse wheel is prone to wobble
			if (zoom_tick_dir != dir){
				return
			}
			
			; In Min/Max mode etc, ignore input for 250ms after last input
			if (ZoomMode != "Normal"){
				; But only if we are not leaving advanced zoom (so you can roll mouse up twice to quit adv zoom and go straight to max norm zoom)
				if (current_zoom != 4){
					return
				}
			}
		}
	}
	
	zoom_tick_time := A_TickCount
	zoom_tick_dir := dir
	
	/*
	; Decide how many zooms are wanted
	if (ZoomMode != "Normal"){
		step := 1
	} else {
		step := 2
	}
	tmp := desired_zoom + (step * dir)
	if (tmp > 3){
		tmp := 3
	} else if (tmp < 1){
		tmp := 1
	}
	*/
	; let zoom thread know there is work to do
	zoom_waiting := dir
}

; Repeatedly examines the variable set by process_input to check if a zoom has been requested.
start_heartbeat(){
	Global zoom_waiting
	
	Loop, {
		if (zoom_waiting != 0){
			tmp := zoom_waiting
			zoom_waiting := 0
			do_zoom(tmp)
		}
		Sleep, 50
	}
}
	
; navigates from one zoom level to another
do_zoom(dir){
	Global ZoomKey
	Global ZoomDelay
	Global ZoomMode
	Global PlayDebugSounds
	Global zoom_rates
	Global desired_zoom
	Global tried_zoom
	Global zoom_tick_time
	Global zoom_tick_dir
	Global ADHD
	Global zoom_sequence
	Global AdvZoomMinMax
	Global AdvZoomKey
	Global zoom_waiting
	Global current_zoom
	
	; Use a loop, so we can keep trying to acheive desired result
	Loop, {
		
		; Do the Pixel Detection to try and work out what zoom we are in now
		current_zoom := which_zoom(get_zoom())
		
		if (current_zoom){
			; Zoom HUD indicator successfully read, proceed

			if (desired_zoom){
				; Zoom already in progress
				ADHD.debug("Trying to reach zoom: " desired_zoom)

				if (current_zoom != desired_zoom){
					; Unexpected zoom
					ADHD.debug("Expected zoom " desired_zoom ", got zoom " current_zoom " (Try #" tried_zoom ")")
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
						ADHD.debug("Aborting")
						if (PlayDebugSounds){
							soundbeep, 100, 100
						}
						; Stop trying
						break
					}
				} else {
					; Desired zoom reached
					ADHD.debug("Found Desired Zoom")
					
					desired_zoom := 0
					tried_zoom := 0
					break
				}
			} else {
				; Start a new zoom
				
				; Cater for various zoom modes
				if (ZoomMode != "Normal"){
					steps := 2
				} else {
					; The pixel check to see which zoom we are in would have taken some time.
					; Check to see if another zoom has been queued in the same direction (eg mouse wheel rolled more than once)
					; If so, clear it from buffer and do it now, as it may result in LESS zooms
					; ie was at 3, zoomed out once is at 1.5 (2 zooms), but if another zoom out waiting then we want zoom 1, which is 1 zoom away
					if (zoom_waiting == dir){
						zoom_waiting := 0
						steps := 2
					} else {
						steps := 1
					}
				}

				; Work out desired_zoom
				if (ZoomMode == "Toggle Min/Max"){
					if (current_zoom == 3 && dir == 1){
						dir == -1
					} else if (AdvZoomMinMax && current_zoom != 4 && dir == -1){
						; Send Advanced zoom on zoom out option
						send_adv_zoom()
						break
					}
				}

				if (current_zoom == 4){
					; zooming while in advanced zoom exits adv zoom by zooming.
					send_adv_zoom()
					break
				} else {
					tmp := current_zoom + (steps * dir)
					desired_zoom := clamp_zoom(tmp)
				}

				if (desired_zoom != current_zoom){
					; work out how many zooms away desired_zoom is
					ctr := 0
					z := current_zoom + 1
					Loop {
						ctr++
						if (zoom_sequence[z] == desired_zoom){
							break
						}
						z++
					}
					ADHD.debug("New Zoom Commenced: " ctr " times in dir " dir )
					send_zoom(ctr)
					continue
				}
			}
		} else {
			; Zoom HUD indicator not read OK
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
}

; Clamps an amount to one of the normal zoom values (1-3)
clamp_zoom(z){
	if (z > 3){
		z := 3
	} else if (z < 1){
		z := 1
	}
	return z
}

; Sends the key for Advanced zoom, and sets variables to indicate we are in advanced zoom mode.
send_adv_zoom(){
	Global AdvZoomKey
	Global current_zoom
	Global desired_zoom

	ADHD.debug("Sending Advanced Zoom Key")
	Send {%AdvZoomKey%}
	current_zoom := 4
	desired_zoom := 0
}

; Sends the key for zoom
send_zoom(amt){
	Global ZoomKey
	Global ZoomDelay
	Global ADHD
	
	ADHD.debug("Sending Zoom key x" amt)
	Loop % amt {
		Send {%ZoomKey%}
		; This sleep is IMPORTANT. Not needed in Testing Grounds, but delay needed in match!
		Sleep, %ZoomDelay%
	}
}


; Translates between game zooms (1.0, 1.5, 3.0) to zoom level (1,2,3)
which_zoom(zm){
	Global zoom_rates
	
	Loop, % zoom_rates.MaxIndex() {
		if (zm == zoom_rates[A_Index]){
			return %A_Index%
		}
	}
	return 0
}

; Operates the pixel detection routine to detect which numbers are visible in the Zoom Readout
get_zoom(){
	global ADHD
	Global AdvZoom
	
	zoom := 0
	if (mult_visible()){
		if (is_3()){
			zoom := 3.0
		} else if (is_5()){
			zoom := 1.5
		} else {
			if (AdvZoom && is_4()){
				zoom := 4.0
			} else {
				zoom := 1.0
			}
		}
	}
	ADHD.debug("`nDetected zoom: " zoom)
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
; 1920x1200 = 1302,837
is_3(){
	global ThreeX
	global ThreeY
	global ThreeCol
	global ThreeTol
	
	return (pixel_check(ThreeX,ThreeY,ThreeCol,ThreeTol))
}

; Detects if 4.0 (Advanced Zoom)
; 1920x1200 = 1300,838
is_4(){
	global FourX
	global FourY
	global FourCol
	global FourTol
	
	return (pixel_check(FourX,FourY,FourCol,FourTol))
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

; Hooks into the ADHD system	
app_active_hook(){
	
}

app_inactive_hook(){

}

; Option was changed / run on startup
option_changed_hook(){
	global ADHD
	global calib_list
	
	; Build list of controls to update for Calibration Mode
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

; Enable / Diable Calibration Mode
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

; Makes the app always on top
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
