local PlayerEventActionMgr = {}
function PlayerEventActionMgr:Init(bClient, gameState)
  self.GameState = gameState
  self.PlayerEventActions = {}
  self.ActionTemplateBuilder = {}
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local itemActionBuilder = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.ItemActionBuilder", true))
  self.ActionTemplateBuilder[EVENTTYPE_PLAYEREVENT_ITEM] = itemActionBuilder()
  local characterActionBuilder = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.CharacterActionBuilder", true))
  self.ActionTemplateBuilder[EVENTTYPE_PLAYEREVENT_CHARACTER] = characterActionBuilder()
  local skillBuffActionBuilder = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.SkillBuffActionBuilder", true))
  self.ActionTemplateBuilder[EVENTTYPE_PLAYEREVENT_SKILLBUFF] = skillBuffActionBuilder()
  local weaponActionBuilder = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.WeaponActionBuilder", true))
  self.ActionTemplateBuilder[EVENTTYPE_PLAYEREVENT_WEAPON] = weaponActionBuilder()
  local vehicleActionBuilder = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.VehicleActionBuilder", true))
  self.ActionTemplateBuilder[EVENTTYPE_PLAYEREVENT_VEHICLE] = vehicleActionBuilder()
  local avatarActionBuilder = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.AvatarActionBuilder", true))
  self.ActionTemplateBuilder[EVENTTYPE_PLAYEREVENT_AVATAR] = avatarActionBuilder()
  local equipmentActionBuilder = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.EquipmentActionBuilder", true))
  self.ActionTemplateBuilder[EVENTTYPE_PLAYEREVENT_EQUIPT] = equipmentActionBuilder()
  for k, v in pairs(self.ActionTemplateBuilder) do
    if v.Init then
      v:Init(bClient)
    end
  end
  self.CahePlayerActionTemplate = {}
  self.PlayerEventRecordTable = {}
  self.PlayerUnconditionActionRecordTable = {}
  self.ItemDefineIDActionRecordTable = {}
  self.PlayerKeyToItemDefineIDActionRecordTable = {}
  self.ItemDefineIDEventRecordTable = {}
end
function PlayerEventActionMgr:Clear(nPlayerKey)
  if nPlayerKey ~= nil and 0 < nPlayerKey and self.PlayerEventActions[nPlayerKey] ~= nil then
    self.PlayerEventActions[nPlayerKey] = nil
    self.CahePlayerActionTemplate[nPlayerKey] = nil
  end
end
function PlayerEventActionMgr:ClearAll()
  for k, v in pairs(self.ActionTemplateBuilder) do
    if v and v.Clear ~= nil then
      v:Clear()
    end
  end
  self.ActionTemplateBuilder = nil
  self.PlayerEventActions = nil
  self.CahePlayerActionTemplate = nil
  self.GameState = nil
end
function PlayerEventActionMgr:GetBuilder(nEventType)
  return self.ActionTemplateBuilder[nEventType]
end
function PlayerEventActionMgr:CacheAction(nEventType, nEventID, targetCharacter, actionDataTable, actionArrayTemplate)
  local nPlayerKey = tonumber(targetCharacter:GetPlayerKey())
  if nPlayerKey == nil or nPlayerKey <= 0 then
    return
  end
  if self.CahePlayerActionTemplate[nPlayerKey] == nil then
    self.CahePlayerActionTemplate[nPlayerKey] = {}
  end
  if self.CahePlayerActionTemplate[nPlayerKey][nEventType] == nil then
    self.CahePlayerActionTemplate[nPlayerKey][nEventType] = {}
  end
  self.CahePlayerActionTemplate[nPlayerKey][nEventType][nEventID] = {data = actionDataTable, template = actionArrayTemplate}
end
function PlayerEventActionMgr:DoActionWithCache(nEventType, nEventID, targetCharacter)
  if not targetCharacter then
    return
  end
  local nPlayerKey = tonumber(targetCharacter:GetPlayerKey())
  if nPlayerKey == nil or nPlayerKey <= 0 then
    return
  end
  local cacheActionInfo
  if self.CahePlayerActionTemplate[nPlayerKey] and self.CahePlayerActionTemplate[nPlayerKey][nEventType] and self.CahePlayerActionTemplate[nPlayerKey][nEventType][nEventID] then
    cacheActionInfo = self.CahePlayerActionTemplate[nPlayerKey][nEventType][nEventID]
  end
  if cacheActionInfo then
    self:DoAction(nEventType, nEventID, targetCharacter, cacheActionInfo.data)
  end
