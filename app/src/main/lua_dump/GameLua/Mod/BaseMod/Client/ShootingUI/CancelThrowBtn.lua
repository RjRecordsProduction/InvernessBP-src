local CancelThrowBtn = {}
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
function CancelThrowBtn:ctor(_)
  print(bWriteLog and "CancelThrowBtn:ctor")
end
function CancelThrowBtn:OnInitialize()
  print(bWriteLog and "CancelThrowBtn:OnInitialize")
end
function CancelThrowBtn:RegistEvents()
  print(bWriteLog and "CancelThrowBtn:RegistEvents")
  self:AddUIMessageEvent("UIMsg_UpdateWeaponFuntion", self.UIMsg_UpdateWeaponFuntion, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and not uPlayerController:IsSpectator() then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.HandleUIWhenPlayerOnPlane, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
    self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  end
  self:InitWeaponChangeDel()
  self:AddUIMessageEvent("UIMsg_HideCancelGrenadeBtn", self.HideCancelGrenadeBtn, self)
  self:AddControlEventByControl(self.UIRoot.CancelGrenadeBtn.Button_CancelThrowGrenade, "OnPressed", self.CancelThrow, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_CancelGrenadeCanvas, self, "ShootingUIPanel_MultiLayer_CancelGrenadeCanvas")
end
function CancelThrowBtn:OnPlayerCharacterChange()
  print(bWriteLog and "CancelThrowBtn OnPlayerCharacterChange")
end
function CancelThrowBtn:ResetUIStateAfterRespawn()
  print(bWriteLog and "CancelThrowBtn:ResetUIStateAfterRespawn")
  self:HideCancelGrenadeBtn()
end
function CancelThrowBtn:HandleUIWhenPlayerOnPlane()
  self:ResetUIOnPlane()
end
function CancelThrowBtn:Reconnect_ResetUIByPlayerControllerState()
  print(bWriteLog and "CancelThrowBtn:Reconnect_ResetUIByPlayerControllerState")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and (PlayerController:IsInPlane() or PlayerController:IsInParachute()) then
    self:ResetUIOnPlane()
  end
end
function CancelThrowBtn:ResetUIOnPlane()
  print(bWriteLog and "CancelThrowBtn:ResetUIOnPlane")
  self:HideCancelGrenadeBtn()
end
function CancelThrowBtn:InitWeaponChangeDel()
  local uWeaponMgr = self:GetWeaponMgr()
  if slua.isValid(uWeaponMgr) then
    self:AddControlEventByControl(uWeaponMgr, "ChangeCurrentUsingWeaponDelegate", self.HandleWeaponchange, self)
    local CurrentUsingSlot = uWeaponMgr:GetCurrentUsingPropSlot()
    self:HandleWeaponchange(CurrentUsingSlot)
  end
end
function CancelThrowBtn:CancelThrow()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    local bCancel = OperateSubsystem:CancelThrow()
    if not bCancel then
      self:HideCancelGrenadeBtn()
    end
  end
end
function CancelThrowBtn:ChangeText(nTextID)
  if not self.UIRoot or not self.UIRoot.CancelGrenadeBtn then
    return
  end
  self.UIRoot.CancelGrenadeBtn:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.CancelGrenadeBtn.TextSwitch:SetActiveWidgetIndex(1)
  self.UIRoot.CancelGrenadeBtn.TextCancel:SetText(LocUtil.GetLocalizeResStr(nTextID))
end
function CancelThrowBtn:ChangeIndex(nIndex)
  if not self.UIRoot or not self.UIRoot.CancelGrenadeBtn then
    return
  end
  self.UIRoot.CancelGrenadeBtn.TextSwitch:SetActiveWidgetIndex(nIndex)
end
function CancelThrowBtn:OnUseGrenadeChangeUI(GrenadeID)
  local WeaponManager = self:GetWeaponMgr()
  if not slua.isValid(WeaponManager) then
    return
  end
  local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
  if not slua.isValid(CurWeapon) then
    return
  end
  local ThrowComponent = CurWeapon:GetComponentByClass(import("/Script/ShadowTrackerExtra.ThrowComponent"))
  if not slua.isValid(ThrowComponent) then
    return
  end
  if ThrowComponent.GetThrowState then
    local ThrowState = ThrowComponent:GetThrowState()
    if ThrowState == 1 or ThrowState == 2 then
      self.UIRoot.CancelGrenadeBtn:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function CancelThrowBtn:HideCancelGrenadeBtn()
  print(bWriteLog and "CancelThrowBtn:HideCancelGrenadeBtn")
  self.UIRoot.CancelGrenadeBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function CancelThrowBtn:ShowCancelGrenadeBtn()
  print(bWriteLog and "CancelThrowBtn:ShowCancelGrenadeBtn")
  self.UIRoot.CancelGrenadeBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
function CancelThrowBtn:UIMsg_UpdateWeaponFuntion()
  print(bWriteLog and "CancelThrowBtn:UIMsg_UpdateWeaponFuntion")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  local CurUsingWeaponSlot = OperateSubsystem:GetCurrentUsingPropSlot()
  if CurUsingWeaponSlot ~= ESurviveWeaponPropSlot.SWPS_MeleeWeapon or not self.bMeleeWeaponAllowThrow then
    print(bWriteLog and "AttackThrowSwitchBtn:UpdateWeaponFuntion Customize_ThrowPlus Collapsed")
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "AttackThrowSwitchBtn:UpdateWeaponFuntion Fail not slua.isValid(uPlayerController)")
    return
  end
  local CurrentWeaponFunction = PlayerController.CurrentWeaponFunction
  local EWeaponOperationMode = import("EWeaponOperationMode")
  if PlayerController.CurrentWeaponFunction == EWeaponOperationMode.Throw then
    self:OnUseGrenadeChangeUI(0)
  end
end
function CancelThrowBtn:HandleWeaponchange(Slot)
  local WeaponManager = self:GetWeaponMgr()
  local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
  local bMelee = ESurviveWeaponPropSlot.SWPS_MeleeWeapon
  if slua.isValid(CurWeapon) then
    if bMelee and CurWeapon.IsAllowThrow then
      self.bMeleeWeaponAllowThrow = CurWeapon:IsAllowThrow()
    end
    local CurGrenadeDefineID = CurWeapon:GetItemDefineID()
    self.CurGrenadeID = CurGrenadeDefineID.TypeSpecificID
    self:OnUseGrenadeChangeUI(self.CurGrenadeID)
  end
end
function CancelThrowBtn:GetWeaponMgr()
  if slua.isValid(self.WeaponMgr) then
    return self.WeaponMgr
  else
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local uWeaponMgr = uPlayerCharacter:GetWeaponManager()
      if slua.isValid(uWeaponMgr) then
        self.WeaponMgr = uWeaponMgr
        return uWeaponMgr
      end
    end
  end
  print(bWriteLog and "CancelThrowBtn: Error Get WeaponMgr")
end
function CancelThrowBtn:OnClose()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_CancelGrenadeCanvas)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCancelThrowBtn = class(ui_base, nil, CancelThrowBtn)
return CCancelThrowBtn