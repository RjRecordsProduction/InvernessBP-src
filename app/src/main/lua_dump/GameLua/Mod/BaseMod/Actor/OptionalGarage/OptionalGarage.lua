local OptionalGarage = {
  MulticastRPC = {
    MulticastRPC_VehicleActive = {
      Params = {
        import("/Script/Engine.Actor")
      },
      Reliable = true
    }
  }
}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local ECollisionEnabled = import("ECollisionEnabled")
OptionalGarage.EState = {
  None = 0,
  Opening = 1,
  Opened = 2
}
function OptionalGarage:ctor()
  self.SeqActor = nil
  self.SeqActorPath = "/Game/Library/Res/Actors/OptionalGarage/BluePrints/OptionalGarageSequenceActor.OptionalGarageSequenceActor_C"
  self.SeqPath = "/Game/Library/Res/Actors/OptionalGarage/Arts_Scenes/LevelSeq/OptionalGarage2900_Seq.OptionalGarage2900_Seq"
  self.bClose = false
end
function OptionalGarage:ReceiveBeginPlay()
  OptionalGarage.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "OptionalGarage:ReceiveBeginPlay")
  self.bRelevantForNetworkReplays = true
end
function OptionalGarage:_PostConstruct()
  OptionalGarage.__super._PostConstruct(self)
  self.SM:Init({
    {
      Id = OptionalGarage.EState.None,
      Name = "None"
    },
    {
      Id = OptionalGarage.EState.Opening,
      Name = "Opening"
    },
    {
      Id = OptionalGarage.EState.Opened,
      Name = "Opened"
    }
  }, OptionalGarage.EState.None)
  self.SM:OnStateChanged(self.OnStateChanged, self)
  print(bWriteLog and "OptionalGarage:_PostConstruct")
  self.bRelevantForNetworkReplays = true
end
function OptionalGarage:OnStateChanged(StateID)
  print(bWriteLog and "OptionalGarage:OnStateChanged " .. StateID)
  if not slua.isValid(self.Object) then
    return
  end
  if StateID == OptionalGarage.EState.None then
    self.MainDoorOpenedCollision:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    self.MainDoorClosedCollision:SetCollisionEnabled(ECollisionEnabled.QueryOnly)
  end
  if StateID == OptionalGarage.EState.Opening then
    self.MainDoorOpenedCollision:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    self.MainDoorClosedCollision:SetCollisionEnabled(ECollisionEnabled.NoCollision)
  end
  if StateID == OptionalGarage.EState.Opened then
    self.MainDoorOpenedCollision:SetCollisionEnabled(ECollisionEnabled.QueryOnly)
    self.MainDoorClosedCollision:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    self.SlideDoor1:SetHiddenInGame(true, true)
    self.SlideDoor1:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    self.SlideDoor2:SetHiddenInGame(true, true)
    self.SlideDoor2:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    self.Window1:SetHiddenInGame(true, true)
    self.Window1:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    self.Window2:SetHiddenInGame(true, true)
    self.Window2:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    self.Window3:SetHiddenInGame(true, true)
    self.Window3:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    if Client then
      self:BP_PlayDoorOpenIdle()
    end
  end
end
function OptionalGarage:OnAllowToInteract(character, Component)
  return not self.bClose
end
function OptionalGarage:OnClientClickInteractiveButton(Character, Component)
  OptionalGarage.__super.OnClientClickInteractiveButton(self, Character, Component)
  if not UIManager.IsUIShow(UIManager.UI_Config_InGame.OptionalGarageUI) then
    UIManager.ShowUI(UIManager.UI_Config_InGame.OptionalGarageUI, self)
  end
end
function OptionalGarage:CloseUI(component)
  OptionalGarage.__super.CloseUI(self, component)
  if UIManager and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.OptionalGarageUI then
    UIManager.CloseUI(UIManager.UI_Config_InGame.OptionalGarageUI)
  end
end
function OptionalGarage:VerifyVehicleItemID(nVehicleItemID)
  local OptionalGarageVehicleConfig = GamePlayTools.GetCurrentConfig("OptionalGarageVehicleConfig")
  if not OptionalGarageVehicleConfig then
    print(bWriteLog and "OptionalGarage:VerifyVehicleItemID invalid OptionalGarageVehicleConfig")
  end
  local MapType = GameMainConfig.GetMapType()
  local TableUtil = require("common.table_util")
  local FinalConfig = TableUtil.CopyTable(OptionalGarageVehicleConfig.Default)
  local MapConfig = OptionalGarageVehicleConfig[MapType]
  TableUtil.OverrideTable(FinalConfig, MapConfig)
  for VehicleItemID, sPath in pairs(FinalConfig) do
    if VehicleItemID == nVehicleItemID and sPath ~= nil then
      return sPath
    end
  end
  return nil
end
function OptionalGarage:ServerChooseVehicle(uPlayerController, nVehicleItemID)
  if Client or not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "OptionalGarage:ServerChooseVehicle() invalid uPlayerCharacter")
    return
  end
  print(bWriteLog and "OptionalGarage:ServerChooseVehicle() " .. nVehicleItemID)
  local VehicleClassPath = self:VerifyVehicleItemID(nVehicleItemID)
  if not VehicleClassPath then
    print(bWriteLog and "OptionalGarage:ServerChooseVehicle invalid nVehicleItemID " .. nVehicleItemID)
    return
  end
  if not self:GetInteractiveComponent():IsInteractionEffective(uPlayerCharacter, 0) or not self:GetInteractiveComponent():IsCharacterOverlapping(uPlayerCharacter) then
    print(bWriteLog and "OptionalGarage:ServerChooseVehicle() not in area ")
    return
  end
  local VehicleClass = slua.loadObject(VehicleClassPath)
  if not VehicleClass then
    print(bWriteLog and "OptionalGarage:ServerChooseVehicle invalid VehicleClass nVehicleItemID=" .. nVehicleItemID)
    return
  end
  local uLoc = self.VehicleSpawnPoint:K2_GetComponentLocation() + FVector(0, 0, 10)
  local uRot = self.VehicleSpawnPoint:K2_GetComponentRotation()
  local uVehicle = CGameWorld:SpawnActor(VehicleClass, uLoc, uRot, nil)
  if slua.isValid(uVehicle) then
    self:AddGameTimer(1, false, function()
      if slua.isValid(uVehicle) then
        self:MulticastRPC_VehicleActive(uVehicle)
      end
    end)
    self.bClose = true
  end
  local SequenceTransform = self:GetTransform()
  self.SeqActor = Game:PlayLevelSequence(self, self.SeqPath, SequenceTransform, self.SeqActorPath, true, {
    OptionalGarage = self.Object
  })
  self:AddGameTimer(0.6, false, function()
    self.SM:SetState(OptionalGarage.EState.Opening)
  end)
  self:AddGameTimer(6.0, false, function()
    self.SM:SetState(OptionalGarage.EState.Opened)
  end)
end
function OptionalGarage:MulticastRPC_VehicleActive(uVehicle)
  if slua.isValid(uVehicle) then
    uVehicle:SetPhysActive(true, -1)
  end
end
local Class = require("class")
local CInteractiveActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local COptionalGarage = Class(CInteractiveActorBase, nil, OptionalGarage)
return require("combine_class").DeclareFeature(COptionalGarage, {
  {
    SM = "GameLua.Mod.BaseMod.GamePlay.Feature.Common.StateMachineFeature"
  }
}, "OptionalGarage")