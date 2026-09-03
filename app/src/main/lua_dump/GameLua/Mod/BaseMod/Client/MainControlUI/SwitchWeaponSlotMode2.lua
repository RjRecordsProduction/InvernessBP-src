local ESlateVisibility = import("ESlateVisibility")
local GameplayStatics = import("GameplayStatics")
local SwitchWeaponSlotMode2 = {
  UIName = "SwitchWeaponSlotMode2",
  LuaEventContainer = {
    "OnGunRunOutOfAmmo",
    "OnGunNormalChangeAmmo"
  }
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local SpecialIcons = {
  XT_Select = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_Special_Check1_png.ZD_icon_Special_Check1_png",
  XT_UnSelect = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_Special_Check2_png.ZD_icon_Special_Check2_png"
}
local ShotGunIConfig = {
  ShotMode_Neostead_ShotGun = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_Icon_shotgun_png.ZD_Icon_shotgun_png",
  ShotMode_Neostead_OneShot = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_Icon_oneshot_png.ZD_Icon_oneshot_png",
  ActiveRGBA = FLinearColor(1, 1, 1, 1),
  UnActiveRGBA = FLinearColor(1, 1, 1, 0.4)
}
function SwitchWeaponSlotMode2:ctor(selfType)
  local ESTEWeaponShootType = import("ESTEWeaponShootType")
  self.FireModeMap = {
    [1] = {
      "bHasSingleFireMode",
      ESTEWeaponShootType.OneBulletBursting
    },
    [2] = {
      "bHasBurstFireMode",
      ESTEWeaponShootType.MultiBulletsBursting
    },
    [3] = {
      "bHasAutoFireMode",
      ESTEWeaponShootType.Auto
    },
    [4] = {
      "bHasVolleyFireMode",
      ESTEWeaponShootType.Volley
    }
  }
  self.SniperDSRBakMagUI = nil
  self.ReloadTime = 0
  self:AddCommonEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_FIREMODE_CHANGE, self.OnFireModeBtnClicked, self)
end
function SwitchWeaponSlotMode2:OnFireModeBtnClicked(_, _, SlotType)
  if self.WeaponSlotType ~= SlotType then
    return
  end
  self:SetWeaponShootType()
end
function SwitchWeaponSlotMode2:AddDXGetitemAnimFinished()
  self:AddGameTimer(1.1, false, function()
    self:CheckShowXTModeUI()
  end)
end
function SwitchWeaponSlotMode2:CheckShowXTModeUI()
  print(bWriteLog and "SwitchWeaponSlotMode2:CheckShowXTModeUI" .. tostring(self.WeaponSlotType))
  self.HitRecordTagSelected:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.HitRecordTagUnSelected:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local CurrentWeapon = self:GetCurrentWeapon()
  if not Game:IsValid(CurrentWeapon) then
    return
  end
  local ModType, ModeType2 = GameMainConfig.GetModType()
  local bHasLivkTag = GameMainConfig.HasExtraModule("Livik")
  if ModType == "Livik" or ModeType2 == "Livik" or bHasLivkTag then
    self.special_icon:SetBrushfromPathAsync(SpecialIcons.XT_Select, false)
    self.specal_icon_unselected:SetBrushfromPathAsync(SpecialIcons.XT_UnSelect, false)
    if CurrentWeapon.HasUpgrade and CurrentWeapon:HasUpgrade() then
      self.HitRecordTagSelected:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.HitRecordTagUnSelected:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.HitRecordTagSelected.Slot:SetLayer(1)
    end
  end
end
function SwitchWeaponSlotMode2:GetCurrentWeapon()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uPlayerCharacter:GetWeaponManager()) then
    return
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  return uWeaponManager:GetInventoryWeaponByPropSlot(self.WeaponSlotType)
end
function SwitchWeaponSlotMode2:SetNextSelect(Value)
  if Value then
    self.CanvasPanel_NextSelect:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.BG:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    if self.ModType == "Sink" then
      self.specal_icon_unselected:SetBrushFromPathAsync(SpecialIcons.EX_Select, false)
    else
      self.specal_icon_unselected:SetBrushFromPathAsync(SpecialIcons.XT_Select, false)
    end
  else
    self.CanvasPanel_NextSelect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.BG:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    if self.ModType == "Sink" then
      self.specal_icon_unselected:SetBrushFromPathAsync(SpecialIcons.EX_UnSelect, false)
    else
      self.specal_icon_unselected:SetBrushFromPathAsync(SpecialIcons.XT_UnSelect, false)
    end
  end
end
function SwitchWeaponSlotMode2:OnNeosteadFireModeChange(bIsGunADS)
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uCurrentPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uCurrentPlayerCharacter) then
    return
  end
  local uWeaponManager = uCurrentPlayerCharacter:GetWeaponManager()
  if not slua.isValid(uWeaponManager) then
    return
  end
  local uCurUsingWeapon = uWeaponManager:GetCurrentUsingWeapon()
  if uCurUsingWeapon ~= self.CurWeapon then
    self.Image_Neostead_Fire_Mode:SetColorAndOpacity(ShotGunIConfig.ActiveRGBA)
    self.Image_Neostead_OneShot_Mode:SetColorAndOpacity(ShotGunIConfig.UnActiveRGBA)
    return
  end
  if bIsGunADS then
    self.Image_Neostead_Fire_Mode:SetColorAndOpacity(ShotGunIConfig.UnActiveRGBA)
    self.Image_Neostead_OneShot_Mode:SetColorAndOpacity(ShotGunIConfig.ActiveRGBA)
  else
    self.Image_Neostead_Fire_Mode:SetColorAndOpacity(ShotGunIConfig.ActiveRGBA)
    self.Image_Neostead_OneShot_Mode:SetColorAndOpacity(ShotGunIConfig.UnActiveRGBA)
  end
end
function SwitchWeaponSlotMode2:StopToSwitchIfSprint()
  local AsBPPlayerPawn = GameplayStatics.GetPlayerCharacter(self, 0)
  if slua.isValid(AsBPPlayerPawn) then
    local BP_PlayerPawn = import("STExtraPlayerCharacter")
    if Game:IsClassOf(AsBPPlayerPawn, BP_PlayerPawn) and slua.isValid(AsBPPlayerPawn) then
      local ESTEPoseState = import("ESTEPoseState")
      if AsBPPlayerPawn.PoseState == ESTEPoseState.Sprint or AsBPPlayerPawn.PoseState == ESTEPoseState.CrouchSprint then
        if AsBPPlayerPawn.PoseState == ESTEPoseState.Sprint then
          AsBPPlayerPawn:SwitchPoseState(ESTEPoseState.Stand, false, false, true, false)
        elseif AsBPPlayerPawn.PoseState == ESTEPoseState.CrouchSprint then
          AsBPPlayerPawn:SwitchPoseState(ESTEPoseState.Crouch, false, false, true, false)
        end
      end
    end
  end
