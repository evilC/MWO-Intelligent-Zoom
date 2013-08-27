#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#InstallMouseHook
#InstallKeybdHook

SetKeyDelay, 0, 50

zooming := 0

#IfWinActive, ahk_class CryENGINE
*~Wheelup::
	do_zoom(1)
	return

*~Wheeldown::
	do_zoom(0)
	return
#IfWinActive

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