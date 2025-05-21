This is a autoloader I made because the data/(songname) was starting
to get really disorganised. 
I will include a correctly formatted directory that the code expects
(assume this is the (modname)/scripts path)

Folder Structure Overview
You will be storing your modchart scripts inside:
(modname)/scripts/(songname)/modcharts/
Example:
For a song named "Example" that loads modcharts named "b", "c", and "d", the folder structure should look like:


(modname)/
└── scripts/
    ├── autoloader.lua
    └── example/
        └── modcharts/
            ├── b.lua
            ├── c.lua
            └── d.lua


Migrating Your Modcharts
If you currently have your modcharts inside (modname)/<song-name>/, follow these steps:

Make Folder in the Scripts Folder:

Make a folder in (modname)/scripts and name it the same as the 
name of the song found in the data folder like the 
Example:
if the name of the song found in (modname)/data is this-is-the-end ,
then the path should be (modname)/scripts/this-is-the-end
(modname)/
└── scripts/
    └── this-is-the-end

Add Folder to the New Folder

After you make the folder for the song, add a folder to that
called modcharts.
Example:

(modname)/
└── scripts/
    └── this-is-the-end/
        └── modcharts

Move Modcharts:

Move all .lua modchart scripts from:
(modname)/
└── data/
    └── this-is-the-end/
to:

(modname)/
└── scripts/
    └──(songname)/
        └──modcharts/
(modname)/scripts/(songname)/modcharts/


Ensure Paths Match the Table in the Script:

Example knownScripts entry:
local knownScripts = {
    ['example'] = {'b', 'c', 'd'}
}
This expects:
(modname)/
└── (modname)/scripts/
    └── (modname)/scripts/example/
        └── (modname)/scripts/example/modcharts/
            ├── (modname)/scripts/example/modcharts/b.lua
            ├── (modname)/scripts/example/modcharts/c.lua
            └── (modname)/scripts/example/modcharts/d.lua


Troubleshooting: Modcharts Are Loaded But Not Running
If the autoloader prints "Loaded:" messages but the actual modchart code isn’t working, here are common causes and how to fix them:

1. Missing Hook Functions (onUpdate, onStepHit, etc.)
Psych Engine only calls specific functions like:

onCreate()

onCreatePost()

onUpdate()

onStepHit()

onBeatHit()

Fix:

Make sure your modchart scripts actually contain these functions.

Example of working structure:

function onUpdate()
    setProperty('camHUD.angle', math.sin(getSongPosition() / 100) * 5)
end


Not valid:

-- code outside a function won't run unless explicitly called
setProperty('camHUD.angle', 5)


2. Code Is in onCreate(), But It’s Never Triggered

If your modchart has logic only inside onCreate(), remember that modcharts loaded by addLuaScript() run onCreate() immediately, but only once when the file is added.

Fix:
Avoid depending solely on onCreate() for timed visual effects. Instead, use onUpdate(), onStepHit(), or onBeatHit() for ongoing effects.



3. Conflicting or Overwritten Functions
If multiple modchart files define the same function (like onUpdate()), only the last loaded one will be used.

Fix:
Use unique prefixes or isolate logic using script variables.

Example:


function onUpdate()
    if songName == 'example' then
        -- only do something for song example
    end
end

Or use unique state variables per script to manage behavior.

4. File Loads but Contains Syntax Errors
Psych Engine won’t always show an error for a syntax mistake in a loaded modchart script.

Fix:

Test each modchart file independently.

Temporarily put a debugPrint("Script loaded OK") at the top of the modchart script to verify it ran.

5. Using Psych Engine-Exclusive Functions Incorrectly
Functions like doTweenX, noteTweenAngle, etc., require proper parameters.

Fix:
Check for typos or missing parameters in all modchart logic.
Example of correct use:

noteTweenX('moveNote0', 0, 400, 1, 'quadInOut')


Extra Debug Tip
Add this to the top of every modchart script during testing:
debugPrint(" [modchart name] script is executing.")

This will confirm the script not only loaded, but also started running.


6. Move the onCreate function or create it
Move the onCreate() Function to the Top (Even If One Exists)
If your modchart defines onCreate() lower in the file 
— or if it’s mixed with other logic 
— it may not run correctly when loaded dynamically with addLuaScript().

This is especially important because Psych Engine calls onCreate() immediately when the file is loaded.

 How to Move onCreate() Safely:
If your script already has an onCreate() function, follow these steps:

Copy,then Cut the entire existing onCreate() function.

Example:


function onCreate()
    setProperty('cameraSpeed', 2)
    debugPrint('Custom modchart setup')
end

Scroll to the top of the script (before any other functions or global variables).

Paste the onCreate() function there.

Now your script looks like this:


function onCreate()
    setProperty('cameraSpeed', 2)
    debugPrint('Custom modchart setup')
end

-- rest of your modchart code follows here
function onStepHit()
    -- effects here
end

Make sure there is only one onCreate() in the file.

If you had multiple onCreate() definitions, merge their contents into one.

Why This Helps:
When scripts are loaded during a song using addLuaScript(), onCreate() is called immediately. If your onCreate() is too low in the file,
it might not be declared yet when the engine looks for it — which means it never runs.

Fix for onCreate(): 
onCreate() Has Variable Declarations

If your onCreate() function defines important variables, and you move it to the top of the file, those variables won’t exist yet for other parts of your code.

Fix: Declare the Variables at the Top, Then Assign Them in onCreate()
Instead of defining variables inside onCreate(), do this:

Don’t do this:


function onCreate()
    local crazyZoom = 2 -- local means it's only visible inside this function
    setProperty('camHUD.zoom', crazyZoom)
end

function onStepHit()
    if curStep == 64 then
        setProperty('camHUD.zoom', crazyZoom) --  undefined here
    end
end

Do this instead:

-- Step 1: Move onCreate() to the top, assign values inside
function onCreate()
    crazyZoom = 2
    setProperty('camHUD.zoom', crazyZoom)
end

-- Step 2: Other logic can now use the variable
function onStepHit()
    if curStep == 64 then
        setProperty('camHUD.zoom', crazyZoom)
    end
end
Bonus Tip: Avoid local for Shared Variables
If you want variables to be accessible across multiple functions in your script, do not use local.

Use local only when you want a variable to exist only inside one function.

