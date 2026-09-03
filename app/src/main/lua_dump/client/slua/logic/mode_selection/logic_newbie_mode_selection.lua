local logic_newbie_mode_selection = {}
function logic_newbie_mode_selection:OnInitialize()
  logic_newbie_mode_selection.__super.OnInitialize(self)
  self.loading_cfg_cache = nil
  self.newbie_mode_data = nil
  self.newbie_view_cfg = nil
  self.award_cfg = nil
  self.death_cfg = nil
  self.death_recommend = nil
  self.death_cfg_id = nil
  self.selected_view_id = nil
  if self:CheckOpen() then
    log(bWriteLog and "[NewbieModeSelection] newbie upgrade training is open")
    local NewbieModeHandler = require("client.network.Protocol.NewbieModeHandler")
    NewbieModeHandler.send_get_newbie_upgrade_data_req()
  else
    log(bWriteLog and "[NewbieModeSelection] newbie upgrade training not open")
  end
end
function logic_newbie_mode_selection:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_NEWBIE_MODE_SELECTION, self.OnModuleNewbieModeSelection, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_JUMP_TO_NEWBIE_MODE_VIEW, self.OnJumpToNewbieModeView, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, self.OnModePostSwitch, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_DEATH_RECOMMEND_POPUP, self.ShowDeathRecommendTip, self)
end
function logic_newbie_mode_selection:OnLogin(bReLogin)
end
function logic_newbie_mode_selection:OnLogOut()
  self.loading_cfg_cache = nil
  self.newbie_mode_data = nil
  self.newbie_view_cfg = nil
  self.award_cfg = nil
  self.death_cfg = nil
  self.death_recommend = nil
  self.death_cfg_id = nil
  self.selected_view_id = nil
end
function logic_newbie_mode_selection:OnPreSwitchGameStatus(preState, nextState)
end
function logic_newbie_mode_selection:OnPostSwitchGameStatus(preState, nextState)
end
function logic_newbie_mode_selection:CheckOpen()
  local bOpen = LobbySystem.CheckOpen(BP_ENUM_NEWBIE_UPGRADE_TRAINING)
  return bOpen
end
function logic_newbie_mode_selection:IsNewbieView(in_view_id)
  if self.newbie_view_cfg and next(self.newbie_view_cfg) then
    for view_id, v in pairs(self.newbie_view_cfg) do
      if in_view_id == view_id then
        return true
      end
    end
  end
  return false
end
function logic_newbie_mode_selection:IsFinish(view_id)
  if self.newbie_mode_data then
    if self.newbie_mode_data.video_train and self.newbie_mode_data.video_train[view_id] then
      return self.newbie_mode_data.video_train[view_id].is_finish
    end
    if self.newbie_mode_data.level_train and self.newbie_mode_data.level_train[view_id] then
      return self.newbie_mode_data.level_train[view_id].is_finish
    end
  end
  return false
end
function logic_newbie_mode_selection:CheckShowReddot(tabID)
  log(bWriteLog and "logic_newbie_mode_selection:CheckShowReddot tabID = " .. tostring(tabID))
  if not tabID then
    return false
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if tabID ~= mode_selection_macro.Enum_TabID.MatchNewbie then
    return false
  end
  local bHaveAwardCanTake = self:HaveAwardCanTake()
  log(bWriteLog and "logic_newbie_mode_selection:CheckShowReddot bHaveAwardCanTake = " .. tostring(bHaveAwardCanTake))
  if bHaveAwardCanTake then
    return true
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local totalAwardInfo = self:GetProgressAwardInfo()
  log_tree(bWriteLog and "logic_newbie_mode_selection:CheckShowReddot totalAwardInfo = ", totalAwardInfo)
  for key, value in pairs(totalAwardInfo) do
    if value == mode_selection_macro.newbieAwardStatus.CAN_GET then
      return true
    end
  end
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "logic_newbie_mode_selection:CheckShowReddot bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  if not bHaveLockedFeature then
    return false
  end
  local bHaveNewbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEWBIE_MODE_REDDOT, tabID)
  log(bWriteLog and "logic_newbie_mode_selection:CheckShowReddot bHaveNewbieGuide = " .. tostring(bHaveNewbieGuide))
  if bHaveNewbieGuide then
    return true
  end
