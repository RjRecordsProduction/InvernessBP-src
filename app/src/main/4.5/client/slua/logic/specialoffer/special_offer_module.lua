local special_offer_module = {}
local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
local GenActData = function(desc, subID)
  subID = subID or 1
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = reddot_macro.Category.Receive,
    desc = desc,
    subID = subID,
    isDynamicCategory = true
  }
  return data
end
local systemName = "specialOffer"
function special_offer_module:DefineAndResetData()
  self.specialBanners = {}
  self.clickedMarks = {}
  self.normalBanners = {}
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local redData = {
    desc = systemName,
    newCount = 0,
    pages = {
      newCount = 0,
      category = reddot_macro.Category.Receive,
      isDynamic = true
    }
  }
  local SuperData = require("common.super_data")
  self.redData = SuperData.CreateSuperData(redData)
end
function special_offer_module:RegistEvents()
  special_offer_module.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SPECIAL_OFFER, self.JumpIn, self)
  self:AddCommonEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, self.RefreshOneRedByEvent, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.WhenNEXTDAY, self)
end
function special_offer_module:OnPostSwitchGameStatus(_, next)
  log(bWriteLog and "  : special_offer_module:OnPostSwitchGameStatus")
  if next == GameStatus.Lobby then
    local SpecialOfferHandler = require("client.network.Protocol.SpecialOfferHandler")
    SpecialOfferHandler.send_get_commercial_showpage_req()
    self:WaitforActData()
  end
end
function special_offer_module:WaitforActData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
  if not self.actTimer then
    self.actTimer = self:AddTimerLoop(0, function()
      local activityDataTable = ActivityNewSystem.GetServerData()
      local actId = tonumber(logic_scrapgold_draw.ActivityId)
      local data = activityDataTable[actId]
      if data then
        local ScrapGoldManger = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ScrapGoldManger)
        ScrapGoldManger:ReqActInfo(actId)
        self:RemoveTimer(self.actTimer)
        self.actTimer = nil
      end
    end, TIMER_INFINITE, 1)
  end
end
function special_offer_module:Url2SpecialOfferId(jumpUrl)
  if not jumpUrl then
    return
  end
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(jumpUrl)
  local module = params and params.module
  local moduleId = module and tonumber(module)
  if not moduleId or moduleId ~= BP_ENUM_MODULE_SPECIAL_OFFER then
    return
  end
  local id = params and params.id
  id = id and tonumber(id)
  local id2ActId = cfg.id2ActId
  log(bWriteLog and "  : Url2SpecialOfferId: " .. tostring(id))
  if id2ActId[cfg.golden] == id then
    return id
  end
end
function special_offer_module:GetBannerWord(jumpUrl)
  if not jumpUrl then
    return
  end
  if self.normalBanners[jumpUrl] then
    return
  end
  local id = self:Url2SpecialOfferId(jumpUrl)
  if not id then
    self.normalBanners[jumpUrl] = true
    return
  end
  for oneId, _ in pairs(cfg.uiCdg) do
    local wordId = self:_Id2WordId(oneId)
    if wordId then
      return wordId
    end
  end
end
function special_offer_module:_Id2WordId(id)
  local special_offer_banner = require("client.slua.logic.specialoffer.special_offer_banner")
  local func = special_offer_banner[id] or special_offer_banner[cfg.ActId2Id[id]]
  local _, wordId
  if func then
    local utility = require("common.utility")
    _, wordId = xpcall(func, utility.ErrorMessageHandler)
  end
  return wordId
end
function special_offer_module:Id2MarkType(id)
  if not cfg.IsModuleReachable(id) then
    return
  end
  local special_offer_mark = require("client.slua.logic.specialoffer.special_offer_mark")
  local func = special_offer_mark[id]
  if func then
    local utility = require("common.utility")
    local _, a, b, c = xpcall(func, utility.ErrorMessageHandler)
    return a, b, c
  end
