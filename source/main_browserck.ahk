; This script is intended to be used to replace the default keybindings to switch between tabs in google chrome.
; ----------------------------------------------------------------------------------------------------------------------
SendMode Input ;                 Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ;    Ensures a consistent starting directory.
SetTitleMatchMode 2 ;            Recommended for new scripts to reduce the number of false positives.
#NoEnv ;                         Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance ignore ;         Prevents multiple instances of the script from running at the same time.

#NoTrayIcon ;                    If you don't want the tray icon, then uncomment this line.
; #Warn ;                        Enable warnings to assist with detecting common errors.

; Checks if the active window is Google Chrome or Brave Browser

; Google Chrome
; #IfWinActive, ahk_exe chrome.exe
; --- Paste your hotkeys here ---
; Note: If you just need Chrome, then replace brave.exe with chrome.exe.

; Brave Browser
#IfWinActive, ahk_exe brave.exe
    ;----------------------------------------------------------------------------------------------------------------------
    ; PATH TO SAVE FILES
    download_video_directory := "C:\Users\" . A_UserName . "\Downloads\Videos"
    download_audio_directory := "A:\Applications\AntennaPod"

    ; URLs
    audioread_url := "https://audioread.com/playlist"

    ; EXECUTABLE PATHS
    keepassxc_path := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\KeePassXC\KeePassXC.lnk"
    ;----------------------------------------------------------------------------------------------------------------------
    ; QUICK REFERENCE:
    ;   ^ = CTRL        ! = ALT         + = Shift        # = Win

    ; KEYBINDINGS

    ; NAVIGATION ARROWS
    ^!Left::Send ^{PgUp} ;         ctrl+alt+pageup              →  go to the previous tab
    ^!Right::Send ^{PgDn} ;        ctrl+alt+pagedown            →  go to the next tab
    ^!Up::Send !+{V} ;             ctrl+alt+shift+uparrow       →  Pin/Unpin the current tab
    ^!Down::Send !+{Z} ;           ctrl+alt+shift+downarrow     →  Pin/Unpin the current tab

    ; NUMPAD ACTIVATION KEYS
    ; Numpad 0: 0                                             --> Reading / Printing
    ^Numpad0::Send !+{P} ;                                      → Activate Simple Print extension
    ^!Numpad0::Send !+{1} ;                                     → Alternate Jiffreader extension
    ; Numpad 1: 1                                             --> Raindrop.io bookmarking
    ^Numpad1::Send !{2} ;                                       → Save page to Raindrop.io
    ^!Numpad1::Send !+{R} ;                                     → Opens Raindrop.io website
    ; Numpad 2: 2                                             -->  Save to read later
    ^Numpad2::Send ^+{2} ;                                      → Save page to Pocket
    ; Numpad 3: 3                                             --> yt-dlp video download
    ^Numpad3::ytdl(download_video_directory, "video") ;         → Download the current video
    ^!Numpad3::display_downdir(download_video_directory) ;      → Display the download directory
    ; Numpad 4: 4                                             --> text-to-speech (audioread.com)
    ^Numpad4::Send !+{2} ;                                      → Save page to Audioread
    ^!Numpad4::open_in_browser(audioread_url) ;                 → Opens Audioread website
    ; Numpad 5: 5
    ^Numpad5::Send !+{3} ;                                      → Summarize the current page with Summary
    ; Numpad 6: 6                                             --> yt-dlp audio download
    ^Numpad6::ytdl(download_audio_directory, "audio") ;         → Download the current video and extract the audio
    ^!Numpad6::display_downdir(download_audio_directory) ;      → Display the download directory
    ; Numpad 7: 7                                             --> Web Archives
    ^Numpad7::Send !{3} ;                                       → Search page on Web Archives
    ^!Numpad7::Send ^{3} ;                                      → Send page to archive.ph
    ; Numpad 8: 8                                             --> SingleFile & SingleFileZ
    ^Numpad8::Send !+{3} ;                                      → Save page using SingleFile
    ^!Numpad8::Send ^+{3} ;                                     → Save page using SingleFileZ
    ; Numpad 9: 9                                             --> Not Defined Yet...
    ; Numpad .: .                                             --> Opens KeePassXC
    ^NumpadDot::open_program(keepassxc_path) ;                  → Opens KeePassXC

    Return

    ; ----------------------------------------------------------------------------------------------------------------------

    ; FUNCTIONS

    ; This function is used to download the current video or audio from youtube
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
            ; Opens the terminal and execute the yt-dlp command to download the video
            ; Variable dl_cmd contains the commands to yt-dlp

            ; Close after wait for a timeout, useful for debugging
            ; RunWait %ComSpec% /c %dl_cmd% && timeout /t 10 && taskkill /f /im cmd.exe

            ; Close without wait for a timeout
            RunWait %ComSpec% /c %dl_cmd% ; && taskkill /f /im cmd.exe

            ; Store on a variable if RunWait command was well sucesseded or not
            ; run_result := ErrorLevel
            ; Show it on a msgbox
            ; MsgBox % run_result ;    —→ For debugging purposes

            ; If the previous command was sucessful, then...
            if(ErrorLevel == 0)
                check_explorer_path(download_dir)
            ; Checks if the download directory is already open on windows explorer
            ; If it is, then refresh the directory, otherwise, open the directory
        }
        ; For Debugging:
        ; command_debug(dl_command)                   ;     → For debugging purposes
        ; Run %ComSpec% /c echo %dl_command% & pause  ;     → For debugging purposes
        Return
    }

    ; This function is used to refresh the download directory after the download is finished.
    ; It receives a file path and check if there's explorer.exe window opened at that path.
    check_explorer_path(path){
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
    capture_tab_url() {
        Clipboard := "" ;               Empty the clipboard, in case it has something
        Send ^l ;                       Automatically select all the text in the url field
        Sleep, 5 ;                      Insert a little delay to make sure the text is selected
        Send ^c ;                       Copy the current URL into the clipboard, must be selected first in order to work
        ClipWait, [ 3, 1] ;             Wait 3 seconds for the clipboard to be updated
        if ErrorLevel { ;               If the clipboard is empty, then...
            MsgBox, The attempt to copy text onto the clipboard failed.
            return
        }
        captured_url := Clipboard ;     Save the clipboard content into the variable
        Clipboard := "" ;               Clear the clipboard for the next use
        return captured_url ;           Return the captured URL
    }

    create_download_directory(dl_dir_path) {
        ; Create the download directory if it doesn't exist
        if (!FileExist(dl_dir_path)) {
            FileCreateDir, %dl_dir_path%
            ; MsgBox, Download directory:  %dl_dir_path%  created.  ;   —→ For debugging purposes
            return
        }
        ; else {
        ; MsgBox, Download directory:  %dl_dir_path% already exists.  ; —→ For debugging purposes
        ; return
        ; }
        return
    }

    prepare_download(download_dir, media) {
        ; Get the URL to be downloaded
        video_url := capture_tab_url() ; Capture the URL of the current tab

        ; After capture the video URL from the clipboard, then...
        ; Use regex to select all the query parameters from the URL
        video_url := RegExReplace(video_url, "&(?'QueryParams'[^&]*)")
        ; MsgBox, %video_url% ; → For debugging purposes

        if(!validate_url(video_url)) { ; If the URL is not valid, then...
            Return "invalid_url" ; Return to the main function
        }
        ; --------------------------------------------------------------------------------------------------------------
        ; COMMAND LINE ARGUMENTS

        ffmpeg_location := "C:\ProgramData\chocolatey\bin\ffmpeg.exe" ; Location of ffmpeg.exe

        ; Command line arguments for video download
        if(media == "video") {
            dlp := "yt-dlp" ;                                                            Downloader program
            ffmp := " --ffmpeg-location " ffmpeg_location " " ;                          ffmpeg location
            cm0a := " --format bestvideo*+bestaudio/best --merge-output-format mkv" ;    Download the best video and audio quality, then merge them into a mkv file
            cm0b := " --no-warnings --progress" ;                                        Don't show warnings, show progress
            cm1a := " --embed-metadata" ;                                                Embed metadata
            cm1b := " --embed-thumbnail" ;                                               Embed thumbnail
            cm1c := " --embed-chapters" ;                                                Embed chapters
            cm2a := " --sponsorblock-mark all" ;                                         Mark all sponsorblock segments
            cm2b := " --sponsorblock-remove default" ;                                   Remove the default sponsorblock segments

            ; MsgBox to ask the user if he wants to download the video with or without subtitles
            MsgBox, 0x81124, yt-dlp, Deseja fazer download do video com legendas? , 30
            IfMsgBox, Yes
            {
                ; Write subtitles, embed subtitles, write auto-subtitles
                cm3a := " --sub-langs en-*,pt-* --sub-format best" ;    Select subtitles idioms and the best format available
                cm3b := " --embed-subs --write-auto-sub" ;              Embed subtitles into the video, write auto-subtitles
                cm3c := " --write-subs" ;                               Write subtitles to external file
            }
            else
            {
                cm3a := " --no-write-auto-sub" ;    Don't write automatic subtitles
                cm3b := " --no-embed-subs" ;        Don't embed subtitles
            }

            ; cm4a := " --cookies-from-browser chrome" ;                              Use the cookies from the browser
            cm5a := " --external-downloader aria2c" ;                                 Use aria2c as the external downloader
            cm5b := " --external-downloader-args ""-c -x16 -k1M -s16""" ;             Set aria2c arguments, see aria2c documentation for more info
            ;NOT WORKING! —→ cm6a := "--get-filename -o ""%(title)s.%(ext)s""  " ;    Use this to rename the file ←— NOT WORKING!!!
            video_url := " " video_url ;                                              Add a space at the beginning of the video URL
            ; dld := " -P " download_dir ;                                            Download output directory
            dld := " -o " download_dir "\%(title)s.%(ext)s" ;                         Download output directory, then apply a template to rename the file

            ; Build the download command
            dl_command := dlp ffmp cm0a cm0b cm1a cm1b cm1c cm2a cm2b cm3a cm3b cm5a cm5b video_url dld ; Concatenate all the command line arguments

            ; MsgBox, %dl_command%  ;    -> For debugging purposes
            Return %dl_command% ;        Return the command string to the main function
        }

        ; Command line arguments for audio download
        else if(media == "audio") {
            ; MsgBox, "Downloading audio..."                                                             ; —→ For debugging purposes

            dlp := "yt-dlp" ; Downloader program
            ffmp := " --ffmpeg-location " ffmpeg_location " " ;                   ffmpeg location
            ; cm0 := " --extract-audio --audio-format mp3 --audio-quality 0" ;    Extract audio, mp3, best quality
            cm0a := " --format 251" ;                                             Download the best audio quality, 251 stands for webm audio
            cm0b := " --remux-video opus" ;                                       Remux the video into opus
            cm0c := " --no-warnings --progress" ;                                 Don't show warnings, show progress
            cm1a := " --embed-metadata" ;                                         Embed metadata
            cm1b := " --embed-thumbnail" ;                                        Embed thumbnail
            cm1c := " --embed-chapters" ;                                         Embed chapters
            cm2a := " --sponsorblock-mark all" ;                                  Mark all sponsorblock segments
            cm2b := " --sponsorblock-remove default" ;                            Remove the default sponsorblock segments
            ; cm4a := " --cookies-from-browser chrome" ;                          Use the cookies from the browser

            ; After made some tests I found out that aria2c is not the best option for audio downloads
            ; Since generally the audio files are small, aria2c is not necessary and does not perform well
            ; When I disocover optimal parameters to fix this, or maybe some future updates to aria2c or yt-dlp, then I will add aria2c to the audio download command
            ; If you want to use aria2c for audio downloads, then uncomment the following lines and add cm5a and cm5b to dl_command concatenation
            ; cm5a := " --external-downloader aria2c"                                                    ; Use aria2c as external downloader
            ; cm5b := " --external-downloader-args ""-c -j 3 -x 16 -s 16 -k 1M"""                        ; Set aria2c arguments, see aria2c documentation for more info

            video_url := " " video_url ; Add a space at the beginning of the video URL
            dld := " -o " download_dir "\%(title)s.%(ext)s" ; Download output directory, then apply a template to rename the file

            ; Build the download command
            dl_command := dlp ffmp cm0a cm0b cm0c cm1a cm1b cm1c cm2a cm2b cm4a video_url dld ; Concatenate all the command line arguments

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

        regex := "[&\s]" ; 2                                Regex to validate the URL
        if (!RegExMatch(video_url, regex)) { ;              If the url doesn't contains spaces and/or ampersands, then...
            return true ; The URL is valid
        }
        else {
            MsgBox, % "Invalid URL, please try again." ;    Inform the user that the URL is invalid
            return false ;                                  The URL is invalid
        }
    }

    ; This function opens a newtab in the default browser with the URL passed as argument
    open_in_browser(url) {
        Run, % "powershell -WindowStyle hidden Start-Process " url
    }

    ; This function opens a program window given the executable path or shortcut path
    open_program(path) {
        Run, % path
    }

    ; ----------------------------------------------------------------------------------------------------------------------
    ; FUTURE IMPLEMENTATIONS

    ; ffmpeg_post_processing() {
    ;     ; Uses ffmpeg to compress the video for space saving
    ;     ; ffmpeg -i %video_url% -c:v libx264 -crf 18 -preset slow -c:a copy -c:s mov_text %(title)s.mp4
    ;     ; ffmpeg -i input.mp4 -vcodec libx265 -crf 28 output.mp4
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