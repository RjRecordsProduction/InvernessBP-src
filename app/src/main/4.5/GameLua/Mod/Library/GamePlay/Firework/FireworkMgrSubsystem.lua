local TableUtil = require("common.table_util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local Pawn_C = import("/Script/Engine.Pawn")
local WaterActor_C = import("WaterSwimActor")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local FireworkPileClassPath = "/Game/Arts_PlayerBluePrints/Firework/FireworkPileActor.FireworkPileActor"
local FireworkMgrSubsystem = {}
local FireworkConfig = {
  PersonalMaxCount = 6,
  PersonalMaxTipsID = 1111,
  ClientMaxShowCount = 6,
  LeftTimeBeforPlane = 20,
  LeftTimeBeforPlaneTips = 111,
  FireworkPileHeight = 150,
  FireworkPileLength = 150,
  FireworkPileWidth = 150,
  FireworkPileCheckHeight = 2000,
  FireworkPileCheckLength = 500,
  FireworkPileCheckWidth = 500,
  FireworkPileCheckOffset = 200,
  FireworkPileLocationTips = 1111,
  FireworkPileSearchMaxDistance = 9000,
  FireworkStickTips = 1111
}
function FireworkMgrSubsystem:OnInit()
  self.bClient = Client ~= nil
  printf("[FireworkMgrSubsystem]OnInit[%s]", self.bClient)
  self:InitConfig()
  local EPawnState = import("EPawnState")
  self.DisablePawnState = {
    EPawnState.DriveVehicle,
    EPawnState.InVehicle,
    EPawnState.Swim,
    EPawnState.Diving,
    EPawnState.Dying,
    EPawnState.PlayEmote,
    EPawnState.InZipline,
    EPawnState.Move
  }
  if self.bClient then
    self:OnInit_Client()
  else
    self:OnInit_Ds()
  end
end
function FireworkMgrSubsystem:OnRelease()
  printf("[FireworkMgrSubsystem]OnRelease[%s]", self.bClient)
  if self.bClient then
    self:OnRelease_Client()
  else
    self:OnRelease_Ds()
  end
  FireworkMgrSubsystem.__super.OnRelease(self)
end
function FireworkMgrSubsystem:InitConfig()
  local RealFireworkConfig = GamePlayTools.GetCurrentConfig("FireworkConfig")
  FireworkConfig = RealFireworkConfig
end
function FireworkMgrSubsystem:OnInit_Ds()
  self.ActiveFireworkPile_DS = {}
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CHARACTER_DIED_PRE, self.OnCharacterPreDie, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameStateChange, self)
end
function FireworkMgrSubsystem:OnRelease_Ds()
  self.ActiveFireworkPile_DS = {}
end
function FireworkMgrSubsystem:OnCharacterPreDie(_, __, KilledPawn, TypeID, DamageCauser, EventInstigatorCtrl)
  if not slua.isValid(KilledPawn) then
    return
  end
  local uComponentClass = import("/Script/Engine.Actor")
  local childActors = KilledPawn:GetAttachedActors(slua.Array(UEnums.EPropertyClass.Object, uComponentClass))
  for _, v in pairs(childActors) do
    if slua.isValid(v) and v:ActorHasTag("FireworkStick") then
      v:K2_DestroyActor()
      print(bWriteLog and "FireworkMgrSubsystem:OnCharacterPreDie Destory Character FireworkStick")
    end
  end
end
function FireworkMgrSubsystem:OnGameStateChange(_, __, sState)
  if sState == "FightingState" and slua.isValid(CGameState) then
    print(bWriteLog and "FireworkMgrSubsystem:OnGameStateChange Destory All FireworkStick")
    local ActorClass = import("/Script/Engine.Actor")
    local GameplayStatics = import("GameplayStatics")
    local actorArray = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
    actorArray = GameplayStatics.GetAllActorsWithTag(CGameState, "FireworkStick", actorArray)
    for _, StickActor in pairs(actorArray) do
      if slua.isValid(StickActor) then
        StickActor:K2_DestroyActor()
      end
    end
  end
