local TreasureChestActor = {
  MulticastRPC = {}
}
TreasureChestActor.MulticastRPC.CloseChestBeforeRecover = {
  Reliable = true,
  Params = {}
}
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local RewindConfig = require("GameLua.Mod.Library.GamePlay.Weapon.DaggerOfTime.RewindActorConfig")
local GameplayStatics = import("GameplayStatics")
TreasureChestActor.EWayToOpen = {
  SkillOpen = 1,
  ClickOpen = 2,
  AutoOpen = 3,
  Custom = 4
}
TreasureChestActor.ETLogType = {
  TLogSpawn = 1,
  TLogOpen = 2,
  TLogGenerate = 3,
  TLogActive = 4
}
TreasureChestActor.EState = {
  None = 0,
  Spawned = 1,
  Activated = 2,
  AnimationFinished = 3,
  Empty = 4
}
function TreasureChestActor:ctor()
  self.bOpened = false
  self.OpenTime = 0
  self.DropMode = nil
  self.LootItems = nil
  self.AllHaveBeenTaken = false
  self.bUpgradedChest = false
  self.bUpdatePickupLoc = false
  self.UpdatePickupDist = 300
  self.DisableClimbing = true
  self.DisableTweenWhenSM = true
end
function TreasureChestActor:_PostConstruct()
  TreasureChestActor.__super._PostConstruct(self)
  if self.StateMachine then
    self.StateMachine:Init({
      {
        Id = self.EState.None,
        Name = "None"
      },
      {
        Id = self.EState.Spawned,
        Name = "Spawned"
      },
      {
        Id = self.EState.Activated,
        Name = "Activated"
      },
      {
        Id = self.EState.AnimationFinished,
        Name = "AnimationFinished"
      },
      {
        Id = self.EState.Empty,
        Name = "Empty"
      }
    }, self.EState.None)
    self.StateMachine:OnStateChanged(self.OnAnimationStateChanged, self)
  end
  if self.DisableClimbing == true then
    self.Tags:Add("NoClimbing")
  end
  self.Tags:Add("StuckGround")
end
function TreasureChestActor:OnAnimationStateChanged()
  print(bWriteLog and "TreasureChestActor:OnAnimationStateChanged")
end
function TreasureChestActor:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bOpened",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "OpenTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "bUpgradedChest",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
end
function TreasureChestActor:ReceiveBeginPlay()
  if not Client then
    if self.InteractiveComponent and slua.isValid(self.InteractiveComponent) and self.InteractiveComponent.bEnabled == true then
      Game:AddTreasureChestToCell(self.Object, self.OpenType)
    else
      print(bWriteLog and string.format("TreasureChestActor:ReceiveBeginPlay, not self.InteractiveComponent.bEnabled, Object=%s,Location=%s", tostring(self.Object), tostring(self:K2_GetActorLocation():ToString())))
    end
    self:MarkNetDormancyForReplay(true, false)
    if self.AvailableCount == nil then
      self.AvailableCount = 1
      print(bWriteLog and "TreasureChestActor:ReceiveBeginPlay, AvailableCount is nil, Object = " .. tostring(self.Object))
    end
  end
  TreasureChestActor.__super.ReceiveBeginPlay(self)
  if self.hasAuthority then
    if self.DropItemCurveAnim then
      self.DropItemCurveAnim:SetComponentTickEnabled(false)
    end
    self:SetActorTickEnabled(false)
    local ParentActor = self:GetAttachParentActor()
    self:AttachToActor(ParentActor)
  end
end
function TreasureChestActor:OnRep_bUpgradedChest()
  print(bWriteLog and "TreasureChestActor:OnRep_bUpgradedChest bUpgradedChest:", self.bUpgradedChest)
  self:UpdateUpgradedChestEffect()
end
function TreasureChestActor:UpdateUpgradedChestEffect()
  if not Client then
    return
  end
  print(bWriteLog and "TreasureChestActor:UpdateUpgradedChestEffect bOpened bUpgradedChest ", self.bOpened, self.bUpgradedChest)
  if not self.bOpened and self.bUpgradedChest then
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(RewindConfig.ChestUpgradeEffect, function(uPartcileSystem)
      if uPartcileSystem and slua.isValid(self.Object) and slua.isValid(CGameWorld) then
        self:DestroyUpgradedChestParticle()
        self:SpawnUpgradedChestParticle(uPartcileSystem)
      end
    end)
  else
    self:DestroyUpgradedChestParticle()
  end
end
function TreasureChestActor:SpawnUpgradedChestParticle(uPartcileSystem)
  if not self.bOpened and self.bUpgradedChest then
    local Location = self:K2_GetActorLocation()
    local Rot = FRotator(0, 90, 0) + self:K2_GetActorRotation()
    if self.StaticMesh and slua.isValid(self.StaticMesh) then
      Rot = self.StaticMesh:K2_GetComponentRotation() + FRotator(0, 90, 0)
    end
    self.UpgradedChestParticle = FuncUtil.SafeCallFun(GameplayStatics, "SpawnEmitterAtLocation", CGameWorld, uPartcileSystem, Location, Rot, FVector(1, 1, 1), true)
  end
