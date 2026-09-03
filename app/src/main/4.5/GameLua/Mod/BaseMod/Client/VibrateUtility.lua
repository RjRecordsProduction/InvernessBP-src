local VibrateUtilitySubSystem = {}
local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local UBackpackUtils = import("BackpackUtils")
local UGameplayStatics = import("GameplayStatics")
local UViberateSystemManager = import("VibrateSystemManager")
local FVibrateTriggerMainItem = import("VibrateTriggerMainItem")
local FVibrateTriggerSubItem = import("VibrateTriggerSubItem")
local FVibrateTriggerAction = import("VibrateTriggerAction")
local EVibrateTriggerEventType = import("EVibrateTriggerEventType")
local EVibrateTriggerActionType = import("EVibrateTriggerActionType")
local EFreshWeaponStateType = import("EFreshWeaponStateType")
local EVibrateTriggerMainItemType = import("EVibrateTriggerMainItemType")
local EVibrateTriggerSubItemType = import("EVibrateTriggerSubItemType")
local EWeaponSpecialSoundType = import("EWeaponSpecialSoundType")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function VibrateUtilitySubSystem:OnInit()
  print(bWriteLog and "VibrateUtilitySubSystem:OnInit")
  if self.Inited then
    print(bWriteLog and "VibrateUtilitySubSystem:OnInit self.Inited is already inited!")
    return
  end
  self.sLoopTime = "9"
  self.HasInitiedVibrateSystem = false
  self.InVibrationWhiteNameType = 1
  self.bEntireVibrationSwitch = true
  self.bCharacterVibrationSwitch = true
  self.bWeaponVibrationSwitch = true
  self.bVehicleVibrationSwitch = true
  self.bSoundUIVibrationSwitch = true
  self.bEquipWeaponSwitch = true
  self.RadialDamageEventType = 2
  self.VibrateSystemManager = nil
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "PlayerCharacter", function()
    print(bWriteLog and "VibrateUtilitySubSystem:OnInit AddDataListener.PlayerCharacter callback")
    self:InitVibrationSystem()
  end)
  self:InitVibrationSystem()
  self.Inited = true
end
function VibrateUtilitySubSystem:InitVibrationSystem()
  print(bWriteLog and "VibrateUtilitySubSystem:InitVibrationSystem")
  self.VibrateSystemManager = self:GetViberateSystemManager()
  if self.VibrateSystemManager == nil then
    print(bWriteLog and "[error] VibrateUtilitySubSystem:InitVibrationSystem failed, self.VibrateSystemManager is nil!")
    return
  end
  if self.HasInitiedVibrateSystem == true then
    print(bWriteLog and "VibrateUtilitySubSystem:InitVibrationSystem is already inited!")
    return
  end
  self:ResetVibrationData()
  self.InVibrationWhiteNameType = LobbySystem.roleData.phone_vibrate_status or 1
  print(bWriteLog and "VibrateUtilitySubSystem:InitVibrationSystem Current Device InVibrationWhiteNameType =" .. tostring(self.InVibrationWhiteNameType))
  self.bEntireVibrationSwitch = LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS)
  self.bSoundUIVibrationSwitch = LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS_VOICE)
  self.bCharacterVibrationSwitch = LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS_CHARACTER)
  self.bWeaponVibrationSwitch = LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS_WEAPON)
  self.bVehicleVibrationSwitch = LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS_VEHICLE)
  print(bWriteLog and "VibrateUtilitySubSystem:LoadUserSettingData bEntireVibrationSwitch=" .. tostring(self.bEntireVibrationSwitch))
  self.VibrateSystemManager:ModifyEntireVibrationSwitch(self.bEntireVibrationSwitch)
  print(bWriteLog and "VibrateUtilitySubSystem:LoadUserSettingData bSoundUIVibrationSwitch=" .. tostring(self.bSoundUIVibrationSwitch))
  self.VibrateSystemManager:ModifySoundUIVibrationSwitch(self.bSoundUIVibrationSwitch)
  print(bWriteLog and "VibrateUtilitySubSystem:LoadUserSettingData bCharacterVibrationSwitch=" .. tostring(self.bCharacterVibrationSwitch))
  self.VibrateSystemManager:ModifyCharacterVibrationSwitch(self.bCharacterVibrationSwitch)
  print(bWriteLog and "VibrateUtilitySubSystem:LoadUserSettingData bWeaponVibrationSwitch=" .. tostring(self.bWeaponVibrationSwitch))
  self.VibrateSystemManager:ModifyWeaponVibrationSwitch(self.bWeaponVibrationSwitch)
  print(bWriteLog and "VibrateUtilitySubSystem:LoadUserSettingData bVehicleVibrationSwitch=" .. tostring(self.bVehicleVibrationSwitch))
  self.VibrateSystemManager:ModifyVehicleVibrationSwitch(self.bVehicleVibrationSwitch)
  if self.bEntireVibrationSwitch == false then
    print(bWriteLog and "VibrateUtilitySubSystem:InitVibrationSystem bEntireVibrationSwitch is false! VibrationSystem is close!")
    return
  end
  if CGame:IsEditor() then
    print(bWriteLog and "VibrateUtilitySubSystem:InitVibrationSystem IsEditor set self.InVibrationWhiteNameType = 3")
    self.InVibrationWhiteNameType = 3
  end
  if self.InVibrationWhiteNameType <= 1 then
    print(bWriteLog and "VibrateUtilitySubSystem:InitVibrationSystem Current Device is not supported! self.InVibrationWhiteNameType = 1")
    return
  end
  self.VibrateSystemManager:ActiveInGameVibration(true)
  self.VibrateSystemManager:SetVibrationLoopTime(self.sLoopTime or "9")
  self:BindEvent()
  self:LoadUserSettingData()
  self.HasInitiedVibrateSystem = true
  self.WeaponSoundFuncs = {}
  self.WeaponSoundFuncs.LoadBullet = self.OnPlayLoadBulletSound
  self.WeaponSoundFuncs.Magazine = self.OnPlayChangeMagazineSound
  self.WeaponSoundFuncs.MagazineIn = self.OnPlayMagazineInSound
  self.WeaponSoundFuncs.MagazineOut = self.OnPlayMagazineOutSound
  self.WeaponSoundFuncs.Bolt = self.OnPlayPullBoltSound
  self.WeaponSoundFuncs.Shell = self.OnPlayLocalShellDrop