end
function FireworkMgrSubsystem:CheckStageEnable()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.GetGameModeState then
    local CurrentState = uGameState:GetGameModeState()
    if CurrentState == "FightingState" then
      return true
    end
    if CurrentState == "ReadyState" and uGameState.ReadyStateTime >= FireworkConfig.LeftTimeBeforPlane then
      return true
    end
  end
  return false
end
function FireworkMgrSubsystem:IsFinishedState()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.GetGameModeState then
    local CurrentState = uGameState:GetGameModeState()
    if CurrentState == "FinishedState" then
      return true
    end
  end
  return false
end
function FireworkMgrSubsystem:CheckPlayerStageEnable(Player)
  if not slua.isValid(Player) then
    return false
  end
  for _, PState in pairs(self.DisablePawnState) do
    if Player:HasState(PState) then
      return false
    end
  end
  return true
end
function FireworkMgrSubsystem:CheckFireworkPileCount(Player)
  if not slua.isValid(Player) then
    return false
  end
  if self.bClient then
    return true
  end
  local PlayerKey = Game:GetPlayerKey(Player)
  local RefFirework = self.ActiveFireworkPile_DS[PlayerKey]
  if not RefFirework then
    return true
  end
  if TableUtil.CountTable(RefFirework) >= FireworkConfig.PersonalMaxCount then
    return false
  end
  return true
end
function FireworkMgrSubsystem:CheckFireworkPosition(Player)
  if not slua.isValid(Player) then
    return false
  end
  local ForwardVec = Player:GetActorForwardVector()
  local Loc = Game:GetActorLocation(Player)
  local GroundPos, HitRes = self:TryGetGroundLocation(Player, Loc + ForwardVec * 100)
  if not GroundPos then
    return false
  end
  local FireworkPileClass = slua.loadClass(FireworkPileClassPath)
  if HitRes and slua.isValid(HitRes.Actor) and (Game:IsClassOf(HitRes.Actor, FireworkPileClass) or Game:IsClassOf(HitRes.Actor, WaterActor_C)) then
    return false
  end
  local LandscapeClass = import("LandscapeProxy")
  local TracePawnRes = self:GetBoxTraceMulti(Player, GroundPos, nil, FVector(0, 0, FireworkConfig.FireworkPileHeight_Pawn), FVector(0, 0, 0), FVector(FireworkConfig.FireworkPileLength_Pawn, FireworkConfig.FireworkPileWidth_Pawn, 1), 3)
  if TracePawnRes then
    for _, value in pairs(TracePawnRes) do
      if value and slua.isValid(value.Actor) and Game:IsClassOf(value.Actor, Pawn_C) then
        return false
      end
    end
  end
  GroundPos.Z = GroundPos.Z + FireworkConfig.FireworkPileOffset
  local TraceRes = self:GetBoxTraceMulti(Player, GroundPos, nil, FVector(0, 0, FireworkConfig.FireworkPileHeight), FVector(0, 0, 0), FVector(FireworkConfig.FireworkPileLength, FireworkConfig.FireworkPileWidth, 1), 3)
  if TraceRes then
    for _, value in pairs(TraceRes) do
      if value and slua.isValid(value.Actor) and not Game:IsClassOf(value.Actor, LandscapeClass) then
        return false
      end
    end
  end
  local TraceUpRes = self:GetBoxTraceMulti(Player, GroundPos, nil, FVector(0, 0, FireworkConfig.FireworkPileCheckHeight), FVector(0, 0, -FireworkConfig.FireworkPileCheckOffset), FVector(FireworkConfig.FireworkPileCheckLength, FireworkConfig.FireworkPileCheckWidth, 1), 3)
  if TraceUpRes then
    for _, value in pairs(TraceUpRes) do
      if value and value.Actor and not Game:IsClassOf(value.Actor, Pawn_C) then
        return false
      end
    end
  end
  return true
