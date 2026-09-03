local logic_home_door_plate = {}
local defaultSkinId = 66660001
function logic_home_door_plate:DefineAndResetData()
  self.skinList = {}
  self.curSkinID = defaultSkinId
end
function logic_home_door_plate:_SortSkinList()
  table.sort(self.skinList, function(a, b)
    local aIsUse = a.bIsUse == true
    local bIsUse = b.bIsUse == true
    if aIsUse ~= bIsUse then
      return aIsUse
    end
    local aReddot = a.bReddot == true
    local bReddot = b.bReddot == true
    if aReddot ~= bReddot then
      return aReddot
    end
    local aIsLock = a.bIsLock == true
    local bIsLock = b.bIsLock == true
    if aIsLock ~= bIsLock then
      return not aIsLock
    end
    return a.cfg.Sort < b.cfg.Sort
  end)
end
function logic_home_door_plate:OnInitialize()
end
function logic_home_door_plate:RegistEvents()
end
function logic_home_door_plate:OnLogin(bReLogin)
end
function logic_home_door_plate:OnLogOut()
end
function logic_home_door_plate:OnPreSwitchGameStatus(preState, nextState)
end
function logic_home_door_plate:OnPostSwitchGameStatus(preState, nextState)
end
function logic_home_door_plate:GetSkinList()
  return self.skinList
end
function logic_home_door_plate:GetCurSkinID()
  return self.curSkinID
end
function logic_home_door_plate:GetSkinDataById(id)
  for _, data in ipairs(self.skinList) do
    if data.cfg.ID == id then
      return data
    end
  end
  return nil
end
function logic_home_door_plate:GetSkinConfigById(id)
  return CDataTable.GetTableData("DoorPlate", id)
end
function logic_home_door_plate:GetSkinPosInfoById(id, type)
  local config = CDataTable.GetTableData("DoorPlatePosInfo", id)
  if not config then
    log(bWriteLog and string.format("logic_home_door_plate:GetSkinPosInfoById, wrong id:%s", id))
    return nil
  end
  local posInfo = config[type]
  local StringUtil = require("common.string_util")
  posInfo = StringUtil.StrReplace(posInfo, "{", "")
  posInfo = StringUtil.StrReplace(posInfo, "}", "")
  posInfo = StringUtil.Split(posInfo, ";")
  local pos = FVector(posInfo[1], posInfo[2], posInfo[3])
  local rotate = FRotator(posInfo[4], posInfo[5], posInfo[6])
  local scale = FVector(posInfo[7], posInfo[8], posInfo[9])
  return pos, rotate, scale
end
function logic_home_door_plate:GetDoorPlateColorById(id)
  if not id then
    id = defaultSkinId
  else
    id = tonumber(id)
  end
  local config = CDataTable.GetTableData("DoorPlate", id)
  config = config or CDataTable.GetTableData("DoorPlate", defaultSkinId)
  local color = config.DoorPlateColor
  local StringUtil = require("common.string_util")
  color = StringUtil.SplitToNum(color, ";")
  return FLinearColor(color[1] / 255, color[2] / 255, color[3] / 255, color[4] / 255)
end
function logic_home_door_plate:GetNamePlateColorById(id)
  local config = CDataTable.GetTableData("DoorPlate", id)
  local color = config.NamePlateColor
  local StringUtil = require("common.string_util")
  color = StringUtil.SplitToNum(color, ";")
  return FLinearColor(color[1] / 255, color[2] / 255, color[3] / 255, color[4] / 255)
end
function logic_home_door_plate:RemoveRedDot(id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local redPointData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDoorPlateSkinRedPoint) or {}
  redPointData[DataMgr.roleData.uid][id] = nil
  PlayerPrefsSystem.SaveTableToFile_N(redPointData, PlayerPrefsSystem.ePlayerPrefsType.eDoorPlateSkinRedPoint)
  for _, data in ipairs(self.skinList) do
    if data.cfg.ID == id then
      data.bReddot = false
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_DOORPLATE_REDDOT)
end
function logic_home_door_plate:GetDefaultSkinId()
  return defaultSkinId
end
function logic_home_door_plate:HaveNew()
  local bReddot = false
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local redPointData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDoorPlateSkinRedPoint) or {}
  if redPointData[DataMgr.roleData.uid] and next(redPointData[DataMgr.roleData.uid]) then
    for id, _ in pairs(redPointData[DataMgr.roleData.uid]) do
      local config = CDataTable.GetTableData("DoorPlate", id)
      if config and config.DefaultDisplay ~= 0 then
        bReddot = true
        return bReddot
      end
    end
  end
  return bReddot
end
function logic_home_door_plate:UpdateJointSkin(skinId)
  log(bWriteLog and "logic_home_door_plate:UpdateJointSkin to " .. tostring(skinId))
  if not self.skinList then
    self.skinList = {}
  end
  local tmpInfo
  if skinId then
    local skinConfig = CDataTable.GetTable("DoorPlate")
    if not skinConfig then
      log(bWriteLog and "logic_home_door_plate:UpdateJointSkin: Failed to update due to nil skinConfig table")
      return
    end
    tmpInfo = {
      cfg = skinConfig[skinId],
      bIsLock = false,
      bIsUse = true,
      bIsSelected = true,
      bIsSelf = false,
      bReddot = false
    }
  end
  self.skinList[0] = tmpInfo
