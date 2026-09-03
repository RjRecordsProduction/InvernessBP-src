local PandoraOneclickRewardComp = {}
local protocolLayer = require("client.slua.logic.Pandora.pandora_protocol_layer")
local Promise = require("common.Promise")
local TimeUtil = require("client.common.time_util")
local pandoraUtils = require("client.slua.logic.Pandora.pandora_utils")
local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local SAUtils = require("client.slua.logic.sa.SAUtils")
local timeout = 5
function PandoraOneclickRewardComp:Init(Owner)
  self.  self.previewResult = {}
  self.rewardResult = {}
end
function PandoraOneclickRewardComp:ClearRewardData()
  self.previewResult = {}
  self.rewardResult = {}
end
function PandoraOneclickRewardComp:OnActivityListChange(changeList)
  if not changeList or not changeList.idList then
    printf("PandoraOneclickRewardComp:OnActivityListChange changeList not found")
    return
  end
  local idList = changeList.idList
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  for k, v in pairs(pandoraSystem.pandora2Id) do
    local activityId = tonumber(v)
    if idList[activityId] then
      local activityData = ActivityNewSystem.GetActivityByID(activityId)
      if activityData then
        printf("PandoraOneclickRewardComp:OnActivityListChange activityId:%s", activityId)
        PandoraOneclickRewardComp:OnActivityConfigeChange(activityData, k)
      end
    end
  end
end
function PandoraOneclickRewardComp:OnActivityConfigeChange(activityData, explicitActid)
  explicitActid = explicitActid or SAUtils.ActivityId2PandoraId(activityData.ID)
  if not explicitActid then
    printf("PandoraOneclickRewardComp:OnActivityConfigeChange not found pandoraId:%s", activityData.ID)
    return
  end
  local begintime = activityData.StartTime
  local endtime = activityData.EndTime
  local sendData = {
    type = "RtnActConfig",
    content = "",
    actid = explicitActid,
    begintime = begintime,
      }
  protocolLayer.SendCmd(sendData)
end
function PandoraOneclickRewardComp:handle_GetActConfig(data)
  local actid = data.actid
  local activityId = SAUtils.PandoraId2ActivityId(tonumber(actid))
  local activityData = ActivityNewSystem.GetActivityByID(activityId)
  if not activityData then
    printf(":handle_GetActConfig activityData not found actid:%s, activityId:%s", actid, activityId)
    return
  end
  log_tree(":handle_GetActConfig activityData:", activityData)
  printf("PandoraOneclickRewardComp:handle_GetActConfig actid:%s, activityId:%s", actid, activityId)
  self:OnActivityConfigeChange(activityData, actid)
end
function PandoraOneclickRewardComp:handle_GiftStatus(data)
  local actid = data.actid
  local gifts = data.gifts
  local now = slua.getMiliseconds() / 1000
  printf("PandoraOneclickRewardComp:handle_GiftStatus actid:%s, flag:%s, now:%s", actid, data.content, now)
  log_tree("PandoraOneclickRewardComp:handle_GiftStatus data:", data)
  self.stopTime_RewardPreviewReq = now + timeout
  if data.content ~= "1" then
    return
  end
  local tbl = {}
  local rewardlist = pandoraUtils.SplitCommonItemGetData(gifts)
  for _, v in pairs(rewardlist) do
    if nil ~= v then
      table.insert(tbl, v)
    end
  end
  self.previewResult[actid] = tbl
  self.Owner:AppendPandoraPreviewRewardList()
  EventSystem:postEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_SMARTASSISTANT_PANDORA_PREVIEW_RECEIVE)
end
function PandoraOneclickRewardComp:handle_StartGetGift(data)
  local actid = data.actid
  local now = slua.getMiliseconds() / 1000
  printf("PandoraOneclickRewardComp:handle_StartGetGift actid:%s, now:%s", actid, now)
  log_tree("PandoraOneclickRewardComp:handle_StartGetGift data:", data)
  self.bReceivedAnyStartGetGift = true
  self.rewardResult[actid] = {pending = true}
