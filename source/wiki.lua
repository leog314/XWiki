-----------------------------------------
-- XWiki - a portable knowledge source --
-- by Leonard Großmann ------------------
-- 3/2/2025 -----------------------------
-----------------------------------------
--- https://github.com/leog314/XWiki ----
-----------------------------------------

-- Using BetterLuaAPI for the TI-Nspire
-- Thanks to adriweb + contributors

platform.apiLevel = "2.0"

local BUILD_NUMBER = "v7/25"
local FPS = 15 -- due to an internal ti bug, will interfere with proper restart under certain conditions

local VERTICAL_ANIMATION_TIME = 0.5

-- fix of TI Bug....

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

function math.round(x)
    return math.floor(x+0.5)
end

function table.Length(t)
    local counter = 0
    for k, v in pairs(t) do
        counter = counter + 1
    end
    return counter
end

function AddToGC(key, func)
    local gcMetatable = platform.withGC(getmetatable)
    gcMetatable[key] = func
end

local function copyTable(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

local function uCol(col)
    return col[1], col[2], col[3]
end

local function uInvertCol(col)
    return 255 - col[1], 255 - col[2], 255 - col[3]
end

local function screenRefresh() return platform.window:invalidate() end
local function pww() return platform.window:width() end
local function pwh() return platform.window:height() end

local function drawCenteredString(gc, str)
    gc:drawString(str, (platform.window:width() - gc:getStringWidth(str)) / 2, platform.window:height() / 2, "middle")
end

local function drawXCenteredString(gc, str, shiftx, y) -- include shiftx
    gc:drawString(str, shiftx + (platform.window:width() - gc:getStringWidth(str)) / 2, y, "top")
end

local function verticalBar(gc, x)
    gc:fillRect(x, 0, 1, platform.window:height())
end

local function horizontalBar(gc, y)
    gc:fillRect(0, y, platform.window:width(), 1)
end

local function drawRoundRect(gc, x, y, wd, ht, rd) -- wd = width, ht = height, rd = radius of the rounded corner
    local x = x - wd / 2 -- let the center of the square be the origin (x coord)
    local y = y - ht / 2 -- same for y coord
    if rd > ht / 2 then rd = ht / 2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max rd)
    gc:drawLine(x + rd, y, x + wd - (rd), y)
    gc:drawArc(x + wd - (rd * 2), y + ht - (rd * 2), rd * 2, rd * 2, 270, 90)
    gc:drawLine(x + wd, y + rd, x + wd, y + ht - (rd))
    gc:drawArc(x + wd - (rd * 2), y, rd * 2, rd * 2, 0, 90)
    gc:drawLine(x + wd - (rd), y + ht, x + rd, y + ht)
    gc:drawArc(x, y, rd * 2, rd * 2, 90, 90)
    gc:drawLine(x, y + ht - (rd), x, y + rd)
    gc:drawArc(x, y + ht - (rd * 2), rd * 2, rd * 2, 180, 90)
end

local function fillRoundRect(gc, x, y, wd, ht, radius) -- wd = width and ht = height -- renders badly when transparency (alpha) is not at maximum >< will re-code later
    if radius > ht / 2 then radius = ht / 2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max radius)
    gc:fillPolygon({ (x - wd / 2), (y - ht / 2 + radius), (x + wd / 2), (y - ht / 2 + radius), (x + wd / 2), (y + ht / 2 - radius), (x - wd / 2), (y + ht / 2 - radius), (x - wd / 2), (y - ht / 2 + radius) })
    gc:fillPolygon({ (x - wd / 2 - radius + 1), (y - ht / 2), (x + wd / 2 - radius + 1), (y - ht / 2), (x + wd / 2 - radius + 1), (y + ht / 2), (x - wd / 2 + radius), (y + ht / 2), (x - wd / 2 + radius), (y - ht / 2) })
    local x = x - wd / 2 -- let the center of the square be the origin (x coord)
    local y = y - ht / 2 -- same
    gc:fillArc(x + wd - (radius * 2), y + ht - (radius * 2), radius * 2, radius * 2, 1, -91)
    gc:fillArc(x + wd - (radius * 2), y, radius * 2, radius * 2, -2, 91)
    gc:fillArc(x, y, radius * 2, radius * 2, 85, 95)
    gc:fillArc(x, y + ht - (radius * 2), radius * 2, radius * 2, 180, 95)
