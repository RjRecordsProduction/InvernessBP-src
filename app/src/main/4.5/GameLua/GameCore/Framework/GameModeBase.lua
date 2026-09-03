local UKismetSystemLibrary = import("KismetSystemLibrary")
local GameModeBase = {
  LuaEventContainer = {
    "DefaultLuaEventPlaceholder"
  }
}
function GameModeBase:ctor(selfType)
  self.footEffectConsumeList = {}
  self.AllTeammatesDied = {}
  self.bHaveInitedRevivalCount = false
  self.bAddKillerFlow = false
end
function GameModeBase:_PostConstruct()
  GameModeBase.__super._PostConstruct(self)
end
function GameModeBase:InitGameplaySys()
  local GameplaySysMgr = require("GameLua.Mod.BaseMod.GamePlay.Core.GameplaySysMgr")
end
function GameModeBase:ReceiveBeginPlay()
  GameModeBase.__super.ReceiveBeginPlay(self)
  self:InitGameplaySys()
  self:PostInitGameplaySys()
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_DIED, self.HandleOnPawnDie, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_RESCUE, self.OnHandleRescued, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_ITEM, EVENTID_PLAYEREVENT_DROPITEM, self.OnDropItem, self)
  self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
    [1] = "FightingState"
  }, self.OnHandleEnterBattle, self)
  if slua.isValid(self.PlayerRespawnComponent) then
    self:AddControlEvent(self.PlayerRespawnComponent, "OnGlobalRespawnedDelegate", self.RevivalRestoreDataFinish, self)
  end
  if Server and not Server.IsShipping() then
    print(bWriteLog and "GameModeBase:ReceiveBeginPlay")
    local MaxPlayerNum = CGame:GetCommandLineValue("ParallelWorld.Debug.MaxPlayerNum=")
    if MaxPlayerNum and MaxPlayerNum ~= "" then
      print(bWriteLog and "GameModeBase:ReceiveBeginPlay MaxPlayerNum = " .. MaxPlayerNum)
      UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, string.format("ParallelWorld.Debug.MaxPlayerNum %s", MaxPlayerNum))
    end
    local ReserveBotNum = CGame:GetCommandLineValue("ParallelWorld.Debug.ReserveBotNum=")
    if ReserveBotNum and ReserveBotNum ~= "" then
      print(bWriteLog and "GameModeBase:ReceiveBeginPlay ReserveBotNum = " .. ReserveBotNum)
      UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, string.format("ParallelWorld.Debug.ReserveBotNum %s", ReserveBotNum))
    end
  end
  if not Client then
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_ITEM, EVENTID_PLAYEREVENT_PICKUPITEM, self.OnHandlePickupItem, self)
    print(bWriteLog and "GameModeBase:ReceiveBeginPlay ResetPropertySerializationStats")
    UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, string.format("net.ResetPropertySerializationStats"))
  end
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_CHAR_KILL, self.HandleOnCharacterKill, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_NEAR_DEATH, self.HandleOnCharacterKnockOut, self)
  local EGameModeType = import("/Script/ShadowTrackerExtra.EGameModeType")
  if self.GameModeType == EGameModeType.ETypicalGameMode or self.GameModeType == EGameModeType.EFourInOneGameMode then
    self.bAddKillerFlow = true
    print(bWriteLog and "GameModeBase:ReceiveBeginPlay bAddKillerFlow true")
  end
  UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, string.format("pc.SpectatorNotClearViewTarget 0"))
