local TombBoxListItem = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function TombBoxListItem:ctor()
  print(bWriteLog and "TombBoxListItem:ctor")
  local ItemUIConfig = GamePlayTools.GetCurrentConfig("ItemUIConfig")
  if ItemUIConfig then
    self.ListItemType = ItemUIConfig.ItemType.TombBoxType
  end
end
function TombBoxListItem:RegistEvents()
  TombBoxListItem.__super.RegistEvents(self)
  self:BindLuaObjEvent(self.UIRoot, "UpdateItemData", self.UpdateItemData, self)
end
function TombBoxListItem:UpdateItemData(ItemID)
end
local class = require("class")
local ListUIItemBase = require("GameLua.Mod.BaseMod.Client.Backpack.ListItemUIBase")
local CTombBoxListItem = class(ListUIItemBase, nil, TombBoxListItem)
return CTombBoxListItem