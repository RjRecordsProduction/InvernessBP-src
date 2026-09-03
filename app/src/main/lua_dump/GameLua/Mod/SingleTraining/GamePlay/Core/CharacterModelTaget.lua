local CharacterModelTaget = {}
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
local KismetMathLibrary = import("KismetMathLibrary")
local EAvatarSlotTypeDef = import("EAvatarSlotType")
local FVector_NetQuantize = import("Vector_NetQuantize")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ECollisionEnabled = import("ECollisionEnabled")
function CharacterModelTaget:ctor()
  self.CurrentDamage = 0
  self.HelmetID = -1
  self.ArmorID = -1
  self.bIsHeadShot = false
  self.bHasActive = false
  self.nRifleTotalDamage = 0
  self.ImpactTime = 0
  self.bHideInSpecialTrain = false
  self.LandId = -1
  self.bIsAlreadyHidded = false
  self.nState = 0
  self.uLocation = nil
  self.ImpactPoint = FVector_NetQuantize()
  self.DamageHitPos = 3
end
function CharacterModelTaget:_PostConstruct()
  CharacterModelTaget.__super._PostConstruct(self)
end
function CharacterModelTaget:ReceiveBeginPlay()
  print(bWriteLog and "CharacterModelTaget:ReceiveBeginPlay")
  CharacterModelTaget.__super.ReceiveBeginPlay(self)
  self:EnableRegionBaseNetConsideration()
  self.iRegionCharacter = 20000
  self.bCanEverTick = false
  self:SetActorTickEnabled(false)
  if Client then
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_LOCAL_HANDLE_SHOOT_DAMAGE, self.OnLocalShootDamage, self)
  else
    if slua.isValid(self.HitBox_Stand) then
      self.HitBox_Stand:SetCollisionProfileName("CharacterMesh")
    end
    if slua.isValid(self.HitBox_Prone) then
      self.HitBox_Prone:SetCollisionProfileName("CharacterMesh")
    end
  end
  local EPawnState = import("EPawnState")
  self:EnterState(EPawnState.Imprisonment)
  local EMovementMode = import("EMovementMode")
  self.STCharacterMovement:DisableSimulateCorrection(true)
  self.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_None, 0)
  self.STCharacterMovement:SetActive(false, false)
  if slua.isValid(self.LagCompensationComponent) then
    self.LagCompensationComponent:K2_DestroyComponent(self.LagCompensationComponent)
    self.LagCompensationComponent = nil
  end
end
function CharacterModelTaget:ReceivePossessed(InController)
  if not slua.isValid(InController) then
    return
  end
  print(bWriteLog and "CharacterModelTaget:ReceivePossessed")
  self.Super:ReceivePossessed(InController)
  local uPlayerState = InController.PlayerState
  if slua.isValid(uPlayerState) then
    uPlayerState.bEnableAITraining = true
  end
end
function CharacterModelTaget:ReceiveEndPlay(EndPlayReason)
  CharacterModelTaget.__super.ReceiveEndPlay(self, EndPlayReason)
end
function CharacterModelTaget:BPOnRecycled()
  if Client then
    self:RemoveCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_LOCAL_HANDLE_SHOOT_DAMAGE)
  end
end
function CharacterModelTaget:InitTargetType(nType, nResetTime, bHideInSpecialTrain, LandId, tSpawnLoc)
  self.ModuelID = nType
  self.uLocation = tSpawnLoc
  local tEquipment = SingleTrainingConfig.ModelTagetEquipment
  if nType and tEquipment[nType] then
    local bHasEquipments = false
    if tEquipment[nType].HelmetID > 0 then
      self.HelmetID = tEquipment[nType].HelmetID
      Game:AddItemByResID(self.Object, tEquipment[nType].HelmetID, 1, false, nil, -1, 0, true)
      bHasEquipments = true
    end
    if 0 < tEquipment[nType].ArmorID then
      self.ArmorID = tEquipment[nType].ArmorID
      Game:AddItemByResID(self.Object, tEquipment[nType].ArmorID, 1, false, nil, -1, 0, true)
      bHasEquipments = true
    end
    if bHasEquipments then
      self:AddControlEvent(self, "OnCharacterAttrChangedWithDetail", self.RestoreEquipment, self)
    end
  end
  if bHideInSpecialTrain then
    self.    self:AddCommonEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_MODEL_TAGET_SHOW, self.ShowModelTarget, self)
  end
  if LandId then
    self.  end
