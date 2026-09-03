local NewbieGuideStep = require("client.slua.logic.ugc.newbie.ugc_newbieguide_step")
local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
local LogicUGCNewbie = {}
function LogicUGCNewbie:DefineAndResetData()
end
function LogicUGCNewbie:OnInitialize()
  if not LobbySystem.CheckUseWoWGuideSwitch() then
    print(bWriteLog and "LogicUGCNewbie:OnInitialize LobbySystem.CheckUseWoWGuideSwitch() false")
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if self.GuideInsts == nil then
    self.GuideInsts = {}
    self._EnterGameNewbieTheme = Config_UGC.C_EnterGameNewbieScheme.A_NoMoreGuidance
    local NewbieConfig = require("client.slua.logic.ugc.newbie.Config.config_ugcnewbie_enabled")
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    for GuideID, GuideConfig in pairs(NewbieConfig) do
      if not Util_UGC.IsUGCNewbieGuideFinish(GuideID) then
        local GuideStepInst = NewbieGuideStep(GuideID, GuideConfig)
        self.GuideInsts[GuideID] = GuideStepInst
      end
    end
  end
end
function LogicUGCNewbie:ResetStep(GuideID)
  local GuideInst = self.GuideInsts[GuideID]
  if GuideInst then
    GuideInst:RefreshStep(true)
  end
end
function LogicUGCNewbie:RefreshSchemeByUid()
  print(bWriteLog and "LogicUGCNewbie:DevRefreshSchemeByUid")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local userUid = tonumber(DataMgr.roleData.uid) or 0
  print(bWriteLog and "LogicUGCNewbie:DevRefreshSchemeByUid userUid:" .. tostring(userUid))
  if userUid % 3 == 0 then
    print(bWriteLog and "LogicUGCNewbie:DevRefreshSchemeByUid A")
    self:SetEnterGameNewbieScheme(Config_UGC.C_EnterGameNewbieScheme.A_NoMoreGuidance)
  elseif userUid % 3 == 1 then
    print(bWriteLog and "LogicUGCNewbie:DevRefreshSchemeByUid B")
    self:SetEnterGameNewbieScheme(Config_UGC.C_EnterGameNewbieScheme.B_GoToBR)
  else
    print(bWriteLog and "LogicUGCNewbie:DevRefreshSchemeByUid C")
    self:SetEnterGameNewbieScheme(Config_UGC.C_EnterGameNewbieScheme.C_GoToSelectedWoWMod)
  end
end
function LogicUGCNewbie:DevRefreshSchemeByLocalFile()
  print(bWriteLog and "LogicUGCNewbie:DevRefreshSchemeByLocalFile")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if Client and Client.IsDevelopment() and Client.IsFileExistByFileName("EnterWoWNewbie.txt") then
    local Content = Client.LoadFileToString("EnterWoWNewbie.txt")
    print(bWriteLog and "LogicUGCNewbie:OnInitialize EnterWoWNewbie.txt Content: " .. Content)
    Content = Content:gsub("%s+", "")
    if Content == "A" then
      print(bWriteLog and "LogicUGCNewbie:OnInitialize EnterWoWNewbie.txt Content:A")
      self:SetEnterGameNewbieScheme(Config_UGC.C_EnterGameNewbieScheme.A_NoMoreGuidance)
    elseif Content == "B" then
      print(bWriteLog and "LogicUGCNewbie:OnInitialize EnterWoWNewbie.txt Content:B")
      self:SetEnterGameNewbieScheme(Config_UGC.C_EnterGameNewbieScheme.B_GoToBR)
    elseif Content == "C" then
      print(bWriteLog and "LogicUGCNewbie:OnInitialize EnterWoWNewbie.txt Content:C")
      self:SetEnterGameNewbieScheme(Config_UGC.C_EnterGameNewbieScheme.C_GoToSelectedWoWMod)
    else
      print(bWriteLog and "LogicUGCNewbie:OnInitialize EnterWoWNewbie.txt Content:Other")
    end
  end