end
function TreasureChestActor:DestroyUpgradedChestParticle()
  if self.UpgradedChestParticle and slua.isValid(self.UpgradedChestParticle) then
    self.UpgradedChestParticle:K2_DestroyComponent(self.UpgradedChestParticle)
    self.UpgradedChestParticle = nil
  end
end
function TreasureChestActor:EndPlayImpl()
  if self.hasAuthority then
    self:FlushNetDormancyOnceForReplay()
    self:RemoveStateMachineTimer()
    if self.bEnableSM == true and self.StateMachine then
      self.StateMachine:SetState(self.EState.Empty)
    end
  else
    self:CloseChest()
    self.bOpened = false
    self.OpenTime = 0
    self:StopCurveComponentTimer()
  end
  if slua.isValid(self.PlayerTombBoxResult) then
    self.PlayerTombBoxResult:K2_DestroyActor()
    self.PlayerTombBoxResult = nil
  end
  self:HandleMapMark_EndPlay()
  self:ClearBulletHoleAndDecal()
  self:DestroyUpgradedChestParticle()
  TreasureChestActor.__super.EndPlayImpl(self)
end
function TreasureChestActor:ClearBulletHoleAndDecal()
  print(bWriteLog and "TreasureChestActor:ClearBulletHoleAndDecal")
  Game:HideOrDestroyAllAttach(self.StaticMesh)
  Game:HideOrDestroyAllAttach(self.StaticMesh1)
end
function TreasureChestActor:BeginPlayImpl()
  TreasureChestActor.__super.BeginPlayImpl(self)
  if self.hasAuthority then
    if self.bEnableSM == true then
      self:FlushNetDormancyOnceForReplay()
      self.StateMachine:SetState(self.EState.Spawned)
      self:RemoveStateMachineTimer()
      self.SMTimer = self:AddGameTimer(1, true, function()
        self:OnTimeHandler()
      end)
      if self.bAutoActive == true and self.CountDownBeforeActive and self.CountDownBeforeActive > 0 then
        self.OpenTime = math.floor(CGameState:GetServerWorldTimeSeconds() + self.CountDownBeforeActive + 0.5)
      end
    end
    self:ReportTreasureTLog(self.ETLogType.TLogSpawn)
    if self.SetNetUpdateGroupID then
      self:SetNetUpdateGroupID(1)
    end
  else
    if self.bOpened == true then
      self:OpenChest()
    end
    self:DisableComponentTickFunction()
  end
  self:HandleMapMark()
end
function TreasureChestActor:RemoveStateMachineTimer()
  if self.SMTimer then
    self:RemoveGameTimer(self.SMTimer)
    self.SMTimer = nil
  end
end
function TreasureChestActor:ActiveTreasureChest()
  if self.hasAuthority then
    print(bWriteLog and "TreasureChestActor:ActiveTreasureChest, CurrentState = " .. tostring(self.StateMachine:GetState()))
    if self.StateMachine:GetState() == self.EState.Spawned then
      self:FlushNetDormancyOnceForReplay()
      self.StateMachine:SetState(self.EState.Activated)
      self:ReportTreasureTLog(self.ETLogType.TLogActive)
    end
  end
end
function TreasureChestActor:OnTimeHandler()
  print(bWriteLog and "TreasureChestActor:OnTimeHandler, CurrentState = " .. tostring(self.StateMachine:GetState()))
  if self.StateMachine:GetState() == self.EState.Spawned then
    if self.bAutoActive then
      self:FlushNetDormancyOnceForReplay()
      if self.CountDownBeforeActive >= 0 then
        if self.CountDownBeforeActive == 0 then
          self.StateMachine:SetState(self.EState.Activated)
          self:ReportTreasureTLog(self.ETLogType.TLogActive)
        end
        self.CountDownBeforeActive = self.CountDownBeforeActive - 1
      else
        self.StateMachine:SetState(self.EState.Activated)
        self:ReportTreasureTLog(self.ETLogType.TLogActive)
      end
    end
  elseif self.StateMachine:GetState() == self.EState.Activated then
    self:RemoveStateMachineTimer()
  elseif self.StateMachine:GetState() == self.EState.AnimationFinished then
    self:RemoveStateMachineTimer()
  elseif self.StateMachine:GetState() == self.EState.Empty then
    self:RemoveStateMachineTimer()
  end
