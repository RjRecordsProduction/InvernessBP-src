local MiniTvAvatarComponent = {}
function MiniTvAvatarComponent:RayEquipItemById(ItemID)
  if not ItemID then
    return
  end
  local ItemDefineID = FItemDefineID(self.ItemType, ItemID)
  self:HandleEquipItem(ItemDefineID, FAvatarCustomDefault())
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CMiniTvAvatarComponent = class(CActorComponentBase, nil, MiniTvAvatarComponent)
return CMiniTvAvatarComponent