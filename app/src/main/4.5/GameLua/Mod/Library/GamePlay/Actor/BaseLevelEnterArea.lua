local BaseLevelEnterArea = {}
local UKismetMathLibrary = import("KismetMathLibrary")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local UGameplayStatics = import("GameplayStatics")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local USTExtraGameplayStatics = import("STExtraGameplayStatics")
local ECollisionChannel = import("ECollisionChannel")
function BaseLevelEnterArea:ctor()
  self.TriggerCollisionName = "PlayAreaComponent"
  self.ClassPathFilter = "STExtraPlayerCharacter"
  self.bDeathNotLeave = false
  self.bNeedCheckOverlapOnce = false
  self.bMultiTriggerCollision = false
  self.bEndPlayTriggerLeave = false
  self.ExclusiveAreaTag = "BaseLevelEnterArea"
  self.ExclusiveAreaConflictResolveMethod = 0
  self.bAreaEnabled = true
  self.bRegistToGameEventListener = false
  self.ViewPointSwitchThreshold = 0
end
function BaseLevelEnterArea:GetLifetimeReplicatedProps()
  local BaseRepTable = {}
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "bAreaEnabled",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function BaseLevelEnterArea:_PostConstruct()
  BaseLevelEnterArea.__super._PostConstruct(self)
  local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
  self.LuaDelegate = FeatureUtil.LuaDelegate()
end
function BaseLevelEnterArea:ReceiveBeginPlay()
  BaseLevelEnterArea.__super.ReceiveBeginPlay(self)
  self.OverlapList = {}
  if not slua.isValid(self.Object) then
    sandbox.LogError("BaseLevelEnterArea:ReceiveBeginPlay Self Object InValid")
    return
  end
  sandbox.LogNormal(bWriteLog and "BaseLevelEnterArea:ReceiveBeginPlay Self Object", self.Object)
  self.ActorName = UKismetSystemLibrary.GetDisplayName(self.Object)
  if self:IsDedicatedServer() and self.AreaLifeSpan ~= nil then
    self:SetAreaLifeSpan(self.AreaLifeSpan)
  end
  if self.bAreaEnabled == nil then
    self.bAreaEnabled = true
  end
  if self.PlayAreaComponent == nil then
    if self.PlayAreaTriggerVolume ~= nil then
      self.PlayAreaComponent = self.PlayAreaTriggerVolume.BrushComponent
    elseif self[self.TriggerCollisionName] ~= nil then
      self.PlayAreaComponent = self[self.TriggerCollisionName]
    end
  end
  self:RegisterEvents()
  if _G.IsEditor and _G.EDITOR_DEBUG_SHOW_PLAYAREA_COLLISION and slua.isValid(self.PlayAreaComponent) then
    self.PlayAreaComponent:SetHiddenInGame(false, true)
  end
end
function BaseLevelEnterArea:RegisterEvents()
  if self.bMultiTriggerCollision then
    if self.ClassPathFilter == "STExtraPlayerController" then
      self:RegisterViewPointTick()
    else
      self:AddControlEvent(self, "OnActorBeginOverlap", self.OnPlayAreaBeginOverlapFunc, self)
      self:AddControlEvent(self, "OnActorEndOverlap", self.OnPlayAreaEndOverlapFunc, self)
      self:AddControlEvent(self, "OnTriggeredBy", self.OnActorTriggeredBy, self)
      if self.PlayAreaTriggerVolume ~= nil then
        self:AddControlEvent(self.PlayAreaTriggerVolume, "OnComponentBeginOverlap", self.OnPlayAreaBeginOverlapFunc, self)
        self:AddControlEvent(self.PlayAreaTriggerVolume, "OnComponentEndOverlap", self.OnPlayAreaEndOverlapFunc, self)
      end
    end
  elseif slua.isValid(self.PlayAreaComponent) then
    self:AddControlEvent(self.PlayAreaComponent, "OnComponentBeginOverlap", self.OnPlayAreaBeginOverlapFunc, self)
    self:AddControlEvent(self.PlayAreaComponent, "OnComponentEndOverlap", self.OnPlayAreaEndOverlapFunc, self)
    self:AddControlEvent(self.PlayAreaComponent, "OnTriggeredBy", self.OnPlayAreaTriggeredBy, self)
  end
  if self.bRegistToGameEventListener and slua.isValid(CGameState) then
    local uGameLevelComponent = CGameState:GetComponentByClass(import("GameLevelManagerComponent"))
    if slua.isValid(uGameLevelComponent) then
      uGameLevelComponent:RegistTriggerActor(self.Object)
    end
  end
  if Client then
    self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_BEGIN_PLAY, self.OnGameStateReCreate, self)
  end