end
function special_offer_module:ClickedBanner(jumpUrl)
  if self.normalBanners[jumpUrl] then
    return
  end
  local id = self:Url2SpecialOfferId(jumpUrl)
  if not id then
    self.normalBanners[jumpUrl] = true
  else
    local wordId = self:GetBannerWord(jumpUrl)
    if wordId then
      self.specialBanners[wordId] = true
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      PlayerPrefsSystem.CheckAndSaveCurrentDate_DynamicPath(PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferBanner, tostring(wordId))
    end
  end
end
function special_offer_module:HasClickedByWordId(wordId)
  if self.specialBanners[wordId] then
    return true
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bIsDiffDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_DynamicPath(PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferBanner, tostring(wordId), true)
  return not bIsDiffDate
end
function special_offer_module:HasClickedMark(id, markTp, forever)
  id = self:ConvertMarkId(id)
  if not id then
    return true
  end
  local id_type = string.format("%s_%s", id, markTp)
  if self.clickedMarks[id_type] then
    return true
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local day = 1
  if forever then
    day = 18250
  end
  local bIsDiffDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_DynamicPath(PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferMark, id_type, true, day)
  if self:IsGetMarkHasClickVersionInfo(id, markTp) and self:IsHasClickInCurVersion(id, markTp) then
    return true
  end
  return not bIsDiffDate
end
function special_offer_module:IsHotMark(id)
  return self.allData and self.allData[id] and self.allData[id].isHot
end
function special_offer_module:RemoveAllTypeRed(id)
  if id == cfg.MaterialsGift then
    local logic_special_offer_material = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_material)
    logic_special_offer_material:RemoveReUpdate()
  end
  log_warning(bWriteLog and "  :RemoveAllTypeRed id: " .. tostring(id))
  local special_offer_mark = require("client.slua.logic.specialoffer.special_offer_mark")
  local redId = self:ConvertMarkId(id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  for _, mark in pairs(special_offer_mark.markType) do
    local id_type = string.format("%s_%s", redId, mark)
    if not self.clickedMarks[id_type] then
      self.clickedMarks[id_type] = true
      self:CacheRedClickVersionInfo(id, mark)
      PlayerPrefsSystem.CheckAndSaveCurrentDate_DynamicPath(PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferMark, id_type)
    end
  end
  self:RefreshOneRed(id)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, id)
end
function special_offer_module:ConvertMarkId(id)
  if id == cfg.ACTIVITY_TYPE_CONSUME_UC then
    return cfg.id2ActId[cfg.ACTIVITY_TYPE_CONSUME_UC]
  elseif id == cfg.CONSUME_UC then
    return cfg.id2ActId[cfg.CONSUME_UC]
  elseif id == cfg.golden then
    local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
    local ext_info = logic_scrapgold_draw.GetExtInfo()
    return ext_info and ext_info.next_version_update_time
  end
  return id
end
function special_offer_module:CacheRedClickVersionInfo(id, markTp)
  local special_offer_mark = require("client.slua.logic.specialoffer.special_offer_mark")
  local EnumMarkType = special_offer_mark.markType
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tClickRedVersionInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferMarkVersion) or {}
  local nCurVersion = DataMgr.GetPreVersion(Client.GetApplicationVersion())
  if id == cfg.ConditionsGift and markTp == EnumMarkType.BuyAble then
    tClickRedVersionInfo[id] = nCurVersion
  elseif id == cfg.subscribe and markTp == EnumMarkType.Hot then
    tClickRedVersionInfo[id] = nCurVersion
  end
  PlayerPrefsSystem.SaveTableToFile_N(tClickRedVersionInfo, PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferMarkVersion)
