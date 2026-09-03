local ShowVehicleFeature = {}
function ShowVehicleFeature:_PostConstruct()
  ShowVehicleFeature.__super._PostConstruct(self)
  if not Client then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_JOIN, self.HandlePlayerJoinEvent, self)
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "ActiveState"
    }, self.HandleEnterGameModeActiveState, self)
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "ReadyState"
    }, self.HandleEnterGameModeReadyState, self)
  end
end
function ShowVehicleFeature:HandleEnterGameModeActiveState()
  if not Client and slua.isValid(CGameState) then
    print(bWriteLog and "ShowVehicleFeature:HandleEnterGameModeActiveState", self.Owner.Object, CGameState:GetGameModeState())
    if CGameState:GetGameModeState() == "ActiveState" then
      self:ShowVehicleInBornIsland()
    end
  end
end
function ShowVehicleFeature:HandleEnterGameModeReadyState()
  if not Client and slua.isValid(CGameState) then
    print(bWriteLog and "ShowVehicleFeature:HandleEnterGameModeReadyState", self.Owner.Object, CGameState:GetGameModeState())
    if CGameState:GetGameModeState() == "ReadyState" then
      self:ShowVehicleInBornIsland()
    end
  end
end
function ShowVehicleFeature:HandlePlayerJoinEvent(_, _, InCharacter)
  if not self.Owner or not slua.isValid(InCharacter) then
    return
  end
  local Controller = InCharacter:GetPlayerControllerSafety()
  if not slua.isValid(Controller) or Controller ~= self.Owner.Object then
    return
  end
  if not Client and slua.isValid(CGameState) then
    print(bWriteLog and "ShowVehicleFeature:HandlePlayerJoinEvent", self.Owner.Object, CGameState:GetGameModeState())
    if CGameState:GetGameModeState() == "ActiveState" or CGameState:GetGameModeState() == "ReadyState" then
      self:ShowVehicleInBornIsland()
    end
  end
end
function ShowVehicleFeature:ShowVehicleInBornIsland()
  local PlayerKey = self.Owner.PlayerKey
  if self:HasAuthority() and PlayerKey ~= 0 then
    local UGameplayStatics = import("GameplayStatics")
    local GameMode = UGameplayStatics.GetGameMode(self.Owner)
    if slua.isValid(GameMode) and slua.isValid(GameMode.ShowVehicle) then
      local VehicleIDs = self:GetVehicleInfoInBornIsland()
      if VehicleIDs and next(VehicleIDs) then
        local InfoEntry = VehicleIDs[1]
        GameMode.ShowVehicle:ShowVehicleFor(PlayerKey, InfoEntry[1], InfoEntry[2], InfoEntry[3])
        print(bWriteLog and "ShowVehicleFeature:ShowVehicleInBornIsland ", PlayerKey, InfoEntry[1], InfoEntry[2], InfoEntry[3])
      end
    end
  end
end
function ShowVehicleFeature:GetVehicleInfoInBornIsland()
  local VehicleInfo = {}
  local Table = CDataTable.GetTableData("BetterVehicleEffect", self.Owner.ShowVehicleSkin)
  if Table and Table.BornFall == 1 then
    local InfoEntry = {
      Table.VehicleInBornIsland,
      Table.VehicleContainer,
      self.Owner.ShowVehicleSkin
    }
    table.insert(VehicleInfo, InfoEntry)
  end
  print(bWriteLog and "ShowVehicleFeature:GetVehicleInfoInBornIsland ", VehicleInfo)
  return VehicleInfo
end
function ShowVehicleFeature:ShowWingmanInBornIsland()
  local PlayerKey = self.Owner.PlayerKey
  if self:HasAuthority() and PlayerKey ~= 0 then
    local UGameplayStatics = import("GameplayStatics")
    local GameMode = UGameplayStatics.GetGameMode(self.Owner)
    if slua.isValid(GameMode) and slua.isValid(GameMode.ShowVehicle) then
      local wingmanInfo = self:GetWingmanInfoInBornIsland()
      if wingmanInfo and next(wingmanInfo) then
        GameMode.ShowVehicle:ShowWingmanFor(PlayerKey, wingmanInfo.classPath, wingmanInfo.spawnTransform)
        print(bWriteLog and "ShowVehicleFeature:ShowWingmanInBornIsland ShowWingmanFor", PlayerKey, wingmanInfo.classPath)
      end
    end
  end
end
function ShowVehicleFeature:GetWingmanInfoInBornIsland()
  local UKismetMathLibrary = import("KismetMathLibrary")
  local wingmanSpawnTranslation = FVector(792230, 12616, 735)
  local wingmanOffsetZ = 400
  local wingmanHelipadClass_BP = slua.loadClass("/Game/Library/Res/Actors/WingPlane/WingmanHelipad.WingmanHelipad")
  local uActorClass = import("/Script/Engine.Actor")
  if wingmanHelipadClass_BP and uActorClass then
    local UGameplayStatics = import("GameplayStatics")
    local wingmanHelipadArray = UGameplayStatics.GetAllActorsOfClass(CGameMode, wingmanHelipadClass_BP, slua.Array(UEnums.EPropertyClass.Object, uActorClass))
    if wingmanHelipadArray:Num() <= 0 then
      print(bWriteLog and "ShowVehicleFeature:GetWingmanInfoInBornIsland. current level has not exist wingmanHelipad.")
      return
    end
    local wingmanHelipadAcotr = wingmanHelipadArray:Get(0)
    if slua.isValid(wingmanHelipadAcotr) then
      local newTranslation = wingmanHelipadAcotr:GetTransform():GetTranslation()
      newTranslation.Z = newTranslation.Z + wingmanOffsetZ
      wingmanSpawnTranslation = newTranslation
    end
  end
  local wingmanInfo = {
    classPath = "/Game/Arts_PlayerBluePrints/Vehicle/WingMan/wing_Vehicle_BornIsland.wing_Vehicle_BornIsland_C",
    spawnTransform = UKismetMathLibrary.MakeTransform(wingmanSpawnTranslation, FRotator(0, 0, 0), FVector(1, 1, 1))
  }
  return wingmanInfo
end
local class = require("class")
local CFeature = require("GameLua.Mod.BaseMod.Gameplay.Feature.Common.FeatureBase")
return class(CFeature, nil, ShowVehicleFeature)