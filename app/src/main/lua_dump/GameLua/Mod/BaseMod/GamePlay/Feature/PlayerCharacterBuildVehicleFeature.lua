local PlayerCharacterBuildVehicleFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
local FBattleItemAdditionalData = import("BattleItemAdditionalData")
local EBattleItemOperationType = import("EBattleItemOperationType")
local EBattleItemOperationFailedReason = import("EBattleItemOperationFailedReason")
local EItemStoreArea = import("EItemStoreArea")
local BackpackUtils = import("BackpackUtils")
local EPawnState = import("EPawnState")
local Config = require("GameLua.Mod.BaseMod.GamePlay.Config.BuildVehicleConfig")
local PICKUP_VEHICLE_DISTANCE_THRESHOLD = 1500
local CHECK_FOCUS_ACTOR_INTERVAL = 0.5
function PlayerCharacterBuildVehicleFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "nVehicleWeaponId",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    }
  }
end
function PlayerCharacterBuildVehicleFeature:ReceiveBeginPlay()
  PlayerCharacterBuildVehicleFeature.__super.ReceiveBeginPlay(self)
  self.AllowPawnStates = {
    [EPawnState.DriveVehicle] = true,
    [EPawnState.InVehicle] = true
  }
  print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:ReceiveBeginPlay"))
  local bIsPlanCHMode = GameStatus.IsCollectionHallMode()
  if bIsPlanCHMode then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:ReceiveBeginPlay In PlanCH GameMode, Return"))
    return
  end
  if self:HasAuthority() then
    self:BindLuaObjEvent(self.Owner, "EVENTID_INGAME_BUILD_SUCCESS", self._OnBuildSuccess, self)
    self:BindLuaObjEvent(self.Owner, "EVENTID_PAWN_PICK_UP_ITEM", self._OnPickupSuccess, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_CHANGE_ROLE_WEAR_DONE, self.OnPlayerChangeRolewearDone, self)
    self:AddControlEvent(self.Owner, "OnHandleSkillEndDelegate", self._OnSkillEnd, self)
  elseif self:IsAutonomousProxy() then
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_ENTER_FIGHTING_STATE, self.OnPlayerEnterFightingState, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_AIRCRAFT_VEHICLE_MESH_APPLIED, self.OnVehicleMeshApplied, self)
    self:InitTargetSkateStorageTimer()
  end
  log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:ReceiveBeginPlay. self.nVehicleWeaponId: " .. tostring(self.nVehicleWeaponId))
end
function PlayerCharacterBuildVehicleFeature:GetBPVehicleUser()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerCharacterBuildVehicleFeature:GetBPVehicleUser not slua.isValid(uPlayerController)")
    return
  end
  local BP_VehicleUser_C = import("/Game/BluePrints/Core/BP_VehicleUser.BP_VehicleUser_C")
  local BP_VehicleUser = uPlayerController:GetComponentByClass(BP_VehicleUser_C)
  return BP_VehicleUser
end
PlayerCharacterBuildVehicleFeature.ServerRPC.ServerRPC_TryAutoEnterVehicle = {
  Reliable = true,
  Params = {
    import("BioVehicleBase")
  }
}
function PlayerCharacterBuildVehicleFeature:ServerRPC_TryAutoEnterVehicle(VehicleActor)
  print(bWriteLog and "PlayerCharacterBuildVehicleFeature:ServerRPC_TryAutoEnterVehicle")
  if not self.Owner then
    print(bWriteLog and "PlayerCharacterBuildVehicleFeature:TryAutoEnterVehicle Fail not self.Owner")
    return
  end
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerCharacterBuildVehicleFeature:TryAutoEnterVehicle Fail not slua.isValid(uPlayerController)")
    return
  end
  local BP_VehicleUser_C = import("/Game/BluePrints/Core/BP_VehicleUser.BP_VehicleUser_C")
  local BP_VehicleUser = uPlayerController:GetComponentByClass(BP_VehicleUser_C)
  if not slua.isValid(BP_VehicleUser) then
    print(bWriteLog and "PlayerCharacterBuildVehicleFeature:ServerRPC_TryAutoEnterVehicle Fail not slua.isValid(BP_VehicleUser)")
    return
  end
  BP_VehicleUser:ForceEnterVehicle(VehicleActor, 0, 0)
