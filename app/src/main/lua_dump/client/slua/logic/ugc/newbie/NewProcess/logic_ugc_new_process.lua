local logic_ugc_new_process = {}
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local PufferConst = require("client.slua.logic.download.puffer_const")
function logic_ugc_new_process:DefineAndResetData()
  self.newbie_mod_data = {}
  self.newbie_history_mod = {}
  self.ModIdList = {}
  self.SelectId = nil
  self.ReqNewbieGuideDataCD = 10
  self.DataTimeStamp = nil
end
function logic_ugc_new_process:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_BATCH, self.OnModInfoBatchRsp, self)
end
function logic_ugc_new_process:OnLogOut()
  log(bWriteLog and "logic_ugc_new_process:OnLogOut")
  self.newbie_mod_data = {}
  self.newbie_history_mod = {}
  self.ModIdList = {}
  self.ModDataShowList = {}
  self.SelectId = nil
  self.bBatchModInfo = false
  self.DataTimeStamp = nil
end
function logic_ugc_new_process:OnPreSwitchGameStatus(preState, nextState)
  self.SelectId = nil
end
function logic_ugc_new_process:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Loading or nextState == GameStatus.Fighting then
    self:SetShowTranslateWindow(false)
  end
end
function logic_ugc_new_process:send_wow_query_newbie_guide_data_req()
  if self:CheckDataValid() then
    log("logic_ugc_new_process:send_wow_query_newbie_guide_data_req CheckDataValid")
    return
  end
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_wow_query_newbie_guide_data_req()
end
function logic_ugc_new_process:on_wow_query_newbie_guide_data_rsp(newbie_mod_data, newbie_history_mod)
  log_tree("logic_ugc_new_process:on_wow_query_newbie_guide_data_rsp newbie_mod_data ", newbie_mod_data)
  log_tree("logic_ugc_new_process:on_wow_query_newbie_guide_data_rsp newbie_history_mod ", newbie_history_mod)
  local TimeUtil = require("client.common.time_util")
  self.DataTimeStamp = TimeUtil.GetServerTimeInSec()
  self.  self.  self.ModIdList = {}
  for i, temp in ipairs(self.newbie_mod_data) do
    table.insert(self.ModIdList, temp.modid)
  end
  if self.bBatchModInfo then
    self:ReqBatchModInfo(self.ModIdList)
  end
end
function logic_ugc_new_process:ReqBatchModInfo(ModIdList)
  log_tree("logic_ugc_new_process:ReqBatchModInfo ModIdList ", ModIdList)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModList, ReqModList = LogicUGC:BatchGetModInfo(ModIdList, LogicUGC.C_ModListTypes.wow_newbie_guide, nil, {bGetPlayReq = true})
  if ModList and next(ModList) then
    self:OnModInfoBatchRsp(nil, nil, LogicUGC.C_ModListTypes.wow_newbie_guide, true, ModList)
  elseif not ReqModList or not next(ReqModList) then
    self:OnModInfoBatchRsp(nil, nil, LogicUGC.C_ModListTypes.wow_newbie_guide, false, {})
  end
end
function logic_ugc_new_process:OnModInfoBatchRsp(_, _, ListType, bIsDirty, MetaList, Param, FilterOfflineModList)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.wow_newbie_guide) and not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.HotTheme) then
    return
  end
  self:InitAssembledData()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWPROCESS_MOD_RSP)
end
function logic_ugc_new_process:InitAssembledData()
  log(bWriteLog and "logic_ugc_new_process:InitAssembledData")
  self.ModDataShowList = {}
  if not self.newbie_mod_data or not next(self.newbie_mod_data) then
    log(bWriteLog and "logic_ugc_new_process:InitAssembledData newbie_mod_data is nil")
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  for _, temp in ipairs(self.newbie_mod_data) do
    local ModInfo = LogicUGC:GetModByAllCache(temp.modid)
    if ModInfo then
      table.insert(self.ModDataShowList, {
        local_text_id = temp.local_text_id,
        mod_id = temp.modid,
        newbie_theme_type = temp.newbie_theme_type,
        bot_setting = temp.bot_setting,
        intention_id = temp.intention_id,
        pub_mod_meta = ModInfo.pub_mod_meta
      })
    end
  end
  if #self.ModDataShowList > 0 then
    table.sort(self.ModDataShowList, function(a, b)
      return a.newbie_theme_type < b.newbie_theme_type
    end)
  end
  self.NewHistoryMod = {}
  if not self.newbie_history_mod or not next(self.newbie_history_mod) then
    log(bWriteLog and "logic_ugc_new_process:InitAssembledData newbie_history_mod is nil")
    return
  end
  for ModId, v in pairs(self.newbie_history_mod) do
    for _, temp in ipairs(self.ModDataShowList) do
      if ModId == temp.mod_id then
        table.insert(self.NewHistoryMod, {
          mod_id = temp.modid,
          intention_id = temp.intention_id
        })
      end
    end
  end
  if 0 < #self.NewHistoryMod then
    table.sort(self.NewHistoryMod, function(a, b)
      return a.intention_id < b.intention_id
    end)
  end
