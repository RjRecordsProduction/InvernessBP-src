local logic_newbie_guide_force_rank = {}
function logic_newbie_guide_force_rank:DefineAndResetData()
  self._waitingLevelUp = false
end
function logic_newbie_guide_force_rank:OnInitialize()
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  self._guideID = newbie_guide_config.ELobbyGuideID.LOBBY_FORCE_RANK_GUIDE_ID
  self:SetNeedShowUnLockGuide(false)
  self:Step_ShowPlayGuide()
end
function logic_newbie_guide_force_rank:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_START_UNLOCK_GUIDE, self.OnStartUnlockGuide, self)
end
function logic_newbie_guide_force_rank:OnLogin(bReLogin)
  self:_Clear()
end
function logic_newbie_guide_force_rank:OnLogOut()
  self:_Clear()
end
function logic_newbie_guide_force_rank:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_newbie_guide_force_rank:OnPostSwitchGameStatus pre=" .. tostring(preState) .. ", nextState=" .. tostring(nextState))
  if self.bFromFightingToLobby and nextState == GameStatus.Fighting then
    self.bFromFightingToLobby = false
  end
  if self.state == -1 or self.bFromFightingToLobby then
    return
  end
  if preState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self.bFromFightingToLobby = true
    log(bWriteLog and "logic_newbie_guide_force_rank:OnPostSwitchGameStatus bFromFightingToLobby=" .. tostring(self.bFromFightingToLobby))
    self:Step_ShowPlayGuide()
  end
end
function logic_newbie_guide_force_rank:OnStartUnlockGuide(level)
  log_format("logic_newbie_guide_force_rank:OnStartUnlockGuide. currentLevel = [%s]", level)
  self:SetNeedShowUnLockGuide(true)
end
function logic_newbie_guide_force_rank:NeedShowGuide()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
  local gameCount = LogicNewbie.GetTotalGameCount()
  local isInABTest = newbie_guide_util.IsInNewbieForceRankABTest()
  log_format("logic_newbie_guide_force_rank:NeedShowGuide. gameCount = [%s], isInABTest = [%s]", gameCount, isInABTest)
  return gameCount == 1 and isInABTest
end
function logic_newbie_guide_force_rank:StartGuide()
  if not self:_CheckCanStart() then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:StartGuide. CheckCanStart return")
    return
  end
  local needUpLevel = self:_Step_UpLevel()
  if needUpLevel then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:StartGuide. Step_UpLevel return")
    return
  end
  local needShowSlap = self:_Step_ShowRankUnlockSlap()
  if needShowSlap then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:StartGuide. Step_ShowRankUnlockSlap return")
    return
  end
  self:_Step_ShowRankGuide()
end
function logic_newbie_guide_force_rank:Step_ShowRankGuide()
  log(bWriteLog and "logic_newbie_guide_force_rank:Step_ShowRankGuide")
  self:_Step_ShowRankGuide()
end
function logic_newbie_guide_force_rank:Step_ShowPlayGuide()
  log(bWriteLog and "logic_newbie_guide_force_rank:Step_Step_ShowPlayGuide")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  local preGuide = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.ELobbyGuideID.LOBBY_FORCE_RANK_GUIDE_ID)
  local rankTimes = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.ELobbyGuideID.LOBBY_RANK_FINISH_TIMES)
  if preGuide and rankTimes then
    self:_Step_ShowRobotGuide()
  else
    log(bWriteLog and "logic_newbie_guide_force_rank:Step_Step_ShowPlayGuide. preguide =" .. tostring(preGuide) .. ", rankTimes = " .. tostring(rankTimes))
  end
end
function logic_newbie_guide_force_rank:_CheckCanStart()
  local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
  if not newbie_guide_util.IsInNewbieForceRankABTest() then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:StartGuide. is not in newbie force abtest")
    return
  end
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local flag = logic_newbie.NeedShowNewbieGuide(self._guideID)
  if not flag then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:StartGuide. not need show newbie guide")
    return
  end
  if self._waitingLevelUp then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:StartGuide. is waiting level up")
    return
  end
  return true
