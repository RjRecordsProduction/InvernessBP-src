local level_unlock_manager = {}
local unlockLevelKey = "UnlockLevelExp"
local level_unlock_config = require("client.logic.level_unlock.config.level_unlock_config")
local ELockType = level_unlock_config.ELockType
local ELobbyType = level_unlock_config.ELobbyType
local ETipDir = level_unlock_config.ETipDir
local ETipStyle = level_unlock_config.ETipStyle
local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
local level_unlock_ui_util = require("client.logic.level_unlock.util.level_unlock_ui_util")
level_unlock_manager.featureDef = level_unlock_config.featureDef
local levelUnlockConfigList = {}
local silentUnlockConfigList = {}
local systemList
function level_unlock_manager:OnInitialize()
  level_unlock_manager.__super.OnInitialize(self)
  self.oldLevel = nil
  self.currentGuideFeature = nil
  self.levelToUnlock = {}
  self.levelToSilentUnlock = {}
  self.featureToUnlock = {}
  self.mainModuleToGuideConfig = {}
  self.hideFeatureList = {}
  self.waiting = false
  self.ShowFoldButtonNewSign = false
  self.unlockAnimPlayed = {}
  self.delayGuideQueue = {}
  self.hasInitLevelUnLockConfig = false
  self.hasInitLevelUnLockAward = false
  systemList = level_unlock_config.InitUnlockGuideConfig()
end
function level_unlock_manager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LEVEL_UP_PANEL, self.ShowLevelUpPanel, self)
end
function level_unlock_manager:OnPostSwitchGameStatus(preState, nextState)
end
function level_unlock_manager:OnGetUnlockData(newbie_level_unlock)
  log_tree("level_unlock_manager:OnGetUnlockData. unlockData = ", newbie_level_unlock)
  self:InitLevelUnLockConfig(newbie_level_unlock)
  self:TrySendLevelUnlockGetEvent()
end
function level_unlock_manager:InitLevelUnLockConfig(newbie_level_unlock)
  if not newbie_level_unlock then
    return
  end
  local unlockConfig = newbie_level_unlock.cfg
  unlockConfig = self:DoWithGuestUnlockData(unlockConfig)
  levelUnlockConfigList = {}
  silentUnlockConfigList = {}
  if not unlockConfig then
    log_warning(bWriteLog and "level_unlock_manager:InitLevelUnLockConfig unlockData.cfg is nil")
    return
  end
  for level, v in pairs(unlockConfig) do
    local systemID = v.func1
    if level_unlock_util:IsFeatureIDValid(systemID) then
      local systemConfig = systemList[systemID]
      if not systemConfig then
        log_error_format("level_unlock_manager:InitLevelUnLockConfig systemID is invalid. systemID = [%s]", systemID)
      end
      levelUnlockConfigList[#levelUnlockConfigList + 1] = {
        currentUnlock = systemID,
        unlockLevel = tonumber(level),
        localizeID = systemConfig and systemConfig.SystemName or "",
        icon = systemConfig and systemConfig.IconPath or ""
      }
    end
    systemID = v.func2
    if level_unlock_util:IsFeatureIDValid(systemID) then
      silentUnlockConfigList[#silentUnlockConfigList + 1] = {
        currentUnlock = systemID,
        unlockLevel = tonumber(level)
      }
    end
  end
  self.hasInitLevelUnLockConfig = true
  table.sort(levelUnlockConfigList, function(a, b)
    return a.unlockLevel < b.unlockLevel
  end)
  table.sort(silentUnlockConfigList, function(a, b)
    return a.unlockLevel < b.unlockLevel
  end)
  for i = 1, #levelUnlockConfigList do
    local config = levelUnlockConfigList[i]
    self.levelToUnlock[config.unlockLevel] = config
    self.featureToUnlock[config.currentUnlock] = config
    if config.currentUnlock then
      local unlockGuideConfig = systemList[config.currentUnlock]
      if unlockGuideConfig then
        unlockGuideConfig.feature = config.currentUnlock
        unlockGuideConfig.unlockLevel = config.unlockLevel
        self:AddGuideByUIConfig(unlockGuideConfig)
      end
    end
  end
  for i = 1, #silentUnlockConfigList do
    local config = silentUnlockConfigList[i]
    local unlockGuideConfig = systemList[config.currentUnlock]
    if unlockGuideConfig then
      unlockGuideConfig.feature = config.currentUnlock
      unlockGuideConfig.unlockLevel = config.unlockLevel
      self.levelToSilentUnlock[config.unlockLevel] = config
      self.featureToUnlock[config.currentUnlock] = config
    end
  end
