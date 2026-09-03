local logic_ugc_WOWPass = {}
local TimeUtil = require("client.common.time_util")
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local UGCHandler = require("client.network.Protocol.UGCHandler")
local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
local CommonItem_Const = require("client.slua.component.item.ItemUtils.CommonItem_Const")
local Enum_ItemStatus = CommonItem_Const.Enum_ItemStatus
local NewTaskStatusDebugCache = {From = nil, TaskStatus = nil}
local TaskReqQueue = {}
function logic_ugc_WOWPass:DefineAndResetData()
  self.bShowRedDot = false
  self.RedDotInfo = {task_has = false, level_has = false}
  self.IsBuyPass = 0
  self.UGCPassInfo = nil
  self.UGCPASSTaskStatus = nil
  self.CurScore = 0
  self.CurLevel = 0
  self.BeforeLevel = 0
  self.nUCCountLackTip = 0
  self.OpenPanelQueue = {}
  self.FinishingTaskInfo = nil
  self.LastSendPassInfoTime = 0
  self.LastReqRedDotTime = 0
  self.ShowTipsQueue = {}
  self.show_flag = nil
end
function logic_ugc_WOWPass:OnInitialize()
end
function logic_ugc_WOWPass:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_COMMON_ITEM_BUY_SUC, self.DirectBuyMissionCardSuccess, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_COMMON_ITEM_BUY_FAIL, self.DirectBuyMissionCardFail, self)
end
function logic_ugc_WOWPass:OnLogin(bReLogin)
  print(bWriteLog and "logic_ugc_WOWPass:OnLogin", bReLogin)
  UGCPassHandler.send_ugc_pass_get_info_req()
end
function logic_ugc_WOWPass:OnLogOut()
  print(bWriteLog and "logic_ugc_WOWPass:OnLogOut")
  self:ClearData()
end
function logic_ugc_WOWPass:OnPreSwitchGameStatus(preState, nextState)
  print(bWriteLog and "logic_ugc_WOWPass:OnPreSwitchGameStatus", preState, nextState)
  self:ClearData()
end
function logic_ugc_WOWPass:OnPostSwitchGameStatus(preState, nextState)
  print(bWriteLog and "logic_ugc_WOWPass:OnPostSwitchGameStatus", preState, nextState)
  if nextState == GameStatus.Lobby then
    UGCPassHandler.send_ugc_pass_get_info_req()
  end
end
function logic_ugc_WOWPass:OnDestroy()
  print(bWriteLog and "logic_ugc_WOWPass:OnDestroy")
  self:ClearData()
end
function logic_ugc_WOWPass:IsSystemOpen()
  return LobbySystem.CheckOpen(92066)
end
function logic_ugc_WOWPass:OpenWowPassPanel(UIConfig, ExtraData, ShowReqTips)
  if not UIConfig then
    return
  end
  if self:GetValidUGCPassInfo() then
    table.insert(self.OpenPanelQueue, UIConfig)
    self:OpenQueuePanels(ExtraData)
  else
    table.insert(self.OpenPanelQueue, UIConfig)
    self:ReqUGCWOWPassInfo(ShowReqTips)
  end
end
function logic_ugc_WOWPass:OpenQueuePanels(ExtraData)
  if UIManager.IsUIShow(UIManager.UI_Config.UGC_WOW_PASS_Pop_BuyPassGuide) then
    self:_CloseBuyBuyPassGuide()
  end
  if UIManager.IsUIShow(UIManager.UI_Config.UGC_WoWPass_Cover_UIBP) then
    self:_CloseBuyBuyPassGuide()
  end
  for i, v in ipairs(self.OpenPanelQueue) do
    if v == UIManager.UI_Config.UGC_WOW_PASS_MainUI then
      self:_OpenWOWPassMainUI(ExtraData)
    elseif v == UIManager.UI_Config.UGC_WOW_PASS_BuyLevel then
      self:_OpenBuyPassLevelUI()
    elseif v == UIManager.UI_Config.UGC_WOW_PASS_Privilege_MainUIBP then
      self:_OpenPrivilgeUI(ExtraData)
    elseif v == UIManager.UI_Config.UGC_WOW_PASS_Pop_BuyPassGuide then
      self:_ShowBuyBuyPassGuide()
    elseif v == UIManager.UI_Config.UGC_WoWPass_Cover_UIBP then
      self:_ShowWOWPassTogetherPopup()
    end
  end
  self.OpenPanelQueue = {}
end
function logic_ugc_WOWPass:CloseWowPassPanel(UIConfig)
  if UIConfig == UIManager.UI_Config.UGC_WOW_PASS_MainUI then
    self:_CloseWOWPassMainUI()
  elseif UIConfig == UIManager.UI_Config.UGC_WOW_PASS_BuyLevel then
    self:_CloseBuyPassLevelUI()
  elseif UIConfig == UIManager.UI_Config.UGC_WOW_PASS_Privilege_MainUIBP then
    self:_ClosePrivilgeUI()
  elseif UIConfig == UIManager.UI_Config.UGC_WOW_PASS_Pop_BuyPassGuide then
    self:_CloseBuyBuyPassGuide()
  elseif UIConfig == UIManager.UI_Config.UGC_WoWPass_Cover_UIBP then
    self:_CloseBuyBuyPassGuide()
  end
end
function logic_ugc_WOWPass:SelectWOWPassMainUITab(Tab)
  local UGC_WOW_PASS_MainUI = UIManager.GetUI(UIManager.UI_Config.UGC_WOW_PASS_MainUI)
  if UGC_WOW_PASS_MainUI then
    UGC_WOW_PASS_MainUI:OnClickTabSelect(Tab)
  end
end
function logic_ugc_WOWPass:ClearData()
  self.UGCPassInfo = nil
  self.UGCPASSTaskStatus = nil
  self.show_flag = nil
  TaskReqQueue = {}
  NewTaskStatusDebugCache = {}
end
function logic_ugc_WOWPass:SetWOWPassRedDotState(bNeedShow)
  self.bShowRedDot = bNeedShow
end
function logic_ugc_WOWPass:GetWOWPassRedDotState()
  return self.bShowRedDot
end
function logic_ugc_WOWPass:RefreshWOWPassTaskRedDotState()
  self.RedDotInfo.task_has = self:CanPlayerGetTaskReward()
  self.bShowRedDot = self.RedDotInfo.task_has or self.RedDotInfo.level_has
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_RED_DOT_STATE_CHANGE, self.bShowRedDot)
end
function logic_ugc_WOWPass:GetWOWPassTaskRedDotState()
  return self.RedDotInfo.task_has
