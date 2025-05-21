-- scripts/tools/modchart_checker.lua
-- ✅ Scans modcharts/global folders
-- ✅ Reports syntax, function/var/tween/timer conflicts
-- ✅ Outputs to file + in-game popup GUI
-- ✅ Can be run from main, pause, or debug menus

local foldersToScan = {
    'scripts/global/',
    'scripts/' .. songName .. '/modcharts/'
}

local checkedFuncs = {}
local conflictFuncs, syntaxErrors = {}, {}
local globalVars, conflictVars = {}, {}
local tweenIDs, conflictTweens = {}, {}
local timerIDs, conflictTimers = {}, {}

local reportLines = {}
local guiLines = {}
local showReport = false
local scrollIndex = 1
local maxLines = 15

function string.endsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function logReport(line)
    table.insert(reportLines, line)
    table.insert(guiLines, line)
end

function onCreatePost()
    for _, folder in ipairs(foldersToScan) do
        if checkDirectory(folder) then
            local files = listFiles(folder)
            for _, file in ipairs(files) do
                if file:endsWith('.lua') then
                    local path = folder .. file
                    local content = getTextFromFile(path)

                    if not content then
                        table.insert(syntaxErrors, {file = file, error = "Could not read file"})
                    else
                        local success, err = pcall(loadstring(content))
                        if not success then
                            table.insert(syntaxErrors, {file = file, error = err})
                        end

                        for _, funcName in ipairs({
                            'onCreate', 'onCreatePost', 'onUpdate', 'onUpdatePost',
                            'onBeatHit', 'onStepHit', 'onTweenCompleted',
                            'onEvent', 'onTimerCompleted', 'onGameOver'
                        }) do
                            if content:find('function%s+' .. funcName .. '%s*%(') then
                                if checkedFuncs[funcName] then
                                    table.insert(conflictFuncs, {func = funcName, files = {checkedFuncs[funcName], file}})
                                else
                                    checkedFuncs[funcName] = file
                                end
                            end
                        end

                        for var in content:gmatch("\n([%a_][%w_]*)%s*=") do
                            if globalVars[var] and globalVars[var] ~= file then
                                table.insert(conflictVars, {var = var, files = {globalVars[var], file}})
                            else
                                globalVars[var] = file
                            end
                        end

                        for tweenID in content:gmatch("[%.:]?%s*doTween%w*%s*%(%s*['\"]([%w_]+)['\"]") do
                            if tweenIDs[tweenID] and tweenIDs[tweenID] ~= file then
                                table.insert(conflictTweens, {id = tweenID, files = {tweenIDs[tweenID], file}})
                            else
                                tweenIDs[tweenID] = file
                            end
                        end
                        for tweenID in content:gmatch("[%.:]?%s*noteTween%w*%s*%(%s*['\"]([%w_]+)['\"]") do
                            if tweenIDs[tweenID] and tweenIDs[tweenID] ~= file then
                                table.insert(conflictTweens, {id = tweenID, files = {tweenIDs[tweenID], file}})
                            else
                                tweenIDs[tweenID] = file
                            end
                        end

                        for timerID in content:gmatch("[%.:]?%s*runTimer%s*%(%s*['\"]([%w_]+)['\"]") do
                            if timerIDs[timerID] and timerIDs[timerID] ~= file then
                                table.insert(conflictTimers, {id = timerID, files = {timerIDs[timerID], file}})
                            else
                                timerIDs[timerID] = file
                            end
                        end
                    end
                end
            end
        end
    end

    logFindings()
    saveFile("modchart_check_report.txt", table.concat(reportLines, "\n"))
    showReport = true
end

function logFindings()
    if #syntaxErrors > 0 then
        logReport('\n🔴 Syntax Errors:')
        for _, err in ipairs(syntaxErrors) do
            logReport('  - ' .. err.file .. ': ' .. err.error)
        end
    end
    if #conflictFuncs > 0 then
        logReport('\n🟠 Conflicting Functions:')
        for _, conflict in ipairs(conflictFuncs) do
            logReport('  - ' .. conflict.func .. ' in ' .. conflict.files[1] .. ' and ' .. conflict.files[2])
        end
    end
    if #conflictVars > 0 then
        logReport('\n🟡 Conflicting Variables:')
        for _, conflict in ipairs(conflictVars) do
            logReport('  - ' .. conflict.var .. ' in ' .. conflict.files[1] .. ' and ' .. conflict.files[2])
        end
    end
    if #conflictTweens > 0 then
        logReport('\n🔵 Conflicting Tween IDs:')
        for _, conflict in ipairs(conflictTweens) do
            logReport('  - ' .. conflict.id .. ' in ' .. conflict.files[1] .. ' and ' .. conflict.files[2])
        end
    end
    if #conflictTimers > 0 then
        logReport('\n🟣 Conflicting Timer IDs:')
        for _, conflict in ipairs(conflictTimers) do
            logReport('  - ' .. conflict.id .. ' in ' .. conflict.files[1] .. ' and ' .. conflict.files[2])
        end
    end
    if #reportLines == 0 then
        logReport('\n✅ No issues found in scanned folders.')
    end
end

function onUpdatePost()
    if showReport then
        drawReportGUI()
    end
end

function drawReportGUI()
    drawRect('modchart_report_bg', 50, 50, 1180, 620, '000000AA')
    drawText('modchart_report_title', 'Modchart Check Report', 60, 60, 24, 'FFFFFF')
    for i = 0, maxLines - 1 do
        local idx = scrollIndex + i
        if guiLines[idx] then
            drawText('modchart_line_' .. i, guiLines[idx], 60, 100 + i * 30, 20, 'DDDDDD')
        end
    end
end

function onUpdate()
    if showReport then
        if keyboardJustPressed('up') then scrollIndex = math.max(1, scrollIndex - 1) end
        if keyboardJustPressed('down') then scrollIndex = math.min(#guiLines - maxLines + 1, scrollIndex + 1) end
        if keyboardJustPressed('escape') or keyboardJustPressed('enter') then
            showReport = false
        end
    end
end

function onPause()
    addPauseMenuItem('Run Modchart Checker', function() loadScript('tools/modchart_checker') end)
end

function onOpenDebugMenu()
    addDebugMenuItem('Run Modchart Checker', function() loadScript('tools/modchart_checker') end)
end