end
function TreasureChestActor:RecoverChestFromOpened(DropId)
  if self.hasAuthority then
    print(bWriteLog and "TreasureChestActor:RecoverChestFromOpened, self.AvailableCount = " .. tostring(self.AvailableCount) .. ", DropId = " .. tostring(DropId))
    if self:CanRecoverChestFromOpened() then
      self:FlushNetDormancyOnceForReplay()
      self:CloseChestBeforeRecover()
      self:AddGameTimer(self.OpenChestRotateTime or 1, false, function()
        self:FlushNetDormancyOnceForReplay()
        if DropId and type(DropId) == "number" then
          self.BP_ProduceDropItemComponent:SetProduceID(DropId)
        end
        self:SetOpened(false)
      end)
      if DropId and type(DropId) == "number" then
        self.bUpgradedChest = true
      else
        self.bUpgradedChest = false
      end
    end
  end
end
function TreasureChestActor:CanRecoverChestFromOpened()
  if self.bOpened and self.AvailableCount > 0 then
    return true
  else
    return false
  end
end
function TreasureChestActor:SetOpened(bOpened)
  print(bWriteLog and "TreasureChestActor:SetOpened, bOpened = " .. tostring(bOpened))
  self.  if self.bOpened == true then
    self.AvailableCount = self.AvailableCount - 1
  else
    self.OpenTime = 0
    if self.InitialStartAngle then
      self.BP_ProduceDropItemComponent.StartAngle = self.InitialStartAngle
    end
    if self.AvailableCount and self.AvailableCount > 0 then
      local Component = self:GetInteractiveComponent()
      if Component then
        Component:SetEnable(true)
      end
    end
  end
end
function TreasureChestActor:OpenChest()
  if not Client and self.hasAuthority and self.bOpened then
    Game:RemoveTreasureChestToCell(self.Object)
  end
  self:HandleMapMark_Open()
  if self.DisableTweenWhenSM == true and self.bEnableSM == true then
    return
  end
  local JustNow = self:IsOpenedJustNow()
  if JustNow then
    self:OpenChestByTween()
  elseif self.OpenChestImmediately then
    self:OpenChestImmediately()
  else
    self:OpenChestByTween()
  end
  self:PostOpenChest()
end
function TreasureChestActor:SetLidCollisionToPlayer(bEnable)
  print(bWriteLog and "TreasureChestActor:SetLidCollisionToPlayer, bEnable = " .. tostring(bEnable))
  if self.StaticMesh1 and slua.isValid(self.StaticMesh1) then
    local ECollisionChannel = import("ECollisionChannel")
    local ECollisionResponse = import("ECollisionResponse")
    if bEnable then
      self.StaticMesh1:SetCollisionObjectType(ECollisionChannel.ECC_WorldStatic)
      self.StaticMesh1:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, ECollisionResponse.ECR_Block)
      self.StaticMesh1:SetCollisionResponseToChannel(ECollisionChannel.ECC_Vehicle, ECollisionResponse.ECR_Block)
      self.StaticMesh1:SetCollisionResponseToChannel(ECollisionChannel.ECC_Camera, ECollisionResponse.ECR_Block)
    else
      self.StaticMesh1:SetCollisionObjectType(ECollisionChannel.ECC_WorldDynamic)
      self.StaticMesh1:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, ECollisionResponse.ECR_Ignore)
      self.StaticMesh1:SetCollisionResponseToChannel(ECollisionChannel.ECC_Vehicle, ECollisionResponse.ECR_Ignore)
      self.StaticMesh1:SetCollisionResponseToChannel(ECollisionChannel.ECC_Camera, ECollisionResponse.ECR_Ignore)
    end
  end
end
function TreasureChestActor:PostOpenChest()
end
function TreasureChestActor:GetOpenedRotator()
  local RelativeRotator = self.OpenChestRotator
  return RelativeRotator
end
function TreasureChestActor:OpenChestByTween()
  print(bWriteLog and "TreasureChestActor:OpenChestByTween")
  local RelativeRotator = self:GetOpenedRotator()
  if RelativeRotator == nil then
    if self.Super.OpenChest then
      self.Super:OpenChest()
    end
    return
  end
  if self.StaticMesh and slua.isValid(self.StaticMesh) then
    local TargetRotator = RelativeRotator + self.StaticMesh:K2_GetComponentRotation()
    self:RotateLidByTween(self.StaticMesh1, TargetRotator, true, RelativeRotator)
  end
