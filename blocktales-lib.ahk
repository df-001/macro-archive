#Requires AutoHotkey v2.0
#Include OCR.ahk

ConfigPath := A_ScriptDir "\config.ini"
global UnlockedPit60 := IniRead(ConfigPath, "Settings", "UnlockedPit60", true)
global EnableBlocking := IniRead(ConfigPath, "Settings", "EnableBlocking", true)
global ShowTPS := IniRead(ConfigPath, "Settings", "ShowTPS", true)
global PitX := 1350

if (UnlockedPit60 == "true") {
    global PitY := 680
} else {
    global PitY := 825
}

; Base Resolution: 1920 x 1080
global ScaleX := A_ScreenWidth / 1920
global ScaleY := A_ScreenHeight / 1080

; Scaling Function
S_X(val) => Round(val * ScaleX)
S_Y(val) => Round(val * ScaleY)

; Scales with Display
global TixX := S_X(270), TixY := S_Y(910)
global TixW := S_X(100), TixH := S_Y(40)
global NRGY := S_Y(790)
global NRG1 := S_X(1670)
global NRG2 := S_X(1745)
global NRG3 := S_X(1822)
global InBattleX := S_X(1846), InBattleY := S_Y(752)
global BlockX1 := S_X(400), BlockY1 := S_Y(300)
global BlockX2 := S_X(910), BlockY2 := S_Y(550)
global MenuOpenX := S_X(1750), MenuOpenY := S_Y(180)

; No Scaling (Hardcoded UI elements that don't move with res)
global PlayerTurnX := 143, PlayerTurnY := 108
global StrategiesX := 450,  StrategiesY := 300
global FocusX      := 450,  FocusY      := 150
global SpecialX    := 150,  SpecialY    := 300
global WindforceX  := 750,  WindforceY  := 150
global FirebrandX  := 600,  FirebrandY  := 150
global VenomX      := 300,  VenomY      := 150

; Other
global AttackRunning := false
global FrameCount := 0
global CurrentTPS := 0

; Script Interactions
LogScreen(msg) {
    ToolTip(msg, 0, 0)
}

UseKeyboard(keyName, duration) {
    SendEvent("{" . keyName . " Down}")
    Sleep(duration)
    SendEvent("{" . keyName . " Up}")
}

UseMouse(x, y) {
    SendMode "Event"
    SetDefaultMouseSpeed(5)
    MouseMove(x, y)
    Sleep(32)
    Click()
}

UpdateTPS() {
    global FrameCount, CurrentTPS
    CurrentTPS := Format("{:.1f}", (FrameCount / 64) * 100)
    FrameCount := 0

    ToolTip("Detection speed: " . CurrentTPS . "% (CPU)", 0, 20, 2) 
}

; Ingame Functions

Block() {
    global AttackRunning, FrameCount

    if (AttackRunning) {
        FrameCount++
        if PixelSearch(&FoundX, &FoundY, BlockX1, BlockY1, BlockX2, BlockY2, 0xACA100, 20) {
            Sleep(80)
            SendEvent("{space Down}")
            SendEvent("{space Up}")
        }
    }
}

; Battle Actions
UseWindforce() {
    global SpecialX, SpecialY, WindforceX, WindforceY
    LogScreen("Action: Using Windforce")
    UseMouse(SpecialX, SpecialY)
    Sleep(50)
    UseMouse(WindforceX, WindforceY)
    Sleep(50)
}

UseFirebrand() {
    global SpecialX, SpecialY, FirebrandX, FirebrandY
    LogScreen("Action: Using Firebrand")
    UseMouse(SpecialX, SpecialY)
    UseMouse(FirebrandX, FirebrandY)
}

UseVenom() {
    global SpecialX, SpecialY, VenomX, VenomY
    LogScreen("Action: Using Venomshank")
    UseMouse(SpecialX, SpecialY)
    UseMouse(VenomX, VenomY)
}

UseFocus() {
    global StrategiesX, StrategiesY, FocusX, FocusY
    LogScreen("Action: Using Focus")
    UseMouse(StrategiesX, StrategiesY)
    UseMouse(StrategiesX, StrategiesY)
    UseMouse(FocusX, FocusY)
    UseMouse(FocusX, FocusY)
}

; NRG
Has3NRG() {
    return (PixelGetColor(NRG3, NRGY) != 0x2D082D)
}

Has2NRG() {
    return (PixelGetColor(NRG2, NRGY) != 0x2D082D)
}

Has1NRG() {
    return (PixelGetColor(NRG1, NRGY) != 0x2D082D)
}

; Situational Awareness
HasTurnStarted() {
    return (PixelGetColor(PlayerTurnX, PlayerTurnY) == 0xCC29BC) || (PixelGetColor(PlayerTurnX, PlayerTurnY) == 0xD43127) || (PixelGetColor(PlayerTurnX, PlayerTurnY) == 0xFBC712)
}

InBattle() {
    return PixelGetColor(InBattleX, InBattleY) == 0xFFFFFF
}

; Map Actions

TravelToPits() {
    LogScreen("Travelling to Pits...")
    ResetMenu()
    UseKeyboard("tab", 50)
    UseMouse(S_X(1390), S_Y(200))
    Loop 13 {
        Sleep(50)
        UseKeyboard("Down", 50)
    }
    UseMouse(S_X(PitX), S_Y(PitY))
    UseKeyboard("tab", 50)
    Sleep(1500)
}

TravelToBizville() {
    LogScreen("Travelling to Bizville...")
    ResetMenu()
    UseKeyboard("tab", 50)
    UseMouse(S_X(1390), S_Y(200))
    UseKeyboard("Down", 50)
    Loop 13 {
        Sleep(50)
        UseKeyboard("Up", 50)
    }
    UseMouse(S_X(600), S_Y(420))
    UseKeyboard("tab", 50)
    Sleep(1500)
}

RestartFight() {
    sleep(1000)
    TravelToPits()
    LogScreen("Initializing battle...")

    UseKeyboard("d", 1000)
    UseKeyboard("s", 333)

    UseKeyboard("d", 1250)
    UseKeyboard("s", 900)
    Sleep(1000)
    UseKeyboard("s", 1000)
    UseKeyboard("d", 1000)
    sleep(2500)
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
    UseMouse(S_X(1000), S_Y(220))
    Sleep(100)
    UseMouse(S_X(1200), S_Y(600))
    Sleep(100)
    UseMouse(S_X(1000), S_Y(220))
    Sleep(100)
    UseMouse(S_X(1200), S_Y(600))
    Sleep(100)
    UseMouse(S_X(1000), S_Y(220))
    Sleep(100)
    UseMouse(S_X(1200), S_Y(600))
    UseMouse(S_X(1840), S_Y(50))
}

; Misc

GetTixFromScreen() {
    result := OCR.FromRect(TixX, TixY, TixW, TixH)

    formatted := RegExReplace(result.Text, "\D", "")

    if (formatted = "")
        return 0
    return Integer(formatted)
}

ResetMenu() {
    if (PixelGetColor(MenuOpenX, MenuOpenY) == 0xAC3232) {
        UseKeyboard("tab", 32)
    }
}
