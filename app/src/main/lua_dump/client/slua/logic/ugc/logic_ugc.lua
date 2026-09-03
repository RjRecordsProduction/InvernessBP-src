local Logic_UGC = {C_ClearCacheCD = 300}
local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
function Logic_UGC:EnterUGC()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  self:ReqGetAllMetaKey()
  if self.ClearModCacheTimer then
    self:RemoveTimer(self.ClearModCacheTimer)
    self.ClearModCacheTimer = nil
  end
  if Config_UGC.NewWOWHall ~= 2 then
    local logic_ugc_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
    logic_ugc_season:ReqGetUGCSeasonData()
  end
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:ReqAuthorExAwardInfo()
  local Logic_UGC_Popup_Queue = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_popup_queue)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:ReqUGCWOWPassBuyGuideReq()
  self:ReqAlbumThemeConfig()
  self:ReqNewbieUGCRecommend()
end
function Logic_UGC:ExitUGC(bFastClearCache)
  self:ClearData(bFastClearCache)
  local LogicUGCSocial = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCSocial)
  LogicUGCSocial:ClearData()
  local LogicUGCRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRank)
  LogicUGCRank:ClearCache()
  local logicUGCRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRoom)
  logicUGCRoom:ClearData()
end
function Logic_UGC:EnterMineUGCMode()
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_get_modlist_req()
  self:ReqGetAllMetaKey()
  if IsWoWEditor then
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    LogicUGCAuthor:ReqAuthorExAwardInfo()
    self:ReqAlbumThemeConfig()
  end
end
function Logic_UGC:CheckModNameUsed(name, isPublish, slot)
  if not name or name == "" then
    return false
  end
  if isPublish then
    if self.ModCacheList[UGCMacros.ENUM_MODE_TYPE.Pub] then
      for i, modInfo in pairs(self.ModCacheList[UGCMacros.ENUM_MODE_TYPE.Pub]) do
        if name == modInfo.pub_mod_meta.setting.name then
          return true
        end
      end
    end
  else
    local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
    local modes = LogicUGCCRUD:GetModeList()
    for i, modInfo in pairs(modes) do
      if name == modInfo.setting.name and (not slot or i ~= slot) then
        return true
      end
    end
  end
  return false
end
function Logic_UGC:CheckCustomVarCloudEnable(modInfo)
  local TableUtil = require("common.table_util")
  local CustomVarCloudEnable = TableUtil.GetTableValue(modInfo, "setting", "CustomVarCloudEnable") or 0
  log(bWriteLog and "Logic_UGC:CheckCustomVarCloudEnable CustomVarCloudEnable = " .. tostring(CustomVarCloudEnable))
  if CustomVarCloudEnable == 0 then
    return false
  end
  return true
end
function Logic_UGC:SetSelectedTabId(in_tab_id)
  log(bWriteLog and "Logic_UGC:SetSelectedTabId in_tab_id " .. tostring(in_tab_id))
  self:PostChangeTabEvent(self.selectedTabId, in_tab_id)
  self.selectedTabId = in_tab_id
  local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
  Logic_UGC_TLog:UpdateRequestId()
end
function Logic_UGC:GetSelectedTabId()
  return self.selectedTabId
end
function Logic_UGC:SetSelectedSubTabId(sub_tab_id)
  self:PostChangeTabEvent(self.selectedSubTabId, sub_tab_id)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  self.selectedSubTabId = sub_tab_id or Config_UGC.CONST_DEFAULT_SUB_TAB_INDEX
  log(bWriteLog and "[v_wllwu] Logic_UGC:SetSelectedTabId, sub_tab_id is:" .. tostring(self.selectedSubTabId))
  local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
  Logic_UGC_TLog:UpdateRequestId()
end
function Logic_UGC:GetSelectedSubTabId()
  if self.selectedSubTabId == 0 then
    return
  end
  return self.selectedSubTabId
end
function Logic_UGC:PostChangeTabEvent(old_id, new_id)
  if old_id == new_id then
    return
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CHANGE_SELECTED_TAB)
end
function Logic_UGC:CanShowGuidPopTip()
  local LogicUGCExposure = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCExposure)
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  if LogicUGCExposure:GetShowGuidePop() or LogicUGCCenter:GetShowGuidePop() then
    return false
  else
    return true
  end
end
function Logic_UGC:GetPubModList()
  return self.modKeyInfoList ~= nil and self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Pub] or nil
end
function Logic_UGC:GetHistoryKeyInfoList()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local maxHistoryCount = Config_UGC.MaxModPalyCut
  local IsBuy = false
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  IsBuy = Util_UGC.WoWPassActive(profile)
  if IsBuy then
    maxHistoryCount = Config_UGC.MaxModPalyCutPassOn
  end
  if self.modKeyInfoList ~= nil and self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.History] then
    local historyList = self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.History] or {}
    local count = 0
    for k, v in pairs(historyList) do
      count = count + 1
    end
    local sortList = {}
    if maxHistoryCount < count then
      for k, v in pairs(historyList) do
        local cons = {}
        cons.play_time = v.play_time
        cons.modid = k
        table.insert(sortList, cons)
      end
      table.sort(sortList, function(a, b)
        return a.play_time > b.play_time
      end)
      for i = #sortList, maxHistoryCount + 1, -1 do
        historyList[sortList[i].modid] = nil
      end
    end
    return historyList
  else
    return nil
  end
end
function Logic_UGC:GetHistoryMatchKeyInfoList()
  if not (self.modKeyInfoList and self.modKeyInfoList.history_match_list) or not next(self.modKeyInfoList.history_match_list) then
    return nil
  end
  local history_match_list = {}
  for k, v in pairs(self.modKeyInfoList.history_match_list) do
    if not history_match_list[v.ugc_mod_id] then
      history_match_list[v.ugc_mod_id] = v
    elseif history_match_list[v.ugc_mod_id].play_time < v.play_time then
      history_match_list[v.ugc_mod_id] = v
    end
  end
  local history_play_list = self:GetHistoryKeyInfoList() or {}
  for modid, v in pairs(history_play_list) do
    if history_match_list[modid] then
      history_match_list[modid] = nil
    end
  end
  return history_match_list
end
function Logic_UGC:GetCollectKeyInfoList()
  local IsBuy = false
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  IsBuy = logic_ugc_WOWPass:IsBuyElite()
  if self.modKeyInfoList ~= nil and self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Collect] then
    local collectAllList = self:GetOriginalCollectKeyInfoList()
    local collectNoPassList = {}
    if IsBuy then
      log(bWriteLog and "Logic_UGC:GetCollectKeyInfoList()  collectAllList")
      return collectAllList
    else
      for k, v in pairs(collectAllList) do
        if not v.wow_pass_shielded then
          collectNoPassList[k] = v
        end
      end
      log(bWriteLog and "Logic_UGC:GetCollectKeyInfoList()  collectNoPassList")
      return collectNoPassList
    end
  end
  log(bWriteLog and "Logic_UGC:GetCollectKeyInfoList()  nil")
  return nil
end
function Logic_UGC:GetOriginalCollectKeyInfoList()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local maxCollectCount = Config_UGC.MaxModCollect
  local IsBuy = false
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  IsBuy = logic_ugc_WOWPass:IsBuyElite()
  if IsBuy then
    maxCollectCount = Config_UGC.MaxModCollectPassOn
  end
  if self.modKeyInfoList ~= nil and self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Collect] then
    local collectList = {}
    local count = 0
    for k, v in pairs(self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Collect]) do
      collectList[k] = v
      if not v.wow_pass_shielded then
        count = count + 1
      end
    end
    local sortList = {}
    if maxCollectCount < count then
      for k, v in pairs(collectList) do
        local cons = {}
        cons.collect_time = v.collect_time
        cons.modid = k
        table.insert(sortList, cons)
      end
      table.sort(sortList, function(a, b)
        return a.collect_time > b.collect_time
      end)
      for i = #sortList, maxCollectCount + 1, -1 do
        self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Collect][sortList[i].modid].wow_pass_shielded = true
      end
    end
  end
  return self.modKeyInfoList ~= nil and self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Collect] or nil
end
function Logic_UGC:UpdateCollectKeyInfoList(ModID, CollectInfo)
  if not ModID then
    return
  end
  if not CollectInfo then
    self:GetOriginalCollectKeyInfoList()
  end
  if self.modKeyInfoList then
    if not self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Collect] then
      self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Collect] = {}
    end
    self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Collect][ModID] = CollectInfo
  end
end
function Logic_UGC:_GetModCache(cacheType, modID)
  local cache = self.ModCacheList[cacheType]
  if not cache then
    return nil
  end
  return cache[modID]
end
function Logic_UGC:GetCacheByType(cacheType)
  return self.ModCacheList[cacheType]
end
function Logic_UGC:ClearModCacheByType(CacheType, bReset)
  if not self.ModCacheList then
    return
  end
  if bReset then
    self.ModCacheList[CacheType] = {}
  else
    self.ModCacheList[CacheType] = nil
  end
  for k, v in pairs(self.ModReqCacheMap) do
    if v[CacheType] then
      self.ModReqCacheMap[k][CacheType] = nil
    end
  end
  if CacheType == UGCMacros.ENUM_MODE_TYPE.UgcMatch then
    self.ModReqMatchList = {}
  end
end
function Logic_UGC:GetModByWithoutPubCache(modID)
  if not self.ModCacheList then
    return nil
  end
  for k, v in pairs(self.ModCacheList) do
    if k ~= UGCMacros.ENUM_MODE_TYPE.Pub and v and v[modID] then
      return v[modID]
    end
  end
  return nil
end
function Logic_UGC:GetModByAllCache(modID)
  log(bWriteLog and "[edward] Logic_UGC:GetModByAllCache modID:" .. tostring(modID))
  local pub_meta_list = self:GetCacheByType(UGCMacros.ENUM_MODE_TYPE.Pub) or {}
  local modInfo = pub_meta_list[modID]
  if modInfo then
    return modInfo
  else
    modInfo = self:GetModByWithoutPubCache(modID)
    return modInfo
  end
end
function Logic_UGC:GetMatchModIsReq()
  return self.ModReqMatchList
end
function Logic_UGC:SetMatchReqCache(ModID)
  if not self.ModReqMatchList then
    self.ModReqMatchList = {}
  end
  self.ModReqMatchList[ModID] = true
  if not self.ModReqCacheMap[ModID] then
    self.ModReqCacheMap[ModID] = {}
  end
  self.ModReqCacheMap[ModID][UGCMacros.ENUM_MODE_TYPE.UgcMatch] = true
end
function Logic_UGC:GetModIsReq(modID)
  if not self.ModReqCacheMap then
    return false
  end
  if self.ModReqCacheMap[modID] then
    return true
  end
  return false
end
function Logic_UGC:_GetModIsReqByType(modID, CacheType)
  if not self.ModReqCacheMap then
    return false
  end
  if self.ModReqCacheMap[modID] and self.ModReqCacheMap[modID][CacheType] then
    return true
  end
  return false
end
function Logic_UGC:GetModIsBan(ModID)
  return self.ModBanCache[ModID]
end
function Logic_UGC:ClearAllModCache()
  if not self.ModCacheList then
    return
  end
  log(bWriteLog and "[edward] Logic_UGC:ClearAllModCache")
  for k, v in pairs(self.ModCacheList) do
    if not UGCMacros.ENUM_SKIP_CLEAR[k] then
      self.ModCacheList[k] = nil
    end
  end
  self.ModReqCacheMap = {}
  self.ModBanCache = {}
  self.ModReqMatchList = {}
end
function Logic_UGC:CacheModJumpData(data)
  self.modJumpCacheData = data
end
function Logic_UGC:GetRecommandBannerPicture(mod_id)
  for k, v in pairs(self.recommendBannerPicList or {}) do
    if v.mod_id == mod_id then
      return v
    end
  end
  return nil