end
function GameModeBase:HandleOnPawnDie(_, __, Pawn, Killer, TypeID)
  if Pawn and slua.isValid(Pawn) then
    if Pawn.SetDiedTime then
      Pawn:SetDiedTime()
    end
    if Pawn.SetDiedPosition then
      Pawn:SetDiedPosition()
    end
    if Pawn.SetDiedPlayerCount then
      Pawn:SetDiedPlayerCount()
    end
  end
  if slua.isValid(Pawn) and Pawn.GetPlayerStateSafety then
    local uPlayerState = Pawn:GetPlayerStateSafety()
    if uPlayerState and slua.isValid(uPlayerState) and uPlayerState.HasAnyReviveChance and uPlayerState:HasAnyReviveChance() then
      if not (not Server or Server.IsShipping()) or CGame:IsEditor() then
        if uPlayerState.bReviveIndefinitely == true then
          print(bWriteLog and "GameModeBase:HandleOnPawnDie, bReviveIndefinitely = true")
          self:AddGameTimer(10, false, function()
            if Pawn and slua.isValid(Pawn) and uPlayerState and slua.isValid(uPlayerState) then
              uPlayerState:SetHaveSinglePlayerReviveItem(true)
              local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
              DSReviveSubsystem:ItemReviveImplementation(uPlayerState, false)
            end
          end)
        else
          print(bWriteLog and "GameModeBase:HandleOnPawnDie, bReviveIndefinitely = " .. tostring(uPlayerState.bReviveIndefinitely))
        end
      else
        print(bWriteLog and "GameModeBase:HandleOnPawnDie, Server.IsShipping()")
      end
      if self:IsPlayerCanSelfRevival(uPlayerState) then
        uPlayerState.IsInWaittingRevivalState = false
        local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
        if DSReviveSubsystem then
          local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
          local ReviveConfig = GamePlayTools.GetCurrentConfig("ReviveConfig")
          local HelicopterConfig = DSReviveSubsystem:GetHelicopterReviveConfig()
          if HelicopterConfig and HelicopterConfig.WaitingTime > ReviveConfig.TimeWaitingForBeforeSpectate then
            uPlayerState.IsInWaittingRevivalState = true
          end
        end
      else
        uPlayerState.IsInWaittingRevivalState = true
      end
      print(bWriteLog and "GameModeBase:HandleOnPawnDie, IsInWaittingRevivalState = " .. tostring(uPlayerState.IsInWaittingRevivalState) .. ", PlayerKey = " .. tostring(Pawn.PlayerKey))
    end
    self:CheckTeamTerminatedClearRevival(uPlayerState)
  end
  local DSPlayerDataReportSubsystem = SubsystemMgr:Get("DSPlayerDataReportSubsystem")
  if DSPlayerDataReportSubsystem then
    DSPlayerDataReportSubsystem:HandleOnPawnDie(Pawn)
  end
end
function GameModeBase:OnHandleRescued(_, _, WhoRescued, RescuedWho)
  if WhoRescued and slua.isValid(WhoRescued) then
    if RescuedWho and slua.isValid(RescuedWho) then
      if WhoRescued.PlayerKey == RescuedWho.PlayerKey then
        local PlayerState = WhoRescued:GetPlayerStateSafety()
        if PlayerState and slua.isValid(PlayerState) then
          if PlayerState.AfterSelfRescueSucceed then
            PlayerState:AfterSelfRescueSucceed()
          else
            print(bWriteLog and "GameModeBase:OnHandleRescued, have no function AfterSelfRescueSucceed, PlayerKey = " .. tostring(RescuedWho.PlayerKey))
          end
          PlayerState:AddGeneralCount(1122, 1, false)
        else
          print(bWriteLog and "GameModeBase:OnHandleRescued, PlayerState = " .. tostring(PlayerState) .. ", PlayerKey = " .. tostring(RescuedWho.PlayerKey))
        end
      else
        local PlayerState = RescuedWho:GetPlayerStateSafety()
        if PlayerState and slua.isValid(PlayerState) then
          if PlayerState.BeRescuedSucceed then
            PlayerState:BeRescuedSucceed()
          else
            print(bWriteLog and "GameModeBase:OnHandleRescued, have no function BeRescuedSucceed, PlayerKey = " .. tostring(RescuedWho.PlayerKey))
          end
        end
        print(bWriteLog and "GameModeBase:OnHandleRescued, WhoRescued != RescuedWho")
      end
    else
      print(bWriteLog and "GameModeBase:OnHandleRescued, RescuedWho = " .. tostring(WhoRescued))
    end
  else
    print(bWriteLog and "GameModeBase:OnHandleRescued, WhoRescued = " .. tostring(WhoRescued))
  end