end
function VibrateUtilitySubSystem:HandleWeaponSounds(SoundName, Weapon, Player)
  local SoundFunc = self.WeaponSoundFuncs[SoundName]
  if SoundFunc ~= nil then
    SoundFunc(self, 0, 0, Weapon, Player)
  end
end
function VibrateUtilitySubSystem:BindEvent()
  print(bWriteLog and "VibrateUtilitySubSystem:BindEvent")
  if true == self.bWeaponVibrationSwitch then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TRACESHOOT, self.OnCurrentWeaponFireShot, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_WEAPONSTATE_CHANGED, self.OnCurrentWeaponStateChange, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYEREVENT_WEAPON_NONE_SHOOT, self.OnWeaponNoneShoot, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_CHANGE_SHOOT_TYPE, self.OnPlayerChangeShootType, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_WEAPON_FIRE_SHOT, self.OnWeaponFireShot, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_WEAPON_SHOOT_LAST_BULLET, self.OnWeaponShootLastBullet, self)
    GameplayData.AddSelfPlayerCharacterEvent(self, "OnPlayWeaponSound", self.HandleWeaponSounds, self)
  end
  if true == self.bVehicleVibrationSwitch then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_VEHICLE_HIT_OBSTACAL, self.OnVehicleHitObstacal, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_VEHICLE_BOOSTING_SPEED, self.OnVehicleBoostSpeed, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_VEHICLE_WHEEL_BROKEN, self.OnVehicleWheelsBroken, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_GETONOFF_VEHICLE, self.OnPlayerGetOnOffVehicle, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_VEHICLE_TAKEDAMAGE, self.OnVehicleTakeDamage, self)
  end
  if true == self.bSoundUIVibrationSwitch then
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_VOICECHECK_INFO, self.HandleVoiceCheckInfo, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_VOICECHECK_VEHICLE_INFO, self.HandleVoiceCheckVehicleInfo, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_VOICECHECK_GLASS_INFO, self.HandleVoiceCheckGlassInfo, self)
  end
  if true == self.bCharacterVibrationSwitch then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PARACHUTE_JUMP, self.OnPlayerParachuteJump, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLAYERSTATE_CHANGE_CLIENT, self.OnPlayerStateChanged, self)
  end
  self.VibrateSystemManager = self:GetViberateSystemManager()
  if not slua.isValid(self.VibrateSystemManager) then
    print(bWriteLog and "VibrateUtilitySubSystem:BindEvent ViberateSystemManager is invalid")
    return
  end
  self:AddSettingOptionEvent("HapticSwitch", function(InHapticSwitch)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyEntireVibrationLevel(InHapticSwitch)
    end
  end)
  self:AddSettingOptionEvent("HapticVoiceSwitch", function(InHapticVoiceSwitch)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifySoundUIVibrationLevel(InHapticVoiceSwitch)
    end
  end)
  self:AddSettingOptionEvent("HapticCharacterSwitch", function(HapticCharacterSwitch)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyCharacterVibrationLevel(HapticCharacterSwitch)
    end
  end)
  self:AddSettingOptionEvent("HapticWeaponSwitch", function(HapticWeaponSwitch)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyWeaponVibrationLevel(HapticWeaponSwitch)
    end
  end)
  self:AddSettingOptionEvent("HapticVehicleSwitch", function(HapticVehicleSwitch)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyVehicleVibrationLevel(HapticVehicleSwitch)
    end
  end)
  self:AddSettingOptionEvent("bHapticVoiceStep", function(bHapticVoiceStep)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyFootstepSoundUIVibrateSetting(bHapticVoiceStep)
    end
  end)
  self:AddSettingOptionEvent("bHapticVoiceGrass", function(bHapticVoiceGrass)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyGlassBrokenSoundUIVibrateSetting(bHapticVoiceGrass)
    end
  end)
  self:AddSettingOptionEvent("bHapticVoiceGun", function(bHapticVoiceGun)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyFireShotSoundUIVibrateSetting(bHapticVoiceGun)
    end
  end)
  self:AddSettingOptionEvent("bHapticVoiceVehicle", function(bHapticVoiceVehicle)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyVehicleSoundUIVibrateSetting(bHapticVoiceVehicle)
    end
  end)
  self:AddSettingOptionEvent("bHapticCharacterBeGunAttack", function(bHapticCharacterBeGunAttack)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyCharacterBeHitVibrateSetting(bHapticCharacterBeGunAttack)
    end
  end)
  self:AddSettingOptionEvent("bHapticCharacterBeOtherAttack", function(bHapticCharacterBeOtherAttack)
  end)
  self:AddSettingOptionEvent("bHapticCharacterFall", function(bHapticCharacterFall)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyCharacterFallVibrateSetting(bHapticCharacterFall)
    end
  end)
  self:AddSettingOptionEvent("bHapticWeaponAttachment", function(bHapticWeaponAttachment)
    self.bEquipWeaponSwitch = bHapticWeaponAttachment
  end)
  self:AddSettingOptionEvent("bHapticWeaponAuto", function(bHapticWeaponAuto)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyAutoWeaponVibrateSetting(bHapticWeaponAuto)
    end
  end)
  self:AddSettingOptionEvent("bHapticWeaponSemiAuto", function(bHapticWeaponSemiAuto)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifySemiAutoWeaponVibrateSetting(bHapticWeaponSemiAuto)
    end
  end)
  self:AddSettingOptionEvent("bHapticWeaponSniper", function(bHapticWeaponSniper)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyBoltWeaponVibrateSetting(bHapticWeaponSniper)
    end
  end)
  self:AddSettingOptionEvent("bHapticWeaponOther", function(bHapticWeaponOther)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyOtherWeaponVibrateSetting(bHapticWeaponOther)
    end
  end)
  self:AddSettingOptionEvent("bHapticVehicleDrive", function(bHapticVehicleDrive)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyVehicleEngineVibrationSetting(bHapticVehicleDrive)
    end
  end)
  self:AddSettingOptionEvent("bHapticVehicleBeAttack", function(bHapticVehicleBeAttack)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyVehicleBeHitVibrateSetting(bHapticVehicleBeAttack)
    end
  end)
  self:AddSettingOptionEvent("bHapticVehicleHit", function(bHapticVehicleHit)
    if slua.isValid(self.VibrateSystemManager) then
      self.VibrateSystemManager:ModifyVehicleCrashVibrateSetting(bHapticVehicleHit)
    end
  end)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "VibrateUtilitySubSystem:BindEvent uPlayerController is invalid")
    return
  end
  if true == self.bCharacterVibrationSwitch then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPostTakeDamageDelegate", self.OnPostTakeDamage, self)
  end
  self:BindCharacterDelegate()
