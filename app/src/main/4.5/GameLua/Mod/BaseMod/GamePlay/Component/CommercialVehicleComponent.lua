local CommercialVehicleComponent = {}
local EFollowState = import("EFollowState")
local EParachuteState = import("EParachuteState")
local EMovementMode = import("EMovementMode")
local ECollisionChannel = import("ECollisionChannel")
local ECollisionResponse = import("ECollisionResponse")
local ESTExtraVehicleType = import("ESTExtraVehicleType")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local VehicleParachuteAnimBpPath = "/Game/Arts_Player/Characters/Animation/Base_AnimBP/Feature/ABP_VehicleParachute.ABP_VehicleParachute_C"
function CommercialVehicleComponent:ctor(SelfType)
  self.VehicleAvatarID = 0
  self.IsTrustClientFastLand = false
end
function CommercialVehicleComponent:ReceiveBeginPlay()
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  self.Super:ReceiveBeginPlay()
  self:AddControlEvent(Owner, "OnFakeOnVehicleDelegate", self.OnFakeOnVehicle, self)
  self:AddControlEvent(Owner, "OnParachuteStateChanged", self.HandleOnParachuteStateChanged, self)
  self:AddControlEvent(Owner, "OnFroceExitParachutingVehicle", self.HandleOnFroceExitParachutingVehicle, self)
  self:AddControlEvent(Owner, "OnFollowStateChanged", self.HandleOnFollowStateChanged, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_CHANGE_ITEM_AVATAR_END, self.HandleOnChangeVehicleAvatarEnd, self)
  self:AddControlEvent(Owner, "OnDeathDelegate", self.HandleCharacterDie, self)
  local PlayerController = Owner:GetPlayerControllerSafety()
  if slua.isValid(PlayerController) then
    self:AddControlEvent(PlayerController, "OnPlayerEnterFlying", self.PreCreateVehicle, self)
  end
end
function CommercialVehicleComponent:HandleCharacterDie()
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  local CurrentVehicle = self:GetCurrentVehicle()
  if slua.isValid(CurrentVehicle) then
    self:TryExitParachutingVehicle()
    CurrentVehicle:K2_DestroyActor()
  end
  Owner.IsFakeOnVehicle = false
  Owner:ForceNetUpdate()
  self:AddTimer(1, function()
    if slua.isValid(self.Object) and slua.isValid(Owner) then
      print(bWriteLog and "CommercialVehicleComponent:HandleCharacterDie, destroy self success")
      self:K2_DestroyComponent(Owner)
    end
  end)
end
function CommercialVehicleComponent:ReceiveEndPlay(EndPlayReason)
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  local RootComponent = Owner:K2_GetRootComponent()
  if slua.isValid(RootComponent) and RootComponent.SetCollisionResponseToChannel then
    RootComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, ECollisionResponse.ECR_Block)
  end
  self:Dispose()
  self.Super:ReceiveEndPlay(EndPlayReason)
end
function CommercialVehicleComponent:ScriptEnterVehicle()
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  self:TryEnterVehicle()
  if Owner.FollowState == EFollowState.Leader then
    for _, Follower in Owner.FlyingTeam:Pairs() do
      if slua.isValid(Follower) and Follower ~= Owner then
        local FollowerThisComp = self:GetCharacterCurrentComponent(Follower)
        if slua.isValid(FollowerThisComp) then
          if slua.isValid(Follower.TwoPersonAircraftLeader) then
            FollowerThisComp:TryEnterLeaderVehicle(Follower.TwoPersonAircraftLeader)
          else
            FollowerThisComp:TryEnterLeaderVehicle()
          end
        end
      end
    end
  end
end
function CommercialVehicleComponent:PreCreateVehicle()
  if not slua.isValid(self.Object) then
    return
  end
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) or not Owner:HasAuthority() then
    return
  end
  self:TryCreateVehicle()
  if slua.isValid(self.InActiveVehicle) then
    self.InActiveVehicle:SetOwner(Owner)
  end
end
function CommercialVehicleComponent:TryCreateVehicle()
  local CurrentVehicle = self:GetCurrentVehicle()
  local VehicleInfo = self:GetParachutingVehicleInfo()
  if not slua.isValid(CurrentVehicle) and VehicleInfo and next(VehicleInfo) then
    self:CreateVehicle(VehicleInfo)
  end
