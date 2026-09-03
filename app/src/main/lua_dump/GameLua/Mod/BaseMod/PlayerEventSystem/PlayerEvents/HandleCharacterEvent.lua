local HandleCharacterEvent = {}
function HandleCharacterEvent:ctor(selfType)
end
function HandleCharacterEvent:Init(gameState, bClient, tableData, actionMgr)
  HandleCharacterEvent.__super.Init(self, gameState, bClient, tableData, actionMgr)
end
function HandleCharacterEvent:PlayerDie(nEventType, nEventID, nPlayerKey)
  local ConditionEntry = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ConditionEntry")
  ConditionEntry.DeactivateEventsByFilterKey(nPlayerKey)
  if self.EventActionMgr then
    self.EventActionMgr:Clear(nPlayerKey)
  end
end
function HandleCharacterEvent:ReceivePlayerAttrEvent(nEventType, nEventID, ...)
  local paramTable = {
    ...
  }
  local uPawn = paramTable[1]
  local nPlayerKey = 0
  if uPawn then
    nPlayerKey = uPawn.PlayerKey
  end
  self.EventActionMgr:TriggerPlayerEvent(nPlayerKey, nEventType, nEventID, ...)
end
function HandleCharacterEvent:HandlePlayerKillPawn(nEventType, nEventID, nPlayerKey, nDeadCharacter, CustomDamageInfo)
  local targetCharacter = self:GetCharacter(nPlayerKey)
  self.EventActionMgr:TriggerPlayerEvent(nPlayerKey, nEventType, nEventID, targetCharacter, nDeadCharacter, CustomDamageInfo)
end
function HandleCharacterEvent:HandlePlayerEnterState(nEventType, nEventID, nPlayerKey, ...)
  self.EventActionMgr:TriggerPlayerEvent(nPlayerKey, nEventType, nEventID, ...)
end
function HandleCharacterEvent:HandlePlayerLeaveState(nEventType, nEventID, nPlayerKey, ...)
  self.EventActionMgr:TriggerPlayerEvent(nPlayerKey, nEventType, nEventID, ...)
end
function HandleCharacterEvent:TriggerPlayerEvent(nEventType, nEventID, nPlayerKey, ...)
  self.EventActionMgr:TriggerPlayerEvent(nPlayerKey, nEventType, nEventID, ...)
end
function HandleCharacterEvent:HandlePlayerTakeDamage(nEventType, nEventID, nPlayerKey, Victim, AttackActor, CustomDamageInfo, DamageCauser)
  self.EventActionMgr:TriggerPlayerEvent(nPlayerKey, nEventType, nEventID, Victim, AttackActor, CustomDamageInfo, DamageCauser)
  self.EventActionMgr:TriggerItemDefineIDEvent(nil, nEventType, nEventID, nPlayerKey, Victim, AttackActor, CustomDamageInfo, DamageCauser)
end
function HandleCharacterEvent:HandlePlayerCauseDamage(nEventType, nEventID, nPlayerKey, AttackActor, Victim, CustomDamageInfo, DamageCauser, DamageItemID)
  self.EventActionMgr:TriggerPlayerEvent(nPlayerKey, nEventType, nEventID, AttackActor, Victim, CustomDamageInfo, DamageCauser, DamageItemID)
end
function HandleCharacterEvent:HandleAfterPlayerTakeDamage(nEventType, nEventID, nPlayerKey, Victim, AttackActor, DamageType, DamageCauser)
  self.EventActionMgr:TriggerItemDefineIDEvent(nil, nEventType, nEventID, nPlayerKey, Victim, AttackActor, DamageType, DamageCauser)
end
function HandleCharacterEvent:PlayerTransform(eventType, eventID, nPlayerKey, uCharacter, nActionID, ...)
  if nActionID == nil or nPlayerKey == nil or uCharacter == nil then
    return
  end
  if uCharacter.PlayerKey ~= nPlayerKey then
    print(bWriteLog and string.format("debugChangeHero PlayerTransform uCharacter.PlayerKey ~= nPlayerKey nPlayerKey:%u, uCharacter.PlayerKey:%u", nPlayerKey, uCharacter.PlayerKey))
    return
  end
  local uTargetCharacter = self:GetCharacter(nPlayerKey)
  if not slua.isValid(uTargetCharacter) then
    if slua.isValid(uCharacter) then
      uTargetCharacter = uCharacter
    else
      sandbox.LogError(string.format("HandleCharacterEvent:PlayerTransform Player:[%u] not exists", nPlayerKey))
      return
    end
  end
  local ActionData = self:GetActionData(eventType, nActionID)
  if not self.EventActionMgr:HasAction(eventType, eventID, uTargetCharacter, ActionData) then
    print(bWriteLog and string.format("debugChangeHero HandleCharacterEvent PlayerTransform DoAction nPlayerKey:%u, nActionID:%d", nPlayerKey, nActionID))
    self.EventActionMgr:DoAction(eventType, eventID, uTargetCharacter, ActionData, ...)
  else
    sandbox.LogError(string.format("debugChangeHero HandleCharacterEvent not HasAction nPlayerKey:%u, nActionID:%d", nPlayerKey, nActionID))
  end
