local ENetRole = import("ENetRole")
local EParachuteState = import("EParachuteState")
local EFollowState = import("EFollowState")
local EParachuteType = import("EParachuteType")
local CharacterParachuteComponent = {}
function CharacterParachuteComponent:ctor(selfType)
  self.AWindSource = nil
  self.ParachuteTlogData = {
    nUID = 0,
    PlayerKey = 0,
    EnterPlaneTime = 0,
    PlayerJumpTime = 0,
    PlayerLandTime = 0,
    PlayerLandPositionX = 0,
    PlayerLandPositionY = 0,
    PlayerLandPositionZ = 0,
    ParachuteType = 3,
    LeaderUID = 0,
    FollowerUID = "",
    CancleFollowTime = 0,
    ParachuteReason = 0,
    PlayerType = 4
  }
  self.haveCheckPawnHeightTime = 0
end
function CharacterParachuteComponent:ReceiveBeginPlay()
  CharacterParachuteComponent.__super.ReceiveBeginPlay(self)
  local MyOwner = self:GetOwnerActor()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  if MyOwner ~= nil and slua.isValid(MyOwner) then
    self:AddControlEvent(MyOwner, "OnParachuteStateChanged", self.OnParachuteStateChanged, self)
    self:AddControlEvent(MyOwner, "OnRepParachuteStateDelegate", self.OnRepParachuteStateDelegate, self)
    if not Client then
      self:AddControlEvent(MyOwner, "OnFollowStateChanged", self.HandleOnFollowStateChanged, self)
    else
      GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
      GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerControllerStateChangedDelegate", self.OnPlayerControllerStateChanged, self)
      GameplayData.AddSelfPlayerControllerEvent(self, "OnParachuteResetScreenCullFactor", self.OnParachuteResetScreenCullFactor, self)
      GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.OnPlayerEnterFlying, self)
    end
  end
end
function CharacterParachuteComponent:GetOwnerActor()
  if not self.MyOwner or not slua.isValid(self.MyOwner) then
    self.MyOwner = self:GetOwner()
  end
  return self.MyOwner
end
function CharacterParachuteComponent:OnParachuteResetScreenCullFactor()
  self:ParachuteResetScreenCullFactor()
end
function CharacterParachuteComponent:OnPlayerEnterFlying()
  print(bWriteLog and "CharacterParachuteComponent:OnPlayerEnterFlying")
  self:ShowTrailMarkActor(false)
end
function CharacterParachuteComponent:OnReconnect(ReconnectInfo)
  print(bWriteLog and "CharacterParachuteComponent::OnReconnect")
  local EParachuteState = import("EParachuteState")
  local MyOwner = self:GetOwnerActor()
  if MyOwner ~= nil and slua.isValid(MyOwner) and MyOwner.ParachuteState ~= EParachuteState.PS_None and MyOwner.FollowState == EFollowState.Follower and MyOwner.Leader and slua.isValid(MyOwner.Leader) then
    local bLeaderInfoRight = false
    for key, value in pairs(MyOwner.Leader.FlyingTeam) do
      if value and slua.isValid(value) and value.PlayerKey == MyOwner.PlayerKey then
        bLeaderInfoRight = true
      end
    end
    if not bLeaderInfoRight then
      MyOwner.Leader.FlyingTeam:Add(MyOwner)
      print(bWriteLog and "CharacterParachuteComponent::OnReconnect readd:" .. tostring(MyOwner.PlayerKey))
    end
  end
end
function CharacterParachuteComponent:InitParachuteData(uPlayerController)
  if not Client and slua.isValid(uPlayerController) then
    print(bWriteLog and string.format("CharacterParachuteComponent:InitParachuteData %s", uPlayerController.PlayerKey))
    self:AddControlEvent(uPlayerController, "OnPlayerControllerStateChangedDelegate", self.OnPlayerControllerStateChanged, self)
    self:InitParachuteTlogData(uPlayerController)
  end
end
function CharacterParachuteComponent:InitAIParachuteData(uNewFakePlayerAIController)
  if not Client and slua.isValid(uNewFakePlayerAIController) then
    print(bWriteLog and string.format("CharacterParachuteComponent:InitAIParachuteData %s", uNewFakePlayerAIController.PlayerKey))
    self:AddControlEvent(uNewFakePlayerAIController, "FakeAIParachuteTypeChange", self.OnFakeAIParachuteTypeChanged, self, uNewFakePlayerAIController)
    self:InitParachuteTlogData(uNewFakePlayerAIController)
  end
