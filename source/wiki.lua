-----------------------------------------
-- XWiki - a portable knowledge source --
-- by Leonard Großmann ------------------
-- 3/2/2025 -----------------------------
-----------------------------------------

-- Using BetterLuaAPI for the TI-Nspire
-- Thanks to adriweb + contributors

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

local function drawXCenteredString(gc, str, y)
    gc:drawString(str, (platform.window:width() - gc:getStringWidth(str)) / 2, y, "top")
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

-----------------------------------------
-------------- main stuff ---------------
-----------------------------------------

local colors = {} -- dark mode colors are inverted grey scales of light mode
colors["text"] = {10, 10, 10}
colors["placeholder"] = {60, 60, 60}
colors["background"] = {235, 235, 235}
colors["bar-universal"] = {48, 213, 200}
colors["rect"] = {10, 10, 10}
colors["rect-activated"] = {48, 213, 200}
local white_mode = true


-----------------------------------------
-------------- Screen classes -----------
-----------------------------------------

HomeScreen = class()

function HomeScreen:init()
    self.placeholder = "Search XWiki"
    self.search_bar = {text=self.placeholder, x0=0.1*pww(), x1=0.9*pww(), y0=0.2*pwh(), y1=0.3*pwh()}

    self.pointer = 0
    self.articles = {}
    self.article_box_height = 0.1*pwh()

    self.max_entries = 5
end

function HomeScreen:paint(gc)
    if white_mode then gc:setColorRGB(uCol(colors["background"])) else gc:setColorRGB(uInvertCol(colors["background"])) end
    gc:fillRect(0, 0, pww(), pwh()) -- background

    if white_mode then gc:setColorRGB(uCol({30, 30, 30})) else gc:setColorRGB(uInvertCol({30, 30, 30})) end -- logo
    gc:setFont("sansserif", "b", 24)

    gc:drawXCenteredString("XWiki", 0)

    gc:setColorRGB(uCol(colors["bar-universal"]))
    gc:horizontalBar(self.search_bar.y0-0.02*pwh())

    if self.pointer ~= 0 then
        if white_mode then gc:setColorRGB(uCol(colors["rect"])) else gc:setColorRGB(uInvertCol(colors["rect"])) end -- search_bar
    else
        gc:setColorRGB(uCol(colors["rect-activated"]))
    end

    gc:drawRect(self.search_bar.x0, self.search_bar.y0, self.search_bar.x1-self.search_bar.x0, self.search_bar.y1-self.search_bar.y0)

    if self.search_bar.text == self.placeholder then -- editor content
        if white_mode then gc:setColorRGB(uCol(colors["placeholder"])) else gc:setColorRGB(uInvertCol(colors["placeholder"])) end
    else
        if white_mode then gc:setColorRGB(uCol(colors["text"])) else gc:setColorRGB(uInvertCol(colors["text"])) end
    end
    gc:setFont("sansserif", "r", 11)
    gc:drawString(self.search_bar.text, self.search_bar.x0+0.01*pww(), self.search_bar.y0+(self.search_bar.y1-self.search_bar.y0)/2, "middle")

    local y = self.search_bar.y1+1
    for i=1, #self.articles do
        local keyword = self.articles[i]
        if keyword ~= nil then
            if self.pointer ~= i then
                if white_mode then gc:setColorRGB(uCol(colors["rect"])) else gc:setColorRGB(uInvertCol(colors["rect"])) end -- search_bar
            else
                gc:setColorRGB(uCol(colors["rect-activated"]))
            end

            gc:drawRect(self.search_bar.x0, y, self.search_bar.x1-self.search_bar.x0, self.article_box_height)

            gc:setFont("sansserif", "b", 12)
            if white_mode then gc:setColorRGB(uCol(colors["text"])) else gc:setColorRGB(uInvertCol(colors["text"])) end
            gc:drawString(keyword, self.search_bar.x0+0.01*pww(), y+self.article_box_height/2, "middle")

            y = y+self.article_box_height+1
        end
    end

    gc:setColorRGB(uCol(colors["bar-universal"]))
    gc:horizontalBar(0.92*pwh())

    gc:setFont("serif", "i", 7)
    if white_mode then gc:setColorRGB(uCol(colors["placeholder"])) else gc:setColorRGB(uInvertCol(colors["placeholder"])) end

    gc:drawXCenteredString("by Leonard Großmann (2025)", 0.95*pwh())
end

function HomeScreen:updateSearch()
    if self.search_bar.text ~= self.placeholder then
        local new_articles={}
        for key,_ in pairs(database) do
            if #new_articles == self.max_entries then
                break
            end
            if string.find(string.lower(key), string.lower(self.search_bar.text)) then
                table.insert(new_articles, key) -- :gsub("_", " ")[1])
            end
        end

        self.articles = copyTable(new_articles)
    else
        self.articles = {}
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
    self.search_bar.text = self.placeholder -- +redirect
end

function HomeScreen:arrowKey(key)
    if key == "up" then
        self.pointer = (self.pointer-1) % (#self.articles+1)
    end
    if key == "down" then
        self.pointer = (self.pointer+1) % (#self.articles+1)

    end
end

-- global stuff

local current_screen = HomeScreen()

function on.paint(gc)
    current_screen:paint(gc)
end

function on.timer()
    screenRefresh()
end

function on.tabKey()
    white_mode = not white_mode
end

function on.charIn(ch)
    current_screen:charIn(ch)
end

function on.backspaceKey()
    current_screen:backspaceKey()
end

function on.clearKey()
    current_screen:clearKey()
end

function on.enterKey()
    current_screen:enterKey()
end

function on.arrowKey(key)
    current_screen:arrowKey(key)
end

timer.start(1/100)