end
function PlayerCharacterBuildVehicleFeature:CanVehicleAutoRide(VehicleActor)
  if not Client then
    return false
  end
  if not slua.isValid(VehicleActor) or not self.nVehicleWeaponId then
    return false
  end
  if not Game:IsBioVehicle(VehicleActor.Object) then
    return false
  end
  local VehicleAvatar = VehicleActor:GetAvatarComponent()
  if not slua.isValid(VehicleAvatar) then
    return false
  end
  local VehicleSkinID = VehicleAvatar:GetCurrentAvatarID()
  local Cfg = CDataTable.GetTableDataByFilter("BuildVehicleCfg", "VehicleSkinID", VehicleSkinID)
  if not Cfg then
    print(bWriteLog and "PlayerCharacterBuildVehicleFeature:CanVehicleAutoRide Not Aircraft Vehicle, VehicleSkinID:" .. tostring(VehicleSkinID))
    return false
  end
  if not Cfg.bAutoRide then
    return false
  end
  if not self.Owner or not self.Owner.GetPlayerKey then
    print(bWriteLog and "PlayerCharacterBuildVehicleFeature:CanVehicleAutoRide Failed to Get PlayerKey")
    return false
  end
  local SelfPlayerKey = self.Owner:GetPlayerKey()
  local VehiclePlayerKey = VehicleActor.SPlayerKey
  if VehiclePlayerKey ~= SelfPlayerKey or Cfg.AvatarID ~= self.nVehicleWeaponId then
    print(bWriteLog and "PlayerCharacterBuildVehicleFeature:CanVehicleAutoRide Vehicle is not mine")
    return false
  end
  return true
end
function PlayerCharacterBuildVehicleFeature:OnVehicleMeshApplied(_, _, VehicleActor)
  if not Client then
    return
  end
  if self.DisableStoreButtonTimer then
    self:RemoveGameTimer(self.DisableStoreButtonTimer)
    self.bDisableStoreButton = false
    self.DisableStoreButtonTimer = nil
  end
  if self:CanVehicleAutoRide(VehicleActor) then
    self.bDisableStoreButton = true
    self.DisableStoreButtonTimer = self:AddGameTimer(1, false, function()
      self.DisableStoreButtonTimer = nil
      self.bDisableStoreButton = false
    end)
    self:ServerRPC_TryAutoEnterVehicle(VehicleActor)
  end
end
function PlayerCharacterBuildVehicleFeature:_OnBuildSuccess(Owner, BuiltActor, _)
  log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:_OnBuildSuccess.  ")
  local nItemID = self:GetWeaponId()
  if self.Owner.PlayerKey ~= Owner.PlayerKey or nItemID == 0 then
    return
  end
  if self.vehicleID then
    log(bWriteLog and "PlayerCharacterBuildVehicleFeature: already. self.vehicleID: " .. tostring(self.vehicleID))
    return
  end
  self.vehicleID = nItemID
  log(bWriteLog and "PlayerCharacterBuildVehicleFeature:_OnBuildSuccess. self.vehicleID: " .. tostring(self.vehicleID))
  local BuildVehicleCfg = CDataTable.GetTableData("BuildVehicleCfg", nItemID)
  if BuildVehicleCfg and BuiltActor.DSStartPlay then
    self.nVehicleWeaponId = nItemID or 0
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnBuildSuccess, ItemID: %s", nItemID))
    self:_CacheVehicleAttrInfo(BuiltActor, nItemID)
    BuiltActor:DSStartPlay(nItemID)
  end
end
function PlayerCharacterBuildVehicleFeature:_CacheVehicleAttrInfo(BuildVehicle, nItemID)
  local uBackPackComponent = self:_GetBackPackComponent()
  if not slua.isValid(uBackPackComponent) then
    return
  end
  local ItemDatas = BackpackUtils.GetConsumablesInBackpack(uBackPackComponent)
  for _, ItemData in pairs(ItemDatas) do
    if ItemData.DefineID.TypeSpecificID == nItemID then
      print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_CacheVehicleAttrInfo, ItemID: %s", nItemID))
      BuildVehicle:CacheItemInfo(uBackPackComponent, ItemData)
    end
  end
