-- scripts/menu/MainMenu.lua
-- Injects a Modchart Checker option into Main Menu without source edits

local injected = false

function onCreatePost()
    if not injected then
        injected = true
        addOption('Modchart Checker', function()
            loadScript('tools/modchart_checker')
        end)
    end
end