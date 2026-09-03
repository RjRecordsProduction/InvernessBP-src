local LobbyEmoteManager = {}
local C_Milestone_MultiLevel_ModuleID = 5
local C_TableName_MilestoneConfig = "MilestoneConfig"
local C_TableName_MilestoneTabConfig = "MilestoneTabConfig"
function LobbyEmoteManager:DefineAndResetData()
  self.WeaponMilestoneSlot = {}
  self.ClothMilestoneSlot = {}
  self.VehicleMilestoneSlot = {}
  self.MilestoneSlotMap = {}
  self.AcquiredMileList = {}
  self.bHaveReceivedMileData = false
  self.ClickCDMap = {}
  self.MultiLevelInfo = nil
  self.AllExpressions = {}
  self.ExpressionsSet = {}
  self._nCurUseMilestone = 0
end
function LobbyEmoteManager:OnPreSwitchGameStatus()
  self.WeaponMilestoneSlot = {}
  self.ClothMilestoneSlot = {}
  self.VehicleMilestoneSlot = {}
  self.MilestoneSlotMap = {}
  self.AcquiredMileList = {}
  self.bHaveReceivedMileData = false
  self.ClickCDMap = {}
  self.AllExpressions = {}
  self.ExpressionsSet = {}
end
function LobbyEmoteManager:ConstructingSlotString(slot)
  local strT = {}
  slot = slot or {}
  for i = 1, 4 do
    if slot[i] then
      strT[#strT + 1] = tostring(slot[i])
    else
      strT[#strT + 1] = tostring(0)
    end
  end
  return table.concat(strT, "|")
end
function LobbyEmoteManager:GetMilestoneSlot(sysType)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  if collect_cfg.E_Milestone_Server_Type.firearms == sysType then
    return self.WeaponMilestoneSlot or {}
  elseif collect_cfg.E_Milestone_Server_Type.outfits == sysType then
    return self.ClothMilestoneSlot or {}
  elseif collect_cfg.E_Milestone_Server_Type.Vehicle == sysType then
    return self.VehicleMilestoneSlot or {}
  elseif sysType and self.MilestoneSlotMap[sysType] then
    return self.MilestoneSlotMap[sysType] or {}
  end
  return {}
end
function LobbyEmoteManager:GetMilestoneEmotionMark()
  local emoMark = {}
  local markEmote = function(slots)
    if not slots then
      return
    end
    for i = 1, 4 do
      if slots[i] then
        local id = self:GetExpressionIDByItemID(slots[i])
        if 0 < id and not emoMark[id] then
          emoMark[id] = true
        end
      end
    end
  end
  markEmote(self.WeaponMilestoneSlot)
  markEmote(self.ClothMilestoneSlot)
  markEmote(self.VehicleMilestoneSlot)
  for t, slot in pairs(self.MilestoneSlotMap) do
    markEmote(slot)
  end
  return emoMark
end
function LobbyEmoteManager:SetSelfSocialLobbyShowMilestone(nCurUseMilestone)
  self._  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_COLLECT_MILESTONE_CHANGE)
end
function LobbyEmoteManager:GetSelfSocialLobbyShowMilestone()
  return self._nCurUseMilestone
end
function LobbyEmoteManager:GetSelfSocialLobbyShowMilestoneType()
  local nCurUseMilestone = self._nCurUseMilestone
  if not nCurUseMilestone or nCurUseMilestone == 0 then
    return
  end
  local uMilestoneCfg = CDataTable.GetTableData("MilestoneConfig", nCurUseMilestone)
  if not uMilestoneCfg then
    return
  end
  return uMilestoneCfg.Type
end
function LobbyEmoteManager:AddMileStoneExtraInfo(UID, ExtraInfo, actionID)
  ExtraInfo = ExtraInfo or ""
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  local sysType = logic_emote.GetMileStoneTypeByItemID(actionID)
  sysType = sysType or collect_cfg.E_Milestone_Server_Type.firearms
  local Slot = {}
  if DataMgr.IsMe(tonumber(UID)) then
    if collect_cfg.E_Milestone_Server_Type.outfits == sysType then
      Slot = self.ClothMilestoneSlot or {}
    elseif collect_cfg.E_Milestone_Server_Type.firearms == sysType then
      Slot = self.WeaponMilestoneSlot or {}
    elseif collect_cfg.E_Milestone_Server_Type.Vehicle == sysType then
      Slot = self.VehicleMilestoneSlot or {}
    elseif self.MilestoneSlotMap and self.MilestoneSlotMap[sysType] then
      Slot = self.MilestoneSlotMap[sysType] or {}
    end
  else
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local setData = TeamUpNewSystem.GetMileStoneData(UID)
    if setData then
      if collect_cfg.E_Milestone_Server_Type.outfits == sysType then
        Slot = setData.cloth_set or {}
      elseif collect_cfg.E_Milestone_Server_Type.firearms == sysType then
        Slot = setData.weapon_set or {}
      elseif collect_cfg.E_Milestone_Server_Type.Vehicle == sysType then
        Slot = setData.vehicle_set or {}
      elseif setData.extra_set and setData.extra_set[sysType] then
        Slot = setData.extra_set[sysType] or {}
      end
    end
  end
  return ExtraInfo .. self:ConstructingSlotString(Slot)
end
function LobbyEmoteManager:GetSelfMilestoneSlotExtraInfo(sysType)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  if collect_cfg.E_Milestone_Server_Type.outfits == sysType then
    return self:ConstructingSlotString(self.ClothMilestoneSlot)
  elseif collect_cfg.E_Milestone_Server_Type.firearms == sysType then
    return self:ConstructingSlotString(self.WeaponMilestoneSlot)
  elseif collect_cfg.E_Milestone_Server_Type.Vehicle == sysType then
    return self:ConstructingSlotString(self.VehicleMilestoneSlot)
  elseif sysType and self.MilestoneSlotMap[sysType] then
    return self:ConstructingSlotString(self.MilestoneSlotMap[sysType])
  end
end
function LobbyEmoteManager:CheckMilestoneEquipment(resID, sysType)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local temp = {}
  if collect_cfg.E_Milestone_Server_Type.outfits == sysType then
    temp = self.ClothMilestoneSlot
  elseif collect_cfg.E_Milestone_Server_Type.firearms == sysType then
    temp = self.WeaponMilestoneSlot
  elseif collect_cfg.E_Milestone_Server_Type.Vehicle == sysType then
    temp = self.VehicleMilestoneSlot
  elseif sysType and self.MilestoneSlotMap[sysType] then
    temp = self.MilestoneSlotMap[sysType] or {}
  end
  for i = 1, 4 do
    if resID == temp[i] then
      return true
    end
  end
  return false
end
function LobbyEmoteManager:ReqSelfMileStoneData()
  if self.bHaveReceivedMileData then
    log(bWriteLog and "LobbyEmoteManager:ReqSelfMileStoneData bHaveReceivedMileData")
    return
  end
  local EmoteHandler = require("client.network.Protocol.EmoteHandler")
  EmoteHandler.send_get_all_milestone_data_req()
end
function LobbyEmoteManager:OnMileStoneDataRsp(all_tbl, cloth_set, weapon_set, vehicle_set, extra_set, all_expressions, expressions_set, smp_show_milestone)
  self.bHaveReceivedMileData = true
  self.AcquiredMileList = all_tbl or {}
  self.ClothMilestoneSlot = cloth_set or {}
  self.WeaponMilestoneSlot = weapon_set or {}
  self.VehicleMilestoneSlot = vehicle_set or {}
  self.MilestoneSlotMap = extra_set or {}
  self.AllExpressions = all_expressions or {}
  self.ExpressionsSet = expressions_set or {}
  self._nCurUseMilestone = smp_show_milestone or 0
  EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_MILELIST_DATA_CHANGE)