end
function LogicUGCNewbie:GMRefreshActions()
  self:OnLogOut()
  self.GuideInsts = {}
  local NewbieConfig = require("client.slua.logic.ugc.newbie.Config.config_ugcnewbie_enabled")
  for GuideID, GuideConfig in pairs(NewbieConfig) do
    local GuideStepInst = NewbieGuideStep(GuideID, GuideConfig)
    self.GuideInsts[GuideID] = GuideStepInst
  end
end
function LogicUGCNewbie:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_BTN_CLICK, self.OnClickBubble, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, self.OnModePostSwitch, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ENTER_GAME_BEGIN, self.OnEnterGameBegin, self)
end
function LogicUGCNewbie:OnModePostSwitch()
  if GameStatus.GetGameStatus() ~= GameStatus.Lobby then
    print(bWriteLog and "LogicUGCNewbie:OnModePostSwitch Return not lobby")
    return
  end
  print(bWriteLog and "LogicUGCNewbie:OnModePostSwitch")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local enter_game_num = LogicNewbie.newbieTotalGameCnt
  print(bWriteLog and "LogicUGCNewbie:OnModePostSwitch enter_game_num = " .. tostring(enter_game_num))
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  if self:IsEnterGameUGCNewbieGuideOn() and self:HasBegunUgcMatch() then
    self:PostLobbySecondPhaseEvent()
  end
end
function LogicUGCNewbie:PostLobbySecondPhaseEvent()
  print(bWriteLog and "LogicUGCNewbie:PostLobbySecondPhaseEvent")
  if GameStatus.GetGameStatus() ~= GameStatus.Lobby then
    print(bWriteLog and "LogicUGCNewbie:PostLobbySecondPhaseEventh Return not lobby")
    return
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWBIE_AFTERENTERGAME, self:GetEnterGameNewbieScheme())
end
function LogicUGCNewbie:OnLogOut()
  if self.GuideInsts and self.GuideInsts then
    for _, Inst in pairs(self.GuideInsts) do
      if Inst then
        Inst:Dispose()
      end
    end
  end
  self.GuideInsts = nil
  self:ClearCachedHotBanner()
end
function LogicUGCNewbie:IsUGCNewbieGuideOn()
  local UITopName = UIManager.GetTopUIName()
  log(bWriteLog and "[v_chenxxue]LogicUGCNewbie:IsUGCNewbieGuideOn name is  " .. UITopName)
  local IsTaskAward = self:HasDailyOrRPAward()
  log(bWriteLog and "[v_chenxxue]LogicUGCNewbie:IsAward  is  " .. tostring(IsTaskAward))
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  local IsWoWPlayLevel
  if logic_ugc_playlevel.CurLevel == 1 then
    IsWoWPlayLevel = true
  else
    IsWoWPlayLevel = false
  end
  log(bWriteLog and "[v_chenxxue]LogicUGCNewbie:IsWoWPlayLevel  is  " .. tostring(IsWoWPlayLevel))
  if UITopName == UIManager.UI_Config.mode_selection_main.keyName and IsTaskAward and IsWoWPlayLevel then
    return true
  end
  return false
end
function LogicUGCNewbie:IsWTeachingRoadUGCNewbieGuide()
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local ConfigUGC = require("client.slua.logic.ugc.config_ugc")
  if not DataMgr.ugc_author_info.total_edit_mod_time or DataMgr.ugc_author_info.total_edit_mod_time == 0 then
    if Util_UGC.IsUGCNewbieGuideFinish(ConfigUGC.Newbie_Guide_Type_Key.StrongTeachingRoad) then
      return true
    else
      return false
    end
  else
    return true
  end
end
function LogicUGCNewbie:IsTeachingRoadUGCLv6NewbieGuide()
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  local IsShowLv6Guide = LogicUGCCenter:GetShowLv6Guide()
  log(bWriteLog and "[v_chenxxue]LogicUGCNewbie:IsShowLv6Guide  is  " .. tostring(IsShowLv6Guide))
  if IsShowLv6Guide then
    return true
  end
  return false