end
function CharacterParachuteComponent:OnPlayerControllerStateChanged(CurrentSate)
  local EStateType = import("EStateType")
  if not Client then
    if slua.isValid(CGameState) then
      local EnterPlaneTime = math.floor(CGameState:GetServerWorldTimeSeconds())
      if CurrentSate == EStateType.State_InPlane then
        self.ParachuteTlogData.ParachuteType = 1
        self.ParachuteTlogData.        self.ParachuteReason = EParachuteType.Classic
        print(bWriteLog and "CharacterParachuteComponent:OnPlayerControllerStateChanged InPlane Time = " .. tostring(EnterPlaneTime))
      elseif CurrentSate == EStateType.State_InExPlane then
        self.ParachuteTlogData.ParachuteType = 2
        self.ParachuteTlogData.        print(bWriteLog and "CharacterParachuteComponent:OnPlayerControllerStateChanged InPlane InExPlane = " .. tostring(EnterPlaneTime))
      end
    end
  elseif CurrentSate == EStateType.State_InPlane or CurrentSate == EStateType.State_InExPlane then
    self:ParachuteSetScreenCullFactor()
  end
  print(bWriteLog and "CharacterParachuteComponent:OnPlayerControllerStateChanged")
  local EParachuteState = import("EParachuteState")
  local MyOwner = self:GetOwnerActor()
  if MyOwner ~= nil and slua.isValid(MyOwner) then
    local uController = MyOwner:GetPlayerControllerSafety()
    if slua.isValid(uController) and uController:GetCurrentStateType() == EStateType.State_Dead and MyOwner.ParachuteState ~= EParachuteState.PS_None then
      MyOwner:SetParachuteState(EParachuteState.PS_None)
      print(bWriteLog and "CharacterParachuteComponent:OnPlayerControllerStateChanged dell")
    end
  end
end
function CharacterParachuteComponent:OnFakeAIParachuteTypeChanged(uNewFakePlayerAIController)
  if not Client and slua.isValid(CGameState) and slua.isValid(uNewFakePlayerAIController) then
    local EnterPlaneTime = math.floor(CGameState:GetServerWorldTimeSeconds())
    local ParachuteType = uNewFakePlayerAIController.ParachuteType
    self.ParachuteTlogData.    if ParachuteType == EParachuteType.Classic then
      self.ParachuteTlogData.ParachuteType = 1
    elseif ParachuteType == EParachuteType.SelfRevive or ParachuteType == EParachuteType.TeammateRevive then
      self.ParachuteTlogData.ParachuteType = 2
    else
      self.ParachuteTlogData.ParachuteType = 3
    end
    self.ParachuteReason = ParachuteType
    print(bWriteLog and string.format("CharacterParachuteComponent:OnFakeAIParachuteTypeChanged - PlayerKey = %s ParachuteType = %s", uNewFakePlayerAIController.PlayerKey, ParachuteType))
  end
end
function CharacterParachuteComponent:OnRepParachuteStateDelegate()
  self:DellCompentTick()
  local MyOwner = self:GetOwnerActor()
  if MyOwner ~= nil and slua.isValid(MyOwner) and MyOwner.Role == ENetRole.ROLE_AutonomousProxy then
    print(bWriteLog and "CharacterParachuteComponent:OnRepParachuteStateDelegate", MyOwner.ParachuteState)
    EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_ON_REP_PARACHUTE_STATE, MyOwner.ParachuteState)
    if MyOwner.ParachuteState == EParachuteState.PS_None then
      MyOwner.bUseControllerRotationYaw = true
      MyOwner.bUseControllerRotationPitch = false
      print(bWriteLog and "CharacterParachuteComponent:OnRepParachuteStateDelegate SetseControllerRotationYaw")
    end
  end
end
function CharacterParachuteComponent:ShowTrailMarkActor(bShow)
  print(bWriteLog and string.format("CharacterParachuteComponent:ShowTrailMarkActor bShow %s", tostring(bShow)))
  local MyOwner = self:GetOwnerActor()
  if not slua.isValid(MyOwner) then
    print(bWriteLog and "CharacterParachuteComponent:ShowTrailMarkActor MyOwner is nil")
    return
  end
  local PlayerController = MyOwner:GetPlayerControllerSafety()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "CharacterParachuteComponent:ShowTrailMarkActor PlayerController is nil")
    return
  end
  local TrailMarkActorLookupTable = PlayerController.TrailMarkActorLookupTable
  if TrailMarkActorLookupTable then
    for _, TrailMarkActorBlock in pairs(TrailMarkActorLookupTable) do
      if slua.isValid(TrailMarkActorBlock) then
        if TrailMarkActorBlock.WorkingList then
          for _, WorkingTrailMarkActor in pairs(TrailMarkActorBlock.WorkingList) do
            if slua.isValid(WorkingTrailMarkActor) then
              WorkingTrailMarkActor:SetActorHiddenInGame(not bShow)
            end
          end
        end
        if TrailMarkActorBlock.AssignableList then
          for _, AssignableTrailMarkActor in pairs(TrailMarkActorBlock.AssignableList) do
            if slua.isValid(AssignableTrailMarkActor) then
              AssignableTrailMarkActor:SetActorHiddenInGame(not bShow)
            end
          end
        end
      end
    end
  end
