local UKismetSystemLibrary = import("KismetSystemLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local PlayerTransformComponent = {}
function PlayerTransformComponent:ctor()
  self.GoingToHeroID = 0
  self.EnterHeroOnce = false
  self.OwnerActor = nil
end
function PlayerTransformComponent:_PostConstruct()
  PlayerTransformComponent.__super._PostConstruct(self)
  local DataCompPath = self.TransformDataComponentPath
  local TransformDataCompClass = require(DataCompPath)
  self.TransformDataComp = TransformDataCompClass()
  printf("debugChangeHero PlayerTransformComponent self.TransformDataComp:", self.TransformDataComp)
  self.OwnerActor = self:GetOwner()
  if not slua.isValid(self.OwnerActor) then
    log_error("debugChangeHero PlayerTransformComponent self.OwnerActor not valid")
    return
  end
  if not self.OwnerActor.GetPlayerCharacterSafety then
    log_error("debugChangeHero PlayerTransformComponent self.OwnerActor self:GetPlayerCharacterSafety() not valid")
  end
  self.TransformDataComp:Init(self, self.OwnerActor)
  if not UKismetSystemLibrary.IsDedicatedServer(self.Object) then
    self:AddControlEvent(self.OwnerActor, "OnSpectatorChange", self.HandleSpectatorChange, self)
    if self.bLocalBindCameraSwitch and self.OwnerActor:IsLocalController() then
      self:AddControlEvent(self.OwnerActor, "OnSwitchCameraModeStart", self.HandleSwitchCameraMode, self)
    end
  end
end
function PlayerTransformComponent:ReceiveBeginPlay()
  PlayerTransformComponent.__super.ReceiveBeginPlay(self)
  printf("debugChangeHero PlayerTransformComponent ReceiveBeginPlay self:%s", UKismetSystemLibrary.GetDisplayName(self))
  self.CheckForceExitHeroTimer = self:AddGameTimer(5, true, function()
    self:CheckForceExitHero()
  end)
end
function PlayerTransformComponent:ServerChooseHeroCheck(HeroID, bForce)
  return true
end
function PlayerTransformComponent:ServerChooseHero(HeroID, bForce)
  local uCharacter = self:GetCharacter()
  if not slua.isValid(uCharacter) then
    return
  end
  local CurrentHeroID = self:GetHeroID()
  if not bForce and CurrentHeroID == HeroID then
    return
  end
  self.GoingTo  printf("debugChangeHero PlayerTransformComponent ServerChooseHero HeroID:%d", HeroID)
  if slua.isValid(self.OwnerActor) and self.OwnerActor:IsAuthority() then
    if 0 < HeroID and HeroID < UEnums.HeroID.MaxHero then
      local uPlayerCharacter = self.OwnerActor:GetPlayerCharacterSafety()
      if slua.isValid(uPlayerCharacter) and uPlayerCharacter.AddTransfromSkillToken then
        uPlayerCharacter:AddTransfromSkillToken()
      end
    elseif 0 < CurrentHeroID then
      local uPlayerCharacter = self.OwnerActor:GetPlayerCharacterSafety()
      if slua.isValid(uPlayerCharacter) and uPlayerCharacter.AddTransfromBackSkillToken then
        uPlayerCharacter:AddTransfromBackSkillToken()
      end
    end
    if 0 < CurrentHeroID and 0 < HeroID then
      self:ChangeHeroToNewHero(HeroID)
    elseif 0 < CurrentHeroID and HeroID <= 0 then
      self:ChangeHeroToHuman()
    elseif CurrentHeroID <= 0 and 0 < HeroID then
      self:ChangeHumanToHero(HeroID)
    elseif CurrentHeroID <= 0 and HeroID <= 0 then
      printf("debugChangeHero PlayerTransformComponent CurrentHeroID <= 0 and HeroID <= 0")
    end
  end
  self.GoingToHeroID = 0
end
function PlayerTransformComponent:LocalControllerSetHeroData(HeroID, uPawn)
  if HeroID == nil then
    return
  end
  if Client and self.TransformDataComp then
    self.uEnterCharacter = uPawn
    if 0 < HeroID then
      self.EnterHeroOnce = true
      self.TransformDataComp:EnterHero(HeroID)
    else
      self.TransformDataComp:ExitHero()
    end
  end
end
function PlayerTransformComponent:TriggerEvents(strEventType)
  if Client then
    return
  end
  if self.TransformDataComp then
    self.TransformDataComp:TriggerEvents(strEventType)
  end
end
function PlayerTransformComponent:GetCharacter()
  if self.uEnterCharacter ~= nil then
    return self.uEnterCharacter
  end
  if not slua.isValid(self.OwnerActor) then
    printf("debugChangeHero GetCharacter self.OwnerActor nil")
    return nil
  end
  local uCharacter = self.OwnerActor:GetPlayerCharacterSafety()
  if not slua.isValid(uCharacter) then
    uCharacter = self.OwnerActor:GetCurPawn()
    if not slua.isValid(uCharacter) then
      printf("debugChangeHero GetCharacter self.OwnerActor nil")
      return nil
    end
  end
  return uCharacter
end
function PlayerTransformComponent:GetHeroID()
  local uCharacter = self:GetCharacter()
  if slua.isValid(uCharacter) and uCharacter.HeroPropFeature then
    local HeroID = uCharacter.HeroPropFeature:GetCurrentHeroID()
    return math.floor(HeroID + 0.1)
  elseif slua.isValid(uCharacter) and uCharacter.GetCurrentHeroID then
    local HeroID = uCharacter:GetCurrentHeroID()
    return math.floor(HeroID + 0.1)
  end
  return 0
end
function PlayerTransformComponent:GetGoToHeroID()
  return self.GoingToHeroID
end
function PlayerTransformComponent:ChangeHumanToHero(HeroID)
  if not slua.isValid(self.OwnerActor) then
    return
  end
  self:SwitchCameraMode(true)
  self.TransformDataComp:EnterHero(HeroID)
  local HeroData = CDataTable.GetTableData("HeroTable", HeroID)
  if HeroData and HeroData.ChangeSkillID > 0 then
    local uPlayerCharacter = self.OwnerActor:GetPlayerCharacterSafety()
    if uPlayerCharacter and slua.isValid(uPlayerCharacter) and not uPlayerCharacter.bEnsure then
      printf("debugChangeHero PlayerTransformComponent ChangeHumanToHero self.PlayerKey:%u SKillID:%d", self.OwnerActor.PlayerKey, HeroData.ChangeSkillID)
      uPlayerCharacter:TriggerEntrySkillWithID(HeroData.ChangeSkillID, true)
    end
  end
end
function PlayerTransformComponent:ChangeHeroToNewHero(HeroID)
  if not slua.isValid(self.OwnerActor) then
    return
  end
  self.TransformDataComp:ExitHero()
  self.TransformDataComp:EnterHero(HeroID)
  local HeroData = CDataTable.GetTableData("HeroTable", HeroID)
  if HeroData and HeroData.ChangeSkillID > 0 then
    local uPlayerCharacter = self.OwnerActor:GetPlayerCharacterSafety()
    if uPlayerCharacter and slua.isValid(uPlayerCharacter) and not uPlayerCharacter.bEnsure then
      printf("debugChangeHero PlayerTransformComponent ChangeHumanToHero self.PlayerKey:%u SKillID:%d", self.OwnerActor.PlayerKey, HeroData.ChangeSkillID)
      uPlayerCharacter:TriggerEntrySkillWithID(HeroData.ChangeSkillID, true)
    end
  end
end
function PlayerTransformComponent:ChangeHeroToHuman()
  self.TransformDataComp:ExitHero()
  self:SwitchCameraMode(false)
  self:TriggerExitHeroSkill()
  self.uEnterCharacter = nil
end
function PlayerTransformComponent:TriggerExitHeroSkill()
  if not slua.isValid(self.OwnerActor) then
    return
  end
  local CurrentHeroID = self:GetHeroID()
  local HeroData = CDataTable.GetTableData("HeroTable", CurrentHeroID)
  if HeroData and HeroData.ChangeBackSkillID > 0 then
    local uPlayerCharacter = self.OwnerActor:GetPlayerCharacterSafety()
    if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
      printf("debugChangeHero PlayerTransformComponent TriggerChangeHeroSkill self.PlayerKey:%u SKillID:%d", self.OwnerActor.PlayerKey, HeroData.ChangeBackSkillID)
      uPlayerCharacter:TriggerEntrySkillWithID(HeroData.ChangeBackSkillID, true)
    end
  end
end
function PlayerTransformComponent:SwitchCameraMode(bEnter)
  if self.bLocalBindCameraSwitch then
    local uCharacter = self:GetCharacter()
    local EPawnState = import("EPawnState")
    if slua.isValid(uCharacter) then
      if bEnter then
        uCharacter.IsNetFPP = false
        uCharacter:SetPawnStateDisabled(EPawnState.SwitchPP, true)
      else
        uCharacter.IsNetFPP = false
        uCharacter:ResetPawnStateDisabled(EPawnState.SwitchPP)
      end
    end
  end
end
function PlayerTransformComponent:ForceExitHero()
  if not slua.isValid(self.OwnerActor) then
    return
  end
  if self.OwnerActor:IsAuthority() and self.OwnerActor.HeroPropFeature and self.OwnerActor.HeroPropFeature.ServerChooseHeroData then
    printf("debugChangeHero DS ForceExitHero")
    self.OwnerActor.HeroPropFeature:ServerChooseHeroData(0)
    self.TransformDataComp:ExitHero(true)
    self:SwitchCameraMode(false)
  else
    printf("debugChangeHero AutonomousOrObserver ForceExitHero")
    self.TransformDataComp:ExitHero(true)
  end
  self.uEnterCharacter = nil
end
function PlayerTransformComponent:CheckForceExitHero()
  if self.EnterHeroOnce then
    local IsNeedForceExist = self.TransformDataComp:CheckForceExitHero()
    if IsNeedForceExist then
      self:ForceExitHero()
    end
  end
end
function PlayerTransformComponent:HandleSpectatorChange()
  if UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  local uOwnerActor = self:GetOwner()
  if not slua.isValid(uOwnerActor) then
    return
  end
  local uViewPawn = uOwnerActor:GetCurPawn()
  if slua.isValid(uViewPawn) and uViewPawn.HeroPropFeature then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local CommonFightTransformConfig = GamePlayTools.GetCurrentConfig("CommonFightTransformConfig")
    if CommonFightTransformConfig and CommonFightTransformConfig:CheckFightTransform(uViewPawn.HeroPropFeature:GetCurrentHeroID()) then
      print(bWriteLog and "CommonPlayerTransformDataComponent:HandleSpectatorChange CommonFightTransformConfig")
    else
      self:LocalControllerSetHeroData(uViewPawn.HeroPropFeature:GetCurrentHeroID(), uViewPawn)
    end
  end
end
function PlayerTransformComponent:HandleSwitchCameraMode(NewMode)
  if UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  local uOwnerActor = self:GetOwner()
  if not slua.isValid(uOwnerActor) then
    return
  end
  local uViewPawn = uOwnerActor:GetCurPawn()
  if slua.isValid(uViewPawn) and uViewPawn.HeroPropFeature then
    self:LocalControllerSetHeroData(uViewPawn.HeroPropFeature:GetCurrentHeroID(), uViewPawn)
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CCharacterCarryBackComponent = class(CActorComponentBase, nil, PlayerTransformComponent)
return CCharacterCarryBackComponent