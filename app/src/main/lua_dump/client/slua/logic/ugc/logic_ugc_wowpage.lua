local logic_ugc_wowpage = {}
local ReqType = {
  [1] = {
    SendString = "send_ugc_gallery_hot_theme_req",
    SendTime = 3
  },
  [2] = {
    SendString = "send_ugc_mixed_banner_req",
    SendTime = 3
  },
  [3] = {
    SendString = "send_ugc_promotion_game_result_req",
    SendTime = 0
  },
  [4] = {
    SendString = "send_ugc_hot_theme_ext_req",
    SendTime = 3
  }
}
function logic_ugc_wowpage:DefineAndResetData()
  self.ReqList = nil
  self.TabInfo = {}
  self.MatchStatReqList = {}
  self.ReqSendTimeList = {}
  self.ClearTimer = nil
  self.ReqModInfoTabType = nil
  self.pendingBatchRequests = {}
  self.BatchOutTime = 5
  self.bIsRefreshTab = false
end
function logic_ugc_wowpage:OnInitialize()
end
function logic_ugc_wowpage:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_BATCH, self.OnModInfoBatchRsp, self)
end
function logic_ugc_wowpage:OnLogin(bReLogin)
  log("logic_ugc_wowpage:OnLogin")
  self:Clear()
end
function logic_ugc_wowpage:OnLogOut()
  self:Clear()
end
function logic_ugc_wowpage:OnPreSwitchGameStatus(preState, nextState)
  self:Clear()
end
function logic_ugc_wowpage:OnPostSwitchGameStatus(preState, nextState)
end
function logic_ugc_wowpage:GetTabInformation(bForce)
  if not bForce and self:CheckTabInfomation() then
    return
  end
  local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  local ReqIndexList = self.ReqList or {}
  if LogicUGCHall:CheckIsOpen() then
    ReqIndexList = self.NewReqList or {2, 1}
  end
  local PendingReqList = {}
  for k, Index in pairs(ReqIndexList) do
    table.insert(PendingReqList, ReqType[Index])
  end
  table.insert(self.MatchStatReqList, PendingReqList)
  self:MatchSendReq()
end
function logic_ugc_wowpage:MatchSendReq()
  if not self.MatchStatReqList or not next(self.MatchStatReqList) then
    return
  end
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  local PendingReqList = self.MatchStatReqList[1]
  for k, Req in pairs(PendingReqList) do
    local ReqString = Req.SendString
    if UGCSearchHandler[ReqString] and not self:CheckSendReqTime(ReqString, Req.SendTime) then
      UGCSearchHandler[ReqString]()
    end
  end
  table.remove(self.MatchStatReqList, 1)
end
function logic_ugc_wowpage:CheckSendReqTime(ReqString, SendTime)
  if not self.ReqSendTimeList[ReqString] then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local afterSendTime = self.ReqSendTimeList[ReqString]
  local nowTime = TimeUtil.GetServerTimeInSec()
  local TimeDiff = nowTime - afterSendTime
  local condition = SendTime < TimeDiff
  if condition then
    return false
  end
  self.ReqSendTimeList[ReqString] = nowTime + TimeDiff
  self:AddTimerOnce(TimeDiff, function()
    local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
    if UGCSearchHandler[ReqString] then
      UGCSearchHandler[ReqString]()
    end
  end)
  return true
end
function logic_ugc_wowpage:CheckTabInfomation()
  if not (self.TabInfo and next(self.TabInfo)) or not self:CheckSelfTabInfo() then
    log(bWriteLog and "logic_ugc_wowpage:CheckTabInfomation TabInfo is nil")
    return false
  end
  self:GetModInfo()
  return true
end
function logic_ugc_wowpage:Clear()
  self.TabInfo = {}
  self.MatchStatReqList = {}
  self.ReqSendTimeList = {}
end
function logic_ugc_wowpage:CheckAllBackToEvent()
  if self.bIsRefreshTab then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REFRESH_TABINFO)
  end
end
function logic_ugc_wowpage:SetbIsRefreshTab(bool)
  self.bIsRefreshTab = bool
end
function logic_ugc_wowpage:CheckSelfTabInfo()
  return false
end
function logic_ugc_wowpage:GetModInfoReq(ModIDList, ModListType)
  if not ModIDList or not ModListType then
    log(bWriteLog and "logic_ugc_wowpage:GetModInfoReq ModIDList or ModListType is nil")
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local CacheModInfoList, ReqList, NotReqList, BanList = LogicUGC:BatchGetModInfo(ModIDList, ModListType, nil, {bGetPlayReq = true, bNotPostEvent = true})
  local table_util = require("common.table_util")
  local CacheModInfoListCount = table_util.CountTable(CacheModInfoList)
  if (not ReqList or not next(ReqList)) and 0 < CacheModInfoListCount then
    self:TabAllModInfoRsp(ModListType, true)
  else
    local ReqListCount = table_util.CountTable(ReqList)
    if 0 < ReqListCount then
      self.pendingBatchRequests[ModListType] = math.ceil(ReqListCount / 20)
      self:AddTimerOnce(self.BatchOutTime, function()
        if self.pendingBatchRequests and self.pendingBatchRequests[ModListType] then
          log(bWriteLog and "logic_ugc_wowpage:GetModInfoReq time out  ModListType:" .. ModListType)
          self.pendingBatchRequests[ModListType] = nil
          self:TabAllModInfoRsp(ModListType)
        end
      end)
    end
  end
  return CacheModInfoList, ReqList
end
function logic_ugc_wowpage:OnModInfoBatchRsp(_, _, ReqListType, bIsDirty, MetaList, ClientParam, filter_offline_mod_list)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if ReqListType and self.pendingBatchRequests[ReqListType] then
    self.pendingBatchRequests[ReqListType] = self.pendingBatchRequests[ReqListType] - 1
    if self.pendingBatchRequests[ReqListType] <= 0 then
      self.pendingBatchRequests[ReqListType] = nil
      self:TabAllModInfoRsp(ReqListType)
    end
  end
end
function logic_ugc_wowpage:GetModInfo()
end
function logic_ugc_wowpage:TabAllModInfoRsp(ReqListType, bDontRsp)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_wowpage = class(CModuleBase, nil, logic_ugc_wowpage)
return Clogic_ugc_wowpage