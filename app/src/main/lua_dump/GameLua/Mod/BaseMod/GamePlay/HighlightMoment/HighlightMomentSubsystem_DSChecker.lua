local HighlightMomentSubsystem_DSChecker = {}
local BackpackUtils = import("BackpackUtils")
local EPawnState = import("EPawnState")
local ASTExtraShootWeapon = import("STExtraShootWeapon")
local TableUtil = require("common.table_util")
local MultipleKillHighlightType = 9
local AngelRescueHighlightType = 15
local LightningWarHighlightType = 16
function HighlightMomentSubsystem_DSChecker:OnCharacterDied(_, __, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if slua.isValid(uVictim) then
    print(bWriteLog and "HighlightMomentSubsystem_DSChecker:OnCharacterDied", uVictim.PlayerName, uVictim.PoseState)
    self:EliminateKillConfirm(uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  end
end
function HighlightMomentSubsystem_DSChecker:OnNearDeath(_, __, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:OnNearDeath", uVictim, uCauser)
  self:KillConfirm(uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
end
function HighlightMomentSubsystem_DSChecker:OnAddKills(_, _, uKillerPS, uVictim)
  if not (slua.isValid(uKillerPS) and slua.isValid(CGameState)) or not Game:IsFightingState() then
    return
  end
  if not self.MultiKillPlayerKeys then
    self.MultiKillPlayerKeys = {}
  end
  if not self.LightningWarPlayerKeys then
    self.LightningWarPlayerKeys = {}
  end
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:OnAddKills", uKillerPS.PlayerName, uKillerPS.Kills, CGameState:GetServerWorldTimeSeconds(), CGameState.StartFlyTime)
  local Config = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig")
  if uKillerPS.Kills >= Config[MultipleKillHighlightType].KillNum and not self.MultiKillPlayerKeys[uKillerPS.PlayerKey] then
    local uKiller = uKillerPS:GetPlayerCharacter()
    if uKiller then
      self.MultiKillPlayerKeys[uKillerPS.PlayerKey] = true
      self:TriggerHighlightMoment(uKiller, MultipleKillHighlightType)
    end
  end
  if uKillerPS.Kills >= Config[LightningWarHighlightType].KillNum and not self.LightningWarPlayerKeys[uKillerPS.PlayerKey] and CGameState:GetServerWorldTimeSeconds() - CGameState.StartFlyTime <= Config[LightningWarHighlightType].Time then
    local uKiller = uKillerPS:GetPlayerCharacter()
    if uKiller then
      self.LightningWarPlayerKeys[uKillerPS.PlayerKey] = true
      self:TriggerHighlightMoment(uKiller, LightningWarHighlightType)
    end
  end
end
function HighlightMomentSubsystem_DSChecker:OnHandleRescued(_, _, uRescuerPawn)
  if not slua.isValid(uRescuerPawn) then
    return
  end
  if not self.AngleRescuePlayerKeys then
    self.AngleRescuePlayerKeys = {}
  end
  local uPlayerState = uRescuerPawn:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then
    return
  end
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:OnHandleRescued", uPlayerState.PlayerName, uPlayerState.PlayerKey, uPlayerState.rescueTimes)
  local Config = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig")
  if uPlayerState.rescueTimes >= Config[AngelRescueHighlightType].RescueCount and not self.AngleRescuePlayerKeys[uPlayerState.PlayerKey] then
    self.AngleRescuePlayerKeys[uPlayerState.PlayerKey] = true
    self:TriggerHighlightMoment(uRescuerPawn, AngelRescueHighlightType)
  end
end
function HighlightMomentSubsystem_DSChecker:OnHandleProjectileLaunch(_, _, Pawn, ProjectileActor)
  if not slua.isValid(ProjectileActor) or not slua.isValid(Pawn) then
    return
  end
  local EPawnState = import("EPawnState")
  if Pawn:HasState(EPawnState.DriveVehicle) or Pawn:HasState(EPawnState.InVehicle) then
    print(bWriteLog and "HighlightMomentSubsystem_DSChecker:OnHandleProjectileLaunch", ProjectileActor, Pawn)
    if not self.ProjectileLaunchRecords then
      self.ProjectileLaunchRecords = {}
    end
    local ProjectileActorGUID = slua.GetNetGUID(ProjectileActor)
    self.ProjectileLaunchRecords[ProjectileActorGUID] = Pawn.PlayerKey
  end
end
function HighlightMomentSubsystem_DSChecker:OnRefreshEliminationKing(_, _, PlayerKey, PlayerName, KillCount)
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:OnRefreshEliminationKing", PlayerKey, PlayerName, KillCount)
  local uPlayerState = Game:GetPlayerStateByPlayerKey(PlayerKey)
  local uPlayerCharacter = slua.isValid(uPlayerState) and uPlayerState:GetPlayerCharacter() or nil
  if slua.isValid(uPlayerCharacter) then
    self:TriggerHighlightMoment(uPlayerCharacter, 5)
  end
end
function HighlightMomentSubsystem_DSChecker:OnVehiclePlayerChange(_, __, uVehicle, uCharacter, bEnter)
  if slua.isValid(uVehicle) and not bEnter then
    local VehicleUID = CGame:GetActorUniqueID(uVehicle)
    local uVehicleSeatComp = uVehicle:GetVehicleSeats()
    if not slua.isValid(uVehicleSeatComp) or not uVehicleSeatComp.SeatOccupiers then
      return
    end
    for _, Passenger in pairs(uVehicleSeatComp.SeatOccupiers) do
      if slua.isValid(Passenger) then
        return
      end
    end
    if VehicleUID and 0 < VehicleUID then
      print(bWriteLog and "HighlightMomentSubsystem_DSChecker:OnVehiclePlayerChange")
      self.VehicleKillRecords[VehicleUID] = {}
    end
  end
end
function HighlightMomentSubsystem_DSChecker:IsFilterByCommonCheck(uVictim, uCauser, uKillerCharacter)
  if not slua.isValid(uVictim) or not slua.isValid(uKillerCharacter) then
    return false
  end
  if not Game:IsHuman(uVictim) or Game:IsMonster(uVictim) or not slua.isValid(uKillerCharacter) then
    print(bWriteLog and "HighlightMomentSubsystem_DSChecker:IsFilterByCommonCheck VictimPawn is not player")
    return false
  end
  local uKillerController = uKillerCharacter:GetPlayerControllerSafety()
  local victimController = uVictim:GetControllerSafety()
  if not (Game:GetTeamID(uVictim) ~= Game:GetTeamID(uKillerCharacter) and uVictim ~= uKillerCharacter and slua.isValid(uKillerController)) or not slua.isValid(victimController) then
    print(bWriteLog and "HighlightMomentSubsystem_DSChecker:IsFilterByCommonCheck VictimPawn is not player or AI")
    return false
  end
  if not Game:IsPlayer(uVictim) and not Game:IsAI(uVictim) then
    print(bWriteLog and "HighlightMomentSubsystem_DSChecker:IsFilterByCommonCheck VictimPawn is not player or AI")
    return false
  end
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:IsFilterByCommonCheck AI-", uVictim.bEnsure, victimController.FakePlayerBornType, victimController.bForceRecordKillNum)
  if uVictim.bEnsure and victimController.FakePlayerBornType == 1 and not victimController.bForceRecordKillNum then
    return false
  end
  return true
end
function HighlightMomentSubsystem_DSChecker:KillConfirm(uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:KillConfirm", uVictim, uCauser, uKillerCharacter, nAdditionalValue)
  if not self:IsFilterByCommonCheck(uVictim, uCauser, uKillerCharacter) then
    return
  end
  for TypeIDKey, CheckFuncMapByType in pairs(self.CheckFuncRouter) do
    if TypeIDKey == -1 or TypeIDKey == nTypeID then
      for AdditionalValueKey, CheckFuncsByAdditionalValue in pairs(CheckFuncMapByType) do
        if AdditionalValueKey == -1 or AdditionalValueKey == nAdditionalValue then
          for nHighlightID, fCheckFunc in pairs(CheckFuncsByAdditionalValue) do
            if fCheckFunc then
              local Config = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig")
              local HighlightConfig = Config[nHighlightID] or {}
              if not HighlightConfig.bIgnoreKnockDown then
                fCheckFunc(self, nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
              end
            end
          end
        end
      end
    end
  end
end
function HighlightMomentSubsystem_DSChecker:EliminateKillConfirm(uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:EliminateKillConfirm", uVictim, uCauser, uKillerCharacter)
  if not self:IsFilterByCommonCheck(uVictim, uCauser, uKillerCharacter) then
    return
  end
  local ESTEPoseState = import("ESTEPoseState")
  local bVictimDying = uVictim.PoseState == ESTEPoseState.Dying or uVictim.PoseState == ESTEPoseState.DyingBeCarried or uVictim.PoseState == ESTEPoseState.DyingSwim
  for TypeIDKey, CheckFuncMapByType in pairs(self.CheckFuncRouter) do
    if TypeIDKey == -1 or TypeIDKey == nTypeID then
      for AdditionalValueKey, CheckFuncsByAdditionalValue in pairs(CheckFuncMapByType) do
        if AdditionalValueKey == -1 or AdditionalValueKey == nAdditionalValue then
          for nHighlightID, fCheckFunc in pairs(CheckFuncsByAdditionalValue) do
            if fCheckFunc then
              local Config = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig")
              local HighlightConfig = Config[nHighlightID] or {}
              if not bVictimDying or HighlightConfig.bIgnoreVictimDying then
                fCheckFunc(self, nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
              end
            end
          end
        end
      end
    end
  end
end
function HighlightMomentSubsystem_DSChecker:CheckFuncRapidKillStreak(nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if not slua.isValid(uKillerCharacter) then
    return
  end
  if not self.RapidKillStreakRecords then
    self.RapidKillStreakRecords = {}
  end
  local uController = uKillerCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uController) then
    return
  end
  local PlayerKey = uKillerCharacter.PlayerKey
  if uController:IsTeamMate(uVictim) then
    print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncRapidKillStreak %s KillTeamMate %s", PlayerKey, uVictim.PlayerKey))
    return
  end
  local Record = self.RapidKillStreakRecords[PlayerKey]
  if not Record then
    Record = {KillNum = 0}
    self.RapidKillStreakRecords[PlayerKey] = Record
  end
  if Record.Timer then
    self:RemoveGameTimer(Record.Timer)
    Record.Timer = nil
  end
  Record.Timer = self:AddGameTimer(HighlightConfig.Timeout, false, function()
    self.RapidKillStreakRecords[PlayerKey] = nil
    print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncRapidKillStreak %s timeout", PlayerKey))
  end)
  Record.KillNum = Record.KillNum + 1
  print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncRapidKillStreak %s KillNum = %d", PlayerKey, Record.KillNum))
  if Record.KillNum >= HighlightConfig.MinKillNum then
    self:TriggerHighlightMoment(uKillerCharacter, nHighlightID, Record.KillNum)
  end
end
function HighlightMomentSubsystem_DSChecker:CheckFuncVehicleMultiKill(nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if not slua.isValid(uKillerCharacter) then
    return
  end
  local uController = uKillerCharacter:GetPlayerControllerSafety()
  local uVehicle = uKillerCharacter:GetCurrentVehicle()
  if not (slua.isValid(uVehicle) and slua.isValid(uController)) or not slua.isValid(uVictim) then
    return
  end
  local VehicleUID = CGame:GetActorUniqueID(uVehicle)
  local VehicleShapeType = uVehicle.VehicleShapeType
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:CheckFuncVehicleMultiKill", VehicleShapeType, VehicleUID, uVictim.PoseState)
  local Config = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig")
  if TableUtil.Find(Config.ValidVehicleShapeList, VehicleShapeType) < 0 or VehicleUID == nil or VehicleUID <= 0 then
    print(bWriteLog and "HighlightMomentSubsystem_DSChecker:CheckFuncVehicleMultiKill invalid vehicle", VehicleShapeType, VehicleUID)
    return
  end
  local PlayerKey = uKillerCharacter.PlayerKey
  local TeamID = uKillerCharacter.TeamID
  if uController:IsTeamMate(uVictim) then
    print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncVehicleMultiKill %s KillTeamMate %s", PlayerKey, uVictim.PlayerKey, TeamID))
    return
  end
  local uVehicleSeatComp = uVehicle:GetVehicleSeats()
  if not slua.isValid(uVehicleSeatComp) then
    print(bWriteLog and "HighlightMomentSubsystem_DSChecker:CheckFuncVehicleMultiKill uVehicleSeatComp", uVehicleSeatComp)
    return
  end
  if not self.VehicleKillRecords[VehicleUID] then
    self.VehicleKillRecords[VehicleUID] = {}
  end
  local VehicleRecordList = self.VehicleKillRecords[VehicleUID]
  if VehicleRecordList and VehicleRecordList[1] and VehicleRecordList[1].TeamID ~= TeamID then
    print(bWriteLog and "HighlightMomentSubsystem_DSChecker:CheckFuncVehicleMultiKill CleanLastTeam", VehicleRecordList[1].TeamID, TeamID)
    VehicleRecordList = {}
  end
  local nCurTime = CGameState:GetServerWorldTimeSeconds()
  table.insert(VehicleRecordList, {
    Passengers = {},
    Time = nCurTime,
      })
  local Record = VehicleRecordList[#VehicleRecordList]
  local PassengersPawn = {}
  for i = 0, uVehicleSeatComp:GetSeatNum() - 1 do
    local Passenger = uVehicleSeatComp:GetPassenger(i)
    if Game:IsValid(Passenger) then
      local bIsDying = Passenger:HasState(EPawnState.Dying)
      print(bWriteLog and "HighlightMomentSubsystem_DSChecker:CheckFuncVehicleMultiKill Passenger", Passenger.TeamID, TeamID, bIsDying)
      if Passenger.TeamID == TeamID and not bIsDying then
        table.insert(Record.Passengers, Passenger.PlayerKey)
        table.insert(PassengersPawn, Passenger)
      end
    end
  end
  local PassengerNum = #Record.Passengers
  if PassengerNum <= 0 then
    return
  end
  local nCheckTime = PassengerNum <= 2 and HighlightConfig.TwoTeammeatesKillConfig.Time or HighlightConfig.FourTeammeatesKillConfig.Time
  local nCheckKillNum = PassengerNum <= 2 and HighlightConfig.TwoTeammeatesKillConfig.KillNum or HighlightConfig.FourTeammeatesKillConfig.KillNum
  local nValidRecordNum = 0
  for Idx = #VehicleRecordList, 1, -1 do
    if VehicleRecordList[Idx] and VehicleRecordList[Idx].Time and nCheckTime > nCurTime - VehicleRecordList[Idx].Time then
      nValidRecordNum = nValidRecordNum + 1
    else
      break
    end
  end
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:CheckFuncVehicleMultiKill-", PlayerKey, PassengerNum, nValidRecordNum, nCheckKillNum)
  if nCheckKillNum > nValidRecordNum then
    return
  end
  for _, PassengerPlayer in pairs(PassengersPawn) do
    self:TriggerHighlightMoment(PassengerPlayer, nHighlightID, 0)
  end
  self.VehicleKillRecords[VehicleUID] = {}
end
function HighlightMomentSubsystem_DSChecker:CheckFuncGrenadeInVehicle(nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if not (slua.isValid(uKillerCharacter) and nAdditionalValue == 602004 and slua.isValid(uCauser)) or not self.ProjectileLaunchRecords then
    return
  end
  local CauserGUID = slua.GetNetGUID(uCauser.Object)
  if self.ProjectileLaunchRecords[CauserGUID] == uKillerCharacter.PlayerKey then
    self.ProjectileLaunchRecords[CauserGUID] = nil
    self:TriggerHighlightMoment(uKillerCharacter, nHighlightID)
  end
end
function HighlightMomentSubsystem_DSChecker:CheckFuncSingleGrenadeMultiKill(nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if not slua.isValid(uKillerCharacter) or nAdditionalValue ~= 602004 then
    return
  end
  if not self.SingleGrenadeMultiKillRecords then
    self.SingleGrenadeMultiKillRecords = {}
  end
  local uController = uKillerCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uController) then
    return
  end
  local PlayerKey = uKillerCharacter.PlayerKey
  if uController:IsTeamMate(uVictim) then
    print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncSingleGrenadeMultiKill %s KillTeamMate %s", PlayerKey, uVictim.PlayerKey))
    return
  end
  local Record = self.SingleGrenadeMultiKillRecords[PlayerKey]
  if not Record then
    Record = {KillNum = 0, CauserGUID = -1}
    self.SingleGrenadeMultiKillRecords[PlayerKey] = Record
  end
  local CauserGUID = slua.GetNetGUID(uCauser.Object)
  if Record.CauserGUID == -1 then
    Record.  elseif Record.CauserGUID ~= CauserGUID then
    return
  end
  if Record.Timer then
    self:RemoveGameTimer(Record.Timer)
    Record.Timer = nil
  end
  Record.Timer = self:AddGameTimer(HighlightConfig.Timeout, false, function()
    self.SingleGrenadeMultiKillRecords[PlayerKey] = nil
    print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncSingleGrenadeMultiKill %s timeout", PlayerKey))
  end)
  Record.KillNum = Record.KillNum + 1
  print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncSingleGrenadeMultiKill %s KillNum = %d", PlayerKey, Record.KillNum))
  if Record.KillNum >= HighlightConfig.MinKillNum then
    self:TriggerHighlightMoment(uKillerCharacter, nHighlightID, Record.KillNum)
  end
end
function HighlightMomentSubsystem_DSChecker:CheckFuncHighSpeedKill(nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if not slua.isValid(uKillerCharacter) or nAdditionalValue == -1 or not slua.isValid(uVictim) then
    return
  end
  local uVictimMovement = uVictim.CharacterMovement
  local nSpeed = 0
  if slua.isValid(uVictimMovement) then
    nSpeed = uVictimMovement.LastUpdateVelocity:Size() * 3.6 / 100
  end
  if nSpeed < HighlightConfig.Speed then
    local uLastVehicle = uVictim.LastAttachedVehicle
    if slua.isValid(uLastVehicle) and uLastVehicle:IsAlive() and math.abs(uVictim.LastLeaveVehicleTime - CGameState:GetServerWorldTimeSeconds()) <= 0.001 then
      nSpeed = uLastVehicle:GetForwardSpeed() * 3.6 / 100
    end
  end
  if nSpeed >= HighlightConfig.Speed then
    nSpeed = math.floor(nSpeed + 0.5)
    self:TriggerHighlightMoment(uKillerCharacter, nHighlightID, nSpeed, {Speed = nSpeed})
  end
end
function HighlightMomentSubsystem_DSChecker:CheckFuncAllWeaponKill(nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if not (slua.isValid(uKillerCharacter) and nAdditionalValue) or nAdditionalValue <= 0 then
    return
  end
  local PlayerKey = uKillerCharacter.PlayerKey
  if not self.KillWeaponTypeRecord then
    self.KillWeaponTypeRecord = {}
  end
  if not self.KillWeaponTypeRecord[PlayerKey] then
    self.KillWeaponTypeRecord[PlayerKey] = {}
  end
  if self.KillWeaponTypeRecord[PlayerKey].bTriggered then
    return
  end
  local nSubType = BackpackUtils.GetItemSubType(nAdditionalValue)
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:CheckFuncAllWeaponKill", PlayerKey, nSubType, nAdditionalValue)
  if not nSubType or nSubType <= 0 then
    return
  end
  self.KillWeaponTypeRecord[PlayerKey][nSubType] = true
  local bTrigger = true
  for _, SubType in pairs(HighlightConfig.SubTypeConfig) do
    if not self.KillWeaponTypeRecord[PlayerKey][SubType] then
      bTrigger = false
      print(bWriteLog and "HighlightMomentSubsystem_DSChecker:CheckFuncAllWeaponKill no SubType", PlayerKey, SubType)
      break
    end
  end
  if bTrigger then
    self:TriggerHighlightMoment(uKillerCharacter, nHighlightID, 0)
    self.KillWeaponTypeRecord[PlayerKey].bTriggered = true
  end
end
function HighlightMomentSubsystem_DSChecker:CheckFuncLongRangeSnipeKill(nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if not slua.isValid(uKillerCharacter) or nAdditionalValue == -1 or not slua.isValid(uVictim) then
    return
  end
  local uVictimState = uVictim:GetPlayerStateSafety()
  local CauserDistance = -1
  if slua.isValid(uVictimState) then
    if uVictimState:IsNearDeathDamageInfoValid() then
      uVictimState:CopyNearDeathDamageInfo()
      local NearDeathDamageInfo = uVictimState.LuaNearDeathDamageInfo
      if NearDeathDamageInfo.AttackerID == uKillerCharacter.PlayerKey then
        CauserDistance = math.ceil(NearDeathDamageInfo.Distance) or -1
      end
    end
    if CauserDistance == -1 and uVictimState:IsDeathDamageInfoValid() then
      uVictimState:CopyDeathDamageInfo()
      local DamageInfo = uVictimState.LuaDeathDamageInfo
      if DamageInfo.AttackerID == uKillerCharacter.PlayerKey then
        CauserDistance = math.ceil(DamageInfo.Distance) or -1
      end
    end
  end
  print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncLongRangeSnipeKill %s Distance = %f", uKillerCharacter.PlayerKey, CauserDistance))
  if CauserDistance >= HighlightConfig.Distance then
    print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncLongRangeSnipeKill %s Distance = %f", uKillerCharacter.PlayerKey, CauserDistance))
    CauserDistance = math.floor(CauserDistance + 0.5)
    self:TriggerHighlightMoment(uKillerCharacter, nHighlightID, CauserDistance, {Distance = CauserDistance})
  end
end
function HighlightMomentSubsystem_DSChecker:CheckFuncSingleShotMultiKill(nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if not slua.isValid(uKillerCharacter) then
    return
  end
  if not self.SingleShotMultiKillRecords then
    self.SingleShotMultiKillRecords = {}
  end
  local uController = uKillerCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uController) then
    return
  end
  local PlayerKey = uKillerCharacter.PlayerKey
  if uController:IsTeamMate(uVictim) then
    return
  end
  if not (slua.isValid(uCauser) and Game:IsClassOf(uCauser, ASTExtraShootWeapon)) or not uCauser.GetCurrentBulletNumInClip then
    return
  end
  local nCurTime = CGameState:GetServerWorldTimeSeconds()
  local OldRecord = self.SingleShotMultiKillRecords[PlayerKey]
  if not OldRecord then
    OldRecord = {
      CauserGUID = -1,
      CurBulletNumInClip = -1,
      nTime = -1
    }
    self.SingleShotMultiKillRecords[PlayerKey] = OldRecord
  end
  local NewRecord = {
    CauserGUID = slua.GetNetGUID(uCauser.Object),
    CurBulletNumInClip = uCauser:GetCurrentBulletNumInClip(0),
    nTime = nCurTime
  }
  local bSuccess = true
  if math.abs(NewRecord.nTime - OldRecord.nTime) > 0.1 then
    bSuccess = false
  end
  if NewRecord.CauserGUID and NewRecord.CauserGUID < 0 or NewRecord.CauserGUID ~= OldRecord.CauserGUID then
    bSuccess = false
  end
  if NewRecord.CurBulletNumInClip ~= OldRecord.CurBulletNumInClip then
    bSuccess = false
  end
  self.SingleShotMultiKillRecords[PlayerKey] = NewRecord
  print(bWriteLog and "HighlightMomentSubsystem_DSChecker:CheckFuncSingleShotMultiKill", PlayerKey, bSuccess)
  if bSuccess then
    self:TriggerHighlightMoment(uKillerCharacter, nHighlightID)
  end
end
function HighlightMomentSubsystem_DSChecker:CheckFuncUpgradedWeaponKill(nHighlightID, HighlightConfig, uVictim, uCauser, nTypeID, uKillerCharacter, nAdditionalValue)
  if not slua.isValid(uKillerCharacter) then
    return
  end
  local uController = uKillerCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uController) or not slua.isValid(uVictim) then
    return
  end
  local PlayerKey = uKillerCharacter.PlayerKey
  if uController:IsTeamMate(uVictim) then
    return
  end
  if not slua.isValid(uCauser) or not Game:IsClassOf(uCauser, ASTExtraShootWeapon) then
    return
  end
  local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
  local WeaponAvatarBPID = AvatarUtil.GetWeaponAvatarBPIdByWeapon(uCauser)
  if WeaponAvatarBPID < 0 then
    print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncUpgradedWeaponKill invalid avatar weapon: %s, WeaponAvatarBPID: %d", PlayerKey, WeaponAvatarBPID))
    return
  end
  local UAvatarUtils = import("AvatarUtils")
  local HighlightMomentDuration = UAvatarUtils.GetWeaponAvatarHighlightMomentDuration(WeaponAvatarBPID) or 0
  print(bWriteLog and string.format("HighlightMomentSubsystem_DSChecker:CheckFuncUpgradedWeaponKill %s HighlightMomentDuration: %s", PlayerKey, tostring(HighlightMomentDuration)))
  if 0 < HighlightMomentDuration then
    self:TriggerHighlightMoment(uKillerCharacter, nHighlightID, uVictim.PlayerKey)
  end
end
return HighlightMomentSubsystem_DSChecker