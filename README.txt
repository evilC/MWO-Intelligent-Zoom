MWO-Intelligent-Zoom
====================

An Autohotkey script to provide proper zoom controls in Mechwarrior Online

INSTRUCTIONS:

1) Double click the EXE, you should see a GUI pop up
Note: It is not recommended to place the EXE on your desktop!
An INI file containing your settings is created in the same folder as the EXE.
Put it somewhere else and drag a shortcut to your desktop

2) Bind controls
On the BINDINGS tab, bind the controls you desire to "Zoom In" and "Zoom Out".
Recommended bindings: In the mouse column, set "Zoom In" to "WheelUp" and "Zoom Out" to "WheelDown"
Tick "Program Mode" to change bindings.
Also tick the "Limit Application" box on this screen to only take effect inside MWO
Remember to untick "Program Mode" before trying to use the macro!

The default settings should work for 1080p, so you may be able to skip the rest of the stages

(You will need to repeat from this step if you change resolution)

3) Set up MWO for calibration
Start MWO, and in the Options screen, set "Windowed Mode" to "Full Window" and accept.
You need to do this so you can see the GUI and MWO at the same time
Then drop into Testing Grounds

4) Start calibration process
On the Main tab, tick the "Always on Top" box
Again on the main tab, tick the "Calibration Mode" box.

5) The calibration process
OK, here is where it starts to get a litte complicated, so listen up...
In order to understand how to calibrate the macro, it helps to explain how it works:
The macro examines the colour of pixels on the screen, and is looking for the yellow HUD colour.
In the bottom-right of the MWO HUD is a Zoom Readout (ZR) which tells you which zoom mode you are in.
It reads either "1.0x", "1.5x" or "3.0x"
Also, the ZR might not be visible (eg you are powered down or the map is open).
As the script cannot "read" the ZR (the screen is just a grid of coloured dots to the script), it needs 3 reference coordinates.
i)   "Basic" - A pixel that should always be HUD colour (eg the middle of the "x" at the end of the ZR)
This is used to detect if you are in map mode or powered down etc - as long as this pixel is the HUD colour, the script will proceed.
ii)  "1.5" - A pixel that is only the HUD colour when at 1.5x zoom (eg the middle of the 5)
iii) "3.0" - A pixel that is only the HUD colour when at 3.0x zoom (eg the middle of the 3)

It can be very useful to open a screenshot of your game screen in a paint program to find coordinates.
In MWO, hit ALT+PrintScreen
Open Paint, hit CTRL+V
You can zoom in/out with CTRL+Mouse wheel
In the bottom left is shown current coordinates

For most users, the calibration procedure should be this:
Complete the 3 rows (Basic, 1.5, 3.0) in order.
a) Find some x, y coordinates for that row that look like they might work
b) Put the coordinates X and Y in the boxes for that row and switch to MWO
c) The "State" column for that row says "YES" when it detects a HUD-coloured pixel, and NO if not.
You want the "Basic" row to always say YES and the other two rows to only say YES in the relevant mode

There is a "Detected Zoom" display at the bottom of the main tab - if it correctly displays your current zoom, you should be good.

For some users, you may need to mess with the colour values:
The "Target" box is the colour it is looking for (Should be the MWO HUD yellow)
The "Current" box is the current colour of that pixel. (This only shows up in Calibration Mode)
The "Tolerance" box is how different the colour is allowed to be. 0 is exactly the same, and 255 will match any colour.
Ideally you want a tight a Tolerance as possible.

IMPORTANT:
When calibrating, be sure to look around and test the calibration.
When the ZR is over light or dark areas, it will change colour slightly, you need to test it works in all lighting conditions.

6) Finishing up
Disable "Fullscreen Window" in MWO options if desired
Disable "Always on Top" in the Main tab
Disable "Calibration mode" in the Main tab
IMPORTANT! You WILL take a BIG framerate hit in game if you do not disable Calibration Mode before playing!

NB: The profiles tab is basically useless for this macro, you can ignore it.