end
function CharacterParachuteComponent:OnParachuteStateChanged(LastParachuteState, ParachuteState)
  self:DellCompentTick()
  local MyOwner = self:GetOwnerActor()
  if MyOwner ~= nil and slua.isValid(MyOwner) and MyOwner.Role == ENetRole.ROLE_AutonomousProxy then
    if ParachuteState == EParachuteState.PS_FreeFall then
      self:CheckAdjustViewTarget()
      self:TryCreateParachuteWindSource()
      self:ShowTrailMarkActor(false)
      self.ShowTrailMarkActorTimer = self:AddGameTimer(0.1, true, function()
        local MyOwner = self:GetOwnerActor()
        if not slua.isValid(MyOwner) then
          return
        end
        local PlayerController = MyOwner:GetPlayerControllerSafety()
        if slua.isValid(PlayerController) then
          if MyOwner.ParachuteState == EParachuteState.PS_FreeFall and PlayerController.bCanOpenParachute and PlayerController.RealTimePawnHeight < 25000 then
            self:ShowTrailMarkActor(true)
            self:RemoveGameTimer(self.ShowTrailMarkActorTimer)
            self.ShowTrailMarkActorTimer = nil
          elseif MyOwner.ParachuteState == EParachuteState.PS_Opening and PlayerController.RealTimePawnHeight < 25000 then
            self:ShowTrailMarkActor(true)
            self:RemoveGameTimer(self.ShowTrailMarkActorTimer)
            self.ShowTrailMarkActorTimer = nil
          end
        end
      end)
    elseif ParachuteState == EParachuteState.PS_None then
      self:TryDestroyParachuteWindSource()
      if self.ShowTrailMarkActorTimer then
        self:ShowTrailMarkActor(true)
        self:RemoveGameTimer(self.ShowTrailMarkActorTimer)
        self.ShowTrailMarkActorTimer = nil
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MARK_PARACHUTE_REFRESH)
  if MyOwner ~= nil and slua.isValid(MyOwner) and MyOwner.Role == ENetRole.ROLE_Authority then
    if LastParachuteState == EParachuteState.PS_Opening and (ParachuteState ~= EParachuteState.PS_Opening or ParachuteState ~= EParachuteState.PS_Landing) then
      print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall 333")
      self:ClearLandedInWallTimers()
      self.LandedInWallTimer1 = self:AddGameTimer(1, false, function()
        self:ParachuteLandedInWall()
        self.LandedInWallTimer1 = nil
      end)
      self.LandedInWallTimer2 = self:AddGameTimer(5, false, function()
        self:ParachuteLandedInWall()
        self.LandedInWallTimer2 = nil
      end)
    end
    if ParachuteState == EParachuteState.PS_FreeFall then
      self:ClearCollectClientPositionTimeDeltaTimer()
      self:CheckParachuteNeedChangeState()
    elseif ParachuteState == EParachuteState.PS_None then
      self:ClearCollectClientPositionTimeDeltaTimer()
      self:ClearCheckParachuteNeedChangeState()
    elseif ParachuteState == EParachuteState.PS_Opening then
      self:ClearCollectClientPositionTimeDeltaTimer()
      self.ChangeCollectClientPositionTimeDeltaTimer = self:AddGameTimer(0.5, true, function()
        local MyOwner = self:GetOwnerActor()
        if not slua.isValid(MyOwner) then
          return
        end
        local uController = MyOwner:GetPlayerControllerSafety()
        if slua.isValid(uController) and uController.RealTimePawnHeight < 10000 then
          self.bChangeCollectClientPositionTime = true
          self:RemoveGameTimer(self.ChangeCollectClientPositionTimeDeltaTimer)
          self.ChangeCollectClientPositionTimeDeltaTimer = nil
        end
      end)
    end
  end
  if not Client then
    self:RecordParchuteStateData(LastParachuteState, ParachuteState)
  end
