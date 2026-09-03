local logic_return_recommend_friend = {}
function logic_return_recommend_friend:DefineAndResetData()
  self.recType = {
    RecNormal2Return = 1,
    RecReturn2Normal = 2,
    RecReturn2Return = 3
  }
  self.recCondType = {
    BeRevived = 1,
    BeRescued = 2,
    BeAssist = 3,
    BeLiked = 4,
    MVP = 5,
    TDMOurHighestKDA = 6,
    TDMOtherHighestKDA = 7,
    UGCBeAssist = 8,
    UGCPlayTime = 9
  }
  self.type2LocIdMap = {
    [self.recType.RecNormal2Return] = {
      [self.recCondType.BeRevived] = 86175,
      [self.recCondType.BeRescued] = 86176,
      [self.recCondType.BeAssist] = 86177,
      [self.recCondType.BeLiked] = 86178,
      [self.recCondType.MVP] = 86179,
      [self.recCondType.TDMOurHighestKDA] = 86180,
      [self.recCondType.TDMOtherHighestKDA] = 86181,
      [self.recCondType.UGCBeAssist] = 86182,
      [self.recCondType.UGCPlayTime] = 86183
    },
    [self.recType.RecReturn2Normal] = {
      [self.recCondType.BeRevived] = 86166,
      [self.recCondType.BeRescued] = 86167,
      [self.recCondType.BeAssist] = 86168,
      [self.recCondType.BeLiked] = 86169,
      [self.recCondType.MVP] = 86170,
      [self.recCondType.TDMOurHighestKDA] = 86171,
      [self.recCondType.TDMOtherHighestKDA] = 86172,
      [self.recCondType.UGCBeAssist] = 86173,
      [self.recCondType.UGCPlayTime] = 86174
    },
    [self.recType.RecReturn2Return] = {
      [self.recCondType.BeRevived] = 86184,
      [self.recCondType.BeRescued] = 86185,
      [self.recCondType.BeAssist] = 86186,
      [self.recCondType.BeLiked] = 86187,
      [self.recCondType.MVP] = 86188,
      [self.recCondType.TDMOurHighestKDA] = 86189,
      [self.recCondType.TDMOtherHighestKDA] = 86190,
      [self.recCondType.UGCBeAssist] = 86191,
      [self.recCondType.UGCPlayTime] = 86192
    }
  }
  self.bPreTeamupSwitch = true
end
function logic_return_recommend_friend:_GMSetTargetTDMRec(bSwitch, bIsSelfTeam, bIsReturnPlayer)
  self.bGMTDMSwitch = bSwitch == 1 and true or false
  self.bGMTDMSelfTeam = bIsSelfTeam == 0 and true or false
  self.bGMTDMSelfReturnPlayer = bIsReturnPlayer == 1 and true or false
end
function logic_return_recommend_friend:_GMSetPreTeamupSwitch(bSwitch)
  self.bPreTeamupSwitch = bSwitch == 1 and true or false
end
function logic_return_recommend_friend:_CheckVaildUID(playerData)
  local uid = tonumber(playerData.UID)
  if uid == tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and string.format("logic_return_recommend_friend:_CheckVaildUID is self, uid:%s", uid))
    return false
  end
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  if logic_new_friend.IsMyFriend(uid) then
    log(bWriteLog and string.format("logic_return_recommend_friend:_CheckVaildUID is friend, uid:%s", uid))
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
  if self.bPreTeamupSwitch and memberInfo then
    log(bWriteLog and string.format("logic_return_recommend_friend:_CheckVaildUID is pre memberInfo, uid:%s", uid))
    return false
  end
  if playerData.last_rejoin_time ~= nil and not playerData.backuser_recommend_abtest then
    log(bWriteLog and string.format("logic_return_recommend_friend:_CheckVaildUID not hit abtest, uid:%s", uid))
    return false
  end
  return true