end
function Logic_UGC:GetResultRecommandList()
  return self.recommendResultList, self.recommendResultListCount
end
function Logic_UGC:SetUGCGameMod(mod)
  print(bWriteLog and "Logic_UGC:SetUGCGameMod " .. tostring(mod))
  if not mod then
    self.bIsUGCGameMod = false
    return
  end
  local BTMode = CDataTable.GetTableData("BTMode", mod)
  if not BTMode then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  self.bIsUGCGameMod = BTMode.ModType == Config_UGC.ModType
  if self.bIsUGCGameMod == false then
    for i = 1, #UGCMacros.UGC_SUB_GAME_MODE_ID_LIST do
      if mod == UGCMacros.UGC_SUB_GAME_MODE_ID_LIST[i] then
        self.bIsUGCGameMod = true
        break
      end
    end
  end
  self.bIsUGCEditMod = mod == UGCMacros.EDIT_SUB_MODE
  print(bWriteLog and "Logic_UGC:SetUGCGameMod self.bIsUGCGameMod = " .. tostring(self.bIsUGCGameMod))
  print(bWriteLog and "Logic_UGC:SetUGCGameMod self.bIsUGCEditMod = " .. tostring(self.bIsUGCEditMod))
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SETUGCGAMEMOD)
end
function Logic_UGC:IsUGCEditMod()
  return self.bIsUGCEditMod
end
function Logic_UGC:IsUGCGameMod()
  return self.bIsUGCGameMod
end
function Logic_UGC:SetBattlegroundCode(code)
  self.nBattlegroundCode = code or 0
end
function Logic_UGC:SetMatchCache(ModID, ModInfo)
  if not self.ModCacheList[UGCMacros.ENUM_MODE_TYPE.UgcMatch] then
    return
  end
  self.ModCacheList[UGCMacros.ENUM_MODE_TYPE.UgcMatch][ModID] = ModInfo
end
function Logic_UGC:SetModCache(ListType, ModID, ModInfo)
  if not self.ModCacheList[ListType] then
    self.ModCacheList[ListType] = {}
  end
  self.ModCacheList[ListType][ModID] = ModInfo
end
function Logic_UGC:GetSortedPubModList()
  local pubList = self:GetPubModList()
  if not pubList then
    log(bWriteLog and "Logic_UGC:GetSortedPubModList no pubList")
    return nil
  end
  local sortPubList = {}
  for modid, info in pairs(pubList) do
    table.insert(sortPubList, {modId = modid, pubInfo = info})
  end
  table.sort(sortPubList, function(a, b)
    local aVerifyTime = a.pubInfo and a.pubInfo.verify_time or 0
    local bVerifyTime = b.pubInfo and b.pubInfo.verify_time or 0
    return aVerifyTime > bVerifyTime
  end)
  log_tree(bWriteLog and "Logic_UGC:GetSortedPubModList sortPubList", sortPubList)
  return sortPubList
end
function Logic_UGC:OnUgcChooseModNoMapUidsNotify(mod_id, uids)
  self.curMatchModId = mod_id
  self.curMatchNoMapIds = uids
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_OTHER_FINISH)
end
function Logic_UGC:GetUgcChooseModNoMapUidsStr(mod_id)
  if mod_id == self.curMatchModId then
    local no_mod_uids = self.curMatchNoMapIds
    if no_mod_uids then
      local names = ""
      local teamSystem = require("client.slua.logic.teamup.logic_team_up")
      for k, uid in pairs(no_mod_uids) do
        local memName = teamSystem.GetMemberName(uid)
        if memName then
          if 0 < #names then
            names = names .. "\239\188\140" .. memName
          else
            names = memName
          end
        end
      end
      if 0 < #names then
        local tipContent = LocUtil.LocalizeResFormat(48452, names)
        return tipContent
      end
    end
  end
  return nil
end
function Logic_UGC:DefineAndResetData()
  self.C_ModListTypes = UGCMacros.ENUM_MODE_TYPE
  self.ClearCacheCD = self.C_ClearCacheCD
  self.recommendList = nil
  self.recommendBannerList = nil
  self.recommendBannerPicList = nil
  self.modKeyInfoList = nil
  self.modJumpCacheData = nil
  self.tempSelectTagsCache = nil
  self.tempSearchTagCache = nil
  self.curMatchModId = nil
  self.curMatchNoMapIds = nil
  self.ModCacheList = {}
  self.ModReqCacheMap = {}
  self.ModBanCache = {}
  self.ModReqMatchList = {}
  self.ClearModCacheTimer = nil
  self.workReachTlogTimestamp = {}
  self.recommendResultList = nil
  self.promotionList = nil
  self.PubModRedDotData = nil
  self.bUGCButtonAnim = false
  self.bFristBecomeAuthor = nil
  self.DetailTranslate = false
  self.NotAuthorTipsID = 9
  self.gallery_rec_first_x = 0
  self.gallery_rec_every_y = 0
  self.PromotionDataTimeStamp = nil
  self.PromotionReqCD = 120
  self.PromotionShowIndex = 0
  self.trans_info = {}
  self.headIcons = {
    [1] = "/Game/UMG/Texture/Headportrait/T_icon_touxiang_055_128.T_icon_touxiang_055_128",
    [2] = "/Game/UMG/Texture/Headportrait/T_Icon_touxiang_211_128.T_Icon_touxiang_211_128",
    [3] = "/Game/UMG/Texture/Headportrait/T_icon_touxiang_089_128.T_icon_touxiang_089_128",
    [4] = "/Game/UMG/Texture/Headportrait/T_Icon_Touxiang_StrayDog_128.T_Icon_Touxiang_StrayDog_128",
    [5] = "/Game/UMG/Texture/Headportrait/T_icon_touxiang_029_128.T_icon_touxiang_029_128",
    [6] = "/Game/UMG/Texture/Headportrait/T_Icon_touxiang_213_128.T_Icon_touxiang_213_128",
    [7] = "/Game/UMG/Texture/Headportrait/T_icon_touxiang_A9_128.T_icon_touxiang_A9_128",
    [8] = "/Game/UMG/Texture/Headportrait/T_Icon_touxiang_231_128.T_Icon_touxiang_231_128",
    [9] = "/Game/UMG/Texture/Headportrait/T_Icon_Touxiang_Elk_128.T_Icon_Touxiang_Elk_128",
    [10] = "/Game/UMG/Texture/Headportrait/T_icon_touxiang_033_128.T_icon_touxiang_033_128",
    [11] = "/Game/UMG/Texture/Headportrait/T_Icon_touxiang_237_128.T_Icon_touxiang_237_128"
  }
end
function Logic_UGC:ctor(_, ModuleConfig)
  self.AutoSendMomentModIDMap = {}
  self.bClose = false
  self.UGCFaceSlapData = nil
  self.bFaceSlapShowing = false
  self.PubModSucceed = 8
  self.AICoverResults_Succeed = 10
  self.AICoverResults_Fail = 11
  self.CreatorLeveUp = 1
  self.ReviewFailed = 7
  self.NewPubModID = nil
end
function Logic_UGC:OnLogOut()
  self.UGCFaceSlapData = nil
  self.caring_last_publish_mod = nil
  self.author_progress = nil
  self.author_level_up_data = nil
end
function Logic_UGC:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ALL_ACTIVITY_CHANGE, self.OnAllActChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_BATCH, self.OnPubModInfoRsp, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_ADD_STEAL_BRAINROT_CARD, self.OnAddStealBrainrotCard, self)
end
function Logic_UGC:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[edward] Logic_UGC:OnPreSwitchGameStatus")
  self.workReachTlogTimestamp = nil
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    if self:IsUGCGameMod() then
      local StaticMeshStreamingVar = FuncUtil.UE4GetConsoleVariableIntValue("r.StaticMeshStreaming")
      if StaticMeshStreamingVar == 1 then
        FuncUtil.UE4ExecuteConsoleCommand("r.StaticMeshStreaming 0")
        self.bDisableStaticMeshStreaming = true
      end
    else
      if self.bDisableStaticMeshStreaming then
        FuncUtil.UE4ExecuteConsoleCommand("r.StaticMeshStreaming 1")
      end
      self.bDisableStaticMeshStreaming = false
    end
  elseif nextState == GameStatus.Lobby then
    if self.bDisableStaticMeshStreaming then
      FuncUtil.UE4ExecuteConsoleCommand("r.StaticMeshStreaming 1")
    end
    self.bDisableStaticMeshStreaming = false
  end
  if preState == GameStatus.Lobby then
    local LogicComplaint = require("client.logic.battle.logic_complaint")
    LogicComplaint.ClearPanel()
  end
