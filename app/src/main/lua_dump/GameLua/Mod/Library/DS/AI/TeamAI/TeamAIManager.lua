TeamAIOrderType = {
  None = 0,
  FollowLeader = 1,
  GrabAirdrop = 2,
  TeamAttack = 3,
  RescueTeammate = 4
}
TeamAIOrderState = {
  Ready = 0,
  Excute = 1,
  End = 2
}
TeamAIUpdateInterTime = 2
TeamAIManager = TeamAIManager or {IsInit = false}
function TeamAIManager:Init()
  if not CGameMode or not CGameMode.PlayerNumPerTeam then
    return
  end
  if CGameMode.PlayerNumPerTeam < 2 then
    return
  end
  TeamAIManager.TeamAIGroupList = {}
  EventSystem:registEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ON_AI_PAWN_SPAWN, TeamAI_HandleAIPlayerSpawn)
  EventSystem:registEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_DIED, TeamAI_HandleAIPlayerDie)
  self.TimeHandler = Game:SetTimer(TeamAIUpdateInterTime, true, function()
    self:Update()
  end)
  TeamAIManager.IsInit = true
end
function TeamAIManager:Update()
  for index, value in pairs(TeamAIManager.TeamAIGroupList) do
    if value and value:GetPlayerNum() > 1 and value.TeamAIOrders then
      for indexOr, Order in ipairs(value.TeamAIOrders) do
        if Order then
          if Order.IsUpdate and Order.State == TeamAIOrderState.Excute then
            Order:Update()
          end
          if Order.State ~= TeamAIOrderState.Excute and Order.IsUpdateCheck and Order:CheckCondition() then
            Order:DoAction()
          end
        end
      end
    end
  end
