local spriteSheets = {}

 spriteSheets.playerOptions =																										-- Frames for player sprite
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

spriteSheets.playerSequence =  																									-- Sequence data for player sprite
{
	{
		name="idle",
		frames= { 1 }, -- frame indexes of animation, in image sheet
		time = 240,
		loopCount = 0
	},
	{
		name="leftTurn",
		frames= { 2, 3 }, -- frame indexes of animation, in image sheet
		time = 1000,
		loopCount = 1
	},
	{
		name="rightTurn",
		frames= { 4, 5 }, -- frame indexes of animation, in image sheet
		time = 1000,
		loopCount = 1
	},
	{
		name="leftReturn",
		frames= { 3, 2, 1,  }, -- frame indexes of animation, in image sheet
		time = 1000,
		loopCount = 1
	},
	{
		name="rightReturn",
		frames= { 5, 4, 1 }, -- frame indexes of animation, in image sheet
		time = 1000,
		loopCount = 1
	},
	{
		name="aniRange",
		frames = {1, 2, 3 ,4 ,5}
	}
}

spriteSheets.bullet1Options =																										-- Frames for player sprite
{
 frames = {
   {
     -- frame1
     x=0,
     y=0,
     width=14,
     height=29
   },
   {
     -- frame2
     x=14,
     y=0,
     width=12,
     height=25
   },
   {
     -- frame3
     x=26,
     y=0,
     width=10,
     height=21
   },
   {
     -- frame4
     x=36,
     y=0,
     width=8,
     height=17
   }
 }
 --optional parameters; used for scaled content support
     sheetContentWidth = 44,  -- width of original 1x size of entire sheet
     sheetContentHeight = 29   -- height of original 1x size of entire sheet
}

spriteSheets.bullet1Sequence = {
    -- consecutive frames sequence
    {
        name = "normal",
        start = 1,
        count = 4,
        time = 800,
        loopCount = 0,
        loopDirection = "forward"
    }
}

spriteSheets.bullet2Options =																										-- Frames for player sprite
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

spriteSheets.bullet2Sequence = {
    -- consecutive frames sequence
    {
        name = "normal",
        start = 1,
        count = 6,
        time = 1200,
        loopCount = 0
    }
}

return spriteSheets