end
function SwitchWeaponSlotMode2:Initialize()
  self.ProfileImg:SetWidgetVisibility(ESlateVisibility.Hidden)
  self:AddControlEvent(self.DX_GetItem, "OnAnimationFinished", self.GetItemAnimFinished, self)
  self:AddControlEvent(self.ProfileImg, "OnSetBrushAsyncComplete", function()
    if not self.bHideProfileImg then
      self.ProfileImg:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
  end)
  self.IsInitWidget = true
  local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  local IsEnableWeaponDurability = STExtraModLogicSwitchLibrary.IsEnableWeaponDurability()
  if not IsEnableWeaponDurability then
    self.WeaponDurability:SetWidgetVisibility(ESlateVisibility.Hidden)
  end
  self:AddControlEvent(self.Anim_WeaponDurability, "OnAnimationFinished", self.AnimWeaponDurabilityFinishied, self)
  self.bCanPlayBulletCountAnim = true
  self.SlateColorOutOfAmmoRed = FSlateColor(self.OutOfAmmoRed)
  self.SlateColorNormalAmmoWhite = FSlateColor(self.NormalAmmoWhite)
  self:AddControlEvent(self.Anim_FlowLight_01, "OnAnimationFinished", self.ReloadAnimFinished, self)
  self:AddControlEvent(self.Anim_FlowLight_02, "OnAnimationFinished", self.LightAnimFinished, self)
  self.CanvasPanel_Reload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function SwitchWeaponSlotMode2:GetItemAnimFinished()
  self:PlayAnimationInQueue()
end
function SwitchWeaponSlotMode2:AnimWeaponDurabilityFinishied()
  self:UpdateWeaponDurabilityColor()
end
function SwitchWeaponSlotMode2:ChangeWeaponImage(IconPath)
  self.ImagePath = IconPath or ""
  self.ProfileImg:SetWidgetVisibility(ESlateVisibility.Hidden)
  self.ProfileImg:SetBrushFromPathAsync(self.ImagePath, false)
  self:CheckShowKCIcon()
end
function SwitchWeaponSlotMode2:CheckShowKCIcon()
  local KillCounterUISubsystem = SubsystemMgr:Get("KillCounterUISubsystem")
  if not KillCounterUISubsystem or not KillCounterUISubsystem:CheckSupportKCUI() then
    self.KillCounterImg:SetWidgetVisibility(ESlateVisibility.Collapsed)
    return
  end
  local CurWeapon = self:GetCurrentWeapon()
  if not slua.isValid(CurWeapon) then
    self.KillCounterImg:SetWidgetVisibility(ESlateVisibility.Collapsed)
    return
  end
  local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
  local WeaponID = CurWeapon:GetWeaponID()
  local curEquipedKillCounter = LogicKillCounter:GetMyEquipedKillCounterId(WeaponID)
  if not curEquipedKillCounter then
    self.KillCounterImg:SetWidgetVisibility(ESlateVisibility.Collapsed)
    return
  end
  self.KillCounterImg:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
end
function SwitchWeaponSlotMode2:Show_HideFireMode(bIsShow, ShootWeapon)
  local HideDPInfo = function()
    self.CanvasPanel_DP12_Info:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  local HideNeostead = function()
    self.Image_Neostead_Fire_Mode:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.Image_Neostead_OneShot_Mode:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  if slua.isValid(ShootWeapon) then
    print(bWriteLog and "CurWeapon valid")
    self.CurWeapon = ShootWeapon
    local AsShootWeaponEntity = self.CurWeapon.WeaponEntityComp
    local ShootWeaponEntity = import("ShootWeaponEntity")
    if Game:IsClassOf(AsShootWeaponEntity, ShootWeaponEntity) then
      self.CurBulletType = slua.IndexReference(AsShootWeaponEntity, "BulletType")
      if bIsShow and self:CanShowFireModeSwitchBtn(self.CurWeapon) then
        self.Button_1:SetWidgetVisibility(ESlateVisibility.Visible)
        self:SetFireModeText()
      else
        self.Button_1:SetWidgetVisibility(ESlateVisibility.Hidden)
      end
    end
    local ShootWeaponEntityComponent
    if self.CurWeapon.GetShootWeaponEntityComponent then
      ShootWeaponEntityComponent = self.CurWeapon:GetShootWeaponEntityComponent()
    end
    if slua.isValid(ShootWeaponEntityComponent) then
      self.ShowBarrelBulletNumUI = ShootWeaponEntityComponent.bShowBarrelBulletNumUI
      if self.ShowBarrelBulletNumUI then
        self.CanvasPanel_DP12_Info:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      else
        HideDPInfo()
      end
    else
      HideDPInfo()
    end
    local ItemDefineID = self.CurWeapon:GetItemDefineID()
    if ItemDefineID.TypeSpecificID == 104102 then
      if slua.isValid(ShootWeaponEntityComponent) then
        self.Image_Neostead_Fire_Mode:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.Image_Neostead_OneShot_Mode:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      else
        HideNeostead()
      end
    else
      HideNeostead()
    end
  else
    print(bWriteLog and "CurWeapon invalid")
  end
  self:ConditionShowBulletBar(ShootWeapon)
  self:OnWeaponChange(ShootWeapon)
end
function SwitchWeaponSlotMode2:OnWeaponChange(ShootWeapon)
  if slua.isValid(ShootWeapon) then
    if ShootWeapon.bSniperDSR then
      if self.SniperDSRBakMagUI then
        self.SniperDSRBakMagUI:UpdateWeapon(ShootWeapon)
      else
        self.SniperDSRBakMagUI = UIManager.ShowUI(UIManager.UI_Config_InGame.SniperDSRBakMagUI, ShootWeapon)
        if self.SniperDSRBakMagUI then
          self.SniperDSRBakMagUI:AttachToPanel(self.CanvasPanel_Main)
          self.SniperDSRBakMagUI:SetAnchors(0, 0, 1, 1)
          self.SniperDSRBakMagUI:SetOffsets(0, 0, 0, 0)
        end
      end
    elseif self.SniperDSRBakMagUI then
      self.SniperDSRBakMagUI:Close()
      self.SniperDSRBakMagUI = nil
    end
  end
