local KismetMathLibrary = import("KismetMathLibrary")
local InteractiveDisplayStand = {}
function InteractiveDisplayStand:ReceiveBeginPlay()
  InteractiveDisplayStand.__super.ReceiveBeginPlay(self)
  if self.hasAuthority then
    self.SpawnedObject = nil
    self.SpawnTimer = nil
    self:SpawnObject()
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.OnGameFighting, self)
  elseif slua.isValid(CGameState) and CGameState.GetGameModeState and CGameState:GetGameModeState() == "FightingState" then
    self:SetActorHiddenInGame(true)
    self:SetActorEnableCollision(false)
    self:SetActorTickEnabled(false)
  end
end
function InteractiveDisplayStand:OnGameFighting()
  if self.hasAuthority then
    print(bWriteLog and "InteractiveDisplayStand:OnGameFighting, Clear DisplayStand in BornLand")
    if self.SpawnTimer then
      self:RemoveGameTimer(self.SpawnTimer)
      self.SpawnTimer = nil
      print(bWriteLog and "InteractiveDisplayStand:OnGameFighting, Remove SpawnTimer")
    end
    if slua.isValid(self.SpawnedObject) then
      self:RemoveControlEvent(self.SpawnedObject, "OnWrapperPickedUp")
      self.SpawnedObject:K2_DestroyActor()
      print(bWriteLog and "InteractiveDisplayStand:OnGameFighting, Destroy SpawnedObject")
    end
    if slua.isValid(self.Object) then
      self:K2_DestroyActor()
      print(bWriteLog and "InteractiveDisplayStand:OnGameFighting, Destroy Actor")
    end
  end
end
function InteractiveDisplayStand:MustCheckResultAfterSkillFinished(Character, Result, Component)
  InteractiveDisplayStand.__super.MustCheckResultAfterSkillFinished(self, Character, Result, Component)
  print(bWriteLog and "InteractiveDisplayStand:MustCheckResultAfterSkillFinished, self.hasAuthority = " .. tostring(self.hasAuthority) .. ", Result = " .. tostring(Result))
  if Result == false then
    return
  end
  Component = Component or self:GetInteractiveComponent()
  if not self.hasAuthority then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
    if slua.isValid(MainControlBaseUI) then
      MainControlBaseUI:ShowEntireMapWindow()
      local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
      local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
      if EntireMapUI then
        EntireMapUI:SelectGameGuide(true)
        local GameGuideUIMain = UIManager.GetUI(UIManager.UI_Config_InGame.GameGuideUIMain)
        if GameGuideUIMain and self.SpawnedItemID then
          print(bWriteLog and "InteractiveDisplayStand:MustCheckResultAfterSkillFinished, SpawnedItemID = ", self.SpawnedItemID)
          GameGuideUIMain:ShowSelectItem(self.SpawnedItemID)
        end
      end
    end
    self:CloseUI(Component)
  end