end
function Logic_UGC:OnPostSwitchGameStatus(preState, nextState)
  print(bWriteLog and "Logic_UGC:OnPostSwitchGameStatus preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
  if nextState ~= GameStatus.Fighting and nextState ~= GameStatus.Loading then
    if preState == GameStatus.Fighting then
      self:ExitUGC(true)
      if IsWoWEditor then
        self:AddTimerOnce(0, function()
          self:RealDoBackToUGC()
        end)
        return
      end
      self.bPendingReOpenUGC = false
      local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
      local bGetIsEditMod = LogicUGCCRUD:GetIsEditMod()
      log(bWriteLog and "Logic_UGC:OnPostSwitchGameStatus self.bIsUGCGameMod = " .. tostring(self.bIsUGCGameMod) .. " bGetIsEditMod = " .. tostring(bGetIsEditMod))
      if self.bIsUGCGameMod and bGetIsEditMod then
        self.bPendingReOpenUGC = true
      end
      local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
      local bPendingEnterMainCity = main_city_process_util.CheckEnterMainCityFromFighting()
      log(bWriteLog and "Logic_UGC:OnPostSwitchGameStatus bPendingEnterMainCity = " .. tostring(bPendingEnterMainCity))
      if bPendingEnterMainCity then
        self:AddBackToUGCInTaskQueue()
        return
      end
      log(bWriteLog and "[v_chenxxue]OnPostSwitchGameStatus GetShowUGCCenterMainUI " .. tostring(LogicUGCCRUD:GetShowUGCCenterMainUI()))
      self:AddTimerOnce(0, function()
        self:RealDoBackToUGC()
      end)
    end
  elseif nextState == GameStatus.Login then
    self:ExitUGC(true)
    self.bIsUGCGameMod = false
    local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
    LogicUGCCRUD:SetIsEditMod(false)
    LogicUGCCRUD:SetShowUGCCenterMainUI(false)
    LogicUGCCRUD:SetLastStartNewbie(false)
    self.bPendingReOpenUGC = false
    local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
    logic_ugc_new_process:SetShowUGCMainUI(false)
  end
end
function Logic_UGC:AddBackToUGCInTaskQueue()
  log(bWriteLog and "Logic_UGC:AddBackToUGCInTaskQueue")
  self:AddTimerOnce(0.5, function()
    local IsInLobbyOrMainCity = GameStatus.IsInLobbyOrMainCity()
    log(bWriteLog and "Logic_UGC:AddBackToUGCInTaskQueue IsInLobbyOrMainCity = " .. tostring(IsInLobbyOrMainCity))
    if not IsInLobbyOrMainCity then
      local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
      self.bIsUGCGameMod = false
      LogicUGCCRUD:SetIsEditMod(false)
      LogicUGCCRUD:SetShowUGCCenterMainUI(false)
      LogicUGCCRUD:SetLastStartNewbie(false)
      self.bPendingReOpenUGC = false
      return
    end
    local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
    local task = {
      module = self,
      funcName = "RealDoBackToUGC",
      param = self,
      debugInfo = "Logic_UGC:AddBackToUGCInTaskQueue",
      protect = true
    }
    queue_task_module:Enqueue(queue_task_module.TaskEnum.UGC, task)
  end)
end
function Logic_UGC:RealDoBackToUGC()
  log(bWriteLog and "Logic_UGC:RealDoBackToUGC")
  if not IsWoWEditor then
    self:EnterUGC()
  end
  local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
  local bGetShowUGCCenterMainUI = LogicUGCCRUD:GetShowUGCCenterMainUI()
  log(bWriteLog and "Logic_UGC:RealDoBackToUGC bGetShowUGCCenterMainUI = " .. tostring(bGetShowUGCCenterMainUI))
  if bGetShowUGCCenterMainUI then
    self:BackToUGCCenter()
  elseif not IsWoWEditor then
    local bGetIsEditMod = LogicUGCCRUD:GetIsEditMod()
    log(bWriteLog and "Logic_UGC:RealDoBackToUGC self.bIsUGCGameMod = " .. tostring(self.bIsUGCGameMod) .. " bGetIsEditMod = " .. tostring(bGetIsEditMod) .. " self.bPendingReOpenUGC = " .. tostring(self.bPendingReOpenUGC))
    if self.bPendingReOpenUGC then
      self:BackToUGC()
    end
  end
  local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
  local bGetShowUGCMainUI = logic_ugc_new_process:GetShowUGCMainUI()
  log(bWriteLog and "Logic_UGC:RealDoBackToUGC bGetShowUGCMainUI = " .. tostring(bGetShowUGCMainUI))
  if bGetShowUGCMainUI then
    local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local curPage = lobbyMainLogic.curPage
    log(bWriteLog and "ModeSelection_Main_UIBP:OnMenuAlphaClick curPage = " .. tostring(curPage) .. " rightMode = " .. tostring(rightMode))
    if curPage == ENUM_LobbyPageType.Right then
      self:AddTimer(0.5, function()
        UIManager.ShowUI(UIManager.UI_Config.UGCMainPanelFindWorksHall)
      end)
    else
      self:AddTimer(0.5, function()
        UIManager.ShowUI(UIManager.UI_Config.mode_selection_main, {defaultTopMenuId = 900})
      end)
    end
  end
  self:CheckStartMatch()
  self.bIsUGCGameMod = false
  LogicUGCCRUD:SetIsEditMod(false)
  LogicUGCCRUD:SetShowUGCCenterMainUI(false)
  LogicUGCCRUD:SetLastStartNewbie(false)
  self.bPendingReOpenUGC = false
  logic_ugc_new_process:SetShowUGCMainUI(false)
end
function Logic_UGC:BackToUGC()
  log(bWriteLog and "Logic_UGC:BackToUGC")
  self:AddTimer(0.5, function()
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    local ui_manager = require("client.slua_ui_framework.manager")
    ui_manager.ShowUI(ui_manager.UI_Config.ugc_mine_main, Config_UGC.Config_UGC_MineTabID.Mine, true)
  end)
end
function Logic_UGC:BackToUGCCenter()
  log(bWriteLog and "Logic_UGC:BackToUGCCenter")
  local time_ticker = require("common.time_ticker")
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  local bAuthor, AuthorType = LogicUGCAuthor:NewCheckPlayerIsAuthor(DataMgr.roleData.uid)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if bAuthor then
    if AuthorType then
      self:AddTimer(0.5, function()
        local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
        local Config_UGC_Center_TabID = Config_UGC_Center.Config_UGC_Center_TabID
        log(bWriteLog and "BackToUGCCenter UGC_Center_Main")
        local logic_ugc_center = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
        logic_ugc_center:OpenUGCCenterMainUI(Config_UGC_Center_TabID.School, Config_UGC_Center_TabID.Challenge, {bBackFromFight = true, tabid = 1})
      end)
    end
  elseif AuthorType and AuthorType == Config_UGC.Enum_Author_Type.New then
    self:AddTimer(0.5, function()
      log(bWriteLog and "BackToUGCCenter UGC_Beginner_Level_UIBP")
      if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_UGC_AUTHOR_VERIFY_ENTRANCE) then
        ShowNotice(116009)
        return
      end
      local Logic_UGC_Center = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
      local newBieLevelId = Logic_UGC_Center:GetNewbieLevelId()
      if newBieLevelId then
        log(bWriteLog and "Logic_UGC:BackToUGCCenter newBieLevelId:" .. tostring(newBieLevelId))
        Logic_UGC_Center:GetTutorialAward(newBieLevelId)
      end
    end)
  end
end
function Logic_UGC:ClearData(bFastClearCache)
  self.recommendList = nil
  self.recommendBannerList = nil
  self.recommendBannerPicList = nil
  self.modJumpCacheData = nil
  self.tempSelectTagsCache = nil
  self.tempSearchTagCache = nil
  self.recommendResultList = nil
  self.promotionList = nil
  self.selectedTabId = 0
  self:ClearCacheRecommendData()
  if self.ClearModCacheTimer then
    self:RemoveTimer(self.ClearModCacheTimer)
    self.ClearModCacheTimer = nil
  end
  if bFastClearCache then
    self:ClearAllModCache()
  else
    self.ClearModCacheTimer = self:AddTimer(self.ClearCacheCD, function()
      self.ClearCacheCD = self.C_ClearCacheCD
      self:ClearAllModCache()
    end)
  end
end
function Logic_UGC:ClearCacheRecommendData()
  local randomCache = self.ModCacheList[UGCMacros.ENUM_MODE_TYPE.Random]
  if not randomCache or not next(randomCache) then
    return
  end
  local logic_ugc_random_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_random_recommend)
  local recommendModList = logic_ugc_random_recommend:GetRecommendModeIdList()
  if not recommendModList or #recommendModList <= 0 then
    self.ModCacheList[UGCMacros.ENUM_MODE_TYPE.Random] = nil
    for k, v in pairs(self.ModReqCacheMap) do
      if v[UGCMacros.ENUM_MODE_TYPE.Random] then
        self.ModReqCacheMap[k][UGCMacros.ENUM_MODE_TYPE.Random] = nil
      end
    end
    return
  end
  local needSaveModeIdMap = {}
  for _, id in ipairs(recommendModList) do
    needSaveModeIdMap[id] = 1
  end
  for mod_id, _ in pairs(randomCache) do
    if not needSaveModeIdMap[mod_id] then
      self.ModCacheList[UGCMacros.ENUM_MODE_TYPE.Random][mod_id] = nil
      if self.ModReqCacheMap[mod_id] and self.ModReqCacheMap[mod_id][UGCMacros.ENUM_MODE_TYPE.Random] then
        self.ModReqCacheMap[mod_id][UGCMacros.ENUM_MODE_TYPE.Random] = nil
      end
    end
  end
end
function Logic_UGC:OpenDetailUIByModId(modId, sourceModule, ExtendParameters)
  if not modId then
    log(bWriteLog and "Logic_UGC:OpenCommentMailDetailUI no modId")
    return
  end
  log(bWriteLog and "Logic_UGC:OpenCommentMailDetailUI modId:" .. tostring(modId))
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    ShowNotice(116009)
    return
  end
  if not Config_UGC.IsUGCUnlock() then
    local ugcEntry = Config_UGC.GetEntryData()
    ShowNotice(LocUtil.LocalizeResFormat(31028, ugcEntry.level_limit))
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modCache = LogicUGC:GetModByAllCache(modId)
  if modCache == nil or modCache.pub_mod_meta == nil then
    ShowNotice(64039)
    return
  end
  ExtendParameters = ExtendParameters or {}
  ExtendParameters.hideGameButton = false
  ExtendParameters.  UIManager.ShowUI(UIManager.UI_Config.UGCDetailMainPanel, Config_UGC.Config_UGC_DetailTabs, modCache.pub_mod_meta, ExtendParameters)