end
function SwitchWeaponSlotMode2:GetNextFireMode(ShootWeapon)
  if not slua.isValid(ShootWeapon) then
    print(bWriteLog and "Get Next Fire Mode:Weapon Is Null!")
    return
  end
  local ShootTypeFromEntity = ShootWeapon:GetShootTypeFromEntity()
  local ShootWeaponEntityComponent = ShootWeapon:GetShootWeaponEntityComponent()
  if not slua.isValid(ShootWeaponEntityComponent) then
    print(bWriteLog and "Get Next Fire Mode:Shoot Weapon Entity Component Is Null!")
    return
  end
  local ESTEWeaponShootType = import("ESTEWeaponShootType")
  local NextShootModeList = {}
  local NextIndex = 0
  if ShootWeaponEntityComponent.bHasVolleyFireMode then
    for _, FireModeInfo in ipairs(self.FireModeMap) do
      if ShootWeaponEntityComponent[FireModeInfo[1]] then
        table.insert(NextShootModeList, FireModeInfo[2])
      end
    end
    for ArrayIndex, ArrayElement in pairs(NextShootModeList) do
      if ShootTypeFromEntity == ArrayElement then
        NextIndex = ArrayIndex
        return NextShootModeList[NextIndex % #NextShootModeList + 1]
      end
    end
  elseif ShootTypeFromEntity == ESTEWeaponShootType.OneBulletBursting then
    if ShootWeaponEntityComponent.bHasBurstFireMode then
      return ESTEWeaponShootType.MultiBulletsBursting
    else
      return ESTEWeaponShootType.Auto
    end
  elseif ShootTypeFromEntity == ESTEWeaponShootType.MultiBulletsBursting then
    if ShootWeaponEntityComponent.bHasAutoFireMode or ShootWeapon.SpecialFixShootType > ESTEWeaponShootType.None then
      return ESTEWeaponShootType.Auto
    else
      return ESTEWeaponShootType.OneBulletBursting
    end
  elseif ShootTypeFromEntity == ESTEWeaponShootType.Auto then
    if ShootWeaponEntityComponent.bHasSingleFireMode then
      return ESTEWeaponShootType.OneBulletBursting
    else
      return ESTEWeaponShootType.MultiBulletsBursting
    end
  end
end
function SwitchWeaponSlotMode2:ShowHideEmbeddedMSwitch(bShow)
  self.CanvasPanel_MSwitch_LSide:SetWidgetVisibility(bShow and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
  self.CanvasPanel_MSwitch:SetWidgetVisibility(bShow and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
  if not bShow then
    local Selected = self.WidgetSwitcher_SlotBtnSelected:GetActiveWidgetIndex()
    local bShowFireModBtn = Selected == 1 and self:CanShowFireModeSwitchBtn(self.CurWeapon)
    EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_FIREMODEVISIBILITY_CHANGE, self.WeaponSlotType, bShowFireModBtn)
    local ModeText = self.Text_Pistol_Fire:GetText()
    local ModeBrush = self.Pistol_Fire_icon.Brush
    EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_FIREMODE_UPDATE, self.WeaponSlotType, ModeText, ModeBrush)
  end
end
function SwitchWeaponSlotMode2:CanShowFireModeSwitchBtn(Weapon)
  if not slua.isValid(Weapon) then
    return false
  end
  if not slua.isValid(Weapon.ShootWeaponComponent) then
    return false
  end
  local ShootWeaponEntityComponent = Weapon.ShootWeaponComponent.ShootWeaponEntityComponent
  if not slua.isValid(ShootWeaponEntityComponent) then
    return false
  end
  local FireModeCount = 0
  for _, FireModeInfo in ipairs(self.FireModeMap) do
    if ShootWeaponEntityComponent[FireModeInfo[1]] then
      FireModeCount = FireModeCount + 1
    end
  end
  if Weapon.SpecialFixShootType and 0 < Weapon.SpecialFixShootType then
    return true
  end
  if 1 < FireModeCount or Weapon:GetExtraShootIntervalFromEntity() > 0.0 then
    return true
  end
  return false
end
function SwitchWeaponSlotMode2:SetFireModeText()
  if not slua.isValid(self.CurWeapon) then
    print(bWriteLog and "-*-*-CurWeapon is null")
    return
  end
  local ModeText, ModeBrush
  ModeText, ModeBrush = self:GetModTextAndBrush()
  if ModeText then
    self.TextBlock_ShootingMode:SetText(ModeText)
    self.Text_Pistol_Fire:SetText(ModeText)
  end
  if ModeBrush then
    if self.Image_ShootingMode then
      self.Image_ShootingMode:SetBrush(ModeBrush)
    end
    self.Pistol_Fire_icon:SetBrush(ModeBrush)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_FIREMODE_UPDATE, self.WeaponSlotType, ModeText, ModeBrush)
end
function SwitchWeaponSlotMode2:GetModTextAndBrush()
  local EWeaponShootIntervalMode = import("EWeaponShootIntervalMode")
  local ESTEWeaponShootType = import("ESTEWeaponShootType")
  local ModeText, ModeBrush
  if not slua.isValid(self.CurWeapon) then
    return
  end
  if self.CurWeapon:GetExtraShootIntervalFromEntity() > 0.0 then
    if 0.0 < self.CurWeapon:GetShootIntervalFromEntity(-1) then
      local CurShootIntervalMode = self.CurWeapon:GetCurShootIntervalMode()
      if CurShootIntervalMode == EWeaponShootIntervalMode.EWeaponShootIntervalMode_A then
        ModeText = self.CurWeapon:GetShootIntervalShowNumberFromEntity()
        ModeBrush = self.FireModeShootRate
      else
        ModeText = self.CurWeapon:GetExtraShootIntervalShowNumberFromEntity()
        ModeBrush = self.FireModeShootExtraRate
      end
    end
  else
    local ShootTypeFromEntity = self.CurWeapon:GetShootTypeFromEntity()
    local ModeInfoMapping = {
      [ESTEWeaponShootType.OneBulletBursting] = {
        "4439",
        self.FireMode_Single
      },
      [ESTEWeaponShootType.MultiBulletsBursting] = {
        "4440",
        self.FireMode_Burst
      },
      [ESTEWeaponShootType.Auto] = {
        "4441",
        self.FireMode_Auto
      },
      [ESTEWeaponShootType.Volley] = {
        "20325",
        self.FireMode_Burst
      }
    }
    local ModeInfo = ModeInfoMapping[ShootTypeFromEntity]
    if ModeInfo then
      ModeText = LocUtil.GetLocalizeResStr(ModeInfo[1])
      ModeBrush = ModeInfo[2]
    end
    print(bWriteLog and "-*-*- Weapon " .. tostring(self.CurWeapon) .. " firemode change to " .. tostring(ShootTypeFromEntity) .. tostring(self.CurWeapon.LastShootType))
    if not self.CurWeapon.GetShootWeaponEntityComponent then
      print(bWriteLog and "Get Next Fire Mode:Shoot Weapon Entity Component Is Null!")
      return
    end
    local ShootWeaponEntityComponent = self.CurWeapon:GetShootWeaponEntityComponent()
    if not slua.isValid(ShootWeaponEntityComponent) then
      print(bWriteLog and "Get Next Fire Mode:Shoot Weapon Entity Component Is Null!")
      return
    end
    if ShootTypeFromEntity == 4 and self.CurWeapon.SpecialFixShootType == 0 and not ShootWeaponEntityComponent.bHasAutoFireMode then
      local USTExtraUIUtils = import("STExtraUIUtils")
      local uPlayerCharacter = GameplayData.GetPlayerCharacter()
      if slua.isValid(uPlayerCharacter) then
        uPlayerCharacter:SetWeaponShootType(1)
        ModeInfo = ModeInfoMapping[1]
        if ModeInfo then
          ModeText = LocUtil.GetLocalizeResStr(ModeInfo[1])
          ModeBrush = ModeInfo[2]
        end
      end
    end
  end
  return ModeText, ModeBrush