end
function PlayerCharacterBuildVehicleFeature:CheckFocusAllowPawnState()
  if not Game:IsValid(self.Owner) or not self.AllowPawnStates then
    return false
  end
  for state, _ in pairs(self.AllowPawnStates) do
    if self.Owner:HasState(state) then
      return false
    end
  end
  for state, _ in pairs(self.AllowPawnStates) do
    if self.Owner:AllowState(state, true) then
      return true
    end
  end
  return false
end
function PlayerCharacterBuildVehicleFeature:CheckVehicleCanbePickup(uVehicle)
  if not slua.isValid(uVehicle) then
    return false
  end
  local uPickComponent = uVehicle.GetPickupComponent and uVehicle:GetPickupComponent()
  if not slua.isValid(uPickComponent) then
    log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:CheckVehicleCanbePickup.  no uPickComponent")
    return false
  end
  local VehicleAvatar = uVehicle:GetAvatarComponent()
  if not slua.isValid(VehicleAvatar) then
    return false
  end
  local VehicleSkinID = VehicleAvatar:GetCurrentAvatarID()
  local Cfg = CDataTable.GetTableDataByFilter("BuildVehicleCfg", "VehicleSkinID", VehicleSkinID)
  if Cfg and Cfg.bAutoStore and self.bDisableStoreButton then
    return false
  end
  local SPlayerKey = uVehicle.SPlayerKey
  local myPlayerKey = self.Owner:GetPlayerKey()
  if SPlayerKey ~= myPlayerKey then
    log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:CheckVehicleCanbePickup.  not my vehicle, return")
    return false
  end
  local bVisible = Game:IsTargetPosVisible(uVehicle:K2_GetActorLocation(), self.Owner:K2_GetActorLocation(), {
    self.Owner,
    uVehicle.Object
  })
  if not bVisible then
    print(bWriteLog and string.format("CheckVehicleCanbePickup: bVisible false, Cannot See Vehicle directly"))
    return false
  end
  if not uPickComponent:CanBePickedUp() then
    log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:CheckVehicleCanbePickup.  Can't BePickedUp")
    return false
  end
  return true
