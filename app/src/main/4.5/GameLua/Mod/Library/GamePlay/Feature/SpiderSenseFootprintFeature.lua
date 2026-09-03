local SpiderSenseFootprintFeature = {
  LuaEventContainer = {
    "OnFootprintInfoChanged"
  }
}
local SPIDER_SENSE_TAG = "SpiderSense"
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local asset_util = require("common.asset_util")
local SpiderHeadsetConfig = require("GameLua.Mod.Library.GamePlay.Config.SpiderHeadsetConfig")
local KismetSystemLibrary = import("/Script/Engine.KismetSystemLibrary")
local FLinearColor = import("/Script/CoreUObject.LinearColor")
local Actor_C = import("/Script/Engine.Actor")
local UGameplayStatics_Cached = import("/Script/Engine.GameplayStatics")
local FFootprintInstanceInfo = import("/Script/ShadowTrackerExtra.FootprintInstanceInfo")
local EAttachLocation = import("EAttachLocation")
local EPawnState = import("EPawnState")
function SpiderSenseFootprintFeature:ctor()
  self.bSpiderSenseGranted = false
end
function SpiderSenseFootprintFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bSpiderSenseGranted",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Bool
    }
  }
end
function SpiderSenseFootprintFeature:ReceiveBeginPlay()
  SpiderSenseFootprintFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "SpiderSenseFootprintFeature:ReceiveBeginPlay")
  if not Client then
    if EVENTTYPE_PLAYEREVENT_AVATAR ~= nil and EVENTID_PLAYEREVENT_AVATAR_LOGIC_EQUIPPED ~= nil then
      self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_PLAYEREVENT_AVATAR_LOGIC_EQUIPPED, self.OnPlayerEquippedAvatar_DS, self)
    end
    self:_SyncSpiderSenseGrantedFromAvatar_DS()
    return
  end
  self.CrosshairDetectTimer = nil
  self.bSpiderSenseActive = false
  self.LastHighlightedActor = nil
  self.bFootprintInfoVisible = false
  self.bConfigApplied = false
  self.LastShownPlayerName = nil
  self.FootprintScreenMarks = {}
  self.HiddenScreenMarkKeys = {}
  self.LastReactionEffectTime = {}
  self._LastReactionFootprintKey = nil
  self.FootprintSyncTimer = nil
  self._LastUIUpdatePlayerName = nil
  self._LastUIUpdateTimeAgo = -1
  self.ActiveReactionEffect = nil
  local uAvatarComp2 = self.Owner:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    self:AddControlEvent(uAvatarComp2, "OnAvatarEquipped", self.HandleAvatarEquipped, self)
  else
    print(bWriteLog and "SpiderSenseFootprintFeature:ReceiveBeginPlay - AvatarComp2 invalid")
  end
  if EVENTTYPE_PLANSP_NORMAL ~= nil and EVENTTYPE_PLANSP_ENERGY_LOCKEDOUT ~= nil then
    self:AddCommonEvent(EVENTTYPE_PLANSP_NORMAL, EVENTTYPE_PLANSP_ENERGY_LOCKEDOUT, self.OnEnergyLockedOut, self)
  end
  if GameplayData and GameplayData.AddSelfPlayerControllerEvent then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
  end
  self:AddGameTimer(0.1, false, function()
    if not slua.isValid(self.Object) then
      return
    end
    self:_SyncInitialStateOnBeginPlay()
  end)
end
function SpiderSenseFootprintFeature:OnPlayerEquippedAvatar_DS(_, __, nPlayerKey, InSlotID, NewItemID, OldItemID)
  if Client then
    return
  end
  local uOwnerPawn = self.Owner and self.Owner.Object or nil
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local uOwnerPC = Game.GetPlayerControllerByPlayerKey and Game:GetPlayerControllerByPlayerKey(nPlayerKey) or nil
  if not slua.isValid(uOwnerPC) then
    return
  end
  if uOwnerPC:GetPlayerCharacterSafety() ~= uOwnerPawn then
    return
  end
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:OnPlayerEquippedAvatar_DS - PlayerKey:%s SlotID:%s NewItemID:%s OldItemID:%s", tostring(nPlayerKey), tostring(InSlotID), tostring(NewItemID), tostring(OldItemID)))
  local HeadsetItemID = SpiderHeadsetConfig.SpiderHeadsetItemID
  if NewItemID == HeadsetItemID then
    self:_SetSpiderSenseGranted_DS(true)
  elseif OldItemID == HeadsetItemID then
    self:_SetSpiderSenseGranted_DS(false)
  end
end
function SpiderSenseFootprintFeature:_SyncSpiderSenseGrantedFromAvatar_DS()
  if Client then
    return
  end
  local uOwnerPawn = self.Owner and self.Owner.Object or nil
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local uAvatarComp2 = uOwnerPawn.getAvatarComponent2 and uOwnerPawn:getAvatarComponent2() or nil
  if not slua.isValid(uAvatarComp2) or type(uAvatarComp2.GetAllEquipItemsTable) ~= "function" then
    return
  end
  local EquipItems = uAvatarComp2:GetAllEquipItemsTable()
  if type(EquipItems) ~= "table" then
    return
  end
  local bWearing = EquipItems[SpiderHeadsetConfig.SpiderHeadsetItemID] == true
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:_SyncSpiderSenseGrantedFromAvatar_DS - bWearing:%s", tostring(bWearing)))
  self:_SetSpiderSenseGranted_DS(bWearing)
