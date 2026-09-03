local PlayerTransformDataBaseComponent = {}
local UBackpackUtils = import("BackpackUtils")
function PlayerTransformDataBaseComponent:ctor()
  self.OwnerActor = nil
  self.OwnerComp = nil
  self.bClearSaveBackpack = true
  self.bResetPawnState = true
  self.LastHeroID = 0
end
function PlayerTransformDataBaseComponent:Init(OwnerComp, OwnerActor)
  self.  self.  if not slua.isValid(self.OwnerActor) then
    log_error("debugChangeHero PlayerTransformDataComponent Init OwnerActor nil")
  end
end
function PlayerTransformDataBaseComponent:ResetCharacterAttr()
  local uCharacter = self:GetCharacter()
  if slua.isValid(uCharacter) then
    if self.bResetPawnState then
      uCharacter:CharacterStateReset()
    end
    if slua.isValid(uCharacter.BuffSystem) then
      uCharacter.BuffSystem:RemoveAllBuffs(true)
    end
    uCharacter:ResetCharacterEnergy()
    local GotoHeroID = self.OwnerComp:GetGoToHeroID()
    local CurrentHeroID = self.OwnerComp:GetHeroID()
    if 0 < CurrentHeroID and 0 < GotoHeroID then
      print(bWriteLog and "debugChangeHero HeroChangeHero !SetHealth")
    else
      local ERecoveryReasonType = import("ERecoveryReasonType")
      uCharacter:SetHealthSafety(uCharacter.HealthMax, ERecoveryReasonType.ERecoveryReason_RescueByTeammate)
    end
  end
end
function PlayerTransformDataBaseComponent:EnterHero(InHeroID)
  if not slua.isValid(self.OwnerActor) then
    printf("debugChangeHero PlayerTransformDataBaseComponent EnterHero OwnerActor nil")
    return
  end
  self:StopAllSkill()
  if self.OwnerActor:IsAuthority() then
    if self.bClearSaveBackpack == true then
      self:SaveAndClearBackpackItem(InHeroID)
    end
    self:TriggerActions(InHeroID)
  else
    self.LastHeroID = InHeroID
  end
end
function PlayerTransformDataBaseComponent:ExitHero(bForceExit)
  if not slua.isValid(self.OwnerActor) then
    printf("debugChangeHero PlayerTransformDataBaseComponent ExitHero OwnerActor nil")
    return
  end
  printf("debugChangeHero PlayerTransformDataBaseComponent ExitHero StopAllSkill")
  self:StopAllSkill()
  if self.OwnerActor:IsAuthority() then
    local CurrentHeroID = self.OwnerComp:GetHeroID()
    if CurrentHeroID <= 0 and not bForceExit then
      printf("debugChangeHero PlayerTransformDataBaseComponent ExitHero CurrentHeroID <= 0")
      return
    end
    local uCharacter = self:GetCharacter()
    if slua.isValid(uCharacter) then
      self:TriggerBackActions()
      self:ResetCharacterAttr()
      if self.bClearSaveBackpack == true then
        self:RecoverBackpackItem(CurrentHeroID)
      end
    end
  else
  end
end
function PlayerTransformDataBaseComponent:TriggerActions(InHeroID)
  local uCharacter = self:GetCharacter()
  local PlayerEventSubsystem = SubsystemMgr:Get("PlayerEventSystem")
  if PlayerEventSubsystem and slua.isValid(uCharacter) then
    self:ResetCharacterAttr()
    PlayerEventSubsystem:ActiveEventByFilterKey(self.OwnerActor.PlayerKey, "EVENTTYPE_PLAYEREVENT_CHARACTER", "EVENTID_PLAYEREVENT_TRANSFORM", true)
    if PlayerEventSubsystem:CheckNeedPostEventWithFilterKey(self.OwnerActor.PlayerKey, "EVENTTYPE_PLAYEREVENT_CHARACTER", "EVENTID_PLAYEREVENT_TRANSFORM", true) then
      local ActionID = 0
      local HeroData = CDataTable.GetTableData("HeroTable", InHeroID)
      if HeroData and HeroData.ActionID ~= nil then
        ActionID = HeroData.ActionID
      end
      printf("debugChangeHero PlayerTransformDataComponent EnterHero postEvent InHeroID:%d, ActionID:%d", InHeroID, ActionID)
      EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_TRANSFORM, self.OwnerActor.PlayerKey, uCharacter, ActionID, InHeroID)
    end
    PlayerEventSubsystem:ActiveEventByFilterKey(self.OwnerActor.PlayerKey, "EVENTTYPE_PLAYEREVENT_CHARACTER", "EVENTID_PLAYEREVENT_TRANSFORM", false)
  end