end
function CommercialVehicleComponent:IsTwoPersonAircraftVehicle(VehicleID)
  local Table = CDataTable.GetTableData("TwoPersonAircraftConfig", VehicleID)
  if Table then
    return true
  else
    return false
  end
end
function CommercialVehicleComponent:HandleOnParachuteStateChanged(LastParachuteState, NewParachuteState)
  if not slua.isValid(self.Object) then
    return
  end
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  if Owner.IgnoreGliderOneTime == true then
    print(bWriteLog and "CommercialVehicleComponent:HandleOnParachuteStateChanged, IgnoreGliderOneTime = true, PlayerKey = " .. tostring(Owner.PlayerKey))
    return
  end
  if Owner.IsLandedWithClientPos and Owner:IsLandedWithClientPos() and NewParachuteState == EParachuteState.PS_None and LastParachuteState == EParachuteState.PS_FreeFall then
    print(bWriteLog and "CommercialVehicleComponent:HandleOnParachuteStateChanged EParachuteState.PS_FreeFall -> EParachuteState.PS_None", LastParachuteState, NewParachuteState, Owner)
    self.IsTrustClientFastLand = true
  end
  print(bWriteLog and "CommercialVehicleComponent:HandleOnParachuteStateChanged", LastParachuteState, NewParachuteState, Owner:GetPlayerNameSafety())
  if Owner:HasAuthority() then
    if NewParachuteState == EParachuteState.PS_FreeFall then
      self:TryCreateVehicle()
      if self:IsInTwoAircraftTeam() then
        self:AircraftTryEnterVehicle()
      else
        self:TryEnterVehicle()
        self:TryEnterLeaderVehicle()
      end
      local CurrentVehicle = self:GetCurrentVehicle()
      if slua.isValid(CurrentVehicle) then
        self:EnableParachutingPetState(false)
      end
    else
      local CurrentVehicle = self:GetCurrentVehicle()
      if slua.isValid(CurrentVehicle) then
        self:TryExitParachutingVehicle()
        CurrentVehicle:K2_DestroyActor()
      end
      Owner.IsFakeOnVehicle = false
      self:EnableParachutingPetState(true)
      Owner:ForceNetUpdate()
      self:AddTimer(1, function()
        if slua.isValid(self.Object) and slua.isValid(Owner) then
          print(bWriteLog and "CommercialVehicleComponent:HandleOnParachuteStateChanged, destroy self success")
          self:K2_DestroyComponent(Owner)
        end
      end)
    end
  elseif NewParachuteState == EParachuteState.PS_FreeFall and slua.isValid(self.ActiveVehicle) then
    self.ActiveVehicle.RootComponent:SetVisibility(true, false)
    if self.ActiveVehicle.BP_Parachute_VehicleLicensePlateComponent then
      self.ActiveVehicle.BP_Parachute_VehicleLicensePlateComponent:SetPlateMeshVisible(true)
    end
    print(bWriteLog and "CommercialVehicleComponent:HandleOnParachuteStateChanged, ParachutingVehicle is visible", tostring(self.ActiveVehicle))
  elseif LastParachuteState == EParachuteState.PS_FreeFall and NewParachuteState ~= EParachuteState.PS_FreeFall then
    local CurrentVehicle = self:GetCurrentVehicle()
    if slua.isValid(CurrentVehicle) then
      CurrentVehicle:K2_DestroyActor()
    end
  end
end
function CommercialVehicleComponent:IsInTwoAircraftTeam()
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return false
  end
  if Game:IsValid(Owner.TwoPersonAircraftLeader) then
    return true
  end
  for _, _Follower in pairs(Owner.FollowingAircraftTeam) do
    if Game:IsValid(_Follower) then
      return true
    end
  end
  return false
end
function CommercialVehicleComponent:AircraftTeamHasLeader()
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return false
  end
  if Owner.FollowState == EFollowState.Leader then
    return true
  end
  if Game:IsValid(Owner.TwoPersonAircraftLeader) and Owner.TwoPersonAircraftLeader.FollowState == EFollowState.Leader then
    return true
  end
  for _, _Follower in pairs(Owner.FollowingAircraftTeam) do
    if Game:IsValid(_Follower) and _Follower.FollowState == EFollowState.Leader then
      return true
    end
  end
  return false