end
function logic_newbie_mode_selection:HaveAwardCanTake()
  log(bWriteLog and "logic_newbie_mode_selection:HaveAwardCanTake")
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  log_tree(bWriteLog and "logic_newbie_mode_selection:HaveAwardCanTake self.newbie_mode_data = ", self.newbie_mode_data)
  if self.newbie_mode_data then
    local video_train = self.newbie_mode_data.video_train or {}
    for key, value in pairs(video_train) do
      if value and value.award_status and value.award_status == mode_selection_macro.newbieAwardStatus.CAN_GET then
        log(bWriteLog and "logic_newbie_mode_selection:HaveAwardCanTake 1")
        return true
      end
    end
    local level_train = self.newbie_mode_data.level_train
    for key, value in pairs(level_train) do
      if value and value.award_status and value.award_status == mode_selection_macro.newbieAwardStatus.CAN_GET then
        log(bWriteLog and "logic_newbie_mode_selection:HaveAwardCanTake 2")
        return true
      end
    end
  end
  log(bWriteLog and "logic_newbie_mode_selection:HaveAwardCanTake 3")
  return false
end
function logic_newbie_mode_selection:SetNewbieModeReddotGuide(tabID)
  log(bWriteLog and "logic_newbie_mode_selection:SetNewbieModeReddotGuide tabID = " .. tostring(tabID))
  if not tabID then
    return
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if tabID ~= mode_selection_macro.Enum_TabID.MatchNewbie then
    return
  end
  local bHaveNewbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEWBIE_MODE_REDDOT, 1)
  log(bWriteLog and "logic_newbie_mode_selection:SetNewbieModeReddotGuide bHaveNewbieGuide = " .. tostring(bHaveNewbieGuide))
  if not bHaveNewbieGuide then
    return
  end
  DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEWBIE_MODE_REDDOT, tabID)
end
function logic_newbie_mode_selection:GetAwardStatus(view_id)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if self.newbie_mode_data then
    if self.newbie_mode_data.video_train and self.newbie_mode_data.video_train[view_id] then
      return self.newbie_mode_data.video_train[view_id].award_status or mode_selection_macro.newbieAwardStatus.CAN_NOT_GET
    end
    if self.newbie_mode_data.level_train and self.newbie_mode_data.level_train[view_id] then
      return self.newbie_mode_data.level_train[view_id].award_status or mode_selection_macro.newbieAwardStatus.CAN_NOT_GET
    end
  end
  return mode_selection_macro.newbieAwardStatus.CAN_NOT_GET
end
function logic_newbie_mode_selection:GetAwardGroupId(view_id)
  local group_id = 0
  if self.newbie_view_cfg and self.newbie_view_cfg[view_id] then
    group_id = self.newbie_view_cfg[view_id].award_group_id or 0
  end
  return group_id
end
function logic_newbie_mode_selection:HaveShowGetAward(view_id)
  if self.newbie_mode_data then
    if self.newbie_mode_data.video_train and self.newbie_mode_data.video_train[view_id] then
      return self.newbie_mode_data.video_train[view_id].show_flag
    end
    if self.newbie_mode_data.level_train and self.newbie_mode_data.level_train[view_id] then
      return self.newbie_mode_data.level_train[view_id].show_flag
    end
  end
  return true
end
function logic_newbie_mode_selection:GetNewbieViewCfg(view_id)
  if self.newbie_view_cfg then
    return self.newbie_view_cfg[view_id]
  end
  return nil
end
function logic_newbie_mode_selection:GetViewType(view_id)
  if self.newbie_view_cfg and self.newbie_view_cfg[view_id] then
    return self.newbie_view_cfg[view_id].type_id
  end
  return require("client.slua.logic.mode_selection.mode_selection_macro").newbieViewType.Invalid
end
function logic_newbie_mode_selection:GetVideoLength(view_id)
  if self.newbie_view_cfg and self.newbie_view_cfg[view_id] then
    return self.newbie_view_cfg[view_id].finish_watch_time or 0
  end
  return 0
end
function logic_newbie_mode_selection:GetVideoShowLength(view_id)
  if self.newbie_view_cfg and self.newbie_view_cfg[view_id] then
    return self.newbie_view_cfg[view_id].show_watch_time or 0
  end
  return 0
