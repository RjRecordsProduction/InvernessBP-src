local level_unlock_jump_config = {}
function level_unlock_jump_config.GuideCbNewbieUpgradeMain(in_config)
  log(bWriteLog and "GuideCbNewbieUpgradeMain 1")
  local eventIndex
  eventIndex = EventSystem:registEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_VIEW_ITEM_ANIM_APPEAR_END, function(_, __, map_item, view_id)
    local target_view_id = 10411
    log(bWriteLog and string.format("GuideCbNewbieUpgradeMain view_id[%s] target_view_id[%s]", tostring(view_id), tostring(target_view_id)))
    if view_id ~= target_view_id then
      return
    end
    EventSystem:UnregistEventByID(eventIndex)
    log(bWriteLog and "GuideCbNewbieUpgradeMain 3 " .. tostring(eventIndex))
    if map_item.GetNewbieGuideWidget then
      local target_widget = map_item:GetNewbieGuideWidget()
      if target_widget then
        log(bWriteLog and "[GuideThemeView] OnViewItemAnimAppearEnd")
        local guide_text = LocUtil.GetLocalizeResStr(49717)
        UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 2, guide_text, target_widget, nil, true, 2)
      end
    end
  end)
  local jump_url = "game://?module=1008403&menuList=240|200"
  GlobalData.JumpUrl(jump_url)
end
function level_unlock_jump_config.GuideCbAchievement(in_config, feature)
  local logicAchievement = require("client.slua.logic.achievement.logic_achievement")
  logicAchievement.JumpUrl()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(feature)
end
function level_unlock_jump_config.GuideCbTeamLobby(in_config, feature)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.ShowUI()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(feature)
end
function level_unlock_jump_config.GuideCbSocialIsland()
  GlobalData.JumpUrl("game://?module=1008403")
end
function level_unlock_jump_config.GuideCbSocialIslandStep2(in_config, feature)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local cb = function()
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    ui_jump_manager.Clear()
    UIManager.CloseUI(UIManager.UI_Config.mode_selection_main)
  end
  logic_mode_selection:EnterSocialIsland(cb)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(feature)
end
function level_unlock_jump_config.GuideCbMatchMode()
  GlobalData.JumpUrl("game://?module=1008403&menuList=200")
end
function level_unlock_jump_config:GuideCbMatchModeStep2()
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
  if uiInfo then
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    uiInfo:JumpToAlphaMenuByTabID(mode_selection_macro.Enum_TabID.RankClassic)
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.matchMode)
  end
end
function level_unlock_jump_config.GuideCbTeamCompetitionMode()
  GlobalData.JumpUrl("game://?module=1008403&menuList=200")
end
function level_unlock_jump_config.GuideCbTeamCompetitionModeStep2()
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
  if uiInfo then
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    uiInfo:JumpToBetaMenuByTabID(mode_selection_macro.Enum_TabID.MatchArena)
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.teamCompetitionMode)
  end
end
function level_unlock_jump_config.GuideCbPveMode()
  GlobalData.JumpUrl("game://?module=1008403&viewId=10353")
end
function level_unlock_jump_config.GuideCbPVEStep2()
  UIManager.CloseUI(UIManager.UI_Config.mode_selection_main)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local info = logic_mode_selection:GetFilterInfo()
  logic_mode_selection:SetSelectView(10353, info)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.pveMode)
end
function level_unlock_jump_config.GuideCbEntertainMode()
  GlobalData.JumpUrl("game://?module=1008403&menuList=200")
end
function level_unlock_jump_config.GuideCbEntertainModeStep2()
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
  if uiInfo then
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    uiInfo:JumpToBetaMenuByTabID(mode_selection_macro.Enum_TabID.Other)
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.entertainMode)
  end
end
function level_unlock_jump_config.GuideCbSeason()
  GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_SEASON)
end
function level_unlock_jump_config.GuideCbCrops(in_config, feature)
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if uiInfo then
    local childUI = uiInfo:GetChildUI(UIManager.UI_Config.lobby_main_right_bottom_tab)
    if childUI then
      childUI:OnButton_FoldUI_BottomRightClick()
    end
  end