end
function HandleCharacterEvent:PlayerTransformBack(eventType, eventID, nPlayerKey, uCharacter, nActionID, ...)
  local uTargetCharacter = self:GetCharacter(nPlayerKey)
  if not slua.isValid(uTargetCharacter) then
    sandbox.LogError(string.format("HandleCharacterEvent:PlayerTransformBack Player:[%d] not exists", nPlayerKey))
    return
  end
  if uCharacter.PlayerKey ~= nPlayerKey then
    print(bWriteLog and string.format("debugChangeHero PlayerTransformBack uCharacter.PlayerKey ~= nPlayerKey nPlayerKey:%u, uCharacter.PlayerKey:%u", nPlayerKey, uCharacter.PlayerKey))
    return
  end
  local BackEventType = EVENTTYPE_PLAYEREVENT_CHARACTER
  local BackEventID = EVENTID_PLAYEREVENT_TRANSFORM
  local ActionData = self:GetActionData(BackEventType, nActionID)
  if self.EventActionMgr:HasAction(BackEventType, BackEventID, uTargetCharacter, ActionData) then
    print(bWriteLog and string.format("debugChangeHero HandleCharacterEvent PlayerTransformBack DoAction nPlayerKey:%u, nActionID:%d", nPlayerKey, nActionID))
    self.EventActionMgr:UnDoAction(BackEventType, BackEventID, uTargetCharacter, ActionData, ...)
  else
    sandbox.LogError(string.format("debugChangeHero HandleCharacterEvent PlayerTransformBack not HasAction nPlayerKey:%u, nActionID:%d", nPlayerKey, nActionID))
  end
end
function HandleCharacterEvent:InitPlayerTalents(EventType, EventID, nPlayerKey, ActionInfoTable)
  print("HandleCharacterEvent:InitPlayerTalents")
  if ActionInfoTable == nil or not self:IsServer() then
    return
  end
  local uTargetCharacter = self:GetCharacter(nPlayerKey)
  if Game and not Game:IsValid(uTargetCharacter) then
    sandbox.LogError(string.format("HandleCharacterEvent:InitPlayerTalents Player:[%u] not exists", nPlayerKey))
    return
  end
  local CharacterEventData = self.EventDataMgr:GetData(EVENTTYPE_PLAYEREVENT_CHARACTER)
  local ConditionEntry = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ConditionEntry")
  for TalentID, TalentParam in pairs(ActionInfoTable) do
    local TalentData = CharacterEventData:GetTalentActionData(TalentID)
    if TalentData then
      local ActionData = CharacterEventData:GetTableData("ActionTable", TalentData.ActionID)
      if ActionData then
        local tParamStr = {}
        tParamStr[1] = TalentParam
        local actionDataTable = {tActionData = ActionData, tParam = tParamStr}
        local Actions = self.EventActionMgr:NewGetAction(EventType, EventID, uTargetCharacter, actionDataTable)
        local EventConditions = ConditionEntry.CreateEventConditions(nPlayerKey, TalentData.Events)
        local ObjectConditions = ConditionEntry.CreateObjectConditions(TalentData.Conditions)
        if _G.next(EventConditions) == nil then
          self.EventActionMgr:NewDoAction(Actions, uTargetCharacter)
          if TalentData.UndoActionWhenRemove then
            self.EventActionMgr:RecordNeedUndoActionsWhenTalentRemove(nPlayerKey, TalentID, Actions)
          end
        else
          self.EventActionMgr:NewPlayerEvent(nPlayerKey, EventConditions, ObjectConditions, Actions, {
            UndoAction = TalentData.UndoAction > 0,
            IsExec = false,
            CanRepeat = 0 < TalentData.CanRepeat,
            ID = TalentID,
            NeedUndoWhenRemove = TalentData.UndoActionWhenRemove > 0
          })
        end
      end
    end
  end
end
function HandleCharacterEvent:RemovePlayerTalents(EventType, EventID, nPlayerKey, TalentIDs)
  print("HandleCharacterEvent:RemovePlayerTalents")
  if TalentIDs == nil or not self:IsServer() then
    return
  end
  local uTargetCharacter = self:GetCharacter(nPlayerKey)
  if Game and not Game:IsValid(uTargetCharacter) then
    sandbox.LogError(string.format("HandleCharacterEvent:RemovePlayerTalents Player:[%u] not exists", nPlayerKey))
    return
  end
  for key, TalentID in pairs(TalentIDs) do
    self.EventActionMgr:UnDoActionsByTalent(nPlayerKey, TalentID, uTargetCharacter)
  end
  for key, TalentID in pairs(TalentIDs) do
    self.EventActionMgr:ClearTalentActionByID(nPlayerKey, TalentID)
  end
end
function HandleCharacterEvent:ClearPlayerTalents(EventType, EventID)
  print("HandleCharacterEvent:ClearPlayerTalents")
  self.EventActionMgr:ClearPlayerEventRecordTable()
end
local class = require("class")
local CEventBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleEventBase")
local CHandleCharacterEvent = class(CEventBase, nil, HandleCharacterEvent)
return CHandleCharacterEvent