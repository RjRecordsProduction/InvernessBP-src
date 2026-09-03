local logic_interaction = {}
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
function logic_interaction:DefineAndResetData()
  self.frd_interact_info = {}
  self.record_lis = {}
  self.FireType = {
    initial = 0,
    Bright = 1,
    destroy = 2,
    recover = 3
  }
  self.fireList = {}
  self.isShowTips = false
  self.reward_data_list = {}
  self.reward_limit_num = 10
end
function logic_interaction:OnInitialize()
end
function logic_interaction:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CHAT_SCINTILLA, self.OnJumpScintilla, self)
end
function logic_interaction:OnJumpScintilla(_, moduleId, params)
  if not params or not params.uid then
    return
  end
  local uid = tonumber(params.uid)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_RecordMain_UIBP, uid, 2)
end
function logic_interaction:GetInteractionScore(frd_uid)
  if self.frd_interact_info and self.frd_interact_info[frd_uid] then
    return self.frd_interact_info[frd_uid].score, self.frd_interact_info[frd_uid].status
  elseif self.fireList and self.fireList[frd_uid] then
    return self.fireList[frd_uid].score, self.fireList[frd_uid].status
  elseif self.innerList and self.innerList[frd_uid] then
    return self.innerList[frd_uid].score, self.innerList[frd_uid].status
  else
    return nil, nil
  end
end
function logic_interaction:GetInteractInfo(frd_uid)
  return self.frd_interact_info[frd_uid]
end
function logic_interaction:GetRecordInfo(frd_uid)
  return self.record_lis[frd_uid]
end
function logic_interaction:DeleteInteractionInfo(frd_uid)
  if self.frd_interact_info and self.frd_interact_info[frd_uid] then
    self.frd_interact_info[frd_uid] = nil
  end
  if self.fireList and self.fireList[frd_uid] then
    self.fireList[frd_uid] = nil
  end
end
function logic_interaction:ConvertRewardData(nUId, uConfig, nRewardedBit)
  local tData = {
    score = uConfig.Score,
    TableID = uConfig.ID,
    RewardID = uConfig.RewardItemId1,
    Num = uConfig.RewardCount1,
    LimitedTime = uConfig.RewardItemLimitTime1
  }
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    tData.RewardID = uConfig.JK_RewardItemId1
    tData.Num = uConfig.JK_RewardCount1
    tData.LimitedTime = uConfig.JK_RewardItemLimitTime1
  end
  tData.bIsReceived = self:IsRewardRecieved(nUId, uConfig.ID, nRewardedBit)
  tData.bIsUnlocked = self:IsRewardUnlocked(nUId, uConfig.ID, uConfig)
  tData.bIsLimited = self:IsRewardLimited(uConfig.ID)
  tData.frd_uid = nUId
  return tData
end
function logic_interaction:GetRewardsData(UID)
  local rewarded_bits = 0
  if self.frd_interact_info[UID] and self.frd_interact_info[UID].rewarded_bits then
    rewarded_bits = self.frd_interact_info[UID].rewarded_bits
  end
  if not rewarded_bits then
    log(bWriteLog and "logic_interaction:GetRewards failed to get rewards data because rewarded bits is null")
    return
  end
  local rewards_data_list = {}
  local uAllInteractionPointsCfg = CDataTable.GetTable("InteractionPoints")
  if not uAllInteractionPointsCfg then
    log(bWriteLog and "logic_interaction:GetInteractionCfg failed to get interaction points config")
    return
  end
  for _, v in pairs(uAllInteractionPointsCfg) do
    local tData = self:ConvertRewardData(UID, v, rewarded_bits)
    table.insert(rewards_data_list, tData)
  end
  return rewards_data_list
end
function logic_interaction:GetRewardData(UID, reward_idx)
  local rewarded_bits = self.frd_interact_info[UID].rewarded_bits or 0
  local reward_config = CDataTable.GetTableData("InteractionPoints", reward_idx)
  local reward_data = self:ConvertRewardData(UID, reward_config, rewarded_bits)
  return reward_data
