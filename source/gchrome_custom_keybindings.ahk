; This script is intended to be used to replace the default keybindings to switch between tabs in google chrome.
; ----------------------------------------------------------------------------------------------------------------------
SendMode Input                    ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%       ; Ensures a consistent starting directory.
SetTitleMatchMode 2               ; Recommended for new scripts to reduce the number of false positives.
#NoEnv                            ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance ignore            ; Prevents multiple instances of the script from running at the same time.
#IfWinActive, ahk_exe chrome.exe  ; If the google chrome window is active, then...
#NoTrayIcon                       ; If you don't want the tray icon, then uncomment this line.
; #Warn                           ; Enable warnings to assist with detecting common errors.
;----------------------------------------------------------------------------------------------------------------------
download_video_directory := "C:\Users\" . A_UserName . "\Downloads\Videos"
; download_audio_directory := "C:\Users\" . A_UserName . "\Downloads\Audios"
download_audio_directory := "A:\Applications\AntennaPod"
;----------------------------------------------------------------------------------------------------------------------
; KEYBINDINGS
; Navigation arrows
^!Left::Send  ^{PgUp}                                     ; ctrl+alt+pageup          → go to the previous tab
^!Right::Send ^{PgDn}                                     ; ctrl+alt+pagedown        → go to the next tab
^!Up::Send    !+{V}                                       ; ctrl+alt+shift+uparrow   → Pin/Unpin the current tab
^!Down::Send  !+{Z}                                       ; ctrl+alt+shift+downarrow → Pin/Unpin the current tab

; Numpad activation keys
^Numpad0::Send !+{P}                                      ; numpad3 -> Activate Simple Print extension
^Numpad1::Send !+{X}                                      ; numpad1 -> Activate Raindrop.io extension
^Numpad2::Send !+{C}                                      ; numpad2 -> Activate Just Read extension

^Numpad3::ytdl(download_video_directory, "video")         ; numpad3 -> Download the current video
^!Numpad3::display_downdir(download_video_directory)      ; numpad3 -> Display the download directory

^Numpad6::ytdl(download_audio_directory, "audio")         ; numpad6 -> Download the current video and extract the audio
^!Numpad6::display_downdir(download_audio_directory)      ; numpad6 -> Display the download directory

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
        ; Opens the terminal and execute the download command
        ; dl_cmd contains the string to be used by yt-dlp
        RunWait %ComSpec% /c %dl_cmd% && pause
        ; Run %ComSpec% /c %dl_cmd% && explorer %download_dir% && exit

        ; Check if the download directory is already open on windows explorer
        ; If it is, then refresh the directory, otherwise, open the directory
        check_explorer_path(download_dir)
    }

    ; command_debug(dl_command)                   ; → For debugging purposes
    ; Run %ComSpec% /c echo %dl_command% & pause  ; → For debugging purposes
    Return
}

; This function is used to refresh the download directory after the download is finished.
; It receives a file path and check if there's explorer.exe window opened at that path.
check_explorer_path(path)
{
    ; Check if there's an explorer.exe window opened at the path
    ifWinExist, ahk_exe explorer.exe, %path%
    {
        ; If there is, then refresh the window
        WinActivate, ahk_exe explorer.exe, %path%
        Send, ^r
    }
    else
    {
        ; Otherwise, open a new explorer.exe window at the path
        Run, explorer %path%
    }

}


; This function gets the URL of the current tab
; It returns the URL of the current tab
get_current_tab_url() {
    ; Gets the URL of the current tab
    SendInput, ^l
    Send, ^c
    url := ClipboardAll
    Clipboard := ""  ; clean the clipboard
    Return url
}

; ----------------------------------------------------------------------------------------------------------------------
create_download_directory(dl_dir_path) {
    ; Create the download directory if it doesn't exist
    if (!FileExist(dl_dir_path)) {
        FileCreateDir, %dl_dir_path%
        ; MsgBox, Download directory:  %dl_dir_path%  created.  ; —→ For debugging purposes
        return
    }
    ; else {
        ; MsgBox, Download directory:  %dl_dir_path% already exists.  ; —→ For debugging purposes
        ; return
    ; }
    return
}

