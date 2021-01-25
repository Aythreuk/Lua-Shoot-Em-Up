local bulletsModule = {}

bulletsModule.bullet1Options =																										-- Frames for player sprite
{
  frames = {
    {
      -- frame1
      x=0,
      y=0,
      width=8,
      height=17
    },
    {
      -- frame2
      x=8,
      y=0,
      width=10,
      height=21
    },
    {
      -- frame3
      x=18,
      y=0,
      width=12,
      height=25
    },
    {
      -- frame4
      x=30,
      y=0,
      width=14,
      height=29
    },
  },
  --optional parameters; used for scaled content support
  sheetContentWidth = 44,  -- width of original 1x size of entire sheet
  sheetContentHeight = 29   -- height of original 1x size of entire sheet
}

bulletsModule.bullet1Sequence = {
  -- consecutive frames sequence
  {
    name = "normal",
    start = 1,
    count = 4,
    time = 1600,
    loopCount = 1
  }
}

bulletsModule.bullet2Options =																										-- Frames for player sprite
{
  frames = {
    {
      -- frame1
      x=0,
      y=0,
      width=9,
      height=29,
    },
    {
      -- frame2
      x=9,
      y=0,
      width=9,
      height=29,
    },
    {
      -- frame3
      x=18,
      y=0,
      width=9,
      height=29,
    },
    {
      -- frame4
      x=27,
      y=0,
      width=9,
      height=29,
    },
    {
      -- frame5
      x=36,
      y=0,
      width=9,
      height=29,
    },
    {
      -- frame6
      x=45,
      y=0,
      width=9,
      height=29,
    },
  }
}

bulletsModule.bullet2Sequence = {
  -- consecutive frames sequence
  {
    name = "normal",
    start = 1,
    count = 6,
    time = 600,
    loopCount = 0,
    loopDirection = "forward"
  }
}

bulletsModule.laser1Options =
{
  frames = {
    {
      --frame1
      x = 0,
      y = 0,
      width = 520,
      height = 70,
    },
    {
      --frame2
      x = 0,
      y = 70,
      width = 520,
      height = 74,
    },
  },
  --optional parameters; used for scaled content support
  sheetContentWidth = 520,  -- width of original 1x size of entire sheet
  sheetContentHeight = 144,   -- height of original 1x size of entire sheet
}

bulletsModule.laser1Sequence = {
  name = "normal",
  start = 1,
  count = 2,
  time = 200,
  loopCount = 0,
}

return bulletsModule
