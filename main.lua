-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require "composer"
local Colors = require "Colors"

print(Colors.LABEL_BLACK)
composer.gotoScene("scheduleScene", {
		effect = "fade",
		time = 300
	})