end
function logic_ugc_WOWPass:RefreshWOWPassRewardRedDotState()
  self.RedDotInfo.level_has = self:CanPlayerGetPassReward()
  self.bShowRedDot = self.RedDotInfo.task_has or self.RedDotInfo.level_has
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_RED_DOT_STATE_CHANGE, self.bShowRedDot)
end
function logic_ugc_WOWPass:GetWOWPasssRewardRedDotState()
  return self.RedDotInfo.level_has
end
function logic_ugc_WOWPass:_OpenWOWPassMainUI(ExtraData)
  print(bWriteLog and "logic_ugc_WOWPass:OpenWOWPassMainUI")
  UIManager.ShowUI(UIManager.UI_Config.UGC_WOW_PASS_MainUI, ExtraData)
end
function logic_ugc_WOWPass:_CloseWOWPassMainUI()
  print(bWriteLog and "logic_ugc_WOWPass:HideWOWPassMainUI")
  UIManager.CloseUI(UIManager.UI_Config.UGC_WOW_PASS_MainUI)
end
function logic_ugc_WOWPass:_OpenBuyPassLevelUI()
  EventSystem:postEvent(EVENTTYPE_WOW_PASS, EVENTID_WOW_PASS_HIDE_TAB)
  UIManager.ShowUI(UIManager.UI_Config.UGC_WOW_PASS_BuyLevel)
end
function logic_ugc_WOWPass:_CloseBuyPassLevelUI()
  UIManager.CloseUI(UIManager.UI_Config.UGC_WOW_PASS_BuyLevel)
end
function logic_ugc_WOWPass:OpenUpLevelSuccessUI()
  UIManager.ShowUI(UIManager.UI_Config.UGC_WOW_PASS_Pop_UpLevel)
end
function logic_ugc_WOWPass:CloseUpLevelSuccessUI()
  UIManager.CloseUI(UIManager.UI_Config.UGC_WOW_PASS_Pop_UpLevel)
end
function logic_ugc_WOWPass:_OpenPrivilgeUI(ExtraData)
  EventSystem:postEvent(EVENTTYPE_WOW_PASS, EVENTID_WOW_PASS_HIDE_TAB)
  if UIManager.IsUIShow(UIManager.UI_Config.UGC_WOW_PASS_MainUI) then
    self:_ClosePrivilgeUI()
  end
  UIManager.ShowUI(UIManager.UI_Config.UGC_WOW_PASS_Privilege_MainUIBP, ExtraData)
end
function logic_ugc_WOWPass:_ClosePrivilgeUI()
  UIManager.CloseUI(UIManager.UI_Config.UGC_WOW_PASS_Privilege_MainUIBP)
end
function logic_ugc_WOWPass:OpenBuyPassSuccessUI()
  UIManager.ShowUI(UIManager.UI_Config.UGC_WOW_PASS_Pop_BuySuccess)
end
function logic_ugc_WOWPass:CloseBuySuccessUI()
  UIManager.CloseUI(UIManager.UI_Config.UGC_WOW_PASS_Pop_BuySuccess)
end
function logic_ugc_WOWPass:_ShowBuyBuyPassGuide()
  log(bWriteLog and "logic_ugc_WOWPass:_ShowBuyBuyPassGuide")
  if UIManager.IsUIShow(UIManager.UI_Config.NewUGCMainPanel) then
    UIManager.ShowUI(UIManager.UI_Config.UGC_WOW_PASS_Pop_BuyPassGuide)
  end
end
function logic_ugc_WOWPass:_ShowWOWPassTogetherPopup()
  log(bWriteLog and "logic_ugc_WOWPass:_ShowWOWPassTogetherPopup")
  if UIManager.IsUIShow(UIManager.UI_Config.NewUGCMainPanel) then
    UIManager.ShowUI(UIManager.UI_Config.UGC_WoWPass_Cover_UIBP)
  end
end
function logic_ugc_WOWPass:_CloseBuyBuyPassGuide()
  UIManager.CloseUI(UIManager.UI_Config.UGC_WOW_PASS_Pop_BuyPassGuide)
  UIManager.CloseUI(UIManager.UI_Config.UGC_WoWPass_Cover_UIBP)
end
function logic_ugc_WOWPass:OpenBuyPrivilegeSuccessUI()
  UIManager.ShowUI(UIManager.UI_Config.UGC_WOW_PASS_Privilege_Success)
end
function logic_ugc_WOWPass:CloseBuyPrivilegeSuccessUI()
  UIManager.CloseUI(UIManager.UI_Config.UGC_WOW_PASS_Privilege_Success)
end
function logic_ugc_WOWPass:GetUGCWOWPassAllTaskConfig()
  if self.AllTaskConfig then
    return self.AllTaskConfig
  end
  if not self.UGCPassInfo then
    log_warning(bWriteLog and "logic_ugc_WOWPass:GetUGCWOWPassAllTaskConfig UGCPassInfo is Nil")
    return
  end
  self.AllTaskConfig = CDataTable.GetTableByFilter("WowPassTaskCfg", "season_id", self:GetSeasonID()) or {}
  return self.AllTaskConfig
end
function logic_ugc_WOWPass:GetUGCWOWPassWeekTaskConfig()
  if self.WeekTaskConfig then
    return self.WeekTaskConfig
  end
  if not self.UGCPassInfo then
    log_warning(bWriteLog and "logic_ugc_WOWPass:GetUGCWOWPassWeekTaskConfig UGCPassInfo is Nil")
    return
  end
  local AllTaskConfig = self:GetUGCWOWPassAllTaskConfig()
  local WeekTaskConfig = {}
  for ID, Task in pairs(AllTaskConfig) do
    if Task.week_index > 0 then
      local WeekTaskMap = WeekTaskConfig[Task.week_index]
      if not WeekTaskMap then
        WeekTaskMap = {}
        WeekTaskConfig[Task.week_index] = WeekTaskMap
      end
      WeekTaskMap[ID] = Task
    end
  end
  self.  return WeekTaskConfig