end
function logic_newbie_guide_force_rank:_Step_UpLevel()
  log(bWriteLog and "logic_newbie_guide_force_rank:_Step_UpLevel")
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.matchMode) then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:_Step_UpLevel. is already unlocked")
    return false
  end
  self:send_new_newbie_perfect_excessive_level_up_req()
  return true
end
function logic_newbie_guide_force_rank:_Step_ShowRankUnlockSlap()
  log(bWriteLog and "logic_newbie_guide_force_rank:_Step_ShowRankUnlockSlap")
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local unlockLevel = level_unlock_manager:GetUnlockLevel(level_unlock_manager.featureDef.matchMode)
  if DataMgr.roleData.level ~= unlockLevel then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:_Step_ShowRankUnlockSlap. not unlock level")
    return false
  end
  local logic_newbie_task_segment_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_task_segment_activity)
  logic_newbie_task_segment_activity:GoToActMainUI(true)
  return true
end
function logic_newbie_guide_force_rank:_Step_ShowRankGuide()
  log(bWriteLog and "logic_newbie_guide_force_rank:_Step_ShowRankGuide")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local info = logic_mode_selection:GetFilterInfo()
  logic_mode_selection:SetSelectView(10001, info)
  self:_ShowGuidePanel()
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  DataMgr.SetNewbieGuideValue(logic_newbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, self._guideID, 1)
end
function logic_newbie_guide_force_rank:_ShowGuidePanel()
  log(bWriteLog and "logic_newbie_guide_force_rank:_ShowGuidePanel")
  local handlePoint, onCloseFunc
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if Lobby_Main_UIBP then
    local matchEntry = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.match_new_entry)
    if matchEntry then
      handlePoint = matchEntry and matchEntry.UIRoot and matchEntry.UIRoot.Button_Entry
      function onCloseFunc()
        matchEntry:OnClickEntry()
      end
    end
  end
  if not handlePoint or not onCloseFunc then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:_ShowGuidePanel. not find handle point")
    return
  end
  local showFunc = function()
    self:SetNeedShowUnLockGuide(false)
    UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 2, LocUtil.GetLocalizeResStr(53035), handlePoint, onCloseFunc, true, 2, false, false, nil, false, false, {isMaskVisible = true})
  end
  local delay
  if self._needShowUnLockGuide then
    delay = 0.2
  elseif UIManager.IsUIShow(UIManager.UI_Config.NewbieGuide_UIBP) then
    delay = 0
  end
  log_format("logic_newbie_guide_force_rank:_ShowGuidePanel. delay = [%s]", delay)
  if delay then
    self:AddTimerOnce(delay, showFunc)
    return
  end
  showFunc()
end
function logic_newbie_guide_force_rank:_Step_ShowRobotGuide()
  log(bWriteLog and "logic_newbie_guide_force_rank:_Step_ShowRobotGuide")
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  local playGuide = DataMgr.GetNewbieGuideValue(logic_newbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.ELobbyGuideID.LOBBY_PLAY_SELECT_GUIDE_ID)
  if playGuide and 0 < playGuide then
    log_warning(bWriteLog and "logic_newbie_guide_force_rank:_Step_ShowRobotGuide. play guide is already show")
    return
  end
  self:_Step_ShowModeSwitchGuide()
