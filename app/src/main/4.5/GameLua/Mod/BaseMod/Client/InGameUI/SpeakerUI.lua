local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local EGameModeType = import("EGameModeType")
local SpeakerUI = {}
function SpeakerUI:ctor()
  self.SpeakerFlag = false
  self.bIsPreTeamSpeaker = false
end
function SpeakerUI:OnInitialize()
  self.InitVoiceStatusTimer = self:AddGameTimer(5.0, false, function()
    self:RefreshVoiceAndSpeakPanel()
  end)
  self:RefreshVoiceAndSpeakPanel()
end
function SpeakerUI:RegistEvents()
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Speaker, self, "MainControlBaseUI_CanvasPanel_Speaker")
  self:AddControlEventByControl(self.UIRoot.Button_showSpeaker, "OnClicked", self.OnShowSpeakerClick, self)
  local VoiceChatSubsytem = SubsystemMgr:Get("VoiceChatSubsystem")
  if VoiceChatSubsytem then
    self.VoiceChatSPData = VoiceChatSubsytem:GetSuperData()
    self:AddDataListener(self.VoiceChatSPData, "bIsPreTeamSpeaker", self.OnPreTeamSpeakerChange, self)
    self:AddDataListener(self.VoiceChatSPData, "bSpeakerSettingPanelOpen", self.OnSpeakerSettingPanelOpenChange, self)
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_VOICE_AND_SPEAK_CHANGE, self.RefreshVoiceAndSpeakPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_QUICK_EXPRESSION_DECAL_CLICK, self.HideVoicePanel, self)
  self.SetVoiceTLogSpeakerTimer = self:AddGameTimer(30.0, true, function()
    local VoiceChatSubsystem = SubsystemMgr:Get("VoiceChatSubsystem")
    if VoiceChatSubsystem then
      VoiceChatSubsystem:SetVoiceTLogSpeaker()
    end
  end)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Speaker)
end
function SpeakerUI:OnPostInitialize()
end
function SpeakerUI:OnShow()
  if not self.VoiceChatSPData then
    return
  end
  self.VoiceChatSPData.bSpeakerUIOpen = true
end
function SpeakerUI:OnHide()
  if not self.VoiceChatSPData then
    return
  end
  self.VoiceChatSPData.bSpeakerUIOpen = false
end
function SpeakerUI:OnClose()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Speaker)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Speaker)
  if self.InitVoiceStatusTimer then
    self:RemoveGameTimer(self.InitVoiceStatusTimer)
    self.InitVoiceStatusTimer = nil
  end
  if self.SetVoiceTLogSpeakerTimer then
    self:RemoveGameTimer(self.SetVoiceTLogSpeakerTimer)
    self.SetVoiceTLogSpeakerTimer = nil
  end
end
function SpeakerUI:CheckShowWModeUI(bNeedShow)
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GetSuperData then
    local SPData = GameState:GetSuperData()
    SPData.bNeedShowWModeUI = bNeedShow
  end
end
function SpeakerUI:HandleAndroidBack()
  self:CheckShowWModeUI(true)
  self:HideVoicePanel()
end
function SpeakerUI:HideVoicePanel()
  self:CloseSpeakerPanel()
  self:CheckShowWModeUI(true)
  self:UpdateSpeakerIconAndText()
end
function SpeakerUI:RefreshVoiceAndSpeakPanel()
  self:UpdateSpeakerIconAndText()
end
function SpeakerUI:SetSpeakerUIVisible(bVisible)
  if bVisible then
    self:SelfHitTestInvisible()
  else
    self:Collapsed()
  end
end
function SpeakerUI:OnShowSpeakerClick()
  if self.SpeakerFlag then
    self:CloseSpeakerPanel()
  else
    self:ShowSpeakerPanel()
  end
end
function SpeakerUI:OnPreTeamSpeakerChange(_, bIsPreTeamSpeaker)
  self.end
