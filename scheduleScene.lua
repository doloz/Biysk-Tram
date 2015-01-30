local composer = require "composer" 
local widget = require "widget"
local NearestStop = require "NearestStop"
local scene = composer.newScene()

local locationLabel
-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- ------------------------------------------------------------------------------
function buttonInitTable(imageName)
    return {
        width = 32,
        height = 32,
        defaultFile = imageName
    }
end

function createButtons(rootView)
    -- local buttonColor = { 1, 0.2, 0.5, 0.7 }
    -- local colorTable = { default = buttonColor, over = buttonColor }
    local fullScheduleButton = widget.newButton(buttonInitTable("more.png"))
    fullScheduleButton.anchorX = 0
    fullScheduleButton.anchorY = 0
    local settingsButton = widget.newButton(buttonInitTable("settings.png"))
    settingsButton.x = display.contentWidth - 10
    settingsButton.y = 10
    settingsButton.anchorX = 1
    settingsButton.anchorY = 0
    -- fullScheduleButton.width = 32
    rootView:insert(fullScheduleButton)
    rootView:insert(settingsButton)
end

function createTable(rootView)
    local tableView = widget.newTableView {
        left = 0,
        top = 50,
        width = display.contentWidth,
        height = display.actualContentHeight - 50,
        backgroundColor = { 0.6, 0.7, 0.8 },
    }
    rootView:insert(tableView)
end 

function createNearestStopLabels(rootView)
    local label = display.newText("Ближайшая остановка", display.contentWidth / 2, 10, nil, 12)
    label:setFillColor( 1, 0, 0 )
    rootView:insert(label)
    local nearestStopName = display.newText("Выставочный зал", display.contentWidth / 2, label.y + 25, native.systemFontBold, 16)
    nearestStopName:setFillColor( 0, 0, 0 )
    rootView:insert(nearestStopName)
end



-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view
    display.setDefault("background", 1, 1, 1)
    createButtons(sceneGroup)
    createTable(sceneGroup)
    -- createNearestStopLabels(sceneGroup)
    NearestStop:setup(display.contentWidth / 2, 10, 250, 70)
    sceneGroup:insert(NearestStop.group)
    locationLabel = display.newText("", display.contentWidth / 2, display.contentHeight / 2, nil, 14)
    sceneGroup:insert(locationLabel)

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        Runtime:addEventListener( "location", updateLocation )
    end
end

function updateLocation(event)
    if event.errorCode then
        locationLabel.text = "Не могу получить данные"
    else
        locationLabel.text = event.latitude .. " " ..  event.longitude .. " " .. event.altitude
    end
end
-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
