local logic_reputation_system = {}
local creditScore, recoverScore, historyTab, creditLevelTab, needSlap
function logic_reputation_system:OnInitialize()
  logic_reputation_system.__super.OnInitialize(self)
  log(bWriteLog and "logic_reputation_system:OnInitialize")
  creditScore = 100
  recoverScore = 0
  historyTab = {}
  creditLevelTab = {}
  needSlap = false
end
function logic_reputation_system:RegistEvents()
  log(bWriteLog and "logic_reputation_system:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CREDIT_NOTICE, self.ShowReputationNotice, self)
end
function logic_reputation_system:GetHistoryTab()
  return historyTab
end
function logic_reputation_system:GetCreditScore()
  return creditScore
end
function logic_reputation_system:GetCreditLevelTab()
  return creditLevelTab
end
function logic_reputation_system:GetRecoverScore()
  return recoverScore
end
function logic_reputation_system:GetDescTable()
  local CreditScoreTable = CDataTable.GetTable("CreditScoreTable") or {}
  local descData = {}
  for k, v in pairs(CreditScoreTable) do
    descData[v.ID] = {}
    for id, val in pairs(v) do
      descData[v.ID][id] = val
    end
  end
  for k, v in ipairs(creditLevelTab) do
    descData[k].ExpRate = v.exp_ratio
    descData[k].AddCoins = v.add_gold_limit
  end
  table.sort(descData, function(a, b)
    return a.ID > b.ID
  end)
  return descData
end
function logic_reputation_system:GetCurDescStr(curScore)
  local curDescStr = ""
  local curDescExtraStr = ""
  local descData = self:GetDescTable()
  for k, v in pairs(descData) do
    local minScore = v.FloorScore
    local maxScore = v.CeilingScore
    if curScore >= minScore and curScore <= maxScore then
      curDescStr = v.ScoreDesc
      if 100 <= minScore then
        do
          local addScore = CDataTable.GetTableData("ParamTable", "credit_score_add")
          curDescExtraStr = LocUtil.LocalizeResFormatByStr(v.ScoreDescExtra, v.AddCoins, addScore.ParamValue)
        end
        break
      end
      curDescExtraStr = LocUtil.LocalizeResFormatByStr(v.ScoreDescExtra, 100 - v.ExpRate)
      break
    end
  end
  return curDescStr, curDescExtraStr
end
function logic_reputation_system:GetLastestIndex(history, keysToSkip, score)
  local maxTimeStamp = 0
  local indexFound = 0
  for k, v in pairs(history) do
    local bValidKey = true
    for i = 1, #keysToSkip do
      if keysToSkip[i] == k then
        bValidKey = false
        break
      end
    end
    if bValidKey and maxTimeStamp <= v.now_time then
      maxTimeStamp = v.now_time
      if v.now_score == score then
        indexFound = k
      end
    end
  end
  return indexFound
end
function logic_reputation_system:ShouldShowReputationNotice()
  log(bWriteLog and "logic_reputation_system:ShouldShowReputationNotice needSlap: " .. tostring(needSlap))
  if not needSlap then
    return false
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  if logic_player_return.blockTip then
    log(bWriteLog and "logic_reputation_system:ShouldShowReputationNotice is return player")
    needSlap = false
    return false
  end
  needSlap = false
  return true
end
function logic_reputation_system:ShowReputationNotice()
  log(bWriteLog and "logic_reputation_system:ShowReputationNotice")
  UIManager.ShowUI(UIManager.UI_Config.ReputationSystem_Popup_UIBP)
end
function logic_reputation_system:RequestCreditInfo()
  local ReputationHandler = require("client.network.Protocol.ReputationHandler")
  ReputationHandler.send_get_credit_info_v2_req()
end
function logic_reputation_system:OnGetCreditInfo(creditInfo, creditLevelInfo)
  if creditInfo == nil or next(creditInfo) == nil then
    log(bWriteLog and "logic_reputation_system:OnGetCreditInfo get creditInfo failed")
    return
  end
  creditLevelTab = creditLevelInfo or {}
  self:OnNotifyCreditInfo(creditInfo)
end
function logic_reputation_system:OnNotifyCreditInfo(creditInfo)
  if creditInfo == nil or next(creditInfo) == nil then
    log(bWriteLog and "logic_reputation_system:OnNotifyCreditInfo get creditInfo failed")
    return
  end
  creditScore = creditInfo.credit_score or 100
  DataMgr.roleData.credit = creditScore
  local history = creditInfo.history or {}
  if creditInfo.day_info then
    local maxRecoverScore = creditInfo.day_info.max_recovery_score or 0
    local hasRecoverScore = creditInfo.day_info.recovery_score or 0
    recoverScore = maxRecoverScore - hasRecoverScore
    if recoverScore < 0 then
      recoverScore = 0
    end
  end
  historyTab = {}
  if type(history) ~= "table" then
    log(bWriteLog and "logic_reputation_system:OnNotifyCreditInfo type of history is not table")
    return
  end
  local keysToSkip = {}
  local curScore = creditScore
  local recordNum = #history
  local bIsLegal = true
  for i = 1, recordNum + 1 do
    local nextKey = self:GetLastestIndex(history, keysToSkip, curScore)
    if history[nextKey] then
      table.insert(historyTab, history[nextKey])
      table.insert(keysToSkip, nextKey)
      curScore = history[nextKey].now_score - history[nextKey].modify_score
    else
      log(bWriteLog and "logic_reputation_system:OnNotifyCreditInfo history is illegal")
      bIsLegal = false
      break
    end
  end
  if not bIsLegal then
    historyTab = {}
    for k, v in pairs(history) do
      table.insert(historyTab, v)
    end
    table.sort(historyTab, function(a, b)
      if a.now_time == b.now_time then
        if a.modify_score < 0 and b.modify_score < 0 then
          return a.now_score < b.now_score
        elseif a.modify_score > 0 and b.modify_score > 0 then
          return a.now_score > b.now_score
        else
          return false
        end
      end
      return a.now_time > b.now_time
    end)
  end
  EventSystem:postEvent(EVENTTYPE_REPUTATION, EVENTID_REPUTATION_GET_CREDIT_INFO)
end
function logic_reputation_system:RequestParamTab()
  local ReputationHandler = require("client.network.Protocol.ReputationHandler")
  ReputationHandler.send_get_credit_conf_v2_req()
end
function logic_reputation_system:OnGetParamTab(creditLevelInfo)
  creditLevelTab = creditLevelInfo or {}
  EventSystem:postEvent(EVENTTYPE_REPUTATION, EVENTID_REPUTATION_GET_PARAM_TAB)
end
function logic_reputation_system:OnNotifyShowNotice()
  needSlap = true
end
function logic_reputation_system:ReportAcceptCreditPack()
  local ReputationHandler = require("client.network.Protocol.ReputationHandler")
  ReputationHandler.send_accept_credit_pact()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CReputationSystem = class(CModuleBase, nil, logic_reputation_system)
return CReputationSystem