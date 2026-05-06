#Requires AutoHotkey v2.0
#SingleInstance Force
#Include OCR.ahk
; Config
global StrategiesX := 450, StrategiesY := 300
global FocusX := 450, FocusY := 150
global SpecialX := 150, SpecialY := 300
global FirebrandX := 600, FirebrandY := 150

; Setup
SetTitleMatchMode 2
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"
CoordMode "ToolTip", "Screen"

; Helpers
LogScreen(msg) {
    ToolTip(msg, 0, 0)
}

UseKeyboard(keyName, duration) {
    SetKeyDelay 50, 50
    
    SendEvent("{" . keyName . " Down}")
    Sleep(duration)
    SendEvent("{" . keyName . " Up}")
    Sleep(34)
}

UseMouse(x, y) {
    SendMode "Event"
    SetDefaultMouseSpeed(5)
    MouseMove(x, y)
    Sleep(34)

    Click()
    Sleep(34)
}

; Functions
UseFirebrand() {
    global SpecialX, SpecialY, FirebrandX, FirebrandY
    LogScreen("Action: Using Firebrand")
    UseMouse(SpecialX, SpecialY)
    UseMouse(FirebrandX, FirebrandY)
}

UseFocus() {
    global StrategiesX, StrategiesY, FocusX, FocusY
    LogScreen("Action: Using Focus")
    UseMouse(StrategiesX, StrategiesY)
    UseMouse(StrategiesX, StrategiesY)
    UseMouse(FocusX, FocusY)
    UseMouse(FocusX, FocusY)
}

HasTurnStarted() {
    return PixelSearch(&FoundX, &FoundY, 100, 101, 100, 101, 0xFFD200)
}

HasSufficientNRG() {
    if PixelSearch(&FoundX, &FoundY, 1755, 790, 1756, 791, 0xCFA509){
        return True
    }
    if PixelSearch(&FoundX, &FoundY, 1755, 790, 1756, 791, 0xF8CC00) {
        return True
    }
    return False
}

NotBattling() {
    return !PixelSearch(&FoundX, &FoundY, 940, 850, 941, 851, 0x00C8FF)
}

RestartFight() {
    sleep(1000)
    TravelToPits()
    LogScreen("Initializing battle...")

    UseKeyboard("d", 1000)
    UseKeyboard("s", 333)

    UseKeyboard("d", 1250)
    UseKeyboard("s", 850)
    sleep(5000)
}

TravelToPits() {
    LogScreen("Travelling to Pits...")
    UseKeyboard("tab", 34)
    Loop 13 {
        Sleep(34)
        UseKeyboard("Down", 34)
    }
    UseMouse(1350, 825)
    UseKeyboard("tab", 34)
    Sleep(1000)
}

TravelToBizville() {
    LogScreen("Travelling to Bizville...")
    UseKeyboard("tab", 34)
    UseKeyboard("Down", 34)
    Loop 13 {
        Sleep(34)
        UseKeyboard("Up", 34)
    }
    UseMouse(600, 420)
    UseKeyboard("tab", 34)
    Sleep(1000)
}

CashOut() {
    LogScreen("Compressing TIX...")
    Sleep(1000)
    UseKeyboard("w", 4000)
    UseKeyboard("a", 11500)
    UseKeyboard("w", 4000)
    Loop 5 {
        Sleep(150)
        UseKeyboard("e", 150)
    }
    UseMouse(1000, 220)
    UseMouse(1200, 600)
    UseMouse(1840, 50)
}

GetTixFromScreen() {
    result := OCR.FromRect(270, 910, 100, 40)

    formatted := RegExReplace(result.Text, "\D", "")

    if (formatted = "")
        return 0
    return Integer(formatted)
}

; Main
if WinExist("Roblox")
    WinActivate("Roblox ahk_class WINDOWSCLIENT")
; Battle loop

Loop {
    if (HasTurnStarted()) {
        Sleep(100)
        if (HasSufficientNRG()) {
            UseFirebrand()
        } else {
            UseFocus()
        }
    }
    Sleep(500)

    if (NotBattling()) {
        LogScreen("Checking battle status...")
        sleep(1000)
        if (NotBattling()) {
            sleep(1000)
            if (GetTixFromScreen() > 350) {
                TravelToBizville()
                CashOut()
            }
            
            LogScreen(GetTixFromScreen())
            RestartFight()
        }
    }
}

Esc::ExitApp