end
function level_unlock_manager:DoWithGuestUnlockData(unlockConfig)
  if not level_unlock_ui_util:CheckIsGuest() then
    return unlockConfig
  end
  local TableUtil = require("common.table_util")
  local guestUnlockConfig = TableUtil.CopyTable(unlockConfig)
  for featureID, level in pairs(level_unlock_config.GuestUnLockFeatures) do
    for k, v in pairs(guestUnlockConfig) do
      if v.func1 == featureID then
        local targetConfig = guestUnlockConfig[level]
        if targetConfig then
          local isReplace = false
          if targetConfig.func1 == 0 then
            targetConfig.func1 = v.func1
            targetConfig.des1 = v.des1
            isReplace = true
          elseif targetConfig.func2 == 0 then
            targetConfig.func2 = v.func1
            targetConfig.des2 = v.des1
            isReplace = true
          end
          if isReplace then
            log_format("level_unlock_manager:DoWithGuestUnlockData replace. featureID = [%s], level = [%s]", featureID, level)
            v.func1 = 0
            v.des1 = 0
            break
          end
        end
      end
    end
  end
  log_tree("level_unlock_manager:DoWithGuestUnlockData guestUnlockConfig = ", guestUnlockConfig)
  return guestUnlockConfig
end
function level_unlock_manager:SetHasInitLevelUnLockAward(isInit)
  log_format("level_unlock_manager:SetHasInitLevelUnLockAward. isInit = [%s]", isInit)
  self.hasInitLevelUnLockAward = isInit
  if self.hasInitLevelUnLockAward then
    self:TrySendLevelUnlockGetEvent()
  end
end
function level_unlock_manager:TrySendLevelUnlockGetEvent()
  if not self.hasInitLevelUnLockConfig then
    log_warning(bWriteLog and "level_unlock_manager:TrySendLevelUnlockGetEvent not init level unlock config")
    return
  end
  if not self.hasInitLevelUnLockAward then
    log_warning(bWriteLog and "level_unlock_manager:TrySendLevelUnlockGetEvent not init level unlock award")
    return
  end
  log(bWriteLog and "level_unlock_manager:TrySendLevelUnlockGetEvent")
  EventSystem:postEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_GET_DATA)
end
function level_unlock_manager:AddGuideByUIConfig(allGuideConfig)
  if not allGuideConfig then
    return
  end
  local uiConfig
  local lobbySecondaryGuideConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 2, ELobbyType.Lobby)
  if lobbySecondaryGuideConfig then
    uiConfig = UIManager.UI_Config[lobbySecondaryGuideConfig.TargetUIConfig]
    self:AddGuideByModuleName(uiConfig, allGuideConfig)
  end
  local mainCitySecondaryGuideConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 2, ELobbyType.MainCity)
  if mainCitySecondaryGuideConfig then
    uiConfig = UIManager.UI_Config[mainCitySecondaryGuideConfig.TargetUIConfig]
    self:AddGuideByModuleName(uiConfig, allGuideConfig)
  end
end
function level_unlock_manager:AddGuideByModuleName(uiConfig, allGuideConfig)
  if uiConfig and uiConfig.moduleName then
    local moduleName = uiConfig.moduleName
    if not self.mainModuleToGuideConfig[moduleName] then
      self.mainModuleToGuideConfig[moduleName] = {}
    end
    local canAdd = true
    for k, v in pairs(self.mainModuleToGuideConfig[moduleName]) do
      if v.feature == allGuideConfig.feature then
        canAdd = false
        break
      end
    end
    if canAdd then
      table.insert(self.mainModuleToGuideConfig[moduleName], allGuideConfig)
    end
  end