end
function logic_newbie_mode_selection:GetFinishAwardItem(view_id)
  if self.newbie_view_cfg and self.newbie_view_cfg[view_id] and self.newbie_view_cfg[view_id].items[1] then
    return self.newbie_view_cfg[view_id].items[1]
  end
  return nil
end
function logic_newbie_mode_selection:GetLevelTotalNum()
  local param_cfg = CDataTable.GetTableData("NewbieUpgradeTrainingParamCfg", "newbie_level_total_num")
  local total_count = param_cfg and tonumber(param_cfg.ParamValue) or 10
  return total_count
end
function logic_newbie_mode_selection:GetLoadingID(view_id)
  if self.newbie_view_cfg and self.newbie_view_cfg[view_id] then
    return self.newbie_view_cfg[view_id].loading_id
  end
  return 0
end
function logic_newbie_mode_selection:GetLoadingCfgByLoadingModuleID(loading_module_id)
  if self.loading_cfg_cache and self.loading_cfg_cache[loading_module_id] then
    return self.loading_cfg_cache[loading_module_id]
  end
  local NewbieLoadingConfig = CDataTable.GetTable("NewbieLoadingConfig")
  if not NewbieLoadingConfig then
    return nil
  end
  local ret_tbl
  for k, v in pairs(NewbieLoadingConfig) do
    if v.ModuleID == loading_module_id then
      ret_tbl = ret_tbl or {}
      table.insert(ret_tbl, v)
    end
  end
  return ret_tbl
end
function logic_newbie_mode_selection:GetNewbieUpgradeViewMapKey(view_id)
  local map_key
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewDict = logic_mode_selection:GetViewDictionary()
  if viewDict and viewDict[view_id] then
    local url = viewDict[view_id].url
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(url)
    local map_id = params.mapId
    if map_id then
      local map_cfg = CDataTable.GetTableData("Map", map_id)
      map_key = map_cfg and map_cfg.MapKey or nil
    end
  end
  return map_key
end
function logic_newbie_mode_selection:GetProgressAwardInfo()
  if self.newbie_mode_data and self.newbie_mode_data.total_award then
    return self.newbie_mode_data.total_award
  end
  log_tree("logic_newbie_mode_selection:GetProgressAwardInfo self.newbie_mode_data = ", self.newbie_mode_data)
  return {
    0,
    0,
    0
  }
end
function logic_newbie_mode_selection:GetFinishCount()
  if self.newbie_mode_data then
    return self.newbie_mode_data.total_finish or 0
  end
  return 0
end
function logic_newbie_mode_selection:GetProgressAwardCfg(id)
  if self.award_cfg then
    return self.award_cfg[id]
  end
  return nil
end
function logic_newbie_mode_selection:GetProgressFinalAwardCfg()
  if not self.award_cfg then
    return nil
  end
  local totalNum = self:GetLevelTotalNum()
  for _, cfg in pairs(self.award_cfg) do
    if cfg.total_cnt == totalNum then
      return cfg.items[1]
    end
  end
  return nil