end
function special_offer_module:IsHasClickInCurVersion(id, markTp)
  local special_offer_mark = require("client.slua.logic.specialoffer.special_offer_mark")
  local EnumMarkType = special_offer_mark.markType
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tClickRedVersionInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferMarkVersion) or {}
  local nCurVersion = DataMgr.GetPreVersion(Client.GetApplicationVersion())
  if id == cfg.ConditionsGift and markTp == EnumMarkType.BuyAble then
    if tClickRedVersionInfo[id] and tClickRedVersionInfo[id] == nCurVersion then
      return true
    end
  elseif id == cfg.subscribe and markTp == EnumMarkType.Hot and tClickRedVersionInfo[id] and tClickRedVersionInfo[id] == nCurVersion then
    return true
  end
  return false
end
function special_offer_module:IsGetMarkHasClickVersionInfo(id, markTp)
  local special_offer_mark = require("client.slua.logic.specialoffer.special_offer_mark")
  local EnumMarkType = special_offer_mark.markType
  if id == cfg.ConditionsGift and markTp == EnumMarkType.BuyAble then
    return true
  elseif id == cfg.subscribe and markTp == EnumMarkType.Hot then
    return true
  end
  return false
end
function special_offer_module:WhenNEXTDAY()
  self.specialBanners = {}
  self.clickedMarks = {}
  self:WaitforActData()
end
function special_offer_module:JumpIn(_, _, vars)
  local nId = vars and tonumber(vars.id)
  if not nId then
    if vars and vars.src and tostring(vars.src) ~= "" then
      vars.source = cfg.BargainEntrySource and cfg.BargainEntrySource.ShareLink or 4
    end
    log(bWriteLog and "special_offer_module JumpIn not id")
    self:OpenOneAct(nil, vars)
    return
  end
  if cfg.ActId2Id[nId] then
    nId = cfg.ActId2Id[nId]
  end
  local fCheckShowFunc = cfg.id2CheckShow[nId]
  if fCheckShowFunc and type(fCheckShowFunc) == "function" and not fCheckShowFunc(vars) then
    ShowNotice(125046)
    return
  end
  if nId == cfg.NewGroupBuy and tonumber(vars.tabId) == 2 and tonumber(vars.from_share) == 1 then
    vars.source = cfg.BargainEntrySource and cfg.BargainEntrySource.ShareLink or 4
  end
  self:OpenOneAct(nId, vars)
end
function special_offer_module:OpenOneAct(actId, param)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    ShowNotice(116009)
    return
  end
  actId = actId and tonumber(actId)
  local logic_activity_recharge_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_activity_recharge_mgr)
  log(bWriteLog and "[YY]OpenOneAct==========" .. tostring(actId))
  if actId and logic_activity_recharge_mgr:IsInActivityBlackList(actId, true) then
    return
  end
  local IsShow = UIManager.IsUIShow(UIManager.UI_Config.SpecialOffer_Main_UIBP)
  if IsShow then
    local SpecialOffer_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.SpecialOffer_Main_UIBP)
    local nTargetId = actId
    nTargetId = nTargetId and cfg.ActId2Id[nTargetId] or nTargetId
    local nCurrentId = tonumber(SpecialOffer_Main_UIBP and SpecialOffer_Main_UIBP.nId)
    nCurrentId = nCurrentId and cfg.ActId2Id[nCurrentId] or nCurrentId
    if nTargetId == cfg.NewGroupBuy and nCurrentId == cfg.NewGroupBuy then
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.EnterNewGroupBuy)
    end
    SpecialOffer_Main_UIBP:SwitchUI(actId, param)
  else
    UIManager.ShowUI(UIManager.UI_Config.SpecialOffer_Main_UIBP, actId, param)
  end
end
function special_offer_module:OpenGolden()
  self:OpenOneAct(cfg.golden)
end
function special_offer_module:OpenRecharge()
  self:OpenOneAct(cfg.recharge)
end
function special_offer_module:OpenUGCRecharge()
  self:OpenOneAct(cfg.WOWCoinRecharge)
end
function special_offer_module:OpenPurchase()
  self:OpenOneAct(cfg.recharge_purchase)
