local logic_ugc_new_map = {gallery_new_mod_abtest = nil}
function logic_ugc_new_map:DefineAndResetData()
  self.IncubationList = {}
  self.ValidationList = {}
  self.ValidationModIDList = {}
  self.ValidationSortModIDList = {}
  self.report = {}
  self.version = 0
  self.ValidationModIDMap = {}
end
function logic_ugc_new_map:OnLogOut()
  log(bWriteLog and "logic_ugc_new_map:OnLogOut")
  self:ClearCacheData()
end
function logic_ugc_new_map:ClearCacheData()
  self.IncubationList = {}
  self.ValidationList = {}
  self.ValidationModIDList = {}
  self.ValidationSortModIDList = {}
  self.ValidationRspStamp = nil
  self.ValidationModIDMap = {}
end
function logic_ugc_new_map:send_ugc_gallery_new_mod_incubation_req()
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_gallery_new_mod_incubation_req()
end
function logic_ugc_new_map:on_ugc_gallery_new_mod_incubation_rsp(mod_list)
  self.IncubationList = mod_list
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWMAP_INCUBATION_UPDATE)
end
function logic_ugc_new_map:send_ugc_gallery_new_mod_validation_req()
  if self:CheckValidationDataValid() then
    log(bWriteLog and "logic_ugc_new_map:send_ugc_gallery_new_mod_validation_req dataValid no need to req")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWMAP_VALIDATION_UPDATE)
    return
  end
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_gallery_new_mod_validation_req()
end
function logic_ugc_new_map:on_ugc_gallery_new_mod_validation_rsp(mod_list_Data)
  self.ValidationList = mod_list_Data
  self.ValidationModIDList = {}
  self.ValidationSortModIDList = {}
  self.ValidationModIDMap = {}
  local ModIdList = mod_list_Data.mod_list
  log_tree("logic_ugc_new_map:on_ugc_gallery_new_mod_validation_rsp ModIdList", ModIdList)
  if ModIdList and next(ModIdList) then
    for mod_id, v in pairs(ModIdList) do
      table.insert(self.ValidationSortModIDList, mod_id)
      self.ValidationModIDMap[mod_id] = true
    end
    log_tree("logic_ugc_new_map:on_ugc_gallery_new_mod_validation_rsp self.ValidationModIDMap", self.ValidationModIDMap)
    if #self.ValidationSortModIDList > 1 then
      local modId = self.ValidationSortModIDList[1]
      if type(ModIdList[modId]) == "number" then
        table.sort(self.ValidationSortModIDList, function(a, b)
          local aRankValue = ModIdList[a]
          local bRankValue = ModIdList[b]
          if aRankValue == bRankValue then
            return a < b
          end
          return aRankValue < bRankValue
        end)
      end
    end
    self.ValidationModIDList = self.ValidationSortModIDList
  end
  self.version = mod_list_Data.version or 0
  self.duration = mod_list_Data.duration or 120
  local TimeUtil = require("client.common.time_util")
  self.versionReceiveTime = TimeUtil.GetServerTimeInSec()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWMAP_VALIDATION_UPDATE)
end
function logic_ugc_new_map:ReqModInfoBatch(type, mod_list)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  log(bWriteLog and "logic_ugc_new_map:ReqModInfoBatch type=" .. tostring(type))
  if type == LogicUGC.C_ModListTypes.new_mod_incubation then
    mod_list = self.IncubationList
  elseif type == LogicUGC.C_ModListTypes.new_mod_validation then
    mod_list = self.ValidationModIDList
  end
  local ModInfoList, ReqList = LogicUGC:BatchGetModInfo(mod_list, type, nil, {bSplit = true})
  if ModInfoList and next(ModInfoList) then
    self:OnModInfoBatchRsp(ModInfoList, type)
  elseif not ReqList or not next(ReqList) then
    self:OnModInfoBatchRsp({}, type)
  end
end
function logic_ugc_new_map:OnModInfoBatchRsp(MetaList, ListType, Param, FilterOfflineModList)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.new_mod_incubation) and not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.new_mod_validation) then
    return
  end
  log(bWriteLog and "logic_ugc_new_map:OnModInfoBatchRsp ListType=" .. tostring(ListType))
  local bIsDirty = false
  if next(MetaList) then
    bIsDirty = true
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWMAP_MODINFO_LIST_RSP, ListType, bIsDirty, MetaList, Param, FilterOfflineModList)
end
function logic_ugc_new_map:CheckValidationDataValid()
  if not self.ValidationModIDList or not next(self.ValidationModIDList) then
    log(bWriteLog and "logic_ugc_new_map:CheckValidationDataValid ValidationList is nil")
    return false
  end
  if not self.duration then
    log(bWriteLog and "logic_ugc_new_map:CheckValidationDataValid ValidationRspStamp is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  return curTime <= self.versionReceiveTime + self.duration
end
function logic_ugc_new_map:Report()
  if not next(self.report) then
    log(bWriteLog and "logic_ugc_new_map:Report self.report is nil")
    return
  end
  if self.version == 0 then
    log(bWriteLog and "logic_ugc_new_map:Report self.version is 0")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if curTime <= self.versionReceiveTime + self.duration then
    log_tree("logic_ugc_new_map:Report self.report", self.report)
    local UGCHandler = require("client.network.Protocol.UGCHandler")
    UGCHandler.send_ugc_report_rec_mod_view_req(self.version, self.report)
    self:ClearReport()
  else
    local oldVersion = self.version
    local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
    UGCSearchHandler.send_ugc_gallery_new_mod_validation_req():Then(function(err_code, mod_list)
      log(bWriteLog and "logic_ugc_new_map:Report old:" .. oldVersion .. " new:" .. self.version)
      log_tree("logic_ugc_new_map:Report self.report", self.report)
      local UGCHandler = require("client.network.Protocol.UGCHandler")
      UGCHandler.send_ugc_report_rec_mod_view_req(self.version, self.report)
      self:ClearReport()
    end)
  end
end
function logic_ugc_new_map:ClearReport()
  self.report = {}
end
function logic_ugc_new_map:AddReportDetail(mod)
  self:AddReport(mod, "detail")
end
function logic_ugc_new_map:AddReportSelect(mod)
  self:AddReport(mod, "select")
end
function logic_ugc_new_map:AddReportCollect(mod)
  self:AddReport(mod, "collect")
end
function logic_ugc_new_map:AddReportExpose(mod)
  self:AddReport(mod, "expose")
end
function logic_ugc_new_map:AddReport(mod, key)
  if not self.report then
    self.report = {}
  end
  if not mod then
    return
  end
  if not self.report[mod] then
    self.report[mod] = self:FormatReportItem()
  end
  self.report[mod][key] = 1
end
function logic_ugc_new_map:FormatReportItem()
  return {
    detail = 0,
    select = 0,
    match = 0,
    collect = 0,
    expose = 0
  }
end
function logic_ugc_new_map:SetNewMapABTest(abTest)
  log(bWriteLog and "logic_ugc_new_map:SetNewMapABTest abTest = " .. tostring(abTest))
  self.gallery_new_mod_abtest = abTest
end
function logic_ugc_new_map:CheckReportMAB(mod_id)
  if not self.ValidationModIDMap or not next(self.ValidationModIDMap) then
    return false
  end
  return self.ValidationModIDMap[mod_id]
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_new_map = class(CModuleBase, nil, logic_ugc_new_map)
return Clogic_ugc_new_map