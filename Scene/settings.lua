
-- Load libraries
local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Exit game function
local function backEvent( event )
    if ( "ended" == event.phase ) then
        composer.gotoScene("scene.menu")
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
	makeButton(backButton, "Back", backEvent, display.contentCenterX, display.contentHeight - 100)
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
    composer.removeScene( "scene.settings" )
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

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