end
function PandoraOneclickRewardComp:handle_GetGiftRes(data)
  local actid = data.actid
  local result = data.content
  local code = data.code
  printf("PandoraOneclickRewardComp:handle_GetGiftRes actid:%s, code:%s, result:%s", actid, code, result)
  log_tree("PandoraOneclickRewardComp:handle_GetGiftRes data:", data)
  self.rewardResult[actid].pending = false
  local tbl = {}
  if code == "0" or code == "409" then
    local rewardlist = pandoraUtils.SplitCommonItemGetData(data.content)
    for _, v in pairs(rewardlist) do
      if nil ~= v then
        table.insert(tbl, v)
      end
    end
  end
  self.rewardResult[actid].result = tbl
  for k, v in pairs(self.rewardResult) do
    if v.pending then
      return
    end
  end
  if self.promsie_GetGift then
    self.promsie_GetGift:Resolve(self.rewardResult)
    self.promsie_GetGift = nil
  end
end
function PandoraOneclickRewardComp:Request_RewardPreviewReq()
  if IsEditor then
    return
  end
  if self.promsie_RewardPreviewReq then
    local now = slua.getMiliseconds() / 1000
    printf("PandoraOneclickRewardComp:Request_RewardPreviewReq in progress. stopTime_RewardPreviewReq:%s, now:%s", self.stopTime_RewardPreviewReq, now)
    if now > self.stopTime_RewardPreviewReq then
      printf("PandoraOneclickRewardComp:Request_RewardPreviewReq remove timer  11. now:%s", now)
      self.Owner:RemoveTimer(self.timer_RewardPreviewReq)
      self.timer_RewardPreviewReq = nil
      self.promsie_RewardPreviewReq:Resolve(self.previewResult)
      self.promsie_RewardPreviewReq = nil
    else
      return
    end
  end
  local sendData = {
    type = "RewardPreviewReq",
    content = ""
  }
  protocolLayer.SendCmd(sendData)
  self.promsie_RewardPreviewReq = Promise.new()
  self.previewResult = {}
  local now = slua.getMiliseconds() / 1000
  self.stopTime_RewardPreviewReq = now + timeout
  printf("PandoraOneclickRewardComp:Request_RewardPreviewReq now:%s", now)
  self.timer_RewardPreviewReq = self.Owner:AddTimerLoop(0, function()
    local now = slua.getMiliseconds() / 1000
    printf("PandoraOneclickRewardComp:Request_RewardPreviewReq timer now:%s", now)
    if now > self.stopTime_RewardPreviewReq then
      printf("PandoraOneclickRewardComp:Request_RewardPreviewReq remove timer  22. now:%s", now)
      self.Owner:RemoveTimer(self.timer_RewardPreviewReq)
      self.timer_RewardPreviewReq = nil
      self.promsie_RewardPreviewReq:Resolve(self.previewResult)
      self.promsie_RewardPreviewReq = nil
    end
  end, TIMER_INFINITE, 0.3)
  return self.promsie_RewardPreviewReq
end
function PandoraOneclickRewardComp:Request_GetGift()
  if IsEditor then
    return
  end
  if self.promsie_GetGift then
    printf("PandoraOneclickRewardComp:Request_GetGift in progress")
    return
  end
  local sendData = {type = "GetGift", content = ""}
  protocolLayer.SendCmd(sendData)
  self.rewardResult = {}
  self.bReceivedAnyStartGetGift = false
  self.promsie_GetGift = Promise.new()
  local now = slua.getMiliseconds() / 1000
  printf("PandoraOneclickRewardComp:Request_GetGift now:%s", now)
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.3, function()
    printf("PandoraOneclickRewardComp:Request_GetGift reach 11. bReceivedAnyStartGetGift:%s, promsie_GetGift:%s", self.bReceivedAnyStartGetGift, self.promsie_GetGift)
    if self.bReceivedAnyStartGetGift == false and self.promsie_GetGift then
      printf("PandoraOneclickRewardComp:Request_GetGift timeout 11")
      self.promsie_GetGift:Resolve(self.rewardResult, "timeout")
      self.promsie_GetGift = nil
    end
  end)
  time_ticker.AddTimerOnce(5, function()
    printf("PandoraOneclickRewardComp:Request_GetGift reach 22. promsie_GetGift:%s", self.promsie_GetGift)
    if self.promsie_GetGift then
      printf("PandoraOneclickRewardComp:Request_GetGift timeout 22")
      self.promsie_GetGift:Resolve(self.rewardResult, "timeout")
      self.promsie_GetGift = nil
    end
  end)
  return self.promsie_GetGift
end
return PandoraOneclickRewardComp