end
function level_unlock_manager:CheckForHideFeature(widget, feature, moduleId)
  log(bWriteLog and "level_unlock_manager:CheckForHideFeature feature = " .. tostring(feature))
  local bOpen = moduleId and LobbySystem.CheckLobbyMenuOpen(moduleId, false)
  if moduleId and not bOpen then
    log(bWriteLog and "level_unlock_manager:CheckForHideFeature entry not open moduleId" .. tostring(moduleId))
    level_unlock_ui_util:SetWidgetVisible(widget, false)
    return
  end
  if not level_unlock_util:HaveLockedFeature() then
    return
  end
  self:CheckCanShowSeasonGuide(feature)
  local currentLevel = DataMgr.roleData.level
  local unlockGuideConfig = systemList[feature]
  if not unlockGuideConfig then
    log_warning(bWriteLog and "level_unlock_manager:CheckForHideFeature unlockGuideConfig not found")
    return
  end
  local config = level_unlock_ui_util:GetGuideStepConfig(unlockGuideConfig, 1)
  if not config then
    log_warning(bWriteLog and "level_unlock_manager:CheckForHideFeature config not found")
    return
  end
  if config.EntranceDisplayType ~= ELockType.hide then
    log_warning(bWriteLog and "level_unlock_manager:CheckForHideFeature not need hide")
    return
  end
  local requireLevel = unlockGuideConfig.unlockLevel
  if not requireLevel or currentLevel >= requireLevel then
    log_warning_format("level_unlock_manager:CheckForHideFeature already unlock. currentLevel = [%s], requireLevel = [%s]", currentLevel, requireLevel)
    return
  end
  self.hideFeatureList[feature] = true
  level_unlock_ui_util:SetWidgetVisible(widget, false)
end
function level_unlock_manager:CheckCanShowSeasonGuide(feature)
  log_format("level_unlock_manager:CheckCanShowSeasonGuide feature = [%s]", feature)
  if feature ~= level_unlock_config.featureDef.season then
    return
  end
  local isLevelUpShow = UIManager.IsUIShow(UIManager.UI_Config.LevelUnlock_Segment_New_UIBP)
  if isLevelUpShow then
    log_warning(bWriteLog and "level_unlock_manager:CheckCanShowSeasonGuide level up panel is show")
    return
  end
  if self:NeedShowLevelup() then
    log_warning(bWriteLog and "level_unlock_manager:CheckCanShowSeasonGuide need show level up")
    return
  end
  local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
  if not logic_season_guide_manager.checkForSeasonForceGuide then
    log_warning(bWriteLog and "level_unlock_manager:CheckCanShowSeasonGuide checkForSeasonForceGuide is false")
    return
  end
  logic_season_guide_manager.checkForSeasonForceGuide = false
  logic_season_guide_manager:StartSeasonGuide()
end
function level_unlock_manager:OnClickMain(moduleConfig)
  log(bWriteLog and "level_unlock_manager:OnClickMain")
  log_tree(bWriteLog and "moduleConfig = ", moduleConfig)
  if not level_unlock_util:IsSwitchOpen() then
    return
  end
  if not moduleConfig then
    return
  end
  local fromModule = moduleConfig.moduleName
  if not fromModule then
    return
  end
  local allGuideConfigList = self.mainModuleToGuideConfig[fromModule]
  if not allGuideConfigList or #allGuideConfigList == 0 then
    log(bWriteLog and "level_unlock_manager:OnClickMain no guide config list")
    return
  end
  for i = 1, #allGuideConfigList do
    local allGuideConfig = allGuideConfigList[i]
    self:UpdateSecondaryGuide(allGuideConfig)
    if self.currentGuideFeature == allGuideConfig.feature then
      local mainConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 1)
      local secondaryConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 2)
      if mainConfig then
        level_unlock_ui_util:HideNewMark(mainConfig, true)
      end
      if secondaryConfig then
        self:StartUnlockGuideImpl(secondaryConfig, allGuideConfig.feature, false)
      end
    end
  end
end
function level_unlock_manager:OnClickFeature(featureDef)
  if not level_unlock_util:IsSwitchOpen() or not featureDef then
    return
  end
  local config = self.featureToUnlock[featureDef]
  if config then
    local unlockGuideConfig = systemList[config.currentUnlock]
    local mainConfig = level_unlock_ui_util:GetGuideStepConfig(unlockGuideConfig, 1)
    local secondaryConfig = level_unlock_ui_util:GetGuideStepConfig(unlockGuideConfig, 2)
    if mainConfig then
      level_unlock_ui_util:HideNewMark(mainConfig, true)
    end
    if secondaryConfig then
      level_unlock_ui_util:HideNewMark(secondaryConfig, false)
    end
  end
  if self.currentGuideFeature == featureDef then
    self.currentGuideFeature = nil
  end