end
function LogicUGCNewbie:IsEnterGameUGCNewbieGuideOn()
  if not LobbySystem.CheckUseWoWGuideSwitch() then
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if growthprojectMgrB and growthprojectMgrB.CheckEnterWoWNewbieGuide() then
    if growthprojectMgrB.CheckEndWoWNewbieGuide() or growthprojectMgrB.CheckEndWoWHallWoWNewbieGuide() then
      return false
    end
    return true
  end
  return false
end
function LogicUGCNewbie:IsOngoingStrongGuide()
  print(bWriteLog and "LogicUGCNewbie:IsOngoingStrongGuide")
  local ConfigUGC = require("client.slua.logic.ugc.config_ugc")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local bIsGuideOn = self:IsEnterGameUGCNewbieGuideOn()
  local bIsNewGuideOn = self:IsEnterWOWHallNewbieGuideOn()
  local bRet = false
  if bIsGuideOn then
    print(bWriteLog and "LogicUGCNewbie:ReqUGCWOWPassBuyGuideReq bIsGuideOn is true")
  else
    print(bWriteLog and "LogicUGCNewbie:ReqUGCWOWPassBuyGuideReq bIsGuideOn is false")
  end
  if bIsNewGuideOn then
    print(bWriteLog and "LogicUGCNewbie:ReqUGCWOWPassBuyGuideReq bIsNewGuideOn is true")
  else
    print(bWriteLog and "LogicUGCNewbie:ReqUGCWOWPassBuyGuideReq bIsNewGuideOn is false")
  end
  local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
  local bIsNewProcessGuideOpen = logic_ugc_new_process:CheckIsOpen()
  print(bWriteLog and "LogicUGCNewbie:ReqUGCWOWPassBuyGuideReq bIsNewProcessGuideOpen is " .. tostring(bIsNewProcessGuideOpen))
  if bIsGuideOn or bIsNewGuideOn then
    local EnterGameNewbieThemeTipState = Util_UGC.IsUGCNewbieGuideFinish(ConfigUGC.Newbie_Guide_Type_Key.EnterGameNewbieThemeTip)
    local EnterGameNewbieNewProcessState = Util_UGC.IsUGCNewbieGuideFinish(ConfigUGC.Newbie_Guide_Type_Key.EnterOpenIntention)
    log(bWriteLog and string.format("LogicUGCNewbie:ReqUGCWOWPassBuyGuideReq New Guide EnterGameNewbieThemeTipState: %s", EnterGameNewbieThemeTipState))
    log(bWriteLog and string.format("LogicUGCNewbie:ReqUGCWOWPassBuyGuideReq New Guide EnterGameNewbieNewProcessState: %s", EnterGameNewbieNewProcessState))
    if EnterGameNewbieThemeTipState or bIsNewProcessGuideOpen and EnterGameNewbieNewProcessState then
      print(bWriteLog and "LogicUGCNewbie:ReqUGCWOWPassBuyGuideReq bShowWoWPass is false")
      bRet = false
    else
      print(bWriteLog and "LogicUGCNewbie:ReqUGCWOWPassBuyGuideReq bShowWoWPass is true")
      bRet = true
    end
  else
    bRet = false
  end
  return bRet