end
function CharacterModelTaget:ShowModelTarget(_, __, bShow, LandId)
  if self.bHideInSpecialTrain and LandId == self.LandId then
    print(bWriteLog and " CharacterModelTaget:ShowModelTarget bShow = " .. tostring(bShow) .. " LandId = " .. tostring(LandId))
    if bShow then
      if self.bIsAlreadyHidded then
        self.bIsAlreadyHidded = false
        self:ShowHideModelTarget(true)
        self.nState = 0
      end
    elseif not self.bIsAlreadyHidded then
      self.bIsAlreadyHidded = true
      self:ShowHideModelTarget(false)
      self.nState = 1
    end
  end
end
function CharacterModelTaget:OnRep_nState()
  print(bWriteLog and "CharacterModelTaget:OnRep_nState nState = " .. tostring(self.nState))
  if self.nState == 0 then
    self:ShowHideModelTarget(true)
  elseif self.nState == 1 then
    self:ShowHideModelTarget(false)
  end
end
function CharacterModelTaget:ShowHideModelTarget(bShow)
  print(bWriteLog and "CharacterModelTaget:ShowHideModelTarget bShow = " .. tostring(bShow))
  if Client then
    if bShow then
      self:SetActorHiddenInGame(false)
      self:SetActorEnableCollision(true)
    else
      self:SetActorHiddenInGame(true)
      self:SetActorEnableCollision(false)
    end
    if slua.isValid(self.HitBox_Stand) then
      self.HitBox_Stand:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    end
    if slua.isValid(self.HitBox_Prone) then
      self.HitBox_Prone:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    end
  elseif bShow then
    self:SetActorEnableCollision(true)
    if slua.isValid(self.HitBox_Stand) then
      self.HitBox_Stand:SetCollisionProfileName("CharacterMesh")
    end
    if slua.isValid(self.HitBox_Prone) then
      self.HitBox_Prone:SetCollisionProfileName("CharacterMesh")
    end
  else
    self:SetActorEnableCollision(false)
  end
end
function CharacterModelTaget:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "ModuelID",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int8
    },
    {
      "nState",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int8
    }
  }
end
function CharacterModelTaget:OnLocalShootDamage(_, _, Weapon, TargetActor, Damage, HitBodyType, ImpactPoint)
  if slua.isValid(Weapon) and TargetActor == self.Object then
    print(bWriteLog and "CharacterModelTaget:OnLocalShootDamage Damage = " .. Damage)
    print(bWriteLog and "CharacterModelTaget:GetImpactSound nBodyType = " .. HitBodyType)
    local audio_util = require("client.common.audio_util")
    local tAudios = SingleTrainingConfig.ModelTagetAudioConfig
    local AvatarComp = self:getAvatarComponent2()
    local ArmorDefineId = AvatarComp:GetEquippedItemDefineID(EAvatarSlotTypeDef.EAvatarSlotType_ArmorEquipemtSlot)
    local HelmetDefineId = AvatarComp:GetEquippedItemDefineID(EAvatarSlotTypeDef.EAvatarSlotType_HelmetEquipemtSlot)
    self.bIsHeadShot = false
    if 1 == HitBodyType then
      self.bIsHeadShot = true
    elseif 3 == HitBodyType then
      if self:IsItemDefineIDValid(ArmorDefineId) then
        audio_util.PlayAudioByActorAsync(tAudios.Armor, self.Object)
      else
        audio_util.PlayAudioByActorAsync(tAudios.Body, self.Object)
      end
    elseif 2 == HitBodyType then
      audio_util.PlayAudioByActorAsync(tAudios.Body, self.Object)
    end
    if not self.bHasActive then
      self.bHasActive = true
      EventSystem:postEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_MODEL_TAGET_SHOW_ARROW, self.ModuelID, false, 2)
    end
  end
end
function CharacterModelTaget:CheckIsHeadShot()
  return self.bIsHeadShot
end
function CharacterModelTaget:IsItemDefineIDValid(ItemDefineId)
  local FItemDefineID_INVALID_TYPE = 0
  local FItemDefineID_INVALID_TYPE_SPECIFIC_ID = 0
  return ItemDefineId.Type ~= FItemDefineID_INVALID_TYPE and ItemDefineId.TypeSpecificID ~= FItemDefineID_INVALID_TYPE_SPECIFIC_ID