end
function logic_return_recommend_friend:_IsInABTest(battle_result)
  if battle_result.IsDeathMatchResult then
    for k, teamData in ipairs(battle_result.TeamResultDatas or {}) do
      for i, playerData in ipairs(teamData.TeamPlayerResultDatas) do
        local uid = tonumber(playerData.UID)
        log(bWriteLog and string.format("logic_return_recommend_friend:_IsInABTest, playerData.last_rejoin_time:%s", playerData.last_rejoin_time))
        log(bWriteLog and string.format("logic_return_recommend_friend:_IsInABTest, playerData.backuser_recommend_abtest:%s", playerData.backuser_recommend_abtest))
        if uid == tonumber(DataMgr.roleData.uid) and playerData.last_rejoin_time ~= nil and not playerData.backuser_recommend_abtest then
          log(bWriteLog and "logic_return_recommend_friend _IsInABTest return of no hit abtest")
          return false
        end
      end
    end
  else
    for k, v in pairs(battle_result.TeammateList or {}) do
      local uid = tonumber(v.UID)
      log(bWriteLog and string.format("logic_return_recommend_friend:_IsInABTest, v.last_rejoin_time:%s", v.last_rejoin_time))
      log(bWriteLog and string.format("logic_return_recommend_friend:_IsInABTest, v.backuser_recommend_abtest:%s", v.backuser_recommend_abtest))
      if uid == tonumber(DataMgr.roleData.uid) and v.last_rejoin_time ~= nil and not v.backuser_recommend_abtest then
        log(bWriteLog and "logic_return_recommend_friend _IsInABTest return of no hit abtest")
        return false
      end
    end
  end
  return true
end
function logic_return_recommend_friend:_OnBattleResult(_, _, battle_result)
  log_tree(bWriteLog and "logic_return_recommend_friend:_OnBattleResult battle_result", battle_result)
  local TableUtil = require("common.table_util")
  self.battleResult = TableUtil.CopyTable(battle_result)
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if not AssemblyActivitySystem.HasActivity() then
    log(bWriteLog and "logic_return_recommend_friend:_OnBattleResult return of no assembly activity")
    return
  end
  local logic_assembly_activity = require("client.slua.logic.come_back.logic_assembly_activity")
  if logic_assembly_activity.IsBackCornReachLimit() or logic_assembly_activity.IsBackCornReachTodayLimit() then
    log(bWriteLog and "logic_return_recommend_friend:_OnBattleResult return of coin limit")
    return
  end
  if not self.battleResult.IsDeathMatchResult and not self.battleResult.IsUGCMatchMode and not self.battleResult.is_team_result then
    log(bWriteLog and "logic_return_recommend_friend:_OnBattleResult return of not is_team_result")
    return
  end
  if not self:_IsInABTest(self.battleResult) then
    return
  end
  self:AddTimerOnce(1, function()
    local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
    PlayerReturnHandler.send_backuser_client_recommend_frd_req():Then(function(res)
      log(bWriteLog and string.format("logic_return_recommend_friend:send_backuser_client_recommend_frd_req, res:%s", res))
      if res == 0 then
        self:FindTargetPlayer(self.battleResult)
      end
    end)
  end)
end
function logic_return_recommend_friend:FindTargetPlayer(battle_result)
  log_tree(bWriteLog and "logic_return_recommend_friend:FindTargetPlayer battle_result", battle_result)
  local modeId = battle_result.battle_type
  local history_combat_util = require("client.logic.combat.history.history_combat_util")
  if history_combat_util.IsClassicRankMode(modeId) or history_combat_util.IsMatchMode(modeId) then
    log(bWriteLog and string.format("logic_return_recommend_friend:FindTargetPlayer, strCode:%s", 1))
    self.targetPlayerData = self:GetRecTargetPlayerForClassicMode(battle_result)
  elseif battle_result.IsDeathMatchResult then
    log(bWriteLog and string.format("logic_return_recommend_friend:FindTargetPlayer, strCode:%s", 2))
    self.targetPlayerData = self:GetRecTargetPlayerForTeamMode(battle_result)
  elseif battle_result.IsUGCMatchMode == true then
    log(bWriteLog and string.format("logic_return_recommend_friend:FindTargetPlayer, strCode:%s", 3))
    self.targetPlayerData = self:GetRecTargetPlayerForUGCMode(battle_result)
  end
