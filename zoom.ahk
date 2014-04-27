; MWO Intelligent Zoom

; Create an instance of the library
ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

; Buffer hotkeys - important, required so rolling mouse wheel up while already zooming queues a zoom
#MaxThreadsBuffer on
; Just in case I spin my mouse wheel in free-spinning mode ;)
#MaxHotkeysPerInterval 999

zoom := 1
max_zoom := 0

; ============================================================================================
; CONFIG SECTION - Configure ADHD

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "MWO Zoom", version: "5.0", author: "evilC", link: "<a href=""http://mwomercs.com/forums/topic/133370-"">Homepage</a>"})
; The default application to limit hotkeys to.
; Starts disabled by default, so no danger setting to whatever you want
ADHD.config_limit_app("CryENGINE")

; GUI size
ADHD.config_size(375,220)

; Configure update notifications:
ADHD.config_updates("http://evilc.com/files/ahk/mwo/mwozoom.au.txt")

; Defines your hotkeys 
; subroutine is the label (subroutine name - like MySub: ) to be called on press of bound key
; uiname is what to refer to it as in the UI (ie Human readable, with spaces)
ADHD.config_hotkey_add({uiname: "Zoom In", subroutine: "ZoomIn"})
ADHD.config_hotkey_add({uiname: "Zoom Out", subroutine: "ZoomOut"})

; Hook into ADHD events
; First parameter is name of event to hook into, second parameter is a function name to launch on that event
ADHD.config_event("option_changed", "option_changed_hook")
/*
ADHD.config_event("app_active", "app_active_hook")
ADHD.config_event("app_inactive", "app_inactive_hook")
ADHD.config_event("tab_changed", "tab_changed_hook")
ADHD.config_event("on_exit", "on_exit_hook")
*/

ADHD.init()

ADHD.create_gui()

; The "Main" tab is tab 1
Gui, Tab, 1

col1 := 10
col2 := 195

Gui, Add, GroupBox, x5 y30 w170 h140, Options

ADHD.gui_add("CheckBox", "AdvZoom", "x" col1 " yp+30", "Enable Adv Zoom Module", 0)
AdvZoom_TT := "Enable to include Advanced Zoom in the range of zooms used."

ADHD.gui_add("CheckBox", "SkipZoom15", "x" col1 " yp+30", "Skip zoom 1.5", 0)
SkipZoom15_TT := "Use this to skip straight from 1.5 to 3.0"

Gui, Add, Text, x%col1% yp+30, Zoom repeat delay (ms)
ADHD.gui_add("Edit", "ZoomDelay", "xp+120 yp-3 W30", "", 150)
ZoomDelay_TT := "How long to leave between zooms.`nWARNING! You need to adjust this figure in an actual game!`nTesting Grounds does not require a delay, BUT A MATCH DOES!"

Gui, Add, GroupBox, x190 y30 w170 h140, MWO Keys

Gui, Add, Text, x%col2% yp+30, Reset Zoom (Zoom 1.0x)
ADHD.gui_add("Edit", "ZoomKey10", "xp+120 yp-3 W30", "", "7")
ZoomKey10_TT := "The key bound to Zoom 1.0 in MWO"

Gui, Add, Text, x%col2% yp+30, Zoom 1 (Zoom 1.5x)
ADHD.gui_add("Edit", "ZoomKey15", "xp+120 yp-3 W30", "", "8")
ZoomKey15_TT := "The key bound to Zoom 1.5 in MWO"

Gui, Add, Text, x%col2% yp+30, Zoom 2 (Zoom 3.0x)
ADHD.gui_add("Edit", "ZoomKey30", "xp+120 yp-3 W30", "", "9")
ZoomKey30_TT := "The key bound to Zoom 3.0 in MWO"

Gui, Add, Text, x%col2% yp+30, Adv Zoom (Zoom 4.0x):
ADHD.gui_add("Edit", "AdvZoomKey", "xp+120 yp-3 W30", "", "v")
AdvZoomKey_TT := "The key bound to Advance Zoom (Module) in MWO"


; End GUI creation section
; ============================================================================================

ADHD.finish_startup()

return

; Hotkey Subroutines
; =================================================

ZoomIn:
	DoZoom(1)
	return
	
ZoomOut:
	DoZoom(-1)
	return



DoZoom(dir){
	global zoom
	global AdvZoom
	global max_zoom
	global SkipZoom15

	last_zoom := zoom

	zoom := zoom + dir
	if (zoom == 2 && SkipZoom15){
		zoom := zoom + dir
	}

	zoom := ClampZoom(zoom)

	; Send the key, even if same zoom (Helps with keeping in synch), except for Adv Zoom
	if (! (last_zoom == 4 && zoom == 4)){
		SendZoom(zoom)
	}
}

SendZoom(zoom){
	global ZoomKey10
	global ZoomKey15
	global ZoomKey30
	global AdvZoomKey

	global ZoomDelay
	if (zoom == 1){
		Send {%ZoomKey10%}
	} else if (zoom == 2){
		Send {%ZoomKey15%}
	} else if (zoom == 3){
		Send {%ZoomKey30%}
	} else if (zoom == 4){
		Send {%AdvZoomKey%}
	}
	Sleep %ZoomDelay%
}

; Clamps an amount to one of the normal zoom values (1-3)
ClampZoom(z){
	global max_zoom

	if (z > max_zoom){
		z := max_zoom
	} else if (z < 1){
		z := 1
	}
	return z
}

option_changed_hook(){
	global AdvZoom
	global max_zoom

	if (AdvZoom == 1){
		max_zoom := 4
	} else {
		max_zoom :=3
	}
	zoom := 1

}

; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this
 