end
function SwitchWeaponSlotMode2:SetBorderOpacity(Opacity)
  self.Border_WeaponIcon:SetContentColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, Opacity))
  self.Border_WeaponSlot:SetContentColorAndOpacity(FLinearColor(0.0, 0.0, 0.0, Opacity))
end
function SwitchWeaponSlotMode2:ClearWeaponSlotData()
  if self.WidgetSwitcher_SlotBtnSelected then
    self.WidgetSwitcher_SlotBtnSelected:SetActiveWidgetIndex(0)
    EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_FIREMODEVISIBILITY_CHANGE, self.WeaponSlotType, false)
  end
  if self.Border_WeaponSlot then
    self.Border_WeaponSlot:SetContentColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 0.5))
  end
  if self.Border_WeaponIcon then
    self.Border_WeaponIcon:SetContentColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 0.5))
  end
  if self.TextBlock_WeaponName then
    self.TextBlock_WeaponName:SetText("")
  end
  if self.TextBlock_CurrentNumberOfBullets then
    self.TextBlock_CurrentNumberOfBullets:SetText("")
  end
  if self.TextBlock_MaxNumberOfBullets then
    self.TextBlock_MaxNumberOfBullets:SetText("")
  end
  local ElementsToHide = {
    self.TextBlock_1,
    self.WeaponDurability,
    self.ProfileImg,
    self.CanvasPanel_DP12_Info,
    self.Image_Neostead_Fire_Mode,
    self.Image_Neostead_OneShot_Mode
  }
  for _, Element in ipairs(ElementsToHide) do
    if Element then
      Element:SetWidgetVisibility(ESlateVisibility.Hidden)
    end
  end
  local ElementsToCollapse = {
    self.KillCounterImg,
    self.HitRecordTagUnSelected,
    self.HitRecordTagSelected,
    self.TextBlock_wuqiong
  }
  for _, Element in ipairs(ElementsToCollapse) do
    if Element then
      Element:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
  end
  self:ChangeImageAndTextColor(false)
  if self.SniperDSRBakMagUI then
    self.SniperDSRBakMagUI:Close()
    self.SniperDSRBakMagUI = nil
  end
  print(bWriteLog and "Clear slot data")
  self:ConditionShowBulletBar()
end
function SwitchWeaponSlotMode2:UpdateBulletCounts(Weapon, BulletInWeapon, BulletInBackpack, BulletType)
  if self.SniperDSRBakMagUI then
    self.SniperDSRBakMagUI:UpdateBulletCounts(Weapon)
  end
  local BulletInBackPackNum = 0
  local GetBackPackBulletNum = function(BulletType)
    local PlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(PlayerController) then
      return
    end
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local BackpackComponentFromController = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(PlayerController)
    if slua.isValid(BackpackComponentFromController) then
      local AvatarUtils = import("AvatarUtils")
      local AvailableBulletsNumInBackpackByDefineID = AvatarUtils.GetAvailableBulletsNumInBackpackByDefineID(BackpackComponentFromController, BulletType)
      return AvailableBulletsNumInBackpackByDefineID
    end
  end
  local UpdateCurrentWeaponBulletInfo = function()
    if 0 <= BulletInWeapon then
      if BulletInWeapon ~= self.weaponBulletCount and self.bPlayBulletChangeAnim and self.bCanPlayBulletCountAnim then
        if self.bIsRed then
          self:PlayUserWidgetAnimation(self.Anim_CurrentBullets, 0.0, 1, 0, 1.0)
        else
          self:PlayUserWidgetAnimation(self.BulletChangeAnim, 0.0, 1, 0, 1.0)
        end
      end
      local BulletNumText = self:GetCurrentBulletNumText(Weapon)
      self.TextBlock_CurrentNumberOfBullets:SetText(BulletNumText)
      self.TextBlock_CurrentNumberOfBullets:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if BulletType and BulletType.Type ~= 0 and BulletType.TypeSpecificID ~= 0 then
    self.HorizontalBox_0:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.MaxBulletNumInOneClip = Weapon.CurMaxBulletNumInOneClip
    self:CheckLowBullet()
    local IsUsingGrenadeLaunch = Weapon:IsUsingGrenadeLaunch()
    if IsUsingGrenadeLaunch then
      self.bIsRed = false
      self.bIsYellow = false
      UpdateCurrentWeaponBulletInfo()
    else
      UpdateCurrentWeaponBulletInfo()
    end
    if 0 <= BulletInBackpack then
      self.TextBlock_MaxNumberOfBullets:SetText(tostring(BulletInBackpack))
      self:RefreshMaxAmmoVisible(Weapon)
      if Weapon:GetReloadWithNoCostFromEntity() or self.bNeedShowEndlessBulletNum then
        self.TextBlock_wuqiong:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.Overlay_MaxBulletNum:SetWidgetVisibility(ESlateVisibility.Collapsed)
      else
        self.TextBlock_wuqiong:SetWidgetVisibility(ESlateVisibility.Collapsed)
        self.Overlay_MaxBulletNum:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
      end
    end
    if 0 < BulletInWeapon then
      BulletInBackPackNum = BulletInBackpack
      self:ChangeImageAndTextColor(BulletInBackPackNum == 0 and BulletInWeapon == 0)
    else
      local BulletNum = GetBackPackBulletNum(BulletType)
      BulletInBackPackNum = BulletNum
      self:ChangeImageAndTextColor(BulletInBackPackNum == 0 and BulletInWeapon == 0)
    end
    self.weaponBulletCount = BulletInWeapon
    if self.ShowBarrelBulletNumUI and slua.isValid(Weapon) then
      local InLoadWidget = {}
      InLoadWidget = {
        self.WidgetSwitcher_Slot_01,
        self.WidgetSwitcher_Slot_02
      }
      for ArrayIndex, ArrayElement in pairs(InLoadWidget) do
        if ArrayIndex <= Weapon.CurBulletNumInBarrel then
          ArrayElement:SetActiveWidgetIndex(0)
        else
          ArrayElement:SetActiveWidgetIndex(1)
        end
      end
    end
    if self.bEndlessBullet then
      self.HorizontalBox_0:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.CanvasUnlimited:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.HorizontalBox_0:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self:ChangeImageAndTextColor(false)
  end
  self:ConditionShowBulletBar(Weapon)
