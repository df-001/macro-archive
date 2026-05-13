#Requires AutoHotkey v2.0 
#SingleInstance Force
#Include blocktales-lib.ahk

; Setup
if (ShowTPS == "true") {
    SetTimer(UpdateTPS, 1000)
}

SetTimer(Block, 2) 

ProcessSetPriority "High" 
SetTitleMatchMode 2 
CoordMode "Pixel", "Screen" 
CoordMode "Mouse", "Screen" 
CoordMode "ToolTip", "Screen" 

; Main
if WinExist("Roblox")
    LogScreen("Hold F to block...")
    WinActivate("Roblox ahk_class WINDOWSCLIENT")

$f:: {
    global AttackRunning := true
    LogScreen("Action: Blocking...")
    KeyWait "f" ; After key release
    AttackRunning := false
    LogScreen("Hold F to block...")
}

Esc::ExitApp