local HostedProtoBridge = {}
local HostedProtoConfig = require("client.slua.logic.HostedProtoBridge.HostedProtoConfig")
local DefaultCD = HostedProtoConfig.Const.DefaultCD
local Proto = HostedProtoConfig.Proto
local HostedProxyConfig = require("client.slua.logic.HostedProtoBridge.HostedProxyConfig")
local local local local local local local getMicroseconds = slua.getMicroseconds
local local local utility = require("common.utility")
local TableUtil = require("common.table_util")
local StringUtil = require("common.string_util")
local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
local BNReleaseVersion = Client and not Client.IsReleaseVersion(NetInterface)
local BInterceptErrorPdr = BNReleaseVersion or HDmpveRemote.HDmpveRemoteConfigGetBool("BInterceptErrorPdr", false)
local nHostedProtoTime = HDmpveRemote.HDmpveRemoteConfigGetInt("HostedProtoTime", 5)
local StaticDataLoaded = {}
local LastTime = {}
local recordTime = 0
local ErrorMessageHandler = function(jsonStr)
  local info = string.format("HostedProtoBridge frequency: %s", jsonStr)
  if BNReleaseVersion then
    local logic_gm_server = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm_server")
    local serverName = TableUtil.GetTableValue(logic_gm_server, "_cur_server")
    if serverName and serverName:find("\230\189\152\229\164\154\230\139\137") then
      ShowNotice(info)
    end
  end
  if not utility.GetLimitStat(info) then
    log_error("HostedProtoBridge ErrorMessageHandler not report because limit stat msg:" .. info)
    return
  end
  ClientToolsReport:SendReport(ClientToolsReport.Enum_SvrReport_Type.Enum_Xpcall, info, false)
end
function HostedProtoBridge:OnReceiveMessage(appType, appId, jsonStr, data)
  log(bWriteLog and string.format("HostedProtoBridge:OnReceiveMessage. appType=%s, jsonStr=%s", tostring(appType), tostring(jsonStr)))
  if BNReleaseVersion then
    recordTime = getMicroseconds()
  end
  if not GameStatus.IsInLobbyOrSpecialFighting() then
    log(bWriteLog and "HostedProtoBridge:OnReceiveMessage not response because not in lobby")
    return
  end
  if not data then
    data = json.decode(jsonStr)
    if not data then
      log(bWriteLog and "HostedProtoBridge:OnReceiveMessage not response because msg isn't invalid")
      return
    end
  end
  local name = data.type
  if not name then
    log(bWriteLog and "HostedProtoBridge.OnReceiveMessage json.decode failed")
    return
  end
  local ProtoConfig = Proto[name]
  if not (ProtoConfig and ProtoConfig.func) or ProtoConfig.func == "" then
    log(bWriteLog and "HostedProtoBridge.OnReceiveMessage ProtoConfig is unvalid")
    return
  end
  local TimeUtil = require("client.common.time_util")
  if not self.bShown and ProtoConfig.needTime and TimeUtil.GetServerTimeInSec() - self.nLoginTime < nHostedProtoTime then
    log(bWriteLog and "HostedProtoBridge:OnReceiveMessage not enough time: " .. tostring(name))
    return
  end
  if self:IsFrequencyLimit(jsonStr, data, appType, appId, ProtoConfig) then
    log(bWriteLog and "HostedProtoBridge.OnReceiveMessage frequency limit")
    return
  end
  if ProtoConfig.logic and ProtoConfig.logic ~= "" then
    local logic = require(ProtoConfig.logic)
    local funcName = ProtoConfig.func
    local func = logic[funcName]
    if func then
      if ProtoConfig.toSelf == true then
        xpcall(func, utility.ErrorMessageHandler, logic, data, appType)
      else
        xpcall(func, utility.ErrorMessageHandler, data, appType)
      end
    else
      log_error(bWriteLog and "HostedProtoBridge:OnReceiveMessage. func don't exists")
    end
  elseif ProtoConfig.modulePath and ProtoConfig.moduleName and ProtoConfig.modulePath ~= "" and ProtoConfig.moduleName ~= "" then
    local modulePath = ModuleManager[ProtoConfig.modulePath]
    if not modulePath then
      log_error(bWriteLog and "HostedProtoBridge:OnReceiveMessage. modulePath isn't exists : " .. tostring(ProtoConfig.modulePath))
      return
    end
    local moduleConfig = modulePath[ProtoConfig.moduleName]
    if not moduleConfig then
      log_error(bWriteLog and "HostedProtoBridge:OnReceiveMessage. moduleConfig isn't exists : " .. tostring(ProtoConfig.moduleName))
      return
    end
    local moduleBase = ModuleManager.GetModule(moduleConfig)
    if moduleBase then
      local func = moduleBase[ProtoConfig.func]
      if func then
        xpcall(func, utility.ErrorMessageHandler, moduleBase, data, appType)
      else
        log_error(bWriteLog and "HostedProtoBridge:OnReceiveMessage. func don't exists")
      end
    end
  else
    log_error(bWriteLog and string.format("HostedProtoBridge:OnReceiveMessage. can't find the func, type:%s,name:%s", tostring(data.type), tostring(name)))
    return
  end
  if BNReleaseVersion then
    log(bWriteLog and string.format("TimeTracer HostedProtoBridge:OnReceiveMessage: appType:%s name:%s Handler time: [%.3fms] ", appType, name, (getMicroseconds() - data._ClientStartTime) / 1000))
  end
