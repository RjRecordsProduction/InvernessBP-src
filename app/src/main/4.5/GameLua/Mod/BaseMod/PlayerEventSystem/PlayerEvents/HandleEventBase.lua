local HandleEventBase = {}
function HandleEventBase:ctor(selfType)
  self.GameState = nil
  self.bIsClient = true
  self.EventDataMgr = nil
  self.EventActionMgr = nil
end
function HandleEventBase:Init(gameState, bClient, dataMgr, actionMgr)
  self.GameState = gameState
  self.bIsClient = bClient
  self.EventDataMgr = dataMgr
  self.EventActionMgr = actionMgr
  if gameState then
    print(bWriteLog and "HandleEventBase:Init GameState OK")
  else
    print(bWriteLog and "HandleEventBase:Init GameState nil")
  end
end
function HandleEventBase:Clear()
  print(bWriteLog and "HandleEventBase:Clear GameState  nil")
  self.GameState = nil
  self.EventDataMgr = nil
  self.EventActionMgr = nil
end
function HandleEventBase:CheckInitDSData(nPlayerKey)
end
function HandleEventBase:GetCharacter(nPlayerKey)
  if slua.isValid(self.GameState) and self.GameState.GetCharacter then
    return self.GameState:GetCharacter(nPlayerKey)
  end
  return nil
end
function HandleEventBase:IsClient()
  return self.bIsClient
end
function HandleEventBase:IsServer()
  return not self.bIsClient
end
function HandleEventBase:GetActionData(eventType, nActionID)
  local ItemEventData = self.EventDataMgr:GetData(eventType)
  local ActionData
  if ItemEventData then
    ActionData = ItemEventData:GetTableData("ActionTable", nActionID)
  end
  if ActionData == nil then
    sandbox.LogError(string.format("HandleEventBase:GetActionData nActionID:[%d] not exists", nActionID))
    return
  end
  return ActionData
end
local class = require("class")
local object = require("object")
local CHandleEventBase = class(object, nil, HandleEventBase)
return CHandleEventBase