local VirtualJoystickProxy = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UIBPFunctionLibrary = import("UIBPFunctionLibrary")
local UGameplayStatics = import("GameplayStatics")
function VirtualJoystickProxy:OnInitialize()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    self:AttachToPanel(MainControlBaseUI.CanvasPanel_0)
    self:SetAnchors(0, 0, 1, 1)
    self:SetOffsets(0, 0, 0, 0)
  end
end
function VirtualJoystickProxy:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.CustomPanel_Joystick, "OnCustomLayoutChangeEvent", self.OnCustomLayoutChangeEvent, self)
  self:AddControlEventByControl(self.UIRoot.CanvasPanel_RunState, "OnCustomLayoutChangeEvent", self.OnCustomLayoutChangeEvent, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_JOYSTICK, self.UpdateJoystickTransform, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_VIEWPORT_SIZE_CHANGED, self.UpdateJoystickTransform, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_QUICK_TWEAK_LAYOUT_STATE, function(_, __, bQuickTweakLayout)
    local PlayerController = self:GetPlayerControllerCompatible()
    if slua.isValid(PlayerController) then
      if bQuickTweakLayout then
        if PlayerController:GetJoystickVisibility() and not UIManager.IsUIShow(UIManager.UI_Config_InGame.VehicleControlUISteering) then
          self:SetWidgetVisible(self.UIRoot.Overlay_Joystick, true)
        end
        PlayerController:LuaHideJoystickWithTag("QuickTweak_CustomLayout")
      else
        self:SetWidgetVisible(self.UIRoot.Overlay_Joystick, false)
        PlayerController:LuaShowJoystickWithTag("QuickTweak_CustomLayout")
      end
    end
  end)
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
function VirtualJoystickProxy:OnShow()
  self:OnCustomLayoutChangeEvent()
end
function VirtualJoystickProxy:OnCustomLayoutChangeEvent()
  local PlayerController = self:GetPlayerControllerCompatible()
  if not slua.isValid(PlayerController) then
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_INGAME_ON_SET_CUSTOMIZE_UIINFO)
  self:SetSprintTriggerLength()
  self:UpdateJoystickTransform()
end
function VirtualJoystickProxy:SetSprintTriggerLength()
  local PlayerController = self:GetPlayerControllerCompatible()
  if slua.isValid(PlayerController) then
    local RushTriggerLength
    local CustomLayoutModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CustomLayoutModule)
    local ST_LayoutDetail = CustomLayoutModule:GetLayoutDetailByType(30)
    if ST_LayoutDetail then
      if ST_LayoutDetail.RelativePos.X == 0 then
        RushTriggerLength = ST_LayoutDetail.RelativePos.Y
      else
        local Layout_Joystick = self.UIRoot.CustomPanel_Joystick:GetLayoutData()
        RushTriggerLength = Layout_Joystick.RelativePos.Y - ST_LayoutDetail.RelativePos.Y
      end
    else
      RushTriggerLength = 300
    end
    PlayerController.JoystickSprintBtnHeight = RushTriggerLength
  end
end
function VirtualJoystickProxy:UpdateJoystickTransform()
  local PlayerController = self:GetPlayerControllerCompatible()
  if not slua.isValid(PlayerController) then
    return
  end
  print(bWriteLog and "VirtualJoystickProxy:UpdateJoystickTransform")
  local UIUtil = require("client.common.ui_util")
  local ScreenPadding = UIUtil.GetScreenPadding()
  local ViewportSizebyScale = UIUtil.GetViewportSizebyScale()
  local Layout_Joystick = self.UIRoot.CustomPanel_Joystick:GetLayoutData()
  local ViewportCenter = FVector2D(ScreenPadding.Left / ViewportSizebyScale.X, ScreenPadding.Top / ViewportSizebyScale.Y)
  local CalculatedRatio = Layout_Joystick.RelativePos / ViewportSizebyScale + Layout_Joystick.AnchorType.Minimum
  PlayerController:SetJoyStickCenter(CalculatedRatio + ViewportCenter)
  PlayerController:SetJoyStickOpacity(Layout_Joystick.Opacity)
  PlayerController:SetJoyStickScale(Layout_Joystick.Scale)
  PlayerController:MakeFireModeEffect()
  local TransparentUIModeSubsystem = SubsystemMgr:Get("TransparentUIModeSubsystem")
  if not TransparentUIModeSubsystem then
    print(bWriteLog and "VirtualJoystickProxy:ResetJoystickWidgetRender - TransparentUIModeSubsystem is nil")
    return
  end
  local bIsOpen = TransparentUIModeSubsystem:GetIsHideUIFunctionOpen()
  local EWidgetVisible = import("EWidgetVisible")
  if bIsOpen and not TransparentUIModeSubsystem.IsShow then
    PlayerController:SetVirtualJoystickWidgetRender(EWidgetVisible.ForceNotVisible)
  else
    PlayerController:SetVirtualJoystickWidgetRender(EWidgetVisible.Default)
  end
end
function VirtualJoystickProxy:UIMsg_JoyStickTriggerSprint()
  local PlayerController = self:GetPlayerControllerCompatible()
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
function VirtualJoystickProxy:UIMsg_UpdateStandCrouchAndSprint()
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
function VirtualJoystickProxy:ResetUIStateAfterRespawn()
  self:SetAutoSprintUI(false)
  local PlayerController = self:GetPlayerControllerCompatible()
  if slua.isValid(PlayerController) then
    PlayerController:SetVirtualStickAutoSprintStatus(false)
  end
end
function VirtualJoystickProxy:AutoSprintActive()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local EPawnState = import("EPawnState")
    if PlayerCharacter:HasState(EPawnState.Sprint) then
      local PlayerController = self:GetPlayerControllerCompatible()
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
function VirtualJoystickProxy:AutoSprintActiveForVehicle()
  local PlayerController = self:GetPlayerControllerCompatible()
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
function VirtualJoystickProxy:SetAutoSprintUI(AutoSprint)
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
function VirtualJoystickProxy:OnShowAutoSprintButton(Visible, ShowPos, Inside)
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
  local UIUtil = require("client.common.ui_util")
  local ScreenMargin = UIUtil.GetScreenPadding()
  local FinalTranslation = ScreenMargin and FVector2D(ShowPos.X - ScreenMargin.Left, ShowPos.Y - ScreenMargin.Top) or ShowPos
  self.UIRoot.CanvasPanel_RunState:SetRenderTranslation(FinalTranslation)
end
function VirtualJoystickProxy:GetPlayerControllerCompatible()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) and GameStatus.IsInMainCity() then
    PlayerController = UGameplayStatics.GetPlayerController(self.UIRoot, 0)
  end
  return PlayerController
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, VirtualJoystickProxy)