local logic_red_envelope = {}
local IgnoreUIConfigMap
local IgnoreUIConfigList = {
  UIManager.UI_Config.connect_wait,
  UIManager.UI_Config.ui_red_envelope
}
function logic_red_envelope:OnInitialize()
  log(bWriteLog and "RedEnvelopeSystem: OnInitialize")
  self._IsStart = false
  self._isPlaying = false
  self._StartTime = 0
  self._EndTime = 0
  self._GetLimitNum = 0
  self._LeftTime = 0
  self._GotTime = 0
  self._intervalmin = 0
  self._intervalmax = 0
  self.sImagePath = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Redpacket_02.Lobby_Redpacket_02"
  self.sAnimName = "/Game/UMG/UI_BP/Lobby/Lobby_Redpacket_Item01_UIBP.Lobby_Redpacket_Item01_UIBP"
end
function logic_red_envelope:OnLogin()
  local RedEnVelopeHandler = require("client.network.Protocol.RedEnVelopeHandler")
  RedEnVelopeHandler.send_get_lucky_money_notify()
end
function logic_red_envelope:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE, self.ReqRedEnvelopeData, self)
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnWidgetHide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchToPageEnd, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.OnShowLobby, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY, self.OnHideLobby, self)
end
function logic_red_envelope:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "RedEnvelopeSystem: OnModePostSwitch")
  if not GameStatus.IsInLobbyOrMainCity() then
    self:HideRedEnvelope()
    if nextState == GameStatus.Login then
      self:Clear()
    end
  end
end
function logic_red_envelope:HasRedBagRain()
  return self._IsStart and self._LeftTime ~= 0
end
function logic_red_envelope:InitData()
  self._IsStart = true
  self._isPlaying = false
  self._StartTime = 0
  self._EndTime = 0
  self._GetLimitNum = 0
  self._LeftTime = 0
  self._GotTime = 0
end
function logic_red_envelope:GetIgnoreUIMap()
  if not IgnoreUIConfigMap then
    IgnoreUIConfigMap = {}
    for _, v in pairs(IgnoreUIConfigList) do
      IgnoreUIConfigMap[v.keyName] = true
    end
  end
  return IgnoreUIConfigMap
end
function logic_red_envelope:Clear()
  log(bWriteLog and "  : RedEnvelopeSystem.Clear")
  self:InitData()
end
function logic_red_envelope:ShouldShow()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  log(bWriteLog and "  : Lobby_camera_manager_module.currentCameraID" .. tostring(Lobby_camera_manager_module.currentCameraID))
  if not lobbyMain then
    log(bWriteLog and "logic_red_envelope:ShouldShow main ui false")
    return false
  elseif lobbyMain:GetVisibility() ~= UEnums.ESlateVisibility.SelfHitTestInvisible then
    log(bWriteLog and "logic_red_envelope:ShouldShow main visible false")
    return false
  elseif Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Default and Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Team then
    log(bWriteLog and "logic_red_envelope:ShouldShow camera false")
    return false
  elseif RoleInfoMainSystem.IsShow() then
    log(bWriteLog and "logic_red_envelope:ShouldShow RoleInfoMainSystem false")
    return false
  elseif not self:IsInTime() then
    log(bWriteLog and "logic_red_envelope:ShouldShow time false")
    return false
  elseif not UIManager.IsAndroidStackEmpty() then
    log(bWriteLog and "logic_red_envelope:ShouldShow IsAndroidStackEmpty false")
    return false
  else
    log(bWriteLog and "logic_red_envelope:ShouldShow true")
    return true
  end