end
function TreasureChestActor:RotateLidByTween(StaticMesh, TargetRotator, bOpen, RelativeRotator)
  print(bWriteLog and "TreasureChestActor:RotateLidByTween, bOpen = " .. tostring(bOpen))
  if StaticMesh and slua.isValid(StaticMesh) then
    self:SetLidCollisionToPlayer(false)
    if self.hasAuthority then
      StaticMesh:K2_SetRelativeRotation(RelativeRotator, false, nil, false)
    else
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      GamePlayTools.PrepareTween(function()
        if self == nil or slua.isValid(self.Object) == false then
          return
        end
        local TweenRotatorStandardFactory = import("TweenRotatorStandardFactory")
        local ETweenEaseType = import("ETweenEaseType")
        local ETweenLoopType = import("ETweenLoopType")
        TweenRotatorStandardFactory.BP_CreateTweenRotateSceneComponentTo(nil, StaticMesh, nil, nil, TargetRotator, self.OpenChestRotateTime or 1, ETweenEaseType.Linear, false, false, 1, ETweenLoopType.Yoyo, 0, 1, -1, true)
      end, function()
        if self == nil or slua.isValid(self.Object) == false then
          return
        end
        StaticMesh:K2_SetRelativeRotation(RelativeRotator, false, nil, false)
      end, self)
    end
    if not bOpen then
      self:AddGameTimer(self.OpenChestRotateTime or 1, false, function()
        if self == nil or slua.isValid(self.Object) == false then
          return
        end
        self:SetLidCollisionToPlayer(true)
      end)
    end
  end
end
function TreasureChestActor:OpenChestImmediately()
  if self.StaticMesh1 and slua.isValid(self.StaticMesh1) then
    local RelativeRotator = self:GetOpenedRotator()
    if RelativeRotator == nil then
      if self.Super.OpenChestImmediately then
        self.Super:OpenChestImmediately()
      elseif self.Super.OpenChest then
        self.Super:OpenChest()
      end
      return
    end
    self:SetLidCollisionToPlayer(false)
    self.StaticMesh1:K2_SetRelativeRotation(RelativeRotator, false, nil, false)
  end
end
function TreasureChestActor:CloseChest()
  if self.DisableTweenWhenSM == true and self.bEnableSM == true then
    return
  end
  self:CloseChestImmediately()
end
function TreasureChestActor:CloseChestBeforeRecover()
  print(bWriteLog and "TreasureChestActor:CloseChestBeforeRecover")
  if self.PlayerTombBoxResult and slua.isValid(self.PlayerTombBoxResult) then
    self.PlayerTombBoxResult:K2_DestroyActor()
    self.PlayerTombBoxResult = nil
  end
  local RelativeRotator = self:GetOpenedRotator()
  if RelativeRotator == nil then
    if self.Super.CloseChest then
      self.Super:CloseChest()
    end
    return
  end
  local TargetRotator = FRotator(0, 0, 0) + self:K2_GetActorRotation()
  self:RotateLidByTween(self.StaticMesh1, TargetRotator, false, FRotator(0, 0, 0))
end
function TreasureChestActor:CloseChestImmediately()
  if self.StaticMesh1 and slua.isValid(self.StaticMesh1) then
    self:SetLidCollisionToPlayer(false)
    self.StaticMesh1:K2_SetRelativeRotation(FRotator(0, 0, 0), false, nil, false)
    self:SetLidCollisionToPlayer(true)
    print(bWriteLog and "TreasureChestActor:CloseChestImmediately, Rotation = FRotator(0, 0, 0)")
  else
    print(bWriteLog and "TreasureChestActor:CloseChestImmediately, StaticMesh1 = " .. tostring(self.StaticMesh1))
  end
end
function TreasureChestActor:ReportTreasureTLog(Type, Character, ItemIDList)
  if slua_DSHUD and slua.isValid(slua_DSHUD) then
    local uDSUtils = slua_DSHUD:GetUtils()
    if uDSUtils then
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      local ActorName = UKismetSystemLibrary.GetObjectName(self.Object)
      local CurrentTime = math.floor(CGameState:GetServerWorldTimeSeconds() + 0.5)
      if Type == self.ETLogType.TLogSpawn then
        if self.ReportSpawnTLog == false then
          return
        end
        local Location = self:K2_GetActorLocation()
        local Param = {
          BoxName = ActorName,
          SpawnTime = CurrentTime,
          SpawnLocation = string.format("%d,%d,%d", math.floor(Location.X + 0.5), math.floor(Location.Y + 0.5), math.floor(Location.Z + 0.5))
        }
        log_tree("TreasureChestActor:ReportTreasureTLog, Param = ", Param)
        uDSUtils:ReportHeavyWeaponBoxSpawnFlow(Param)
      elseif Type == self.ETLogType.TLogOpen then
        if self.ReportOpenTLog == false then
          return
        end
        if Character and slua.isValid(Character) then
          local PlayerState = Character:GetPlayerStateSafety()
          if PlayerState then
            PlayerState.MonsterTreasureBoxGetNum = PlayerState.MonsterTreasureBoxGetNum + 1
            local HeavyWeaponBoxOpenPlayerFlow = import("HeavyWeaponBoxOpenPlayerFlow")
            local Param = HeavyWeaponBoxOpenPlayerFlow()
            if Param then
              Param.BoxName = ActorName
              Param.UID = PlayerState.UID
              Param.TeamID = PlayerState.TeamID
              Param.WaitTimeFromActiveToOpen = CurrentTime
            end
            if self.SetDropItems and self.FinnalDropItems then
              self:SetDropItems(self.FinnalDropItems, PlayerState)
            end
            log_tree("TreasureChestActor:ReportTreasureTLog, Param = ", Param)
            uDSUtils:ReportHeavyWeaponBoxOpenPlayerFlow(Param)
          end
        end
      elseif Type == self.ETLogType.TLogGenerate then
        if self.ReportGenerateTLog == false then
          return
        end
        if ItemIDList then
          local BoxName = ActorName
          local ItemIDs = {}
          for _, v in pairs(ItemIDList) do
            table.insert(ItemIDs, v.ItemID)
          end
          self.FinnalDropItems = ItemIDList
          log_tree("TreasureChestActor:ReportTreasureTLog, ItemIDs = ", ItemIDs)
          uDSUtils:ReportHeavyWeaponBoxItemFlowForLua(BoxName, ItemIDs)
        end
      elseif Type == self.ETLogType.TLogActive then
        if self.ReportActiveTLog == false then
          return
        end
        local Param = {BoxName = ActorName, ActiveTime = CurrentTime}
        log_tree("TreasureChestActor:ReportTreasureTLog, Param = ", Param)
        uDSUtils:ReportHeavyWeaponBoxActivationFlow(Param)
      else
        print(bWriteLog and "TreasureChestActor:ReportTreasureTLog, Type = " .. tostring(Type))
      end
    end
  else
    print(bWriteLog and "TreasureChestActor:ReportTreasureTLog, slua_DSHUD = " .. tostring(slua_DSHUD))
  end
