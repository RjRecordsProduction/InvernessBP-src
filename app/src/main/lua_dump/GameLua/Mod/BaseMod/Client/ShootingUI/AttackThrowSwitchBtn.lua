local AttackThrowSwitchBtn = {}
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
function AttackThrowSwitchBtn:ctor(_)
  print(bWriteLog and "AttackThrowSwitchBtn:ctor")
  self.WeaponMgr = nil
  self.bMeleeWeaponAllowThrow = false
end
function AttackThrowSwitchBtn:OnInitialize()
  print(bWriteLog and "AttackThrowSwitchBtn:OnInitialize")
end
function AttackThrowSwitchBtn:RegistEvents()
  print(bWriteLog and "AttackThrowSwitchBtn:RegistEvents")
  self:AddUIMessageEvent("UIMsg_UpdateWeaponFuntion", self.UIMsg_UpdateWeaponFuntion, self)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and not uPlayerController:IsSpectator() then
    print(bWriteLog and "AttackThrowSwitchBtn:RegistEvents AddSelfPlayerControllerEvent")
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFighting", self.HandlePlayerEnterFighting, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.HandlePlayerEnterFighting, self)
    self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  end
  self:InitWeaponChangeDel()
  self:AddControlEventByControl(self.UIRoot.Button_ThrowPlus, "OnClicked", self.OnClickThrowPlus, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.Border_Throw, self, "ShootingUIPanel_Border_Throw")
end
function AttackThrowSwitchBtn:OnPlayerCharacterChange()
  print(bWriteLog and "AttackThrowSwitchBtn OnPlayerCharacterChange")
  self.WeaponMgr = nil
  self:InitWeaponChangeDel()
end
function AttackThrowSwitchBtn:HandlePlayerEnterFighting()
  print(bWriteLog and "AttackThrowSwitchBtn ONPlayerEnteringFighting ForceUpdate")
  self:InitWeaponChangeDel()
end
function AttackThrowSwitchBtn:InitWeaponChangeDel()
  local uWeaponMgr = self:GetWeaponMgr()
  if slua.isValid(uWeaponMgr) then
    self:AddControlEventByControl(uWeaponMgr, "ChangeCurrentUsingWeaponDelegate", self.HandleWeaponchange, self)
    local CurrentUsingSlot = uWeaponMgr:GetCurrentUsingPropSlot()
    self:HandleWeaponchange(CurrentUsingSlot)
  end
end
function AttackThrowSwitchBtn:ShowOrHideThrowPlus()
  print(bWriteLog and "AttackThrowSwitchBtn:ShowOrHideThrowPlus")
  local GameState = GameplayData:GetGameState()
  if not slua.isValid(GameState) then
    print(bWriteLog and "AttackThrowSwitchBtn:ShowOrHideThrowPlus not slua.isValid(uGameState)")
    return
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  local CurWeaponSlot = OperateSubsystem:GetCurrentUsingPropSlot()
  local EGameModeType = import("EGameModeType")
  local GameModeType = GameState.GameModeType
  local GameModeState = GameState:GetGameModeState()
  if not self.bMeleeWeaponAllowThrow or GameModeState == "ReadyState" and (GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode) then
    self.UIRoot.Customize_ThrowPlus:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function AttackThrowSwitchBtn:HandleWeaponchange(Slot)
  local WeaponManager = self:GetWeaponMgr()
  local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
  local bMelee = ESurviveWeaponPropSlot.SWPS_MeleeWeapon
  if slua.isValid(CurWeapon) then
    if bMelee and CurWeapon.IsAllowThrow then
      self.bMeleeWeaponAllowThrow = CurWeapon:IsAllowThrow()
    end
    local CurGrenadeDefineID = CurWeapon:GetItemDefineID()
    self.CurGrenadeID = CurGrenadeDefineID.TypeSpecificID
  end
  self:UIMsg_UpdateWeaponFuntion()
  self:ShowOrHideThrowPlus()
end
function AttackThrowSwitchBtn:UIMsg_UpdateWeaponFuntion()
  print(bWriteLog and "AttackThrowSwitchBtn:UIMsg_UpdateWeaponFuntion")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  local CurUsingWeaponSlot = OperateSubsystem:GetCurrentUsingPropSlot()
  if CurUsingWeaponSlot ~= ESurviveWeaponPropSlot.SWPS_MeleeWeapon or not self.bMeleeWeaponAllowThrow then
    self.UIRoot.Customize_ThrowPlus:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
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
  if CurrentWeaponFunction == EWeaponOperationMode.None or CurrentWeaponFunction == EWeaponOperationMode.Shoot or CurrentWeaponFunction == EWeaponOperationMode.Skill then
    self.UIRoot.WidgetSwitcher_Throw:SetActiveWidgetIndex(0)
  elseif PlayerController.CurrentWeaponFunction == EWeaponOperationMode.Throw then
    self.UIRoot.WidgetSwitcher_Throw:SetActiveWidgetIndex(1)
  end
  self.UIRoot.Customize_ThrowPlus:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function AttackThrowSwitchBtn:OnClickThrowPlus()
  print(bWriteLog and "AttackThrowSwitchBtn:OnClickThrowPlus")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "AttackThrowSwitchBtn:OnClickThrowPlus not uPlayerController")
    return
  end
  local EWeaponOperationMode = import("EWeaponOperationMode")
  if PlayerController.CurrentWeaponFunction == EWeaponOperationMode.Skill then
    PlayerController:ChangeWeaponFunction(EWeaponOperationMode.Throw)
  else
    PlayerController:ChangeWeaponFunction(EWeaponOperationMode.Skill)
  end
end
function AttackThrowSwitchBtn:IsPassenger()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    return false
  end
  local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
  if VehicleUserComponent.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_ASPassenger then
    return false
  end
  return true
end
function AttackThrowSwitchBtn:GetVehicleUserComponent()
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    return nil
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return nil
  end
  return VehicleUserComponent
end
function AttackThrowSwitchBtn:GetWeaponMgr()
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
  print(bWriteLog and "AttackThrowSwitchBtn: Error Get WeaponMgr")
end
function AttackThrowSwitchBtn:OnClose()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.Border_Throw)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CAttackThrowSwitchBtn = class(ui_base, nil, AttackThrowSwitchBtn)
return CAttackThrowSwitchBtn