end
function Logic_UGC:GetGalleryParamConfig()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(Config_UGC.GalleryParamConfig, self.OnGetGalleryParamConfig)
end
function Logic_UGC.OnGetGalleryParamConfig(_, galleryParamConfig)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  Config_UGC.SetEntryData(galleryParamConfig)
  local logic_ugc_hot_theme = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_theme)
  logic_ugc_hot_theme:SetHotThemeGalleryParams(galleryParamConfig)
  local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
  logic_ugc_hot_page:SetHotThemeGalleryParams(galleryParamConfig)
  local LogicUGCExposure = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCExposure)
  LogicUGCExposure:SetExposureLogReqCD(galleryParamConfig.ExposureLogReqCD)
  local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
  LogicUGCCollectionList.ModCollectionCount = tonumber(galleryParamConfig.ModCollectionCount or 30)
  LogicUGCCollectionList.LikeModCollectionCount = tonumber(galleryParamConfig.LikeModCollectionCount)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SHARE_ENHANCE)
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  LogicUGCCenter:SetUGCCreatorOpenPass(galleryParamConfig.UGCCreatorOpenPass)
end
function Logic_UGC:ReqGetAllMetaKey()
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_get_all_meta_key_req()
end
function Logic_UGC:OnGetAllMetaKeyRsp(list)
  self.modKeyInfoList = list or {}
  self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Pub] = self.modKeyInfoList.pub_mod_list
  self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.History] = self.modKeyInfoList.history_play_list
  self.modKeyInfoList[UGCMacros.ENUM_MODE_TYPE.Collect] = self.modKeyInfoList.collections
  local LogicUGCSocial = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCSocial)
  LogicUGCSocial:InitCollectList()
  if list then
    if list.history_play_list then
      LogicUGCSocial:InitHistoryPlayList(list.history_play_list)
    end
    if list.author then
      local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
      LogicUGCAuthor:UpdateMineAuthorInfo(list.author)
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MINE_MODS)
end
function Logic_UGC:NewReqSearchMod(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_combined_search_mod_req(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
end
function Logic_UGC:NewReqSearchCollection(keyword, rank_type, tag_list, feature_tag_list)
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_combined_search_collection_req(keyword, rank_type, tag_list, feature_tag_list)
end
function Logic_UGC:NewReqRankModIndividuation()
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_personal_recommond_req()
end
function Logic_UGC:BatchGetModInfo(ModList, ReqListType, Callback, ExtraData)
  if not ModList or not next(ModList) then
    return
  end
  local ModNum = #ModList
  log(bWriteLog and string.format("[UGC] Logic_UGC:BatchGetModInfo, modList count: %d, listType: %s", ModNum, ReqListType))
  ExtraData = ExtraData or {}
  local ExistList, CacheList, ReqModList, BanList
  local bExist = false
  local ReqPlayList
  local ValidModList = {}
  for i, ModID in ipairs(ModList) do
    if 0 < ModID then
      if self.ModBanCache[ModID] then
        if ReqListType and UGCMacros.ENUM_RE_REQ[ReqListType] then
          table.insert(ValidModList, ModID)
        else
          BanList = BanList or {}
          table.insert(BanList, ModID)
        end
      else
        table.insert(ValidModList, ModID)
      end
    end
  end
  if ReqListType and ExtraData.bForce then
    ReqModList = ValidModList
    ReqPlayList = ValidModList
  else
    if ExtraData.bExportArray then
      CacheList = {}
    end
    ReqPlayList = {}
    ExistList = {}
    ReqModList = {}
    local bCheckMatchType = false
    if ReqListType and ReqListType == self.C_ModListTypes.UgcMatch then
      bCheckMatchType = true
    end
    local bSimple = ExtraData.bSimple
    for i, ModID in ipairs(ValidModList) do
      local ModInfo
      if bSimple then
        ModInfo = self:_GetModCache(ReqListType, ModID)
      else
        ModInfo = self:GetModByAllCache(ModID)
      end
      if ModInfo then
        bExist = true
        ExistList[ModID] = ModInfo
        if CacheList then
          table.insert(CacheList, ModInfo)
        end
        if bCheckMatchType then
          self:SetMatchCache(ModID, ModInfo)
        end
        table.insert(ReqPlayList, ModID)
      else
        local bIsReq = false
        if bSimple then
          bIsReq = self:_GetModIsReqByType(ModID, ReqListType)
        else
          bIsReq = self:GetModIsReq(ModID)
        end
        if not bIsReq then
          table.insert(ReqModList, ModID)
          table.insert(ReqPlayList, ModID)
        end
      end
    end
  end
  local NotReqModList
  if ReqListType then
    local ReqNum = #ReqModList
    local TypeParam = ExtraData.TypeParam
    local bSplit = ExtraData.bSplit
    if bExist then
      if Callback then
        if ReqNum == 0 then
          Callback(ExistList, ReqListType, TypeParam, false)
        else
          Callback(ExistList, ReqListType, TypeParam, true)
        end
      end
      if not ExtraData.bNotPostEvent then
        EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_BATCH, ReqListType, false, ExistList, TypeParam)
      end
    end
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    local ReqModInfoMaxNum = Config_UGC.ReqModInfoMaxNum
    if ReqNum > ReqModInfoMaxNum then
      local SplitReqModList = {}
      local Page = 1
      for i, ModID in ipairs(ReqModList) do
        if not SplitReqModList[Page] then
          SplitReqModList[Page] = {}
        end
        table.insert(SplitReqModList[Page], ModID)
        if bSplit and 1 < Page then
          NotReqModList = NotReqModList or {}
          table.insert(NotReqModList, ModID)
        end
        if ReqModInfoMaxNum <= #SplitReqModList[Page] then
          Page = Page + 1
        end
      end
      if bSplit then
        ReqModList = SplitReqModList[1]
        ReqNum = #ReqModList
        self:_BatchReqModInfo(Callback, ReqModList, ReqListType, TypeParam)
      else
        for i, v in ipairs(SplitReqModList) do
          self:_BatchReqModInfo(Callback, v, ReqListType, TypeParam)
        end
      end
    else
      self:_BatchReqModInfo(Callback, ReqModList, ReqListType, TypeParam)
    end
    if bWriteLog then
      log(bWriteLog and string.format("[UGC] Logic_UGC:BatchGetModInfo, ReqModList count: %d", ReqNum))
      if 0 < ReqNum and ReqNum ~= ModNum then
        log_tree("[UGC] Logic_UGC:BatchGetModInfo ReqModList = ", ReqModList)
      end
    end
  end
  log_tree(bWriteLog and "[UGC] Logic_UGC:BatchGetModInfo ModList = ", ModList)
  if ExtraData.bGetPlayReq and next(ReqPlayList) then
    self:OnGetModPlayerMatch(ReqPlayList)
  end
  if CacheList then
    return CacheList, ReqModList, NotReqModList, BanList
  else
    return ExistList, ReqModList, NotReqModList, BanList
  end
end
function Logic_UGC:GM_MarkAsRequesting(ModID, ReqListType)
  if not self.ModReqCacheMap then
    self.ModReqCacheMap = {}
  end
  if ReqListType then
    if not self.ModReqCacheMap[ModID] then
      self.ModReqCacheMap[ModID] = {}
    end
    self.ModReqCacheMap[ModID][ReqListType] = true
    log(bWriteLog and string.format("[UGC-GM] Marked mod %d as requesting for type '%s'", ModID, ReqListType))
    return
  end
  for listType, _ in pairs(self.C_ModListTypes) do
    if not self.ModReqCacheMap[ModID] then
      self.ModReqCacheMap[ModID] = {}
    end
    self.ModReqCacheMap[ModID][listType] = true
  end
  log(bWriteLog and string.format("[UGC-GM] Marked mod %d as requesting for ALL types", ModID))
end
function Logic_UGC:GM_ClearRequestingMark(ModID, ReqListType)
  if not self.ModReqCacheMap then
    log(bWriteLog and "[UGC-GM] No request cache to clear")
    return
  end
  if ReqListType then
    if self.ModReqCacheMap[ModID] then
      self.ModReqCacheMap[ModID][ReqListType] = nil
    end
    log(bWriteLog and string.format("[UGC-GM] Cleared requesting mark for mod %d (type: %s)", ModID, ReqListType))
    return
  end
  if self.ModReqCacheMap[ModID] then
    self.ModReqCacheMap[ModID] = nil
    if self.ModReqMatchList[ModID] then
      self.ModReqMatchList[ModID] = nil
    end
  end
  log(bWriteLog and string.format("[UGC-GM] Cleared all requesting marks for mod %d", ModID))
end
function Logic_UGC:GM_CheckRequestingStatus(ModID)
  if not self.ModReqCacheMap or not self.ModReqCacheMap[ModID] then
    return "Not marked as requesting"
  end
  local status = {}
  for listType, isRequesting in pairs(self.ModReqCacheMap[ModID]) do
    if isRequesting then
      table.insert(status, string.format("Requesting for: %s", listType))
    end
  end
  if #status == 0 then
    return "Not currently marked as requesting"
  end
  return table.concat(status, "\n")
end
function Logic_UGC:_BatchReqModInfo(Callback, ReqModList, ReqListType, TypeParam)
  if not ReqModList or not next(ReqModList) then
    return
  end
  if not self.ModReqCacheMap then
    self.ModReqCacheMap = {}
  end
  for i, ModID in ipairs(ReqModList) do
    if not self.ModReqCacheMap[ModID] then
      self.ModReqCacheMap[ModID] = {}
    end
    self.ModReqCacheMap[ModID][ReqListType] = TypeParam or true
    if ReqListType == UGCMacros.ENUM_MODE_TYPE.UgcMatch then
      self.ModReqMatchList[ModID] = true
    end
  end
  local FixedTypeParam = {ReqList = ReqModList, ClientParam = TypeParam}
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_pub_mod_info_batch_req(ReqModList, ReqListType, FixedTypeParam):Then(function(ErrCode, MetaList, ListType, TypeParam, FilterOfflineModList)
    local ClientParam
    if TypeParam and type(TypeParam) == "table" then
      ClientParam = TypeParam.ClientParam
    else
      ClientParam = TypeParam
    end
    if Callback then
      Callback(MetaList, ListType, ClientParam, false, FilterOfflineModList)
    end
  end)
end
function Logic_UGC:OnModInfoBatchRsp(modList, listType, type_para, filter_offline_mod_list)
  listType = listType or UGCMacros.ENUM_MODE_TYPE.Pub
  if not self.ModCacheList[listType] then
    self.ModCacheList[listType] = {}
  end
  local ClientParams = {}
  if type_para and type(type_para) == "table" then
    ClientParams[listType] = type_para.ClientParam
    if type_para.ReqList and type(type_para.ReqList) == "table" then
      local RspModList = modList or {}
      for i, ModID in ipairs(type_para.ReqList) do
        if not RspModList[ModID] then
          if not self.ModBanCache[ModID] then
            self.ModBanCache[ModID] = true
            log(bWriteLog and string.format("[UGC] Logic_UGC:OnModInfoBatchRsp, Mod %s Is Ban, listType: %s", tostring(ModID), listType))
          end
          if self.ModReqCacheMap[ModID] then
            self.ModReqCacheMap[ModID] = nil
            log(bWriteLog and "[UGC] Logic_UGC:OnModInfoBatchRsp, Clear ModReqCacheMap, ModID: " .. tostring(ModID))
            if self.ModReqMatchList[ModID] then
              self.ModReqMatchList[ModID] = nil
            end
          end
        end
      end
    end
  else
    ClientParams[listType] = type_para
  end
  local ReqListTypes = {}
  ReqListTypes[listType] = modList
  local Cache = self.ModCacheList[listType]
  local bIsDirty = false
  if modList then
    local TableUtil = require("common.table_util")
    TableUtil.OverrideTable(Cache, modList)
    bIsDirty = next(modList) and true or false
    if self.ModReqCacheMap then
      for ModID, Meta in pairs(modList) do
        local ReqCache = self.ModReqCacheMap[ModID]
        if ReqCache then
          for ReqListType, ClientParam in pairs(ReqCache) do
            if ReqListType ~= listType then
              if not ReqListTypes[ReqListType] then
                ReqListTypes[ReqListType] = {}
              end
              ReqListTypes[ReqListType][ModID] = Meta
              ClientParams[ReqListType] = ClientParam
            end
          end
          self.ModReqCacheMap[ModID] = nil
          if self.ModReqMatchList[ModID] then
            self.ModReqMatchList[ModID] = nil
          end
        end
      end
    end
  end
  log(bWriteLog and string.format("[UGC] Logic_UGC:OnModInfoBatchRsp, listType: %s, bIsDirty: %s", listType, tostring(bIsDirty)))
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local logic_ugc_random_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_random_recommend)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  local Logic_UGC_Season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
  local Logic_UGC_Personalization = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_personalization)
  local logic_ugc_match_tab = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_match_tab)
  local logic_ugc_hot_author = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_author)
  local logic_ugc_new_map = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_map)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local logic_ugc_intention = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_intention)
  local logic_ugc_mod_play_history = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mod_play_history)
  for ReqListType, MetaList in pairs(ReqListTypes) do
    local ClientParam = ClientParams[ReqListType]
    print(bWriteLog and "[edward] Logic_UGC:OnModInfoBatchRsp, Real ReqListType = ", ReqListType)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_BATCH, ReqListType, bIsDirty, MetaList, ClientParam, filter_offline_mod_list)
    LogicUGCResManager:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    logic_ugc_random_recommend:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    LogicUGCMulti:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    logic_ugc_search:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    Logic_UGC_Season:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    Logic_UGC_Personalization:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    logic_ugc_match_tab:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    logic_ugc_hot_author:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    logic_ugc_new_map:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    PlayerStatusMgr:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    logic_ugc_intention:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
    logic_ugc_mod_play_history:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
  end
end
function Logic_UGC:OnGetGalleryRecommendIdListRsp(modIdList)
  self.recommendList = modIdList or {}
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_RECOMMEND_ID_LIST)
end
function Logic_UGC:OnGetGalleryBannerRsp(bannerMap, banner_pic_list)
  self.recommendBannerList = bannerMap or {}
  self.recommendBannerPicList = banner_pic_list or {}
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_BANNER_LIST)
end
function Logic_UGC:OnGetResultRecommendRsp(topn, data)
  self.recommendResultList = data or {}
  self.recommendResultListCount = topn
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_RESULT_RECOMMEND_ID_LIST)
end
function Logic_UGC:send_ugc_promotion_game_result_req(req_type)
  if self:CheckPromotionDataValid() then
    log(bWriteLog and "Logic_UGC:send_ugc_promotion_game_result_req dataValid no need to req")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_RESULT_PROMOTION_ID_LIST, self.promotionList)
    return
  end
  self.PromotionShowIndex = 0
  log(bWriteLog and "Logic_UGC:send_ugc_promotion_game_result_req dataValid need to req")
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_promotion_game_result_req(req_type)
end
function Logic_UGC:OnGetPromotionRecommendRsp(data, extra_info)
  log_tree("Logic_UGC:OnGetPromotionRecommendRsp data =", data)
  local TimeUtil = require("client.common.time_util")
  self.PromotionDataTimeStamp = TimeUtil.GetServerTimeInSec()
  self.promotionList = data
  self.trans_info = extra_info and extra_info.trans_info or {}
  log_tree("Logic_UGC:OnGetPromotionRecommendRsp extra_info = ", extra_info)
  self.gallery_rec_first_x = extra_info and extra_info.gallery_rec_first_x or 0
  self.gallery_rec_every_y = extra_info and extra_info.gallery_rec_every_y or 0
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_RESULT_PROMOTION_ID_LIST, data)
end
function Logic_UGC:OnGetModPlayerMatch(modid_list)
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  logic_ugc_mode:BatchModPlayerReq(modid_list)
end
function Logic_UGC:OnGetPromotionRecommendList()
  return self.promotionList or nil