end
function logic_return_recommend_friend:_SendRecTargetUID(playerData)
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local bIsSelfReturnPlayer = logic_return_activity_utils.IsActInProgress()
  if not playerData.bIsReturnPlayer and not bIsSelfReturnPlayer then
    return
  end
  local actionType = 3
  local recType = self.recType.RecNormal2Return
  if bIsSelfReturnPlayer then
    if playerData.bIsReturnPlayer then
      recType = self.recType.RecReturn2Return
    else
      recType = self.recType.RecReturn2Normal
    end
    actionType = 1
  end
  local locId = self.type2LocIdMap[recType][playerData.recCondType]
  local desc = LocUtil.GetLocalizeResStr(locId)
  UIManager.ShowUI(UIManager.UI_Config.Return_Team_Recommend_InGame_UIBP, actionType, playerData.uid, desc)
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_back_user_client_recommend_frd_report(playerData.uid)
end
function logic_return_recommend_friend:OnInitialize()
end
function logic_return_recommend_friend:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, self._OnBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_TDM_GET_RESULT_RSP, self._OnBattleResult, self)
end
function logic_return_recommend_friend:OnLogin(bReLogin)
end
function logic_return_recommend_friend:OnLogOut()
end
function logic_return_recommend_friend:OnPreSwitchGameStatus(preState, nextState)
end
function logic_return_recommend_friend:OnPostSwitchGameStatus(preState, nextState)
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    self.targetPlayerData = nil
    self.battleResult = nil
    local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
    logic_team_up.CheckInviteList()
  end
end
function logic_return_recommend_friend:IsNeedShowRecUI()
  if self.targetPlayerData then
    self:_SendRecTargetUID(self.targetPlayerData)
    self.targetPlayerData = nil
    return true
  end
  return false
