local ItemActionBuilder = {}
function ItemActionBuilder:Init(bClient)
  ItemActionBuilder.__super.Init(self, bClient)
  self.Conditions = {}
  local itemCondition = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.HandleItemCondition")
  local itemConditionInst = itemCondition()
  self.Conditions[EVENTID_PLAYEREVENT_DROPITEM] = itemConditionInst
  self.Conditions[EVENTID_PLAYEREVENT_USEITEM] = itemConditionInst
  self.Conditions[EVENTID_PLAYEREVENT_DISUSEITEM] = itemConditionInst
  self.Conditions[EVENTID_PLAYEREVENT_DROPITEM] = itemConditionInst
  self.Conditions[EVENTID_PLAYEREVENT_SWAPITEM] = itemConditionInst
  self.Conditions[EVENTID_PLAYEREVENT_EQUIPITEM] = itemConditionInst
  self.Conditions[EVENTID_PLAYEREVENT_EQUIPWEAPONTANDATTACHITEM] = itemConditionInst
  self.Conditions[EVENTID_PLAYEREVENT_UNEQUIPITEM] = itemConditionInst
end
function ItemActionBuilder:Clear()
  self.Conditions = nil
end
function ItemActionBuilder:BuildActionTemplate(eventID, targetCharacter, actionDataTable)
  if self.Conditions[eventID] then
    self.Conditions[eventID]:Init(self.bIsClient, actionDataTable.nItemID, 1)
    if not self.Conditions[eventID]:IsOK(targetCharacter) then
      return
    end
  end
  if eventID == EVENTID_PLAYEREVENT_PICKUPITEM or eventID == EVENTID_PLAYEREVENT_USEITEM or eventID == EVENTID_PLAYEREVENT_CONSUMEITEM or eventID == EVENTID_PLAYEREVENT_BACKPACKITEM_CLEANUP or eventID == EVENTID_PLAYEREVENT_EQUIPITEM or eventID == EVENTID_PLAYEREVENT_EQUIPWEAPONTANDATTACHITEM then
    return self:CreatePlayerActionArray(actionDataTable.tActionData, {}, targetCharacter)
  end
end
function ItemActionBuilder:IsActionDataEqual(actionDataTable1, actionDataTable2)
  if not actionDataTable1 and not actionDataTable2 then
    return true
  end
  if not actionDataTable1 or not actionDataTable2 then
    return false
  end
  if actionDataTable1.nItemID == actionDataTable2.nItemID and (not (actionDataTable1.nInstanceID and actionDataTable2.nInstanceID) or actionDataTable1.nInstanceID == actionDataTable2.nInstanceID) then
    return true
  end
  return false
end
local class = require("class")
local CBuilderBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.ActionBuilderBase")
local CItemActionBuilder = class(CBuilderBase, nil, ItemActionBuilder)
return CItemActionBuilder