end
function Logic_UGC:SetPromotionShowIndex(index)
  log(bWriteLog and "Logic_UGC:SetPromotionShowIndex index = " .. tostring(index))
  self.PromotionShowIndex = index
end
function Logic_UGC:RemoveDuplicatesPromotionList(SearchList)
  if not SearchList or not next(SearchList) then
    log(bWriteLog and "Logic_UGC:RemoveDuplicatesPromotionList not SearchList")
    return
  end
  if not self.promotionList or not next(self.promotionList) then
    log(bWriteLog and "Logic_UGC:RemoveDuplicatesPromotionList not self.promotionList")
    return
  end
  for index, PromotionModID in ipairs(self.promotionList) do
    for i, SearchModID in ipairs(SearchList) do
      if SearchModID == PromotionModID then
        table.remove(self.promotionList, index)
        break
      end
    end
  end
  log_tree("Logic_UGC:RemoveDuplicatesPromotionList self.promotionList:", self.promotionList)
end
function Logic_UGC:ReqModShareCreate(modID, active)
  if not modID then
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_set_share_mod_req(modID, active)
end
function Logic_UGC:ModShareCreateRsp(modID, active)
  if not modID then
    return
  end
  log(bWriteLog and "Logic_UGC:ModShareCreateRsp, modID: " .. modID .. ", share_switch: " .. active)
  local modInfo = self:GetModByAllCache(modID)
  if modInfo then
    modInfo.pub_mod_meta.setting.share_switch = active
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_SHARE_MOD, modInfo.pub_mod_meta)
end
function Logic_UGC:ReqTextFilter(text)
  if not text or text == "" then
    return
  end
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_lobby_text_filter_req(text)
end
function Logic_UGC:SetAutoSendMomentModID(ModID)
  self.AutoSendMomentModIDMap[ModID] = true
  local ModCache = self:GetModByAllCache(ModID)
  if ModCache then
    self:AutoSendMoment(ModID, ModCache.pub_mod_meta)
  else
    self:BatchGetModInfo({ModID}, UGCMacros.ENUM_MODE_TYPE.MomentDetailComment, function(MetaList, ListType, Param, bUseCache, FilterOfflineModList)
      self:OnAutoSendMoment(MetaList, ListType, Param, bUseCache, FilterOfflineModList)
    end)
  end
end
function Logic_UGC:OnAutoSendMoment(ModList, ListType)
  if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.MomentDetailComment) then
    return
  end
  log(bWriteLog and "Logic_UGC:OnAutoSendMoment")
  if not ModList then
    return
  end
  local ModID, ModInfo = next(ModList)
  if not ModID then
    return
  end
  self:AutoSendMoment(ModID, ModInfo.pub_mod_meta)
end
function Logic_UGC:AutoSendMoment(ModID, ModInfo)
  log(bWriteLog and "Logic_UGC:AutoSendMoment ModID:" .. tostring(ModID))
  if not self.AutoSendMomentModIDMap[ModID] then
    return
  end
  self.AutoSendMomentModIDMap[ModID] = nil
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  local CanOpenMoment = logic_moment.IsCanOpenSelfMoment(false)
  log(bWriteLog and "Logic_UGC:AutoSendMoment, CanOpenMoment:" .. tostring(CanOpenMoment))
  if not CanOpenMoment then
    return
  end
  local modInfo = ModInfo
  local authority = 0
  local url = ""
  local video_url = ""
  local itemName = LocUtil.LocalizeResFormat(69417)
  local content = itemName
  local domain_id = 0
  local moment_macro = require("client.slua.logic.moment.moment_macro")
  local source = moment_macro.ENUM_MOMENT_SHARE_SOURCE_TYPE.UGC_WORK_SQUARE
  local useSquare = 0
  local useClub = 0
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local cover_url = Util_UGC.GetCoverImageUrl(modInfo.setting, modInfo.base.template_id, false)
  local otherinfo = {
    ugc_mod_id = modInfo.mod_id,
    ugc_  }
  local curUseBgId
  local client_trans = {
    data_mod_id = modInfo.mod_id,
    data_base_uid = modInfo.base.uid,
    data_desc = modInfo.setting.desc,
    data_mod_name = modInfo.setting.name,
    data_mod_tag = modInfo.setting.tag
  }
  local is_wow_moment = true
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  logic_moment.SendMomentReq(authority, url, video_url, content, domain_id, source, useSquare, useClub, otherinfo, curUseBgId, client_trans, is_wow_moment)
end
function Logic_UGC:ReqGetPubMeta(modID)
  if not modID then
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_get_pub_meta_req(modID)
end
function Logic_UGC:OnGetPubMetaRsp(mod_id, meta)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_PUBMETA, mod_id, meta)
end
function Logic_UGC:SetUGCDebugID(debug_id_table)
end
function Logic_UGC:GetUGCDebugID()
  local cfg = CDataTable.GetTable("UGCDebugIDConfig")
  local t = {}
  if cfg == nil then
    return t
  end
  for k, v in pairs(cfg) do
    t[k] = v
  end
  log_tree(bWriteLog and "Logic_UGC:GetUGCDebugID ", t)
  return t
end
function Logic_UGC:GetAssetPublishUnixstamp(AssetId)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if gTestDelayPublish and AssetId == 3101054 then
    local TestDate = "2025-03-01 02:00:00"
    local TimeUtil = require("client.common.time_util")
    local T = TimeUtil.TimeStringToUnixstamp(TestDate, false)
    return T
  end
  if self.AssetID2PublishDate == nil then
    print(bWriteLog and "Logic_UGC:GetAssetPublishUnixStamp Construct the metadata for the first time.")
    local TimeUtil = require("client.common.time_util")
    self.AssetID2PublishDate = {}
    local delayPublish
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsBLUEHOLE() then
      delayPublish = CDataTable.GetTable("UGCDelayPublishConfigBluehole")
    else
      delayPublish = CDataTable.GetTable("UGCDelayPublishConfig")
    end
    if delayPublish then
      for idx, pubInfo in pairs(delayPublish) do
        if pubInfo.OpenDate then
          local T = TimeUtil.TimeStringToUnixstamp(pubInfo.OpenDate, false)
          local FormattedDate = os.date("%Y-%m-%d %H:%M:%S", T)
          self.AssetID2PublishDate[pubInfo.AssetID] = math.floor(T)
          print(bWriteLog and "Logic_UGC:GetAssetPublishUnixStamp AssetID = " .. tostring(pubInfo.AssetID) .. " " .. FormattedDate)
        end
      end
    end
  end
  return self.AssetID2PublishDate[AssetId]
end
function Logic_UGC:InitExpireDates()
  print(bWriteLog and "Logic_UGC:GetAssetPublishUnixStamp Construct the metadata for the first time.")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local TimeUtil = require("client.common.time_util")
  self.AssetID2ExpiredDate = {}
  local delayPublish = CDataTable.GetTable("UGCDelayPublishConfig")
  if delayPublish then
    for idx, pubInfo in pairs(delayPublish) do
      local TimeRange = {}
      if pubInfo.OpenDate then
        local T = TimeUtil.TimeStringToUnixstamp(pubInfo.OpenDate, false)
        TimeRange.OpenTime = T
      end
      if pubInfo.ExpiredDate and pubInfo.ExpiredDate ~= "" then
        local T = TimeUtil.TimeStringToUnixstamp(pubInfo.ExpiredDate, false)
        TimeRange.ExpiredTime = T
        local FormattedDate = os.date("%Y-%m-%d %H:%M:%S", T)
        print(bWriteLog and "Logic_UGC:GetExpiredTimeUnixstamp AssetID = " .. tostring(pubInfo.AssetID) .. " " .. FormattedDate)
      end
      self.AssetID2ExpiredDate[pubInfo.AssetID] = TimeRange
    end
  end
end
function Logic_UGC:GetExpiredTimeUnixstamp(AssetId)
  if gTestItemExpiredItem and AssetId == 3101054 then
    local TestDate = "2024-05-01 02:00:00"
    local TimeUtil = require("client.common.time_util")
    local T = TimeUtil.TimeStringToUnixstamp(TestDate, false)
    return T
  end
  if self.AssetID2ExpiredDate == nil then
    self:InitExpireDates()
  end
  if self.AssetID2ExpiredDate[AssetId] then
    return self.AssetID2ExpiredDate[AssetId].ExpiredTime
  end
end
function Logic_UGC:GetExpiredTimeInStr(AssetId)
  local TimeUtil = require("client.common.time_util")
  local T = self:GetExpiredTimeUnixstamp(AssetId)
  if T then
    local nowTime = TimeUtil.GetServerTimeInSec()
    if T > nowTime then
      return LocUtil.LocalizeResFormat(8500938, TimeUtil.GetLeftTimeStr(T))
    else
      return LocUtil.GetLocalizeResStr(8500939)
    end
  end
