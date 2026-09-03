local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local KingEliminationFeature = {}
local DefaultMaxKillCount = 5
function KingEliminationFeature:ctor()
  self.KillInfoTable = {}
  self.CurrentKingEliminationPlayerKey = -1
  self.LastKingEliminationPlayerKey = -1
  self.FirstKingEliminationPlayerKey = -1
  self.NewKingEliminationInfoTable = {}
  self.DeadKingEliminationInfoTable = {}
end
function KingEliminationFeature:SetDefaultMaxKillCount(NewNum)
  DefaultMaxKillCount = math.max(NewNum - 1, 0)
end
function KingEliminationFeature:ReceiveBeginPlay()
  KingEliminationFeature.__super.ReceiveBeginPlay(self)
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  if self.Owner:IsAuthority() and GamePlayTools.EnableKingElimination() then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CHARACTER_DIED, self.OnCharacterDied, self)
    self:AddCommonEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_PLAYER_RESPAWN, self.OnPlayerRespawn, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_CHAR_KILL, self.HandleOnCharacterKill, self)
  end
end
function KingEliminationFeature:OnPlayerRespawn(_, __, PlayerCharacter)
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local PlayerKey = tonumber(PlayerCharacter.PlayerKey)
  print(bWriteLog and "KingEliminationFeature:OnPlayerRespawn PlayerCharacter: ", PlayerKey)
  if self.KillInfoTable[PlayerKey] then
    self.KillInfoTable[PlayerKey].bIsDead = false
  end
end
function KingEliminationFeature:OnCharacterDied(_, _, VictimPawn)
  if not slua.isValid(VictimPawn) then
    print(bWriteLog and "KingEliminationFeature:OnCharacterDied VictimPawn is not valid")
    return
  end
  local KilledPlayerKey = tonumber(VictimPawn.PlayerKey)
  if self.KillInfoTable[KilledPlayerKey] then
    self.KillInfoTable[KilledPlayerKey].bIsDead = true
  end
  self.NewKingEliminationInfoTable[KilledPlayerKey] = nil
  local KilledPlayerState = GameplayData.GetPlayerState(KilledPlayerKey)
  if slua.isValid(KilledPlayerState) and KilledPlayerState.SetKingEliminationState then
    KilledPlayerState:SetKingEliminationState(false)
  end
  if KilledPlayerKey == self.CurrentKingEliminationPlayerKey then
    self.CurrentKingEliminationPlayerKey = -1
  end
