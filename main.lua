-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require "composer"
local Colors = require "Colors"

-- local buttonPadding = 5
-- local image1 = display.newImageRect("img/gps.png")
-- image1.x = display.contentCenterX
-- image1.y = 50

-- -- local image2 = display.newI

-- local systemFonts = native.getFontNames()

-- -- Set the string to query for (part of the font name to locate)
-- local searchString = "pt"

-- -- Display each font in the Terminal/console
-- for i, fontName in ipairs( systemFonts ) do

--     local j, k = string.find( string.lower(fontName), string.lower(searchString) )

--     if ( j ~= nil ) then
--         print( "Font Name = " .. tostring( fontName ) )
--     end
-- end

-- print(Colors.LABEL_BLACK)
composer.gotoScene("scheduleScene", {
		effect = "fade",
		time = 300
	})