end
function VibrateUtilitySubSystem:OnPostTakeDamage(Damage, DamageEvent, EventInstigator, DamageCauser, DamageType)
  print(bWriteLog and "VibrateUtilitySubSystem:BindEvent OnPostTakeDamageDelegate DamageType : " .. DamageType)
  self:OnPlayerPostTakeDamage(DamageType, DamageCauser, false)
end
function VibrateUtilitySubSystem:BindCharacterDelegate()
  print(bWriteLog and "VibrateUtilitySubSystem:BindCharacterDelegate")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "VibrateUtilitySubSystem:BindCharacterDelegate uPlayerController is invalid")
    return
  end
  if not uPlayerController.GetPlayerCharacterSafety then
    return
  end
  local uPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPawn) then
    print(bWriteLog and "VibrateUtilitySubSystem:BindCharacterDelegate uPawn is invalid")
    return
  end
  self.bWeaponVibrationSwitch = LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS_WEAPON)
  if true == self.bWeaponVibrationSwitch then
    if self.CharacterWeaponEquipDelegate ~= nil then
      uPawn.OnCharacterWeaponEquipDelegate:Remove(self.CharacterWeaponEquipDelegate)
      self.CharacterWeaponEquipDelegate = nil
    end
    if self.CharacterWeaponUnEquipDelegate ~= nil then
      uPawn.OnCharacterWeaponEquipDelegate:Remove(self.CharacterWeaponUnEquipDelegate)
      self.CharacterWeaponUnEquipDelegate = nil
    end
    self.CharacterWeaponEquipDelegate = uPawn.OnCharacterWeaponEquipDelegate:Add(function(Weapon, Slot)
      print(bWriteLog and "VibrateUtilitySubSystem:BindCharacterDelegate OnCharacterWeaponEquipDelegate")
      self:OnCharacterWeaponEquip(Weapon, Slot)
    end)
    self.CharacterWeaponUnEquipDelegate = uPawn.OnCharacterWeaponUnEquipDelegate:Add(function(Weapon)
      print(bWriteLog and "VibrateUtilitySubSystem:BindCharacterDelegate OnCharacterWeaponUnEquipDelegate")
      self:OnCharacterWeaponUnEquip(Weapon)
    end)
  end
end
function VibrateUtilitySubSystem:HandleCharacterRespawned()
  self:InitVibrationSystem()
  self:BindCharacterDelegate()
end
function VibrateUtilitySubSystem:GetViberateSystemManager()
  if self.VibrateSystemManager ~= nil then
    return self.VibrateSystemManager
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "VibrateUtilitySubSystem:GetViberateSystemManager PlayerController is invalid")
    return
  end
  if not uPlayerController.GetPlayerCharacterSafety then
    return
  end
  local uPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPawn) then
    print(bWriteLog and "VibrateUtilitySubSystem:GetViberateSystemManager uPawn is invalid")
    return
  end
  self.VibrateSystemManager = UViberateSystemManager.GetInstance(uPawn, false)
  return self.VibrateSystemManager
end
function VibrateUtilitySubSystem:LoadUserSettingData()
  print(bWriteLog and "VibrateUtilitySubSystem:LoadUserSettingData")
  if not slua.isValid(self:GetViberateSystemManager()) then
    print(bWriteLog and "VibrateUtilitySubSystem:LoadUserSettingData ViberateSystemManager is invalid")
    return
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local InCharacterVibrationLevel = SettingModule:GetOptionValue("HapticCharacterSwitch")
  local InWeaponVibrationLevel = SettingModule:GetOptionValue("HapticWeaponSwitch")
  local InVehicleVibrationLevel = SettingModule:GetOptionValue("HapticVehicleSwitch")
  local InSoundUIVibrationLevel = SettingModule:GetOptionValue("HapticVoiceSwitch")
  local bInCharacterBeHitVibrate = SettingModule:GetOptionValue("bHapticCharacterBeGunAttack")
  local bInCharacterClimbVibrate = false
  local bInCharacterFallVibrate = SettingModule:GetOptionValue("bHapticCharacterFall")
  local bInCharacterSwimVibrate = false
  local bInVehicleEngineVibrate = SettingModule:GetOptionValue("bHapticVehicleDrive")
  local bInVehicleBeHitVibrate = SettingModule:GetOptionValue("bHapticVehicleBeAttack")
  local bInVehicleCrashVibrate = SettingModule:GetOptionValue("bHapticVehicleHit")
  local bInFootstepSoundUIVibrate = SettingModule:GetOptionValue("bHapticVoiceStep")
  local bInFireShotSoundUIVibrate = SettingModule:GetOptionValue("bHapticVoiceGun")
  local bInGlassBrokenSoundUIVibrate = SettingModule:GetOptionValue("bHapticVoiceGrass")
  local bInVehicleSoundUIVibrate = SettingModule:GetOptionValue("bHapticVoiceVehicle")
  local InEntireVibrationLevel = SettingModule:GetOptionValue("HapticSwitch")
  local bInAutoWeaponVibrate = SettingModule:GetOptionValue("bHapticWeaponAuto")
  local bInSemiAutoWeaponVibrate = SettingModule:GetOptionValue("bHapticWeaponSemiAuto")
  local bInBoltWeaponVibrate = SettingModule:GetOptionValue("bHapticWeaponSniper")
  local bInOtherWeaponVibrate = SettingModule:GetOptionValue("bHapticWeaponOther")
  self.bEquipWeaponSwitch = SettingModule:GetOptionValue("bHapticWeaponAttachment")
  self.VibrateSystemManager:LoadUserSettingData(InCharacterVibrationLevel, InWeaponVibrationLevel, InVehicleVibrationLevel, InSoundUIVibrationLevel, bInCharacterBeHitVibrate, bInCharacterClimbVibrate, bInCharacterFallVibrate, bInCharacterSwimVibrate, bInVehicleEngineVibrate, bInVehicleBeHitVibrate, bInVehicleCrashVibrate, bInFootstepSoundUIVibrate, bInFireShotSoundUIVibrate, bInGlassBrokenSoundUIVibrate, bInVehicleSoundUIVibrate, InEntireVibrationLevel, bInAutoWeaponVibrate, bInSemiAutoWeaponVibrate, bInBoltWeaponVibrate, bInOtherWeaponVibrate)
  print(bWriteLog and "VibrateUtilitySubSystem:LoadUserSettingData sucessful", InCharacterVibrationLevel, InWeaponVibrationLevel, InVehicleVibrationLevel, InSoundUIVibrationLevel, bInCharacterBeHitVibrate, bInCharacterClimbVibrate, bInCharacterFallVibrate, bInCharacterSwimVibrate, bInVehicleEngineVibrate, bInVehicleBeHitVibrate, bInVehicleCrashVibrate, bInFootstepSoundUIVibrate, bInFireShotSoundUIVibrate, bInGlassBrokenSoundUIVibrate, bInVehicleSoundUIVibrate, InEntireVibrationLevel, bInAutoWeaponVibrate, bInSemiAutoWeaponVibrate, bInBoltWeaponVibrate, bInOtherWeaponVibrate, self.bEquipWeaponSwitch)
