local logic_ugc_intention = {IntentionAbtest = nil}
function logic_ugc_intention:DefineAndResetData()
  self.AlbumThemeDataTimeStamp = nil
  self.AlbumThemeDataCD = 300
  self.Is_new = nil
  self.Is_back = nil
  self.IntentionList = {}
  self.SelectList = {}
  self.bRecommendModsRsp = false
  self.bReqHotThemeState = false
end
function logic_ugc_intention:OnLogin(bReLogin)
  print(bWriteLog and "logic_ugc_intention:OnLogin", bReLogin)
  self:send_ugc_is_recommend_fresh_req()
end
function logic_ugc_intention:OnLogOut()
  log(bWriteLog and "logic_ugc_intention:OnLogOut")
  self.Is_new = nil
  self.Is_back = nil
  self.IntentionList = {}
  self.SelectList = {}
  self.bRecommendModsRsp = false
  self.bReqHotThemeState = false
end
function logic_ugc_intention:OnPostSwitchGameStatus(preState, nextState)
  print(bWriteLog and "logic_ugc_intention:OnPostSwitchGameStatus", preState, nextState)
  if nextState == GameStatus.Lobby then
    self:send_ugc_is_recommend_fresh_req()
  end
end
function logic_ugc_intention:send_ugc_is_recommend_fresh_req()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCUnlock() then
    log(bWriteLog and "logic_ugc_intention:send_ugc_is_recommend_fresh_req IsUGCUnlock = false")
    return
  end
  log(bWriteLog and "logic_ugc_intention:send_ugc_is_recommend_fresh_req")
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_is_recommend_fresh_req()
end
function logic_ugc_intention:on_ugc_is_recommend_fresh_rsp(is_new, is_back)
  log(bWriteLog and "logic_ugc_intention:on_ugc_is_recommend_fresh_rsp is_new = " .. tostring(is_new) .. ", is_back = " .. tostring(is_back))
  self.Is_new = is_new
  self.Is_back = is_back
end
function logic_ugc_intention:send_ugc_admin_recommend_mods_req()
  log(bWriteLog and "logic_ugc_intention:send_ugc_admin_recommend_mods_req")
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_admin_recommend_mods_req()
end
function logic_ugc_intention:on_ugc_admin_recommend_mods_rsp(mods)
  log_tree("logic_ugc_intention:on_ugc_admin_recommend_mods_rsp mods", mods)
  self.IntentionList = mods
  self.ModIdList = {}
  for i, temp in ipairs(mods) do
    if temp.show_mod_id_list then
      for j, mod_id in ipairs(temp.show_mod_id_list) do
        table.insert(self.ModIdList, mod_id)
      end
    end
  end
  self.bRecommendModsRsp = true
  self:ReqIntentionListModInfo(self.ModIdList)
end
function logic_ugc_intention:send_ugc_mark_recommend_mods_req(id_arr, is_chosen)
  if is_chosen then
    self.Is_new = false
    self.Is_back = false
  end
  log(bWriteLog and "logic_ugc_intention:send_ugc_mark_recommend_mods_req is_chosen = " .. tostring(is_chosen))
  log_tree("logic_ugc_intention:send_ugc_mark_recommend_mods_req id_arr", id_arr)
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_mark_recommend_mods_req(id_arr, is_chosen)
  self:set_timeout_timer(5)
end
function logic_ugc_intention:on_ugc_mark_recommend_mods_rsp(err_code, id_arr)
  self:stop_timeout_timer()
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("logic_ugc_intention:on_ugc_mark_recommend_mods_rsp id_arr", id_arr)
  if UIManager.IsUIShow(UIManager.UI_Config.UGC_Main_Intention_Panel_UI) then
    UIManager.CloseUI(UIManager.UI_Config.UGC_Main_Intention_Panel_UI)
  end
  self:ReqHotThemePageData()
end
function logic_ugc_intention:stop_timeout_timer()
  if self.timeOutTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.timeOutTimer)
    self.timeOutTimer = nil
  end
  logic_connection_waiting:Hide(1)
end
function logic_ugc_intention:set_timeout_timer(time)
  logic_connection_waiting:Show(1)
  local time_ticker = require("common.time_ticker")
  if self.timeOutTimer then
    time_ticker.RemoveTimer(self.timeOutTimer)
  end
  self.timeOutTimer = time_ticker.AddTimerOnce(time, function()
    self:stop_timeout_timer()
  end)
end
function logic_ugc_intention:SetIntentionABTest(abTest)
  log(bWriteLog and "logic_ugc_intention:SetIntentionABTest abTest = " .. tostring(abTest))
  self.IntentionAbtest = abTest
end
function logic_ugc_intention:ReqIntentionListModInfo(ModIdList)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModList, ReqModList = LogicUGC:BatchGetModInfo(ModIdList, LogicUGC.C_ModListTypes.HotTheme, nil, {
    bGetPlayReq = true,
    TypeParam = "logic_ugc_intention"
  })
  log_tree("logic_ugc_intention:ReqIntentionListModInfo ModList", ModList)
  log_tree("logic_ugc_intention:ReqIntentionListModInfo ReqModList", ReqModList)
  if ModList and next(ModList) then
    self:OnModInfoBatchRsp(ModList, LogicUGC.C_ModListTypes.HotTheme)
  elseif not ReqModList or not next(ReqModList) then
    self:OnModInfoBatchRsp({}, LogicUGC.C_ModListTypes.HotTheme)
  end
