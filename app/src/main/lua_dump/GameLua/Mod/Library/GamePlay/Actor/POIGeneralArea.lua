local POIGeneralArea = {}
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local ECollisionChannel = import("ECollisionChannel")
local ECollisionResponse = import("ECollisionResponse")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function POIGeneralArea:ctor()
  self.ClassPathFilter = "STExtraCharacter"
  self.PlayerCount = 0
  self.PlayerInfos = {}
  self.VisitedPlayerMap = {}
  self.PlayerReviveRecord = {}
  self.EnterPOITipsRecord = {}
  self.EnableRevive = false
  self.bAddReviveCard = false
  self.bReviveToPlane = false
  self.bReviveToLoc = false
  self.bReviveToLocAndParachute = false
end
POIGeneralArea.RecordKillTimes = {}
POIGeneralArea.RecordDieTimes = {}
POIGeneralArea.RecordReviveTimes = {}
function POIGeneralArea:ReceiveBeginPlay()
  POIGeneralArea.__super.ReceiveBeginPlay(self)
  if not self:IsAuthority() then
    self:CheckEnableViewPointTrigger()
  else
    if self.PlayerReviveInCntTlogID > 0 then
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_REVIVAL_FINISH, self.GenReviveFinishTLog, self)
    end
    if 0 < self.PlayerDieCntTlogID or 0 < self.PlayerKillCntTlogID then
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CHARACTER_DIED_PRE, self.HandleOnPawnDie, self)
    end
    self:InitReviveConfig()
    self.DeathPlayerSkyTransitionIds = {}
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_RESET_DATA_ON_RESPAWN, self.OnResetDataOnRespawn, self)
  end
  self.VisitedPlayerMap = {}
  if self.bTestPet and slua.isValid(self.PlayAreaComponent) then
    self.PlayAreaComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_WorldDynamic, ECollisionResponse.ECR_Overlap)
  end
  local POIGeneralAreaSubsystem = SubsystemMgr:Get("POIGeneralAreaSubsystem")
  if POIGeneralAreaSubsystem then
    POIGeneralAreaSubsystem:Register(self)
  end
end
function POIGeneralArea:CheckEnableViewPointTrigger()
  if Client then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    GameplayData.AddSelfPlayerControllerEvent(self, "OnSetViewTarget", self.OnSetViewTarget, self)
  end
end
function POIGeneralArea:InitReviveConfig()
  if Client then
    return
  end
  if self.ReviveType == 1 then
    self.bAddReviveCard = true
  elseif self.ReviveType == 2 then
    self.bReviveToPlane = true
  elseif self.ReviveType == 3 then
    self.bReviveToLoc = true
  elseif self.ReviveType == 4 then
    self.bReviveToLocAndParachute = true
  end
  if self.AreaID > 0 then
    print(bWriteLog and "POIGeneralArea:InitReviveConfig AreaID:" .. tostring(self.AreaID))
    local nCfgCount = 0
    if self.bAddReviveCard then
      nCfgCount = nCfgCount + 1
      print(bWriteLog and "POIGeneralArea:InitReviveConfig bAddReviveCard")
    end
    if self.bReviveToPlane then
      nCfgCount = nCfgCount + 1
      print(bWriteLog and "POIGeneralArea:InitReviveConfig bReviveToPlane")
    end
    if self.bReviveToLoc then
      nCfgCount = nCfgCount + 1
      print(bWriteLog and "POIGeneralArea:InitReviveConfig bReviveToLoc")
    end
    if self.bReviveToLocAndParachute then
      nCfgCount = nCfgCount + 1
      print(bWriteLog and "POIGeneralArea:InitReviveConfig bReviveToLocAndParachute")
    end
    if 1 < nCfgCount then
      print(bWriteLog and "POIGeneralArea:InitReviveConfig Config Error")
      return
    end
    if self.bExitPOIAreaClearRevive and slua.isValid(self.SpecialClearReviveArea) then
      print(bWriteLog and "POIGeneralArea:InitReviveConfig Clear ReviveState Config-1 Error!!!")
      return
    end
    if not self.bExitPOIAreaClearRevive and not slua.isValid(self.SpecialClearReviveArea) then
      print(bWriteLog and "POIGeneralArea:InitReviveConfig Clear ReviveState Config-2 Error!!!")
      return
    end
    if slua.isValid(self.SpecialClearReviveArea) then
      if self.SpecialClearReviveArea.RegisterPOIAreaInfo then
        self.SpecialClearReviveArea:RegisterPOIAreaInfo(self.AreaID, self.Object)
      else
        print(bWriteLog and "POIGeneralArea:InitReviveConfig SpecialClearReviveArea Error!!!")
        return
      end
    end
    if self.bReviveToPlane or self.bReviveToLoc or self.bReviveToLocAndParachute then
      print(bWriteLog and "POIGeneralArea:InitReviveConfig Config Is Valid")
      self:RegisterPOIAreaToReviveSubsystem()
    end
  else
    print(bWriteLog and "POIGeneralArea:InitReviveConfig AreaID:" .. tostring(self.AreaID) .. " Is Invalid")
  end