end
function logic_newbie_mode_selection:ShowDeathRecommendTip()
  log(bWriteLog and "logic_newbie_mode_selection:ShowDeathRecommendTip self.death_recommend = " .. tostring(self.death_recommend) .. " self.death_cfg_id = " .. tostring(self.death_cfg_id))
  if IsWoWEditor then
    return
  end
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "logic_newbie_mode_selection:ShowDeathRecommendTip bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  if not bHaveLockedFeature then
    return
  end
  if not self.death_recommend or not self.death_cfg_id then
    self:ShowClientDeathRecommendTips()
    return
  end
  local cfg_id = self.death_cfg_id
  self.death_recommend = nil
  self.death_cfg_id = nil
  local cfg = self.death_cfg and self.death_cfg[cfg_id]
  log_tree("logic_newbie_mode_selection:ShowDeathRecommendTip cfg = ", cfg)
  if not cfg then
    self:ShowClientDeathRecommendTips()
    return
  end
  local title_id = cfg.title_id
  local content_id = cfg.content_id
  local recommend_view = cfg.recommend_view
  log_format("logic_newbie_mode_selection:ShowDeathRecommendTip title_id = [%s], content_id = [%s], recommend_view = [%s]", title_id, content_id, recommend_view)
  if not (title_id and content_id) or not recommend_view then
    self:ShowClientDeathRecommendTips()
    return
  end
  local award_item = self:GetFinishAwardItem(recommend_view)
  log_tree("logic_newbie_mode_selection:ShowDeathRecommendTip award_item = ", award_item)
  if not award_item then
    self:ShowClientDeathRecommendTips()
    return
  end
  local death_recommend_data = DataMgr.newbieGuide[DataMgr.NEWBIE_GUIDE_MODULE_ID_DEATH_RECOMMEND_GUIDE] or {}
  log_tree("logic_newbie_mode_selection:ShowDeathRecommendTip death_recommend_data = ", death_recommend_data)
  if death_recommend_data and death_recommend_data[recommend_view] and death_recommend_data[recommend_view] == 1 then
    log_format("logic_newbie_mode_selection:ShowDeathRecommendTip is already show. viewID = [%s]", recommend_view)
    return
  end
  local title = LocUtil.GetLocalizeResStr(title_id)
  local content = LocUtil.GetLocalizeResStr(content_id)
  local jumpButton = {}
  function jumpButton.callback()
    GlobalData.JumpUrl(string.format("game://?module=1008403&viewId=%s&menuList=240|200&onlyScroll=1", recommend_view))
  end
  UIManager.ShowUI(UIManager.UI_Config.Newbie_Death_Recommend_RightBottom_Tip, title, content, award_item.item_id, award_item.count, award_item.valid_hours, jumpButton)
  DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_DEATH_RECOMMEND_GUIDE, recommend_view)
end
function logic_newbie_mode_selection:ShowClientDeathRecommendTips()
  log(bWriteLog and "logic_newbie_mode_selection:ShowClientDeathRecommendTips")
  if IsWoWEditor then
    return
  end
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  local bCheckOpen = logic_newbie_mode_selection:CheckOpen()
  log(bWriteLog and "logic_newbie_mode_selection:ShowClientDeathRecommendTips bCheckOpen = " .. tostring(bCheckOpen))
  if not bCheckOpen then
    return
  end
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "logic_newbie_mode_selection:ShowClientDeathRecommendTips bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  if not bHaveLockedFeature then
    return
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local enter_game_num = LogicNewbie.newbieTotalGameCnt
  log(bWriteLog and "logic_newbie_mode_selection:ShowClientDeathRecommendTips enter_game_num = " .. tostring(enter_game_num))
  local canRecommendTips = enter_game_num and 2 < enter_game_num
  log(bWriteLog and "logic_newbie_mode_selection:ShowClientDeathRecommendTips finish newbie guide canRecommendTips = " .. tostring(canRecommendTips))
  if not canRecommendTips then
    return
  end
  local sort_death_recommend_cfg = {}
  local death_recommend_cfg = CDataTable.GetTable("NewbieUpgradeDeathRecommend")
  if death_recommend_cfg then
    for cfg_id, cfg in pairs(death_recommend_cfg) do
      table.insert(sort_death_recommend_cfg, cfg)
    end
  end
  table.sort(sort_death_recommend_cfg, function(a, b)
    local sort1 = a.sort or 0
    local sort2 = b.sort or 0
    return sort1 < sort2
  end)
  local death_recommend_data = DataMgr.newbieGuide[DataMgr.NEWBIE_GUIDE_MODULE_ID_DEATH_RECOMMEND_GUIDE] or {}
  log_tree("logic_newbie_mode_selection:ShowClientDeathRecommendTips death_recommend_data = ", death_recommend_data)
  local result_recommend_cfg
  for key, cfg in pairs(sort_death_recommend_cfg) do
    local recommend_view = cfg.recommend_view
    if not recommend_view or death_recommend_data and death_recommend_data[recommend_view] and death_recommend_data[recommend_view] == 1 then
    else
      result_recommend_cfg = {
        ConfigID = cfg.ConfigID,
        title_id = cfg.title_id,
        content_id = cfg.content_id,
        recommend_view = cfg.recommend_view
      }
      break
    end
  end
  log_tree("logic_newbie_mode_selection:ShowClientDeathRecommendTips result_recommend_cfg = ", result_recommend_cfg)
  if result_recommend_cfg == nil or not next(result_recommend_cfg) then
    return
  end
  local title_id = result_recommend_cfg.title_id
  local content_id = result_recommend_cfg.content_id
  local recommend_view = result_recommend_cfg.recommend_view
  if not (title_id and content_id) or not recommend_view then
    return
  end
  local award_item = self:GetFinishAwardItem(recommend_view)
  log_tree("logic_newbie_mode_selection:ShowClientDeathRecommendTips award_item = ", award_item)
  if not award_item then
    return
  end
  local title = LocUtil.GetLocalizeResStr(title_id)
  local content = LocUtil.GetLocalizeResStr(content_id)
  local jumpButton = {
    callback = function()
      GlobalData.JumpUrl(string.format("game://?module=1008403&viewId=%s&menuList=240|200&onlyScroll=1", recommend_view))
    end
  }
  UIManager.ShowUI(UIManager.UI_Config.Newbie_Death_Recommend_RightBottom_Tip, title, content, award_item.item_id, award_item.count, award_item.valid_hours, jumpButton)
  DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_DEATH_RECOMMEND_GUIDE, recommend_view)