end
function GameModeBase:OnDropItem(_, _, PlayerKey, ItemID, Count, Reason)
  local PlayerState = Game:GetPlayerStateByPlayerKey(PlayerKey)
  if PlayerState and slua.isValid(PlayerState) then
    local Config = require("GameLua.Mod.BaseMod.DS.Config.SelfRescueConfig")
    if ItemID == Config.SelfRescueItemId then
      if PlayerState.LostSelfRescueResource then
        PlayerState:LostSelfRescueResource()
      else
        print(bWriteLog and "GameModeBase:OnDropItem, have no function LostSelfRescueResource, PlayerKey = " .. tostring(PlayerKey))
      end
    end
    if not Client then
      local uPlayerController = PlayerState:GetOwner()
      if slua.isValid(uPlayerController) and uPlayerController.CommerFeature then
        uPlayerController.CommerFeature:OnDropItem(nil, nil, PlayerKey, ItemID, nil, Reason, nil)
      end
    end
  else
    print(bWriteLog and "GameModeBase:OnDropItem, PlayerState = " .. tostring(PlayerState) .. ", PlayerKey = " .. tostring(PlayerKey))
  end
end
function GameModeBase:OnHandlePickupItem(EventType, EventID, PlayerKey, ItemID, Count, Reason, Source)
  local PlayerState = Game:GetPlayerStateByPlayerKey(PlayerKey)
  if PlayerState and slua.isValid(PlayerState) then
    PlayerState:OnHandlePickupItem(EventType, EventID, PlayerKey, ItemID, Count, Reason, Source)
  end
end
function GameModeBase:OnHandleEnterBattle()
  local Config = require("GameLua.Mod.BaseMod.DS.Config.SelfRescueConfig")
  self:AddGameTimer(Config.SelfRescueInvalidTime, false, function()
    print(bWriteLog and "GameModeBase:OnHandleEnterBattle, Clear Item")
    local PlayerArray = Game:GetAllPlayerPawns()
    for i = 0, PlayerArray:Num() - 1 do
      local uPlayerCharacter = PlayerArray:Get(i)
      if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
        Game:ConsumeItem(uPlayerCharacter, Config.SelfRescueItemId, 99)
        local uPlayerState = uPlayerCharacter:GetPlayerStateSafety()
        if uPlayerState and slua.isValid(uPlayerState) and uPlayerState.CheckCanSelfRescue then
          uPlayerState:CheckCanSelfRescue()
        end
      else
        print(bWriteLog and "GameModeBase:OnHandleEnterBattle, uPlayerCharacter = " .. tostring(uPlayerCharacter))
      end
    end
  end)
end
function GameModeBase:HandleOnCharacterKill(_, __, uKillerPS, uVictimPawn)
  print(bWriteLog and "[tinghaohu]GameModeBase:HandleOnCharacterKill")
  if slua.isValid(uKillerPS) and slua.isValid(uKillerPS.CharacterOwner) then
    self:HandleConsumeFootEffect(uKillerPS.CharacterOwner)
  end
  if self.bAddKillerFlow then
    local FatalDamageSubsystem = SubsystemMgr:Get("FatalDamageSubsystem")
    if FatalDamageSubsystem then
      FatalDamageSubsystem:AddPlayerKillerFlow(uKillerPS, uVictimPawn)
    end
  end
end
function GameModeBase:HandleOnCharacterKnockOut(_, __, uVictimPawn, uEventInstigatorCtrl)
  print(bWriteLog and "[tinghaohu]GameModeBase:HandleOnCharacterKnockOut")
  local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
  if Game:IsClassOf(uEventInstigatorCtrl, ASTExtraPlayerController) then
    local killer = uEventInstigatorCtrl:GetPlayerCharacterSafety()
    self:HandleConsumeFootEffect(killer)
  end
end
function GameModeBase:HandleConsumeFootEffect(killer)
  if not slua.isValid(killer) then
    return
  end
  if self.footEffectConsumeList[killer.PlayerKey] == true then
    return
  end
  local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  if Game:IsClassOf(killer, ASTExtraBaseCharacter) and killer.getAvatarComponent2 then
    local uAvatarComp2 = killer:getAvatarComponent2()
    if slua.isValid(uAvatarComp2) then
      local EAvatarSlotType = import("EAvatarSlotType")
      local fFootEffectItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_FootEffectEquipemtSlot)
      if fFootEffectItem and fFootEffectItem.TypeSpecificID ~= 0 then
        print(bWriteLog and "[tinghaohu]GameModeBase:HandleConsumeFootEffect. fFootEffectItemID:" .. tostring(fFootEffectItem.TypeSpecificID))
        self.footEffectConsumeList[killer.PlayerKey] = true
        killer:ServerSendToLobbyServerUseItem(fFootEffectItem.TypeSpecificID, 1)
      end
    end
  end