end
function logic_ugc_new_process:GetModDataShowList()
  self:InitAssembledData()
  return self.ModDataShowList
end
function logic_ugc_new_process:GetNewHistoryMod()
  self:InitAssembledData()
  return self.NewHistoryMod
end
function logic_ugc_new_process:SetNewProcessSelectId(SelectID)
  self.SelectId = SelectID
  log(bWriteLog and "logic_ugc_new_process:SetNewProcessSelectId SelectId = " .. tostring(self.SelectId))
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWPROCESS_MOD_SELECT)
end
function logic_ugc_new_process:GetNewProcessSelectId()
  return self.SelectId
end
function logic_ugc_new_process:CheckNewProcessSelectId(SelectID)
  if not SelectID then
    return false
  end
  return self.SelectId == SelectID
end
function logic_ugc_new_process:ClearNewProcessSelectId()
  self.SelectId = nil
end
function logic_ugc_new_process:GetOtherModIdList(ModId)
  if not self.ModIdList or not next(self.ModIdList) then
    log(bWriteLog and "logic_ugc_new_process:GetOtherModIdList ModIdList is nil")
    return
  end
  local TableUtil = require("common.table_util")
  local NewModIdList = TableUtil.CopyTable(self.ModIdList)
  for i, v in ipairs(self.ModIdList) do
    if v == ModId then
      table.remove(NewModIdList, i)
      break
    end
  end
  return NewModIdList
end
function logic_ugc_new_process:SetBatchModInfoState(state)
  log(bWriteLog and "logic_ugc_new_process:SetBatchModInfoState state = " .. tostring(state))
  self.bBatchModInfo = state
end
function logic_ugc_new_process:SetNewbieGuideData(newbieGuideData)
  self.newbie_guide_abtest = newbieGuideData and newbieGuideData.newbie_guide_abtest or 0
  self.wow_newbie_stat = newbieGuideData and newbieGuideData.wow_newbie_stat or 0
  log(bWriteLog and "logic_ugc_new_process:SetNewbieGuideData newbie_guide_abtest = " .. tostring(self.newbie_guide_abtest) .. " wow_newbie_stat = " .. tostring(self.wow_newbie_stat))
end
function logic_ugc_new_process:CheckIsOpen()
  return self.newbie_guide_abtest == 1 and self.wow_newbie_stat == 1
end
function logic_ugc_new_process:GetDownResPakList()
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  self.pakList = LogicPufferBundle.GetMixPackDownloadContent(Config_UGC.NewbieResKey)
  log_tree("logic_ugc_new_process:GetDownResPakList self.pakList =", self.pakList)
  return self.pakList
end
function logic_ugc_new_process:GetResPakList()
  local StringUtil = require("common.string_util")
  self.pakList = {}
  local pakCfg = CDataTable.GetTableData("DownloaderPakCfg", Config_UGC.NewbieResKey)
  if pakCfg then
    local stringArr = StringUtil.Split(pakCfg.PakContent, "|")
    local keyList = {}
    for i, value in ipairs(stringArr) do
      table.insert(keyList, value)
    end
    self.pakList = keyList
  else
    self.pakList = {}
  end
  return self.pakList
end
function logic_ugc_new_process:SetDownloadState(state)
  self.DownloadState = state
end
function logic_ugc_new_process:GetDownloadState()
  return self.DownloadState
end
function logic_ugc_new_process:CheckDataValid()
  if not self.newbie_mod_data or #self.newbie_mod_data <= 0 then
    log(bWriteLog and "logic_ugc_new_process:CheckDataValid newbie_mod_data is nil")
    return false
  end
  if not self.DataTimeStamp then
    log(bWriteLog and "logic_ugc_new_process:CheckDataValid DataTimeStamp is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  return curTime <= self.DataTimeStamp + self.ReqNewbieGuideDataCD
end
function logic_ugc_new_process:GetShowUGCMainUI()
  return self.bIsShowUGCMainUI or false
end
function logic_ugc_new_process:SetShowUGCMainUI(bIsShowUGCMainUI)
  self.  log(bWriteLog and "logic_ugc_new_process:SetShowUGCMainUI bIsShowUGCMainUI is " .. tostring(self.bIsShowUGCMainUI))
end
function logic_ugc_new_process:GetShowTranslateWindow()
  return self.bIsShowTranslateWindow or false
end
function logic_ugc_new_process:SetShowTranslateWindow(bIsShowTranslateWindow)
  self.  log(bWriteLog and "logic_ugc_new_process:SetShowTranslateWindow bIsShowTranslateWindow is " .. tostring(self.bIsShowTranslateWindow))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_new_process = class(CModuleBase, nil, logic_ugc_new_process)
return Clogic_ugc_new_process