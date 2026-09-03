local ActivityUtil = {}
local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
local TableUtil = require("common.table_util")
local E_ActSwitchType = ActivitySwitchType
local E_local E_ActType = ActivityType
local E_local local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
local E_SubActType = ActivityMacros.SubActType
local C_SwitchIcon = ActivityMacros.ActTabIcon
local C_SwitchIcon_Selected = ActivityMacros.ActTabSelIcon
local NoRedShowTypeTb = {
  [E_ActivityShowType.None] = 1,
  [E_ActivityShowType.Bg] = 1,
  [E_ActivityShowType.TopBg] = 1,
  [E_ActivityShowType.BottomImage] = 1
}
local StringUtil = require("common.string_util")
local strFind = StringUtil.StrFind
local TimeUtil = require("client.common.time_util")
function ActivityUtil.CanShowAct(actData)
  log(bWriteLog and string.format("ActivityUtil.CanShowAct. ID=%s", tostring(actData.ID)))
  if not actData.Type then
    log(bWriteLog and "ActivityUtil.CanShowAct. actData.Type is nil")
    return false
  end
  if ActivityNewSystem.IsSignInType(actData) then
    log(bWriteLog and "ActivityUtil.CanShowAct. actData is sign in type")
    return false
  end
  if not ActivityUtil.IsCurActSwitchTypeInCenter(actData) then
    log(bWriteLog and "ActivityUtil.CanShowAct. actData not in current switch type")
    return false
  end
  if not ActivityUtil.CheckActIsInProgress(actData) then
    log(bWriteLog and "ActivityUtil.CanShowAct. actData not in progress")
    return false
  end
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local pageType = ActivityCenterModule:GetActPageType(actData)
  if NoRedShowTypeTb[pageType] then
    log(bWriteLog and "ActivityUtil.CanShowAct. pageType in NoRedShowTypeTb")
    return false
  end
  if ActivityNewSystem.IsEmbeddingGameletAct(actData) then
    log(bWriteLog and "ActivityUtil.CanShowAct. actData is gamelet act")
    return ActivityNewSystem.IsGameletActCanShow(actData)
  end
  return true
end
function ActivityUtil.CheckActIsInProgress(activityData)
  if not activityData then
    log(bWriteLog and "ActivityUtil.CheckActIsInProgress. activityData is nil")
    return
  end
  if activityData.Type == E_ActType.PreventLose_LoginReward then
    local nowTime = TimeUtil.GetServerTimeInSec()
    if nowTime >= activityData.StartTime and nowTime < activityData.EndTime then
      return true
    end
    log(bWriteLog and string.format("ActivityUtil.CheckActIsInProgress. return false, nowTime=%s StartTime=%s EndTime=%s", tostring(nowTime), tostring(activityData.StartTime), tostring(activityData.EndTime)))
    return false
  end
  return true
end
function ActivityUtil.IsCurActSwitchTypeInCenter(tActData)
  local bIsInCenter = true
  if not tActData.ImgLink then
    tActData.ImgLink = ""
  end
  if strFind(tActData.ImgLink, "module=" .. BP_ENUM_MODULE_BIND_FACEBOOK) then
    local logic_bind_facebook = require("client.slua.logic.activity.logic_bind_facebook")
    local bindType = E_ActType.BIND_SEND_GIFT
    if not ActivityNewSystem.IsModuleOnline(logic_bind_facebook.activityId, bindType) then
      bIsInCenter = false
    end
  elseif strFind(tActData.ImgLink, "module=" .. BP_ENUM_MODULE_BUY_UPASS_ACT) then
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    bIsInCenter = UnknowPassBuyActSystem.GetNeedShowEntrance()
  end
  if ActivityMacros.ActTabConfig[tActData.TabType] then
    return bIsInCenter
  end
  log(bWriteLog and string.format("ActivityUtil.IsCurActSwitchTypeInCenter. not in center, Title=%s", tostring(tActData.Title)))
  return false