end
function PlayerCharacterBuildVehicleFeature:InitTargetSkateStorageTimer()
  if self.StorageTimer then
    self:RemoveGameTimer(self.StorageTimer)
    self.StorageTimer = nil
  end
  local UIBPFunctionLibrary = import("UIBPFunctionLibrary")
  self.FocusActorCheckParam = import("FocusActorCheckParam")()
  self.FocusActorCheckParam.SphereCheckRadius = Config.SphereCheckRadius
  self.FocusActorCheckParam.CheckDistance = Config.CheckDistance
  self.FocusActorCheckParam.CheckAngle = Config.CheckAngle
  self.FocusActorCheckParam.FanCheckObjectTypes = Config.FanCheckObjectTypes
  self.FocusActorCheckParam.bDebugShow = Config.bDebugShow
  self.FocusActorCheckParam.CheckActorNum = Config.CheckActorNum
  self.FocusActorCheckParam.CheckBlock = Config.CheckBlock
  for _, type in ipairs(Config.CheckObjectTypes) do
    slua.IndexReference(self.FocusActorCheckParam, "CheckObjectTypes"):Add(type)
  end
  log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:InitTargetSkateStorageTimer. : ")
  self.StorageTimer = self:AddGameTimer(CHECK_FOCUS_ACTOR_INTERVAL, true, function()
    if self.nVehicleWeaponId ~= 0 then
      local IsPhotoGrapherOpenState
      if not self.Owner.GetPlayerStateSafety then
        log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:InitTargetSkateStorageTimer.  no GetPlayerStateSafety, return")
        return
      end
      local PlayerState = self.Owner:GetPlayerStateSafety()
      if slua.isValid(PlayerState) and PlayerState.PhotoGrapherFeature then
        local PhotoGrapherFeature = PlayerState.PhotoGrapherFeature
        if PhotoGrapherFeature:IsPhotoGrapherOpenState() then
          IsPhotoGrapherOpenState = true
        end
      end
      local BuildVehicleCfg = CDataTable.GetTableData("BuildVehicleCfg", self.nVehicleWeaponId)
      if not BuildVehicleCfg then
        log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:InitTargetSkateStorageTimer.  not BuildVehicleCfg, return")
        return
      end
      local ValidActorClass = slua.loadClass(BuildVehicleCfg.VehiclePath)
      slua.IndexReference(self.FocusActorCheckParam, "ValidActorClass"):Add(ValidActorClass)
      local uController = self.Owner:GetPlayerControllerSafety()
      local bCanbePick = false
      if self:CheckFocusAllowPawnState() and slua.isValid(uController) then
        local FocusActor
        local uVehicleUser = uController:GetVehicleUserComp()
        if slua.isValid(uVehicleUser) then
          local uClosestVehicle = uVehicleUser:GetCurrentClosestVehicle()
          if Game:IsClassOf(uClosestVehicle, ValidActorClass) then
            FocusActor = uClosestVehicle
          end
        end
        if not slua.isValid(FocusActor) and slua.isValid(UIBPFunctionLibrary) then
          local FocusActorArray = UIBPFunctionLibrary.GetFocusActor(uController, self.FocusActorCheckParam)
          if 0 < FocusActorArray:Num() then
            FocusActor = FocusActorArray:Get(0)
          end
        end
        if slua.isValid(FocusActor) then
          bCanbePick = self:CheckVehicleCanbePickup(FocusActor)
          if bCanbePick and self.TargetStoreVehicle ~= FocusActor and not IsPhotoGrapherOpenState then
            self:HanldeOnSkateStorage(true, FocusActor)
          end
        end
      end
      if not bCanbePick and self.TargetStoreVehicle or IsPhotoGrapherOpenState then
        self:HanldeOnSkateStorage(false, nil)
      end
    end
  end)
end
function PlayerCharacterBuildVehicleFeature:HanldeOnSkateStorage(bShow, uVehicle)
  print(bWriteLog and string.format("PlayerCharacterBuildBlanketFeaturee bShow:%s, uVehicle:%s", bShow, tostring(uVehicle)))
  if slua.isValid(self.TargetStoreVehicle) then
    self.TargetStoreVehicle:OnVehicleBeFocused(false)
  end
  if bShow then
    self.TargetStoreVehicle = uVehicle
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN, "Type_StoreSkate")
    uVehicle:OnVehicleBeFocused(true)
  else
    self.TargetStoreVehicle = nil
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_StoreSkate")
  end
end
function PlayerCharacterBuildVehicleFeature:TryPickupVehicle()
  if not slua.isValid(self.TargetStoreVehicle) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature: TryPickupVehicle no Vehicle"))
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_StoreSkate")
    return
  end
  self:RPC_PickupVehicle(self.TargetStoreVehicle, false)
end
function PlayerCharacterBuildVehicleFeature:TryPickupTargetVehicle(uVehicle)
  if not slua.isValid(uVehicle) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature: TryPickupTargetVehicle no Vehicle"))
    return
  end
  self:RPC_PickupVehicle(uVehicle, true)
end
PlayerCharacterBuildVehicleFeature.ServerRPC.RPC_PickupVehicle = {
  Reliable = true,
  Params = {
    import("BioVehicleBase"),
    UEnums.EPropertyClass.Bool
  }
}
PlayerCharacterBuildVehicleFeature.ClientRPC.RPC_ShowTips = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PlayerCharacterBuildVehicleFeature.ClientRPC.Client_HideStore = {
  Reliable = true,
  Params = {}
}
function PlayerCharacterBuildVehicleFeature:RPC_PickupVehicle(Vehicle, bAutoPick)
  if not self:_CanPickupVehicle(Vehicle) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:RPC_PickupVehicle NOT _CanPickupVehicle, return"))
    return
  end
  local nItemID = self.nVehicleWeaponId
  if nItemID == 0 then
    log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:RPC_PickupVehicle.  nItemID == 0, return")
    return
  end
  if not self:_CanPickupIntoBackPack(nItemID) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:RPC_PickupVehicle NOT _CanPickupIntoBackPack, return"))
    return
  end
  if slua.isValid(Vehicle) then
    Vehicle:ForceExitCharacters(true)
  end
  print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:RPC_PickupVehicle %s", Vehicle))
  self.CachePickup  self.CacheAutoPick = bAutoPick
  self.Owner:TriggerEntrySkillWithID(Config.StorageSkillId, true)