end
function SpiderSenseFootprintFeature:_SetSpiderSenseGranted_DS(bValue)
  if Client then
    return
  end
  bValue = bValue == true
  if self.bSpiderSenseGranted == bValue then
    return
  end
  self.bSpiderSenseGranted = bValue
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:_SetSpiderSenseGranted_DS - bSpiderSenseGranted:%s", tostring(bValue)))
end
function SpiderSenseFootprintFeature:OnRep_bSpiderSenseGranted(OldValue)
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:OnRep_bSpiderSenseGranted - OldValue:%s NewValue:%s", tostring(OldValue), tostring(self.bSpiderSenseGranted)))
  if not Client then
    return
  end
  if not self.Owner then
    return
  end
  if self.bSpiderSenseGranted then
    self:_SyncInitialStateOnBeginPlay()
  elseif self.bSpiderSenseActive then
    print(bWriteLog and "SpiderSenseFootprintFeature:OnRep_bSpiderSenseGranted - Force disable on revoke")
    self:SetSpiderSenseEnabled(false)
  end
end
function SpiderSenseFootprintFeature:_SyncInitialStateOnBeginPlay()
  if not (self.Owner and self.Owner.IsLocallyControlled) or not self.Owner:IsLocallyControlled() and (not self.Owner.IsLocalViewed or not self.Owner:IsLocalViewed()) then
    print(bWriteLog and "SpiderSenseFootprintFeature:_SyncInitialStateOnBeginPlay - Skip non-local non-viewed owner")
    return
  end
  local uOwner = self.Owner and self.Owner.Object or nil
  local EnergyFeature = slua.isValid(uOwner) and uOwner.SpecialMoveEnergyFeature or nil
  if EnergyFeature and EnergyFeature.bEnergyLockedOut then
    print(bWriteLog and "SpiderSenseFootprintFeature:_SyncInitialStateOnBeginPlay - Energy already locked out, force disable")
    self:OnEnergyLockedOut()
    return
  end
  if self.Owner:IsLocallyControlled() and not self.bSpiderSenseGranted then
    print(bWriteLog and "SpiderSenseFootprintFeature:_SyncInitialStateOnBeginPlay - Skip, server has not granted spider sense")
    return
  end
  local uAvatarComp2 = self.Owner.getAvatarComponent2 and self.Owner:getAvatarComponent2() or nil
  if not slua.isValid(uAvatarComp2) or type(uAvatarComp2.GetAllEquipItemsTable) ~= "function" then
    print(bWriteLog and "SpiderSenseFootprintFeature:_SyncInitialStateOnBeginPlay - AvatarComp2 / API invalid")
    return
  end
  local EquipItems = uAvatarComp2:GetAllEquipItemsTable()
  if type(EquipItems) ~= "table" then
    return
  end
  local HeadsetItemID = SpiderHeadsetConfig.SpiderHeadsetItemID
  if EquipItems[HeadsetItemID] then
    print(bWriteLog and string.format("SpiderSenseFootprintFeature:_SyncInitialStateOnBeginPlay - Headset already equipped (ItemID:%s), replay HandleAvatarEquipped", tostring(HeadsetItemID)))
    self:HandleAvatarEquipped(0, true, HeadsetItemID)
  else
    print(bWriteLog and "SpiderSenseFootprintFeature:_SyncInitialStateOnBeginPlay - Headset not equipped, no action")
  end
end
function SpiderSenseFootprintFeature:OnEnergyLockedOut()
  print(bWriteLog and "SpiderSenseFootprintFeature:OnEnergyLockedOut - Permanently disable spider sense")
  if self.bSpiderSenseActive then
    self:SetSpiderSenseEnabled(false)
  end
end
function SpiderSenseFootprintFeature:OnReconnect()
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:OnReconnect - bSpiderSenseGranted:%s bSpiderSenseActive:%s", tostring(self.bSpiderSenseGranted), tostring(self.bSpiderSenseActive)))
  if not Client then
    return
  end
  if not slua.isValid(self.Object) then
    return
  end
  if not (self.Owner and self.Owner.IsLocallyControlled) or not self.Owner:IsLocallyControlled() and (not self.Owner.IsLocalViewed or not self.Owner:IsLocalViewed()) then
    print(bWriteLog and "SpiderSenseFootprintFeature:OnReconnect - Skip non-local non-viewed owner")
    return
  end
  self:SetSpiderSenseEnabled(false)
  self:AddGameTimer(0.1, false, function()
    if not slua.isValid(self.Object) then
      return
    end
    print(bWriteLog and "SpiderSenseFootprintFeature:OnReconnect - Re-evaluate state via _SyncInitialStateOnBeginPlay")
    self:_SyncInitialStateOnBeginPlay()
  end)