end

-----------------------------------------
------ Adding the functions to gc -------
-----------------------------------------

AddToGC("drawRoundRect", drawRoundRect)
AddToGC("fillRoundRect", fillRoundRect)
AddToGC("verticalBar", verticalBar)
AddToGC("horizontalBar", horizontalBar)
AddToGC("drawCenteredString", drawCenteredString)
AddToGC("drawXCenteredString", drawXCenteredString)

local function inRect(px, py, x, y, dx, dy)
    return (x<=px) and (px<=x+dx) and (y<=py) and (py <= y+dy)
end

-----------------------------------------
-------------- main stuff ---------------
-----------------------------------------

local colors = {} -- dark mode colors are inverted grey scales of light mode
colors["text"] = {10, 10, 10}
colors["placeholder"] = {80, 80, 80}
colors["background"] = {235, 235, 235}
colors["bar-universal"] = {48, 213, 200}
colors["rect"] = {10, 10, 10}
colors["rect-activated"] = {48, 213, 200}
local white_mode = false
-- if white_mode then cursor.set("default") else cursor.set("hollow pointer") end

local images = {}
images["settings-icon-white_mode"] = "\018\000\000\000\018\000\000\000\000\000\000\000\036\000\000\000\016\000\001\000alalal\1401alalalJ\169J\169J\169J\169al\1401al\1401\255\127alalalal\1401J\169J\169\181VJ\169J\169J\169J\169J\169J\169\1401J\169J\169\1401\255\127alal\1401J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169\1401al\1401J\169J\169J\169J\169J\169J\169J\169\181V\181VJ\169J\169J\169J\169J\169J\169J\169\1401alJ\169J\169J\169J\169J\169\1735alalalal\1735J\169J\169J\169J\169J\169alal\1401J\169J\169J\169alalalJ\169J\169alalalJ\169J\169J\169\1401al\1401J\169J\169J\169\1735alJ\169J\169J\169J\169J\169J\169al\181VJ\169J\169J\169\1401J\169J\169J\169J\169alalJ\169J\169alalJ\169J\169al\181VJ\169J\169J\169J\169J\169J\169J\169\1735alJ\169J\169alalalalJ\169J\169al\1735J\169J\169J\169J\169J\169J\169\1735alJ\169J\169alalalalJ\169J\169al\1735J\169J\169J\169J\169J\169J\169J\169alalJ\169J\169alalJ\169J\169alalJ\169J\169J\169J\169\1401J\169J\169J\169\1735alJ\169J\169J\169J\169J\169J\169al\1735J\169J\169J\169\1401al\1401J\169J\169J\169alalalJ\169J\169alalalJ\169J\169J\169\1401alalJ\169J\169J\169J\169J\169\1735alalalal\1735J\169J\169J\169J\169J\169al\1401J\169J\169J\169J\169J\169J\169J\169\1735\1735J\169J\169J\169J\169J\169J\169J\169\1401\1401\1401J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169J\169\1401\255\127al\255\127\1401J\169J\169\1401J\169J\169J\169J\169J\169J\169\1401J\169J\169\1401\255\127alalalal\1401alalalJ\169J\169J\169J\169\1401alal\1401\255\127alal"
images["settings-icon-dark_mode"] = "\018\000\000\000\018\000\000\000\000\000\000\000\036\000\000\000\016\000\001\000alalal\1401alalal\181\214\181\214\181\214\181\214al\1401al\1401\255\127alalalal\1401\181\214\181\214\181V\181\214\181\214\181\214\181\214\181\214\181\214\1401\181\214\181\214\1401\255\127alal\1401\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\1401al\1401\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181V\181V\181\214\181\214\181\214\181\214\181\214\181\214\181\214\1401al\181\214\181\214\181\214\181\214\181\214\1735alalalal\1735\181\214\181\214\181\214\181\214\181\214alal\1401\181\214\181\214\181\214alalal\181\214\181\214alalal\181\214\181\214\181\214\1401al\1401\181\214\181\214\181\214\1735al\181\214\181\214\181\214\181\214\181\214\181\214al\181V\181\214\181\214\181\214\1401\181\214\181\214\181\214\181\214alal\181\214\181\214alal\181\214\181\214al\181V\181\214\181\214\181\214\181\214\181\214\181\214\181\214\1735al\181\214\181\214alalalal\181\214\181\214al\1735\181\214\181\214\181\214\181\214\181\214\181\214\1735al\181\214\181\214alalalal\181\214\181\214al\1735\181\214\181\214\181\214\181\214\181\214\181\214\181\214alal\181\214\181\214alal\181\214\181\214alal\181\214\181\214\181\214\181\214\1401\181\214\181\214\181\214\1735al\181\214\181\214\181\214\181\214\181\214\181\214al\1735\181\214\181\214\181\214\1401al\1401\181\214\181\214\181\214alalal\181\214\181\214alalal\181\214\181\214\181\214\1401alal\181\214\181\214\181\214\181\214\181\214\1735alalalal\1735\181\214\181\214\181\214\181\214\181\214al\1401\181\214\181\214\181\214\181\214\181\214\181\214\181\214\1735\1735\181\214\181\214\181\214\181\214\181\214\181\214\181\214\1401\1401\1401\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\181\214\1401\255\127al\255\127\1401\181\214\181\214\1401\181\214\181\214\181\214\181\214\181\214\181\214\1401\181\214\181\214\1401\255\127alalalal\1401alalal\181\214\181\214\181\214\181\214\1401alal\1401\255\127alal"