end
function logic_ugc_WOWPass:GetUGCWOWPassSeasonTaskConfig()
  if self.SeasonTaskConfig then
    return self.SeasonTaskConfig
  end
  if not self.UGCPassInfo then
    log_warning(bWriteLog and "logic_ugc_WOWPass:GetUGCWOWPassSeasonTaskConfig UGCPassInfo is Nil")
    return
  end
  local AllTaskConfig = self:GetUGCWOWPassAllTaskConfig()
  local SeasonTaskConfig = {}
  for ID, Task in pairs(AllTaskConfig) do
    if Task.week_index == 0 then
      SeasonTaskConfig[ID] = Task
    end
  end
  self.  return SeasonTaskConfig
end
function logic_ugc_WOWPass:GetValidUGCPassInfo()
  if self.UGCPassInfo then
    if self:IsSeasonActive() then
      return self.UGCPassInfo
    else
      print(bWriteLog and "logic_ugc_WOWPass:GetValidUGCPassInfo UGCPass End")
      return nil
    end
  else
    return nil
  end
end
function logic_ugc_WOWPass:GetValidUGCPASSTaskStatus()
  if self:GetCurWeekIndex() == self.CurTaskWeek then
    return self.UGCPASSTaskStatus
  else
    print(bWriteLog and "logic_ugc_WOWPass:GetValidUGCPASSTaskStatus UGCPassTask Next Week")
  end
end
function logic_ugc_WOWPass:GetUGCPASSTaskStatusByID(WeekID, TaskID)
  local UGCPASSTaskStatus = self:GetValidUGCPASSTaskStatus()
  if UGCPASSTaskStatus then
    local TaskStatusList = WeekID and WeekID ~= 0 and UGCPASSTaskStatus.week_task[WeekID] or UGCPASSTaskStatus.challenge_task
    if TaskStatusList then
      return TaskStatusList[TaskID]
    end
  end
end
function logic_ugc_WOWPass:ShowRewardSlapUI(ItemList)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local tShowConfig = {}
  if ItemList and #ItemList == 1 then
    local Item = ItemList[1]
    local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
    local maintype = logic_ugc_inventory:GetTabIDDigits(Item.resid)
    local subtype = logic_ugc_inventory:GetSubTabIDDigits(Item.resid)
    local bCheckTab = logic_ugc_inventory:CheckTabIdIsInventory(maintype)
    if bCheckTab then
      do
        local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
        tShowConfig = {
          tAllBtnShowData = CommonItemGet_BtnCfgUtils.CreateTwoGeneralBtnData(LocUtil.GetLocalizeResStr(29080), function()
            local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
            local maintype = logic_ugc_inventory:GetTabIDDigits(Item.resid)
            local subtype = logic_ugc_inventory:GetSubTabIDDigits(Item.resid)
            local bCheckTab = logic_ugc_inventory:CheckTabIdIsInventory(maintype)
            if bCheckTab then
              local res_ids = {
                Item.resid
              }
              local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
              UGCPassHandler.send_ugc_personal_setting_set_req(maintype, subtype, res_ids)
            else
              log(bWriteLog and "logic_ugc_WOWPass:ShowRewardSlapUI UGCPassTask not in inventory")
            end
          end)
        }
      end
    end
  end
  Logic_CommonItemGet.ShowPanel_FullCustom(ItemList, tShowConfig)
end
function logic_ugc_WOWPass:BuyPassLevel(BuyPrice, Level, CurScore, BuyLevel)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  local strBuy = LocUtil.GetLocalizeResStr(301185)
  local tip = LocUtil.LocalizeResFormat(68893, BuyPrice, BuyLevel)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local msgData = {
    styleType = 2,
    title = strBuy,
    msg = tip,
    clickOkCallback = function()
      if DataMgr.ticket >= BuyPrice then
        UIManager.CloseUI(UIManager.UI_Config.UGC_WOW_PASS_BuyLevel)
      end
      self:ReqUGCWOWPassBuyLevel(BuyPrice, Level, CurScore)
    end
  }
  CommonMsgBoxMgr.ShowUSPolicyTip(msgData)
end
function logic_ugc_WOWPass:UpdateCameraAndBg(SceneType, IsShow)
  IsShow = IsShow or false
  local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  local CamerID = ConstAvatarDislay.CameraID[SceneType]
  if not CamerID then
    return
  end
  local SceneName = "Lobby_RP_400"
  local LightName = "Lobby_RP_Light"
  local CamerCfg = CDataTable.GetTableData("LobbyCameraInfo", CamerID)
  if CamerCfg then
    SceneName = CamerCfg.SceneName
    LightName = CamerCfg.LightLevelName
  end
  if IsShow then
    LobbySceneManager.LoadStreamLevel(true, SceneName, CamerID, LightName, {
      bAsync = LobbySceneManager.ENUM_ASYNC.WOW_PASS,
      Callback = function()
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_UPDATE_SCENE_TARGET_POSITION)
      end
    })
  else
    LobbySceneManager.LoadStreamLevel(false, SceneName, nil, nil, {bForceUnload = true})
  end
end
function logic_ugc_WOWPass:ReqUGCWOWPassIsBuy()
  UGCPassHandler.send_ugc_pass_get_buy_info_req()
end
function logic_ugc_WOWPass:OnUGCWOWPassIsBuyRsp(error_code, is_buy)
  print(bWriteLog and "logic_ugc_WOWPass:OnUGCWOWPassIsBuyRsp", error_code, is_buy)
  if error_code == 0 then
    self.IsBuyPass = is_buy
  else
    ShowNotice(error_code)
  end
end
local InfoReqCD = 5
function logic_ugc_WOWPass:ReqUGCWOWPassInfo(bNeedShowTips)
  print(bWriteLog and "logic_ugc_WOWPass:ReqUGCWOWPassInfo")
  local CurTime = TimeUtil.GetServerTimeInSec()
  if CurTime - self.LastSendPassInfoTime < InfoReqCD then
    return
  end
  table.insert(self.ShowTipsQueue, bNeedShowTips)
  local PHomePassHandler = require("client.network.Protocol.PHomePassHandler")
  PHomePassHandler.send_manor_upass_info_req()
  UGCPassHandler.send_ugc_pass_get_info_req()
  self.LastSendPassInfoTime = TimeUtil.GetServerTimeInSec()
