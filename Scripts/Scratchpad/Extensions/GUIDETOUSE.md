# DCS Scratchpad Usage Guide

This guide describes how to use the Scratchpad in this DCS Saved Games setup. It does not cover installation.

## Quick start

1. Press `Ctrl+Alt+Backtick` to show the Scratchpad.
2. Click inside the text area, or press `Ctrl+Alt+3`, to give the editor keyboard focus.
3. Use the physical-key mappings or the on-screen keypad described below. Use `Shift`+letter when you want to type a letter.
4. Press `Esc`, click outside the Scratchpad, or press `Ctrl+Alt+3` again to release keyboard focus.
5. Press `Ctrl+Alt+Backtick` again to hide the Scratchpad.

When the editor is focused, Scratchpad captures keyboard input so that keystrokes do not also operate the aircraft. Release focus when you want normal DCS keyboard controls back.

## Window and focus controls

| Control | Function |
|---|---|
| `Ctrl+Alt+Backtick` | Show or hide the Scratchpad window. Hiding it also saves the current page and releases keyboard focus. |
| `Ctrl+Alt+3` | Toggle editor focus while the Scratchpad is visible. Focus enables typing; pressing it again releases focus and saves the page. |
| Click in the text area | Focus the editor and enable typing. |
| `Esc` | Release editor focus without hiding the Scratchpad. |
| Click outside the Scratchpad | Release editor focus. |
| Drag the title bar | Move the Scratchpad. Its position is saved automatically. |
| Drag a window edge/corner | Resize the Scratchpad. Its size is saved automatically. |

## Page controls

Each `.txt` file in `Saved Games\DCS\Scratchpad\` is a Scratchpad page. The window title shows the current page's filename without `.txt`.

| Control | Function |
|---|---|
| `Ctrl+Alt+1` | Go to the previous page. |
| `Ctrl+Alt+2` | Go to the next page. |
| `←` button | Go to the previous page. |
| `→` button | Go to the next page. |

Changing pages saves the page being left. The current page is also saved when focus is released or the Scratchpad is hidden.

## Physical-key shortcuts

These mappings work only while the Scratchpad editor is focused. The keys below are plain, unmodified keys, so they replace the normal letters while the editor is focused. Every other plain `a`–`z` key is blocked and produces nothing. Hold `Shift` while pressing a letter to insert its uppercase form. A binding is an exact combination: mapping `q` does not also map `Shift+q`.

| Shortcut | Scratchpad result |
|---|---|
| `q` | Insert `1`. |
| `w` | Insert `2`. |
| `e` | Insert `3`. |
| `a` | Insert `4`. |
| `s` | Insert `5`. |
| `d` | Insert `6`. |
| `z` | Insert `7`. |
| `x` | Insert `8`. |
| `c` | Insert `9`. |
| `f` | Insert `0`. |
| `v` | Backspace: delete the selection, or delete the character before the cursor. |
| `r` | Enter: insert a new line. |
| `u` | Move to the beginning of the current line. |
| `i` | Move to the end of the current line. |
| `t` | Move up one line when possible, then move to the end of that line. On the first line, move to the end of the current line. |
| `g` | Move down one line when possible, then move to the end of that line. On the last line, move to the end of the current line. |
| `j` | Move down one line when possible, preserving the current column or using the target line's end if it is shorter. |
| `k` | Move up one line when possible, preserving the current column or using the target line's end if it is shorter. |
| `h` | Move left by one character without leaving the current line. At the start of the line, do nothing. |
| `l` | Move right by one character without leaving the current line. At the end of the line, do nothing. |
| `b`, `m`, `n`, `o`, `p`, or `y` | Do nothing because these plain letters have no DIY binding. |
| `Shift+a` through `Shift+z` | Insert the corresponding uppercase letter, unless that exact shifted combination is given its own DIY binding. |

Unmapped non-letter keys keep their normal editor behavior. In particular, `Space` inserts a normal space.

## On-screen keypad

The upper keypad has three rows:

```text
1  2  3  ENT  ↑  N  S
4  5  6   0   ↓  W  E
7  8  9   ⌫   ␣  -  +
```

| Button | Function |
|---|---|
| `0`–`9` | Insert the displayed digit. |
| `ENT` | Insert a new line. |
| `⌫` | Delete the selection, or delete the character before the cursor. |
| `␣` | Insert a space. |
| `↑` | Same as `t`: move up one line when possible, then move to its end. |
| `↓` | Same as `g`: move down one line when possible, then move to its end. |
| `N`, `S`, `W`, `E` | Insert the displayed direction letter. |
| `-`, `+` | Insert the displayed symbol. |

The lower on-screen QWERTY keyboard inserts uppercase letters `A` through `Z`.

## Coordinates from the F10 map

The coordinate controls appear only when DCS permits ownship export, normally in single player or on a server with player export enabled.

1. Check the coordinate checkbox at the bottom of the Scratchpad.
2. A white crosshair appears at the center of the screen.
3. Open the F10 map and place the crosshair over the desired location.
4. Press `+L/L` to insert the location's supported coordinate formats and altitude into the Scratchpad.

The active `ns430.lua` extension also adds an NS430-style line containing `%PlaceHolderName`. Replace that placeholder with a 1–5 character alphanumeric waypoint name if you intend to use the generated line for NS430 data.

## DIY customization

Close DCS before editing Lua or configuration files, and restart DCS after every change. Scratchpad extensions are loaded only once during startup.

### Change physical-key bindings

Edit `Saved Games\DCS\Scripts\Scratchpad\Extensions\keybindings-zyr.lua`.

The user-editable settings are at the top:

```lua
local focusToggleHotkey = "Ctrl+Alt+3"
local blockUnmappedPlainLetters = true