end
function CommercialVehicleComponent:HandleOnFroceExitParachutingVehicle()
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  print(bWriteLog and "CommercialVehicleComponent:HandleOnFroceExitParachutingVehicle" .. Owner:GetPlayerNameSafety())
  if Owner:HasAuthority() then
    local CurrentVehicle = self:GetCurrentVehicle()
    if slua.isValid(CurrentVehicle) then
      self:TryExitParachutingVehicle()
      CurrentVehicle:K2_DestroyActor()
    end
    Owner.IsFakeOnVehicle = false
    self:EnableParachutingPetState(true)
    Owner:ForceNetUpdate()
    self:AddTimer(1, function()
      if slua.isValid(self.Object) and slua.isValid(Owner) then
        print(bWriteLog and "CommercialVehicleComponent:HandleOnFroceExitParachutingVehicle, destroy self success")
        self:K2_DestroyComponent(Owner)
      end
    end)
  else
    local CurrentVehicle = self:GetCurrentVehicle()
    if slua.isValid(CurrentVehicle) then
      CurrentVehicle:K2_DestroyActor()
    end
  end
end
function CommercialVehicleComponent:EnableParachutingPetState(bEnable)
  local EPetState = import("EPetState")
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) or not Owner:HasAuthority() then
    return
  end
  if slua.isValid(Owner.PetComponent_BP) then
    if bEnable then
      Owner.PetComponent_BP:PetLeaveState(EPetState.PetDisappear)
    else
      Owner.PetComponent_BP:PetEnterState(EPetState.PetDisappear)
    end
  end