end
function LogicUGCNewbie:ShowBubble(UIStyleID, TargetWidget, ClickWidget, callback, GuideID, CustomContainerUICtrl, CustomContainerUIName)
  local BubbleConfig = require("client.slua.logic.ugc.newbie.config_ugc_newbie_bubble")
  local CurrentCfg = BubbleConfig[UIStyleID]
  if CurrentCfg then
    local TextID = LocUtil.GetLocalizeResStr(CurrentCfg.TextID)
    local params = {
      uTargetWidget = TargetWidget,
      uClickWidget = ClickWidget,
      textID = TextID,
      highlightOutlineType = CurrentCfg.Shape,
      bClickClose = CurrentCfg.bWeekGuide,
      bClickDestory = not CurrentCfg.bPersistent and true,
      bPersistent = CurrentCfg.bPersistent or false,
      bHideForceGuide = CurrentCfg.bHideForceGuide,
      showMask = CurrentCfg.showMask,
      textDirection = CurrentCfg.TextDirection,
      OnBubbleShow = CurrentCfg.OnBubbleShow,
      OnBubbleTick = CurrentCfg.OnBubbleTick,
      OnBubbleClose = CurrentCfg.OnBubbleClose,
      showHandEffect = CurrentCfg.bShowHandEffect or false,
      SizeOffset = CurrentCfg.SizeOffset or FVector2D(0, 0),
      positionRetryCount = CurrentCfg.PositionRetryCount
    }
    if CurrentCfg.showMask == nil then
      params.showMask = true
    end
    local ui
    if CustomContainerUICtrl ~= nil and CustomContainerUICtrl.CreateChildWindow then
      ui = CustomContainerUICtrl:CreateChildWindow(CustomContainerUIName, UIManager.UI_Config.Common_NewbieGuide_Bubble_Masked_UIBP, GuideID or CurrentCfg.GuideID, params, callback)
    else
      ui = UIManager.ShowUI(UIManager.UI_Config.Common_NewbieGuide_Bubble_Masked_UIBP, GuideID or CurrentCfg.GuideID, params, callback)
    end
    if ui then
      if CurrentCfg.OverrideContainer then
        local frontendUtils = slua_GameFrontendHUD:GetUtils()
        local container = frontendUtils:GetGlobalUIContainer(CurrentCfg.OverrideContainer)
        container:AddWidget(ui.UIRoot)
      end
      if CurrentCfg.ZOrder then
        ui:SetZOrder(CurrentCfg.ZOrder)
      end
    end
    return ui
  end
end
function LogicUGCNewbie:OnUIOpened(UICtrl, ...)
  print(bWriteLog and "LogicUGCNewbie:OnUIOpened")
  local KeyName = UICtrl._config.keyName
  EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_UI_OPEN, KeyName, ...)
end
function LogicUGCNewbie:OnClickBubble(_, _, GuideID)
  print(bWriteLog and "LogicUGCNewbie:OnClickBubble GuideID:" .. GuideID)
end
function LogicUGCNewbie:HasDailyOrRPAward()
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  for _, task in ipairs(LogicUGCTask.DailyTasks) do
    if task.status == NewDayTaskSystem.Mission_Finished then
      return true
    end
  end
  for _, activeData in ipairs(LogicUGCTask.WeeklyActive.received) do
    if activeData.status == NewDayTaskSystem.Mission_Finished then
      return true
    end
  end
  return false
end
function LogicUGCNewbie:CheckWoWPlayAward()
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  if logic_ugc_playlevel.Award then
    local E_    for Lv, AwardState in pairs(logic_ugc_playlevel.Award) do
      if Lv == 1 and AwardState == E_ActivityProgressStatus.Done then
        return true
      end
    end
  end
  return false
end
function LogicUGCNewbie:GetEnterGameNewbieScheme()
  return self._EnterGameNewbieTheme
end
function LogicUGCNewbie:SetEnterGameNewbieScheme(Value)
  print(bWriteLog and "LogicUGCNewbie:SetEnterGameNewbieScheme Value = " .. Value)
  self._EnterGameNewbieTheme = Value
end
function LogicUGCNewbie:SetCachedHotBanner(Value)
  self._HotBannerUICtrl = Value
end
function LogicUGCNewbie:GetCachedHotBanner()
  return self._HotBannerUICtrl
end
function LogicUGCNewbie:ClearCachedHotBanner()
  self._HotBannerUICtrl = nil
