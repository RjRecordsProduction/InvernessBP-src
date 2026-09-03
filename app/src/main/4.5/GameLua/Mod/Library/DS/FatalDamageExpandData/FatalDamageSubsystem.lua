local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BackpackUtils = import("BackpackUtils")
local EAvatarSlotType = import("EAvatarSlotType")
local ECharacterSubType = import("ECharacterSubType")
local ECharacterMainType = import("ECharacterMainType")
local ECharacterHealthStatus = import("ECharacterHealthStatus")
local STExtraPlayerCharacter = import("STExtraPlayerCharacter")
local STExtraSimpleCharacter = import("STExtraSimpleCharacter")
local EFatalDamageRelationShip = import("EFatalDamageRelationShip")
local EFatalDamageCharacterType = import("EFatalDamageCharacterType")
local EFakePlayerBornType = import("EFakePlayerBornType")
local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
local bBroadcastDamageInfo = true
local FatalDamageSubsystem = {}
function FatalDamageSubsystem:ctor()
  self.FatalDamageID = 0
end
function FatalDamageSubsystem:OnInit()
  FatalDamageSubsystem.__super.OnInit(self)
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.IsEnableDamageInfo then
    bBroadcastDamageInfo = GameState:IsEnableDamageInfo()
  end
end
function FatalDamageSubsystem:BroadcastFatalDamageInfoWrapperSimpleLua(Causer, Victim, DamageType, AdditionalParam, IsHeadShot)
  if not slua.isValid(Victim) then
    return
  end
  local FFatalDamageParameterCompress = import("FatalDamageParameterCompress")
  local FatalDamageParameterNew = FFatalDamageParameterCompress()
  if slua.isValid(Causer) then
    if Causer.GetPlayerControllerSafety then
      local CauserPC = Causer:GetPlayerControllerSafety()
      if slua.isValid(CauserPC) then
        local BPID = BackpackUtils.GetBPIDByResID(AdditionalParam)
        FatalDamageParameterNew.causerWeaponAvatarID = CauserPC:GetWeaponAvatarItemId(BPID)
        if FatalDamageParameterNew.causerWeaponAvatarID == 0 then
          FatalDamageParameterNew.causerWeaponAvatarID = AdditionalParam
        end
      end
      if Causer.getAvatarComponent2 then
        local AvatarComponent = Causer:getAvatarComponent2()
        if slua.isValid(AvatarComponent) then
          local DefienID = AvatarComponent:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
          FatalDamageParameterNew.causerClothAvatarID = DefienID.TypeSpecificID
        end
      end
    end
    print(bWriteLog and "BroadcastFatalDamageInfo_Implementation causer name is: ", Causer:GetPlayerNameSafety())
  end
  if slua.isValid(Causer) then
    FatalDamageParameterNew.causerName = Causer:GetPlayerNameSafety()
    FatalDamageParameterNew.causerNation = Causer.Nation
  end
  if slua.isValid(Victim) then
    FatalDamageParameterNew.victimName = Victim:GetPlayerNameSafety()
    FatalDamageParameterNew.victimNation = Victim.Nation
  end
  FatalDamageParameterNew.damageType = DamageType
  FatalDamageParameterNew.  FatalDamageParameterNew.IsHeadshot = IsHeadShot
  FatalDamageParameterNew.ResultHealthStatus = ECharacterHealthStatus.HealthyAlive
  FatalDamageParameterNew.PreviousHealthStatus = ECharacterHealthStatus.FinishedLastBreath
  if slua.isValid(Victim) and Victim.GetBroadcastFatalDamageExpandData then
    FatalDamageParameterNew.ExpandDataContent = Victim:GetBroadcastFatalDamageExpandData(Causer, Victim, nil, DamageType, FatalDamageParameterNew.causerWeaponAvatarID)
  end
  FatalDamageParameterNew.isCausedByDevliver = false
  FatalDamageParameterNew.causerKey = 0
  FatalDamageParameterNew.victimKey = 0
  FatalDamageParameterNew.FuzzyCauserName = ""
  FatalDamageParameterNew.FuzzyVictimName = ""
  FatalDamageParameterNew.realKillerName = ""
  FatalDamageParameterNew.realKillerNewKillNum = 0
  FatalDamageParameterNew.AssistNum = 0
  FatalDamageParameterNew.victimType = Victim:IsBoss() and EFatalDamageCharacterType.EBoss or EFatalDamageCharacterType.EMonster
  FatalDamageParameterNew.causerClothAvatarID = XSuitAvatarDataUtil:GenerateKillBroadcastItemID(FatalDamageParameterNew.causerClothAvatarID, FatalDamageParameterNew.causerKey)
  local AllPlayerControllers = Game:GetAllPlayerControllers()
  for _, PlayerController in pairs(AllPlayerControllers) do
    if slua.isValid(PlayerController) and slua.isValid(PlayerController.PlayerState) then
      FatalDamageParameterNew.Relationship = EFatalDamageRelationShip.NotRelated
      local PlayerState = PlayerController.PlayerState
      if slua.isValid(Causer) and Causer.IsSameTeamWithPlayerState and Causer:IsSameTeamWithPlayerState(PlayerState) then
        FatalDamageParameterNew.Relationship = EFatalDamageRelationShip.MyTeamateIsCauser
        if slua.isValid(Victim) and Victim.IsSameTeamWithPlayerState and Victim:IsSameTeamWithPlayerState(PlayerState) then
          FatalDamageParameterNew.Relationship = EFatalDamageRelationShip.MyTeammateIsCauserAndVictim
        end
      elseif slua.isValid(Victim) and Victim.IsSameTeamWithPlayerState and Victim:IsSameTeamWithPlayerState(PlayerState) then
        FatalDamageParameterNew.Relationship = EFatalDamageRelationShip.MyTeammateIsVictim
      end
      print(bWriteLog and "BroadcastFatalDamageInfo for PC: ", PlayerController.PlayerName)
      if PlayerController.PlayerControllerFatalDamageFeature then
        PlayerController.PlayerControllerFatalDamageFeature:RPC_Client_BroadcastFatalDamageToClientForLua(FatalDamageParameterNew)
      end
    end
  end
end
function FatalDamageSubsystem:BroadcastFatalDamageInfoWrapperLua(Causer, Victim, DamageType, AdditionalParam, IsHeadShot, ResultHealthStatus, PreviousHealthStatus, WhoKillMe, KillerKillCount)
  if not slua.isValid(Victim) then
    return
  end
  if Victim.bShouldIgnoreSendFatalDamage then
    return
  end
  local FFatalDamageParameterCompress = import("FatalDamageParameterCompress")
  local FatalDamageParameterNew = FFatalDamageParameterCompress()
  local CauserWeaponAvatarID = 0
  local CauserClothAvatarID = 0
  local bIsCausedByDevliver = false
  if slua.isValid(Causer) then
    if Causer.GetPlayerControllerSafety then
      local CauserPC = Causer:GetPlayerControllerSafety()
      if slua.isValid(CauserPC) then
        local BPID = BackpackUtils.GetBPIDByResID(AdditionalParam)
        CauserWeaponAvatarID = CauserPC:GetWeaponAvatarItemId(BPID)
        if CauserWeaponAvatarID == 0 then
          CauserWeaponAvatarID = AdditionalParam
        end
      else
        local CauserAIPC = Causer:GetController()
        if slua.isValid(CauserAIPC) and CauserAIPC.IsDeliver and CauserAIPC:IsDeliver() then
          bIsCausedByDevliver = true
        end
      end
      if Causer.getAvatarComponent2 then
        local AvatarComponent = Causer:getAvatarComponent2()
        if slua.isValid(AvatarComponent) then
          local DefienID = AvatarComponent:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
          CauserClothAvatarID = DefienID.TypeSpecificID
        end
      end
    end
    if ResultHealthStatus == ECharacterHealthStatus.HasLastBreath and slua.isValid(Victim) and Victim.GetPlayerControllerSafety and Causer.GetPlayerControllerSafety then
      local AreTheySameTeam = Victim:IsSameTeam(Causer)
      local CauserName = Causer:GetPlayerNameSafety()
      local VictimController = Victim:GetPlayerControllerSafety()
      if slua.isValid(VictimController) and 0 < #CauserName and Causer.GetPlayerStateSafety then
        local CauserPS = Causer:GetPlayerStateSafety()
        local PlayerUID = slua.isValid(CauserPS) and CauserPS.UID or 0
        VictimController:RPC_OwnerClient_SetLastBreathMurder(CauserName, Causer:GetEnsure(), PlayerUID, AreTheySameTeam)
        print(bWriteLog and "BroadcastFatalDamageInfo_Implementation causer is", PlayerUID, "With Name = ", CauserName)
      end
    end
  else
    print(bWriteLog and "BroadcastFatalDamageInfo_Implementation causer is NULL")
    if slua.isValid(WhoKillMe) then
      Causer = WhoKillMe
      print(bWriteLog and "BroadcastFatalDamageInfo_Implementation causer renamed to ", Causer:GetPlayerNameSafety())
    end
  end
  local CauserKey = 0
  local VictimKey = 0
  if slua.isValid(Causer) and Causer.GetPlayerControllerSafety then
    local CauserPlayerController = Causer:GetPlayerControllerSafety()
    if slua.isValid(CauserPlayerController) and CauserPlayerController.PlayerKey then
      CauserKey = CauserPlayerController.PlayerKey
    end
  end
  if slua.isValid(Victim) and Victim.GetPlayerControllerSafety then
    local VictimPlayerController = Victim:GetPlayerControllerSafety()
    if slua.isValid(VictimPlayerController) and VictimPlayerController.PlayerKey then
      VictimKey = VictimPlayerController.PlayerKey
    end
  end
  if slua.isValid(Causer) then
    FatalDamageParameterNew.causerName = Causer:GetPlayerNameSafety()
    FatalDamageParameterNew.causerNation = Causer.Nation
  end
  if DamageType == UEnums.DamageType.PoisonDamage then
    FatalDamageParameterNew.causerName = "SafeZone"
  end
  if slua.isValid(Victim) then
    FatalDamageParameterNew.victimName = Victim:GetPlayerNameSafety()
    FatalDamageParameterNew.victimNation = Victim.Nation
  end
  FatalDamageParameterNew.damageType = DamageType
  FatalDamageParameterNew.  FatalDamageParameterNew.IsHeadshot = IsHeadShot
  FatalDamageParameterNew.  FatalDamageParameterNew.  FatalDamageParameterNew.isCausedByDevliver = bIsCausedByDevliver
  local KillerName = ""
  if slua.isValid(WhoKillMe) then
    KillerName = WhoKillMe:GetPlayerNameSafety()
  end
  FatalDamageParameterNew.causerType = EFatalDamageCharacterType.EPlayer
  if slua.isValid(Causer) then
    if Game:IsClassOf(Causer, STExtraSimpleCharacter) then
      local Monster = Causer
      FatalDamageParameterNew.causerName = Monster.MonsterNameID
      if Monster.CustomMonsterNameID and 0 < Monster.CustomMonsterNameID then
        FatalDamageParameterNew.causerName = tostring(Monster.CustomMonsterNameID)
      end
      FatalDamageParameterNew.causerType = Monster:IsBoss() and EFatalDamageCharacterType.EBoss or EFatalDamageCharacterType.EMonster
    elseif Game:IsClassOf(Causer, STExtraPlayerCharacter) then
      local InfecCharacter = Causer
      local CharacterMainType = InfecCharacter:GetCharacterMainType()
      local CharacterSubType = InfecCharacter:GetCharacterSubType()
      if CharacterMainType == ECharacterMainType.WalkingDeadAI then
        FatalDamageParameterNew.causerType = EFatalDamageCharacterType.EWalkingDeadAI
      elseif CharacterSubType == ECharacterSubType.RevengerPlayer then
        FatalDamageParameterNew.causerType = EFatalDamageCharacterType.EInfecRevenger
      elseif CharacterMainType == ECharacterMainType.Mercenary then
        FatalDamageParameterNew.causerType = EFatalDamageCharacterType.EMercenary
      elseif CharacterSubType == ECharacterSubType.NormalPlayer then
      elseif CharacterMainType == ECharacterMainType.WalkingDead then
        FatalDamageParameterNew.causerType = EFatalDamageCharacterType.EWalkingDead
      else
        FatalDamageParameterNew.causerType = EFatalDamageCharacterType.EInfecZombie
      end
    end
  elseif DamageType == UEnums.DamageType.PoisonDamage then
    FatalDamageParameterNew.causerType = EFatalDamageCharacterType.EUnknown
  end
  FatalDamageParameterNew.real  FatalDamageParameterNew.realKillerNewKillNum = KillerKillCount
  if slua.isValid(Victim) and Victim.GetBroadcastFatalDamageExpandData then
    FatalDamageParameterNew.ExpandDataContent = Victim:GetBroadcastFatalDamageExpandData(Causer, Victim, WhoKillMe, DamageType, CauserWeaponAvatarID)
  end
  FatalDamageParameterNew.causerWeaponAvatarID = CauserWeaponAvatarID
  FatalDamageParameterNew.causerClothAvatarID = CauserClothAvatarID
  FatalDamageParameterNew.causerKey = CauserKey
  FatalDamageParameterNew.victimKey = VictimKey
  FatalDamageParameterNew.causerClothAvatarID = XSuitAvatarDataUtil:GenerateKillBroadcastItemID(FatalDamageParameterNew.causerClothAvatarID, FatalDamageParameterNew.causerKey)
  local GameInstance = slua.getGameInstance()
  local CauserTemp = Causer
  if not slua.isValid(CauserTemp) then
    CauserTemp = nil
  end
  if slua.isValid(GameInstance) and GameInstance:IsServerReplayRecording() and slua.isValid(Victim) and Victim.BroadcastFatalDamageInfo then
    Victim:BroadcastFatalDamageInfoWithCompressData(CauserTemp, Victim, FatalDamageParameterNew, CauserKey, VictimKey)
    local CauserPlayerUID = slua.isValid(Causer) and Causer.PlayerUID or ""
    local VictimPlayerUID = slua.isValid(Victim) and Victim.PlayerUID or ""
    if Victim.WeaponRecordDataForReplay then
      GameInstance:ReplayRecordKillInfo(CauserPlayerUID, VictimPlayerUID, ResultHealthStatus == ECharacterHealthStatus.HasLastBreath, Victim.WeaponRecordDataForReplay)
    end
  end
  self:ResetWeaponRecordData(Victim)
  if not bBroadcastDamageInfo then
    return
  end
  local ExtraInfo = {}
  local bVictimShouldSendFatalDamage = self:ShouldSendFatalDamageToClient(Causer, Victim)
  if not bVictimShouldSendFatalDamage then
    return
  end
  ExtraInfo.  if slua.isValid(Causer) and Causer.GetTeamAndSelfPlayerStates then
    local CauserTeamAndSelfPlayerStates = Causer:GetTeamAndSelfPlayerStates()
    local CauserExtraInfo = {
      TeamAndSelfPlayerkey = {},
      AssistsInfo = {}
    }
    local CauserPlayerState = Causer:GetPlayerState()
    if slua.isValid(CauserPlayerState) and CauserPlayerState.GetTeamId then
      CauserExtraInfo.TeamID = CauserPlayerState:GetTeamId()
    end
    for _, TeamAndSelfPlayerState in pairs(CauserTeamAndSelfPlayerStates) do
      if slua.isValid(TeamAndSelfPlayerState) then
        local PlayerKey = TeamAndSelfPlayerState:GetPlayerKey()
        CauserExtraInfo.TeamAndSelfPlayerkey[PlayerKey] = true
        if slua.isValid(Victim) and TeamAndSelfPlayerState.AssistKillPlayers then
          local bIsAssist, bIsFound = TeamAndSelfPlayerState.AssistKillPlayers:Get(Victim.PlayerKey)
          if bIsFound and bIsAssist == false then
            TeamAndSelfPlayerState.AssistKillPlayers:Add(Victim.PlayerKey, true)
            CauserExtraInfo.AssistsInfo[PlayerKey] = TeamAndSelfPlayerState.Assists
          end
        end
      end
    end
    ExtraInfo.  end
  if slua.isValid(Victim) and Victim.GetTeamAndSelfPlayerStates then
    local VictimTeamAndSelfPlayerStates = Victim:GetTeamAndSelfPlayerStates()
    local VictimExtraInfo = {
      TeamAndSelfPlayerkey = {}
    }
    local VictimPlayerState = Victim:GetPlayerState()
    if slua.isValid(VictimPlayerState) and VictimPlayerState.GetTeamId then
      VictimExtraInfo.TeamID = VictimPlayerState:GetTeamId()
    end
    for _, TeamAndSelfPlayerState in pairs(VictimTeamAndSelfPlayerStates) do
      if slua.isValid(TeamAndSelfPlayerState) then
        local PlayerKey = TeamAndSelfPlayerState:GetPlayerKey()
        VictimExtraInfo.TeamAndSelfPlayerkey[PlayerKey] = true
      end
    end
    ExtraInfo.  end
  self.FatalDamageID = self.FatalDamageID + 1
  ExtraInfo.FatalDamageID = self.FatalDamageID
  local ExtraInfoByte = slua.LuaArchiverEncode(LuaStateWrapper, ExtraInfo)
  FatalDamageParameterNew.AssistNum = 0
  FatalDamageParameterNew.Relationship = EFatalDamageRelationShip.NotRelated
  FatalDamageParameterNew.FuzzyCauserName = ""
  FatalDamageParameterNew.FuzzyVictimName = ""
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.bUseFuzzyInformation then
    local _, FuzzyCauserName = GameState:GetFuzzyNameByRealPlayerName(FatalDamageParameterNew.causerName, FatalDamageParameterNew.FuzzyCauserName)
    local _, FuzzyVictimName = GameState:GetFuzzyNameByRealPlayerName(FatalDamageParameterNew.victimName, FatalDamageParameterNew.FuzzyVictimName)
    FatalDamageParameterNew.    FatalDamageParameterNew.  end
  FatalDamageParameterNew.victimType = EFatalDamageCharacterType.EPlayer
  if Game:IsClassOf(Victim, STExtraPlayerCharacter) then
    local CharacterMainType = Victim:GetCharacterMainType()
    if CharacterMainType == ECharacterMainType.Mercenary then
      FatalDamageParameterNew.victimType = EFatalDamageCharacterType.EMercenary
    end
  end
  if slua.isValid(GameState) and GameState.FatalDamageFeature then
    GameState.FatalDamageFeature:MulticastRPC_BroadcastFatalDamageToClientForLua(FatalDamageParameterNew, ExtraInfoByte)
  end