end
function VibrateUtilitySubSystem:CheckPlayerCanTriggerViberate(Player)
  if not slua.isValid(Player) or ENetRole.ROLE_Authority == Player.Role then
    return false
  end
  local PC = UGameplayStatics.GetPlayerController(Player, 0)
  if not slua.isValid(PC) then
    return false
  end
  if PC.IsSpectator and PC:IsSpectator() then
    return false
  end
  if PC.IsDemoPlaySpectator and PC:IsDemoPlaySpectator() then
    return false
  end
  if PC.IsInPetSpectator and PC:IsInPetSpectator() then
    return false
  end
  if not PC.GetPlayerCharacterSafety then
    return false
  end
  if ENetRole.ROLE_AutonomousProxy ~= Player.Role and PC:GetPlayerCharacterSafety() ~= Player then
    return false
  end
  return true
end
function VibrateUtilitySubSystem:CheckCanTriggerViberate(ContextObject)
  if not slua.isValid(ContextObject) then
    return false
  end
  local PC = UGameplayStatics.GetPlayerController(ContextObject, 0)
  if not slua.isValid(PC) then
    return false
  end
  if PC.IsSpectator and PC:IsSpectator() then
    return false
  end
  if PC.IsDemoPlaySpectator and PC:IsDemoPlaySpectator() then
    return false
  end
  if PC.IsInPetSpectator and PC:IsInPetSpectator() then
    return false
  end
  return true
end
function VibrateUtilitySubSystem:PostSimpleVibrateTriggerAction(ContextObject, MainItemType, EventType, ActionType)
  if not self:CheckCanTriggerViberate(ContextObject) then
    return
  end
  local VSM = UViberateSystemManager.GetInstance(ContextObject, false)
  if not slua.isValid(VSM) then
    return
  end
  local MainItem = FVibrateTriggerMainItem()
  MainItem.  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:PostPlayerSimpleVibrateTriggerAction(Player, MainItemType, EventType, ActionType, bCheckGate, bCheckInterval)
  if not self:CheckPlayerCanTriggerViberate(Player) then
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    return
  end
  local MainItem = FVibrateTriggerMainItem()
  MainItem.  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, bCheckGate, bCheckInterval, -1)
end
function VibrateUtilitySubSystem:GetWeaponVibrateTriggerItem(Weapon, OwnerPlayerPC, OutMainItem, OutSubItemList)
  if not slua.isValid(Weapon) or not slua.isValid(OwnerPlayerPC) then
    return OutMainItem, OutSubItemList
  end
  local WeaponIDStr = tostring(Weapon:GetItemDefineID().TypeSpecificID)
  OutMainItem = FVibrateTriggerMainItem()
  OutMainItem.MainItemType = EVibrateTriggerMainItemType.Weapon
  OutMainItem.Data = WeaponIDStr
  local AttachmentListData = UBackpackUtils.GetWeaponAttachByWeaponDefineID(Weapon:GetItemDefineID(), OwnerPlayerPC:GetBackpackComponent())
  OutSubItemList:Clear()
  for __, UnitItem in pairs(AttachmentListData) do
    local AttachmentIDStr = tostring(UnitItem.defineID.TypeSpecificID)
    local SubItem = FVibrateTriggerSubItem()
    SubItem.SubItemType = EVibrateTriggerSubItemType.WeaponAttachment
    SubItem.Data = AttachmentIDStr
    OutSubItemList:Add(SubItem)
  end
  return OutMainItem, OutSubItemList