end
function PlayerEventActionMgr:UnDoActionWithCache(nEventType, nEventID, targetCharacter)
  if not targetCharacter then
    return
  end
  local nPlayerKey = tonumber(targetCharacter:GetPlayerKey())
  if nPlayerKey == nil or nPlayerKey <= 0 then
    return
  end
  local cacheActionInfo
  if self.CahePlayerActionTemplate[nPlayerKey] and self.CahePlayerActionTemplate[nPlayerKey][nEventType] and self.CahePlayerActionTemplate[nPlayerKey][nEventType][nEventID] then
    cacheActionInfo = self.CahePlayerActionTemplate[nPlayerKey][nEventType][nEventID]
  end
  if cacheActionInfo then
    self:UnDoAction(nEventType, nEventID, targetCharacter, cacheActionInfo.data)
  end
end
function PlayerEventActionMgr:GetAction(nEventType, nEventID, targetCharacter, actionDataTable)
  if not targetCharacter then
    return
  end
  local nPlayerKey = tonumber(targetCharacter:GetPlayerKey())
  if nPlayerKey == nil or nPlayerKey <= 0 then
    return
  end
  if self.CahePlayerActionTemplate[nPlayerKey] and self.CahePlayerActionTemplate[nPlayerKey][nEventType] and self.CahePlayerActionTemplate[nPlayerKey][nEventType][nEventID] then
    return self.CahePlayerActionTemplate[nPlayerKey][nEventType][nEventID].template
  end
  local builder = self:GetBuilder(nEventType)
  if not builder then
    return
  end
  local actionArrayTemplate = builder:BuildActionTemplate(nEventID, targetCharacter, actionDataTable)
  if not actionArrayTemplate then
    return
  end
  return actionArrayTemplate
end
function PlayerEventActionMgr:NewGetAction(nEventType, nEventID, targetCharacter, actionDataTable)
  local builder = self:GetBuilder(nEventType)
  if not builder then
    return
  end
  local actionArrayTemplate = builder:BuildActionTemplate(nEventID, targetCharacter, actionDataTable)
  if not actionArrayTemplate then
    return
  end
  return actionArrayTemplate
end
function PlayerEventActionMgr:NewDoAction(ActionArrayTemplate, ...)
  for k, action in ipairs(ActionArrayTemplate) do
    if action then
      action:DoAction(...)
    end
  end
end
function PlayerEventActionMgr:NewUndoAction(ActionArrayTemplate, ...)
  for k, action in ipairs(ActionArrayTemplate) do
    if action then
      action:UnDoAction(...)
    end
  end