end
function POIGeneralArea:RegisterPOIAreaToReviveSubsystem()
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  if DSReviveSubsystem and DSReviveSubsystem.RegisterPOIReviveInfo then
    print(bWriteLog and "POIGeneralArea:RegisterPOIAreaToReviveSubsystem")
    local bResult = false
    if self.bReviveToPlane then
      bResult = DSReviveSubsystem:RegisterPOIReviveInfo(self.Object, self.AreaID, self.bIndependentRevive, "ReviveToPlane")
    elseif self.bReviveToLoc then
      bResult = DSReviveSubsystem:RegisterPOIReviveInfo(self.Object, self.AreaID, self.bIndependentRevive, "ReviveToLoc", self.ReviveCentreLoc, self.ReviveLocRadius)
    elseif self.bReviveToLocAndParachute then
      bResult = DSReviveSubsystem:RegisterPOIReviveInfo(self.Object, self.AreaID, self.bIndependentRevive, "ReviveToLocAndParachute", self.ReviveCentreLoc, self.ReviveLocRadius)
    end
    if bResult then
      self.EnableRevive = true
    else
      print(bWriteLog and "POIGeneralArea:RegisterPOIAreaToReviveSubsystem")
    end
  end
end
function POIGeneralArea:CheckIsEnableViewPointTriggerTarget(ViewTarget)
  if Game:IsClassOf(ViewTarget, import("SpectatorPawn")) then
    return true
  end
  return false
end
function POIGeneralArea:OnSetViewTarget(NewViewTarget)
  if Client then
    if self:CheckIsEnableViewPointTriggerTarget(NewViewTarget) then
      print(bWriteLog and string.format("POIGeneralArea:OnSetViewTarget ViewPointTick %s %s", tostring(self.Object), tostring(NewViewTarget)))
      self:RegisterViewPointTick()
    else
      print(bWriteLog and string.format("POIGeneralArea:OnSetViewTarget UnViewPointTick %s %s", tostring(self.Object), tostring(NewViewTarget)))
      self:UnRegisterViewPointTick()
    end
  end
end
function POIGeneralArea:ResetViewPointOverlaps()
  POIGeneralArea.__super.ResetViewPointOverlaps(self)
  local uControllerArray = Game:GetAllPlayerControllers()
  if uControllerArray then
    for _, uPlayerController in pairs(uControllerArray) do
      if slua.isValid(uPlayerController) and uPlayerController.SkyTransition ~= nil and uPlayerController.SkyTransition.bClientStateBlock then
        uPlayerController.SkyTransition:ClientReSetState(0)
      end
    end
  end
end
function POIGeneralArea:OnPlayAreaBeginOverlapFunc(uOverlappedActorOrComp, uOtherActor)
  if Client and self.ViewPointTickTimer ~= nil then
    if not self.bNeedCheckOverlapOnce or self.OverlapList[uOtherActor] == nil then
      self.OverlapList[uOtherActor] = true
      if Game:IsClassOf(uOtherActor, import("/Script/ShadowTrackerExtra.STExtraPlayerController")) and uOtherActor.SkyTransition ~= nil then
        uOtherActor.SkyTransition:ClientSetState(self.SkyTransitionID, 0)
      end
    end
    return
  end
  POIGeneralArea.__super.OnPlayAreaBeginOverlapFunc(self, uOverlappedActorOrComp, uOtherActor)
end
function POIGeneralArea:OnPlayAreaEndOverlapFunc(uOverlappedActorOrComp, uOtherActor)
  if Client and self.ViewPointTickTimer ~= nil then
    self.OverlapList[uOtherActor] = nil
    if Game:IsClassOf(uOtherActor, import("/Script/ShadowTrackerExtra.STExtraPlayerController")) and uOtherActor.SkyTransition ~= nil then
      uOtherActor.SkyTransition:ClientSetState(1, 0)
    end
    return
  end
  POIGeneralArea.__super.OnPlayAreaEndOverlapFunc(self, uOverlappedActorOrComp, uOtherActor)
