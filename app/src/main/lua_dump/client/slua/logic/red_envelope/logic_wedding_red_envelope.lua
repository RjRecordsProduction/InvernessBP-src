local logic_wedding_red_envelope = {}
local IgnoreUIConfigMap
local IgnoreUIConfigList = {
  UIManager.UI_Config.connect_wait,
  UIManager.UI_Config.ui_red_envelope,
  UIManager.UI_Config.Lobby_Redpacket_FatefulConnection_UIBP
}
function logic_wedding_red_envelope:OnInitialize()
  log(bWriteLog and "logic_wedding_red_envelope:OnInitialize")
  local LimitNumCfg = CDataTable.GetTableData("WeddingTableCfg", "redpacket_daily_take_limit")
  if LimitNumCfg and LimitNumCfg.ParamValue then
    self._GetLimitNum = tonumber(LimitNumCfg.ParamValue)
    log(bWriteLog and "logic_wedding_red_envelope:Init daily limit config loaded from table, value:" .. tostring(self._GetLimitNum))
  else
    self._GetLimitNum = 3
  end
  local intervalminCfg = CDataTable.GetTableData("WeddingTableCfg", "redpacket_drop_min_interval")
  if intervalminCfg and intervalminCfg.ParamValue then
    self._intervalmin = tonumber(intervalminCfg.ParamValue)
    log(bWriteLog and "logic_wedding_red_envelope:Init min interval config loaded from table, value:" .. tostring(self._intervalmin))
  else
    self._intervalmin = 10
  end
  local intervalmaxCfg = CDataTable.GetTableData("WeddingTableCfg", "redpacket_drop_max_interval")
  if intervalmaxCfg and intervalmaxCfg.ParamValue then
    self._intervalmax = tonumber(intervalmaxCfg.ParamValue)
    log(bWriteLog and "logic_wedding_red_envelope:Init max interval config loaded from table, value:" .. tostring(self._intervalmax))
  else
    self._intervalmax = 15
  end
  log_format(bWriteLog and "logic_wedding_red_envelope:Init config loading completed - limit:%s min_interval:%s max_interval:%s", self._GetLimitNum, self._intervalmin, self._intervalmax)
  self._EndTime = 0
  self._GotNum = 0
  self.endTimeFromDS = 0
  self.ownerUID = 0
  self.gameId = 0
  self.getLimitNumTime = 0
  self.sImagePath = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Redpacket_02.Lobby_Redpacket_02"
  local sImagePath = CDataTable.GetTableData("WeddingTableCfg", "redpacket_image_path")
  if sImagePath and sImagePath.TextValue and sImagePath.TextValue ~= "" then
    self.sImagePath = sImagePath.TextValue
  end
  self.GetRedEnvelopeList = {}
end
function logic_wedding_red_envelope:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE, self.ReqRedEnvelopeData, self)
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnWidgetHide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchToPageEnd, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.OnShowLobby, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY, self.OnHideLobby, self)
  self:AddCommonEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ON_ENTERTPLAN_NOTIFY, self.OnEnterTPlan, self)
end
function logic_wedding_red_envelope:OnLogin()
end
function logic_wedding_red_envelope:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_wedding_red_envelope:OnPostSwitchGameStatus nextState" .. tostring(nextState))
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_wedding_red_envelope:OnPostSwitchGameStatus is not in LobbyOrMainCity")
    self._EndTime = 0
    self:HideRedEnvelope()
    if nextState == GameStatus.Login then
      self:InitData()
    end
  end
end
function logic_wedding_red_envelope:OnEnterTPlan(_, _, canEnter)
  log(bWriteLog and "logic_wedding_red_envelope:OnEnterTPlan canEnter " .. tostring(canEnter))
  if canEnter then
    self._EndTime = 0
    self:HideRedEnvelope()
  end
