local PlayerCharacterMercenaryFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function PlayerCharacterMercenaryFeature:ctor()
  self.HiredInfo = slua.Array(UEnums.EPropertyClass.Int)
end
function PlayerCharacterMercenaryFeature:ReceiveEndPlay()
  if not Client and self:IsHire() then
    print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:ReceiveEndPlay, Owner PlayerKey = %s", tostring(self.Owner and self.Owner.PlayerKey or 0)))
  end
  PlayerCharacterMercenaryFeature.__super.ReceiveEndPlay(self)
end
function PlayerCharacterMercenaryFeature:GetLifetimeReplicatedProps()
  print(bWriteLog and "PlayerCharacterMercenaryFeature:GetLifetimeReplicatedProps")
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "HiredInfo",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
end
function PlayerCharacterMercenaryFeature:IsHire()
  return self.MercenaryPawn and slua.isValid(self.MercenaryPawn)
end
function PlayerCharacterMercenaryFeature:CanHireMercenaryServer()
  if Client then
    return
  end
  if not self.Owner then
    return false
  end
  if self:IsHire() then
    print(bWriteLog and "PlayerCharacterMercenaryFeature:CanHireMercenary, false IsHire")
    return false
  end
  if self.Owner.GetPlayerControllerSafety then
    local uPlayerController = self.Owner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) and uPlayerController.IsExited and uPlayerController:IsExited() then
      print(bWriteLog and "PlayerCharacterMercenaryFeature:CanHireMercenary, false IsExited")
      return false
    end
  end
  if CGameMode and CGameMode.PlayerNumPerTeam == 1 then
    return true
  end
  local uPlayerState = self.Owner:GetPlayerStateSafety()
  if not (uPlayerState and slua.isValid(uPlayerState)) or not uPlayerState.GetTeamMatePlayerStateList then
    print(bWriteLog and "PlayerCharacterMercenaryFeature:CanHireMercenary, false uPlayerState = nil")
    return false
  end
  local TeammatesState = uPlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammatesState == nil or TeammatesState:Num() <= 0 then
    print(bWriteLog and "PlayerCharacterMercenaryFeature:CanHireMercenary, true, TeammatesState = nil")
    return true
  end
  for _, uTeammatePlayerState in pairs(TeammatesState) do
    if uTeammatePlayerState and slua.isValid(uTeammatePlayerState) then
      local uTeammateCharacter = uTeammatePlayerState:GetPlayerCharacter()
      if uTeammateCharacter and slua.isValid(uTeammateCharacter) and uTeammateCharacter.MercenaryFeature and uTeammateCharacter.MercenaryFeature:IsHire() then
        return false
      end
    end
  end
  return true