end
function GameModeBase:ReceiveEndPlay(EndPlayReason)
  local GameplaySysMgr = require("GameLua.Mod.BaseMod.GamePlay.Core.GameplaySysMgr")
  GameplaySysMgr.EndPlay()
  GameModeBase.__super.ReceiveEndPlay(self, EndPlayReason)
end
function GameModeBase:PostInitGameplaySys()
  EventSystem:registEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_JOIN, function(_, __, uPlayer)
    local GameplaySysMgr = require("GameLua.Mod.BaseMod.GamePlay.Core.GameplaySysMgr")
    GameplaySysMgr.HandlePlayerJoinIn(uPlayer)
  end)
end
function GameModeBase:IsRevivalGameMode(uPlayerState)
  local bIsRevivalMode = false
  if uPlayerState == nil or not slua.isValid(uPlayerState) then
    print(bWriteLog and "GameModeBase:IsRevivalGameMode, return false when uPlayerState = " .. tostring(uPlayerState))
    return bIsRevivalMode
  end
  bIsRevivalMode = self:IsPlayerCanSelfRevival(uPlayerState)
  if bIsRevivalMode == false and uPlayerState.HasAnyReviveChance then
    bIsRevivalMode = uPlayerState:HasAnyReviveChance()
  end
  print(bWriteLog and "GameModeBase:IsRevivalGameMode, bIsRevivalMode = " .. tostring(bIsRevivalMode) .. " when PlayerKey = " .. tostring(uPlayerState.PlayerKey))
  return bIsRevivalMode
end
function GameModeBase:IsPlayerCanSelfRevival(uPlayerState)
  local bCanSelfRevival = false
  if uPlayerState == nil or not slua.isValid(uPlayerState) then
    print(bWriteLog and "GameModeBase:IsPlayerCanSelfRevival, return false when uPlayerState = " .. tostring(uPlayerState))
    return bCanSelfRevival
  end
  if uPlayerState.GetRevivalCount and uPlayerState.GetHaveSinglePlayerReviveItem then
    bCanSelfRevival = uPlayerState:GetRevivalCount() > 0 and uPlayerState:GetHaveSinglePlayerReviveItem()
  end
  if bCanSelfRevival == false and uPlayerState.GetRevivalCount and uPlayerState:GetRevivalCount() > 0 then
    local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
    if DSReviveSubsystem then
      local HelicopterConfig = DSReviveSubsystem:GetHelicopterReviveConfig()
      if HelicopterConfig and HelicopterConfig.NoAutoRevive ~= true then
        bCanSelfRevival = true
      end
    end
  end
  if bCanSelfRevival == false then
    bCanSelfRevival = self.Super:IsPlayerCanSelfRevival(uPlayerState)
  end
  if (not (not Server or Server.IsShipping()) or CGame:IsEditor()) and uPlayerState.bReviveIndefinitely == true then
    bCanSelfRevival = true
    print(bWriteLog and "GameModeBase:IsPlayerCanSelfRevival, bCanSelfRevival = true because bReviveIndefinitely")
  end
  if bCanSelfRevival == false then
    local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
    if DSReviveSubsystem and DSReviveSubsystem:GetPOIAreaReviveConfig() and uPlayerState.GetBuyReviveCount and 0 < uPlayerState:GetBuyReviveCount() then
      bCanSelfRevival = true
    end
  end
  if uPlayerState.SetCanSelfRevival then
    uPlayerState:SetCanSelfRevival(bCanSelfRevival)
  end
  print(bWriteLog and "GameModeBase:IsPlayerCanSelfRevival, bCanSelfRevival = " .. tostring(bCanSelfRevival) .. " when PlayerKey = " .. tostring(uPlayerState.PlayerKey))
  return bCanSelfRevival