end
function POIGeneralArea:GetLifetimeReplicatedProps()
  local BaseRepTable = POIGeneralArea.__super.GetLifetimeReplicatedProps(self) or {}
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "RepAreaID",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "PlayerCount",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "RepSkyTransitionID",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function POIGeneralArea:GenReviveFinishTLog(_, __, PlayerKey)
  if CGameMode and CGameMode.FindPlayerStateWithPlayerKey then
    local uPlayerState = CGameMode:FindPlayerStateWithPlayerKey(PlayerKey, "Normal")
    if slua.isValid(uPlayerState) and self:CheckCanRecord(PlayerKey, POIGeneralArea.RecordReviveTimes) then
      local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      if USTExtraBlueprintFunctionLibrary.IsPointComponentBoxIntersection(uPlayerState.DeadLocation, self.PlayAreaComponent) then
        uPlayerState:AddGeneralCount(self.PlayerReviveInCntTlogID, 1, false)
        POIGeneralArea.RecordReviveTimes[PlayerKey] = CGameState:GetServerWorldTimeSeconds()
        print(bWriteLog and "POIGeneralArea:GenReviveFinishTLog success")
      end
    end
  end
end
POIGeneralArea.ShowedTipsPlayerList = {}
function POIGeneralArea:ServerOnPlayerEnterOrLeave(uPlayer, bEnter)
  POIGeneralArea.__super.ServerOnPlayerEnterOrLeave(self, uPlayer, bEnter)
  self:HandleServerOnPlayerEnterOrLeave(uPlayer, bEnter)
end
function POIGeneralArea:HandleServerOnPlayerEnterOrLeave(uPlayer, bEnter)
  if not slua.isValid(uPlayer) then
    return
  end
  local uPlayerState = uPlayer:GetPlayerStateSafety()
  if self.EnterPlayerCntTlogID > 0 and slua.isValid(uPlayerState) and bEnter and self.VisitedPlayerMap[uPlayerState.PlayerKey] == nil then
    self.VisitedPlayerMap[uPlayerState.PlayerKey] = true
    uPlayerState:AddGeneralCount(self.EnterPlayerCntTlogID, 1, false)
    print(bWriteLog and "POIGeneralArea:GenPlayerEnterTLog success")
  end
  if 0 < self.EnterAreaTypeTlogID and slua.isValid(uPlayerState) then
    print(bWriteLog and "POIGeneralArea:EnterAreaTypeTlog success UID = " .. tostring(uPlayerState.UID))
    uPlayerState:AddGeneralCount(self.EnterAreaTypeTlogID, 1, true)
  end
  self:HandleSetAreaID(uPlayer, bEnter)
  self:HandleSetMapID(uPlayer, bEnter)
  if bEnter and self.bAddReviveCard then
    self:CheckAddRevivalItem(uPlayer)
  end
  if self.bCountPlayer then
    self:CountPlayer(uPlayer, bEnter)
  end
  local EPawnState = import("EPawnState")
  if self.bAddReviveCard and slua.isValid(uPlayerState) and uPlayerState.ReviveStateFeature and uPlayerState.ReviveStateFeature.DSSetRevivalCardCountdown and uPlayer:HasState(EPawnState.Dead) == false then
    uPlayerState.ReviveStateFeature:DSSetRevivalCardCountdown(not bEnter)
    if bEnter == false and uPlayerState.ReviveStateFeature:GetHaveSinglePlayerReviveItem() == true and not uPlayer:HasState(EPawnState.SplineMove) then
      local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      local ReviveConfig = GamePlayTools.GetCurrentConfig("ReviveConfig")
      local LastShowTipsTime = math.maxinteger
      if POIGeneralArea.ShowedTipsPlayerList[uPlayer.PlayerKey] then
        LastShowTipsTime = CGameState:GetServerWorldTimeSeconds() - POIGeneralArea.ShowedTipsPlayerList[uPlayer.PlayerKey]
      end
      if ReviveConfig.LeavePOITipsID and ReviveConfig.LeavePOIShowTipsCD and LastShowTipsTime > ReviveConfig.LeavePOIShowTipsCD then
        Game:UIShowImageTips(uPlayer.PlayerKey, ReviveConfig.LeavePOITipsID)
        POIGeneralArea.ShowedTipsPlayerList[uPlayer.PlayerKey] = CGameState:GetServerWorldTimeSeconds()
      end
    end
  end
  if bEnter then
    if self.EnterAreaTipsID and 0 < self.EnterAreaTipsID then
      if uPlayer.PlayerKey and not self.EnterPOITipsRecord[uPlayer.PlayerKey] then
        Game:UIShowImageTips(uPlayer.PlayerKey, self.EnterAreaTipsID)
        self.EnterPOITipsRecord[uPlayer.PlayerKey] = true
      else
        print(bWriteLog and "POIGeneralArea:HandleServerOnPlayerEnterOrLeave Has Sent Tips = " .. tostring(uPlayer.PlayerKey))
      end
    else
      print(bWriteLog and "POIGeneralArea:HandleServerOnPlayerEnterOrLeave No EnterAreaTipsID")
    end
  end
  self:SetSkyTransitionState(uPlayer, bEnter)