end
function logic_ugc_intention:OnModInfoBatchRsp(MetaList, ListType, Param)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.HotTheme) then
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModList, ReqModList = LogicUGC:BatchGetModInfo(self.ModIdList, nil, nil, {bExportArray = true})
  log_tree("logic_ugc_intention:OnModInfoBatchRsp ModList", ModList)
  log_tree("logic_ugc_intention:OnModInfoBatchRsp ReqModList", ReqModList)
  log(bWriteLog and "logic_ugc_intention:OnModInfoBatchRsp self.Is_new = " .. tostring(self.Is_new) .. ", self.Is_back = " .. tostring(self.Is_back))
  log(bWriteLog and "logic_ugc_intention:OnModInfoBatchRsp self.bRecommendModsRsp = " .. tostring(self.bRecommendModsRsp))
  if (not ModList or not next(ModList)) and (not ReqModList or not next(ReqModList)) then
    log(bWriteLog and "logic_ugc_intention:OnModInfoBatchRsp ModList and ReqModList is nil")
    log(bWriteLog and "logic_ugc_intention:OnModInfoBatchRsp self.bReqHotThemeState = " .. tostring(self.bReqHotThemeState))
    if self.bRecommendModsRsp and not self.bReqHotThemeState then
      self.Is_new = false
      self.Is_back = false
      self:ReqHotThemePageData()
      self.bReqHotThemeState = true
    end
  end
  log(bWriteLog and "BeginShowTips EVENTID_UGC_INTENTION_CHECK")
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INTENTION_CHECK)
end
function logic_ugc_intention:GetIsNew()
  return self.Is_new
end
function logic_ugc_intention:GetIsBack()
  return self.Is_back
end
function logic_ugc_intention:GetBRecommendModsRsp()
  return self.bRecommendModsRsp
end
function logic_ugc_intention:GetIntentionModList()
  return self.IntentionList
end
function logic_ugc_intention:GetShowIntentionList()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ShowIntentionModList = {}
  for i = 1, #self.IntentionList do
    if self.IntentionList[i] and self.IntentionList[i].show_mod_id_list then
      for _, mod_id in ipairs(self.IntentionList[i].show_mod_id_list) do
        local ModInfo = LogicUGC:GetModByWithoutPubCache(mod_id)
        if ModInfo then
          table.insert(ShowIntentionModList, {
            ConfigDesc = self.IntentionList[i].desc,
            ConfigName = self.IntentionList[i].name,
            ConfigTag = self.IntentionList[i].target_ml_tag,
            intent_id = self.IntentionList[i].intent_id,
            is_new_play = false,
            pub_mod_meta = ModInfo.pub_mod_meta
          })
          break
        end
      end
    end
  end
  log_tree("logic_ugc_intention:GetShowIntentionList ShowIntentionModList", ShowIntentionModList)
  local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
  local NewHistoryMod = logic_ugc_new_process:GetNewHistoryMod()
  log_tree("logic_ugc_intention:GetShowIntentionList NewHistoryMod", NewHistoryMod)
  if NewHistoryMod and next(NewHistoryMod) then
    for _, temp in ipairs(ShowIntentionModList) do
      for _, tempHis in ipairs(NewHistoryMod) do
        if temp.intent_id == tempHis.intention_id then
          temp.is_new_play = true
        else
          temp.is_new_play = false
        end
      end
    end
  end
  return ShowIntentionModList
end
function logic_ugc_intention:SetIntentionSelectList(SelectID)
  table.insert(self.SelectList, SelectID)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INTENTION_MOD_SELECT)
end
function logic_ugc_intention:DelSpecifiedIntentionSelect(SelectID)
  if not self.SelectList or not next(self.SelectList) then
    log(bWriteLog and "logic_ugc_intention:DelSpecifiedIntentionSelect SelectList is nil")
    return
  end
  for i, v in ipairs(self.SelectList) do
    if v == SelectID then
      table.remove(self.SelectList, i)
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INTENTION_MOD_SELECT)
end
function logic_ugc_intention:GetIntentionSelectList()
  return self.SelectList
end
function logic_ugc_intention:CheckIntentionSelectList(SelectID)
  for i, v in ipairs(self.SelectList) do
    if v == SelectID then
      return true
    end
  end
  return false
end
function logic_ugc_intention:ClearIntentionSelectList()
  self.SelectList = {}
end
function logic_ugc_intention:ReqHotThemePageData()
  log(bWriteLog and "logic_ugc_intention:ReqHotThemePageData")
  local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
  logic_ugc_hot_page:GetTabInformation()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_intention = class(CModuleBase, nil, logic_ugc_intention)
return Clogic_ugc_intention