end
function CommercialVehicleComponent:CreateVehicle(VehicleInfo)
  local Owner = self:GetOwner()
  print(bWriteLog and "CommercialVehicleComponent:CreateVehicle", Owner, VehicleInfo)
  if not slua.isValid(self.InActiveVehicle) and VehicleInfo and next(VehicleInfo) then
    local Info = VehicleInfo[1]
    local VehicleClass = slua.loadClass(Info[1])
    local UGameplayStatics = import("GameplayStatics")
    local SpawnTransform = FTransform()
    local NewVehicle = UGameplayStatics.BeginDeferredActorSpawnFromClass(self, VehicleClass, SpawnTransform, UEnums.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    if slua.isValid(NewVehicle) then
      UGameplayStatics.FinishSpawningActor(NewVehicle, SpawnTransform)
      local UVehicleSeatComponentClass = import("VehicleSeatComponent")
      local VehicleSeatComp = NewVehicle:GetComponentByClass(UVehicleSeatComponentClass)
      if not slua.isValid(VehicleSeatComp) then
        NewVehicle:K2_DestroyActor()
        return
      end
      self:InitInActiveVehicle(NewVehicle)
      NewVehicle:InitOccupiedSeat(VehicleSeatComp.Seats:Num())
      local UVehicleAvatarComponentClass = import("VehicleAvatarComponent")
      local VehicleAvatarComp = NewVehicle:GetComponentByClass(UVehicleAvatarComponentClass)
      if slua.isValid(VehicleAvatarComp) then
        local Controller = Owner and Owner.GetPlayerControllerSafety and Owner:GetPlayerControllerSafety()
        if slua.isValid(Controller) then
          VehicleAvatarComp:SetVehicleNetAvatarData(Controller)
        end
        VehicleAvatarComp:ChangeItemAvatar(Info[2], false)
        if VehicleAvatarComp.SetNetMultiSlotData then
          print(bWriteLog and "CommercialVehicleComponent:CreateVehicle VehicleAvatarComponent SetNetMultiSlotData wheelHub: " .. tostring(Info[3] and Info[3][1]))
          VehicleAvatarComp:SetNetMultiSlotData(Info[3] or {})
        end
        VehicleAvatarComp.CanChangeAvatar = false
      end
      local ComponentCls = import("VehicleAvatarComponentBattleBase")
      local VehicleAvatar = NewVehicle:GetComponentByClass(ComponentCls)
      if slua.isValid(VehicleAvatar) then
        VehicleAvatar:ChangeVehicleAvatar(Info[2], false)
        if VehicleAvatar.SetNetMultiSlotData then
          print(bWriteLog and "CommercialVehicleComponent:CreateVehicle VehicleAvatarComponentBattleBase SetNetMultiSlotData wheelHub: " .. tostring(Info[3] and Info[3][1]))
          VehicleAvatar:SetNetMultiSlotData(Info[3] or {})
        end
        local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
        local bEnableTireLight = VehiclePlateLicenseUtil.NeedOpenHighTire(tonumber(Owner.PlayerUID), Info[2])
        VehicleAvatar:PreChangeHighTireLight(Info[2], bEnableTireLight)
        print(bWriteLog and "CommercialVehicleComponent:CreateVehicle ItemID:" .. tostring(Info[2]) .. " bEnableTireLight:" .. tostring(bEnableTireLight))
      end
      local VehicleLicenseNumberComponentCls = import("VehicleLicenseNumberComponent")
      local BP_Parachute_VehicleLicensePlateComponent = NewVehicle:GetComponentByClass(VehicleLicenseNumberComponentCls)
      if slua.isValid(BP_Parachute_VehicleLicensePlateComponent) then
        BP_Parachute_VehicleLicensePlateComponent:CreateLicense(Info[2], Owner)
      end
    end
  end
end
function CommercialVehicleComponent:GetParachutingVehicleInfo()
  local Owner = self:GetOwner()
  local PlayerController = Owner:GetPlayerControllerSafety()
  if slua.isValid(PlayerController) and PlayerController.GetParachutingVehicleInfo then
    return PlayerController:GetParachutingVehicleInfo()
  end
  return nil
end
function CommercialVehicleComponent:TryEnterLeaderVehicle(CustomLeader)
  local Owner = self:GetOwner()
  if Owner.ParachuteState ~= EParachuteState.PS_FreeFall then
    print(bWriteLog and "CommercialVehicleComponent:TryEnterLeaderVehicle failed, parachute state is not <PS_FreeFall>")
    return
  end
  if Owner.FollowState == EFollowState.Follower then
    local CurrentVehicle = self:GetCurrentVehicle()
    if slua.isValid(CurrentVehicle) then
      print(bWriteLog and "CommercialVehicleComponent:TryEnterLeaderVehicle failed, follower has his own vehicle")
      return
    end
    local Leader = CustomLeader or Owner.Leader
    local LeaderThisComponent = self:GetCharacterCurrentComponent(Leader)
    if not slua.isValid(LeaderThisComponent) then
      return
    end
    local LeaderVehicle = LeaderThisComponent:GetActiveVehicle()
    if LeaderVehicle and LeaderVehicle.VehicleType == ESTExtraVehicleType.VT_Aircraft and not self:IsInTwoAircraftTeam() then
      print(bWriteLog and "CommercialVehicleComponent:TryEnterLeaderVehicle is not Same AircraftTeam")
      return
    end
    if slua.isValid(LeaderVehicle) and LeaderVehicle.CanInviteFollower == true and not LeaderVehicle:IsInVehicle(Owner.PlayerKey) and LeaderVehicle:GetAvailableSeatIndex() >= 0 then
      Owner.ParachuteComponent:StopParachute()
      Owner.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_None, 0)
      Owner.STCharacterMovement:Deactivate()
      local RootComponent = Owner:K2_GetRootComponent()
      if Game:IsClassOf(RootComponent, import("/Script/Engine.PrimitiveComponent")) then
        RootComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, ECollisionResponse.ECR_Ignore)
      end
      Owner.IsFakeOnVehicle = true
      self:SetCurrentVehicle(LeaderVehicle)
      LeaderVehicle:AddFollower(Owner.PlayerKey)
      LeaderVehicle:AttachCharacter(Owner)
      if Owner.getAvatarComponent2 and slua.isValid(Owner:getAvatarComponent2()) then
        Owner:getAvatarComponent2():DoAllAvatarReplaceOnVehicle()
        Owner:getAvatarComponent2():UpdateCutPlaneState()
      end
      LeaderVehicle:ForceNetUpdate()
      Owner:ForceNetUpdate()
      print(bWriteLog and "CommercialVehicleComponent:TryEnterLeaderVehicle success, enter leader's vehicle")
    else
      print(bWriteLog and "CommercialVehicleComponent:TryEnterLeaderVehicle false, LeaderVehicle Is Not Valid")
    end
  end