end
function logic_ugc_WOWPass:OnUGCWOWPassInfoRsp(ErrorCode, PassInfo)
  print(bWriteLog and "logic_ugc_WOWPass:OnUGCWOWPassInfoRsp", ErrorCode, PassInfo)
  if ErrorCode == 0 and PassInfo then
    log_tree(PassInfo)
    local version_util = require("client.common.version_util")
    local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
    local static_season_info = PassInfo.static_season_info
    if not static_season_info then
      self.OpenPanelQueue = {}
      return
    end
    local cfg = static_season_info.cfg
    if not cfg then
      self.OpenPanelQueue = {}
      return
    end
    print(bWriteLog and "logic_ugc_WOWPass:OnUGCWOWPassInfoRsp ClientVersion", ClientVersion, cfg.version)
    if version_util.CompareVersionStandard(ClientVersion, cfg.version) == -1 then
      ShowNotice(2008001)
      self.OpenPanelQueue = {}
      return
    end
    self.UGC    if self.UGCPassInfo and self.UGCPassInfo.is_buy and self.UGCPassInfo.is_buy == 1 then
      self.IsBuyPass = 1
    end
    self:SetLevel(PassInfo.current_level)
    self:SetScore(PassInfo.current_level_exp_value)
    self:SetMaxScorePerLevel(PassInfo.level_up_max_exp_value)
    self:SetUCPricePerLevel(PassInfo.exp_value_per_uc_tick)
    self:OpenQueuePanels()
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_INFO_UPDATE)
  else
    if self.ShowTipsQueue[1] then
      ShowNotice(ErrorCode)
    end
    table.remove(self.ShowTipsQueue, 1)
    self.OpenPanelQueue = {}
    self:ReqUGCWOWPassIsBuy()
  end
end
function logic_ugc_WOWPass:CheckWoWPassDisplay(uid)
  log(bWriteLog and string.format("logic_ugc_WOWPass:CheckWoWPassDisplay uid: %s", tostring(uid)))
  if tonumber(DataMgr.roleData.uid) == tonumber(uid) then
    local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
    log(bWriteLog and string.format("logic_ugc_WOWPass:CheckWoWPassDisplay bWoWPassDisplay = %s", tostring(LogicSettingBasic.bWoWPassDisplay)))
    return LogicSettingBasic.bWoWPassDisplay
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local info = logic_profile:GetLocalProfile(uid)
  if info and info.ugc_privacy_setting then
    log_tree(bWriteLog and "logic_ugc_WOWPass:CheckWoWPassDisplay info.ugc_privacy_setting", info.ugc_privacy_setting)
  end
  if info and info.ugc_privacy_setting and info.ugc_privacy_setting.wow_pass_display == true then
    log(bWriteLog and "logic_ugc_WOWPass:CheckWoWPassDisplay return false")
    return false
  end
  log(bWriteLog and "logic_ugc_WOWPass:CheckWoWPassDisplay return true")
  return true
end
function logic_ugc_WOWPass:GetWOWpassIcon()
  if not self:CheckWoWPassDisplay(tonumber(DataMgr.roleData.uid)) then
    return nil
  end
  if self:IsBuyElite() then
    local RawBuyTimes = self.UGCPassInfo and self.UGCPassInfo.accumulate_buy_times
    local BuyTimes = RawBuyTimes and 0 < RawBuyTimes and RawBuyTimes or 1
    local WowPassSignCfgs = CDataTable.GetTable("WowPassSign")
    local CurSignCfg
    for ID, SignCfg in pairs(WowPassSignCfgs) do
      if BuyTimes >= SignCfg.AccBuyCount then
        if CurSignCfg == nil then
          Cur        elseif CurSignCfg.AccBuyCount < SignCfg.AccBuyCount then
          Cur        end
      end
    end
    if CurSignCfg ~= nil then
      return CurSignCfg.SignIconPath
    end
  end
  return nil
end
function logic_ugc_WOWPass:ReqUGCWOWRedPointInfo()
  print(bWriteLog and "logic_ugc_WOWPass:ReqUGCWOWRedPointInfo")
  local CurTime = TimeUtil.GetServerTimeInSec()
  if CurTime - self.LastReqRedDotTime < 3 then
    print(bWriteLog and "logic_ugc_WOWPass:ReqUGCWOWRedPointInfo In CD")
    return
  end
  UGCPassHandler.send_ugc_pass_enter_redpoint_req()
end
function logic_ugc_WOWPass:OnUGCWOWRedPointInfoRsp(ErrorCode, NotifyInfo)
  if ErrorCode == 0 and type(NotifyInfo) == "table" then
    print(bWriteLog and "logic_ugc_WOWPass:OnUGCWOWRedPointInfoRsp", ErrorCode, NotifyInfo.task_has, NotifyInfo.level_has)
    self.bShowRedDot = NotifyInfo.task_has or NotifyInfo.level_has
    self.RedDotInfo = NotifyInfo
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_RED_DOT_STATE_CHANGE, self.bShowRedDot)
  end
end
function logic_ugc_WOWPass:OnUGCPassRewardInfoNotify(NotifyInfo)
  if NotifyInfo then
    print(bWriteLog and "logic_ugc_WOWPass:OnUGCPassRewardInfoNotify", NotifyInfo.task_has, NotifyInfo.level_has)
    if NotifyInfo.task_has ~= nil then
      self.bShowRedDot = NotifyInfo.task_has or self.RedDotInfo.level_has
      self.RedDotInfo.task_has = NotifyInfo.task_has
    end
    if NotifyInfo.level_has ~= nil then
      self.bShowRedDot = NotifyInfo.level_has or self.RedDotInfo.task_has
      self.RedDotInfo.level_has = NotifyInfo.level_has
    end
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_RED_DOT_STATE_CHANGE, self.bShowRedDot)
  end
end
function logic_ugc_WOWPass:ReqUGCWOWPassTaskStatus()
  print(bWriteLog and "logic_ugc_WOWPass:ReqUGCWOWPassTaskStatus")
  UGCPassHandler.send_ugc_pass_get_current_task_status_req()
end
function logic_ugc_WOWPass:OnGetUGCWOWPassTaskStatusRsp(ErrorCode, StatusList)
  print(bWriteLog and "logic_ugc_WOWPass:OnGetUGCWOWPassTaskStatusRsp", ErrorCode)
  if ErrorCode == 0 then
    log_tree("logic_ugc_WOWPass:OnGetUGCWOWPassTaskStatusRsp StatusList", StatusList)
    NewTaskStatusDebugCache = {
      From = "ugc_pass_get_current_task_status_rsp",
      StatusList = DeepCopy(StatusList or {})
    }
    self:SetUGCWOWPassTaskStatus(StatusList)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_TASK_STATUS_CHANGE_ALL)
  else
    ShowNotice(ErrorCode)
  end