end
function HostedProtoBridge:OnSendMessage(appType, data)
  log(bWriteLog and string.format("HostedProtoBridge:OnSendMessage. appType=%s", tostring(appType)))
  if not GameStatus.IsInLobbyOrSpecialFighting() then
    log(bWriteLog and "HostedProtoBridge:OnSendMessage not sendCmd because not in lobby")
    return
  end
  if not data then
    log_error(bWriteLog and "HostedProtoBridge:OnSendMessage. Content isn't valid")
    return
  end
  self:SendMessage(appType, data)
end
function HostedProtoBridge:SetOpenFlag(appType, appId)
  self.bShown = true
  log(bWriteLog and "HostedProtoBridge:SetOpenFlag.  ")
  local IdKey = tostring(appId)
  if not self.OpenFlagMap then
    self.OpenFlagMap = {}
  end
  if not self.OpenFlagLength then
    self.OpenFlagLength = 0
  end
  local typeMap = self.OpenFlagMap[appType]
  if not typeMap then
    typeMap = {}
    self.OpenFlagMap[appType] = typeMap
    self.OpenFlagLength = self.OpenFlagLength + 1
  elseif not typeMap[IdKey] then
    self.OpenFlagLength = self.OpenFlagLength + 1
  end
  self.OpenFlagMap[appType][IdKey] = 1
end
function HostedProtoBridge:SendRegion()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local region = DataMgr.RegionData and DataMgr.RegionData.region
  region = region or login_module.sIpRegion
  local tab = {type = "SendRegion", content = region}
  self:SendToAllHosted(tab)