end
function PlayerCharacterMercenaryFeature:HireMercenaryServer(uMercenary)
  if Client then
    return false
  end
  if not Game:IsFightingState() then
    return false
  end
  if not (self.Owner and slua.isValid(uMercenary) and Game:IsHuman(uMercenary)) or not uMercenary.GetPlayerStateSafety then
    return false
  end
  local uMercenaryCtrl = uMercenary:GetController()
  if not slua.isValid(uMercenaryCtrl) then
    return false
  end
  if not self:CanHireMercenaryServer() then
    print(bWriteLog and "PlayerCharacterMercenaryFeature:HireMercenaryServer, not CanHireMercenaryServer return")
    return false
  end
  local uPlayerState = self.Owner:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HireMercenaryServer, not slua.isValid(uPlayerState)"))
    return false
  end
  self.MercenaryPawn = uMercenary
  if self.MercenaryPawn.SetOwner then
    self.MercenaryPawn:SetOwner(self.Owner.Object)
  end
  if uMercenary.TeamID ~= nil then
    uMercenary.TeamID = self.Owner.TeamID
  end
  local uMercenaryPlayerState = uMercenary:GetPlayerStateSafety()
  if slua.isValid(uMercenaryPlayerState) then
    uMercenaryPlayerState.TeamID = uPlayerState:GetTeamId()
    if uPlayerState.MercenaryFeature and uPlayerState.MercenaryFeature.HireMercenaryServer then
      uPlayerState.MercenaryFeature:HireMercenaryServer(uMercenaryPlayerState, self.MercenaryPawn)
    end
  end
  if uMercenaryCtrl.IsMercenary ~= nil and uMercenaryCtrl.IsMercenary == false then
    uMercenaryCtrl.IsMercenary = true
    uMercenaryCtrl.ShouldSendFatalDamage = true
    local AIParams = uMercenaryCtrl.AIParams
    if AIParams then
      AIParams.MLBotType = 1
    end
    if uMercenaryCtrl:GetAILevel() <= 0 then
      uMercenaryCtrl:SetAILevel(1)
    end
    if self.MercenaryPawn.OnHireSuccessFirst then
      self.MercenaryPawn:OnHireSuccessFirst(self.Owner.Object)
    end
  end
  if self.MercenaryPawn.OnHireSuccess then
    self.MercenaryPawn:OnHireSuccess(self.Owner.Object, uPlayerState)
  end
  self:RemoveControlEvent(self.Owner, "OnDeathDelegate")
  self:RemoveControlEvent(self.MercenaryPawn, "OnDeathDelegate")
  self:AddControlEvent(self.Owner, "OnDeathDelegate", self.HandleDeathDelegateServer, self)
  self:AddControlEvent(self.MercenaryPawn, "OnDeathDelegate", self.HandleMercenaryDeathDelegateServer, self)
  self:RemoveControlEvent(self.MercenaryPawn, "OnPlayerAttrChangeDelegate")
  self:AddControlEvent(self.MercenaryPawn, "OnPlayerAttrChangeDelegate", self.HandleMercenaryAttrChangeDelegateServer, self)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_EXIT)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_EXIT, self.HandlePlayerExit, self)
  self:RemoveCommonEvent(EVENTTYPE_PLAYER, EVENTID_PLAYER_EXIT_BATTLE_INITIATIVELY)
  self:AddCommonEvent(EVENTTYPE_PLAYER, EVENTID_PLAYER_EXIT_BATTLE_INITIATIVELY, self.HandlePlayerExitBattleInitiatively, self)
  self:RemoveCommonEvent(EVENTTYPE_PLAYER, EVENTID_BEGIN_SEND_BATTLE_RESULT)
  self:AddCommonEvent(EVENTTYPE_PLAYER, EVENTID_BEGIN_SEND_BATTLE_RESULT, self.HandleOnSendPlayerBattleResult, self)
  if slua.isValid(CGameMode) then
    self:RemoveControlEvent(CGameMode, "SendTeamBattleResult")
    self:AddControlEvent(CGameMode, "SendTeamBattleResult", function(nInTeamID, sInReason)
      if nInTeamID and nInTeamID == Game:GetTeamID(self.Owner) and sInReason ~= "win" then
        self:HandleDeathDelegateServer()
      end
    end)
  end
  Game:SetAIBlackboardValue(self.MercenaryPawn, UEnums.EBlackBoardKeyType.Object, "MasterActor", self.Owner.Object)
  print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HireMercenaryServer, Success, uMercenary.TeamID=%s, self.Owner.PlayerKey=%s,MercenaryPawn.PlayerKey=%s", tostring(uMercenary.TeamID), tostring(self.Owner.PlayerKey), tostring(self.MercenaryPawn.PlayerKey)))
  if not uMercenaryCtrl.IsMLAI then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_STARTGAME_AIPROXY_NET, true, false, true)
    self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_ALLOCATE_SUCCESS)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_ALLOCATE_SUCCESS, self.HandleOnAIAllocateSuccess, self)
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_MERCENARY_ALLOCATE, uMercenaryCtrl)
  else
    self:UpdateAllyMasterID(uMercenaryCtrl)
  end
  return true
end
function PlayerCharacterMercenaryFeature:HandleOnAIAllocateSuccess(_, __, uMLAIController, uMLAIPawn)
  if self:IsHire() and slua.isValid(uMLAIController) and uMLAIPawn and uMLAIPawn == self.MercenaryPawn then
    self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_ALLOCATE_SUCCESS)
    self:UpdateAllyMasterID(uMLAIController)
    local uPlayerState = self.Owner and self.Owner.GetPlayerStateSafety and self.Owner:GetPlayerStateSafety() or nil
    if slua.isValid(uPlayerState) and uPlayerState.MercenaryFeature and uPlayerState.MercenaryFeature.SetIsMercenaryMLAIServer then
      uPlayerState.MercenaryFeature:SetIsMercenaryMLAIServer(true)
    end
    print(bWriteLog and "PlayerCharacterMercenaryFeature:HandleOnAIAllocateSuccess,self.Owner.PlayerKey=" .. tostring(self.Owner.PlayerKey))
  end