local setting_icon = {x=0.98*pww()-18, y=0.09*pwh()-9, size=18}

toolpalette.enableCopy(true)
toolpalette.enablePaste(true)

-- clipping function

local function ClipString(gc, string, size, clip_start)
    local clipped = false
    while gc:getStringWidth(string) > size do
        clipped = true
        if clip_start then
            string = string:sub(2)
        else
            string = string:sub(1, -2)
        end
    end
    if clipped and not clip_start then
        string = string:sub(1, -4) .. "..."
    end
    return string
end

AddToGC("ClipString", ClipString)

-----------------------------------------
-------------- Screen handler -----------
-----------------------------------------

ScreenHandler = class()

function ScreenHandler:init(initialScreen)
    self.currentScreen = {screen=initialScreen, fx=function (t) return 0 end, fy=function (t) return 0 end}
    self.newScreen = nil -- max two screens at a time
end

function ScreenHandler:IsAnimationOver() return (self.animation.time>self.animation.totalTime) end -- nil = forever

function ScreenHandler:step()
    if self.newScreen == nil then
        return
    end

    self.animation.time = self.animation.time + 1/FPS
    if not self:IsAnimationOver() then
        self.currentScreen.screen.shiftx = self.currentScreen.fx(self.animation.time)
        self.currentScreen.screen.shifty = self.currentScreen.fy(self.animation.time)

        self.newScreen.screen.shiftx = self.newScreen.fx(self.animation.time)
        self.newScreen.screen.shifty = self.newScreen.fy(self.animation.time)
    else
        -- destroy
        self.currentScreen.screen.editor = nil -- TI bug?
        self.currentScreen = nil
        collectgarbage()

        self.currentScreen = {screen=self.newScreen.screen, fx=function (t) return 0 end, fy=function (t) return 0 end}
        self.currentScreen.screen.shiftx = 0
        self.currentScreen.screen.shifty = 0 -- correcting for floating point errors

        self.newScreen = nil
        self.animation = nil
        collectgarbage()
    end
end

function ScreenHandler:paint(gc)
    self.currentScreen.screen:paint(gc)
    if self.newScreen~=nil then self.newScreen.screen:paint(gc) end
end

