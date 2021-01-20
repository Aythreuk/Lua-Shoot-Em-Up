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

return shipsModule