end
function PlayerCharacterMercenaryFeature:UpdateAllyMasterID(uMLAIController)
  if self:IsHire() and slua.isValid(uMLAIController) and slua.isValid(self.Owner.Object) then
    local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
    if not MLAIProcessSubSystem then
      return
    end
    local uMLAIControllerComp = MLAIProcessSubSystem:GetMLAIControllerComponentWithID(uMLAIController.PlayerKey)
    if slua.isValid(uMLAIControllerComp) and uMLAIControllerComp.SetAllyMasterID then
      local MLAIProcessUtil = require("GameLua.ExtraModule.MLAI.DS.AI.MLAIProcessUtil")
      if slua.isValid(self.MercenaryPawn) then
        MLAIProcessUtil:ChangeAllyMasterID(uMLAIControllerComp, self.Owner.PlayerKey, self.MercenaryPawn.RSTSSceneName)
      end
      uMLAIControllerComp.IsModifyDamageLuaOverride = true
      print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:UpdateAllyMasterID, GetAllyMasterID=%s, uMLAIController.PlayerKey=%s", tostring(uMLAIControllerComp:GetAllyMasterID()), tostring(uMLAIController.PlayerKey)))
      if slua.isValid(self.MercenaryPawn) and slua.isValid(self:GetMLAICppSubSystem()) and self:GetMLAICppSubSystem().WhitelistPlayerStatesSwitch then
        self:GetMLAICppSubSystem().UpdateMercenaryPlayerWhiteInterval = 2
        self:GetMLAICppSubSystem():AddMercenary2MasterMap(self.MercenaryPawn, self.Owner.Object, true)
      end
      if self.MercenaryPawn.OnHireSuccessMLAI then
        self.MercenaryPawn:OnHireSuccessMLAI(self.Owner.Object)
      end
      self:OnMercenaryHire(self.MercenaryPawn, true)
    end
  end
end
function PlayerCharacterMercenaryFeature:GetMLAICppSubSystem()
  if not slua.isValid(self.uSubSystem) then
    local UMLAISubSystem = import("MLAISubSystem")
    local USubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
    self.uSubSystem = USubsystemBlueprintLibrary.GetWorldSubsystem(CGameWorld, UMLAISubSystem)
  end
  return self.uSubSystem
end
function PlayerCharacterMercenaryFeature:ResetMercenaryServer()
  if Client then
    return
  end
  if not (self.Owner and slua.isValid(self.MercenaryPawn) and slua.isValid(self.Owner.Object)) or not self.Owner.GetPlayerStateSafety then
    return
  end
  if slua.isValid(self:GetMLAICppSubSystem()) and self:GetMLAICppSubSystem().WhitelistPlayerStatesSwitch then
    self:GetMLAICppSubSystem():RemoveMercenary2MasterMap(self.MercenaryPawn, self.Owner.Object)
  end
  self:RemoveControlEvent(self.Owner, "OnDeathDelegate")
  self:RemoveControlEvent(self.MercenaryPawn, "OnDeathDelegate")
  self:RemoveControlEvent(self.MercenaryPawn, "OnPlayerAttrChangeDelegate")
  self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_EXIT)
  self:RemoveCommonEvent(EVENTTYPE_PLAYER, EVENTID_PLAYER_EXIT_BATTLE_INITIATIVELY)
  self:RemoveCommonEvent(EVENTTYPE_PLAYER, EVENTID_BEGIN_SEND_BATTLE_RESULT)
  if slua.isValid(CGameMode) then
    self:RemoveControlEvent(CGameMode, "SendTeamBattleResult")
  end
  if self.MercenaryPawn.GetPlayerStateSafety then
    local uMercenaryPlayerState = self.MercenaryPawn:GetPlayerStateSafety()
    if slua.isValid(uMercenaryPlayerState) then
      local uPlayerState = self.Owner:GetPlayerStateSafety()
      if slua.isValid(uPlayerState) and uPlayerState.MercenaryFeature and uPlayerState.MercenaryFeature.ResetMercenaryServer then
        uPlayerState.MercenaryFeature:ResetMercenaryServer()
      end
      if self.MercenaryPawn.OnFinishHireServer then
        self.MercenaryPawn:OnFinishHireServer(self.Owner.Object, uPlayerState)
      end
    end
  end
  self:OnMercenaryHire(self.MercenaryPawn, false)
  self.MercenaryPawn = nil
  print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:ResetMercenaryServer, self.Owner.PlayerKey=%s", tostring(self.Owner.PlayerKey)))