end
function special_offer_module:OpenPrime()
  self:OpenOneAct(cfg.subscribe)
end
function special_offer_module:OpenDailyFortunePack()
  self:OpenOneAct(cfg.DailyFortunePack)
end
function special_offer_module:OpenDailySpecialBundle()
  self:OpenOneAct(cfg.DailySpecialBundle)
end
function special_offer_module:OpenFinancialActivity()
  self:OpenOneAct(cfg.Financial)
end
function special_offer_module:OpenCustomPack()
  self:OpenOneAct(cfg.OPTIONAL_RECHARGE)
end
function special_offer_module:OpenLimitPack()
  self:OpenOneAct(cfg.LimitedSet)
end
function special_offer_module:OpenJkGiftSet()
  self:OpenOneAct(cfg.JkGiftSet)
end
function special_offer_module:OpenGroupBuy()
  self:OpenOneAct(cfg.NewGroupBuy)
end
function special_offer_module:SwitchToWorkShop(keyName)
  if UIManager.IsUIShow(UIManager.UI_Config[keyName]) then
    self:OpenGolden()
  end
end
function special_offer_module:OpenCustomPack()
  self:OpenOneAct(cfg.OPTIONAL_RECHARGE)
end
function special_offer_module:RefreshRed()
  for id, _ in pairs(cfg.uiCdg) do
    self:RefreshOneRed(id)
  end
  if self.redData.pages and self.redData.pages.newCount then
    self.redData.newCount = self.redData.pages.newCount
  end
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  if not reddot_manager:IsRegist(systemName) then
    reddot_manager:Regist(self.redData)
  end
end
function special_offer_module:RefreshOneRedByEvent(_, _, Id)
  self:RefreshOneRed(Id)
  if self.redData.pages and self.redData.pages.newCount then
    self.redData.newCount = self.redData.pages.newCount
  end
end
local RecomputeAncestorOnWeightChange = function(leaf)
  leaf.realWeight = leaf.weight or 0
  local ReddotConfig = require("client.slua.logic.reddot.reddot_config")
  local parentData = leaf:GetParent()
  while parentData do
    local maxWeight = -1
    local category = ReddotConfig.INVALID_CATEGORY
    local subID = ReddotConfig.INVALID_SUBID
    for _, v in pairs(parentData) do
      if type(v) == "table" and v.realWeight and maxWeight < v.realWeight then
        maxWeight = v.realWeight
        category = v.category or category
        subID = v.subID or subID
      end
    end
    if parentData.weight and maxWeight < parentData.weight then
      maxWeight = parentData.weight
    end
    parentData.realWeight = maxWeight
    parentData.    parentData.    parentData = parentData:GetParent()
  end
end
function special_offer_module:RefreshOneRed(id)
  if not id then
    return
  end
  local preData = self.redData.pages[id]
  if not preData then
    self.redData.pages[id] = GenActData(LocUtil.GetLocalizeResStr(cfg.id2ResId[id]))
  end
  local newCount = 0
  local markType, day, isPromoteToNew = self:Id2MarkType(id)
  if markType then
    local subID = 0
    local SpecialOfferMark = require("client.slua.logic.specialoffer.special_offer_mark")
    if markType == SpecialOfferMark.markType.Got then
      subID = 2
    elseif markType == SpecialOfferMark.markType.New then
      subID = 3
    elseif markType == SpecialOfferMark.markType.BuyAble then
      subID = 3
    elseif isPromoteToNew then
      subID = 3
    end
    if not self:IsTickCountDownReddot(id, markType, day) then
      log(bWriteLog and "special_offer_module:RefreshOneRed\227\128\138\227\128\138\227\128\138\227\128\138  " .. tostring(id) .. "  " .. tostring(markType))
      newCount = 1
    end
    local ReddotConfig = require("client.slua.logic.reddot.reddot_config")
    self.redData.pages[id].    local weight = ReddotConfig:GetWeight(systemName, self.redData.pages[id])
    local isNeedChangeWeight = weight ~= self.redData.pages[id].weight
    self.redData.pages[id].weight = ReddotConfig:GetWeight(systemName, self.redData.pages[id])
    if isNeedChangeWeight then
      RecomputeAncestorOnWeightChange(self.redData.pages[id])
    end
  end
  self.redData.pages[id].end
