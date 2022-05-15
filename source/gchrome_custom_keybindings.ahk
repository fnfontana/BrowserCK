; This script is intended to be used to replace the default keybindings to switch between tabs in google chrome.
; ----------------------------------------------------------------------------------------------------------------------
SendMode Input                    ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%       ; Ensures a consistent starting directory.
SetTitleMatchMode 2               ; Recommended for new scripts to reduce the number of false positives.
#NoEnv                            ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance ignore            ; Prevents multiple instances of the script from running at the same time.
#IfWinActive, ahk_exe chrome.exe  ; If the google chrome window is active, then...
; #NoTrayIcon                     ; If you don't want the tray icon, then uncomment this line.
; #Warn                           ; Enable warnings to assist with detecting common errors.
;----------------------------------------------------------------------------------------------------------------------
download_directory = "C:\Users\ffont\Downloads\Videos"
;----------------------------------------------------------------------------------------------------------------------
; KEYBINDINGS
; Navigation arrows
^!Left::Send ^{PgUp}    ; ctrl+alt+pageup -> go to the previous tab
^!Right::Send ^{PgDn}   ; ctrl+alt+pagedown -> go to the next tab
^!Down::Send !+{Z}      ; alt+shift+z -> Enable/Disable Pop-up tab
+!Down::Send !+{Z}      ; alt+shift+z -> Enable/Disable Pop-up tab
^!Up::Send !+{V}        ; alt+shift+z -> Pin/Unpin the current tab
+!Up::Send !+{V}        ; alt+shift+z -> Pin/Unpin the current tab

; Numpad activation keys
^Numpad0::Send !+{P}    ; numpad3 -> Activate Simple Print extension
^Numpad1::Send !+{X}    ; numpad1 -> Activate Raindrop.io extension
^Numpad2::Send !+{C}    ; numpad2 -> Activate Just Read extension
^Numpad3::ytdl(download_directory)  ; numpad3 -> Download the current video

return
; ------------------------------------------------------
; FUNCTIONS
ytdl(download_dir) {
    ; CAPTURE THE CURRENT VIDEO URL
    Clipboard := ""             ; Empty the clipboard
    Send ^l                     ; Automatically select all the text in the url field
    Send ^c                     ; Copy the current URL into the clipboard, must be selected first in order to work
    ClipWait, [ 3, 1]           ; Wait 3 seconds for the clipboard to be updated
    if ErrorLevel  {            ; If the clipboard is empty, then...
        MsgBox, The attempt to copy text onto the clipboard failed.
        return
    }
    video_url := Clipboard      ; Get the URL from the clipboard
    Clipboard := ""             ; Empty the clipboard
    ; --------------------------------------------------------------------------------------------------------------
    ; After capture the video URL from the clipboard, then...
    ; Use regex to select all the query parameters from the URL
    video_url := RegExReplace(video_url, "&(?'QueryParams'[^&]*)")
    ; MsgBox, %video_url% ; → For debugging purposes
    ; --------------------------------------------------------------------------------------------------------------
    ; COMMAND LINE ARGUMENTS
    dlp := "yt-dlp"
    cm0 := " -f best --no-warnings --progress"
    cm1 := " --embed-chapters --sponsorblock-mark all"
    cm2 := " --write-subs --sub-langs en-*,pt-* --embed-subs --write-auto-sub"
    cm3 := " --embed-metadata"
    cm4 := " --cookies-from-browser chrome"
    cm5 := " --external-downloader aria2c --external-downloader-args ""-x 16 -k 1M"""
    ;NOT WORKING! —→ cm6 := "--get-filename -o ""%(title)s.%(ext)s""  " ; Use this to rename the file ←— NOT WORKING!!!
    video_url := " " video_url  ; Add a space at the beginning of the video URL
    dld := " -P " download_dir
    
    dl_command := dlp cm0 cm1 cm2 cm3 cm4 cm5 video_url dld 
    ; MsgBox, %dl_command%                                                                  ; → For debugging purposes
; --------------------------------------------------------------------------------------------------------------
    ; Uses ffmpeg to compress the video for space saving
    ; ffmpeg -i %video_url% -c:v libx264 -crf 18 -preset slow -c:a copy -c:s mov_text %(title)s.mp4 

    MsgBox, 0x81124, yt-dlp, Deseja fazer download? , 30
    ifMsgBox Yes
        ; Run %ComSpec% /c %dl_command% & start %download_dir% & pause
        RunWait %ComSpec% /c %dl_command% && pause
        Run explorer.exe %download_dir%
        ; command_debug(dl_command)                   ; → For debugging purposes
        ; Run %ComSpec% /c echo %dl_command% & pause  ; → For debugging purposes
        Return
    ifMsgBox No
        return
}

command_debug(command) {
    Run, notepad.exe ; OK
    WinWait, ahk_class Notepad
    WinActivate, ahk_class Notepad
    Send, Command Debug: `n
    Send, %command% `n
}