end
function POIGeneralArea:ServerOnFakePlayerEnterOrLeave(uPlayer, bEnter)
  POIGeneralArea.__super.ServerOnFakePlayerEnterOrLeave(self, uPlayer, bEnter)
  self:HandleServerOnFakePlayerEnterOrLeave(uPlayer, bEnter)
end
function POIGeneralArea:HandleServerOnFakePlayerEnterOrLeave(uPlayer, bEnter)
  if not slua.isValid(uPlayer) or not Game:IsBaseCharacter(uPlayer) then
    return
  end
  if self.bCountPlayer then
    self:CountPlayer(uPlayer, bEnter)
  end
  self:HandleSetAreaID(uPlayer, bEnter)
  if slua.isValid(uPlayer) and uPlayer.bEnsure and uPlayer.GetControllerSafety then
    local uController = uPlayer:GetControllerSafety()
    if slua.isValid(uController) and uController.FakePlayerBornType == 1 then
      return
    end
  end
  self:HandleSetMapID(uPlayer, bEnter)
  if bEnter and self.bAddReviveCard then
    self:CheckAddRevivalItem(uPlayer)
  end
  self:RecordAIHasBeenToPOI(uPlayer, bEnter)
  local uPlayerState = uPlayer:GetPlayerStateSafety()
  if self.bAddReviveCard and slua.isValid(uPlayerState) and uPlayerState.ReviveStateFeature and uPlayerState.ReviveStateFeature.DSSetRevivalCardCountdown and uPlayerState.ReviveStateFeature.bHaveSinglePlayerReviveItem then
    uPlayerState.ReviveStateFeature:DSSetRevivalCardCountdown(not bEnter)
  end
end
function POIGeneralArea:RecordAIHasBeenToPOI(uCharacter, bEnter)
  if Game:IsValid(uCharacter) == false then
    return
  end
  if Game:IsValid(CGameState) == false or CGameState:GetGameModeState() ~= "FightingState" then
    return
  end
  if bEnter then
    if uCharacter.bEnsure and uCharacter.bMEnsure == false then
      local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
      if MLAIProcessSubSystem then
        MLAIProcessSubSystem:AddAIWhoHaveBeenToPOI(uCharacter.PlayerKey, self.Object)
      end
    end
  else
    local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
    if MLAIProcessSubSystem then
      MLAIProcessSubSystem:RemoveAIWhoHaveBeenToPOI(uCharacter.PlayerKey)
    end
  end
end
function POIGeneralArea:OnOtherActorEnterOrLeave(uOtherActor, bEnter)
  if Client then
    return
  end
  if uOtherActor.SetAttrValue ~= nil then
    self:HandleSetAreaID(uOtherActor, bEnter)
    self:HandleSetMapID(uOtherActor, bEnter)
  end
  if uOtherActor.SkyTransition ~= nil then
    self:SetSkyTransitionState(uOtherActor, bEnter)
  end
end
function POIGeneralArea:SetSkyTransitionID(NewSkyTransitionID)
  if Client then
    return
  end
  if self.SkyTransitionID ~= NewSkyTransitionID then
    local uActorList = self:GetAllOverlapActorsInArea()
    if uActorList then
      for _, uActor in pairs(uActorList) do
        if slua.isValid(uActor) and uActor.SkyTransition then
          uActor.SkyTransition:SetStateActive(self.SkyTransitionID, false)
          uActor.SkyTransition:SetStateActive(NewSkyTransitionID, true)
        end
      end
    end
    self.SkyTransitionID = NewSkyTransitionID
    self.RepSkyTransitionID = NewSkyTransitionID
  end