end
function TreasureChestActor:OnRep_bOpened()
  if self.bOpened == true then
    self:OpenChest()
    self:PlayOpenAudio()
    self.CurveComponentTimer = self:AddGameTimer(self.StopTickTime, false, function()
      if self and self.Object and slua.isValid(self.Object) then
        self:DisableComponentTickFunction()
      end
    end)
  elseif self.StaticMesh1 and slua.isValid(self.StaticMesh1) then
    local TargetRotator = FRotator(0, 0, 0)
    local CurrentRotator = self.StaticMesh1:K2_GetComponentRotation()
    print(bWriteLog and "TreasureChestActor:OnRep_bOpened, CurrentRotator = " .. tostring(CurrentRotator:ToString()))
    if TargetRotator == CurrentRotator then
      return
    end
    self:CloseChest()
  end
  self:UpdateUpgradedChestEffect()
end
function TreasureChestActor:StopCurveComponentTimer()
  if self.CurveComponentTimer then
    self:RemoveGameTimer(self.CurveComponentTimer)
    self.CurveComponentTimer = nil
  end
end
function TreasureChestActor:DisableComponentTickFunction()
  if self.DropItemCurveAnim and slua.isValid(self.DropItemCurveAnim) then
    local JustOpened = self:IsOpenedJustNow(self.StopTickTime)
    print(bWriteLog and "TreasureChestActor:DisableComponentTickFunction, bOpened = " .. tostring(self.bOpened) .. ", JustOpened = " .. tostring(JustOpened))
    if self.bOpened == false or self.bOpened == true and JustOpened == false then
      self.DropItemCurveAnim:SetComponentTickEnabled(false)
    end
  end
end
function TreasureChestActor:OnRep_OpenTime()
  print(bWriteLog and "TreasureChestActor:OnRep_OpenTime, self.OpenTime = " .. tostring(self.OpenTime))
end
function TreasureChestActor:IsOpenedJustNow(Interval)
  Interval = Interval or 3
  if self.bOpened == true and slua.isValid(CGameState) then
    if self.OpenTime == 0 then
      return true
    else
      local CurrentTime = math.floor(CGameState:GetServerWorldTimeSeconds() + 0.5)
      print(bWriteLog and "TreasureChestActor:IsOpenedJustNow, CurrentTime = " .. tostring(CurrentTime) .. ", OpenTime = " .. tostring(self.OpenTime) .. ", Interval = " .. tostring(Interval))
      if Interval >= CurrentTime - self.OpenTime then
        return true
      else
        return false
      end
    end
  else
    return false
  end
end
function TreasureChestActor:PlayOpenAudio()
  if self:IsOpenedJustNow() == false then
    return
  end
  if self.OpenAudio and self.OpenAudio.AssetPathName and self.OpenAudio.AssetPathName ~= "" and self.OpenAudio.AssetPathName ~= "None" then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudioByActorAsync(self.OpenAudio.AssetPathName, self.Object, nil, true)
  end
end
function TreasureChestActor:OnAllowToInteract(character, component)
  if self.OpenType == self.EWayToOpen.Custom then
    return false
  end
  if self.AvailableCount == nil then
    return false
  end
  if (self.bOpened or self.AvailableCount <= 0) and component then
    component:SetEnable(false)
  end
  return self.bOpened == false and self.AvailableCount > 0 and self:CanOpenByStateMachine()