end
function logic_newbie_mode_selection:GetUrl(url_func_id)
  local url
  local language = Client.GetCurrentLanguage()
  log(bWriteLog and "[NewbieModeSelection] GetUrl url_func_id " .. tostring(url_func_id) .. " language " .. tostring(language))
  if self.video_url_cfg and url_func_id and self.video_url_cfg[url_func_id] then
    url = self.video_url_cfg[url_func_id][language]
    url = url or self.video_url_cfg[url_func_id].en
  end
  url = url or self.video_url_cfg[0] and self.video_url_cfg[0].en or nil
  return url
end
function logic_newbie_mode_selection:SetSelectView(view_id)
  self.selected_end
function logic_newbie_mode_selection:GetSelectViewInfo()
  return self.selected_view_id
end
function logic_newbie_mode_selection:IsNeedShowLoadingGuide(main_mode)
  if main_mode then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    if logic_mode_selection:CheckIsSelectedThemeView(nil) then
      log(bWriteLog and "logic_newbie_mode_selection:IsNeedShowLoadingGuide theme mode, skip")
      return false
    end
    if not logic_mode_selection:IsClassicRankMode(main_mode) and not logic_mode_selection:IsClassicMatchMode(main_mode) then
      log(bWriteLog and "logic_newbie_mode_selection:IsNeedShowLoadingGuide not classic mode, skip")
      return false
    end
  end
  local guideType = self:GetLoadingGuideType()
  return guideType ~= nil
end
function logic_newbie_mode_selection:GetLoadingGuideType()
  local loading_macro = require("client.slua.logic.loading.loading_macro")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  local toLobby = LoadingSystem.GetToLobby() or false
  if toLobby then
    return nil
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local enter_guide = require("client.slua.logic.growth_project.enter_guide")
  log(bWriteLog and string.format("logic_newbie_mode_selection:GetLoadingGuideType executeFightGuide[%s] Manual_EnterFightGuide[%s] newbieTotalGameCnt[%s]", tostring(enter_guide.executeFightGuide), tostring(enter_guide.Manual_EnterFightGuide), tostring(LogicNewbie.newbieTotalGameCnt)))
  local game_cnt = LogicNewbie.newbieTotalGameCnt
  local bNewbieGuide = (enter_guide.executeFightGuide or enter_guide.Manual_EnterFightGuide) and game_cnt == 0
  if bNewbieGuide then
    return loading_macro.ENewbieGuideType.Train
  elseif game_cnt == 0 then
    return loading_macro.ENewbieGuideType.First
  elseif game_cnt == 1 then
    return loading_macro.ENewbieGuideType.Second
  else
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
    local view_id = logic_mode_utils.GetViewIDByModeID(logic_mode_mgr.nInGameModeID)
    local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
    local loading_module_id = logic_newbie_mode_selection:GetLoadingID(view_id)
    log(bWriteLog and string.format("logic_newbie_mode_selection:GetLoadingGuideType nInGameModeID[%s] viewID[%s] loadingModuleID[%s]", tostring(logic_mode_mgr.nInGameModeID), tostring(view_id), tostring(loading_module_id)))
    if 0 < loading_module_id then
      return loading_macro.ENewbieGuideType.Advanced
    end
  end
  return nil