end
function LobbyEmoteManager:AddAcquiredMilestone(item_info)
  if not self.AcquiredMileList then
    self.AcquiredMileList = {}
  end
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  for i, v in pairs(item_info) do
    self.AcquiredMileList[v] = 1
    local cfg = collect_module:GetSplitTableData(C_TableName_MilestoneConfig, collect_module.E_ColCfgMode.Def, v)
    if cfg then
      local tab = collect_cfg.serverType2MilestoneTab[cfg.Type]
      local key = collect_cfg.C_Milestone_Tab_Text_List[tab]
      reddot_node_collect_manager:AddMilestoneRedPoint(key)
    end
  end
end
function LobbyEmoteManager:CheckSelfMilestoneAcquired(itemID)
  return self.AcquiredMileList[itemID] == 1
end
function LobbyEmoteManager:NeedShowMileStoneNewBie()
  local has = false
  local TableUtil = require("common.table_util")
  for t, map in pairs(self.MilestoneSlotMap) do
    if TableUtil.CountTable(map) > 0 then
      has = true
      break
    end
  end
  if not has and TableUtil.CountTable(self.WeaponMilestoneSlot) < 1 and 1 > TableUtil.CountTable(self.ClothMilestoneSlot) and TableUtil.CountTable(self.VehicleMilestoneSlot) then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local isClickTab1 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMileStoneNewBie)
  if isClickTab1 and isClickTab1.isClick then
    return false
  end
  return true
