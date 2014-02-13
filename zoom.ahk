; MWO Intelligent Zoom

; Create an instance of the library
ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

; Buffer hotkeys - important, required so rolling mouse wheel up while already zooming queues a zoom
#MaxThreadsBuffer on
; Just in case I spin my mouse wheel in free-spinning mode ;)
#MaxHotkeysPerInterval 999

; Set up vars
calib_list := Array("Basic","Five","Three","Four")
axis_list := Array("X","Y")
pixel_detect_start := 0
pixel_detect_size := 0
zoom_rates := Array(1.0,1.5,3.0,4.0)
zoom_sequence := Array(1,2,3,1,2)
default_colour := "F7AF36"
default_tol := "40"
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

ADHD.config_about({name: "MWO Zoom", version: "4.3.0", author: "evilC", link: "<a href=""http://mwomercs.com/forums/topic/133370-"">Homepage</a>"})
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
ADHD.config_hotkey_add({uiname: "Calibrate Basic", subroutine: "CalibrateBasic"})
adhd_hk_k_3_TT := "Will copy the colour from the Current to the Target box in Calibration Mode"
ADHD.config_hotkey_add({uiname: "Calibrate 1.5x", subroutine: "Calibrate1_5x"})
adhd_hk_k_4_TT := "Will copy the colour from the Current to the Target box in Calibration Mode"
ADHD.config_hotkey_add({uiname: "Calibrate 3.0x", subroutine: "Calibrate3x"})
adhd_hk_k_5_TT := "Will copy the colour from the Current to the Target box in Calibration Mode"
ADHD.config_hotkey_add({uiname: "Calibrate 4.0x (Adv)", subroutine: "Calibrate4x"})
adhd_hk_k_6_TT := "Will copy the colour from the Current to the Target box in Calibration Mode"

; Hook into ADHD events
; First parameter is name of event to hook into, second parameter is a function name to launch on that event
ADHD.config_event("app_active", "app_active_hook")
ADHD.config_event("app_inactive", "app_inactive_hook")
ADHD.config_event("option_changed", "option_changed_hook")
ADHD.config_event("tab_changed", "tab_changed_hook")
ADHD.config_event("on_exit", "on_exit_hook")

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
ADHD.gui_add("Edit", "BasicTol", "xp+20 yp W40", "", default_tol)
Gui, Add, Text, xp+50 yp+3 W40 center vBasicState,

Gui, Add, Text, x5 yp+25, 1.5
ADHD.gui_add("Edit", "FiveX", "xp+30 yp-3 W40", "", 1310)
ADHD.gui_add("Edit", "FiveY", "xp+50 yp W40", "", 776)
ADHD.gui_add("Edit", "FiveCol", "xp+50 yp W50", "", default_colour)
Gui, Add, Text, xp+50 yp W20 center vFiveSetCol, ■
Gui, Add, Edit, xp+20 yp W50 vFiveCurrent
Gui, Add, Text, xp+50 yp W20 center vFiveCurrentCol,
ADHD.gui_add("Edit", "FiveTol", "xp+20 yp W40", "", default_tol)
Gui, Add, Text, xp+50 yp+3 W40 center vFiveState,

Gui, Add, Text, x5 yp+25, 3.0
ADHD.gui_add("Edit", "ThreeX", "xp+30 yp-3 W40", "", 1301)
ADHD.gui_add("Edit", "ThreeY", "xp+50 yp W40", "", 774)
ADHD.gui_add("Edit", "ThreeCol", "xp+50 yp W50", "", default_colour)
Gui, Add, Text, xp+50 yp W20 center vThreeSetCol, ■
Gui, Add, Edit, xp+20 yp W50 vThreeCurrent
Gui, Add, Text, xp+50 yp W20 center vThreeCurrentCol,
ADHD.gui_add("Edit", "ThreeTol", "xp+20 yp W40", "", default_tol)
Gui, Add, Text, xp+50 yp+3 W40 center vThreeState,

Gui, Add, Text, x5 yp+25, Adv
ADHD.gui_add("Edit", "FourX", "xp+30 yp-3 W40", "", 1300)
ADHD.gui_add("Edit", "FourY", "xp+50 yp W40", "", 779)
ADHD.gui_add("Edit", "FourCol", "xp+50 yp W50", "", default_colour)
Gui, Add, Text, xp+50 yp W20 center vFourSetCol, ■
Gui, Add, Edit, xp+20 yp W50 vFourCurrent
Gui, Add, Text, xp+50 yp W20 center vFourCurrentCol,
ADHD.gui_add("Edit", "FourTol", "xp+20 yp W40", "", default_tol)
Gui, Add, Text, xp+50 yp+3 W40 center vFourState,