end
function level_unlock_manager:UpdateSecondaryGuide(allGuideConfig)
  if not allGuideConfig then
    log(bWriteLog and "=======>LevelUnlock guide config is nil")
    return
  end
  local guideConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 2)
  if not guideConfig then
    log(bWriteLog and "=======>LevelUnlock, guideConfig is nil")
    return
  end
  local uiConfig = UIManager.UI_Config[guideConfig.TargetUIConfig]
  if not uiConfig then
    log(bWriteLog and "=======>LevelUnlock, uiconfig is nil")
    return
  end
  local currentLevel = DataMgr.roleData.level
  local unlockLevel = allGuideConfig.unlockLevel
  local visible = currentLevel < unlockLevel
  level_unlock_ui_util:SetDynamicVisibleWidget(guideConfig, visible)
end
function level_unlock_manager:StartUnlockGuide(currentLevel)
  log(bWriteLog and "level_unlock_manager:StartUnlockGuide currentLevel = " .. currentLevel)
  if not self:CheckCanStartUnlockGuide() then
    log(bWriteLog and "level_unlock_manager:StartUnlockGuide CheckCanStartUnlockGuide return false")
    self:AddToDelayGuideQueue(currentLevel)
    return
  end
  self:ExecuteStartUnlockGuide(currentLevel)
end
function level_unlock_manager:ExecuteStartUnlockGuide(currentLevel)
  log(bWriteLog and "level_unlock_manager:ExecuteStartUnlockGuide currentLevel = " .. tostring(currentLevel))
  EventSystem:postEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_START_UNLOCK_GUIDE, currentLevel)
  self:ShowHideFeature(currentLevel)
  local config = self.levelToUnlock[currentLevel]
  config = self:CheckUnlockGuide(config)
  if config then
    log(bWriteLog and "=======>LevelUnlock start unlock guide: " .. currentLevel)
    local unlockGuideConfig = systemList[config.currentUnlock]
    if not unlockGuideConfig then
      log(bWriteLog and "level_unlock_manager:ExecuteStartUnlockGuide, unlockGuideConfig is nil")
      return
    end
    local mainConfig = level_unlock_ui_util:GetGuideStepConfig(unlockGuideConfig, 1)
    if not mainConfig then
      log(bWriteLog and "level_unlock_manager:ExecuteStartUnlockGuide, mainConfig is nil")
      return
    end
    self.currentGuideFeature = unlockGuideConfig.feature
    self:StartUnlockGuideImpl(mainConfig, unlockGuideConfig.feature, true)
    if self.ShowFoldButtonNewSign then
      EventSystem:postEvent(EVENTTYPE_COMMUNITY, EVENTID_COMMUNITY_NOTIFY_REDDOT_INFO)
    end
  end
  local silentConfig = self.levelToSilentUnlock[currentLevel]
  if silentConfig then
    local unlockGuideConfig = systemList[silentConfig.currentUnlock]
    if not unlockGuideConfig then
      log(bWriteLog and "level_unlock_manager:ExecuteStartUnlockGuide, silent unlockGuideConfig is nil")
      return
    end
    local mainConfig = level_unlock_ui_util:GetGuideStepConfig(unlockGuideConfig, 1)
    if not mainConfig then
      log(bWriteLog and "level_unlock_manager:ExecuteStartUnlockGuide, silent mainConfig is nil")
      return
    end
    self:StartUnlockGuideImpl(mainConfig, unlockGuideConfig.feature, true)
  end
end
function level_unlock_manager:StartUnlockGuideImpl(guideConfig, featureDef, isMain)
  if guideConfig.TargetUIConfig then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.1, function()
      local childWidget = level_unlock_ui_util:GetTargetWidget(guideConfig, isMain)
      if childWidget then
        self:StartUnlockTip(childWidget, featureDef, isMain)
      end
    end)
  end
  self.ShowFoldButtonNewSign = guideConfig.ShowFoldButtonNewSign
  level_unlock_ui_util:ShowNewMark(guideConfig, isMain)
end
function level_unlock_manager:ShowHideFeature(currentLevel)
  log(bWriteLog and "level_unlock_manager:ShowHideFeature currentLevel = " .. tostring(currentLevel))
  log_tree(bWriteLog and "self.hideFeatureList = ", self.hideFeatureList)
  for systemID, v in pairs(self.hideFeatureList) do
    local unlockGuideConfig = systemList[systemID]
    if v and unlockGuideConfig and unlockGuideConfig.unlockLevel and currentLevel >= unlockGuideConfig.unlockLevel then
      local lobbyGuideConfig = level_unlock_ui_util:GetGuideStepConfig(unlockGuideConfig, 1, ELobbyType.Lobby)
      self:ShowHideFeatureByGuideConfig(systemID, lobbyGuideConfig)
      local mainCityGuideConfig = level_unlock_ui_util:GetGuideStepConfig(unlockGuideConfig, 1, ELobbyType.MainCity)
      self:ShowHideFeatureByGuideConfig(systemID, mainCityGuideConfig)
    end
  end
