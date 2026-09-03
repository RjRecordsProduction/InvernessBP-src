local CharacterStrongestSquadFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local DeadBoxCfg = require("GameLua.Mod.Library.GamePlay.Config.CarryDeadBoxConfig")
CharacterStrongestSquadFeature.ClientRPC.RPC_Client_ShowSummonUI = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
CharacterStrongestSquadFeature.MulticastRPC.MulticastRPC_ShowSummonEffect = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Int
  }
}
CharacterStrongestSquadFeature.ServerRPC.RPC_Server_ConfirmSummon = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
function CharacterStrongestSquadFeature:_PostConstruct()
  CharacterStrongestSquadFeature.__super._PostConstruct(self)
  self.bSummonUIShowing = false
  self.SummonLocation = {}
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  self.Config = GamePlayTools.GetCurrentConfig("StrongestSquadFeatureConfig")
end
function CharacterStrongestSquadFeature:RPC_Client_ShowSummonUI(PlayerName, EndTime, X, Y, Z, CallerAreaID)
  if Client and slua.isValid(CGameState) then
    if self.bSummonUIShowing == true then
      return
    end
    if 0 < EndTime then
      local nCountDownTime = math.floor(EndTime - CGameState:GetServerWorldTimeSeconds() + 0.5)
      print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Client_ShowSummonUI, nCountDownTime = " .. tostring(nCountDownTime))
      if 1 < nCountDownTime then
        self.bSummonUIShowing = true
        local ConfirmInfo = {
          Style = "Simple",
          Content = LocUtil.LocalizeResFormat(69917, PlayerName or ""),
          LeftLable = LocUtil.GetLocalizeResStr(117036),
          RightLable = LocUtil.GetLocalizeResStr(301346),
          LeftCountDownTime = nCountDownTime,
          CountDownEndTime = EndTime,
          RightLableColorAndOpacity = FSlateColor(FLinearColor(1, 0.723055, 0.015209, 1))
        }
        function ConfirmInfo.RightCB()
          print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Client_ShowSummonUI, Confirm")
          local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
          if IngameSelfieSubsystem then
            IngameSelfieSubsystem:ExitSelfie()
          end
          self:RPC_Server_ConfirmSummon(X, Y, Z, CallerAreaID)
          self.bSummonUIShowing = false
          EventSystem:postEventSafety(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_STRONGESTSQUAD_SUMMON)
        end
        function ConfirmInfo.CloseCB()
          print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Client_ShowSummonUI, Close")
          self.bSummonUIShowing = false
        end
        local CommonConfirm = require("GameLua.Mod.BaseMod.Common.Confirm.CommonConfirm")
        CommonConfirm.ShowConfirm(ConfirmInfo)
      end
    end
  end
end
function CharacterStrongestSquadFeature:CacheSummonLocation(X, Y, Z)
  local NewLocation = FVector(X, Y, Z)
  print(bWriteLog and "CharacterStrongestSquadFeature:CacheSummonLocation, Save NewLocation = " .. tostring(NewLocation:ToStringShort()))
  if #self.SummonLocation < 3 then
    table.insert(self.SummonLocation, 1, FVector(X, Y, Z))
  else
    table.remove(self.SummonLocation, 3)
    table.insert(self.SummonLocation, 1, FVector(X, Y, Z))
  end
end
function CharacterStrongestSquadFeature:IsSummonLocationValid(X, Y, Z)
  local Location = FVector(X, Y, Z)
  for k, v in ipairs(self.SummonLocation) do
    if FVector.Distance(v, Location) < 100 then
      self.SummonLocation = {}
      print(bWriteLog and "CharacterStrongestSquadFeature:IsSummonLocationValid, true at k = " .. tostring(k))
      return true
    end
  end
  for k, v in ipairs(self.SummonLocation) do
    print(bWriteLog and "CharacterStrongestSquadFeature:IsSummonLocationValid, v = " .. tostring(v:ToStringShort()))
  end
  print(bWriteLog and "CharacterStrongestSquadFeature:IsSummonLocationValid, false when Location = " .. tostring(Location:ToStringShort()))
  return false
