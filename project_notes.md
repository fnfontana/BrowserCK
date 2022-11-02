# BrowserCK

---

## What is BrowserCK?

An AutoHotkey script that enhances the Google Chrome browser with keyboard shortcuts.

## Currently Implemented

### Tab Management

- Navigate trough tabs
- Move tab to end or beginning of the tabs bar
- Move tabs along the tabs bar
- Pop out / Pop in tab
- Pin / Unpin tab

### Integration with yt-dlp

- Download video from current tab
- Download audio from current tab
  - Listen to YouTube videos like it was a podcast

---

## Already Implemented

- [x] Discover the cause of the instability causing the script to not work sometimes when using yt-dlp hotkey.
  
  **Cause:** Run command given with to many arguments and causing the command to fail.
  
  `Run %ComSpec% /c %dl_cmd% && explorer %download_dir% && exit`
  
  **Solutions:**
  
  - The problematic command mentioned before was replaced by a new one:

    `RunWait %ComSpec% /c %dl_cmd% && taskkill /f /im cmd.exe`
  
  - Followed by a new dedicated funciton *check_explorer_path(path)*, it solved the problem of creating a new window at each time the command run;

- [x] Implement a dedicated function or script to handle the yt-dlp command.

---

## Next to Implement

- [ ]

---

## Room for Improvments

- [ ] Optimize yt-dlp arguments.
- [ ] Insert modal showing the option to embed subtitles or not
  - [ ] Or maybe assign an alternative hotkey for this option
- [ ] Present in a clean way the video title and metadata after downloading it.
- [ ] Fetch multiple links from the clipboard and download them.
- [ ] Enable quiet mode (backgroud processing without gui)
- [ ] Use ffmpeg post processing / compressing to save space

---

## Other Ideas

- New name ideas:
  - Chrome Commander
  - The Chrome Commander (TCC)
