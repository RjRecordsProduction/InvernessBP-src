local LobbyBubbleConfig = require("client.slua.logic.lobby_bubble.LobbyBubbleConfig")
local LobbyBubbleManager = {}
function LobbyBubbleManager:ctor()
  self.bubbleQueue = {}
end
function LobbyBubbleManager:DefineAndResetData()
  log(bWriteLog and "LobbyBubbleManager:DefineAndResetData")
end
function LobbyBubbleManager:_CheckParam(queueType, bubbleType)
  if not self.bubbleQueue[queueType] then
    log_error("LobbyBubbleManager:_CheckParam queueType is missing" .. tostring(queueType))
    return
  end
  if not self.bubbleQueue[queueType][bubbleType] then
    log_error("LobbyBubbleManager:_CheckParam bubbleType is missing" .. tostring(bubbleType))
    return
  end
  return true
end
function LobbyBubbleManager:_ResumeBubble(queueType)
  for _bubbleType, _bubbleNode in ipairs(self.bubbleQueue[queueType]) do
    if _bubbleNode.status == LobbyBubbleConfig.Enum_Bubble_Status.Showing then
      break
    end
    if _bubbleNode.bAutoShow and _bubbleNode.status == LobbyBubbleConfig.Enum_Bubble_Status.Waiting and self:_IsFitCondition(_bubbleNode) then
      self:ShowBubbleInternal(queueType, _bubbleType)
    end
  end
end
function LobbyBubbleManager:_GetBubbleNode(queueType, bubbleType)
  return self.bubbleQueue[queueType][bubbleType]
end
function LobbyBubbleManager:_InitBubbleQueue(queueType)
  local _bubbleQueue = LobbyBubbleConfig.Bubble_Queue[queueType]
  if not _bubbleQueue then
    log_error("bubbleQueue not found" .. tostring(queueType))
    return
  end
  if self.bubbleQueue[queueType] then
    return
  end
  local TableUtil = require("common.table_util")
  self.bubbleQueue[queueType] = TableUtil.CopyTable(_bubbleQueue)
end
function LobbyBubbleManager:_ClearBubbleQueue()
  self.bubbleQueue = {}
  log(bWriteLog and "LobbyBubbleManager:_ClearBubbleQueue")
end
function LobbyBubbleManager:_ShowBubbleImmediate(queueType, bubbleType)
  for _bubbleType, _bubbleNode in ipairs(self.bubbleQueue[queueType]) do
    if _bubbleNode.bAutoShow and bubbleType < _bubbleType and _bubbleNode.status == LobbyBubbleConfig.Enum_Bubble_Status.Showing then
      self:_DoAction(queueType, _bubbleType, LobbyBubbleConfig.Enum_Bubble_Status.Waiting)
    end
  end
  self:_DoAction(queueType, bubbleType, LobbyBubbleConfig.Enum_Bubble_Status.Showing)
  self:_PrintStatus(queueType)
end
function LobbyBubbleManager:_GetAction(bubbleNode, status)
  return bubbleNode.action and bubbleNode.action[status]
end
function LobbyBubbleManager:_DoAction(queueType, bubbleType, status)
  local bubbleNode = self:_GetBubbleNode(queueType, bubbleType)
  local action = self:_GetAction(bubbleNode, status)
  bubbleNode.  if action then
    action()
  end
end
function LobbyBubbleManager:_IsFitCondition(_bubbleNode)
  local checkFunction = _bubbleNode.checkFunction
  local canShow = not checkFunction or checkFunction()
  return canShow
end
function LobbyBubbleManager:_PrintStatus(queueType)
  if not bWriteLog then
    return
  end
  local statusMap = {}
  for name, value in pairs(LobbyBubbleConfig.Enum_Bubble_Status) do
    statusMap[value] = name
  end
  for _bubbleType, _bubbleNode in ipairs(self.bubbleQueue[queueType]) do
    log(bWriteLog and " _PrintStatus" .. "  bubbletype" .. tostring(_bubbleNode.name) .. "  status:" .. tostring(statusMap[_bubbleNode.status]))
  end
end
function LobbyBubbleManager:OnLogOut()
  self:_ClearBubbleQueue()