end
local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
local goldenId = special_offer_cfg.id2ActId[special_offer_cfg.golden]
local hideIdTb = {
  [goldenId] = 1
}
function ActivityUtil.IsHideInActivityCenter(activity)
  if not activity then
    return true
  end
  if hideIdTb[activity.ID] then
    return true
  end
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  if activity.ImgLink and not pandoraSystem.CheckActIsShowByUrl(activity.ImgLink) then
    return true
  end
  if activity.TabType and not ActivityMacros.ActTabConfig[activity.TabType] then
    return true
  end
  if activity.ShowSceneID and activity.ShowSceneID > 1 then
    if activity.Type == ActivityType.ACTIVITY_TYPE_LINK then
      return false
    end
    return true
  end
  if activity.Type == E_ActType.ITEM_EXCHANGE then
    local exParam = activity.ExParam
    if exParam ~= "" then
      local params = StringUtil.Split(exParam, ",")
      local isShowInLobby = tonumber(params[1]) == 1
      return isShowInLobby
    end
  end
  if activity.Type == E_ActType.NOTICE_INFO and activity.ImgUrl ~= "" and activity.Detail == "" then
    return true
  end
  if activity.BackupParam1 and tonumber(activity.BackupParam1) == ActivityBackUpOneType.UGCSeason then
    if activity.Type == ActivityType.ACTIVITY_TYPE_LINK then
      return true
    end
    return false
  end
  return false
end
function ActivityUtil.GetTabName(TabType)
  local result = ""
  if TabType and ActivityMacros.ActTabConfig[TabType] then
    local TabConfig = ActivityMacros.ActTabConfig[TabType]
    result = LocUtil.GetLocalizeResStr(TabConfig.sLocalizeID)
  end
  return result
