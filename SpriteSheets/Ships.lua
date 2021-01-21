local shipsModule = {}

shipsModule.playerOptions =																										-- Frames for player sprite
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

shipsModule.playerSequence =  																									-- Sequence data for player sprite
{
  name="aniRange",
  frames = {1, 2, 3 ,4 ,5}
}

shipsModule.enemy1Options =
{
  frames = {
    {
      -- frame 1
      x = 0,
      y = 0,
      width = 64,
      height = 99,
    },
    {
      -- frame 2
      x = 0,
      y = 99,
      width = 64,
      height = 99
    },
    {
      -- frame 3
      x = 0,
      y = 198,
      width = 64,
      height = 99,
    },
    {
      -- frame 4
      x = 0,
      y = 297,
      width = 64,
      height = 99,
    },
  },
  --optional parameters; used for scaled content support
  sheetContentWidth = 64,  -- width of original 1x size of entire sheet
  sheetContentHeight = 396,   -- height of original 1x size of entire sheet
}

shipsModule.enemy1Sequence =
{
  name = "normal",
  start = 1,
  count = 4,
  time = 400,
  loopCount = 0,
}

return shipsModule