end
function TreasureChestActor:CanOpenByStateMachine()
  if self.bEnableSM == true then
    return self.StateMachine:GetState() == self.EState.AnimationFinished
  else
    return true
  end
end
function TreasureChestActor:OnClientShowInteractiveUI(show, component)
  component = component or self:GetInteractiveComponent()
  if self.OpenType == self.EWayToOpen.AutoOpen then
    if show then
      local GameplayStatics = import("GameplayStatics")
      local character = GameplayStatics.GetPlayerCharacter(self, 0)
      if character then
        character:ServerRPCOnClickInteractiveButton(component, 0)
      end
    end
  else
    TreasureChestActor.__super.OnClientShowInteractiveUI(self, show, component)
  end
end
function TreasureChestActor:OnServerAddOrDeleteComponent(Character, bAddOrDelete, Component)
  if bAddOrDelete == true and Character and Character.bMEnsure == true and self.bOpened == false and self:CanOpenByStateMachine() and (self.OpenType == self.EWayToOpen.AutoOpen or self.OpenType == self.EWayToOpen.ClickOpen) then
    self:MustCheckResultAfterSkillFinished(Character, true, Component)
  end
end
function TreasureChestActor:MustCheckResultAfterServerClick(character, result, component)
  component = component or self:GetInteractiveComponent()
  if self.OpenType == self.EWayToOpen.AutoOpen then
    self:MustCheckResultAfterSkillFinished(character, result, component)
  elseif self.OpenType == self.EWayToOpen.ClickOpen then
    self:MustCheckResultAfterSkillFinished(character, result, component)
  else
    TreasureChestActor.__super.MustCheckResultAfterServerClick(self, character, result, component)
  end
end
function TreasureChestActor:MustCheckResultAfterSkillFinished(character, Result, Component)
  print(bWriteLog and "TreasureChestActor:MustCheckResultAfterSkillFinished, self.hasAuthority = " .. tostring(self.hasAuthority) .. ", Result = " .. tostring(Result))
  if Result == false then
    return
  end
  Component = Component or self:GetInteractiveComponent()
  if self.hasAuthority then
    self:FlushNetDormancyOnceForReplay()
    self.OpenTime = math.floor(CGameState:GetServerWorldTimeSeconds() + 0.5)
    self:SetOpened(true)
    self:OpenChest()
    if self.bUpdatePickupLoc then
      self:AddGameTimer(self.OpenChestRotateTime or 1, false, function()
        Game:UpdatePickupActorLocation(self:K2_GetActorLocation(), 1, self.UpdatePickupDist)
        Game:UpdateDeadBoxLocation(self:K2_GetActorLocation(), 1, self.UpdatePickupDist)
      end)
    end
    self:ReportTreasureTLog(self.ETLogType.TLogOpen, character)
    if false then
      self:AddGameTimer(self.OpenChestRotateTime / 2, false, function()
        if self and self.BP_ProduceDropItemComponent and slua.isValid(self.BP_ProduceDropItemComponent) then
          self:SetStartAngleByRotation()
          self:GenerateItems(nil, character)
          self:SpawnBuffActorByRandom(character)
          EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_ON_OPEN_TREASURECHEST, self.Object, character)
        end
      end)
    else
      self:SetStartAngleByRotation()
      self:GenerateItems(nil, character)
      self:SpawnBuffActorByRandom(character)
      EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_ON_OPEN_TREASURECHEST, self.Object, character)
    end
  else
    self:CloseUI(Component)
  end
  TreasureChestActor.__super.MustCheckResultAfterSkillFinished(self, character, Result, Component)
end
function TreasureChestActor:SetStartAngleByRotation()
  local Rotation = self:K2_GetActorRotation()
  print(bWriteLog and "TreasureChestActor:SetStartAngleByRotation, Rotation = " .. tostring(Rotation:ToString()))
  local Angle = Rotation.Yaw
  if Angle < 0 then
    Angle = 360 + Angle
  end
  if self.InitialStartAngle == nil then
    self.InitialStartAngle = self.BP_ProduceDropItemComponent.StartAngle
  end
  local FinalAngle = math.floor(Angle) + self.BP_ProduceDropItemComponent.StartAngle
  while FinalAngle < 0 do
    FinalAngle = FinalAngle + 360
  end
  FinalAngle = math.fmod(FinalAngle, 360)
  self.BP_ProduceDropItemComponent.StartAngle = FinalAngle
