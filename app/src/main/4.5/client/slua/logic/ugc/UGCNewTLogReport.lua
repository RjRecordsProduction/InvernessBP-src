local UGCNewTLogReport = {
  ExposeList = {},
  ExposeIDMap = {},
  ExposeReqMax = 90,
  SendReqTimer = nil,
  LoopReqTime = 5,
  TempExposedMap = {}
}
UGCNewTLogReport.C_TabStr = {
  mod_collection_id = "mod_collection_id=",
  filtertag = "filtertag=",
  subfiltertag = "subfiltertag=",
  theme_id = "theme_id=",
  sub_tab_id = "sub_tab_id="
}
UGCNewTLogReport.C_StrValue = {
  CornerPlay = "cornerplay=",
  CornerPlayNum = "CornerPlayNum=",
  Carousel = "Carousel=",
  detailTabId = "detailTabId=",
  bPromotion = "bPromotion=",
  HotRankType = "HotRankType=",
  DebugClosureID = "DebugClosureID=",
  DownloadType = "DownloadType=",
  DownloadState = "DownloadState=",
  TraceId = "TraceId=",
  UgcHall = "UgcHall=",
  UgcHallBannerUserClick = "UgcHallBannerUserClick=",
  DownloadResSize = "DownloadResSize=",
  action = "action=",
  PlayTime = "PlayTime=",
  Leader = "Leader=",
  IsFreeInOut = "IsFreeInOut=",
  MultiModList = "MultiModList="
}
function UGCNewTLogReport:OnDestroy()
  self:SendExposeReq()
  self:ClearTLogData()
  UGCNewTLogReport.__super.OnDestroy(self)
end
function UGCNewTLogReport:OnLogOut()
  self:SendExposeReq()
  self:ClearTLogData()
  UGCNewTLogReport.__super.OnLogOut(self)
end
function UGCNewTLogReport:OnPreSwitchGameStatus(preState, nextState)
  UGCNewTLogReport.__super.OnPreSwitchGameStatus(self, preState, nextState)
  self:SendExposeReq()
  self:ClearTLogData()
end
function UGCNewTLogReport:ExposeTLog(Expose)
  if not (Expose and Expose.mod_id and Expose.request_id) or Expose.request_id == 0 then
    log(bWriteLog and "UGCNewTLogReport:ExposeTLog key params is nil")
    return
  end
  local ExposeModID = Expose.mod_id
  local RequestID = Expose.request_id
  for _, v in ipairs(self.ExposeList) do
    if v.mod_id == ExposeModID and v.request_id == RequestID then
      log(bWriteLog and string.format("UGCNewTLogReport:ExposeTLog,all_the_same: %s == %s, %s == %s", tostring(v.mod_id), tostring(ExposeModID), tostring(v.request_id), tostring(RequestID)))
      return
    end
  end
  if self.TempExposedMap[ExposeModID] and self.TempExposedMap[ExposeModID] == RequestID then
    log(bWriteLog and "UGCNewTLogReport:ExposeTLog, is exposed, id = " .. tostring(ExposeModID))
    return
  end
  table.insert(self.ExposeList, Expose)
  if not self.ExposeIDMap[ExposeModID] then
    self.ExposeIDMap[ExposeModID] = {}
  end
  table.insert(self.ExposeIDMap[ExposeModID], 1, Expose)
  if #self.ExposeList >= self.ExposeReqMax then
    self:SendExposeReq()
  end
  self:OpenReqTimer()
end
function UGCNewTLogReport:InteractionTLog(Interaction, InteractiveType, BattleID)
  if not (Interaction and Interaction.mod_id and Interaction.request_id) or Interaction.request_id == 0 then
    log(bWriteLog and "UGCNewTLogReport:InteractionTLog key params is nil")
    return
  end
  self:SendInteractionReq(Interaction, InteractiveType, BattleID)
end
function UGCNewTLogReport:ClearExposedCache()
  self.TempExposedMap = {}
end
local C_FormatStr1 = "%s%s%s"
local C_FormatStr2 = "%s&%s%s"
function UGCNewTLogReport:GetParamsTabStr(Params)
  if not Params or not next(Params) then
    return ""
  end
  local ParamsStr = ""
  local FormatStr
  for k, v in pairs(self.C_TabStr) do
    local ParamValue = Params[k]
    if ParamValue then
      FormatStr = ParamsStr ~= "" and C_FormatStr2 or C_FormatStr1
      ParamsStr = string.format(FormatStr, ParamsStr, v, tostring(ParamValue))
    end
  end
  if not Params.mod_collection_id then
    local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
    local ModCollectionID = LogicUGCCollectionList:GetOpenCollection()
    if ModCollectionID then
      FormatStr = ParamsStr ~= "" and C_FormatStr2 or C_FormatStr1
      ParamsStr = string.format(FormatStr, ParamsStr, self.C_TabStr.mod_collection_id, tostring(ModCollectionID))
    end
  end
  return ParamsStr
