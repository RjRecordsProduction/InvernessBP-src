local EAirAttackGenerateType = import("EAirAttackGenerateType")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local ECollisionChannel = import("ECollisionChannel")
local EAirAttackInfo = import("EAirAttackInfo")
local AirAttackBaseComponent = {}
function AirAttackBaseComponent:ctor()
  print(bWriteLog and "AirAttackBaseComponent:ctor")
end
function AirAttackBaseComponent:ReceiveBeginPlay()
  AirAttackBaseComponent.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "AirAttackBaseComponent:ReceiveBeginPlay()")
  if self.AirAttackCS == nil and self:GetOwner() ~= nil then
    local AirAttackCSComponent = self:GetOwner():GetComponentByClass(import("/Script/ShadowTrackerExtra.AirAttackCS"))
    if AirAttackCSComponent ~= nil then
      self.AirAttackCS = AirAttackCSComponent
      print(bWriteLog and "AirAttackBaseComponent:ReceiveBeginPlay() Set AirAttackCS.")
    end
  end
  local ENetRole = import("ENetRole")
  if self.AirAttackCS ~= nil and self:GetOwner().Role == ENetRole.ROLE_Authority then
    Game:SetTimer(0, false, function()
      local AirAttackSubsystem = SubsystemMgr:Get("AirAttackSubsystem")
      if AirAttackSubsystem ~= nil then
        local AirAttackConfig = import("AirAttackOuterConfig")
        local FAirAttackConfig = AirAttackConfig()
        local InitializeConfig = AirAttackSubsystem.Config
        local bChanged = false
        for k, v in pairs(InitializeConfig) do
          if bChanged == false and FAirAttackConfig[k] ~= v then
            bChanged = true
          end
          FAirAttackConfig[k] = v
        end
        if bChanged then
          local TempOwner = self:GetOwner()
          if TempOwner and slua.isValid(TempOwner) then
            Game:SetAirAttack(TempOwner, FAirAttackConfig)
            print(bWriteLog and "AirAttackBaseComponent:AirAttackSubsystem SetAirAttack")
          end
        end
      end
    end)
  end