end
function logic_interaction:HasRewards(fri_uid)
  local rewarded_bits = 0
  if self.frd_interact_info and self.frd_interact_info[fri_uid] then
    rewarded_bits = self.frd_interact_info[fri_uid].rewarded_bits or 0
  end
  if not rewarded_bits then
    return false
  end
  local uAllInteractionPointsCfg = CDataTable.GetTable("InteractionPoints")
  if not uAllInteractionPointsCfg then
    log(bWriteLog and "logic_interaction:GetInteractionCfg failed to get interaction points config")
    return false
  end
  for _, v in pairs(uAllInteractionPointsCfg) do
    if self:IsRewardUnlocked(fri_uid, v.ID, v) and not self:IsRewardRecieved(fri_uid, v.ID, rewarded_bits) and not self:IsRewardLimited(v.ID) then
      return true
    end
  end
  return false
end
function logic_interaction:IsRewardUnlocked(f_uid, lv, uConfig)
  if not f_uid or not lv then
    log(bWriteLog and "logic_interaction:IsRewardUnlocked failed due to a nil param")
    return false
  end
  local score = 0
  if self.frd_interact_info and self.frd_interact_info[f_uid] and self.frd_interact_info[f_uid].score then
    score = self.frd_interact_info[f_uid].score
  else
    log(bWriteLog and "logic_interaction:IsRewardUnlocked failed due to nil user info")
  end
  if not uConfig then
    uConfig = CDataTable.GetTableData("InteractionPoints", lv)
    if not uConfig then
      log(bWriteLog and "logic_interaction:IsRewardUnlocked failed due to nil config")
      return false
    end
  end
  return score >= uConfig.Score
end
function logic_interaction:IsRewardRecieved(f_uid, lv, rewarded_bits)
  if not rewarded_bits then
    if f_uid and self.frd_interact_info[f_uid] then
      rewarded_bits = self.frd_interact_info[f_uid].rewarded_bits or 0
    else
      return false
    end
  end
  return rewarded_bits & 1 << lv - 1 ~= 0
end
function logic_interaction:IsRewardLimited(lv)
  if not (self.reward_data_list and self.reward_data_list.list) or not self.reward_data_list.list[lv] then
    return false
  end
  return self.reward_data_list.list[lv] >= self.reward_limit_num
