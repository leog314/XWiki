-----------------------------------------
-- XWiki - a portable knowledge source --
-- by Leonard Großmann ------------------
-- 12/10/2025 ---------------------------
-----------------------------------------
--- https://github.com/leog314/XWiki ----
-----------------------------------------

-----------------------------------------
-- floa - a flowy, modern lua extension -
--> just for XWiki: maybe gets released some time in the future as official extension
-----------------------------------------

-- fix of TI bug...
local tstart = timer.start
function timer.start(ms)
    if not timer.isRunning then
        tstart(ms)
    end
    timer.isRunning = true
end

local tstop = timer.stop
function timer.stop()
    timer.isRunning = false
    tstop()
end

-- some more useful stuff...

function math.round(x)
    return math.floor(x + 0.5)
end

function table.Length(t)
    local counter = 0
    for k, v in pairs(t) do
        counter = counter + 1
    end
    return counter
end

function table.Copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

-- mainly by Adriweb (BetterLuaApi) with some rewrites...

function AddToGC(key, func)
    local gcMetatable = platform.withGC(getmetatable)
    gcMetatable[key] = func
end

local function screenRefresh() return platform.window:invalidate() end
local function pww() return platform.window:width() end
local function pwh() return platform.window:height() end


local function drawXCenteredString(gc, str, shiftx, y) -- include shiftx
    gc:drawString(str, shiftx + (platform.window:width() - gc:getStringWidth(str)) / 2, y, "top")
end

local function verticalBar(gc, x)
    gc:fillRect(x, 0, 1, platform.window:height())
end

local function horizontalBar(gc, y)
    gc:fillRect(0, y, platform.window:width(), 1)
end

local function fillRoundRect(gc, x, y, wd, ht, rd) -- only fillRect included -> rewritten
    if radius > ht / 2 then radius = ht / 2 end
    gc:fillRect(x, y + rd, wd, ht)

    gc:fillRect(x + rd, y, wd - 2 * rd, rd)
    gc:fillRect(x + rd, y + ht - rd, wd - 2 * rd, rd)

    gc:fillArc(x, y, rd, rd, 90, 90)                      -- upper left circle
    gc:fillArc(x + wd - rd, y, rd, rd, 0, 90)             -- upper right circle
    gc:fillArc(x, y + ht - rd, rd, rd, 180, 90)           -- lower left circle
    gc:fillArc(x + wd - rd, y + ht - rd, rd, rd, 270, 90) -- lower rigth circle
end

-----------------------------------------
------ Adding the functions to gc -------
-----------------------------------------

AddToGC("fillRoundRect", fillRoundRect)
AddToGC("verticalBar", verticalBar)
AddToGC("horizontalBar", horizontalBar)
AddToGC("drawXCenteredString", drawXCenteredString)

-----------------------------------------
-- some more input handling...
local function inRect(px, py, x, y, dx, dy)
    return (x <= px) and (px <= x + dx) and (y <= py) and (py <= y + dy)
end

-----------------------------------------
------------ Color extension ------------
-----------------------------------------

RGB = class()

function RGB:init(r, g, b)
    self.red = r
    self.green = g
    self.blue = b
end

function RGB:uCol()
    return self.red, self.green, self.blue
end

local function setRGB(gc, rgb)
    gc:setColorRGB(rgb:uCol())
end

AddToGC("setRGB", setRGB)

-----------------------------------------
-------------- Color array --------------
-----------------------------------------

Color = {
    ["black"] = RGB(0, 0, 0),
    ["red"] = RGB(255, 0, 0),
    ["green"] = RGB(0, 255, 0),
    ["blue "] = RGB(0, 0, 255),
    ["white"] = RGB(255, 255, 255),
    ["brown"] = RGB(165, 42, 42),
    ["cyan"] = RGB(0, 255, 255),
    ["darkblue"] = RGB(0, 0, 139),
    ["darkred"] = RGB(139, 0, 0),
    ["fuchsia"] = RGB(255, 0, 255),
    ["gold"] = RGB(255, 215, 0),
    ["gray"] = RGB(127, 127, 127),
    ["grey"] = RGB(127, 127, 127),
    ["lightblue"] = RGB(173, 216, 230),
    ["lightgreen"] = RGB(144, 238, 144),
    ["magenta"] = RGB(255, 0, 255),
    ["maroon"] = RGB(128, 0, 0),
    ["navyblue"] = RGB(159, 175, 223),
    ["orange"] = RGB(255, 165, 0),
    ["palegreen"] = RGB(152, 251, 152),
    ["pink"] = RGB(255, 192, 203),
    ["purple"] = RGB(128, 0, 128),
    ["royalblue"] = RGB(65, 105, 225),
    ["salmon"] = RGB(250, 128, 114),
    ["seagreen"] = RGB(46, 139, 87),
    ["silver"] = RGB(192, 192, 192),
    ["turquoise"] = RGB(64, 224, 208),
    ["violet"] = RGB(238, 130, 238),
    ["yellow"] = RGB(255, 255, 0),
}

-----------------------------------------
------------ Actual Floa GUI ------------
-----------------------------------------

Button = class()

function Button:init(text, x, y, margin, radius, wd, ht, text_color, text_alignment, background_color, border_color,
                     border_thickness)
    self.text = text

    local GetParameters = function(str, gc) return gc:getStringWidth(str), gc:getStringHeight(str) end
    self.text_wd, self.text_ht = platform.withGC(GetParameters, self.text)

    self.x, self.y = x,
        y                 -- upper left corner of the corresponding rectangle

    if margin ~= nil then self.margin = margin else self.margin = 2 end
    if wd ~= nil then self.wd = wd else self.wd = self.text_wd + 2 * self.margin end                             -- width -> default: text width + small margin declared above
    if ht ~= nil then self.ht = ht else self.ht = self.text_ht + 2 * self.margin end                             -- height -> default: text height + small margin declared above

    if radius ~= nil then self.rd = radius else self.rd = 0 end                                                  -- default: rectangular button

    if text_color ~= nil then self.text_color = text_color else self.text_color = RGB(0, 0, 0) end               -- default: black
    if text_alignment == "left" then self.text_almt = "left" else self.text_almt = "center" end                  -- possible values: "left" or "center", default: "center"
    if background_color ~= nil then self.bg_color = background_color else self.bg_color = RGB(255, 255, 255) end -- default: white

    self.borderless = (border_color == nil or border_thickness == nil)                                           -- both values need to be set in order to have a border
    if not self.borderless then
        self.border_color =
        border_color                                                                                             -- default value: borderless
        self.border_th =
        border_thickness                                                                                         -- default value: 0
    else
        self.border_th = 0
    end
end

function Button:paint(gc)
    if not borderless then
        gc:setRGB(self.border_color)
        gc:fillRoundRect(self.x, self.y, self.wd + 2 * self.border_th, self.hd + 2 * self.border_th, self.rd)
    end
    gc:setRGB(self.bg_color)
    gc:fillRoundRect(self.x + self.border_th, self.y + self.border_th, self.wd, self.ht, self.rd)

    gc:setRGB(self.text_color)
    if self.text_almt == "left" then
        gc:drawString(self.text, self.x + self.border_th + self.margin, self.y + self.border_th + self.margin, "middle")
    else
        gc:drawString(self.text, self.x - self.text_wd / 2, self.y, "middle")
    end
end