end
function ActivityUtil.GetStringLen(inputstr)
  if not inputstr then
    return 0
  end
  local bytes = {
    inputstr:byte(1, #inputstr)
  }
  local length, begin = 0, false
  for _, byte in ipairs(bytes) do
    if byte < 128 or 192 <= byte then
      begin = false
      length = length + 1
    elseif not begin then
      begin = true
      length = length + 1
    end
  end
  return length
end
local SignTypeTb = {
  [E_ActType.LOGIN] = 1,
  [E_ActType.TOTAL_LOGIN] = 1,
  [E_ActType.LoginPunchIn] = 1
}
function ActivityUtil.SortTask(List, Type)
  if not List then
    log_warning(bWriteLog and "ActivityUtil.SortTask. List is nil, skip sorting")
    return
  end
  log_warning(bWriteLog and string.format("ActivityUtil.SortTask. List=%s, Type=%s", tostring(List), tostring(Type)))
  if Type and SignTypeTb[Type] then
    ActivityUtil.SortSign(List)
    return
  end
  local RuleTb = {
    Status = {
      [1] = 1,
      [0] = 2,
      [2] = 3
    },
    Type = {
      [10] = 0
    }
  }
  local sort_util = require("common.sort_util")
  sort_util.SortByRule(List, RuleTb, "Type", "Status", "Total", "ID", "Key")
end
function ActivityUtil.SortSign(List)
  local RuleTb = {
    Status = {
      [1] = 1,
      [0] = 1,
      [2] = 3
    },
    Type = {
      [10] = 0
    }
  }
  local sort_util = require("common.sort_util")
  sort_util.SortByRule(List, RuleTb, "Type", "Status", "Index", "ID", "Key")
end
function ActivityUtil.SortAndSetCurActSubData(activity)
  if not activity then
    return
  end
  for _, subActivity in ipairs(activity.List) do
    subActivity.IsShowExPage = false
    subActivity.CanGetTimes = 0
    for _, v in pairs(subActivity.CostList) do
      v.have_count = ActivityUtil.GetItemNum(v.itemId)
    end
    if activity.Type == E_ActType.ITEM_EXCHANGE then
      subActivity = ActivityUtil.ResetExchangeParams(subActivity)
    end
    if activity.SelectExchange then
      subActivity.IsSelectExchange = true
    end
  end
  return activity
end
function ActivityUtil.ResetExchangeParams(subActivity)
  local can_exchange_num = 0
  for _, v in pairs(subActivity.CostList) do
    v.have_count = ActivityUtil.GetItemNum(v.itemId)
    if 0 < v.have_count and 0 < v.count then
      local temp_exchange_num = math.floor(v.have_count / v.count)
      if can_exchange_num == 0 then
        can_exchange_num = temp_exchange_num
      elseif temp_exchange_num < can_exchange_num then
        can_exchange_num = temp_exchange_num
      end
    end
  end
  local left_times = subActivity.Total - subActivity.Progress
  if 1 <= left_times and 1 <= can_exchange_num then
    subActivity.IsShowExPage = true
    subActivity.CanGetTimes = left_times
    if can_exchange_num < subActivity.CanGetTimes then
      subActivity.CanGetTimes = can_exchange_num
    end
  else
    subActivity.IsShowExPage = false
    subActivity.CanGetTimes = 0
  end
  return subActivity
end
function ActivityUtil.IsGroupAwardType(subData)
  if subData and subData.Type == E_ActType.GROUP and subData.Drop and #subData.Drop > 0 then
    return true
  end
  return false
end
function ActivityUtil.GetItemNum(nItemID)
  if nItemID == 1000 then
    return DataMgr.gold
  elseif nItemID == 1003 then
    return DataMgr.roleData.roleExp
  elseif nItemID == 1103 then
    return DataMgr.battle_coin
  else
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByResID(nItemID)
    if itemData ~= nil then
      return itemData.count
    end
    local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    local count = logic_xmission_warpre.GetItemNumByItemIdAndAffix(nItemID, true, false)
    return count
  end
end
function ActivityUtil.GetNoticePageType(tNoticeData)
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  if tNoticeData.MsgContentType == NoticesConst.NoticeContentType.Text then
    return E_ActivityShowType.Notice
  elseif tNoticeData.MsgContentType == NoticesConst.NoticeContentType.ImageOrBlueprint then
    return E_ActivityShowType.Image
  end
  return E_ActivityShowType.None
end
function ActivityUtil.GetCurRebatePhaseInfo(data)
  local daysToSecFactor = 86400
  local conds = StringUtil.Split(data.Condition, ",")
  local condBegin = conds[2] * daysToSecFactor + data.StartTime
  local condEnd = conds[3] * daysToSecFactor + data.StartTime - 1
  local curTaskEnd = 0
  local now = TimeUtil.GetServerTimeInSec()
  local curPhaseInfo = {
    activityPhase = -1,
    rebatePhase = -1,
    endTime = -1
  }
  local activityListMap = ActivityNewSystem.GetSubListMap()
  local rebateFirst = activityListMap[data.ID .. "_" .. tostring(2)]
  if not rebateFirst then
    return nil
  end
  local rebateFirstBegin = rebateFirst.Condition[1] * daysToSecFactor + data.StartTime - 1
  local ActivityRebate = require("client.logic.activity.logic_activity_rebate")
  if condBegin < now and condEnd >= now and data.List[1].Status == 0 then
    curPhaseInfo.activityPhase = ActivityRebate.activityPhase.discount
    curPhaseInfo.endTime = condEnd
  elseif condBegin < now and now <= rebateFirstBegin then
    curPhaseInfo.activityPhase = ActivityRebate.activityPhase.betweenDiscountAndRebate
    curPhaseInfo.endTime = rebateFirstBegin
  else
    curPhaseInfo.activityPhase = ActivityRebate.activityPhase.ending
    curPhaseInfo.endTime = -1
    for idx, _ in pairs(data.List) do
      local rebateInfo = activityListMap[data.ID .. "_" .. tostring(idx + 1)]
      curTaskEnd = rebateInfo.Condition[2] * daysToSecFactor + data.StartTime - 1
      if now < curTaskEnd then
        curPhaseInfo.activityPhase = ActivityRebate.activityPhase.rebate
        curPhaseInfo.rebatePhase = idx
        curPhaseInfo.endTime = curTaskEnd
        break
      end
    end
  end
  return curPhaseInfo
end
function ActivityUtil.GetSubActPageType(tSubData)
  if not tSubData then
    return E_SubActType.Award
  end
  if tSubData.IsSelectExchange then
    return E_SubActType.SelectExchange
  end
  if tSubData.Type == E_ActType.ITEM_EXCHANGE then
    return E_SubActType.Exchange
  elseif tSubData.Type == E_ActType.ACTIVITY_TYPE_REBATE then
    return E_SubActType.AwardTimeLimit
  elseif tSubData.Type == E_ActType.TaskPropsCollect then
    return E_SubActType.TaskPropsCollect
  else
    return E_SubActType.Award
  end
end
function ActivityUtil.GetDefaultBg(tActdata, nSwitchType)
  if not tActdata then
    return
  end
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local type = ActivityCenterModule:GetActPageType(tActdata)
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  if tActdata.MsgContentType and tActdata.MsgContentType == NoticesConst.NoticeContentType.Text then
    return "/Game/Mod/Lobby/Split/NewActivity/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_Affiche_BG.NewActivty_Affiche_BG"
  end
  if type == E_ActivityShowType.Notice then
    return "/Game/Mod/Lobby/Split/NewActivity/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_Affiche_BG.NewActivty_Affiche_BG"
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission(false) or nSwitchType == E_ActSwitchType.Xmission then
    return "/Game/Mod/Lobby/Split/NewActivity/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_SubwaySurvive_BG_07.NewActivty_SubwaySurvive_BG_07"
  else
    return "/Game/Mod/Lobby/Split/NewActivity/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_Default_BG1.NewActivty_Default_BG1"
  end
end
local _InitRemakeProgressData = function(remakeList, data)
  if not data then
    return
  end
  local itemData = {}
  itemData.ID = data.ID
  itemData.Rewards = data.Drop and data.Drop[1]
  itemData.RequireScore = data.Condition and data.Condition[1]
  itemData.Index = data.Index
  itemData.Status = data.Status
  itemData.ExpireTime = data.Drop and data.Drop[1] and data.Drop[1].expireTime
  itemData.CostID = data.CostList and data.CostList[1] and data.CostList[1].itemId or nil
  remakeList[data.Index] = itemData
end
function ActivityUtil.GetProgressDataByType(tActData)
  local tRemakeList = {}
  local nGetIndex = 1
  local maxScore = 0
  local curScore = 0
  local curPersonProgress, curPersonMaxProgress
  if tActData.Type == E_ActType.AVALON_PROGRESS or tActData.Type == E_ActType.GIFT_INTIMACY_DOUBLE then
    for k, v in ipairs(tActData.List) do
      _InitRemakeProgressData(tRemakeList, v)
      if v.Status == E_ActivityProgressStatus.Done then
        nGetIndex = k
      end
      maxScore = v.Total or 0
      curScore = tActData.other.progress and tActData.other.progress[k] or 0
    end
  end
  if tActData.Type == E_ActType.PROGRESS then
    curScore = tActData.other.max_score or 0
    for k, v in ipairs(tActData.List) do
      _InitRemakeProgressData(tRemakeList, v)
      if v.Status == E_ActivityProgressStatus.Done then
        nGetIndex = k
      end
      if v.Index == 1 then
        maxScore = 0 < v.Condition[2] and v.Condition[2] or 200
      end
      maxScore = v.Total or 0
    end
  end
  if tActData.Type == E_ActType.ACTIVITY_CENTER_KR_PROGRESS then
    curScore = tActData.other.progress or 0
    curPersonProgress = tActData.other.personal_progress
    for k, v in ipairs(tActData.List) do
      _InitRemakeProgressData(tRemakeList, v)
      if v.Status == E_ActivityProgressStatus.Done then
        nGetIndex = k
      end
      maxScore = v.Condition[1] + maxScore
      if v.Index == 1 then
        curPersonMaxProgress = v.Condition[3]
      end
    end
  end
  return tRemakeList, maxScore, curScore, nGetIndex, curPersonProgress, curPersonMaxProgress
end
function ActivityUtil.GetCurActTaskData(activity)
  local nAllTaskNum = 0
  local nCurDoneNum = 0
  nAllTaskNum = #activity.List
  for _, subActivity in ipairs(activity.List) do
    if subActivity.Type == E_ActType.ITEM_EXCHANGE then
      if subActivity.Status == E_ActivityProgressStatus.Get then
        nCurDoneNum = nCurDoneNum + 1
      end
    elseif subActivity.Status == E_ActivityProgressStatus.Get then
      nCurDoneNum = nCurDoneNum + 1
    end
  end
  return nCurDoneNum, nAllTaskNum
end
function ActivityUtil.JumpUrl(url, total, actID)
  ActivityNewSystem.JumpUrl(url, total, actID, true)
end
function ActivityUtil.GetImportentActData()
  local nActType = E_ActType.ACTIVITY_TYPE_LINK
  local E_ImportantActTab = 12
  local result = {
    bHasAct = false,
    sImageUrl = "",
    sJumpUrl = "",
    nEndTime = 0,
    nNotShowTime = 0,
    isGoExchange = 0
  }
  local data = ActivityNewSystem.GetActivityByTypeAndLabel(nActType, E_ImportantActTab)
  if data then
    log_tree("ActivityUtil.GetImportentActData", data)
    local nowTime = TimeUtil.GetServerTimeInSec()
    local severData = ActivityNewSystem.GetServerDataByID(data.ID)
    if not severData then
      return result
    end
    result.bHasAct = severData.cfg and severData.cfg.priority_begin_time and severData.cfg.priority_end_time and nowTime >= severData.cfg.priority_begin_time and nowTime <= severData.cfg.priority_end_time
    result.sImageUrl = data.ImgUrl
    result.sJumpUrl = data.ImgLink
    result.nEndTime = data.StartTime
    result.nNotShowTime = data.EndTime
    result.isGoExchange = data.cond_2
  end
  return result
end
function ActivityUtil.GetRechargeTipsData()
  local nActType = E_ActType.ACTIVITY_TYPE_LINK
  local nTabType = E_ActSwitchType.IOSOfUSRechargeTips
  local result = {
    bHasAct = false,
    sDescription = "",
    sJumpUrl = "",
    nEndTime = 0
  }
  local data = ActivityNewSystem.GetActivityByTypeAndLabel(nActType, nTabType)
  if data then
    local nowTime = TimeUtil.GetServerTimeInSec()
    local severData = ActivityNewSystem.GetActivityByID(data.ID)
    if not severData then
      return result
    end
    local begin_time = severData.StartTime
    local end_time = severData.EndTime
    if begin_time and end_time then
      result.bHasAct = nowTime >= begin_time and nowTime <= end_time
    end
    result.sDescription = data.Title or ""
    result.sJumpUrl = data.ImgLink or ""
  end
  log_tree("ActivityUtil.GetRechargeTipsData", result)
  return result
end
function ActivityUtil.GetLobbyBottomEntranceData()
  local nTabType = E_ActSwitchType.LobbyMidBottomEntrance
  local tDatas = ActivityNewSystem.GetActivityByLabel(nTabType)
  if #tDatas <= 0 then
    return
  end
  local tData = tDatas[1]
  local nNowTime = TimeUtil.GetServerTimeInSec()
  local nStartTime = tData.StartTime or 0
  local nEndTime = tData.EndTime or 0
  if nNowTime < nStartTime or nNowTime > nEndTime then
    return
  end
  local result = {
    jump = tData.ImgLink,
    start_time = tData.StartTime,
    end_time = tData.EndTime,
    duration = 0,
    cdn = tData.ImageUrl,
    id = tData.ID,
    bNotBubble = true
  }
  log(bWriteLog and string.format("ActivityUtil.GetLobbyBottomEntranceData. outOfTimeRange=%s", tostring(nNowTime < nStartTime or nNowTime > nEndTime)))
  log_tree("ActivityUtil.GetLobbyBottomEntranceData", result)
  return result
end
function ActivityUtil.GetTimeStr(nTotalTime, nDay)
  if not nTotalTime or nTotalTime <= 0 then
    return ""
  end
  local days = math.floor(nTotalTime / 86400)
  local hours = math.fmod(math.floor(nTotalTime / 3600), 24)
  local mins = math.fmod(math.floor(nTotalTime / 60), 60)
  local seconds = math.fmod(math.floor(nTotalTime), 60)
  nDay = nDay or 2
  if days >= nDay then
    return LocUtil.LocalizeResFormat(4409, days + 1)
  else
    if 0 < days then
      hours = hours + days * 24
    end
    return string.format("%02d:%02d:%02d", hours, mins, seconds)
  end
end
local cycle2ResId = {
  [0] = 512288,
  [1] = 512289,
  [7] = 512290
}
function ActivityUtil.GetShareDescByAct(id)
  local data = ActivityNewSystem.GetServerDataByID(id)
  local resId = cycle2ResId[data.cfg.cycle_type or 0]
  local drop = TableUtil.GetTableValue(data, "cfg", "award", 1, "drop", 1)
  local itemId = drop and drop.item_id
  if not itemId then
    return ""
  end
  local itemData = CDataTable.GetTableData("Item", itemId)
  local itemName = FuncUtil.GetItemNameWithLimitTime(itemData.ItemName, drop.item_expire_time or 0)
  local num = drop and drop.item_num or 1
  return LocUtil.LocalizeResFormat(resId, itemName, num), itemId, num, drop.item_expire_time
end
function ActivityUtil.ShouldLoadBHAd()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsBLUEHOLE() then
    return false
  end
  local BShowBHAd = HDmpveRemote.HDmpveRemoteConfigGetBool("BShowBHAd", false)
  if not BShowBHAd then
    log(bWriteLog and "ActivityUtil.ShowBHAdOrNot. BShowBHAd is false")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bIsDiffDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eBHAdToday, true)
  if not bIsDiffDate then
    log(bWriteLog and "ActivityUtil.ShowBHAdOrNot. today has shown ad")
    return false
  end
  return true