end
function KingEliminationFeature:HandleOnCharacterKill(_, __, KillerPS, VictimPawn, DamageType, AdditionalParam)
  if not slua.isValid(KillerPS) then
    print(bWriteLog and "KingEliminationFeature:HandleOnCharacterKill KillerPS is not valid")
    return
  end
  if not slua.isValid(VictimPawn) then
    print(bWriteLog and "KingEliminationFeature:HandleOnCharacterKill VictimPawn is not valid")
    return
  end
  print(bWriteLog and "KingEliminationFeature:HandleOnCharacterKill-", VictimPawn, Game:IsHuman(VictimPawn), Game:IsMonster(VictimPawn), Game:IsPlayer(VictimPawn), Game:IsAI(VictimPawn))
  local uKillerPawn = KillerPS:GetPlayerCharacter()
  if not Game:IsHuman(VictimPawn) or Game:IsMonster(VictimPawn) or not slua.isValid(uKillerPawn) then
    print(bWriteLog and "KingEliminationFeature:HandleOnCharacterKill VictimPawn is not player")
    return
  end
  local uKillerController = uKillerPawn:GetPlayerControllerSafety()
  local victimController = VictimPawn:GetControllerSafety()
  if not (Game:GetTeamID(VictimPawn) ~= Game:GetTeamID(uKillerPawn) and VictimPawn ~= uKillerPawn and slua.isValid(uKillerController)) or not slua.isValid(victimController) then
    return
  end
  local bIsAI = Game:IsAI(VictimPawn)
  if not Game:IsPlayer(VictimPawn) and not Game:IsAI(VictimPawn) then
    return
  end
  print(bWriteLog and "KingEliminationFeature:HandleOnCharacterKill AI-", VictimPawn.bEnsure, victimController.FakePlayerBornType, victimController.bForceRecordKillNum)
  if VictimPawn.bEnsure and victimController.FakePlayerBornType == 1 and not victimController.bForceRecordKillNum then
    return
  end
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local KillerPlayerKey = tonumber(KillerPS.PlayerKey)
  local KillerPlayerName = KillerPS.PlayerName
  local KilledPlayerKey = tonumber(VictimPawn.PlayerKey)
  local KilledPlayerName = VictimPawn.PlayerName
  print(bWriteLog and "KingEliminationFeature:HandleOnCharacterKill: ", "KillerPlayerKey: ", KillerPlayerKey, "KillerPlayerName: ", KillerPlayerName, "KilledPlayerKey: ", KilledPlayerKey, "KilledPlayerName: ", KilledPlayerName)
  if KilledPlayerKey == self.CurrentKingEliminationPlayerKey then
    self.CurrentKingEliminationPlayerKey = -1
    local KillCount = self.KillInfoTable[KilledPlayerKey].KillCount + 1
    local EffectID = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(KillerPS.UID, ExtendAttribute.EliminationKingEffect)
    self:GenerateDeadKingEliminationInfo(KillerPlayerKey, KillerPlayerName, KilledPlayerKey, KilledPlayerName, KillCount, EffectID)
    print(bWriteLog and "KingEliminationFeature:HandleOnCharacterKill EliminationKing Died: ", "KilledPlayerKey ", KilledPlayerKey, "KilledPlayerName ", KilledPlayerName)
  end
  if not self.KillInfoTable[KillerPlayerKey] then
    self.KillInfoTable[KillerPlayerKey] = {
      PlayerName = KillerPlayerName,
      KillCount = 0,
      bIsDead = false
    }
  end
  if self.KillInfoTable[KilledPlayerKey] then
    self.KillInfoTable[KilledPlayerKey].bIsDead = true
  end
  if self.CurrentKingEliminationPlayerKey == KillerPlayerKey then
    self.KillInfoTable[KillerPlayerKey].KillCount = self.KillInfoTable[KillerPlayerKey].KillCount + 1
  else
    local CurrentMaxKillCount = self:GetCurrentMaxKillCount()
    self.KillInfoTable[KillerPlayerKey].KillCount = self.KillInfoTable[KillerPlayerKey].KillCount + 1
    local KillCount = self.KillInfoTable[KillerPlayerKey].KillCount
    if CurrentMaxKillCount < KillCount and not self.KillInfoTable[KillerPlayerKey].bIsDead then
      self.CurrentKingEliminationPlayerKey = KillerPlayerKey
      local EffectID = self:ResolveKingEliminationEffectID(KillerPS, uKillerPawn)
      if self.FirstKingEliminationPlayerKey == -1 then
        self.FirstKingEliminationPlayerKey = KillerPlayerKey
        self:GenerateNewKingEliminationInfo(KillerPlayerKey, KillerPlayerName, KillCount, true, EffectID)
        print(bWriteLog and "KingEliminationFeature:HandleOnCharacterKill FirstKingEliminationPlayerKey: ", "KillerPlayerKey ", KillerPlayerKey, "KillerPlayerName ", KillerPlayerName)
      else
        self:GenerateNewKingEliminationInfo(KillerPlayerKey, KillerPlayerName, KillCount, false, EffectID)
        print(bWriteLog and "KingEliminationFeature:HandleOnCharacterKill Generate New EliminationKing: ", "KillerPlayerKey ", KillerPlayerKey, "KillerPlayerName ", KillerPlayerName)
      end
    end
  end
end
function KingEliminationFeature:ResolveKingEliminationEffectID(KillerPS, uKillerPawn)
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local EffectID = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(KillerPS.UID, ExtendAttribute.EliminationKingEffect)
  local OverrideRaw = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(KillerPS.UID, ExtendAttribute.EliminationKingClothOverrideEnabled)
  local bPreferenceOn = type(OverrideRaw) == "table" and OverrideRaw.flag == true
  print(bWriteLog and "KingEliminationFeature:ResolveKingEliminationEffectID EffectID = " .. tostring(EffectID) .. " EliminationKingClothOverrideEnabled flag: " .. tostring(bPreferenceOn))
  if not (bPreferenceOn and slua.isValid(uKillerPawn)) or not uKillerPawn.CharacterAvatarComp2_BP then
    return EffectID
  end
  local AvatarComp = uKillerPawn.CharacterAvatarComp2_BP
  if not slua.isValid(AvatarComp) then
    return EffectID
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = AvatarComp:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if not (AvatarItem and AvatarItem.TypeSpecificID) or AvatarItem.TypeSpecificID <= 0 then
    return EffectID
  end
  local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
  local NormalizedClothID = XSuitAvatarDataUtil:GenerateEliminationKingOverrideItemID(AvatarItem.TypeSpecificID, KillerPS.UID) or 0
  if NormalizedClothID <= 0 then
    return EffectID
  end
  local BattleEffectCfg = CDataTable.GetTableData("GoldClothBattleEffect", NormalizedClothID)
  if BattleEffectCfg and BattleEffectCfg.KingEliminationOverrideID and 0 < BattleEffectCfg.KingEliminationOverrideID then
    EffectID = BattleEffectCfg.KingEliminationOverrideID
  end
  return EffectID
