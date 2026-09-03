local MicrophoneButton = {}
local KismetInputLibrary = import("KismetInputLibrary")
local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
local Collapsed = UEnums.ESlateVisibility.Collapsed
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local EMicMode = logic_chat_voice_const.Enum_InGameMicMode
local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
local PTTOpenDelay = 0.5
local PTTCloseDelay = 0.2
function MicrophoneButton:ctor()
  self.isInterphoneActive = false
  self.PressedShowMicrophoneTimer = nil
  self.ReleasedShowMicrophoneTimer = nil
  self.TLog_MicphoneIns = nil
  self.TLog_MicrophoneTimeStamp = 0.0
  self.TLog_MircophoneIndex = 0
  self.TLog_InterphoneIndex = 0
  self.InterphoneTimeStamp = 0.0
  self.IsInInterphone = false
  self.bForbidMic_EU = false
end
function MicrophoneButton:OnInitialize()
  print(bWriteLog and "MicrophoneButton:Initialize")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    self:AttachToPanel(MainControlBaseUI.CanvasPanel_ZTK)
    self:SetAnchors(0, 0, 1, 1)
    self:SetOffsets(0, 0, 0, 0)
  end
  self:RefreshMicphoneStatus()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  if logic_chat_voice:CheckEUChatRestriction() then
    self.bForbidMic_EU = true
  end
  self.UIConfig_PTTPanel = UIManager.UI_Config_InGame.PTTPanel
  if LobbySystem.roleData and LobbySystem.roleData.region_info and LobbySystem.roleData.region_info.push_to_talk_switch == 0 then
    self.UIConfig_PTTPanel = UIManager.UI_Config_InGame.PTTPanel_Simple
  end
end
function MicrophoneButton:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.Border_Touch, "OnMouseButtonDownEvent", self.OnTouchStart, self)
  self:AddControlEventByControl(self.UIRoot.Border_Touch, "OnMouseButtonUpEvent", self.OnTouchEnd, self)
  self:AddControlEventByControl(self.UIRoot.Border_Touch, "OnMouseMoveEvent", self.OnTouchMove, self)
  local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot, self, "MainControlBaseUI_CanvasPanel_Micphone")
  self:RegistDataListeners()
  EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_REGIST_ATTACH_PANEL, self.UIRoot.CanvasPanel_MicrophoneGuide)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_VOICE_AND_SPEAK_CHANGE, function()
    self:UpdateMicphoneIconAndText()
    self:HideAllMicFx()
  end)
  self:AddCommonEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_FORBID_VOICE, function(_, __, bIsForbid)
    self:OnForbidVoice(bIsForbid)
  end)
end
function MicrophoneButton:OnClose()
  local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot)
  self:RemoveAllGameTimer()
  self:RemoveAllDataListener()
end
function MicrophoneButton:RegistDataListeners()
  self._DelayRegister = self:AddGameTimer(0, true, function()
    local VoiceChatSubsytem = SubsystemMgr:Get("VoiceChatSubsystem")
    if VoiceChatSubsytem then
      local VoiceChatSPData = VoiceChatSubsytem:GetSuperData()
      self:AddDataListener(VoiceChatSPData, "bMicphoneSettingPanelOpen", self.OnMicphonePanelChange, self)
      self:AddDataListener(VoiceChatSPData, "MicMode", self.RefreshMicIconByMode, self)
      self.VoiceChatSPData = VoiceChatSubsytem:GetSuperData()
      self:RefreshMicIconByMode()
      self:RemoveGameTimer(self._DelayRegister)
      self._DelayRegister = 0
    end
  end)
end
function MicrophoneButton:OnMicphonePanelChange()
  self:UpdateMicphoneIconAndText()
end
function MicrophoneButton:RefreshMicIconByMode()
  local MicMode = self.VoiceChatSPData and self.VoiceChatSPData.MicMode or EMicMode.OFF
  local MicType = EMicMode.GetMicType(MicMode)
  if MicType == EMicMode.OpenMic then
    self.UIRoot.Image_Icon:SetBrushFromSoftObjectPathAsync(self.UIRoot.SOP_MicON, false)
  elseif MicType == EMicMode.PTT then
    self.UIRoot.Image_Icon:SetBrushFromSoftObjectPathAsync(self.UIRoot.SOP_PTT, false)
  else
    self.UIRoot.Image_Icon:SetBrushFromSoftObjectPathAsync(self.UIRoot.SOP_MicOFF, false)
  end
  self:UpdateMicTLogIndices(MicMode, MicType)