end
function ActivityUtil.ShowBHAdOrNot()
  log(bWriteLog and "ActivityUtil.ShowBHAdOrNot.")
  if not ActivityUtil.ShouldLoadBHAd() then
    return
  end
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  AdvertiseSdk:LoadAdWithoutPrize()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eBHAdToday)
end
function ActivityUtil.PreloadBHAd()
  if not ActivityUtil.ShouldLoadBHAd() then
    return
  end
  local actDataList = ActivityNewSystem.GetActivityByLabel(ActivitySwitchType.AdvertisingSpin)
  if next(actDataList) then
    log(bWriteLog and "ActivityUtil.PreloadBHAd.  has ad act  return")
    return
  end
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  AdvertiseSdk:LoadAdWithoutPrize(true)
end
function ActivityUtil.GetReviseExpireTime(InReviseStr, ItemId)
  if not InReviseStr or InReviseStr == "" then
    return 0
  end
  if ItemId then
    local ItemCfg = CDataTable.GetTableData("Item", ItemId)
    if not ItemCfg then
      return 0
    end
    if ItemCfg.ValidTimes ~= 0 or ItemCfg.ExTime ~= "" then
      return 0
    end
  end
  local expireTime = 0
  local TimeStr = StringUtil.Split(InReviseStr, ",")[2]
  expireTime = TimeUtil.TimeStringToUnixstamp(TimeStr)
  return expireTime