end
function CharacterParachuteComponent:CheckAdjustViewTarget()
  print(bWriteLog and "CharacterParachuteComponent:CheckAdjustViewTarget")
  local MyOwner = self:GetOwnerActor()
  if MyOwner ~= nil and slua.isValid(MyOwner) and MyOwner.Role == ENetRole.ROLE_AutonomousProxy then
    if self.CheckAdjustViewTargetTimmer then
      self:RemoveGameTimer(self.CheckAdjustViewTargetTimmer)
      self.CheckAdjustViewTargetTimmer = nil
    end
    if MyOwner.ParachuteState == EParachuteState.PS_FreeFall then
      self.CheckAdjustViewTargetTimmer = self:AddGameTimer(1, true, function()
        if MyOwner ~= nil and slua.isValid(MyOwner) and MyOwner.Role == ENetRole.ROLE_AutonomousProxy and MyOwner.ParachuteState == EParachuteState.PS_FreeFall then
          local uPlayerController = MyOwner:GetPlayerControllerSafety()
          if slua.isValid(uPlayerController) and not uPlayerController:IsSpectator() then
            local CurrentViewTarget = uPlayerController:GetViewTarget()
            if CurrentViewTarget ~= MyOwner then
              print(bWriteLog and "CharacterParachuteComponent:CheckAdjustViewTarget adjust")
              uPlayerController:SetViewTargetTest(MyOwner)
            end
          end
        end
      end)
    end
  end
end
function CharacterParachuteComponent:ParachuteSetScreenCullFactor()
  print(bWriteLog and "CharacterParachuteComponent:ParachuteSetScreenCullFactor in")
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLevel = GameInstance:GetExactDeviceLevel()
  if 1 < nDeviceLevel and Client and not self.CacheScreenSizeCullFactor then
    local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    self.CacheScreenSizeCullFactor = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("r.SuperFrame.ScreenSizeCullFactor")
    GameInstance:ExecuteCMD("r.SuperFrame.ScreenSizeCullFactor", 0.5)
    local MyOwner = self:GetOwnerActor()
    if MyOwner ~= nil and slua.isValid(MyOwner) then
      local uController = MyOwner:GetPlayerControllerSafety()
      if slua.isValid(uController) then
        uController.bNeedResetScreenCullFactor = true
      end
    end
    print(bWriteLog and "CharacterParachuteComponent:ParachuteSetScreenCullFactor set SuperFrame.ScreenSizeCullFactor 0.5")
  end
end
function CharacterParachuteComponent:ParachuteResetScreenCullFactor()
  print(bWriteLog and "CharacterParachuteComponent:ParachuteResetScreenCullFactor in")
  if Client and self.CacheScreenSizeCullFactor then
    local STExtraGameInstance = import("STExtraGameInstance")
    local GameInstance = STExtraGameInstance.GetInstance()
    GameInstance:ExecuteCMD("r.SuperFrame.ScreenSizeCullFactor", self.CacheScreenSizeCullFactor)
    print(bWriteLog and "CharacterParachuteComponent:ParachuteResetScreenCullFactor set SuperFrame.ScreenSizeCullFactor:" .. tostring(self.CacheScreenSizeCullFactor))
    self.CacheScreenSizeCullFactor = nil
    local MyOwner = self:GetOwnerActor()
    if MyOwner ~= nil and slua.isValid(MyOwner) then
      local uController = MyOwner:GetPlayerControllerSafety()
      if slua.isValid(uController) then
        uController.bNeedResetScreenCullFactor = false
      end
    end
  end
end
function CharacterParachuteComponent:DellCompentTick()
  local MyOwner = self:GetOwnerActor()
  if slua.isValid(MyOwner) and MyOwner.ParachuteState ~= EParachuteState.PS_None then
    print(bWriteLog and "self.PrimaryComponentTick set true")
    self:SetComponentTickEnabled(true)
    self:ParachuteSetScreenCullFactor()
  elseif slua.isValid(MyOwner) and MyOwner.ParachuteState == EParachuteState.PS_None then
    print(bWriteLog and "self.PrimaryComponentTick set false")
    self:SetComponentTickEnabled(false)
    self:ParachuteResetScreenCullFactor()
  end
