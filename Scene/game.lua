
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------



local options =
{
	frames = {
			{
					-- ship1
					x=1,
					y=1,
					width=94,
					height=100,

			},
			{
					-- ship2
					x=97,
					y=1,
					width=86,
					height=99,

			},
			{
					-- ship3
					x=273,
					y=1,
					width=76,
					height=99,

			},
			{
					-- ship4
					x=185,
					y=1,
					width=86,
					height=99,

			},
			{
					-- ship5
					x=351,
					y=1,
					width=76,
					height=99,

			},
	}
}

local playerSequence =
{
	{
			name="idle",
		 frames= { 1 }, -- frame indexes of animation, in image sheet
		 time = 240,
		 loopCount = 0
	},
{
		name="leftTurn",
	 frames= { 2, 4 }, -- frame indexes of animation, in image sheet
	 time = 240,
	 loopCount = 0
},
{
		name="rightTurn",
	 frames= { 3, 5 }, -- frame indexes of animation, in image sheet
	 time = 240,
	 loopCount = 0
}
}
local playerSheet = graphics.newImageSheet("shipSpriteSheet1.png", options)

-- Player hit the escape button
local function onKeyEvent ( event )
if (event.phase == "down" and event.keyName == "escape") then
	print("Escape function was called")
	native.requestExit()
end
	return false
end

-- Add the key event listener
Runtime:addEventListener( "key", onKeyEvent )



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local playerSprite = display.newSprite(sceneGroup, playerSheet, playerSequence)
	playerSprite.x = display.contentCenterX
	playerSprite.y = display.contentHeight - 400
	playerSprite:setFrame(1)
print(playerSprite.frame)
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