end
function PlayerTransformDataBaseComponent:TriggerBackActions()
  local CurrentHeroID = self.OwnerComp:GetHeroID()
  if CurrentHeroID == 0 then
    CurrentHeroID = self.LastHeroID
  end
  local uCharacter = self:GetCharacter()
  local PlayerEventSubsystem = SubsystemMgr:Get("PlayerEventSystem")
  if PlayerEventSubsystem and slua.isValid(uCharacter) then
    PlayerEventSubsystem:ActiveEventByFilterKey(self.OwnerActor.PlayerKey, "EVENTTYPE_PLAYEREVENT_CHARACTER", "EVENTID_PLAYEREVENT_TRANSFORMBACK", true)
    if PlayerEventSubsystem:CheckNeedPostEventWithFilterKey(self.OwnerActor.PlayerKey, "EVENTTYPE_PLAYEREVENT_CHARACTER", "EVENTID_PLAYEREVENT_TRANSFORMBACK", true) then
      local ActionID = 0
      local HeroData = CDataTable.GetTableData("HeroTable", CurrentHeroID)
      if HeroData and HeroData.ActionID ~= nil then
        ActionID = HeroData.ActionID
      end
      printf("debugChangeHero PlayerTransformDataBaseComponent ExitHero postEvent CurrentHeroID:%d, ActionID:%d", CurrentHeroID, ActionID)
      EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_TRANSFORMBACK, self.OwnerActor.PlayerKey, uCharacter, ActionID, CurrentHeroID)
    end
    PlayerEventSubsystem:ActiveEventByFilterKey(self.OwnerActor.PlayerKey, "EVENTTYPE_PLAYEREVENT_CHARACTER", "EVENTID_PLAYEREVENT_TRANSFORMBACK", false)
  end
end
function PlayerTransformDataBaseComponent:TriggerEvents(strEventType)
end
function PlayerTransformDataBaseComponent:SaveAndClearBackpackItem(AimHeroID)
  local uCharacter = self:GetCharacter()
  if slua.isValid(uCharacter) then
    local OwnerController = uCharacter:GetControllerSafety()
    if slua.isValid(OwnerController) then
      local EClearAndRecoverMethod = import("EClearAndRecoverMethod")
      OwnerController:SetClearAndRecoverStrategyName("NotClearEmoteClassStrategy", EClearAndRecoverMethod.Transform)
      OwnerController:SaveAndClearBackpackItem()
    end
  end
end
function PlayerTransformDataBaseComponent:RecoverBackpackItem(CurrentHeroID)
  local uCharacter = self:GetCharacter()
  if slua.isValid(uCharacter) then
    local OwnerController = uCharacter:GetControllerSafety()
    if slua.isValid(OwnerController) then
      OwnerController:RecoverBackpackItem()
    end
  end
end
function PlayerTransformDataBaseComponent:StopAllSkill()
  if not slua.isValid(self.OwnerActor) then
    return
  end
  local uPlayerCharacter = self.OwnerActor:GetPlayerCharacterSafety()
  if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
    local uSkillManagerComp = uPlayerCharacter:GetSkillManager()
    if slua.isValid(uSkillManagerComp) then
      local UTSkillStopReason = import("UTSkillStopReason")
      printf("debugChangeHero PlayerTransformDataBaseComponent StopAllSkill")
      uSkillManagerComp:StopSkillAll(UTSkillStopReason.SkillStopReason_Interrupted)
      return
    end
  end
  log_error("debugChangeHero PlayerTransformDataBaseComponent StopAllSkill failed")
end
function PlayerTransformDataBaseComponent:GetCharacter()
  return self.OwnerComp:GetCharacter()
end
function PlayerTransformDataBaseComponent:CheckForceExitHero()
  return false
end
local class = require("class")
local object = require("common.delegate_container")
local CPlayerTransformDataBaseComponent = class(object, nil, PlayerTransformDataBaseComponent)
return CPlayerTransformDataBaseComponent