end
function logic_newbie_mode_selection:OnModuleNewbieModeSelection(_, __, params)
  log_tree("[NewbieModeSelection] OnModuleNewbieModeSelection", params)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local view_id
  if params.viewId then
    view_id = tonumber(params.viewId)
  end
  log(bWriteLog and "[NewbieModeSelection] OnModuleNewbieModeSelection view_id " .. tostring(view_id))
  if not view_id then
    return
  end
  local award_status = self:GetAwardStatus(view_id)
  local award_group_id = self:GetAwardGroupId(view_id)
  if award_status == mode_selection_macro.newbieAwardStatus.CAN_GET and award_group_id ~= 0 then
    self:SendNewbieUpgradeViewAwardReq(view_id)
    return
  end
  local view_type = self:GetViewType(view_id)
  if view_type == mode_selection_macro.newbieViewType.Level_Training_Standalone or view_type == mode_selection_macro.newbieViewType.Level_Training then
    UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Popup_level_UIBP, view_id)
  elseif view_type == mode_selection_macro.newbieViewType.Video_Training then
    UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Popup_Video_UIBP, view_id)
  else
    log_error(bWriteLog and "[NewbieModeSelection] OnModuleNewbieModeSelection invalid view type")
  end
end
function logic_newbie_mode_selection:OnJumpToNewbieModeView(_, __, params)
  log_tree("[NewbieModeSelection] OnJumpToNewbieModeView", params)
  if params and params.viewId then
    GlobalData.JumpUrl(string.format("game://?module=1008403&viewId=%s&menuList=240|200&onlyScroll=1", tostring(params.viewId)))
  end
end
function logic_newbie_mode_selection:SetReturnFromNewbieUpgradeLevel()
  self.bReturn_from_newbie_upgrade_level = true
end
function logic_newbie_mode_selection:SetOneMorePrimeGuideGame(sub_mod)
  self.one_more_sub_mod_id = sub_mod
end
function logic_newbie_mode_selection:OnModePostSwitch(_, __, params)
  log(bWriteLog and "logic_newbie_mode_selection:OnModePostSwitch")
  if params then
    log(bWriteLog and "[NewbieModeSelection] logic_newbie_mode_selection:OnModePostSwitch pre " .. tostring(params.pre) .. " current " .. tostring(params.current) .. " one_more_sub_mod_id " .. tostring(self.one_more_sub_mod_id) .. " bReturn_from_newbie_upgrade_level " .. tostring(self.bReturn_from_newbie_upgrade_level))
    if params.pre == GameStatus.Login then
      self.one_more_sub_mod_id = nil
    end
    if params.current == GameStatus.Lobby then
      if self.one_more_sub_mod_id then
        local sub_mod = self.one_more_sub_mod_id
        self.one_more_sub_mod_id = nil
        local enter_guide = require("client.slua.logic.growth_project.enter_guide")
        local logic_enter_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_guide)
        logic_enter_guide:EnterStandaloneNewbieLevel(sub_mod, true)
      elseif params.pre == GameStatus.Fighting and self.bReturn_from_newbie_upgrade_level then
        self.bReturn_from_newbie_upgrade_level = nil
        local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
        local bEnterMainCity = main_city_process_util.CheckEnterMainCityFromFighting()
        if bEnterMainCity then
          return
        end
        local promise = require("common.Promise")
        local await = promise.Helper.LobbyAwait
        await(0.3, function()
          local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
          return lobbyMain ~= nil
        end):Then(function()
          GlobalData.JumpUrl("game://?module=1008403&menuList=240|200")
        end)
      end
    elseif params.current == GameStatus.Fighting then
      self.one_more_sub_mod_id = nil
      self.bReturn_from_newbie_upgrade_level = nil
    end
  end
