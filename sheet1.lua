--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:e2384542a17a8e451c918ee3d8b21b7d:7b6875bdd420ac3c861f39839cc0880b:8aa43c05598814dfe56f66be4ef8ad91$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {

        {
            -- ani1
            x=1,
            y=1,
            width=300,
            height=300,

        },
        {
            -- ani2
            x=1,
            y=303,
            width=300,
            height=300,

        },
        {
            -- ani3
            x=1,
            y=605,
            width=300,
            height=300,

        },
        {
            -- ani4
            x=303,
            y=1,
            width=300,
            height=300,

        },
        {
            -- ani5
            x=605,
            y=1,
            width=300,
            height=300,

        },
        {
            -- ani6
            x=303,
            y=303,
            width=300,
            height=300,

        },
        {
            -- ani7
            x=303,
            y=605,
            width=300,
            height=300,

        },
        {
            -- ani8
            x=605,
            y=303,
            width=300,
            height=300,

        },
    },

    sheetContentWidth = 906,
    sheetContentHeight = 906
}

SheetInfo.frameIndex =
{

    ["ani1"] = 1,
    ["ani2"] = 2,
    ["ani3"] = 3,
    ["ani4"] = 4,
    ["ani5"] = 5,
    ["ani6"] = 6,
    ["ani7"] = 7,
    ["ani8"] = 8,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
