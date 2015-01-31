--- Nearest Stop
local widget = require "widget"

local NearestStop = {
	autoDetection = true,
	currentStop = nil
}

local metrics
local layers = {}

function setupMetrics(x, y, width, height)
	metrics = {
		x = x,
		y = y,
		w = width,
		h = height,
		left = x - width / 2,
		right = x + width / 2,
		top = y - height / 2,
		bottom = y + height / 2
	}
end

function createWaitGeoInfoLayer(alpha)
	local waitGeoInfo = display.newGroup()
	local waitLabel = display.newText(waitGeoInfo, "Ищем ближайшую остановку...", metrics.x, metrics.y + 5, nil, 12, "right")
	-- waitLabel.align = "center"
	local gpsIcon = display.newImage(waitGeoInfo, "img/gps.png", metrics.x, metrics.top + 20)
	gpsIcon:scale(0.5, 0.5)

	waitGeoInfo.icon = gpsIcon
	waitGeoInfo.alpha = alpha
	layers.waitGeoInfo = waitGeoInfo

	waitGeoInfo.show = function ()
		function animationCycle()
			local sc = 0.7
			transition.to(gpsIcon, {
				time = 400,
				tag = "icon_rotation1",
				rotation = 181,
				xScale = sc,
				yScale = sc
			})
			transition.to(gpsIcon, {
				time = 400,
				tag = "icon_rotation2",
				rotation = 360,
				xScale = 0.5,
				yScale = 0.5,
				delay = 800
			})
		end
		timer.performWithDelay(1600, animationCycle, 0)
	end
	return waitGeoInfo
end

function createStopDetectedLayer(alpha)
	local stopDetected = display.newGroup()
	local stopNameLabel = display.newText(stopDetected, "Выставочный зал", metrics.x, metrics.y, native.systemFontBold, 15)
	local gpsIcon = display.newImage(stopDetected, "img/gps_green.png", metrics.x, metrics.top + 20)
	gpsIcon:scale(0.5, 0.5)

	stopDetected.label = stopNameLabel
	stopDetected.alpha = alpha
	layers.stopDetected = stopDetected
	return stopDetected
end

function createGotErrorLayer(alpha)
	local gotError = display.newGroup()
	display.newImage(gotError, "img/gps_red.png", metrics.x, metrics.top + 20):scale(0.5, 0.5)
	display.newText(gotError, "Ошибка геолокации", metrics.x, metrics.y + 10, native.systemFont, 13)
	gotError.alpha = alpha
	layers.gotError = gotError
	return gotError
end

function NearestStop:transitionToLayer(layer)
	local trTime = 400
	if self.currentLayer then
		if self.currentLayer.hide then
			self.currentLayer.hide()
		end
		transition.to(self.currentLayer, {
			alpha = 0.0,
			time = 400	
		})
	end

	transition.to(layer, {
		alpha = 1.0,
		time = trTime,
		onComplete = layer.show
	})
	self.currentLayer = layer
end


function NearestStop:setup(x, y, width, height)
	setupMetrics(x, y, width, height)
	local mainGroup = display.newGroup()
	local bgRect = display.newRect(mainGroup, x, y, width, height)
	bgRect:setFillColor(0.5, 0.2, 0.8)

	mainGroup:insert(createWaitGeoInfoLayer(0.0))
	mainGroup:insert(createStopDetectedLayer(0.0))
	mainGroup:insert(createGotErrorLayer(0.0))

	self.group = mainGroup
	self:transitionToLayer(layers.waitGeoInfo)
	timer.performWithDelay( 4000, function ()
	 	self:transitionToLayer(layers.gotError) end)
	timer.performWithDelay( 8000, function ()
	 	self:transitionToLayer(layers.stopDetected) end)

	-- local mainGroup, errorGroup, regularGroup = display.newGroup(), display.newGroup(), display.newGroup()
	-- local bgRect = display.newRect(mainGroup, x, y, width, height)

	-- bgRect:setFillColor(0.5, 0.2, 0.8)

	-- -- regular
	-- local nearestStopLabel = display.newText(regularGroup, "Ближайшая остановка", x, y - 4, nil, 12)
	-- local nearestStopNameLabel = display.newText(regularGroup, "Выставочный зал", x, y + 15, native.systemFontBold, 16)
	-- local tramIcon = display.newImage(regularGroup, "img/tram.png", x, y - 20)

	-- regularGroup.alpha = 0.0
	-- local errorMessageLabel = display.newText(errorGroup, "Геолокация не работает", x, y - 4, nil, 12)
	-- local errorIcon = display.newImage(errorGroup, "img/nogps.png", x, y - 20)
	-- errorIcon:scale(0.5, 0.5)
	-- local setStopButton = widget.newButton {
	-- 	x = x,
	-- 	y = nearestStopNameLabel.y,
	-- 	onRelease = setStopButtonPressed,
	-- 	label = "● Задать остановку вручную ●",
	-- 	labelColor = { default = { 1, 1, 1 }, over = { 0, 0.5, 1 } },
	-- 	fontSize = 13,
	-- 	onRelease = function ()
	-- 		self:switchGroups()
	-- 	end
	-- }
	-- errorGroup:insert(setStopButton)

	-- self.regularGroup = regularGroup
	-- self.errorGroup = errorGroup
	-- self.group = mainGroup
	-- self.nearestStopLabel = nearestStopLabel
	-- self.nearestStopNameLabel = nearestStopNameLabel
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