end
function FireworkMgrSubsystem:TryGetGroundLocation(worldObj, InLoc, StartOffset, EndOffset)
  if not slua.isValid(worldObj) or not slua.isValid(InLoc) then
    return FVector(0)
  end
  local bHit, uHitResult
  StartOffset = StartOffset or 200
  EndOffset = EndOffset or 400
  local RayStart = InLoc + FVector(0, 0, StartOffset)
  local RayEnd = InLoc - FVector(0, 0, EndOffset)
  bHit, uHitResult = UKismetSystemLibrary.LineTraceSingle(worldObj, RayStart, RayEnd, 6, true, nil, 0, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 1)
  if bHit and uHitResult and uHitResult.Location then
    local DragLocation = FVector(uHitResult.Location.X, uHitResult.Location.Y, uHitResult.Location.Z)
    return DragLocation, uHitResult
  else
    return nil
  end
end
function FireworkMgrSubsystem:GetBoxTraceMulti(worldObj, TryLocation, TryRotation, StartOffectVec, EndOffsetVec, HalfSizeVector, TraceChanel)
  local bHit, uHitResults
  StartOffectVec = StartOffectVec or FVector(0, 0, 200)
  EndOffsetVec = EndOffsetVec or FVector(0, 0, 50)
  HalfSizeVector = HalfSizeVector or FVector(100, 100, 100)
  TraceChanel = TraceChanel or 1
  local RayStart = TryLocation + StartOffectVec
  local RayEnd = TryLocation - EndOffsetVec
  TryRotation = TryRotation or FRotator(0)
  bHit, uHitResults = UKismetSystemLibrary.BoxTraceMulti(worldObj, RayStart, RayEnd, HalfSizeVector, TryRotation, TraceChanel, true, nil, 0, uHitResults, true, FLinearColor.Red, FLinearColor.Green, 1)
  if bHit then
    return uHitResults
  end
  return nil
end
function FireworkMgrSubsystem:RegisterToSystem_DS(Player, uFirework)
  if not slua.isValid(Player) or not slua.isValid(uFirework) then
    return
  end
  local PlayerKey = Game:GetPlayerKey(Player)
  local RefFirework = self.ActiveFireworkPile_DS[PlayerKey]
  if not RefFirework then
    self.ActiveFireworkPile_DS[PlayerKey] = {}
    RefFirework = self.ActiveFireworkPile_DS[PlayerKey]
  end
  if TableUtil.Find(RefFirework, uFirework) < 0 then
    table.insert(RefFirework, uFirework)
    print(bWriteLog and "FireworkMgrSubsystem:RegisterToSystem_DS Player,uFirework", Player, uFirework)
  end
end
function FireworkMgrSubsystem:UnRegisterToSystem_DS(Player, uFirework)
  if not slua.isValid(Player) or not slua.isValid(uFirework) then
    return
  end
  local PlayerKey = Game:GetPlayerKey(Player)
  local RefFirework = self.ActiveFireworkPile_DS[PlayerKey]
  if not RefFirework then
    self.ActiveFireworkPile_DS[PlayerKey] = {}
    RefFirework = self.ActiveFireworkPile_DS[PlayerKey]
  end
  local TableIdx = TableUtil.Find(RefFirework, uFirework)
  if 0 < TableIdx then
    table.remove(RefFirework, TableIdx)
    print(bWriteLog and "FireworkMgrSubsystem:UnRegisterToSystem_DS Player,uFirework", Player, uFirework)
  end
end
function FireworkMgrSubsystem:OnInit_Client()
  self.ActiveFireworkPile_Client = {}
  self.FireworkPile_Dis = {}
end
function FireworkMgrSubsystem:OnRelease_Client()
  self.ActiveFireworkPile_Client = {}