end
function LobbyEmoteManager:RecordHasShowMileStoneNewBie()
  local isClickTab1 = {isClick = true}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(isClickTab1, PlayerPrefsSystem.ePlayerPrefsType.eMileStoneNewBie)
end
function LobbyEmoteManager:RecordClickTime(key)
  local TimeUtil = require("client.common.time_util")
  self.ClickCDMap[key] = TimeUtil.GetMiliseconds()
end
function LobbyEmoteManager:GetLastClickTime(key)
  return self.ClickCDMap[key] or 0
end
function LobbyEmoteManager:SetMilestoneSlotInfo(sysType, slots, expressionID)
  local EmoteHandler = require("client.network.Protocol.EmoteHandler")
  EmoteHandler.send_save_milestone_slot_info_req(sysType, slots, expressionID)
end
function LobbyEmoteManager:ResMilestoneSlotInfo(sysType, slots, expression_id)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  if sysType == collect_cfg.E_Milestone_Server_Type.outfits then
    self.ClothMilestoneSlot = slots
  elseif sysType == collect_cfg.E_Milestone_Server_Type.firearms then
    self.WeaponMilestoneSlot = slots
  elseif collect_cfg.E_Milestone_Server_Type.Vehicle == sysType then
    self.VehicleMilestoneSlot = slots
  elseif sysType and slots then
    self.MilestoneSlotMap[sysType] = slots
  end
  if expression_id and 0 < expression_id then
    self.ExpressionsSet = self.ExpressionsSet or {}
    self.ExpressionsSet[sysType] = expression_id
  end
  EventSystem:postEvent(EVENTTYPE_MILESTONE, EVENTID_MILESTONE_UPDATE_EQUIPPED)
  ShowNotice(82024)
end
local sortMilestones = function(a, b)
  if a.acquired == b.acquired then
    return a.sortID > b.sortID
  else
    return a.acquired
  end
end
function LobbyEmoteManager:GetMilestones(sysType, acquiredList, filterNotAcquired)
  acquiredList = acquiredList or self.AcquiredMileList
  self:InitMilestoneMultiList()
  local info = self.MultiLevelInfo
  local groupSim = {}
  for groupID, items in pairs(info.groupID2Items) do
    local maxID = info.groupID2MaxID[groupID]
    local sID, sLevel
    for level, itemID in pairs(items) do
      if not (itemID ~= maxID and acquiredList[itemID]) or sID and level < sLevel then
      else
        sID = itemID
        sLevel = level
      end
    end
    if acquiredList[maxID] then
      groupSim[maxID] = true
    elseif sID then
      groupSim[sID] = true
    elseif filterNotAcquired then
    else
      groupSim[maxID] = true
    end
  end
  return self:GetMilestonesConfig(sysType, groupSim, info.itemID2GroupID, acquiredList, filterNotAcquired)