end
function InteractiveDisplayStand:SpawnObject()
  if not self.SpawnedItemID or Client then
    print(bWriteLog and "InteractiveDisplayStand:SpawnObject, SpawnedItemID is nil")
    return
  end
  local WrapperActorClassPath = self:GetWrapperActorClassPath(self.SpawnedItemID)
  if not WrapperActorClassPath then
    print(bWriteLog and "InteractiveDisplayStand:SpawnObject, Failed to get WrapperActorClassPath for ItemID: " .. tostring(self.SpawnedItemID))
    return
  end
  local Transform = self:GetTransform()
  local PlaceWorldLocation = KismetMathLibrary.TransformLocation(Transform, self.SpawnedPosition)
  local PlaceWorldRotation = KismetMathLibrary.TransformRotation(Transform, self.SpawnedRotator)
  local UGameplayStatics = import("GameplayStatics")
  local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
  if not WrapperActorClassPath or WrapperActorClassPath == "" then
    print(bWriteLog and "InteractiveDisplayStand:SpawnObject - WrapperActorClassPath is empty")
    return
  end
  local FormattedPath = WrapperActorClassPath
  if not string.find(FormattedPath, "_C$") then
    FormattedPath = FormattedPath .. "_C"
  end
  local bSuccess, WrapperActorClass = pcall(import, FormattedPath)
  if not bSuccess or not WrapperActorClass then
    print(bWriteLog and string.format("InteractiveDisplayStand:SpawnObject - Failed to import class: %s", tostring(FormattedPath)))
    return
  end
  local SpawnTransform = FTransform(PlaceWorldRotation, PlaceWorldLocation, self.SpawnedScale)
  self.SpawnedObject = UGameplayStatics.BeginDeferredActorSpawnFromClass(CGameWorld, WrapperActorClass, SpawnTransform, ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil)
  if slua.isValid(self.SpawnedObject) then
    UGameplayStatics.FinishSpawningActor(self.SpawnedObject, SpawnTransform)
    print(bWriteLog and "UAVCreateSkillActorSystem:RealCreateActor over")
    self:AddControlEvent(self.SpawnedObject, "OnWrapperPickedUp", self.OnItemPickedUp, self)
    if self.SpawnedObject.bDeavtivateParticle ~= nil then
      self.SpawnedObject.bDeavtivateParticle = true
    end
    local ParticleSystemComponentClass = import("/Script/Engine.ParticleSystemComponent")
    local ParticleSystemComponent = self.SpawnedObject:GetComponentByClass(ParticleSystemComponentClass)
    if ParticleSystemComponent and slua.isValid(ParticleSystemComponent) then
      ParticleSystemComponent:Deactivate()
    end
    print(bWriteLog and "InteractiveDisplayStand:SpawnObject, Spawned ItemID: " .. tostring(self.SpawnedItemID) .. ", Path: " .. WrapperActorClassPath)
    if self.SpawnedObject.AddToAIWorldCell then
      self:AddWrapperActorToAIWorld(self.SpawnedObject)
      print(bWriteLog and "InteractiveDisplayStand:SpawnObject, Added to AI world cell")
    end
  else
    print(bWriteLog and "InteractiveDisplayStand:SpawnObject, Failed to spawn actor")
  end
end
function InteractiveDisplayStand:GetWrapperActorClassPath(ItemId)
  local ItemDropMgr = CGameMode.BP_ItemDropMgr
  if not slua.isValid(ItemDropMgr) then
    print(bWriteLog and "InteractiveDisplayStand:GetWrapperActorClassPath, ItemDropMgr is not valid")
    return
  end
  local ItemData = CDataTable.GetTableData("Item", ItemId)
  if not ItemData then
    print(bWriteLog and string.format("InteractiveDisplayStand:GetWrapperActorClassPath, ItemId = %s ItemData is not valid", ItemId))
    return
  end
  local FItemDefineID = import("ItemDefineID")
  local ItemDefineID = FItemDefineID(ItemData.ItemType, ItemId)
  local WrapperActorClassPath = ItemDropMgr:GetWrapperActorPath(ItemDefineID)
  if not WrapperActorClassPath then
    print(bWriteLog and string.format("InteractiveDisplayStand:GetWrapperActorClassPath, ItemId = %s GetWrapperActorPath is not valid", ItemId))
    return
  end
  return WrapperActorClassPath
end
function InteractiveDisplayStand:OnItemPickedUp()
  print(bWriteLog and string.format("InteractiveDisplayStand:OnItemPickedUp, The display item is picked up, respawn after %ss", self.SpawnedInterval))
  self.SpawnTimer = self:AddGameTimer(self.SpawnedInterval, false, function()
    self:SpawnObject()
    self:RemoveGameTimer(self.SpawnTimer)
    self.SpawnTimer = nil
  end)
  if slua.isValid(self.SpawnedObject) then
    self:RemoveControlEvent(self.SpawnedObject, "OnWrapperPickedUp")
  end
end
function InteractiveDisplayStand:AddWrapperActorToAIWorld(uActor)
  if Client then
    return
  end
  if slua.isValid(uActor) then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SPAWN_WRAPPER_ACTOR_ADD_TO_AIWORLD, uActor)
  end
end
local class = require("class")
local CInteractiveActorTemplate = require("GameLua.Mod.BaseMod.GamePlay.Actor.InteractiveActorTemplate")
local CInteractiveDisplayStand = class(CInteractiveActorTemplate, nil, InteractiveDisplayStand)
return CInteractiveDisplayStand