end
function CharacterParachuteComponent:TryCreateParachuteWindSource()
  local MyOwner = self:GetOwnerActor()
  if MyOwner ~= nil and slua.isValid(MyOwner) and MyOwner.Role == ENetRole.ROLE_AutonomousProxy and self:IsParachuteWindEnable() then
    self:TryDestroyParachuteWindSource()
    local AvatarComponent = MyOwner:getAvatarComponent2()
    if AvatarComponent ~= nil and slua.isValid(AvatarComponent) and AvatarComponent:IsWearingAvatarNeedParachuteWind() then
      local LoadClassDelegate = slua.createDelegate(function(WindSourceClass)
        if not slua.isValid(WindSourceClass) then
          return
        end
        if not slua.isValid(CGameWorld) then
          return
        end
        self.AWindSource = CGameWorld:SpawnActor(WindSourceClass, FVector(0, 0, 0), FRotator(90, 0, 0), nil)
      end)
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      USTExtraBlueprintFunctionLibrary.GetAssetByAssetReferenceAsync(UKismetSystemLibrary.MakeSoftObjectPath("/Game/Mod/EvoBase/BluePrints/Actor/BP_WindSource.BP_WindSource_C"), LoadClassDelegate)
    end
  end
end
function CharacterParachuteComponent:TryDestroyParachuteWindSource()
  if self.AWindSource ~= nil and slua.isValid(self.AWindSource) then
    self.AWindSource:K2_DestroyActor()
    self.AWindSource = nil
  end
end
function CharacterParachuteComponent:ClearLandedInWallTimers()
  if self.LandedInWallTimer1 then
    self:RemoveGameTimer(self.LandedInWallTimer1)
    self.LandedInWallTimer1 = nil
  end
  if self.LandedInWallTimer2 then
    self:RemoveGameTimer(self.LandedInWallTimer2)
    self.LandedInWallTimer2 = nil
  end
end
function CharacterParachuteComponent:ParachuteLandedInWall()
  local uCharacter = self:GetOwnerActor()
  print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall in")
  if slua.isValid(uCharacter) and uCharacter.Role == ENetRole.ROLE_Authority and slua.isValid(uCharacter.CapsuleComponent) and uCharacter.CapsuleComponent.GetOverlappingComponents then
    local Parent = uCharacter.RootComponent:GetAttachParent()
    if slua.isValid(Parent) then
      return
    end
    local uOverlapComps = uCharacter.CapsuleComponent:GetOverlappingComponents(slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.PrimitiveComponent")))
    local bOverlapOrPassWall = uOverlapComps.Num and uOverlapComps:Num() > 0
    local HitResult = import("/Script/Engine.HitResult")()
    if not bOverlapOrPassWall then
      local CapsuleComp = uCharacter:K2_GetRootComponent()
      if slua.isValid(CapsuleComp) then
        print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall in 2")
        local Radius = CapsuleComp:GetScaledCapsuleRadius()
        local HalfHeight = CapsuleComp:GetScaledCapsuleHalfHeight()
        local StartLocation = uCharacter:K2_GetActorLocation()
        local TargetLocation = FVector(StartLocation.X + 1, StartLocation.Y + 1, StartLocation.Z + 1)
        local Actor = import("/Script/Engine.Actor")
        local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, Actor)
        ActorsToIgnore:Add(uCharacter)
        local KismetSystemLibrary = import("KismetSystemLibrary")
        local TraceType = Game:ConvertToTraceType(CapsuleComp:GetCollisionObjectType())
        bOverlapOrPassWall, _ = KismetSystemLibrary.CapsuleTraceSingle(uCharacter, StartLocation, TargetLocation, Radius, HalfHeight, TraceType, false, ActorsToIgnore, 0, HitResult, true, FLinearColor.Red, FLinearColor.Green, 5)
      end
    end
    if bOverlapOrPassWall then
      local CurrentLoc = uCharacter:K2_GetActorLocation()
      print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall PlayerKey:", uCharacter.PlayerKey, " pos:", CurrentLoc:ToString())
      local bResolved = false
      local ResolveAttempts = {
        {
          AdjustRadius = 100,
          IterationRounds = 4,
          AdjustMaxHeight = 500,
          bRaiseUpAdjust = true
        },
        {
          AdjustRadius = 200,
          IterationRounds = 6,
          AdjustMaxHeight = 800,
          bRaiseUpAdjust = true
        },
        {
          AdjustRadius = 400,
          IterationRounds = 8,
          AdjustMaxHeight = 1200,
          bRaiseUpAdjust = true
        }
      }
      local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
      for AttemptIdx, AttemptConfig in ipairs(ResolveAttempts) do
        local ResolveParams = FResolvePenetrationParams()
        slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uCharacter)
        slua.IndexReference(ResolveParams, "OverlapIgnoreActors"):Add(uCharacter)
        ResolveParams.AdjustRadius = AttemptConfig.AdjustRadius
        ResolveParams.IterationRounds = AttemptConfig.IterationRounds
        ResolveParams.AdjustMaxHeight = AttemptConfig.AdjustMaxHeight
        ResolveParams.bRaiseUpAdjust = AttemptConfig.bRaiseUpAdjust
        local bFindLocOK = false
        local uNoPassWallLocation = FVector(0, 0, 0)
        bFindLocOK, uNoPassWallLocation = uCharacter:FindActorLocationSafetyWithParams(uNoPassWallLocation, CurrentLoc, ResolveParams)
        if bFindLocOK then
          uCharacter:SetActorLocationSafety(uNoPassWallLocation)
          print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall resolved at attempt:", AttemptIdx, " PlayerKey:", uCharacter.PlayerKey, " NewPos:", uCharacter:K2_GetActorLocation():ToString())
          bResolved = true
          break
        else
          print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall attempt:", AttemptIdx, " failed PlayerKey:", uCharacter.PlayerKey)
        end
      end
      if not bResolved then
        print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall all FindLoc attempts failed, trying SetActorLocationSafetyWithParams PlayerKey:", uCharacter.PlayerKey)
        local FallbackParams = FResolvePenetrationParams()
        slua.IndexReference(FallbackParams, "PassWallIgnoreActors"):Add(uCharacter)
        slua.IndexReference(FallbackParams, "OverlapIgnoreActors"):Add(uCharacter)
        FallbackParams.AdjustRadius = 400
        FallbackParams.IterationRounds = 8
        FallbackParams.AdjustMaxHeight = 1500
        FallbackParams.bRaiseUpAdjust = true
        FallbackParams.bTeleportIgnoreCheckPassWall = true
        local bSetOK = uCharacter:SetActorLocationSafetyWithParams(CurrentLoc, FallbackParams)
        if bSetOK then
          print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall SetActorLocationSafetyWithParams OK PlayerKey:", uCharacter.PlayerKey, " NewPos:", uCharacter:K2_GetActorLocation():ToString())
          bResolved = true
        else
          print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall SetActorLocationSafetyWithParams failed PlayerKey:", uCharacter.PlayerKey)
        end
      end
      if bResolved then
        self:ClearLandedInWallTimers()
      else
        print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall all resolve methods failed PlayerKey:", uCharacter.PlayerKey)
      end
    else
      print(bWriteLog and "CharacterParachuteComponent:ParachuteLandedInWall uOverlapComps.Num==0 PlayerKey:", uCharacter.PlayerKey)
    end
  end
