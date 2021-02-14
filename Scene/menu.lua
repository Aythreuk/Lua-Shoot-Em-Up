-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local widget = require( "widget" )                                              -- Load libraries
local composer = require( "composer" )

local scene = composer.newScene()                                               -- Variables and references

native.setProperty( "mouseCursorVisible", true )                                -- Initialization

local function exitEvent( event )                                               -- Exit game function
  if ( "ended" == event.phase ) then
    native.requestExit()
  end
end

local function settingsEvent( event )                                           -- Settings function
  if ( "ended" == event.phase ) then
    composer.gotoScene("Scene.settings")
  end
end

local function newGameEvent( event )                                            -- New game function
  if ( "ended" == event.phase ) then
    composer.gotoScene("Scene.game")
  end
end

local function scoresEvent ( event )
  if ( "ended" == event.phase ) then
    composer.gotoScene("Scene.scores")
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

local center, scrnHeight = display.contentCenterX, display.contentHeight
local bg = display.newImage( sceneGroup, "Images/menu_background.png",
center, display.contentCenterY)
-- title backing
local titleBackVertices = { center + 200, 50, center + 300, 100, center + 200, 150,
center - 200, 150, center - 300, 100, center - 200, 50 }
local titleBack = display.newPolygon( sceneGroup, center, 100, titleBackVertices )
titleBack:setFillColor( 0.9, 0.9, 1, 0.5 )
titleBack.strokeWidth = 3
titleBack:setStrokeColor( 0 )
-- game title
local gameTitle = display.newText( sceneGroup, "Galaxy 51", center,
100, "Fonts/Black_Ops_One/BlackOpsOne-Regular.ttf", 72 )
gameTitle:setFillColor( 0.25, 0.25, 0.5 )
-- button backing
local buttonBackVertices = { center + 100, scrnHeight - 350, center + 150,
scrnHeight - 300, center + 150, scrnHeight - 50, center + 100, scrnHeight,
center - 100, scrnHeight, center - 150, scrnHeight - 50, center - 150,
scrnHeight - 300, center - 100, scrnHeight - 350 }
local buttonBack = display.newPolygon( sceneGroup, center, scrnHeight - 200,
buttonBackVertices )
buttonBack:setFillColor( 0.9, 0.9, 1, 0.5 )
buttonBack.strokeWidth = 3
buttonBack:setStrokeColor( 0 )

local function makeButton ( label, event, x, y )
  local self = {}
  self = widget.newButton(
  {
    label = label,
    onEvent = event,
    x = x,
    y = y,
    emboss = false,
    shape = "roundedRect",
    width = 200,
    height = 40,
    cornerRadius = 2,
    fillColor = { default={ 0.8, 0.8, 1, 1 }, over={1,0.1,0.7,0.4} },
    strokeColor = { default={ 0.4, 0.4, 0.6 ,1 }, over={0.8,0.8,1,1} },
    strokeWidth = 4
  }
)
sceneGroup:insert( self )
end
--208, 208, 225
-- Create buttons
local exitButton = makeButton( "Exit", exitEvent, display.contentCenterX,
scrnHeight - 100)
local settingsButton = makeButton( "Settings", settingsEvent, display.contentCenterX,
scrnHeight - 166)
local scoresButton = makeButton( "Highscores", scoresEvent, display.contentCenterX,
scrnHeight - 233)
local newGameButton = makeButton( "New Game", newGameEvent, display.contentCenterX,
scrnHeight - 300)
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
    composer.removeScene( "Scene.menu" )
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