end
function POIGeneralArea:OnRep_RepSkyTransitionID(OldSkyTransitionID)
  if Client and self.ViewPointTickTimer ~= nil and self.RepSkyTransitionID ~= OldSkyTransitionID then
    self.SkyTransitionID = self.RepSkyTransitionID
    if self.OverlapList then
      for uActor, bValid in pairs(self.OverlapList) do
        if Game:IsClassOf(uActor, import("/Script/ShadowTrackerExtra.STExtraPlayerController")) and bValid then
          self:SetSkyTransitionState(uActor, true)
        end
      end
    end
  end
end
function POIGeneralArea:SetSkyTransitionState(uOtherActor, bEnter)
  if Client then
    if self.SkyTransitionID <= 0 then
      return
    end
    if Game:IsClassOf(uOtherActor, import("/Script/ShadowTrackerExtra.STExtraPlayerController")) and uOtherActor.SkyTransition ~= nil then
      if bEnter then
        uOtherActor.SkyTransition:ClientSetState(self.SkyTransitionID, 0)
      else
        uOtherActor.SkyTransition:ClientReSetState(0)
      end
    end
  else
    if self.SkyTransitionID <= 0 then
      return
    end
    if slua.isValid(uOtherActor) and uOtherActor.SkyTransition ~= nil then
      if bEnter then
        uOtherActor.SkyTransition:SetStateActive(self.SkyTransitionID, true)
      elseif self.bDeathNotLeaveSkyTransition and self:IsPlayerCharacterDead(uOtherActor) then
        print(bWriteLog and string.format("POIGeneralArea:SetSkyTransitionState bDeathNotLeaveSkyTransition %s", uOtherActor.PlayerKey))
        self.DeathPlayerSkyTransitionIds[uOtherActor.PlayerKey] = self.SkyTransitionID
      else
        uOtherActor.SkyTransition:SetStateActive(self.SkyTransitionID, false)
      end
    end
  end