end
function PlayerCharacterBuildVehicleFeature:RPC_ShowTips(id)
  ShowNotice(id)
end
function PlayerCharacterBuildVehicleFeature:Client_HideStore()
  log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:Client_HideStore.  ")
  EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_StoreSkate")
end
function PlayerCharacterBuildVehicleFeature:GetWeaponId()
  local pawn = self.Owner
  local weapon = pawn:GetCurrentWeapon()
  local weaponId
  if weapon then
    local DefineID = weapon:GetItemDefineID()
    if DefineID then
      weaponId = DefineID.TypeSpecificID
    end
  end
  return weaponId
end
function PlayerCharacterBuildVehicleFeature:_CanPickupVehicle(Vehicle)
  if not Vehicle or not slua.isValid(Vehicle) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_IsVehicleValid Vehicle is not valid"))
    return false
  end
  local player = self.Owner
  local distance = player:GetDistanceTo(Vehicle)
  if distance > PICKUP_VEHICLE_DISTANCE_THRESHOLD then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_IsVehicleValid Vehicle is too far"))
    return false
  end
  local SPlayerKey = Vehicle.SPlayerKey
  if SPlayerKey ~= player:GetPlayerKey() then
    log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:_CanPickupVehicle.  not my vehicle, return")
    return false
  end
  local bVisible = Game:IsTargetPosVisible(Vehicle:K2_GetActorLocation(), player:K2_GetActorLocation(), {
    player,
    Vehicle.Object
  })
  if not bVisible then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_IsVehicleValid, Cannot See Vehicle directly"))
    return false
  end
  local VehiclePickableComp = Vehicle:GetPickupComponent()
  if not slua.isValid(VehiclePickableComp) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_IsVehicleValid VehiclePickableComp is not valid"))
    return false
  end
  if not VehiclePickableComp:CanBePickedUp() then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_IsVehicleValid not CanBePickedUp"))
    return false
  end
  return true
end
function PlayerCharacterBuildVehicleFeature:_CanPickupIntoBackPack(nItemID)
  local uBackPackComponent = self:_GetBackPackComponent()
  if not slua.isValid(uBackPackComponent) then
    return false
  end
  if nItemID == nil then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_CanPickupIntoBackPack nItemID is not valid"))
    return false
  end
  local PickupInfoCount = 1
  local DefineID = FItemDefineID(0, nItemID)
  local LeftPickupLimitCount = uBackPackComponent:CheckLeftLimitCountForItem(nItemID, PickupInfoCount)
  if LeftPickupLimitCount == 0 then
    uBackPackComponent:BroadcastItemOperationFailedDelegate(DefineID, EBattleItemOperationType.Pickup, EBattleItemOperationFailedReason.PickupFailed_PickupLimitExceeded)
    return false
  end
  local CapacityCount = uBackPackComponent:CheckCapacityForItem(DefineID, PickupInfoCount, EItemStoreArea.InBag)
  local SpecialCount = uBackPackComponent:CheckSpecialMaxCountForItem(DefineID, PickupInfoCount)
  local CapacityLimitedPickupCount = math.min(CapacityCount, LeftPickupLimitCount)
  local SpecialLimitedPickupCount = SpecialCount
  if 0 < CapacityLimitedPickupCount and SpecialLimitedPickupCount == 0 then
    uBackPackComponent:BroadcastItemOperationFailedDelegate(DefineID, EBattleItemOperationType.Pickup, EBattleItemOperationFailedReason.PickupFailed_ItemCountExceeded)
    return false
  end
  local ExpectedPickupCount = math.min(CapacityLimitedPickupCount, SpecialLimitedPickupCount)
  if ExpectedPickupCount == 0 then
    uBackPackComponent:BroadcastItemOperationFailedDelegate(DefineID, EBattleItemOperationType.Pickup, EBattleItemOperationFailedReason.PickupFailed_CapacityExceeded)
    return false
  end
  return true
