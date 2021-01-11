-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Load libraries
local widget = require( "widget" )
local composer = require( "composer" )

-- Variables and references
local scene = composer.newScene()
local group1 = display.newGroup()

-- Exit game function
local function exitEvent( event )
    if ( "ended" == event.phase ) then
        native.requestExit()
    end
end

-- Settings function
local function settingsEvent( event )
    if ( "ended" == event.phase ) then
        print("Let's change the settings!")
        composer.gotoScene("scene.settings")
    end
end

-- New game function
local function newGameEvent( event )
    if ( "ended" == event.phase ) then
        print("Let's start a new game!")
        composer.gotoScene("scene.game")
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

  -- Function to style each button uniformly
  local function makeButton ( button, label, event, x, y )
    local button = widget.newButton(
        {
            label = label,
            onEvent = event,
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = 200,
            height = 40,
            cornerRadius = 2,
            fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
            strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
            strokeWidth = 4,
            x = x,
            y = y
        }
    )
  sceneGroup:insert(button)
  end

  -- Create buttons
  makeButton("exitButton", "Exit", exitEvent, display.contentCenterX, display.contentHeight - 100)
  makeButton("settingsButton", "Settings", settingsEvent, display.contentCenterX, display.contentHeight - 200)
  makeButton("newGameButton", "New Game", newGameEvent, display.contentCenterX, display.contentHeight - 300)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene( "scene.menu" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
