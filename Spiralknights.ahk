#IfWinActive Spiral Knights
; File: Documents/AutoHotkey.ahk
; Optimized for gunner with maskeraith farming Black Kats

;Set your controls here and ingame to match. Use non-letter keys so it doesn't interfere with typing.

	attack	=LButton
	defend	=a
	dash	={F7}
	bash	={F10}
	spriteattack	={F9}
	spritedefend	={F3}
	spritespecial	={F4}
	spritetype	="Maskeraith"
;	spritetype	="Seraphynx"
;	spritetype	="Drakon"
	spritetimeout	="2500"
	clickspeed	=100
	spamdelay	=100
	stealthlastsfor	=16000
	togglescript	={F12}

;Replace all occurrances of the key if you wish to remap this script

;--- spam dash ---;

dashing:=1
SetTimer, Spamdash, %spamdelay%
;Hotkey, %dash%, hotkeydash
;hotkeydash:
$F7::SetTimer, Spamdash, % (dashing:=!dashing) ? %spamdelay% : "Off" ; uses ternary
;return

protectingstealth:=0
Spamdash:
	if not protectingstealth
		Send %dash% ;always dash every 100ms
return

	;--- AoE after charge? ---;
AoE:=0
;~a & ~LButton::AoE:=1
;--- poison after shot ---;

poisoning:=0
~LButton::
	if GetKeyState("a") {
		AoE:=1
	}
	;sendInput, {click 100} ;trade large amounts of materials at once
return
~LButton Up::
	poisoning:=1
	SetTimer, poison, % (poisoning) ? "100" : "Off"
	SetTimer, stoppoison, % (poisoning) ? "2500" : "Off"
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
~a::SetTimer, stealth, % (sneaking) ? clickspeed : "Off"
~a up::sneaking:=1

stealth:
	SetTimer, stealth, Off
	If not GetKeyState("a")
		protectingstealth:=1
		Send %spritedefend%
		SetTimer, stealthended, %stealthlastsfor%
return

stealthended:
	protectingstealth:=0
	SetTimer, stealthended, Off
return

;;--- disable everything ---;

f12::

Suspend

Pause,,1

return