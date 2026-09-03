local ShootAimBtnUI = {}
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local EPawnState = import("EPawnState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
function ShootAimBtnUI:ctor()
  self.RotateViewWithSniperSwitch = false
  self.bRegist3DTouchEvents = false
  self.AimHighLightBrush = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_kaijing_2_png.ZD_icon_kaijing_2_png"
  self.AimNormalBrush = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_kaijing_png.ZD_icon_kaijing_png"
  self.NormalAimMode = true
end
function ShootAimBtnUI:OnInitialize()
  self:InitPlayerControllerVariables()
  self:HandleSightMirror()
end
function ShootAimBtnUI:RegistEvents()
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  self:AddUIMessageEvent("UIMsg_SwitchAimMode", self.UIMsg_SwitchAimMode, self)
  self:AddUIMessageEvent("UIMSG_HightLightAimBtn", self.UIMSG_HightLightAimBtn, self)
  self:AddUIMessageEvent("UIMSG_NormalAimBtn", self.UIMSG_NormalAimBtn, self)
  self:AddControlEventByControl(self.UIRoot.MultiButton_ShootAim, "OnMouseButtonDownEvent", self.OnShootAimBtnPressDown, self)
  self:AddControlEventByControl(self.UIRoot.MultiButton_ShootAim, "OnHoldEnded", self.OnShootAimBtnHoldEnded, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_AimCanvas, self, "ShootingUIPanel_MultiLayer_AimCanvas")
  self:AddSettingOptionEvent("RotateViewWithSniperSwitch", function(RotateViewWithSniperSwitch)
    self.  end, true)
  self:AddSettingOptionEvent("OpenMirrorMode", function(OpenMirrorMode)
    self.UIRoot.MultiButton_ShootAim.ButtonType = OpenMirrorMode
  end, true)
end
function ShootAimBtnUI:OnPostInitialize()
end
function ShootAimBtnUI:OnClose()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_AimCanvas)
end
function ShootAimBtnUI:GameAssistantHideUI()
  self.UIRoot.Border_AimBtn:SetContentColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 0.01))
end
function ShootAimBtnUI:ResetUIStateAfterRespawn()
  self:UIMSG_NormalAimBtn()
end
function ShootAimBtnUI:OnShootAimBtnPressDown(MyGeometry, MouseEvent)
  local UKismetInputLibrary = import("KismetInputLibrary")
  local PointerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(MouseEvent)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:OnAimBtnPressDown(PointerIndex, MouseEvent, self.RotateViewWithSniperSwitch)
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:HideBuffList()
  end
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.Aim, 1)
  end
end
function ShootAimBtnUI:OnScopeStateChanged(AimMode, bIsTouchBegin, PointerIndex)
  self.UIRoot.MultiButton_ShootAim.ButtonType = AimMode
  self.ShotAimPointerIndex = bIsTouchBegin and PointerIndex or nil
end
function ShootAimBtnUI:OnShootAimBtnHoldEnded()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:OnAimBtnHoldEnded(self.ShotAimPointerIndex)
  end
end
function ShootAimBtnUI:OnHoldOpenShootAim(FingerIndex)
  print(bWriteLog and "ShootAimBtnUI:OnHoldOpenShootAim")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:OpenShootAim(FingerIndex, false, true)
  end
end
function ShootAimBtnUI:InitPlayerControllerVariables()
  print(bWriteLog and "ShootAimBtnUI:InitPlayerControllerVariables")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootAimBtnUI:InitPlayerControllerVariables not slua.isValid(uPlayerController)")
    return
  end
  local Slot = self.UIRoot.ShootAimBtn.Slot
  if not Slot then
    return
  end
  local ViewportX, ViewportY = 0, 0
  ViewportX, ViewportY = PlayerController:GetViewportSize(0, 0)
  local Pos = Slot:GetPosition()
  PlayerController.AimBtnPos = FVector2D(Pos.X + ViewportX, Pos.Y + ViewportY - 44)
  PlayerController.AimBtnSize = Slot:GetSize()
end
function ShootAimBtnUI:UIMsg_SwitchAimMode()
  self.NormalAimMode = not self.NormalAimMode
end
function ShootAimBtnUI:UIMSG_HightLightAimBtn()
  self.UIRoot.Image_AimTrigger:SetBrushFromPathAsync(self.AimHighLightBrush, false)
end
function ShootAimBtnUI:UIMSG_NormalAimBtn()
  self.UIRoot.Image_AimTrigger:SetBrushFromPathAsync(self.AimNormalBrush, false)
end
function ShootAimBtnUI:OnReleaseAngledSightBtn(FingerIndex)
  print(bWriteLog and "ShootAimBtnUI:OnReleaseAngledSightBtn")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootAimBtnUI:OnReleaseAngledSightBtn Fail not slua.isValid(uPlayerController)")
    return
  end
  if PlayerController.SensibilityConfig.SideMirrorModeC == 2 then
    print(bWriteLog and "ShootAimBtnUI:OnReleaseAngledSightBtn uPlayerController.SensibilityConfig.SideMirrorModeC  == 2")
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) or not PlayerCharacter.DoAngledSight then
    print(bWriteLog and "ShootAimBtnUI:OnReleaseAngledSightBtn not slua.isValid(uPlayerCharacter)")
    return
  end
  PlayerCharacter:DoAngledSight(false)
end
function ShootAimBtnUI:HandleSightMirror()
  print(bWriteLog and "ShootingUIPanelUIBase:HandleSightMirror")
  self:AddSettingOptionEvent("SideMirrorMode", function(SideMirrorMode)
    print(bWriteLog and "ShootingUIPanelUIBase:HandleSightMirror SideMirrorMode=" .. SideMirrorMode)
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) and slua.isValid(PlayerCharacter.FPPComponent) then
      self:ConditionRefreshAngledSightState(PlayerCharacter, SideMirrorMode)
      PlayerCharacter:ShowAngledSightState(PlayerCharacter.FPPComponent:IsAngledSight())
    end
  end)
end
function ShootAimBtnUI:ConditionRefreshAngledSightState(PlayerCharacter, SideMirrorMode)
  print(bWriteLog and "ShootAimBtnUI:ConditionRefreshAngledSightState")
  if slua.isValid(PlayerCharacter) and PlayerCharacter.FPPComponent:IsAngledSight() and not PlayerCharacter.bIsGunADS and SideMirrorMode == 1 then
    PlayerCharacter:DoAngledSight(false)
  end
end
function ShootAimBtnUI:VehicleWeaponEnableScope(CurWeaponSlot, WeaponManager)
  if CurWeaponSlot == ESurviveWeaponPropSlot.SWPS_VehicleWeapon then
    local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
    if not slua.isValid(CurWeapon) then
      return true
    end
    if not CurWeapon.GetShootWeaponEntityComponent then
      return true
    end
    local WeaponComponent = CurWeapon:GetShootWeaponEntityComponent()
    if not slua.isValid(WeaponComponent) then
      return true
    end
    return WeaponComponent.bEnableScopeIn
  else
    local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
    if not slua.isValid(CurWeapon) then
      return true
    end
    if not CurWeapon.GetShootWeaponEntityComponent then
      return true
    end
    if not CurWeapon.bIsPistol then
      return true
    end
    local WeaponComponent = CurWeapon:GetShootWeaponEntityComponent()
    if not slua.isValid(WeaponComponent) then
      return true
    end
    return WeaponComponent.bEnableScopeIn
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CShootAimBtnUI = class(ui_base, nil, ShootAimBtnUI)
return CShootAimBtnUI