end
function SwitchWeaponSlotMode2:ShowProfileImg()
  self.bHideProfileImg = false
  if self.ProfileImg then
    self.ProfileImg:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  end
end
function SwitchWeaponSlotMode2:HideProfileImg()
  self.bHideProfileImg = true
  if self.ProfileImg then
    self.ProfileImg:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function SwitchWeaponSlotMode2:ChangeImageAndTextColor(IsGunRunOutOfAmmo)
  self.bGunOutOfAmmo = IsGunRunOutOfAmmo
  if self.bGunOutOfAmmo then
    self.TextBlock_CurrentNumberOfBullets:SetColorAndOpacity(self.SlateColorOutOfAmmoRed)
    self.TextBlock_1:SetColorAndOpacity(self.SlateColorOutOfAmmoRed)
    self.TextBlock_MaxNumberOfBullets:SetColorAndOpacity(self.SlateColorOutOfAmmoRed)
    self.ProfileImg:SetColorAndOpacity(self.OutOfAmmoRed)
    self:LuaBroadcast("OnGunRunOutOfAmmo")
  else
    self.TextBlock_CurrentNumberOfBullets:SetColorAndOpacity(self.SlateColorNormalAmmoWhite)
    self.TextBlock_1:SetColorAndOpacity(self.SlateColorNormalAmmoWhite)
    self.TextBlock_MaxNumberOfBullets:SetColorAndOpacity(self.SlateColorNormalAmmoWhite)
    self.ProfileImg:SetColorAndOpacity(self.NormalAmmoWhite)
    self:LuaBroadcast("OnGunNormalChangeAmmo")
  end
  if not self.bGunOutOfAmmo and self.WidgetSwitcher_SlotBtnSelected:GetActiveWidgetIndex() == 1 then
    if self.bIsRed then
      if not self.SlateColorRed then
        self.SlateColorRed = FSlateColor(FLinearColor(1.0, 0.0, 0.0, 1.0))
      end
      self.TextBlock_CurrentNumberOfBullets:SetColorAndOpacity(self.SlateColorRed)
    elseif self.bIsYellow then
      if not self.SlateColorYellow then
        self.SlateColorYellow = FSlateColor(FLinearColor(1.0, 0.7, 0.0, 1.0))
      end
      self.TextBlock_CurrentNumberOfBullets:SetColorAndOpacity(self.SlateColorYellow)
    end
  end
end
function SwitchWeaponSlotMode2:Selected_UnSelected(IsSelected)
  print(bWriteLog and string.format("SwitchWeaponSlotMode2:Selected_UnSelected IsSelected=%s, WeaponSlotType=%s, CurWeaponValid=%s", tostring(IsSelected), tostring(self.WeaponSlotType), tostring(slua.isValid(self.CurWeapon))))
  local bShowFireModBtn = false
  if IsSelected then
    self.WidgetSwitcher_SlotBtnSelected:SetActiveWidgetIndex(1)
    self:ChangeImageAndTextColor(self.bGunOutOfAmmo)
    bShowFireModBtn = self:CanShowFireModeSwitchBtn(self.CurWeapon)
  else
    self.WidgetSwitcher_SlotBtnSelected:SetActiveWidgetIndex(0)
    self:ChangeImageAndTextColor(self.bGunOutOfAmmo)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_FIREMODEVISIBILITY_CHANGE, self.WeaponSlotType, bShowFireModBtn)
end
function SwitchWeaponSlotMode2:PlayAnimationInQueue()
  if self:IsAnimationPlaying(self.DX_GetItem) then
  elseif 1 <= self.AnimationQueue:Num() then
    local Icon = self.AnimationQueue:Get(0)
    if slua.isValid(Icon) then
      if self.Item then
        self.Item:SetBrushFromTexture(Icon, false)
      end
      self.AnimationQueue:Remove(0)
      local AsBPSTExtraPlayerController = GameplayData.GetPlayerController()
      local BP_STExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
      local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
      if Game:IsClassOf(AsBPSTExtraPlayerController, BP_STExtraPlayerController) then
        if not slua.isValid(AsBPSTExtraPlayerController.BP_VehicleUser) then
          print(bWriteLog and "SwitchWeaponSlotMode2:PlayAnimationInQueue: AsBPSTExtraPlayerController.BP_VehicleUser is nil")
          return
        end
        local VehicleUserState = AsBPSTExtraPlayerController.BP_VehicleUser.VehicleUserState
        if VehicleUserState == ESTExtraVehicleUserState.EVUS_OutOfVehicle or VehicleUserState == ESTExtraVehicleUserState.EVUS_ASPassenger then
          self:PlayUserWidgetAnimation(self.DX_GetItem, 0.0, 1, 0, 1.0)
          self:AddDXGetitemAnimFinished()
        end
      end
    end
  end
end
function SwitchWeaponSlotMode2:InitAccessoryDescItemUI()
  self.AccessoryDescWiddgetTable = {}
  for i = 1, 4 do
    local AccessoryDescItemUI = UIManager.ShowUI(UIManager.UI_Config_InGame.AccessoryDescItemUI)
    if AccessoryDescItemUI then
      AccessoryDescItemUI:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.Box_AttributeItem:AddChild(AccessoryDescItemUI.UIRoot)
      AccessoryDescItemUI:SetAnchors(0, 0, 1, 1)
      self.AccessoryDescWiddgetTable[i] = AccessoryDescItemUI
    else
      print(bWriteLog and "SwitchWeaponSlotMode2:InitAccessoryDescItemUI: AccessoryDescItemUI is nil")
    end
  end