end
function logic_wedding_red_envelope:ReqRedEnvelopeData()
  log(bWriteLog and "logic_wedding_red_envelope:ReqRedEnvelopeData")
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  self:WantShowRedEnvelope()
end
function logic_wedding_red_envelope:OnWidgetHide(_, _, className)
  log(bWriteLog and "logic_wedding_red_envelope:OnWidgetHide className" .. tostring(className))
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local ignoreUI = self:GetIgnoreUIMap() or {}
  if ignoreUI[className] then
    return
  end
  self:WantShowRedEnvelope()
end
function logic_wedding_red_envelope:OnSwitchToPageEnd(_, _, _, toPage)
  log(bWriteLog and "logic_wedding_red_envelope:OnSwitchToPageEnd toPage" .. tostring(toPage))
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if toPage == 1 then
    self:WantShowRedEnvelope()
  else
    self:HideRedEnvelope()
  end
end
function logic_wedding_red_envelope:OnShowLobby()
  log(bWriteLog and "logic_wedding_red_envelope:OnShowLobby")
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  self:WantShowRedEnvelope()
end
function logic_wedding_red_envelope:OnHideLobby()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  self:HideRedEnvelope()
end
function logic_wedding_red_envelope:InitData()
  log(bWriteLog and "logic_wedding_red_envelope:InitData")
  self._EndTime = 0
  self._GotNum = 0
  self.endTimeFromDS = 0
  self.ownerUID = 0
  self.gameId = 0
  self.getLimitNumTime = 0
end
function logic_wedding_red_envelope:GetIgnoreUIMap()
  if not IgnoreUIConfigMap then
    IgnoreUIConfigMap = {}
    for _, v in pairs(IgnoreUIConfigList) do
      IgnoreUIConfigMap[v.keyName] = true
    end
  end
  return IgnoreUIConfigMap
end
function logic_wedding_red_envelope:MCShouldShow()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.MainCity_Main_UIBP)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if not lobbyMain then
    log(bWriteLog and "logic_wedding_red_envelope:MCShouldShow main ui false")
    return false
  elseif lobbyMain:GetVisibility() ~= UEnums.ESlateVisibility.SelfHitTestInvisible then
    log(bWriteLog and "logic_wedding_red_envelope:MCShouldShow main visible false")
    return false
  elseif RoleInfoMainSystem.IsShow() then
    log(bWriteLog and "logic_wedding_red_envelope:MCShouldShow RoleInfoMainSystem false")
    return false
  elseif not self:IsInTime() then
    log(bWriteLog and "logic_wedding_red_envelope:MCShouldShow time false")
    return false
  elseif not self:CanGetRedEnvelope() then
    log(bWriteLog and "logic_wedding_red_envelope:MCShouldShow not Num")
    return false
  elseif self:HasGetRedEnvelope() then
    log(bWriteLog and "logic_wedding_red_envelope:MCShouldShow HasGetRedEnvelope false")
    return false
  else
    log(bWriteLog and "logic_wedding_red_envelope:MCShouldShow true")
    return true
  end
end
function logic_wedding_red_envelope:ShouldShow()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  log(bWriteLog and "Lobby_camera_manager_module.currentCameraID" .. tostring(Lobby_camera_manager_module.currentCameraID))
  if not lobbyMain then
    log(bWriteLog and "logic_wedding_red_envelope:ShouldShow main ui false")
    return false
  elseif lobbyMain:GetVisibility() ~= UEnums.ESlateVisibility.SelfHitTestInvisible then
    log(bWriteLog and "logic_wedding_red_envelope:ShouldShow main visible false")
    return false
  elseif Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Default and Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Team then
    log(bWriteLog and "logic_wedding_red_envelope:ShouldShow camera false")
    return false
  elseif RoleInfoMainSystem.IsShow() then
    log(bWriteLog and "logic_wedding_red_envelope:ShouldShow RoleInfoMainSystem false")
    return false
  elseif not self:IsInTime() then
    log(bWriteLog and "logic_wedding_red_envelope:ShouldShow time false")
    return false
  elseif not self:CanGetRedEnvelope() then
    log(bWriteLog and "logic_wedding_red_envelope:ShouldShow not Num")
    return false
  elseif not UIManager.IsAndroidStackEmpty() then
    log(bWriteLog and "logic_wedding_red_envelope:ShouldShow IsAndroidStackEmpty false")
    return false
  elseif self:HasGetRedEnvelope() then
    log(bWriteLog and "logic_wedding_red_envelope:ShouldShow HasGetRedEnvelope false")
    return false
  else
    log(bWriteLog and "logic_wedding_red_envelope:ShouldShow true")
    return true
  end