end
function CharacterModelTaget:BPHandleTakeDamage(uDamageInfo)
  local nCurrentDamage = 0
  if slua.isValid(uDamageInfo) then
    nCurrentDamage = uDamageInfo.Damage
    uDamageInfo.Damage = 0
  else
    return
  end
  if uDamageInfo.DamageType == 4 or uDamageInfo.DamageType == 18 then
    return
  end
  local uAttackCharacter = uDamageInfo.Caster
  if not slua.isValid(uAttackCharacter) then
    print(bWriteLog and "CharacterModelTaget:PostTakeDamageEvent uAttackCharacter Not Valid")
    return
  end
  if not Game:IsPlayer(uAttackCharacter) then
    print(bWriteLog and "CharacterModelTaget:PostTakeDamageEvent Not Player")
    return
  end
  self.DamageHitPos = uDamageInfo.DamageHitPos
  self.ImpactPoint.X = uDamageInfo.ImpactPoint.X
  self.ImpactPoint.Y = uDamageInfo.ImpactPoint.Y
  self.ImpactPoint.Z = uDamageInfo.ImpactPoint.Z
  local uPlayerController = uAttackCharacter:GetPlayerControllerSafety()
  local uWeapon = uAttackCharacter:GetCurrentWeapon()
  if slua.isValid(uPlayerController) and self.DamageHitPos and slua.isValid(self.ImpactPoint) then
    if slua.isValid(uWeapon) then
      local DefineID = uWeapon:GetItemDefineID()
      local TableUtil = require("common.table_util")
      if DefineID and TableUtil.IsInTable(SingleTrainingConfig.ScatterGunIDs, DefineID.TypeSpecificID) then
        print(bWriteLog and "  CharacterModelTaget:PostTakeDamageEvent nRifleTotalDamage" .. self.nRifleTotalDamage)
        self.nRifleTotalDamage = self.nRifleTotalDamage + nCurrentDamage
        if self.ImpactTime <= 0.0 then
          self.ImpactTime = slua.getMiliseconds()
          self:AddGameTimer(0.2, false, function()
            if slua.isValid(self.Object) and slua.isValid(uPlayerController) and self.DamageHitPos and slua.isValid(self.ImpactPoint) then
              uPlayerController:ClientRPC_ShowDamageNum(self.nRifleTotalDamage, self.DamageHitPos, self.ImpactPoint, self.Object, uDamageInfo.DamageType)
              self.nRifleTotalDamage = 0
              self.ImpactTime = 0
            end
          end)
        end
      else
        print(bWriteLog and "CharacterModelTaget:PostTakeDamageEvent Damage = " .. tostring(nCurrentDamage))
        uPlayerController:ClientRPC_ShowDamageNum(nCurrentDamage, self.DamageHitPos, self.ImpactPoint, self.Object, uDamageInfo.DamageType)
      end
    else
      print(bWriteLog and "CharacterModelTaget:PostTakeDamageEvent Damage = " .. tostring(nCurrentDamage))
      uPlayerController:ClientRPC_ShowDamageNum(nCurrentDamage, self.DamageHitPos, self.ImpactPoint, self.Object, uDamageInfo.DamageType)
    end
  end
end
function CharacterModelTaget:ResetCharAnimInstanceClass()
  return
end
function CharacterModelTaget:RestoreEquipment(uCharacter, sAttrName, nValueDelta, nResultValue)
  if nValueDelta < 0 and nResultValue < 1 then
    print(bWriteLog and "CharacterModelTaget:RestoreEquipment sAttrName = " .. sAttrName)
    local nItemId = -1
    if "HeadDuability" == sAttrName then
      nItemId = self.HelmetID
    elseif "BodyDuability" == sAttrName then
      nItemId = self.ArmorID
    end
    if 0 < nItemId then
      self:AddGameTimer(3, false, function()
        Game:AddItemByResID(self.Object, nItemId, 1, false, nil, -1, 0, true)
      end)
    end
  end
end
local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CCharacterModelTaget = class(CCharacterBase, nil, CharacterModelTaget)
return CCharacterModelTaget