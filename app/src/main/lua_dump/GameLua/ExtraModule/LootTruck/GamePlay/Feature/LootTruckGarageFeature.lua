local LootTruckGarageFeature = {}
local LootTruckGarageConfig = require("GameLua.ExtraModule.LootTruck.GamePlay.Config.LootTruckGarageConfig")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local LootTruckGaragePath = "/Game/Mod/LootTruck/BluePrints/BP_LootTruckGarage.BP_LootTruckGarage"
local LootTruckPath = "/Game/Mod/LootTruck/Arts_PlayerBluePrints/VH_LootTruck.VH_LootTruck"
function LootTruckGarageFeature:ctor(selfType)
  LootTruckGarageFeature.__super.ctor(self, selfType)
  self.LootTruckGarages = {}
  self.DispatchCount = 0
  self._GMOpenMapMark = false
  self._GMLootTrucks = {}
  self.TruckToGarageIndexMap = {}
end
function LootTruckGarageFeature:ReceiveBeginPlay()
  LootTruckGarageFeature.__super.ReceiveBeginPlay(self)
  local MapType = GameMainConfig.GetMapType()
  if not LootTruckGarageConfig[MapType] then
    printf("LootTruckGarageFeature:ReceiveBeginPlay invalid config MapType:%s", MapType)
  end
  printf("LootTruckGarageFeature:ReceiveBeginPlay current MapType:%s", MapType)
  self.Config = LootTruckGarageConfig[MapType]
  if self.Config and not Client then
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.OnEnterFightingState, self)
  end