end
function LobbyBubbleManager:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "ActivityBubbleModule OnPostSwitchGameStatus preState" .. tostring(preState) .. " nextState" .. tostring(nextState))
end
function LobbyBubbleManager:ShowBubble(queueType, bubbleType)
  self:_InitBubbleQueue(queueType)
  if not self:_CheckParam(queueType, bubbleType) then
    return
  end
  log(bWriteLog and " show bubble" .. tostring(queueType) .. ":" .. tostring(bubbleType))
  self:ShowBubbleInternal(queueType, bubbleType)
end
function LobbyBubbleManager:ShowBubbleInternal(queueType, bubbleType)
  log(bWriteLog and " show ShowBubbleInternal" .. tostring(queueType) .. ":" .. tostring(bubbleType))
  local currentBubbleNode = self:_GetBubbleNode(queueType, bubbleType)
  if currentBubbleNode.status == LobbyBubbleConfig.Enum_Bubble_Status.Showing then
    log(bWriteLog and " bubble is showing" .. tostring(bubbleType) .. ":" .. tostring(bubbleType))
    return
  end
  if not currentBubbleNode.bAutoShow then
    self:_ShowBubbleImmediate(queueType, bubbleType)
    return
  end
  local needToWaiting = false
  for _bubbleType, _bubbleNode in ipairs(self.bubbleQueue[queueType]) do
    if bubbleType > _bubbleType then
      if _bubbleNode.status == LobbyBubbleConfig.Enum_Bubble_Status.Showing then
        needToWaiting = true
        log(bWriteLog and " higherBubbleType" .. tostring(_bubbleType))
        break
      end
    elseif bubbleType < _bubbleType and currentBubbleNode.bAutoShow and _bubbleNode.status == LobbyBubbleConfig.Enum_Bubble_Status.Showing then
      self:_DoAction(queueType, _bubbleType, LobbyBubbleConfig.Enum_Bubble_Status.Waiting)
    end
  end
  if needToWaiting then
    self:_DoAction(queueType, bubbleType, LobbyBubbleConfig.Enum_Bubble_Status.Waiting)
  else
    self:_DoAction(queueType, bubbleType, LobbyBubbleConfig.Enum_Bubble_Status.Showing)
  end
  self:_PrintStatus(queueType)
end
function LobbyBubbleManager:HideBubble(queueType, bubbleType)
  self:_InitBubbleQueue(queueType)
  if not self:_CheckParam(queueType, bubbleType) then
    return
  end
  log(bWriteLog and " Hide bubble" .. tostring(queueType) .. ":" .. tostring(bubbleType))
  local currentBubbleNode = self:_GetBubbleNode(queueType, bubbleType)
  if currentBubbleNode.status == LobbyBubbleConfig.Enum_Bubble_Status.Hiding then
    log(bWriteLog and " bubble is hiding" .. tostring(bubbleType) .. ":" .. tostring(bubbleType))
    return
  end
  self:_DoAction(queueType, bubbleType, LobbyBubbleConfig.Enum_Bubble_Status.Hiding)
  self:_ResumeBubble(queueType)
  self:_PrintStatus(queueType)
end
function LobbyBubbleManager:TryShowBubble(queueType, bubbleType)
  self:_InitBubbleQueue(queueType)
  if not self:_CheckParam(queueType, bubbleType) then
    return false
  end
  log(bWriteLog and " show TryShowBubble" .. tostring(queueType) .. ":" .. tostring(bubbleType))
  local currentBubbleNode = self:_GetBubbleNode(queueType, bubbleType)
  local canShow = self:_IsFitCondition(currentBubbleNode)
  if not canShow then
    log(bWriteLog and " TryShowBubble canshow is false")
    self:_PrintStatus(queueType)
    return false
  end
  self:ShowBubbleInternal(queueType, bubbleType)
  return true
end
function LobbyBubbleManager:ResumeBubble(queueType)
  log(bWriteLog and "resume bubble" .. tostring(queueType))
  self:_InitBubbleQueue(queueType)
  self:_ResumeBubble(queueType)
  self:_PrintStatus(queueType)
end
function LobbyBubbleManager:GetBubbleQueueType()
  return LobbyBubbleConfig.Enum_Bubble_Queue_Type
end
function LobbyBubbleManager:GetBubbleType(queueType)
  return LobbyBubbleConfig.Enum_Bubble_Type[queueType]
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLobbyBubbleManager = class(CModuleBase, nil, LobbyBubbleManager)
return CLobbyBubbleManager