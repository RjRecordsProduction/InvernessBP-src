local UnknowPassUtil = {}
local EXPIRE_TYPE_SEASON_LIMIT = 1
function UnknowPassUtil.GetSeasonIndex()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local season = UnknowPassMacro.UnKnowPass_NextSeason - 1
  return season % UnknowPassSystem.VersionSeasonNum
end
function UnknowPassUtil.GetCurValueByUid(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if profile then
    local UPassIsBuy, UPassIsShow, UPassKeepBuy, UPassValue = LogicFriend.ParsePassInfo(profile.upass)
    log(bWriteLog and "UnknowPassSystem.GetCurValueByUid " .. UPassValue)
    return UPassValue
  else
    return 0
  end
end
function UnknowPassUtil.GetVersionNumber()
  UnknowPassUtil.GetUnknowPassNextSeason()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local res = ""
  local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassMacro.UnKnowPass_NextSeason - 1)
  if cfg then
    res = cfg.ResourseVerion
  end
  log(bWriteLog and "UnknowPassSystem.GetVersionNumber " .. res)
  if res == "" then
    return UnknowPassSystem.VersionNum_1_2_0
  end
  return res
end
function UnknowPassUtil.IsNewSeason()
  UnknowPassUtil.GetUnknowPassNextSeason()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  log(bWriteLog and "[  UnKnowPass_NextSeason  " .. tostring(UnknowPassMacro.UnKnowPass_NextSeason))
  log(bWriteLog and "[  Season  " .. tostring(UnknowPassSystem.Season))
  return tonumber(UnknowPassMacro.UnKnowPass_NextSeason) - 1 ~= tonumber(UnknowPassSystem.Season)
end
function UnknowPassUtil.GetUnknowPassNextSeason()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  if UnknowPassMacro.UnKnowPass_NextSeason_HasSet then
    return
  end
  if UnknowPassSystem.Season and UnknowPassSystem.Season > 0 then
    UnknowPassMacro.UnKnowPass_NextSeason = UnknowPassSystem.Season + 1
    UnknowPassMacro.UnKnowPass_NextSeason_HasSet = true
    return
  else
    local TimeUtil = require("client.common.time_util")
    local SeasonTable = CDataTable.GetTable("UnknowPassSeasonTimeCfg")
    local NowTime = TimeUtil.GetServerTimeInSec()
    for i, cfg in pairs(SeasonTable) do
      local timeString = cfg.SeasonStartTime
      local startTime = TimeUtil.TimeStringToUnixstamp(timeString)
      if NowTime < startTime then
        UnknowPassMacro.UnKnowPass_NextSeason = cfg.SeasonId
        UnknowPassMacro.UnKnowPass_NextSeason_HasSet = true
        return
      end
    end
  end
  UnknowPassMacro.UnKnowPass_NextSeason = 22
  UnknowPassMacro.UnKnowPass_NextSeason_HasSet = true
end
function UnknowPassUtil.CheckInSeasonLocal()
  local TimeUtil = require("client.common.time_util")
  local SeasonTable = CDataTable.GetTable("UnknowPassSeasonTimeCfg")
  local NowTime = TimeUtil.GetServerTimeInSec()
  for i, cfg in pairs(SeasonTable) do
    local startTime = TimeUtil.TimeStringToUnixstamp(cfg.SeasonStartTime)
    local endTime = TimeUtil.TimeStringToUnixstamp(cfg.SeasonEndTime)
    if NowTime <= endTime and NowTime >= startTime then
      return true
    end
  end
  return false
end
function UnknowPassUtil.GetSeasonStartTime()
  local cfg = UnknowPassSystem.SeasonInfo.cfg
  if not cfg then
    local TimeUtil = require("client.common.time_util")
    return TimeUtil.GetServerTimeInSec()
  end
  return cfg.begin_timestamp
end
function UnknowPassUtil.GetNextSeasonStartTime()
  local TimeUtil = require("client.common.time_util")
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local timeString = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassMacro.UnKnowPass_NextSeason).SeasonStartTime
  return TimeUtil.TimeStringToUnixstamp(timeString)
end
function UnknowPassUtil.GetSpecificSeasonEndTime(seasonNum)
  local TimeUtil = require("client.common.time_util")
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local seasonData = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", seasonNum)
  if seasonData then
    local timeString = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", seasonNum).SeasonEndTime
    return TimeUtil.TimeStringToUnixstamp(timeString)
  end
  return 0
end
function UnknowPassUtil.IsSeriesAStart()
  local startSeasonCfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.A])
  if not (startSeasonCfg and startSeasonCfg.SeasonStartTime) or startSeasonCfg.SeasonStartTime == "" then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local startTime = TimeUtil.TimeStringToUnixstamp(startSeasonCfg.SeasonStartTime)
  local nNowTime = TimeUtil.GetServerTimeInSec()
  return startTime <= nNowTime
end
function UnknowPassUtil.CheckVersionValid()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  UnknowPassUtil.GetUnknowPassNextSeason()
  local seasonID = UnknowPassMacro.UnKnowPass_NextSeason - 1
  local currentVersion = Client.GetAppVersion()
  local uObj_seasonCfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", seasonID) or {}
  local versionStart = uObj_seasonCfg.VersionStart
  local version_util = require("client.common.version_util")
  if versionStart and versionStart ~= "" and versionStart ~= "0" and version_util.LowerVersion(currentVersion, versionStart) then
    return false
  end
  return true