end
function SpiderSenseFootprintFeature:HandleAvatarEquipped(nSlotID, bEquipped, ItemID)
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:HandleAvatarEquipped - SlotID:%s bEquipped:%s ItemID:%s", tostring(nSlotID), tostring(bEquipped), tostring(ItemID)))
  if not (self.Owner and self.Owner.IsLocallyControlled) or not self.Owner:IsLocallyControlled() and (not self.Owner.IsLocalViewed or not self.Owner:IsLocalViewed()) then
    print(bWriteLog and "SpiderSenseFootprintFeature:HandleAvatarEquipped - Skip non-local non-viewed owner")
    return
  end
  if not self:IsSpiderHeadsetItem(ItemID) then
    return
  end
  if bEquipped then
    local uOwner = self.Owner and self.Owner.Object or nil
    local EnergyFeature = slua.isValid(uOwner) and uOwner.SpecialMoveEnergyFeature or nil
    if EnergyFeature and EnergyFeature.bEnergyLockedOut then
      print(bWriteLog and "SpiderSenseFootprintFeature:HandleAvatarEquipped - Skip enable, energy locked out")
      return
    end
    if self.Owner:IsLocallyControlled() and not self.bSpiderSenseGranted then
      print(bWriteLog and "SpiderSenseFootprintFeature:HandleAvatarEquipped - Skip enable, server has not granted spider sense")
      return
    end
  end
  self:SetSpiderSenseEnabled(bEquipped)
end
function SpiderSenseFootprintFeature:IsSpiderHeadsetItem(ItemID)
  return ItemID == SpiderHeadsetConfig.SpiderHeadsetItemID
end
function SpiderSenseFootprintFeature:SetSpiderSenseEnabled(bEnabled)
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:SetSpiderSenseEnabled - bEnabled:%s", tostring(bEnabled)))
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) then
    print(bWriteLog and "SpiderSenseFootprintFeature:SetSpiderSenseEnabled - PC invalid")
    return
  end
  if bEnabled then
    local FootprintClassPath = SpiderHeadsetConfig.SpiderSenseFootprintActorClassPath
    local FootprintClass = asset_util.GetAssetSync(FootprintClassPath)
    if not FootprintClass then
      print(bWriteLog and string.format("SpiderSenseFootprintFeature:SetSpiderSenseEnabled - FootprintClass unavailable, path=%s, skip enable", tostring(FootprintClassPath)))
      return
    end
    PC.ExtraFootprintActorClassMap:Add(SPIDER_SENSE_TAG, FootprintClass)
    local Lifetime = SpiderHeadsetConfig.SpiderSenseFootprintLifetime or 0
    if 0 < Lifetime then
      PC.ExtraFootprintLifetimeMap:Add(SPIDER_SENSE_TAG, Lifetime)
    end
    PC.ExtraFootprintSkipOnVehicleMap:Add(SPIDER_SENSE_TAG, true)
    print(bWriteLog and string.format("SpiderSenseFootprintFeature:SetSpiderSenseEnabled - Added class entry, lifetime:%.1f, skipOnVehicle:true", Lifetime))
    self:ApplyConfigToFootprintActor(PC, SpiderHeadsetConfig)
    self:StartCrosshairDetection()
    self:StartFootprintScreenMarkSync()
    self.bSpiderSenseActive = true
  else
    self:StopCrosshairDetection()
    self:StopFootprintScreenMarkSync()
    self:ClearAllFootprintScreenMarks()
    self.bSpiderSenseActive = false
    self.bConfigApplied = false
    PC.ExtraFootprintActorClassMap:Remove(SPIDER_SENSE_TAG)
    PC.ExtraFootprintLifetimeMap:Remove(SPIDER_SENSE_TAG)
    PC.ExtraFootprintSkipOnVehicleMap:Remove(SPIDER_SENSE_TAG)
    local CachedActor = PC.ExtraFootprintActorMap:Get(SPIDER_SENSE_TAG)
    if slua.isValid(CachedActor) then
      print(bWriteLog and "SpiderSenseFootprintFeature:SetSpiderSenseEnabled - Destroying cached FootprintActor")
      CachedActor:K2_DestroyActor()
    end
    PC.ExtraFootprintActorMap:Remove(SPIDER_SENSE_TAG)
    print(bWriteLog and "SpiderSenseFootprintFeature:SetSpiderSenseEnabled - Removed entry from ExtraFootprintActorClassMap")
  end