end
function logic_return_recommend_friend:GetRecTargetPlayerForClassicMode(result)
  local targetRecUIDMap = {}
  local canRecUIDMap = {}
  local FindTargetPlayerUID = function()
    if next(targetRecUIDMap) then
      for k, v in pairs(targetRecUIDMap) do
        if v.bIsReturnPlayer then
          return k
        end
      end
      for k, v in pairs(targetRecUIDMap) do
        if not v.bIsReturnPlayer then
          return k
        end
      end
    end
  end
  for k, v in pairs(result.TeammateList or {}) do
    local uid = tonumber(v.UID)
    if self:_CheckVaildUID(v) then
      canRecUIDMap[uid] = {
        bIsReturnPlayer = v.last_rejoin_time ~= nil
      }
    end
  end
  log_tree(bWriteLog and "logic_return_recommend_friend:GetRecTargetPlayerForClassicMode canRecUIDMap", canRecUIDMap)
  local actionLuaTlog = result.LuaTLog
  for k, uid in pairs(actionLuaTlog and actionLuaTlog.BeRevivedTeammatesList or {}) do
    if canRecUIDMap[tonumber(uid)] then
      targetRecUIDMap[tonumber(uid)] = {
        uid = tonumber(uid),
        bIsReturnPlayer = canRecUIDMap[tonumber(uid)].bIsReturnPlayer,
        recCondType = self.recCondType.BeRevived
      }
      log(bWriteLog and string.format("logic_return_recommend_friend:GetRecTargetPlayerForClassicMode BeRevivedTeammatesList, uid:%s", uid))
    end
  end
  local targetUID = FindTargetPlayerUID()
  if targetUID then
    return targetRecUIDMap[targetUID]
  end
  for k, v in pairs(result.TeammateList or {}) do
    if canRecUIDMap[tonumber(v.UID)] then
      for i, uid in ipairs(v.RescueTeammatesList or {}) do
        if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
          targetRecUIDMap[tonumber(v.UID)] = {
            uid = tonumber(v.UID),
            bIsReturnPlayer = canRecUIDMap[tonumber(v.UID)].bIsReturnPlayer,
            recCondType = self.recCondType.BeRescued
          }
          log(bWriteLog and string.format("logic_return_recommend_friend:GetRecTargetPlayerForClassicMode RescueTeammatesList, uid:%s", v.UID))
        end
      end
    end
  end
  local targetUID = FindTargetPlayerUID()
  if targetUID then
    return targetRecUIDMap[targetUID]
  end
  for k, v in pairs(result.TeammateList or {}) do
    if canRecUIDMap[tonumber(v.UID)] then
      for i, uid in ipairs(v.AssistTeammatesList or {}) do
        if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
          targetRecUIDMap[tonumber(v.UID)] = {
            uid = tonumber(v.UID),
            bIsReturnPlayer = canRecUIDMap[tonumber(v.UID)].bIsReturnPlayer,
            recCondType = self.recCondType.BeAssist
          }
          log(bWriteLog and string.format("logic_return_recommend_friend:GetRecTargetPlayerForClassicMode AssistTeammatesList, uid:%s", v.UID))
        end
      end
    end
  end
  local targetUID = FindTargetPlayerUID()
  if targetUID then
    return targetRecUIDMap[targetUID]
  end
  for k, uid in pairs(actionLuaTlog and actionLuaTlog.BeLikedTeammatesList or {}) do
    if canRecUIDMap[tonumber(uid)] then
      targetRecUIDMap[tonumber(uid)] = {
        uid = tonumber(uid),
        bIsReturnPlayer = canRecUIDMap[tonumber(uid)].bIsReturnPlayer,
        recCondType = self.recCondType.BeLiked
      }
      log(bWriteLog and string.format("logic_return_recommend_friend:GetRecTargetPlayerForClassicMode BeLikedTeammatesList, uid:%s", uid))
    end
  end
  local targetUID = FindTargetPlayerUID()
  if targetUID then
    return targetRecUIDMap[targetUID]
  end
  for k, v in pairs(result.TeammateList or {}) do
    if canRecUIDMap[tonumber(v.UID)] and v.IsMVP then
      targetRecUIDMap[tonumber(v.UID)] = {
        uid = tonumber(v.UID),
        bIsReturnPlayer = canRecUIDMap[tonumber(v.UID)].bIsReturnPlayer,
        recCondType = self.recCondType.MVP
      }
      log(bWriteLog and string.format("logic_return_recommend_friend:GetRecTargetPlayerForClassicMode IsMVP, uid:%s", v.UID))
    end
  end
  local targetUID = FindTargetPlayerUID()
  if targetUID then
    return targetRecUIDMap[targetUID]
  end
