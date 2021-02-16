
-- Load libraries
local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables
local json = require( "json" )

local scoresTable = {}

local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

-- Exit game function
local function backEvent( event )
  if ( "ended" == event.phase ) then
    composer.gotoScene("Scene.menu")
  end
end

local function loadScores()

  local file = io.open( filePath, "r" )

  if file then
    local contents = file:read( "*a" )
    io.close( file )
    scoresTable = json.decode( contents )
  end

  if ( scoresTable == nil or #scoresTable == 0 ) then
    scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
  end
end

local function saveScores()

  for i = #scoresTable, 11, -1 do
    table.remove( scoresTable, i )
  end

  local file = io.open( filePath, "w" )

  if file then
    file:write( json.encode( scoresTable ) )
    io.close( file )
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local bg = display.newImage( sceneGroup, "Images/scores_background.jpg",
  display.contentCenterX, display.contentCenterY)


  -- Load the previous scores
  loadScores()

  -- Insert the saved score from the last game into the table, then reset it
  table.insert( scoresTable, composer.getVariable( "finalScore" ) )
  composer.setVariable( "finalScore", 0 )

  -- Sort the table entries from highest to lowest
  local function compare( a, b )
    return a > b
  end
  table.sort( scoresTable, compare )

  -- Save the scores
  saveScores()

  local scoreBack = display.newRect( sceneGroup, display.contentCenterX,
  display.contentCenterY, display.contentWidth - 1000, display.contentHeight)
  scoreBack:setFillColor( 0.9, 0.9, 1, 0.5 )
  scoreBack.strokeWidth = 3
  scoreBack:setStrokeColor( 0 )
  local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, native.systemFont, 72 )
  highScoresHeader:setFillColor( 0.2 )

  for i = 1, 10 do
    if ( scoresTable[i] ) then
      local yPos = 150 + ( i * 56 )

      local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX-50, yPos, native.systemFont, 42 )
      rankNum:setFillColor( 0.2 )
      rankNum.anchorX = 1

      local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.systemFont, 42 )
      thisScore.anchorX = 0
      thisScore:setFillColor( 0.2 )

    end
  end

  -- Button constructor
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

-- Create buttons
local backButton = makeButton( "Back", backEvent, display.contentCenterX, display.contentHeight - 100)
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
  composer.removeScene( "Scene.scores" )
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