end
function PlayerCharacterMercenaryFeature:HandleDeathDelegateServer()
  if Client then
    return
  end
  local EPawnState = import("EPawnState")
  if not (self.Owner and self.Owner:HasState(EPawnState.Dead)) or self.Owner:IsAlive() then
    return
  end
  if not self:IsHire() then
    return
  end
  local uPlayerState = self.Owner:GetPlayerStateSafety()
  if not (uPlayerState and slua.isValid(uPlayerState) and uPlayerState.GetRevivalCount) or not uPlayerState.GetLeftBuyLifeCounts then
    print(bWriteLog and "PlayerCharacterMercenaryFeature:HandleDeathDelegateServer, false uPlayerState = nil")
    return
  end
  if uPlayerState:GetRevivalCount() > 0 or uPlayerState:GetLeftBuyLifeCounts() > 0 then
    print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HandleDeathDelegateServer, return, uPlayerState(%s):GetRevivalCount()=%s, GetLeftBuyLifeCounts=%s", tostring(uPlayerState.PlayerKey), tostring(uPlayerState:GetRevivalCount()), tostring(uPlayerState:GetLeftBuyLifeCounts())))
    return
  end
  self:ChooseTeammateTransferOwnership(uPlayerState)
end
function PlayerCharacterMercenaryFeature:ChooseTeammateTransferOwnership(uPlayerState)
  if not uPlayerState or not slua.isValid(uPlayerState) then
    return
  end
  print(bWriteLog and "PlayerCharacterMercenaryFeature:ChooseTeammateTransferOwnership, self.Owner.PlayerKey=" .. tostring(self.Owner.PlayerKey))
  local TeammatesState = uPlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammatesState and TeammatesState:Num() > 0 then
    local tValidTeammatesCharacters = self:GetTeammatesStateWithCondtion(TeammatesState, true, false, true)
    for _, uTeammateCharacter in ipairs(tValidTeammatesCharacters) do
      if uTeammateCharacter and slua.isValid(uTeammateCharacter) and self:TransferOwnershipToTeammate(uTeammateCharacter) then
        return
      end
    end
    local tValidTeammatesCharacters = self:GetTeammatesStateWithCondtion(TeammatesState, false, true, true)
    for _, uTeammateCharacter in ipairs(tValidTeammatesCharacters) do
      if uTeammateCharacter and slua.isValid(uTeammateCharacter) and self:TransferOwnershipToTeammate(uTeammateCharacter) then
        return
      end
    end
  end
  if self.MercenaryPawn and slua.isValid(self.MercenaryPawn) then
    print(bWriteLog and "PlayerCharacterMercenaryFeature:ChooseTeammateTransferOwnership DamageTarget")
    local uMercenaryCtrl = self.MercenaryPawn:GetController()
    if uMercenaryCtrl and slua.isValid(uMercenaryCtrl) and uMercenaryCtrl.ShouldSendFatalDamage ~= nil then
      uMercenaryCtrl.ShouldSendFatalDamage = false
    end
    Game:DamageTarget(nil, self.MercenaryPawn, 1000000, UEnums.DamageType.PoisonDamage)
    self:ResetMercenaryServer()
  else
    print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HandleDeathDelegateServer self.Owner.PlayerKey=%s, not self.MercenaryPawn", tostring(self.Owner.PlayerKey)))
  end