end
function logic_return_recommend_friend:GetRecTargetPlayerForTeamMode(result)
  local canRecUIDMap = {}
  local myTeamID = result.my_result.TeamID
  local myTeamData = result.TeamResultDatas[myTeamID]
  for k, teamData in ipairs(result.TeamResultDatas or {}) do
    for i, playerData in ipairs(teamData.TeamPlayerResultDatas) do
      if self.bGMTDMSwitch then
        if tonumber(playerData.UID) ~= tonumber(DataMgr.roleData.uid) then
          canRecUIDMap[tonumber(playerData.UID)] = {
            uid = tonumber(playerData.UID),
            bIsReturnPlayer = self.bGMTDMSelfReturnPlayer
          }
        end
      elseif self:_CheckVaildUID(playerData) and not playerData.is_robot then
        canRecUIDMap[tonumber(playerData.UID)] = {
          uid = tonumber(playerData.UID),
          bIsReturnPlayer = playerData.last_rejoin_time ~= nil
        }
      end
    end
  end
  log_tree(bWriteLog and "logic_return_recommend_friend:GetRecTargetPlayerForTeamMode canRecUIDMap", canRecUIDMap)
  local targetTeamData = myTeamData.TeamRank == 1 and myTeamData or result.TeamResultDatas[myTeamData.TeamID == 1 and 2 or 1]
  local recCondType = myTeamData.TeamRank == 1 and self.recCondType.TDMOurHighestKDA or self.recCondType.TDMOtherHighestKDA
  if self.bGMTDMSwitch then
    targetTeamData = self.bGMTDMSelfTeam and myTeamData or result.TeamResultDatas[myTeamData.TeamID == 1 and 2 or 1]
    recCondType = self.bGMTDMSelfTeam and self.recCondType.TDMOurHighestKDA or self.recCondType.TDMOtherHighestKDA
  end
  local maxKDAUID = 0
  for k, v in ipairs(targetTeamData.TeamPlayerResultDatas) do
    if canRecUIDMap[tonumber(v.UID)] and tonumber(v.UID) ~= tonumber(DataMgr.roleData.uid) and v.mvp == 1 then
      maxKDAUID = tonumber(v.UID)
      break
    end
  end
  if maxKDAUID ~= 0 then
    canRecUIDMap[maxKDAUID].    return canRecUIDMap[maxKDAUID]
  end
end
function logic_return_recommend_friend:GetRecTargetPlayerForUGCMode(result)
  local targetRecUIDMap = {}
  local canRecUIDMap = {}
  local FindTargetPlayerUID = function()
    if next(targetRecUIDMap) then
      for k, v in pairs(targetRecUIDMap) do
        if v.bIsReturnPlayer then
          return k
        end
      end
      for k, v in pairs(targetRecUIDMap) do
        if not v.bIsReturnPlayer then
          return k
        end
      end
    end
  end
  for k, v in pairs(result.TeammateList or {}) do
    if self:_CheckVaildUID(v) then
      canRecUIDMap[tonumber(v.UID)] = {
        bIsReturnPlayer = v.last_rejoin_time ~= nil
      }
    end
  end
  log_tree(bWriteLog and "logic_return_recommend_friend:GetRecTargetPlayerForUGCMode canRecUIDMap", canRecUIDMap)
  for k, v in pairs(result.TeammateList or {}) do
    if canRecUIDMap[tonumber(v.UID)] then
      for i, uid in ipairs(v.AssistTeammatesList or {}) do
        if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
          targetRecUIDMap[tonumber(v.UID)] = {
            uid = tonumber(v.UID),
            bIsReturnPlayer = canRecUIDMap[tonumber(v.UID)].bIsReturnPlayer,
            recCondType = self.recCondType.UGCBeAssist
          }
          log(bWriteLog and string.format("logic_return_recommend_friend:GetRecTargetPlayerForUGCMode AssistTeammatesList, uid:%s", v.UID))
        end
      end
    end
  end
  local targetUID = FindTargetPlayerUID()
  if targetUID then
    return targetRecUIDMap[targetUID]
  end
  if result.OnlineTime > 600 then
    for k, v in pairs(result.TeammateList or {}) do
      if canRecUIDMap[tonumber(v.UID)] then
        targetRecUIDMap[tonumber(v.UID)] = {
          uid = tonumber(v.UID),
          bIsReturnPlayer = canRecUIDMap[tonumber(v.UID)].bIsReturnPlayer,
          recCondType = self.recCondType.UGCPlayTime
        }
        log(bWriteLog and string.format("logic_return_recommend_friend:GetRecTargetPlayerForUGCMode OnlineTime, uid:%s", v.UID))
      end
    end
  end
  local targetUID = FindTargetPlayerUID()
  if targetUID then
    return targetRecUIDMap[targetUID]
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_return_recommend_friend = class(CModuleBase, nil, logic_return_recommend_friend)
return Clogic_return_recommend_friend