end
function ActivityUtil.GetExpireTimeStr(InExpireTs)
  if not InExpireTs or InExpireTs == 0 then
    return ""
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() or PublishRegionMacros.IsBLUEHOLE() then
    local TimeStr = TimeUtil.FormatTime_YMDHM(InExpireTs, true)
    return LocUtil.LocalizeResFormat(4425, TimeStr)
  else
    local TimeStr = TimeUtil.FormatTime_YMDHM(InExpireTs)
    return LocUtil.LocalizeResFormat(19217, TimeStr)
  end
end
function ActivityUtil.CombineExpireTs(InExpireTs, InExtraTable)
  if InExpireTs == nil or InExpireTs == 0 then
    return
  end
  InExtraTable = InExtraTable or {}
  InExtraTable.ShowUseTime = true
  InExtraTable.bIsLimit = true
  InExtraTable.time_s = ActivityUtil.GetExpireTimeStr(InExpireTs)
end
function ActivityUtil.IsInActivityRealTime(actData)
  if not actData then
    return
  end
  local StartTime = actData.StartTime or 0
  local EndTime = actData.EndTime or 0
  if TimeUtil.UnixTimeBetween(StartTime, EndTime) == 0 then
    return true
  end
  return false
end
local _exchangeTLog = function(act, itemId, num)
  local reason_str = string.format("id:%s_num:%s", itemId, num)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ExchangeExecution, act, reason_str)