end
function TreasureChestActor:SpawnBuffActorByRandom(Character)
  math.randomseed(os.time())
  local temp = math.random()
  if temp <= self.BuffDropProbability then
    if self.BuffActors and self.BuffActors:Num() > 0 then
      local index = math.random(0, self.BuffActors:Num() - 1)
      local obj = self.BuffActors:Get(index)
      if obj and obj.AssetPathName ~= "None" then
        local world = self:GetWorld()
        local class = slua.loadClass(obj.AssetPathName)
        local position = self:K2_GetActorLocation()
        position.X = position.X + self.BuffPositionOffset.X
        position.Y = position.Y + self.BuffPositionOffset.Y
        position.Z = position.Z + self.BuffPositionOffset.Z
        local actor = world:SpawnActor(class, position, nil, nil)
        if actor then
          print(bWriteLog and "TreasureChestActor:SpawnBuffActorByRandom, index = " .. tostring(index))
        else
          print(bWriteLog and "TreasureChestActor:SpawnBuffActorByRandom, actor = nil")
        end
      else
        print(bWriteLog and "TreasureChestActor:SpawnBuffActorByRandom, nil when index = " .. tostring(index))
      end
    else
      print(bWriteLog and "TreasureChestActor:SpawnBuffActorByRandom, self.BuffActors:Num() = 0")
    end
  else
    print(bWriteLog and "TreasureChestActor:SpawnBuffActorByRandom, " .. tostring(temp) .. " > " .. tostring(self.BuffDropProbability))
  end
end
function TreasureChestActor:SetOpenType(OpenType, LoadingDuration)
  print(bWriteLog and "TreasureChestActor:SetOpenType, OpenType = " .. tostring(OpenType) .. ", LoadingDuration = " .. tostring(LoadingDuration))
  if OpenType and (OpenType == self.EWayToOpen.SkillOpen or OpenType == self.EWayToOpen.ClickOpen or OpenType == self.EWayToOpen.AutoOpen) then
    self.    if OpenType == self.EWayToOpen.SkillOpen and LoadingDuration and type(LoadingDuration) == "number" and 0 < LoadingDuration then
      local Component = self:GetInteractiveComponent()
      if Component then
        Component.bResetSkillData = true
        Component.      end
    end
  end
end
function TreasureChestActor:SetLootItems(DropMode, ItemList)
  print(bWriteLog and "TreasureChestActor:SetLootItems, DropMode = " .. tostring(DropMode) .. ", ItemList = " .. tostring(ItemList))
  if ItemList and type(ItemList) == "table" and next(ItemList) ~= nil then
    self.LootItems = ItemList
    self.    log_tree("TreasureChestActor:SetLootItems, ItemList = ", ItemList)
  end
end
function TreasureChestActor:GenerateItems(DropActor, Character)
  if self.BP_ProduceDropItemComponent then
    local Count = 0
    local DropMode, boxName, resultArray = nil, "", {}
    if self.LootItems and next(self.LootItems) ~= nil then
      DropMode = self.DropMode
      local FDropPropDataStruct = import("DropPropData")
      for k, v in pairs(self.LootItems) do
        local DropPropData = FDropPropDataStruct()
        DropPropData.ItemID = k
        DropPropData.ItemCount = v
        DropPropData.DropMode = self.DropMode
        DropPropData.bDropOnDead = true
        table.insert(resultArray, DropPropData)
        Count = Count + 1
      end
    else
      local FDropPropData = import("DropPropData")
      local uDropDataStruct = slua.Array(UEnums.EPropertyClass.Struct, FDropPropData)
      self.BP_ProduceDropItemComponent:SetCharacterOwner(Character)
      boxName, resultArray = self.BP_ProduceDropItemComponent:GenerateDropItemByCfg(uDropDataStruct)
      self.BP_ProduceDropItemComponent:SetCharacterOwner(nil)
      if resultArray == nil or 0 >= resultArray:Num() then
        print(bWriteLog and "TreasureChestActor:GenerateItems, resultArray = " .. tostring(resultArray))
        return
      end
      local FirstItem = resultArray:Get(0)
      if FirstItem == nil then
        print(bWriteLog and "TreasureChestActor:GenerateItems, FirstItem = nil")
        return
      end
      Count = resultArray:Num()
      DropMode = FirstItem.DropMode
    end
    if DropMode == 2 then
      if self.ChestName and self.ChestName ~= "" then
        boxName = self.ChestName
      end
      local EPickUpBoxType = import("EPickUpBoxType")
      self.PlayerTombBoxResult = self.BP_ProduceDropItemComponent:DropToTreasureBox(resultArray, DropActor or self.Object, boxName, EPickUpBoxType.EPickUpBoxType_TreasureBox, FVector(0, 0, 0), true, false)
      local result = Game:IsValid(self.PlayerTombBoxResult)
      if result then
        self:AddChestEmptyDelegate(self.PlayerTombBoxResult)
      end
      self:SpawnBoxOverDell(self.PlayerTombBoxResult, Character)
      print(bWriteLog and "TreasureChestActor:GenerateItems, boxName = " .. tostring(boxName) .. ", num = " .. tostring(Count) .. ", result = " .. tostring(result))
    else
      print(bWriteLog and "TreasureChestActor:GenerateItems, num = " .. tostring(Count))
      self.BP_ProduceDropItemComponent:StartDropWithDropData(DropActor or self.Object, nil, resultArray)
    end
    self:ReportTreasureTLog(self.ETLogType.TLogGenerate, nil, resultArray)
    if self.TreasureChestActorExtraDropFeature then
      self.TreasureChestActorExtraDropFeature:CheckGenerateExtraDropBox(Character, resultArray)
    end
  else
    print(bWriteLog and "TreasureChestActor:GenerateItems, BP_ProduceDropItemComponent = nil")
  end