end
function level_unlock_manager:ShowHideFeatureByGuideConfig(systemID, guideConfig)
  if not guideConfig or guideConfig.EntranceDisplayType ~= ELockType.hide then
    return
  end
  log(bWriteLog and "level_unlock_manager:ShowHideFeatureByGuideConfig. systemID = " .. tostring(systemID))
  local childWidget = level_unlock_ui_util:GetTargetWidget(guideConfig, true, false)
  if childWidget then
    level_unlock_ui_util:SetWidgetVisible(childWidget, true)
    self.hideFeatureList[systemID] = false
  end
end
function level_unlock_manager:StartUnlockTip(widget, unlockFeature, isMain)
  local allGuideConfig = systemList[unlockFeature]
  if not allGuideConfig then
    log(bWriteLog and "level_unlock_manager:StartUnlockTip feature = " .. tostring(unlockFeature) .. " allGuideConfig is nil")
    return
  end
  local mainConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 1)
  local secondaryConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 2)
  local guideConfig
  if not isMain then
    guideConfig = secondaryConfig
  else
    guideConfig = mainConfig
  end
  if not guideConfig then
    log(bWriteLog and "level_unlock_manager:StartUnlockTip unlockFeature: " .. tostring(unlockFeature) .. " guide config is nil")
    return
  end
  if not self:CheckCanShowLevelUnLockBubble(guideConfig) then
    log_warning(bWriteLog and "level_unlock_manager:StartUnlockTip Style is nil")
    return
  end
  local text
  if guideConfig.TipID > 0 then
    text = LocUtil.GetLocalizeResStr(guideConfig.TipID)
  end
  local cb = function()
    level_unlock_ui_util:JumpToModule(unlockFeature, isMain)
  end
  log(bWriteLog and "level_unlock_manager:StartUnlockTip show tip: " .. tostring(widget))
  self:AddTimerOnce(0, function()
    local withHand = guideConfig.HandEffect
    local withFlash = guideConfig.FlashEffect
    local tipDir = guideConfig.TipDirection == -1 and ETipDir.right or guideConfig.TipDirection
    local tipStyle = guideConfig.Style
    local forceGuide = not guideConfig.Interruptible
    local extraParams = {style = tipStyle, showFlashEffect = withFlash}
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local ParamTable = ui_show_queue_config.GetParamTable(nil, guideConfig.UIQueueParam)
    UIManager.ShowUI(UIManager.UI_Config.level_unlock_bubble, tipDir, text, widget, cb, withHand, forceGuide, nil, extraParams, ParamTable)
  end)
end
function level_unlock_manager:CheckCanShowLevelUnLockBubble(guideConfig)
  if not guideConfig then
    log(bWriteLog and "level_unlock_manager:CheckCanShowLevelUnLockBubble guide config is nil")
    return false
  end
  local isStypeEmpty = not guideConfig.Style or guideConfig.Style < 0
  local isHandEmpty = not guideConfig.HandEffect
  local isFlashEmpty = not guideConfig.FlashEffect
  if isStypeEmpty and isHandEmpty and isFlashEmpty then
    log_warning_format("level_unlock_manager:CheckCanShowLevelUnLockBubble, isStypeEmpty = [%s], isHandEmpty = [%s], isFlashEmpty = [%s]", isStypeEmpty, isHandEmpty, isFlashEmpty)
    return false
  end
  return true
end
function level_unlock_manager:GetSystemList()
  log(bWriteLog and "level_unlock_manager:GetUnlockGuideConfigMap")
  return systemList
end
function level_unlock_manager:ShowLevelUpPanel()
  log(bWriteLog and "level_unlock_manager RealOnModeSwitch")
  if not self:NeedShowLevelup() then
    log_warning(bWriteLog and "level_unlock_manager:ShowLevelUpPanel NeedShowLevelup return false")
    return
  end
  self:OpenLevelupPanel()
