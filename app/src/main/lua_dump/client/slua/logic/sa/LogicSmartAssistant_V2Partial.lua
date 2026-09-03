local LogicSmartAssistant_V2Partial = {}
local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
local LogicSmartAssistantToolCardCfg = require("client.slua.logic.sa.toolcard.LogicSmartAssistantToolCardCfg")
local SAUtils = require("client.slua.logic.sa.SAUtils")
local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
function LogicSmartAssistant_V2Partial:DefineAndResetData()
  self.sd_minitv_user_info = nil
  self.sd_ban_flg = nil
  self.sd_ban_end_time = nil
  self.mergedList = nil
  self.notifyMap = {}
  self.notifyQueue = {}
  self.currentAction = nil
end
function LogicSmartAssistant_V2Partial:BuildCollectCardSkipSet(info)
  local collectCardPriorityKeys = {
    "collect_card_bottle",
    "collect_card_exchange",
    "collect_card_progress"
  }
  local skipSet = {}
  local found = false
  for _, priorityKey in ipairs(collectCardPriorityKeys) do
    local data = info[priorityKey]
    if data then
      if not data.item_list or #data.item_list == 0 then
        skipSet[priorityKey] = true
      elseif found then
        skipSet[priorityKey] = true
      else
        found = true
      end
    end
  end
  return skipSet
end
function LogicSmartAssistant_V2Partial:on_get_robot_assistant_reward_task_notice_rsp(info)
  log_tree("LogicSmartAssistant_V2Partial:on_get_robot_assistant_reward_task_notice_rsp info:%s", info)
  local collectCardSkipSet = self:BuildCollectCardSkipSet(info)
  local awardList = {}
  local taskList = {}
  local clientCfg = LogicSmartAssistantToolCardCfg.ToolCardCfgV2
  for k, v in pairs(info) do
    if collectCardSkipSet[k] then
      log_format(bWriteLog and "LogicSmartAssistant_V2Partial:on_get_robot_assistant_reward_task_notice_rsp skip collect_card duplicate, key = %s", k)
    else
      local module = require("client.slua.logic.sa.toolcard.v2." .. k)
      if module and module.CanShowToolCard and not module.CanShowToolCard() then
        log_format(bWriteLog and "LogicSmartAssistant_V2Partial:on_get_robot_assistant_reward_task_notice_rsp CanShowToolCard return false, key = %s", k)
      else
        if v.label_type == "reward" then
          table.insert(awardList, v)
        elseif v.label_type == "task" then
          table.insert(taskList, v)
        end
        local cfg = clientCfg[k]
        if cfg then
          v.        end
        v.clientKey = k
      end
    end
  end
  table.sort(awardList, function(a, b)
    return a.sort_weight > b.sort_weight
  end)
  table.sort(taskList, function(a, b)
    return a.sort_weight > b.sort_weight
  end)
  local mergedList = {
    self.oneclick_reward_data
  }
  for i = 1, #awardList do
    table.insert(mergedList, awardList[i])
  end
  for i = 1, #taskList do
    table.insert(mergedList, taskList[i])
  end
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local str = string.format("uid:%s,cards:%s", DataMgr.roleData.uid, "")
  for i = 1, #mergedList do
    str = str .. mergedList[i].clientKey .. ","
  end
  str = string.sub(str, 1, -2)
  BasicDataTLogReport:ReportDelay(TLogEventDefine.SmartAssistantV2SystemRecommendDisplay, 0, str)
  local maxCount = 4
  if maxCount > #mergedList then
    local keys = MiniTVConst.GAME_Encyclopedia_Desc
    local randIndex = math.random(1, #keys)
    while maxCount > #mergedList do
      table.insert(mergedList, {
        clientKey = "empty",
        desc = keys[randIndex % #keys + 1]
      })
      randIndex = randIndex + 1
    end
  else
    mergedList = {
      mergedList[1],
      mergedList[2],
      mergedList[3],
      mergedList[4]
    }
  end
  self.  printf("LogicSmartAssistant_V2Partial:on_get_robot_assistant_reward_task_notice_rsp len mergedList:%s", #mergedList)
end
function LogicSmartAssistant_V2Partial:on_notify_minitv_action(action_desc)
  local cfg = CDataTable.GetTableData("MiniTVEventCfg", action_desc.event_id)
  if not cfg then
    printf("LogicSmartAssistant_V2Partial:on_notify_minitv_action event_id not found: %d", action_desc.event_id)
    return
  end
  action_desc.priority = cfg.Priority
  self.notifyMap[action_desc.event_id] = action_desc
  self:updateQueue()
end
function LogicSmartAssistant_V2Partial:updateQueue()
  self.notifyQueue = {}
  for k, v in pairs(self.notifyMap) do
    table.insert(self.notifyQueue, v)
  end
  table.sort(self.notifyQueue, function(a, b)
    return a.priority > b.priority
  end)
  EventSystem:postEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_RECV_ACTION)
end
function LogicSmartAssistant_V2Partial:PopPriorityAction()
  if #self.notifyQueue > 0 then
    local action = table.remove(self.notifyQueue, 1)
    self.notifyMap[action.event_id] = nil
    self.currentAction = action
    return action
  end
  return nil
end
function LogicSmartAssistant_V2Partial:GetCurrentAction()
  return self.currentAction
end
function LogicSmartAssistant_V2Partial:OnWardrobeOpen()
  local suitItemID = SAUtils.GetCurrentSuitInfo()
  if suitItemID then
    self.currentSuitItemID = suitItemID
  end
end
function LogicSmartAssistant_V2Partial:OnWardrobeClose()
  local suitItemID, itemQuality, clothLevel = SAUtils.GetCurrentSuitInfo()
  printf("LogicSmartAssistant_V2Partial:OnWardrobeClose suitItemID:%s, itemQuality:%s, clothLevel:%s", suitItemID, itemQuality, clothLevel)
  if suitItemID then
    if suitItemID == 403000 or suitItemID == 1400129 then
      printf("LogicSmartAssistant_V2Partial:OnWardrobeClose default suit")
      return
    end
    if self.currentSuitItemID ~= suitItemID then
      local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
      SmartAssistantHandler.send_report_minitv_raw_event_req(MiniTVConst.RAW_EVENT_TYPE.SUIT_CHANGE, {cloth_type = clothLevel})
    end
  end
end
function LogicSmartAssistant_V2Partial:IsAIChatAvaliable()
  local logic_AIChat_Adult = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_AIChat_Adult)
  if not logic_AIChat_Adult:CheckAgeGate() then
    printf("LogicSmartAssistant_V2Partial:IsAIChatAvaliable close age")
    return false
  end
  return true
end
function LogicSmartAssistant_V2Partial:PromiseAIChatAvaliable()
  local Promise = require("common.Promise")
  local promise = Promise.new()
  local logic_AIChat_Adult = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_AIChat_Adult)
  logic_AIChat_Adult:CallAgegateSDKPromise():Then(function(isAdult)
    log(bWriteLog and "LogicSmartAssistant_V2Partial:PromiseAIChatAvaliable CallAgegateSDKPromise resolved, isAdult:" .. tostring(isAdult))
    if self:IsAIChatAvaliable() then
      promise:Resolve(true)
    else
      log(bWriteLog and "LogicSmartAssistant_V2Partial:PromiseAIChatAvaliable IsAIChatAvaliable returned false")
      promise:Reject(false)
    end
  end)
  return promise
end
function LogicSmartAssistant_V2Partial:HasAgreedProtocol()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eSmartAssistantV2
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
  return saveData.hasAgreed and true or false
end
return LogicSmartAssistant_V2Partial