end
function UGCNewTLogReport:GetParamsStrValue(Params)
  local ParamsStr = ""
  local FormatStr
  if Params and next(Params) then
    for k, v in pairs(self.C_StrValue) do
      local ParamValue = Params[k]
      if ParamValue then
        FormatStr = ParamsStr ~= "" and C_FormatStr2 or C_FormatStr1
        if k == "MultiModList" then
          local MultiModListStr = ""
          for Index, ModID in ipairs(ParamValue) do
            if Index == 1 then
              MultiModListStr = tostring(ModID)
            else
              MultiModListStr = MultiModListStr .. "," .. tostring(ModID)
            end
          end
          ParamsStr = string.format(FormatStr, ParamsStr, v, MultiModListStr)
        else
          ParamsStr = string.format(FormatStr, ParamsStr, v, tostring(ParamValue))
        end
      end
    end
  end
  if GameStatus.IsInLobbyOrSpecialFighting() then
    local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
    if logic_ugc_hall:CheckIsOpen() then
      local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
      local curPage = lobbyMainLogic.curPage
      if curPage == ENUM_LobbyPageType.Right then
        FormatStr = ParamsStr ~= "" and C_FormatStr2 or C_FormatStr1
        ParamsStr = string.format(FormatStr, ParamsStr, self.C_StrValue.UgcHall, "1")
      end
    end
  end
  return ParamsStr
end
function UGCNewTLogReport:OpenReqTimer()
  if self.SendReqTimer then
    return
  end
  self.SendReqTimer = self:AddTimerLoop(self.LoopReqTime, function()
    self:SendExposeReq()
  end, TIMER_INFINITE, self.LoopReqTime)
end
function UGCNewTLogReport:ClearTLogData()
  if self.SendReqTimer then
    self:RemoveTimer(self.SendReqTimer)
    self.SendReqTimer = nil
  end
  self.TempExposedMap = {}
end
function UGCNewTLogReport:SendExposeReq()
  if #self.ExposeList == 0 then
    return
  end
  local ExposeList = {}
  for _, Expose in ipairs(self.ExposeList) do
    local FixedExpose = {
      mod_id = Expose.mod_id,
      request_id = Expose.request_id,
      expose_id = Expose.expose_id,
      page = Expose.page,
      sub_page = Expose.tab_id or 0,
      tab = self:GetParamsTabStr(Expose),
      position = Expose.position or 1,
      value = Expose.SearchValue,
      str_value = self:GetParamsStrValue(Expose),
      row = Expose.row or 1,
      col = Expose.col or 1,
      recall_source = Expose.recall_source or ""
    }
    table.insert(ExposeList, FixedExpose)
    self.TempExposedMap[Expose.mod_id] = Expose.request_id
    if bWriteLog then
      local LogStr = ""
      for k, v in pairs(FixedExpose) do
        LogStr = LogStr .. "|" .. string.format("%s=%s", k, tostring(v))
      end
      log("UGCNewTLogReport:SendExposeReq = " .. LogStr)
    end
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_report_uni_mod_expose_req(ExposeList)
  self.ExposeList = {}
end
function UGCNewTLogReport:SendInteractionReq(Interaction, InteractiveType, BattleID)
  local StrValue = self:GetParamsStrValue(Interaction)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_report_uni_mod_interactive_req(Interaction.mod_id, Interaction.request_id, Interaction.expose_id, InteractiveType, nil, StrValue, BattleID)
  if bWriteLog then
    local LogStr = string.format("UGCNewTLogReport:SendInteractionReq = mod_id=%s|request_id=%s|expose_id=%s|interactive_type=%s|str_value=%s|battle_id=%s", tostring(Interaction.mod_id), tostring(Interaction.request_id), tostring(Interaction.expose_id), tostring(InteractiveType), tostring(StrValue), tostring(BattleID))
    log(LogStr)
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if InteractiveType == UGCMacros.ENU_UGC_TLOG_REACH_TYPE.START_MATCH then
    self.ExposeIDMap = {}
  end
end
function UGCNewTLogReport:GetExposeData(ModID, Scene)
  local ExposeList = self.ExposeIDMap[ModID]
  if not ExposeList then
    return nil
  end
  if Scene then
    for _, Expose in ipairs(ExposeList) do
      if Expose.page == Scene then
        return Expose
      end
    end
  end
  return ExposeList[1]
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBasicDataTLogReport = class(CModuleBase, nil, UGCNewTLogReport)
return CBasicDataTLogReport