end
function level_unlock_manager:GetUnlockFeature(level)
  local config = self.levelToUnlock[level]
  config = self:CheckUnlockGuide(config)
  local nextUnlockConfig = self.levelToUnlock[level + 1]
  nextUnlockConfig = self:CheckUnlockGuide(nextUnlockConfig)
  local filterFunc = function(targetConfig)
    return targetConfig
  end
  config = filterFunc(config)
  nextUnlockConfig = filterFunc(nextUnlockConfig)
  log_warning_format("level_unlock_manager:GetUnlockFeature. level = [%s], config = [%s], nextUnlockConfig = [%s]", level, config, nextUnlockConfig)
  return config, nextUnlockConfig
end
function level_unlock_manager:CheckUnlockGuide(config)
  if not config then
    return nil
  end
  local allGuideConfig = systemList[config.currentUnlock]
  if allGuideConfig and allGuideConfig.CheckFunction ~= "" then
    local level_unlock_check_config = require("client.logic.level_unlock.config.level_unlock_check_config")
    local func = level_unlock_check_config[allGuideConfig.CheckFunction]
    if type(func) == "function" and not func() then
      return nil
    end
  end
  return config
end
function level_unlock_manager:GetUnlockLevel(feature)
  local featureUnlockConfig = self.featureToUnlock[feature]
  if not featureUnlockConfig then
    log_warning(bWriteLog and "level_unlock_manager:GetUnlockLevel feature = " .. tostring(feature) .. " is nil")
    return nil
  end
  return featureUnlockConfig.unlockLevel
end
function level_unlock_manager:RecordLevel(level)
  log_format("level_unlock_manager:RecordLevel. level = [%s]", level)
  self.oldLevel = level
end
function level_unlock_manager:GetRecordedLevel()
  return self.oldLevel
end
function level_unlock_manager:SaveUnlockLevel(level)
  if not level_unlock_util:HaveLockedFeature() then
    log(bWriteLog and "level_unlock_manager:SaveUnlockLevel have no locked feature")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({unlockLevel = level}, PlayerPrefsSystem.ePlayerPrefsType.unlockLevelKey)
end
function level_unlock_manager:LoadUnlockLevel()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tmp = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.unlockLevelKey)
  if tmp and tmp.unlockLevel then
    return tmp.unlockLevel
  end
  return 1
end
function level_unlock_manager:GetLockTip(feature)
  local featureUnlockConfig = self.featureToUnlock[feature]
  if featureUnlockConfig and featureUnlockConfig.localizeID and featureUnlockConfig.unlockLevel then
    return LocUtil.LocalizeResFormat(29726, LocUtil.GetLocalizeResStr(featureUnlockConfig.localizeID), featureUnlockConfig.unlockLevel)
  end
  return LocUtil.GetLocalizeResStr(29728)
end
function level_unlock_manager:OpenLevelupPanel(useOldPanel)
  if UIManager then
    log(bWriteLog and "level unlock manager OpenLevelupPanel")
    local bReturn = false
    if self.waiting then
      log(bWriteLog and "level_unlock_manager current is waiting")
      bReturn = true
    else
      log(bWriteLog and "level unlock manager OpenLevelupPanel GameStatus " .. GameStatus.GetGameStatus())
      if not GameStatus.IsInLobbyOrMainCity() then
        bReturn = true
      else
        local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
        if LogicTxMissionMain.IsInXMission() then
          log(bWriteLog and "level_unlock_manager OpenLevelupPanel IsInXMission")
          bReturn = true
        elseif UIManager.UI_Config.MainCity_SkipSeq_UIBP and UIManager.IsUIShow(UIManager.UI_Config.MainCity_SkipSeq_UIBP) then
          log(bWriteLog and "level_unlock_manager OpenLevelupPanel MainCity_SkipSeq_UIBP")
          bReturn = true
        else
          local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
          if LobbySystem.CheckUseNewGuide() then
            local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
            local needUpdateRole = newbieGuideManager.NeedUpdateRole()
            if needUpdateRole then
              log(bWriteLog and "level_unlock_manager OpenLevelupPanel needUpdateRole")
              bReturn = true
            elseif not growthprojectMgrB.IsFinishAllNewGuide() then
              local LogicNewbie = require("client.logic.newbie.logic_newbie")
              if growthprojectMgrB.CheckGuideStep(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE, 0) then
                log(bWriteLog and "level_unlock_manager OpenLevelupPanel NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE")
                bReturn = true
              else
              end
            end
          else
            if not growthprojectMgrB.IsFinishAllNewGuide() then
              bReturn = true
            else
            end
          end
        end
      end
    end
    log(bWriteLog and "level_unlock_manager OpenLevelupPanel bReturn " .. tostring(bReturn))
    if bReturn then
      local logic_lobby_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_guide_manager)
      logic_lobby_guide_manager:SetNotShowLevelUpPanel()
      return
    end
    local ui = UIManager.GetUI(UIManager.UI_Config.level_unlock_bubble)
    if ui then
      log(bWriteLog and "close level unlock bubble when open level up panel")
      UIManager.CloseUI(UIManager.UI_Config.level_unlock_bubble)
    end
    if useOldPanel then
      log(bWriteLog and "OpenLevelupPanel level_unlock_levelup")
      UIManager.ShowUI(UIManager.UI_Config.level_unlock_levelup)
    else
      log(bWriteLog and "OpenLevelupPanel LevelUnlock_Segment_New_UIBP")
      local preLevel = self:GetRecordedLevel()
      local curLevel = DataMgr.roleData.level
      UIManager.ShowUI(UIManager.UI_Config.LevelUnlock_Segment_New_UIBP, preLevel, curLevel)
    end
    if level_unlock_util:HaveLockedFeature() then
      local config = self.levelToUnlock[DataMgr.roleData.level]
      if config then
        local allGuideConfig = systemList[config.currentUnlock]
        if allGuideConfig then
          local mainConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 1)
          if mainConfig and mainConfig.TipID then
            UIManager.CloseUI(UIManager.UI_Config.Assembly_Main_UIBP)
            local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
            UnknowPassTunnelSystem.CloseRP()
          end
        end
      end
    end
  end
  self:RecordLevel(DataMgr.roleData.level)
