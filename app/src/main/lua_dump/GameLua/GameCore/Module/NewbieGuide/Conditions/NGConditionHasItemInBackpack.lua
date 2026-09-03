local NGConditionHasItemInBackpack = {}
function NGConditionHasItemInBackpack:ctor(selfType, Params)
  self.CheckItemList = Params.CheckItemList or {}
  self.BackpackSoreArea = Params.BackpackSoreArea or 0
end
function NGConditionHasItemInBackpack:CheckConditionOK(...)
  log(bWriteLog and "Debug NewbieGuide: NGConditionHasItemInBackpack CheckConditionOK")
  local bSuperOk = NGConditionHasItemInBackpack.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not slua.isValid(uPlayerController.BackpackComponent) then
    return false
  end
  local UBackpackUtils = import("BackpackUtils")
  local Items = UBackpackUtils.GetItemsBackpackNeedToShowItemNew(uPlayerController.BackpackComponent, false, self.BackpackSoreArea)
  if self.CheckItemList ~= nil and #self.CheckItemList > 0 then
    local FindItem = false
    for _, FindID in ipairs(self.CheckItemList) do
      for i = 0, Items:Num() - 1 do
        local ItemID = Items:Get(i)
        if ItemID == FindID then
          FindItem = true
          break
        end
      end
    end
    return FindItem
  else
    return 0 < Items:Num()
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionHasItemInBackpack = class(CObject, nil, NGConditionHasItemInBackpack)
return CNGConditionHasItemInBackpack