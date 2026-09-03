local ItemEventData = {
  ItemActionType = {
    PICKUP = 1,
    EQUIP = 2,
    USE = 3,
    CONSUME = 6,
    ItemCleanUp = 7,
    WeaponItemEQUIP = 8
  }
}
function ItemEventData:Init(bClient)
  ItemEventData.__super.Init(self, bClient)
  self.ItemEventIDToOprType = {}
  self.ItemEventIDToOprType[EVENTID_PLAYEREVENT_PICKUPITEM] = self.ItemActionType.PICKUP
  self.ItemEventIDToOprType[EVENTID_PLAYEREVENT_EQUIPITEM] = self.ItemActionType.EQUIP
  self.ItemEventIDToOprType[EVENTID_PLAYEREVENT_EQUIPWEAPONTANDATTACHITEM] = self.ItemActionType.WeaponItemEQUIP
  self.ItemEventIDToOprType[EVENTID_PLAYEREVENT_USEITEM] = self.ItemActionType.USE
  self.ItemEventIDToOprType[EVENTID_PLAYEREVENT_CONSUMEITEM] = self.ItemActionType.CONSUME
  self.ItemEventIDToOprType[EVENTID_PLAYEREVENT_BACKPACKITEM_CLEANUP] = self.ItemActionType.ItemCleanUp
  self.ItemIdToEventActions = nil
end
function ItemEventData:InitItemActionTable()
  if self.ItemIdToEventActions == nil then
    local cfgItemActionTable
    if self.IsClient then
      cfgItemActionTable = CDataTable.GetTable("ItemActionTable")
    else
      cfgItemActionTable = CDataTable.GetTable("ItemActionTable")
    end
    if cfgItemActionTable == nil then
      return
    end
    self.ItemIdToEventActions = {}
    for i, actionCfg in pairs(cfgItemActionTable) do
      if actionCfg.ItemID then
        if self.ItemIdToEventActions[actionCfg.ItemID] == nil then
          self.ItemIdToEventActions[actionCfg.ItemID] = {}
        end
        if actionCfg.ActionType then
          self.ItemIdToEventActions[actionCfg.ItemID][actionCfg.ActionType] = actionCfg
        end
      end
    end
  end
end
function ItemEventData:GetItemActionTableData(itemID, eventID)
  if itemID == nil or eventID == nil or self.ItemEventIDToOprType == nil then
    return
  end
  local itemActionType = self.ItemEventIDToOprType[eventID]
  if itemActionType == nil then
    return
  end
  if self.ItemIdToEventActions == nil then
    self:InitItemActionTable()
  end
  if self.ItemIdToEventActions and self.ItemIdToEventActions[itemID] then
    return self.ItemIdToEventActions[itemID][itemActionType]
  end
end
function ItemEventData:Clear()
  ItemEventData.__super.Clear(self)
  self.ItemEventIDToOprType = nil
  self.ItemIdToEventActions = nil
end
function ItemEventData:GetItemTable(ResID)
  local itemCfg = self:GetTableData("Item", ResID)
  return itemCfg
end
function ItemEventData:GetBPTable(ResID)
  local itemTable = self:GetItemTable(ResID)
  if itemTable then
    local BPTable
    if itemTable.ItemType == ENUM_ITEM_TYPE.Extra then
      BPTable = self:GetTableData("AvatarBPTable", itemTable.BPID)
    elseif itemTable.ItemType == 3 then
      BPTable = self:GetTableData("ConsumableBPTable", itemTable.BPID)
    end
    return BPTable
  end
  return nil
end
function ItemEventData:GetItemActionTable(ResID, nEventID)
  return self:GetItemActionTableData(ResID, nEventID)
end
local class = require("class")
local CEventDataBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventData.EventData.EventDataBase")
local CItemEventData = class(CEventDataBase, nil, ItemEventData)
return CItemEventData