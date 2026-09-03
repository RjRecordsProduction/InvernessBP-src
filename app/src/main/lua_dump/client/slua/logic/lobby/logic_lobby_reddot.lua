local logic_lobby_reddot = {
  redDotMap = {}
}
local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local SystemName = reddot_macro.SystemName
local InReddotFrameworkModule = {}
InReddotFrameworkModule[lobby_system_entrance_marco.SystemIDDefine.ESPORT] = {
  "client.slua.logic.esport.center_reddot_data",
  SystemName.EsportCenter
}
InReddotFrameworkModule[lobby_system_entrance_marco.SystemIDDefine.CORPS] = {
  "client.slua.logic.corps.corps_reddot_data",
  SystemName.Corps
}
InReddotFrameworkModule[lobby_system_entrance_marco.SystemIDDefine.MAIL] = {
  "client.slua.logic.mail.logic_mail_redpoint_data",
  SystemName.Mail
}
InReddotFrameworkModule[lobby_system_entrance_marco.SystemIDDefine.EGAME_ENTRY] = {
  "client.slua.logic.esport.esport_reddot_data",
  SystemName.ESport
}
InReddotFrameworkModule[lobby_system_entrance_marco.SystemIDDefine.VLINK_SDK] = {
  "client.slua.logic.vlink_sdk.vlink_reddot_data",
  SystemName.Vlink
}
InReddotFrameworkModule[32] = {
  "client.slua.logic.lbs.lbs_reddot_data",
  SystemName.WarZone
}
InReddotFrameworkModule[lobby_system_entrance_marco.SystemIDDefine.SUPERCORE_ENTRY] = {
  "client.slua.logic.supercore.supercore_reddot_data",
  SystemName.SuperStar
}
InReddotFrameworkModule[lobby_system_entrance_marco.SystemIDDefine.KOL_RANK] = {
  "client.slua.umg.Kol_IN.kol_reddot_config",
  SystemName.KolRank
}
InReddotFrameworkModule[lobby_system_entrance_marco.SystemIDDefine.ASSEMBLY] = {
  "client.slua.logic.task.assembly_reddot_data",
  SystemName.Assembly
}
local ModuleIDToReddotFramework = {
  [BP_ENUM_MODULE_ESPORT] = lobby_system_entrance_marco.SystemIDDefine.ESPORT,
  [BP_ENUM_MODULE_CORPS] = lobby_system_entrance_marco.SystemIDDefine.CORPS,
  [BP_ENUM_MODULE_MAIL] = lobby_system_entrance_marco.SystemIDDefine.MAIL,
  [BP_ENUM_MODULE_EGAME_ENTRY] = lobby_system_entrance_marco.SystemIDDefine.EGAME_ENTRY,
  [BP_ENUM_VLINK_SDK] = lobby_system_entrance_marco.SystemIDDefine.VLINK_SDK,
  [BP_ENUM_MODULE_SUPERCORE_ENTRY] = lobby_system_entrance_marco.SystemIDDefine.SUPERCORE_ENTRY,
  [BP_ENUM_MODULE_KOL_RANK] = lobby_system_entrance_marco.SystemIDDefine.KOL_RANK,
  [BP_ENUM_MODULE_ASSEMBLY] = lobby_system_entrance_marco.SystemIDDefine.ASSEMBLY
}
local GroupName = "More"
local reddot_group = require("client.slua.logic.reddot.reddot_group")
local GroupData = reddot_group:AddGroup(GroupName)
local RegistedCount = 0
local delegate_container = require("common.delegate_container")
local DelegateContainer = delegate_container()
local reddotModuleNum = 0
for _, _ in pairs(InReddotFrameworkModule) do
  reddotModuleNum = reddotModuleNum + 1
end
function logic_lobby_reddot.OnLogin()
  DelegateContainer:Dispose()
  DelegateContainer:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_UPDATE_SYSTEM_ENTRANCE, function(_, _, entrance_info)
    logic_lobby_reddot.OnEntranceChange(entrance_info)
  end)
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local registedSystem = reddot_manager:GetRegistedSystem()
  for _, systemInfo in pairs(InReddotFrameworkModule) do
    local _, systemName = systemInfo[1], systemInfo[2]
    DelegateContainer:AddDataListener(registedSystem, systemName, function(_, registed)
      print(bWriteLog and string.format("logic_lobby_reddot system[%s] registed, OldValue[%s] NewValue[%s]!", systemName, _, registed))
      if registed then
        RegistedCount = RegistedCount + 1
        print(bWriteLog and string.format("logic_lobby_reddot system[%s] registed, No.[%d]!", systemName, RegistedCount))
        if RegistedCount >= reddotModuleNum then
          logic_lobby_reddot.OnEntranceChange(LobbySystem.roleData.system_entrance_info)
        end
      end
    end)
  end
end
function logic_lobby_reddot.OnLogout()
  logic_lobby_reddot.redDotMap = {}
  DelegateContainer:Dispose()
  RegistedCount = 0
end
function logic_lobby_reddot.ProcModuleReddot(moduleId, bRedDot)
  log(bWriteLog and "logic_lobby_reddot.ProcModuleReddot moduleId = " .. moduleId .. ", bRedDot = " .. tostring(bRedDot))
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() and not LogicNewbie.NeedShowNewbieGuide(moduleId) then
    return
  end
  local oldSts = logic_lobby_reddot.redDotMap[moduleId]
  if oldSts == nil and bRedDot or oldSts == false and bRedDot or oldSts == true and bRedDot == false then
    log(bWriteLog and "logic_lobby_reddot.ProcModuleReddot changed moduleId = " .. moduleId .. ", bRedDot = " .. tostring(bRedDot))
    if not InReddotFrameworkModule[moduleId] then
      logic_lobby_reddot.redDotMap[moduleId] = bRedDot
    end
    EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, moduleId, bRedDot)
  end
end
function logic_lobby_reddot.GetRedDotStatus(moduleId)
  if moduleId == BP_ENUM_MODULE_BLACK_FRIDAY_MAIN then
    local BlackFridayRedDotModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayRedDotModule)
    return BlackFridayRedDotModule:HasBannerRedDot()
  end
  return logic_lobby_reddot.redDotMap[moduleId] or false
end
function logic_lobby_reddot.GetReddotDataByModule(moduleId)
  local id = ModuleIDToReddotFramework[moduleId]
  if id then
    local systemInfo = InReddotFrameworkModule[id]
    local moduleName, _ = systemInfo[1], systemInfo[2]
    local module = require(moduleName)
    return module.GetData()
  end
end
function logic_lobby_reddot.GetGroupData()
  return GroupData
end
function logic_lobby_reddot.OnEntranceChange(entrance_info)
  print(bWriteLog and "logic_lobby_reddot.OnEntranceChange")
  local notInGroup = {}
  for _, groupID in pairs(entrance_info) do
    notInGroup[groupID] = true
  end
  for groupID, systemInfo in pairs(InReddotFrameworkModule) do
    local moduleName, systemName = systemInfo[1], systemInfo[2]
    if notInGroup[groupID] and reddot_group:IsInGroup(systemName, GroupName) then
      local module = require(moduleName)
      local reddotData = module.GetData()
      reddot_group:RemoveFromGroup(reddotData, GroupName)
    elseif not notInGroup[groupID] and not reddot_group:IsInGroup(systemName, GroupName) then
      local module = require(moduleName)
      local reddotData = module.GetData()
      reddot_group:AddToGroup(reddotData, GroupName)
    end
  end
end
return logic_lobby_reddot