end
function GameModeBase:RevivalRestoreDataFinish(uPlayerCharacter, nPlayerKey, bAI)
  if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "revivaldebug GameModeBase RevivalRestoreDataFinish uPlayerCharacter:", uPlayerCharacter.PlayerKey)
    if Game:IsValid(self.GameState) then
      local CurState = self:GetCurrentState()
      if CurState and slua.isValid(CurState) and CurState.PlayersInfoRecord then
        CurState:PlayersInfoRecord()
      else
        local SelfRevival = false
        local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
        if DSReviveSubsystem:GetItemReviveConfig() or DSReviveSubsystem:GetHelicopterReviveConfig() and DSReviveSubsystem.PlayerLastRevivalType[nPlayerKey] ~= DSReviveSubsystem.ReviveType.MVP then
          local uPlayerState = uPlayerCharacter:GetPlayerStateSafety()
          if uPlayerState and slua.isValid(uPlayerState) and self:IsPlayerCanSelfRevival(uPlayerState) then
            print(bWriteLog and "GameModeBase:RevivalRestoreDataFinish, SelfRevive, PlayerKey = " .. tostring(uPlayerCharacter.PlayerKey))
            SelfRevival = true
          end
        end
        if not SelfRevival then
          print(bWriteLog and "GameModeBase:RevivalRestoreDataFinish, no PlayersInfoRecord function, and AlivePlayerNum + 1")
          self.GameState:SetAlivePlayerNum(self.GameState:GetAlivePlayerNum() + 1)
        end
      end
    end
    if uPlayerCharacter.AddRevivalCount then
      uPlayerCharacter:AddRevivalCount(-1)
    end
    local uPlayerState = uPlayerCharacter:GetPlayerStateSafety()
    if uPlayerState and slua.isValid(uPlayerState) then
      print(bWriteLog and "revivaldebug GameModeBase HandleOnPawnDie IsInWaittingRevivalState false PlayerKey:", uPlayerCharacter.PlayerKey)
      uPlayerState.IsInWaittingRevivalState = false
      if uPlayerState.ResetDiedPlayerCount then
        uPlayerState:ResetDiedPlayerCount()
      end
      uPlayerState:LuaBroadcastCommonEventCpp("EVENTTYPE_INGAME_NORMAL", "EVENTID_PLAYER_REVIVAL_FINISH", nPlayerKey)
    end
  end
end
function GameModeBase:CheckTeammateAllNearDeath(uCharacter)
  if not slua.isValid(uCharacter) then
    return
  end
  if uCharacter.bEnsure then
    return
  end
  if slua.isValid(uCharacter) and uCharacter.GetPlayerStateSafety then
    local bHasHealthTeammate = false
    local uCurPlayerState = uCharacter:GetPlayerStateSafety()
    if slua.isValid(uCurPlayerState) then
      local tOtherTeammate = uCurPlayerState:GetTeamMatePlayerStateList({}, true)
      for i, uTeammatePlayerState in pairs(tOtherTeammate) do
        if slua.isValid(uTeammatePlayerState) then
          local uOtherCharacter = uTeammatePlayerState:GetPlayerCharacter()
          local CanSelfRevive = self:IsPlayerCanSelfRevival(uTeammatePlayerState)
          if slua.isValid(uOtherCharacter) and (uOtherCharacter.Health and uOtherCharacter.Health > 1.0E-5 or uOtherCharacter:CanSelfRescue() or uTeammatePlayerState.bIsRespawning or CanSelfRevive) then
            bHasHealthTeammate = true
            break
          end
        end
      end
      if self:IsPlayerCanSelfRevival(uCurPlayerState) or uCharacter:CanSelfRescue() then
        bHasHealthTeammate = true
        print(bWriteLog and "GameModeBase:CheckTeammateAllNearDeath, PlayerCanSelfRevival when PlayerKey = " .. tostring(uCurPlayerState.PlayerKey))
      end
      if (not (not Server or Server.IsShipping()) or CGame:IsEditor()) and uCharacter.bReviveIndefinitely == true then
        bHasHealthTeammate = true
        print(bWriteLog and "GameModeBase:CheckTeammateAllNearDeath, bHasHealthTeammate = true because bReviveIndefinitely")
      end
      print(bWriteLog and "GameModeBase:CheckTeammateAllNearDeath, bHasHealthTeammate = " .. tostring(bHasHealthTeammate))
      if bHasHealthTeammate == false then
        self.AllTeammatesDied[uCharacter.TeamID] = true
        print(bWriteLog and "revivaldebug GameModeBase CheckTeammateAllNearDeath bHasHealthTeammate false, uPlayerState:", uCharacter.PlayerKey)
        for _, uTeamPlayerState in pairs(tOtherTeammate) do
          if Game:IsValid(uTeamPlayerState) and uTeamPlayerState:IsAlive() == false then
            self:ClearPlayerRevialAndSendBattleResult(uTeamPlayerState, true, false, false)
          end
        end
      end
    end
  end