end
function CharacterStrongestSquadFeature:RPC_Server_ConfirmSummon(X, Y, Z, CallerAreaID)
  if self.Owner == nil or self.Owner.Object == nil or slua.isValid(self.Owner.Object) == false then
    print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Server_ConfirmSummon, Owner is nil")
    return
  end
  if self.Owner.Object.TeleportPawnFeature == nil then
    print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Server_ConfirmSummon, no TeleportPawnFeature")
    return
  end
  if self:IsSummonLocationValid(X, Y, Z) == false then
    print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Server_ConfirmSummon, not valid Location, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return
  end
  if self:IsCharacterCanBeSummoned(CallerAreaID) == true then
    local Location = self.Owner.Object:K2_GetActorLocation()
    self:MulticastRPC_ShowSummonEffect(Location.X, Location.Y, Location.Z, 2)
    local Location = FVector(X, Y, Z)
    local TeleportID = 1001
    if self.Config and self.Config.TeleportIDConfig then
      print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Server_ConfirmSummon, TeleportIDConfig = " .. tostring(self.Config.TeleportIDConfig))
      TeleportID = self.Config.TeleportIDConfig
    end
    local bSuccess = self.Owner.Object.TeleportPawnFeature:RemoteTeleport(Location, self.Owner.Object:K2_GetActorRotation(), TeleportID)
    if bSuccess then
      local Add = self.Owner.Object.HealthMax - self.Owner.Object.Health
      Game:AddHealth(self.Owner.Object, Add)
      local Location = self.Owner.Object:K2_GetActorLocation()
      self:MulticastRPC_ShowSummonEffect(Location.X, Location.Y, Location.Z, 1)
      print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Server_ConfirmSummon, AddHealth = " .. tostring(Add) .. ", Location = " .. tostring(Location) .. ", AreaID = " .. tostring(CallerAreaID) .. ", bSuccess = " .. tostring(bSuccess) .. ", PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    else
      print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Server_ConfirmSummon, Location = " .. tostring(Location) .. ", AreaID = " .. tostring(CallerAreaID) .. ", bSuccess = " .. tostring(bSuccess) .. ", PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    end
  else
    print(bWriteLog and "CharacterStrongestSquadFeature:RPC_Server_ConfirmSummon, not allowed, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
  end
end
function CharacterStrongestSquadFeature:IsCharacterCanBeSummoned(CallerAreaID)
  if not slua.isValid(self.Owner.Object) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, Owner Not Valid")
    return false
  end
  local EPawnState = import("EPawnState")
  if self.Owner.Object:HasState(EPawnState.Dead) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, Dead, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.Dying) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, Dying, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.BeCarriedBack) or self.Owner.Object:HasState(EPawnState.CarryBack) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, CarryBack, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.InPlane) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, InPlane, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.InParachute) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, InParachute, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.InVehicle) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, InVehicle, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.DriveVehicle) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, DriveVehicle, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.InZipline) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, InZipline, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.CarryBox) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, CarryBox, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.Imprisonment) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, Imprisonment, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Owner.Object:HasState(EPawnState.SplineMove) then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, SplineMove, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if slua.isValid(self.Owner.Object.SkillManager) then
    local bCastingCarry = self.Owner.Object.SkillManager:IsCastingSkillID(DeadBoxCfg.CarryDeadBoxSkillID)
    if bCastingCarry then
      print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, bCastingCarry box , PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
      return false
    end
  end
  if slua.isValid(self.Owner.Object.STCharacterMovement) and self.Owner.Object.STCharacterMovement:IsActive() == false then
    print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, STCharacterMovement invalid, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
    return false
  end
  if self.Config.SameAreaIDCanBeSummoned == false and CallerAreaID ~= nil and 0 < CallerAreaID then
    local AreaID = math.floor(self.Owner.Object:GetAttrValue("AreaID") + 0.5)
    if AreaID == CallerAreaID then
      print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, AreaID = " .. tostring(AreaID) .. ", PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
      return false
    end
  end
  if 0 < #self.Config.SummonExcludeAreaIDList then
    local AreaID = math.floor(self.Owner.Object:GetAttrValue("AreaID") + 0.5)
    if 0 < AreaID then
      for k, v in ipairs(self.Config.SummonExcludeAreaIDList) do
        if AreaID == v then
          print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, Exclude AreaID = " .. tostring(AreaID) .. ", PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
          return false
        end
      end
    end
  end
  if self.Owner and self.Owner.CanBeSummonedByStrongestSquad then
    local Result = self.Owner:CanBeSummonedByStrongestSquad()
    if Result == false then
      print(bWriteLog and "CharacterStrongestSquadFeature:IsCharacterCanBeSummoned, Owner return false, PlayerKey = " .. tostring(self.Owner.Object.PlayerKey))
      return false
    end
  end
  return true
end
function CharacterStrongestSquadFeature:MulticastRPC_ShowSummonEffect(PositionX, PositionY, PositionZ, Index)
  if not Client then
    print(bWriteLog and "CharacterStrongestSquadFeature:MulticastRPC_ShowSummonEffect, not Client")
    return
  end
  local EffectPathList = {
    [1] = self.Config.BeSummonedRevivedEffect,
    [2] = self.Config.SummonReviveEffect
  }
  local EffectOffsetList = {
    [1] = Game:ConstructFVectorByLuaTable(self.Config.BeSummonedRevivedEffectOffset),
    [2] = Game:ConstructFVectorByLuaTable(self.Config.SummonReviveEffectOffset)
  }
  local AudioConfig = {
    [1] = self.Config.BeSummonedRevivedAudio,
    [2] = self.Config.SummonReviveAudio
  }
  if Index == 1 or Index == 2 then
    local EffectPath = EffectPathList[Index]
    if EffectPath == "" then
      print(bWriteLog and "CharacterStrongestSquadFeature:MulticastRPC_ShowSummonEffect, EffectPath Not Valid ")
      return
    end
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(EffectPath, function(uParticleSystem)
      if uParticleSystem then
        if self and self.Owner and slua.isValid(self.Owner.Object) then
          local Location = FVector(PositionX, PositionY, PositionZ)
          if EffectOffsetList[Index] then
            Location = Location + EffectOffsetList[Index]
          end
          local UGameplayStatics = import("GameplayStatics")
          UGameplayStatics.SpawnEmitterAtLocation(self.Owner.Object, uParticleSystem, Location, FRotator(0, 0, 0), FVector(1, 1, 1), true)
          local AudioPath = AudioConfig[Index]
          if AudioPath and AudioPath ~= "" then
            local audio_util = require("client.common.audio_util")
            audio_util.PlayAudioAsyncAtLocation(AudioPath, Location, FRotator(0, 0, 0), self.Owner.Object)
          end
        else
          print(bWriteLog and "CharacterStrongestSquadFeature:MulticastRPC_ShowSummonEffect, Self Not Valid ")
        end
      else
        print(bWriteLog and "CharacterStrongestSquadFeature:MulticastRPC_ShowSummonEffect, uParticleSystem = " .. tostring(uParticleSystem))
      end
    end)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, CharacterStrongestSquadFeature)