end
function Logic_UGC:GetDelayPublishTime(modInfo)
  if modInfo == nil then
    print(bWriteLog and "Logic_UGC:GetDelayPublishTime modInfo is nil")
    return false
  end
  if modInfo.stat == nil then
    return true
  end
  if modInfo.stat.AllObjectEditInfo == nil then
    return true
  end
  local objEditInfo = modInfo.stat.AllObjectEditInfo
  if objEditInfo == nil then
    print(bWriteLog and "Logic_UGC:GetDelayPublishTime objEditInfo is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local delayTime
  for _, objInfo in pairs(objEditInfo) do
    local num = objInfo[3]
    local assetId = objInfo[1]
    if num ~= nil and assetId ~= nil and 0 < num then
      print(bWriteLog and "Logic_UGC:GetDelayPublishTime num = " .. tostring(num) .. " ,assetId = " .. tostring(assetId))
      local t = self:GetAssetPublishUnixstamp(assetId)
      if t and nowTime < t and (delayTime == nil or delayTime < t) then
        delayTime = t
      end
    end
  end
  if delayTime then
    return delayTime
  end
  return false
end
function Logic_UGC:GetExpiredTime(modInfo)
  if modInfo == nil then
    print(bWriteLog and "Logic_UGC:GetExpiredTime modInfo is nil")
    return false
  end
  if gTestItemExpiredUI then
    return 2333
  end
  if modInfo.stat == nil then
    return false
  end
  if modInfo.stat.AllObjectEditInfo == nil then
    return false
  end
  local objEditInfo = modInfo.stat.AllObjectEditInfo
  if objEditInfo == nil then
    print(bWriteLog and "Logic_UGC:GetExpiredTime objEditInfo is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local delayTime
  for _, objInfo in pairs(objEditInfo) do
    local num = objInfo[3]
    local assetId = objInfo[1]
    if num ~= nil and assetId ~= nil and 0 < num then
      print(bWriteLog and "Logic_UGC:GetExpiredTime num = " .. tostring(num) .. ", assetId = " .. tostring(assetId))
      local t = self:GetExpiredTimeUnixstamp(assetId)
      if t and nowTime > t and (delayTime == nil or delayTime > t) then
        delayTime = t
      end
    end
  end
  if delayTime then
    return delayTime
  end
  return false
end
function Logic_UGC:GetExpiredAssetIds()
  if self.AssetID2ExpiredDate == nil then
    self:InitExpireDates()
  end
  local Ret = {}
  local TimeUtil = require("client.common.time_util")
  local NowTime = TimeUtil.GetServerTimeInSec()
  if CGameMode and CGameMode.ServerStartTime and CGameMode.ServerStartTime ~= 0 then
    local ServerStartTime = CGameMode.ServerStartTime
    if ServerStartTime then
      print(bWriteLog and "Logic_UGC:GetExpiredAssetIds ServerStartTime " .. tostring(ServerStartTime))
      NowTime = ServerStartTime
    end
  end
  for assetId, TimeRange in pairs(self.AssetID2ExpiredDate) do
    local ExpiredTime = TimeRange.ExpiredTime
    local OpenTime = TimeRange.OpenTime
    local bTimeBefore = OpenTime ~= nil and OpenTime ~= 0 and NowTime < OpenTime
    local bTimeAfter = ExpiredTime ~= nil and ExpiredTime ~= 0 and NowTime > ExpiredTime
    if bTimeBefore or bTimeAfter then
      print(bWriteLog and "Logic_UGC:GetExpiredAssetIds Exipired " .. tostring(assetId))
      table.insert(Ret, assetId)
    else
      print(bWriteLog and "Logic_UGC:GetExpiredAssetIds Not Expired " .. tostring(assetId))
    end
  end
  return Ret
end
function Logic_UGC:SetUGCModIngameAutoStartMatch()
  self.bUGCAutoMatch = true
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local bEnterGameFromMainCity = Lobby_Main_City_Enter.bEnterGameFromMainCity
  log(bWriteLog and "Logic_UGC:SetUGCModIngameAutoStartMatch bEnterGameFromMainCity = " .. tostring(bEnterGameFromMainCity))
  Lobby_Main_City_Enter.bEnterGameFromMainCity = false
  Lobby_Main_City_Enter.bIgnoreAutoEnterMainCity = true
end
function Logic_UGC:CheckStartMatch()
  if IsWoWEditor then
    return
  end
  if self.bUGCAutoMatch then
    self.bUGCAutoMatch = false
    self:AddTimer(5, function()
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_MATCH_UGC_AUTOMATCH)
    end)
  end
end
function Logic_UGC:GetClientAutoTransEnabled()
  print(bWriteLog and "Logic_UGC:GetClientAutoTransEnabled")
  return self:GetAllAutoTransEnabled()
end
function Logic_UGC:SetClientAutoTransEnabled(bFlag, bSkipSaveToFile)
  print(bWriteLog and "Logic_UGC:SetClientAutoTransEnabled " .. tostring(bFlag))
  self:SetAlltAutoTransEnabled(bFlag)
end
function Logic_UGC:GetClientOutsideAutoTransEnabled()
  print(bWriteLog and "Logic_UGC:GetClientOutsideAutoTransEnabled")
  return self:GetAllAutoTransEnabled()
end
function Logic_UGC:SetClientOutsideAutoTransEnabled(bFlag)
  print(bWriteLog and "Logic_UGC:SetClientOutsideAutoTransEnabled " .. tostring(bFlag))
  self:SetAlltAutoTransEnabled(bFlag)
end
function Logic_UGC:CheckOutsideAutoTransShowTips()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local LoadTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCOutsideAutoTransTips)
  local LoadTable2 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCAutoTranslateInfo) or {}
  if LoadTable2 and LoadTable2.NeverShowTips then
    return false
  end
  if LoadTable ~= nil and LoadTable.lastShowTipsTime ~= 0 then
    local time_util = require("client.common.time_util")
    if time_util.IsSameDay(time_util.GetServerTimeInSec(), LoadTable.lastShowTipsTime or 0) then
      log_warning(bWriteLog and "[v_chenxxue] Logic_UGC:CheckOutsideAutoTransShowTips have show")
      return false
    end
  end
  log_warning(bWriteLog and "[v_chenxxue] Logic_UGC:CheckOutsideAutoTransShowTips can show")
  return true
end
function Logic_UGC:SaveOutsideAutoTransShowTipsTime()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SaveTable = {
    lastShowTipsTime = FuncUtil.GetServerTimeInSec(),
    NewEnterWOWAutoTransTips = true
  }
  log_warning(bWriteLog and "[v_chenxxue]Logic_UGC:SaveOutsideAutoTransShowTipsTime " .. tostring(SaveTable.lastShowTipsTime))
  PlayerPrefsSystem.SaveTableToFile_N(SaveTable, PlayerPrefsSystem.ePlayerPrefsType.eUGCOutsideAutoTransTips)
end
function Logic_UGC:CheckShowOutsideAutoTranslateCheckWindow()
  local bshow = false
  print(bWriteLog and "Logic_UGC:CheckShowOutsideAutoTranslateCheckWindow")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local publishRegion = Client.GetPublishRegion()
  if publishRegion == PublishRegionMacros.BLUEHOLE then
    return bshow
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bIsInHomeMod = PlanPH_GamePlay_Tools and PlanPH_GamePlay_Tools.IsPHomeMode()
  if UIManager.IsUIShow(UIManager.UI_Config.ui_chat_main) or bIsInHomeMod then
    return bshow
  end
  local IsOpenTips
  local Val = self:GetClientOutsideAutoTransEnabled()
  if Val ~= nil then
    IsOpenTips = self:CheckOutsideAutoTransShowTips()
  end
  if Val == nil or Val == false and IsOpenTips then
    bshow = true
  end
  return bshow
end
function Logic_UGC:ShowOutsideAutoTranslateCheckWindow(data, FinishCallback)
  print(bWriteLog and "Logic_UGC:ShowOutsideAutoTranslateCheckWindow")
  if self:CheckOutsideAutoTransShowTips() then
    local LogicChatChannelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
    local FirstLanName = ""
    for i, v in ipairs(LogicChatChannelWorld.language_data_list) do
      if type(v.id) == type(DataMgr.FirstSecondLanguage[1]) and v.id == DataMgr.FirstSecondLanguage[1] then
        FirstLanName = v.langName
        break
      end
    end
    local configs = CDataTable.GetTable("BlueHoleMatchLang")
    for _, v in pairs(configs) do
      if type(v.id) == type(DataMgr.FirstSecondLanguage[1]) and v.id == DataMgr.FirstSecondLanguage[1] then
        FirstLanName = v.langName
        break
      end
    end
    local MsgTitle = LocUtil.GetLocalizeResStr(67953)
    local MsgContent = LocUtil.LocalizeResFormat(67954)
    local CancelTip = LocUtil.GetLocalizeResStr(8902105)
    local GoBindTip = LocUtil.GetLocalizeResStr(38606)
    local ExtraData = {
      isShowCheckBox = true,
      checkBoxText = LocUtil.LocalizeResFormat(67955)
    }
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    CommonMsgBoxMgr.Show(2, MsgTitle, MsgContent, function(bIsCheck)
      print(bWriteLog and "CreativeTranslateSubsystem:OnInitGame IsAutoTranslateOpen Confirm  " .. tostring(bIsCheck))
      self:SetClientOutsideAutoTransEnabled(true)
      self:SaveOutsideAutoTransShowTipsTime()
      ShowNotice(LocUtil.LocalizeResFormat(67956, FirstLanName))
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_Click_OutsideTranslate, 1, "ShowOutsideAutoTransTips")
      if FinishCallback ~= nil then
        FinishCallback()
      end
      if bIsCheck then
        local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        local SaveTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCAutoTranslateInfo) or {}
        SaveTable.NeverShowTips = true
        PlayerPrefsSystem.SaveTableToFile_N(SaveTable, PlayerPrefsSystem.ePlayerPrefsType.eUGCAutoTranslateInfo)
      end
    end, function(bIsCheck)
      print(bWriteLog and "CreativeTranslateSubsystem:OnInitGame IsAutoTranslateOpen Cancel " .. tostring(bIsCheck))
      self:SetClientOutsideAutoTransEnabled(false)
      self:SaveOutsideAutoTransShowTipsTime()
      ShowNotice(LocUtil.GetLocalizeResStr(67957))
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_Click_OutsideTranslate, 0, "ShowOutsideAutoTransTips")
      if FinishCallback ~= nil then
        FinishCallback()
      end
      if bIsCheck then
        local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        local SaveTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCAutoTranslateInfo) or {}
        SaveTable.NeverShowTips = true
        PlayerPrefsSystem.SaveTableToFile_N(SaveTable, PlayerPrefsSystem.ePlayerPrefsType.eUGCAutoTranslateInfo)
      end
    end, GoBindTip, CancelTip, ExtraData)
    return true
  else
    print(bWriteLog and "Logic_UGC:ShowOutsideAutoTranslateCheckWindow Today it has been show.")
    return false
  end
end
function Logic_UGC:SetOutsideNewPoint()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({eUGCOutsideFirsPoint = true}, PlayerPrefsSystem.ePlayerPrefsType.eUGCOutsideFirsPoint)
end
function Logic_UGC:ShowAutoTranslateCheckWindow(FinishCallback)
  print(bWriteLog and "Logic_UGC:ShowAutoTranslateCheckWindow")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return false
  end
  local Val
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local LoadTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCAutoTranslateInfo) or {}
  log_tree("PlayerPrefsSystem.ePlayerPrefsType.eUGCAutoTranslateInfo", LoadTable)
  Val = LoadTable.bAutoTranslate
  if Val == nil then
    return self:ShowOutsideAutoTranslateCheckWindow(nil, FinishCallback)
  end
  return false
end
function Logic_UGC:ClearAutoTransFlag()
  print(bWriteLog and "Logic_UGC:ClearAutoTransFlag")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SaveTable = {}
  PlayerPrefsSystem.SaveTableToFile_N(SaveTable, PlayerPrefsSystem.ePlayerPrefsType.eUGCAutoTranslateInfo)
end
function Logic_UGC:ClearOutsideAutoTransFlag()
  print(bWriteLog and "Logic_UGC:ClearAutoTransFlag")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SaveTable = {}
  PlayerPrefsSystem.SaveTableToFile_N(SaveTable, PlayerPrefsSystem.ePlayerPrefsType.eUGCOutsideAutoTranslateInfo)
  log(bWriteLog and "[v_chenxxue]Logic_UGC:ClearOutsideAutoTransFlag  eUGCOutsideAutoTranslateInfo:   " .. tostring(SaveTable.bOutsideAutoTranslate))
end
function Logic_UGC:CheckIsWOWSeasonFrozen(modInfo)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if modInfo and modInfo.lock_online_state and modInfo.lock_online_state == 1 then
    if modInfo.base.state_reason == Config_UGC.Config_UGC_FrozenID.WOWSeason then
      log(bWriteLog and "[v_yibxu] UGCDetailInfoSubPanel:InitRightUp  modId = " .. modInfo.mod_id .. "is WOWSEASON frozen")
      return true
    else
      log(bWriteLog and "[v_yibxu] UGCDetailInfoSubPanel:InitRightUp  modId = " .. modInfo.mod_id .. "is ONLINE frozen")
      return false
    end
  else
    return false
  end
end
function Logic_UGC:IsWOWOpen()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local ugcEntry = Config_UGC.GetEntryData()
  if Config_UGC.IsUGCReleased() then
    if self:IsLevelLock(ugcEntry.level_limit) then
      return false, ugcEntry.level_limit
    else
      return true
    end
  else
    return false
  end
end
function Logic_UGC:IsLevelLock(cfgLevel)
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
  log(bWriteLog and "Logic_UGC:IsLevelLock bLevelUnlockSwitchOpen = " .. tostring(bLevelUnlockSwitchOpen))
  if not bLevelUnlockSwitchOpen then
    return false
  end
  return cfgLevel > DataMgr.roleData.level
end
function Logic_UGC:GetDownloadAward()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if not PufferDownloader.DownloadRewardCfg[PufferConst.Enum_BundleID.WOWResAward] then
    return nil
  end
  log_tree("Logic_UGC:GetDownloadAward() ", PufferDownloader.DownloadRewardCfg[PufferConst.Enum_BundleID.WOWResAward])
  return PufferDownloader.DownloadRewardCfg[PufferConst.Enum_BundleID.WOWResAward]