end
function PlayerCharacterMercenaryFeature:GetTeammatesStateWithCondtion(TeammatesState, bCheckIsAlive, bCheckCanRevival, bSortDist)
  local tValidTeammatesCharacters = {}
  if TeammatesState == nil then
    return tValidTeammatesCharacters
  end
  for _, uTeammatePlayerState in pairs(TeammatesState) do
    if uTeammatePlayerState and slua.isValid(uTeammatePlayerState) and (not bCheckIsAlive or uTeammatePlayerState:IsAlive()) and (not bCheckCanRevival or uTeammatePlayerState.GetRevivalCount and uTeammatePlayerState:GetRevivalCount() > 0 or uTeammatePlayerState.GetLeftBuyLifeCounts and 0 < uTeammatePlayerState:GetLeftBuyLifeCounts()) then
      local uTeammateController = uTeammatePlayerState:GetOwner()
      if uTeammateController and slua.isValid(uTeammateController) and (not uTeammateController.IsExited or not uTeammateController:IsExited()) then
        local uTeammateCharacter = uTeammatePlayerState:GetPlayerCharacter()
        if uTeammateCharacter then
          table.insert(tValidTeammatesCharacters, uTeammateCharacter)
        end
      end
    end
  end
  if bSortDist and 0 < #tValidTeammatesCharacters then
    local OwnerLoc = self.Owner:K2_GetActorLocation()
    table.sort(tValidTeammatesCharacters, function(uCharacterA, uCharacterB)
      return FVector.DistSquared(OwnerLoc, uCharacterA:K2_GetActorLocation()) < FVector.DistSquared(OwnerLoc, uCharacterB:K2_GetActorLocation())
    end)
  end
  return tValidTeammatesCharacters
end
function PlayerCharacterMercenaryFeature:TransferOwnershipToTeammate(uTeammateCharacter)
  if uTeammateCharacter and slua.isValid(uTeammateCharacter) and uTeammateCharacter.MercenaryFeature and uTeammateCharacter.MercenaryFeature.HireMercenaryServer then
    local TmpCacheMercenaryPawn = self.MercenaryPawn
    self:ResetMercenaryServer()
    return uTeammateCharacter.MercenaryFeature:HireMercenaryServer(TmpCacheMercenaryPawn)
  end
  return false
end
function PlayerCharacterMercenaryFeature:HandleMercenaryDeathDelegateServer()
  print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HandleMercenaryDeathDelegateServer self.Owner.PlayerKey=%s, MercenaryPawn.PlayerKey=%s", tostring(self.Owner.PlayerKey), tostring(self.MercenaryPawn.PlayerKey)))
  self:ResetMercenaryServer()
end
function PlayerCharacterMercenaryFeature:HandleMercenaryAttrChangeDelegateServer(AttrName, OldAttrValue, NewAttrValue, Reason)
  if Client then
    return
  end
  if not (self.Owner and slua.isValid(self.Owner.Object)) or not self.Owner.GetPlayerStateSafety then
    return
  end
  if not self:IsHire() then
    return
  end
  if AttrName == "Health" then
    print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HandleMercenaryAttrChangeDelegateServer, AttrName=%s, NewAttrValue=%s, MercenaryPawn.Health=%s", tostring(AttrName), tostring(NewAttrValue), tostring(self.MercenaryPawn.Health)))
    local uPlayerState = self.Owner:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) and uPlayerState.MercenaryFeature and uPlayerState.MercenaryFeature.MercenaryHealthChangeServer then
      uPlayerState.MercenaryFeature:MercenaryHealthChangeServer(NewAttrValue)
    end
  end
end
function PlayerCharacterMercenaryFeature:SendStringMsgServer(MsgContent)
  if not (not Client and MsgContent) or MsgContent == "" then
    return
  end
  if not self.Owner then
    return
  end
  local uPlayerState = self.Owner:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) or not uPlayerState.MercenaryFeature then
    return
  end
  uPlayerState.MercenaryFeature:SetMercenaryMsgContentServer(MsgContent)
  print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:SendStringMsgServer, MercenaryMsgContent=%s", tostring(MsgContent)))
end
function PlayerCharacterMercenaryFeature:AddGeneralCount(ID, bReset)
  if not self.Owner then
    return
  end
  local uPlayerState = self.Owner:GetPlayerStateSafety()
  if not uPlayerState or not slua.isValid(uPlayerState) then
    return
  end
  if bReset == nil then
    bReset = false
  end
  print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:AddGeneralCount:%s,bReset:%s,PlayerKey:%s", tostring(ID), tostring(bReset), tostring(uPlayerState.PlayerKey)))
  uPlayerState:AddGeneralCount(ID, 1, bReset)
