local UGCNewTLogReport = {
  ExposeList = {},
  ExposeIDMap = {},
  ExposeReqMax = 90,
  SendReqTime = nil,
  LoopReqTime = 3,
  TempExposedMap = {}
}
UGCNewTLogReport.TabStr = {
  mod_collection_id = "mod_collection_id=",
  filtertag = "filtertag=",
  subfiltertag = "subfiltertag=",
  theme_id = "theme_id=",
  sub_tab_id = "sub_tab_id="
}
UGCNewTLogReport.StrValue = {
  cornerplay = "&cornerplay=",
  Carousel = "Carousel=",
  detailTabId = "detailTabId=",
  bPromotion = "bPromotion=",
  HotRankType = "HotRankType=",
  DebugClosureID = "DebugClosureID=",
  DownloadType = "DownloadType=",
  DownloadState = "DownloadState=",
  TraceId = "TraceId=",
  UgcHall = "UgcHall=",
  DownloadResSize = "DownloadResSize="
}
local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
function UGCNewTLogReport:OpenReqTimer()
  if self.SendReqTime then
    return
  end
  self.SendReqTime = self:AddTimerLoop(self.LoopReqTime, function()
    if next(self.ExposeList) then
      self:SendExposeReq()
    end
  end, TIMER_INFINITE, self.LoopReqTime)
end
function UGCNewTLogReport:EndReqTimer()
  if self.SendReqTime then
    self:RemoveTimer(self.SendReqTime)
    self.SendReqTime = nil
  end
end
function UGCNewTLogReport:OnLogOut()
  self:EndReqTimer()
end
function UGCNewTLogReport:OnPreSwitchGameStatus()
  self:SendExposeReq()
  self:ClearExposedCache()
end
function UGCNewTLogReport:SendExposeReq()
  if #self.ExposeList == 0 then
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_report_uni_mod_expose_req(self.ExposeList)
  for _, v in ipairs(self.ExposeList) do
    self.TempExposedMap[v.mod_id] = v.request_id
    log(bWriteLog and "UGCNewTLogReport:SendExposeReq modid = " .. v.mod_id)
  end
  self.ExposeList = {}
  self:EndReqTimer()
end
function UGCNewTLogReport:ClearExposedCache()
  self.TempExposedMap = {}
end
function UGCNewTLogReport:SendInteractionReq(expose, interactive_type)
  if not expose or not interactive_type then
    log(bWriteLog and "UGCNewTLogReport:SendInteractionReq fail")
    return
  end
  local expose_id = expose.expose_id or 0
  if self.ExposeIDMap[expose.mod_id] and self.TempExposedMap[expose.mod_id] and self.TempExposedMap[expose.mod_id] == expose.request_id then
    expose_id = self.ExposeIDMap[expose.mod_id]
  else
    self.ExposeIDMap[expose.mod_id] = expose_id
    table.insert(self.ExposeList, expose)
  end
  if interactive_type == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.START_GAME then
    self.ExposeIDMap = {}
  end
  log(bWriteLog and "UGCNewTLogReport:SendInteractionReq =" .. expose.mod_id .. "," .. expose.request_id .. "," .. expose_id .. "," .. interactive_type)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_report_uni_mod_interactive_req(expose.mod_id, expose.request_id, expose_id, interactive_type, nil, expose.str_value)
end
function UGCNewTLogReport:TLogReport(buttontype, expose, interactivetype)
  if not (expose and expose.mod_id and expose.request_id) or expose.request_id == 0 then
    log(bWriteLog and "UGCNewTLogReport:UGCNewTLogReport expose or mod_id  is nil")
    return
  end
  local TimeUtil = require("client.common.time_util")
  expose.page = buttontype
  expose.expose_id = math.floor(TimeUtil.GetMicroseconds()) * 1000 + (expose.position or 1)
  if interactivetype ~= UGCMacros.ENU_UGC_TLOG_REACH_TYPE.SHOW_MOD then
    self:SendInteractionReq(expose, interactivetype)
    self:OpenReqTimer()
  else
    local ExposeModID = expose.mod_id
    local Temp = {}
    for _, v in ipairs(self.ExposeList) do
      Temp[v.mod_id] = true
      if v.mod_id == ExposeModID and v.request_id == expose.request_id then
        log(bWriteLog and string.format("UGCNewTLogReport:UGCNewTLogReport,all_the_same: %s == %s, %s == %s", tostring(v.mod_id), tostring(ExposeModID), tostring(v.request_id), tostring(expose.request_id)))
        return
      end
    end
    if self.TempExposedMap[ExposeModID] and self.TempExposedMap[ExposeModID] == expose.request_id then
      log(bWriteLog and "UGCNewTLogReport:UGCNewTLogReport, is exposed, id = " .. tostring(ExposeModID))
      return
    end
    if Temp[ExposeModID] then
      log(bWriteLog and "UGCNewTLogReport:UGCNewTLogReport,  Modid = " .. tostring(ExposeModID))
    end
    table.insert(self.ExposeList, expose)
    self.ExposeIDMap[ExposeModID] = expose.expose_id
    if #self.ExposeList >= self.ExposeReqMax then
      self:SendExposeReq()
    end
  end
  self:OpenReqTimer()
end
local class = require("class")
local CModuleBase = require("client.slua.data.BasicData.BasicDataTLogReport")
local CBasicDataTLogReport = class(CModuleBase, nil, UGCNewTLogReport)
return CBasicDataTLogReport