end
function CharacterParachuteComponent:InitParachuteTlogData(uController)
  if Client then
    return
  end
  print(bWriteLog and "CharacterParachuteComponent:InitParachuteTlogData")
  if slua.isValid(uController) then
    local uPlayerState = uController.PlayerState
    if slua.isValid(uPlayerState) then
      self.ParachuteTlogData.nUID = uPlayerState.UID
      self.ParachuteTlogData.PlayerKey = uPlayerState.PlayerKey
      print(bWriteLog and "CharacterParachuteComponent:InitParachuteTlogData UID = " .. tostring(self.ParachuteTlogData.nUID))
    end
  end
end
function CharacterParachuteComponent:RecordParchuteStateData(LastParachuteState, ParachuteState)
  if not Client and slua.isValid(CGameState) then
    local nRecordTime = math.floor(CGameState:GetServerWorldTimeSeconds())
    if self.ParachuteTlogData.PlayerJumpTime == 0 and LastParachuteState == EParachuteState.PS_None and (ParachuteState == EParachuteState.PS_Opening or ParachuteState == EParachuteState.PS_FreeFall or ParachuteState == EParachuteState.PS_Launch) then
      self.ParachuteTlogData.PlayerJumpTime = nRecordTime
      print(bWriteLog and "CharacterParachuteComponent:RecordParchuteStateData JumpTime = " .. tostring(nRecordTime))
      local MyOwner = self:GetOwnerActor()
      if MyOwner ~= nil and slua.isValid(MyOwner) then
        if MyOwner.FollowState == EFollowState.Leader then
          self.ParachuteTlogData.FollowerUID = ""
          for _, uFollower in pairs(MyOwner.FlyingTeam) do
            if slua.isValid(uFollower) and uFollower ~= MyOwner then
              local uPlayerController = uFollower:GetPlayerControllerSafety()
              if slua.isValid(uPlayerController) then
                if self.ParachuteTlogData.FollowerUID == "" then
                  self.ParachuteTlogData.FollowerUID = tostring(uPlayerController.UID)
                else
                  self.ParachuteTlogData.FollowerUID = self.ParachuteTlogData.FollowerUID .. "+" .. tostring(uPlayerController.UID)
                end
              end
            end
          end
          print(bWriteLog and "CharacterParachuteComponent:RecordParchuteStateData FollowerUID = " .. tostring(self.ParachuteTlogData.FollowerUID))
        end
        if MyOwner.FollowState == EFollowState.Follower then
          local uController = MyOwner:GetPlayerControllerSafety()
          if slua.isValid(MyOwner.Leader) then
            local uController = MyOwner.Leader:GetPlayerControllerSafety()
            if slua.isValid(uController) then
              self.ParachuteTlogData.LeaderUID = uController.UID
              print(bWriteLog and "CharacterParachuteComponent:RecordParchuteStateData Leader UID = " .. tostring(self.ParachuteTlogData.LeaderUID))
            end
          end
        end
      end
    end
    if LastParachuteState == EParachuteState.PS_Opening and (ParachuteState ~= EParachuteState.PS_Opening or ParachuteState ~= EParachuteState.PS_Landing) then
      self.ParachuteTlogData.PlayerLandTime = nRecordTime
      local MyOwner = self:GetOwnerActor()
      if MyOwner ~= nil and slua.isValid(MyOwner) then
        local uOwnerLoc = Game:GetActorLocation(MyOwner)
        local uController = MyOwner:GetControllerSafety()
        if slua.isValid(uController) then
          if Game:IsAIController(uController) then
            self.ParachuteTlogData.PlayerType = uController:GetAIPlayerType()
            self.ParachuteTlogData.AIStyle = uController.MLAIStyle
            self.ParachuteTlogData.AILevel = uController:GetAILevel()
          else
            self.ParachuteTlogData.PlayerType = 4
          end
        end
        self.ParachuteTlogData.ParachuteReason = self.ParachuteReason
        if slua.isValid(uOwnerLoc) then
          self.ParachuteTlogData.PlayerLandPositionX = math.floor(uOwnerLoc.X)
          self.ParachuteTlogData.PlayerLandPositionY = math.floor(uOwnerLoc.Y)
          self.ParachuteTlogData.PlayerLandPositionZ = math.floor(uOwnerLoc.Z)
          print(bWriteLog and "CharacterParachuteComponent:RecordParchuteStateData LandTime = " .. tostring(nRecordTime) .. "Loc = " .. uOwnerLoc:ToString())
          self:ReportParachuteTlogData()
        else
          print(bWriteLog and "CharacterParachuteComponent:RecordParchuteStateData InValid Data")
          self:ResetParachuteTlogData()
        end
        self.ParachuteReason = nil
      end
    end
  end
