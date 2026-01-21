

Autoloader for Modcharts

This is an autoloader I made because the data/(songname) structure was getting really disorganized. Below is the folder structure that the script expects. Assume this README is placed at (modname)/scripts.

Folder Structure Overview

You will be storing your modchart scripts inside:

(modname)/scripts/(songname)/modcharts/

Example

For a song named example that loads modcharts named b, c, and d, the folder structure should look like:

(modname)/
└── scripts/
    ├── autoloader.lua
    └── example/
        └── modcharts/
            ├── b.lua
            ├── c.lua
            └── d.lua


⸻

Migrating Your Modcharts

If you currently have your modcharts inside (modname)/data/<song-name>/, follow these steps:

1. Make Folder in the Scripts Directory

Make a folder in (modname)/scripts/ and name it the same as the song name found in the data folder.

Example:

If the song name is this-is-the-end, create the path:

(modname)/
└── scripts/
    └── this-is-the-end/

2. Add modcharts Folder

Inside your new song folder, add a folder called modcharts.

(modname)/
└── scripts/
    └── this-is-the-end/
        └── modcharts/

3. Move Modcharts

Move all .lua modchart scripts from:

(modname)/data/this-is-the-end/

To:

(modname)/scripts/this-is-the-end/modcharts/


⸻

Ensure Paths Match the Table in the Script

Example knownScripts entry:

local knownScripts = {
    ['example'] = {'b', 'c', 'd'}
}

This expects the following file structure:

(modname)/scripts/example/modcharts/
├── b.lua
├── c.lua
└── d.lua


⸻

Troubleshooting: Modcharts Are Loaded But Not Running

If the autoloader prints “Loaded:” messages but the actual modchart code isn’t working, try the following solutions:

1. Missing Hook Functions (onUpdate, onStepHit, etc.)

Psych Engine only calls specific functions:
	•	onCreate()
	•	onCreatePost()
	•	onUpdate()
	•	onStepHit()
	•	onBeatHit()

Fix: Make sure your modchart scripts actually define these functions.

Valid Example:

function onUpdate()
    setProperty('camHUD.angle', math.sin(getSongPosition() / 100) * 5)
end

Invalid:

-- This won't run unless called manually
setProperty('camHUD.angle', 5)


⸻

2. Code in onCreate() Never Runs

onCreate() is only triggered once when using addLuaScript().

Fix: Use onUpdate(), onStepHit(), or onBeatHit() for ongoing behavior.

⸻

3. Conflicting or Overwritten Functions

If multiple scripts define the same function (e.g., onUpdate()), only the last one loaded is used.

Fix: Use conditional logic or isolate logic using state variables.

function onUpdate()
    if songName == 'example' then
        -- Only run for the correct song
    end
end


⸻

4. Script Loads but Contains Syntax Errors

Psych Engine might not show clear errors for syntax issues.

Fix:
	•	Test each script independently.
	•	Add this at the top of each script:

debugPrint("example script is executing")


⸻

5. Incorrect Use of Engine Functions

Functions like noteTweenX require correct parameters.

Fix: Double-check usage:

noteTweenX('moveNote0', 0, 400, 1, 'quadInOut')


⸻

6. onCreate() Function is Too Low in File

Psych calls onCreate() immediately after loading a file. If the function is defined too low, it might not exist yet.

Fix:
	•	Move onCreate() to the very top of the file.
	•	Merge multiple onCreate() blocks if needed.

function onCreate()
    setProperty('cameraSpeed', 2)
    debugPrint('Custom modchart setup')
end


⸻

onCreate() Has Variable Declarations

If you define important variables inside onCreate(), they won’t exist globally.

Don’t do this:

function onCreate()
    local crazyZoom = 2
    setProperty('camHUD.zoom', crazyZoom)
end

function onStepHit()
    setProperty('camHUD.zoom', crazyZoom) -- Error: undefined
end

Do this instead:

-- Declare variable globally
crazyZoom = 0

function onCreate()
    crazyZoom = 2
    setProperty('camHUD.zoom', crazyZoom)
end

function onStepHit()
    if curStep == 64 then
        setProperty('camHUD.zoom', crazyZoom)
    end
end

Tip: Avoid using local for variables shared across functions.

⸻

Bonus Debug Tip

Add this line at the top of every modchart script during testing:

debugPrint("[modchart name] script is executing.")

This confirms the script is not only loaded but actively running.

