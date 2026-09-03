local GlobalAvatarFeature = {DSSwitchID_EnableRedirectItem = 122}
function GlobalAvatarFeature:ReceiveBeginPlay()
  print(bWriteLog and "GlobalAvatarFeature:ReceiveBeginPlay")
  if not Client then
    local DrinkGlobalAvatarItem = import("GlobalItemAvatar")()
    DrinkGlobalAvatarItem.ItemID = 601001
    DrinkGlobalAvatarItem.AvatarID = 601103
    self:AddItemToGlobalItemAvatarMap(DrinkGlobalAvatarItem)
  end
end
function GlobalAvatarFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local FGlobalItemAvatarMap = import("GlobalItemAvatarMap")
  local RepTable = {
    {
      "GlobalItemAvatarMap",
      ELifetimeCondition.COND_None,
      FGlobalItemAvatarMap
    }
  }
  return RepTable
end
function GlobalAvatarFeature:IsEnableRedirectItemIdToAvatarID()
  local DSSwitch = self.Owner:CheckDSSwitchOpen(self.DSSwitchID_EnableRedirectItem)
  return DSSwitch
end
function GlobalAvatarFeature:OnRep_GlobalItemAvatarMap()
  print(bWriteLog and "GlobalAvatarFeature:OnRep_GlobalItemAvatarMap", self.GlobalItemAvatarMap)
  if self.GlobalItemAvatarMap then
    for key, AvatarItem in pairs(self.GlobalItemAvatarMap.AvatarItemList) do
      print(bWriteLog and "GlobalAvatarFeature:OnRep_GlobalItemAvatarMap avatar item", AvatarItem.ItemID, AvatarItem.AvatarID)
    end
  end
end
function GlobalAvatarFeature:AddItemToGlobalItemAvatarMap(InGlobalAvatarItem)
  print(bWriteLog and "GlobalAvatarFeature:AddItemToGlobalItemAvatarMap", InGlobalAvatarItem.ItemID, InGlobalAvatarItem.AvatarID)
  local bFound = false
  if not self.GlobalItemAvatarMap then
    print(bWriteLog and "GlobalAvatarFeature:AddItemToGlobalItemAvatarMap GlobalItemAvatarMap is nil")
    return
  end
  for key, AvatarItem in pairs(self.GlobalItemAvatarMap.AvatarItemList) do
    if InGlobalAvatarItem.ItemID == AvatarItem.ItemID then
      AvatarItem.AvatarID = InGlobalAvatarItem.AvatarID
      bFound = true
      break
    end
  end
  local AvatarItemList = slua.IndexReference(self.GlobalItemAvatarMap, "AvatarItemList")
  if not bFound then
    AvatarItemList:Add(InGlobalAvatarItem)
    self.GlobalItemAvatarMap = self.GlobalItemAvatarMap
  end
end
function GlobalAvatarFeature:GetRedirectAvatarID(InItemID)
  if not self.GlobalItemAvatarMap then
    print(bWriteLog and "GlobalAvatarFeature:GetRedirectAvatarID GlobalItemAvatarMap is nil")
    return 0
  end
  for key, AvatarItem in pairs(self.GlobalItemAvatarMap.AvatarItemList) do
    if InItemID == AvatarItem.ItemID then
      return AvatarItem.AvatarID
    end
  end
  return 0
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CGlobalAvatarFeature = class(CFeatureBase, nil, GlobalAvatarFeature)
return CGlobalAvatarFeature