end
function MicrophoneButton:UpdateMicTLogIndices(MicMode, MicType)
  if MicType == EMicMode.PTT then
    self:SetVoiceTLogMicrophone(0)
    local ChannelMode = EMicMode.GetChannelMode(MicMode)
    if ChannelMode == EMicMode.ALL then
      self.TLog_InterphoneIndex = 2
    elseif ChannelMode == EMicMode.Team or ChannelMode == EMicMode.PreTeam then
      self.TLog_InterphoneIndex = 1
    else
      self.TLog_InterphoneIndex = 0
    end
  else
    local ChannelMode = EMicMode.GetChannelMode(MicMode)
    if ChannelMode == EMicMode.ALL then
      self:SetVoiceTLogMicrophone(2)
    elseif ChannelMode == EMicMode.Team or ChannelMode == EMicMode.PreTeam then
      self:SetVoiceTLogMicrophone(1)
    else
      self:SetVoiceTLogMicrophone(0)
    end
  end
end
function MicrophoneButton:OnTouchStart()
  self.bPressed = true
  if self.bForbidMic_EU then
    ShowNotice(46880037)
  elseif not self:CheckPrivacyAccepted() then
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:RequestPrivacy()
  elseif self.PressedShowMicrophoneTimer then
    self:RemoveGameTimer(self.PressedShowMicrophoneTimer)
    self.PressedShowMicrophoneTimer = nil
  else
    self:ClosePTTPanel()
    self.PressedShowMicrophoneTimer = self:AddGameTimer(PTTOpenDelay, false, function()
      self.PressedShowMicrophoneTimer = nil
      if self.bPressed and EMicMode.GetMicType(self.VoiceChatSPData.MicMode) == EMicMode.PTT then
        self:ShowPTTPanel()
        self.isInterphoneActive = true
        self:SetVoiceTLogInterphone(true)
      end
    end)
  end
  local Handled = WidgetBlueprintLibrary.Handled()
  local Handled = WidgetBlueprintLibrary.CaptureMouse(Handled, self.UIRoot.Border_Touch)
  return Handled
end
function MicrophoneButton:OnTouchEnd()
  self.bPressed = false
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_MIC_BUTTON_TOUCH_END)
  if self.isInterphoneActive then
    self.ReleasedShowMicrophoneTimer = self:AddGameTimer(PTTCloseDelay, false, function()
      self:ClosePTTPanel()
    end)
  elseif self.PressedShowMicrophoneTimer then
    self:RemoveGameTimer(self.PressedShowMicrophoneTimer)
    self.PressedShowMicrophoneTimer = nil
    if UIManager.IsUIShow(UIManager.UI_Config_InGame.MicphoneSettingPanel) then
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CLOSE_SPEAKER_PANEL)
      self:CloseMicphonePanel()
    else
      ClientTLogUtil.ReportGeneralCountByBRPhase(12017, 12017)
      self:ShowMicphonePanel()
    end
  end
  local Handled = WidgetBlueprintLibrary.Handled()
  local Handled = WidgetBlueprintLibrary.ReleaseMouseCapture(Handled, self.UIRoot.Border_Touch)
  return Handled
end
function MicrophoneButton:OnTouchMove(InGeometry, MouseEvent)
  if self.isInterphoneActive and self._PTTPanel then
    local Delta = KismetInputLibrary.PointerEvent_GetCursorDelta(MouseEvent)
    self._PTTPanel:MoveCursor(Delta)
  end
  local Handled = WidgetBlueprintLibrary.Unhandled()
  return Handled
end
function MicrophoneButton:CloseMicphonePanel()
  if UIManager.UI_Config_InGame.MicphoneSettingPanel then
    UIManager.CloseUI(UIManager.UI_Config_InGame.MicphoneSettingPanel)
  end