end
function logic_wedding_red_envelope:WantShowRedEnvelope()
  log(bWriteLog and "logic_wedding_red_envelope:WantShowRedEnvelope")
  if GameStatus.IsInMainCity() then
    if self:MCShouldShow() then
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_WEDDING_REDENVELOPE_MC_SHOW)
    end
  elseif GameStatus.IsIn2DLobby() then
    if self:ShouldShow() then
      local ui = UIManager.ShowUI(UIManager.UI_Config.Lobby_Redpacket_FatefulConnection_UIBP)
      ui:OnlyShow()
    end
  else
    log(bWriteLog and "logic_wedding_red_envelope:WantShowRedEnvelope state:" .. tostring(GameStatus.GetGameStatus()))
  end
end
function logic_wedding_red_envelope:HideRedEnvelope()
  log(bWriteLog and "logic_wedding_red_envelope:HideRedEnvelope")
  UIManager.CloseUI(UIManager.UI_Config.Lobby_Redpacket_FatefulConnection_UIBP)
  if UIManager.UI_Config and UIManager.UI_Config.MainCity_Activity_Bubble_Redpacket_UIBP then
    UIManager.CloseUI(UIManager.UI_Config.MainCity_Activity_Bubble_Redpacket_UIBP)
  end
end
function logic_wedding_red_envelope:IsInTime()
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "logic_wedding_red_envelope:IsInTime " .. tostring(self._EndTime) .. " " .. tostring(TimeUtil.GetServerTimeInSec()))
  return TimeUtil.GetServerTimeInSec() < self._EndTime
end
function logic_wedding_red_envelope:CanGetRedEnvelope()
  local canGet = self._GotNum < self._GetLimitNum
  log_format(bWriteLog and "logic_wedding_red_envelope:CanGetRedEnvelope got_num:%s limit_num:%s can_get:%s", self._GotNum, self._GetLimitNum, tostring(canGet))
  return canGet
end
function logic_wedding_red_envelope:HasGetRedEnvelope()
  if not self.GetRedEnvelopeList then
    return false
  end
  log_tree("logic_wedding_red_envelope:HasGetRedEnvelope", self.GetRedEnvelopeList)
  log(bWriteLog and "logic_wedding_red_envelope:HasGetRedEnvelope" .. tostring(self._EndTime))
  if self.GetRedEnvelopeList[self._EndTime] then
    return true
  else
    return false
  end
