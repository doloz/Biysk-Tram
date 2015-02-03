--- Nearest Stop
local widget = require "widget"
local Colors = require "Colors"

local NearestStop = {
	currentStop = nil
}



local metrics
local layers = {}

function NearestStop:setAutoDetection (value)
	if (self.autoDetection ~= value) then
		self.autoDetection = value
		if self.autoDetection then
			Runtime:addEventListener("location", updateLocation)
			self:transitionToLayer(layers.waitGeoInfo)
		else
			assert(currentStop, "When switching to manual mode, current stop must be non-nil")
			Runtime:removeEventListener("location", updateLocation)
			self:transitionToLayer(layers.stopDetected)
		end
	end
end

function NearestStop:setCurrentStop (value)
		if NearestStop.currentStop == value then
			return
		end
		NearestStop.currentStop = value
		local label = layers.stopDetected.label
		label.text = NearestStop.currentStop
		label.anchorX = 0.5
		label.x = metrics.x
		label.y = metrics.y + 10

		transition.to(layers.stopDetected.icon, {
			time = 400,
			rotation = 360,
			iterations = 1
		})
end

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
	local waitLabel = display.newText(waitGeoInfo, "Ищем ближайшую остановку...", metrics.x, metrics.y + 10, nil, 12, "right")
	-- waitLabel.align = "center"
	local gpsIcon = display.newImage(waitGeoInfo, "img/gps.png", metrics.x, metrics.top + 20)
	gpsIcon:scale(0.5, 0.5)

	waitGeoInfo.icon = gpsIcon
	waitGeoInfo.alpha = alpha
	layers.waitGeoInfo = waitGeoInfo

	waitGeoInfo.show = function ()
		transition.to(gpsIcon, {
			time = 2000,
			tag = "icon_rotation1",
			rotation = 360,
			iterations = -1
		})
	end

	waitGeoInfo.hide = function ()
		transition.cancel("icon_rotation1")
	end
	return waitGeoInfo
end

function createStopDetectedLayer(alpha)
	local stopDetected = display.newGroup()
	local stopNameLabel = display.newText(stopDetected, "", metrics.x, metrics.y + 10, native.systemFontBold, 15)
	local gpsIcon = display.newImage(stopDetected, "img/gps_green.png", metrics.x, metrics.top + 20)
	gpsIcon:scale(0.5, 0.5)

	stopDetected.label = stopNameLabel
	stopDetected.icon = gpsIcon
	stopDetected.alpha = alpha
	layers.stopDetected = stopDetected
	stopDetected.show = function ()

	end

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
		if self.currentLayer == layer then
			return
		end
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
	bgRect:setFillColor(colorsFromHex("FF5300"))

	mainGroup:insert(createWaitGeoInfoLayer(0.0))
	mainGroup:insert(createStopDetectedLayer(0.0))
	mainGroup:insert(createGotErrorLayer(0.0))

	local buttonSide = 32
	local selectStopButton = widget.newButton {
		x = metrics.right - buttonSide / 2 - 20,
		y = metrics.y,
		width = buttonSide,
		height = buttonSide,
		defaultFile = "img/selectStop@2x.png",
		overFile = "img/selectStopOver.png",
		onRelease = function ()
			print("Pressed!")
		end
	}	
	mainGroup:insert(selectStopButton)

	self.group = mainGroup
	self:setAutoDetection(true)
	-- self:transitionToLayer(layers.waitGeoInfo)
	-- timer.performWithDelay( 4000, function ()
	--  	self:transitionToLayer(layers.gotError) end)
	-- timer.performWithDelay( 8000, function ()
	--  	self:transitionToLayer(layers.stopDetected) end)
	-- Runtime:addEventListener("location", updateLocation)
end

local geoPoints = {
	["Общага"] = {
		latitude = 54.84484638,
		longitude = 83.09595016
	},
	["ТЦ"] = {
		latitude = 54.83905830,
		longitude = 83.09567189
	},
	["НГУ"] = {
		latitude = 54.84387304, 
		longitude = 83.09393926
	}
}

function findNearest(event)
	local threshold = 0.5
	-- local nothingFound = true
	-- local found = {}
	local minDistance = math.huge
	local minDistanceStop = nil
	for stop, coords in pairs(geoPoints) do
		local f1 = event.latitude 
		local l1 = event.longitude
		local f2 = coords.latitude
		local l2 = coords.longitude
		local sin = math.sin
		local cos = math.cos
		local distance = 111.2 * math.acos(sin(f1) * sin(f2) + cos(f1) * cos(f2) * cos(l2-l1))
		print(f1 .. l1 .. " - > " .. f2 .. l2 .. " = " .. distance)
		if distance < threshold then
			if distance < minDistance then 
				minDistance = distance
				minDistanceStop = stop
			end
			-- table.insert(found, )
		end
	end

	return minDistanceStop
end

function updateLocation(event)
	print(event.latitude .. event.longitude)
	if NearestStop.currentLayer == layers.gotError then
		return
	end

	if event.errorCode then
		NearestStop:transitionToLayer(layers.gotError)
	else
		local nearest = findNearest(event)

		if nearest then
			NearestStop:setCurrentStop(nearest)
			-- layers.stopDetected.label.text = nearest
			NearestStop:transitionToLayer(layers.stopDetected)
		else
			NearestStop:transitionToLayer(layers.gotError)
		end
	end
end

-- function NearestStop:switchGroups()
-- 	local newErrorAlpha = 1.0 - self.errorGroup.alpha
-- 	transition.to(self.errorGroup, {
-- 		alpha = newErrorAlpha,
-- 		time = 400
-- 	})
-- 	transition.to(self.regularGroup, {
-- 		alpha = 1.0 - newErrorAlpha,
-- 		time = 400	
-- 	})
-- end

return NearestStop