end
function level_unlock_manager:IsFeatureUnlocked(feature, moduleId)
  local bOpen = moduleId and LobbySystem.CheckLobbyMenuOpen(moduleId, false)
  if moduleId and not bOpen then
    log(bWriteLog and "level_unlock_manager:IsFeatureUnlocked entry not open moduleId" .. tostring(moduleId))
    return
  end
  if not level_unlock_util:HaveLockedFeature() then
    log(bWriteLog and "level_unlock_manager:IsFeatureUnlocked no locked feature")
    return true
  end
  local currentLevel = DataMgr.roleData.level
  local featureUnlockConfig = self.featureToUnlock[feature]
  if not featureUnlockConfig then
    log(bWriteLog and "level_unlock_manager:IsFeatureUnlocked no feature config. feature = " .. tostring(feature))
    return true
  end
  log_format("level_unlock_manager:IsFeatureUnlocked. feature = [%s], currentLevel = [%s], needLevel = [%s]", feature, currentLevel, featureUnlockConfig.unlockLevel)
  if currentLevel >= featureUnlockConfig.unlockLevel then
    return true
  end
  return false
end
function level_unlock_manager:IsCurrentUnlockFeature(feature)
  return self.currentGuideFeature == feature
end
function level_unlock_manager:IsShowFoldNew()
  if not level_unlock_util:HaveLockedFeature() then
    return false
  end
  return self.ShowFoldButtonNewSign
end
function level_unlock_manager:ResetShowFoldNew()
  self.ShowFoldButtonNewSign = false
end
function level_unlock_manager:WaitingForLevelUp()
  self.waiting = true
  log(bWriteLog and "level_unlock_manager wait")
end
function level_unlock_manager:StopWaitingForLevelUp()
  self.waiting = false
  log(bWriteLog and "Stop wait")
end
function level_unlock_manager:ShowLevelup()
  self.waiting = false
  log(bWriteLog and "level_unlock_manager show levelup, stop waiting")
  if self:NeedShowLevelup() then
    self:OpenLevelupPanel()
  end
end
function level_unlock_manager:NeedShowLevelup()
  if not level_unlock_util:IsSwitchOpen() then
    log_warning(bWriteLog and "level_unlock_manager:NeedShowLevelup switch is not open")
    return false
  end
  if not self.oldLevel or self.oldLevel >= DataMgr.roleData.level then
    log(bWriteLog and "level_unlock_manager:NeedShowLevelup oldLevel is not less than currentLevel")
    return false
  end
  return true
end
function level_unlock_manager:GetFeatureName(config)
  if config.currentUnlock == level_unlock_config.featureDef.workshop then
    return LocUtil.GetLocalizeResStr(11687)
  end
  return LocUtil.GetLocalizeResStr(config.localizeID)