end
function VibrateUtilitySubSystem:OnCurrentWeaponFireShot(_, __, Weapon)
  if not slua.isValid(Weapon) then
    return
  end
  local Player = Weapon:GetOwnerPawn()
  if not self:CheckPlayerCanTriggerViberate(Player) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCurrentWeaponFireShot Failed CasePlayer")
    return
  end
  local PC = UGameplayStatics.GetPlayerController(Player, 0)
  if not slua.isValid(PC) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCurrentWeaponFireShot Failed CasePlayerController")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCurrentWeaponFireShot Failed CaseVSM")
    return
  end
  if not VSM:CheckShootWeaponTypeVibrateGate(Weapon) then
    return
  end
  local EventType = EVibrateTriggerEventType.FireShot
  local ActionType = EVibrateTriggerActionType.Onece
  local MainItem = FVibrateTriggerMainItem()
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  MainItem, SubItems = self:GetWeaponVibrateTriggerItem(Weapon, PC, MainItem, SubItems)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnCurrentWeaponStateChange(_, __, Weapon, LastState, NewState, Player)
  if not slua.isValid(Weapon) or LastState == NewState then
    return
  end
  if not self:CheckPlayerCanTriggerViberate(Player) then
    return
  end
  local PC = UGameplayStatics.GetPlayerController(Player, 0)
  if not slua.isValid(PC) then
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not VSM then
    return
  end
  if not VSM:CheckShootWeaponTypeVibrateGate(Weapon) then
    return
  end
  local EventType = EVibrateTriggerEventType.None
  local ActionType = EVibrateTriggerActionType.None
  if EFreshWeaponStateType.FreshWeaponStateType_Idle == NewState and EFreshWeaponStateType.FreshWeaponStateType_PreFire == LastState then
    EventType = EVibrateTriggerEventType.BoltEnd
    ActionType = EVibrateTriggerActionType.Stop
  elseif EFreshWeaponStateType.FreshWeaponStateType_IdleToBackpack == NewState then
  elseif EFreshWeaponStateType.FreshWeaponStateType_BackpackToIdle == NewState then
  elseif EFreshWeaponStateType.Reload == NewState then
    EventType = EVibrateTriggerEventType.ReloadStart
    ActionType = EVibrateTriggerActionType.Start
  elseif EFreshWeaponStateType.FreshWeaponStateType_PreFire == NewState then
    EventType = EVibrateTriggerEventType.BoltStart
    ActionType = EVibrateTriggerActionType.Start
  end
  if EFreshWeaponStateType.FreshWeaponStateType_Reload == LastState then
    EventType = EVibrateTriggerEventType.ReloadEnd
    ActionType = EVibrateTriggerActionType.Onece
  elseif EFreshWeaponStateType.FreshWeaponStateType_PreFire == LastState then
    EventType = EVibrateTriggerEventType.BoltEnd
    ActionType = EVibrateTriggerActionType.Onece
  end
  if EVibrateTriggerEventType.None == EventType then
    return
  end
  local MainItem = FVibrateTriggerMainItem()
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  MainItem, SubItems = self:GetWeaponVibrateTriggerItem(Weapon, PC, MainItem, SubItems)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnWeaponNoneShoot(_, __, InWeapon, InCharacter)
  if not slua.isValid(InWeapon) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponNoneShoot Failed")
    return
  end
  local Player = InWeapon:GetOwnerPawn()
  if not slua.isValid(Player) or not self:CheckPlayerCanTriggerViberate(Player) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponNoneShoot Failed CasePlayer")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponNoneShoot Failed CaseVSM")
    return
  end
  if not VSM:CheckShootWeaponTypeVibrateGate(InWeapon) then
    return
  end
  local EventType = EVibrateTriggerEventType.NoneShoot
  local ActionType = EVibrateTriggerActionType.Onece
  local MainItem = FVibrateTriggerMainItem()
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  MainItem.MainItemType = EVibrateTriggerMainItemType.Weapon
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnPlayerChangeShootType(_, __, InWeapon, InCharacter)
  if not slua.isValid(InCharacter) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerChangeShootType Failed")
    return
  end
  local Player = InWeapon:GetOwnerPawn()
  if not slua.isValid(Player) or not self:CheckPlayerCanTriggerViberate(Player) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerChangeShootType Failed CasePlayer")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerChangeShootType Failed CaseVSM")
    return
  end
  if not VSM:CheckShootWeaponTypeVibrateGate(InWeapon) then
    return
  end
  local EventType = EVibrateTriggerEventType.ChangeShootType
  local ActionType = EVibrateTriggerActionType.Onece
  self:PostPlayerSimpleVibrateTriggerAction(InCharacter, EVibrateTriggerMainItemType.Character, EventType, ActionType, true, true)
end
function VibrateUtilitySubSystem:OnWeaponFireShot(_, __, InWeapon)
  if not slua.isValid(InWeapon) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponFireShot Failed")
    return
  end
  local Player = InWeapon:GetOwnerPawn()
  if not slua.isValid(Player) or not self:CheckPlayerCanTriggerViberate(Player) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponFireShot Failed CasePlayer")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponFireShot Failed CaseVSM")
    return
  end
  if not VSM:CheckShootWeaponTypeVibrateGate(InWeapon) then
    return
  end
  local PC = UGameplayStatics.GetPlayerController(Player, 0)
  if not slua.isValid(PC) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponFireShot Failed PC is invalid")
    return
  end
  local EventType = EVibrateTriggerEventType.FireShot
  local ActionType = EVibrateTriggerActionType.Onece
  local MainItem = FVibrateTriggerMainItem()
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  MainItem, SubItems = self:GetWeaponVibrateTriggerItem(InWeapon, PC, MainItem, SubItems)
  MainItem.MainItemType = EVibrateTriggerMainItemType.Weapon
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnWeaponShootLastBullet(_, __, InWeapon, InCharacter)
  print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponShootLastBullet")
  if not slua.isValid(InWeapon) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponShootLastBullet Failed")
    return
  end
  local Player = InWeapon:GetOwnerPawn()
  if not slua.isValid(Player) or not self:CheckPlayerCanTriggerViberate(Player) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponShootLastBullet Failed CasePlayer")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnWeaponShootLastBullet Failed CaseVSM")
    return
  end
  if not VSM:CheckShootWeaponTypeVibrateGate(InWeapon) then
    return
  end
  local EventType = EVibrateTriggerEventType.ShootLastBullet
  local ActionType = EVibrateTriggerActionType.Onece
  local MainItem = FVibrateTriggerMainItem()
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  MainItem.MainItemType = EVibrateTriggerMainItemType.Weapon
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:PostPlayerWeaponSimpleVibrateTriggerAction(Player, Weapon, EventType, ActionType)
  if not slua.isValid(Weapon) or ENetRole.SimulatedProxy == Weapon.Role then
    return
  end
  if not self:CheckPlayerCanTriggerViberate(Player) then
    return
  end
  local PC = UGameplayStatics.GetPlayerController(Player, 0)
  if not slua.isValid(PC) then
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    return
  end
  if not VSM:CheckShootWeaponTypeVibrateGate(Weapon) then
    return
  end
  local MainItem = FVibrateTriggerMainItem()
  MainItem.MainItemType = EVibrateTriggerMainItemType.Weapon
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  MainItem, SubItems = self:GetWeaponVibrateTriggerItem(Weapon, PC, MainItem, SubItems)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnPlayWeaponSpecialSound(Weapon, Player, SoundType)
  if not (slua.isValid(Weapon) and slua.isValid(Player)) or not self:CheckPlayerCanTriggerViberate(Player) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayWeaponSpecialSound Failed CaseWeapon 0")
    return
  end
  local PC = UGameplayStatics.GetPlayerController(Player, 0)
  if not slua.isValid(PC) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayWeaponSpecialSound Failed PlayerController")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayWeaponSpecialSound Failed VSM")
    return
  end
  if not VSM:CheckShootWeaponTypeVibrateGate(Weapon) then
    return
  end
  local EventType = EVibrateTriggerEventType.None
  local ActionType = EVibrateTriggerActionType.None
  if EWeaponSpecialSoundType.LoadBullet == SoundType and Player:HasState(EPawnState.GunReload) then
    EventType = EVibrateTriggerEventType.LoadBulletOnReload
    ActionType = EVibrateTriggerActionType.Onece
  elseif EWeaponSpecialSoundType.ChangeMagazine == SoundType then
    EventType = EVibrateTriggerEventType.ChangeMagazine
    ActionType = EVibrateTriggerActionType.Onece
  elseif EWeaponSpecialSoundType.MagIn == SoundType then
    EventType = EVibrateTriggerEventType.MagIn
    ActionType = EVibrateTriggerActionType.Onece
  elseif EWeaponSpecialSoundType.MagOut == SoundType then
    EventType = EVibrateTriggerEventType.MagOut
    ActionType = EVibrateTriggerActionType.Onece
  elseif EWeaponSpecialSoundType.PullBolt == SoundType then
    EventType = EVibrateTriggerEventType.PullBolt
    ActionType = EVibrateTriggerActionType.Onece
  elseif EWeaponSpecialSoundType.LocalShellDrop == SoundType then
    EventType = EVibrateTriggerEventType.LocalShellDrop
    ActionType = EVibrateTriggerActionType.Onece
  end
  if EVibrateTriggerEventType.None == EventType then
    return
  end
  local MainItem = FVibrateTriggerMainItem()
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  MainItem, SubItems = self:GetWeaponVibrateTriggerItem(Weapon, PC, MainItem, SubItems)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnPlayLoadBulletSound(_, __, Weapon, Player)
  local SoundType = EWeaponSpecialSoundType.LoadBullet
  self:OnPlayWeaponSpecialSound(Weapon, Player, SoundType)