Gui, Add, Text, x5 yp+30 vDetZoomLab, Detected Zoom: 
Gui, Add, Text, xp+100 yp W30 vCurrentZoom,

Gui, Add, Button, xp+30 yp-5 gDetectCoordinates vDetectCoordinates, Detect Coordinates

Gui, Add, Text, xp+120 yp+5 W40 center vSnapshotLab, SnapShot:
Gui, Add, Text, 0xE xp+60 yp-5 w50 h25 hwndhPic vSnapshot          ; SS_Bitmap    = 0xE

Gui, Add, Text, x5 yp+30, MWO Keys: Zoom
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

pToken := Gdip_Startup()

ADHD.finish_startup()

; kick off the heartbeat
start_heartbeat()
return

; Hotkey Subroutines
; =================================================

ZoomIn:
	process_input(1)
	return
	
ZoomOut:
	process_input(-1)
	return

CalibModeChanged:	
	calib_mode_changed()
	return

CalibModeTimer:
	CalibModeTimer()
	return

CalibrateBasic:
	calibrate_colour("Basic")
	return

Calibrate1_5x:
	calibrate_colour("Five")
	return

Calibrate3x:
	calibrate_colour("Three")
	return

Calibrate4x:
	calibrate_colour("Four")
	return

DetectCoordinates:
	detect_coordinates()
	return

; Functions
; =================================================

; Calibration Mode main loop
; Populates Current+Swatch and State columns. Also the Detected Zoom readout at bottom
CalibModeTimer(){
	Global calib_list
	global snapshot_bmp

	if WinActive("ahk_class CryENGINE"){
		check_results := Array()
		Loop, % calib_list.MaxIndex(){
			tmpx := calib_list[A_Index] "X"
			tmpy := calib_list[A_Index] "Y"
			tmpx := %tmpx%
			tmpy := %tmpy%
			;PixelGetColor, current_col, %tmpx%, %tmpy%, RGB
			current_col := pixel_get_color(tmpx,tmpy,snapshot_bmp)

			current_col_obj := ToRGB(current_col)
			
			StringSplit, current_col, current_col, x
			current_col := current_col2
			ctrl := calib_list[A_Index] "Current"
			GuiControl,,%ctrl%, %current_col%

			; Set swatches
			swatch := calib_list[A_Index] "CurrentCol"
			tmp := "+c" current_col
			GuiControl, %tmp%, %swatch%
			GuiControl,, %swatch%, ■
			
			
			tol := calib_list[A_Index] "Tol"
			tol := %tol%
			
			target_col_obj := calib_list[A_Index] "Col"
			target_col_obj := %target_col_obj%
			target_col_obj := ToRGB("0x" target_col_obj)

			state := Compare(current_col_obj,target_col_obj,tol)

			check_results[A_Index] := state

			ctrl := calib_list[A_Index] "State"
			if (state){
				GuiControl,,%ctrl%, YES
			} else {
				GuiControl,,%ctrl%, NO
			}
		}

		; Detect zoom from this round of tests (Without doing extra pixel checks)
		if (check_results[1]){
			if (check_results[2]){
				GuiControl,, CurrentZoom, 1.5x
			} else if (check_results[3]){
				GuiControl,, CurrentZoom, 3x
			} else if (check_results[4]){
				GuiControl,, CurrentZoom, 4x
			} else {
				GuiControl,, CurrentZoom, 1x
			}
		} else {
			GuiControl,, CurrentZoom, ???
		}
		take_snapshot()
		;show_snapshot()
	}
	return
}

; Takes the colour from the Current column and puts it in the Target column
calibrate_colour(row){
	Global CalibMode
	Global calib_list
	global snapshot_bmp

	if (CalibMode){
		; Grab current colour from GUI
		GuiControlGet, tmp,, %row%Current
	} else {
		; Grab current colour from screen
		tmpx := row "X"
		tmpy := row "Y"
		tmpx := %tmpx%
		tmpy := %tmpy%
		take_snapshot()
		tmp := pixel_get_color(tmpx,tmpy,snapshot_bmp)
		; Strip 0x
		tmp := substr(tmp,3)
	}
	GuiControl,,%row%Col, %tmp%
	soundbeep
}

