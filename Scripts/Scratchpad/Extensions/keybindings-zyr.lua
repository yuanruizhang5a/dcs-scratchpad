-- Physical-key remapping for the Scratchpad editor.
--
-- Binding names use DCS key names plus optional Ctrl, Alt, and Shift
-- modifiers. Mappings are exact: "q" and "Ctrl+q" are different bindings.

local focusToggleHotkey = "Ctrl+Alt+3"
local blockUnmappedPlainLetters = true

local keyBindings = {
    ["q"] = {action = "insert", text = "1"},
    ["w"] = {action = "insert", text = "2"},
    ["e"] = {action = "insert", text = "3"},
    ["a"] = {action = "insert", text = "4"},
    ["s"] = {action = "insert", text = "5"},
    ["d"] = {action = "insert", text = "6"},
    ["z"] = {action = "insert", text = "7"},
    ["x"] = {action = "insert", text = "8"},
    ["c"] = {action = "insert", text = "9"},
    ["f"] = {action = "insert", text = "0"},
    ["v"] = {action = "backspace"},
    ["r"] = {action = "enter"},
    ["u"] = {action = "line_begin"},
    ["i"] = {action = "line_end"},
    -- ["Shift+space"] = {action = "insert", text = " "},
    ["t"] = {action = "cursor_up_line_end"},
    ["g"] = {action = "cursor_down_line_end"},
    ["j"] = {action = "cursor_down"},
    ["k"] = {action = "cursor_up"},
    ["h"] = {action = "cursor_left"},
    ["l"] = {action = "cursor_right"},
}

local dxgui = require("dxgui")
local Window = require("Window")

local function logMessage(message)
    log("[keybindings-zyr] " .. tostring(message))
end

local function bindingId(button, ctrlPressed, altPressed, shiftPressed)
    return table.concat({
        ctrlPressed and "1" or "0",
        altPressed and "1" or "0",
        shiftPressed and "1" or "0",
        string.lower(button),
    }, "|")
end

local function parseBinding(binding)
    if type(binding) ~= "string" or binding == "" then
        return nil, nil, "binding name must be a non-empty string"
    end

    local parsed = Window.parseHotKey(binding)
    if not parsed or not parsed.button then
        return nil, nil, "binding has no key"
    end

    return bindingId(
        parsed.button,
        parsed.ctrlPressed,
        parsed.altPressed,
        parsed.shiftPressed
    ), parsed
end

local function modifierPressed(leftName, rightName)
    return dxgui.GetKeyboardButtonPressed(leftName)
        or dxgui.GetKeyboardButtonPressed(rightName)
end

local function currentBindingId(keyName)
    return bindingId(
        keyName,
        modifierPressed("left ctrl", "right ctrl"),
        modifierPressed("left alt", "right alt"),
        modifierPressed("left shift", "right shift")
    )
end

local function utf8SequenceLength(firstByte)
    if firstByte < 128 then
        return 1
    elseif firstByte < 224 then
        return 2
    elseif firstByte < 240 then
        return 3
    elseif firstByte < 248 then
        return 4
    end

    -- Treat malformed bytes as individual characters instead of failing.
    return 1
end

