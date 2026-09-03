local ReputationSystem_Homepage_UIBP = {}
function ReputationSystem_Homepage_UIBP:ctor(_, uid)
  self.end
function ReputationSystem_Homepage_UIBP:RegistEvents()
  ReputationSystem_Homepage_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Desc, self.OnButton_DescClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_History, self.OnButton_HistoryClick, self)
  self:AddCommonEvent(EVENTTYPE_REPUTATION, EVENTID_REPUTATION_GET_CREDIT_INFO, self.RefreshUIOnGetCerditInfo, self)
end
function ReputationSystem_Homepage_UIBP:OnPostInitialize()
  ReputationSystem_Homepage_UIBP.__super.OnPostInitialize(self)
  self:InitUI()
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  logic_reputation_system:RequestCreditInfo()
end
function ReputationSystem_Homepage_UIBP:InitUI()
  if tostring(self.uid) ~= tostring(DataMgr.roleData.uid) then
    self.UIRoot.Button_History:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Button_History:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  local creditStr = LocUtil.GetLocalizeResStr(29642)
  self.UIRoot.TextBlock_HighCredit:SetText(creditStr)
  self.UIRoot.TextBlock_MidCredit:SetText(creditStr)
  self.UIRoot.TextBlock_LowCredit:SetText(creditStr)
  self.UIRoot.Text_ButtonDesc:SetText(creditStr)
  self.UIRoot.Text_ButtonHistory:SetText(LocUtil.GetLocalizeResStr(29632))
  self.UIRoot.TextBlock_Foul:SetText(LocUtil.GetLocalizeResStr(29635))
  self.UIRoot.TextBlock_Note:SetText(LocUtil.GetLocalizeResStr(44587))
  self.UIRoot.TextBlock_Rule:SetText(LocUtil.GetLocalizeResStr(9823))
  self.UIRoot.CanvasPanel_BreakRules:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.TextBlock_Recover:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.TextBlock_CreditState:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.UIRoot.DX_Enter then
    self:PlayUserWidgetAnimation(self.UIRoot.DX_Enter, 0, 1, 0, 1)
    self:PlayAudio("/Game/WwiseEvent/UI_hall/Play_UI_Hall_CreditSystem_Enter.Play_UI_Hall_CreditSystem_Enter")
  end
end
function ReputationSystem_Homepage_UIBP:RefreshUIOnGetCerditInfo()
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  local creditScore = self:GetCurrentScore()
  log(bWriteLog and "leomzhou ReputationSystem_Homepage_UIBP:RefreshUIOnGetCerditInfo creditScore: " .. tostring(creditScore))
  self:SwitchUIToCurState(creditScore)
  if tostring(self.uid) ~= tostring(DataMgr.roleData.uid) then
    log(bWriteLog and "ReputationSystem_Homepage_UIBP:RefreshUIOnGetCerditInfo uid is others")
    return
  end
  local recoverScore = logic_reputation_system:GetRecoverScore()
  log(bWriteLog and "leomzhou ReputationSystem_Homepage_UIBP:RefreshUIOnGetCerditInfo recoverScore: " .. tostring(recoverScore))
  self.UIRoot.TextBlock_Recover:SetText(LocUtil.LocalizeResFormat(29636, recoverScore))
  self:ShowBreakRulesTips()
end
function ReputationSystem_Homepage_UIBP:SwitchUIToCurState(creditScore)
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  local curDescStr, curDescExtraStr = logic_reputation_system:GetCurDescStr(creditScore)
  self.UIRoot.TextBlock_CreditState:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.TextBlock_CreditState:SetText(curDescStr)
  if curDescExtraStr == "" then
    self:SetWidgetVisible(self.UIRoot.TextBlock_CreditDesc, false)
  else
    self:SetWidgetVisible(self.UIRoot.TextBlock_CreditDesc, true)
    self.UIRoot.TextBlock_CreditDesc:SetText(curDescExtraStr)
  end
  if creditScore == 100 then
    self.UIRoot.WidgetSwitcher_Credit:SetActiveWidgetIndex(0)
    self.UIRoot.TextBlock_HighScore:SetText(creditScore)
    self.UIRoot.TextBlock_Recover:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif 60 <= creditScore and creditScore <= 99 then
    self.UIRoot.WidgetSwitcher_Credit:SetActiveWidgetIndex(1)
    self.UIRoot.ProgressBar_Mid:SetPercent(creditScore / 100)
    self.UIRoot.TextBlock_MidScore:SetText(creditScore)
    if tostring(self.uid) == tostring(DataMgr.roleData.uid) then
      self.UIRoot.TextBlock_Recover:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.TextBlock_Recover:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.UIRoot.WidgetSwitcher_Credit:SetActiveWidgetIndex(2)
    self.UIRoot.ProgressBar_Low:SetPercent(creditScore / 100)
    self.UIRoot.TextBlock_LowScore:SetText(creditScore)
    if tostring(self.uid) == tostring(DataMgr.roleData.uid) then
      self.UIRoot.TextBlock_Recover:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.TextBlock_Recover:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function ReputationSystem_Homepage_UIBP:GetCurrentScore()
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  local creditScore
  if tostring(self.uid) ~= tostring(DataMgr.roleData.uid) then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    creditScore = tonumber(RoleInfoMainSystem.GetPersonInfo().role_credit)
  else
    creditScore = logic_reputation_system:GetCreditScore()
  end
  return creditScore
end
function ReputationSystem_Homepage_UIBP:ShowBreakRulesTips()
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  local history = logic_reputation_system:GetHistoryTab() or {}
  local lastestIndex = -1
  for k, v in ipairs(history) do
    if v.modify_score < 0 then
      lastestIndex = k
      break
    end
  end
  if lastestIndex == -1 then
    log(bWriteLog and "ReputationSystem_Homepage_UIBP:ShowBreakRulesTips lastestIndex = -1")
    return
  end
  if history[lastestIndex] and history[lastestIndex].now_time then
    local latestTime = history[lastestIndex].now_time
    local TimeUtil = require("client.common.time_util")
    local latestDate = TimeUtil.OSDate("%Y-%m-%d", latestTime)
    local curTime = TimeUtil.GetServerTimeInSec()
    local curDate = TimeUtil.OSDate("%Y-%m-%d", curTime)
    if latestDate == curDate then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReputationSystem) or {}
      if cfg.latestClickTime and latestTime <= cfg.latestClickTime then
        log(bWriteLog and "ReputationSystem_Homepage_UIBP:ShowBreakRulesTips has clicked")
        return
      end
      self.UIRoot.CanvasPanel_BreakRules:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if self.UIRoot.DX_Tips then
        self:PlayUserWidgetAnimation(self.UIRoot.DX_Tips, 0, 1, 0, 1)
      end
    end
  end
end
function ReputationSystem_Homepage_UIBP:OnButton_DescClick()
  self:PlayAudio(sound_config.click)
  UIManager.ShowUI(UIManager.UI_Config.ReputationSystem_Popup02_UIBP)
end
function ReputationSystem_Homepage_UIBP:OnButton_HistoryClick()
  self:PlayAudio(sound_config.click)
  self.UIRoot.CanvasPanel_BreakRules:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReputationSystem) or {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  cfg.latestClickTime = curTime
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eReputationSystem)
  UIManager.ShowUI(UIManager.UI_Config.ReputationSystem_History_Popup_UIBP)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CReputationSystem_Homepage_UIBP = class(ui_base, nil, ReputationSystem_Homepage_UIBP)
return CReputationSystem_Homepage_UIBP