function SpeakerUI:OnSpeakerSettingPanelOpenChange(_, bSpeakerSettingPanelOpen)
  self.SpeakerFlag = bSpeakerSettingPanelOpen
  self:UpdateSpeakerIconAndText()
  self:CheckShowWModeUI(not bSpeakerSettingPanelOpen)
end
function SpeakerUI:ShowSpeakerPanel()
  self.SpeakerFlag = true
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_OR_HIDE_QUICK_EXPRESSION, false)
  UIManager.ShowUI(UIManager.UI_Config_InGame.SpeakerSettingPanel)
  self:CheckShowWModeUI(false)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_OPNE_VOICE_SPEAKER)
end
function SpeakerUI:CloseSpeakerPanel()
  self.SpeakerFlag = false
  if UIManager.UI_Config_InGame.SpeakerSettingPanel then
    UIManager.CloseUI(UIManager.UI_Config_InGame.SpeakerSettingPanel)
  end
  self:CheckShowWModeUI(true)
end
function SpeakerUI:UpdateSpeakerIconAndText(IsShowingPanel)
  if IsShowingPanel == nil then
    IsShowingPanel = self.SpeakerFlag
  end
  print(bWriteLog and "SpeakerUI:UpdateSpeakerIconAndText SpeakerFlag: " .. tostring(self.SpeakerFlag))
  if not self.UIRoot then
    print(bWriteLog and "SpeakerUI:UpdateSpeakerIconAndText UIRoot is nil")
    return
  end
  if IsShowingPanel then
    self.UIRoot.Image_HideVoicePanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_SpeakerStatus:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Image_Voice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Image_VoiceDisabled:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Image_HideVoicePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.TextBlock_SpeakerStatus:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local VoiceSDKInterface = self:GetVoiceSDKInterface()
    if not slua.isValid(VoiceSDKInterface) then
      print(bWriteLog and "SpeakerUI:UpdateSpeakerIconAndText get VoiceSDKInterface failed")
      return
    end
    local VoiceChatSubsystem = SubsystemMgr:Get("VoiceChatSubsystem")
    if VoiceSDKInterface:LbsSpeakerEnable() then
      self.UIRoot.TextBlock_SpeakerStatus:SetText(LocUtil.GetLocalizeResStr(34960))
      self.UIRoot.Image_Voice:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.Image_VoiceDisabled:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      if VoiceChatSubsystem then
        VoiceChatSubsystem:SetVoiceTLogSpeaker(2)
      end
    elseif VoiceSDKInterface:TeamSpeakerEnable() and not VoiceSDKInterface:LbsSpeakerEnable() then
      local SpeakerStatusText = ""
      if self.bIsPreTeamSpeaker then
        SpeakerStatusText = LocUtil.GetLocalizeResStr(49645)
      else
        SpeakerStatusText = LocUtil.GetLocalizeResStr(31037)
      end
      if self:IsInfectionGameMode() then
        SpeakerStatusText = LocUtil.GetLocalizeResStr(7409)
      end
      self.UIRoot.TextBlock_SpeakerStatus:SetText(SpeakerStatusText)
      self.UIRoot.Image_Voice:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.Image_VoiceDisabled:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      if VoiceChatSubsystem then
        VoiceChatSubsystem:SetVoiceTLogSpeaker(1)
      end
    else
      self.UIRoot.TextBlock_SpeakerStatus:SetText("")
      self.UIRoot.Image_Voice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.Image_VoiceDisabled:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if VoiceChatSubsystem then
        VoiceChatSubsystem:SetVoiceTLogSpeaker(0)
      end
    end
  end
end
function SpeakerUI:GetVoiceSDKInterface()
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetGameFrontendHUD():GetVoiceSDKInterface()
end
function SpeakerUI:IsInfectionGameMode()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    return GameState.GameModeType == EGameModeType.EPVEInfectionGameMode
  end
  return false
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, SpeakerUI)