end
function logic_ugc_WOWPass:OnUGCWOWPassTaskStatusNotify(StatusList)
  print(bWriteLog and "logic_ugc_WOWPass:OnUGCWOWPassTaskStatusNotify")
  log_tree("logic_ugc_WOWPass:OnUGCWOWPassTaskStatusNotify StatusList", StatusList)
  NewTaskStatusDebugCache = {
    From = "ugc_pass_task_status_change_notify",
    StatusList = DeepCopy(StatusList or {})
  }
  self:SetUGCWOWPassTaskStatus(StatusList)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_TASK_STATUS_CHANGE_ALL)
  self:RefreshWOWPassTaskRedDotState()
end
function logic_ugc_WOWPass:SetUGCWOWPassTaskStatus(StatusList)
  self.UGCPASSTaskStatus = StatusList
  self.CurTaskWeek = self:GetCurWeekIndex()
  local WeekTaskConfig = self:GetUGCWOWPassWeekTaskConfig()
  if not WeekTaskConfig then
    return
  end
  for WeekID, TaskList in pairs(StatusList.week_task) do
    local TaskConfigMap = WeekTaskConfig[WeekID]
    for ID, Status in pairs(TaskList) do
      local TaskConfig = TaskConfigMap and TaskConfigMap[ID]
      if TaskConfig and TaskConfig.task_limit_week > 0 and TaskConfig.week_index ~= self.CurTaskWeek and Status.status ~= Config_UGC.Enum_UGCPASSTask_Status.UnReward then
        Status.status = Config_UGC.Enum_UGCPASSTask_Status.Expired
      end
    end
  end
end
function logic_ugc_WOWPass:FinishTaskByCardReq(WeekID, TaskID)
  print(bWriteLog and "logic_ugc_WOWPass:FinishTaskByCardReq", WeekID, TaskID)
  local LatestStatus = self:GetUGCPASSTaskStatusByID(WeekID, TaskID)
  if not LatestStatus or LatestStatus.status ~= Config_UGC.Enum_UGCPASSTask_Status.UnFinish then
    print(bWriteLog and "logic_ugc_WOWPass:FinishTaskByCardReq invalid status, skip", WeekID, TaskID, LatestStatus and LatestStatus.status)
    return
  end
  UGCPassHandler.send_ugc_pass_finish_task_by_card_req(WeekID, TaskID)
end
function logic_ugc_WOWPass:OnFinishTaskByCardRsp(ErrorCode, WeekID, TaskID)
  print(bWriteLog and "logic_ugc_WOWPass:OnFinishTaskByCardRsp", ErrorCode, WeekID, TaskID)
  if ErrorCode == 0 then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_TASK_Finish_Rsp, WeekID, TaskID)
    self.FinishingTaskInfo = {WeekID = WeekID, TaskID = TaskID}
  else
    ShowNotice(ErrorCode)
    self:ReportTLogData(ErrorCode, WeekID, TaskID, "finish_rsp")
  end
end
local function DumpTable(object)
  if type(object) == "table" then
    local s = "{ "
    local first = true
    for k, v in pairs(object) do
      local nextStr = k .. ":" .. DumpTable(v)
      if not first then
        nextStr = ", " .. nextStr
      end
      s = s .. nextStr
      first = false
    end
    return s .. " }"
  end
  return tostring(object)
end
function logic_ugc_WOWPass:GetSingleTaskRewardReq(WeekID, TaskID, Task, TaskStatus)
  print(bWriteLog and "logic_ugc_WOWPass:GetSingleTaskRewardReq", WeekID, TaskID)
  local LatestStatus = self:GetUGCPASSTaskStatusByID(WeekID, TaskID)
  if not LatestStatus or LatestStatus.status ~= Config_UGC.Enum_UGCPASSTask_Status.UnReward then
    print(bWriteLog and "logic_ugc_WOWPass:GetSingleTaskRewardReq invalid status, skip", WeekID, TaskID, LatestStatus and LatestStatus.status)
    return
  end
  local TaskCache = {
    task_condition_id = Task.task_condition_id,
    finish_type = Task.finish_type,
    finish_value = Task.finish_value,
    circle_count = Task.circle_count,
    task_card_resid = Task.task_card_resid,
    card_count = Task.card_count
  }
  table.insert(TaskReqQueue, {
    WeekID = WeekID,
    TaskID = TaskID,
    TaskStr = DumpTable(TaskCache),
    StatusStr = DumpTable(TaskStatus)
  })
  UGCPassHandler.send_ugc_pass_get_task_reward_req(WeekID, TaskID)
end
function logic_ugc_WOWPass:_FormatDebugString(str)
  if not str then
    return str
  end
  str = string.gsub(str, "true", "1")
  str = string.gsub(str, "false", "0")
  str = string.gsub(str, ",", "-")
  str = string.gsub(str, "{", "<")
  str = string.gsub(str, "}", ">")
  str = string.gsub(str, "%(", "<")
  str = string.gsub(str, "%)", ">")
  str = string.gsub(str, " ", "")
  if string.len(str) > 255 then
    str = string.sub(str, 1, 255)
  end
  return str
end
function logic_ugc_WOWPass:_GenerateStr(WeekID, TaskID, ClientTaskStatus, From)
  if ClientTaskStatus.WeekID ~= WeekID or ClientTaskStatus.TaskID ~= TaskID then
    return
  end
  local Basicinfo = string.format("WeekID:%s,TaskID:%s", tostring(WeekID), tostring(TaskID))
  local ServerStatusCache = NewTaskStatusDebugCache.StatusList or {}
  local ChangeTask = ServerStatusCache.challenge_task or {}
  local ServerTaskStatus = ChangeTask[TaskID]
  if not ServerTaskStatus then
    local WeekTask = ServerStatusCache.week_task or {}
    local WeekTaskList = WeekTask[WeekID] or {}
    ServerTaskStatus = WeekTaskList[TaskID] or {}
  end
  local ServerInfo = string.format("From:%s,Status:%s", tostring(NewTaskStatusDebugCache.From), dump(ServerTaskStatus))
  local ClickFrom = "Nil"
  if UIManager.IsUIShow(UIManager.UI_Config.UGC_WOW_PASS_MainUI) then
    ClickFrom = "UGC_WOW_PASS_MainUI"
  end
  print(bWriteLog and "logic_ugc_WOWPass:_GenerateStr ExecFrom", From)
  print(bWriteLog and "logic_ugc_WOWPass:_GenerateStr ClickFrom", ClickFrom)
  print(bWriteLog and "logic_ugc_WOWPass:_GenerateStr Basicinfo", Basicinfo)
  print(bWriteLog and "logic_ugc_WOWPass:_GenerateStr ClientTask", ClientTaskStatus.TaskStr)
  print(bWriteLog and "logic_ugc_WOWPass:_GenerateStr ClientStatus", ClientTaskStatus.StatusStr)
  print(bWriteLog and "logic_ugc_WOWPass:_GenerateStr NewestServerInfo", ServerInfo)
  return {
    from = From,
    click_from = ClickFrom,
    basic_info = Basicinfo,
    client_task = ClientTaskStatus.TaskStr,
    client_status = ClientTaskStatus.StatusStr,
    server_info = ServerInfo
  }