end
function PlayerEventActionMgr:DoAction(nEventType, nEventID, targetCharacter, actionDataTable, ...)
  local actionArrayTemplate = self:GetAction(nEventType, nEventID, targetCharacter, actionDataTable)
  if actionArrayTemplate == nil then
    return
  end
  local nPlayerKey = tonumber(targetCharacter:GetPlayerKey())
  local playerActions = self.PlayerEventActions[nPlayerKey]
  if not playerActions then
    self.PlayerEventActions[nPlayerKey] = {}
    playerActions = self.PlayerEventActions[nPlayerKey]
  end
  local actionEvents = playerActions[nEventType]
  if not actionEvents then
    playerActions[nEventType] = {}
    actionEvents = playerActions[nEventType]
  end
  local actions = actionEvents[nEventID]
  if not actions then
    actionEvents[nEventID] = {}
    actions = actionEvents[nEventID]
  end
  actions[#actions + 1] = {actionArray = actionArrayTemplate, dataTable = actionDataTable}
  for k, action in ipairs(actionArrayTemplate) do
    if action then
      action:DoAction(targetCharacter, ...)
    end
  end
end
function PlayerEventActionMgr:HasAction(nEventType, nEventID, uTargetCharacter, actionDataTable)
  if not slua.isValid(uTargetCharacter) or self.PlayerEventActions == nil then
    return false
  end
  local nPlayerKey = tonumber(uTargetCharacter:GetPlayerKey())
  local playerActions = self.PlayerEventActions[nPlayerKey]
  if playerActions == nil then
    return false
  end
  local actionEvents = playerActions[nEventType]
  if actionEvents == nil then
    return false
  end
  local actions = actionEvents[nEventID]
  if actions == nil then
    return
  end
  local builder = self:GetBuilder(nEventType)
  if not builder then
    return false
  end
  for i, v in pairs(actions) do
    if builder:IsActionDataEqual(v.dataTable, actionDataTable) then
      return true
    end
  end
  return false
end
function PlayerEventActionMgr:UnDoAction(nEventType, nUnDoEventID, targetCharacter, actionDataTable, ...)
  if not slua.isValid(targetCharacter) then
    return
  end
  local nPlayerKey = tonumber(targetCharacter:GetPlayerKey())
  local playerActions = self.PlayerEventActions[nPlayerKey]
  if not playerActions then
    return
  end
  local actionEvents = playerActions[nEventType]
  if not actionEvents then
    return
  end
  local actions = actionEvents[nUnDoEventID]
  if not actions then
    return
  end
  local builder = self:GetBuilder(nEventType)
  if not builder then
    return
  end
  for i, v in pairs(actions) do
    if v and builder:IsActionDataEqual(v.dataTable, actionDataTable) then
      for j, action in ipairs(v.actionArray) do
        if action then
          action:UnDoAction(targetCharacter, ...)
        end
      end
      actions[i] = nil
      break
    end
  end
end
function PlayerEventActionMgr:GetAimActionData(nEventType, nEventID, targetCharacter, actionDataTable, ...)
  if not slua.isValid(targetCharacter) then
    return
  end
  local nPlayerKey = tonumber(targetCharacter:GetPlayerKey())
  local playerActions = self.PlayerEventActions[nPlayerKey]
  if not playerActions then
    return
  end
  local actionEvents = playerActions[nEventType]
  if not actionEvents then
    return
  end
  local actions = actionEvents[nEventID]
  if not actions then
    return
  end
  local builder = self:GetBuilder(nEventType)
  if not builder then
    return
  end
  for i, v in pairs(actions) do
    if v and builder:IsActionDataEqual(v.dataTable, actionDataTable) then
      return v.dataTable
    end
  end
end
function PlayerEventActionMgr:NewPlayerEvent(nPlayerKey, EventConditions, ObjectConditions, Actions, ActionState)
  local PlayerData = self.PlayerEventRecordTable[nPlayerKey]
  if PlayerData == nil then
    PlayerData = {}
    self.PlayerEventRecordTable[nPlayerKey] = PlayerData
  end
  for EventType, ID2Condition in pairs(EventConditions) do
    local PrevEventData = PlayerData[EventType]
    if PrevEventData == nil then
      PrevEventData = {}
      PlayerData[EventType] = PrevEventData
    end
    for EventID, Condition in pairs(ID2Condition) do
      local ActionTable = PrevEventData[EventID]
      if ActionTable == nil then
        ActionTable = {}
        PrevEventData[EventID] = ActionTable
      end
      table.insert(ActionTable, {
        EventCondition = Condition,
        ObjConditions = ObjectConditions,
        Actions = Actions,
              })
    end
  end
end
function PlayerEventActionMgr:RecordNeedUndoActionsWhenTalentRemove(nPlayerKey, nTalentID, Actions)
  local PlayerData = self.PlayerUnconditionActionRecordTable[nPlayerKey]
  if PlayerData == nil then
    PlayerData = {}
    self.PlayerUnconditionActionRecordTable[nPlayerKey] = PlayerData
  end
  PlayerData[nTalentID] = Actions
end
function PlayerEventActionMgr:UnDoActionsByTalent(nPlayerKey, nTalentID, targetCharacter)
  local PlayerData = self.PlayerUnconditionActionRecordTable[nPlayerKey]
  if PlayerData and PlayerData[nTalentID] then
    for _, action in ipairs(PlayerData[nTalentID]) do
      action:UnDoAction(targetCharacter)
    end
  end
  local PlayerEventData = self.PlayerEventRecordTable[nPlayerKey]
  if PlayerEventData then
    for EventType, EventData in pairs(PlayerEventData) do
      for EventID, ActionTable in pairs(EventData) do
        for _, ActionData in pairs(ActionTable) do
          if ActionData.ActionState and ActionData.ActionState.ID == nTalentID and ActionData.ActionState.NeedUndoWhenRemove and ActionData.ActionState.IsExec then
            for _, action in ipairs(ActionData.Actions) do
              local WeaponEventTypeID = _G.EVENTTYPE_PLAYEREVENT_WEAPON
              local WeaponInitID = _G.EVENTID_PLAYEREVENT_WEAPON_INIT
              if WeaponEventTypeID and WeaponInitID and EventType == WeaponEventTypeID and EventID == WeaponInitID then
                local uWeaponManager = targetCharacter:GetWeaponManager()
                local WeaponList = slua.isValid(uWeaponManager) and uWeaponManager:GetAllInventoryWeaponList(false)
                if WeaponList then
                  for _, uWeapon in pairs(WeaponList) do
                    if slua.isValid(uWeapon) then
                      action:UnDoAction(uWeapon)
                    end
                  end
                end
              else
                action:UnDoAction(targetCharacter)
              end
            end
          end
        end
      end
    end
  end
end
function PlayerEventActionMgr:ClearTalentActionByID(nPlayerKey, nTalentID)
  self.PlayerUnconditionActionRecordTable[nPlayerKey] = nil
  local PlayerEventData = self.PlayerEventRecordTable[nPlayerKey]
  if PlayerEventData then
    for _, EventData in pairs(PlayerEventData) do
      for _, ActionTable in pairs(EventData) do
        for i, ActionData in pairs(ActionTable) do
          if ActionData.ActionState and ActionData.ActionState.ID == nTalentID then
            ActionTable[i] = nil
          end
        end
      end
    end
  end
end
function PlayerEventActionMgr:TriggerPlayerEvent(nPlayerKey, EventType, EventID, ...)
  local PlayerData = self.PlayerEventRecordTable[nPlayerKey]
  if PlayerData == nil then
    return
  end
  local EventData = PlayerData[EventType]
  if EventData == nil then
    return
  end
  local ActionTable = EventData[EventID]
  if ActionTable == nil then
    return
  end
  print(bWriteLog and "TriggerPlayerEvent, Type:" .. tostring(_G.EventDefineID[EventType]) .. "ID:" .. tostring(_G.EventDefineID[EventID]))
  local ConditionEntry = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ConditionEntry")
  for _, ActionData in pairs(ActionTable) do
    if ActionData.EventCondition == true or ActionData.EventCondition:Evaluate(...) then
      local Success = ConditionEntry.EvaluateConditions(ActionData.ObjConditions, ...)
      local State = ActionData.ActionState
      if Success then
        if not State.IsExec or State.CanRepeat then
          self:NewDoAction(ActionData.Actions, ...)
          print(bWriteLog and string.format("TriggerPlayerEvent Player:[%d], EventType:[%d], EventID:[%d] ExecAction", nPlayerKey, EventType, EventID))
          State.IsExec = true
        end
      elseif State.IsExec and State.UndoAction then
        self:NewUndoAction(ActionData.Actions, ...)
        State.IsExec = false
        print(bWriteLog and string.format("TriggerPlayerEvent Player:[%d], EventType:[%d], EventID:[%d] UndoAction", nPlayerKey, EventType, EventID))
      end
    end
  end
end
function PlayerEventActionMgr:UndoPlayerEvent(nPlayerKey, EventType, EventID, ...)
  local PlayerData = self.PlayerEventRecordTable[nPlayerKey]
  if PlayerData == nil then
    return
  end
  local EventData = PlayerData[EventType]
  if EventData == nil then
    return
  end
  local ActionTable = EventData[EventID]
  if ActionTable == nil then
    return
  end
  local ConditionEntry = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ConditionEntry")
  for _, ActionData in pairs(ActionTable) do
    if ActionData.EventCondition == true or ActionData.EventCondition:Evaluate(...) then
      local State = ActionData.ActionState
      if State.IsExec and State.UndoAction then
        self:NewUndoAction(ActionData.Actions, ...)
        State.IsExec = false
        print(bWriteLog and string.format("UndoPlayerEvent Player:[%d] UndoAction", nPlayerKey))
      end
    end
  end
end
function PlayerEventActionMgr:ClearPlayerEventRecordTable()
  self.PlayerEventRecordTable = {}
end
function PlayerEventActionMgr:ClearPlayerEventRecordTableByPlayerKey(nPlayerKey)
  self.PlayerEventRecordTable[nPlayerKey] = nil
end
function PlayerEventActionMgr:RegisterItemDefineIDEvent(ItemInstanceID, InActions, InDoEventStr, InObjConditionStr, InUnDoEventStr, InUnDoObjConditionStr, InCanRepeat)
  local ActionData = {
    Actions = InActions,
    DoEventStr = InDoEventStr,
    ObjConditionStr = InObjConditionStr,
    UnDoEventStr = InUnDoEventStr,
    UnDoObjConditionStr = InUnDoObjConditionStr,
    ActionState = {IsExec = false, CanRepeat = InCanRepeat}
  }
  if not self.ItemDefineIDActionRecordTable[ItemInstanceID] then
    self.ItemDefineIDActionRecordTable[ItemInstanceID] = {}
  end
  local Index = #self.ItemDefineIDActionRecordTable[ItemInstanceID]
  self.ItemDefineIDActionRecordTable[ItemInstanceID][Index + 1] = ActionData
  print(bWriteLog and "PlayerEventActionMgr:NewItemDefineIDEvent :" .. tostring(ItemInstanceID))
end
function PlayerEventActionMgr:UnRegisterItemDefineIDEvent(ItemInstanceID, nPlayerKey, ...)
  self:ItemDefineIDUnBindPlayerKey(ItemInstanceID, nPlayerKey, ...)
  self.ItemDefineIDActionRecordTable[ItemInstanceID] = nil
end
function PlayerEventActionMgr:ItemDefineIDBindPlayerKey(ItemInstanceID, nPlayerKey, targetCharacter, ...)
  local ActionTableDatas = self.ItemDefineIDActionRecordTable[ItemInstanceID]
  if ActionTableDatas then
    if not self.PlayerKeyToItemDefineIDActionRecordTable[nPlayerKey] then
      self.PlayerKeyToItemDefineIDActionRecordTable[nPlayerKey] = {}
    end
    self.PlayerKeyToItemDefineIDActionRecordTable[nPlayerKey][ItemInstanceID] = true
    self.ItemDefineIDEventRecordTable[ItemInstanceID] = {}
    local PlayerData = self.ItemDefineIDEventRecordTable[ItemInstanceID]
    local ConditionEntry = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ConditionEntry")
    for index, ActionTableData in ipairs(ActionTableDatas) do
      local EventConditions = ConditionEntry.CreateEventConditions(nPlayerKey, ActionTableData.DoEventStr)
      local ObjectConditions = ConditionEntry.CreateObjectConditions(ActionTableData.ObjConditionStr)
      local UndoEventConditions = ConditionEntry.CreateEventConditions(nPlayerKey, ActionTableData.UnDoEventStr)
      local UndoObjectConditions = ConditionEntry.CreateObjectConditions(ActionTableData.UnDoObjConditionStr)
      ActionTableData.      ActionTableData.      ActionTableData.      ActionTableData.      for EventType, ID2Condition in pairs(EventConditions) do
        local PrevEventData = PlayerData[EventType]
        if PrevEventData == nil then
          PrevEventData = {}
          PlayerData[EventType] = PrevEventData
        end
        for EventID, Condition in pairs(ID2Condition) do
          local ActionTable = PrevEventData[EventID]
          if ActionTable == nil then
            ActionTable = {}
            PrevEventData[EventID] = ActionTable
          end
          table.insert(ActionTable, {ActionInfo = ActionTableData, ActionDoOrUndo = 1})
        end
      end
      for EventType, ID2Condition in pairs(UndoEventConditions) do
        local PrevEventData = PlayerData[EventType]
        if PrevEventData == nil then
          PrevEventData = {}
          PlayerData[EventType] = PrevEventData
        end
        for EventID, Condition in pairs(ID2Condition) do
          local ActionTable = PrevEventData[EventID]
          if ActionTable == nil then
            ActionTable = {}
            PrevEventData[EventID] = ActionTable
          end
          table.insert(ActionTable, {ActionInfo = ActionTableData, ActionDoOrUndo = 2})
        end
      end
      if _G.next(EventConditions) == nil and not ActionTableData.ActionState.IsExec then
        if ConditionEntry.EvaluateConditions(ObjectConditions, targetCharacter) then
          print(bWriteLog and string.format("PlayerEventActionMgr:ItemDefineIDBindPlayerKey Player:[%u], Init ExecAction", nPlayerKey))
          self:NewDoAction(ActionTableData.Actions, ...)
          ActionTableData.ActionState.IsExec = true
        else
          print(bWriteLog and string.format("PlayerEventActionMgr:ItemDefineIDBindPlayerKey, ObjectConditions failed nPlayerKey:[%u] ", nPlayerKey))
        end
      end
    end
  end
end
function PlayerEventActionMgr:ItemDefineIDUnBindPlayerKey(ItemInstanceID, nPlayerKey, ...)
  local ActionTableDatas = self.ItemDefineIDActionRecordTable[ItemInstanceID]
  if ActionTableDatas and self.PlayerKeyToItemDefineIDActionRecordTable[nPlayerKey] then
    self.ItemDefineIDEventRecordTable[ItemInstanceID] = {}
    self.PlayerKeyToItemDefineIDActionRecordTable[nPlayerKey][ItemInstanceID] = nil
    for index, ActionDataTable in ipairs(ActionTableDatas) do
      if ActionDataTable.ActionState.IsExec then
        self:NewUndoAction(ActionDataTable.Actions, ...)
        ActionDataTable.ActionState.IsExec = false
        print(bWriteLog and string.format("PlayerEventActionMgr:ItemDefineIDUnBindPlayerKey ItemInstanceID:[%d] nPlayerKey:[%u] UndoAction", ItemInstanceID, nPlayerKey))
      end
    end
  end
end
function PlayerEventActionMgr:TriggerItemDefineIDEvent(ItemInstanceID, EventType, EventID, nPlayerKey, ...)
  if ItemInstanceID then
    self:RealTriggerItemDefineIDEvent(ItemInstanceID, EventType, EventID, ...)
  else
    local ActionTables = self.PlayerKeyToItemDefineIDActionRecordTable[nPlayerKey]
    if not ActionTables then
      return
    end
    for key, value in pairs(ActionTables) do
      self:RealTriggerItemDefineIDEvent(key, EventType, EventID, ...)
    end
  end
end
function PlayerEventActionMgr:RealTriggerItemDefineIDEvent(ItemInstanceID, EventType, EventID, ...)
  local PlayerData = self.ItemDefineIDEventRecordTable[ItemInstanceID]
  if PlayerData == nil then
    return
  end
  local EventData = PlayerData[EventType]
  if EventData == nil then
    return
  end
  local ActionTable = EventData[EventID]
  if ActionTable == nil then
    return
  end
  for _, ActionData in pairs(ActionTable) do
    if ActionData.ActionDoOrUndo == 1 then
      self:ItemDefineIDRealDoActions(ActionData.ActionInfo, EventType, EventID, ...)
    elseif ActionData.ActionDoOrUndo == 2 then
      self:ItemDefineIDRealUnDoActions(ActionData.ActionInfo, EventType, EventID, ...)
    end
  end
end
function PlayerEventActionMgr:ItemDefineIDRealDoActions(ActionDataTable, EventType, EventID, ...)
  if ActionDataTable then
    local ConditionEntry = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ConditionEntry")
    local EventCondition
    if ActionDataTable.EventConditions[EventType] then
      EventCondition = ActionDataTable.EventConditions[EventType][EventID]
    end
    if EventCondition and (EventCondition == true or EventCondition:Evaluate(...)) then
      local Success = ConditionEntry.EvaluateConditions(ActionDataTable.ObjectConditions, ...)
      local State = ActionDataTable.ActionState
      if Success and (not State.IsExec or State.CanRepeat) then
        self:NewDoAction(ActionDataTable.Actions, ...)
        State.IsExec = true
        print(bWriteLog and "PlayerEventActionMgr:ItemDefineIDRealDoActions")
      end
    end
  end
end
function PlayerEventActionMgr:ItemDefineIDRealUnDoActions(ActionDataTable, EventType, EventID, ...)
  if ActionDataTable then
    local State = ActionDataTable.ActionState
    if State.IsExec then
      local ConditionEntry = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ConditionEntry")
      local EventCondition
      if ActionDataTable.UndoEventConditions[EventType] then
        EventCondition = ActionDataTable.UndoEventConditions[EventType][EventID]
      end
      if EventCondition and (EventCondition == true or EventCondition:Evaluate(...)) then
        local Success = ConditionEntry.EvaluateConditions(ActionDataTable.UndoObjectConditions, ...)
        if Success then
          self:NewUndoAction(ActionDataTable.Actions, ...)
          State.IsExec = false
          print(bWriteLog and "PlayerEventActionMgr:ItemDefineIDRealUnDoActions")
        end
      end
    end
  end
end
function PlayerEventActionMgr:ClearItemDefineIDRecordTable()
  self.ItemDefineIDActionRecordTable = {}
  self.ItemDefineIDActionRecordTable = {}
  self.PlayerKeyToItemDefineIDActionRecordTable = {}
end
return PlayerEventActionMgr