end
function logic_interaction:GetIconInfoByID(frd_uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local relation = LogicFriend.GetRelation(frd_uid)
  local score, status = self:GetInteractionScore(frd_uid)
  if not score or not status then
    return
  end
  local iconPath, iconName
  if status == 1 then
    iconPath, iconName = self:GetIconInfo(relation, score, "Bright")
  else
    iconPath, iconName = self:GetIconInfo(relation, score, "Destruction")
  end
  return iconPath, iconName, score, status
end
function logic_interaction:GetIconInfo(relation, score, pattern)
  if not (relation and score) or not pattern then
    log(bWriteLog and "logic_interaction:GetIconInfo: Error Failed to get icon info due to nil params")
    return
  end
  local IconKey, NameKey = self:GetInteractionIconKey(relation, pattern)
  local IconConfigs = self:GetInteractionIconConfigs(score)
  if not (IconConfigs and IconConfigs[IconKey]) or not IconConfigs[NameKey] then
    log(bWriteLog and "logic_interaction:GetIconInfo: Error Failed to get icon info due to nil configs: " .. IconKey .. "  " .. NameKey)
    return
  end
  if string.len(IconConfigs[NameKey]) == 0 then
    return IconConfigs[IconKey], nil
  end
  return IconConfigs[IconKey], LocUtil.LocalizeResFormatByStr(IconConfigs[NameKey])
end
function logic_interaction:GetInteractionIconConfigs(score)
  local ScoreIconConfigs = CDataTable.GetTable("ScoreIcon")
  local result = ScoreIconConfigs[1]
  for level, info in pairs(ScoreIconConfigs) do
    if score and info.score and score >= info.score then
      result = info
    end
  end
  return result
end
function logic_interaction:GetInteractionIconKey(relation, pattern)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local relationKey = ""
  if not relation or relation == 0 then
    relationKey = "Ordinary"
  elseif relation == IntimacyConst.EIntimacyType.Lover then
    relationKey = "Lovers"
  else
    relationKey = "NotLovers"
  end
  local patternKey = pattern or "Bright"
  return relationKey .. patternKey, relationKey .. "Name"
end
function logic_interaction:GetInteractiveScoreandTexture(frd_uid)
  if tonumber(frd_uid) == tonumber(DataMgr.roleData.uid) or frd_uid == 0 then
    return nil
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local relation = LogicFriend.GetRelation(frd_uid)
  local score = self:GetInteractionScore(frd_uid)
  local iconPath, iconName = self:GetIconInfo(relation, score, "Bright")
  return score, iconPath, iconName
end
function logic_interaction:GetInteractionRecord(fri_uid, bFilterInterrupt)
  local configs = CDataTable.GetTable("MilestoneEvents")
  local InteractiveBehaviors = CDataTable.GetTable("InteractiveBehavior")
  local InteractionRecordData = {}
  if not self.record_lis or not self.record_lis[fri_uid] then
    return
  end
  local record = self.record_lis[fri_uid]
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local relation = LogicFriend.GetRelation(fri_uid)
  table.sort(record, function(a, b)
    return a.optime > b.optime
  end)
  local FilteredRecordData = {}
  for k, v in pairs(record) do
    local last_rec = FilteredRecordData[#FilteredRecordData]
    if last_rec and v.op_type == 2 and last_rec.op_type == v.op_type and bFilterInterrupt then
    else
      table.insert(FilteredRecordData, v)
    end
  end
  for k, v in pairs(FilteredRecordData) do
    local dataText
    if v.op_type == 5 then
      if v.para2 == 0 then
      else
        dataText = LocUtil.GeneralFormat(configs[v.op_type].InteractionRecord, InteractiveBehaviors[v.para1].Text, InteractiveBehaviors[v.para1].Score)
      end
    elseif v.op_type == 1 then
      local sparkIcon, name = self:GetIconInfo(relation, v.para1, "Bright")
      dataText = name and LocUtil.GeneralFormat(configs[v.op_type].InteractionRecord, v.para1, name)
    elseif v.op_type == 2 then
      local sparkIcon, name = self:GetIconInfoByID(fri_uid)
      dataText = name and LocUtil.GeneralFormat(configs[v.op_type].InteractionRecord, v.para2, name)
    elseif v.op_type == 3 then
      local sparkIcon, name = self:GetIconInfoByID(fri_uid)
      dataText = name and LocUtil.GeneralFormat(configs[v.op_type].InteractionRecord, v.para1, name)
    elseif v.op_type == 4 then
      local sparkIcon, name = self:GetIconInfo(relation, v.para1, "Bright")
      dataText = name and LocUtil.GeneralFormat(configs[v.op_type].InteractionRecord, v.para1, name)
    elseif v.op_type == 6 then
      dataText = LocUtil.GeneralFormat(configs[v.op_type].InteractionRecord, v.para2)
    end
    if configs[v.op_type] and dataText then
      local data = {
        optime = v.optime,
        text = dataText
      }
      table.insert(InteractionRecordData, data)
    end
  end
  table.sort(InteractionRecordData, function(a, b)
    return a.optime > b.optime
  end)
  return InteractionRecordData
end
function logic_interaction:GetDailyInteractRecord(fri_uid)
  local InteractiveBehaviors = CDataTable.GetTable("InteractiveBehavior")
  local DailyInteractions, FinishedInteractions = {}, {}
  local DailyScore = 0
  if not self.frd_interact_info or not self.frd_interact_info[fri_uid] then
    return
  end
  for index, Behavior in pairs(InteractiveBehaviors) do
    local isFinish = self:IsInteractionFinished(fri_uid, index)
    local RecordEntry = {
      ID = Behavior.ID,
      Text = Behavior.Text,
          }
    if isFinish then
      DailyScore = DailyScore + Behavior.Score
      table.insert(FinishedInteractions, RecordEntry)
    else
      table.insert(DailyInteractions, RecordEntry)
    end
  end
  for _, v in ipairs(FinishedInteractions) do
    table.insert(DailyInteractions, v)
  end
  return DailyInteractions, DailyScore
end
function logic_interaction:IsInteractionFinished(fri_uid, index)
  if not (fri_uid and self.frd_interact_info) or not self.frd_interact_info[fri_uid] then
    return false
  end
  local cur_interact_bits = self.frd_interact_info[fri_uid].cur_interact_bits or 0
  return cur_interact_bits & 1 << index - 1 ~= 0
end
function logic_interaction:GetLastInteractiveScore(friendId)
  local interactiveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.InteractiveData) or {}
  return interactiveData[friendId] or 0
end
function logic_interaction:CacheInteractiveScore(friendId, score)
  local interactiveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.InteractiveData) or {}
  interactiveData[friendId] = score
  PlayerPrefsSystem.SaveTableToFile_N(interactiveData, PlayerPrefsSystem.ePlayerPrefsType.InteractiveData)