end
function GameModeBase:CheckTeamTerminatedClearRevival(uPlayerState)
  if slua.isValid(uPlayerState) and slua.isValid(uPlayerState) then
    local tOtherTeammate = uPlayerState:GetTeamMatePlayerStateList({}, true)
    local bHasHealthTeammate = false
    for _, uTeamPlayerState in pairs(tOtherTeammate) do
      if slua.isValid(uTeamPlayerState) then
        local uOtherCharacter = uTeamPlayerState:GetPlayerCharacter()
        local CanSelfRevive = self:IsPlayerCanSelfRevival(uTeamPlayerState)
        if slua.isValid(uOtherCharacter) and (uOtherCharacter.Health and uOtherCharacter.Health > 1.0E-5 or uOtherCharacter:CanSelfRescue() or uTeamPlayerState.bIsRespawning or CanSelfRevive) then
          bHasHealthTeammate = true
          break
        else
          local bIsAI = false
          local uController = uTeamPlayerState:GetOwner()
          if Game:IsAIController(uController) then
            bIsAI = true
          end
          if bIsAI and not Game:IsValid(uOtherCharacter) and uTeamPlayerState:IsAlive() then
            bHasHealthTeammate = true
            break
          end
        end
      end
    end
    local uPlayerCharacter = uPlayerState:GetPlayerCharacter()
    if self:IsPlayerCanSelfRevival(uPlayerState) or Game:IsValid(uPlayerCharacter) and uPlayerCharacter:CanSelfRescue() then
      bHasHealthTeammate = true
      print(bWriteLog and "GameModeBase:CheckTeamTerminatedClearRevival, PlayerCanSelfRevival when PlayerKey = " .. tostring(uPlayerState.PlayerKey))
    end
    if not (not Server or Server.IsShipping()) or CGame:IsEditor() then
      local uCharacter = uPlayerState:GetPlayerCharacter()
      if uCharacter and uCharacter.bReviveIndefinitely == true then
        bHasHealthTeammate = true
        print(bWriteLog and "GameModeBase:CheckTeamTerminatedClearRevival, bHasHealthTeammate = true because bReviveIndefinitely")
      end
    end
    print(bWriteLog and "GameModeBase:CheckTeamTerminatedClearRevival, bHasHealthTeammate = " .. tostring(bHasHealthTeammate) .. ", PlayerKey = " .. tostring(uPlayerState.PlayerKey))
    if bHasHealthTeammate == false then
      do
        local CanSendTeamResult = true
        for _, uTeamPlayerState in pairs(tOtherTeammate) do
          if Game:IsValid(uTeamPlayerState) then
            if uTeamPlayerState:IsAlive() == false then
              self:ClearPlayerRevialAndSendBattleResult(uTeamPlayerState, true, false, false)
            else
              CanSendTeamResult = false
            end
          end
        end
        self:ClearPlayerRevialAndSendBattleResult(uPlayerState, false)
        if CanSendTeamResult == false then
          self:AddGameTimer(0.1, false, function()
            if Game:IsValid(uPlayerCharacter) then
              local Component = uPlayerCharacter.NearDeatchComponent
              if Component and slua.isValid(Component) then
                Component:ClearNearDeathTeammate()
              end
            end
          end)
        end
      end
    end
  end
end
function GameModeBase:ClearPlayerRevialAndSendBattleResult(uPlayerState, bSendBattleResult, bSyncSend, bSendTeamResult)
  if uPlayerState and slua.isValid(uPlayerState) then
    if uPlayerState.ClearAllReviveCounts then
      uPlayerState:ClearAllReviveCounts()
    end
    if bSendBattleResult then
      if bSyncSend then
        if uPlayerState.bHasSendBattleResult == false then
          self:AddGameTimer(0.01, false, function()
            if slua.isValid(self.Object) and slua.isValid(uPlayerState) then
              Game:CheckSendBattleResult(self.Object, uPlayerState, bSendTeamResult or false)
            end
          end)
        end
      else
        Game:CheckSendBattleResult(self.Object, uPlayerState, bSendTeamResult or false)
      end
    end
  end