end
function BaseLevelEnterArea:ReceiveEndPlay(_, bClearTable)
  if self.LuaDelegate then
    self.LuaDelegate:Dispose()
    self.LuaDelegate = nil
  end
  self:UnRegisterEvents()
  self.OverlapList = nil
  self.ClassFilter = nil
  BaseLevelEnterArea.__super.ReceiveEndPlay(self, _, bClearTable)
end
function BaseLevelEnterArea:UnRegisterEvents()
  self:ClearComponentOverlaps()
  if self.bEndPlayTriggerLeave then
    self:ResetViewPointOverlaps()
  end
  if Client then
    self:RemoveCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_BEGIN_PLAY)
  end
  if self.bRegistToGameEventListener and slua.isValid(CGameState) then
    local uGameLevelComponent = CGameState:GetComponentByClass(import("GameLevelManagerComponent"))
    if slua.isValid(uGameLevelComponent) and slua.isValid(self.Object) then
      uGameLevelComponent:UnRegistTriggerActor(self.Object)
    end
  end
  self:UnRegisterViewPointTick()
  if self.bMultiTriggerCollision then
    if self.ClassPathFilter == "STExtraPlayerController" then
    else
      self:RemoveControlEvent(self, "OnActorBeginOverlap")
      self:RemoveControlEvent(self, "OnActorEndOverlap")
      self:RemoveControlEvent(self, "OnTriggeredBy")
      if self.PlayAreaTriggerVolume ~= nil then
        self:RemoveControlEvent(self.PlayAreaTriggerVolume, "OnComponentBeginOverlap")
        self:RemoveControlEvent(self.PlayAreaTriggerVolume, "OnComponentEndOverlap")
      end
    end
  elseif slua.isValid(self.PlayAreaComponent) then
    self:RemoveControlEvent(self.PlayAreaComponent, "OnComponentBeginOverlap")
    self:RemoveControlEvent(self.PlayAreaComponent, "OnComponentEndOverlap")
    self:RemoveControlEvent(self.PlayAreaComponent, "OnTriggeredBy")
  end
end
function BaseLevelEnterArea:OnGameStateReCreate()
  print(bWriteLog and "BaseLevelEnterArea:OnGameStateReCreate")
  if self.bRegistToGameEventListener and slua.isValid(CGameState) then
    local uGameLevelComponent = CGameState:GetComponentByClass(import("GameLevelManagerComponent"))
    if slua.isValid(uGameLevelComponent) and slua.isValid(self.Object) then
      uGameLevelComponent:RegistTriggerActor(self.Object)
    end
  end
  if self.ViewPointTickTimer ~= nil then
    self:ResetViewPointOverlaps()
  end
