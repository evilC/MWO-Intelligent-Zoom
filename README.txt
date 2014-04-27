MWO-Intelligent-Zoom
====================

An Autohotkey script to provide proper zoom controls in Mechwarrior Online

Features:
Allows you to bind zoom to mouse wheel.

Irons out MWO's quirky zoom controls (eg Adv zoom popping up briefly)

Allows you to chose if Advanced Zoom is reached via zoom in / out or on a seperate button.


Quick Start Instructions:
=========================

In MWO, open the bindings menu.

Bind "Reset Zoom" to 7
Bind "Zoom 1" to 8
Bind "Zoom 2" to 9
If you are using Advanced Zoom module, Make sure it is bound to v

You can change these keys if you wish, this is just an example.

Now run zoom.exe and go to the Bindings tab.
IMPORTANT! Tick the "Limit to Application" box. If you do not, the script will do stuff when not in MWO.
Click the "Bind" button by "Zoom In" and roll the mouse wheel up.
Click the "Bind" button by "Zoom Out" and roll the mouse wheel down.

I recommend ticking BOTH the boxes on the right - when ticked, this will allow the zoom to work when you are holding CTRL, SHIFT or ALT.


Options:
========
Enable Advanced Zoom Module
On: When you roll the wheel up enough, advanced zoom will activate
Off: When you roll the wheel up, it will stop at zoom 3.0

Skip zoom 1.5
On: Zoom level 1.5 will be skipped - if you zoom in from zoom 1.0, you will go straight to zoom 3.0


Zoom Repeat Delay
This sets the amount of time that is left between sending keys.
This is VERY IMPORTANT. Do not think that as a delay of 0 works in Testing Grounds, it will work properly in matches - it will not!