end
function logic_ugc_WOWPass:ReportTLogData(ErrorCode, WeekID, TaskID, From)
  local ClientTaskStatus = table.remove(TaskReqQueue, 1)
  if ClientTaskStatus then
    local ErrorInfo = self:_GenerateStr(WeekID, TaskID, ClientTaskStatus, From)
    UGCPassHandler.send_ugc_wowpass_task_rsperror_tlog_req(ErrorInfo)
  end
end
function logic_ugc_WOWPass:OnGetSingleTaskRewardRsp(ErrorCode, WeekID, TaskID, ItemList)
  print(bWriteLog and "logic_ugc_WOWPass:OnGetSingleTaskRewardRsp", ErrorCode, WeekID, TaskID)
  if ErrorCode == 0 then
    log_tree("logic_ugc_WOWPass:OnGetSingleTaskRewardRsp ItemList", ItemList)
    self:ShowRewardSlapUI(ItemList)
  else
    ShowNotice(ErrorCode)
    self:ReportTLogData(ErrorCode, WeekID, TaskID, "reward_rsp")
  end
end
function logic_ugc_WOWPass:GetAllTaskRewardReq()
  print(bWriteLog and "logic_ugc_WOWPass:GetAllTaskRewardReq")
  UGCPassHandler.send_ugc_pass_get_all_task_reward_req()
end
function logic_ugc_WOWPass:OnGetAllTaskRewardRsp(ErrorCode, ItemList)
  print(bWriteLog and "logic_ugc_WOWPass:OnGetAllTaskRewardRsp", ErrorCode)
  if ErrorCode == 0 then
    log_tree("logic_ugc_WOWPass:OnGetAllTaskRewardRsp ItemList", ItemList)
    self:ShowRewardSlapUI(ItemList)
  else
    ShowNotice(ErrorCode)
  end
end
function logic_ugc_WOWPass:ReqUGCWOWPassBuyLevel(BuyPrice, Level, CurScore)
  print(bWriteLog and "logic_ugc_WOWPass:ReqUGCWOWPassBuyLevel")
  self.nUCCountLackTip = BuyPrice
  UGCPassHandler.send_ugc_pass_buy_level_req(BuyPrice, Level, CurScore)
end
function logic_ugc_WOWPass:OnUGCWOWPassBuyLevelRsp(err_code, buy_score, pass_score, current_pass_level, before_pass_level)
  print(bWriteLog and "logic_ugc_WOWPass:OnUGCWOWPassBuyLevelRsp", err_code, buy_score, pass_score, current_pass_level, before_pass_level)
  if err_code == 0 then
    self:SetBeforeLevel(before_pass_level)
    self:SetLevel(current_pass_level)
    if before_pass_level < current_pass_level then
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_BUY_Level_RSP)
      self:OpenUpLevelSuccessUI()
    end
  elseif err_code == 2008006 then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(self.nUCCountLackTip)
  else
    ShowNotice(err_code)
  end
end
function logic_ugc_WOWPass:OnUGCPassScoreLevelChangeRsp(DiffValue, Score, Level)
  print(bWriteLog and "logic_ugc_WOWPass:OnUGCPassScoreLevelChangeRsp", DiffValue, Score, Level)
  self:SetLevel(Level)
  self:SetScore(Score)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_SCORE_LEVEL_CHANGE)
end
function logic_ugc_WOWPass:BuyPass()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  local Price, DiscountPrice = self:GetSeasonPirce()
  local DiffPrice = DiscountPrice > DataMgr.ticket and DiscountPrice - DataMgr.ticket or 0
  local strBuy = LocUtil.GetLocalizeResStr(301185)
  local tip = LocUtil.LocalizeResFormat(68896, DiscountPrice)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local msgData = {
    styleType = 2,
    title = strBuy,
    msg = tip,
    clickOkCallback = function()
      self:_CloseBuyBuyPassGuide()
      self:ReqUGCWOWPassBuyReq(DiscountPrice)
    end
  }
  CommonMsgBoxMgr.ShowUSPolicyTip(msgData)
end
function logic_ugc_WOWPass:ReqUGCWOWPassBuyReq(BuyPrice)
  print(bWriteLog and "logic_ugc_WOWPass:ReqUGCWOWPassBuy")
  self.nUCCountLackTip = BuyPrice
  UGCPassHandler.send_ugc_buy_pass_req()
end
function logic_ugc_WOWPass:ReqUGCWOWPassBuyRsp(err_code, instant_reward_list, pass_score, current_pass_level, level_reward_status)
  print(bWriteLog and "logic_ugc_WOWPass:ReqUGCWOWPassBuyRsp")
  if err_code == 0 then
    self:SetLevel(current_pass_level)
    self:SetScore(pass_score)
    if self.UGCPassInfo and self.UGCPassInfo.level_reward_status_list then
      self.UGCPassInfo.level_reward_status_list = level_reward_status
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_AWARD_STATUS_CHANGE)
    end
    if self.UGCPassInfo and self.UGCPassInfo.is_buy then
      self.UGCPassInfo.is_buy = 1
      self.IsBuyPass = 1
    end
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_BUY_PASS_RSP)
    self:OpenBuyPassSuccessUI()
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    LogicUGC:ClearAllModCache()
    UIManager.CloseUI(UIManager.UI_Config.UGC_WoWPass_BuyTogether_UIBP)
    self:ReqUGCWOWRedPointInfo()
  elseif err_code == 2008006 then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(self.nUCCountLackTip)
  else
    ShowNotice(err_code)
  end