end
function level_unlock_jump_config.GuideCbCropsStep2(in_config, feature)
  GlobalData.JumpUrl("game://?module=1003300")
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.corps)
end
function level_unlock_jump_config.GuideCbMainCity()
  GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_MAIN_CITY_ENTER)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.mainCity)
end
function level_unlock_jump_config:GuideCbEnterHome()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local LobbyMidMessageUIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Message_UIBP)
    if LobbyMidMessageUIBP then
      local uiInfo = LobbyMidMessageUIBP:GetChildWindow(UIManager.UI_Config.Lobby_Home_Entrance_Item_UIBP)
      if uiInfo then
        uiInfo:OnClickButton_Entry()
      end
    end
  end
end
function level_unlock_jump_config:GuideCbEnterHome_MainCity()
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.MainCity_Main_Tab_UIBP)
  if uiInfo then
    uiInfo:OnClickButton_Home()
  end
end
function level_unlock_jump_config.GuideCbWorkShop()
  level_unlock_jump_config.OpenLobbyLabEntrance()
end
function level_unlock_jump_config.GuideCbWorkShopStep2()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.workshop)
  UIManager.CloseUI(UIManager.UI_Config.lobby_lab_entrance)
  local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
  NewCharacterSystem:JumpToCharacter()
end
function level_unlock_jump_config.GuideCbWorkShopPet()
  level_unlock_jump_config.OpenLobbyLabEntrance()
end
function level_unlock_jump_config.GuideCbWorkShopPetStep2()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.workshopPet)
  UIManager.CloseUI(UIManager.UI_Config.lobby_lab_entrance)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:EnterMain()
end
function level_unlock_jump_config.GuideCbWorkShopPet_MainCity()
  level_unlock_jump_config.OpenMainCityLabEntrance()
end
function level_unlock_jump_config.GuideCbWorkShopPetStep2_MainCity()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.workshopPet)
  UIManager.CloseUI(UIManager.UI_Config.MainCity_Tab_Entrance_UIBP)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:EnterMain()
end
function level_unlock_jump_config.OpenLobbyLabEntrance()
  local bSwitch = LobbySystem.CheckLobbyMenuOpen(BP_ENUM_SWITCH_WORK_SHOP, true)
  if not bSwitch then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.lobby_lab_entrance)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickMain(UIManager.UI_Config.lobby_lab_entrance)
end
function level_unlock_jump_config.GuideCbWorkShop_MainCity()
  level_unlock_jump_config.OpenMainCityLabEntrance()
end
function level_unlock_jump_config.GuideCbWorkShopStep2_MainCity()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.workshop)
  UIManager.CloseUI(UIManager.UI_Config.MainCity_Tab_Entrance_UIBP)
  local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
  NewCharacterSystem:JumpToCharacter()
end
function level_unlock_jump_config.OpenMainCityLabEntrance()
  local bSwitch = LobbySystem.CheckLobbyMenuOpen(BP_ENUM_SWITCH_WORK_SHOP, true)
  log(bWriteLog and "MainCity_Main_Tab_UIBP:OnClickButton_Workshop bSwitch = " .. tostring(bSwitch))
  if not bSwitch then
    return
  end
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.MainCity_Main_Tab_UIBP)
  if uiInfo then
    uiInfo:ShowWorkShopUI()
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickMain(UIManager.UI_Config.MainCity_Tab_Entrance_UIBP)
end
function level_unlock_jump_config.GuideCbCollectCard()
  local CardCollectionUtil = require("GameLua.Mod.Lobby.Base.CardCollection.logic.CardCollectionUtil")
  local CardCollectionSeasonUIConfig = require("GameLua.Mod.Lobby.Base.CardCollection.logic.CardCollectionSeasonUIConfig")
  CardCollectionUtil.OpenPanel(CardCollectionSeasonUIConfig.ECardCollectionPanelType.Main)
end
return level_unlock_jump_config