--- Nearest Stop
local widget = require "widget"

local NearestStop = {}

function NearestStop:setup(x, y, width, height)
	local mainGroup, errorGroup, regularGroup = display.newGroup(), display.newGroup(), display.newGroup()
	local bgRect = display.newRect(mainGroup, x, y, width, height)

	bgRect:setFillColor(0.5, 0.2, 0.8)

	-- regular
	local nearestStopLabel = display.newText(regularGroup, "Ближайшая остановка", x, y - 4, nil, 12)
	local nearestStopNameLabel = display.newText(regularGroup, "Выставочный зал", x, y + 15, native.systemFontBold, 16)
	local tramIcon = display.newImage(regularGroup, "img/tram.png", x, y - 20)

	regularGroup.alpha = 0.0
	local errorMessageLabel = display.newText(errorGroup, "Геолокация не работает", x, y - 4, nil, 12)
	local errorIcon = display.newImage(errorGroup, "img/nogps.png", x, y - 20)
	errorIcon:scale(0.5, 0.5)
	local setStopButton = widget.newButton {
		x = x,
		y = nearestStopNameLabel.y,
		onRelease = setStopButtonPressed,
		label = "● Задать остановку вручную ●",
		labelColor = { default = { 1, 1, 1 }, over = { 0, 0.5, 1 } },
		fontSize = 13,
		onRelease = function ()
			self:switchGroups()
		end
	}
	errorGroup:insert(setStopButton)

	self.regularGroup = regularGroup
	self.errorGroup = errorGroup
	self.group = mainGroup
	self.nearestStopLabel = nearestStopLabel
	self.nearestStopNameLabel = nearestStopNameLabel
	Runtime:addEventListener("location", updateLocation)
end

function updateLocation(event)
	if event.errorCode then
	end
end

function NearestStop:switchGroups()
	local newErrorAlpha = 1.0 - self.errorGroup.alpha
	transition.to(self.errorGroup, {
		alpha = newErrorAlpha,
		time = 400
	})
	transition.to(self.regularGroup, {
		alpha = 1.0 - newErrorAlpha,
		time = 400	
	})
end

return NearestStop