local keyBindings = {
    ["q"] = {action = "insert", text = "1"},
    ["v"] = {action = "backspace"},
    ["r"] = {action = "enter"},
    ["u"] = {action = "line_begin"},
    ["i"] = {action = "line_end"},
    ["t"] = {action = "cursor_up_line_end"},
    ["g"] = {action = "cursor_down_line_end"},
    ["j"] = {action = "cursor_down"},
    ["k"] = {action = "cursor_up"},
    ["h"] = {action = "cursor_left"},
    ["l"] = {action = "cursor_right"},
}
```

- Change `focusToggleHotkey` to change the focus toggle.
- Keep `blockUnmappedPlainLetters` set to `true` to make every unbound plain `a`–`z` key do nothing. Set it to `false` to restore normal typing for those unbound letters.
- Add, remove, or edit rows inside `keyBindings` to change physical shortcuts.
- Explicit entries in `keyBindings` take priority over automatic letter blocking.
- Binding names are case-insensitive and may use `Ctrl`, `Alt`, and `Shift`, such as `Ctrl+q`, `Alt+f`, or `Ctrl+Shift+x`.
- Modified and unmodified bindings are different. Mapping plain `q` does not map `Shift+q`; therefore the shifted key can still insert `Q`.
- Do not map `Escape`; it is reserved for releasing Scratchpad focus.
- Do not reuse the focus hotkey in `keyBindings`; conflicting entries are ignored.

Supported action forms:

```lua
-- Explicitly make a key do nothing.
["b"] = {action = "noop"},

-- Insert any text, including a space or symbol.
["q"] = {action = "insert", text = "1"},

-- Delete backward.
["v"] = {action = "backspace"},

-- Insert a new line.
["r"] = {action = "enter"},

-- Move to the beginning/end of the current line.
["u"] = {action = "line_begin"},
["i"] = {action = "line_end"},

-- Move down/up one line while keeping the current column when possible.
["j"] = {action = "cursor_down"},
["k"] = {action = "cursor_up"},

-- Move down/up one line, then move to that line's end.
["g"] = {action = "cursor_down_line_end"},
["t"] = {action = "cursor_up_line_end"},

-- Move left/right by one character without crossing a line boundary.
["h"] = {action = "cursor_left"},
["l"] = {action = "cursor_right"},
```

### Change the on-screen keypad

Edit `Saved Games\DCS\Scripts\Scratchpad\Extensions\keypad-zyr.lua`.

- Edit `keyMatrix` to change the upper keypad's labels, inserted characters, or order.
- Edit `AlpMatrix` to change the lower alphabetic keyboard.
- Edit `width`, `height`, `kwidth`, and `kheight` to change button sizes.
- A quoted string such as `"N"` displays and inserts the same character.
- A one-item table such as `{["ENT"] = "\n"}` displays the table key (`ENT`) and inserts its value (a newline).
- The `↑` and `↓` entries call `moveCursorUpLineEnd` and `moveCursorDownLineEnd`. Those helper functions are near the top of the same file.

### Change general Scratchpad hotkeys and font size

Edit `Saved Games\DCS\Config\ScratchpadConfig.lua`.

```lua
["hotkey"] = "Ctrl+Alt+`",
["hotkeyPrevPage"] = "Ctrl+Alt+1",
["hotkeyNextPage"] = "Ctrl+Alt+2",
["fontSize"] = 14,
```

- `hotkey` controls show/hide.
- `hotkeyPrevPage` and `hotkeyNextPage` control page navigation.
- `fontSize` controls editor text size.
- `windowPosition` and `windowSize` are normally updated automatically when the window is moved or resized.

### Change page contents

Edit or create `.txt` files in `Saved Games\DCS\Scratchpad\`. Each eligible text file becomes one page the next time Scratchpad loads its page list.

### Files normally left unchanged

Routine customization should not require editing:

- `Saved Games\DCS\Scripts\Hooks\scratchpad-hook.lua`
- `Saved Games\DCS\Scripts\Scratchpad\ScratchpadWindow.dlg`
- `Saved Games\DCS\Scripts\Scratchpad\CrosshairWindow.dlg`

Use `keybindings-zyr.lua`, `keypad-zyr.lua`, and `ScratchpadConfig.lua` for normal DIY changes.

## Troubleshooting

- After editing a Lua file, fully restart DCS.
- Confirm that the Scratchpad editor is focused before testing physical mappings. Use `Ctrl+Alt+3` if necessary.
- Check `Saved Games\DCS\Logs\Scratchpad.log` for extension errors.
- A successful startup should list both `keybindings-zyr.lua` and `keypad-zyr.lua`; the key-binding extension should log that it initialized.
- If a changed Lua file prevents an extension from loading, check table commas, quote pairs, and braces first.
