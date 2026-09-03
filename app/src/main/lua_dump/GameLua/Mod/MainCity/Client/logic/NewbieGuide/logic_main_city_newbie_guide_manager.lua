local logic_main_city_newbie_guide_manager = {}
function logic_main_city_newbie_guide_manager:RegistEvents()
  log(bWriteLog and "logic_main_city_newbie_guide_manager:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_NEWBIEGUIDE_STEP_FINISH, self.OnMainCityNewbieGuideStepFinish, self)
end
function logic_main_city_newbie_guide_manager:OnMainCityNewbieGuideStepFinish(_, __, stepID)
  log(bWriteLog and "logic_main_city_newbie_guide_manager:OnMainCityNewbieGuideStepFinish stepID = " .. tostring(stepID))
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_main_city_newbie_guide_manager:OnMainCityNewbieGuideStepFinish not GameStatus.IsInLobbyOrMainCity()")
    return
  end
  local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
  if newbie_guide_util.GetMCNewbieActivityTip() then
    self:OnMainCityNewbieGuideStepFinish_ABTest(stepID)
    return
  end
  self:OnMainCityNewbieGuideStepFinish_Normal(stepID)
end
function logic_main_city_newbie_guide_manager:OnMainCityNewbieGuideStepFinish_Normal(stepID)
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  if stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_ENTRY_GUIDE_ID then
    local logic_main_city_newbie_guide_sequence = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_sequence)
    logic_main_city_newbie_guide_sequence:StartNewBieGuide_Sequence()
  elseif stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_SEQUENCE_GUIDE_ID then
    local logic_main_city_newbie_guide_popup = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_popup)
    logic_main_city_newbie_guide_popup:StartNewBieGuide_ShowPopup()
  elseif stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_POPUP_GUIDE_ID then
    local logic_main_city_newbie_guide_explore = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_explore)
    logic_main_city_newbie_guide_explore:StartNewBieGuide_Explore()
  elseif stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_EXPLORE_GUIDE_ID then
    local logic_main_city_newbie_guide_fold = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_fold)
    logic_main_city_newbie_guide_fold:StartNewBieGuide_Fold()
  elseif stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_FOLD_GUIDE_ID then
    local logic_main_city_newbie_guide_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_setting)
    logic_main_city_newbie_guide_setting:StartNewBieGuide_Setting()
  end
end
function logic_main_city_newbie_guide_manager:OnMainCityNewbieGuideStepFinish_ABTest(stepID)
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  if stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_ENTRY_GUIDE_ID then
    local logic_main_city_newbie_guide_sequence = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_sequence)
    logic_main_city_newbie_guide_sequence:StartNewBieGuide_Sequence()
  elseif stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_SEQUENCE_GUIDE_ID then
    local logic_main_city_newbie_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_activity_guide)
    logic_main_city_newbie_activity_guide:StartNewBieGuide_Activity()
  elseif stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_NEWBIE_ACTIVITY_GUIDE_ID then
    local logic_main_city_newbie_guide_first_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_first_match)
    logic_main_city_newbie_guide_first_match:StartNewBieGuide_FirstMatch()
  elseif stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_NEWBIE_FIRST_MATCH_GUIDE_ID then
    local logic_main_city_newbie_guide_popup = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_popup)
    logic_main_city_newbie_guide_popup:StartNewBieGuide_ShowPopup()
  elseif stepID == newbie_guide_config.EMainCityGuideID.MAINCITY_POPUP_GUIDE_ID then
    local logic_main_city_newbie_guide_explore = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_explore)
    logic_main_city_newbie_guide_explore:StartNewBieGuide_Explore()
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_main_city_newbie_guide_manager = class(CModuleBase, nil, logic_main_city_newbie_guide_manager)
return Clogic_main_city_newbie_guide_manager