end
function HostedProtoBridge:SendMessage(appType, data, appId)
  log(bWriteLog and string.format("HostedProtoBridge:SendMessage. appType=%s, data=%s", tostring(appType), tostring(data)))
  appId = appId or data.appId
  if not appId then
    local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    appId = logic_gamelet_interface:GetAppIdByShowEntrance(appType)
  end
  local ProxyConfig = HostedProxyConfig[appType]
  if not ProxyConfig then
    if not appId then
      log_error(bWriteLog and string.format("HostedProtoBridge:OnSendMessage. appType=%s, ProxyConfig isn't valid, appId isn't valid", tostring(appType)))
      return
    else
      local _beginTime = getMicroseconds()
      log(bWriteLog and string.format("HostedProtoBridge:OnSendMessage. appType=%s, ProxyConfig isn't valid, but appId(%s) is valid", tostring(appType), tonumber(appId)))
      local realContent = data
      local jsonStr = json.encode(realContent)
      log(bWriteLog and string.format("HostedProtoBridge:SendMessage. length:%s, jsonStr:", tostring(#jsonStr), tostring(jsonStr)))
      local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
      gamelet_interface:SendMessageToApp(appId, jsonStr)
      if BNReleaseVersion then
        log(bWriteLog and string.format("TimeTracer HostedProtoBridge OnSendMessage: appType:%s name:%s time: [%.3fms] ", appType, tostring(data.type), (getMicroseconds() - _beginTime) / 1000))
      end
      return
    end
  end
  local SendFuncName = ProxyConfig.sendFunc
  if not SendFuncName or not SendFuncName == "" then
    log_error(bWriteLog and string.format("HostedProtoBridge:OnSendMessage. appType=%s, SendFuncName:%s isn't valid", tostring(appType), tostring(SendFuncName)))
    return
  end
  local _beginTime = getMicroseconds()
  if ProxyConfig.logicName and ProxyConfig.logicName ~= "" then
    local Logic = require(ProxyConfig.logicName)
    if not Logic or not Logic[SendFuncName] then
      log_error(bWriteLog and string.format("HostedProtoBridge:OnSendMessage. Logic isn't valid or Logic has no this func:%s", tostring(SendFuncName)))
      return
    end
    local realContent = data
    local jsonStr = json.encode(realContent)
    log(bWriteLog and string.format("HostedProtoBridge:SendMessage. length:%s, jsonStr:", tostring(#jsonStr), tostring(jsonStr)))
    local Func = Logic[SendFuncName]
    if ProxyConfig.toSelf then
      xpcall(Func, utility.ErrorMessageHandler, Logic, jsonStr, appId)
    else
      xpcall(Func, utility.ErrorMessageHandler, jsonStr, appId)
    end
  elseif ProxyConfig.modulePath and ProxyConfig.moduleName and ProxyConfig.modulePath ~= "" and ProxyConfig.moduleName ~= "" then
    local modulePath = ModuleManager[ProxyConfig.modulePath]
    if not modulePath then
      log_error(bWriteLog and string.format("HostedProtoBridge:OnSendMessage. ModulePath isn't valid or Logic has no this func:%s", tostring(ProxyConfig.modulePath)))
      return
    end
    local moduleName = modulePath[ProxyConfig.moduleName]
    if not moduleName then
      log_error(bWriteLog and string.format("HostedProtoBridge:OnSendMessage. moduleName isn't valid or Logic has no this func:%s", tostring(ProxyConfig.moduleName)))
      return
    end
    local moduleBase = ModuleManager.GetModule(moduleName)
    if moduleBase then
      local func = moduleBase[SendFuncName]
      if not func then
        log_error(bWriteLog and string.format("HostedProtoBridge:SendMessage. func don't exists:%s", SendFuncName))
      end
      local realContent = data
      local jsonStr = json.encode(realContent)
      log(bWriteLog and string.format("HostedProtoBridge:SendMessage. length:%s, jsonStr:", tostring(#jsonStr), tostring(jsonStr)))
      xpcall(func, utility.ErrorMessageHandler, moduleBase, jsonStr, appId)
    end
  end
  if BNReleaseVersion then
    log(bWriteLog and string.format("TimeTracer HostedProtoBridge OnSendMessage: appType:%s name:%s time: [%.3fms] ", appType, tostring(data.type), (getMicroseconds() - _beginTime) / 1000))
  end
end
function HostedProtoBridge:IsFrequencyLimit(jsonStr, data, appType, appId, protoCfg)
  local name = data.type
  if protoCfg.Static then
    if not StaticDataLoaded[appType] then
      StaticDataLoaded[appType] = {}
    end
    if StaticDataLoaded[appType][name] then
      ErrorMessageHandler(jsonStr)
      if BInterceptErrorPdr then
        return true
      end
    end
    StaticDataLoaded[appType][name] = 1
  elseif not protoCfg.AllowHighFreq then
    if not LastTime[appType] then
      LastTime[appType] = {}
    end
    local currentTime = getMicroseconds() / 1000000
    local cd = protoCfg.CD or DefaultCD
    local lastTime = LastTime[appType][name] or 0
    if cd > currentTime - lastTime then
      ErrorMessageHandler(jsonStr)
      if BInterceptErrorPdr then
        self:SendFrequently(appType, appId, data)
        return true
      end
    end
    LastTime[appType][name] = currentTime
  end
  if BNReleaseVersion then
    log(bWriteLog and string.format("TimeTracer HostedProtoBridge:IsFrequencyLimit: appType:%s type:%s decode time: [%.3fms] ", appType, name, (getMicroseconds() - recordTime) / 1000))
    recordTime = getMicroseconds()
    data._ClientStartTime = recordTime
  end
  return false
end
function HostedProtoBridge:SendFrequently(appType, appId, data)
  if self.FrequentlyTimer then
    self:RemoveTimer(self.FrequentlyTimer)
    self.FrequentlyTimer = nil
  end
  if not self.PendingFrequentlyMap then
    self.PendingFrequentlyMap = {}
  end
  if not self.PendingFrequentlyMap[appType] then
    self.PendingFrequentlyMap[appType] = {}
  end
  if not self.PendingFrequentlyMap[appType][appId] then
    self.PendingFrequentlyMap[appType][appId] = {}
  end
  local name = data.type
  local pendingMap = self.PendingFrequentlyMap[appType][appId]
  local oldId = pendingMap[name]
  pendingMap[name] = oldId or data.actid or 0
  self.FrequentlyTimer = self:AddTimerOnce(1, function()
    self:RealSendFrequently()
  end)
end
function HostedProtoBridge:RealSendFrequently()
  log(bWriteLog and "HostedProtoBridge:RealSendFrequently.")
  for appType, idMap in pairs(self.PendingFrequentlyMap) do
    for appId, pendingMap in pairs(idMap) do
      for s, id in pairs(pendingMap) do
        local data = {
          type = "Frequently",
          content = s,
          act        }
        self:SendMessage(appType, data, appId)
      end
    end
  end
  self.PendingFrequentlyMap = nil
end
function HostedProtoBridge:SendGC()
  Client.CrashLog(NetInterface, 4, "Battle", "Before GCPandoraUI")
  local data = {type = "gc", content = ""}
  self:SendToAllHosted(data)
  Client.CrashLog(NetInterface, 4, "Battle", "After GCPandoraUI")
end
function HostedProtoBridge:SendPreSwitchGameStatusWithLobby(pre, next)
  local data = {
    type = "OnPreSwitchGameStatus",
    content = "",
    content = {curStatus = pre, nextStatus = next}
  }
  self:SendToAllHosted(data)
end
function HostedProtoBridge:SendPostSwitchGameStatusWithLobby(pre, next)
  local data = {
    type = "OnPostSwitchGameStatus",
    content = "",
    content = {preStatus = pre, nextStatus = next}
  }
  self:SendToAllHosted(data)
end
function HostedProtoBridge:GetClassNameByCfg(cfg)
  if not cfg then
    return
  end
  local TableUtil = require("common.table_util")
  local className = TableUtil.GetTableValue(cfg, "moduleName")
  if className then
    local names = StringUtil.Split(className, ".")
    className = names[#names]
  end
  return className
end
local FilterTopUI = {
  GM_WhitePoint = 1,
  LoginLobby_Timestamp_BP = 1,
  Lobby_Click_Animation = 1,
  Lobby_Watermark_BP = 1,
  Common_Mask_UIBP = 1,
  connect_wait = 1
}
local SpecialNamesShow = {ui_loading = 1, GameLetSDK_UIBP = 1}
function HostedProtoBridge:OnUIShow(_, _, cfg)
  if not self.OpenFlagLength or self.OpenFlagLength == 0 then
    return
  end
  if not cfg or cfg.isMainUI == false then
    return
  end
  if cfg.keyName and FilterTopUI[cfg.keyName] then
    return
  end
  local className = self:GetClassNameByCfg(cfg)
  if SpecialNamesShow[className] then
    self:SendGameUIShow(className)
  end
  self:SendTopUIShow(className, cfg)
end
function HostedProtoBridge:SendGameUIShow(moduleId)
  if not self.OpenFlagLength or self.OpenFlagLength == 0 then
    return
  end
  if not moduleId then
    return
  end
  log_warning(bWriteLog and "HostedProtoBridge:SendGameUIShow. className " .. tostring(moduleId))
  local data = {
    type = "OnGameUIShow",
    content = moduleId,
    className = moduleId
  }
  self:SendToAllOpenHosted(data)
end
function HostedProtoBridge:SendTopUIShow(className, cfg)
  if not className or not cfg.containerName then
    return
  end
  if cfg.containerName ~= UIContainers.Top then
    return
  end
  local data = {
    type = "OnTopUIShow",
    content = className,
    className = className,
    containerName = UIContainers.Top
  }
  self:SendToAllOpenHosted(data)
end
function HostedProtoBridge:OnUIHide(_, _, keyName)
  if not self.OpenFlagLength or self.OpenFlagLength == 0 then
    return
  end
  if not keyName or FilterTopUI[keyName] then
    return
  end
  local config = UIManager.GetConfigByKey(keyName)
  if not config or config.isMainUI == false then
    return
  end
  local className = self:GetClassNameByCfg(config)
  if SpecialNamesShow[className] then
    self:SendGameUIHide(className)
  end
  self:SendTopUIHide(className, config)
end
function HostedProtoBridge:SendGameUIHide(moduleId)
  local data = {
    type = "OnGameUIHide",
    content = moduleId
  }
  log_warning(bWriteLog and "HostedProtoBridge:SendGameUIHide. className " .. tostring(data.content))
  self:SendToAllOpenHosted(data)
end
function HostedProtoBridge:SendTopUIHide(className, config)
  if not config.containerName or config.containerName ~= UIContainers.Top then
    return
  end
  local data = {
    type = "OnTopUIHide",
    content = className,
    className = className,
    containerName = UIContainers.Top
  }
  self:SendToAllOpenHosted(data)
end
function HostedProtoBridge:SendToAllOpenHosted(data)
  if not self.OpenFlagMap then
    return
  end
  for appType, idMap in pairs(self.OpenFlagMap) do
    for appId, _ in pairs(idMap) do
      self:SendMessage(appType, data, appId)
    end
  end
end
function HostedProtoBridge:SendToAllHosted(data)
  self:SendMessage("Pandora", data)
  local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  for appId, appInfo in pairs(logic_gamelet_interface.gamelet_apps_info) do
    local appType = appInfo.appType
    self:SendMessage(appType, data, appId)
  end
end
function HostedProtoBridge:SendAndroidBack(appType, appId)
  local data = {
    type = "AndroidBack",
    content = ""
  }
  self:SendMessage(appType, data, appId)
end
function HostedProtoBridge:OnDeactivated()
  local data = {
    type = "OnDeactivated",
    content = ""
  }
  self:SendToAllHosted(data)
end
function HostedProtoBridge:OnReactivated()
  local data = {
    type = "OnReactivated",
    content = ""
  }
  self:SendToAllHosted(data)
end
function HostedProtoBridge:GeCreatorForumBubbleTips()
  local data = {type = "OnWowShow", content = ""}
  self:SendToAllHosted(data)
end
function HostedProtoBridge:DefineAndResetData()
  self.OpenFlagMap = nil
  self.OpenFlagLength = nil
  self.FrequentlyTimer = nil
  self.PendingFrequentlyMap = nil
  self.nLoginTime = 0
end
function HostedProtoBridge:RegistEvents()
  self:AddCommonEvent(EVENTID_UI, BP_ENUM_UI_SHOW, self.OnUIShow, self)
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnUIHide, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, self.OnDeactivated, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, self.OnReactivated, self)
end
function HostedProtoBridge:OnLogOut()
  StaticDataLoaded = {}
  LastTime = {}
  self.bShown = nil
end
function HostedProtoBridge:OnPreSwitchGameStatus(preState, nextState)
  self.OpenFlagMap = nil
  self.OpenFlagLength = nil
  if self.FrequentlyTimer then
    self:RemoveTimer(self.FrequentlyTimer)
    self.FrequentlyTimer = nil
  end
  self.PendingFrequentlyMap = nil
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) then
    self:SendGC()
    self:SendPreSwitchGameStatusWithLobby(preState, nextState)
  end
end
function HostedProtoBridge:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "HostedProtoBridge:OnPostSwitchGameStatus.  ")
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    self:SendPostSwitchGameStatusWithLobby(preState, nextState)
  elseif preState == "Login" then
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    self.nWaitLoadingTimer = self:AddTimerLoop(0.1, function()
      if not LoadingSystem.IsShowing() then
        local TimeUtil = require("client.common.time_util")
        self.nLoginTime = TimeUtil.GetServerTimeInSec()
        log(bWriteLog and "HostedProtoBridge:OnPostSwitchGameStatus.  from login")
        if self.nWaitLoadingTimer then
          self:RemoveTimer(self.nWaitLoadingTimer)
          self.nWaitLoadingTimer = nil
        end
      end
    end, 0, 1)
  end
end
local Class = require("class")
local ModuleBase = require("client.module_framework.ModuleBase")
local CHostedProtoBridge = Class(ModuleBase, nil, HostedProtoBridge)
return CHostedProtoBridge