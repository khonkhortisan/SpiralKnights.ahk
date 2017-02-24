; File: Documents/AutoHotkey.ahk
; Optimized for gunner with maskeraith farming Black Kats
; Written using Elastic Tabstops (for Notepad++)

;Set your controls here and ingame to match. Use non-letter keys so it doesn't interfere with typing.
#include readini.ahk
readini(SpiralKnights.ini)

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

;;--- disable everything ---;

togglescriptlabel:

Suspend

Pause,,1

return