end
function POIGeneralArea:IsPlayerCharacterDead(uOtherActor)
  if Game:IsClassOf(uOtherActor, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
    if uOtherActor.Health > 0 or uOtherActor.NearDeatchComponent and uOtherActor.NearDeatchComponent:IsHaveLastBreathStatus() then
      return false
    else
      return true
    end
  else
    return false
  end
end
function POIGeneralArea:OnResetDataOnRespawn(_, __, uPlayerCharacter)
  if self.bDeathNotLeaveSkyTransition and slua.isValid(uPlayerCharacter) and uPlayerCharacter.SkyTransition then
    local nPlayerKey = uPlayerCharacter.PlayerKey
    print(bWriteLog and string.format("POIGeneralArea:OnResetDataOnRespawn %s (%s)", uPlayerCharacter.ToString ~= nil and uPlayerCharacter:ToString() or uPlayerCharacter.PlayerKey, self.Object))
    local SkyTransitionId = self.DeathPlayerSkyTransitionIds[nPlayerKey]
    if SkyTransitionId then
      print(bWriteLog and string.format("POIGeneralArea:OnResetDataOnRespawn restore %s SkyTransitionId = %s", nPlayerKey, SkyTransitionId))
      uPlayerCharacter.SkyTransition:SetStateActive(SkyTransitionId, false)
      self.DeathPlayerSkyTransitionIds[nPlayerKey] = nil
    end
  end
end
function POIGeneralArea:CountPlayer(uPlayer, bEnter)
  if not self.PlayerCount then
    return
  end
  if slua.isValid(uPlayer) and uPlayer.bEnsure and uPlayer.GetControllerSafety then
    local uController = uPlayer:GetControllerSafety()
    if slua.isValid(uController) and uController.FakePlayerBornType == 1 then
      return
    end
  end
  if bEnter then
    self.PlayerCount = self.PlayerCount + 1
  else
    self.PlayerCount = self.PlayerCount - 1
  end
end
POIGeneralArea.GetRevivalItemPlayers = {}
function POIGeneralArea:CheckAddRevivalItem(uPlayer)
  if not slua.isValid(CGameState) or CGameState:GetGameModeState() ~= "FightingState" then
    return
  end
  if not slua.isValid(uPlayer) then
    return
  end
  if uPlayer.bEnsure and uPlayer.bMEnsure == false then
    local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
    if MLAIProcessSubSystem then
      MLAIProcessSubSystem:AddAIWhoHaveBeenToPOI(uPlayer.PlayerKey, self.Object)
    end
    return
  end
  if not uPlayer:IsAlive() then
    return
  end
  local uPlayerState = uPlayer:GetPlayerStateSafety()
  if uPlayerState and slua.isValid(uPlayerState) and uPlayerState and uPlayerState.ReviveStateFeature and uPlayerState.ReviveStateFeature:GetUseSinglePlayerReviveItem() == true then
    return
  end
  if POIGeneralArea.GetRevivalItemPlayers[uPlayer.PlayerKey] then
    return
  end
  POIGeneralArea.GetRevivalItemPlayers[uPlayer.PlayerKey] = true
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  if not DSReviveSubsystem then
    return
  end
  local ItemReviveConfig = DSReviveSubsystem:GetItemReviveConfig()
  if ItemReviveConfig then
    local SelfReviveItemId = ItemReviveConfig.ItemId
    Game:AddItemByResID(uPlayer, SelfReviveItemId, 1)
  end
end
function POIGeneralArea:OnRep_PlayerCount(OldValue)
  print(bWriteLog and "POIGeneralArea:OnRep_PlayerCount, AreaID: " .. tostring(self.PlayerCount) .. "," .. tostring(self.AreaID))
  self:UpdateUI(self.PlayerCount, self.AreaID)
end
function POIGeneralArea:UpdateUI(Count, CurAreaIndex)
  local UI = UIManager.GetUI(UIManager.UI_Config_InGame.AreaPlayerNumPanel)
  if UI ~= nil then
    if UI.ReCheckArea then
      UI:ReCheckArea(Count, CurAreaIndex)
    end
  else
    UIManager.ShowUI(UIManager.UI_Config_InGame.AreaPlayerNumPanel, Count, CurAreaIndex)
    print(bWriteLog and "POIGeneralArea:UpdateUI There is no target ui, Create AreaPlayerNumPanel")
  end
  local MiniUI = UIManager.GetUI(UIManager.UI_Config_InGame.AreaPlayerNumMiniPanel)
  if MiniUI ~= nil then
    if MiniUI.ReCheckArea then
      MiniUI:ReCheckArea(Count, CurAreaIndex)
    end
  else
    UIManager.ShowUI(UIManager.UI_Config_InGame.AreaPlayerNumMiniPanel, Count, CurAreaIndex)
    print(bWriteLog and "POIGeneralArea:UpdateUI There is no target MiniUI, Create AreaPlayerNumMiniPanel")
  end
end
function POIGeneralArea:DSCheckPlayerCount()
  if slua.isValid(self.PlayAreaComponent) then
    local Actor_C = import("/Script/Engine.Actor")
    local PlayerPawn_C = import("STExtraPlayerCharacter")
    local AreaPlayerList = self.PlayAreaComponent:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, Actor_C), PlayerPawn_C)
    if AreaPlayerList and AreaPlayerList.Num then
      self.PlayerCount = AreaPlayerList:Num()
    end
  end
end
function POIGeneralArea:GetPlayerCount()
  return self.PlayerCount