end
function logic_interaction:ClearInteractiveScoreCache()
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.InteractiveData)
end
function logic_interaction:send_get_interact_info_req(frd_uid)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  log(bWriteLog and "logic_interaction:send_get_interact_info_req")
  ChatHandler.send_get_interact_info_req(tonumber(frd_uid))
end
function logic_interaction:on_get_interact_info_rsp(frd_uid, frd_interact_info, record_lis, interact_reward_limit_data, limit_num)
  log(bWriteLog and "logic_interaction:on_get_interact_info_rsp")
  if not self.frd_interact_info then
    self.frd_interact_info = {}
  end
  self.frd_interact_info[frd_uid] = frd_interact_info or {}
  if not self.record_lis then
    self.record_lis = {}
  end
  self.record_lis[frd_uid] = record_lis or {}
  if frd_interact_info and next(frd_interact_info) then
    self.fireList[frd_uid] = {
      score = frd_interact_info.score or 0,
      status = frd_interact_info.status or 0,
      last_complete_time = frd_interact_info.last_complete_time or 0
    }
  end
  self.reward_data_list = interact_reward_limit_data
  self.reward_  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_INTERACT_RSP, frd_uid)
end
function logic_interaction:on_fire_list(innerList)
  if not innerList or not next(innerList) then
    return
  end
  log(bWriteLog and "logic_interaction:on_fire_list")
  log_tree(bWriteLog and "[v_yunjxing] logic_interaction:on_fire_list:", innerList)
  self.end
function logic_interaction:on_fire_listAddMsg()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local dataList = {}
  local innerList = self.innerList
  if not innerList or not next(innerList) then
    return
  end
  for k, v in pairs(innerList) do
    self.fireList[k] = {
      status = v.status or 0,
      score = v.score or 0,
      last_complete_time = v.last_complete_time or 0,
      last_switch_season_id = v.last_switch_season_id or 0
    }
    if v.last_switch_season_id == DataMgr.season_id then
      local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.InteractiveFire) or {}
      if (not saveData[k] or not TimeUtil.IsSameDay(saveData[k], nowTime) and not TimeUtil.IsSameDay(v.last_complete_time or 0, nowTime)) and (v.score or 0) >= 7 then
        log(bWriteLog and "logic_interaction:on_fire_list v.score" .. tostring(v.score))
        log(bWriteLog and "logic_interaction:on_fire_list saveData[k]" .. tostring(saveData[k]))
        log(bWriteLog and "logic_interaction:on_fire_list v.last_complete_time" .. tostring(v.last_complete_time))
        log(bWriteLog and "logic_interaction:on_fire_list nowTime" .. tostring(nowTime))
        local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
        local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
        local relation = LogicFriend.GetRelation(k)
        local iconPath, iconName = self:GetIconInfo(relation, v.score or 0, "Bright")
        if iconPath and iconName then
          logic_chat_main.AddInteractiveMsg(k, true, false, LocUtil.LocalizeResFormat(73578), iconPath, iconName)
        end
      end
    end
    dataList[k] = nowTime
  end
  PlayerPrefsSystem.SaveTableToFile_N(dataList, PlayerPrefsSystem.ePlayerPrefsType.InteractiveFire)