function ScreenHandler:push(screen, direction)
    self.newScreen = {screen=screen, fx=function (t) return 0 end, fy=function (t) return 0 end}
    self.animation = {time=0, totalTime=0}

    if direction=="up" then -- -> push screens up
        self.animation.totalTime = VERTICAL_ANIMATION_TIME
        local delta = pwh()
    
        self.currentScreen.fy = function (t) return -(delta/self.animation.totalTime)*t end
        self.newScreen.fy = function (t) return delta-(delta/self.animation.totalTime)*t end

        self.newScreen.screen.shifty = delta

    elseif direction == "down" then
        self.animation.totalTime = VERTICAL_ANIMATION_TIME
        local delta = pwh()

        self.currentScreen.fy = function (t) return (delta/self.animation.totalTime)*t end
        self.newScreen.fy = function (t) return (delta/self.animation.totalTime)*t-delta end

        self.newScreen.screen.shifty = -delta

    elseif direction == "left" then
        self.animation.totalTime = 4/3 * VERTICAL_ANIMATION_TIME
        local delta = pww()

        self.currentScreen.fx = function (t) return -(delta/self.animation.totalTime)*t end
        self.newScreen.fx = function (t) return delta-(delta/self.animation.totalTime)*t end

        self.newScreen.screen.shiftx = delta

    elseif direction == "right" then
        self.animation.totalTime = 4/3 * VERTICAL_ANIMATION_TIME
        local delta = pww()

        self.currentScreen.fx = function (t) return (delta/self.animation.totalTime) *t end
        self.newScreen.fx = function (t) return (delta/self.animation.totalTime)*t-delta end
    
        self.newScreen.screen.shiftx = -delta
    end
end

function ScreenHandler:mouseDown(x, y)
    if self.newScreen==nil then self.currentScreen.screen:mouseDown(x, y) end
end

function ScreenHandler:charIn(ch)
    if self.newScreen==nil then self.currentScreen.screen:charIn(ch) end
end

function ScreenHandler:backspaceKey()
    if self.newScreen==nil then self.currentScreen.screen:backspaceKey() end
end

function ScreenHandler:clearKey()
    if self.newScreen==nil then self.currentScreen.screen:clearKey() end
end

function ScreenHandler:enterKey()
    if self.newScreen==nil then self.currentScreen.screen:enterKey() end
end

function ScreenHandler:returnKey()
    if self.newScreen==nil then self.currentScreen.screen:returnKey() end
end

function ScreenHandler:arrowKey(key)
    if self.newScreen==nil then self.currentScreen.screen:arrowKey(key) end
end

function ScreenHandler:escapeKey()
    if self.newScreen==nil then self.currentScreen.screen:escapeKey() end
end

function ScreenHandler:help()
    if self.newScreen==nil then self.currentScreen.screen:help() end
end

function ScreenHandler:copy()
    if self.newScreen==nil then self.currentScreen.screen:copy() end
end

function ScreenHandler:paste()
    if self.newScreen==nil then self.currentScreen.screen:paste() end
end


-----------------------------------------
-------------- Screen classes -----------
-----------------------------------------

------------- HomeScreen class ----------

HomeScreen = class()

function HomeScreen:init()
    self.placeholder = "Search XWiki"
    self.search_bar = {text=self.placeholder, x0=0.1*pww(), x1=0.9*pww(), y0=0.2*pwh(), y1=0.3*pwh()}

    self.pointer = 0
    self.articles = {}
    self.article_box_height = 0.1*pwh()

    self.max_entries = 5

    self.shiftx, self.shifty = 0, 0
end