end
function CommercialVehicleComponent:TryEnterVehicle()
  local Owner = self:GetOwner()
  print(bWriteLog and "CommercialVehicleComponent:TryEnterVehicle ", Owner)
  if Owner.ParachuteState ~= EParachuteState.PS_FreeFall then
    print(bWriteLog and "CommercialVehicleComponent:TryEnterVehicle failed, parachute state is not <PS_FreeFall>")
    return
  end
  if slua.isValid(self.InActiveVehicle) then
    self:ActivateVehicle()
    self.ActiveVehicle:AddDriver(Owner.PlayerKey)
    Owner.IsFakeOnVehicle = true
    self.ActiveVehicle:AttachCharacter(Owner)
    if Owner.getAvatarComponent2 and slua.isValid(Owner:getAvatarComponent2()) then
      Owner:getAvatarComponent2():DoAllAvatarReplaceOnVehicle()
      Owner:getAvatarComponent2():UpdateCutPlaneState()
    end
    Owner.ParachuteComponent:InvalidateAdjustFollowerLocation()
    Owner.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_None, 0)
    print(bWriteLog and "CommercialVehicleComponent:TryEnterParachutingVehicle success, enter player's own vehicle")
  end
end
function CommercialVehicleComponent:AircraftTryEnterVehicle()
  local Owner = self:GetOwner()
  print(bWriteLog and "CommercialVehicleComponent:AircraftTryEnterVehicle ", Owner)
  if Owner.ParachuteState ~= EParachuteState.PS_FreeFall then
    print(bWriteLog and "CommercialVehicleComponent:AircraftTryEnterVehicle failed, parachute state is not <PS_FreeFall>")
    return
  end
  if self:AircraftTeamHasLeader() then
    if Owner.FollowState == EFollowState.Leader then
      self:GetVehicleFromAircraftLeader()
      self:TryEnterVehicle()
    else
      self:DestroyCurrentVehicle()
      self:TryEnterLeaderVehicle()
    end
  elseif Owner.TwoPersonAircraftLeader then
    self:DestroyCurrentVehicle()
    self:TryEnterLeaderVehicle(Owner.TwoPersonAircraftLeader)
  else
    self:TryEnterVehicle()
    if Game:IsValid(Owner.Leader) then
      Owner.Leader.ParachuteComponent:InvalidateAdjustFollowerLocation()
    end
    for _, _Follower in pairs(Owner.FollowingAircraftTeam) do
      if Game:IsValid(_Follower) then
        local FollowThisComponent = self:GetCharacterCurrentComponent(_Follower)
        if slua.isValid(FollowThisComponent) then
          FollowThisComponent:DestroyCurrentVehicle()
          FollowThisComponent:TryEnterLeaderVehicle(Owner)
        end
      end
    end
  end
end
function CommercialVehicleComponent:BorrowVehicleToLeader()
  self:DestroyCurrentVehicle()
end
function CommercialVehicleComponent:GetVehicleFromAircraftLeader()
  local Owner = self:GetOwner()
  local Vehicle = self:GetCurrentVehicle()
  local AircraftOwner = Owner.TwoPersonAircraftLeader
  print(bWriteLog and "CommercialVehicleComponent:GetVehicleFromAircraftLeader" .. tostring(Owner:GetPlayerNameSafety()))
  if AircraftOwner then
    self:DestroyCurrentVehicle()
    print(bWriteLog and "CommercialVehicleComponent:GetVehicleFromAircraftLeader success" .. tostring(AircraftOwner:GetPlayerNameSafety()))
    local _AircraftOwnerThisComponent = self:GetCharacterCurrentComponent(AircraftOwner)
    if _AircraftOwnerThisComponent then
      self:InitInActiveVehicle(_AircraftOwnerThisComponent:GetCurrentVehicle())
      _AircraftOwnerThisComponent.ActiveVehicle = nil
      _AircraftOwnerThisComponent.InActiveVehicle = nil
    end
  end
end
function CommercialVehicleComponent:DestroyCurrentVehicle()
  print(bWriteLog and "CommercialVehicleComponent:DestroyCurrentVehicle")
  local CurrentVehicle = self:GetCurrentVehicle()
  if slua.isValid(CurrentVehicle) then
    CurrentVehicle:K2_DestroyActor()
    print(bWriteLog and "CommercialVehicleComponent:DestroyCurrentVehicle CurrentVehicle")
  end
  self.ActiveVehicle = nil
  self.InActiveVehicle = nil
