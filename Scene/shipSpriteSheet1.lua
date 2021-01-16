--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:fea622d394103fb3378b62791502cf93:b10bf06554977ddaccfc71ed67856fe7:4abde774e4d6a5d8b38d2a2d4e6372e6$
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
    },

    sheetContentWidth = 428,
    sheetContentHeight = 102
}

SheetInfo.frameIndex =
{

    ["ship1"] = 1,
    ["ship2"] = 2,
    ["ship3"] = 3,
    ["ship4"] = 4,
    ["ship5"] = 5,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
