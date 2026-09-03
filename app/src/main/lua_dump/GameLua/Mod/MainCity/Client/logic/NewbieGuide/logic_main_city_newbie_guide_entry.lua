local logic_main_city_newbie_guide_entry = {curLoginShow = false, canShowGuide = false}
local OthersUICfg = {
  ui_season_switch_mgr = true,
  Newbie_Friends_Recommend = true,
  Flap_Newbie_EightDays = true,
  mode_selection_main = true,
  level_unlock_levelup = true,
  LevelUnlock_Segment_New_UIBP = true,
  ui_season_slapface = true
}
function logic_main_city_newbie_guide_entry:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchToPageEnd, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY, self.OnHideLobby, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, self.OnFaceSlapEnd, self)
end
function logic_main_city_newbie_guide_entry:OnLogOut()
  self.curLoginShow = false
end
function logic_main_city_newbie_guide_entry:OnSwitchToPageEnd(_, __, fromPage, toPage)
  log(bWriteLog and "logic_main_city_newbie_guide_entry:OnSwitchToPageEnd fromPage = " .. tostring(fromPage) .. " toPage = " .. tostring(toPage))
  if toPage ~= ENUM_LobbyPageType.Mid then
    UIManager.CloseUI(UIManager.UI_Config.MainCity_Newbie_Slide_UIBP)
    return
  end
  self:ShowMainCityEntryGuide()
end
function logic_main_city_newbie_guide_entry:OnHideLobby()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:OnHideLobby")
  UIManager.CloseUI(UIManager.UI_Config.MainCity_Newbie_Slide_UIBP)
end
function logic_main_city_newbie_guide_entry:OnFaceSlapEnd()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:OnFaceSlapEnd")
  self:ShowMainCityEntryGuide()
end
function logic_main_city_newbie_guide_entry:ShowMainCityEntryGuide()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:ShowMainCityEntryGuide")
  local bShowMainCityEntryGuide = self:CheckShowMainCityEntryGuide()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:OnSwitchToPageEnd bShowMainCityEntryGuide = " .. tostring(bShowMainCityEntryGuide))
  if not bShowMainCityEntryGuide then
    return
  end
  self.curLoginShow = true
  UIManager.ShowUI(UIManager.UI_Config.MainCity_Newbie_Slide_UIBP)
end
function logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide")
  if not logic_main_city_newbie_guide_entry.canShowGuide then
    log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide return canShowGuide")
    return
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local flag1 = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, 20007)
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide flag1 = " .. tostring(flag1))
  if not flag1 then
    return false
  end
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  local clickFlag = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.EMainCityGuideID.MAINCITY_ENTRY_GUIDE_ID)
  local slideFlag = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.EMainCityGuideID.MAINCITY_SLIDE_ENTRY_GUIDE_ID)
  printf("logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide. clickFlag=%s, slideFlag=%s", tostring(clickFlag), tostring(slideFlag))
  if clickFlag and slideFlag then
    return false
  end
  if self.curLoginShow then
    log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide curLoginShow = " .. tostring(self.curLoginShow))
    return false
  end
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  local isMainCityEntryOpen = main_city_process_util.IsMainCityEntryOpen()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide IsMainCityEntryOpen = " .. tostring(isMainCityEntryOpen))
  if not isMainCityEntryOpen then
    return false
  end
  local logic_setting_notify = require("client.logic.setting.logic_setting_notify")
  local isInReturnFirstDay = logic_setting_notify.IsBackFirstDay()
  local isReturnFirstDayAndFirstLogin = isInReturnFirstDay and LobbySystem.isTodayFirstLogin
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide isReturnFirstDayAndFirstLogin = " .. tostring(isReturnFirstDayAndFirstLogin))
  if isReturnFirstDayAndFirstLogin then
    return false
  end
  local mainLobbyLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local curPage = mainLobbyLogic.curPage
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide curPage = " .. tostring(curPage))
  if curPage ~= ENUM_LobbyPageType.Mid then
    return false
  end
  local b_Lobby_Main_UIBP_Show = UIManager.IsUIShow(UIManager.UI_Config.Lobby_Main_UIBP)
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide b_Lobby_Main_UIBP_Show = " .. tostring(b_Lobby_Main_UIBP_Show))
  if not b_Lobby_Main_UIBP_Show then
    return false
  end
  local isWindowOB = Client.IsWindowOB()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide isWindowOB = " .. tostring(isWindowOB))
  if isWindowOB then
    return false
  end
  local bOthersUIShow = self:IsUIShow()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide bOthersUIShow = " .. tostring(bOthersUIShow))
  if bOthersUIShow then
    return false
  end
  local ModuleManager = require("client.module_framework.ModuleManager")
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local isInSlap = NewFaceSlapSystem:IsInSlap()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide isInSlap = " .. tostring(isInSlap))
  log(bWriteLog and "logic_main_city_newbie_guide_entry:CheckShowMainCityEntryGuide IsSlapStart = " .. tostring(NewFaceSlapSystem:IsSlapStart()))
  if isInSlap then
    return false
  end
  return true
end
function logic_main_city_newbie_guide_entry:IsUIShow()
  log(bWriteLog and "logic_main_city_newbie_guide_entry:IsUIShow")
  for keyName, _ in pairs(OthersUICfg) do
    local cfg = UIManager.GetConfigByKey(keyName)
    if cfg and UIManager.IsUIShow(cfg) then
      log(bWriteLog and "logic_main_city_newbie_guide_entry:IsUIShow keyName = " .. tostring(keyName))
      return true
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_main_city_newbie_guide_entry)
return CModuleTemplate