end
function SpiderSenseFootprintFeature:ApplyConfigToFootprintActor(PC, Config)
  local FootprintActor = PC.ExtraFootprintActorMap:Get(SPIDER_SENSE_TAG)
  if not slua.isValid(FootprintActor) then
    print(bWriteLog and "SpiderSenseFootprintFeature:ApplyConfigToFootprintActor - FootprintActor not spawned yet, config will be applied on spawn")
    return
  end
  local Lifetime = Config.SpiderSenseFootprintLifetime or 0
  FootprintActor.Footprint  if 0 < Lifetime then
    FootprintActor:SetActorTickEnabled(true)
  end
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:ApplyConfigToFootprintActor - FootprintLifetime:%.1f TickEnabled:%s", Lifetime, tostring(0 < Lifetime)))
  local DetectionRadius = Config.CrosshairDetectionRadius or 50.0
  FootprintActor.Crosshair  print(bWriteLog and string.format("SpiderSenseFootprintFeature:ApplyConfigToFootprintActor - CrosshairDetectionRadius:%.1f", DetectionRadius))
  local SampleStep = Config.FootprintSampleStep or 1
  if SampleStep < 1 then
    SampleStep = 1
  end
  FootprintActor.Footprint  print(bWriteLog and string.format("SpiderSenseFootprintFeature:ApplyConfigToFootprintActor - FootprintSampleStep:%d", SampleStep))
end
function SpiderSenseFootprintFeature:StartCrosshairDetection()
  if self.CrosshairDetectTimer then
    self:RemoveGameTimer(self.CrosshairDetectTimer)
    self.CrosshairDetectTimer = nil
  end
  local Interval = SpiderHeadsetConfig.CrosshairDetectInterval or 0.1
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:StartCrosshairDetection - Interval:%.2f", Interval))
  self.CrosshairDetectTimer = self:AddGameTimer(Interval, true, function()
    self:OnCrosshairDetectTick()
  end)
end
function SpiderSenseFootprintFeature:StopCrosshairDetection()
  print(bWriteLog and "SpiderSenseFootprintFeature:StopCrosshairDetection")
  if self.CrosshairDetectTimer then
    self:RemoveGameTimer(self.CrosshairDetectTimer)
    self.CrosshairDetectTimer = nil
  end
  self._cachedHitResult = nil
  self._cachedActorsToIgnore = nil
  self._cachedFootprintInfo = nil
  self:ClearFootprintHighlight()
  self:HideFootprintInfoUI()
  self:StopReactionEffect()
end
function SpiderSenseFootprintFeature:OnCrosshairDetectTick()
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) then
    return
  end
  local uPlayerCharacter = PC:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  local FootprintActor = PC.ExtraFootprintActorMap:Get(SPIDER_SENSE_TAG)
  if not slua.isValid(FootprintActor) then
    if self.bFootprintInfoVisible then
      self:ClearFootprintHighlight()
      self:HideFootprintInfoUI()
    end
    return
  end
  if uPlayerCharacter:HasState(EPawnState.Dying) or uPlayerCharacter:HasState(EPawnState.Dead) or uPlayerCharacter:HasState(EPawnState.BeCarriedBack) then
    if self.bFootprintInfoVisible or self._CurrentAimedKey or slua.isValid(self.LastHighlightedActor) then
      self:ClearAimState()
    end
    return
  end
  if not self.bConfigApplied then
    self:ApplyConfigToFootprintActor(PC, SpiderHeadsetConfig)
    self.bConfigApplied = true
    print(bWriteLog and "SpiderSenseFootprintFeature:OnCrosshairDetectTick - Config applied to FootprintActor on first detect tick")
  end
  local ViewRotation = uPlayerCharacter:GetViewRotation()
  ViewRotation:Normalize()
  local ViewDir = ViewRotation:Vector()
  local StartLocation = uPlayerCharacter:GetSpringArmLocation()
  local DetectRange = SpiderHeadsetConfig.CrosshairDetectRange or 5000.0
  local EndLocation = StartLocation + ViewDir * DetectRange
  if not self._cachedHitResult then
    self._cachedHitResult = import("/Script/Engine.HitResult")()
    self._cachedActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
  end
  local uHitResult = self._cachedHitResult
  local bHit, uHitResult = KismetSystemLibrary.LineTraceSingle(uPlayerCharacter, StartLocation, EndLocation, 0, true, self._cachedActorsToIgnore, 0, uHitResult, true, FLinearColor(1, 0, 0, 1), FLinearColor(0, 1, 0, 1), 1)
  local HitLocation = bHit and uHitResult.Location or EndLocation
  if not self._cachedFootprintInfo then
    self._cachedFootprintInfo = FFootprintInstanceInfo()
  end
  local FootprintInfo = self._cachedFootprintInfo
  local bFound = FootprintActor:GetFootprintInfoAtLocation(HitLocation, FootprintInfo)
  if bFound then
    local AimedKey = self:MakeLocationKey(FootprintInfo.FootprintTransform:GetLocation())
    if not self.FootprintScreenMarks[AimedKey] then
      print(bWriteLog and string.format("SpiderSenseFootprintFeature:OnCrosshairDetectTick - C++ reported footprint at Key:%s but no tracked ScreenMark, treat as not-found", AimedKey))
      bFound = false
    end
  end
  if bFound then
    if self.LastHighlightedActor ~= FootprintActor then
      self:ClearFootprintHighlight()
    end
    self.LastHighlightedActor = FootprintActor
    local ClosestIndex = self:FindClosestFootprintIndex(FootprintActor, HitLocation)
    if 0 <= ClosestIndex then
      FootprintActor:SetFootprintHighlighted(ClosestIndex, true)
    end
    local CurrentTime = UGameplayStatics_Cached.GetTimeSeconds(uPlayerCharacter)
    local TimeAgo = CurrentTime - FootprintInfo.CreationTime
    local FootprintWorldLocation = FootprintInfo.FootprintTransform:GetLocation()
    self:HandleFootprintAimed(FootprintWorldLocation, CurrentTime)
    self:ShowFootprintInfoUI(FootprintInfo.OwnerPlayerName, TimeAgo, FootprintWorldLocation)
  else
    if self.bFootprintInfoVisible then
      self:ClearFootprintHighlight()
      self:HideFootprintInfoUI()
    end
    self:RestoreAimedFootprintScreenMark()
  end