prepare_download(download_dir, media) {
    ; CAPTURE THE CURRENT VIDEO URL
    Clipboard := ""             ; Empty the clipboard
    Send ^l                     ; Automatically select all the text in the url field
    Sleep, 10                   ; insert a little delay to allow the text to be selected
    Send ^c                     ; Copy the current URL into the clipboard, must be selected first in order to work
    ClipWait, [ 3, 1]           ; Wait 3 seconds for the clipboard to be updated
    if ErrorLevel  {            ; If the clipboard is empty, then...
        MsgBox, The attempt to copy text onto the clipboard failed.
        return
    }
    video_url := Clipboard      ; Get the URL from the clipboard
    Clipboard := ""             ; Clear the clipboard
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

    ffmpeg_location := "C:\ProgramData\chocolatey\bin\ffmpeg.exe" ; Location of ffmpeg.exe

    ; Command line arguments for video download
    if(media == "video") {
        dlp := "yt-dlp"                                                                              ; Downloader program
        ffmp := " --ffmpeg-location " ffmpeg_location " "                                            ; ffmpeg location
        cm0a := " --format bestvideo*+bestaudio/best --merge-output-format mkv"                      ; Download the best video and audio quality, then merge them into a mkv file
        cm0b := " --no-warnings --progress"                                                          ; Don't show warnings, show progress
        cm1a := " --embed-metadata"                                                                  ; Embed metadata
        cm1b := " --embed-thumbnail"                                                                 ; Embed thumbnail
        cm1c := " --embed-chapters"                                                                  ; Embed chapters
        cm2a := " --sponsorblock-mark all"                                                           ; Mark all sponsorblock segments
        cm2b := " --sponsorblock-remove default"                                                     ; Remove the default sponsorblock segments
        cm3a := " --write-subs --sub-langs en-*,pt-* --embed-subs --write-auto-sub"                  ; Write subtitles, embed subtitles, write auto-subtitles
        cm4a := " --cookies-from-browser chrome"                                                     ; Use the cookies from the browser
        cm5a := " --external-downloader aria2c"                                                      ; Use aria2c as the external downloader
        cm5b := " --external-downloader-args ""-c -x 16 -k 1M -s 32"""                               ; Set aria2c arguments, see aria2c documentation for more info
        ;NOT WORKING! —→ cm6a := "--get-filename -o ""%(title)s.%(ext)s""  "                         ; Use this to rename the file ←— NOT WORKING!!!
        video_url := " " video_url                                                                   ; Add a space at the beginning of the video URL
        ; dld := " -P " download_dir                                                                   ; Download output directory
        dld := " -o " download_dir "\%(title)s.%(ext)s"                                              ; Download output directory, then apply a template to rename the file
        
        ; Build the download command
        dl_command := dlp ffmp cm0a cm0b cm1a cm1b cm1c cm2a cm2b cm3a cm4a cm5a cm5b video_url dld  ; Concatenate all the command line arguments

        ; MsgBox, %dl_command%  ; → For debugging purposes  
        Return %dl_command%                                                                          ; Return the command string to the main function
    }

    ; Command line arguments for audio download
    else if(media == "audio") {
        ; MsgBox, "Downloading audio..."                                                             ; —→ For debugging purposes

        dlp := "yt-dlp"                                                                              ; Downloader program
        ffmp := " --ffmpeg-location " ffmpeg_location " "                                            ; ffmpeg location
        ; cm0 := " --extract-audio --audio-format mp3 --audio-quality 0"                             ; Extract audio, mp3, best quality
        cm0a := " --format 251"                                                                      ; Download the best audio quality, 251 stands for webm audio
        cm0b := " --remux-video opus"                                                                ; Remux the video into opus
        cm0c := " --no-warnings --progress"                                                          ; Don't show warnings, show progress
        cm1a := " --embed-metadata"                                                                  ; Embed metadata
        cm1b := " --embed-thumbnail"                                                                 ; Embed thumbnail
        cm1c := " --embed-chapters"                                                                  ; Embed chapters
        cm2a := " --sponsorblock-mark all"                                                           ; Mark all sponsorblock segments
        cm2b := " --sponsorblock-remove default"                                                     ; Remove the default sponsorblock segments
        cm4a := " --cookies-from-browser chrome"                                                     ; Use the cookies from the browser
        
        ; After made some tests I found out that aria2c is not the best option for audio downloads
        ; Since generally the audio files are small, aria2c is not necessary and does not perform well
        ; When I disocover optimal parameters to fix this, or maybe some future updates to aria2c or yt-dlp, then I will add aria2c to the audio download command
        ; If you want to use aria2c for audio downloads, then uncomment the following lines and add cm5a and cm5b to dl_command concatenation
        ; cm5a := " --external-downloader aria2c"                                                    ; Use aria2c as external downloader
        ; cm5b := " --external-downloader-args ""-c -j 3 -x 16 -s 16 -k 1M"""                        ; Set aria2c arguments, see aria2c documentation for more info

        video_url := " " video_url                                                                   ; Add a space at the beginning of the video URL
        dld := " -o " download_dir "\%(title)s.%(ext)s"                                              ; Download output directory, then apply a template to rename the file
        
        ; Build the download command        
        dl_command := dlp ffmp cm0a cm0b cm0c cm1a cm1b cm1c cm2a cm2b cm4a video_url dld            ; Concatenate all the command line arguments

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
        MsgBox, % "Invalid URL, please try again."              ; Inform the user that the URL is invalid
        return false                                            ; The URL is invalid
    }
}

; ----------------------------------------------------------------------------------------------------------------------
; FUTURE IMPLEMENTATIONS
; ffmpeg_post_processing() {
;     ; Uses ffmpeg to compress the video for space saving
;     ; ffmpeg -i %video_url% -c:v libx264 -crf 18 -preset slow -c:a copy -c:s mov_text %(title)s.mp4 
;     Return
; }

; ----------------------------------------------------------------------------------------------------------------------
; DEBBUGING FUNCTIONS
display_downdir(down_dir) {
    MsgBox, , % "Download Info", % "Save file path: " . down_dir, 20
    Return
}

command_debug(command) {
    Run, notepad.exe ; OK
    WinWait, ahk_class Notepad
    WinActivate, ahk_class Notepad
    Send, Command Debug: `n
    Send, %command% `n
}