end
function Logic_UGC:GetDownloadAwardList()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if self:GetDownloadAward() then
    log_tree("[v_chenxxue]Logic_UGC:GetDownloadAward() DownloadAward = ", PufferDownloader.DownloadRewardCfg[PufferConst.Enum_BundleID.WOWResAward])
    local AwardData = PufferDownloader.DownloadRewardCfg[PufferConst.Enum_BundleID.WOWResAward]
    local Awardlist = {}
    if AwardData.itemid1 > 0 then
      local arrayItem1 = {}
      arrayItem1.itemid = AwardData.itemid1
      arrayItem1.count = AwardData.itemcnt1
      table.insert(Awardlist, arrayItem1)
    end
    if 0 < AwardData.itemid2 then
      local arrayItem2 = {}
      arrayItem2.itemid = AwardData.itemid2
      arrayItem2.count = AwardData.itemcnt2
      table.insert(Awardlist, arrayItem2)
    end
    if 0 < AwardData.itemid3 then
      local arrayItem3 = {}
      arrayItem3.itemid = AwardData.itemid3
      arrayItem3.count = AwardData.itemcnt3
      table.insert(Awardlist, arrayItem3)
    end
    log_tree("[v_chenxxue]Logic_UGC:GetDownloadAward() Awardlist ", Awardlist)
    return Awardlist
  end
  log(bWriteLog and "[v_chenxxue]Logic_UGC:GetDownloadAwardList() DownloadAward is nil")
  return nil
end
function Logic_UGC:CheckModAdjust(modInfo)
  local bAdjust = false
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Play_Cnt = Util_UGC.GetModPlayCount(modInfo)
  local game_result_finish_cnt = modInfo.game_result_finish_cnt or 0
  log(bWriteLog and "[v_yibxu] Logic_UGC:CheckModAdjust Play_Cnt = " .. Play_Cnt .. " game_result_finish_cnt = " .. game_result_finish_cnt)
  local state = modInfo.base.state_release
  if state == Config_UGC.E_PublishState.Published and 100 < Play_Cnt and game_result_finish_cnt <= 0 then
    bAdjust = true
  end
  return bAdjust
end
function Logic_UGC:SetPubModRedDotData(mod_id, bShowReddot)
  if not mod_id then
    return
  end
  log(bWriteLog and "Logic_UGC:SetPubModRedDotData mod_id = " .. mod_id .. " bShowReddot = " .. tostring(bShowReddot))
  self.PubModRedDotData[mod_id] = bShowReddot
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.PubModRedDotData, PlayerPrefsSystem.ePlayerPrefsType.eUGCPubModRedDotData)
end
function Logic_UGC:GetPubModRedDotData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local RedDotData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCPubModRedDotData)
  self.PubModRedDotData = RedDotData or {}
  log_tree("Logic_UGC:GetPubModRedDotData self.PubModRedDotData = ", self.PubModRedDotData)
end
function Logic_UGC:CheckShowRedDot()
  local bRedDot = false
  self:GetPubModRedDotData()
  for key, value in pairs(self.PubModRedDotData) do
    if value == true then
      bRedDot = true
      break
    end
  end
  log(bWriteLog and "Logic_UGC:CheckShowRedDot bRedDot = " .. tostring(bRedDot))
  return bRedDot
end
function Logic_UGC:SetButtonAnimState(state)
  self.bUGCButtonAnim = state
end
function Logic_UGC:GetButtonAnimState()
  return self.bUGCButtonAnim
end
function Logic_UGC:UpdateCreatorTips(author_info)
  local TableUtil = require("common.table_util")
  local ShowId = -1
  if not author_info then
    log(bWriteLog and "Logic_UGC:UpdateCreatorTips author_info is nil")
    return
  end
  if not author_info.caring_notify_bitmap or not next(author_info.caring_notify_bitmap) then
    log(bWriteLog and "Logic_UGC:UpdateCreatorTips author_info.caring_notify_bitmap is nil")
    return
  end
  log_tree("Logic_UGC:UpdateCreatorTips author_info = ", author_info)
  local ShowList = {}
  local CreatorStateCfg = CDataTable.GetTable("CreatorCareTipCfg")
  for k, v in pairs(CreatorStateCfg) do
    if k ~= 6 and k ~= self.PubModSucceed then
      local bShow = self:CheckShowTips(author_info.caring_notify_bitmap[1], k)
      if bShow then
        table.insert(ShowList, v)
      end
    end
  end
  if TableUtil.CountTable(ShowList) > 0 then
    table.sort(ShowList, function(a, b)
      return a.Sort < b.Sort
    end)
    ShowId = ShowList[1].Id
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_CREATOR_STATE, ShowId)
  local isLevelUp = ShowId == 1
  if isLevelUp then
    local curLevel = DataMgr.ugc_author_info.new_level or 0
    local levelCfgTable = CDataTable.GetTable("UGCAuthorLevelUpTipsCfg")
    local levelCfgs = {}
    for _, value in pairs(levelCfgTable) do
      table.insert(levelCfgs, value)
    end
    table.sort(levelCfgs, function(a, b)
      return a.ID < b.ID
    end)
    local max_anim_level = levelCfgs[#levelCfgs].ID
    local targetCfg
    if curLevel >= max_anim_level then
      targetCfg = levelCfgs[#levelCfgs]
    else
      for i, cfg in ipairs(levelCfgs) do
        if curLevel < cfg.ID then
          targetCfg = levelCfgs[i - 1]
          break
        end
      end
    end
    if targetCfg then
      self.author_level_up_data = targetCfg
    end
  end
end
function Logic_UGC:NotifyCreatorStateChange(notify_type)
  log(bWriteLog and "Logic_UGC:NotifyCreatorStateChange")
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_clear_caring_notify_req(notify_type)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC.bFristBecomeAuthor = false
end
function Logic_UGC:CheckShowTips(bitmap, tipId)
  log(bWriteLog and "Logic_UGC:CheckShowTips bitmap = " .. tostring(bitmap) .. " tipId = " .. tostring(tipId))
  if not bitmap then
    return false
  end
  local cur_interact_bits = bitmap or 0
  return cur_interact_bits & 1 << tipId - 1 ~= 0
end
function Logic_UGC:CheckShowPubSuccess(tipId, caring_last_publish_mod)
  if tipId ~= self.PubModSucceed then
    return
  end
  if not caring_last_publish_mod then
    log(bWriteLog and "Logic_UGC:CheckShowPubSuccess caring_last_publish_mod is nil")
    return
  end
  self.  local MessageInfo = {message = 79596}
  local ModInfo = self:GetModByAllCache(caring_last_publish_mod)
  if ModInfo then
    MessageInfo.    UIManager.ShowUI(UIManager.UI_Config.UGCPubMod_Tip_UIBP, MessageInfo)
  else
    self:BatchGetModInfo({caring_last_publish_mod}, self.C_ModListTypes.Pub, nil, {
      TypeParam = self.caring_last_publish_mod
    })
  end
end
function Logic_UGC:OnPubModInfoRsp(_, _, lisType, bIsDirty, MetaList, Param, FilterOfflineModList)
  if not UGCMacros.CheckMetaType(lisType, UGCMacros.ENUM_MODE_TYPE.Pub) then
    return
  end
  if Param ~= self.caring_last_publish_mod then
    return
  end
  local ModInfo = self:GetModByAllCache(self.caring_last_publish_mod)
  if ModInfo then
    local MessageInfo = {message = 79596, ModInfo = ModInfo}
    UIManager.ShowUI(UIManager.UI_Config.UGCPubMod_Tip_UIBP, MessageInfo)
  end
end
function Logic_UGC:UpdateNotAuthorTips(author_info)
  if not author_info then
    log(bWriteLog and "Logic_UGC:UpdateNotAuthorTips author_info is nil")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "Logic_UGC:UpdateNotAuthorTips is BLUEHOLE")
    return
  end
  if not author_info.caring_notify_bitmap or not next(author_info.caring_notify_bitmap) then
    log(bWriteLog and "Logic_UGC:UpdateNotAuthorTips author_info.caring_notify_bitmap is nil")
    return
  end
  log_tree("Logic_UGC:UpdateNotAuthorTips author_info = ", author_info)
  local showlist = {}
  local CreatorStateCfg = CDataTable.GetTableData("CreatorCareTipCfg", self.NotAuthorTipsID)
  table.insert(showlist, CreatorStateCfg)
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local bShow = Logic_UGC:CheckShowTips(author_info.caring_notify_bitmap[1], self.NotAuthorTipsID)
  if bShow then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_NOTAUTHOR_TIPS_STATE, showlist)
  end
end
function Logic_UGC:IsFromSearch()
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  if self.selectedTabId == config_ugc.Config_UGC_TabID.All then
    return false
  elseif self.selectedTabId == config_ugc.Config_UGC_TabID.SearchMod or self.selectedTabId == config_ugc.Config_UGC_TabID.SearchCollections then
    return true
  end
end
function Logic_UGC:SetSelectedThemeId(ThemeId)
  log(bWriteLog and "Logic_UGC:SetSelectedThemeId ThemeId " .. tostring(ThemeId))
  self.selectedend
function Logic_UGC:GetSelectedThemeId()
  return self.selectedThemeId
end
function Logic_UGC:SetSelectedDetailTabID(TabID)
  log(bWriteLog and "Logic_UGC:SetSelectedDetailTabID TabID " .. tostring(TabID))
  self.selectedDetailend
function Logic_UGC:GetSelectedDetailTabID()
  return self.selectedDetailTabID
end
function Logic_UGC:SetDetailTranslateState(state)
  log(bWriteLog and "Logic_UGC:SetDetailTranslateState state = " .. tostring(state))
  self.DetailTranslate = state
end
function Logic_UGC:GetDetailTranslateState()
  return self.DetailTranslate
end
function Logic_UGC:IsShowLoadingMultiAttachUI()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return false
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  local bToLobby = LoadingSystem.GetToLobby() or false
  if bToLobby then
    return false
  end
  local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if LogicUGCCRUD:GetIsEditMod() or LogicUGC:IsUGCEditMod() then
    return false
  end
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if not LogicUGCMulti:IsMatchSuccessByUGCMulti() then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if not LogicUGCMatch:GetUgcMatchModInfo() then
      return false
    else
      local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
      local SubMode = logic_mode_mgr.nInGameModeID or 0
      if SubMode == 0 then
        return false
      end
      local bIsEnterUGCMod = false
      local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
      local UGCMods = {
        880001,
        880002,
        880003,
        880004,
        880005,
        880006,
        880007,
        880008,
        880000
      }
      for i = 1, #UGCMacros.UGC_SUB_GAME_MODE_ID_LIST do
        table.insert(UGCMods, UGCMacros.UGC_SUB_GAME_MODE_ID_LIST[i])
      end
      for _, v in ipairs(UGCMods) do
        if v == SubMode then
          bIsEnterUGCMod = true
          break
        end
      end
      if not bIsEnterUGCMod then
        return false
      end
    end
  end
  return true
end
function Logic_UGC:IsShowLoadingEditAttachUI()
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  local toLobby = LoadingSystem.GetToLobby() or false
  if toLobby then
    log(bWriteLog and "Logic_UGC:IsShowLoadingEditAttachUI toLobby")
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if not LogicUGC:IsUGCEditMod() then
    log(bWriteLog and "Logic_UGC:IsShowLoadingEditAttachUI not IsUGCEditMod")
    return
  end
  return true
end
function Logic_UGC:GetUGCFaceSlapData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activity = ActivityNewSystem.GetActivityListByType(ActivityType.UGCFacePic)
  if not activity or not next(activity) then
    log(bWriteLog and "Logic_UGC:GetUGCFaceSlapData activity is nil")
    return nil
  end
  log_tree(bWriteLog and "Logic_UGC:GetUGCFaceSlapData activity = ", activity)
  local StringUtil = require("common.string_util")
  self.UGCFaceSlapData = {}
  local TimeUtil = require("client.common.time_util")
  local currTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(activity) do
    if currTime >= v.StartTime and currTime <= v.EndTime then
      local cons = StringUtil.SplitToNum(v.Condition, ",")
      local exposure_cnt = cons[2] or 0
      local data = {
        ID = v.ID,
        Title = v.Title,
        Desc = v.Desc,
        ImgUrl = v.ImgUrl,
        Condition1 = cons[1] or 0,
        Condition2 = exposure_cnt,
        ImgLink = v.ImgLink,
        Level_Down_Limit = cons[3] or 0,
        Level_Up_Limit = cons[4] or 0,
        List = v.List
      }
      table.insert(self.UGCFaceSlapData, data)
    else
      log(bWriteLog and "Logic_UGC:GetUGCFaceSlapData activity is not in time ID = " .. v.ID)
    end
  end
  return self.UGCFaceSlapData