end
function TreasureChestActor:AddChestEmptyDelegate(PlayerTombBox)
  local PickupWrapper = PlayerTombBox:GetBoxPickupWrapperActor()
  if PickupWrapper and slua.isValid(PickupWrapper) then
    print(bWriteLog and "TreasureChestActor:AddChestEmptyDelegate, AddDynamic(OnWrapperEmpty)")
    self:AddControlEvent(PickupWrapper, "OnWrapperEmpty", self.OnChestEmpty, self)
  else
    print(bWriteLog and "TreasureChestActor:AddChestEmptyDelegate, PickupWrapper = " .. tostring(PickupWrapper))
  end
end
function TreasureChestActor:OnChestEmpty()
  self.AllHaveBeenTaken = true
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local Name = UKismetSystemLibrary.GetObjectName(self.Object)
  print(bWriteLog and "TreasureChestActor:OnChestEmpty, Name = " .. tostring(Name))
  if self.bEnableSM == true then
    self.StateMachine:SetState(self.EState.Empty)
  end
end
function TreasureChestActor:SpawnBoxOverDell(PlayerTombBoxResult)
end
function TreasureChestActor:AttachToActor(uActor)
  if not self.hasAuthority then
    return
  end
  if slua.isValid(uActor) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local bImplement = UKismetSystemLibrary.DoesImplementInterface(uActor, import("MoveablePlatformInterface"))
    if bImplement then
      local USTExtraGameplayStatics = import("STExtraGameplayStatics")
      USTExtraGameplayStatics.ActorAttachToMoveablePlatform(self.Object, uActor)
    end
  end
end
function TreasureChestActor:HandleMapMark()
  if slua.isValid(self.Object) then
    if self.hasAuthority and self.MapMarkIconID and self.MapMarkIconID > 0 then
      if self.CountDownBeforeActive and 0 < self.CountDownBeforeActive then
        local CountDonwTime = math.floor(CGameState:GetServerWorldTimeSeconds()) + self.CountDownBeforeActive
        self.ChestMapMarkAction = InGameMarkTools.ServerAddMapMark(self.MapMarkIconID, self:K2_GetActorLocation(), CountDonwTime)
        self:AddGameTimer(self.CountDownBeforeActive, false, function()
          if self.ChestMapMarkAction then
            InGameMarkTools.UpdateMapMarkCustomState(self.ChestMapMarkAction, 1)
          end
        end)
      else
        self.ChestMapMarkAction = InGameMarkTools.ServerAddMapMark(self.MapMarkIconID, self:K2_GetActorLocation())
      end
    end
    if Client and self.bOpened == false and self.ScreenMarkIconID and 0 < self.ScreenMarkIconID then
      if self.ScreenMarkAction then
        InGameMarkTools.HideMapMark(self.ScreenMarkAction)
        self.ScreenMarkAction = nil
      end
      self.ScreenMarkAction = InGameMarkTools.ClientAddMapMark(self.ScreenMarkIconID, self:K2_GetActorLocation(), nil, nil, 4, self.Object)
    end
  end
end
function TreasureChestActor:HandleMapMark_Open()
  if slua.isValid(self.Object) then
    if self.hasAuthority then
      if self.ChestMapMarkAction and self.OpenHideMapMark then
        InGameMarkTools.HideMapMark(self.ChestMapMarkAction)
      end
    elseif self.ScreenMarkAction and self.OpenHideScrrenMark then
      InGameMarkTools.HideMapMark(self.ScreenMarkAction)
      self.ScreenMarkAction = nil
    end
  end
end
function TreasureChestActor:HandleMapMark_EndPlay()
  if self.ChestMapMarkAction then
    InGameMarkTools.HideMapMark(self.ChestMapMarkAction)
  end
  if self.ScreenMarkAction then
    InGameMarkTools.HideMapMark(self.ScreenMarkAction)
    self.ScreenMarkAction = nil
  end
end
local Class = require("class")
local CInteractiveActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local TreasureChestActorClass = Class(CInteractiveActorBase, nil, TreasureChestActor)
return require("combine_class").DeclareFeature(TreasureChestActorClass, {
  {
    StateMachine = "GameLua.Mod.BaseMod.GamePlay.Feature.Common.StateMachineFeature"
  },
  {
    TreasureChestActorExtraDropFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.TreasureChestActorExtraDropFeature"
  }
}, "TreasureChestActor")