end
function GameModeBase:GetIdeaDecalManager()
  if not slua.isValid(self.Object) then
    return nil
  end
  if not slua.isValid(self.IdeaDecalManager) then
    local UGameplayStatics = import("GameplayStatics")
    local uActorArray = UGameplayStatics.GetAllActorsOfClass(self.Object, import("IdeaDecalManager"), slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor")))
    if uActorArray:Num() > 0 then
      self.IdeaDecalManager = uActorArray:Get(0)
    elseif CGameWorld then
      self.IdeaDecalManager = CGameWorld:SpawnActor(import("IdeaDecalManager"), nil, nil, nil)
    end
  end
  return self.IdeaDecalManager
end
function GameModeBase:GetWeaponDamageFromRecord(PlayerKey, TargetWeaponType)
  print(bWriteLog and "GameModeBase:GetWeaponDamageFromRecord", PlayerKey, TargetWeaponType)
  PlayerKey = tonumber(PlayerKey)
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  if WeaponRecordSubSystem and PlayerKey then
    return WeaponRecordSubSystem:GetWeaponDamageFromRecord(PlayerKey, TargetWeaponType)
  end
  return 0
end
function GameModeBase:GetWeaponReportByWeaponRecord(PlayerKey)
  PlayerKey = tonumber(PlayerKey)
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  local OnePlayerWeapon = import("OnePlayerWeapon")()
  local uPlayer = Game:GetPlayerByPlayerKey(tonumber(PlayerKey))
  print(bWriteLog and "GameModeBase:GetWeaponReportByWeaponRecord", PlayerKey, uPlayer)
  if WeaponRecordSubSystem and slua.isValid(uPlayer) then
    OnePlayerWeapon = WeaponRecordSubSystem:InitWeaponReportByWeaponRecord(PlayerKey, Game:GetPlayerUID(uPlayer))
  end
  print(bWriteLog and "GameModeBase:GetWeaponReportByWeaponRecord", OnePlayerWeapon)
  return OnePlayerWeapon
end
function GameModeBase:GetPlayerTotalShootNum(PlayerKey)
  PlayerKey = tonumber(PlayerKey)
  local WeaponRecordSubSystem = SubsystemMgr:Get("WeaponRecordSubSystem")
  local ShootNum = 0
  if WeaponRecordSubSystem then
    ShootNum = WeaponRecordSubSystem:GetPlayerTotalShootNum(PlayerKey)
  end
  print(bWriteLog and "GameModeBase:GetPlayerTotalShootNum", PlayerKey, ShootNum)
  return ShootNum
end
function GameModeBase:GetCircleTimeErrorFlow()
  local CircleMgrComponentCls = import("/Script/ShadowTrackerExtra.CircleMgrComponent")
  local uCircleMgrComponent = self:GetComponentByClass(CircleMgrComponentCls)
  if slua.isValid(uCircleMgrComponent) and uCircleMgrComponent.TimerErrorFlow:Num() > 0 then
    local ContentTable = {}
    local TimerErrorFlowLen = uCircleMgrComponent.TimerErrorFlow:Num()
    for CurrentIndex = 0, TimerErrorFlowLen - 1 do
      table.insert(ContentTable, uCircleMgrComponent.TimerErrorFlow:Get(CurrentIndex))
    end
    local ContentParams = table.concat(ContentTable, ";")
    return ContentParams
  end
end
function GameModeBase:FindOrCreateMultiNavComponent()
  if Game:IsValid(self.uMultiNavDataComp) then
    return self.uMultiNavDataComp
  end
  local uMultiNavDataCompClass = slua.loadClass("/Game/BluePrints/Core/BP_MultiNavDataComponent.BP_MultiNavDataComponent")
  local MultiNavComp = self:GetComponentByClass(uMultiNavDataCompClass)
  if Game:IsValid(MultiNavComp) then
    self.uMultiNavDataComp = MultiNavComp
    return self.uMultiNavDataComp
  end
  self.uMultiNavDataComp = Game:AddComponent(uMultiNavDataCompClass, self.Object, "BP_MultiNavDataComponent")
  if not Game:IsValid(self.uMultiNavDataComp) then
    print(bWriteLog and "error GameModeBase:FindOrCreateMultiNavComponent failed to create.")
    return nil
  end
  return self.uMultiNavDataComp
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CGameModeBase = class(CActorBase, nil, GameModeBase)
return CGameModeBase