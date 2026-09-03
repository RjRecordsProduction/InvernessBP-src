local PickUpListItem = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function PickUpListItem:ctor()
  print(bWriteLog and "PickUpListItem:ctor")
  local ItemUIConfig = GamePlayTools.GetCurrentConfig("ItemUIConfig")
  if ItemUIConfig then
    self.ListItemType = ItemUIConfig.ItemType.PickupType
  end
end
local class = require("class")
local ListUIItemBase = require("GameLua.Mod.BaseMod.Client.Backpack.ListItemUIBase")
local CPickUpListItem = class(ListUIItemBase, nil, PickUpListItem)
return CPickUpListItem