local TombBoxListItem = {}
function TombBoxListItem:ctor()
  print(bWriteLog and "TombBoxListItem:ctor")
end
local class = require("class")
local ListUIItemBase = require("GameLua.Mod.BaseMod.Client.Backpack.ListItemUIBase")
local CTombBoxListItem = class(ListUIItemBase, nil, TombBoxListItem)
return CTombBoxListItem