local HandleItemEvent = {}
local EBattleItemUseReason = import("EBattleItemUseReason")
local EBattleItemDisuseReason = import("EBattleItemDisuseReason")
function HandleItemEvent:ctor(selfType)
end
function HandleItemEvent:Init(gameState, bClient, dataMgr, actionMgr)
  HandleItemEvent.__super.Init(self, gameState, bClient, dataMgr, actionMgr)
end
function HandleItemEvent:DoItemAction(nEventType, nEventID, nPlayerKey, nItemID)
  if not self.GetCharacter then
    return
  end
  local targetCharacter = self:GetCharacter(nPlayerKey)
  local ItemEventData = self.EventDataMgr:GetData(nEventType)
  if targetCharacter and ItemEventData then
    local ItemActionCfgData = ItemEventData:GetItemActionTable(nItemID, nEventID)
    if ItemActionCfgData then
      local ActionData = ItemEventData:GetTableData("ActionTable", ItemActionCfgData.ActionID)
      local actionDataTable = {nItemID = nItemID, tActionData = ActionData}
      self.EventActionMgr:DoAction(nEventType, nEventID, targetCharacter, actionDataTable)
    else
    end
  else
  end
end
function HandleItemEvent:UnDoItemAction(nEventType, nEventID, nPlayerKey, nItemID, nUndoEventID)
  local targetCharacter = self:GetCharacter(nPlayerKey)
  if targetCharacter and 0 < nItemID then
    local actionDataTable = {nItemID = nItemID, tActionData = nil}
    local ItemEventData = self.EventDataMgr:GetData(nEventType)
    if ItemEventData then
      local ItemActionCfgData = ItemEventData:GetItemActionTable(nItemID, nUndoEventID)
      if ItemActionCfgData and ItemActionCfgData.NeedUndo >= 1 then
        self.EventActionMgr:UnDoAction(nEventType, nUndoEventID, targetCharacter, actionDataTable)
      end
    end
  end
