local spriteSheets = {}

local playerOptions =																										-- Frames for player sprite
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

local playerSequence =  																									-- Sequence data for player sprite
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

return {
playerOptions = playerOptions
playerSequence = playerSequence
}