end
function VibrateUtilitySubSystem:OnPlayChangeMagazineSound(_, __, Weapon, Player)
  local SoundType = EWeaponSpecialSoundType.ChangeMagazine
  self:OnPlayWeaponSpecialSound(Weapon, Player, SoundType)
end
function VibrateUtilitySubSystem:OnPlayPullBoltSound(_, __, Weapon, Player)
  local SoundType = EWeaponSpecialSoundType.PullBolt
  self:OnPlayWeaponSpecialSound(Weapon, Player, SoundType)
end
function VibrateUtilitySubSystem:OnPlayMagazineInSound(_, __, Weapon, Player)
  local SoundType = EWeaponSpecialSoundType.MagIn
  self:OnPlayWeaponSpecialSound(Weapon, Player, SoundType)
end
function VibrateUtilitySubSystem:OnPlayMagazineOutSound(_, __, Weapon, Player)
  local SoundType = EWeaponSpecialSoundType.MagOut
  self:OnPlayWeaponSpecialSound(Weapon, Player, SoundType)
end
function VibrateUtilitySubSystem:OnPlayLocalShellDrop(_, __, Weapon, Player)
  local SoundType = EWeaponSpecialSoundType.LocalShellDrop
  self:OnPlayWeaponSpecialSound(Weapon, Player, SoundType)
end
function VibrateUtilitySubSystem:PostVehicleVibrateTriggerAction(InVehicle, InEventType)
  if self.bVehicleVibrationSwitch == false then
    return
  end
  if not slua.isValid(InVehicle) then
    return
  end
  local PlayerController = UGameplayStatics.GetPlayerController(InVehicle, 0)
  if not slua.isValid(PlayerController) then
    return
  end
  if not PlayerController.GetPlayerCharacterSafety then
    return
  end
  local Player = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(Player) or Player:GetCurrentVehicle() ~= InVehicle then
    return
  end
  if not self:CheckPlayerCanTriggerViberate(Player) then
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    return
  end
  local MainItem = FVibrateTriggerMainItem()
  MainItem.MainItemType = EVibrateTriggerMainItemType.Vehicle
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.TriggerEventType = InEventType
  TriggerAction.TriggerActionType = EVibrateTriggerActionType.Onece
  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnVehicleWheelsBroken(_, __, InVehicle)
  print(bWriteLog and "VibrateUtilitySubSystem:OnVehicleWheelsBroken")
  local EventType = EVibrateTriggerEventType.VehicleWheelsBroken
  self:PostVehicleVibrateTriggerAction(InVehicle, EventType)
end
function VibrateUtilitySubSystem:OnVehicleHitObstacal(_, __, InVehicle)
  print(bWriteLog and "VibrateUtilitySubSystem:OnVehicleHitObstacal")
  local EventType = EVibrateTriggerEventType.VehicleHitObstacal
  self:PostVehicleVibrateTriggerAction(InVehicle, EventType)
end
function VibrateUtilitySubSystem:OnVehicleBoostSpeed(_, __, InVehicle)
  print(bWriteLog and "VibrateUtilitySubSystem:OnVehicleBoostSpeed")
  local EventType = EVibrateTriggerEventType.VehicleBoostSpeed
  self:PostVehicleVibrateTriggerAction(InVehicle, EventType)
end
function VibrateUtilitySubSystem:OnVehicleTakeDamage(_, __, InVehicle, Damage, LeftHP, DamageType, DamageCauser)
  if UEnums.DamageType.ShootDamage == DamageType or UEnums.DamageType.RadialDamage == DamageType then
    local EventType = EVibrateTriggerEventType.VehicleHitByBullet
    self:PostVehicleVibrateTriggerAction(InVehicle, EventType)
  end