end
function HandleItemEvent:DoWeaponItemAction(nEventType, nEventID, nPlayerKey, nItemID, nInstanceId)
  if not self.GetCharacter then
    return
  end
  local targetCharacter = self:GetCharacter(nPlayerKey)
  local ItemEventData = self.EventDataMgr:GetData(nEventType)
  if not slua.isValid(targetCharacter) or not ItemEventData then
    return print("HandleItemEvent DoWeaponItemAction ItemEventData nil Error nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
  local uWeaponManager = targetCharacter:GetWeaponManager()
  if not slua.isValid(uWeaponManager) then
    return print("HandleItemEvent DoWeaponItemAction uWeaponManager nil Error nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
  local ItemCfg = CDataTable.GetTableData("Item", nItemID)
  if not ItemCfg then
    return print("HandleItemEvent DoWeaponItemAction ItemCfg nil Error nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
  local ItemDefineID = FItemDefineID(ItemCfg.ItemType, nItemID, nInstanceId)
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local InWeaponDefineID
  if ModelDisplayTypeHelper.IsWeapon(ItemCfg.ItemType) then
    InWeaponDefineID = ItemDefineID
  elseif ItemCfg.ItemType == ENUM_ITEM_TYPE.Medicine then
    local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local BackPackComp = USTExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(targetCharacter)
    if slua.isValid(BackPackComp) then
      local ItemHandle = BackPackComp:GetItemHandleByDefineID(ItemDefineID)
      if slua.isValid(ItemHandle) then
        for key, value in pairs(ItemHandle.AssociationMap) do
          if value.AssociationType == 1 then
            InWeaponDefineID = value.AssociationTargetDefineID
          end
        end
      end
    end
  end
  if not InWeaponDefineID then
    print(bWriteLog and "HandleItemEvent DoWeaponItemAction InWeaponDefineID==nil nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
    return
  end
  local uWeapon = uWeaponManager:GetInventoryWeaponByDefineID(InWeaponDefineID)
  if slua.isValid(uWeapon) then
    local ItemActionCfgData = ItemEventData:GetItemActionTable(nItemID, nEventID)
    if ItemActionCfgData then
      local ActionData = ItemEventData:GetTableData("ActionTable", ItemActionCfgData.ActionID)
      local actionDataTable = {
        nItemID = nItemID,
        nInstanceID = nInstanceId,
        WeaponDefineID = InWeaponDefineID,
        t      }
      self.EventActionMgr:DoAction(nEventType, nEventID, targetCharacter, actionDataTable, uWeapon, true)
    else
      print(bWriteLog and "HandleItemEvent DoWeaponItemAction targetCharacter==nil nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
    end
  else
    print(bWriteLog and "HandleItemEvent DoWeaponItemAction targetCharacter==nil nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
end
function HandleItemEvent:UnDoWeaponItemAction(nEventType, nEventID, nPlayerKey, nItemID, nInstanceId, nUndoEventID)
  local targetCharacter = self:GetCharacter(nPlayerKey)
  if not slua.isValid(targetCharacter) or nItemID < 1 then
    return print("HandleItemEvent UnDoWeaponItemAction Pawn nil Error nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
  local actionDataTable = {
    nItemID = nItemID,
    nInstanceID = nInstanceId,
    WeaponDefineID = nil,
    tActionData = nil
  }
  local ItemEventData = self.EventDataMgr:GetData(nEventType)
  if not ItemEventData then
    return print("HandleItemEvent UnDoWeaponItemAction ItemEventData nil Error nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
  local ItemActionCfgData = ItemEventData:GetItemActionTable(nItemID, nUndoEventID)
  if not ItemActionCfgData or 1 > ItemActionCfgData.NeedUndo then
    return print("HandleItemEvent UnDoWeaponItemAction ItemActionCfgData nil Error nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
  local AimActionData = self.EventActionMgr:GetAimActionData(nEventType, nUndoEventID, targetCharacter, actionDataTable)
  if not AimActionData then
    return print("HandleItemEvent UnDoWeaponItemAction AimActionData nil Error nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
  local uWeaponManager = targetCharacter:GetWeaponManager()
  if slua.isValid(uWeaponManager) then
    local uWeapon = uWeaponManager:GetInventoryWeaponByDefineID(AimActionData.WeaponDefineID)
    if slua.isValid(uWeapon) then
      self.EventActionMgr:UnDoAction(nEventType, nUndoEventID, targetCharacter, actionDataTable, uWeapon, true)
    else
      print(bWriteLog and "HandleItemEvent UnDoWeaponItemAction targetCharacter==nil nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
    end
  else
    print(bWriteLog and "HandleItemEvent UnDoWeaponItemAction targetCharacter==nil nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
end
function HandleItemEvent:PickupItem(nEventType, nEventID, nPlayerKey, nItemID, nCount, nReason)
  local ItemEventData = self.EventDataMgr:GetData(nEventType)
  if ItemEventData then
    local ItemActionCfgData = ItemEventData:GetItemActionTable(nItemID, nEventID)
    if ItemActionCfgData and ItemActionCfgData.ActionTypeAddInfo == nReason then
      return
    end
  end
  self:DoItemAction(nEventType, nEventID, nPlayerKey, nItemID)
end
function HandleItemEvent:DropItem(nEventType, nEventID, nPlayerKey, nItemID, nCount, nReason)
  self:UnDoItemAction(nEventType, nEventID, nPlayerKey, nItemID, EVENTID_PLAYEREVENT_PICKUPITEM)
end
function HandleItemEvent:ConsumeItem(nEventType, nEventID, uPawn, nItemID, nCount)
  if uPawn.GetPlayerKey then
    local nPlayerKey = tonumber(uPawn:GetPlayerKey())
    self:DoItemAction(nEventType, nEventID, nPlayerKey, nItemID)
  end
end
function HandleItemEvent:CleanupItem(nEventType, nEventID, nPlayerKey, nItemID)
  self:DoItemAction(nEventType, EVENTID_PLAYEREVENT_BACKPACKITEM_CLEANUP, nPlayerKey, nItemID)
end
function HandleItemEvent:EquipItem(nEventType, nEventID, nPlayerKey, nItemID, nInstanceId)
  local ItemCfg = CDataTable.GetTableData("Item", nItemID)
  if not ItemCfg then
    return print("HandleItemEvent:EquipItem ItemCfg nil Error nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsWeapon(ItemCfg.ItemType) or ItemCfg.ItemType == ENUM_ITEM_TYPE.Medicine then
    self:DoWeaponItemAction(nEventType, nEventID, nPlayerKey, nItemID, nInstanceId)
  else
    self:DoItemAction(nEventType, nEventID, nPlayerKey, nItemID)
  end
end
function HandleItemEvent:UnEquipItem(nEventType, nEventID, nPlayerKey, nItemID, nInstanceId)
  local ItemCfg = CDataTable.GetTableData("Item", nItemID)
  if not ItemCfg then
    return print("HandleItemEvent:EquipItem ItemCfg nil Error nPlayerKey:" .. nPlayerKey .. ", nItemID" .. nItemID .. ", Instanceid" .. nInstanceId)
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsWeapon(ItemCfg.ItemType) or ItemCfg.ItemType == ENUM_ITEM_TYPE.Medicine then
    self:UnDoWeaponItemAction(nEventType, nEventID, nPlayerKey, nItemID, nInstanceId, EVENTID_PLAYEREVENT_EQUIPITEM)
  else
    self:UnDoItemAction(nEventType, nEventID, nPlayerKey, nItemID, EVENTID_PLAYEREVENT_EQUIPITEM)
  end
end
function HandleItemEvent:UseItem(nEventType, nEventID, nPlayerKey, nItemID, nReason)
  self:DoItemAction(nEventType, nEventID, nPlayerKey, nItemID)
end
function HandleItemEvent:DisUseItem(nEventType, nEventID, nPlayerKey, nItemID, nReason)
  self:UnDoItemAction(nEventType, nEventID, nPlayerKey, nItemID, EVENTID_PLAYEREVENT_USEITEM)
end
local class = require("class")
local CEventBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleEventBase")
local CHandleItemEvent = class(CEventBase, nil, HandleItemEvent)
return CHandleItemEvent