end
function BaseLevelEnterArea:ServerOnPlayerEnterOrLeave(uCharacter, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("BaseLevelEnterArea ServerOnPlayerEnterOrLeave bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName, uCharacter))
  if self.LuaDelegate then
    self.LuaDelegate:Broadcast("OnPlayerEnterOrLeave", uCharacter, bEnter, self)
  end
end
function BaseLevelEnterArea:ServerOnFakePlayerEnterOrLeave(uCharacter, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("BaseLevelEnterArea ServerOnFakePlayerEnterOrLeave bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName, uCharacter))
  if self.LuaDelegate then
    self.LuaDelegate:Broadcast("OnPlayerEnterOrLeave", uCharacter, bEnter, self)
  end
end
function BaseLevelEnterArea:ClientOnPlayerEnterOrLeave(uCharacter, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("BaseLevelEnterArea ClientOnPlayerEnterOrLeave bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName, uCharacter))
end
function BaseLevelEnterArea:OnActorEnterOrLeaveExclusiveArea(uOtherActor, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("BaseLevelEnterArea OnActorEnterOrLeaveExclusiveArea bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName, uOtherActor))
end
function BaseLevelEnterArea:OnOtherActorEnterOrLeave(uOtherActor, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("BaseLevelEnterArea OnOtherActorEnterOrLeave bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName, uOtherActor))
end
function BaseLevelEnterArea:ServerOnVehicleEnterOrLeave(uVehicle, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("BaseLevelEnterArea ServerOnVehicleEnterOrLeave bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName, uVehicle))
end
function BaseLevelEnterArea:ClientOnVehicleEnterOrLeave(uVehicle, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("BaseLevelEnterArea ClientOnVehicleEnterOrLeave bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName, uVehicle))
end
function BaseLevelEnterArea:IsPosInsideAreaBox(vPos)
  if USTExtraBlueprintFunctionLibrary.IsPointComponentBoxIntersection(vPos, self.PlayAreaComponent) then
    return true
  end
  return false
end
function BaseLevelEnterArea:CheckIsOfClassFilter(uOtherActor)
  if self.ClassPathFilter == nil then
    return true
  end
  local ClassPathFilterType = type(self.ClassPathFilter)
  if ClassPathFilterType == "string" and self.ClassPathFilter ~= "" then
    self.ClassFilter = import(self.ClassPathFilter)
    return Game:IsClassOf(uOtherActor, self.ClassFilter)
  elseif ClassPathFilterType == "table" then
    for _, ClassPath in pairs(self.ClassPathFilter) do
      local Class = import(ClassPath)
      if Game:IsClassOf(uOtherActor, Class) then
        return true
      end
    end
    return false
  end
  return false
end
function BaseLevelEnterArea:CheckIsAllowLeave(uOtherActor)
  if Game:IsClassOf(uOtherActor, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
    if not self.bDeathNotLeave or uOtherActor.Health > 0 or uOtherActor.NearDeatchComponent and uOtherActor.NearDeatchComponent:IsHaveLastBreathStatus() then
      return true
    else
      return false
    end
  else
    return true
  end
end
function BaseLevelEnterArea:OnAreaEnableChanged(bEnable)
end
function BaseLevelEnterArea:SetAreaEnable(bEnable)
  if not self:IsDedicatedServer() then
    return
  end
  self.bAreaEnabled = bEnable
  self:SetCollisionEnabled(bEnable)
  self:ForceNetUpdate()
  self:OnAreaEnableChanged(bEnable)
end
function BaseLevelEnterArea:OnRep_bAreaEnabled()
  if self:IsDedicatedServer() then
    return
  end
  self:SetCollisionEnabled(self.bAreaEnabled)
  self:OnAreaEnableChanged(self.bAreaEnabled)
end
function BaseLevelEnterArea:SetAreaLifeSpan(LifeSpan)
  if not self:IsDedicatedServer() then
    return
  end
  self.Area  if self.AreaCloseTimer ~= nil then
    self:RemoveGameTimer(self.AreaCloseTimer)
    self.AreaCloseTimer = nil
  end
  if self.AreaLifeSpan > 0 then
    self.AreaCloseTimer = self:AddGameTimer(self.AreaLifeSpan, false, function()
      self:SetAreaEnable(false)
      self.AreaCloseTimer = nil
    end)
  end
end
function BaseLevelEnterArea:OnPlayAreaBeginOverlapFunc(uOverlappedActorOrComp, uOtherActor)
  if self:CheckIsOfClassFilter(uOtherActor) then
    if not self:IsDedicatedServer() and not Client then
      local bIsServer = UKismetSystemLibrary.IsDedicatedServer(self.Object)
      print(bWriteLog and "BaseLevelEnterArea RoleError")
    end
    if self:IsDedicatedServer() then
      if self.bAreaEnabled and (not self.bNeedCheckOverlapOnce or self.OverlapList[uOtherActor] == nil) then
        self.OverlapList[uOtherActor] = true
        if Game:IsPlayer(uOtherActor) then
          self:ServerOnPlayerEnterOrLeave(uOtherActor, true)
        elseif Game:IsAI(uOtherActor) then
          self:ServerOnFakePlayerEnterOrLeave(uOtherActor, true)
        else
          self:OnOtherActorEnterOrLeave(uOtherActor, true)
        end
        self:OnActorCheckExclusiveAreaFunc(uOverlappedActorOrComp, uOtherActor, true)
      end
    elseif self.bAreaEnabled and (not self.bNeedCheckOverlapOnce or self.OverlapList[uOtherActor] == nil) then
      self.OverlapList[uOtherActor] = true
      if Game:IsPlayer(uOtherActor) then
        self:ClientOnPlayerEnterOrLeave(uOtherActor, true)
      else
        self:OnOtherActorEnterOrLeave(uOtherActor, true)
      end
      self:OnActorCheckExclusiveAreaFunc(uOverlappedActorOrComp, uOtherActor, true)
    end
  end
end
function BaseLevelEnterArea:OnPlayAreaEndOverlapFunc(uOverlappedActorOrComp, uOtherActor)
  if self:CheckIsOfClassFilter(uOtherActor) then
    if not self:IsDedicatedServer() and not Client then
      local bIsServer = UKismetSystemLibrary.IsDedicatedServer(self.Object)
      print(bWriteLog and "BaseLevelEnterArea RoleError")
    end
    if self:IsDedicatedServer() then
      if self:CheckIsAllowLeave(uOtherActor) then
        self.OverlapList[uOtherActor] = nil
        if Game:IsPlayer(uOtherActor) then
          self:ServerOnPlayerEnterOrLeave(uOtherActor, false)
        elseif Game:IsAI(uOtherActor) then
          self:ServerOnFakePlayerEnterOrLeave(uOtherActor, false)
        else
          self:OnOtherActorEnterOrLeave(uOtherActor, false)
        end
        self:OnActorCheckExclusiveAreaFunc(uOverlappedActorOrComp, uOtherActor, false)
      end
    elseif self:CheckIsAllowLeave(uOtherActor) then
      self.OverlapList[uOtherActor] = nil
      if Game:IsPlayer(uOtherActor) then
        self:ClientOnPlayerEnterOrLeave(uOtherActor, false)
      else
        self:OnOtherActorEnterOrLeave(uOtherActor, false)
      end
      self:OnActorCheckExclusiveAreaFunc(uOverlappedActorOrComp, uOtherActor, false)
    end
  end
end
function BaseLevelEnterArea:OnActorTriggeredBy(uVehicle, TriggerEvent)
  print(bWriteLog and string.format("BaseLevelEnterArea:OnTriggeredBy! uVehicle:%s Action:%s", tostring(uVehicle), tostring(TriggerEvent.Action)))
  if not slua.isValid(uVehicle) then
    print(bWriteLog and "BaseLevelEnterArea:OnOnTriggeredBy uVehicle is invalid!")
    return
  end
  local ETriggerAction = import("ETriggerAction")
  if TriggerEvent.Action == ETriggerAction.Enter then
    if self:IsDedicatedServer() then
      self:ServerOnVehicleEnterOrLeave(uVehicle, true)
    else
      self:ClientOnVehicleEnterOrLeave(uVehicle, true)
    end
  elseif self:IsDedicatedServer() then
    self:ServerOnVehicleEnterOrLeave(uVehicle, false)
  else
    self:ClientOnVehicleEnterOrLeave(uVehicle, false)
  end
end
function BaseLevelEnterArea:OnPlayAreaTriggeredBy(uVehicle, OtherComp, TriggerEvent)
  print(bWriteLog and string.format("BaseLevelEnterArea:OnTriggeredBy! uVehicle:%s Action:%s", tostring(uVehicle), tostring(TriggerEvent.Action)))
  if not slua.isValid(uVehicle) then
    print(bWriteLog and "BaseLevelEnterArea:OnOnTriggeredBy uVehicle is invalid!")
    return
  end
  local ETriggerAction = import("ETriggerAction")
  if TriggerEvent.Action == ETriggerAction.Enter then
    if self:IsDedicatedServer() then
      self:ServerOnVehicleEnterOrLeave(uVehicle, true)
    else
      self:ClientOnVehicleEnterOrLeave(uVehicle, true)
    end
  elseif self:IsDedicatedServer() then
    self:ServerOnVehicleEnterOrLeave(uVehicle, false)
  else
    self:ClientOnVehicleEnterOrLeave(uVehicle, false)
  end
end
function BaseLevelEnterArea:OnActorCheckExclusiveAreaFunc(uOverlappedActorOrComp, uOtherActor, bEnter)
  if uOtherActor.GetLuaFilePath == nil then
    sandbox.LogError("BaseLevelEnterArea:OnActorCheckExclusiveAreaFunc uOtherActor not hook lua", self.ActorName, uOtherActor)
    return
  end
  if self.ExclusiveAreaConflictResolveMethod ~= 0 then
    if uOtherActor.BaseLevelEnterAreaList == nil then
      uOtherActor.BaseLevelEnterAreaList = {}
      if uOtherActor.BaseLevelEnterAreaList == nil then
        sandbox.LogError("BaseLevelEnterArea:OnActorCheckExclusiveAreaFunc uOtherActor not hook lua", self.ActorName, uOtherActor)
        return
      end
    end
    if self.ExclusiveAreaTag == nil then
      return
    end
    if uOtherActor.BaseLevelEnterAreaList[self.ExclusiveAreaTag] == nil then
      uOtherActor.BaseLevelEnterAreaList[self.ExclusiveAreaTag] = {}
    end
    local BaseLevelEnterAreaList = uOtherActor.BaseLevelEnterAreaList[self.ExclusiveAreaTag]
    if bEnter then
      if self.ExclusiveAreaConflictResolveMethod == 1 then
        table.insert(BaseLevelEnterAreaList, self)
        self:OnActorEnterOrLeaveExclusiveArea(uOtherActor, true)
      elseif self.ExclusiveAreaConflictResolveMethod == 2 then
        table.insert(BaseLevelEnterAreaList, 1, self)
        if #BaseLevelEnterAreaList == 1 then
          self:OnActorEnterOrLeaveExclusiveArea(uOtherActor, true)
        end
      end
    else
      local Index = #BaseLevelEnterAreaList
      while 0 < Index do
        local Area = BaseLevelEnterAreaList[Index]
        if Area == self then
          table.remove(BaseLevelEnterAreaList, Index)
          if Index == #BaseLevelEnterAreaList + 1 then
            if Index == 1 then
              self:OnActorEnterOrLeaveExclusiveArea(uOtherActor, false)
              break
            end
            local NewArea = BaseLevelEnterAreaList[#BaseLevelEnterAreaList]
            if slua.isValid(NewArea.Object) then
              NewArea:OnActorEnterOrLeaveExclusiveArea(uOtherActor, true)
            end
          end
          break
        end
        Index = Index - 1
      end
      if Index <= 0 then
        sandbox.LogError("BaseLevelEnterArea:OnActorCheckExclusiveAreaFunc Leave NoEntered Area", self.ActorName, uOtherActor)
      end
    end
  end
end
function BaseLevelEnterArea:SetCollisionEnabled(bEnable)
  local ECollisionEnabled = import("ECollisionEnabled")
  if self.bMultiTriggerCollision then
    self:SetActorEnableCollision(bEnable)
  elseif slua.isValid(self.PlayAreaComponent) then
    if bEnable then
      self.PlayAreaComponent:SetCollisionEnabled(ECollisionEnabled.QueryOnly)
    else
      self.PlayAreaComponent:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    end
  end
end
function BaseLevelEnterArea:IsCollisionEnabled()
  if self.bMultiTriggerCollision then
    return self:GetActorEnableCollision()
  elseif slua.isValid(self.PlayAreaComponent) then
    return self.PlayAreaComponent:K2_IsCollisionEnabled()
  end
end
function BaseLevelEnterArea:GetAllOverlapActorsInArea()
  local Actor_C = import("/Script/Engine.Actor")
  local PathFilterList = {}
  local ClassPathFilterType = type(self.ClassPathFilter)
  if ClassPathFilterType == "string" and self.ClassPathFilter ~= "" then
    table.insert(PathFilterList, self.ClassPathFilter)
  elseif ClassPathFilterType == "table" then
    for _, PathFilter_C in pairs(self.ClassPathFilter) do
      table.insert(PathFilterList, PathFilter_C)
    end
  elseif ClassPathFilterType == "nil" then
    table.insert(PathFilterList, "/Script/Engine.Actor")
  end
  local AreaActorList = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
  if self.bMultiTriggerCollision then
    for _, ClassPath in ipairs(PathFilterList) do
      local PathFilter_C = import(ClassPath)
      local TempAreaActorList = self:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, Actor_C), PathFilter_C)
      if TempAreaActorList then
        for _, AreaActor in pairs(TempAreaActorList) do
          AreaActorList:Add(AreaActor)
        end
      end
    end
  elseif slua.isValid(self.PlayAreaComponent) then
    for _, ClassPath in ipairs(PathFilterList) do
      local PathFilter_C = import(ClassPath)
      local TempAreaActorList = self.PlayAreaComponent:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, Actor_C), PathFilter_C)
      if TempAreaActorList then
        for _, AreaActor in pairs(TempAreaActorList) do
          AreaActorList:Add(AreaActor)
        end
      end
    end
  end
  return AreaActorList
end
function BaseLevelEnterArea:GetAllCharacterInArea()
  local Actor_C = import("/Script/Engine.Actor")
  local PlayerPawn_C = import("STExtraPlayerCharacter")
  local AreaPlayerList
  if self.bMultiTriggerCollision then
    AreaPlayerList = self:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, Actor_C), PlayerPawn_C)
  elseif slua.isValid(self.PlayAreaComponent) then
    AreaPlayerList = self.PlayAreaComponent:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, Actor_C), PlayerPawn_C)
  end
  return AreaPlayerList
end
function BaseLevelEnterArea:IsActorInArea(uOtherActor)
  if self.bMultiTriggerCollision then
    if self.PlayAreaTriggerVolume ~= nil then
      return self:IsOverlappingActor(uOtherActor) or self.PlayAreaTriggerVolume:IsOverlappingActor(uOtherActor)
    end
    return self:IsOverlappingActor(uOtherActor)
  elseif slua.isValid(self.PlayAreaComponent) then
    return self.PlayAreaComponent:IsOverlappingActor(uOtherActor)
  end
  return false
end
function BaseLevelEnterArea:RegisterViewPointTick(TickInterval)
  self.bNeedCheckOverlapOnce = true
  if self.ViewPointTickTimer == nil then
    self.ViewPointTickTimer = self:AddGameTimer(TickInterval or 1, true, function()
      self:TickViewPoint()
    end)
    self:TickViewPoint()
    self:AddCommonEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_BEGIN, self.OnForceTickViewPoint, self)
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPostViewTargetChangeDelegate", self.OnForceTickViewPoint, self)
  end
end
function BaseLevelEnterArea:UnRegisterViewPointTick()
  if self.ViewPointTickTimer ~= nil then
    self:ResetViewPointOverlaps()
    self:RemoveGameTimer(self.ViewPointTickTimer)
    self.ViewPointTickTimer = nil
  end
end
function BaseLevelEnterArea:OnForceTickViewPoint()
  print(bWriteLog and "BaseLevelEnterArea:OnForceTickViewPoint " .. tostring(self.Object))
  self:TickViewPoint(true)
end
function BaseLevelEnterArea:ResetViewPointOverlaps()
  if self.OverlapList ~= nil then
    local TableUtil = require("common.table_util")
    local TempList = TableUtil.CopyTable(self.OverlapList)
    for uOtherActor, _ in pairs(TempList) do
      self:OnPlayAreaEndOverlapFunc(nil, uOtherActor)
    end
    self.OverlapList = {}
  end
end
function BaseLevelEnterArea:TickViewPoint(bUseViewTargetLoc)
  local uWorld
  if Client then
    uWorld = slua_GameFrontendHUD:GetWorld()
  else
    uWorld = CGameWorld
  end
  if not slua.isValid(uWorld) then
    return
  end
  if self.OverlapList == nil then
    return
  end
  local uPlayerControllerArray = Game:GetAllPlayerControllers()
  if uPlayerControllerArray then
    for _, uPlayerController in pairs(uPlayerControllerArray) do
      if slua.isValid(uPlayerController) then
        if self.ViewLoc == nil or self.ViewRot == nil then
          self.ViewLoc = uPlayerController:K2_GetActorLocation()
          self.ViewRot = uPlayerController:K2_GetActorRotation()
        end
        if bUseViewTargetLoc and slua.isValid(uPlayerController:GetViewTarget()) then
          self.ViewLoc = uPlayerController:GetViewTarget():K2_GetActorLocation()
          self.ViewRot = uPlayerController:GetViewTarget():K2_GetActorRotation()
        else
          self.ViewLoc, self.ViewRot = USTExtraBlueprintFunctionLibrary.GetPlayerViewPoint(uPlayerController, self.ViewLoc, self.ViewRot)
        end
        local BoxOrigin, BoxExtent
        BoxOrigin, BoxExtent = self:GetActorBounds(true, BoxOrigin, BoxExtent)
        if UKismetMathLibrary.IsPointInBox(self.ViewLoc, BoxOrigin, BoxExtent + FVector(2, 2, 2) * self.ViewPointSwitchThreshold) then
          local uClosestPointOnCollision = self.ViewLoc
          local Distance = USTExtraBlueprintFunctionLibrary.ActorGetDistanceToCollision(self.Object, ECollisionChannel.ECC_Pawn, self.ViewLoc, uClosestPointOnCollision)
          if Distance == 0 and self.OverlapList[uPlayerController] == nil then
            self:OnPlayAreaBeginOverlapFunc(self.Object, uPlayerController)
            self:AddControlEvent(uPlayerController, "OnEndPlay", function()
              self:OnPlayAreaEndOverlapFunc(self.Object, uPlayerController)
            end)
          elseif Distance > self.ViewPointSwitchThreshold and self.OverlapList[uPlayerController] ~= nil then
            self:RemoveControlEvent(uPlayerController, "OnEndPlay")
            self:OnPlayAreaEndOverlapFunc(self.Object, uPlayerController)
          end
        elseif self.OverlapList[uPlayerController] ~= nil then
          self:RemoveControlEvent(uPlayerController, "OnEndPlay")
          self:OnPlayAreaEndOverlapFunc(self.Object, uPlayerController)
        end
      end
    end
  end
end
function BaseLevelEnterArea:ListenOnPlayerEnterOrLeave(Callback, Caller)
  if self.LuaDelegate then
    self.LuaDelegate:Add("OnPlayerEnterOrLeave", Callback, Caller)
  end
  return self.LuaDelegate
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CBaseLevelEnterArea = class(object, nil, BaseLevelEnterArea)
return CBaseLevelEnterArea