end
function PlayerCharacterMercenaryFeature:HandlePlayerExit(_, _, PlayerKey)
  if self.Owner.PlayerKey and PlayerKey and self.Owner.PlayerKey == PlayerKey then
    if not self:IsHire() then
      print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HandlePlayerExit, not IsHire, PlayerKey=%s", tostring(PlayerKey)))
      return
    end
    print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HandlePlayerExit, self.Owner.PlayerKey=%s, PlayerKey=%s", tostring(self.Owner.PlayerKey), tostring(PlayerKey)))
    self:ChooseTeammateTransferOwnership(self.Owner:GetPlayerStateSafety())
  end
end
function PlayerCharacterMercenaryFeature:HandlePlayerExitBattleInitiatively(_, __, nPlayerUID, tExitInfo)
  local uPlayerState = self.Owner:GetPlayerStateSafety()
  if not uPlayerState or not slua.isValid(uPlayerState) then
    return
  end
  if uPlayerState.UID and nPlayerUID and uPlayerState.UID == nPlayerUID then
    if not self:IsHire() then
      print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HandlePlayerExitBattleInitiatively, not IsHire, nPlayerUID=%s", tostring(nPlayerUID)))
      return
    end
    print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HandlePlayerExitBattleInitiatively, uPlayerState.UID=%s, nPlayerUID=%s", tostring(uPlayerState.UID), tostring(nPlayerUID)))
    self:ChooseTeammateTransferOwnership(uPlayerState)
  end
end
function PlayerCharacterMercenaryFeature:HandleOnSendPlayerBattleResult(_, __, nUID, sReason)
  if nUID and sReason and sReason ~= "win" and slua.isValid(self.Owner.Object) and self.Owner.GetPlayerStateSafety then
    local uPlayerState = self.Owner:GetPlayerStateSafety()
    if not uPlayerState or not slua.isValid(uPlayerState) then
      return
    end
    print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:HandleOnSendPlayerBattleResult nUID=%s, sReason =%s, uPlayerState.UID=%s", tostring(nUID), tostring(sReason), tostring(uPlayerState.UID)))
    if uPlayerState.UID and uPlayerState.UID == nUID then
      self:HandleDeathDelegateServer()
    end
  end
end
function PlayerCharacterMercenaryFeature:OnMercenaryHire(MercenaryPawn, bIsHireSuccess)
  if not slua.isValid(MercenaryPawn) or not self:IsHire() then
    return
  end
  local ResId = MercenaryPawn.ResId
  if ResId ~= nil and 0 < ResId then
    local IsHire = 0
    if bIsHireSuccess == true then
      IsHire = 1
    end
    if self.HiredInfo:Num() >= 2 then
      self.HiredInfo:Set(0, ResId)
      self.HiredInfo:Set(1, IsHire)
    else
      self.HiredInfo:Add(ResId)
      self.HiredInfo:Add(IsHire)
    end
    print(bWriteLog and string.format("PlayerCharacterMercenaryFeature:OnMercenaryHire -ResId: %s, bIsHireSuccess: %s", tostring(ResId), tostring(bIsHireSuccess)))
  end
end
function PlayerCharacterMercenaryFeature:OnRep_HiredInfo()
  local Owner = self.Owner
  if not Owner or not Owner:IsLocallyControlled() then
    return
  end
  print(bWriteLog and "PlayerCharacterMercenaryFeature:OnRep_HiredInfo Called On Local Character")
  if not self.HiredInfo or self.HiredInfo:Num() < 2 then
    print(bWriteLog and "PlayerCharacterMercenaryFeature:OnRep_HiredInfo, Invalid HiredInfo")
    return
  end
  local ResId = self.HiredInfo:Get(0)
  if ResId == nil or ResId <= 0 then
    print(bWriteLog and "PlayerCharacterMercenaryFeature:OnRep_HiredInfo, Invalid ResId")
    return
  end
  local bIsHireSuccess = self.HiredInfo:Get(1)
  if bIsHireSuccess == 0 then
    bIsHireSuccess = false
  else
    bIsHireSuccess = true
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_MERCENARY_HIRE, ResId, bIsHireSuccess)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerCharacterMercenaryFeature)