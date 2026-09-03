local logic_lobby_guide_manager = {}
function logic_lobby_guide_manager:DefineAndResetData()
  self.bNotShowLevelUpPanel = false
end
function logic_lobby_guide_manager:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    self:DefineAndResetData()
  end
end
function logic_lobby_guide_manager:CheckCanRealShowLevelPanel()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanRealShowLevelPanel")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local bCheckUseNewGuide = LobbySystem.CheckUseNewGuide()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanRealShowLevelPanel bCheckUseNewGuide = " .. tostring(bCheckUseNewGuide))
  if bCheckUseNewGuide then
    local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
    local needUpdateRole = newbieGuideManager.NeedUpdateRole()
    log(bWriteLog and "logic_lobby_guide_manager:CheckCanRealShowLevelPanel needUpdateRole = " .. tostring(needUpdateRole))
    if needUpdateRole then
      return false
    end
    if not growthprojectMgrB.IsFinishAllNewGuide() then
      local LogicNewbie = require("client.logic.newbie.logic_newbie")
      local bGuideTask = growthprojectMgrB.CheckGuideStep(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE, 0)
      log(bWriteLog and "logic_lobby_guide_manager:CheckCanRealShowLevelPanel bGuideTask = " .. tostring(bGuideTask))
      if bGuideTask then
        return false
      end
    end
  elseif not growthprojectMgrB.IsFinishAllNewGuide() then
    return false
  end
  return true
end
function logic_lobby_guide_manager:CheckCanGuide_StartGameGuide()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_StartGameGuide")
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local bNeedShowLevelUp = level_unlock_manager:NeedShowLevelup()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_StartGameGuide bNeedShowLevelUp = " .. tostring(bNeedShowLevelUp))
  local bCheckCanRealShowLevelPanel = self:CheckCanRealShowLevelPanel()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_StartGameGuide bCheckCanRealShowLevelPanel = " .. tostring(bCheckCanRealShowLevelPanel))
  if bNeedShowLevelUp and bCheckCanRealShowLevelPanel and not self.bNotShowLevelUpPanel then
    local config = level_unlock_manager:GetUnlockFeature(DataMgr.roleData.level)
    log_tree(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_StartGameGuide 1 config = ", config)
    if config then
      return false
    end
  end
  if level_unlock_manager:CheckShowLevelUpAndUnlockFeature() then
    log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_StartGameGuide CheckShowLevelUpAndUnlockFeature")
    return false
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.level_unlock_bubble)
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_StartGameGuide ui = " .. tostring(ui))
  if ui then
    return false
  end
  local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
  local bCanGuide = logic_season_guide_manager:CheckCanShowSeasonGuide()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_StartGameGuide bCanGuide = " .. tostring(bCanGuide))
  if bCanGuide then
    return false
  end
  return true
end
function logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide")
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local bNeedShowLevelUp = level_unlock_manager:NeedShowLevelup()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_StartGameGuide bNeedShowLevelUp = " .. tostring(bNeedShowLevelUp))
  local bCheckCanRealShowLevelPanel = self:CheckCanRealShowLevelPanel()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_StartGameGuide bCheckCanRealShowLevelPanel = " .. tostring(bCheckCanRealShowLevelPanel))
  if bNeedShowLevelUp and bCheckCanRealShowLevelPanel and not self.bNotShowLevelUpPanel then
    local config = level_unlock_manager:GetUnlockFeature(DataMgr.roleData.level)
    log_tree(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide 1 config = ", config)
    if config then
      return false
    end
  end
  if level_unlock_manager:CheckShowLevelUpAndUnlockFeature() then
    log_tree(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide 2")
    return false
  end
  local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
  local bCanGuide = logic_season_guide_manager:CheckCanShowSeasonGuide()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide bCanGuide = " .. tostring(bCanGuide))
  if bCanGuide then
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local bNeedMatchEntryGuide = growthprojectMgrB.CheckNeedMatchEntryGuide()
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide bNeedMatchEntryGuide = " .. tostring(bNeedMatchEntryGuide))
  if bNeedMatchEntryGuide then
    return false
  end
  local LobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local match_new_entry = LobbyMain:GetChildUI(UIManager.UI_Config.match_new_entry)
  if match_new_entry and match_new_entry.UIRoot then
    if match_new_entry.UIRoot.Canvas_Panel_HandGuide and match_new_entry.UIRoot.Canvas_Panel_HandGuide:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
      log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide match_new_entry 1")
      return false
    end
    if match_new_entry.UIRoot.GuidePanel and match_new_entry.UIRoot.GuidePanel:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed then
      log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide match_new_entry 2")
      return false
    end
  end
  if LobbySystem.CheckUseNewGuide() then
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    if not growthprojectMgrB.IsFinishAllNewGuide() then
      local LogicNewbie = require("client.logic.newbie.logic_newbie")
      local needGuide = growthprojectMgrB.CheckGuideStep(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_FIRST_BATTLE_AFTER_TASK, 0)
      log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide needGuide = " .. tostring(needGuide))
      if needGuide then
        return false
      end
    end
  end
  log(bWriteLog and "logic_lobby_guide_manager:CheckCanGuide_SlidePageGuide return true")
  return true
end
function logic_lobby_guide_manager:SetNotShowLevelUpPanel()
  log(bWriteLog and "logic_lobby_guide_manager:SetNotShowLevelUpPanel self.bNotShowLevelUpPanel = " .. tostring(self.bNotShowLevelUpPanel))
  self.bNotShowLevelUpPanel = true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_guide_manager = class(CModuleBase, nil, logic_lobby_guide_manager)
return Clogic_lobby_guide_manager