end
function MicrophoneButton:ShowMicphonePanel()
  if self.isInterphoneActive then
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_OR_HIDE_QUICK_EXPRESSION, false)
  self:CreateChildWindow(self.UIRoot.CanvasPanel_Micphone_Socket, UIManager.UI_Config_InGame.MicphoneSettingPanel)
end
function MicrophoneButton:ShowPTTPanel()
  self._PTTPanel = self:CreateChildWindow(self.UIRoot.CanvasPanel_Micphone_Socket, self.UIConfig_PTTPanel)
end
function MicrophoneButton:ClosePTTPanel()
  if self.ReleasedShowMicrophoneTimer then
    self:RemoveGameTimer(self.ReleasedShowMicrophoneTimer)
  end
  self.ReleasedShowMicrophoneTimer = nil
  if self._PTTPanel then
    self._PTTPanel = nil
    UIManager.HideUI(self.UIConfig_PTTPanel)
  end
  self.isInterphoneActive = false
  self:SetVoiceTLogInterphone(false)
end
function MicrophoneButton:ShowSTTResult(...)
  self:CreateChildWindow(self.UIRoot.CanvasPanel_Micphone_Socket, UIManager.UI_Config_InGame.STTResultPanel, ...)
end
function MicrophoneButton:RefreshMicphoneStatus()
  self:CloseMicphonePanel()
  self:UpdateMicphoneIconAndText()
  self:HideAllMicFx()
end
function MicrophoneButton:UpdateMicphoneIconAndText(IsShowingPanel)
  if IsShowingPanel == nil then
    IsShowingPanel = UIManager.IsUIShow(UIManager.UI_Config_InGame.MicphoneSettingPanel)
  end
  print(bWriteLog and "MicrophoneButton:UpdateMicphoneIconAndText IsShowingPanel: " .. tostring(IsShowingPanel))
  if IsShowingPanel then
    self.UIRoot.Image_Icon:SetBrushFromSoftObjectPathAsync(self.UIRoot.SOP_Close, false)
    self.UIRoot.Image_Icon:SetRenderScale(FVector2D(0.7, 0.7))
    self.UIRoot.TextBlock_Microphonestatus:SetWidgetVisibility(Collapsed)
  else
    self.UIRoot.Image_Icon:SetRenderScale(FVector2D(1, 1))
    EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_MIC_BUTTON_SHOW)
    self.UIRoot.TextBlock_Microphonestatus:SetWidgetVisibility(SelfHitTestInvisible)
    self:RefreshMicIconByMode()
  end
end
function MicrophoneButton:HideAllMicFx()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_HIDE_ALL_MIC_FX)
end
function MicrophoneButton:RefreshVoicePanel()
  self:UpdateMicphoneIconAndText()
  self:HideAllMicFx()
end
function MicrophoneButton:SetVoiceTLogMicrophone(SetIndex)
  if SetIndex == self.TLog_MircophoneIndex then
    return
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    return
  end
  local CurrentTime = GameState:GetServerWorldTimeSeconds()
  local DeltaTime = CurrentTime - self.TLog_MicrophoneTimeStamp
  if self.TLog_MircophoneIndex == 1 and PlayerState.TeammateMicrophoneTime then
    PlayerState.TeammateMicrophoneTime = PlayerState.TeammateMicrophoneTime + DeltaTime
    self:RecordMicphoneTlogToServer()
  elseif self.TLog_MircophoneIndex == 2 and PlayerState.EnemyMicrophoneTime then
    PlayerState.EnemyMicrophoneTime = PlayerState.EnemyMicrophoneTime + DeltaTime
    self:RecordMicphoneTlogToServer()
  end
  self.TLog_MircophoneIndex = SetIndex
  self.TLog_MicrophoneTimeStamp = CurrentTime