end
function POIGeneralArea:HandleOnPawnDie(_, __, Pawn, TypeID, Killer, EventInstigator)
  local Player = Pawn
  local PlayerKey = Game:GetPlayerKey(Player)
  if self.PlayerDieCntTlogID > 0 and slua.isValid(Player) and Game:IsPlayer(Player) then
    local PlayerLocation = Game:GetActorLocation(Player)
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local PlayerState = GameplayData.GetPlayerState(PlayerKey)
    if slua.isValid(PlayerState) and USTExtraBlueprintFunctionLibrary.IsPointComponentBoxIntersection(PlayerLocation, self.PlayAreaComponent) and self:CheckCanRecord(PlayerKey, POIGeneralArea.RecordDieTimes) then
      PlayerState:AddGeneralCount(self.PlayerDieCntTlogID, 1, false)
      POIGeneralArea.RecordDieTimes[PlayerKey] = CGameState:GetServerWorldTimeSeconds()
      print(bWriteLog and "POIGeneralArea:HandleOnPawnDie AddGeneralCount PlayerDieCntTlogID:", self.PlayerDieCntTlogID)
    end
  end
  if 0 < self.PlayerKillCntTlogID and slua.isValid(EventInstigator) and EventInstigator.GetPlayerCharacterSafety then
    local KillerPawn = EventInstigator:GetPlayerCharacterSafety()
    if slua.isValid(KillerPawn) and Game:IsPlayer(KillerPawn) and self.PlayAreaComponent:IsOverlappingActor(KillerPawn) and not Game:IsMonster(Pawn) and self:CheckCanRecord(PlayerKey, POIGeneralArea.RecordKillTimes) then
      local KillerPlayerState = KillerPawn:GetPlayerStateSafety()
      if slua.isValid(KillerPlayerState) and Game:IsEnemy(KillerPawn, Player) then
        KillerPlayerState:AddGeneralCount(self.PlayerKillCntTlogID, 1, false)
        POIGeneralArea.RecordKillTimes[PlayerKey] = CGameState:GetServerWorldTimeSeconds()
        print(bWriteLog and "POIGeneralArea:OnPlayerKill AddGeneralCount PlayerKillCntTlogID:", self.PlayerKillCntTlogID)
      end
    end
  end
end
function POIGeneralArea:CheckCanRecord(Key, RecordTimes)
  if RecordTimes then
    if RecordTimes[Key] == nil then
      return true
    end
    if CGameState:GetServerWorldTimeSeconds() - RecordTimes[Key] < 1 then
      return false
    end
  end
  return true
end
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
function POIGeneralArea:ClientOnPlayerEnterOrLeave(uCharacter, bEnter)
  if bEnter and slua.isValid(uCharacter) and self.EnterGuideTargetID and self.EnterGuideTargetID > 0 then
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_SET_MAP_GUIDE_TARGET, self.EnterGuideTargetID)
    print(bWriteLog and "POIGeneralArea:ClientOnPlayerEnterOrLeave EVENTID_SET_MAP_GUIDE_TARGET self.EnterGuideTargetID:", self.EnterGuideTargetID)
  end
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    if bEnter then
      TApmHelper.PostEvent(605, "EnterPOI", false)
    else
      TApmHelper.PostEvent(605, "LeavePOI", false)
    end
  end
end
function POIGeneralArea:ReceiveEndPlay(_, bClearTable)
  self:UnRegisterViewPointTick()
  POIGeneralArea.__super.ReceiveEndPlay(self, _, false)
end
function POIGeneralArea:SetAreaID(AreaID)
  print(bWriteLog and string.format("POIGeneralArea:SetAreaID %s", AreaID))
  self.  self.Rep  self:ResetMapID(self.AreaID)
  self:ForceNetUpdate()
end
function POIGeneralArea:OnRep_RepAreaID()
  print(bWriteLog and string.format("POIGeneralArea:OnRep_RepAreaID %s", self.RepAreaID))
  self.AreaID = self.RepAreaID
  self:ResetMapID(self.AreaID)
end
function POIGeneralArea:ResetMapID(AreaID)
  if self.bNeedChangeMap and self.MapID == 0 and 0 < AreaID then
    self.MapID = AreaID
    print(bWriteLog and string.format("POIGeneralArea:ResetMapID bNeedChangeMap, use AreaID %s as MapID", self.MapID))
  end
end
function POIGeneralArea:CheckPlayerCanSelfRevive(uPlayer)
  if slua.isValid(uPlayer) and uPlayer.PlayerKey then
    if not self.PlayerReviveRecord[uPlayer.PlayerKey] then
      if self.bIndependentRevive then
        print(bWriteLog and "POIGeneralArea:CheckPlayerCanSelfRevive bIndependentRevive")
        return true
      else
        local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
        if DSReviveSubsystem and DSReviveSubsystem.CheckPlayerHasRevivedInArea and not DSReviveSubsystem:CheckPlayerHasRevivedInArea(uPlayer.PlayerKey) then
          print(bWriteLog and "POIGeneralArea:CheckPlayerCanSelfRevive Not bIndependentRevive")
          return true
        end
      end
    else
      print(bWriteLog and "POIGeneralArea:CheckPlayerCanSelfRevive Not Revive In Current Area")
    end
  end
  return false