end
function VibrateUtilitySubSystem:OnPlayerGetOnOffVehicle(_, __, InVehicle, InCharacter, bGetOn)
  if self.bVehicleVibrationSwitch == false then
    return
  end
  if not (slua.isValid(InVehicle) and slua.isValid(InCharacter)) or not self:CheckPlayerCanTriggerViberate(InCharacter) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerGetOnOffVehicle Failed")
    return
  end
  local PC = UGameplayStatics.GetPlayerController(InCharacter, 0)
  if not slua.isValid(PC) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerGetOnOffVehicle Failed PC is invalid")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(InCharacter, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerGetOnOffVehicle Failed VSM")
    return
  end
  local ActionType = EVibrateTriggerActionType.Onece
  local EventType = EVibrateTriggerEventType.None
  if bGetOn == true then
    EventType = EVibrateTriggerEventType.VehicleGetOn
  else
    EventType = EVibrateTriggerEventType.VehicleGetOff
  end
  local MainItem = FVibrateTriggerMainItem()
  MainItem.MainItemType = EVibrateTriggerMainItemType.Vehicle
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:GetVehicleVibrateTriggerItem(Vehicle, OutMainItem, OutSubItemList)
  if not slua.isValid(Vehicle) then
    return OutMainItem, OutSubItemList
  end
  OutMainItem.MainItemType = EVibrateTriggerMainItemType.Vehicle
  local ASTExtraWheeledVehicle = import("STExtraWheeledVehicle")
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  if not GameLuaAPI.IsClassOf(Vehicle, ASTExtraWheeledVehicle) then
    return OutMainItem, OutSubItemList
  end
  local GearStr = Vehicle:GetCurrentGear()
  local SubItem = FVibrateTriggerSubItem()
  SubItem.SubItemType = EVibrateTriggerSubItemType.VehicleGear
  SubItem.Data = GearStr
  OutSubItemList:Add(SubItem)
  return OutMainItem, OutSubItemList
end
function VibrateUtilitySubSystem:OnPlayerPostTakeDamage(DamageType, DamageCauser, bIsHeadShot)
  local UIUtil = require("client.common.ui_util")
  local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerPostTakeDamage Failed CasePlayerController")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(uPlayerController, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerPostTakeDamage Failed CaseVSM")
    return
  end
  local EventType = EVibrateTriggerEventType.None
  local ActionType = EVibrateTriggerActionType.Onece
  local MainItem = FVibrateTriggerMainItem()
  MainItem.MainItemType = EVibrateTriggerMainItemType.Character
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  local IWeaponOwnerInterface = import("WeaponOwnerInterface")
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerPostTakeDamage DamageType : " .. DamageType)
  if UEnums.DamageType.ShootDamage == DamageType or UEnums.DamageType.STPointDamage == DamageType then
    if bIsHeadShot == true then
      EventType = EVibrateTriggerEventType.HitByBulletOnHead
    else
      EventType = EVibrateTriggerEventType.HitByBulletOnBody
    end
    if slua.isValid(DamageCauser) and GameLuaAPI.IsClassOf(DamageCauser, IWeaponOwnerInterface) then
      local ShootWeapon = DamageCauser:GetCurrentShootWeapon()
      if slua.isValid(ShootWeapon) then
        MainItem, SubItems = self:GetWeaponVibrateTriggerItem(ShootWeapon, ShootWeapon:GetOwnerPlayerController(), MainItem, SubItems)
      end
    end
  elseif UEnums.DamageType.FallingDamage == DamageType then
    EventType = EVibrateTriggerEventType.FallDamage
  elseif UEnums.DamageType.AirAttackDamage == DamageType then
    EventType = EVibrateTriggerEventType.AirAttackDamage
  elseif UEnums.DamageType.VehicleDamage == DamageType then
    EventType = EVibrateTriggerEventType.VehicleImpactDamage
  elseif UEnums.DamageType.GrenadeRadiusDamage == DamageType or UEnums.DamageType.CustomRadiusDamage == DamageType or self.RadialDamageEventType == DamageType then
    EventType = EVibrateTriggerEventType.ExplosionDamage
  elseif UEnums.DamageType.BurningDamage == DamageType then
    EventType = EVibrateTriggerEventType.BurningDamage
  elseif UEnums.DamageType.MeleeDamage == DamageType then
    EventType = EVibrateTriggerEventType.MeleeDamage
  end
  if EVibrateTriggerEventType.None == EventType then
    return
  end
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnTakeDamage(_, __, DamageInfo, IsHeadShotDamage, IsLocalAttacker)
  if IsLocalAttacker ~= true then
    return
  end
  self:OnPlayerPostTakeDamage(DamageInfo.DamageType, DamageInfo.Caster, IsHeadShotDamage)
end
function VibrateUtilitySubSystem:HandleVoiceCheckInfo(_, __, InNowIndex, uCharacter, InPosVector, InIsWeapon, InIsSlience, InWeaponID, InIsExplosion)
  local EventType = EVibrateTriggerEventType.ShowVoiceMove
  if InIsWeapon then
    if InIsExplosion then
      EventType = EVibrateTriggerEventType.ShowVoiceExplosion
    elseif InIsSlience then
      EventType = EVibrateTriggerEventType.ShowVoiceSilenceShoot
    else
      EventType = EVibrateTriggerEventType.ShowVoiceShoot
    end
  else
    EventType = EVibrateTriggerEventType.ShowVoiceMove
  end
  self:PostUIVoiceVibration(EventType)
end
function VibrateUtilitySubSystem:HandleVoiceCheckVehicleInfo(_, __, InNowIndex, InVehicle, InPosVector)
  local EventType = EVibrateTriggerEventType.ShowVoiceVehicle
  self:PostUIVoiceVibration(EventType)
end
function VibrateUtilitySubSystem:HandleVoiceCheckGlassInfo(_, __, InNowIndex, InPosVector)
  local EventType = EVibrateTriggerEventType.ShowVoiceBreakGlass
  self:PostUIVoiceVibration(EventType)