end
function KingEliminationFeature:GetCurrentMaxKillCount()
  local MaxKillCount = DefaultMaxKillCount
  for _, KillInfo in pairs(self.KillInfoTable) do
    if not KillInfo.bIsDead and MaxKillCount < KillInfo.KillCount then
      MaxKillCount = KillInfo.KillCount
    end
  end
  return MaxKillCount
end
function KingEliminationFeature:GenerateDeadKingEliminationInfo(KillerPlayerKey, KillerPlayerName, EliminationKingPlayerKey, EliminationKingPlayerName, KillCount, EffectID)
  if not self.DeadKingEliminationInfoTable[KillerPlayerKey] then
    self.DeadKingEliminationInfoTable[KillerPlayerKey] = {}
  end
  local DeadInfoTable = self.DeadKingEliminationInfoTable[KillerPlayerKey]
  DeadInfoTable.  DeadInfoTable.  DeadInfoTable.  DeadInfoTable.  DeadInfoTable.  DeadInfoTable.  local DeadKingEliminationPlayerState = GameplayData.GetPlayerState(EliminationKingPlayerKey)
  if slua.isValid(DeadKingEliminationPlayerState) and DeadKingEliminationPlayerState.SetKingEliminationState then
    DeadKingEliminationPlayerState:SetKingEliminationState(false)
  end
end
function KingEliminationFeature:GenerateNewKingEliminationInfo(PlayerKey, PlayerName, KillCount, bIsFirstEliminationKing, EffectID)
  if not self.NewKingEliminationInfoTable[PlayerKey] then
    self.NewKingEliminationInfoTable[PlayerKey] = {}
  end
  local NewKingInfoTable = self.NewKingEliminationInfoTable[PlayerKey]
  NewKingInfoTable.  NewKingInfoTable.  NewKingInfoTable.  NewKingInfoTable.  NewKingInfoTable.  local LastKingEliminationPlayerState = GameplayData.GetPlayerState(self.LastKingEliminationPlayerKey)
  if slua.isValid(LastKingEliminationPlayerState) and LastKingEliminationPlayerState.SetKingEliminationState then
    LastKingEliminationPlayerState:SetKingEliminationState(false)
  end
  local CurrentKingEliminationPlayerState = GameplayData.GetPlayerState(PlayerKey)
  if slua.isValid(CurrentKingEliminationPlayerState) and CurrentKingEliminationPlayerState.SetKingEliminationState then
    CurrentKingEliminationPlayerState:SetKingEliminationState(true)
  end
  self.LastKingElimination  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REFRESH_ELIMINATION_KING, PlayerKey, PlayerName, KillCount)
end
function KingEliminationFeature:ConsumeKingEliminationInfo(KillerPlayerKey)
  if not KillerPlayerKey then
    return
  end
  KillerPlayerKey = tonumber(KillerPlayerKey)
  if not self.DeadKingEliminationInfoTable[KillerPlayerKey] and not self.NewKingEliminationInfoTable[KillerPlayerKey] then
    return
  end
  local KingEliminationInfo = {}
  if self.DeadKingEliminationInfoTable[KillerPlayerKey] then
    KingEliminationInfo.DeadKingEliminationInfo = self.DeadKingEliminationInfoTable[KillerPlayerKey]
    self.DeadKingEliminationInfoTable[KillerPlayerKey] = nil
  end
  if self.NewKingEliminationInfoTable[KillerPlayerKey] then
    KingEliminationInfo.NewKingEliminationInfo = self.NewKingEliminationInfoTable[KillerPlayerKey]
    self.NewKingEliminationInfoTable[KillerPlayerKey] = nil
  end
  return KingEliminationInfo
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, KingEliminationFeature)