end
function logic_home_door_plate:GetJointSkinInfo()
  return self.skinList and self.skinList[0] or nil
end
function logic_home_door_plate:send_get_manor_skin_data_req()
  local PHomeDoorPlateHandler = require("client.network.Protocol.PHomeDoorPlateHandler")
  PHomeDoorPlateHandler.send_get_manor_skin_data_req()
end
function logic_home_door_plate:on_get_manor_skin_data_rsp(manor_skin)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local redPointData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDoorPlateSkinRedPoint) or {}
  local skinConfig = CDataTable.GetTable("DoorPlate")
  local TimeUtil = require("client.common.time_util")
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  self.skinList = {}
  if manor_skin and manor_skin.cur_skin_id then
    self.curSkinID = manor_skin.cur_skin_id
  else
    log(bWriteLog and "logic_home_door_plate:on_get_manor_skin_data_rsp failed to update data due to nil ")
  end
  if not manor_skin.unlocked_skin_list then
    manor_skin.unlocked_skin_list = {}
  end
  local bIsUsingSelf = true
  if manor_skin.operators then
    bIsUsingSelf = tonumber(manor_skin.operators) == tonumber(DataMgr.roleData.uid)
  end
  for id, data in pairs(skinConfig) do
    id = tonumber(id)
    local info = {
      cfg = data,
      bIsLock = manor_skin.unlocked_skin_list[id] == nil,
      bIsUse = id == manor_skin.cur_skin_id and bIsUsingSelf,
      bIsSelected = id == manor_skin.cur_skin_id and bIsUsingSelf,
      bIsSelf = true,
      bReddot = redPointData[DataMgr.roleData.uid] and redPointData[DataMgr.roleData.uid][id] and manor_skin.unlocked_skin_list[id] ~= nil
    }
    local isStartShow = TimeUtil.GetServerTimeInSec() >= TimeUtil.TimeStringToUnixstamp(data.BeginShowTime)
    if not isStartShow or info.cfg.DefaultDisplay == 0 and info.bIsLock then
    else
      if id == defaultSkinId then
        info.bIsLock = false
        info.bReddot = false
      end
      if not logic_home_joint:HasJointHome() and info.cfg.IsDoubleDoorplate == 1 then
        info.bIsLock = true
      end
      table.insert(self.skinList, info)
    end
  end
  self:_SortSkinList()
  if not bIsUsingSelf then
    self:UpdateJointSkin(manor_skin.cur_skin_id)
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_DOORPLATE)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_DOORPLATE_REDDOT)
end
function logic_home_door_plate:send_change_manor_skin_req(target_skin_id)
  local PHomeDoorPlateHandler = require("client.network.Protocol.PHomeDoorPlateHandler")
  PHomeDoorPlateHandler.send_change_manor_skin_req(target_skin_id)
end
function logic_home_door_plate:on_change_manor_skin_rsp(target_skin_id)
  self:UpdateJointSkin(nil)
  for _, data in ipairs(self.skinList) do
    if data.cfg.ID == self.curSkinID then
      data.bIsUse = false
    end
    if data.cfg.ID == target_skin_id then
      data.bIsUse = true
    end
  end
  self.curSkinID = target_skin_id
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  logic_home_profile:UpdatePlayerHomeProfile(tonumber(DataMgr.roleData.uid), "cur_skin_id", target_skin_id)
  self:_SortSkinList()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHANGE_DOORPLATE, target_skin_id)
end
function logic_home_door_plate:on_new_manor_skin_notify(new_skin_id)
  local config = CDataTable.GetTableData("DoorPlate", new_skin_id)
  if not config then
    log(bWriteLog and string.format("logic_home_door_plate:on_new_manor_skin_notify, new_skin_id:%s config == nil", new_skin_id))
    return
  end
  if config.DefaultDisplay == 0 then
    log(bWriteLog and string.format("logic_home_door_plate:on_new_manor_skin_notify, new_skin_id:%s DefaultDisplay == 0", new_skin_id))
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local redPointData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDoorPlateSkinRedPoint) or {}
  local selfData = redPointData[DataMgr.roleData.uid] or {}
  for _, data in ipairs(self.skinList) do
    if data.cfg.ID == new_skin_id then
      data.bReddot = true
      data.bIsLock = false
      break
    end
  end
  selfData[new_skin_id] = true
  redPointData[DataMgr.roleData.uid] = selfData
  PlayerPrefsSystem.SaveTableToFile_N(redPointData, PlayerPrefsSystem.ePlayerPrefsType.eDoorPlateSkinRedPoint)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_DOORPLATE_REDDOT)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_home_door_plate = class(CModuleBase, nil, logic_home_door_plate)
return Clogic_home_door_plate