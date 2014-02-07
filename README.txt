MWO-Intelligent-Zoom
====================

An Autohotkey script to provide proper zoom controls in Mechwarrior Online

Quick Start Instructions:

In order to complete Quick Start, you will need to have a "Coordinate Set"
If you play in 1080p (1920x1080) resolution, the default coordinates should work for you.
If not, or you use a different resolution, check the release thread on the MWO forums, especially the second post:
http://mwomercs.com/forums/topic/133370-/page__view__findpost__p__2697189
Failing that, see the "Advanced" section for how to work out the coordinates.

1) Ready your computer and MWO for the macro, and gather required info
Fire up MWO, drop into Testing Grounds and go into the Settings menu.
Check which Resolution (eg 1920x1080 AKA "1080p") you are using in-game. The resolution is important as this macro works by looking at the HUD to tell what zoom you are currently in, and that info is in different places for different resolutions. This is also a good time to make sure that the game resolution matches the "Native Resoultion" of your monitor. You may have problems getting this app to work if this is not the case.
This app is only designed to work with MWO when it is in "Fullscreen" or "Full(screen) Window" mode.
You may also need to "Disable Aero" or "Disable UAC" (Google either) to get this app to work. If colours are always detected as black or white, this may be your problem.
Make a note of your MWO zoom key. If using non-qwerty keyboards, your keybindings may be different to the defaults this app uses. For example, for users of German keyboards, the default key for zoom is "y", not "z".

2) Starting the Zoom App for the first time.
Minimize MWO
Extract the zoom.exe from the ZIP file.
Note: It is NOT recommended to place the zoom.exe file on your desktop!
An INI file containing your settings is created in the same folder as the EXE.
Put it somewhere else and drag a shortcut to your desktop
Double click zoom.exe (or the shortcut to it), you should see a GUI pop up
Go to the profiles tab and click Add, in the box that comes up, type in a name for the profile (It is best to organize by resolution, eg "1080p" or maybe "1920x1200")
You should also check the settings of the "MWO Keys" boxes on the Main tab and make sure these match MWO.

3) Bind hotkeys to trigger Zoom App functions.
On the BINDINGS tab, tick "Program Mode" to change bindings.
In the mouse column, set the "Zoom In" row to "WheelUp" and the "Zoom Out" row to "WheelDown"
In the keyboard column, set the four "Calibrate Basic / 1.5x / 3x / 4x" rows to F1-F4 respecively, and tick the box in the Shift column on each row.
Also tick the "Limit Application" box on this screen to only take effect inside MWO
!!Remember to untick "Program Mode" before trying to use the macro!!

4) Prepare for the calibration process
On the Main tab, tick the "Always on Top" box
Again on the main tab, tick the "Calibration Mode" box.
Tab back into MWO, the Zoom GUI should still be on top. Make sure it is not covering the Zoom Readout (1.0x, 1.5x, 3.0x etc) in the lower right of the HUD.

5a) Calibrate coordinates
If using 1080p, you should not need to do anything here.
Fill in the values in the Main tab with those from the Coordinate Set.

5b) Calibrate colours
(You may need to do this step in future if you change brightness settings etc)
Does row 1 ("Basic") have "YES" on the right? If not, hit Shift-F1 (You may need to do this once or twice to find a good value).
Hit your MWO zoom key (default z)
Does row 2 ("1.5") have "YES" on the right? If not, hit Shift-F2.
Hit your MWO zoom key (default z)
Does row 3 ("1.5") have "YES" on the right? If not, hit Shift-F3.
If you have the Advanced Zoom module, activate it and do the last step, else stop here.
Does row 4 ("Adv") have "YES" on the right? If not, hit Shift-F4.

IMPORTANT:
When calibrating, be sure to look around and test the calibration.
When the HUD is over light or dark areas, it will change colour slightly, you need to test it works in all lighting conditions.

6) Finishing up
Disable "Fullscreen Window" in MWO options if desired
Disable "Always on Top" in the Main tab
Disable "Calibration mode" in the Main tab
IMPORTANT! You WILL take a BIG framerate hit in game if you do not disable Calibration Mode before playing!