end
function PlayerCharacterBuildVehicleFeature:_OnSkillEnd(_, StopReason, SkillId)
  local nItemID
  if SkillId == Config.StorageSkillId then
    nItemID = self.nVehicleWeaponId
  end
  if not nItemID or nItemID == 0 then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnSkillEnd StopReason=%d, SkillID=%d", StopReason, SkillId))
  local Vehicle = self.CachePickupVehicle
  if not slua.isValid(Vehicle) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnSkillEnd Vehicle is not valid, return"))
    return
  end
  if not self:_CanPickupVehicle(Vehicle) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnSkillEnd NOT _CanPickupVehicle, return"))
    return
  end
  if not self:_CanPickupIntoBackPack(nItemID) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnSkillEnd NOT _CanPickupIntoBackPack, return"))
    return
  end
  local VehiclePickupWrapper = self:_GetPickupWrapper(Vehicle)
  if not slua.isValid(VehiclePickupWrapper) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnSkillEnd VehiclePickupWrapper is not valid, return"))
    return
  end
  self.LastPickupWrapperLocation = VehiclePickupWrapper:K2_GetActorLocation()
  self.Cache  local player = self.Owner
  VehiclePickupWrapper:K2_SetActorLocation(player:K2_GetActorLocation(), false, nil, false)
  self:_RecordVehicleAttr(Vehicle, VehiclePickupWrapper)
  if self.CacheAutoPick then
    player:SetAllowPawnState(EPawnState.Pick, true)
  end
  VehiclePickupWrapper.bCanBePickUpOnDS = true
  player:PickUpActor(VehiclePickupWrapper, 0, 0, 0)
end
function PlayerCharacterBuildVehicleFeature:_OnPickupSuccess(uCharacter, InVehiclePickupWrapper)
  log(bWriteLog and "PlayerCharacterBuildVehicleFeature:_OnPickupSuccess.  ")
  if uCharacter.PlayerKey ~= self.Owner.PlayerKey or self.CacheVehiclePickupWrapper ~= InVehiclePickupWrapper then
    return
  end
  self:ClearVehicleInfo()
  if self.CacheAutoPick then
    self.Owner:SetAllowPawnState(EPawnState.Pick, false)
  end
  local uBackPackComponent = self:_GetBackPackComponent()
  if not slua.isValid(uBackPackComponent) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnPickupSuccess uBackPackComponent is not valid, return"))
    return
  end
  local Vehicle = self.CachePickupVehicle
  if not slua.isValid(Vehicle) then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnPickupSuccess Vehicle is not valid, return"))
    return
  end
  log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:_OnPickupSuccess. nWeaponID: " .. tostring(Vehicle.nWeaponID))
  local nItemID = Vehicle.nWeaponID
  if uBackPackComponent:GetItemCountByItemSpecialID(nItemID) > 0 then
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnPickupSuccess uCharacter = %s", uCharacter))
    Vehicle:DestroyByStorage()
    Vehicle:Broadcast_RecoverSkate(uCharacter)
  else
    print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnPickupSuccess PickUpActor failed"))
    if slua.isValid(self.CacheVehiclePickupWrapper) then
      self.CacheVehiclePickupWrapper:K2_SetActorLocation(self.LastPickupWrapperLocation, false, nil, false)
    end
  end
  self:CheckConsumable()
  self:Client_HideStore()
  self.nVehicleWeaponId = 0
  self.CachePickupVehicle = nil
  self.CacheVehiclePickupWrapper = nil
end
function PlayerCharacterBuildVehicleFeature:ClearVehicleInfo()
  log(bWriteLog and "PlayerCharacterBuildVehicleFeature:ClearVehicleInfo.  ")
  self.vehicleID = nil