end
function CommercialVehicleComponent:TryExitParachutingVehicle()
  local Owner = self:GetOwner()
  print(bWriteLog and "CommercialVehicleComponent:TryExitParachutingVehicle ", Owner)
  local CurrentVehicle = self:GetCurrentVehicle()
  if not slua.isValid(CurrentVehicle) then
    print(bWriteLog and string.format("CommercialVehicleComponent:TryExitParachutingVehicle failed, <%s> has not been in parachuting vehicle", Owner))
    return
  end
  if Owner.FollowState == EFollowState.Leader then
    local UScriptGameplayStatics = import("ScriptGameplayStatics")
    local RemovedNum = 0
    for _, PlayerKey in pairs(CurrentVehicle.OccupiedSeats) do
      local Character = UScriptGameplayStatics.GetCharacterByPlayerKey(self, PlayerKey)
      self:ExitParachutingVehicle(Character)
      RemovedNum = RemovedNum + 1
    end
    if RemovedNum == 0 then
      for _, PlayerKey in pairs(CurrentVehicle.OccupiedSeats) do
        local Character = UScriptGameplayStatics.GetCharacterByPlayerKey(self, PlayerKey)
        if slua.isValid(Character) and Character.getAvatarComponent2 and slua.isValid(Character:getAvatarComponent2()) then
          Character:getAvatarComponent2():RemoveAllReplaceOnVehicle()
          local EClothCutStateType = import("EClothCutStateType")
          Character:getAvatarComponent2():SetClothPlaneCutState(EClothCutStateType.EClothCutStateType_NotCut)
        end
      end
    end
    CurrentVehicle:RemoveAll()
    print(bWriteLog and string.format("CommercialVehicleComponent:TryExitParachutingVehicle, leader <%s> exits parachuting vehicle", Owner))
  elseif CurrentVehicle:IsInVehicle(Owner.PlayerKey) then
    CurrentVehicle:Remove(Owner.PlayerKey)
    self:ExitParachutingVehicle(Owner)
    print(bWriteLog and string.format("CommercialVehicleComponent:TryExitParachutingVehicle, follower <%s> exits parachuting vehicle", Owner))
  end
end
function CommercialVehicleComponent:ExitParachutingVehicle(InCharacter)
  if slua.isValid(InCharacter) then
    local EDetachmentRule = import("EDetachmentRule")
    InCharacter:K2_DetachFromActor(EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld)
    local CurrentComponent = self:GetCharacterCurrentComponent(InCharacter)
    if slua.isValid(CurrentComponent) then
      CurrentComponent:SetCurrentVehicle(nil)
    end
    InCharacter.IsFakeOnVehicle = false
    if InCharacter.getAvatarComponent2 and slua.isValid(InCharacter:getAvatarComponent2()) then
      InCharacter:getAvatarComponent2():RemoveAllReplaceOnVehicle()
      local EClothCutStateType = import("EClothCutStateType")
      InCharacter:getAvatarComponent2():SetClothPlaneCutState(EClothCutStateType.EClothCutStateType_NotCut)
    end
    if slua.isValid(InCharacter.STCharacterMovement) then
      if self.IsTrustClientFastLand then
        InCharacter.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_Falling, 0)
        self.IsTrustClientFastLand = false
      else
        InCharacter.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_Flying, 0)
      end
    end
    InCharacter:ForceNetUpdate()
  end
end
function CommercialVehicleComponent:GetCharacterCurrentComponent(InCharacter)
  if not slua.isValid(InCharacter) then
    return nil
  end
  local UVehicleParachuteComponentClass = import("VehicleParachuteComponent")
  return InCharacter:GetComponentByClass(UVehicleParachuteComponentClass)
