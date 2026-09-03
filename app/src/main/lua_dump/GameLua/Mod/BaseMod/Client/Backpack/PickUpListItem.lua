local PickUpListItem = {}
function PickUpListItem:ctor()
  print(bWriteLog and "PickUpListItem:ctor")
end
local class = require("class")
local ListUIItemBase = require("GameLua.Mod.BaseMod.Client.Backpack.ListItemUIBase")
local CPickUpListItem = class(ListUIItemBase, nil, PickUpListItem)
return CPickUpListItem