function special_offer_module:IsTickCountDownReddot(id, markType, day)
  if not day then
    return false
  end
  if id == cfg.subscribe then
    return false
  end
  if not self:HasClickedMark(id, markType) then
    return false
  end
  return true
end
function special_offer_module:GetRedDot()
  self:RefreshRed()
  return self.redData
end
function special_offer_module:GetRedDotByPage(id)
  if not id then
    return
  end
  if not self.redData.pages then
    return
  end
  return self.redData.pages[id]
end
function special_offer_module:OnGetAllData(allData)
  self.  self:OnDataChange()
end
function special_offer_module:Get3940ActData(id)
  local actType = ActivityType.ACTIVITY_TYPE_CONSUME_UC
  if id == cfg.CONSUME_UC then
    actType = ActivityType.CONSUME_UC
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local act = ActivityNewSystem.GetActivityByTypeAndLabel(actType, ActivitySwitchType.SpecialOffer)
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  if act and nCurTime >= act.StartTime and nCurTime <= act.EndTime then
    cfg.SetActId(id, tonumber(act.ID))
    return act
  end
end
function special_offer_module:GetPandoraActData(id)
  local actType = ActivityType.ACTIVITY_TYPE_LINK
  if id == cfg.PandoraPopular then
    actType = ActivityType.ACTIVITY_TYPE_LINK
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actList = ActivityNewSystem.GetActivityListByTypeAndLabel(actType, ActivitySwitchType.SpecialOffer)
  if actList and next(actList) then
    return actList[1]
  end
end
function special_offer_module:OnGetOneData(id, data)
  if not self.allData then
    local RoomHandler = require("client.network.Protocol.SpecialOfferHandler")
    RoomHandler.send_get_commercial_showpage_req()
    return
  end
  self.allData[id] = data
  self:OnDataChange()
end
local day3Time = 259200
function special_offer_module:OnDataChange()
  local special_offer_time = require("client.slua.logic.specialoffer.special_offer_time")
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local special_offer_mark = require("client.slua.logic.specialoffer.special_offer_mark")
  local EnumMarkType = special_offer_mark.markType
  for id, v in pairs(self.allData) do
    v.allWeight = (v.weight or 0) + (v.pay_weight or 0)
    local timeFunc = special_offer_time[id]
    timeFunc = timeFunc or cfg.ActId2Id[id] and special_offer_time[cfg.ActId2Id[id]]
    log_warning(bWriteLog and "  :OnDataChange id: " .. tostring(id))
    if timeFunc then
      local startTime, endTime = timeFunc()
      if startTime and type(startTime) == "number" then
        log(bWriteLog and "  :special_offer_module OnDataChange startTime:" .. tostring(startTime))
        local before = curTime - startTime
        local later = endTime - curTime
        if before < day3Time then
          v.allWeight = v.allWeight + v.open_after_weight
        end
        if later < day3Time then
          v.allWeight = v.allWeight + v.end_before_weight
        end
      end
    end
    local hot_starttime, hot_endtime = v.hot_starttime, v.hot_endtime
    if type(hot_starttime) == "number" and curTime > hot_starttime and curTime < hot_endtime then
      v.isHot = true
      if self:IsGetMarkHasClickVersionInfo(id, EnumMarkType.Hot) and self:IsHasClickInCurVersion(id, EnumMarkType.Hot) then
        v.isHot = false
      end
    end
  end
end
function special_offer_module:GetAllData()
  return self.allData
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CItemGetModule = class(CModuleBase, nil, special_offer_module)
return CItemGetModule