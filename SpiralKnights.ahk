; Add the line #include Github/SpiralKnights.ahk/SpiralKnights.ahk to the file ~/Documents/AutoHotkey.ahk
; Set your controls in SpiralKnights.ini and ingame to match. Use non-letter keys for the controls this script sends so it doesn't interfere with typing.
; Change this path if it's incorrect.
settingsfile=GitHub/SpiralKnights.ahk/SpiralKnights.ini

; Optimized for gunner with maskeraith farming Black Kats
; Written using Elastic Tabstops (for Notepad++)





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;#include ReadIni.ahk                                    ;
;doesn't work if this file is also included              ;
;even using %A_ScriptDir%, so merged.                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadIni( filename = 0 )
; Read a whole .ini file and creates variables like this:
; %Section%%Key% = %value%
{
Local s, c, p, key, k

	if not filename
		filename := SubStr( A_ScriptName, 1, -3 ) . "ini"

	FileRead, s, %filename%

	Loop, Parse, s, `n`r, %A_Space%%A_Tab%
	{
		c := SubStr(A_LoopField, 1, 1)
		if (c="[")
			key := SubStr(A_LoopField, 2, -1)
		else if (c=";")
			continue
		else {
			p := InStr(A_LoopField, "=")
			if p {
				k := SubStr(A_LoopField, 1, p-1)
				%key%%k% := SubStr(A_LoopField, p+1)
			}
		}
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readini(settingsfile)                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;--- variables as hotkeys, enable only in window ---;

;using variables as hotkeys requires Hotkey. #IfWinActive breaks Hotkey.
;Hotkey, $%dash%, dashlabel
Hotkey, %attack%, attacklabel
Hotkey, ~%attack% up, attackuplabel
Hotkey, ~%defend%, defendlabel
Hotkey, ~%defend% up, defenduplabel





;--- spam dash ---;

;dashing:=1
SetTimer, Spamdash, %spamdelay%
;dashlabel:
;SetTimer, Spamdash, % (dashing:=!dashing) ? "100" : "Off" ; uses ternary
;return

protectingstealth:=0
Spamdash:
IfWinActive, Spiral Knights
{
	if not protectingstealth
		if GetKeyState(north) or GetKeyState(south) or GetKeyState(west) or GetKeyState(east) {
			;if poisoning {
			;	Send %bash%
			;}
			Send %dash% ;always dash every 100ms
		}
}
return

;--- poison after shot, AoE after shield charge ---;
poisoning:=0
AoE:=0
attacklabel:
IfWinActive, Spiral Knights
{
	if GetKeyState(defend, "p") {
		AoE:=1
	}
	;sendInput, {click 100} ;trade large amounts of materials at once
	if GetKeyState(north) or GetKeyState(south) or GetKeyState(west) or GetKeyState(east) {
		if Not GetKeyState(defend, "p") {
			Send %bash%
		}
	}
}
Send {%attack% down}
return
attackuplabel:
IfWinActive, Spiral Knights
{
	poisoning:=1
	SetTimer, poison, % (poisoning) ? spamdelay : "Off"
	SetTimer, stoppoison, % (poisoning) ? spritetimeout : "Off"
	if Not GetKeyState(defend, "p") {
		;dash again, cover blown.
		protectingstealth:=0
	}
	;Send %bash%
	;It seems there is a way to cancel moving forward, but still cause stun when bashing. Shield cancel?
	;I hope it's not only when getting hit.
}
return

poison:
IfWinActive, Spiral Knights
{
	if AoE {
		Send %spritespecial%
	} else {
		;Aah there's random fuzz on the fire icon!
		;ImageSearch,,, 0, 102-matchingareasize+1, clientwidth, 102, GitHub/SpiralKnights.ahk/fire.png
		;ImageSearch,,, 286, 85, 303, 102, *254 GitHub/SpiralKnights.ahk/fire.png
		;if ErrorLevel=0
		;	MsgBox, zero
		;else if ErrorLevel=1
		;	MsgBox, one
		;else if ErroLevel=2
		;	MsgBox, two
		;usehealth()

		Send %spriteattack%
	}
}
return
stoppoison:
	poisoning:=0
	AoE:=0
	SetTimer, poison, Off
	SetTimer, stoppoison, Off
	;can't pick up keys if these spam
	Send %use0%
	Send %use1%
	Send %use2%
	Send %use3%
return

;--- tap shield for stealth, pausing dash ---;

sneaking:=0
defendlabel:
IfWinActive, Spiral Knights
{
	SetTimer, stealth, % (sneaking) ? clickspeed : "Off"
}
return
defenduplabel:
IfWinActive, Spiral Knights
{
	if GetKeyState(north) or GetKeyState(south) or GetKeyState(west) or GetKeyState(east) {
		;Send %bash%
	}
	sneaking:=1
}
return

stealth:
	SetTimer, stealth, Off
IfWinActive, Spiral Knights
{
	If not GetKeyState(defend)
		protectingstealth:=1
		Send %spritedefend%
		SetTimer, stealthended, %stealthlastsfor%
}
return

stealthended:
	protectingstealth:=0
	SetTimer, stealthended, Off
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;image search section                                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Order inventory
;	Shoot button uses vials
;	4 uses health capsules
;	5 uses remedy capsules
;	6 uses helpers
;Buttons take up 54 pixel tiles.
;buttontilesize=54
;Tiles are raised 2 pixels from the bottom of the screen.
;bottomborder=2
;Center is 4 pixels, not one.
;Center of window divides first and second buttons
;Usable identification area, limited by number held: about 18x18 pixels.
;Color difference when grayed out: Difference between health1 and health1b:
;Top-left corner of button tile, buttons numbered 0 1 2 3:
;	width/2+54(button-1)
;	height-2-54
;(top-left)Center of button tile:
;	corner+26=54/2
;(bottom-right)Center of button tile:
;	corner+27
;Size of matching area: 18
;Corner of matching area:
;	corner of button tile+27-matchingarea/2=(buttontilesize-matchingareasize)/2
;Matching area:

;Count right, same as windowspy/gimp
CoordMode, Pixel, Client

clientwidth=1440;windowgetwidth
clientheight=837;windowgetheight
buttontilesize=54
matchingareasize=18
bottomborder=2

buttonnumber=0
button0x1=(clientwidth+buttontilesize-matchingareasize)/2+buttontilesize*(buttonnumber-1)
button0x2=(clientwidth+buttontilesize+matchingareasize)/2+buttontilesize*(buttonnumber-1)-1
button0y1=clientheight-bottomborder-buttontilesize+(buttontilesize-matchingareasize)/2
button0y2=clientheight-bottomborder-buttontilesize+(buttontilesize+matchingareasize)/2-1
buttonnumber=1
button1x1=(clientwidth+buttontilesize-matchingareasize)/2+buttontilesize*(buttonnumber-1)
button1x2=(clientwidth+buttontilesize+matchingareasize)/2+buttontilesize*(buttonnumber-1)-1
button1y1=clientheight-bottomborder-buttontilesize+(buttontilesize-matchingareasize)/2
button1y2=clientheight-bottomborder-buttontilesize+(buttontilesize+matchingareasize)/2-1
buttonnumber=2
button2x1=(clientwidth+buttontilesize-matchingareasize)/2+buttontilesize*(buttonnumber-1)
button2x2=(clientwidth+buttontilesize+matchingareasize)/2+buttontilesize*(buttonnumber-1)-1
button2y1=clientheight-bottomborder-buttontilesize+(buttontilesize-matchingareasize)/2
button2y2=clientheight-bottomborder-buttontilesize+(buttontilesize+matchingareasize)/2-1
buttonnumber=3
button3x1=(clientwidth+buttontilesize-matchingareasize)/2+buttontilesize*(buttonnumber-1)
button3x2=(clientwidth+buttontilesize+matchingareasize)/2+buttontilesize*(buttonnumber-1)-1
button3y1=clientheight-bottomborder-buttontilesize+(buttontilesize-matchingareasize)/2
button3y2=clientheight-bottomborder-buttontilesize+(buttontilesize+matchingareasize)/2-1

;for button=0,1,2,3
;for searchimage=health, remedy, vial, helper, other?
;

;If ImageSearch,,, button0x1, button0y1, button0x2, button0y2, health1.png
;{
;	inventory0=health
;	;inventory0=remedy
;}
;If ImageSearch,,, button1x1, button1y1, button1x2, button1y2, health1.png
;{
;	inventory1=health
;}
;If ImageSearch,,, button2x1, button2y1, button2x2, button2y2, health1.png
;{
;	inventory2=health
;}
;If ImageSearch,,, button3x1, button3y1, button3x2, button3y2, health1.png
;{
;	inventory3=health
;}

usehealth(){
	Send %use0%
}
;if inventory0=health {
;	Send use0
;} else if inventory1=health {
;	Send use1
;} else if inventory2=health {
;	Send use2
;} else if inventory3=health {
;	Send use3
;}
;return
;useremedy:
;if inventory0=remedy {
;	Send use0
;} else if inventory1=remedy {
;	Send use1
;} else if inventory2=remedy {
;	Send use2
;} else if inventory3=remedy {
;	Send use3
;}
;return
;usevial:
;if inventory0=vial {
;	Send use0
;} else if inventory1=vial {
;	Send use1
;} else if inventory2=vial {
;	Send use2
;} else if inventory3=vial {
;	Send use3
;}
;return
;usehelper:
;if not inventory0=health and not inventory0=remedy and not inventory0=vial {
;	Send use0
;} else if not inventory1=health and not inventory1=remedy and not inventory1=vial {
;	Send use1
;} else if inventory2=health and not inventory2=remedy and not inventory2=vial {
;	Send use2
;} else if inventory3=health and not inventory3=remedy and not inventory3=vial {
;	Send use3
;}
;return

;only use remedy if image searched malady
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Status effects:
;Between shield bar and countdown numbers, height is from 102 up
;Without emergency revive, everything is shifted right 3 pixels