# Puppet Story Studio

A browser app that maps an uploaded or pasted story to a live traditional Indian puppet-show performance with spoken dialogue and movement.

## Run on Windows, macOS, or Linux

Start the app using the script for your computer:

- Windows: double-click `start-windows.bat`. It uses built-in Windows PowerShell and does not require Python.
- macOS/Linux: install Python 3.9 or newer, then in a terminal in this folder run `sh ./start-macos-linux.sh`.

No extra packages are installed. The Windows server uses built-in PowerShell; the macOS/Linux server uses Python's standard library. Speech uses the browser's built-in Web Speech API; available voices, languages, and voice quality depend on the browser and device. Keep the terminal window open and visit `http://127.0.0.1:4174` in a recent browser.

To use the app from a phone or tablet on the same Wi-Fi network, open `http://<computer-ip>:4174` in its browser. Keep the computer running the server; the phone/tablet is the browser client.

## Two-page flow

1. The first page starts with an empty story box. Paste a story or open a `.txt` file to see a rough rules-based conversion estimate.
2. Choose **Continue to puppet show**. The second page maps the story and automatically performs it once with browser-generated speech. The final frame remains visible after speech and movement finish. The app does not create or offer a downloadable video.

## Current scope

- Stories can produce up to eight minutes of estimated show time. Long inputs are shortened toward the limit while retaining higher-scoring story moments.
- The mapper can identify up to eighteen named story characters, including people, animals, and personified story objects. The puppet library includes distinct illustrated lions, rabbits, elephants, foxes, fish, flowers, the sun, the moon, and a river, alongside the existing people, birds, turtles, and trees.
- Characters visible in each act are arranged side by side at separate stage positions; their lineup adapts to the number of participants in that act.
- Scene backgrounds persist across character turns and change when the story moves to another setting. Daylight shades remain steady until the story gives a new time cue. The act caption appears at the bottom of the show.
- Character identity, costume, both hand slots, and ride slots are composited into a single puppet image. Detailed pre-drawn variants include sword-and-shield guards, horse and boat riders, basket carriers, archers, and lantern bearers; other recognized tools and rides are drawn into the generated character image. Movement includes entrance and exit, baseline forward and backward steps, upper-line and baseline travel, meetings, and attack lunges with a reaction from the adjacent character.
- Each setting gets its own baseline/upper-line point count, sized to the largest cast present in that setting's acts. The act timeline shows the active point and that setting's total points.
- Play/Pause controls the live performance and browser speech. Afterward, the final frame remains visible and the show does not loop.
- Story parsing, conversion estimates, character assignment, motion, and scene choices are local heuristics, not AI language understanding.
- Six illustrated backdrops are selected by story setting and time-of-day shades. They are not AI-generated images.
- Browser voices are device-specific and require browser speech-synthesis support. No audio or video file is rendered or downloaded.

## Files

- `index.html`, `input.js`: story input and conversion estimate.
- `puppet-show.html`, `app.js`, `style.css`: cast mapping, show rendering, and playback.
- `server.ps1`: Windows local web server using built-in PowerShell.
- `server.py`: macOS/Linux local web server using Python's standard library.
- `start-windows.bat`, `start-macos-linux.sh`: platform launch scripts; no Python packages are installed.
- `assets/puppets/`, `assets/backgrounds/`: reusable puppet figures and illustrated scenes.
- No default story or bundled sample-story files.