end
function SpiderSenseFootprintFeature:MakeLocationKey(WorldLocation)
  local Precision = SpiderHeadsetConfig.FootprintLocationKeyPrecision or 1.0
  if Precision <= 0 then
    Precision = 1.0
  end
  local X = math.floor(WorldLocation.X / Precision + 0.5)
  local Y = math.floor(WorldLocation.Y / Precision + 0.5)
  local Z = math.floor(WorldLocation.Z / Precision + 0.5)
  return string.format("%d_%d_%d", X, Y, Z)
end
function SpiderSenseFootprintFeature:StartFootprintScreenMarkSync()
  if self.FootprintSyncTimer then
    self:RemoveGameTimer(self.FootprintSyncTimer)
    self.FootprintSyncTimer = nil
  end
  local Interval = SpiderHeadsetConfig.FootprintScreenMarkSyncInterval or 0.2
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:StartFootprintScreenMarkSync - Interval:%.2f", Interval))
  self.FootprintSyncTimer = self:AddGameTimer(Interval, true, function()
    self:OnFootprintScreenMarkSyncTick()
  end)
end
function SpiderSenseFootprintFeature:StopFootprintScreenMarkSync()
  print(bWriteLog and "SpiderSenseFootprintFeature:StopFootprintScreenMarkSync")
  if self.FootprintSyncTimer then
    self:RemoveGameTimer(self.FootprintSyncTimer)
    self.FootprintSyncTimer = nil
  end
  self._cachedActiveIndices = nil
end
function SpiderSenseFootprintFeature:OnFootprintScreenMarkSyncTick()
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) then
    return
  end
  local FootprintActor = PC.ExtraFootprintActorMap:Get(SPIDER_SENSE_TAG)
  if not slua.isValid(FootprintActor) then
    if next(self.FootprintScreenMarks) then
      self:ClearAllFootprintScreenMarks()
    end
    return
  end
  local ISMC = FootprintActor.InstancedMeshComponent
  if not slua.isValid(ISMC) then
    return
  end
  local TypeID = SpiderHeadsetConfig.FootprintScreenMarkTypeID or 1100
  self._FailedScreenMarkKeys = self._FailedScreenMarkKeys or {}
  local CurrentKeys = {}
  local CurrentLocations = {}
  if not self._cachedActiveIndices then
    self._cachedActiveIndices = slua.Array(UEnums.EPropertyClass.Int)
  end
  local ActiveIndices = self._cachedActiveIndices
  ActiveIndices:Clear()
  FootprintActor:GetActiveFootprintIndices(ActiveIndices)
  local ActiveCount = ActiveIndices:Num()
  for i = 0, ActiveCount - 1 do
    local InstIndex = ActiveIndices:Get(i)
    local _, uTransform = ISMC:GetInstanceTransform(InstIndex, nil, true)
    if uTransform then
      local Loc = uTransform:GetLocation()
      local Key = self:MakeLocationKey(Loc)
      CurrentKeys[Key] = true
      CurrentLocations[Key] = Loc
    end
  end
  local bAimedFootprintRemoved = false
  for Key, InstID in pairs(self.FootprintScreenMarks) do
    if not CurrentKeys[Key] then
      print(bWriteLog and string.format("SpiderSenseFootprintFeature:OnFootprintScreenMarkSyncTick - Remove ScreenMark Key:%s InstID:%s", Key, tostring(InstID)))
      InGameMarkTools.HideMapMark(InstID)
      self.FootprintScreenMarks[Key] = nil
      self.HiddenScreenMarkKeys[Key] = nil
      self.LastReactionEffectTime[Key] = nil
      self._FailedScreenMarkKeys[Key] = nil
      if self._CurrentAimedKey == Key then
        bAimedFootprintRemoved = true
      end
    end
  end
  if bAimedFootprintRemoved then
    print(bWriteLog and "SpiderSenseFootprintFeature:OnFootprintScreenMarkSyncTick - Aimed footprint disappeared, force clear aim state")
    self:ClearAimState()
  end
  for Key, _ in pairs(self._FailedScreenMarkKeys) do
    if not CurrentKeys[Key] then
      self._FailedScreenMarkKeys[Key] = nil
    end
  end
  for Key, Loc in pairs(CurrentLocations) do
    if not self.FootprintScreenMarks[Key] and not self._FailedScreenMarkKeys[Key] then
      local InstID = InGameMarkTools.ClientAddMapMark(TypeID, Loc, 0, "", UEnums.EAddMarkFlag.EAMF_Screen)
      if InstID then
        print(bWriteLog and string.format("SpiderSenseFootprintFeature:OnFootprintScreenMarkSyncTick - Add ScreenMark Key:%s InstID:%s Loc:(%.1f,%.1f,%.1f)", Key, tostring(InstID), Loc.X, Loc.Y, Loc.Z))
        self.FootprintScreenMarks[Key] = InstID
      else
        self._FailedScreenMarkKeys[Key] = true
        print(bWriteLog and string.format("SpiderSenseFootprintFeature:OnFootprintScreenMarkSyncTick - Blacklist failed Key:%s", Key))
      end
    end
  end
