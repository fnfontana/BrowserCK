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
download_video_directory := "C:\Users\" . A_UserName . "\Downloads\Videos"
download_audio_directory := "C:\Users\" . A_UserName . "\Downloads\Audios"
;----------------------------------------------------------------------------------------------------------------------
; KEYBINDINGS
; Navigation arrows
^!Left::Send  ^{PgUp}              ; ctrl+alt+pageup          → go to the previous tab
^!Right::Send ^{PgDn}              ; ctrl+alt+pagedown        → go to the next tab
^!Up::Send    !+{V}                ; ctrl+alt+shift+uparrow   → Pin/Unpin the current tab
^!Down::Send  !+{Z}                ; ctrl+alt+shift+downarrow → Pin/Unpin the current tab

; Numpad activation keys
^Numpad0::Send !+{P}                                      ; numpad3 -> Activate Simple Print extension
^Numpad1::Send !+{X}                                      ; numpad1 -> Activate Raindrop.io extension
^Numpad2::Send !+{C}                                      ; numpad2 -> Activate Just Read extension
^Numpad3::ytdl(download_video_directory, "video")         ; numpad3 -> Download the current video
^!Numpad3::display_downdir(download_video_directory)      ; numpad3 -> Display the download directory
^Numpad6::ytdl(download_audio_directory, "audio")         ; numpad6 -> Download the current video and extract the audio

Return
; ----------------------------------------------------------------------------------------------------------------------
; FUNCTIONS
ytdl(download_dir, media) {
    if(media == "video") {
        MsgBox, 0x81124, yt-dlp, Deseja fazer download do video? , 30
        ifMsgBox, No
            Return
    }
    else if(media == "audio") {
        MsgBox, 0x81124, yt-dlp, Deseja fazer download e extrair o audio? , 30
        ifMsgBox, No
            Return
    }
    

    create_download_directory(download_dir)
    dl_cmd := prepare_download(download_dir, media)

    if(dl_cmd == "invalid_url") { 
        err_message := "Invalid URL: Check the video URL and try again."
        MsgBox, , yt-dlp, % err_message, 30
        ; MsgBox % dl_cmd                           ; —→ For debugging purposes
        Return
    }
    else {
        Run %ComSpec% /c %dl_cmd% && explorer %download_dir% && exit
        ; RunWait %ComSpec% /c %dl_cmd% && pause
        ; Run explorer.exe %download_dir%
    }
    ; command_debug(dl_command)                   ; → For debugging purposes
    ; Run %ComSpec% /c echo %dl_command% & pause  ; → For debugging purposes
    Return
}
; ----------------------------------------------------------------------------------------------------------------------
create_download_directory(dl_dir_path) {
    ; Create the download directory if it doesn't exist
    if (!FileExist(dl_dir_path)) {
        FileCreateDir, %dl_dir_path%
        ; MsgBox, Download directory:  %dl_dir_path%  created.  ; —→ For debugging purposes
        return
    }
    else {
        ; MsgBox, Download directory:  %dl_dir_path% already exists.  ; —→ For debugging purposes
        return
    }
}

prepare_download(download_dir, media) {
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

    if(!validate_url(video_url)) {      ; If the URL is not valid, then...
        Return "invalid_url"            ; Return to the main function
    }
    ; --------------------------------------------------------------------------------------------------------------
    ; COMMAND LINE ARGUMENTS
    if(media == "video") {
        dlp := "yt-dlp"                                                                             ; Downloader program
        cm0 := " -f best --no-warnings --progress"                                                  ; Best quality, no warnings, show progress
        cm1 := " --embed-chapters --sponsorblock-mark all"                                          ; Embed chapters, block sponsors
        cm2 := " --write-subs --sub-langs en-*,pt-* --embed-subs --write-auto-sub"                  ; Write subtitles, embed subtitles, write auto-subtitles
        cm3 := " --embed-metadata"                                                                  ; Embed metadata
        cm4 := " --cookies-from-browser chrome"                                                     ; Use the cookies from the browser
        cm5 := " --external-downloader aria2c --external-downloader-args ""-x 16 -k 1M -s 32"""     ; Use aria2c as external downloader, 16 parallel downloads, 1M max download size
        ;NOT WORKING! —→ cm6 := "--get-filename -o ""%(title)s.%(ext)s""  "                         ; Use this to rename the file ←— NOT WORKING!!!
        video_url := " " video_url                                                                  ; Add a space at the beginning of the video URL
        dld := " -P " download_dir                                                                  ; Download output directory
        
        dl_command := dlp cm0 cm1 cm2 cm3 cm4 cm5 video_url dld    
                            ; Build the download command
        ; MsgBox, %dl_command%   
        Return %dl_command%  
    }
    else if(media == "audio") {
        ; MsgBox, "Downloading audio..."                                                           ; —→ For debugging purposes
    
        dlp := "yt-dlp"                                                                            ; Downloader program
        cm0 := " --extract-audio --audio-format mp3 --audio-quality 0"                             ; Extract audio, mp3, best quality
        cm1 := " --embed-chapters --sponsorblock-remove all"                                       ; Embed chapters, block sponsors
        cm2 := " --embed-thumbnail --embed-metadata"                                               ; Embed the thumbnail and metadata to output file
        cm3 := " --no-warnings --progress --ignore-errors"                                         ; No warnings, show progress, ignore errors
        cm4 := " --cookies-from-browser chrome"                                                    ; Use the cookies from the browser
        ; cm5 := " --external-downloader aria2c --external-downloader-args ""-x 16 -k 1M -s 32"""    ; Use aria2c as external downloader, 16 parallel downloads, 1M max download size
        video_url := " " video_url                                                                 ; Add a space at the beginning of the video URL
        dld := " -P " download_dir                                                                 ; Download output directory

        ; Build the download command
        dl_command := dlp cm0 cm1 cm2 cm3 cm4 video_url dld    

        ; MsgBox, %dl_command%   
        Return %dl_command%  
    }
}

validate_url(video_url) {
    ; This function receives a string containing the video URL
    ; It uses a regular expression to validate the URL
    ; It accepts videos from youtube or any other video site
    ; To be considered valid, the url should not:
    ; - Contain spaces
    ; - Contain query parameters
    ; Returns true if the URL is valid, false otherwise.

    regex := "[&\s]"                      ; Regex to validate the URL
    if (!RegExMatch(video_url, regex)) {  ; If the url doesn't contains spaces and/or ampersands, then...
        return true                       ; The URL is valid
    }
    else {
    ;   MsgBox, % "Invalid URL, please try again."              
        return false                      ; The URL is invalid
    }
}

ffmpeg_post_processing() {
    ; Uses ffmpeg to compress the video for space saving
    ; ffmpeg -i %video_url% -c:v libx264 -crf 18 -preset slow -c:a copy -c:s mov_text %(title)s.mp4 
    Return
}

; ----------------------------------------------------------------------------------------------------------------------
; DEBBUGING FUNCTIONS
display_downdir(down_dir) {
    MsgBox, , % "Download Info", % "Save videos to: " . down_dir, 20
    Return
}

command_debug(command) {
    Run, notepad.exe ; OK
    WinWait, ahk_class Notepad
    WinActivate, ahk_class Notepad
    Send, Command Debug: `n
    Send, %command% `n
}