~Mbutton::
	detect_coordinates()
	return

detect_coordinates(){
	global ADHD
	global snapshot_bmp
	global ZoomKey
	global default_colour
	global pixel_detect_size
	global pixel_detect_start

	;tol := 40	; ToDo: use tol value from GUI

	; Build cache of the 3 zooms
	snapshots := Object()
	Loop, 3 {
		take_snapshot()
		show_snapshot()
		snapshots.insert(snapshot_bmp)
		Send {%ZoomKey%}
		Sleep, 1000
	}

	rgb_default := ToRGB("0x" default_colour)

	; Search for a pixel common to all zooms

	min_diff := 999999
	cache_basic := Object()

	num_snapshots := 3

	Loop, 10 {
		; Gradually loosen up the tolerance
		zt := A_Index - 1
		ot := A_Index

		tol := ot * 10
		detected_coords := Object()

		Loop, % num_snapshots {
			; Loop through each snapshot
			cache_basic.insert([])
			snapshot_idx := A_Index

			Loop, % pixel_detect_size[1] {
				; pixel loop - x
				zx := A_Index - 1	; used for zero-based indexes
				ox := A_Index		; used for one-based indexes
				cache_basic[A_Index].insert([])
				Loop, % pixel_detect_size[2] {
					; pixel loop - y
					zy := A_Index - 1
					oy := A_Index

					if (snapshot_idx != 1){
						; if not the base level...
						if (cache_basic[ox,oy] == 0){
							; If pixel was marked as not a possibility for previous snapshot, ignore and set next snapshot to ignore
							continue
						}
					}

					val := pixel_get_color(pixel_detect_start[1] + zx, pixel_detect_start[2] + zy, snapshots[snapshot_idx])
					val := ToRGB(val)

					cmp := Compare(val, rgb_default, tol)

					cache_basic[ox,oy] := cmp

					; Detect success
					if (cache_basic[ox,oy] && (snapshot_idx == num_snapshots)){
						; This pixel is a match
						detected_coords.insert([ox,oy])
					}
				}
			}
		}
		; Stop once we have a match
		if (detected_coords.MaxIndex()){
			break
		}
	}

	if (detected_coords.MaxIndex()){
		Loop, % detected_coords.MaxIndex() {
			msgbox % "CONTENDER - BASIC (" tol "): " snapx_to_screen(detected_coords[A_Index,1]) "," snapy_to_screen(detected_coords[A_Index,2])
			; ToDo: pick best match
		}
	}

	;msgbox % "Best basic pixel: " snapx_to_screen(best_match[1]) "," snapy_to_screen(best_match[2])

	; Detect best coordinates for each zoom

	cache_zooms := Object()
	cache_zooms.insert([])

	; when making actual loop, ensure oz starts at level we are comparing against.
	oz := 2

	Loop, 10 {
		; Gradually loosen up the tolerance
		zt := A_Index - 1
		ot := A_Index

		tol := ot * 10
		detected_coords := Object()
		detected_coords.insert([])
		detected_coords.insert([])
		detected_coords.insert([])
		detected_coords.insert([])

		snapshot_idx := oz - 1
		snapshot_ctr := 0

		Loop, % num_snapshots {
			; Loop through each snapshot
			cache_zooms[1].insert([])
			;snapshot_idx := A_Index
			snapshot_idx++
			if (snapshot_idx > num_snapshots){
				snapshot_idx := 1
			}
			snapshot_ctr++

			Loop, % pixel_detect_size[1] {
				; pixel loop - x
				zx := A_Index - 1	; used for zero-based indexes
				ox := A_Index		; used for one-based indexes
				cache_zooms[1][A_Index].insert([])
				Loop, % pixel_detect_size[2] {
					; pixel loop - y
					zy := A_Index - 1
					oy := A_Index

					if (snapshot_idx != oz){
						; if not the base level...
						if (cache_zooms[1][ox,oy] == 0){
							; If pixel was marked as not a possibility for previous snapshot, ignore and set next snapshot to ignore
							continue
						}
					}

					val := pixel_get_color(pixel_detect_start[1] + zx, pixel_detect_start[2] + zy, snapshots[snapshot_idx])
					val := ToRGB(val)

					cmp := Compare(val, rgb_default, tol)

					if (snapshot_idx == oz){
						; If this is the base snapshot, store true/false value of compare
						cache_zooms[1][ox,oy] := cmp
					} else {
						; The pixel passed the base check.
						; A further match means pixel is not unique, a further fail is good. So invert value of cmp
						cache_zooms[1][ox,oy] := !cmp
					}

					; Detect success
					if (cache_zooms[1][ox,oy] && (snapshot_ctr == num_snapshots)){
						; This pixel is a match
						detected_coords[oz].insert([ox,oy])
					}

				}
			}
		}
		; Stop once we have a match
		if (detected_coords[snapshot_idx].MaxIndex()){
			break
		}
	}

	if (detected_coords[2].MaxIndex()){
		Loop, % detected_coords[2].MaxIndex() {
			msgbox % "CONTENDER - 1.5x (" tol "): " snapx_to_screen(detected_coords[2][A_Index,1]) "," snapy_to_screen(detected_coords[2][A_Index,2])
			; ToDo: pick best match
		}
	}

		
}