end
function SpiderSenseFootprintFeature:ClearAimState()
  self:ClearFootprintHighlight()
  self:HideFootprintInfoUI()
  self:StopReactionEffect()
  self._CurrentAimedKey = nil
  self._LastReactionFootprintKey = nil
end
function SpiderSenseFootprintFeature:ClearAllFootprintScreenMarks()
  print(bWriteLog and "SpiderSenseFootprintFeature:ClearAllFootprintScreenMarks")
  if self.FootprintScreenMarks then
    for Key, InstID in pairs(self.FootprintScreenMarks) do
      InGameMarkTools.HideMapMark(InstID)
    end
  end
  self.FootprintScreenMarks = {}
  self.HiddenScreenMarkKeys = {}
  self.LastReactionEffectTime = {}
  self._LastReactionFootprintKey = nil
  self._FailedScreenMarkKeys = {}
end
function SpiderSenseFootprintFeature:HandleFootprintAimed(WorldLocation, CurrentTime)
  local Key = self:MakeLocationKey(WorldLocation)
  if self._CurrentAimedKey and self._CurrentAimedKey ~= Key then
    self:RestoreAimedFootprintScreenMark()
  end
  self._CurrentAimed  local InstID = self.FootprintScreenMarks[Key]
  if InstID and not self.HiddenScreenMarkKeys[Key] then
    print(bWriteLog and string.format("SpiderSenseFootprintFeature:HandleFootprintAimed - Hide ScreenMark Key:%s InstID:%s", Key, tostring(InstID)))
    InGameMarkTools.HideMapMark(InstID)
    self.HiddenScreenMarkKeys[Key] = true
  end
  if self._LastReactionFootprintKey == Key then
    return
  end
  self:TLogPlayerSafe(12326)
  local Cooldown = SpiderHeadsetConfig.FootprintReactionEffectCooldown or 1.5
  local LastTime = self.LastReactionEffectTime[Key] or -math.huge
  if Cooldown > CurrentTime - LastTime then
    return
  end
  self.LastReactionEffectTime[Key] = CurrentTime
  self._LastReactionFootprint  self:PlayReactionEffectAtLocation(WorldLocation)
end
function SpiderSenseFootprintFeature:TLogPlayerSafe(InID)
  if not Client or not InID then
    return
  end
  local uOwner = self.Owner and self.Owner.Object or nil
  if not (slua.isValid(uOwner) and uOwner.IsLocallyControlled) or not uOwner:IsLocallyControlled() then
    return
  end
  if not uOwner.GetPlayerStateSafety then
    return
  end
  local uPlayerState = uOwner:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) or not uPlayerState.RPC_ServerAddGeneralCount then
    return
  end
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:TLogPlayerSafe - InID:%s", tostring(InID)))
  uPlayerState:RPC_ServerAddGeneralCount(InID, 1, false)
end
function SpiderSenseFootprintFeature:RestoreAimedFootprintScreenMark()
  if not self._CurrentAimedKey then
    self._LastReactionFootprintKey = nil
    self:StopReactionEffect()
    return
  end
  local Key = self._CurrentAimedKey
  local InstID = self.FootprintScreenMarks[Key]
  if InstID and self.HiddenScreenMarkKeys[Key] then
    print(bWriteLog and string.format("SpiderSenseFootprintFeature:RestoreAimedFootprintScreenMark - Show ScreenMark Key:%s InstID:%s", Key, tostring(InstID)))
    InGameMarkTools.ShowMapMark(InstID)
  end
  self.HiddenScreenMarkKeys[Key] = nil
  self._CurrentAimedKey = nil
  self._LastReactionFootprintKey = nil
  self:StopReactionEffect()