end
function ActivityUtil.SendExchange(act, itemId, num, posId)
  log(bWriteLog and "ActivityUtil.SendExchange act:" .. tostring(act))
  log(bWriteLog and "ActivityUtil.SendExchange itemId:" .. tostring(itemId))
  log(bWriteLog and "ActivityUtil.SendExchange num:" .. tostring(num))
  log(bWriteLog and "ActivityUtil.SendExchange posId:" .. tostring(posId))
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_do_exchange_by_activity_id_req(act, itemId, num, {pos_id = posId})
  _exchangeTLog(act, itemId, num)
end
function ActivityUtil.SendExchangeWithSource(act, itemId, num, exchangeData)
  log(bWriteLog and "ActivityUtil.SendExchangeWithSource act:" .. tostring(act))
  log(bWriteLog and "ActivityUtil.SendExchangeWithSource itemId:" .. tostring(itemId))
  log(bWriteLog and "ActivityUtil.SendExchangeWithSource num:" .. tostring(num))
  log_tree("ActivityUtil.SendExchangeWithSource exchangeData", exchangeData)
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_do_exchange_by_activity_id_req(act, itemId, num, {
    pos_id = exchangeData.pos,
    source = exchangeData.source
  })
  _exchangeTLog(act, itemId, num)
end
return ActivityUtil