end
function PlayerCharacterBuildVehicleFeature:_GetPickupWrapper(Vehicle)
  local VehiclePickableComp = Vehicle:GetPickupComponent()
  if not slua.isValid(VehiclePickableComp) then
    return
  end
  return VehiclePickableComp.PickupVehicle
end
function PlayerCharacterBuildVehicleFeature:_RecordVehicleAttr(Vehicle, VehiclePickupWrapper)
  local VehicleCommon = Vehicle:GetVehicleCommon()
  if not slua.isValid(VehicleCommon) or not slua.isValid(VehiclePickupWrapper) then
    print(bWriteLog and string.format("_RecordVehicleHP:_OnSkillEnd VehicleCommon or VehiclePickupWrapper is not valid, return"))
    return
  end
  local HP = VehicleCommon:GetVehicleHP()
  local HPMax = VehicleCommon:GetVehicleHPMax()
  local HPRatio = HP / HPMax
  local HPItemAddtionalData = FBattleItemAdditionalData()
  HPItemAddtionalData.EDataType = EBattleItemAdditionalDataType.RemainingDuability
  HPItemAddtionalData.FloatData = HPRatio
  VehiclePickupWrapper.SavedAdditionalDataList:Add(HPItemAddtionalData)
  local Fuel = VehicleCommon:GetFuel()
  local FuelMax = VehicleCommon:GetFuelMax()
  local FuelRatio = Fuel / FuelMax
  local FuelItemAddtionalData = FBattleItemAdditionalData()
  FuelItemAddtionalData.EDataType = EBattleItemAdditionalDataType.VehicleFuelRatio
  FuelItemAddtionalData.FloatData = FuelRatio
  VehiclePickupWrapper.SavedAdditionalDataList:Add(FuelItemAddtionalData)
  print(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:_OnSkillEnd HP = %s / %s = %s, Fuel = %s / %s = %s", HP, HPMax, HPRatio, Fuel, FuelMax, FuelRatio))
end
function PlayerCharacterBuildVehicleFeature:_GetBackPackComponent()
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uBackPackComponent = uPlayerController:GetBackpackComponent()
  return uBackPackComponent
end
function PlayerCharacterBuildVehicleFeature:OnPlayerChangeRolewearDone(_, _, obj)
  if self.nVehicleWeaponId and self.nVehicleWeaponId ~= 0 then
    local uController = self.Owner and self.Owner:GetPlayerControllerSafety()
    if obj and uController == obj then
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local uGameState = GameplayData.GetGameState()
      local CurGameState = uGameState:GetGameModeState()
      if CurGameState ~= "ReadyState" and uGameState.GameModeType ~= 18 then
        return
      end
      local uPlayerController = self.Owner:GetPlayerControllerSafety()
      if not slua.isValid(uPlayerController) then
        return
      end
      local Consumable = uPlayerController:SGetConsumableByXsuitAndGlider()
      if Consumable then
        self:RPC_ShowTips(792618)
      end
    end
    return
  end
  self:CheckConsumable()
end
function PlayerCharacterBuildVehicleFeature:OnPlayerEnterFightingState()
  log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:OnPlayerEnterFightingState.  ")
  self:HanldeOnSkateStorage(false, nil)
end
function PlayerCharacterBuildVehicleFeature:FindBackpackVehicleConsumables()
  if not self.Owner then
    log(bWriteLog and "PlayerCharacterBuildVehicleFeature:FindBackpackVehicleConsumables.  Owner is not valid")
    return
  end
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "PlayerCharacterBuildVehicleFeature:FindBackpackVehicleConsumables.  uPlayerController is not valid")
    return
  end
  local BackpackComponent = uPlayerController.BackpackComponent
  local Consumables = slua.Array(UEnums.EPropertyClass.Int)
  for _, v in pairs(CDataTable.GetTable("VehicleUseConfig")) do
    Consumables:Add(v.Consumable)
  end
  local character = self.Owner
  local weaponManager = character:GetWeaponManager()
  local weapon = weaponManager and weaponManager:GetCurrentUsingWeapon()
  if weapon then
    local isHold
    local DefineID = weapon:GetItemDefineID().TypeSpecificID
    for _, v in pairs(CDataTable.GetTable("VehicleUseConfig")) do
      if v.Consumable == DefineID then
        isHold = true
        break
      end
    end
    if isHold then
      local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
      log(bWriteLog and "PlayerCharacterBuildVehicleFeature:FindBackpackVehicleConsumables.  switch")
      character:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, true, true)
    end
  end
  local BattleItemDataArray = BackpackComponent:GetItemListBySpecialID(Consumables, true, EItemStoreArea.InBag)
  return BattleItemDataArray