end
function SpiderSenseFootprintFeature:PlayReactionEffectAtLocation(WorldLocation)
  if not Client then
    return
  end
  local EffectPath = SpiderHeadsetConfig.FootprintReactionEffectPath
  if not EffectPath or EffectPath == "" then
    return
  end
  local OwnerCharacter = self.Owner
  if not OwnerCharacter or not slua.isValid(OwnerCharacter.Mesh) then
    print(bWriteLog and "SpiderSenseFootprintFeature:PlayReactionEffectAtLocation - Owner or Mesh invalid")
    return
  end
  if not OwnerCharacter.IsLocallyControlled or not OwnerCharacter:IsLocallyControlled() and (not OwnerCharacter.IsLocalViewed or not OwnerCharacter:IsLocalViewed()) then
    print(bWriteLog and "SpiderSenseFootprintFeature:PlayReactionEffectAtLocation - Skip non-local non-viewed owner")
    return
  end
  local LogX, LogY, LogZ = 0, 0, 0
  if WorldLocation then
    LogX, LogY, LogZ = WorldLocation.X, WorldLocation.Y, WorldLocation.Z
  end
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:PlayReactionEffectAtLocation - AimedLoc:(%.1f,%.1f,%.1f) Path:%s", LogX, LogY, LogZ, EffectPath))
  local ReactionEffectAsset = asset_util.GetAssetSync(EffectPath)
  if not slua.isValid(ReactionEffectAsset) then
    print(bWriteLog and "SpiderSenseFootprintFeature:PlayReactionEffectAtLocation - Failed to load reaction effect asset")
    return
  end
  local AttachBone = SpiderHeadsetConfig.FootprintReactionEffectAttachBone or "head"
  local OffsetCfg = SpiderHeadsetConfig.FootprintReactionEffectAttachOffset or {
    X = 0,
    Y = 0,
    Z = 0
  }
  local RotationCfg = SpiderHeadsetConfig.FootprintReactionEffectAttachRotation or {
    Pitch = 0,
    Yaw = 0,
    Roll = 0
  }
  local ScaleCfg = SpiderHeadsetConfig.FootprintReactionEffectAttachScale or {
    X = 1,
    Y = 1,
    Z = 1
  }
  local AttachOffset = FVector(OffsetCfg.X or 0, OffsetCfg.Y or 0, OffsetCfg.Z or 0)
  local AttachRotation = FRotator(RotationCfg.Pitch or 0, RotationCfg.Yaw or 0, RotationCfg.Roll or 0)
  local AttachScale = FVector(ScaleCfg.X or 1, ScaleCfg.Y or 1, ScaleCfg.Z or 1)
  local AttachComponent = OwnerCharacter.Mesh
  local bBoneExists = false
  if AttachComponent.DoesSocketExist then
    bBoneExists = AttachComponent:DoesSocketExist(AttachBone)
  end
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:PlayReactionEffectAtLocation - AttachComp:%s BoneExists(%s):%s", tostring(AttachComponent or "nil"), tostring(AttachBone), tostring(bBoneExists)))
  local SpawnedEffect = UGameplayStatics_Cached.SpawnEmitterAttached(ReactionEffectAsset, AttachComponent, AttachBone, AttachOffset, AttachRotation, AttachScale, EAttachLocation.KeepRelativeOffset, true)
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:PlayReactionEffectAtLocation - Spawn done, Bone:%s Offset:(%.3f,%.3f,%.3f) ValidFX:%s", tostring(AttachBone), AttachOffset.X, AttachOffset.Y, AttachOffset.Z, tostring(slua.isValid(SpawnedEffect))))
  self:StopReactionEffect()
  if slua.isValid(SpawnedEffect) then
    self.ActiveReactionEffect = SpawnedEffect
  end
  local AudioPath = SpiderHeadsetConfig.FootprintReactionAudioPath
  if AudioPath and AudioPath ~= "" and WorldLocation then
    local AudioEvent = asset_util.GetAssetSync(AudioPath)
    if slua.isValid(AudioEvent) then
      local AkGameplayStatics = import("AkGameplayStatics")
      AkGameplayStatics.PostEventAtLocation(AudioEvent, WorldLocation, FRotator(0, 0, 0), "", OwnerCharacter)
      print(bWriteLog and string.format("SpiderSenseFootprintFeature:PlayReactionEffectAtLocation - Play audio path:%s", tostring(AudioPath)))
    else
      print(bWriteLog and "SpiderSenseFootprintFeature:PlayReactionEffectAtLocation - Failed to load reaction audio asset")
    end
  end
end
function SpiderSenseFootprintFeature:StopReactionEffect()
  local FX = self.ActiveReactionEffect
  self.ActiveReactionEffect = nil
  if not slua.isValid(FX) then
    return
  end
  print(bWriteLog and "SpiderSenseFootprintFeature:StopReactionEffect - Deactivate active reaction FX")
  if FX.DeactivateSystem then
    FX:DeactivateSystem()
  elseif FX.Deactivate then
    FX:Deactivate()
  end
end
function SpiderSenseFootprintFeature:FindClosestFootprintIndex(FootprintActor, WorldLocation)
  return FootprintActor:GetFootprintIndexAtLocation(WorldLocation)
end
function SpiderSenseFootprintFeature:ClearFootprintHighlight()
  print(bWriteLog and "SpiderSenseFootprintFeature:ClearFootprintHighlight")
  if slua.isValid(self.LastHighlightedActor) then
    self.LastHighlightedActor:ClearAllHighlights()
  end
  self.LastHighlightedActor = nil