end
function POIGeneralArea:UpdatePlayerCanSelfRevive(uPlayer)
  if slua.isValid(uPlayer) and uPlayer.PlayerKey then
    print(bWriteLog and "POIGeneralArea:UpdatePlayerCanSelfRevive PlayerKey = " .. tostring(uPlayer.PlayerKey) .. " AreaID = " .. tostring(self.AreaID))
    self.PlayerReviveRecord[uPlayer.PlayerKey] = true
  end
end
function POIGeneralArea:HandleSetAreaID(uPlayer, bEnter)
  if not self.AreaID or self.AreaID <= 0 then
    return
  end
  if bEnter then
    uPlayer:SetAttrValue("AreaID", self.AreaID, -1)
  else
    uPlayer:SetAttrValue("AreaID", 0, -1)
  end
  self:HandleSetReviveState(uPlayer, bEnter)
end
function POIGeneralArea:HandleSetReviveState(uPlayer, bEnter)
  if not slua.isValid(uPlayer) then
    return false
  end
  if not Game:IsBaseCharacter(uPlayer) then
    return false
  end
  if slua.isValid(uPlayer) and uPlayer.bEnsure and uPlayer.GetControllerSafety then
    local uController = uPlayer:GetControllerSafety()
    if slua.isValid(uController) and uController.FakePlayerBornType == 1 then
      return
    end
  end
  if not self.EnableRevive then
    print(bWriteLog and "POIGeneralArea:HandleSetReviveState not EnableRevive")
    return false
  end
  if (self.bReviveToPlane or self.bReviveToLoc or self.bReviveToLocAndParachute) and uPlayer.GetPlayerStateSafety then
    local uPlayerState = uPlayer:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      if bEnter then
        local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
        if DSReviveSubsystem and not DSReviveSubsystem:GetRevivalClosedResult() then
          print(bWriteLog and "POIGeneralArea:HandleSetReviveState")
          if uPlayer:IsAlive() then
            print(bWriteLog and "POIGeneralArea:HandleSetReviveState, Alive PlayerKey = " .. tostring(uPlayer.PlayerKey) .. " AreaID = " .. tostring(self.AreaID))
            if self:CheckPlayerCanSelfRevive(uPlayer) then
              print(bWriteLog and "POIGeneralArea:HandleSetReviveState, AttrVal Add LeftBuyLifeCount ")
              uPlayerState:SetLeftBuyLifeCounts(1)
              uPlayerState.POIReviveAreaID = self.AreaID
              return true
            else
              print(bWriteLog and "POIGeneralArea:HandleSetReviveState, HasRevived In This Area")
            end
          end
        else
          print(bWriteLog and "POIGeneralArea:HandleSetReviveState, bRevivalClosed = true, PlayerKey = " .. tostring(uPlayer.PlayerKey))
        end
      elseif self.bExitPOIAreaClearRevive and uPlayer:IsAlive() and uPlayerState.POIReviveAreaID and uPlayerState.POIReviveAreaID == self.AreaID and not uPlayer:UpdatePOIReviveAreaID(self.Object) then
        uPlayerState.POIReviveAreaID = -1
        uPlayerState:SetLeftBuyLifeCounts(0)
        print(bWriteLog and "POIGeneralArea:HandleSetReviveState, Clear Revive State")
      end
    end
  end
  return false
end
function POIGeneralArea:HandleSetMapID(uPlayer, bEnter)
  if not self.bNeedChangeMap then
    return
  end
  if not self.MapID or self.MapID <= 0 then
    return
  end
  if bEnter then
    uPlayer:SetAttrValue("MapID", self.MapID, -1)
  else
    uPlayer:SetAttrValue("MapID", 0, -1)
  end
end
function POIGeneralArea:SendTipsToPlayerInArea(nTipsID, Param, Param2)
  local uActorList = self:GetAllOverlapActorsInArea()
  if uActorList then
    for _, uActor in pairs(uActorList) do
      if slua.isValid(uActor) and Game:IsPlayer(uActor) then
        local sPlayerKey = uActor:GetPlayerKey()
        if sPlayerKey then
          Game:UIShowImageTips(tonumber(sPlayerKey), nTipsID, Param, Param2)
        end
      end
    end
  end
  print(bWriteLog and "POIGeneralArea:SendTipsToPlayerInArea nTipsID:", nTipsID, " AreaID:", self.AreaID)
end
local class = require("class")
local object = require("GameLua.Mod.Library.GamePlay.Actor.BaseLevelEnterArea")
local CPOIGeneralArea = class(object, nil, POIGeneralArea)
return CPOIGeneralArea