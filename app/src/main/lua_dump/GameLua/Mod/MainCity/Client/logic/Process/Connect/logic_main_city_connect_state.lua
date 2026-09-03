local logic_main_city_connect_state = {}
function logic_main_city_connect_state:DefineAndResetData()
  self.bInConnectingToMainCityDS = false
  self.bMainCityReadyChange = false
  self.bPendingReEnterGame = false
end
function logic_main_city_connect_state:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_RES_OK, self.OnMatchResOK, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_CHANGE, self.OnMainCityChange, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_CONNECTED_TO_DS, self.OnMainCityConnectedToDS, self)
end
function logic_main_city_connect_state:OnMatchResOK(_, __, estimatetime, mode)
  log(bWriteLog and "logic_main_city_connect_state:OnMatchResOK mode = " .. tostring(mode) .. " self.bMainCityReadyChange = " .. tostring(self.bMainCityReadyChange))
  if mode == 26000 and self.bMainCityReadyChange then
    self:SetMainCityReadyChange(false)
    self:OnMainCityChange()
  end
end
function logic_main_city_connect_state:OnMainCityChange()
  log(bWriteLog and "logic_main_city_connect_state:OnMainCityChange")
  local MainCity_Connecting_UIBP = UIManager.GetUI(UIManager.UI_Config.MainCity_Connecting_UIBP)
  log(bWriteLog and "logic_main_city_connect_state:OnMainCityChange MainCity_Connecting_UIBP = " .. tostring(MainCity_Connecting_UIBP))
  if MainCity_Connecting_UIBP then
    return
  end
  EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_SHOW_SWITCH_UI)
  UIManager.ShowUI(UIManager.UI_Config.MainCity_Connecting_UIBP)
end
function logic_main_city_connect_state:OnMainCityConnectedToDS()
  log(bWriteLog and "logic_main_city_connect_state:OnMainCityConnectedToDS")
  self:AddTimerOnce(1, function()
    log(bWriteLog and "logic_main_city_connect_state:OnMainCityConnectedToDS 1")
    EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_CLOSE_CONNETING_UI)
  end)
end
function logic_main_city_connect_state:SetConnectingState(bInConnectingToMainCityDS, bShowTips)
  log(bWriteLog and "logic_main_city_connect_state:SetConnectingState bInConnectingToMainCityDS = " .. tostring(bInConnectingToMainCityDS) .. " self.bInConnectingToMainCityDS = " .. tostring(self.bInConnectingToMainCityDS) .. " bShowTips = " .. tostring(bShowTips))
  self.  if not bShowTips then
    return
  end
  self:AddTimerOnce(0.6, function()
    if not self.bInConnectingToMainCityDS then
      return
    end
    local MainCity_Connecting_UIBP = UIManager.GetUI(UIManager.UI_Config.MainCity_Connecting_UIBP)
    log(bWriteLog and "logic_main_city_connect_state:OnMainCityConnectedToDS MainCity_Connecting_UIBP = " .. tostring(MainCity_Connecting_UIBP))
    if MainCity_Connecting_UIBP then
      return
    end
    self:ShowMainCityConnectingTipsUI(73337, 8)
  end)
end
function logic_main_city_connect_state:SetMainCityReadyChange(bMainCityReadyChange)
  log(bWriteLog and "logic_main_city_connect_state:SetMainCityReadyChange bMainCityReadyChange = " .. tostring(bMainCityReadyChange) .. " self.bMainCityReadyChange = " .. tostring(self.bMainCityReadyChange))
  self.end
function logic_main_city_connect_state:ShowMainCityConnectingTipsUI(id, timetOutTime)
  log(bWriteLog and "logic_main_city_connect_state:ShowMainCityConnectingTipsUI id = " .. tostring(id) .. " timetOutTime = " .. tostring(timetOutTime))
  local MainCity_Connecting_Tips_UIBP = UIManager.GetUI(UIManager.UI_Config.MainCity_Connecting_Tips_UIBP)
  if not MainCity_Connecting_Tips_UIBP then
    UIManager.ShowUI(UIManager.UI_Config.MainCity_Connecting_Tips_UIBP, id, timetOutTime)
    return
  end
  MainCity_Connecting_Tips_UIBP:RefreshUI(id, timetOutTime)
end
function logic_main_city_connect_state:OnReceiveGameInfo(game_info)
  log(bWriteLog and "logic_main_city_connect_state:OnReceiveGameInfo")
  if game_info and game_info.sub_mode_group and game_info.sub_mode_group == 26000 then
    self.bPendingReEnterGame = true
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_main_city_connect_state = class(CModuleBase, nil, logic_main_city_connect_state)
return Clogic_main_city_connect_state