end
function TeamAIManager:AddTeamOrder(TeamID, OrderType)
  if not TeamAIManager.IsInit then
    return
  end
  if not TeamID or TeamID <= 0 then
    return
  end
  if not OrderType or OrderType <= 0 then
    return
  end
  if not TeamAIManager.TeamAIGroupList[TeamID] then
    local ObjectTemp = {}
    local class = require("class")
    local TeamAIGroupBase = require("GameLua.Mod.Library.DS.AI.TeamAI.TeamAIGroupBase")
    local CObjectPool = class(TeamAIGroupBase, nil, ObjectTemp)
    local TeamGroup = CObjectPool()
    TeamGroup.    TeamAIManager.TeamAIGroupList[TeamID] = TeamGroup
  end
  if not TeamAIManager.TeamAIGroupList[TeamID].TeamAIOrders then
    TeamAIManager.TeamAIGroupList[TeamID].TeamAIOrders = {}
  end
  if next(TeamAIManager.TeamAIGroupList[TeamID].TeamAIOrders) then
    for index, value in ipairs(TeamAIManager.TeamAIGroupList[TeamID].TeamAIOrders) do
      if value and value.OrderType == OrderType then
        return
      end
    end
  end
  local TeamAIOrder = self:NewTeamOrderByType(OrderType)
  if not TeamAIOrder then
    return
  end
  TeamAIOrder.TeamAIGroup = TeamAIManager.TeamAIGroupList[TeamID]
  local TeamAIOrders = TeamAIManager.TeamAIGroupList[TeamID].TeamAIOrders
  TeamAIOrders[#TeamAIOrders + 1] = TeamAIOrder
end
function TeamAIManager:GetAIOccupyPriority(AIPlayer)
  local Priority = 0
  if not Game:IsValid(AIPlayer) then
    return Priority
  end
  local TeamID = AIPlayer:GetTeamId()
  if TeamID <= 0 or TeamAIManager.TeamAIGroupList[TeamID] == nil then
    return Priority
  end
  local TeamAIGroup = TeamAIManager.TeamAIGroupList[TeamID]
  local OccupyPlayers = TeamAIGroup.OccupyPlayers
  if not OccupyPlayers or next(OccupyPlayers) == nil then
    return Priority
  end
  local PlayerKey = Game:GetPlayerKey(AIPlayer)
  if OccupyPlayers[PlayerKey] then
    Priority = OccupyPlayers[PlayerKey]
  end
  return Priority
end
function TeamAIManager:RemoveTeamOrder(TeamID, OrderType)
  if not TeamID or TeamID <= 0 then
    return
  end
  if not OrderType or OrderType <= 0 then
    return
  end
  if not TeamAIManager.TeamAIGroupList[TeamID] then
    return
  end
  local TeamAIGroup = TeamAIManager.TeamAIGroupList[TeamID]
  if not TeamAIGroup then
    return
  end
  if not TeamAIGroup.TeamAIOrders then
    for key, value in pairs(TeamAIGroup.TeamAIOrders) do
      if value.OrderType == OrderType then
        table.remove(TeamAIGroup.TeamAIOrders, key)
        return
      end
    end
  end
end
function TeamAI_HandleAIPlayerSpawn(_, __, AIPawn)
  print(bWriteLog and "AI Spawn!")
  if not Game:IsValid(AIPawn) then
    return
  end
  local TeamID = AIPawn:GetTeamId()
  if not TeamAIManager.TeamAIGroupList[TeamID] then
    local ObjectTemp = {}
    local class = require("class")
    local TeamAIGroupBase = require("GameLua.Mod.Library.DS.AI.TeamAI.TeamAIGroupBase")
    local CObjectPool = class(TeamAIGroupBase, nil, ObjectTemp)
    local TeamGroup = CObjectPool()
    TeamGroup.    TeamAIManager.TeamAIGroupList[TeamID] = TeamGroup
  end
  local nPlayerKey = Game:GetPlayerKey(AIPawn)
  if nPlayerKey and 0 < nPlayerKey then
    local TeamAIGroupPlayers = TeamAIManager.TeamAIGroupList[TeamID].Players
    TeamAIGroupPlayers[nPlayerKey] = AIPawn
  end
end
function TeamAI_HandleAIPlayerDie(_, __, Pawn, Killer, TypeID)
  print(bWriteLog and "AI Die!")
  if not Game:IsValid(Pawn) then
    return
  end
  local TeamID = Pawn:GetTeamId()
  if not TeamAIManager.TeamAIGroupList[TeamID] or not TeamAIManager.TeamAIGroupList[TeamID].Players then
    return
  end
  local nPlayerKey = Game:GetPlayerKey(Pawn)
  if nPlayerKey and 0 < nPlayerKey then
    local TeamAIGroupPlayers = TeamAIManager.TeamAIGroupList[TeamID].Players
    TeamAIGroupPlayers[nPlayerKey] = nil
  end
end
function TeamAIManager:NewTeamOrderByType(OrderType)
  if OrderType == TeamAIOrderType.FollowLeader then
    local TeamAIOrderFollowLeader = {}
    local class = require("class")
    local object = require("GameLua.Mod.Library.DS.AI.TeamAI.TeamAIOrderFollowLeader")
    local CTeamAIOrderFollowLeader = class(object, nil, TeamAIOrderFollowLeader)
    return CTeamAIOrderFollowLeader()
  elseif OrderType == TeamAIOrderType.GrabAirdrop then
    local TeamAIOrderGrabAirdrop = {}
    local class = require("class")
    local object = require("GameLua.Mod.Library.DS.AI.TeamAI.TeamAIOrderGrabAirdrop")
    local CTeamAIOrderGrabAirdrop = class(object, nil, TeamAIOrderGrabAirdrop)
    return CTeamAIOrderGrabAirdrop()
  elseif OrderType == TeamAIOrderType.RescueTeammate then
    local TeamAIOrderRescueTeammate = {}
    local class = require("class")
    local object = require("GameLua.Mod.Library.DS.AI.TeamAI.TeamAIOrderRescueTeammate")
    local CTeamAIOrderRescueTeammate = class(object, nil, TeamAIOrderRescueTeammate)
    return CTeamAIOrderRescueTeammate()
  elseif OrderType == TeamAIOrderType.TeamAttack then
    local TeamAIOrderTeamAttack = {}
    local class = require("class")
    local object = require("GameLua.Mod.Library.DS.AI.TeamAI.TeamAIOrderTeamAttack")
    local CTeamAIOrderTeamAttack = class(object, nil, TeamAIOrderTeamAttack)
    return CTeamAIOrderTeamAttack()
  end
end