end
function LobbyEmoteManager:GetMilestonesConfig(mileType, groupSim, itemID2GroupID, acquiredList, filterNotAcquired)
  local cfg = CDataTable.GetTableByFilter(C_TableName_MilestoneConfig, "Type", mileType)
  if not cfg then
    log(bWriteLog and string.format("LobbyEmoteManager GetMilestonesConfig MilestoneConfig is empty."))
    return {}
  end
  local checkShow = function(itemData, ID)
    local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
    if collect_encryption_module:IsEncryption(ID) then
      return false
    end
    if not itemData then
      return false
    end
    if groupSim[ID] then
      return true
    end
    if not itemID2GroupID[ID] then
      if not filterNotAcquired then
        return true
      else
        return acquiredList[ID]
      end
    end
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local result = {}
  for id, v in pairs(cfg) do
    local itemData = CDataTable.GetTableData("Item", v.ID)
    if checkShow(itemData, v.ID) then
      local temp = {
        sortID = id,
        itemID = v.ID,
        name = itemData.ItemName,
        emoteID = v.EmoteID,
        sysType = mileType,
        acquired = acquiredList[v.ID] == 1,
        entryName1 = v.EntryName1,
        entryDec1 = v.EntryDec1,
        entryIcon1 = v.EntryIcon1,
        entryName2 = v.EntryName2,
        entryDec2 = v.EntryDec2,
        entryIcon2 = v.EntryIcon2,
        entryName3 = v.EntryName3,
        entryDec3 = v.EntryDec3,
        entryIcon3 = v.EntryIcon3
      }
      result[#result + 1] = temp
    end
  end
  table.sort(result, sortMilestones)
  return result
end
function LobbyEmoteManager:GetMilestoneGroupItemsByItemID(itemID)
  self:InitMilestoneMultiList()
  local info = self.MultiLevelInfo
  if info.itemID2GroupID[itemID] then
    return info.groupID2Items[info.itemID2GroupID[itemID]] or {}
  else
    return {itemID}
  end
end
function LobbyEmoteManager:GetMilestoneGroupMaxItemByItemID(itemID)
  self:InitMilestoneMultiList()
  local info = self.MultiLevelInfo
  if info.itemID2GroupID[itemID] then
    return info.groupID2MaxID[info.itemID2GroupID[itemID]] or {}
  else
    return itemID
  end
end
function LobbyEmoteManager:InitMilestoneMultiList()
  if self.MultiLevelInfo then
    return
  end
  local list = CDataTable.GetTableByFilter("MultiLevelItem", "ModuleID", C_Milestone_MultiLevel_ModuleID)
  local itemID2Level = {}
  local itemID2GroupID = {}
  local groupID2MaxID = {}
  local groupID2Items = {}
  for itemID, data in pairs(list) do
    local gID = data.GroupID
    local level = data.Level
    itemID2Level[itemID] = level
    itemID2GroupID[itemID] = gID
    if not groupID2Items[gID] then
      groupID2Items[gID] = {}
    end
    groupID2Items[gID][level] = itemID
    if not groupID2MaxID[gID] then
      groupID2MaxID[gID] = itemID
    else
      local le = itemID2Level[groupID2MaxID[gID]] or 0
      if level > le then
        groupID2MaxID[gID] = itemID
      end
    end
  end
  self.MultiLevelInfo = {
    groupID2MaxID = groupID2MaxID,
    groupID2Items = groupID2Items,
      }
end
function LobbyEmoteManager:GetMilestoneUPIcon(itemID)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local cfg = collect_module:GetSplitTableData(C_TableName_MilestoneConfig, collect_module.E_ColCfgMode.Def, itemID)
  if cfg then
    return cfg.UPIcon
  end
  return ""
end
function LobbyEmoteManager:GetMilestoneTypeByItemID(itemID)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local cfg = collect_module:GetSplitTableData(C_TableName_MilestoneConfig, collect_module.E_ColCfgMode.Def, itemID)
  if cfg then
    return cfg.Type
  end
  return nil
end
function LobbyEmoteManager:IsMilestoneTabEncryption(sysType)
  log(bWriteLog and string.format("LobbyEmoteManager:IsMilestoneTabEncryption sysType = %s", sysType))
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local config = collect_module:GetSplitTableData(C_TableName_MilestoneTabConfig, collect_module.E_ColCfgMode.Def, sysType)
  if not config then
    log(bWriteLog and string.format("LobbyEmoteManager:IsMilestoneTabEncryption this item is not config. sysType = %s", sysType))
    return false
  end
  local version = config.Version
  log(bWriteLog and string.format("LobbyEmoteManager:IsMilestoneTabEncryption Version = %s", version))
  if version and version ~= "" and not FuncUtil.CompareVersion(Client.GetApplicationVersion(), version) then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local current = TimeUtil.GetServerTimeInSec()
  local startTime = config.StartTime
  log(bWriteLog and string.format("LobbyEmoteManager:IsMilestoneTabEncryption startTime = %s", startTime))
  if startTime and startTime ~= "" then
    local show = TimeUtil.TimeStringToUnixstamp(startTime)
    if current < show then
      return true
    end
  end
  local endTime = config.EndTime
  log(bWriteLog and string.format("LobbyEmoteManager:IsMilestoneTabEncryption endTime = %s", endTime))
  if endTime and endTime ~= "" then
    local show = TimeUtil.TimeStringToUnixstamp(endTime)
    if current > show then
      return true
    end
  end
  return false
end
function LobbyEmoteManager:GetExpressionIDBySysType(sysType)
  local id = 0
  if self.ExpressionsSet and self.ExpressionsSet[sysType] then
    id = self.ExpressionsSet[sysType]
  else
    local configs = CDataTable.GetTableByFilter(C_TableName_MilestoneConfig, "Type", sysType)
    for i, cfg in pairs(configs) do
      local emotes = self:GetEmotesByMilestoneConfig(cfg)
      if emotes and 0 < #emotes then
        id = tonumber(emotes[1])
        break
      end
    end
  end
  return id
end
function LobbyEmoteManager:GetExpressionListBySysType(sysType)
  local configs = CDataTable.GetTableByFilter(C_TableName_MilestoneConfig, "Type", sysType)
  local result, emoteSet = {}, {}
  for _, cfg in pairs(configs) do
    local emotes = self:GetEmotesByMilestoneConfig(cfg)
    if emotes and 0 < #emotes then
      for _, emoteID in ipairs(emotes) do
        if not emoteSet[emoteID] then
          emoteSet[emoteID] = true
          result[#result + 1] = emoteID
        end
      end
    end
  end
  return result
end
function LobbyEmoteManager:GetEmotesByMilestoneConfig(config)
  if config and config.EmoteID ~= "" then
    local StringUtil = require("common.string_util")
    local emotes = StringUtil.Split(config.EmoteID, ";")
    return emotes
  end
  return {}
end
function LobbyEmoteManager:GetExpressionIDByItemID(itemID)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local cfg = collect_module:GetSplitTableData(C_TableName_MilestoneConfig, collect_module.E_ColCfgMode.Def, itemID)
  local id = 0
  if not cfg then
    log(bWriteLog and string.format("LobbyEmoteManager:GetExpressionIDByItemID: itemID:%s cfg is nil.", itemID))
    return id
  end
  if self.ExpressionsSet and self.ExpressionsSet[cfg.Type] then
    id = self.ExpressionsSet[cfg.Type]
  else
    local emotes = self:GetEmotesByMilestoneConfig(cfg)
    if emotes and 0 < #emotes then
      id = tonumber(emotes[1])
    end
  end
  return id
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLobbyEmoteManager = class(CModuleBase, nil, LobbyEmoteManager)
return CLobbyEmoteManager