end
function PlayerCharacterBuildVehicleFeature:CheckConsumable()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  local CurGameState = uGameState:GetGameModeState()
  if CurGameState ~= "ReadyState" and uGameState.GameModeType ~= 18 then
    log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:OnPlayerChangeRolewearDone. CurGameState: " .. tostring(CurGameState))
    return
  end
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:OnPlayerChangeRolewearDone.  uPlayerController is not valid")
    return
  end
  local nVehicleWeaponId = self.nVehicleWeaponId
  log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:CheckConsumable. nVehicleWeaponId: " .. tostring(nVehicleWeaponId))
  local Consumable = uPlayerController:SGetConsumableByXsuitAndGlider()
  if Consumable == nVehicleWeaponId then
    return
  end
  local EBattleItemDropReason = import("EBattleItemDropReason")
  local BattleItemDataArray = self:FindBackpackVehicleConsumables()
  for _, FBattleItemData in pairs(BattleItemDataArray) do
    log(bWriteLog and "  PlayerCharacterBuildVehicleFeature:CheckConsumable. v.DefineID.TypeSpecificID: " .. tostring(FBattleItemData.DefineID.TypeSpecificID))
    uPlayerController:ServerDropItem(FBattleItemData.DefineID, 1, EBattleItemDropReason.Force)
  end
  if Consumable then
    Game:AddItemByResID(self.Owner.Object, Consumable, 1, false)
    self:ClientRPC_UpdateMaxBuildDistance(Consumable)
    self:UpdateMaxBuildDistLocally(Consumable)
  end
end
PlayerCharacterBuildVehicleFeature.ServerRPC.ServerRPC_UpdateMaxBuildDistance = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerCharacterBuildVehicleFeature:ServerRPC_UpdateMaxBuildDistance(ConsumableID)
  self:UpdateMaxBuildDistLocally(ConsumableID)
end
PlayerCharacterBuildVehicleFeature.ClientRPC.ClientRPC_UpdateMaxBuildDistance = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerCharacterBuildVehicleFeature:ClientRPC_UpdateMaxBuildDistance(ConsumableID)
  self:UpdateMaxBuildDistLocally(ConsumableID)
end
function PlayerCharacterBuildVehicleFeature:UpdateMaxBuildDistLocally(ConsumableID)
  if not self.Owner then
    return
  end
  local BuildSystemComp = self.Owner:GetOrCreateBuildSystemComponent()
  if not slua.isValid(BuildSystemComp) then
    log(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:UpdateMaxBuildDistLocally Failed to get BuildSystemComp"))
    return
  end
  local BuildVehicleCfg = CDataTable.GetTableData("BuildVehicleCfg", ConsumableID)
  local NewDist = 1500
  if BuildVehicleCfg and BuildVehicleCfg.OverwriteMaxBuildDist and BuildVehicleCfg.OverwriteMaxBuildDist ~= 0 then
    NewDist = BuildVehicleCfg.OverwriteMaxBuildDist
  end
  BuildSystemComp:OverrideBuildingMaxBuildDistance(NewDist, false, Config.BuildingId)
  log(bWriteLog and string.format("PlayerCharacterBuildVehicleFeature:UpdateMaxBuildDistLocally OverrideBuildingMaxBuildDistance %d", NewDist))
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPlayerCharacterBuildVehicleFeature = class(CFeatureBase, nil, PlayerCharacterBuildVehicleFeature)
return require("combine_class").SetFeatureDynamic(CPlayerCharacterBuildVehicleFeature)