end
function SwitchWeaponSlotMode2:HideAllAccessoryDesc()
  for ArrayIndex, ArrayElement in pairs(self.AccessoryDescWiddgetTable) do
    ArrayElement:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function SwitchWeaponSlotMode2:ShowItemAccessoryDesc(ItemID)
  print(bWriteLog and "PistolSlotModeBase:UpdateAccessoryDesc")
  local UIRoot = self.UIRoot
  local AccessoryDescData = CDataTable.GetTableData("AccessoryDesc", ItemID)
  if not AccessoryDescData then
    print(bWriteLog and "SwitchWeaponSlotMode2:ShowItemAccessoryDesc: AccessoryDescData is nil")
    return
  end
  local MarksArray = AccessoryDescData.Marks_a
  local DescriptionsArray = AccessoryDescData.Descriptions2_a
  if MarksArray:Num() ~= DescriptionsArray:Num() or MarksArray:Num() == 0 then
    print(bWriteLog and "SwitchWeaponSlotMode2:ShowItemAccessoryDesc: MarksArray:Num() ~= DescriptionsArray:Num() or MarksArray:Num() == 0")
    return
  end
  self:HideAllAccessoryDesc()
  local NumOfMarks = MarksArray:Num()
  for Num = 1, NumOfMarks do
    local AccessoryDesc = self.AccessoryDescWiddgetTable[Num]
    if not AccessoryDesc then
      print(bWriteLog and "SwitchWeaponSlotMode2:ShowItemAccessoryDesc: AccessoryDesc is nil" .. tostring(Num))
      return
    end
    if Num <= NumOfMarks then
      AccessoryDesc:UpdateAccessoryDescUI(Num, DescriptionsArray)
    else
      AccessoryDesc:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
  end
end
function SwitchWeaponSlotMode2:AddAttachmentAnimationToQuere(ID)
  local LoadedDelegate = slua.createDelegate(function(Icon)
    self:AddAttachmentAnimationToQuereAsync(Icon, ID)
  end)
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local KismetSystemLibrary = import("KismetSystemLibrary")
  STExtraBlueprintFunctionLibrary.GetAssetByAssetReferenceAsync(KismetSystemLibrary.MakeSoftObjectPath(self:GetAttachmentImage(ID)), LoadedDelegate)
end
function SwitchWeaponSlotMode2:AddAttachmentAnimationToQuereAsync(Icon, ID)
  if Game:IsClassOf(Icon, import("/Script/Engine.Texture2D")) then
    self.AnimationQueue:Add(Icon)
    self:PlayAnimationInQueue()
  end
end
function SwitchWeaponSlotMode2:GetAttachmentImage(DefineID)
  return CDataTable.GetTableData("Item", DefineID.TypeSpecificID).ItemSmallIcon
end
function SwitchWeaponSlotMode2:Show_HideSwitchWeaponTips(NewParam, NewParam1)
  if NewParam then
    self.Tips21_22:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.UTRichTextBlock_Tips22_Text1:SetText(NewParam1.text1)
  else
    self.Tips21_22:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function SwitchWeaponSlotMode2:UpdateFireModeShape(show)
  print(bWriteLog and "SwitchWeaponSlotMode2:UpdateFireModeShape")
  local HidePistolFire = function()
    self.Canvas_Pistol_Fire:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.Button_1:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  if not slua.isValid(self.CurWeapon) then
    print(bWriteLog and string.format("SwitchWeaponSlotMode2:UpdateFireModeShape self.CurWeapon invalid, show=%s, WeaponSlotType=%s", tostring(show), tostring(self.WeaponSlotType)))
    HidePistolFire()
    return
  end
  if show then
    local weaponComp = self:GetWeaponMgr()
    if self:CanShowFireModeSwitchBtn(self.CurWeapon) then
      local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
      if slua.isValid(weaponComp) and slua.isValid(weaponComp:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)) then
        self.Canvas_Pistol_Fire:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.Button_1:SetWidgetVisibility(ESlateVisibility.Collapsed)
      else
        self.Canvas_Pistol_Fire:SetWidgetVisibility(ESlateVisibility.Collapsed)
        self.Button_1:SetWidgetVisibility(ESlateVisibility.Visible)
      end
    else
      HidePistolFire()
    end
  else
    HidePistolFire()
  end
end
function SwitchWeaponSlotMode2:GetWeaponMgr()
  local STExtraUIUtils = import("STExtraUIUtils")
  local OwningPlayerPawnOrVehicleDriver = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self)
  if slua.isValid(OwningPlayerPawnOrVehicleDriver) then
    local WeaponManager = OwningPlayerPawnOrVehicleDriver:GetWeaponManager()
    return WeaponManager
  end
end
function SwitchWeaponSlotMode2:UpdateShield()
  local weaponComp = self:GetWeaponMgr()
  if slua.isValid(weaponComp) then
    local ShieldWeaponSlot = weaponComp:GetShieldWeaponSlot()
    if weaponComp:GetPropSlotByLogicSocket(ShieldWeaponSlot) == self.WeaponSlotType then
      self:SetBorderOpacity(1.0)
      self:UpdateFireModeShape(false)
      self:Selected_UnSelected(true)
    end
  end
end
function SwitchWeaponSlotMode2:ChangeSlotWeapon(Weapon)
  local HideDP12Info = function()
    self.CanvasPanel_DP12_Info:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self:CheckShowXTModeUI()
  end
  local HideNeostead = function()
    self.Image_Neostead_Fire_Mode:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.Image_Neostead_OneShot_Mode:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  self:UnRegistWeaponEvent(self.CurWeapon)
  if self.Anim_FlowLight_01 then
    self:StopAnimation(self.Anim_FlowLight_01)
  end
  if self.Anim_FlowLight_02 then
    self:StopAnimation(self.Anim_FlowLight_02)
  end
  self.CanvasPanel_Reload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if slua.isValid(Weapon) then
    self.Cur    self:RegistWeaponEvent(Weapon)
    self:UpdateWeaponDurability(Weapon)
    local ShootWeaponEntityComponent = Weapon:GetShootWeaponEntityComponent()
    if slua.isValid(ShootWeaponEntityComponent) then
      self.ShowBarrelBulletNumUI = ShootWeaponEntityComponent.bShowBarrelBulletNumUI
      if self.ShowBarrelBulletNumUI then
        self.CanvasPanel_DP12_Info:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self:CheckShowXTModeUI()
      else
        HideDP12Info()
      end
    else
      HideDP12Info()
    end
    if slua.isValid(self.CurWeapon) then
      local ItemDefineID = self.CurWeapon:GetItemDefineID()
      if ItemDefineID.TypeSpecificID == 104102 then
        self.Image_Neostead_Fire_Mode:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.Image_Neostead_OneShot_Mode:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        local STExtraUIUtils = import("STExtraUIUtils")
        local OwningPlayerPawnOrVehicleDriver = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self)
        local AsBPPlayerPawn = OwningPlayerPawnOrVehicleDriver
        local BP_PlayerPawn = import("STExtraPlayerCharacter")
        if Game:IsClassOf(AsBPPlayerPawn, BP_PlayerPawn) then
          self:OnNeosteadFireModeChange(AsBPPlayerPawn.bIsGunADS)
        end
      else
        HideNeostead()
      end
    else
      HideNeostead()
    end
  end
  self:ConditionShowBulletBar(Weapon)
  self:OnWeaponChange(Weapon)