end
function logic_interaction:on_interact_key_event_notify(frd_uid, change_type, value, para1, para2)
  log(bWriteLog and "logic_interaction:on_interact_key_event_notify")
  log(bWriteLog and "logic_interaction:on_interact_key_event_notify :" .. " myUid" .. tostring(DataMgr.roleData.uid) .. "frd_uid:" .. tostring(frd_uid) .. " change_type:" .. tostring(change_type) .. " value:" .. tostring(value) .. " para1:" .. tostring(para1) .. " para2:" .. tostring(para2))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if self.fireList[frd_uid] == nil then
    self.fireList[frd_uid] = {
      status = 0,
      score = 0,
      last_complete_time = 0
    }
  end
  self:send_get_interact_info_req(frd_uid)
  if change_type == 1 then
    self.fireList[frd_uid].status = value
    if self.fireList[frd_uid].status == 2 and 0 < value + para1 then
      local lastTime = self.fireList[frd_uid].last_complete_time or 0
      local TimeUtil = require("client.common.time_util")
      local nowTime = TimeUtil.GetServerTimeInSec()
      local interruptDay = 0
      local interruptList = CDataTable.GetTable("InteractionInterrupted")
      if not interruptList then
        return
      end
      for k, v in pairs(interruptList) do
        if v.InterruptMax * 86400 > nowTime - lastTime then
          interruptDay = interruptList[k].LightNeed
          break
        end
      end
      local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
      local iconPath, iconName = self:GetIconInfoByID(frd_uid)
      if iconPath and iconName then
        logic_chat_main.AddInteractiveMsg(frd_uid, true, true, LocUtil.LocalizeResFormat(73577, tostring(interruptDay)), iconPath, iconName)
      end
    end
  elseif change_type == 2 then
    self.fireList[frd_uid].score = value
    local configs = CDataTable.GetTable("ScoreIcon")
    local bLevelUp = false
    for k, v in pairs(configs) do
      if 1 < k and self.fireList[frd_uid].score - para1 < v.score and value >= v.score then
        bLevelUp = true
        break
      end
    end
    if bLevelUp then
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      local relation = LogicFriend.GetRelation(frd_uid)
      local sparkIcon, name = self:GetIconInfo(relation, value, "Bright")
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(frd_uid)
      if profile and name then
        self.showInteractionTipsFri = frd_uid
        self.showInteractionTipsText = LocUtil.LocalizeResFormat(73593, profile.nickName, LocUtil.GetLocalizeResStr(73596), name)
        self.showInteractionTipsTexture = sparkIcon
        ShowNotice(self.showInteractionTipsText, false, 5, 3)
      end
    end
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_INTERACT_UPDATE, frd_uid, value)
  elseif change_type == 3 then
    if para1 == 1 then
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      local relation = LogicFriend.GetRelation(frd_uid)
      local data = CDataTable.GetTableData("ScoreIcon", 2)
      local iconKey, nameKey = self:GetInteractionIconKey(relation, "Bright")
      local name = data[nameKey]
      local sparkIcon = data[iconKey]
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(frd_uid)
      if profile then
        self.showInteractionTipsFri = frd_uid
        self.showInteractionTipsText = LocUtil.LocalizeResFormat(73593, profile.nickName, LocUtil.GetLocalizeResStr(73595), name)
        self.showInteractionTipsTexture = sparkIcon
      end
    elseif not self.fireList[frd_uid].score or self.fireList[frd_uid].score < 2 then
      local TimeUtil = require("client.common.time_util")
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      local relation = LogicFriend.GetRelation(frd_uid)
      if not self.fireList[frd_uid].last_complete_time or not TimeUtil.IsSameDay(value, self.fireList[frd_uid].last_complete_time) then
        local iconPatch, iconName = self:GetIconInfo(relation, 3, "Bright")
        if iconName and iconPatch then
          local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
          logic_chat_main.AddInteractiveMsg(frd_uid, true, true, LocUtil.LocalizeResFormat(73576, tostring(3)), iconPatch, iconName)
        end
      end
      self.fireList[frd_uid].last_complete_time = value
    end
  elseif change_type == 4 then
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.InteractiveTips) or {}
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    local ShowTipsNum = 0
    local ShowTipsLastTime = 0
    if saveData and saveData[frd_uid] then
      log(bWriteLog and "logic_interaction change_type == 4 saveData[frd_uid].tipsNum" .. tostring(saveData[frd_uid].tipsNum))
      log(bWriteLog and "logic_interaction change_type == 4 saveData[frd_uid].tipsNum BossLoc" .. tostring(not TimeUtil.IsSameDay(nowTime, saveData[frd_uid].InteractiveTime)))
      ShowTipsNum = saveData[frd_uid].tipsNum
      ShowTipsLastTime = saveData[frd_uid].InteractiveTime or 0
      if not TimeUtil.IsSameDay(nowTime, ShowTipsLastTime) then
        ShowTipsNum = 0
      end
    end
    if ShowTipsNum < 3 then
      local InteractiveBehavior = CDataTable.GetTable("InteractiveBehavior")
      if InteractiveBehavior[value] then
        self.InteractiveValue = value
        local showTips = LocUtil.LocalizeResFormat(73579, tostring(InteractiveBehavior[value].Text), tostring(InteractiveBehavior[value].score))
        local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
        logic_chat_main.AddInteractiveMsg(frd_uid, true, true, showTips)
        local num = ShowTipsNum
        saveData[frd_uid] = {
          tipsNum = num + 1,
          InteractiveTime = nowTime
        }
        PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.InteractiveTips)
      end
    end
  end