end
function CharacterParachuteComponent:HandleOnFollowStateChanged(LastFollowState, NewFollowState)
  if not Client then
    local Owner = self:GetOwnerActor()
    print(bWriteLog and "CharacterParachuteComponent:HandleOnFollowStateChanged  FlyingLeader playerkey")
    if slua.isValid(Owner) and slua.isValid(CGameState) then
      local nTime = math.floor(CGameState:GetServerWorldTimeSeconds())
      if Owner.ParachuteState == EParachuteState.PS_FreeFall and LastFollowState == EFollowState.Follower and NewFollowState == EFollowState.None then
        self.ParachuteTlogData.CancleFollowTime = nTime
        print(bWriteLog and "CharacterParachuteComponent:HandleOnFollowStateChanged Cancle Follow Time = " .. tostring(nTime))
      end
    end
  end
end
function CharacterParachuteComponent:ReportParachuteTlogData()
  if not Client then
    log_tree("PlayerParachuteDSTlogData", self.ParachuteTlogData)
    if self.ParachuteTlogData.PlayerKey ~= 0 and 0 < self.ParachuteTlogData.PlayerJumpTime and 0 < self.ParachuteTlogData.PlayerLandTime then
      print(bWriteLog and "CharacterParachuteComponent:ReportParchuteTlogData")
      if NetUtil then
        NetUtil.SendPacket("report_ds_player_jump_flow", self.ParachuteTlogData)
      end
      self:ResetParachuteTlogData()
    else
      self:ResetParachuteTlogData()
      print(bWriteLog and "CharacterParachuteComponent:ReportParchuteTlogData DataInValid")
    end
  end