The profiles tab can be used for different settings (eg if you sometimes play on a television with a different resolution, or you turn up brightness on darker levels, or you sometimes alter colour saturation using SweetFX)


ADVANCED
========

How The Macro Works
-------------------
The macro examines the colour of pixels on the screen, and is looking for the yellow HUD colour.
In the bottom-right of the MWO HUD is a Zoom Readout (ZR) which tells you which zoom mode you are in.
It reads either "1.0x", "1.5x" or "3.0x" (plus "4.0x" when using the Advanced Zoom Module if you have that fitted)
Also, the ZR might not be visible (eg you are powered down or the map is open).
As the script cannot "read" the ZR (the screen is just a grid of coloured dots to the script), it needs 3 reference coordinates.
i)   "Basic" - A pixel that should always be HUD colour (eg the middle of the "x" at the end of the ZR)
This is used to detect if you are in map mode or powered down etc - as long as this pixel is the HUD colour, the script will proceed.
ii)  "1.5" - A pixel that is only the HUD colour when at 1.5x zoom (eg the middle of the 5)
iii) "3.0" - A pixel that is only the HUD colour when at 3.0x zoom (eg the middle of the 3)

The fourth "Adv" row is for the "Advanced Zoom" module.
If you have this, you can check the "Enable Adv Zoom Module" checkbox and find a pixel unique to 4.0x zoom (eg the left-most part of the 4).


Colour Calibration:
-------------------
Graphics settings (Both in game and in the configuration for your graphics card) can affect the colour of the pixels on the screen, which means that my HUD colour is not the same as your HUD colour. Also, the position depends on the resolution you play in, so not coordinates work for all people.

The process of calibrating the colours is as follows:
The "Target" box is the colour it is looking for (Should be the MWO HUD yellow)
The "Current" box is the current colour of that pixel. (This only shows up in Calibration Mode)
The "Tolerance" box is how different the colour is allowed to be. 0 is exactly the same, and 255 will match any colour.
Ideally you want a tight a Tolerance as possible.

Assuming you have the 4 calibration hotkeys bound (See Step 3 in the quickstart section):
Make sure MWO is in "Fullscreen Window" mode still and that Always on Top is ticked is still ticked on The Main tab of Zoom.
Tab into MWO and make sure the Zoom UI is not covering the Zoom Readout in the bottom right of MWO's HUD.

For each row (ie Basic, 1.5, 3.0, Adv), repeat these steps:
i) Make sure you are in zoom mode for that row (ie zoom 1 for the Basic Row, zoom 1.5 for the 1.5 row, etc). Use the MWO zoom key (eg z) if you need to.
ii) Hit the "Calibrate Basic" hotkey for that row (eg Shift-F1 for row 1, Shift-F4 for row 4), you should hear a beep.
The current colour for the Basic Pixel should have been copied into the Target box, and the Status should now show YES as the pixel matches.
If it is not, repeat this step


Coordinate Calibration:
-----------------------
It can be very useful to open a screenshot of your game screen in a paint program to find coordinates.
In MWO, hit ALT+PrintScreen
Open Paint, hit CTRL+V
You can zoom in/out with CTRL+Mouse wheel
In the bottom left is shown current coordinates

For most users, the calibration procedure should be this:
Complete the first 3 rows (Basic, 1.5, 3.0) in order.
For each row:
a) Find some x, y coordinates for that row that look like they might work
b) Put the coordinates X and Y in the boxes for that row and switch to MWO
c) The "State" column for that row says "YES" when it detects a HUD-coloured pixel, and NO if not.
You want the "Basic" row to always say YES and the other two rows to only say YES in the relevant mode.
If the coordinate looks good but the colour does not quite match, you can use the Calibration hotkeys to copy the current value to the target value (See basic instructions)

There is a "Detected Zoom" display at the bottom of the main tab - if it correctly displays your current zoom, you should be good.

Once you have that down, configure the Advanced Zoom Module if desired.