end
function AirAttackBaseComponent:MakeAirAttackAreaWarning(vMapCenterDummy, nMapRadiusDummy, nAttackRadius, nCurIndex)
  if nMapRadiusDummy < nAttackRadius then
    printf("[AirAttack] MakeAirAttackAreaWarning, MapRadiusDummy[%f] < AttackRadius[%f].", nMapRadiusDummy, nAttackRadius)
    return
  end
  local GenerateType = self:GetAirAttackGenerateType(nCurIndex)
  local LocalOuterRadius = self.AirAttackConfig.OuterRadius
  if self.bAirAttackUseModifier then
    local SizeModifier = self:GetAirAttackSizeModifier(nCurIndex)
    nAttackRadius = nAttackRadius * SizeModifier
    LocalOuterRadius = LocalOuterRadius * SizeModifier
  end
  local WhiteZonePosition = FVector(0)
  local BlueZonePosition = FVector(0)
  local WhiteZoneRadius = 0
  local BlueZoneRadius = 0
  local bGetCircleInfo = false
  if slua.isValid(CGameMode) then
    local CircleMgrComponentC = import("/Script/ShadowTrackerExtra.CircleMgrComponent")
    local CircleMgrComponent = CGameMode:GetComponentByClass(CircleMgrComponentC)
    if slua.isValid(CircleMgrComponent) then
      WhiteZonePosition = CircleMgrComponent:GetCurrentWhiteCircle()
      WhiteZoneRadius = WhiteZonePosition.Z
      WhiteZonePosition.Z = 0
      BlueZonePosition = CircleMgrComponent:GetCurrentBlueCircle()
      BlueZoneRadius = BlueZonePosition.Z
      BlueZonePosition.Z = 0
      bGetCircleInfo = true
    end
  end
  if slua.isValid(CGameState) and bGetCircleInfo == false then
    WhiteZonePosition = CGameState.WhiteCircle
    WhiteZoneRadius = WhiteZonePosition.Z
    WhiteZonePosition.Z = 0
    BlueZonePosition = CGameState.BlueCircle
    BlueZoneRadius = BlueZonePosition.Z
    BlueZonePosition.Z = 0
  end
  local bSuitable = false
  local LoopTimes = 0
  local Center, LocalMapCenter, LocalAttackArea, Direction
  while LoopTimes < 50 and bSuitable == false do
    if GenerateType == EAirAttackGenerateType.RandomExcludeNone then
      if math.random() > 0.5 then
        GenerateType = EAirAttackGenerateType.Ringtaw
      else
        GenerateType = EAirAttackGenerateType.Outsider
      end
    elseif GenerateType == EAirAttackGenerateType.WithinBlue then
      if math.random() > 0.5 then
        GenerateType = EAirAttackGenerateType.Ringtaw
      else
        GenerateType = EAirAttackGenerateType.WithinWhite
      end
    end
    Direction = FVector.ForwardVector:RotateAngleAxis(math.random(0.0, 360.0), FVector.UpVector)
    local RadiusOffsetMin = 0
    local RadiusOffsetMax = 0
    Center = FVector(vMapCenterDummy.X, vMapCenterDummy.Y, vMapCenterDummy.Z)
    local RadiusOffset = 0
    if GenerateType == EAirAttackGenerateType.None then
      Center = vMapCenterDummy
      RadiusOffsetMin = 0
      RadiusOffsetMax = nMapRadiusDummy - nAttackRadius
    elseif GenerateType == EAirAttackGenerateType.Ringtaw then
      Center = WhiteZonePosition
      RadiusOffsetMin = WhiteZoneRadius
      local BlueCircleSide = Direction * BlueZoneRadius + BlueZonePosition
      RadiusOffsetMax = FVector.DistXY(BlueCircleSide, WhiteZonePosition)
    elseif GenerateType == EAirAttackGenerateType.Outsider then
      Center = BlueZonePosition
      RadiusOffsetMin = BlueZoneRadius
      RadiusOffsetMax = BlueZoneRadius + LocalOuterRadius
    elseif GenerateType == EAirAttackGenerateType.WithinWhite then
      Center = WhiteZonePosition
      RadiusOffsetMin = 0
      RadiusOffsetMax = WhiteZoneRadius
    else
      Center = vMapCenterDummy
      RadiusOffsetMin = 0
      RadiusOffsetMax = RadiusOffsetMin
    end
    RadiusOffset = math.random() * (RadiusOffsetMax - RadiusOffsetMin) + RadiusOffsetMin
    local TempArea = Center + Direction * RadiusOffset
    TempArea.Z = nAttackRadius
    self.AirAttackArea = TempArea
    LocalMapCenter = FVector(vMapCenterDummy.X, vMapCenterDummy.Y, vMapCenterDummy.Z)
    LocalMapCenter.Z = 0
    LocalAttackArea = FVector(self.AirAttackArea.X, self.AirAttackArea.Y, self.AirAttackArea.Z)
    LocalAttackArea.Z = 0
    local LocalDist = (LocalAttackArea - LocalMapCenter):Size()
    bSuitable = nMapRadiusDummy > LocalDist and self:ReviseAirAttackLocation(self.AirAttackArea)
    LoopTimes = LoopTimes + 1
  end
  if bSuitable == false then
    local _radius = math.random() * (nMapRadiusDummy - nAttackRadius)
    local _angle = math.random() * 6.283184
    local TempArea2 = FVector(0)
    TempArea2.X = vMapCenterDummy.X + _radius * math.cos(_angle)
    TempArea2.Y = vMapCenterDummy.Y + _radius * math.sin(_angle)
    TempArea2.Z = nAttackRadius
    self.AirAttackArea = TempArea2
  end
end
function AirAttackBaseComponent:MakeAirAttackOrder(InAirAttackOrder, InAttackDuringTime, InBombsCount, InAttackCenter, InAttackRadius)
  if Game:IsNearlyZero(InAttackDuringTime) or Game:IsNearlyZero(InAttackRadius) or InBombsCount == 0 then
    return
  end
  self:MakeAirAttackPositionOrder(InAirAttackOrder, InBombsCount, InAttackCenter, InAttackRadius)
  InBombsCount = InAirAttackOrder.bombsPosition:Num()
  self:MakeAirAttackIntervalOrder(InAirAttackOrder, InAttackDuringTime, InBombsCount)
  InAirAttackOrder.BombBaseDamage = math.floor(self.BombBaseDamage)
  InAirAttackOrder.BombMinDamage = math.floor(self.BombMinDamage)
  return InAirAttackOrder, InAttackCenter
