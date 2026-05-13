#Requires AutoHotkey v2.0
#SingleInstance Force
#Include OCR.ahk
#Include blocktales-lib.ahk

; Initialization
global LowEnemyHP := false

; Block Timer
if (EnableBlocking == "true") {
    SetTimer(Block, 2)
}

; TPS Debug
if (ShowTPS == "true") {
    SetTimer(UpdateTPS, 1000)
}

; Setup
ProcessSetPriority "High"
SetTitleMatchMode 2
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"
CoordMode "ToolTip", "Screen"

; Main
if WinExist("Roblox")
    WinActivate("Roblox ahk_class WINDOWSCLIENT")
ResetMenu()

; Battle loop
Loop {
    if (HasTurnStarted()) {
        AttackRunning := false
        Sleep(50)
        if (Has2NRG()) {
            UseFirebrand()
            LowEnemyHP := true
        } else if LowEnemyHP and (Has1NRG()){
            UseVenom()
        } else {
            UseFocus()
        }
    }

    if !(InBattle()) {
        LogScreen("Checking battle status...")
        sleep(1000)
        if !(InBattle()) {
            AttackRunning := false
            sleep(1000)
            if (GetTixFromScreen() > 901) {
                TravelToBizville()
                CashOut()
            }
            
            LogScreen(GetTixFromScreen())
            RestartFight()
            LowEnemyHP := false
        }
    } else {
        LogScreen("Action: Guarding")
        AttackRunning := true
    }
    Sleep(250)
}


Esc::ExitApp