end
function SwitchWeaponSlotMode2:UpdateBulletByWeapon(Weapon, NeedUpdateBackpackNum)
  if not slua.isValid(Weapon) then
    return
  end
  local AvailableBulletsNumInBackpackByDefineID = 0
  if NeedUpdateBackpackNum then
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local AvatarUtils = import("AvatarUtils")
    local ShootWeaponEntity = import("ShootWeaponEntity")
    local IsUsingGrenadeLaunch_1 = Weapon:IsUsingGrenadeLaunch()
    local uPlayerController = GameplayData.GetPlayerController()
    if IsUsingGrenadeLaunch_1 then
      if slua.isValid(uPlayerController) then
        local BackpackComponentFromController = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(uPlayerController)
        if slua.isValid(BackpackComponentFromController) then
          AvailableBulletsNumInBackpackByDefineID = AvatarUtils.GetAvailableBulletsNumInBackpackByDefineID(BackpackComponentFromController, Weapon.GrenadeLaunchComponent.BulletType)
        end
      end
      self:UpdateBulletCounts(Weapon, Weapon.GrenadeLaunchComponent.CurBulletNum, AvailableBulletsNumInBackpackByDefineID, Weapon.GrenadeLaunchComponent.BulletType)
    else
      local AsShootWeaponEntity = Weapon.WeaponEntityComp
      if Game:IsClassOf(AsShootWeaponEntity, ShootWeaponEntity) then
        if slua.isValid(uPlayerController) then
          local BackpackComponentFromController = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(uPlayerController)
          if slua.isValid(BackpackComponentFromController) then
            AvailableBulletsNumInBackpackByDefineID = AvatarUtils.GetAvailableBulletsNumInBackpackByDefineID(BackpackComponentFromController, slua.IndexReference(AsShootWeaponEntity, "BulletType"))
          end
        end
        self:UpdateBulletCounts(Weapon, Weapon:GetCurrentBulletNumInClip(0), AvailableBulletsNumInBackpackByDefineID, slua.IndexReference(AsShootWeaponEntity, "BulletType"))
      end
    end
  else
    local IsUsingGrenadeLaunch = Weapon:IsUsingGrenadeLaunch()
    if IsUsingGrenadeLaunch then
      self:UpdateBulletCounts(Weapon, Weapon.GrenadeLaunchComponent.CurBulletNum, -1, Weapon.GrenadeLaunchComponent.BulletType)
    else
      self:UpdateBulletCounts(Weapon, Weapon:GetCurrentBulletNumInClip(0), -1, Weapon.GetBulletTypeFromEntity and Weapon:GetBulletTypeFromEntity() or nil)
    end
  end
end
function SwitchWeaponSlotMode2:UpdateWeaponDurability(InputWeapon)
  if not slua.isValid(InputWeapon) then
    return
  end
  local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  local IsEnableWeaponDurability = STExtraModLogicSwitchLibrary.IsEnableWeaponDurability()
  if IsEnableWeaponDurability then
    local GlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
    local ConstantWeaponDurabilityFromEntity = InputWeapon:GetConstantWeaponDurabilityFromEntity()
    local OutColor, Status = GlobalBattleUIFunctionLibrary.GetDurabilityColorConfig(InputWeapon:GetWeaponDurability(), ConstantWeaponDurabilityFromEntity, self)
    self.WeaponDurabilityColor = slua.IndexReference(OutColor, "SpecifiedColor")
    self.WeaponDurability    self:UpdateWeaponDurabilityColor()
  end
end
function SwitchWeaponSlotMode2:UpdateWeaponDurabilityColor()
  local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  local IsEnableWeaponDurability = STExtraModLogicSwitchLibrary.IsEnableWeaponDurability()
  if IsEnableWeaponDurability then
    if self.WeaponDurabilityStatus == 0 then
      self.WeaponDurability:SetWidgetVisibility(ESlateVisibility.Hidden)
    else
      self.WeaponDurability:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
      self.WeaponDurability:SetColorAndOpacity(self.WeaponDurabilityColor)
    end
  end
end
function SwitchWeaponSlotMode2:UpdateWeaponDurabilityAnimation()
  if not slua.isValid(self.CurWeapon) then
    return
  end
  local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  local IsEnableWeaponDurability = STExtraModLogicSwitchLibrary.IsEnableWeaponDurability()
  if IsEnableWeaponDurability and self.WeaponDurability:IsVisible() and self.CurWeapon:GetWeaponDurability() <= 0 then
    self:PlayUserWidgetAnimation(self.Anim_WeaponDurability, 0.0, 1, 0, 1.0)
  end
end
function SwitchWeaponSlotMode2:RefreshMaxAmmoVisible(Weapon)
  if slua.isValid(Weapon) then
    local ShootWeaponEntityComponent = Weapon:GetShootWeaponEntityComponent()
    if slua.isValid(ShootWeaponEntityComponent) and ShootWeaponEntityComponent.bAutoDrop then
      self.TextBlock_MaxNumberOfBullets:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.TextBlock_1:SetWidgetVisibility(ESlateVisibility.Collapsed)
      return
    end
  end
  self.TextBlock_1:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_MaxNumberOfBullets:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
end
function SwitchWeaponSlotMode2:IsLowBulletToRed()
  local Ret = self:HasInfinityBullet()
  if Ret or self.CountRed == 0 and self.CountYellow == 0 then
    return false
  elseif self.MaxBulletNumInOneClip > 4 then
    return tonumber(self.TextBlock_CurrentNumberOfBullets:GetText()) <= self.MaxBulletNumInOneClip * self.CountRed
  else
    return false
  end
end
function SwitchWeaponSlotMode2:IsLowBulletToYellow()
  local Ret = self:HasInfinityBullet()
  if Ret or self.CountRed == 0 and self.CountYellow == 0 then
    return false
  elseif self.MaxBulletNumInOneClip > 4 then
    return tonumber(self.TextBlock_CurrentNumberOfBullets:GetText()) <= self.MaxBulletNumInOneClip * self.CountYellow
  else
    return false
  end
end
function SwitchWeaponSlotMode2:SetLeftBulletRate(CountYellow, CountRed)
  self.  self.end