end
function logic_ugc_WOWPass:ReqUGCWOWPassBuyGuideReq()
  print(bWriteLog and "logic_ugc_WOWPass:ReqUGCWOWPassBuyGuideReq")
  local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
  local bIsGuideOn = logic_ugc_newbie_guide:IsOngoingStrongGuide()
  if not bIsGuideOn then
    UGCPassHandler.send_ugc_pass_buy_guide_req()
  else
    print(bWriteLog and "logic_ugc_WOWPass:ReqUGCWOWPassBuyGuideReq bIsGuideOn is false")
  end
end
function logic_ugc_WOWPass:ReqUGCWOWPassBuyGuideRsp(err_code, show_flag)
  print(bWriteLog and string.format("logic_ugc_WOWPass:ReqUGCWOWPassBuyGuideRsp error_code: %s, show_flag: %s", err_code, show_flag))
  if err_code == 0 then
    self.    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_BUY_GUIDE_RSP)
  else
  end
end
function logic_ugc_WOWPass:LevelRewardStatusChangeNotify(StatusList)
  print(bWriteLog and "logic_ugc_WOWPass:LevelRewardStatusChangeNotify")
  if self.UGCPassInfo and self.UGCPassInfo.level_reward_status_list then
    self.UGCPassInfo.level_reward_status_list = StatusList
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_AWARD_STATUS_CHANGE)
    self:RefreshWOWPassRewardRedDotState()
  end
end
function logic_ugc_WOWPass:ReqWOWPassGetAllAward()
  print(bWriteLog and "logic_ugc_WOWPass:ReqWOWPassGetAllAward")
  UGCPassHandler.send_ugc_pass_get_all_level_award_req()
end
function logic_ugc_WOWPass:WOWPassGetAllAwardRsp(ErrorCode, ItemList, StatusList)
  print(bWriteLog and "logic_ugc_WOWPass:WOWPassGetAllAwardRsp", ErrorCode)
  local logic_home_pass = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_pass)
  if ErrorCode == 0 then
    log_tree("logic_ugc_WOWPass:WOWPassGetAllAwardRsp ItemList", ItemList)
    if logic_home_pass:IsTakingJointReward() then
      logic_home_pass:SetWowJointReward(ItemList or {})
    else
      self:ShowRewardSlapUI(ItemList)
    end
    if self.UGCPassInfo and self.UGCPassInfo.level_reward_status_list then
      self.UGCPassInfo.level_reward_status_list = StatusList
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_AWARD_STATUS_CHANGE)
      self:RefreshWOWPassRewardRedDotState()
    end
  else
    logic_home_pass:CheckJointRewardError(ErrorCode, 2)
    ShowNotice(ErrorCode)
  end
end
function logic_ugc_WOWPass:ReqWOWPassAward(Level, bElite)
  print(bWriteLog and "logic_ugc_WOWPass:ReqWOWPassAward", Level, bElite)
  UGCPassHandler.send_ugc_pass_get_level_award_req(Level, bElite)
end
function logic_ugc_WOWPass:WOWPassGetAwardRsp(ErrorCode, Level, bElite, ItemList, StatusList)
  print(bWriteLog and "logic_ugc_WOWPass:WOWPassGetAwardRsp", ErrorCode, Level, bElite)
  if ErrorCode == 0 then
    log_tree("logic_ugc_WOWPass:WOWPassGetAwardRsp ItemList", ItemList)
    self:ShowRewardSlapUI(ItemList)
    if self.UGCPassInfo and self.UGCPassInfo.level_reward_status_list then
      self.UGCPassInfo.level_reward_status_list = StatusList
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_AWARD_STATUS_CHANGE)
      self:RefreshWOWPassRewardRedDotState()
    end
  else
    ShowNotice(ErrorCode)
  end
end
function logic_ugc_WOWPass:GetUGCPassSeasonInfo()
  if self.UGCPassInfo then
    return self.UGCPassInfo.static_season_info
  end
  return nil
end
function logic_ugc_WOWPass:GetUGCPassSeasonInfoCfg()
  if self:GetUGCPassSeasonInfo() then
    return self:GetUGCPassSeasonInfo().cfg
  end
  return nil
end
function logic_ugc_WOWPass:GetMaxLevel()
  if self:GetUGCPassSeasonInfoCfg() then
    return self:GetUGCPassSeasonInfoCfg().max_level
  end
  return 50
end
function logic_ugc_WOWPass:IsBuyElite()
  if self:GetValidUGCPassInfo() then
    return self.UGCPassInfo.is_buy == 1 and true or false
  end
  return self.IsBuyPass == 1 and true or false
end
function logic_ugc_WOWPass:SetLevel(Value)
  self.CurLevel = Value
end
function logic_ugc_WOWPass:GetLevel()
  return self.CurLevel
end
function logic_ugc_WOWPass:SetScore(Value)
  self.CurScore = Value
end
function logic_ugc_WOWPass:GetScore()
  return self.CurScore
end
function logic_ugc_WOWPass:SetMaxScorePerLevel(Value)
  self.MaxScorePerLevel = Value
end
function logic_ugc_WOWPass:GetMaxScorePerLevel()
  return self.MaxScorePerLevel
end
function logic_ugc_WOWPass:SetUCPricePerLevel(Value)
  self.UCPricePerLevel = Value
end
function logic_ugc_WOWPass:GetUCPricePerLevel()
  return self.UCPricePerLevel
end
function logic_ugc_WOWPass:SetBeforeLevel(Value)
  self.BeforeLevel = Value
end
function logic_ugc_WOWPass:GetBeforeLevel()
  return self.BeforeLevel
end
function logic_ugc_WOWPass:GetSeasonID()
  if self:GetUGCPassSeasonInfo() then
    return self:GetUGCPassSeasonInfo().season_id
  end
  return nil
end
function logic_ugc_WOWPass:GetSeasonPirce()
  local SeasonId = self:GetSeasonID()
  if SeasonId then
    local SeasonInfo = CDataTable.GetTableData("WowPassSeasonTimeCfg", SeasonId)
    if SeasonInfo then
      return SeasonInfo.Price, SeasonInfo.DiscountPrice
    end
  end
  return nil
end
function logic_ugc_WOWPass:GetSeasonPassRoleImagePath()
  local SeasonId = self:GetSeasonID()
  if SeasonId then
    local SeasonInfo = CDataTable.GetTableData("WowPassSeasonTimeCfg", SeasonId)
    if SeasonInfo then
      return SeasonInfo.RoleImagePath, SeasonInfo.RoleImagePath2
    end
  end
