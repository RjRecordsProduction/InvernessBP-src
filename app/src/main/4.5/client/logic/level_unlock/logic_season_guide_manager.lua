local logic_season_guide_manager = {}
local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
local level_unlock_config = require("client.logic.level_unlock.config.level_unlock_config")
local level_unlock_ui_util = require("client.logic.level_unlock.util.level_unlock_ui_util")
function logic_season_guide_manager:DefineAndResetData()
  self.checkForSeasonForceGuide = false
  self.classicRankCount = 0
end
function logic_season_guide_manager:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_season_guide_manager:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    self.checkForSeasonForceGuide = true
  end
end
function logic_season_guide_manager:StartSeasonGuide()
  log(bWriteLog and "logic_season_guide_manager:StartSeasonGuide")
  local bCanGuide, widget = self:CheckCanShowSeasonGuide()
  log(bWriteLog and "logic_season_guide_manager:StartSeasonGuide bCanGuide = " .. tostring(bCanGuide) .. " widget = " .. tostring(widget))
  if not bCanGuide then
    return false
  end
  self:ShowSeasonForceGuide(widget)
  return true
end
function logic_season_guide_manager:CheckCanShowSeasonGuide()
  log(bWriteLog and "logic_season_guide_manager:CheckCanShowSeasonGuide")
  if not level_unlock_util:HaveLockedFeature() then
    log(bWriteLog and "logic_season_guide_manager:CheckCanShowSeasonGuide 1")
    return false, nil
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local feature = level_unlock_config.featureDef.season
  local isFeatureUnlocked = level_unlock_manager:IsFeatureUnlocked(feature)
  log(bWriteLog and "logic_season_guide_manager:CheckCanShowSeasonGuide isFeatureUnlocked = " .. tostring(isFeatureUnlocked))
  if not isFeatureUnlocked then
    return false, nil
  end
  local enterSeason = self.enter_season or 0
  log(bWriteLog and "logic_season_guide_manager:CheckCanShowSeasonGuide enterSeason = " .. tostring(enterSeason) .. " self.classicRankCount = " .. tostring(self.classicRankCount))
  if enterSeason ~= 0 or not (0 < self.classicRankCount) then
    return false, nil
  end
  local needShowLevelup = level_unlock_manager:NeedShowLevelup()
  log(bWriteLog and "logic_season_guide_manager:CheckCanShowSeasonGuide needShowLevelup = " .. tostring(needShowLevelup))
  if needShowLevelup then
    return false, nil
  end
  local systemList = level_unlock_manager:GetSystemList()
  local allGuideConfig = systemList[level_unlock_config.featureDef.season]
  local guideConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 1)
  if not guideConfig then
    return false, nil
  end
  local isSeasonUIShow = UIManager.IsUIShow(UIManager.UI_Config.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP)
  log(bWriteLog and "logic_season_guide_manager:CheckCanShowSeasonGuide isSeasonUIShow = " .. tostring(isSeasonUIShow))
  if isSeasonUIShow then
    return false, nil
  end
  local isAndroidStackEmpty, failedUI = UIManager.IsAndroidStackEmpty()
  if not isAndroidStackEmpty then
    log_warning(bWriteLog and "logic_season_guide_manager:CheckCanShowSeasonGuide not isAndroidStackEmpty. failedUI = " .. tostring(failedUI))
    return
  end
  if GameStatus.IsIn2DLobby() then
    local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if lobbyMain:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
      log_warning(bWriteLog and "logic_season_guide_manager:CheckCanShowSeasonGuide lobbyMain is nil or hidden")
      return false
    end
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    if Lobby_Main_Control.curPage ~= ENUM_LobbyPageType.Mid then
      log_warning(bWriteLog and "logic_season_guide_manager:CheckCanShowSeasonGuide not in mid page")
      return false
    end
  end
  local widget = level_unlock_ui_util:GetTargetWidget(guideConfig, true)
  if not widget then
    return false, nil
  end
  return true, widget
end
function logic_season_guide_manager:ShowSeasonForceGuide(widget)
  log(bWriteLog and "logic_season_guide_manager:ShowSeasonForceGuide")
  local ui = UIManager.GetUI(UIManager.UI_Config.level_unlock_bubble)
  if ui then
    UIManager.CloseUI(UIManager.UI_Config.level_unlock_bubble)
  end
  local text = LocUtil.GetLocalizeResStr(29729)
  local cb = function()
    level_unlock_ui_util:JumpToModule(level_unlock_config.featureDef.season, true)
    self.enter_season = 1
  end
  self:AddTimerOnce(0, function()
    if not slua.isValid(widget) then
      return
    end
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local ParamTable = ui_show_queue_config.GetParamTable(nil, "IsLobbyLevelUnLock")
    UIManager.ShowUI(UIManager.UI_Config.level_unlock_bubble, 1, text, widget, cb, true, false, nil, nil, ParamTable)
  end)
end
function logic_season_guide_manager:SetEnterSeason()
  log(bWriteLog and "logic_season_guide_manager:SetEnterSeason")
  self.enter_season = 1
end
function logic_season_guide_manager:OnSyncEnterSeason(enter_season)
  log(bWriteLog and "logic_season_guide_manager:OnSyncEnterSeason enter_season = " .. tostring(enter_season) .. " self.enter_season = " .. tostring(self.enter_season))
  if self.enter_season == 1 then
    return
  end
  if not enter_season then
    return
  end
  self.end
function logic_season_guide_manager:OnGetUnlockData(unlockData)
  log(bWriteLog and "logic_season_guide_manager:OnGetUnlockData")
  if not unlockData then
    return
  end
  if unlockData.module_process then
    self.enter_season = unlockData.module_process.enter_season
  end
  if not self.enter_season then
    self.enter_season = 0
  end
end
function logic_season_guide_manager:RecordClassicRankCount(count)
  log(bWriteLog and "logic_season_guide_manager:RecordClassicRankCount count = " .. tostring(count))
  if count then
    self.classicRankCount = count
  end
end
function logic_season_guide_manager:RecordClassicRank(isClassicRank)
  log(bWriteLog and "logic_season_guide_manager:RecordClassicRank isClassicRank = " .. tostring(isClassicRank))
  self.end
function logic_season_guide_manager:AddMatchCount(add)
  log(bWriteLog and "logic_season_guide_manager:AddMatchCount add = " .. tostring(add))
  if self.isClassicRank and add and self.classicRankCount then
    self.classicRankCount = self.classicRankCount + add
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_season_guide_manager = class(CModuleBase, nil, logic_season_guide_manager)
return Clogic_season_guide_manager