-- Maps original song names to their formatted keys
function formatSongName(n)
    return n:lower():gsub(" ", "-")
end

-- Known scripts to load per song
local knownScripts = {
[--[['a']]] = { --[['b','c','d']]}
}

function onCreate()
    local currentSong = songName
    local formatted = formatSongName(currentSong)

    debugPrint("Original song name: " .. currentSong)
    debugPrint("Formatted song name: " .. formatted)

    local list = knownScripts[formatted]
    if not list then
        debugPrint("⚠️ No modcharts entry for: " .. formatted)
        return
    end

    for i = 1, #list do
        local scriptPath = '/scripts/' .. formatted .. '/modcharts/' .. list[i]
        addLuaScript(scriptPath)
        debugPrint('Loaded: ' .. scriptPath)
    end
end