end
function level_unlock_manager:NeedPlayUnlockAnim(feature)
  if self:IsCurrentUnlockFeature(feature) then
    return not self.unlockAnimPlayed[feature]
  end
end
function level_unlock_manager:UnlockAnimPlayed(feature)
  self.unlockAnimPlayed[feature] = true
end
function level_unlock_manager:CheckCanStartUnlockGuide()
  log(bWriteLog and "level_unlock_manager CheckCanStartUnlockGuide")
  local isIn2DLobby = GameStatus.IsIn2DLobby()
  local isInMainCity = GameStatus.IsInMainCity()
  if not isIn2DLobby and not isInMainCity then
    log_warning(bWriteLog and "level_unlock_manager CheckCanStartUnlockGuide not In2DLobby")
    return false
  end
  return true
end
function level_unlock_manager:AddToDelayGuideQueue(level)
  log(bWriteLog and "level_unlock_manager AddToDelayGuideQueue level " .. level)
  local TableUtil = require("common.table_util")
  if TableUtil.IsInTable(self.delayGuideQueue, level) then
    log_warning(bWriteLog and "level_unlock_manager AddToDelayGuideQueue level " .. level .. " already in queue")
    return
  end
  table.insert(self.delayGuideQueue, level)
  table.sort(self.delayGuideQueue, function(a, b)
    return b < a
  end)
  if self.guideQueueTimer ~= nil then
    log_warning(bWriteLog and "level_unlock_manager AddToDelayGuideQueue lobbyGuideQueue timer is not nil")
    return
  end
  local timer_ticker = require("common.time_ticker")
  self.guideQueueTimer = timer_ticker.AddTimerLoop(0.5, function()
    self:DelayShowGuide()
  end, TIMER_INFINITE, 0.25)
end
function level_unlock_manager:DelayShowGuide()
  log(bWriteLog and "level_unlock_manager DelayShowGuide")
  if not self.guideQueueTimer then
    return
  end
  if not self:CheckCanStartUnlockGuide() then
    return
  end
  local len = #self.delayGuideQueue
  if 0 < len then
    local guideLevel = self.delayGuideQueue[len]
    self:ExecuteStartUnlockGuide(guideLevel)
    table.remove(self.delayGuideQueue, len)
    return
  end
  local timer_ticker = require("common.time_ticker")
  timer_ticker.RemoveTimer(self.guideQueueTimer)
  self.guideQueueTimer = nil
end
function level_unlock_manager:CheckShowLevelUpAndUnlockFeature()
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.LevelUnlock_Segment_New_UIBP)
  log(bWriteLog and "logic_lobby_guide_manager:CheckShowLevelUpAndUnlockFeature uiInfo = " .. tostring(uiInfo))
  if uiInfo then
    local currentUnlockConfig, nextUnlockConfig = self:GetUnlockFeature(DataMgr.roleData.level)
    log_tree(bWriteLog and "logic_lobby_guide_manager:CheckShowLevelUpAndUnlockFeature currentUnlockConfig = ", currentUnlockConfig)
    log_tree(bWriteLog and "logic_lobby_guide_manager:CheckShowLevelUpAndUnlockFeature nextUnlockConfig = ", nextUnlockConfig)
    if currentUnlockConfig or nextUnlockConfig then
      return true
    end
  end
  return false
end
function level_unlock_manager:GetCurrentGuideFeature()
  return self.currentGuideFeature
end
function level_unlock_manager:NeedShowCurrentLevelGuideFeature()
  local feature = self:GetCurrentGuideFeature()
  if not feature then
    log_warning(bWriteLog and "level_unlock_manager:NeedShowCurrentLevelGuideFeature feature is nil")
    return false
  end
  local featureUnlockConfig = self.featureToUnlock[feature]
  if not featureUnlockConfig then
    log_warning(bWriteLog and "level_unlock_manager:NeedShowCurrentLevelGuideFeature featureUnlockConfig is nil")
    return false
  end
  local unlockLevel = featureUnlockConfig.unlockLevel
  if DataMgr.roleData.level ~= unlockLevel then
    log_warning(bWriteLog and "level_unlock_manager:NeedShowCurrentLevelGuideFeature level is not equal")
    return false
  end
  log_format("level_unlock_manager:NeedShowCurrentLevelGuideFeature feature = %s, unlockLevel = %s", feature, unlockLevel)
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLevelUnlockManager = class(CModuleBase, nil, level_unlock_manager)
return CLevelUnlockManager