end
function FireworkMgrSubsystem:RegisterToSystem_Client(uFirework)
  if not slua.isValid(uFirework) or not self.ActiveFireworkPile_Client then
    return
  end
  if TableUtil.Find(self.ActiveFireworkPile_Client, uFirework) < 0 then
    table.insert(self.ActiveFireworkPile_Client, uFirework)
    print(bWriteLog and "FireworkMgrSubsystem:RegisterToSystem_Client uFirework", uFirework)
    self:RefreshEffect_Client()
  end
end
function FireworkMgrSubsystem:UnRegisterToSystem_Client(uFirework)
  if not slua.isValid(uFirework) or not self.ActiveFireworkPile_Client then
    return
  end
  local TableIdx = TableUtil.Find(self.ActiveFireworkPile_Client, uFirework)
  if 0 < TableIdx then
    table.remove(self.ActiveFireworkPile_Client, TableIdx)
    print(bWriteLog and "FireworkMgrSubsystem:UnRegisterToSystem_Client uFirework", uFirework)
    self:RefreshEffect_Client()
  end
end
function FireworkMgrSubsystem:RefreshEffect_Client()
  local Character = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Character) then
    return
  end
  local Loc = Game:GetActorLocation(Character)
  self.FireworkPile_Dis = {}
  for _, AFP in pairs(self.ActiveFireworkPile_Client) do
    local ALoc = Game:GetActorLocation(AFP)
    table.insert(self.FireworkPile_Dis, {
      FVector.DistXY(Loc, ALoc),
      AFP
    })
  end
  table.sort(self.FireworkPile_Dis, function(A, B)
    return A[1] < B[1]
  end)
  for Rank, DisData in pairs(self.FireworkPile_Dis) do
    local bShouldShow = false
    if Rank <= FireworkConfig.ClientMaxShowCount then
      bShouldShow = true
    else
      bShouldShow = false
    end
    if slua.isValid(DisData[2]) and DisData[2].SetEffectEnable then
      DisData[2]:SetEffectEnable(bShouldShow)
    end
  end
end
function FireworkMgrSubsystem:GetFireworkStick_Client(Character)
  if not slua.isValid(Character) then
    return nil
  end
  local uActorClass = import("/Script/Engine.Actor")
  local ChildActors = Character:GetAttachedActors(slua.Array(UEnums.EPropertyClass.Object, uActorClass))
  for _, v in pairs(ChildActors) do
    if slua.isValid(v) and v:ActorHasTag("FireworkStick") then
      return v
    end
  end
  return nil
end
function FireworkMgrSubsystem:GetFireworkStickSetting(Character)
  local FireworkStick = self:GetFireworkStick_Client(Character)
  if not slua.isValid(FireworkStick) or not FireworkStick.GetPlayerSettingOpen then
    return false
  end
  return FireworkStick:GetPlayerSettingOpen()
end
function FireworkMgrSubsystem:GetFireworkStickOpen(Character)
  local FireworkStick = self:GetFireworkStick_Client(Character)
  if not slua.isValid(FireworkStick) or not FireworkStick.GetPlayerSettingOpen then
    return false
  end
  return FireworkStick:GetPlayerOpen()
end
function FireworkMgrSubsystem:SetPlayerSettingOpen(Character, InOpen)
  local FireworkStick = self:GetFireworkStick_Client(Character)
  if not slua.isValid(FireworkStick) or not FireworkStick.GetPlayerSettingOpen then
    return false
  end
  FireworkStick:SetPlayerSettingOpen(InOpen)
end
function FireworkMgrSubsystem:GetFireworkStickTimestamp(Character)
  local FireworkStick = self:GetFireworkStick_Client(Character)
  if not slua.isValid(FireworkStick) or not FireworkStick.GetPlayerTimestamp then
    return -1
  end
  return FireworkStick:GetPlayerTimestamp()
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, FireworkMgrSubsystem)