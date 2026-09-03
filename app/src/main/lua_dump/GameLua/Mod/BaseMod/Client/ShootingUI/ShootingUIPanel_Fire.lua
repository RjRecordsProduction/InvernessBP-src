local EPawnState = import("EPawnState")
local ETouchIndex = import("ETouchIndex")
local ESTEScopeType = import("ESTEScopeType")
local UBackpackUtils = import("BackpackUtils")
local ETouchFireType = import("ETouchFireType")
local EPlayerCameraMode = import("EPlayerCameraMode")
local EReleaseToFireType = import("EReleaseToFireType")
local UKismetInputLibrary = import("KismetInputLibrary")
local ESTEWeaponShootType = import("ESTEWeaponShootType")
local EWeaponTriggerEvent = import("EWeaponTriggerEvent")
local ECurPlayerHandStatus = UEnums.ECurPlayerHandStatus
local EWeaponOperationMode = import("EWeaponOperationMode")
local EShootWeaponShootMode = import("EShootWeaponShootMode")
local UWidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
local UGameplayStatics = import("GameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ShootingUIPanelIMP = require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanelIMP")
local CustomType = require("client.logic.setting.CustomType")
local Fire_HighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_kaihuo_1_png.ZD_icon_kaihuo_1_png"
function ShootingUIPanelIMP:RegistEvents_Fire()
  print(bWriteLog and "ShootingUIPanelUIBase:RegistEvents_Fire")
  self:AddControlEventByControl(self.UIRoot.CancelFireBtn_Rside, "OnReleased", self.OnReleasedCancelFire, self)
  self:AddControlEventByControl(self.UIRoot.CancelReleaseFireBtn, "OnReleased", self.OnReleasedCancelFire, self)
  self:AddControlEventByControl(self.UIRoot.OnFireBtn_ReleaseBtn, "OnReleased", self.OnReleasedFire, self, true)
  self:AddControlEventByControl(self.UIRoot.OnFireBtn_LReleaseBtn, "OnReleased", self.OnReleasedFire, self, false)
  self:AddControlEventByControl(self.UIRoot.OnFireBtn_ReleaseBtn, "OnMouseButtonDownEvent", self.OnFireButtonMouseButtonDown, self, true)
  self:AddControlEventByControl(self.UIRoot.OnFireBtn_LReleaseBtn, "OnMouseButtonDownEvent", self.OnFireButtonMouseButtonDown, self, false)
  self:AddControlEventByControl(self.UIRoot.OnFireBtn_Lside, "OnMouseButtonDownEvent", self.OnFireButtonMouseButtonDown, self, false)
  self:AddControlEventByControl(self.UIRoot.CancelReleaseFireBtn, "OnMouseButtonDownEvent", self.CancelReleaseFireBtnDown, self)
  self:AddUIMessageEvent("UIMsg_PrefireEnd", self.UIMsg_PrefireEnd, self)
  self:AddUIMessageEvent("UIMSG_NormalAimBtn", self.UIMSG_NormalAimBtn, self)
  self:AddUIMessageEvent("UIMsg_ReleaseFireBtn", self.UIMsg_ReleaseFireBtn, self)
  self:AddUIMessageEvent("UIMsg_NormalLeftFire", self.UIMsg_NormalLeftFire, self)
  self:AddUIMessageEvent("UIMsg_NormalRightFire", self.UIMsg_NormalRightFire, self)
  self:AddUIMessageEvent("UIMsg_DoUITouchMove", self.OnDoUITouchMove, self)
  self:AddUIMessageEvent("UIMsg_PlayerControllerPressFire", self.OnPlayerControllerPressFire, self)
  self:AddUIMessageEvent("UIMsg_NormalRightFire_NoThrowGrenade", self.UIMsg_NormalRightFire_NoThrowGrenade, self)
  self:AddUIMessageEvent("UIMsg_PlayerControllerShowOrHideFireBtn", self.UIMsg_PlayerControllerShowOrHideFireBtn, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnChangeCharacterLogicDelegate", self.OnChangeCharacter, self)
end
function ShootingUIPanelIMP:UIMSG_NormalAimBtn()
  self.AutoCollapsedScoping = false
end
function ShootingUIPanelIMP:UIMsg_NormalRightFire_NoThrowGrenade()
  self:NormalFireBtnByStatus(true)
end
function ShootingUIPanelIMP:UIMsg_NormalLeftFire()
  self:NormalFireBtnByStatus(false)
end
function ShootingUIPanelIMP:UIMsg_NormalRightFire()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local CurrentUseWeaponSlot = WeaponManager:GetCurrentUsingPropSlot()
  if CurrentUseWeaponSlot ~= ESurviveWeaponPropSlot.SWPS_HandProp then
    self:GrenadeThrow()
  else
    self:NormalFireBtnByStatus(true)
  end
end
function ShootingUIPanelIMP:UIMsg_ReleaseFireBtn()
  self:OnReleaseFireBtn()
end
function ShootingUIPanelIMP:UIMsg_PlayerControllerShowOrHideFireBtn()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if PlayerController.IsShowFireBtn then
    self.UIRoot.AttackBtnPanel_Rside:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:HightLightFireBtnByStatus(false)
  else
    self:NormalFireBtnByStatus(false)
  end
end
function ShootingUIPanelIMP:OnReleasedCancelFire()
  print(bWriteLog and "ShootingUIPanelUIBase:OnReleasedCancelFire")
  self:ResetCancelFireBtn()
  if not self.AutoCollapsedScoping then
    print(bWriteLog and "ShootingUIPanelUIBase:OnReleasedCancelFire not self.AutoCollapsedScoping")
    return
  end
  self:ReleaseFireScopeOut()
end
function ShootingUIPanelIMP:OnFireButtonMouseButtonDown(bIsRight, MyGeometry, MouseEvent)
  print(bWriteLog and "ShootingUIPanelUIBase:OnFireButtonMouseButtonDown bIsRight=" .. tostring(bIsRight))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnFireButtonMouseButtonDown Fail not uPlayerCharacter")
    return UWidgetBlueprintLibrary:Unhandled()
  end
  if PlayerCharacter.bDead then
    print(bWriteLog and "ShootingUIPanelUIBase:OnFireButtonMouseButtonDown Fail uPlayerCharacter.bDead")
    return UWidgetBlueprintLibrary:Unhandled()
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnFireButtonMouseButtonDown Fail not slua.isValid(uPlayerController)")
    return UWidgetBlueprintLibrary:Unhandled()
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if slua.isValid(VehicleUserComponent) and slua.isValid(VehicleUserComponent.Character) and slua.isValid(VehicleUserComponent.Vehicle) and not VehicleUserComponent:CheckCanLeanOutVehicle() then
    VehicleUserComponent:TryChangeFreeFireSeatAndLeanOut()
    return UWidgetBlueprintLibrary:Unhandled()
  end
  local FingerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(MouseEvent)
  local TouchForce = UKismetInputLibrary.PointerEvent_TouchForce(MouseEvent)
  if bIsRight then
    self.FireFingerIndex_Right = FingerIndex
  else
    self.FireFingerIndex_Left = FingerIndex
    PlayerController.bNotMoveFire = true
    PlayerController.IgnoreCameraMovingIndexArray:AddUnique(FingerIndex)
  end
  self:OnPressFireBtn(FingerIndex, TouchForce, ETouchFireType.ButtonFire, bIsRight)
  if bIsRight then
    PlayerController.bAlreadyFired = true
  end
  if PlayerController.OnPlayerHitFireBtn then
    PlayerController:OnPlayerHitFireBtn(bIsRight)
  end
  if PlayerController.OnPlayerHitFireBtnEvent then
    PlayerController:OnPlayerHitFireBtnEvent(MouseEvent)
  end
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.Fire, 1)
  end
  return UWidgetBlueprintLibrary:Unhandled()
end
function ShootingUIPanelIMP:CancelReleaseFireBtnDown(MyGeometry, MouseEvent)
  print(bWriteLog and "ShootingUIPanelUIBase:CancelReleaseFireBtnDown")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelUIBase:CancelReleaseFireBtnDown not slua.isValid(uPlayerController)")
    return UWidgetBlueprintLibrary:Unhandled()
  end
  local FingerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(MouseEvent)
  PlayerController.IgnoreCameraMovingIndexArray:AddUnique(FingerIndex)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local CurShootWeapon = PlayerCharacter:GetCurrentShootWeapon()
    if slua.isValid(CurShootWeapon) and CurShootWeapon.BowAccumulateEnergyState then
      CurShootWeapon.BowAccumulateEnergyState:ForceEndState(true)
    end
  end
  return UWidgetBlueprintLibrary.Handled()
end
function ShootingUIPanelIMP:ResetCancelFireBtn()
  print(bWriteLog and "ShootingUIPanelUIBase:ResetCancelFireBtn")
  self.ReleaseFireWeaponCache = nil
  self.UIRoot.ReleaseFireSwitcher:SetActiveWidgetIndex(0)
  self.UIRoot.ReleaseFireSwitcher_Lside:SetActiveWidgetIndex(0)
end
function ShootingUIPanelIMP:ReleaseFireScopeOut()
  print(bWriteLog and "ShootingUIPanelUIBase:ReleaseFireScopeOut")
  self.AutoCollapsedScoping = false
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:ReleaseFireScopeOut not uPlayerCharacter")
    return
  end
  PlayerCharacter:ScopeOut(ESTEScopeType.AutoCollapsed)
end
function ShootingUIPanelIMP:FireBtnRelease(FingerIndex, bIsRight, bForceStop)
  print(bWriteLog and "ShootingUIPanelUIBase:FireBtnRelease FingerIndex=" .. FingerIndex .. " bIsRight=" .. tostring(bIsRight) .. "bForceStop=" .. tostring(bForceStop))
  self:NormalFireBtnByStatus(bIsRight)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelUIBase:FireBtnRelease not slua.isValid(uPlayerController)")
    return
  end
  print(bWriteLog and "ShootingUIPanelUIBase:FireBtnRelease uPlayerController.OnFireTouchFingerIndex=" .. PlayerController.OnFireTouchFingerIndex)
  if PlayerController.OnFireTouchFingerIndex == FingerIndex or bForceStop then
    PlayerController:EndForceTouchFire(FVector(0.0, 0.0, 0.0))
    PlayerController.bAlreadyFired = false
  end
  PlayerController:EndTouchScreen(FVector(0.0, 0.0, 0.0), FingerIndex, true)
  if bIsRight then
    self.FireFingerIndex_Right = ETouchIndex.Touch10
    print(bWriteLog and "ShootingUIPanelUIBase:FireBtnRelease Set FireFingerIndexRight:Touch10")
  else
    self.FireFingerIndex_Left = ETouchIndex.Touch10
    print(bWriteLog and "ShootingUIPanelUIBase:FireBtnRelease Set FireFingerIndexLeft:Touch10")
  end
end
function ShootingUIPanelIMP:OnDoUITouchMove()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local DeviceAdaptationData = PlayerController.CurDeviceAdaptationData
  local Slot = self.UIRoot.AttackBtnPanel_Rside.Slot
  if not Slot then
    return
  end
  local Size = Slot:GetSize()
  local NewPos = PlayerController:CalcAttactBtnPos(PlayerController.UITouchMoveX, PlayerController.UITouchMoveY, Size.X, Size.Y)
  Slot:SetPosition(FVector2D(NewPos.X + DeviceAdaptationData.LeftOffset, NewPos.Y + DeviceAdaptationData.BottomOffset))
end
function ShootingUIPanelIMP:OnPlayerControllerPressFire()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.PressFireFingerIndex then
    return
  end
  if PlayerController.bDisableFireAction then
    return
  end
  self:OnPressFireBtn(PlayerController.PressFireFingerIndex, 0, ETouchFireType.NotFire, true)
  self.UIRoot.AttackBtnPanel_Rside:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function ShootingUIPanelIMP:OnPressFireBtn(FingerIndex, TouchForce, FireType, bIsRightSide)
  print(bWriteLog and "ShootingUIPanelUIBase:OnPressFireBtn")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnPressFireBtn Fail not slua.isValid(uPlayerController)")
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_FIREBTN_PRESS)
  if PlayerController.EndTouchScreenCommandMap then
    if bIsRightSide then
      PlayerController.EndTouchScreenCommandMap:Add(FingerIndex, "UIMsg_NormalRightFire_NoThrowGrenade")
    else
      PlayerController.EndTouchScreenCommandMap:Add(FingerIndex, "UIMsg_NormalLeftFire")
    end
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) or PlayerCharacter.GetCurrentShootWeapon == nil then
    print(bWriteLog and "ShootingUIPanelUIBase:OnPressFireBtn Fail not PlayerCharacter or GetCurrentShootWeapon is nil")
    return
  end
  local CurShootWeapon = PlayerCharacter:GetCurrentShootWeapon()
  if slua.isValid(CurShootWeapon) and CurShootWeapon.OnPressFire then
    CurShootWeapon:OnPressFire()
    return
  end
  local bIsInFreeCameraView = PlayerController:IsInFreeCameraView()
  local bIsPlayingEmote = PlayerCharacter:GetIsPlayingEmote()
  if bIsInFreeCameraView and not bIsPlayingEmote then
    print(bWriteLog and "ShootingUIPanelUIBase:OnPressFireBtn Fail bIsInFreeCameraView and not bIsPlayingEmote")
    return
  end
  print(bWriteLog and "ShootingUIPanelUIBase:OnPressFireBtn FingerIndex=" .. tostring(FingerIndex) .. " bIsRightSide=" .. tostring(bIsRightSide))
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if not DataLayerSubsystem then
    return
  end
  local FireBtnStatus = DataLayerSubsystem:GetFireBtnStatus()
  if FireBtnStatus == ECurPlayerHandStatus.Begging then
    PlayerCharacter:TriggerEntrySkillWithID(1013704, true)
    return
  end
  local Weapon = PlayerCharacter:GetCurrentWeapon()
  if slua.isValid(Weapon) then
    if Weapon.IsInFireCD and Weapon:IsInFireCD() then
      return
    end
    local ItemID = Weapon:GetItemDefineID().TypeSpecificID
    if UBackpackUtils.HasTag(ItemID, "OldGrenade") then
      self:GrenadePrepareToThrow(FingerIndex)
    else
      Weapon:TriggerWeaponEvent(EWeaponTriggerEvent.EWeaponTriggerEvent_PressFuncBtn)
    end
  end
  local CurShootWeapon = PlayerCharacter:GetCurrentShootWeapon()
  if slua.isValid(CurShootWeapon) then
    self.ReleaseFireWeaponCache = CurShootWeapon
    local bIsNeedReleaseFire, ReleaseFireType = self:IsNeedReleaseFire(CurShootWeapon)
    if bIsNeedReleaseFire then
      print(bWriteLog and "ShootingUIPanelUIBase:OnPressFireBtn NeedReleaseFire")
      if not PlayerCharacter:AllowState(EPawnState.GunFire, true) then
        return
      end
      if ReleaseFireType == EReleaseToFireType.RELEASEFIRE_SHOTGUN or ReleaseFireType == EReleaseToFireType.RELEASEFIRE_SNIPER then
        if ReleaseFireType == EReleaseToFireType.RELEASEFIRE_SNIPER and PlayerController.CurCameraMode ~= EPlayerCameraMode.PCM_Aim then
          if self:CheckAutoScoping() then
            PlayerCharacter:Scoping(ESTEScopeType.AutoCollapsed)
          end
          self.AutoCollapsedScoping = true
        end
        self:ShowCancelReleaseFireBtn(bIsRightSide)
      else
        return
      end
    else
      print(bWriteLog and "ShootingUIPanelUIBase:OnPressFireBtn Normal Fire")
      self:HightLightFireBtnByStatus(bIsRightSide)
      if not PlayerCharacter:HasState(EPawnState.LeanOutVehicle) then
        local uVehicleUserComponent = PlayerController:GetVehicleUserComp()
        if slua.isValid(uVehicleUserComponent) then
          uVehicleUserComponent:TryLeanOutOrIn(true, false)
        end
      end
      PlayerCharacter:StartFire(0, 0, EShootWeaponShootMode.SWST_TraceTarget, FVector(0, 0, 0), true, nil)
      PlayerController.bIsPressingFireBtn = true
    end
  else
    print(bWriteLog and "ShootingUIPanelUIBase:OnPressFireBtn Melee")
    self:HightLightFireBtnByStatus(bIsRightSide)
    PlayerCharacter:Melee(false)
  end
  if PlayerController.OnFireTouchFingerIndex and PlayerController.TouchFireType then
    PlayerController.OnFireTouch    PlayerController.Touch  end
end
function ShootingUIPanelIMP:OnReleasedFire(bIsRight)
  print(bWriteLog and "ShootingUIPanelUIBase:OnReleasedFire bIsRight=" .. tostring(bIsRight))
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController.bIsPressingFireBtn = false
    PlayerController.ReleaseFireBtnTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  end
  local FingerIndex = self.FireFingerIndex_Left
  if bIsRight then
    FingerIndex = self.FireFingerIndex_Right
  end
  self:FireBtnRelease(FingerIndex, bIsRight, true)
  if slua.isValid(PlayerController) and PlayerController.EndTouchScreenCommandMap then
    PlayerController.EndTouchScreenCommandMap:Remove(FingerIndex)
  end
  if slua.isValid(PlayerController) and PlayerController.OnPlayerReleaseFireBtn then
    PlayerController:OnPlayerReleaseFireBtn()
  end
end
function ShootingUIPanelIMP:IsNeedReleaseFire(ShootWeapon)
  print(bWriteLog and "ShootingUIPanelUIBase:IsNeedReleaseFire")
  if not slua.isValid(ShootWeapon) then
    print(bWriteLog and "ShootingUIPanelUIBase:IsNeedReleaseFire not slua.isValid(ShootWeapon)")
    return false, EReleaseToFireType.RELEASEFIRE_NONE
  end
  if ShootWeapon.IsNeedReleaseFire then
    return ShootWeapon:IsNeedReleaseFire()
  end
  local WeaponComponent
  if ShootWeapon.GetShootWeaponEntityComponent then
    WeaponComponent = ShootWeapon:GetShootWeaponEntityComponent()
  end
  if not slua.isValid(WeaponComponent) then
    print(bWriteLog and "ShootingUIPanelUIBase:IsNeedReleaseFire not slua.isValid(WeaponComponent)")
    return false, EReleaseToFireType.RELEASEFIRE_NONE
  end
  local ReleaseFireType = WeaponComponent.ReleaseFireType
  if ReleaseFireType == EReleaseToFireType.RELEASEFIRE_NONE then
    return false, EReleaseToFireType.RELEASEFIRE_NONE
  end
  if ReleaseFireType == EReleaseToFireType.RELEASEFIRE_SHOTGUN then
    return self.ShotGunReleaseFireType == 1, EReleaseToFireType.RELEASEFIRE_SHOTGUN
  end
  if ReleaseFireType == EReleaseToFireType.RELEASEFIRE_SNIPER then
    return self.SniperReleaseFireType == 1, EReleaseToFireType.RELEASEFIRE_SNIPER
  end
  if ReleaseFireType == EReleaseToFireType.RELEASEFIRE_BRUST then
    return ShootWeapon.CurShootType == ESTEWeaponShootType.MultiBulletsBursting and self.SniperReleaseFireType == 1, EReleaseToFireType.RELEASEFIRE_SNIPER
  end
end
function ShootingUIPanelIMP:CheckAutoScoping()
  print(bWriteLog and "ShootingUIPanelUIBase:CheckAutoScoping")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  local CurShootWeapon = self.ReleaseFireWeaponCache
  if not slua.isValid(CurShootWeapon) then
    return false
  end
  if CurShootWeapon.BowEnergyAccumulate then
    return false
  end
  if CurShootWeapon:IsInPreFire() then
    self.ScopeAfterPrefire = true
    return false
  else
    if PlayerCharacter:HasState(EPawnState.GunReload) then
      self.ScopeAfterReload = true
      return false
    end
    return true
  end
end
function ShootingUIPanelIMP:ShowCancelReleaseFireBtn(bIsRight)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowCancelReleaseFireBtn bIsRight=" .. tostring(bIsRight))
  if bIsRight then
    self.UIRoot.ReleaseFireSwitcher_Lside:SetActiveWidgetIndex(1)
  else
    self.UIRoot.ReleaseFireSwitcher:SetActiveWidgetIndex(1)
  end
end
function ShootingUIPanelIMP:HightLightFireBtnByStatus(bIsRight)
  print(bWriteLog and "ShootingUIPanelUIBase:HightLightFireBtnByStatus bIsRight" .. tostring(bIsRight))
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if not DataLayerSubsystem then
    return
  end
  local FireBtnStatus = DataLayerSubsystem:GetFireBtnStatus()
  local FireBtnImage, FireBtnBG = self:GetUpdateFireBtnWidget(bIsRight)
  if FireBtnStatus == ECurPlayerHandStatus.Fist then
    FireBtnImage:SetBrush(self.UIRoot.Fist_HighLightIcon)
    FireBtnBG:SetBrush(self.UIRoot.FireBG_HighLight)
  elseif FireBtnStatus == ECurPlayerHandStatus.Melee then
    local Normal, HighLight = self:GetCurMeleeHightLightAndNormalIcon()
    FireBtnImage:SetBrush(HighLight)
    FireBtnBG:SetBrush(self.UIRoot.FireBG_HighLight)
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) then
      local Weapon = PlayerCharacter:GetCurrentWeapon()
      if slua.isValid(Weapon) and Weapon:GetWeaponWantsMode() == EWeaponOperationMode.Throw then
        local FireBtnImageOther, FireBtnBGOther = self:GetUpdateFireBtnWidget(not bIsRight)
        FireBtnImageOther:SetBrush(HighLight)
        FireBtnBGOther:SetBrush(self.UIRoot.FireBG_HighLight)
      end
    end
  elseif FireBtnStatus == ECurPlayerHandStatus.Gun then
    FireBtnImage:SetBrushFromPathAsync(Fire_HighLightIconPath, false)
    FireBtnBG:SetBrush(self.UIRoot.FireBG_HighLight)
  end
  self:RefreshAttackBtnEnd()
end
function ShootingUIPanelIMP:GetUpdateFireBtnWidget(bIsRight)
  print(bWriteLog and "ShootingUIPanelUIBase:GetUpdateFireBtnWidget bIsRight=" .. tostring(bIsRight))
  if bIsRight then
    return self.UIRoot.OnFireBtn_Rside, self.UIRoot.OnFireBtnBG_Rside
  else
    return self.UIRoot.OnFireBtn_LsideImage, self.UIRoot.OnFireBtnBG_Lside
  end
end
function ShootingUIPanelIMP:GetCurMeleeHightLightAndNormalIcon()
  return self.UIRoot.Melee_NormalIcon, self.UIRoot.Melee_HighLightIcon
end
function ShootingUIPanelIMP:GetCurFistHightLightAndNormalIcon()
  return self.UIRoot.Fist_NormalIcon, self.UIRoot.Fist_HighLightIcon
end
function ShootingUIPanelIMP:RefreshAttackBtnEnd()
  print(bWriteLog and "ShootingUIPanel:RefreshAttackBtn")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnReleaseFireBtn not PlayerCharacter")
    return
  end
  local CurWeapon = PlayerCharacter:GetCurrentWeapon()
  if not slua.isValid(CurWeapon) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnReleaseFireBtn not CurWeapon")
    return
  end
  local WeaponDefine = require("GameLua.GameCore.Module.Weapon.WeaponDefine")
  local DefineID = CurWeapon:GetItemDefineID()
  if DefineID and DefineID.TypeSpecificID then
    local CurWeaponID = DefineID.TypeSpecificID
    local WeaponLibrary = require("GameLua.GameCore.Module.Weapon.WeaponLibrary")
    local WeaponConfigData = WeaponLibrary.GetWeaponConfig(CurWeaponID)
    local CustomVirtualItemSubsystem = SubsystemMgr:Get("CustomVirtualItemSubsystem")
    if CustomVirtualItemSubsystem ~= nil then
      local CustomConfig = CustomVirtualItemSubsystem:GetBluePrintInfo(CurWeaponID)
      if CustomConfig and CustomConfig.WeaponLuaConfig then
        WeaponConfigData = CustomConfig.WeaponLuaConfig
      end
    end
    if WeaponConfigData ~= nil and WeaponConfigData[WeaponDefine.ConfigKey.AttackIcon] ~= nil then
      local AttackBtnIcon = WeaponConfigData[WeaponDefine.ConfigKey.AttackIcon]
      if AttackBtnIcon then
        print(bWriteLog and "ShootingUIPanel:RefreshAttackBtn AttackBtnIcon")
        self.UIRoot.OnFireBtn_LsideImage:SetBrushFromPathAsync(AttackBtnIcon, false)
        self.UIRoot.OnFireBtn_Rside:SetBrushFromPathAsync(AttackBtnIcon, false)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_REFRESH_ATTACK_BTN)
end
function ShootingUIPanelIMP:NormalFireBtnByStatus(bIsRight)
  print(bWriteLog and "ShootingUIPanelUIBase:NormalFireBtnByStatus")
  local FireBtnImage, FireBtnBG = self:GetUpdateFireBtnWidget(bIsRight)
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if not DataLayerSubsystem then
    return
  end
  local FireBtnStatus = DataLayerSubsystem:GetFireBtnStatus()
  if FireBtnStatus == ECurPlayerHandStatus.Fist then
    local Normal, _ = self:GetCurFistHightLightAndNormalIcon()
    FireBtnImage:SetBrush(Normal)
    FireBtnBG:SetBrush(slua.IndexReference(self.UIRoot, "FireBG_NormalIcon"):clone())
  elseif FireBtnStatus == ECurPlayerHandStatus.Melee then
    local Normal, _ = self:GetCurMeleeHightLightAndNormalIcon()
    FireBtnImage:SetBrush(Normal)
    FireBtnBG:SetBrush(slua.IndexReference(self.UIRoot, "FireBG_NormalIcon"):clone())
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) then
      local Weapon = PlayerCharacter:GetCurrentWeapon()
      if slua.isValid(Weapon) and Weapon:GetWeaponWantsMode() == EWeaponOperationMode.Throw then
        local FireBtnImageOther, FireBtnBGOther = self:GetUpdateFireBtnWidget(not bIsRight)
        FireBtnImageOther:SetBrush(Normal)
        FireBtnBGOther:SetBrush(slua.IndexReference(self.UIRoot, "FireBG_NormalIcon"):clone())
      end
    end
  elseif FireBtnStatus == ECurPlayerHandStatus.Gun then
    FireBtnImage:SetBrush(self.UIRoot.Fire_NormalIcon)
    FireBtnBG:SetBrush(self.UIRoot.FireBG_NormalIcon)
  end
  self:RefreshAttackBtnEnd()
end
function ShootingUIPanelIMP:OnReleaseFireBtn()
  print(bWriteLog and "ShootingUIPanelUIBase:OnReleaseFireBtn")
  self.FingerIndex3DTouch = ETouchIndex.Touch10
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnReleaseFireBtn not slua.isValid(uPlayerController)")
    return
  end
  PlayerController.bIsPressingFireBtn = false
  PlayerController.ReleaseFireBtnTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnReleaseFireBtn not uPlayerCharacter")
    return
  end
  local Weapon = PlayerCharacter:GetCurrentWeapon()
  if not slua.isValid(Weapon) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnReleaseFireBtn not Weapon")
    return
  end
  local ItemID = Weapon:GetItemDefineID().TypeSpecificID
  if UBackpackUtils.HasTag(ItemID, "OldGrenade") then
    self:GrenadeThrow()
  else
    Weapon:TriggerWeaponEvent(EWeaponTriggerEvent.EWeaponTriggerEvent_ReleaseFuncBtn)
  end
  local CurShootWeapon = PlayerCharacter:GetCurrentShootWeapon()
  if slua.isValid(CurShootWeapon) then
    local Result, ReleaseFireType = self:IsNeedReleaseFire(CurShootWeapon)
    if CurShootWeapon == self.ReleaseFireWeaponCache and Result then
      PlayerCharacter:StartFire(0, 0, EShootWeaponShootMode.SWST_TraceTarget, FVector(0, 0, 0), true, nil)
      self:ResetCancelFireBtn()
      if self.AutoCollapsedScoping then
        self:ReleaseFireScopeOut()
      end
      self.ScopeAfterPrefire = false
      self.ScopeAfterReload = false
      print(bWriteLog and "ShootingUIPanelUIBase:OnReleaseFireBtn Relaease Fire")
      return
    end
  end
  if PlayerCharacter.MeleeReleased then
    PlayerCharacter:MeleeReleased()
  end
  print(bWriteLog and "ShootingUIPanelUIBase:OnReleaseFireBtn Relaease")
end
function ShootingUIPanelIMP:ChangeFireBtnByWeaponPlotSlot(Status)
  print(bWriteLog and "ShootingUIPanelUIBase:ChangeFireBtnByWeaponPlotSlot")
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if not DataLayerSubsystem then
    return
  end
  local FireBtnStatus = DataLayerSubsystem:GetFireBtnStatus()
  if FireBtnStatus == ECurPlayerHandStatus.Begging then
    self:ChangeFireStatusAndUpdateFireBtn(ECurPlayerHandStatus.Begging)
  else
    self:ChangeFireStatusAndUpdateFireBtn(Status)
  end