function SwitchWeaponSlotMode2:ClearAnimationQueue()
  self.AnimationQueue:Clear()
end
function SwitchWeaponSlotMode2:StopGetItemAnimation()
  self:StopAnimation(self.DX_GetItem)
end
function SwitchWeaponSlotMode2:GetCurrentBulletNumText(Weapon)
  local CurBulletNumInClip = Weapon:GetCurrentBulletNumInClip(2)
  if Weapon:GetClipHasInfiniteBulletsFromEntity() then
    return "\226\136\158"
  end
  return tostring(CurBulletNumInClip)
end
function SwitchWeaponSlotMode2:HasInfinityBullet()
  if slua.isValid(self.CurWeapon) and self.CurWeapon:GetClipHasInfiniteBulletsFromEntity() then
    return true
  end
  return false
end
function SwitchWeaponSlotMode2:CheckLowBullet()
  local CurNumOfBullets = 0
  local NoLimit = false
  local IsInfinity = self:HasInfinityBullet()
  if slua.isValid(self.CurWeapon) then
    local CurBulletNumInClip = self.CurWeapon:GetCurrentBulletNumInClip(2)
    CurNumOfBullets = CurBulletNumInClip
    NoLimit = IsInfinity or self.CountRed == 0 and self.CountYellow == 0 or not (self.MaxBulletNumInOneClip > 4)
    if NoLimit then
      self.bIsRed = false
      self.bIsYellow = false
    else
      self.bIsYellow = CurNumOfBullets <= self.MaxBulletNumInOneClip * self.CountYellow
      self.bIsRed = CurNumOfBullets <= self.MaxBulletNumInOneClip * self.CountRed
    end
  end
end
function SwitchWeaponSlotMode2:HandleWeaponUpdateUpgradeInfo(Weapon)
  if Weapon == self.CurWeapon then
    self:ChangeSlotWeapon(self.CurWeapon)
  end
end
function SwitchWeaponSlotMode2:SetWeaponShootType()
  local STExtraUIUtils = import("STExtraUIUtils")
  local OwningPlayerPawnOrVehicleDriver = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self)
  if slua.isValid(OwningPlayerPawnOrVehicleDriver) then
    OwningPlayerPawnOrVehicleDriver:PlaySwitchFireModeSound()
    if slua.isValid(self.CurWeapon) then
      if self.CurWeapon:GetExtraShootIntervalFromEntity() > 0.0 then
        if slua.isValid(OwningPlayerPawnOrVehicleDriver) then
          OwningPlayerPawnOrVehicleDriver:SwitchWeaponShootInterval(self.CurWeapon)
          print(bWriteLog and "Switch Weapon Shoot Interval")
        end
      else
        local FireMode = self:GetNextFireMode(self.CurWeapon)
        if FireMode then
          OwningPlayerPawnOrVehicleDriver:SetWeaponShootType(FireMode)
        end
        print(bWriteLog and "-*-*- Weapon " .. tostring(self.CurWeapon) .. " firemode  will change to " .. tostring(FireMode))
      end
    else
      print(bWriteLog and "-*-*- Switch firemode btn, cur weapon is null")
    end
  else
    print(bWriteLog and "-*-*- Get Basecharacter fail")
  end
end
function SwitchWeaponSlotMode2:ConditionShowBulletBar(uWeapon)
  if slua.isValid(uWeapon) and uWeapon:IsShowBulletRemainPercentForUI() then
    self.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self.ProgressBar_0:SetPercent(uWeapon:GetCurBulletRemainPercent())
  else
    self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
end
function SwitchWeaponSlotMode2:UnRegistWeaponEvent(uWeapon)
  if slua.isValid(uWeapon) then
    self:RemoveControlEvent(uWeapon, "OnWeaponReloadStartDelegate")
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
    self:RemoveControlEvent(uPlayerCharacter, "OnCharacterWeaponReloadFinish")
  end
end
function SwitchWeaponSlotMode2:RegistWeaponEvent(uWeapon)
  if slua.isValid(uWeapon) then
    self:AddControlEvent(uWeapon, "OnWeaponReloadStartDelegate", self.HandleStartReload, self)
    if uWeapon.HasQuickReload then
      self:BindLuaObjEvent(uWeapon, "OnTriggerQuickReload", self.HandleQuickReload, self)
    end
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
    self:AddControlEvent(uPlayerCharacter, "OnCharacterWeaponReloadFinish", self.HandleReloadFailed, self)
  end
end
function SwitchWeaponSlotMode2:HandleQuickReload()
  self.CanvasPanel_Reload:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:ReloadAnimFinished()
end
function SwitchWeaponSlotMode2:HandleStartReload()
  if slua.isValid(self.CurWeapon) then
    if self.Anim_FlowLight_01 then
      self:StopAnimation(self.Anim_FlowLight_01)
    end
    if self.Anim_FlowLight_02 then
      self:StopAnimation(self.Anim_FlowLight_02)
    end
    self.CanvasPanel_Reload:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.ReloadTime = self.CurWeapon:GetCurReloadTime()
    self:PlayUserWidgetAnimation(self.Anim_FlowLight_01, 0, 1, 0, 1 / self.ReloadTime)
  end
end
function SwitchWeaponSlotMode2:ReloadAnimFinished()
  if self.Anim_FlowLight_02 then
    self:PlayUserWidgetAnimation(self.Anim_FlowLight_02, 0, 1, 0, 1)
  end
end
function SwitchWeaponSlotMode2:LightAnimFinished()
  if slua.isValid(self.CurWeapon) then
    self.CanvasPanel_Reload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function SwitchWeaponSlotMode2:HandleReloadEnd()
  if self.Anim_FlowLight_01 then
    self:StopAnimation(self.Anim_FlowLight_01)
  end
end
function SwitchWeaponSlotMode2:HandleReloadFailed(weapon, IsDSReloadFailed)
  if slua.isValid(weapon) and slua.isValid(self.CurWeapon) and self.CurWeapon == weapon then
    if IsDSReloadFailed then
      if self.Anim_FlowLight_01 then
        self:StopAnimation(self.Anim_FlowLight_01)
      end
      self.CanvasPanel_Reload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self:PlayUserWidgetAnimation(self.Anim_FlowLight_02, 0, 1, 0, 1)
    end
  else
    self.CanvasPanel_Reload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function SwitchWeaponSlotMode2:OnDestroy()
  print(bWriteLog and "SwitchWeaponSlotMode2:OnDestroy")
  self:Dispose()
  if self.SniperDSRBakMagUI then
    self.SniperDSRBakMagUI:Close()
    self.SniperDSRBakMagUI = nil
  end
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, SwitchWeaponSlotMode2)