snapx_to_screen(coord){
	return snapshot_to_screen(coord,1)
}

snapy_to_screen(coord){
	return snapshot_to_screen(coord,2)
}

; Converts snapshot coordinates to screen coordinates
snapshot_to_screen(coord,ctype){
	global pixel_detect_start
	return coord - 1 + pixel_detect_start[ctype]
}

; Tries to work out coordinates to use based upon a mathematical formula
detect_coordinates_old(){
	Global ADHD
	global adhd_limit_application_on
	global adhd_limit_application
	global calib_list
	global axis_list

	if (!adhd_limit_application_on){
		msgbox The "Limit to Application" option in the Bindings tab must be enabled to Detect Coordinates.
		return
	}
	StringCaseSense, On
	if (adhd_limit_application != "CryENGINE"){
		msgbox The "Limit to Application" option in the Bindings tab must be set to "CryENGINE" (No Quotes, CaSe SenSITive).
		StringCaseSense, Off
		return
	}
	StringCaseSense, Off

	curr_size := ADHD.limit_app_get_size()
	if (curr_size.h == -1){
		msgbox "Resolution not detected - please open the game, then try again."
		return
	}

	msgbox,4,,% "Detected " curr_size.w "x" curr_size.h " Resolution.`n`nWarning! This process will overwrite the current profile.`nIf you wish to preserve the current profile, click Cancel, then add a new profile in the Profiles tab.`n`nThis feature is experimental - if it does not work for you, please make a post on the Homepage.`n`nDo you wish to continue?"

	IfMsgBox, No
		return

	; pixel ratios. Calculated from a known good (hand picked) coordinate - should be the same for all resolutions.
	; x: half_width / (x_coord - half_width)
	; y: half_width / (y_coord - half_height)
	x_ratio := Array()
	y_ratio := Array()

	x_ratio[1] := 2.7826086957
	y_ratio[1] := 3.9669421488

	x_ratio[2] := 2.7195467422
	y_ratio[2] := 4.085106383

	x_ratio[3] := 2.8656716418
	y_ratio[3] := 3.9669421488

	x_ratio[4] := 2.8571428571
	y_ratio[4] := 4.085106383

	half_width := round(curr_size.w / 2)
	half_height := round(curr_size.h / 2)

	x_coord := Array()
	y_coord := Array()

	Loop, 4 {
		x_coord[A_Index] := round((half_width / x_ratio[A_Index]) + half_width)
		y_coord[A_Index] := round((half_width / y_ratio[A_Index]) + half_height)
	}

	
	Loop, 4 {
		ctr := A_Index
		Loop, 2 {
			axis := axis_list[A_Index]
			val := %axis%_coord[ctr]
			ctrl := calib_list[ctr] axis
			GuiControl,,%ctrl%, %val%
		}
	}

}

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
	
	wobble_time := 150

	if (zoom_tick_time){
		if (((zoom_tick_time + wobble_time) > A_TickCount)){
			; Eliminate wobble - after a zoom, block zooms in the opposite direction for wobble_time ms
			; Useful as the mouse wheel is prone to wobble
			if (zoom_tick_dir != dir){
				return
			}
			
			; In toggle modes, ignore ALL input for wobble_time ms after last input
			if (ZoomMode != "Normal"){
				return
			}
		}
	}
	
	zoom_tick_time := A_TickCount
	zoom_tick_dir := dir
	
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
	Global zoom_tick_time
	Global zoom_tick_dir
	Global ADHD
	Global zoom_sequence
	Global AdvZoomMinMax
	Global AdvZoomKey
	Global zoom_waiting
	Global current_zoom

	if (dir == 1){
		dirdesc := "(IN)"
	} else {
		dirdesc := "(OUT)"
	}
	
	ADHD.debug("=== NEW INPUT DETECTED " dirdesc " ===")

	tried_zoom := 0

	; Use a loop, so we can keep trying to acheive desired result
	Loop, {
		
		debug_line := ""

		; Do the Pixel Detection to try and work out what zoom we are in now
		current_zoom := which_zoom(get_zoom(false))

		tried_zoom++
		
		if (current_zoom){
			; Zoom HUD indicator successfully read, proceed

			if (desired_zoom){
				; Zoom already in progress
				;ADHD.debug("Trying to reach zoom: " desired_zoom)

				if (current_zoom != desired_zoom){
					; Unexpected zoom
					;ADHD.debug("Expected zoom " desired_zoom ", got zoom " current_zoom " (Try #" tried_zoom ")")
					debug_line .= "Expecting zoom " desired zoom ", detected zoom " current_zoom " (Try #" tried_zoom "), "
					if (tried_zoom < 3){
						debug_line .= "Trying again."
						ADHD.debug(debug_line)
						; Wait another 50ms and try again
						sleep, 50
						continue
					} else {
						; Tried 3 times and failed, give up.
						desired_zoom := 0
						debug_line .= "Aborting - Unexpected Zoom."
						ADHD.debug(debug_line)
						ADHD.debug("----------------------------------------------")
						if (PlayDebugSounds){
							soundbeep, 100, 100
							sleep, 25
							soundbeep, 100, 100
						}
						; Stop trying
						break
					}
				} else {
					; Desired zoom reached
					debug_line .= "Found Desired Zoom"
					ADHD.debug(debug_line)
					ADHD.debug("----------------------------------------------")

					desired_zoom := 0

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
						ADHD.debug("Triggering Advanced Zoom on Wheel Out")
						ADHD.debug("----------------------------------------------")
						send_adv_zoom()
						break
					}
				}

				if (current_zoom == 4){
					; zooming while in advanced zoom exits adv zoom by zooming.
					ADHD.debug("Exiting Advanced Zoom")
					ADHD.debug("----------------------------------------------")
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
					debug_line .= "New Zoom Commenced: " current_zoom "->" desired_zoom ": " ctr " zooms."
					ADHD.debug(debug_line)
					send_zoom(ctr)
					continue
				} else {
					debug_line .= "Ignoring input."
					desired_zoom := 0
					ADHD.debug(debug_line)
					ADHD.debug("----------------------------------------------")
					break
				}

				; If it got this far, no known conditions met
				debug_line .= "Aborting - Unknown State."

				soundbeep, 100, 100
				sleep, 25
				soundbeep, 100, 100
				sleep, 25
				soundbeep, 100, 100

				ADHD.debug(debug_line)
				ADHD.debug("----------------------------------------------")
				desired_zoom := 0
				break
			}
		} else {
			debug_line .= "Zoom not detected. (Try #" tried_zoom "), "
			; Zoom HUD indicator not read OK
			if (tried_zoom < 3){
				debug_line .= "Trying again..."
				ADHD.debug(debug_line)

				; Wait another 50ms and try again
				sleep, 50
				continue
			} else {
				debug_line .= "Aborting - Current Zoom Unkown."
				ADHD.debug(debug_line)
				ADHD.debug("----------------------------------------------")

				desired_zoom := 0
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
	
	;ADHD.debug("Sending Zoom key x" amt)
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
get_zoom(calibmode){
	global ADHD
	Global AdvZoom
	Global last_basic
	Global last_1_5x
	Global last_3x
	Global last_4x
	
	; Take a new snapshot for comparisons
	if (!calibmode){
		take_snapshot()
	}

	debug_line := "Pixel Check: "
	zoom := 0
	if (check_basic()){
		debug_line .= "Basic - OK (" last_basic "), "
		if (check_3x()){
			debug_line .= "3x - OK (" last_3x ")"
			zoom := 3.0
		} else if (check_1_5x()){
			debug_line .= "3x - NO (" last_3x "), "
			debug_line .= "1.5x - OK (" last_1_5x ")"
			zoom := 1.5
		} else {
			debug_line .= "3x - NO (" last_3x "), "
			debug_line .= "1.5x - NO (" last_1_5x "), "
			if (AdvZoom && check_4x()){
				debug_line .= "4x - OK (" last_4x ")"
				zoom := 4.0
			} else {
				if (AdvZoom){
					debug_line .= "4x - NO (" last_4x ")"
				}
				debug_line .= " : 1x Assumed"
				zoom := 1.0
			}
		}
	} else {
		debug_line .= "Basic - FAILED (" last_basic ")"
	}
	;ADHD.debug("`nDetected zoom: " zoom)
	if (!calibmode){
		ADHD.debug(debug_line)
	}
	return zoom
}

; Detects if x is present (is 1.0x, 1.5x or 3.0x likely to be visible?)
check_basic(){
	Global last_col
	Global last_basic

	global BasicX
	global BasicY
	global BasicCol
	global BasicTol
	
	ret := (pixel_check(BasicX,BasicY,BasicCol,BasicTol))
	last_basic := last_col
	return ret
}

; Detects between 1.5x and 1.0x
check_1_5x(){
	Global last_col
	Global last_1_5x

	global FiveX
	global FiveY
	global FiveCol
	global FiveTol
	
	ret := (pixel_check(FiveX,FiveY,FiveCol,FiveTol))
	last_1_5x := last_col
	return ret
}

; Detects if 3.0
check_3x(){
	Global last_col
	Global last_3x

	global ThreeX
	global ThreeY
	global ThreeCol
	global ThreeTol
	
	ret := (pixel_check(ThreeX,ThreeY,ThreeCol,ThreeTol))
	last_3x := last_col
	return ret
}

; Detects if 4.0 (Advanced Zoom)
check_4x(){
	Global last_col
	Global last_4x

	global FourX
	global FourY
	global FourCol
	global FourTol
	
	ret := (pixel_check(FourX,FourY,FourCol,FourTol))
	last_4x := last_col
	return ret
}

; Default colour is 0xF7AF36
pixel_check(x,y,col,tol){
	Global last_col
	global snapshot_bmp

	col := "0x" col
	col := ToRGB(col)

	;tim := A_TickCount
	;PixelGetColor, det_obj, %x%, %y%, RGB
	det_obj := pixel_get_color(x,y,snapshot_bmp)

	last_col := det_obj
	det_obj := ToRGB(det_obj)
	ret := Compare(det_obj,col,tol)
	return ret
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

	rebuild_coordcache()
}

tab_changed_hook(){
	calib_mode_changed()
}

on_exit_hook(){
	global snapshot_bmp
	global pToken

	Gdip_DisposeImage(snapshot_bmp)
	Gdip_ShutDown(pToken)
	return
}

; Enable / Diable Calibration Mode
calib_mode_changed(){
	global CalibMode
	global adhd_debug_mode
	Global adhd_current_tab

	gui, submit, nohide
	
	if ((CalibMode || adhd_debug_mode) && adhd_current_tab == "Main"){
		Guicontrol, -hidden, DetZoomLab
		Guicontrol, -hidden, CurrentZoom
		Guicontrol, -hidden, DetectCoordinates
		GuiControl, -hidden,Snapshot
		GuiControl, -hidden,SnapshotLab

		if (CalibMode){
			SetTimer, CalibModeTimer, 250
		}
	} else {
		Guicontrol, +hidden, DetZoomLab
		Guicontrol, +hidden, CurrentZoom
		SetTimer, CalibModeTimer, Off
		GuiControl,,BasicState,
		GuiControl,,FiveState,
		GuiControl,,ThreeState,
		GuiControl,,FourState,
		GuiControl, +hidden,DetectCoordinates
		GuiControl, +hidden,Snapshot
		GuiControl, +hidden,SnapshotLab
	}
}

; Makes the app always on top
set_always_on_top(){
	global AlwaysOnTop
	
	if (AlwaysOnTop){
		Gui,+AlwaysOnTop
		; Set debug window always on top also
		Gui,2:+AlwaysOnTop
	} else {
		Gui,-AlwaysOnTop
		Gui,2:-AlwaysOnTop
	}
}

; Calculates size and position of a box that covers all the coordinates
rebuild_coordcache(){
	global calib_list
	global axis_list
	global pixel_detect_start
	global pixel_detect_size

	coords := object()
	min := Array(999999,999999)
	max := Array(0,0)

	Loop, 4 {
		ctr := A_Index
		coords.insert([])
		Loop, 2 {
			axis := axis_list[A_Index]
			val := %axis%_coord[ctr]
			ctrl := calib_list[ctr] axis
			GuiControlGet,%ctrl%
			coords[ctr,A_Index] := %ctrl%

			if (coords[ctr,A_Index] < min[A_Index]){
				min[A_Index] := coords[ctr,A_Index]
			}
			if (coords[ctr,A_Index] > max[A_Index]){
				max[A_Index] := coords[ctr,A_Index]
			}
		}
	}
	;pixel_detect_size := Array((max[1] - min[1]) + 1, (max[2] - min[2]) + 1)

	;if possible, pass back a box of 5px around the coords
	if (min[1] > 5 && min[2] > 5){
		pixel_detect_start := Array(min[1] - 5,min[2] - 5)
		pixel_detect_size := Array((max[1] - min[1]) + 11, (max[2] - min[2]) + 11)
	} else {
		pixel_detect_start := Array(min[1],min[2])
		;Add 1 so we alwats get at least 1 pixel
		pixel_detect_size := Array((max[1] - min[1]) + 1, (max[2] - min[2]) + 1)
	}
}

; GDI+ Functions
; Gets colour of a pixel relative to the snapshot
snapshot_get_color(xpos, ypos, src){
	ret := GDIP_GetPixel(src, xpos, ypos)
	ret := ARGBtoRGB(ret)
	return ret
}

; Gets colour of a pixel relative to the screen
pixel_get_color(xpos, ypos, src){
	global pixel_detect_start

	;PixelGetColor, current_col, %xpos%, %ypos%, RGB

	xpos := xpos - pixel_detect_start[1]
	ypos := ypos - pixel_detect_start[2]

	ret := snapshot_get_color(xpos,ypos,src)

	;msgbox % xpos "," ypos ": " ret "(PixelGetColor says: " current_col ")"
	return ret
}

take_snapshot(){
	global snapshot_bmp
	global pixel_detect_start
	global pixel_detect_size
	global CalibMode
	global adhd_debug_mode

	snapshot_bmp := GDIP_BitmapFromScreen(pixel_detect_start[1] "|" pixel_detect_start[2] "|" pixel_detect_size[1] "|" pixel_detect_size[2])
	;snapshot_bmp := GDIP_BitmapFromScreen("300|300|200|200")
	if (CalibMode || adhd_debug_mode){
		show_snapshot()
	}
	return
}

;Shows the snapshot area in the gui
show_snapshot(){
	global snapshot_bmp
	global hPic

	hBitmap := Gdip_CreateHBITMAPFromBitmap(snapshot_bmp)
	SendMessage, 0x172, 0, hBitmap, , ahk_id %hPic% ; STM_SETIMAGE = 0x172
	return
}

; Color manipulation and comparison functions
; Converts hex ("0xFFFFFF" as a string) to an object of r/g/b integers
ToRGB(color) {
    return { "r": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "b": color & 0xFF }
}

; Compares r/g/b integer objects, with a tolerance
; returns true or false
Compare(c1, c2, tol := 20) {
    rdiff := Abs( c1.r - c2.r )
    gdiff := Abs( c1.g - c2.g )
    bdiff := Abs( c1.b - c2.b )

    return rdiff <= tol && gdiff <= tol && bdiff <= tol
}

Diff(c1,c2){
    rdiff := Abs( c1.r - c2.r )
    gdiff := Abs( c1.g - c2.g )
    bdiff := Abs( c1.b - c2.b )

    return (rdiff + gdiff + bdiff) / 3
}

ARGBtoRGB( ARGB ){
	SetFormat, IntegerFast, hex
	ARGB := ARGB & 0x00ffffff
	ARGB .= ""  ; Necessary due to the "fast" mode.
	SetFormat, IntegerFast, d
	return ARGB
}

; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this

#Include <Gdip>			; http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
;#Include Gdip.ahk
