-- A minimal keypad meant for coordinate input

-- local keyMatrix = {
--  { "1", "2", "3", {["␣"] = " "}, {["ENT"] = "\n"}, "N", "S" },
--  { "4", "5", "6", "0", "EMPTY", "W", "E" },
--  { "7", "8", "9", "⌫", "-", ".", "'" }, -- "\""
-- }
-- local width = 30
-- local height = 30

local keyMatrix = {
  { "1", "2", "3", {["ENT"] = "\n"}, "a", {["␣"] = " "}, "N", "S" },
  { "4", "5", "6", "0", "b", ".", "W", "E" },
  { "7", "8", "9", "⌫", "c", "'", "-", "+" }, -- "\""
 }

local width = 40
local height = 40
local entheight = 80

local y = 0
for _, r in pairs(keyMatrix) do
  local x = 0
  for k, v in pairs(r) do
    local title = v
    local char = v
    if type(v) == "table" then
      title, char = pairs(v)(v)
    end

    local onClick = function(text)
      text:insert(char)
    end
    if v == "⌫" then
      onClick = function(text)
        text:deleteBackward()
      end
    end
	  if v == "CLR" then
      onClick = function(text)
        text:setText("")
      end
    end

    local w = width
    local h = height

    -- if title == "ENT" then
    --   h = entheight
    -- end

    if title ~= "EMPTY" then 
      addButton(x, y, w, h, title, onClick)
    end
    x = x + width
  end
  y = y + height
end

local AlpMatrix = {
  { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" },
  { "A", "S", "D", "F", "G", "H", "J", "K", "L" },
  { "Z", "X", "C", "V", "B", "N", "M" },
}

local kwidth = 30
local kheight = 30
local dis = 10
local i = 0

local yy = y
for _, r in pairs(AlpMatrix) do
  local xx = 0 + i * dis
  i = i + 1
  for k, v in pairs(r) do
    local title = v
    local char = v
    if type(v) == "table" then
      title, char = pairs(v)(v)
    end

    local onClick = function(text)
      text:insert(char)
    end
    
    addButton(xx, yy, kwidth, kheight, title, onClick)
    xx = xx + kwidth
  end
  yy = yy + kheight
end