end
function LogicUGCNewbie:HasBegunUgcMatch()
  print(bWriteLog and "LogicUGCNewbie:HasBegunUgcMatch")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  return Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.HasEnteredUGCMatch)
end
function LogicUGCNewbie:RecordBegunUgcMatch()
  print(bWriteLog and "LogicUGCNewbie:RecordHasBegunUgcMatch")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  Util_UGC.SetUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.HasEnteredUGCMatch)
end
function LogicUGCNewbie:OnEnterGameBegin(_, __, sub_mode)
  print(bWriteLog and "LogicUGCNewbie:OnEnterGameBegin")
  if sub_mode == 880000 then
    self:RecordBegunUgcMatch()
  end
end
function LogicUGCNewbie:IsEnterWOWHallNewbieGuideOn()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if growthprojectMgrB and growthprojectMgrB.CheckEnterWoWHallNewbieBranch() then
    if growthprojectMgrB.CheckEndWoWHallWoWNewbieGuide() then
      return false
    end
    return true
  end
  return false
end
function LogicUGCNewbie:StartLobbyRightPageGuide()
  local bCanGuide, widget = self:CheckLobbyRightPageGuide()
  log(bWriteLog and "LogicUGCNewbie:StartLobbyRightPageGuide bCanGuide = " .. tostring(bCanGuide))
  if not bCanGuide then
    return false
  end
  self:ShowLobbyRightPageGuide(widget)
  return true
end
function LogicUGCNewbie:CheckLobbyRightPageGuide()
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  if not level_unlock_util:HaveLockedFeature() then
    log(bWriteLog and "LogicUGCNewbie:CheckLobbyRightPageGuide. not have locked feature")
    return false, nil
  end
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local flag = logic_newbie.NeedShowNewbieGuide(newbie_guide_config.ELobbyGuideID.LOBBY_UGC_HALL_GUIDE_ID)
  if not flag then
    log_warning(bWriteLog and "LogicUGCNewbie:CheckLobbyRightPageGuide. not need show newbie guide")
    return false
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if level_unlock_manager:NeedShowCurrentLevelGuideFeature() then
    log_warning(bWriteLog and "LogicUGCNewbie:CheckLobbyRightPageGuide show level unlock guide")
    return false
  end
  local widget
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local switchUI = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Main_Switch_UIBP)
    widget = switchUI.UIRoot.Canvas_R
  end
  if not widget then
    log_warning(bWriteLog and "LogicUGCNewbie:CheckLobbyRightPageGuide widget is nil")
    return false
  end
  return true, widget
end
function LogicUGCNewbie:ShowLobbyRightPageGuide(widget)
  log(bWriteLog and "LogicUGCNewbie:ShowLobbyRightPageGuide. widget = " .. tostring(widget))
  local level_unlock_config = require("client.logic.level_unlock.config.level_unlock_config")
  local ETipDir = level_unlock_config.ETipDir
  local callback = function()
    local logic_lobby_main_page_jump = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_main_page_jump)
    logic_lobby_main_page_jump:JumpToPage(ENUM_LobbyPageType.Right, nil, {bUGC = true})
    local logic_newbie = require("client.logic.newbie.logic_newbie")
    DataMgr.SetNewbieGuideValue(logic_newbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.ELobbyGuideID.LOBBY_UGC_HALL_GUIDE_ID, 1)
  end
  self:AddTimerOnce(0, function()
    log(bWriteLog and "LogicUGCNewbie:ShowLobbyRightPageGuide Delay. widget = " .. tostring(widget))
    if not slua.isValid(widget) then
      return
    end
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local ParamTable = ui_show_queue_config.GetParamTable(nil, "IsLobbyLevelUnLock")
    UIManager.ShowUI(UIManager.UI_Config.level_unlock_bubble, ETipDir.down, LocUtil.GetLocalizeResStr(89880), widget, callback, true, false, nil, nil, ParamTable)
  end)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCNewbie = class(CModuleBase, nil, LogicUGCNewbie)
return CLogicUGCNewbie