end
function FatalDamageSubsystem:ResetWeaponRecordData(PlayerCharacter)
  if slua.isValid(PlayerCharacter) and PlayerCharacter.WeaponRecordDataForReplay then
    PlayerCharacter.WeaponRecordDataForReplay.WeaponId = 0
    PlayerCharacter.WeaponRecordDataForReplay.HeadShoot = 0
    PlayerCharacter.WeaponRecordDataForReplay.LimbsShoot = 0
    PlayerCharacter.WeaponRecordDataForReplay.BodyShoot = 0
    PlayerCharacter.WeaponRecordDataForReplay.HandShoot = 0
    PlayerCharacter.WeaponRecordDataForReplay.FootShoot = 0
  end
end
local tKillerFlow = {}
function FatalDamageSubsystem:RetrievePlayerKillerFlow(nUID)
  if not nUID then
    print(bWriteLog and "FatalDamageSubsystem:RetrievePlayerKillerFlow nUID nil")
    return
  end
  if not tKillerFlow[nUID] then
    print(bWriteLog and "FatalDamageSubsystem:RetrievePlayerKillerFlow tKillerFlow[nUID] nil")
    return
  end
  return table.concat(tKillerFlow[nUID], ",")
end
function FatalDamageSubsystem:AddPlayerKillerFlow(uKillerPS, uVictimPawn)
  if not slua.isValid(uKillerPS) or not slua.isValid(uVictimPawn) then
    print(bWriteLog and "FatalDamageSubsystem:AddPlayerKillerFlow invalid playerstate or pawn")
    return
  end
  if uVictimPawn.bEnsure then
    print(bWriteLog and "FatalDamageSubsystem:AddPlayerKillerFlow bEnsure")
    return
  end
  local sVictimUID = uVictimPawn.PlayerUID
  if not sVictimUID then
    print(bWriteLog and "FatalDamageSubsystem:AddPlayerKillerFlow sVictimUID nil")
    return
  end
  local nVictimUID = tonumber(sVictimUID) or 0
  if nVictimUID == 0 then
    print(bWriteLog and "FatalDamageSubsystem:AddPlayerKillerFlow nVictimUID nil or 0")
    return
  end
  if uKillerPS.bPSEnsure then
    print(bWriteLog and "FatalDamageSubsystem:AddPlayerKillerFlow bPSEnsure")
    return
  end
  local nKillerUID = uKillerPS.UID or 0
  local sKillerOpenID = uKillerPS.OpenID or ""
  local sKillerName = uKillerPS.PlayerName or ""
  if not tKillerFlow[nVictimUID] then
    tKillerFlow[nVictimUID] = {}
  end
  sKillerName = string.gsub(sKillerName, ":", "")
  sKillerName = string.gsub(sKillerName, ",", "")
  local sKillerFlow = tostring(nKillerUID) .. ":" .. sKillerOpenID .. ":" .. sKillerName
  table.insert(tKillerFlow[nVictimUID], sKillerFlow)
  print(bWriteLog and string.format("FatalDamageSubsystem:AddPlayerKillerFlow nVictimUID[%s] sKillerFlow[%s]", tostring(nVictimUID), sKillerFlow))
end
function FatalDamageSubsystem:ClearPlayerKillerFlow(nUID)
  if not nUID then
    print(bWriteLog and "FatalDamageSubsystem:ClearPlayerKillerFlow nUID nil")
    return
  end
  if not tKillerFlow[nUID] then
    print(bWriteLog and "FatalDamageSubsystem:ClearPlayerKillerFlow tKillerFlow[nUID] nil")
    return
  end
  tKillerFlow[nUID] = nil
  print(bWriteLog and string.format("FatalDamageSubsystem:ClearPlayerKillerFlow nUID[%s]", tostring(nUID)))
end
function FatalDamageSubsystem:ShouldSendFatalDamageToClient(Causer, Victim)
  if not slua.isValid(Victim) then
    return false
  end
  if Victim:GetEnsure() then
    local VictimController = Victim:GetController()
    if slua.isValid(VictimController) and VictimController.FakePlayerBornType == EFakePlayerBornType.FromSpawner and VictimController.ShouldSendFatalDamageToClient and not VictimController:ShouldSendFatalDamageToClient() then
      return false
    end
  end
  return true
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, FatalDamageSubsystem)