end
function ShootingUIPanelIMP:ChangeFireStatusAndUpdateFireBtn(Status)
  if Status == nil then
    return
  end
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if not DataLayerSubsystem then
    return
  end
  print(bWriteLog and "ShootingUIPanelUIBase:ChangeFireStatusAndUpdateFireBtn")
  local UIRoot = self.UIRoot
  DataLayerSubsystem:SetFireBtnStatus(Status)
  local Refresh = function(ActiveIndex, ButtonBrush, ButtonBGBrush)
    UIRoot.WidgetSwitcher_FirebtnLSide:SetActiveWidgetIndex(ActiveIndex)
    UIRoot.AttackModeSwitcher_Rside:SetActiveWidgetIndex(ActiveIndex)
    UIRoot.OnFireBtnPanel_Lside:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIRoot.OnFireBtn_Rside:SetBrush(ButtonBrush)
    UIRoot.OnFireBtnBG_Rside:SetBrush(ButtonBGBrush)
    UIRoot.OnFireBtn_LsideImage:SetBrush(ButtonBrush)
    UIRoot.OnFireBtnBG_Lside:SetBrush(ButtonBGBrush)
  end
  if Status == ECurPlayerHandStatus.Fist then
    local Normal, HighLight = self:GetCurFistHightLightAndNormalIcon()
    Refresh(0, Normal, slua.IndexReference(UIRoot, "FireBG_NormalIcon"):clone())
  elseif Status == ECurPlayerHandStatus.Melee then
    local Normal, HighLight = self:GetCurMeleeHightLightAndNormalIcon()
    Refresh(0, Normal, slua.IndexReference(UIRoot, "FireBG_NormalIcon"):clone())
  elseif Status == ECurPlayerHandStatus.Gun then
    Refresh(0, slua.IndexReference(UIRoot, "Fire_NormalIcon"):clone(), slua.IndexReference(UIRoot, "FireBG_NormalIcon"):clone())
  elseif Status == ECurPlayerHandStatus.Greanade then
    UIRoot.WidgetSwitcher_FirebtnLSide:SetActiveWidgetIndex(1)
    UIRoot.AttackModeSwitcher_Rside:SetActiveWidgetIndex(1)
  elseif Status == ECurPlayerHandStatus.Begging then
    local Normal, HighLight = self:GetBeggingNormalIcon()
    UIRoot.OnFireBtn_Rside:SetBrush(Normal)
    UIRoot.OnFireBtnBG_Rside:SetBrush(slua.IndexReference(UIRoot, "FireBG_NormalIcon"):clone())
    UIRoot.OnFireBtn_LsideImage:SetBrush(Normal)
    UIRoot.OnFireBtnBG_Lside:SetBrush(slua.IndexReference(UIRoot, "FireBG_NormalIcon"):clone())
  end
  self:RefreshAttackBtnEnd()
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_UPDATE_FIRE_BTN)
end
function ShootingUIPanelIMP:OnChangeCharacter(TargetPawnType)
  local ECharacterSubType = import("ECharacterSubType")
  if TargetPawnType < ECharacterSubType.MotherZombie then
    return
  end
  self:ShowUIByOperation(UEnums.UIOperation.Shoot)
  self:UpdateCancelShootBtn(UEnums.ECurPlayerHandStatus.Fist)
end
function ShootingUIPanelIMP:UpdateCancelShootBtn(Status)
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if not DataLayerSubsystem then
    return
  end
  if Status == ECurPlayerHandStatus.Begging then
    DataLayerSubsystem:SetFireBtnStatus(Status)
    self:RefreshAttackBtnEnd()
  else
    self:ChangeFireStatusAndUpdateFireBtn(Status)
  end
end
function ShootingUIPanelIMP:GetBeggingNormalIcon()
  print(bWriteLog and "ShootingUIPanelUIBase:GetBeggingNormalIcon")
  return self.UIRoot.Begging_NormalIcon, self.UIRoot.Begging_NormalIcon
end
function ShootingUIPanelIMP:SetFireBtnVisible(Visibility)
  self.UIRoot.FireBtnModelContainerR:SetWidgetVisibility(Visibility)
end
function ShootingUIPanelIMP:UIMsg_PrefireEnd()
  print(bWriteLog and "ShootingUIPanelUIBase:UIMsg_PrefireEnd")
  if not self.ScopeAfterPrefire then
    print(bWriteLog and "ShootingUIPanelUIBase:UIMsg_PrefireEnd not self.ScopeAfterPrefire")
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    PlayerCharacter:ScopeIn(ESTEScopeType.AutoCollapsed)
  end
  self.ScopeAfterPrefire = false
end
function ShootingUIPanelIMP:UIMsg_ResetCancelFireBtn()
  print(bWriteLog and "ShootingUIPanelUIBase:UIMsg_ResetCancelFireBtn")
  self:ResetCancelFireBtn()
end
function ShootingUIPanelIMP:Close_Fire()
end