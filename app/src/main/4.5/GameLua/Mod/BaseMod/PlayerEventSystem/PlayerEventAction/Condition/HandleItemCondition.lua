local ItemCondition = {}
function ItemCondition:ctor(selfType)
  self.nResID = 0
end
function ItemCondition:Init(isClient, resID, needNum)
  self.nResID = resID
  self.nNeedNum = needNum
  ItemCondition.__super.Init(self, isClient)
end
function ItemCondition:Clear()
  ItemCondition.__super.Clear(self)
end
function ItemCondition:IsOK(uTarget)
  if uTarget then
    local uPlayerController = uTarget:GetControllerSafety()
    if uPlayerController then
      local uBackpackComponent = uPlayerController.BackpackComponent
      if uBackpackComponent then
        return uBackpackComponent:GetItemCountByItemSpecialID(self.nResID) >= self.nNeedNum
      end
    end
  end
  return false
end
local class = require("class")
local CConditionBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.PlayerConditionBase")
local CItemCondition = class(CConditionBase, nil, ItemCondition)
return CItemCondition