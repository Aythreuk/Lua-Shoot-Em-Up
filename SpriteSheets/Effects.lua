local effectsModule = {}

-- explosion effect
effectsModule.explosion1Options =																										-- Frames for player sprite
{
  frames = {
    {
      -- frame1
      x=0,
      y=0,
      width=12,
      height=12
    },
    {
      -- frame2
      x=12,
      y=0,
      width=30,
      height=30
    },
    {
      -- frame3
      x=42,
      y=0,
      width=74,
      height=74
    },
    {
      -- frame4
      x=116,
      y=0,
      width=84,
      height=84
    },
    {
      -- frame5
      x=200,
      y=0,
      width=88,
      height=88
    },
    {
      -- frame6
      x=288,
      y=0,
      width=90,
      height=90
    },
    {
      -- frame7
      x=378,
      y=0,
      width=94,
      height=94
    },
    {
      -- frame8
      x=472,
      y=0,
      width=86,
      height=86
    },
  },
  --optional parameters; used for scaled content support
  sheetContentWidth = 558,  -- width of original 1x size of entire sheet
  sheetContentHeight = 96,   -- height of original 1x size of entire sheet
}

effectsModule.explosion1Sequence = {
  -- consecutive frames sequence
  {
    name = "normal",
    start = 1,
    count = 8,
    time = 2000,
    loopCount = 1
  }
}

return effectsModule