end
function CommercialVehicleComponent:OnRep_InActiveVehicle()
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  print(bWriteLog and "CommercialVehicleComponent:OnRep_InActiveVehicle ", Owner, self.InActiveVehicle)
  if slua.isValid(self.InActiveVehicle) then
    self.InActiveVehicle.RootComponent:SetVisibility(false, false)
    if self.InActiveVehicle.BP_Parachute_VehicleLicensePlateComponent then
      self.InActiveVehicle.BP_Parachute_VehicleLicensePlateComponent:SetPlateMeshVisible(false)
    end
    print(bWriteLog and "CommercialVehicleComponent:OnRep_InActiveVehicle, ParachutingVehicle is invisible", tostring(self.InActiveVehicle))
    if Owner.ParachuteState == EParachuteState.PS_FreeFall and Owner:IsLocallyControlled() then
      Owner.ParachuteComponent:InvalidateAdjustFollowerLocation()
      self:TryReqEnterVehicle(self.InActiveVehicle, self.InActiveVehicle:GetChangeAvatarComplete())
    end
  end
end
function CommercialVehicleComponent:OnRep_ActiveVehicle()
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  print(bWriteLog and "CommercialVehicleComponent:OnRep_ActiveVehicle ", Owner:GetPlayerNameSafety(), tostring(self.ActiveVehicle))
  if slua.isValid(self.ActiveVehicle) then
    self.ActiveVehicle.RootComponent:SetVisibility(true, false)
    if self.ActiveVehicle.BP_Parachute_VehicleLicensePlateComponent then
      self.ActiveVehicle.BP_Parachute_VehicleLicensePlateComponent:SetPlateMeshVisible(true)
    end
    print(bWriteLog and "CommercialVehicleComponent:OnRep_ActiveVehicle, ParachutingVehicle is visible", tostring(self.ActiveVehicle))
    Owner.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_None, 0)
    Owner:UseCameraParamForVehicleParachute(true)
    local RootComponent = Owner:K2_GetRootComponent()
    if Game:IsClassOf(RootComponent, import("/Script/Engine.PrimitiveComponent")) then
      RootComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, ECollisionResponse.ECR_Ignore)
    end
    self.ActiveVehicle:OnRep_OccupiedSeats()
    self.ActiveVehicle:PlayOpenAnim()
    local ComponentCls = import("VehicleAvatarComponentBattleBase")
    local VehicleAvatar = self.ActiveVehicle:GetComponentByClass(ComponentCls)
    if slua.isValid(VehicleAvatar) then
      self.VehicleAvatarID = VehicleAvatar:GetCurrentAvatarID()
    end
  else
    Owner:UseCameraParamForVehicleParachute(false)
    if self.IsTrustClientFastLand then
      Owner.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_Falling, 0)
      self.IsTrustClientFastLand = false
    else
      Owner.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_Flying, 0)
    end
    if Owner:IsLocallyControlled() and Owner.ParachuteState == EParachuteState.PS_FreeFall then
      local LocalController = Owner:GetPlayerControllerSafety()
      if slua.isValid(LocalController) then
        local ControlRotation = LocalController:GetControlRotation()
        Owner:K2_SetActorRotation(FRotator(0, ControlRotation.Yaw, 0), false, nil, true)
      end
    end
    local Controller = Owner:GetPlayerControllerSafety()
    if slua.isValid(Controller) then
      print(bWriteLog and "CommercialVehicleComponent:OnRep_ActiveVehicle, BattleNormalTipsByTextID", self.VehicleAvatarID)
      local ItemEntry = CDataTable.GetTableData("Item", self.VehicleAvatarID)
      if ItemEntry and Owner.ParachuteState ~= EParachuteState.PS_FreeFall then
        IngameTipsTools.BattleNormalTipsByTextID(508506, ItemEntry.ItemName)
      end
    end
  end
end
function CommercialVehicleComponent:HandleOnFollowStateChanged(LastFollowState, NewFollowState)
  local Owner = self:GetOwner()
  print(bWriteLog and "CommercialVehicleComponent:HandleOnFollowStateChanged", tostring(Owner), LastFollowState, NewFollowState)
  if slua.isValid(Owner) and Owner:HasAuthority() then
    if Owner.ParachuteState ~= EParachuteState.PS_FreeFall then
      return
    end
    if LastFollowState == EFollowState.Follower and NewFollowState == EFollowState.None then
      local CurrentVehicle = self:GetCurrentVehicle()
      if slua.isValid(CurrentVehicle) and CurrentVehicle:IsInVehicle(Owner.PlayerKey) and not CurrentVehicle:IsDriverByPlayerKey(Owner.PlayerKey) then
        CurrentVehicle:Remove(Owner.PlayerKey)
        self:ExitParachutingVehicle(Owner)
        local Controller = Owner:GetPlayerControllerSafety()
        local NewYaw = Owner:K2_GetActorRotation().Yaw
        if slua.isValid(Controller) then
          NewYaw = Controller:GetControlRotation().Yaw
        end
        Owner:K2_SetActorRotation(FRotator(0, NewYaw, 0), false, nil, true)
        print(bWriteLog and string.format("CommercialVehicleComponent:HandleOnFollowStateChanged | follower <%s> exit parachuting vehicle", Owner:GetPlayerNameSafety()))
      end
    end
  end
