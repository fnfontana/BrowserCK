# GChromeCK

---

## What is GChromeCK?

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

## Next to Implement

- [x] Discover the cause of the instability causing the script to not work sometimes when using yt-dlp hotkey.
  
  **Cause:** Run command given with to many arguments and causing the command to fail.
  
  `Run %ComSpec% /c %dl_cmd% && explorer %download_dir% && exit`
  
  **Solution:** Try to create a **function** or a **batch script** that waits for the download to finish. It receives *dl_cmd* and *download_dir* as arguments, waits for the download to finish and then opens the download directory. Make sure to check if the folder is already open in explorer.exe, if so, then don’t open it again.

- [ ] Implement a dedicated function or script to handle the yt-dlp command.

- [ ] Fetch multiple links from the clipboard and download them.

- [ ] Present in a clean way the video title and metadata after downloading it.

- [ ] Optimize yt-dlp arguments.

## Improvments

- [ ] ffmpeg post processing / compressing to save space
- [ ] enable quiet mode (backgroud processing without gui)

## Ideas

- New name ideas:
  - Chrome Commander
  - The Chrome Commander (TCC)