end
function UnknowPassUtil.GetWeekStartTimeByIndex(n)
  local cfg = UnknowPassSystem.SeasonInfo.cfg
  if not cfg then
    local TimeUtil = require("client.common.time_util")
    return TimeUtil.GetServerTimeInSec() + 604800
  end
  local weekIndex = tonumber(n) or 1
  local detalTime = (weekIndex - 1) * 604800
  return cfg.begin_timestamp + detalTime
end
function UnknowPassUtil.GetSeasonEndTime()
  local cfg = UnknowPassSystem.SeasonInfo.cfg
  if not cfg then
    local TimeUtil = require("client.common.time_util")
    return TimeUtil.GetServerTimeInSec()
  end
  return cfg.end_timestamp
end
function UnknowPassUtil.ParseUpassInfo(upassInfo)
  if upassInfo ~= nil then
    local is_buy = 0
    local is_uishow = false
    if upassInfo.switch == nil then
      is_uishow = false
    else
      is_uishow = upassInfo.switch.ui or is_uishow
    end
    is_buy = upassInfo.is_buy or is_buy
    return is_buy, is_uishow and 1 or 0, upassInfo.keep_buy or 0, upassInfo.cur_value or 0, upassInfo.pass_type or 0
  end
end
function UnknowPassUtil.GetPassTitle()
  return LocUtil.GetLocalizeResStr(4547)
end
function UnknowPassUtil.GetPassTips()
  local tips = ""
  local NMaxLevel = UnknowPassSystem.MaxLevel
  if UnknowPassSystem.Season <= 51 then
    tips = LocUtil.LocalizeFormatConcatenation(42920, NMaxLevel, NMaxLevel, NMaxLevel)
  else
    local seasonTime = UnknowPassUtil.GetPeriodText()
    tips = LocUtil.LocalizeFormatConcatenation(76748, NMaxLevel, NMaxLevel, NMaxLevel, seasonTime)
  end
  return tips
end
function UnknowPassUtil.SetSeasonInfo(nameTextObj, timeTextObj)
  if UnknowPassSystem.SeasonInfo then
    local seasonName = UnknowPassSystem.SeasonInfo.cfg.season_name
    if nil ~= nameTextObj and seasonName then
      nameTextObj:SetText(seasonName)
    end
    local seasonTime = UnknowPassUtil.GetPeriodText()
    if nil ~= timeTextObj and seasonTime then
      timeTextObj:SetText(seasonTime)
    end
  end
end
function UnknowPassUtil.GetPeriodText()
  local TimeUtil = require("client.common.time_util")
  local startTime = UnknowPassUtil.GetWeekStartTimeByIndex(1)
  local endTime = UnknowPassUtil.GetSeasonEndTime()
  local seasonTime = TimeUtil.FormatTime_timeFrame(startTime, endTime, false, true)
  return seasonTime
end
function UnknowPassUtil.GetPassSeasonByItemID(itemid)
  local cfg = CDataTable.GetTable("UnknowPassSeasonTimeCfg")
  for season, singleCfg in pairs(cfg) do
    if itemid == singleCfg.NormalItemId or itemid == singleCfg.EliteItemId then
      return tonumber(season)
    end
  end
end
function UnknowPassUtil.CheckCloseUI(config)
  if UIManager.GetUI(config) then
    UIManager.CloseUI(config)
  end
end
function UnknowPassUtil.GetAwardList(reward_list)
  local itemList = {}
  if reward_list then
    for i, v in ipairs(reward_list) do
      table.insert(itemList, {
        res_id = v.item_id,
        count = v.item_num,
        valid_hours = v.item_expire_time,
        showType = v.item_show_type,
        extra = v.extra
      })
    end
  end
  return itemList
end
function UnknowPassUtil.IsRPSeasonTimeLimitItem(resId)
  if not resId then
    return false
  end
  if not resId then
    return false
  end
  if resId == 20001 then
    return true
  end
  local cfg = CDataTable.GetTableData("SeasonCardsConfig", resId)
  if cfg and cfg.TimeLimitType == EXPIRE_TYPE_SEASON_LIMIT then
    return true
  end
  return false
end
function UnknowPassUtil.IsSeasonTimeLimitItem(resId)
  if UnknowPassUtil.IsRPSeasonTimeLimitItem(resId) then
    return true
  end
  return false
end
function UnknowPassUtil.GetSeasonEndTimeStr()
  local tSeasonCfg = CDataTable.GetTableData("SeasonInfo", DataMgr.season_id)
  local TimeUtil = require("client.common.time_util")
  local nTimeNum = TimeUtil.TimeStringToUnixstamp(tSeasonCfg.EndTime)
  local sTimeStr = LocUtil.LocalizeResFormat(44769, TimeUtil.FormatTime_YMDHM(nTimeNum, false, true))
  return sTimeStr
end
function UnknowPassUtil.SeasonTimeLimitItemHandler(tAllItem)
  local sTimeStr = UnknowPassUtil.GetSeasonEndTimeStr()
  for _, v in pairs(tAllItem) do
    if UnknowPassUtil.IsSeasonTimeLimitItem(v.res_id) then
      v.extra = {is_limit = true, time_s = sTimeStr}
    end
  end
  return tAllItem
end
function UnknowPassUtil.RPItemSeasonTimeLimit(nItemId)
  local sTimeStr = UnknowPassUtil.GetSeasonEndTimeStr()
  if UnknowPassUtil.IsSeasonTimeLimitItem(nItemId) then
    return {is_limit = true, time_s = sTimeStr}
  end
end
return UnknowPassUtil