end
function CommercialVehicleComponent:HandleOnChangeVehicleAvatarEnd(_, _, InVehicle)
  print(bWriteLog and "CommercialVehicleComponent:HandleOnChangeVehicleAvatarEnd")
  if not slua.isValid(self.InActiveVehicle) or self.InActiveVehicle ~= InVehicle then
    print(bWriteLog and "InActiveVehicle/InVehicle is invalid", self.InActiveVehicle, InVehicle)
    return
  end
  self:TryReqEnterVehicle(InVehicle, true)
end
function CommercialVehicleComponent:TryReqEnterVehicle(InVehicle, VehicleChangeAvatarComplete)
  if VehicleChangeAvatarComplete ~= true then
    print(bWriteLog and "CommercialVehicleComponent:TryReqEnterVehicle, vehicle has not changed avatar ", InVehicle)
    return
  end
  local Owner = self:GetOwner()
  print(bWriteLog and "CommercialVehicleComponent:TryReqEnterVehicle ", Owner, InVehicle)
  if not slua.isValid(InVehicle) then
    print(bWriteLog and "CommercialVehicleComponent:TryReqEnterVehicle failed, parameter InVehicle is invalid")
    return
  end
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  local AParachutingVehicle = import("ParachutingVehicle")
  if not GameLuaAPI.IsClassOf(InVehicle, AParachutingVehicle) then
    print(bWriteLog and string.format("CommercialVehicleComponent:TryReqEnterVehicle failed, <%s> is not AParachutingVehicle", InVehicle))
    return
  end
  if Owner.ParachuteState ~= EParachuteState.PS_FreeFall then
    print(bWriteLog and "CommercialVehicleComponent:TryReqEnterVehicle failed, parachute state is not <PS_FreeFall>", Owner.ParachuteState)
    return
  end
  if slua.isValid(self.InActiveVehicle) and self.InActiveVehicle == InVehicle then
    self:ReqEnterVehicle()
    print(bWriteLog and "CommercialVehicleComponent:TryReqEnterVehicle, request enter mine parachuting vehicle")
  end
end
function CommercialVehicleComponent:OnFakeOnVehicle()
  local Owner = self:GetOwner()
  if slua.isValid(Owner) then
    self:ToggleAnimNew(Owner.IsFakeOnVehicle)
  end
end
function CommercialVehicleComponent:ToggleAnimNew(Enable)
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  local uMesh = Owner.Mesh
  if not slua.isValid(uMesh) then
    return
  end
  if Client then
    if Enable then
      local Util = require("client.slua_ui_framework.util")
      Util.GetAssetAsync(VehicleParachuteAnimBpPath, function(LoadedABP)
        if slua.isValid(LoadedABP) and slua.isValid(uMesh) then
          print(bWriteLog and string.format("CommercialVehicleComponent:ToggleAnimNew, Active Vehicle Parachute SubInstance! %s", Owner:GetPlayerNameSafety()))
          uMesh:SetSubInstance("Vehicle", LoadedABP)
        end
      end)
    elseif slua.isValid(uMesh) then
      print(bWriteLog and string.format("CommercialVehicleComponent:ToggleAnimNew, Deactive Vehicle Parachute SubInstance! %s", Owner:GetPlayerNameSafety()))
      uMesh:SetSubInstance("Vehicle", nil)
      uMesh:SetSubInstance("PostProcess", nil)
      uMesh.bEnableUpdateRateOptimization = true
    end
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CCommercialVehicleComponent = class(CDelegateContainer, nil, CommercialVehicleComponent)
return CCommercialVehicleComponent