end
function Logic_UGC:GetFaceSlapValidExposureCnt(data)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local loc_exposure_cnt = 0
  local Record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWOWFaceSlapExposureCnt) or {}
  if not Record[data.ID] then
    Record[data.ID] = {}
    Record[data.ID].exposure_cnt = 0
    Record[data.ID].lastExposureTime = 0
  end
  log_tree(bWriteLog and "Logic_UGC:GetFaceSlapValidExposureCnt Record = ", Record)
  for i, j in pairs(data.List) do
    if j.Cycle == 0 then
      loc_exposure_cnt = Record[data.ID].exposure_cnt or 0
    elseif j.Cycle == 1 then
      local lastExposureTime = Record[data.ID].lastExposureTime
      if not TimeUtil.IsSameDay(lastExposureTime, TimeUtil.GetServerTimeInSec()) then
        loc_exposure_cnt = 0
        Record[data.ID].exposure_cnt = loc_exposure_cnt
        log(bWriteLog and "Logic_UGC:GetFaceSlapValidExposureCnt not same day")
      else
        loc_exposure_cnt = Record[data.ID].exposure_cnt or 0
      end
    elseif j.Cycle == 7 then
      local lastExposureTime = Record[data.ID].lastExposureTime
      if not TimeUtil.IsSameWeek(lastExposureTime, TimeUtil.GetServerTimeInSec()) then
        loc_exposure_cnt = 0
        Record[data.ID].exposure_cnt = loc_exposure_cnt
        log(bWriteLog and "Logic_UGC:GetFaceSlapValidExposureCnt not same week")
      else
        loc_exposure_cnt = Record[data.ID].exposure_cnt or 0
      end
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(Record, PlayerPrefsSystem.ePlayerPrefsType.eUGCWOWFaceSlapExposureCnt)
  log(bWriteLog and "Logic_UGC:GetFaceSlapValidExposureCnt loc_exposure_cnt = " .. loc_exposure_cnt .. " ACTID = " .. data.ID)
  return loc_exposure_cnt
end
function Logic_UGC:OnAllActChange()
  log(bWriteLog and "Logic_UGC:OnAllActChange")
  self.UGCFaceSlapData = nil
end
function Logic_UGC:IsCanShow()
  local bInLobby = GameStatus.IsInLobbyOrMainCity()
  if not bInLobby then
    log(bWriteLog and "Logic_UGC:IsCanShow return false of gameStatus = " .. tostring(gameStatus) .. " ,not in Login Status and MainCity")
    return false
  end
  if self:IsCloseFaceSlap() then
    log(bWriteLog and "Logic_UGC:IsCanShow return false of IsCloseFaceSlap = true")
    return false
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if level_unlock_manager:CheckShowLevelUpAndUnlockFeature() then
    log(bWriteLog and "Logic_UGC:IsCanShow return false of have unlock feature")
    return false
  end
  return true
end
function Logic_UGC:IsCloseFaceSlap()
  local common_config = require("client.slua.common.common_config")
  return self.bClose or common_config:IsBlockingPopupTip()
end
function Logic_UGC:CheckPromotionDataValid()
  if not self.promotionList or #self.promotionList <= 0 then
    log(bWriteLog and "Logic_UGC:CheckPromotionDataValid promotionList is nil")
    return false
  end
  if not self.PromotionDataTimeStamp then
    log(bWriteLog and "Logic_UGC:CheckPromotionDataValid PromotionDataTimeStamp is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  return curTime <= self.PromotionDataTimeStamp + self.PromotionReqCD
end
function Logic_UGC:GetNewThisWeek()
  local new_mod_list = {}
  local cache_pub_mod_list = self:GetCacheByType(UGCMacros.ENUM_MODE_TYPE.Pub)
  if not cache_pub_mod_list or not next(cache_pub_mod_list) then
    log(bWriteLog and "Logic_UGC:GetNewThisWeek cache_pub_mod_list is nil")
    return new_mod_list
  end
  local pubList = self:GetPubModList()
  if not pubList or not next(pubList) then
    log(bWriteLog and "Logic_UGC:GetNewThisWeek no publist")
    return new_mod_list
  end
  local array = {}
  for modId, pubInfo in pairs(pubList) do
    if modId and cache_pub_mod_list[modId] then
      table.insert(array, cache_pub_mod_list[modId])
    end
  end
  local TimeUtil = require("client.common.time_util")
  for modId, meta in pairs(array) do
    if TimeUtil.IsSameWeek(meta.pub_mod_meta.update_date, TimeUtil.GetServerTimeInSec()) then
      table.insert(new_mod_list, meta)
    end
  end
  return new_mod_list
end
function Logic_UGC:CheckShowUGCMainMineGuideTips()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local cfg = BasicDataServerTable:GetCacheData(Config_UGC.GalleryParamConfig)
  local WeeklyShareCreatorMinLevelConfig = cfg.WeeklyShareCreatorMinLevelConfig or 5
  local WeeklyShareCreatorMinPublishConfig = cfg.WeeklyShareCreatorMinPublishConfig or 10
  local cache_pub_mod_list = self:GetCacheByType(UGCMacros.ENUM_MODE_TYPE.Pub)
  local TableUtil = require("common.table_util")
  local pub_mod_cnt = TableUtil.CountTable(cache_pub_mod_list)
  log(bWriteLog and "Logic_UGC:CheckShowUGCMainMineGuideTips pub_mod_cnt = " .. pub_mod_cnt .. " DataMgr.ugc_author_info.new_level = " .. DataMgr.ugc_author_info.new_level)
  if cfg and (DataMgr.ugc_author_info.new_level < tonumber(WeeklyShareCreatorMinLevelConfig) or pub_mod_cnt < tonumber(WeeklyShareCreatorMinPublishConfig)) then
    return true
  end
  return false
end
function Logic_UGC:UpdateShareEmpowerRedDot(task_list)
  local ugc_center_reddot_data = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  for mod_id, v in pairs(task_list) do
    ugc_center_reddot_data.AddShareModRedDotData(mod_id)
    if v.status == 1 then
      ugc_center_reddot_data.UpdateModRedDotData(mod_id, true)
    else
      ugc_center_reddot_data.UpdateModRedDotData(mod_id, false)
    end
  end
end
function Logic_UGC:SetAlltAutoTransEnabled(bFlag)
  log(bWriteLog and "Logic_UGC:SetClientAutoTransEnabled " .. tostring(bFlag))
  self.bCachedSkipSaveToFile = bFlag
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_set_auto_translate_switch_req(bFlag)
end
function Logic_UGC:GetAllAutoTransEnabled()
  if self.bCachedSkipSaveToFile ~= nil then
    log(bWriteLog and "Logic_UGC:GetAllOutsideAutoTransEnabled Cached = " .. tostring(self.bCachedSkipSaveToFile))
    return self.bCachedSkipSaveToFile
  end
  log(bWriteLog and "Logic_UGC:SetClientAutoTransEnabled send_ugc_get_auto_translate_switch_req")
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_get_auto_translate_switch_req()
end
function Logic_UGC:SetFreeInOutLevel(Level)
  print("Logic_UGC:SetFreeInOutLevel", Level)
  if not Level then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  Config_UGC.AuthorLevelOpenFreeInOut = Level
end
function Logic_UGC:ONGetAllAutoTransRsp(ugc_auto_translate_switch)
  self.bCachedSkipSaveToFile = ugc_auto_translate_switch
  log(bWriteLog and "Logic_UGC:ONGetAllAutoTransRsp " .. tostring(ugc_auto_translate_switch))
end
function Logic_UGC:OnClearModReqSign()
  log(bWriteLog and "Logic_UGC:OnClearModReqSign")
  self.ModReqCacheMap = {}
  self.ModReqMatchList = {}
end
function Logic_UGC:ReqAlbumThemeConfig()
  log(bWriteLog and "Logic_UGC:ReqAlbumThemeConfig")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.wow_spec_theme_task_conf_table, self.OnGetAlbumThemeConfig)
end
function Logic_UGC:ReqNewbieUGCRecommend()
  log(bWriteLog and "Logic_UGC:ReqNewbieUGCRecommend")
  local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
  if logic_ugc_new_process:CheckIsOpen() then
    log(bWriteLog and "Logic_UGC:ReqNewbieUGCRecommend CheckIsOpen is true")
    logic_ugc_new_process:SetBatchModInfoState(true)
    logic_ugc_new_process:send_wow_query_newbie_guide_data_req()
    local logic_ugc_intention = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_intention)
    logic_ugc_intention:send_ugc_admin_recommend_mods_req()
  end
end
function Logic_UGC.OnGetAlbumThemeConfig(_, AlbumThemeConfig)
  log(bWriteLog and "Logic_UGC:OnGetAlbumThemeConfig")
  Logic_UGC.end
function Logic_UGC:ClearModCacheTypeID(type, mod_id)
  if not type then
    return
  end
  if not mod_id then
    return
  end
  local getCache = self.ModCacheList[type]
  if not getCache or not next(getCache) then
    log(bWriteLog and "Logic_UGC:ClearModCacheTypeID getCache is nil")
    return
  end
  getCache[mod_id] = nil
end
function Logic_UGC:CheckFirstEnterWOWAutoTransTips()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local LoadTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCOutsideAutoTransTips) or {}
  if LoadTable == nil or not next(LoadTable) then
    return true
  end
  if not LoadTable.NewEnterWOWAutoTransTips then
    return true
  end
  return false
end
function Logic_UGC:GetModNameMaxLen()
  return CDataTable.GetTableData("UGCMetaParameterConfig", 2).StringMaxChar or 30
end
function Logic_UGC:GetModDescMaxLen()
  return CDataTable.GetTableData("UGCMetaParameterConfig", 3).StringMaxChar or 256
end
Logic_UGC.B_WOWPassYellow = false
Logic_UGC.B_Crystal = false
Logic_UGC.B_WOWPassBlue = false
function Logic_UGC:SetUGCPopupCheckGM(type, bSkip)
  if type == "WOWPassYellow" then
    self.B_WOWPassYellow = bSkip
  elseif type == "Crystal" then
    self.B_Crystal = bSkip
  elseif type == "WOWPassBlue" then
    self.B_WOWPassBlue = bSkip
  end
end
function Logic_UGC:GetUGCPopupCheckGM(type)
  if type == "WOWPassYellow" then
    log(bWriteLog and "Logic_UGC:GetUGCPopupCheckGM B_WOWPass = " .. tostring(self.B_WOWPassYellow))
    return self.B_WOWPassYellow
  elseif type == "Crystal" then
    log(bWriteLog and "Logic_UGC:GetUGCPopupCheckGM B_Crystal = " .. tostring(self.B_Crystal))
    return self.B_Crystal
  elseif type == "WOWPassBlue" then
    log(bWriteLog and "Logic_UGC:GetUGCPopupCheckGM B_WOWPassBlue = " .. tostring(self.B_WOWPassBlue))
    return self.B_WOWPassBlue
  end
end
function Logic_UGC:OnAddStealBrainrotCard()
  if self.ClearModCacheTimer then
    self:RemoveTimer(self.ClearModCacheTimer)
    self.ClearModCacheTimer = nil
    self:ExitUGC(true)
  else
    self.ClearCacheCD = 1
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGC = class(CModuleBase, nil, Logic_UGC)
return CLogicUGC