end
function logic_red_envelope:MCShouldShow()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.MainCity_Main_UIBP)
  local topUIName = UIManager.GetTopUIName()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  log(bWriteLog and "  : Lobby_camera_manager_module.currentCameraID" .. tostring(Lobby_camera_manager_module.currentCameraID))
  if not lobbyMain then
    log(bWriteLog and "logic_red_envelope:MCShouldShow main ui false")
    return false
  elseif lobbyMain:GetVisibility() ~= UEnums.ESlateVisibility.SelfHitTestInvisible then
    log(bWriteLog and "logic_red_envelope:MCShouldShow main visible false")
    return false
  elseif Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Default and Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Team then
    log(bWriteLog and "logic_red_envelope:MCShouldShow camera false")
    return false
  elseif RoleInfoMainSystem.IsShow() then
    log(bWriteLog and "logic_red_envelope:MCShouldShow RoleInfoMainSystem false")
    return false
  elseif not self:IsInTime() then
    log(bWriteLog and "logic_red_envelope:MCShouldShow time false")
    return false
  elseif topUIName ~= UIManager.UI_Config.MainCity_Main_UIBP.keyName then
    log(bWriteLog and "logic_red_envelope:MCShouldShow topUIName ~= UIManager.UI_Config.MainCity_Main_UIBP.keyName")
    return false
  else
    log(bWriteLog and "logic_red_envelope:MCShouldShow true")
    return true
  end
end
function logic_red_envelope:OnWidgetHide(_, _, className)
  local status = GameStatus.GetGameStatus()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local ignoreUI = self:GetIgnoreUIMap() or {}
  if ignoreUI[className] then
    return
  end
  self:WantShowRedEnvelope()
end
function logic_red_envelope:OnSwitchToPageEnd(_, _, _, toPage)
  log(bWriteLog and "RedEnvelopeSystem:OnSwitchToPageEnd toPage" .. tostring(toPage))
  local status = GameStatus.GetGameStatus()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if toPage == 1 then
    self:WantShowRedEnvelope()
  else
    self:HideRedEnvelope()
  end
end
function logic_red_envelope:OnShowLobby()
  local status = GameStatus.GetGameStatus()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  self:WantShowRedEnvelope()
end
function logic_red_envelope:OnHideLobby()
  local status = GameStatus.GetGameStatus()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  self:HideRedEnvelope()
end
function logic_red_envelope:WantShowRedEnvelope()
  if GameStatus.IsInMainCity() then
    if self:MCShouldShow() then
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_REDENVELOPE_MC_SHOW)
    end
  elseif self:ShouldShow() then
    local ui = UIManager.ShowUI(UIManager.UI_Config.ui_red_envelope)
    ui:OnlyShow()
  end
end
function logic_red_envelope:RefreshRedEnvelopeSystemData(begints, endts, left_times, total_times, intervalmin, intervalmax, sAnimName, sImagePath)
  self._StartTime = begints
  log(bWriteLog and "logic_red_envelope:RefreshRedEnvelopeSystemData endtime= " .. tostring(endts))
  self._EndTime = endts
  self._LeftTime = left_times
  self._GetLimitNum = total_times
  self._GotTime = total_times - left_times
  self._  self._  if sImagePath then
    log(bWriteLog and "[  sImagePath :" .. sImagePath)
    local asset_util = require("common.asset_util")
    local res = asset_util.GetAssetSync(sImagePath)
    if res then
      self.    end
  end
  if sAnimName then
    log(bWriteLog and "[  sAnimName :" .. sAnimName)
    self.  end
end
function logic_red_envelope:NotifiedToStart()
  if GameStatus.IsInLobbyOrMainCity() then
    self:WantShowRedEnvelope()
  end
end
function logic_red_envelope:HideRedEnvelope()
  log(bWriteLog and "[   HideRedEnvelope:")
  UIManager.CloseUI(UIManager.UI_Config.ui_red_envelope)
end
function logic_red_envelope:IsCouldGetAward()
  return self:IsInTime()
end
function logic_red_envelope:IsInTime()
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "logic_red_envelope:IsInTime " .. tostring(self._EndTime) .. " " .. tostring(TimeUtil.GetServerTimeInSec()))
  return TimeUtil.GetServerTimeInSec() < self._EndTime
end
function logic_red_envelope:ReqRedEnvelopeData()
  if self:IsInTime() then
    self:NotifiedToStart()
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_red_envelope)