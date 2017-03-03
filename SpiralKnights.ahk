; Add the line #include Github/SpiralKnights.ahk/SpiralKnights.ahk to the file ~/Documents/AutoHotkey.ahk
; Set your controls in SpiralKnights.ini and ingame to match. Use non-letter keys so it doesn't interfere with typing.
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
Hotkey, ~%attack%, attacklabel
Hotkey, ~%attack% up, attackuplabel
Hotkey, ~%defend%, defendlabel
Hotkey, ~%defend% up, defenduplabel
Hotkey, ~%togglescript%, togglescriptlabel





#IfWinActive Spiral Knights

;--- spam dash ---;

;dashing:=1
SetTimer, Spamdash, %spamdelay%
;dashlabel:
;SetTimer, Spamdash, % (dashing:=!dashing) ? "100" : "Off" ; uses ternary
;return

protectingstealth:=0
Spamdash:
	if not protectingstealth
		if GetKeyState(north) or GetKeyState(south) or GetKeyState(west) or GetKeyState(east)
			Send %dash% ;always dash every 100ms
return

;--- poison after shot, AoE after shield charge ---;
poisoning:=0
AoE:=0
;Hotkey, ~%attack%, attacklabel
attacklabel:
	if GetKeyState(defend, "p") {
		AoE:=1
	}
	;sendInput, {click 100} ;trade large amounts of materials at once
return
;Hotkey, ~%attack% up, attackuplabel
attackuplabel:
	poisoning:=1
	SetTimer, poison, % (poisoning) ? spamdelay : "Off"
	SetTimer, stoppoison, % (poisoning) ? spritetimeout : "Off"
	Send %bash%
return

poison:
	if AoE {
		Send %spritespecial%
	} else {
		Send %spriteattack%
	}
return
stoppoison:
	poisoning:=0
	AoE:=0
	SetTimer, poison, Off
	SetTimer, stoppoison, Off
return

;--- tap shield for stealth, pausing dash ---;

sneaking:=0
defendlabel:
	SetTimer, stealth, % (sneaking) ? clickspeed : "Off"
return
defenduplabel:
	sneaking:=1
return

stealth:
	SetTimer, stealth, Off
	If not GetKeyState(defend)
		protectingstealth:=1
		Send %spritedefend%
		SetTimer, stealthended, %stealthlastsfor%
return

stealthended:
	protectingstealth:=0
	SetTimer, stealthended, Off
return