end
function AirAttackBaseComponent:MakeAirAttackPositionOrder_Lua(InAirAttackOrder, InBombsCount, InAttackCenter, InAttackRadius)
  InAirAttackOrder.bombsPosition2D:Clear()
  InAirAttackOrder.bombsPosition:Clear()
  local BombPositionDummy2D = FVector2D(0, 0)
  local BombPositionDummy = FVector(0)
  local Start = FVector(0)
  local End = FVector(0)
  InAirAttackOrder.SeaLevelHeight = self.SeaLevelHeight
  InAirAttackOrder.FlightHeight = self.FlightHeight
  local TraceHitInfo = import("/Script/Engine.HitResult")()
  local bHit = false
  for i = 1, InBombsCount do
    local CurRadius = math.random() * (InAttackRadius - self.AirAttackConfig.BombsRadius)
    local CurAngle = math.random() * 3.141592 * 2
    BombPositionDummy.X = InAttackCenter.X + CurRadius * math.cos(CurAngle)
    BombPositionDummy.Y = InAttackCenter.Y + CurRadius * math.sin(CurAngle)
    End.X = BombPositionDummy.X
    Start.X = BombPositionDummy.X
    End.Y = BombPositionDummy.Y
    Start.Y = BombPositionDummy.Y
    End.Z = self.SeaLevelHeight - 100
    Start.Z = self.FlightHeight
    BombPositionDummy2D.X = BombPositionDummy.X
    BombPositionDummy2D.Y = BombPositionDummy.Y
    local ObjectTypes = slua.Array(UEnums.EPropertyClass.Int)
    ObjectTypes:Add(ECollisionChannel.ECC_WorldStatic)
    bHit, TraceHitInfo = UKismetSystemLibrary.LineTraceSingleForObjects(self.Object, Start, End, ObjectTypes, true, nil, 0, TraceHitInfo, true, FLinearColor.Red, FLinearColor.Green, 1)
    if bHit then
      BombPositionDummy.Z = TraceHitInfo.ImpactPoint.Z + 10
      InAirAttackOrder.bombsPosition:Add(BombPositionDummy)
      InAirAttackOrder.bombsPosition2D:Add(BombPositionDummy2D)
    end
  end
end
function AirAttackBaseComponent:MakeAirAttackIntervalOrder(InAirAttackOrder, InAttackDuringTime, InBombsCount)
  InAirAttackOrder.bombsInterval:Clear()
  if InBombsCount <= 0 then
    return
  end
  local AttackTimeInterval = InAttackDuringTime / InBombsCount
  local BombInterval = 0
  for i = 1, InBombsCount do
    if 1 == i then
      BombInterval = 0
    elseif InBombsCount == i then
      BombInterval = InAttackDuringTime
    else
      BombInterval = AttackTimeInterval * i + (math.random() - 0.5) * AttackTimeInterval
    end
    InAirAttackOrder.bombsInterval:Add(math.floor(BombInterval * 1000))
  end
end
function AirAttackBaseComponent:OnRep_AirAttackStatus()
  print(bWriteLog and "[AirAttackBaseComponent] OnRep_AirAttackStatus.. self.AirAttackStatus:" .. self.AirAttackStatus .. " WaveIndex:" .. self.WaveIndex .. " AirAttackArea:" .. self.AirAttackArea:ToString())
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_RECEIVED_AIR_ATTACK, self.AirAttackStatus, self.WaveIndex, self:GetOwner(), self.AirAttackArea)
end
function AirAttackBaseComponent:ReceiveEndPlay(Reason)
  print(bWriteLog and "AirAttackBaseComponent:ReceiveEndPlay")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_RECEIVED_AIR_ATTACK, EAirAttackInfo.AttackOver, -1, self:GetOwner(), FVector(0, 0, 0))
  AirAttackBaseComponent.__super.ReceiveEndPlay(self, Reason)
end
local Class = require("class")
local Object = require("GameLua.Mod.BaseMod.GamePlay.Component.XComponent")
local CAirAttackComponent = Class(Object, nil, AirAttackBaseComponent)
return CAirAttackComponent