end
function SpiderSenseFootprintFeature:ShowFootprintInfoUI(PlayerName, TimeAgo, WorldLocation)
  local PlayerNameStr = tostring(PlayerName)
  local bFirstShow = not self.bFootprintInfoVisible
  local bTargetChanged = self.LastShownPlayerName ~= PlayerNameStr
  if bFirstShow or bTargetChanged then
    local LocStr = "nil"
    if WorldLocation then
      LocStr = string.format("(%.1f, %.1f, %.1f)", WorldLocation.X, WorldLocation.Y, WorldLocation.Z)
    end
    print(bWriteLog and string.format("SpiderSenseFootprintFeature:ShowFootprintInfoUI - Player:%s TimeAgo:%.1f bWasVisible:%s WorldLoc:%s", PlayerNameStr, TimeAgo, tostring(self.bFootprintInfoVisible), LocStr))
  end
  self.bFootprintInfoVisible = true
  self.LastShownPlayerName = PlayerNameStr
  local TraceUIConfig = UIManager.UI_Config_InGame.SPSuit_TraceGuidance_UIBP
  if TraceUIConfig then
    local TraceUI = UIManager.ShowUI(TraceUIConfig, PlayerNameStr, TimeAgo, WorldLocation)
    TraceUI = TraceUI or UIManager.GetUI(TraceUIConfig)
    if TraceUI and TraceUI.UpdateInfo then
      local DisplayTimeAgo = TimeAgo or 0
      local bNameChanged = self._LastUIUpdatePlayerName ~= PlayerNameStr
      local bTimeChanged = math.abs((self._LastUIUpdateTimeAgo or -1) - DisplayTimeAgo) >= 0.1
      if bFirstShow or bNameChanged or bTimeChanged then
        self._LastUIUpdatePlayerName = PlayerNameStr
        self._LastUIUpdateTimeAgo = DisplayTimeAgo
        TraceUI:UpdateInfo(PlayerNameStr, TimeAgo, WorldLocation)
      elseif WorldLocation and TraceUI.SetFollowLocation then
        TraceUI:SetFollowLocation(WorldLocation)
      elseif WorldLocation then
        TraceUI.Follow      end
    end
  else
    print(bWriteLog and "SpiderSenseFootprintFeature:ShowFootprintInfoUI - UI_Config_InGame.SPSuit_TraceGuidance_UIBP not found")
  end
  self:LuaBroadcast("OnFootprintInfoChanged", true, PlayerNameStr, TimeAgo)
end
function SpiderSenseFootprintFeature:HideFootprintInfoUI()
  if not self.bFootprintInfoVisible then
    return
  end
  print(bWriteLog and string.format("SpiderSenseFootprintFeature:HideFootprintInfoUI - LastShownPlayer:%s", tostring(self.LastShownPlayerName)))
  self.bFootprintInfoVisible = false
  self.LastShownPlayerName = nil
  self._LastUIUpdatePlayerName = nil
  self._LastUIUpdateTimeAgo = -1
  local TraceUIConfig = UIManager.UI_Config_InGame.SPSuit_TraceGuidance_UIBP
  if TraceUIConfig then
    UIManager.HideUI(TraceUIConfig)
  end
  self:LuaBroadcast("OnFootprintInfoChanged", false, "", 0)
end
function SpiderSenseFootprintFeature:CloseFootprintInfoUI()
  self:HideFootprintInfoUI()
  local TraceUIConfig = UIManager.UI_Config_InGame.SPSuit_TraceGuidance_UIBP
  if TraceUIConfig then
    UIManager.CloseUI(TraceUIConfig)
  end
end
function SpiderSenseFootprintFeature:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "SpiderSenseFootprintFeature:ReceiveEndPlay")
  if not Client and EVENTTYPE_PLAYEREVENT_AVATAR ~= nil and EVENTID_PLAYEREVENT_AVATAR_LOGIC_EQUIPPED ~= nil then
    self:RemoveCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_PLAYEREVENT_AVATAR_LOGIC_EQUIPPED)
  end
  if Client then
    local uAvatarComp2 = self.Owner and self.Owner:getAvatarComponent2()
    if slua.isValid(uAvatarComp2) then
      self:RemoveControlEvent(uAvatarComp2, "OnAvatarEquipped")
    end
    local bShouldCleanupGlobal = self.Owner and self.Owner.IsLocallyControlled and not self.Owner:IsLocallyControlled() and self.Owner.IsLocalViewed and self.Owner:IsLocalViewed()
    if bShouldCleanupGlobal then
      self:SetSpiderSenseEnabled(false)
      self:CloseFootprintInfoUI()
    else
      print(bWriteLog and "SpiderSenseFootprintFeature:ReceiveEndPlay - Skip cleanup on non-local non-viewed owner")
    end
  end
  SpiderSenseFootprintFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CSpiderSenseFootprintFeature = class(CFeatureBase, nil, SpiderSenseFootprintFeature)
return CSpiderSenseFootprintFeature