function HomeScreen:paint(gc)
    if white_mode then gc:setColorRGB(uCol(colors["background"])) else gc:setColorRGB(uInvertCol(colors["background"])) end
    gc:fillRect(self.shiftx, self.shifty, pww(), pwh()) -- background

    if white_mode then gc:setColorRGB(uCol({30, 30, 30})) else gc:setColorRGB(uInvertCol({30, 30, 30})) end -- logo
    gc:setFont("sansserif", "b", 24)

    gc:drawXCenteredString("XWiki", self.shiftx, self.shifty)

    local img
    if white_mode then img = image.new(images["settings-icon-white_mode"]) else img = image.new(images["settings-icon-dark_mode"]) end

    gc:drawImage(img, self.shiftx + setting_icon.x, self.shifty + setting_icon.y)

    gc:setColorRGB(uCol(colors["bar-universal"]))
    gc:horizontalBar(self.shifty + self.search_bar.y0-0.02*pwh())

    if self.pointer ~= 0 then
        if white_mode then gc:setColorRGB(uCol(colors["rect"])) else gc:setColorRGB(uInvertCol(colors["rect"])) end -- search_bar
    else
        gc:setColorRGB(uCol(colors["rect-activated"]))
    end

    gc:drawRect(self.shiftx + self.search_bar.x0, self.shifty + self.search_bar.y0, self.search_bar.x1-self.search_bar.x0, self.search_bar.y1-self.search_bar.y0)

    if self.search_bar.text == self.placeholder then -- editor content
        if white_mode then gc:setColorRGB(uCol(colors["placeholder"])) else gc:setColorRGB(uInvertCol(colors["placeholder"])) end
    else
        if white_mode then gc:setColorRGB(uCol(colors["text"])) else gc:setColorRGB(uInvertCol(colors["text"])) end
    end

    gc:setFont("sansserif", "r", 11)
    gc:drawString(gc:ClipString(self.search_bar.text, self.search_bar.x1-self.search_bar.x0-0.02*pww(), true),
    self.shiftx + self.search_bar.x0+0.01*pww(), self.shifty + self.search_bar.y0+(self.search_bar.y1-self.search_bar.y0)/2, "middle")

    local y = math.round(self.search_bar.y1)
    for i=1, #self.articles do
        local keyword = self.articles[i]
        if keyword ~= nil then
            if self.pointer ~= i then
                if white_mode then gc:setColorRGB(uCol(colors["rect"])) else gc:setColorRGB(uInvertCol(colors["rect"])) end -- search_bar
            else
                gc:setColorRGB(uCol(colors["rect-activated"]))
            end

            gc:drawRect(self.shiftx + self.search_bar.x0, self.shifty + y, self.search_bar.x1-self.search_bar.x0, math.round(self.article_box_height)-1)

            gc:setFont("sansserif", "b", 12)
            if white_mode then gc:setColorRGB(uCol(colors["text"])) else gc:setColorRGB(uInvertCol(colors["text"])) end

            gc:drawString(gc:ClipString(keyword, self.search_bar.x1-self.search_bar.x0-0.02*pww(), false),
            self.shiftx + self.search_bar.x0+0.01*pww(), self.shifty + y + self.article_box_height/2, "middle")

            y = y+math.round(self.article_box_height)
        end
    end

    gc:setColorRGB(uCol(colors["bar-universal"]))
    gc:horizontalBar(self.shifty + 0.92*pwh())

    gc:setFont("serif", "i", 7)
    if white_mode then gc:setColorRGB(uCol(colors["placeholder"])) else gc:setColorRGB(uInvertCol(colors["placeholder"])) end

    gc:drawXCenteredString("by Leonard Großmann (2025)", self.shiftx, self.shifty + 0.95*pwh())

    gc:drawString(BUILD_NUMBER, self.shiftx + 0.02*pww(), self.shifty + 0.95*pwh(), "top")
end

function HomeScreen:updateSearch()
    if self.search_bar.text ~= self.placeholder then
        local new_articles={}

        for key,_ in pairs(database) do
            if string.find(string.lower(key), string.lower(self.search_bar.text), 1, true) then -- content is substring of key?
                if #new_articles < self.max_entries then -- table still not full
                    table.insert(new_articles, key)
                else
                    for i=1, self.max_entries do
                        if #key < #new_articles[i] then -- prefer shorter keywords
                            new_articles[i] = key
                            break
                        end
                    end
                end
            end
        end

        -- if database[self.search_bar.text] ~= nil then table.insert(new_articles, self.search_bar.text) end

        self.articles = copyTable(new_articles)
    else
        self.articles = {}
    end
end

function HomeScreen:mouseDown(x, y)
    if x==0 and y==0 then -- is cursor not visible?
        self:enterKey()
    elseif (setting_icon.x<=x and x<=setting_icon.x+setting_icon.size) and (setting_icon.y<=y and y<=setting_icon.y+setting_icon.size) then
        Handler:push(HelpScreen(), "down")
    else
        for i=1, #self.articles do
            if inRect(x, y, self.search_bar.x0, self.search_bar.y1+(i-1)*self.article_box_height, self.search_bar.x1-self.search_bar.x0, self.article_box_height) then
                self.pointer = i
                self:enterKey()
            end
        end
    end
end

function HomeScreen:charIn(ch)
    if self.search_bar.text ~= self.placeholder then
        self.search_bar.text = self.search_bar.text .. ch
    else
        self.search_bar.text = ch
    end
    self:updateSearch()
end