end
function MicrophoneButton:RecordMicphoneTlogToServer()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.TeammateMicrophoneTime then
    return
  end
  if not slua.isValid(self.TLog_MicphoneIns) then
    local TLog_Micphone = import("TLog_Micphone")
    self.TLog_MicphoneIns = TLog_Micphone()
  end
  self.TLog_MicphoneIns.TeammateMicrophoneTime = PlayerState.TeammateMicrophoneTime and PlayerState.TeammateMicrophoneTime or self.TLog_MicphoneIns.TeammateMicrophoneTime
  self.TLog_MicphoneIns.TeammateSpeakerTime = PlayerState.TeammateSpeakerTime and PlayerState.TeammateSpeakerTime or self.TLog_MicphoneIns.TeammateSpeakerTime
  self.TLog_MicphoneIns.EnemyMicrophoneTime = PlayerState.EnemyMicrophoneTime and PlayerState.EnemyMicrophoneTime or self.TLog_MicphoneIns.EnemyMicrophoneTime
  self.TLog_MicphoneIns.EnemySpeakerTime = PlayerState.EnemySpeakerTime and PlayerState.EnemySpeakerTime or self.TLog_MicphoneIns.EnemySpeakerTime
  self.TLog_MicphoneIns.TeammateInterphoneTime = PlayerState.TeammateInterphoneTime and PlayerState.TeammateInterphoneTime or self.TLog_MicphoneIns.TeammateInterphoneTime
  self.TLog_MicphoneIns.EnemyInterphoneTime = PlayerState.EnemyInterphoneTime and PlayerState.EnemyInterphoneTime or self.TLog_MicphoneIns.EnemyInterphoneTime
  PlayerController:RPC_Server_SetMicphoneTLogToServer(self.TLog_MicphoneIns)
end
function MicrophoneButton:SetVoiceTLogInterphone(IsBegin)
  if IsBegin or self.IsInInterphone then
    local GameState = GameplayData.GetGameState()
    if slua.isValid(GameState) then
      local PlayerState = GameplayData.GetPlayerState()
      if slua.isValid(PlayerState) then
        if IsBegin then
          self.InterphoneTimeStamp = GameState:GetServerWorldTimeSeconds()
          self.IsInInterphone = true
        else
          local ReturnValue_2 = GameState:GetServerWorldTimeSeconds() - self.InterphoneTimeStamp
          if self.TLog_InterphoneIndex == 1 and PlayerState.TeammateInterphoneTime then
            PlayerState.TeammateInterphoneTime = ReturnValue_2 + PlayerState.TeammateInterphoneTime
            self.IsInInterphone = false
            self:RecordMicphoneTlogToServer()
          elseif self.TLog_InterphoneIndex == 2 and PlayerState.EnemyInterphoneTime then
            PlayerState.EnemyInterphoneTime = ReturnValue_2 + PlayerState.EnemyInterphoneTime
            self.IsInInterphone = false
            self:RecordMicphoneTlogToServer()
          end
        end
      end
    end
  end
end
function MicrophoneButton:CheckPrivacyAccepted()
  if Client.IsEditor() then
    return true
  end
  if slua_GameFrontendHUD.FirstVoicePopupSwitch then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    return SettingConfig.ChatPrivacyAcceptedVersion == Client.GetAppVersion()
  else
    return true
  end
end
function MicrophoneButton:OnForbidVoice(bIsForbid)
  print(bWriteLog and "MicrophoneButton:OnForbidVoice " .. tostring(bIsForbid))
  if bIsForbid then
    local BanMacro = require("client.slua.config.ClientMacros.BanMacro")
    self.VoiceForbidBtn = self:CreateChildWindow(self.UIRoot.CanvasPanel_Micphone, UIManager.UI_Config_InGame.VoiceForbidBtn, BanMacro.PLAYER_BAN_NO_VOICE)
    if self.VoiceForbidBtn then
      self.VoiceForbidBtn:SetAnchors(0.5, 0.5, 0.5, 0.5)
      self.VoiceForbidBtn:SetOffsets(0, 0, 38, 38)
      self.VoiceForbidBtn:SetAlignment(0.5, 0.5)
    end
    self.UIRoot.Border_Touch:SetWidgetVisibility(Collapsed)
    local VoiceChatSubsytem = SubsystemMgr:Get("VoiceChatSubsystem")
    if VoiceChatSubsytem then
      VoiceChatSubsytem:SwitchMicMode(0)
    end
  else
    if self.VoiceForbidBtn then
      self.VoiceForbidBtn:Close()
      self.VoiceForbidBtn = nil
    end
    self.UIRoot.Border_Touch:SetWidgetVisibility(SelfHitTestInvisible)
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, MicrophoneButton)