end
function VibrateUtilitySubSystem:PostUIVoiceVibration(InEventType)
  if false == self.bSoundUIVibrationSwitch then
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "VibrateUtilitySubSystem:PostUIVoiceVibration Failed PlayerController")
    return
  end
  if not uPlayerController.GetPlayerCharacterSafety then
    return
  end
  local uPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPawn) then
    return
  end
  local VSM = UViberateSystemManager.GetInstance(uPawn, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:PostUIVoiceVibration Failed VSM")
    return
  end
  local ActionType = EVibrateTriggerActionType.Onece
  local MainItem = FVibrateTriggerMainItem()
  MainItem.MainItemType = EVibrateTriggerMainItemType.ShowVoiceUI
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.TriggerEventType = InEventType
  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnPlayerStateChanged(_, __, InCharacter, InState, bEnterState)
  if not slua.isValid(InCharacter) or not self:CheckPlayerCanTriggerViberate(InCharacter) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerStateChanged Failed")
    return
  end
  local PC = UGameplayStatics.GetPlayerController(InCharacter, 0)
  if not slua.isValid(PC) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerStateChanged Failed PC is invalid")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(InCharacter, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerStateChanged Failed VSM")
    return
  end
  local ActionType = EVibrateTriggerActionType.Onece
  local EventType = EVibrateTriggerEventType.None
  if bEnterState == false then
    if InState == EPawnState.Shoveling then
      EventType = EVibrateTriggerEventType.Shoveling
      VSM:InvalidateVibrateEntityByEventType(EVibrateTriggerEventType.Shoveling)
    end
    return
  end
  local TriggerAction = FVibrateTriggerAction()
  if InState == EPawnState.Dying then
    EventType = EVibrateTriggerEventType.FallOnGround
  elseif InState == EPawnState.Dead then
    EventType = EVibrateTriggerEventType.Dead
  elseif InState == EPawnState.Sprint then
    EventType = EVibrateTriggerEventType.StartSprint
  elseif InState == EPawnState.Shoveling then
    EventType = EVibrateTriggerEventType.Shoveling
  elseif InState == EPawnState.Vault then
    EventType = EVibrateTriggerEventType.Climb
  elseif InState == EPawnState.Swim then
    EventType = EVibrateTriggerEventType.StartSwim
  end
  if EVibrateTriggerEventType.None == EventType then
    return
  end
  self:PostPlayerSimpleVibrateTriggerAction(InCharacter, EVibrateTriggerMainItemType.Character, EventType, ActionType, true, true)
end
function VibrateUtilitySubSystem:OnPlayerLandOnGround(_, __)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerLandOnGround Failed PlayerController")
    return
  end
  if not uPlayerController.GetPlayerCharacterSafety then
    return
  end
  local uPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPawn) then
    return
  end
  local VSM = UViberateSystemManager.GetInstance(uPawn, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerLandOnGround Failed VSM")
    return
  end
  local ActionType = EVibrateTriggerActionType.Onece
  local EventType = EVibrateTriggerEventType.FallOnGround
  local MainItem = FVibrateTriggerMainItem()
  MainItem.MainItemType = EVibrateTriggerMainItemType.Character
  local SubItems = slua.Array(UEnums.EPropertyClass.Struct, FVibrateTriggerSubItem)
  local TriggerAction = FVibrateTriggerAction()
  TriggerAction.Trigger  TriggerAction.TriggerSubItemList = SubItems
  TriggerAction.Trigger  TriggerAction.Trigger  VSM:PostVibrateTriggerAction(TriggerAction, true, true, -1)
end
function VibrateUtilitySubSystem:OnPlayerParachuteJump(_, __, InCharacter)
  if not slua.isValid(InCharacter) or not self:CheckPlayerCanTriggerViberate(InCharacter) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerParachuteJump Failed")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(InCharacter, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnPlayerParachuteJump Failed VSM")
    return
  end
  local EventType = EVibrateTriggerEventType.JumpFromPlane
  local ActionType = EVibrateTriggerActionType.Onece
  self:PostPlayerSimpleVibrateTriggerAction(InCharacter, EVibrateTriggerMainItemType.Character, EventType, ActionType, true, true)
end
function VibrateUtilitySubSystem:OnCharacterWeaponEquip(InWeapon, InSlot)
  if ESurviveWeaponPropSlot.SWPS_HandProp == InSlot then
    return
  end
  if not slua.isValid(InWeapon) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCharacterWeaponEquip Failed")
    return
  end
  local Player = InWeapon:GetOwnerPawn()
  if not slua.isValid(Player) or not self:CheckPlayerCanTriggerViberate(Player) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCharacterWeaponEquip Failed CasePlayer")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCharacterWeaponEquip Failed CaseVSM")
    return
  end
  if self.bEquipWeaponSwitch == false then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCharacterWeaponEquip bEquipWeaponSwitch is false")
    return
  end
  local EventType = EVibrateTriggerEventType.EquipWeapon
  local ActionType = EVibrateTriggerActionType.Onece
  self:PostPlayerSimpleVibrateTriggerAction(Player, EVibrateTriggerMainItemType.Character, EventType, ActionType, true, true)
end
function VibrateUtilitySubSystem:OnCharacterWeaponUnEquip(InWeapon)
  if not slua.isValid(InWeapon) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCharacterWeaponUnEquip Failed")
    return
  end
  if "Throw_Socket" == InWeapon:GetWeaponAttachSocket() then
    return
  end
  local Player = InWeapon:GetOwnerPawn()
  if not slua.isValid(Player) or not self:CheckPlayerCanTriggerViberate(Player) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCharacterWeaponUnEquip Failed CasePlayer")
    return
  end
  local VSM = UViberateSystemManager.GetInstance(Player, false)
  if not slua.isValid(VSM) then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCharacterWeaponUnEquip Failed CaseVSM")
    return
  end
  if self.bEquipWeaponSwitch == false then
    print(bWriteLog and "VibrateUtilitySubSystem:OnCharacterWeaponUnEquip bEquipWeaponSwitch is false")
    return
  end
  local EventType = EVibrateTriggerEventType.UnEquipWeapon
  local ActionType = EVibrateTriggerActionType.Onece
  self:PostPlayerSimpleVibrateTriggerAction(Player, EVibrateTriggerMainItemType.Character, EventType, ActionType, true, true)
end
function VibrateUtilitySubSystem:ResetVibrationData()
  self.VibrateSystemManager = self:GetViberateSystemManager()
  if self.VibrateSystemManager then
    printf("VibrateUtilitySubSystem:ResetVibrationData")
    self.VibrateSystemManager:ClearVibratePath2Json()
    self.VibrateSystemManager:ActiveInGameVibration(false)
    self.VibrateSystemManager:ClearAllVibration()
    self.VibrateSystemManager:StopVibrate()
  end
end
function VibrateUtilitySubSystem:OnRelease()
  printf("VibrateUtilitySubSystem:OnRelease")
  self:ResetVibrationData()
  self.CharacterWeaponEquipDelegate = nil
  self.CharacterWeaponUnEquipDelegate = nil
  self.VibrateSystemManager = nil
  self.Inited = false
  VibrateUtilitySubSystem.__super.OnRelease(self)
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, VibrateUtilitySubSystem)