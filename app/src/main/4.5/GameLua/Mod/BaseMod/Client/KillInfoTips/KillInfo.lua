local EGameModeType = import("EGameModeType")
local EFatalDamageCharacterType = import("EFatalDamageCharacterType")
local EFatalDamageRelationship = import("EFatalDamageRelationShip")
local ECharacterHealthStatus = import("ECharacterHealthStatus")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local DefaultDamagePath = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_death.killfeed_cause_death"
local HSDBNOKillIconPath = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_condition_HS-DBNO.killfeed_condition_HS-DBNO"
local DBNOKillIconPath = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_condition_DBNO.killfeed_condition_DBNO"
local HSKillIconPath = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_condition_HS.killfeed_condition_HS"
local DefaultWeaponAvatarIconBGPath = "/Game/Arts/UI/NoAtlas/Eliminatedking/Eliminatedking_image__juxing_02.Eliminatedking_image__juxing_02"
local AdditionalWeaponListLua = {
  [107002] = true,
  [107020] = true,
  [602091] = true,
  [108030] = true,
  [604140] = true,
  [42060401] = true
}
local InvalidDamageTypeLua = {
  [UEnums.DamageType.InvalidDamageType] = true,
  [UEnums.DamageType.CustomRadiusDamage] = true,
  [UEnums.DamageType.WinnerFakeDeath] = true,
  [UEnums.DamageType.ZombieDamage] = true,
  [UEnums.DamageType.TopFiveGaveUpDamage] = true,
  [UEnums.DamageType.TyrantMonsterStonedDamage] = true,
  [UEnums.DamageType.CartridgeExplosionDamage] = true,
  [UEnums.DamageType.RadialDamage] = true,
  [UEnums.DamageType.CustomRadialDamage] = true
}
local SpecialDamageTypeLua = {
  [UEnums.DamageType.ShootDamage] = true,
  [UEnums.DamageType.STPointDamage] = true,
  [UEnums.DamageType.RPGExplosionDamage] = true,
  [UEnums.DamageType.GrenadeRadiusDamage] = true,
  [UEnums.DamageType.BurningDamage] = true,
  [UEnums.DamageType.DotDamage] = true
}
local DamageTypeMapIconPath = {
  [UEnums.DamageType.DrowningDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_drown_r.killfeed_cause_drown_r",
  [UEnums.DamageType.GrenadeRadiusDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_grenade.killfeed_cause_grenade",
  [UEnums.DamageType.FallingDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_fall_r.killfeed_cause_fall_r",
  [UEnums.DamageType.MeleeDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_punch_r.killfeed_cause_punch_r",
  [UEnums.DamageType.SkillDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_punch_r.killfeed_cause_punch_r",
  [UEnums.DamageType.PoisonDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_playzone_r.killfeed_cause_playzone_r",
  [UEnums.DamageType.VehicleExplodeRadiusDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_explosion_r.killfeed_cause_explosion_r",
  [UEnums.DamageType.AirAttackDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_explosion_r.killfeed_cause_explosion_r",
  [UEnums.DamageType.BurningDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_ranshaodan.killfeed_cause_ranshaodan",
  [UEnums.DamageType.VehicleDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_vehicle_r.killfeed_cause_vehicle_r",
  [UEnums.DamageType.PoisonFogDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_poison_fog.killfeed_cause_poison_fog",
  [UEnums.DamageType.Resurrection] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_RevivalTower.killfeed_RevivalTower",
  [UEnums.DamageType.LowTemperatureDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_dongsi.killfeed_cause_dongsi",
  [UEnums.DamageType.GasolineCanExplosion] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_explosion_r.killfeed_cause_explosion_r",
  [UEnums.DamageType.LastBreathWithoutRescue] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_death.killfeed_cause_death",
  [UEnums.DamageType.AirDropShelter] = "/Game/Library/Res/Weapons/StructureFlareGrenade/CG030_SignalFlare_Bunker/Arts_UI/Texture/NoAtlas/CG030_SignalFlare_White.CG030_SignalFlare_White"
}
local FatalDamageRelationship2ColorMap = {
  [EFatalDamageRelationship.MyTeamateIsCauser] = FLinearColor(0.274677, 0.896269, 1, 1),
  [EFatalDamageRelationship.MyTeammateIsVictim] = FLinearColor(1, 0.41978, 0.412543, 1),
  [EFatalDamageRelationship.NotRelated] = FLinearColor(1, 1, 1, 1),
  [EFatalDamageRelationship.MyTeammateIsCauserAndVictim] = FLinearColor(1, 1, 1, 1)
}
local FatalDamageCharacterType2WeaponIconMap = {
  [EFatalDamageCharacterType.EMonster] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_Zombie.killfeed_cause_Zombie",
  [EFatalDamageCharacterType.EBoss] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_Boss.killfeed_cause_Boss",
  [EFatalDamageCharacterType.EInfecZombie] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_Zombie.killfeed_cause_Zombie",
  [EFatalDamageCharacterType.EInfecRevenger] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_Macheteknife.killfeed_cause_Macheteknife"
}
local FatalDamageMonsterID2WeaponIconMap = {
  [-4000010] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_ToiletPerson.killfeed_cause_ToiletPerson"
}
local KillInfo = {}
function KillInfo:ctor(selfType)
  self.bShouldFuzzyLua = false
  self.bBattleNationSwitch = false
  self.bAllNationSwitch = false
  self.TipRowNum = 1
end
function KillInfo:Initialize()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local bIsObserver = PlayerController.IsObserver and (PlayerController:IsDemoPlayGlobalObserver() or PlayerController:IsObserver()) or false
  self.bShouldFuzzyLua = not bIsObserver and GameState.bUseFuzzyInformation
  self.bBattleNationSwitch = GlobalData.GetNationSwitch("Battle")
  self.bAllNationSwitch = GlobalData.GetNationSwitch("All")
  self.CanvasPanel_KingElimination_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function KillInfo:Construct()
  if self.Super then
    self.Super:Construct()
  end
  if self.KingEliminationInfoItem then
    self.KingEliminationInfoItem:Close()
    self.KingEliminationInfoItem = nil
  end
  if not self.KingEliminationInfoItem then
    self.KingEliminationInfoItem = UIManager.ShowUI(UIManager.UI_Config.KingEliminationInfoItem)
    if self.KingEliminationInfoItem then
      self.KingEliminationInfoItem:AttachToPanel(self.CanvasPanel_KingElimination_Root)
      self.KingEliminationInfoItem:SetAnchors(0, 0, 1, 1)
      self.KingEliminationInfoItem:SetOffsets(0, 0, 0, 0)
      self.KingEliminationInfoItem:SetAutoSize(true)
      self.CanvasPanel_KingElimination_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function KillInfo:Destruct()
  print(bWriteLog and "[muidarzhang] KillInfo:Destruct")
  if self.KingEliminationInfoItem then
    self.KingEliminationInfoItem:Close()
    self.KingEliminationInfoItem = nil
  end
  if self.PreLoadXSuitEffectHandle then
    local Util = require("client.slua_ui_framework.util")
    Util.ClearAssetAsync(self.PreLoadXSuitEffectHandle)
    self.PreLoadXSuitEffectHandle = nil
  end
  if self.DelayWeaponEffectTimer then
    self:RemoveGameTimer(self.DelayWeaponEffectTimer)
    self.DelayWeaponEffectTimer = nil
  end
  if self.Super then
    self.Super:Destruct()
  end
end
function KillInfo:OnDestroy()
  print(bWriteLog and "[muidarzhang] KillInfo:OnDestroy")
  self:Dispose()
end
function KillInfo:GetGMTestFlag()
  if IsEditor then
    local gm_kill_braodcast = RequireBlackList("blacklist.slua.logic.gm.gm_kill_broadcast")
    return gm_kill_braodcast and gm_kill_braodcast.GetGMTestFlag() or false
  else
    return false
  end
end
function KillInfo:GetWeaponAvatarID(DamageType, CauserWeaponAvatarID, AdditionalParam, expandDataTable)
  if DamageType == UEnums.DamageType.SkillDamage and AdditionalParam ~= nil and type(AdditionalParam) == "number" then
    local ExpandData = slua.LuaArchiverDecode(LuaStateWrapper, expandDataTable) or {}
    if ExpandData ~= nil and ExpandData.ThemeRewardKillInfo and type(ExpandData.ThemeRewardKillInfo) == "table" then
      for RewardID, Info in pairs(ExpandData.ThemeRewardKillInfo) do
        if Info.AvatarID and Info.SkillID and Info.SkillID[AdditionalParam] then
          return Info.AvatarID
        end
      end
    end
  end
  if DamageType == UEnums.DamageType.VehicleDamage then
    return self:GetCauserVehicleSkinID(expandDataTable)
  elseif DamageType == UEnums.DamageType.BurningDamage or DamageType == UEnums.DamageType.GrenadeRadiusDamage then
    local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
    local ExpandDataTable = slua.LuaArchiverDecode(LuaStateWrapper, expandDataTable) or {}
    local ReplaceWeaponID = 0
    if ExpandDataTable.CauserCurHoldingWeaponSkinID and type(ExpandDataTable.CauserCurHoldingWeaponSkinID) == "string" then
      local StringUtil = require("common.string_util")
      local WeaponSkins = StringUtil.Split(ExpandDataTable.CauserCurHoldingWeaponSkinID, "|")
      for k, v in pairs(WeaponSkins) do
        local TempID = AvatarUtil.GetGrenadeKillBindGunID(tonumber(v), CauserWeaponAvatarID)
        if TempID ~= 0 then
          ReplaceWeaponID = TempID
          break
        end
      end
    end
    if ReplaceWeaponID ~= 0 then
      return ReplaceWeaponID
    else
      return CauserWeaponAvatarID
    end
  else
    return CauserWeaponAvatarID
  end
end
function KillInfo:GetCauserVehicleSkinID(expandDataTable)
  expandDataTable = slua.LuaArchiverDecode(LuaStateWrapper, expandDataTable) or {}
  local causerVehicleSkinID = tonumber(expandDataTable.CauserVehicleSkinID or 0)
  return causerVehicleSkinID
end
function KillInfo:GetAnimationWidget(avatarID)
  log(bWriteLog and "KillInfo:GetAnimationWidget")
  if IsEditor and self:GetGMTestFlag() then
    local gm_kill_braodcast = RequireBlackList("blacklist.slua.logic.gm.gm_kill_broadcast")
    local animName = gm_kill_braodcast.WeaponAvatarBattleEffectData.AnimName
    if self[animName] then
      return self[animName]
    end
  end
  local defaultWidget = self.ani_effect
  if avatarID == 0 then
    log(bWriteLog and "KillInfo:GetAnimationWidget, avatarID == 0. ")
    return defaultWidget
  end
  local weaponAvatarBattleEffectCfg = CDataTable.GetTableData("WeaponAvatarBattleEffect", avatarID)
  if weaponAvatarBattleEffectCfg and weaponAvatarBattleEffectCfg.AnimationName then
    log(bWriteLog and string.format("KillInfo:GetAnimationWidget, weaponAvatarBattleEffectCfg.AnimationName:%s", weaponAvatarBattleEffectCfg.AnimationName))
    local animationWidget = self[weaponAvatarBattleEffectCfg.AnimationName]
    if animationWidget then
      return animationWidget
    end
  end
  return defaultWidget
end
function KillInfo:TriggerEffect(WeaponAvatarID, ClothAvatarID)
  log(bWriteLog and "KillInfo:TriggerEffect")
  if slua.isValid(self.EffectWidget) then
    self.EffectWidget:Hide()
  end
  if slua.isValid(self.ClothEffectWidget) then
    self.ClothEffectWidget:Hide()
  end
  if self:GetGMTestFlag() then
    return
  end
  local HasWeaponEffect = false
  local WeaponEffectPath
  local CacheWidget = self.EffectCache:Get(WeaponAvatarID)
  if slua.isValid(CacheWidget) then
    HasWeaponEffect = true
    log(bWriteLog and "KillInfo:TriggerEffect Has Weapon Cache")
  else
    local WeaponCfg = CDataTable.GetTableData("WeaponAvatarBattleEffect", WeaponAvatarID)
    local passive_resource_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.passive_resource_downloader)
    if WeaponCfg and WeaponCfg.EffectPath ~= "" and passive_resource_downloader:CheckResourceHasBeenDownloaded({
      WeaponCfg.EffectPath
    }) then
      HasWeaponEffect = true
      WeaponEffectPath = WeaponCfg.EffectPath
    end
  end
  local HasClothEffect = false
  local ClothEffectPath
  local CacheClothWidget = self.ClothEffectCache:Get(ClothAvatarID)
  if slua.isValid(CacheClothWidget) then
    HasClothEffect = true
    log(bWriteLog and "KillInfo:TriggerEffect Has Cloth Cache")
  else
    local ClothCfg = CDataTable.GetTableData("GoldClothBattleEffect", ClothAvatarID)
    if ClothCfg and ClothCfg.KillEffect ~= "" then
      HasClothEffect = true
      ClothEffectPath = ClothCfg.KillEffect
    end
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if HasWeaponEffect and not HasClothEffect then
    log(bWriteLog and "KillInfo:TriggerEffect Only Weapon")
    if slua.isValid(CacheWidget) then
      log(bWriteLog and "KillInfo:TriggerEffect Only Weapon Use Cache")
      self.EffectWidget = CacheWidget
      self.EffectWidget:Show()
      return
    end
    self.WeaponAvatarIDForLoading = WeaponAvatarID
    STExtraBlueprintFunctionLibrary.GetClassByAssetReferenceAsync(KismetSystemLibrary.MakeSoftObjectPath(WeaponEffectPath), slua.createDelegate(function(Obj)
      self:OnEffectResLoaded(Obj)
    end))
    return
  end
  if HasClothEffect and not HasWeaponEffect then
    log(bWriteLog and "KillInfo:TriggerEffect Only Cloth")
    if slua.isValid(CacheClothWidget) then
      log(bWriteLog and "KillInfo:TriggerEffect Only Cloth Use Cache")
      self.ClothEffectWidget = CacheClothWidget
      self.ClothEffectWidget:Show()
      return
    end
    self.ClothAvatarIDForLoading = ClothAvatarID
    STExtraBlueprintFunctionLibrary.GetClassByAssetReferenceAsync(KismetSystemLibrary.MakeSoftObjectPath(ClothEffectPath), slua.createDelegate(function(Obj)
      self:OnClothEffectResLoaded(Obj)
    end))
    return
  end
  if HasClothEffect and HasWeaponEffect then
    log(bWriteLog and "KillInfo:TriggerEffect All")
    if slua.isValid(CacheWidget) and slua.isValid(CacheClothWidget) then
      log(bWriteLog and "KillInfo:TriggerEffect All Use Cache")
      self.EffectWidget = CacheWidget
      self.EffectWidget:Show()
      self.ClothEffectWidget = CacheClothWidget
      self:DelayShowCloth()
      return
    end
    self.EffectWidget = nil
    if slua.isValid(CacheWidget) then
      self.EffectWidget = CacheWidget
    end
    self.ClothEffectWidget = nil
    if slua.isValid(CacheClothWidget) then
      self.ClothEffectWidget = CacheClothWidget
    end
    if WeaponEffectPath then
      self.WeaponAvatarIDForLoading = WeaponAvatarID
      STExtraBlueprintFunctionLibrary.GetClassByAssetReferenceAsync(KismetSystemLibrary.MakeSoftObjectPath(WeaponEffectPath), slua.createDelegate(function(Obj)
        log(bWriteLog and "KillInfo:TriggerEffect All Weapon Loaded")
        self:OnEffectResLoaded(Obj)
        if slua.isValid(self.ClothEffectWidget) then
          log(bWriteLog and "KillInfo:TriggerEffect All Weapon Loaded, cloth ready")
          self:DelayShowCloth()
        else
          log(bWriteLog and "KillInfo:TriggerEffect All Weapon Loaded, cloth not ready")
        end
      end))
    end
    if ClothEffectPath then
      self.ClothAvatarIDForLoading = ClothAvatarID
      STExtraBlueprintFunctionLibrary.GetClassByAssetReferenceAsync(KismetSystemLibrary.MakeSoftObjectPath(ClothEffectPath), slua.createDelegate(function(Obj)
        log(bWriteLog and "KillInfo:TriggerEffect All Cloth Loaded")
        self:OnClothEffectResLoaded(Obj)
        if slua.isValid(self.GoldClothEffectPanel) then
          self.GoldClothEffectPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
        if slua.isValid(self.EffectWidget) then
          log(bWriteLog and "KillInfo:TriggerEffect All Cloth Loaded, weapon ready")
          if slua.isValid(self.ClothEffectWidget) then
            log(bWriteLog and "KillInfo:TriggerEffect All Cloth Loaded, weapon ready Hide Cloth first")
            self.ClothEffectWidget:Hide()
          end
          self:DelayShowCloth()
        else
          log(bWriteLog and "KillInfo:TriggerEffect All Cloth Loaded, weapon not ready")
          if slua.isValid(self.ClothEffectWidget) then
            self.ClothEffectWidget:Hide()
          end
        end
      end))
    end
    return
  end
end
function KillInfo:DelayShowCloth()
  self:AddGameTimer(0.63, false, function()
    if slua.isValid(self.EffectWidget) then
      self.EffectWidget:Hide()
    end
    if slua.isValid(self.ClothEffectWidget) then
      if slua.isValid(self.GoldClothEffectPanel) then
        self.GoldClothEffectPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      self.ClothEffectWidget:Show()
    end
  end)
end
function KillInfo:SetSkillIcon(DamageType, AdditionalParam, PreviousHealthStatus)
  if DamageType ~= UEnums.DamageType.SkillDamage then
    return
  end
  printf("KillInfo:SetSkillIcon")
  local KillInfoUtil = require("GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfoUtil")
  local SkillIconPath = KillInfoUtil.GetSkillIconPath(DamageType, AdditionalParam, PreviousHealthStatus)
  if SkillIconPath and SkillIconPath ~= "" then
    print(bWriteLog and string.format("KillInfo:SetSkillIcon SkillIconPath:%s", SkillIconPath))
    self.Image_WeaponIcon:SetBrushFromPathAsync(SkillIconPath, true)
    self.Image_WeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function KillInfo:UpdateKillEffect(WeaponAvatarID, DamageRecordData)
  local Util = require("client.slua_ui_framework.util")
  if self.PreLoadXSuitEffectHandle then
    Util.ClearAssetAsync(self.PreLoadXSuitEffectHandle)
    self.PreLoadXSuitEffectHandle = nil
  end
  if self.DelayWeaponEffectTimer then
    print(bWriteLog and "KillInfo:UpdateKillEffect DelayWeaponEffectTimer Removed")
    self:RemoveGameTimer(self.DelayWeaponEffectTimer)
    self.DelayWeaponEffectTimer = nil
  end
  local LogicKillInfo = require("client.slua.logic.kill_info.logic_killinfo")
  local XSuitAvatarID = DamageRecordData.CauserClothAvatarID
  local bHasXSuitEffect = false
  local XSuitCfg = CDataTable.GetTableData("GoldClothBattleEffect", XSuitAvatarID)
  if XSuitCfg and XSuitCfg.KillEffect and XSuitCfg.KillEffect ~= "" then
    bHasXSuitEffect = LogicKillInfo.CheckKillPassiveDownloadByXSuitID(XSuitAvatarID)
  end
  local bHasWeaponEffect = false
  local WeaponCfg = CDataTable.GetTableData("WeaponAvatarBattleEffect", WeaponAvatarID)
  if WeaponCfg and (WeaponCfg.EffectPath and WeaponCfg.EffectPath ~= "" or WeaponCfg.BgPath and WeaponCfg.BgPath ~= "") then
    bHasWeaponEffect = LogicKillInfo.IsWeaponKillInfoAssetDownload(WeaponAvatarID)
  end
  self:PlayAnimIn(WeaponAvatarID)
  if bHasWeaponEffect and bHasXSuitEffect then
    self:UpdateEffect(0)
    self.PreLoadXSuitEffectHandle = Util.GetAssetAsync(XSuitCfg.KillEffect, function(Asset)
      self.PreLoadXSuitEffectHandle = nil
      self:UpdateClothEffect(XSuitAvatarID)
      self:ChangeInfoBgByWeaponAvatarIDLua(WeaponAvatarID)
      local ClothAnimLength = 0
      if slua.isValid(self.ClothEffectWidget) and slua.isValid(self.ClothEffectWidget.ice_effect) and XSuitCfg.KillBroadcastIndependent then
        ClothAnimLength = self.ClothEffectWidget.ice_effect:GetEndTime() or 0
      end
      self.DelayWeaponEffectTimer = self:AddGameTimer(ClothAnimLength, false, function()
        self.DelayWeaponEffectTimer = nil
        self:UpdateEffect(WeaponAvatarID)
        self:PlayKillBroadcastAudio(WeaponAvatarID, DamageRecordData)
      end)
    end)
  elseif bHasWeaponEffect then
    self:UpdateClothEffect(0)
    self:ChangeInfoBgByWeaponAvatarIDLua(WeaponAvatarID)
    self:UpdateEffect(WeaponAvatarID)
    self:PlayKillBroadcastAudio(WeaponAvatarID, DamageRecordData)
  elseif bHasXSuitEffect then
    self:ChangeInfoBgByWeaponAvatarIDLua(0)
    self:UpdateEffect(0)
    self:UpdateClothEffect(XSuitAvatarID)
  else
    self:UpdateEffect(0)
    self:ChangeInfoBgByWeaponAvatarIDLua(0)
    self:UpdateClothEffect(0)
  end
end
function KillInfo:FileItem(DamageRecordData)
  local ResultHealthStatus = DamageRecordData.ResultHealthStatus
  local bResultHealthStatusEQOne = ResultHealthStatus == 1
  local bUseFuzzyLua = self.bShouldFuzzyLua and bResultHealthStatusEQOne
  local CauserName = bUseFuzzyLua and DamageRecordData.FuzzyCauserName or DamageRecordData.Causer
  local VictimName = bUseFuzzyLua and DamageRecordData.FuzzyVictimName or DamageRecordData.VictimName
  self.TextBlock_PlayerName01:SetText(CauserName)
  self.TextBlock_PlayerName02:SetText(VictimName)
  local WeaponIconPath = self:GetWeaponIconPathLua(DamageRecordData.DamageType, DamageRecordData.AdditionalParam, DamageRecordData.PreviousHealthStatus)
  if WeaponIconPath then
    print(bWriteLog and "KillInfo:FileItem Image_WeaponIcon SelfHitTestInvisible")
    self.Image_WeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_WeaponIcon:SetBrushFromPathAsync(WeaponIconPath, true)
  else
    print(bWriteLog and "KillInfo:FileItem Image_WeaponIcon Collapsed")
    self.Image_WeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  end
  self:SetDeadIconLua(DamageRecordData.IsHeadShot, ResultHealthStatus)
  local OBUI_Library = import("/Game/BluePrints/UI/OBUI/Lib/OBUI_Library.OBUI_Library_C")
  local PlayerController = GameplayData.GetPlayerController()
  self.WidgetSwitcher_CustomNationCauser:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.WidgetSwitcher_CustomNationVictim:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if OBUI_Library and slua.isValid(PlayerController) and PlayerController.IsObserver and (PlayerController:IsDemoPlayGlobalObserver() or PlayerController:IsObserver()) then
    local BFind, LogoPath, CauserLogoObject = OBUI_Library.GetCustomTeamLogoByTeamID(DamageRecordData.CauserTeamID, {
      256,
      128,
      64
    }, self)
    print(bWriteLog and "KillInfo:FileItem CauserLogoObject", DamageRecordData.CauserTeamID, CauserLogoObject, BFind, LogoPath, slua.isValid(CauserLogoObject))
    if slua.isValid(CauserLogoObject) then
      self.WidgetSwitcher_CustomNationCauser:SetActiveWidgetIndex(2)
      self.Image_Causer_TeamLogo:SetBrushFromTexture(CauserLogoObject, false)
    else
      self.WidgetSwitcher_CustomNationCauser:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    local _, _, VictimLogoObject = OBUI_Library.GetCustomTeamLogoByTeamID(DamageRecordData.VictimTeamID, {
      256,
      128,
      64
    }, self)
    print(bWriteLog and "KillInfo:FileItem VictimLogoObject", DamageRecordData.VictimTeamID, VictimLogoObject)
    if slua.isValid(VictimLogoObject) then
      self.WidgetSwitcher_CustomNationVictim:SetActiveWidgetIndex(2)
      self.Image_Victim_TeamLogo:SetBrushFromTexture(VictimLogoObject, false)
    else
      self.WidgetSwitcher_CustomNationVictim:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  elseif self.CustomNation then
    self.WidgetSwitcher_CustomNationCauser:SetActiveWidgetIndex(1)
    self.WidgetSwitcher_CustomNationVictim:SetActiveWidgetIndex(1)
    self:SetCustomNation(self.Image_CustomCauser, DamageRecordData.CauserTeamID)
    self:SetCustomNation(self.Image_CustomVictim, DamageRecordData.VictimTeamID)
  else
    self.WidgetSwitcher_CustomNationCauser:SetActiveWidgetIndex(0)
    self.WidgetSwitcher_CustomNationVictim:SetActiveWidgetIndex(0)
    local CauserNation = DamageRecordData.CauserNation
    local VictimNation = DamageRecordData.VictimNation
    if CauserNation ~= "" then
      self:SetNationLua(CauserNation, self.Image_Causer, ResultHealthStatus)
    else
      self.Image_Causer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if VictimNation ~= "" then
      self:SetNationLua(VictimNation, self.Image_Victim, ResultHealthStatus)
    else
      self.Image_Victim:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  local WeaponAvatarID = self:GetWeaponAvatarID(DamageRecordData.DamageType, DamageRecordData.CauserWeaponAvatarID, DamageRecordData.AdditionalParam, DamageRecordData.ExpandDataContent)
  self:UpdateColorLua(DamageRecordData.RecordRelationShip, WeaponAvatarID, DamageRecordData.IsUseColor, DamageRecordData.UseColor)
  self:UpdateKillEffect(WeaponAvatarID, DamageRecordData)
  self:ShowKill(true, 1, true)
  self:SetZombieIconLua(DamageRecordData.CauserType, DamageRecordData.AdditionalParam)
  self:SetSkillIcon(DamageRecordData.DamageType, DamageRecordData.AdditionalParam, DamageRecordData.PreviousHealthStatus)
  self:ShowKingEliminationInfo(DamageRecordData)
end
function KillInfo:PlayKillBroadcastAudio(WeaponAvatarID, DamageRecordData)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local ENetRole = import("ENetRole")
  if PlayerCharacter.Role == ENetRole.ROLE_SimulatedProxy then
    return
  end
  local SelfName = PlayerCharacter:GetPlayerNameSafety()
  if DamageRecordData.Causer ~= SelfName then
    return
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local WeaponID = ItemUpgradeMgr:GetNormalWeaponID(WeaponAvatarID)
  local SoundUnlockCfg = CDataTable.GetTableData("WeaponSkinVoiceCfg", WeaponID)
  if not (SoundUnlockCfg and SoundUnlockCfg.KillBroadcastVoice) or #SoundUnlockCfg.KillBroadcastVoice <= 0 then
    return
  end
  local NeedPlayAudio = false
  if DataMgr then
    local GroupID = ItemUpgradeMgr:GetNormalGroupIDOfWeaponID(WeaponAvatarID)
    if 0 < GroupID then
      local EWeaponOverrideFeatureSwitchType = import("/Script/ShadowTrackerExtra.EWeaponOverrideFeatureSwitchType")
      NeedPlayAudio = DataMgr.IsWeaponSkinFeatureSwitchOn(GroupID, EWeaponOverrideFeatureSwitchType.KillBroadcast)
    end
  else
    print(bWriteLog and "KillInfo:PlayKillBroadcastAudio DataMgr is nil")
  end
  if NeedPlayAudio then
    local audio_util = require("client.common.audio_util")
    print(bWriteLog and "KillInfo:PlayKillBroadcastAudio TryPlayBankAudio")
    return audio_util.TryPlayBankAudio(SoundUnlockCfg.KillBroadcastVoice, SoundUnlockCfg.BankName, nil, false)
  end
end
function KillInfo:ShowKingEliminationInfo(DamageRecordData)
  self.TipRowNum = 1
  self.bHasKingEliminationInfo = false
  self.CanvasPanel_KingElimination_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.PlayerControllerFatalDamageFeature then
    return
  end
  if PlayerController:IsHawkEyeSpectator() or Client.IsWindowsClientReplay() or PlayerController:IsSpectatorOrDemoPlayer() then
    return
  end
  local FatalDamageInfo = slua.LuaArchiverDecode(LuaStateWrapper, DamageRecordData.ExpandDataContent)
  if not FatalDamageInfo or not FatalDamageInfo.KingEliminationInfo then
    return
  end
  local KingEliminationInfo = FatalDamageInfo.KingEliminationInfo
  if not KingEliminationInfo.DeadKingEliminationInfo and not KingEliminationInfo.NewKingEliminationInfo then
    return
  end
  self.CanvasPanel_KingElimination_Root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.KingEliminationInfoItem then
    self.KingEliminationInfoItem:UpdateKingEliminationInfo(DamageRecordData, KingEliminationInfo)
    self.TipRowNum = 2
    self.bHasKingEliminationInfo = true
  end
end
function KillInfo:GetWeaponIconPathLua(DamageType, AdditionalParam, PreviousHealthStatus)
  if AdditionalWeaponListLua[AdditionalParam] then
    local ItemConfig = CDataTable.GetTableData("Item", AdditionalParam)
    if not ItemConfig then
      return
    end
    return ItemConfig.KillWhiteIcon
  end
  if ECharacterHealthStatus.FinishedLastBreath == PreviousHealthStatus then
    return
  end
  if InvalidDamageTypeLua[DamageType] then
    return
  end
  if DamageType == UEnums.DamageType.MeleeDamage then
    if 0 < AdditionalParam then
      local ItemConfig = CDataTable.GetTableData("Item", AdditionalParam)
      if not ItemConfig then
        return
      end
      return ItemConfig.KillWhiteIcon
    else
      return DamageTypeMapIconPath[DamageType]
    end
  end
  if DamageType == UEnums.DamageType.LastBreathWithoutRescue or DamageType == UEnums.DamageType.GasolineCanExplosion then
    return DamageTypeMapIconPath[DamageType]
  end
  if SpecialDamageTypeLua[DamageType] then
    local ItemConfig = CDataTable.GetTableData("Item", AdditionalParam)
    if ItemConfig and ItemConfig.KillWhiteIcon ~= "" then
      return ItemConfig.KillWhiteIcon
    end
  end
  if DamageTypeMapIconPath[DamageType] then
    return DamageTypeMapIconPath[DamageType]
  else
    return DefaultDamagePath
  end
end
function KillInfo:SetDeadIconLua(bIsHeadShot, HealthStatus)
  if HealthStatus == ECharacterHealthStatus.HealthyAlive then
    local GameState = GameplayData.GetGameState()
    if not slua.isValid(GameState) then
      return
    end
    if GameState.GameModeType == EGameModeType.EHeavyWeaponGameMode then
      self.SizeBox_killtype:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.SizeBox_killtype:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.Image_KillType:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    if HealthStatus == ECharacterHealthStatus.HasLastBreath then
      local KillTypeIconPath = bIsHeadShot and HSDBNOKillIconPath or DBNOKillIconPath
      self.Image_KillType:SetBrushFromPathAsync(KillTypeIconPath, true)
    elseif HealthStatus == ECharacterHealthStatus.FinishedLastBreath then
      if bIsHeadShot then
        self.Image_KillType:SetBrushFromPathAsync(HSKillIconPath, true)
      else
        self.SizeBox_killtype:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.Image_KillType:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function KillInfo:ChangeInfoBgByWeaponAvatarIDLua(WeaponAvatarID)
  self:ChangeInfoBgByWeaponAvatarID(WeaponAvatarID)
end
function KillInfo:SetNationLua(Nation, ImgWidget, Type)
  local Final  if self.bShouldFuzzyLua and Type == 1 then
    FinalNation = "G1"
  end
  if self.bBattleNationSwitch and self.bAllNationSwitch then
    ImgWidget:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    local NationInfo = GlobalData.GetNationInfo(FinalNation)
    if NationInfo and NationInfo.res_path then
      ImgWidget:SetBrushFromPathAsync(NationInfo.res_path, false)
    end
  else
    ImgWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function KillInfo:UpdateColorLua(RelationShip, WeaponAvatarID, IsUseColor, UseColor)
  local FinalColor = FLinearColor(1, 1, 1, 1)
  local LogicKillInfo = require("client.slua.logic.kill_info.logic_killinfo")
  local bHasWeaponEffect = false
  local WeaponAvatarConfig = CDataTable.GetTableData("WeaponAvatarBattleEffect", WeaponAvatarID)
  if WeaponAvatarConfig and (WeaponAvatarConfig.EffectPath and WeaponAvatarConfig.EffectPath ~= "" or WeaponAvatarConfig.BgPath and WeaponAvatarConfig.BgPath ~= "") then
    bHasWeaponEffect = LogicKillInfo.IsWeaponKillInfoAssetDownload(WeaponAvatarID)
  end
  if bHasWeaponEffect and WeaponAvatarConfig and WeaponAvatarConfig.IsFixColor == 1 then
    FinalColor = FLinearColor(WeaponAvatarConfig.R / 255.0, WeaponAvatarConfig.G / 255.0, WeaponAvatarConfig.B / 255.0, 1)
  elseif IsUseColor then
    FinalColor = UseColor
  else
    FinalColor = FatalDamageRelationship2ColorMap[RelationShip] or FinalColor
  end
  local SlateFinalColor = FSlateColor(FinalColor)
  self.Image_KillType:SetColorAndOpacity(FinalColor)
  self.Image_WeaponIcon:SetColorAndOpacity(FinalColor)
  self.TextBlock_PlayerName01:SetColorAndOpacity(SlateFinalColor)
  self.TextBlock_PlayerName02:SetColorAndOpacity(SlateFinalColor)
end
function KillInfo:SetZombieIconLua(CauserType, AdditionalParam)
  local IconPath = FatalDamageCharacterType2WeaponIconMap[CauserType]
  if not IconPath then
    return
  end
  local bModMatched = false
  local ModKillInfoCfg = GamePlayTools.GetConfigAfterModRedirect("Client.Config.KillInfoCfg")
  if ModKillInfoCfg then
    if ModKillInfoCfg.FatalDamageCharacterType2WeaponIconMap and ModKillInfoCfg.FatalDamageCharacterType2WeaponIconMap[CauserType] then
      print(bWriteLog and string.format("KillInfo:SetZombieIconLua ModCfg CauserType:%s,path:%s", tostring(CauserType), tostring(ModKillInfoCfg.FatalDamageCharacterType2WeaponIconMap[CauserType])))
      IconPath = ModKillInfoCfg.FatalDamageCharacterType2WeaponIconMap[CauserType]
      bModMatched = true
    elseif AdditionalParam and ModKillInfoCfg.FatalDamageMonsterID2WeaponIconMap and ModKillInfoCfg.FatalDamageMonsterID2WeaponIconMap[AdditionalParam] then
      print(bWriteLog and string.format("KillInfo:SetAdditionalWeaponIcon ModCfg AdditionalParam:%s,path:%s", tostring(AdditionalParam), tostring(ModKillInfoCfg.FatalDamageMonsterID2WeaponIconMap[AdditionalParam])))
      IconPath = ModKillInfoCfg.FatalDamageMonsterID2WeaponIconMap[AdditionalParam]
      bModMatched = true
    end
  end
  if not bModMatched and AdditionalParam and FatalDamageMonsterID2WeaponIconMap[AdditionalParam] then
    print(bWriteLog and "KillInfo:SetZombieIconLua:", AdditionalParam, FatalDamageMonsterID2WeaponIconMap[AdditionalParam])
    IconPath = FatalDamageMonsterID2WeaponIconMap[AdditionalParam]
  end
  self.Image_WeaponIcon:SetBrushFromPathAsync(IconPath, true)
  self.Image_WeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CKillInfo = class(CDelegateContainer, nil, KillInfo)
return CKillInfo