end
function logic_wedding_red_envelope:on_wedding_red_envelope_notify(message)
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bIsOpen = IntimacyUtils.IsBondingSystemOpen()
  if not bIsOpen then
    log(bWriteLog and "logic_wedding_red_envelope:on_wedding_red_envelope_notify bonding system not open")
    return false
  end
  log_tree("logic_wedding_red_envelope:on_wedding_red_envelope_notify message", message)
  local TimeUtil = require("client.common.time_util")
  local currentServerTime = TimeUtil.GetServerTimeInSec()
  if self:IsInTime() then
    log(bWriteLog and "logic_wedding_red_envelope:on_wedding_red_envelope_notify IsInTime")
    return
  end
  if not self:CanGetRedEnvelope() then
    log(bWriteLog and "logic_wedding_red_envelope:on_wedding_red_envelope_notify LimitNumTime" .. tostring(self.getLimitNumTime))
    if TimeUtil.IsSameDay(self.getLimitNumTime, currentServerTime) then
      log(bWriteLog and "logic_wedding_red_envelope:on_wedding_red_envelope_notify IsSameDay")
      return
    end
  end
  if message and next(message) then
    local RedEnVelopeHandler = require("client.network.Protocol.RedEnVelopeHandler")
    local owner_uid = tonumber(message.uid)
    self.endTimeFromDS = tonumber(message.endTime) or 0
    self.gameId = tonumber(message.gameId) or 0
    log_format(bWriteLog and "logic_wedding_red_envelope:on_wedding_red_envelope_notify time_check current_time:%s end_time:%s is_expired:%s", currentServerTime, self.endTimeFromDS, tostring(currentServerTime > self.endTimeFromDS))
    if currentServerTime > self.endTimeFromDS then
      log(bWriteLog and "logic_wedding_red_envelope:on_wedding_red_envelope_notify red_envelope_rain_expired, skip processing")
      return
    end
    if owner_uid then
      self.ownerUID = owner_uid
      RedEnVelopeHandler.send_soulmate_redpacket_rain_play_req(owner_uid, self.gameId)
    else
      log(bWriteLog and "logic_wedding_red_envelope:on_wedding_red_envelope_notify no uid")
    end
  end
end
function logic_wedding_red_envelope:on_soulmate_redpacket_rain_play_rsp(err_code, owner_uid, owner_game_id, daily_cnt)
  if err_code == 0 then
    local previousGotNum = self._GotNum
    self._GotNum = tonumber(daily_cnt) or 0
    log_format(bWriteLog and "logic_wedding_red_envelope:on_soulmate_redpacket_rain_play_rsp update_got_num previous:%s current:%s limit:%s", previousGotNum, self._GotNum, self._GetLimitNum)
    if not self:CanGetRedEnvelope() then
      log(bWriteLog and "logic_wedding_red_envelope:on_soulmate_redpacket_rain_play_rsp daily_limit_reached")
      self._EndTime = 0
      return
    else
      local previousEndTime = self._EndTime
      self._EndTime = self.endTimeFromDS
      log_format(bWriteLog and "logic_wedding_red_envelope:on_soulmate_redpacket_rain_play_rsp update_end_time previous:%s current:%s from_ds:%s", previousEndTime, self._EndTime, self.endTimeFromDS)
      self:WantShowRedEnvelope()
    end
  elseif err_code == 20150003 then
    local TimeUtil = require("client.common.time_util")
    local currTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "logic_wedding_red_envelope:on_soulmate_redpacket_rain_play_rsp num limit " .. tostring(currTime))
    self._GotNum = self._GetLimitNum
    self.getLimitNumTime = currTime
  end
end
function logic_wedding_red_envelope:send_soulmate_redpacket_rain_take_req()
  log(bWriteLog and "logic_wedding_red_envelope:send_soulmate_redpacket_rain_take_req " .. tostring(self.ownerUID))
  local RedEnVelopeHandler = require("client.network.Protocol.RedEnVelopeHandler")
  RedEnVelopeHandler.send_soulmate_redpacket_rain_take_req(self.ownerUID)
end
function logic_wedding_red_envelope:on_soulmate_redpacket_rain_take_rsp(err_code, owner_uid, daily_cnt, award_items)
  if not self.GetRedEnvelopeList then
    self.GetRedEnvelopeList = {}
  end
  self.GetRedEnvelopeList[self._EndTime] = true
  self:HideRedEnvelope()
  if err_code == 0 then
    self._GotNum = tonumber(daily_cnt)
    if self._GotNum >= self._GetLimitNum then
      local TimeUtil = require("client.common.time_util")
      self.getLimitNumTime = TimeUtil.GetServerTimeInSec()
    end
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_WEDDING_REDENVELOPE_GET_ITEM)
    if award_items and next(award_items) then
      local AwardList = {}
      for k, v in pairs(award_items) do
        local award = {}
        award.count = v
        award.res_id = k
        table.insert(AwardList, award)
      end
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(AwardList)
    end
  else
    ShowNotice(err_code)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_wedding_red_envelope)