function HomeScreen:backspaceKey()
    if self.search_bar.text ~= self.placeholder and self.search_bar.text ~= "" then
        self.search_bar.text = self.search_bar.text:sub(1, #self.search_bar.text-1)
    end
    if self.search_bar.text == "" then
        self.search_bar.text = self.placeholder
    end
    self:updateSearch()
end

function HomeScreen:clearKey()
    self.search_bar.text = self.placeholder
    self:updateSearch()
end

function HomeScreen:enterKey()
    if #self.articles ~= 0 then
        if self.pointer ~= 0 then
            Handler:push(ReadScreen(self.articles[self.pointer]), "left")
        else
            if database[self.search_bar.text] ~= nil then
                Handler:push(ReadScreen(self.search_bar.text), "left")
            else
                Handler:push(ReadScreen(self.articles[1]), "left")
            end
        end
    end
    self.search_bar.text = self.placeholder -- +redirect
end

function HomeScreen:returnKey()
    local randIndex = math.round((table.Length(database)-1)*math.random())+1
    local counter = 0
  
    for key, _ in pairs(database) do
        counter = counter + 1
        if counter == randIndex then
            Handler:push(ReadScreen(key), "left")
            break
        end
    end
end

function HomeScreen:arrowKey(key)
    if key == "up" then
        self.pointer = (self.pointer-1) % (#self.articles+1)
    end
    if key == "down" then
        self.pointer = (self.pointer+1) % (#self.articles+1)

    end
end

function HomeScreen:escapeKey()
    self.pointer = 0
end

function HomeScreen:help()
    Handler:push(HelpScreen(), "down")
end

function HomeScreen:copy()
    return
end

function HomeScreen:paste()
    if self.search_bar.text ~= self.placeholder then self.search_bar.text = self.search_bar.text .. clipboard.getText() else self.search_bar.text=clipboard.getText() end
    self:updateSearch()
end

----------- "TextScreen" class ----------

ReadScreen = class()

function ReadScreen:init(keyword)
    self.keyword = keyword

    self.editor_params = {x0=0.1*pww(), y0=0.2*pwh(), x1=0.9*pww(), y1=0.9*pwh()}
    self.editor = D2Editor:newRichText():move(self.editor_params.x0, self.editor_params.y0):
    resize(self.editor_params.x1-self.editor_params.x0, self.editor_params.y1-self.editor_params.y0):
    setColorable(true):setMainFont("sansserif", "r"):setFontSize(9):setReadOnly(true):setBorder(2):
    setBorderColor(0x30d5c8):setFocus(true)
    -- use D2Editor now cause it actually makes sense =)

    self.editor:setTextColor(0x0a0a0a) -- no if here, because can not change background color of D2Editor -> ~Thanks TI :)

    local acknowledge_message = '\n\n---- License and Acknowledgement\n\n' ..
    'This article is based on content from Wikipedia and is licensed under the Creative Commons Attribution-ShareAlike License (CC BY-SA 3.0).\n' ..
    'The original article was written by Wikipedia contributors and can be found at the following URL:\n' ..
    '\t\t' .. database[self.keyword].url .. '\n' ..
    'Modifications may have been made by the author of this app. The full license text is available at:\n' ..
    '\t\thttps://creativecommons.org/licenses/by-sa/3.0/'


    self.editor:setText(database[self.keyword].content .. acknowledge_message, 0)

    self.editor:registerFilter {
        enterKey = function()
            self.editor:setFocus(not self.editor:hasFocus())
            return true
        end,
     }

    self.shiftx, self.shifty = 0, 0
end

function ReadScreen:paint(gc)
    if white_mode then gc:setColorRGB(uCol(colors["background"])) else gc:setColorRGB(uInvertCol(colors["background"])) end
    gc:fillRect(self.shiftx, self.shifty, pww(), pwh()) -- background

    if white_mode then gc:setColorRGB(uCol({30, 30, 30})) else gc:setColorRGB(uInvertCol({30, 30, 30})) end -- logo
    gc:setFont("sansserif", "i", 12)

    gc:drawXCenteredString(gc:ClipString(self.keyword, 0.7*pww(), false), self.shiftx, self.shifty + self.editor_params.y0/2-gc:getStringHeight(self.keyword)/2)

    local img
    if white_mode then img = image.new(images["settings-icon-white_mode"]) else img = image.new(images["settings-icon-dark_mode"]) end

    gc:drawImage(img, self.shiftx + setting_icon.x, self.shifty + setting_icon.y)

    gc:setColorRGB(uCol(colors["bar-universal"]))
    gc:horizontalBar(self.shifty + self.editor_params.y0-0.02*pwh())

    self.editor:move(self.editor_params.x0 + self.shiftx, self.editor_params.y0 + self.shifty)

    gc:setColorRGB(uCol(colors["bar-universal"]))
    gc:horizontalBar(self.shifty + self.editor_params.y1+0.02*pwh())

    gc:setFont("serif", "i", 7)
    if white_mode then gc:setColorRGB(uCol(colors["placeholder"])) else gc:setColorRGB(uInvertCol(colors["placeholder"])) end

    gc:drawXCenteredString("by Leonard Großmann (2025)", self.shiftx, self.shifty + 0.95*pwh())

    gc:drawString(BUILD_NUMBER, self.shiftx + 0.02*pww(), self.shifty + 0.95*pwh(), "top")
end

function ReadScreen:mouseDown(x, y)
    if (setting_icon.x<=x and x<=setting_icon.x+setting_icon.size) and (setting_icon.y<=y and y<=setting_icon.y+setting_icon.size) then
        -- self.editor = nil
        -- collectgarbage()
        Handler:push(HelpScreen(), "down")
    end
end

function ReadScreen:charIn(ch)
    return
end

function ReadScreen:backspaceKey()
    return
end

function ReadScreen:clearKey()
    return
end

function ReadScreen:enterKey()
    return
end

function ReadScreen:returnKey()
    return
end

function ReadScreen:arrowKey(key)
    return
end

function ReadScreen:escapeKey()
    -- self.editor = nil
    -- collectgarbage()
    Handler:push(HomeScreen(), "right")
end

function ReadScreen:help()
    Handler:push(HelpScreen(), "down")
end

function ReadScreen:copy()
    local string, pos, sel, error = self.editor:getExpressionSelection()
    clipboard.addText(string:sub(sel, pos))
end

function ReadScreen:paste()
    return
end

-- Help Screen

HelpScreen = class()

function HelpScreen:init()
    self.editor_params = {x0=0.1*pww(), y0=0.2*pwh(), x1=0.9*pww(), y1=0.9*pwh()}

    self.editor = D2Editor:newRichText():move(self.editor_params.x0, self.editor_params.y0):
    resize(self.editor_params.x1-self.editor_params.x0, self.editor_params.y1-self.editor_params.y0):
    setColorable(true):setMainFont("sansserif", "r"):setFontSize(9):setReadOnly(true):setBorder(2):
    setBorderColor(0x30d5c8):setFocus(true)

    self.editor:setTextColor(0x0a0a0a)

    local general_license_ack = '\n\n---- Licensing and Attribution Notice\n\n' ..
    'This app uses content from Wikipedia, which is available under the Creative Commons Attribution-ShareAlike 3.0 License (CC BY-SA 3.0).\n' ..
    'Some summaries and text shown in this app are based on original Wikipedia articles and may have been edited or condensed by the app author.\n' ..
    'By using this app, you acknowledge that:\n' ..
    '\t-The original content was created by Wikipedia contributors.\n' ..
    '\t-Modifications may have been made to adapt the content.\n' ..
    '\t-The full license is available at: https://creativecommons.org/licenses/by-sa/3.0/\n' ..
    '\t-You can access the original articles and their edit history via the source links provided with each summary.\n\n' ..
    'Wikipedia® is a trademark of the Wikimedia Foundation. This app is not affiliated with or endorsed by the Wikimedia Foundation.\n\n'..
    "This project used 'Better Lua Api' by adriweb + contributors and Luna by Vogtinator + contributors."

    self.editor:setText(
    "XWiki is a portable knowledge source for the TI-Nspire calculator series created by Leonard Großmann (2025).\n"..
    "To search for something use the keypad for typing in the article name. After that press <enter> or use the handheld's cursor to select an article.\n"..
    "You will be redirected to the article, if it's available, otherwise the most promissing page will open.\n" ..
    "By pressing the <return> key you get redirected to a randomly chosen article.\n"..
    "Any page consists of a text editor, where you can read the content of the article. Usually the content is a five sentence summary of the Wikipedia article.\n"..
    "Switch back to the homescreen by pressing <esc>.\n"..
    "You can change the background color (=switch to dark/light mode) using <tab>.\n"..
    "Characters (in the search bar) can be deleted using <del> (deletes last char) or <clear> (clears the search bar).\n"..
    "If you have any further questions/suggestions take a look on the Github repository:\n"..
    "\t\thttps://github.com/leog314/XWiki\n"..
    "Note: I am aware that not everything might work as expected, work is still in progress. I hope that the app reacts fine anyway. :)\n"..
    "The project is open source, you can load your own articles and modify the GUI, if you want to. Please just mention this project, if you do so.\n"..
    "Anyway, I am not in any means responsible for the contents of this wiki nor of its modifications. While disgusting content should have been filtered out to some degree, this isn't guaranteed. You use the app at your own risk!"..
    general_license_ack, 0
)
    self.editor:registerFilter {
        enterKey = function()
            self.editor:setFocus(not self.editor:hasFocus())
            return true
        end,
    }

    self.shiftx, self.shifty = 0, 0
end

function HelpScreen:paint(gc)
    if white_mode then gc:setColorRGB(uCol(colors["background"])) else gc:setColorRGB(uInvertCol(colors["background"])) end
    gc:fillRect(0, 0, self.shiftx + pww(), self.shifty + pwh()) -- background

    if white_mode then gc:setColorRGB(uCol({30, 30, 30})) else gc:setColorRGB(uInvertCol({30, 30, 30})) end
    gc:setFont("sansserif", "b", 12)

    gc:drawXCenteredString("Controls and Help", self.shiftx, self.shifty + self.editor_params.y0/2-gc:getStringHeight("Controls and Help")/2)

    local img
    if white_mode then img = image.new(images["settings-icon-white_mode"]) else img = image.new(images["settings-icon-dark_mode"]) end

    gc:drawImage(img, self.shiftx + setting_icon.x, self.shifty + setting_icon.y)

    gc:setColorRGB(uCol(colors["bar-universal"]))
    gc:horizontalBar(self.shifty + self.editor_params.y0-0.02*pwh())

    self.editor:move(self.editor_params.x0 + self.shiftx, self.editor_params.y0 + self.shifty)

    gc:setColorRGB(uCol(colors["bar-universal"]))
    gc:horizontalBar(self.shifty + self.editor_params.y1+0.02*pwh())

    gc:setFont("serif", "i", 7)
    if white_mode then gc:setColorRGB(uCol(colors["placeholder"])) else gc:setColorRGB(uInvertCol(colors["placeholder"])) end

    gc:drawXCenteredString("by Leonard Großmann (2025)", self.shiftx, self.shifty + 0.95*pwh())

    gc:drawString(BUILD_NUMBER, self.shiftx + 0.02*pww(), self.shifty + 0.95*pwh(), "top")
end

function HelpScreen:mouseDown(x, y)
    return
end

function HelpScreen:charIn(ch)
    return
end

function HelpScreen:backspaceKey()
    return
end

function HelpScreen:clearKey()
    return
end

function HelpScreen:enterKey()
    return
end

function HelpScreen:returnKey()
    return
end

function HelpScreen:arrowKey(key)
    return
end

function HelpScreen:escapeKey()
    Handler:push(HomeScreen(), "up")
end

function HelpScreen:help()
    return
end

function HelpScreen:copy()
    local string, pos, sel, error = self.editor:getExpressionSelection()
    clipboard.addText(string:sub(sel, pos))
end

function HelpScreen:paste()
    return
end

-- global stuff

function on.activate()
    timer.start(1/FPS)
end

function on.construction()
    Handler = ScreenHandler(HomeScreen())
end

function on.paint(gc)
    Handler:paint(gc)
end

function on.timer()
    Handler:step()
    screenRefresh()
end

function on.tabKey()
    white_mode = not white_mode
    -- if white_mode then cursor.set("default") else cursor.set("hollow pointer") end
end

function on.mouseDown(x, y)
    Handler:mouseDown(x, y)
end

function on.charIn(ch)
    Handler:charIn(ch)
end

function on.backspaceKey()
    Handler:backspaceKey()
end

function on.clearKey()
    Handler:clearKey()
end

function on.enterKey()
    Handler:enterKey()
end

function on.returnKey()
    Handler:returnKey()
end

function on.arrowKey(key)
    Handler:arrowKey(key)
end

function on.escapeKey()
    Handler:escapeKey()
end

function on.help()
    Handler:help()
end

function on.copy()
    Handler:copy()
end

function on.paste()
    Handler:paste()
end