end
function logic_newbie_guide_force_rank:_Step_ShowModeSwitchGuide()
  log(bWriteLog and "logic_newbie_guide_force_rank:_Step_ShowModeSwitchGuide")
  if IsWoWEditor then
    return
  end
  local clickfunction = function()
    local handlePoint, onCloseFunc
    local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if Lobby_Main_UIBP then
      local matchEntry = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.match_new_entry)
      local modeEntry = matchEntry:GetChildWindow(UIManager.UI_Config.lobby_mode_entry)
      if matchEntry then
        handlePoint = modeEntry and modeEntry.UIRoot and modeEntry.UIRoot.Button_Enter
        function onCloseFunc()
          modeEntry:OnButton_EnterClick()
          self:AddTimerOnce(0.1, function()
            self:_Step_ShowPlayGuide()
          end)
          self:AddTimerOnce(0.5, function()
            EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_NEWBIE_GUIDE_PLAYMODE_BEGIN)
          end)
        end
      end
    end
    UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 1, LocUtil.GetLocalizeResStr(612401117), handlePoint, onCloseFunc, true, 2, false, false, nil, false, false, {isMaskVisible = true})
  end
  local extradata = {
    iconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/SmartAssistantV2/Icon/SmartAssistantV2_Icon_Character.SmartAssistantV2_Icon_Characte",
    contentText = LocUtil.GetLocalizeResStr(612401116),
    okFunction = clickfunction,
    closeFunction = clickfunction,
    selfCloseFunction = clickfunction,
    countdown = 15,
    bShowMask = true
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_NewbieGuide_Tips_UIBP, extradata)
end
function logic_newbie_guide_force_rank:_Step_ShowPlayGuide()
  log(bWriteLog and "logic_newbie_guide_force_rank:_Step_ShowPlayGuide")
  local handlePoint, onCloseFunc
  local ModeSelection_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
  if ModeSelection_Main_UIBP then
    handlePoint = ModeSelection_Main_UIBP.UIRoot and ModeSelection_Main_UIBP.UIRoot.LoopScrollBox_Menu2
    function onCloseFunc()
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_NEWBIE_GUIDE_PLAYMODE_END)
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 2, LocUtil.GetLocalizeResStr(612401118), handlePoint, onCloseFunc, false, 1, true, false, nil, false, false, {
    extSize = {X = 3, Y = 3},
    isMaskVisible = false,
    areaHightLight = true
  })
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  DataMgr.SetNewbieGuideValue(logic_newbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.ELobbyGuideID.LOBBY_PLAY_SELECT_GUIDE_ID, 1)
end
function logic_newbie_guide_force_rank:_Clear()
  self._waitingLevelUp = false
end
function logic_newbie_guide_force_rank:SetNeedShowUnLockGuide(needShow)
  log_format("logic_newbie_guide_force_rank:SetNeedShowUnLockGuide. needShow = [%s]", needShow)
  self._needShowUnLockGuide = needShow
end
function logic_newbie_guide_force_rank:send_new_newbie_perfect_excessive_level_up_req()
  log(bWriteLog and "logic_newbie_guide_force_rank:send_new_newbie_perfect_excessive_level_up_req")
  self._waitingLevelUp = true
  local NewbieGuideHandler = require("client.network.Protocol.NewbieGuideHandler")
  NewbieGuideHandler.send_new_newbie_perfect_excessive_level_up_req()
end
function logic_newbie_guide_force_rank:on_new_newbie_perfect_excessive_level_up_rsp(err_code)
  log_format("logic_newbie_guide_force_rank:on_new_newbie_perfect_excessive_level_up_rsp. err_code = [%s]", err_code)
  self._waitingLevelUp = false
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function logic_newbie_guide_force_rank:test_new_newbie_perfect_excessive_level_up_rsp()
  log(bWriteLog and "logic_newbie_guide_force_rank:test_new_newbie_perfect_excessive_level_up_rsp")
  self:on_new_newbie_perfect_excessive_level_up_rsp(0)
  local exp = 0
  local nextLevel = 3
  local currentLevel = DataMgr.roleData.level
  if currentLevel == 1 then
    exp = 580
  elseif currentLevel == 2 then
    exp = 300
  end
  DataMgr.OnRoleAttrChangeNotify(2, nextLevel)
  DataMgr.OnRoleAttrChangeNotify(1, exp, nil, 0)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_newbie_guide_force_rank = class(CModuleBase, nil, logic_newbie_guide_force_rank)
return Clogic_newbie_guide_force_rank