end
function logic_interaction:send_get_interact_score_reward_req(reward_idx, frd_uid)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_get_interact_score_reward_req(reward_idx, frd_uid)
end
function logic_interaction:on_get_interact_score_reward_rsp(err_code, frd_uid, reward_idx, res_list)
  if err_code == 13070027 then
    ShowNotice(77165)
    return
  elseif err_code == 13070025 then
    ShowNotice(51413)
  elseif err_code ~= 0 then
    return
  end
  if not self.frd_interact_info[frd_uid] then
    log(bWriteLog and "logic_interaction:on_get_interact_score_reward_rsp\239\188\154Unexpected value frd_interact_info is nil")
    return
  end
  if not self.frd_interact_info[frd_uid].rewarded_bits then
    self.frd_interact_info[frd_uid].rewarded_bits = 0
  end
  local uConfig = CDataTable.GetTableData("InteractionPoints", reward_idx)
  if uConfig then
    self.frd_interact_info[frd_uid].rewarded_bits = self.frd_interact_info[frd_uid].rewarded_bits | 1 << reward_idx - 1
  end
  local reward_data = self:GetRewardData(frd_uid, reward_idx)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local filtered_res_list = {}
  for i, item_info in pairs(res_list) do
    if item_info.resid ~= 0 then
      filtered_res_list[i] = item_info
    end
  end
  if next(filtered_res_list) then
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(filtered_res_list)
  end
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_INTERACT_RECEIVE, frd_uid, reward_idx, reward_data)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_interaction = class(CModuleBase, nil, logic_interaction)
return Clogic_interaction