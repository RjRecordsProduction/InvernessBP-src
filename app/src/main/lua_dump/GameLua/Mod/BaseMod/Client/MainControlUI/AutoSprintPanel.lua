local AutoSprintPanel = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function AutoSprintPanel:RegistEvents()
  self:AddUIMessageEvent("UIMsg_JoyStickTriggerSprint", self.UIMsg_JoyStickTriggerSprint, self)
  self:AddUIMessageEvent("UIMsg_UpdateStandCrouchAndSprint", self.UIMsg_UpdateStandCrouchAndSprint, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_SPECTATING_UI, self.Collapsed, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_COMPLETE_PLAYBACK_UI, self.Collapsed, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_ENTER_WONDERFUL, self.Collapsed, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnAutoSprintActive", self.AutoSprintActive, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnAutoSprintActiveForVehicle", self.AutoSprintActiveForVehicle, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnShowAutoSprintButton", self.OnShowAutoSprintButton, self)
end
function AutoSprintPanel:UIMsg_JoyStickTriggerSprint()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if not PlayerController.IsJoystickTriggerSprint or not PlayerController.bAutoSprint then
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local PoseState = PlayerCharacter.PoseState
  local ESTEPoseState = import("ESTEPoseState")
  if PoseState == ESTEPoseState.Sprint or PoseState == ESTEPoseState.CrouchSprint or PoseState == ESTEPoseState.SwimSprint then
    PlayerController:SetVirtualStickAutoSprintStatus(true)
    self:SetAutoSprintUI(true)
  end
end
function AutoSprintPanel:UIMsg_UpdateStandCrouchAndSprint()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local PoseState = PlayerCharacter.PoseState
  local ESTEPoseState = import("ESTEPoseState")
  if PoseState == ESTEPoseState.Stand or PoseState == ESTEPoseState.Crouch or PoseState == ESTEPoseState.Prone then
    self:SetAutoSprintUI(false)
  end
end
function AutoSprintPanel:ResetUIStateAfterRespawn()
  self:SetAutoSprintUI(false)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:SetVirtualStickAutoSprintStatus(false)
  end
end
function AutoSprintPanel:AutoSprintActive()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local EPawnState = import("EPawnState")
    if PlayerCharacter:HasState(EPawnState.Sprint) then
      local PlayerController = GameplayData.GetPlayerController()
      if slua.isValid(PlayerController) then
        PlayerController.bAutoSprint = true
        self:SetAutoSprintUI(true)
        PlayerController:SetVirtualStickAutoSprintStatus(true)
      end
    else
      print(bWriteLog and "OnAutoSprintActive Error : Character Has State Sprint Failed")
    end
  end
end
function AutoSprintPanel:AutoSprintActiveForVehicle()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "OnAutoSprintActiveForVehicle Error : PlayerController is nil")
    return
  end
  if slua.isValid(PlayerController) and PlayerController.bVehicleCanAutoMove then
    self:SetAutoSprintUI(true)
    PlayerController:SetVirtualStickAutoSprintStatus(true)
  else
    self:SetAutoSprintUI(false)
    PlayerController:SetVirtualStickAutoSprintStatus(false)
  end
end
function AutoSprintPanel:SetAutoSprintUI(AutoSprint)
  if self.CacheCurrentAutoSprint == AutoSprint then
    return
  end
  print(bWriteLog and "MainControlBaseUI:AutoSprintActive AutoSprint:" .. tostring(AutoSprint))
  self.CacheCurrent  if AutoSprint then
    self:SelfHitTestInvisible()
    self.UIRoot.CanvasPanel_AutoNavigate:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_Sprinting:SetText(LocUtil.GetLocalizeResStr(64657))
  else
    self.UIRoot.CanvasPanel_AutoNavigate:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function AutoSprintPanel:OnShowAutoSprintButton(Visible, ShowPos, Inside)
  if Inside then
    self.UIRoot.TextBlock_KeepSprint:SetText(LocUtil.GetLocalizeResStr(81577))
    self.UIRoot.WidgetSwitcher_Run:SetActiveWidgetIndex(1)
    self:PlayUserWidgetAnimation(self.UIRoot.DX_RunLock, 0, 1, 0, 1)
  else
    self.UIRoot.TextBlock_KeepSprint:SetText(LocUtil.GetLocalizeResStr(81577))
    self.UIRoot.WidgetSwitcher_Run:SetActiveWidgetIndex(0)
  end
  if Visible then
    self.UIRoot.CanvasPanel_RunState:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if not self.UIRoot.CanvasPanel_ArrowVfxGroup:IsVisible() then
      self.UIRoot.CanvasPanel_ArrowVfxGroup:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    self:PlayUserWidgetAnimation(self.UIRoot.DX_Arrow, 0, 3, 0, 1)
  else
    self.UIRoot.CanvasPanel_RunState:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_ArrowVfxGroup:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local ScreenMargin
  local UIBPFunctionLibrary = import("UIBPFunctionLibrary")
  if slua.isValid(UIBPFunctionLibrary) then
    ScreenMargin = UIBPFunctionLibrary.GetUIRectOffset()
  end
  local FinalTranslation = ScreenMargin and FVector2D(ShowPos.X - ScreenMargin.Left, ShowPos.Y - ScreenMargin.Top) or ShowPos
  self.UIRoot.CanvasPanel_RunState:SetRenderTranslation(FinalTranslation)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
function AutoSprintPanel:OnClose()
  print(bWriteLog and "AutoSprintPanel:OnClose")
  AutoSprintPanel.__super.OnClose(self)
end
return class(ui_base, nil, AutoSprintPanel)