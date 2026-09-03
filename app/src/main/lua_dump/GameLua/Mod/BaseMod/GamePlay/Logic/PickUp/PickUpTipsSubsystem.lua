local common = require("client.slua_ui_framework.common")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameComponentData = require("GameLua.GameCore.Data.GameComponentData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local PickUpTipsSubsystem = {}
function PickUpTipsSubsystem:ctor()
  self.PickUpTipsConditionID = 0
  self.PickUpTipsConditionTable = {}
end
function PickUpTipsSubsystem:OnInit()
  print(bWriteLog and "PickUpTipsSubsystem:OnInit")
  self:RegistEvents()
end
function PickUpTipsSubsystem:OnRelease()
  print(bWriteLog and "PickUpTipsSubsystem:OnRelease")
  PickUpTipsSubsystem.__super.OnRelease(self)
end
function PickUpTipsSubsystem:RegistEvents()
  GameComponentData.AddSelfBackpackComponentEvent(self, "ItemOperationDelegate", self.OnItemOperationDelegate, self)
end
function PickUpTipsSubsystem:AddPickUpTipsCondition(ConditionFunc, ...)
  self.PickUpTipsConditionID = self.PickUpTipsConditionID + 1
  self.PickUpTipsConditionTable[self.PickUpTipsConditionID] = {
    Func = ConditionFunc,
    Args = table.pack(...)
  }
  return self.PickUpTipsConditionID
end
function PickUpTipsSubsystem:RemovePickUpTipsCondition(ConditionID)
  self.PickUpTipsConditionTable[ConditionID] = nil
end
function PickUpTipsSubsystem:OnItemOperationDelegate(ItemDefineID, OptType, Reason)
  print(bWriteLog and string.format("PickUpTipsSubsystem:OnItemOperationDelegate ItemId=%d, Opt=%d, Reason=%d", ItemDefineID.TypeSpecificID, OptType, Reason))
  local nItemID = ItemDefineID.TypeSpecificID
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  if BackpackConfig and BackpackConfig.ItemsNotToShowTips and BackpackConfig.ItemsNotToShowTips[nItemID] then
    print(bWriteLog and "BackpackComponent:OnItemOperationDelegate ItemsNotToShowTips nItemID" .. nItemID)
    return
  end
  local ItemData = CDataTable.GetTableData("Item", nItemID)
  if not ItemData then
    print(bWriteLog and "BackpackComponent:OnItemOperationDelegate ItemData invalid nItemID" .. nItemID)
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local kismet_string_library = require("common.kismet_string_library")
  if kismet_string_library.Len(ItemData.ItemName) > 0 then
    local EBattleItemOperationType = import("EBattleItemOperationType")
    if OptType == EBattleItemOperationType.Pickup then
      local EBattleItemPickupReason = import("EBattleItemPickupReason")
      if Reason ~= EBattleItemPickupReason.Initial and Reason ~= EBattleItemPickupReason.FromStore then
        self:DisplayPickUpTips(nItemID, ItemData.ItemName)
      end
    elseif OptType == EBattleItemOperationType.Drop then
      local EBattleItemDropReason = import("EBattleItemDropReason")
      if Reason == EBattleItemDropReason.CapacityExceeded then
        PlayerController:DisplayGameTipWithMsgIDAndString(30066, ItemData.ItemName, "")
      end
    elseif OptType == EBattleItemOperationType.Use then
      EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_ITEM, EVENTID_PLAYEREVENT_USEITEM_CLIENT, ItemDefineID, OptType, Reason)
    end
  end
end
function PickUpTipsSubsystem:DisplayPickUpTips(nItemID, sItemName)
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.IsEnableRedirectItemIdToAvatarID and uGameState:IsEnableRedirectItemIdToAvatarID() then
    local RedirectAvatarID = uGameState:GetRedirectAvatarID(nItemID)
    if 0 ~= RedirectAvatarID then
      nItemID = RedirectAvatarID
      print(bWriteLog and "BackpackComponent:DisplayPickUpTips RedirectAvatarID=" .. RedirectAvatarID)
    end
  end
  local bShowPickUpTips = true
  for _, Condition in pairs(self.PickUpTipsConditionTable) do
    bShowPickUpTips = bShowPickUpTips and common.CallCombinationArgs(Condition.Func, Condition.Args, nItemID, sItemName)
  end
  if not bShowPickUpTips then
    return
  end
  IngameTipsTools.BattleNormalTipsByTextID(34330, sItemName)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, PickUpTipsSubsystem)