end
function logic_ugc_WOWPass:GetSeasonImagePreviewRolePath()
  log(bWriteLog and "logic_ugc_WOWPass:GetSeasonImagePreviewRolePath")
  local SeasonId = self:GetSeasonID()
  log(bWriteLog and "logic_ugc_WOWPass:GetSeasonImagePreviewRolePath SeasonId = " .. tostring(SeasonId))
  if SeasonId then
    local SeasonInfo = CDataTable.GetTableData("WowPassSeasonTimeCfg", SeasonId)
    if SeasonInfo then
      return SeasonInfo.ImagePreviewRolePath
    end
  end
  return nil
end
function logic_ugc_WOWPass:GetSeasonImagePreviewBGPath()
  log(bWriteLog and "logic_ugc_WOWPass:GetSeasonImagePreviewBGPath")
  local SeasonId = self:GetSeasonID()
  log(bWriteLog and "logic_ugc_WOWPass:GetSeasonImagePreviewBGPath SeasonId = " .. tostring(SeasonId))
  if SeasonId then
    local SeasonInfo = CDataTable.GetTableData("WowPassSeasonTimeCfg", SeasonId)
    if SeasonInfo then
      return SeasonInfo.ImagePreviewBGPath
    end
  end
  return nil
end
function logic_ugc_WOWPass:GetSeasonEndTime()
  local cfg = self:GetUGCPassSeasonInfoCfg()
  if not cfg then
    return TimeUtil.GetServerTimeInSec()
  end
  return cfg.end_time
end
function logic_ugc_WOWPass:GetCurWeekIndex()
  local cfg = self:GetUGCPassSeasonInfoCfg()
  if not cfg then
    return 1
  end
  local WeekTimeSec = math.max(TimeUtil.GetServerTimeInSec() - cfg.start_time, 0)
  return math.ceil(WeekTimeSec / 604800)
end
function logic_ugc_WOWPass:GetFirstUnRewardTaskWeek()
  local UGCPASSTaskStatus = self:GetValidUGCPASSTaskStatus()
  if UGCPASSTaskStatus then
    for WeekID, TaskList in pairs(UGCPASSTaskStatus.week_task) do
      if WeekID > self:GetCurWeekIndex() then
        break
      end
      for ID, Status in pairs(TaskList) do
        if Status.status == Config_UGC.Enum_UGCPASSTask_Status.UnReward then
          return WeekID
        end
      end
    end
  end
  return self:GetCurWeekIndex()
end
function logic_ugc_WOWPass:GetTaskConfig()
  return self:GetUGCWOWPassWeekTaskConfig(), self:GetUGCWOWPassSeasonTaskConfig()
end
function logic_ugc_WOWPass:IsSeasonActive()
  if not self.UGCPassInfo then
    self:ReqUGCWOWPassInfo()
    return false
  end
  local EndTime = self:GetSeasonEndTime()
  local LeftTime = EndTime - TimeUtil.GetServerTimeInSec()
  return 0 < LeftTime
end
function logic_ugc_WOWPass:GetPassRewardStatus(Level)
  local UGCPassInfo = self:GetValidUGCPassInfo()
  if UGCPassInfo then
    local LevelStatus = UGCPassInfo.level_reward_status_list
    if LevelStatus then
      return LevelStatus.normal_status[Level] or 0, LevelStatus.elite_status[Level] or 0
    end
  end
  return 0, 0
end
function logic_ugc_WOWPass:CanPlayerGetPassReward()
  local UGCPassInfo = self:GetValidUGCPassInfo()
  if not UGCPassInfo then
    return
  end
  local LevelStatus = UGCPassInfo.level_reward_status_list
  if not LevelStatus then
    return
  end
  for Level, Status in pairs(LevelStatus.normal_status) do
    if Status == Enum_ItemStatus.Done then
      return true
    end
  end
  for Level, Status in pairs(LevelStatus.elite_status) do
    if Status == Enum_ItemStatus.Done then
      return true
    end
  end
end
function logic_ugc_WOWPass:CanPlayerGetTaskReward()
  local UGCPASSTaskStatus = self:GetValidUGCPASSTaskStatus()
  if UGCPASSTaskStatus then
    for WeekID, TaskList in pairs(UGCPASSTaskStatus.week_task) do
      for ID, Status in pairs(TaskList) do
        if Status.status == Config_UGC.Enum_UGCPASSTask_Status.UnReward then
          return true
        end
      end
    end
    for ID, Status in pairs(UGCPASSTaskStatus.challenge_task) do
      if Status.status == Config_UGC.Enum_UGCPASSTask_Status.UnReward then
        return true
      end
    end
  end
end
function logic_ugc_WOWPass:GetFinishingTaskInfo()
  return self.FinishingTaskInfo
end
function logic_ugc_WOWPass:ClearFinishingTaskInfo()
  self.FinishingTaskInfo = nil
end
function logic_ugc_WOWPass:SetPendingTaskFinishByCardInfo(WeekID, TaskID, goodsID)
  self.PendingFinishByCardInfo = {
    WeekID = WeekID,
    TaskID = TaskID,
    GoodsID = goodsID
  }
end
function logic_ugc_WOWPass:DirectBuyMissionCardSuccess(_, _, Param)
  local PendingFinishByCardInfo = self.PendingFinishByCardInfo
  if PendingFinishByCardInfo and Param and PendingFinishByCardInfo.GoodsID == Param.id then
    self:FinishTaskByCardReq(PendingFinishByCardInfo.WeekID, PendingFinishByCardInfo.TaskID)
    self.PendingFinishByCardInfo = nil
  end
end
function logic_ugc_WOWPass:DirectBuyMissionCardFail(_, _, Param)
  local PendingFinishByCardInfo = self.PendingFinishByCardInfo
  if PendingFinishByCardInfo and Param and PendingFinishByCardInfo.GoodsID == Param.id then
    self.PendingFinishByCardInfo = nil
  end
end
function logic_ugc_WOWPass:ShowTaskPanel()
  log(bWriteLog and "logic_ugc_WOWPass:ShowTaskPanel")
  if not self:IsSeasonActive() then
    local logic_assembly_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_assembly_system)
    logic_assembly_system:ShowMainUI()
  else
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    local SelectEnum = Config_UGC.Enum_WOWPass_Select
    self:OpenWowPassPanel(UIManager.UI_Config.UGC_WOW_PASS_MainUI, {
      TabID = SelectEnum.Task
    })
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_WOWPass = class(CModuleBase, nil, logic_ugc_WOWPass)
return Clogic_ugc_WOWPass