end
function LootTruckGarageFeature:AddLootTruckGarage(GarageActor)
  if slua.isValid(GarageActor) then
    self.LootTruckGarages[#self.LootTruckGarages + 1] = GarageActor
    printf("LootTruckGarageFeature:AddLootTruckGarage Index:%d at %s", #self.LootTruckGarages, GarageActor:K2_GetActorLocation():ToString())
    return #self.LootTruckGarages
  end
end
function LootTruckGarageFeature:OnEnterFightingState()
  self:AddGameTimer(self.Config.DispatchConfig.InitialDispatchTime, false, function()
    self:RandomInitialDispatch()
  end)
end
function LootTruckGarageFeature:RandomInitialDispatch()
  if not slua.isValid(CGameState) then
    return
  end
  local DispatchConfig = self.Config.DispatchConfig
  local Count = DispatchConfig.InitialCount
  local MaxCount = DispatchConfig.MaxCount
  Count = math.min(Count, MaxCount)
  printf("LootTruckGarageFeature:RandomInitialDispatch Count:%d", Count)
  local Weight = {}
  for Index, GarageActor in ipairs(self.LootTruckGarages) do
    if slua.isValid(GarageActor) then
      Weight[Index] = DispatchConfig.InitialWeight
      local Loc = GarageActor:K2_GetActorLocation()
      if not CGameState:IsInWhiteCircle(Loc) then
        Weight[Index] = DispatchConfig.NotInFirstCircleWeight
      end
    end
  end
  local RandomIndexs = Game:RandomByWeight(Weight, Count)
  for _, Index in pairs(RandomIndexs) do
    if slua.isValid(self.LootTruckGarages[Index]) then
      self.LootTruckGarages[Index]:DispatchLootTruck(true)
      self.DispatchCount = self.DispatchCount + 1
    end
  end
end
function LootTruckGarageFeature:RandomAdditionalDispatch(ExcludeIndex)
  printf("LootTruckGarageFeature:RandomAdditionalDispatch")
  local DispatchConfig = self.Config.DispatchConfig
  if self.DispatchCount >= DispatchConfig.MaxCount then
    return
  end
  local ECollisionChannel = import("ECollisionChannel")
  local STExtraBaseCharacterClass = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local LootTruckClass = slua.loadClass(LootTruckPath)
  if not LootTruckClass then
    return
  end
  local Weights = {}
  local LootTruckNums = {}
  local PlayerNums = {}
  local MaxPlayerNum = 0
  local MinPlayerNum = 1000
  for Index, GarageActor in ipairs(self.LootTruckGarages) do
    if ExcludeIndex == Index then
      printf("LootTruckGarageFeature:RandomAdditionalDispatch last loottruck exclude index:%d", ExcludeIndex)
    elseif slua.isValid(GarageActor) then
      if GarageActor.bOpen or GarageActor.bClosing then
        printf("LootTruckGarageFeature:RandomAdditionalDispatch illegal Garage %d, bOpen:%s, bClosing:%s", Index, GarageActor.bOpen, GarageActor.bClosing)
      else
        Weights[Index] = DispatchConfig.InitialWeight
        local Loc = GarageActor:K2_GetActorLocation()
        local PlayerNum = 0
        local NearCharacters = USTExtraBlueprintFunctionLibrary.GetOverlappingActorForTypeBySphere(GarageActor, nil, Loc, DispatchConfig.CheckPlayerRadius, ECollisionChannel.ECC_Pawn, STExtraBaseCharacterClass)
        for _, Character in pairs(NearCharacters) do
          if Game:IsPlayer(Character) or Game:IsAI(Character) then
            PlayerNum = PlayerNum + 1
          end
        end
        MaxPlayerNum = math.max(MaxPlayerNum, PlayerNum)
        MinPlayerNum = math.min(MinPlayerNum, PlayerNum)
        PlayerNums[Index] = PlayerNum
        local NearLootTrucks = USTExtraBlueprintFunctionLibrary.GetOverlappingActorForTypeBySphere(GarageActor, nil, Loc, DispatchConfig.CheckLootTruckRadius, ECollisionChannel.ECC_Vehicle, LootTruckClass)
        local LootTruckNum = 0
        for _, LootTruck in pairs(NearLootTrucks) do
          if slua.isValid(LootTruck) then
            LootTruckNum = LootTruckNum + 1
          end
        end
        LootTruckNums[Index] = LootTruckNum
        printf("LootTruckGarageFeature:RandomAdditionalDispatch Index:%d, PlayerNum:%d, TruckNum:%d at %s", Index, PlayerNum, LootTruckNum, Loc:ToString())
      end
    end
  end
  for Index, GarageActor in ipairs(self.LootTruckGarages) do
    if PlayerNums[Index] then
      if PlayerNums[Index] == MinPlayerNum then
        Weights[Index] = DispatchConfig.MinPlayerNumWeight
      end
      if PlayerNums[Index] == MaxPlayerNum then
        Weights[Index] = DispatchConfig.MaxPlayerNumWeight
      end
    end
    if LootTruckNums[Index] and 0 < LootTruckNums[Index] then
      Weights[Index] = DispatchConfig.NearbyLootTruckWeight
    end
  end
  local RandomIndexTable = Game:RandomByWeight(Weights, 1)
  local RandomIndex
  if next(RandomIndexTable) then
    if Weights[RandomIndexTable[1]] == 0 then
      if IsEditor then
        RandomIndex = RandomIndexTable[1]
      end
    else
      RandomIndex = RandomIndexTable[1]
    end
  end
  if not RandomIndex then
    printf("LootTruckGarageFeature:RandomAdditionalDispatch no valid garage, return")
    return
  end
  printf("LootTruckGarageFeature:RandomAdditionalDispatch RandomIndex:%d", RandomIndex)
  local res = self.LootTruckGarages[RandomIndex]:DispatchLootTruck()
  if not res then
    self:AdditionalTLog(false)
  end
end
function LootTruckGarageFeature:OnLootTruckSpawn(LootTruck, Index)
  if Client or not slua.isValid(LootTruck) then
    return
  end
  local UniqueID = Game:GetActorUniqueID(LootTruck)
  self:AddControlEvent(LootTruck, "OnVehicleHealthDestroy", self.OnLootTruckHealthDestroy, self, UniqueID)
  self.TruckToGarageIndexMap[UniqueID] = Index
  if self._GMOpenMapMark then
    local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
    InGameMarkTools.ShowFastSyncActor(LootTruck, 410901, 0)
    self._GMLootTrucks[#self._GMLootTrucks + 1] = LootTruck
  end
end
function LootTruckGarageFeature:OnLootTruckHealthDestroy(UniqueID)
  printf("LootTruckGarageFeature:OnLootTruckHealthDestroy")
  local ExcludeIndex = self.TruckToGarageIndexMap[UniqueID]
  if self.Config.DispatchConfig.NextTime then
    self:AddGameTimer(self.Config.DispatchConfig.NextTime, false, function()
      self:RandomAdditionalDispatch(ExcludeIndex)
    end)
  else
    self:RandomAdditionalDispatch(ExcludeIndex)
  end
  if self._GMOpenMapMark then
    local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
    for _, LootTruck in pairs(self._GMLootTrucks) do
      if slua.isValid(LootTruck) and LootTruck:IsDestroyed() then
        InGameMarkTools.ModifyFastSyncActorCustomState(LootTruck, 1)
      end
    end
  end
end
function LootTruckGarageFeature:TLog(ID)
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if DSCommonTLogSubsystem then
    DSCommonTLogSubsystem:AddCommonTLog(ID, 1, false)
  end
end
function LootTruckGarageFeature:AdditionalTLog(res)
  if res then
    self.DispatchCount = self.DispatchCount + 1
    printf("LootTruckGarageFeature:RandomAdditionalDispatch success count:%d", self.DispatchCount)
    self:TLog(664)
  else
    printf("LootTruckGarageFeature:RandomAdditionalDispatch fail")
    self:TLog(665)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, LootTruckGarageFeature)