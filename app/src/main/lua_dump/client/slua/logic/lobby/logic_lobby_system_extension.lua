local logic_lobby_system_extension = {}
local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
function logic_lobby_system_extension:DefineAndResetData()
  self.systemID_to_moduleID = {}
  self.moduleID_to_systemID = {}
  self.mainSystemList = nil
  self.maincitySystemList = {}
  self.mainSystemXunYou = nil
end
function logic_lobby_system_extension:OnInitialize()
  self:_LoadConfig()
end
function logic_lobby_system_extension:_LoadConfig()
  self:_LoadConfigToList("MainUISystem", "mainSystemList")
  self:_LoadConfigToList("MainCityUISystem", "maincitySystemList")
end
function logic_lobby_system_extension:_LoadConfigToList(tableName, keyName)
  self[keyName] = {}
  local mainSystemTable = CDataTable.GetTable(tableName)
  if not mainSystemTable then
    return
  end
  for _, v in pairs(mainSystemTable) do
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(v.module)
    local moduleId = tonumber(params.module)
    self.systemID_to_moduleID[v.SystemID] = moduleId
    if self:_CheckSystemOpen(v) then
      log(bWriteLog and "logic_lobby_system_extension:_LoadConfig CheckSystemOpen  SystemID: " .. v.SystemID)
      local item = self:_CreateItemInfo(v)
      if self.systemID_to_moduleID[v.SystemID] == BP_ENUM_MODULE_XUN_YOU then
        local AccelSystem = require("client.slua.logic.gamemaster.logic_accel")
        if AccelSystem.IsServerEnableAccel() and AccelSystem.IsLocalEnableAccel() then
          self.mainSystemXunYou = item
        end
      else
        self[keyName][#self[keyName] + 1] = item
      end
    end
  end
  local _SortItem = function(a, b)
    return a.weights < b.weights
  end
  table.sort(self[keyName], _SortItem)
end
function logic_lobby_system_extension:_CheckSystemOpen(info)
  if not info then
    return false
  end
  local   if info.CloseInMatch and info.CloseInMatch == 1 and Client.IsMatchVersion and Client.IsMatchVersion() then
    return false
  end
  if info.Switch then
    local gameId = Client.GetITopGameId()
    local StringUtil = require("common.string_util")
    local gameIds = StringUtil.Split(info.Switch, "|")
    for _, v in pairs(gameIds) do
      if v == gameId and self:_CheckUISwithcer(info) then
        return true
      end
    end
  end
  return false
end
function logic_lobby_system_extension:_CheckMenuStatus(info)
  if info.UISwitch and info.UISwitch ~= "" and info.UISwitch ~= "0" then
    local StringUtil = require("common.string_util")
    local idList = StringUtil.Split(info.UISwitch, "|")
    local switch_id = 0
    if idList and 1 < #idList then
      local strPlatform = Client.GetDevicePlatformName()
      local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
      if strPlatform == DevicePlatformNameMacros.IOS then
        switch_id = tonumber(idList[2])
      else
        switch_id = tonumber(idList[1])
      end
    else
      switch_id = tonumber(idList[1])
    end
    return LobbySystem.CheckOpen(switch_id)
  end
  return true
end
function logic_lobby_system_extension:_CheckUISwithcer(info)
  if not info then
    return false
  end
  local bMenuOpen = logic_lobby_system_extension:_CheckMenuStatus(info)
  if not bMenuOpen then
    print(bWriteLog and "logic_lobby_system_extension:_CheckMenuStatus not open. info.SystemID" .. info.SystemID)
    return false
  end
  local SystemId = info.SystemId
  if SystemId == lobby_system_entrance_marco.SystemIDDefine.ASSEMBLY or SystemId == lobby_system_entrance_marco.MaincitySystemIDDefine.ASSEMBLY then
    local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
    return AssemblyActivitySystem.HasActivity()
  end
  if SystemId == lobby_system_entrance_marco.SystemIDDefine.VLINK_SDK or SystemId == lobby_system_entrance_marco.MaincitySystemIDDefine.VLINK_SDK then
    local logic_vlink_sdk = require("client.slua.logic.vlink_sdk.logic_vlink_sdk")
    if not logic_vlink_sdk.redPointcfgData or next(logic_vlink_sdk.redPointcfgData) == nil then
      return false
    end
    local redPointData = logic_vlink_sdk.redPointcfgData
    if redPointData and redPointData.isSwitch then
      return true
    else
      return false
    end
  end
  if SystemId == lobby_system_entrance_marco.SystemIDDefine.COMMUNITY or SystemId == lobby_system_entrance_marco.MaincitySystemIDDefine.COMMUNITY then
    local logic_community = require("client.slua.logic.community.logic_community")
    log(bWriteLog and "logic_lobby_system_extension:_CheckMenuStatus  no communtiy!!")
    return logic_community.GetShowEntry()
  end
  if SystemId == lobby_system_entrance_marco.SystemIDDefine.SUPERCORE_ENTRY or SystemId == lobby_system_entrance_marco.MaincitySystemIDDefine.SUPERCORE_ENTRY then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    if not ActivityNewSystem.CheckSuperVIP() then
      return false
    end
  end
  if SystemId == lobby_system_entrance_marco.SystemIDDefine.PREMIUM_HALL or SystemId == lobby_system_entrance_marco.MaincitySystemIDDefine.PREMIUM_HALL then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    if not ActivityNewSystem.CheckPremiumHallSVIP() then
      return false
    end
  end
  return bMenuOpen
end
function logic_lobby_system_extension:_CreateItemInfo(data)
  local itemInfo = {
    SystemID = data.SystemID,
    name = data.SystemName,
    module = data.module,
    weights = data.Weights,
    icon = data.Icon,
    h5Url = data.JumpH5Url,
    UISwitch = data.UISwitch
  }
  return itemInfo
end
function logic_lobby_system_extension:_RefreshAssemblyEntry(tableName, keyName)
  local systemId = tableName == "MainCityUISystem" and lobby_system_entrance_marco.MaincitySystemIDDefine.ASSEMBLY or lobby_system_entrance_marco.SystemIDDefine.ASSEMBLY
  local cfg = CDataTable.GetTableData(tableName, systemId)
  if not cfg then
    return
  end
  local existIndex
  for i, item in ipairs(self[keyName] or {}) do
    if item.SystemID == systemId then
      existIndex = i
      break
    end
  end
  if self:_CheckSystemOpen(cfg) then
    if not existIndex then
      self[keyName][#self[keyName] + 1] = self:_CreateItemInfo(cfg)
      table.sort(self[keyName], function(a, b)
        return a.weights < b.weights
      end)
    end
  elseif existIndex then
    table.remove(self[keyName], existIndex)
  end
end
function logic_lobby_system_extension:GetSystemEntranceInfo()
  local system_entrance_info = self:GetServerData()
  local tempInfo = {}
  for k, systemID in pairs(system_entrance_info) do
    if self.systemID_to_moduleID[systemID] then
      table.insert(tempInfo, systemID)
    end
  end
  return tempInfo
end
function logic_lobby_system_extension:GetFromType(systemID)
  local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
  if systemID < 10000 then
    return lobby_system_entrance_marco.FromType.Classic
  elseif 10000 < systemID and systemID < 20000 then
    return lobby_system_entrance_marco.FromType.Maincity
  end
end
function logic_lobby_system_extension:GetSystemEntranceInfo(fromType)
  local keyName = "MainUISystem"
  if fromType == lobby_system_entrance_marco.FromType.Maincity then
    keyName = "MainCityUISystem"
  end
  local system_entrance_info = LobbySystem.roleData.system_entrance_info or {}
  local tempInfo = {}
  for k, v in pairs(system_entrance_info) do
    local mainSystem = CDataTable.GetTableData(keyName, v)
    if self:_CheckSystemOpen(mainSystem) then
      table.insert(tempInfo, v)
    end
  end
  return tempInfo
end
function logic_lobby_system_extension:GetServerData()
  local system_entrance_info = LobbySystem.roleData.system_entrance_info or {}
  return system_entrance_info
end
function logic_lobby_system_extension:GetServerDataCount()
  local system_entrance_info = self:GetServerData()
  return #system_entrance_info
end
function logic_lobby_system_extension:_SetEntranceInfo(entrance_info)
  LobbySystem.roleData.system_  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_UPDATE_SYSTEM_ENTRANCE, entrance_info)
end
function logic_lobby_system_extension:GetMainModuleIDBySystemID(systemID)
  return self.systemID_to_moduleID[systemID]
end
function logic_lobby_system_extension:GetMainSystemID2ModuleIDMap()
  return self.systemID_to_moduleID
end
function logic_lobby_system_extension:GetMainSystemList()
  self:_RefreshAssemblyEntry("MainUISystem", "mainSystemList")
  return self.mainSystemList
end
function logic_lobby_system_extension:GetMainCitySystemList()
  self:_RefreshAssemblyEntry("MainCityUISystem", "maincitySystemList")
  return self.maincitySystemList
end
function logic_lobby_system_extension:GetMainCitySystemInfoByID(systemID)
  if not next(self.maincitySystemList) then
    return nil
  end
  for i, v in ipairs(self.maincitySystemList) do
    if v.SystemID == systemID then
      return v
    end
  end
  return nil
end
function logic_lobby_system_extension:GetMainSystemXunYou()
  return self.mainSystemXunYou
end
function logic_lobby_system_extension:CheckInSystemInfo(SystemID)
  if not LobbySystem.roleData or not LobbySystem.roleData.system_entrance_info then
    return false
  end
  for _, _SystemID in ipairs(LobbySystem.roleData.system_entrance_info) do
    if _SystemID == SystemID then
      return true
    end
  end
  return false
end
function logic_lobby_system_extension:CheckInSystemInfoByModuleID(moduleID)
  if not LobbySystem.roleData or not LobbySystem.roleData.system_entrance_info then
    return false
  end
  for _, SystemID in pairs(LobbySystem.roleData.system_entrance_info) do
    if self.systemID_to_moduleID[SystemID] == moduleID then
      return true
    end
  end
  return false
end
function logic_lobby_system_extension:HasSystem(moduleId)
  return self.moduleID_to_systemID[moduleId] ~= nil
end
function logic_lobby_system_extension:send_report_system_entrance_info_req(endentrance_info)
  local lobbyHandler = require("client.network.Protocol.LobbyHandler")
  lobbyHandler.send_report_system_entrance_info_req(endentrance_info)
end
function logic_lobby_system_extension:on_report_system_entrance_info_rsp(error_num, data)
  if error_num == 0 then
    logic_lobby_system_extension:_SetEntranceInfo(data)
  else
    ShowNotice(error_num)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_system_extension = class(CModuleBase, nil, logic_lobby_system_extension)
return Clogic_lobby_system_extension