end
function logic_newbie_mode_selection:OnGetNewbieUpgradeDataRsp(data, newbie_view_cfg, award_cfg, death_cfg, video_url_cfg)
  log_tree("[NewbieModeSelection] OnGetNewbieUpgradeDataRsp data", data)
  log_tree("[NewbieModeSelection] OnGetNewbieUpgradeDataRsp newbie_view_cfg", newbie_view_cfg)
  log_tree("[NewbieModeSelection] OnGetNewbieUpgradeDataRsp award_cfg", award_cfg)
  log_tree("[NewbieModeSelection] OnGetNewbieUpgradeDataRsp death_cfg", death_cfg)
  log_tree("[NewbieModeSelection] OnGetNewbieUpgradeDataRsp video_url_cfg", video_url_cfg)
  self.newbie_mode_  self.  self.  self.  self.  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_GET_NEWBIE_UPGRADE_DATA_RSP)
end
function logic_newbie_mode_selection:OnNewbieUpgradeTotalRewardRsp(cfg_id, data)
  log_tree("[NewbieModeSelection] OnNewbieUpgradeTotalRewardRsp data", data)
  log(bWriteLog and "[NewbieModeSelection] OnNewbieUpgradeTotalRewardRsp cfg_id " .. tostring(cfg_id))
  self.newbie_mode_  local award_cfg = self:GetProgressAwardCfg(cfg_id)
  if award_cfg and award_cfg.items[1] then
    local award_item = award_cfg.items[1]
    local _data = {}
    _data.res_id = award_item.item_id
    _data.count = award_item.count
    _data.valid_hours = award_item.valid_hours
    _data.expire_time = 0
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle({_data})
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_REFRESH_NEWBIE_UPGRADE_PROGRESS_AWARD)
end
function logic_newbie_mode_selection:SendNewbieUpgradeTrainDetailReq(view_id, seconds)
  if self:CheckOpen() then
    local NewbieModeHandler = require("client.network.Protocol.NewbieModeHandler")
    NewbieModeHandler.send_newbie_upgrade_train_detail_req(view_id, {watch_time = seconds})
  end
end
function logic_newbie_mode_selection:OnNewbieUpgradeTrainDetailRsp(view_id, data)
  log_tree("[NewbieModeSelection] OnNewbieUpgradeTrainDetailRsp data", data)
  self.newbie_mode_end
function logic_newbie_mode_selection:OnNewbieUpgradeSyncData(view_id, data)
  log(bWriteLog and "[NewbieModeSelection] OnNewbieUpgradeSyncData view_id " .. tostring(view_id))
  log_tree("[NewbieModeSelection] OnNewbieUpgradeSyncData data", data)
  self.newbie_mode_  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_NEWBIE_UPGRADE_SYNC_DATA, view_id)
end
function logic_newbie_mode_selection:OnNewbieUpgradeAwardShowRsp(data)
  log_tree("[NewbieModeSelection] OnNewbieUpgradeAwardShowRsp data", data)
  self.newbie_mode_end
function logic_newbie_mode_selection:OnNewbieUpgradeTrainRecommandNtf(cfg_id)
  if cfg_id then
    self.death_recommend = true
    self.death_  end
end
function logic_newbie_mode_selection:SendNewbieUpgradeViewAwardReq(view_id)
  log(bWriteLog and "[NewbieModeSelection] SendNewbieUpgradeViewAwardReq view_id " .. tostring(view_id))
  local NewbieModeHandler = require("client.network.Protocol.NewbieModeHandler")
  NewbieModeHandler.send_newbie_upgrade_view_award_req(view_id)
end
function logic_newbie_mode_selection:OnNewbieUpgradeViewAwardRsp(view_id, data)
  log(bWriteLog and "[NewbieModeSelection] OnNewbieUpgradeViewAwardRsp view_id " .. tostring(view_id))
  log_tree("[NewbieModeSelection] OnNewbieUpgradeViewAwardRsp data", data)
  self.newbie_mode_  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_NEWBIE_UPGRADE_VIEW_AWARD, view_id)
  local award_item = self:GetFinishAwardItem(view_id)
  if award_item then
    local award_data = {}
    award_data.res_id = award_item.item_id
    award_data.count = award_item.count
    award_data.valid_hours = award_item.valid_hours
    award_data.expire_time = 0
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle({award_data})
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_newbie_mode_selection = class(CModuleBase, nil, logic_newbie_mode_selection)
return Clogic_newbie_mode_selection