local function setCursorAtByte(textarea, text, byteOffset)
    byteOffset = math.max(0, math.min(byteOffset, #text))

    local line = 0
    local index = 0
    local byteIndex = 1

    while byteIndex <= byteOffset do
        local firstByte = text:byte(byteIndex)
        if firstByte == 10 then -- newline
            line = line + 1
            index = 0
            byteIndex = byteIndex + 1
        else
            index = index + 1
            byteIndex = byteIndex + utf8SequenceLength(firstByte)
        end
    end

    textarea:setSelectionNew(line, index, line, index)
end

local function replaceSelection(textarea, replacement)
    local text = textarea:getText()
    local _, _, startByte, endByte = getSelection()
    local updated = string.sub(text, 1, startByte)
        .. replacement
        .. string.sub(text, endByte + 1)

    textarea:setText(updated)
    setCursorAtByte(textarea, updated, startByte + #replacement)
end

local function deleteBackward(textarea)
    local text = textarea:getText()
    local _, _, startByte, endByte = getSelection()

    if startByte ~= endByte then
        replaceSelection(textarea, "")
        return
    end

    if startByte == 0 then
        return
    end

    -- Move from the byte immediately before the cursor to the leading byte of
    -- that UTF-8 character.
    local deleteFrom = startByte
    while deleteFrom > 1 do
        local byte = text:byte(deleteFrom)
        if byte and byte >= 128 and byte < 192 then
            deleteFrom = deleteFrom - 1
        else
            break
        end
    end

    local updated = string.sub(text, 1, deleteFrom - 1)
        .. string.sub(text, endByte + 1)

    textarea:setText(updated)
    setCursorAtByte(textarea, updated, deleteFrom - 1)
end

local function moveCursorToLineEnd(textarea)
    local _, _, lineEnd = textarea:getSelectionNew()
    local lineLength = textarea:getLineTextLength(lineEnd)
    textarea:setSelectionNew(lineEnd, lineLength, lineEnd, lineLength)
end

local function moveCursorToLineBeginning(textarea)
    local _, _, lineEnd = textarea:getSelectionNew()
    textarea:setSelectionNew(lineEnd, 0, lineEnd, 0)
end

local function moveCursorDown(textarea)
    local _, _, lineEnd, indexEnd = textarea:getSelectionNew()
    local targetLine = lineEnd + 1

    if targetLine >= textarea:getLineCount() then
        return
    end

    local targetIndex = math.min(indexEnd, textarea:getLineTextLength(targetLine))
    textarea:setSelectionNew(targetLine, targetIndex, targetLine, targetIndex)
end

local function moveCursorUp(textarea)
    local _, _, lineEnd, indexEnd = textarea:getSelectionNew()
    local targetLine = lineEnd - 1

    if targetLine < 0 then
        return
    end

    local targetIndex = math.min(indexEnd, textarea:getLineTextLength(targetLine))
    textarea:setSelectionNew(targetLine, targetIndex, targetLine, targetIndex)
end

local function moveCursorLeft(textarea)
    local _, _, lineEnd, indexEnd = textarea:getSelectionNew()
    local targetIndex = math.max(indexEnd - 1, 0)
    textarea:setSelectionNew(lineEnd, targetIndex, lineEnd, targetIndex)
end

local function moveCursorRight(textarea)
    local _, _, lineEnd, indexEnd = textarea:getSelectionNew()
    local lineLength = textarea:getLineTextLength(lineEnd)
    local targetIndex = math.min(indexEnd + 1, lineLength)
    textarea:setSelectionNew(lineEnd, targetIndex, lineEnd, targetIndex)
end

local function validateAction(binding, action)
    if type(action) ~= "table" then
        return nil, "action for `" .. binding .. "` must be a table"
    end

    if action.action == "insert" then
        if type(action.text) ~= "string" then
            return nil, "insert action for `" .. binding .. "` requires string field `text`"
        end
        return action
    end

    if action.action == "backspace"
        or action.action == "enter"
        or action.action == "noop"
        or action.action == "line_begin"
        or action.action == "line_end"
        or action.action == "cursor_down"
        or action.action == "cursor_up"
        or action.action == "cursor_down_line_end"
        or action.action == "cursor_up_line_end"
        or action.action == "cursor_left"
        or action.action == "cursor_right" then
        return action
    end

    return nil, "unsupported action for `" .. binding .. "`: " .. tostring(action.action)
end

local function compileBindings(focusBindingId)
    local compiled = {}

    for binding, action in pairs(keyBindings) do
        local id, parsed, parseError = parseBinding(binding)
        if not id then
            logMessage("Ignoring `" .. tostring(binding) .. "`: " .. parseError)
        elseif parsed.button == "escape" then
            logMessage("Ignoring `" .. binding .. "`: Escape is reserved for Scratchpad blur")
        elseif id == focusBindingId then
            logMessage("Ignoring `" .. binding .. "`: it conflicts with the focus hotkey")
        elseif compiled[id] then
            logMessage("Ignoring duplicate normalized binding `" .. binding .. "`")
        else
            local validAction, actionError = validateAction(binding, action)
            if validAction then
                compiled[id] = validAction
            else
                logMessage(actionError)
            end
        end
    end

    if blockUnmappedPlainLetters then
        for byte = string.byte("a"), string.byte("z") do
            local letter = string.char(byte)
            local id = bindingId(letter, false, false, false)

            -- Explicit DIY bindings always win. Shift/Ctrl/Alt combinations
            -- have different IDs, so they remain available for normal input
            -- or their own explicit bindings.
            if not compiled[id] and id ~= focusBindingId then
                compiled[id] = {action = "noop"}
            end
        end
    end

    return compiled
end

local function executeAction(textarea, action)
    local ok, actionError = pcall(function()
        if action.action == "noop" then
            return
        elseif action.action == "insert" then
            replaceSelection(textarea, action.text)
        elseif action.action == "backspace" then
            deleteBackward(textarea)
        elseif action.action == "enter" then
            replaceSelection(textarea, "\n")
        elseif action.action == "line_begin" then
            moveCursorToLineBeginning(textarea)
        elseif action.action == "line_end" then
            moveCursorToLineEnd(textarea)
        elseif action.action == "cursor_down" then
            moveCursorDown(textarea)
        elseif action.action == "cursor_up" then
            moveCursorUp(textarea)
        elseif action.action == "cursor_down_line_end" then
            moveCursorDown(textarea)
            moveCursorToLineEnd(textarea)
        elseif action.action == "cursor_up_line_end" then
            moveCursorUp(textarea)
            moveCursorToLineEnd(textarea)
        elseif action.action == "cursor_left" then
            moveCursorLeft(textarea)
        elseif action.action == "cursor_right" then
            moveCursorRight(textarea)
        end
    end)

    if not ok then
        logMessage("Binding action failed: " .. tostring(actionError))
    end
end


local initialized = false

local function initialize()
    if initialized then
        return true
    end

    local textarea = getTextarea()
    if not textarea then
        return false
    end

    local focusBindingId, _, focusParseError = parseBinding(focusToggleHotkey)
    if not focusBindingId then
        error("invalid focus hotkey: " .. focusParseError)
    end

    local compiledBindings = compileBindings(focusBindingId)
    local window = textarea:getRoot()
    if not window then
        error("could not find the Scratchpad root window")
    end

    local pendingEdit = nil

    local function applyEdit(self, edit)
        -- Restore the exact state from before DCS handled the physical key,
        -- removing any native character insertion or clipboard paste.
        self:setText(edit.text)
        self:setSelectionNew(
            edit.lineStart,
            edit.indexStart,
            edit.lineEnd,
            edit.indexEnd
        )
        executeAction(self, edit.action)
    end

    textarea:addKeyDownCallback(function(self, keyName)
        if isHidden() or not self:getFocused() or type(keyName) ~= "string" then
            return
        end

        local action = compiledBindings[currentBindingId(keyName)]
        if not action then
            return
        end

        -- Finalize an earlier mapped key first if overlapping key presses occur.
        if pendingEdit then
            local previousEdit = pendingEdit
            pendingEdit = nil
            applyEdit(self, previousEdit)
        end

        local lineStart, indexStart, lineEnd, indexEnd = self:getSelectionNew()
        pendingEdit = {
            action = action,
            keyName = string.lower(keyName),
            text = self:getText(),
            lineStart = lineStart,
            indexStart = indexStart,
            lineEnd = lineEnd,
            indexEnd = indexEnd,
            corrected = false,
        }

        -- Do not consume the key-down event. Allow DCS to finish its native
        -- text-input path, then replace that result from the change/key-up
        -- callbacks below.
    end)

    -- DCS can insert shifted characters after the key-down callbacks complete.
    -- Its resulting change event is the earliest reliable point at which the
    -- original text can be restored and the mapped action applied exactly once.
    textarea:addChangeCallback(function(self)
        if pendingEdit and not pendingEdit.corrected then
            pendingEdit.corrected = true
            applyEdit(self, pendingEdit)
        end
    end)

    -- Reapply on key-up as a final correction after all DCS text-input work is
    -- complete. This is intentionally idempotent because it starts from the
    -- captured pre-key state each time.
    textarea:addKeyUpCallback(function(self, keyName)
        if pendingEdit
            and type(keyName) == "string"
            and pendingEdit.keyName == string.lower(keyName) then
            local edit = pendingEdit
            pendingEdit = nil
            applyEdit(self, edit)
            return true
        end
    end)

    textarea:addFocusCallback(function(self)
        if not self:getFocused() then
            pendingEdit = nil
        end
    end)

    window:addHotKeyCallback(focusToggleHotkey, function()
        if not isHidden() then
            textarea:setFocused(not textarea:getFocused())
        end
    end)

    initialized = true
    logMessage("Initialized physical key bindings and focus hotkey " .. focusToggleHotkey)
    return true
end

-- Extensions are loaded before the Scratchpad window is constructed. Register
-- a separate DCS callback and initialize on the first later simulation frame
-- where the edit box exists. The callback remains registered, but becomes an
-- inexpensive no-op after initialization because DCS has no callback-removal
-- API for an individual callback table.
local initializationFinished = false
local initializer = {}

function initializer.onSimulationFrame()
    if initializationFinished then
        return
    end

    local ok, doneOrError = pcall(initialize)
    if not ok then
        logMessage("Initialization failed: " .. tostring(doneOrError))
        initializationFinished = true
        return
    end

    if doneOrError then
        initializationFinished = true
    end
end

DCS.setUserCallbacks(initializer)
logMessage("Loaded; waiting for the Scratchpad window")