end
function CharacterParachuteComponent:ResetParachuteTlogData()
  print(bWriteLog and "CharacterParachuteComponent:ResetParachuteTlogData UID = " .. tostring(self.ParachuteTlogData.nUID))
  self.ParachuteTlogData.EnterPlaneTime = 0
  self.ParachuteTlogData.PlayerJumpTime = 0
  self.ParachuteTlogData.PlayerLandTime = 0
  self.ParachuteTlogData.PlayerLandPositionX = 0
  self.ParachuteTlogData.PlayerLandPositionY = 0
  self.ParachuteTlogData.PlayerLandPositionZ = 0
  self.ParachuteTlogData.ParachuteType = 3
  self.ParachuteTlogData.LeaderUID = 0
  self.ParachuteTlogData.FollowerUID = ""
  self.ParachuteTlogData.CancleFollowTime = 0
  self.ParachuteTlogData.ParachuteReason = 0
  self.ParachuteTlogData.PlayerType = 4
end
function CharacterParachuteComponent:CheckParachuteNeedChangeState()
  local uCharacter = self:GetOwnerActor()
  if not slua.isValid(uCharacter) or Client then
    return
  end
  if self.CheckParachuteNeedChangeStateTimer then
    self:ClearCheckParachuteNeedChangeState()
  end
  print(bWriteLog and "CharacterParachuteComponent:CheckParachuteNeedChangeState PlayerKey:", uCharacter.PlayerKey)
  self.CheckParachuteNeedChangeStateTimer = self:AddGameTimer(3, true, function()
    if not slua.isValid(uCharacter) or uCharacter.ParachuteState == EParachuteState.PS_None then
      return
    end
    local TraceStart = uCharacter:K2_GetActorLocation() + FVector(0, 0, 100)
    local TraceEnd = TraceStart + FVector(0, 0, -100000)
    local uHitResult = import("/Script/Engine.HitResult")()
    local ActorClass = import("/Script/Engine.Actor")
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    if not ActorsToIgnore then
      ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
    end
    local EDrawDebugTrace = import("EDrawDebugTrace")
    local bHit, uHitResult = UKismetSystemLibrary.LineTraceSingle(self.Object, TraceStart, TraceEnd, 6, true, ActorsToIgnore, EDrawDebugTrace.None, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 1)
    if bHit and uHitResult.Location and TraceStart.Z - uHitResult.Location.Z < 200 then
      print(bWriteLog and "CharacterParachuteComponent:CheckParachuteNeedChangeState block PlayerKey:", uCharacter.PlayerKey, "TraceStart:", uCharacter:K2_GetActorLocation():ToString(), " uHitResult.Location:", uHitResult.Location.Z)
      if 1 < self.haveCheckPawnHeightTime then
        local EStateType = import("EStateType")
        local uPlayerController = uCharacter:GetPlayerControllerSafety()
        if slua.isValid(uPlayerController) then
          print(bWriteLog and "CharacterParachuteComponent:CheckParachuteNeedChangeState block over change PlayerKey:", uCharacter.PlayerKey)
          uPlayerController:ServerChangeStatePC(EStateType.State_Fight)
        end
      else
        self.haveCheckPawnHeightTime = self.haveCheckPawnHeightTime + 1
      end
    end
  end)
end
function CharacterParachuteComponent:ClearCheckParachuteNeedChangeState()
  if self.CheckParachuteNeedChangeStateTimer then
    self:RemoveGameTimer(self.CheckParachuteNeedChangeStateTimer)
    self.CheckParachuteNeedChangeStateTimer = nil
    self.haveCheckPawnHeightTime = 0
    local uCharacter = self:GetOwnerActor()
    if not slua.isValid(uCharacter) or Client then
      return
    end
    print(bWriteLog and "CharacterParachuteComponent:ClearCheckParachuteNeedChangeState PlayerKey:", uCharacter.PlayerKey)
  end
end
function CharacterParachuteComponent:GetCollectClientPositionTimeDelta()
  if self.bChangeCollectClientPositionTime then
    return 0.032
  end
  return 0.1
end
function CharacterParachuteComponent:ClearCollectClientPositionTimeDeltaTimer()
  self.bChangeCollectClientPositionTime = false
  if self.ChangeCollectClientPositionTimeDeltaTimer then
    self:RemoveGameTimer(self.ChangeCollectClientPositionTimeDeltaTimer)
    self.ChangeCollectClientPositionTimeDeltaTimer = nil
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CCharacterParachuteComponent = class(CActorComponentBase, nil, CharacterParachuteComponent)
return CCharacterParachuteComponent