local NoticesConst = require("client.logic.Notice.NoticesConst")
local StringUtil = require("common.string_util")
local TimeUtil = require("client.common.time_util")
local local local NoticesUtil = {}
function NoticesUtil.GetITopNotices(noticesList, iTopScene)
  log_format("NoticesUtil.GetITopNotices. iTopScene=%s ", tostring(iTopScene))
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  noticesList = noticesList or {}
  local IMSDKNotice = import("IMSDKNotice")
  local IMSDKNoticeInstance = IMSDKNotice.GetInstance()
  local iTopNotices = IMSDKNoticeInstance:GetNotice(iTopScene)
  if iTopNotices then
    for k, v in pairs(iTopNotices) do
      local noticeData = NoticesUtil.GenerateNoticeData(v, NoticesConst.DataSource.iTop, k)
      if noticeData ~= nil then
        noticeData.itopScene = iTopScene
        table.insert(noticesList, noticeData)
        StoreUtils.AddParameterToJumpURL(noticeData, "jump", StoreConst.source_NoticeJumpToCrate)
      end
    end
  end
  log_tree("NoticesUtil.GetITopNotices, noticesList = ", noticesList)
end
local IsNormalNotice = function(v)
  if not v or not v.cfg then
    return false
  end
  if v.cfg.back_int_value and (v.cfg.back_int_value == ActivityBackUpIntType.Gamelet or v.cfg.back_int_value == ActivityBackUpIntType.TxMission) then
    return false
  end
  return true
end
local IsTxMissionNotice = function(v)
  if not v or not v.cfg then
    return false
  end
  if not v.cfg.back_int_value or v.cfg.back_int_value ~= ActivityBackUpIntType.TxMission then
    return false
  end
  return true
end
function NoticesUtil.GetActivityNotices(noticesList)
  log(bWriteLog and "NoticesUtil.GetActivityNotices.")
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local GameletUtil = require("client.slua.logic.gamelet.GameletUtil")
  noticesList = noticesList or {}
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataType = ActivityNewSystem.GetServerDataByType(ActivityType.NOTICE_INFO)
  if activityDataType then
    for k, v in pairs(activityDataType) do
      if IsNormalNotice(v) then
        local noticeData = NoticesUtil.GenerateNoticeData(v, NoticesConst.DataSource.Activity)
        if noticeData ~= nil then
          table.insert(noticesList, noticeData)
          StoreUtils.AddParameterToJumpURL(noticeData, "jump", StoreConst.source_NoticeJumpToCrate)
        end
      end
    end
  end
  log_tree("NoticesUtil.GetActivityNotices, notices_list = ", noticesList)
end
function NoticesUtil.GetTxMissionNotices(notices_list)
  log(bWriteLog and "NoticesUtil.GetTxMissionNotices")
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  notices_list = notices_list or {}
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataType = ActivityNewSystem.GetServerDataByType(ActivityType.NOTICE_INFO)
  if activityDataType then
    for k, v in pairs(activityDataType) do
      if IsTxMissionNotice(v) then
        local noticeData = NoticesUtil.GenerateNoticeData(v, NoticesConst.DataSource.Activity)
        if noticeData ~= nil then
          table.insert(notices_list, noticeData)
          StoreUtils.AddParameterToJumpURL(noticeData, "jump", StoreConst.source_NoticeJumpToCrate)
        end
      end
    end
  end
  log_tree("NoticesUtil.GetTxMissionNotices, notices_list = ", notices_list)
end
function NoticesUtil.SortNotices(noticesList, desc)
  if not noticesList or #noticesList <= 0 then
    return
  end
  table.sort(noticesList, function(a, b)
    if desc and desc == true then
      if a.Sort > b.Sort then
        return true
      elseif a.Sort < b.Sort then
        return false
      else
        return a.MsgId > b.MsgId
      end
    elseif a.Sort < b.Sort then
      return true
    elseif a.Sort > b.Sort then
      return false
    else
      return a.MsgId > b.MsgId
    end
  end)
end
function NoticesUtil.GenerateNoticeData(v, type, index)
  log_format("NoticesUtil.GenerateNoticeData. v=%s, type=%s, index=%s ", tostring(v), tostring(type), tostring(index))
  if not v then
    log(bWriteLog and "NoticesUtil.GenerateNoticeData. v is nil")
    return nil
  end
  local notice = {}
  notice.ClickTime = 0
  if type == NoticesConst.DataSource.iTop then
    notice.Type = NoticesConst.DataSource.iTop
    notice.Sort = tonumber(v.MsgSortWeight or 0)
    notice.MsgId = tostring(v.MsgId or 0)
    notice.StartTime = tonumber(v.StartTime or 0)
    notice.EndTime = tonumber(v.EndTime or 0)
    notice.StartDaily = 0
    notice.EndDaily = 0
    notice.MsgTitle = v.MsgTitle or ""
    notice.MsgContentType = v.MsgContentType or 1
    notice.MsgContent = v.MsgContent or ""
    notice.PicPath = ""
    notice.PicTitle = ""
    if v.PicArray then
      for kk, vv in pairs(v.PicArray) do
        if 0 < string.len(vv.PicPath) then
          notice.PicPath = vv.PicPath
          notice.PicTitle = vv.PicTitle
          break
        end
      end
    end
    notice.MsgUrl = v.MsgUrl or ""
    local strMsgEditCond = tostring(v.MsgEditCond or "")
    local extraCondTable = strMsgEditCond ~= "" and json.decode(strMsgEditCond) or {}
    notice.DisplayTimes = tonumber(extraCondTable.displayTimes or 0)
    notice.ValidTime = tostring(extraCondTable.validTime or "")
    notice.PauseTime = tonumber(extraCondTable.pauseTime or 0)
    notice.ThumbNail = tostring(extraCondTable.thumbNail or "")
    notice.EventCenter = tostring(extraCondTable.eventCenter or "")
    notice.VideoPath = tostring(extraCondTable.videoPath or "")
    notice.VersionStart = tostring(extraCondTable.versionStart or "")
    notice.VersionEnd = tostring(extraCondTable.versionEnd or "")
    notice.DisplaySeconds = tonumber(extraCondTable.displaySeconds or 0)
    notice.BluetoothUpdate = tonumber(extraCondTable.bluetoothUpdate or 0)
    notice.ExternalWebview = tonumber(extraCondTable.externalWebview or 0)
    notice.BlockChannelpak = tonumber(extraCondTable.blockChannelpak or 0)
    notice.IsjaguarShow = tonumber(extraCondTable.isjaguarShow or 0)
    local itemOwnedOrigin = tonumber(extraCondTable.itemOwned) or 0
    notice.itemOwned = math.abs(itemOwnedOrigin)
    notice.itemOwnedForever = itemOwnedOrigin < 0
    notice.DolphinId = tonumber(extraCondTable.DolphinId or 0) or 0
    notice.AppID = tostring(extraCondTable.AppID or "")
    notice.ActivityRedPointStatus = tonumber(extraCondTable.activityReddot) or 0
    if extraCondTable.noticeSortWeight then
      notice.Sort = tonumber(extraCondTable.noticeSortWeight or 0)
    end
  else
    notice.Type = type
    notice.MsgId = tostring(v.cfg.activity_id or 0)
    notice.StartTime = v.cfg.start_time or 0
    notice.EndTime = v.cfg.end_time or 0
    notice.StartDaily = v.cfg.daily_start_time or 0
    notice.EndDaily = v.cfg.daily_end_time or 0
    notice.MsgTitle = v.cfg.activity_name or ""
    notice.PicTitle = v.cfg.activity_name or ""
    notice.MsgContentType = NoticesConst.NoticeContentType.Text
    if v.cfg.activity_image_link ~= "" then
      notice.MsgContentType = NoticesConst.NoticeContentType.ImageOrBlueprint
    end
    notice.MsgContent = v.cfg.activity_desc or ""
    notice.PicPath = v.cfg.activity_image_link or ""
    notice.MsgUrl = v.cfg.page_link or ""
    notice.Sort = v.cfg.show_order or 0
    notice.VersionStart = v.cfg.version or "0.0.0.00000"
    notice.VersionEnd = "50.50.0.00000"
    notice.AppID = v.cfg.gameid_list or ""
    if v.cfg.award and v.cfg.award[1] then
      notice.VersionEnd = v.cfg.award[1].extra_cond or "50.50.0.00000"
    end
    notice.ThumbNail = v.cfg.mail_title or ""
    notice.EventCenter = v.cfg.mail_content or ""
    notice.VideoPath = v.cfg.remark_content or ""
    notice.bEnableRegionalizationImageDownload = v.cfg.back_int_value == ActivityBackUpIntType.RegionCDN
    if v.cfg.award and v.cfg.award[1] and v.cfg.award[1].cond then
      local tmpcond = StrSplit(v.cfg.award[1].cond, ",")
      notice.DisplayTimes = tonumber(tmpcond[1] or 0)
      notice.PauseTime = tonumber(tmpcond[2] or 0)
      notice.DisplaySeconds = tonumber(tmpcond[3] or 0)
      notice.ExternalWebview = tonumber(tmpcond[4] or 0)
      notice.BlockChannelpak = tonumber(tmpcond[5] or 0)
      local itemOwnedOrigin = tonumber(tmpcond[6]) or 0
      notice.itemOwned = math.abs(itemOwnedOrigin)
      notice.itemOwnedForever = itemOwnedOrigin < 0
      notice.ProcessNewSortDay = tonumber(tmpcond[7] or 0)
      notice.NewSort = tonumber(tmpcond[8] or 0)
    else
      notice.DisplayTimes = 0
      notice.PauseTime = 0
      notice.DisplaySeconds = 0
      notice.ExternalWebview = 0
      notice.BlockChannelpak = 0
      notice.itemOwned = 0
      notice.ProcessNewSortDay = 0
      notice.NewSort = 0
    end
    if tonumber(v.cfg.type) == ActivityType.NOTICE_INFO then
      notice.ShowCountDown = tonumber(v.cfg.back_up_one) == 1
    end
    if 0 < notice.ProcessNewSortDay then
      local endTime = notice.StartTime + notice.ProcessNewSortDay * 86400
      if TimeUtil.UnixTimeBetween(notice.StartTime, endTime) == 0 then
        notice.Sort = notice.NewSort
      end
    end
    if v.cfg.back_up_two then
      local params = StringUtil.ParseURLParams(v.cfg.back_up_two)
      notice.LoginTimes = tonumber(params.login_times or 0) or 0
    end
  end
  log_tree("NoticesUtil.GenerateNoticeData. notice = ", notice)
  return notice
end
function NoticesUtil.CanShowForBaseParams(notice)
  if not NoticesUtil.CheckForDisplayTimes(notice, true) then
    log(bWriteLog and "notice failed due to display times")
    return false
  end
  if not NoticesUtil.CanShowForBaseParamsExpectDisplayTimes(notice) then
    log(bWriteLog and "notice failed due to other params")
    return false
  end
  return true
end
function NoticesUtil.CheckForDisplayTimes(notice, ifPop)
  if notice.DisplayTimes and notice.DisplayTimes > 0 then
    local preDisplayTimes = NoticesUtil.GetDisplayTotalTimes(notice)
    if preDisplayTimes >= notice.DisplayTimes then
      log(bWriteLog and "NoticesUtil.CheckForDisplayTimes return false. MsgId=" .. tostring(notice.MsgId) .. ", DisplayTimes=" .. tostring(notice.DisplayTimes) .. ", preDisplayTimes=" .. tostring(preDisplayTimes))
      return false
    end
  end
  if ifPop and notice.DisplayTimes then
    if notice.DisplayTimes < 0 then
      log(bWriteLog and "NoticesUtil.CheckForDisplayTimes not show negative")
    end
    return notice.DisplayTimes >= 0
  end
  return true
end
function NoticesUtil.CanShowForBaseParamsExpectDisplayTimes(notice)
  if not NoticesUtil.CheckForLoginTimes(notice) then
    return false
  end
  if not NoticesUtil.CheckForPauseTime(notice) then
    return false
  end
  if not NoticesUtil.CheckForValidTime(notice) then
    return false
  end
  if not NoticesUtil.CheckForStartEndDaily(notice) then
    return false
  end
  if not NoticesUtil.CheckForStartEndVersion(notice) then
    return false
  end
  if not NoticesUtil.CheckForBluetoothUpdate(notice) then
    return false
  end
  if not NoticesUtil.CheckForDownload(notice) then
    return false
  end
  if not NoticesUtil.CheckForBlockChannelpak(notice) then
    return false
  end
  if not NoticesUtil.CheckForDolphinId(notice) then
    return false
  end
  if not NoticesUtil.CheckForUnownedItems(notice) then
    return false
  end
  return true
end
function NoticesUtil.CheckForLoginTimes(notice)
  if notice.LoginTimes and notice.LoginTimes > 0 then
    local preLoginTimes = NoticesUtil.GetTodayLoginTimes()
    if preLoginTimes < notice.LoginTimes then
      log(bWriteLog and "NoticesUtil.CheckForLoginTimes return false. MsgId=" .. tostring(notice.MsgId) .. ", LoginTimes=" .. tostring(notice.LoginTimes) .. ", preLoginTimes=" .. tostring(preLoginTimes))
      return false
    end
  end
  return true
end
function NoticesUtil.CheckForPauseTime(notice)
  if notice.PauseTime and notice.PauseTime > 0 then
    local preShowTime = NoticesUtil.GetShowTime(notice)
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if 0 < preShowTime and curTime - preShowTime < notice.PauseTime * 60 * 60 then
      log(bWriteLog and "NoticesUtil.CheckForPauseTime return false. MsgId=" .. tostring(notice.MsgId) .. ", PauseTime=" .. tostring(notice.PauseTime) .. ", preShowTime=" .. tostring(preShowTime))
      return false
    end
  end
  return true
end
function NoticesUtil.CheckForValidTime(notice)
  local TimeUtil = require("client.common.time_util")
  if notice.ValidTime and notice.ValidTime ~= "" and string.len(notice.ValidTime) == 8 then
    local startTimeStr = string.format("%s:%s:00", string.sub(notice.ValidTime, 1, 2), string.sub(notice.ValidTime, 3, 4))
    local endTimeStr = string.format("%s:%s:00", string.sub(notice.ValidTime, 5, 6), string.sub(notice.ValidTime, 7, 8))
    local curTime = TimeUtil.GetServerTimeInSec()
    local curDayStr = TimeUtil.OSDate("!%Y-%m-%d", curTime)
    startTimeStr = curDayStr .. " " .. startTimeStr
    endTimeStr = curDayStr .. " " .. endTimeStr
    local startTime = TimeUtil.TimeStringToUnixstamp(startTimeStr)
    local endTime = TimeUtil.TimeStringToUnixstamp(endTimeStr)
    if curTime < startTime or curTime > endTime then
      log(bWriteLog and "NoticesUtil.CheckForValidTime return false. MsgId=" .. tostring(notice.MsgId) .. ", ValidTime=" .. tostring(notice.ValidTime) .. ", curDayStr=" .. tostring(curDayStr))
      return false
    end
  end
  return true
end
function NoticesUtil.CheckForStartEndDaily(notice)
  local TimeUtil = require("client.common.time_util")
  if notice.StartDaily and notice.StartDaily > 0 and notice.EndDaily and 0 < notice.EndDaily then
    local startTimeStr = TimeUtil.OSDate("!%Y-%m-%d %H:%M:%S", notice.StartDaily)
    startTimeStr = string.sub(startTimeStr, 12)
    local endTimeStr = TimeUtil.OSDate("!%Y-%m-%d %H:%M:%S", notice.EndDaily)
    endTimeStr = string.sub(endTimeStr, 12)
    local curTime = TimeUtil.GetServerTimeInSec()
    local curDayStr = TimeUtil.OSDate("!%Y-%m-%d", curTime)
    startTimeStr = curDayStr .. " " .. startTimeStr
    endTimeStr = curDayStr .. " " .. endTimeStr
    local startTime = TimeUtil.TimeStringToUnixstamp(startTimeStr)
    local endTime = TimeUtil.TimeStringToUnixstamp(endTimeStr)
    if curTime < startTime or curTime > endTime then
      log(bWriteLog and "NoticesUtil.CheckForStartEndDaily return false. MsgId=" .. tostring(notice.MsgId) .. ", StartDaily=" .. tostring(notice.StartDaily) .. ", EndDaily=" .. tostring(notice.EndDaily) .. ", curDayStr=" .. tostring(curDayStr))
      return false
    end
  end
  return true
end
function NoticesUtil.CheckForStartEndVersion(notice)
  local version_util = require("client.common.version_util")
  local currentVersion = Client.GetAppVersion()
  if notice.VersionStart and notice.VersionStart ~= "" and notice.VersionStart ~= "0" and version_util.LowerVersion(currentVersion, notice.VersionStart) then
    log(bWriteLog and "NoticesUtil.CheckForStartEndVersion return false. currentVersion:" .. currentVersion .. " VersionStart:" .. notice.VersionStart .. " MsgId:" .. tostring(notice.MsgId))
    return false
  end
  if notice.VersionEnd and notice.VersionEnd ~= "" and notice.VersionEnd ~= "0" and version_util.HigherVersion(currentVersion, notice.VersionEnd) then
    log(bWriteLog and "NoticesUtil.CheckForStartEndVersion return false. currentVersion:" .. currentVersion .. " VersionEnd:" .. notice.VersionEnd .. " MsgId:" .. tostring(notice.MsgId))
    return false
  end
  return true
end
function NoticesUtil.CheckForBluetoothUpdate(notice)
  if notice.BluetoothUpdate and tonumber(notice.BluetoothUpdate) > 0 then
    local AkAudioSystem = require("client.slua.logic.audio.logic_ak_audio")
    local isUpdate = AkAudioSystem.IsUsingBluetoothWithOptimization()
    log(bWriteLog and "NoticesUtil.CheckForBluetoothUpdate IsUsingBluetooth:" .. tostring(isUpdate))
    if not isUpdate then
      log(bWriteLog and "NoticesUtil.CheckForBluetoothUpdate return false. BluetoothUpdate:" .. tostring(notice.BluetoothUpdate) .. " isUpdate:" .. tostring(isUpdate) .. " MsgId:" .. tostring(notice.MsgId))
      return false
    end
  end
  return true
end
function NoticesUtil.CheckForDownload(notice)
  if notice.MsgContentType ~= 1 and notice.VideoPath ~= "" then
    local AssetPath = ""
    if NoticesUtil.IsUMGNotice(notice.VideoPath) then
      AssetPath = NoticesUtil.GetUMGVideoPath(notice.VideoPath)
    elseif NoticesUtil.IsVideoNotice(notice.VideoPath) then
      AssetPath = DataMgr.GetVideoDownloadPath("./" .. notice.VideoPath)
    end
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {AssetPath})
    local pak_util = require("client.common.pak_util")
    local isFileExist = pak_util.IsFileExist(AssetPath)
    if AssetPath ~= "" and (state ~= PufferConst.ENUM_DownloadState.Done or not isFileExist) then
      log(bWriteLog and "NoticesUtil.CheckForDownload return false. VideoPath:" .. tostring(notice.VideoPath) .. " state:" .. tostring(state) .. " MsgId:" .. tostring(notice.MsgId))
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {AssetPath})
      return false
    end
  end
  return true
end
function NoticesUtil.CheckForBlockChannelpak(notice)
  if notice.BlockChannelpak == 1 then
    local aosShop = Client.GetAOSSHOP()
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    if aosShop == AOSSHOPMacros.ThirdPartyPayment or aosShop == AOSSHOPMacros.Samsung or aosShop == AOSSHOPMacros.Amazon or aosShop == AOSSHOPMacros.HMS then
      log(bWriteLog and "NoticesUtil.CheckForBlockChannelpak return false. aosShop:" .. tostring(aosShop))
      return false
    end
  end
  return true
end
function NoticesUtil.CheckForUnownedItems(notice)
  if notice.itemOwned and notice.itemOwned ~= 0 then
    local NoticesItemOwnedHelper = require("client.logic.Notice.NoticesItemOwnedHelper")
    if NoticesItemOwnedHelper.HasItem(notice.itemOwned, notice.itemOwnedForever) then
      log(bWriteLog and "NoticesUtil.CheckForUnownedItems return false")
      return false
    end
  end
  return true
end
function NoticesUtil.CheckForDolphinId(notice)
  log(bWriteLog and "NoticesUtil.CheckForDolphinId " .. tostring(notice.DolphinId))
  if notice.DolphinId and notice.DolphinId ~= 0 then
    local DolphinConfig = require("client.slua.umg.NewUpdate.dolphin_updater_config")
    local dolphinIDInPakcage = DolphinConfig:GetDolphinChannelId()
    if dolphinIDInPakcage ~= notice.DolphinId then
      return false
    end
  end
  return true
end
function NoticesUtil.GetDisplayTotalTimes(notice)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local displayRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayTotalTimes) or {}
  local key = tostring(notice.Type) .. "_" .. tostring(notice.MsgId)
  log(bWriteLog and "NoticesUtil.GetDisplayTotalTimes, Type=" .. tostring(notice.Type) .. ", MsgId = " .. tostring(notice.MsgId) .. ", TotalTimes = " .. tostring(displayRecord[key] or 0))
  return displayRecord[key] or 0
end
function NoticesUtil.GetShowTime(notice)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local showTimeRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayTimes) or {}
  local key = tostring(notice.Type) .. "_" .. tostring(notice.MsgId)
  local showTime = showTimeRecord[key] or 0
  log(bWriteLog and "NoticesUtil.GetShowTime, Type=" .. tostring(notice.Type) .. ", MsgId = " .. tostring(notice.MsgId) .. ", clickTime = " .. tostring(showTime))
  return showTime
end
function NoticesUtil.IsUMGNotice(videoPath)
  if not videoPath or videoPath == "" then
    return false
  end
  local arrList = StringUtil.Split(videoPath, ".")
  if arrList and 0 < #arrList and arrList[1] == arrList[2] then
    return true
  end
  return false
end
function NoticesUtil.GetUMGVideoPath(videoPath)
  if not NoticesUtil.IsUMGNotice(videoPath) then
    return nil
  end
  local umgBPPath
  local arrPath = StringUtil.Split(videoPath, ".")
  if arrPath and 2 <= #arrPath then
    local strFirst = tostring(arrPath[1])
    local idx = string.find(strFirst, "_UIBP")
    if idx and 0 < idx then
      local activityName = string.sub(strFirst, 0, idx - 1)
      if 3 <= #arrPath then
        local strVersion = arrPath[3]
        umgBPPath = string.format("/Game/Arts_UI/FaceSlap/%s/%s/UIBP/%s", strVersion, activityName, arrPath[1] .. "." .. arrPath[2])
      else
        umgBPPath = string.format("/Game/Arts_UI/FaceSlap/%s/UIBP/%s", activityName, videoPath)
      end
    end
  end
  return umgBPPath
end
function NoticesUtil.IsVideoNotice(videoPath)
  if not videoPath or videoPath == "" then
    return false
  end
  local lowStr = string.lower(videoPath)
  if string.find(lowStr, "%.mp4") then
    return true
  end
  return false
end
function NoticesUtil.IsCollectionPageNotice(notice)
  if not notice then
    return false
  elseif notice.itopScene and notice.itopScene == NoticesConst.ITopScene.MAINTENANCE_NOTICE_BEFORE_LOGIN then
    return false
  elseif notice.MsgContentType ~= NoticesConst.NoticeContentType.Text then
    return false
  elseif notice.VideoPath ~= nil and notice.VideoPath ~= "" then
    return false
  end
  return true
end
function NoticesUtil.IsJKB()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return GlobalData.IsJapanOrKorea() or Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
end
function NoticesUtil.GetPreDisplayIDByType(type)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local displayRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayID) or {}
  local preDisplayID = displayRecord and displayRecord[type] or 0
  log(bWriteLog and string.format("NoticesUtil.GetPreDisplayIDByType. type=%s, preDisplayID=%s", tostring(type), tostring(preDisplayID)))
  return preDisplayID
end
function NoticesUtil.GetDisplayMsgIDs(type)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local displayRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayIDs) or {}
  if displayRecord[type] and displayRecord[type].DisplayID then
    return displayRecord[type].DisplayID
  end
end
function NoticesUtil.GetiTopAndActivityNotices(allNotices)
  local itopList = {}
  local activityList = {}
  if allNotices and #allNotices then
    for i = 1, #allNotices do
      local v = allNotices[i]
      if NoticesUtil.IsCollectionPageNotice(v) then
      elseif tonumber(v.Type) == NoticesConst.DataSource.iTop then
        table.insert(itopList, v)
      elseif tonumber(v.Type) == NoticesConst.DataSource.Activity then
        table.insert(activityList, v)
      end
    end
  end
  return itopList, activityList
end
function NoticesUtil.GetShowNoticesByPreID(shownNotices, noticeList, preNoticeID, type, numberOfShow)
  log(bWriteLog and string.format("NoticesUtil.GetShowNoticesByPreID. type=%s", tostring(type)))
  if not noticeList or #noticeList <= 0 then
    return
  end
  local preIndex = 0
  if preNoticeID and 0 < preNoticeID then
    for k, v in pairs(noticeList) do
      if tonumber(v.Type) == type and tonumber(v.MsgId) == preNoticeID then
        preIndex = k
        break
      end
    end
  end
  local CheckMaxShowNum = function(notice)
    if not shownNotices or #shownNotices < numberOfShow then
      return true
    end
    local iNum = 0
    for i = 1, #shownNotices do
      local v = shownNotices[i]
      if notice.Type == v.Type then
        iNum = iNum + 1
      end
    end
    return iNum < numberOfShow
  end
  local bDisplayList = NoticesUtil.GetDisplayMsgIDs(type) or {}
  local handleList = {}
  for i = 1, preIndex do
    local v = noticeList[i]
    if v.MsgId and not bDisplayList[v.MsgId] and NoticesUtil.CanShowForBaseParams(v) == true and CheckMaxShowNum(v) then
      table.insert(shownNotices, v)
      handleList[v.MsgId] = 1
    end
  end
  for i = preIndex + 1, #noticeList do
    local v = noticeList[i]
    if NoticesUtil.CanShowForBaseParams(v) == true and CheckMaxShowNum(v) then
      table.insert(shownNotices, v)
    end
  end
  for j = 1, preIndex do
    local v = noticeList[j]
    if not handleList[v.MsgId] and NoticesUtil.CanShowForBaseParams(v) == true and CheckMaxShowNum(v) then
      table.insert(shownNotices, v)
    end
  end
end
function NoticesUtil.SaveShowTime(notice)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local showTimeRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayTimes) or {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local key = tostring(notice.Type) .. "_" .. tostring(notice.MsgId)
  log(bWriteLog and "NoticesUtil.SaveShowTime, Type=" .. tostring(notice.Type) .. ", MsgId = " .. tostring(notice.MsgId) .. ", time = " .. tostring(curTime))
  showTimeRecord[key] = curTime
  playerPrefsSystem.SaveTableToFile_N(showTimeRecord, playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayTimes)
end
function NoticesUtil.IsDependResourceReady(noticeData)
  if not noticeData then
    return false
  end
  if NoticesUtil.IsUMGNotice(noticeData.VideoPath) then
    local umgPath = NoticesUtil.GetUMGVideoPath(noticeData.VideoPath)
    local pak_util = require("client.common.pak_util")
    local isFileExist = pak_util.IsFileExist(umgPath)
    log(bWriteLog and "[SY]NoticesUtil.IsDependResourceReady.IsUMGNotice " .. tostring(isFileExist) .. "File : " .. umgPath)
    return isFileExist
  end
  if not noticeData.PicPath or noticeData.PicPath == "" or noticeData.PicPath == "none" then
    log(bWriteLog and "NoticesUtil.IsDependResourceReady. PicPath is unvalid!")
    return true
  end
  local bReady = true
  local path = noticeData.PicPath
  local util = require("client.slua_ui_framework.util")
  path = util.GetUrlByLanguage(path)
  if not NoticesUtil.IsResourceReady(path) then
    bReady = false
  end
  if noticeData.ThumbNail and noticeData.ThumbNail ~= "" and noticeData.ThumbNail ~= "none" then
    local thumbNailPath = util.GetUrlByLanguage(noticeData.ThumbNail)
    if not NoticesUtil.IsResourceReady(thumbNailPath) then
      bReady = false
    end
  end
  return bReady
end
function NoticesUtil.SaveTodayNoShowTime(stat)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local timeStamp = 0
  if stat and 0 < stat then
    local TimeUtil = require("client.common.time_util")
    timeStamp = TimeUtil.GetServerTimeInSec()
  end
  local tb = {time = timeStamp}
  log(bWriteLog and "NoticesUtil.SaveTodayNoShowStatus, stat=" .. tostring(stat) .. ", timeStamp=" .. tostring(timeStamp))
  playerPrefsSystem.SaveTableToFile_N(tb, playerPrefsSystem.ePlayerPrefsType.eNoticeTodayNoShowTime)
end
function NoticesUtil.IsTodayNoShow()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local timeRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeTodayNoShowTime) or {}
  local timeStamp = timeRecord.time or 0
  log(bWriteLog and "NoticesUtil.IsTodayNoShow, timeStamp = " .. tostring(timeStamp))
  local TimeUtil = require("client.common.time_util")
  local currStamp = TimeUtil.GetServerTimeInSec()
  if 0 < timeStamp and math.floor(timeStamp / 86400) == math.floor(currStamp / 86400) then
    return true
  end
  return false
end
function NoticesUtil.IsResourceReady(path)
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  local image_download_config = require("client.slua.logic.image_download.image_download_config")
  local compressSavePath = image_download_mgr:_GetFullFilePath(path, image_download_config.EnumDiskCacheType.VersionUpdate)
  local compressTexture = image_download_mgr:_GetLocalCacheAndFile(path, compressSavePath)
  if slua.isValid(compressTexture) then
    return true
  end
  return false
end
function NoticesUtil.IsPandoraOrGameletUrl(url)
  local jump_utils = require("client.logic.store.jump_utils")
  if jump_utils.IsPanDoraJumpUrl(url) then
    return true
  end
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  return gamelet_interface:IsGameletModule(params.module)
end
function NoticesUtil.IsPandoraOrGameletCanJump(url)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  local jump_utils = require("client.logic.store.jump_utils")
  if jump_utils.IsPanDoraJumpUrl(url) then
    local actid = params.actid
    local pandora_logic = require("client.slua.logic.Pandora.pandora_logic")
    return pandora_logic.ActIsAllReady(actid)
  else
    local appId = params.appId
    local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    return gamelet_interface:IsInterfaceReady(appId)
  end
end
function NoticesUtil.DownloadNoticeDependency()
  log(bWriteLog and "NoticesUtil.DownloadNoticeDependency.")
  local AudioCfg = CDataTable.GetTable("UMGNoticeAudio")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  for i, v in pairs(AudioCfg) do
    log_tree("NoticesUtil.DownloadNoticeDependency v = ", v)
    if v.BankName and v.BankName ~= "" then
      local bankList = StringUtil.Split(v.BankName, ";")
      log_tree("NoticesUtil.DownloadNoticeDependency. BankList= ", bankList)
      PufferManager.DownBankListPak(bankList)
    end
    if NoticesUtil.IsVideoNotice(v.Key) then
      local videoPath = NoticesUtil.GetVideoPath(v.Key)
      local DownloadPath = DataMgr.GetVideoDownloadPath(videoPath)
      if DownloadPath and DownloadPath ~= "" then
        log(bWriteLog and "[SY]NoticesUtil.DownloadNoticeDependency. videoPath" .. tostring(DownloadPath))
        PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {DownloadPath})
      end
    end
  end
end
function NoticesUtil.GetVideoPath(key)
  local arrList = StringUtil.Split(key, ".")
  if arrList and 3 < #arrList and arrList[1] == arrList[2] and string.lower(arrList[4]) == "mp4" then
    local path = string.format("./MoviesPakDir/%s.mp4", arrList[1])
    log(bWriteLog and "[SY]NoticesUtil.GetVideoPath.path" .. tostring(path))
    return path
  end
  return ""
end
function NoticesUtil.SaveDisplayID(notice)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local displayRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayID) or {}
  displayRecord[tonumber(notice.Type)] = tonumber(notice.MsgId)
  log(bWriteLog and "NoticesUtil.SaveDisplayID, Type=" .. tostring(notice.Type) .. ", MsgId = " .. tostring(notice.MsgId))
  playerPrefsSystem.SaveTableToFile_N(displayRecord, playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayID)
end
function NoticesUtil.SaveDisplayMsgIDs(notice)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local displayRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayIDs) or {}
  local noticeType = tonumber(notice.Type)
  local msgId = tostring(notice.MsgId)
  if not displayRecord[noticeType] then
    displayRecord[noticeType] = {
      DisplayID = {}
    }
  end
  displayRecord[noticeType].DisplayID[msgId] = 1
  displayRecord[noticeType].Version = Client.GetApplicationVersion()
  log(bWriteLog and "NoticesUtil.SaveDisplayMsgID, Type=" .. tostring(notice.Type) .. ", MsgId = " .. tostring(notice.MsgId))
  playerPrefsSystem.SaveTableToFile_N(displayRecord, playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayIDs)
end
function NoticesUtil.SaveDisplayTotalTimes(notice)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local displayRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayTotalTimes) or {}
  local key = tostring(notice.Type) .. "_" .. tostring(notice.MsgId)
  if not displayRecord[key] then
    displayRecord[key] = 1
  else
    displayRecord[key] = displayRecord[key] + 1
  end
  log(bWriteLog and "NoticesUtil.SaveDisplayTotalTimes, Type=" .. tostring(notice.Type) .. ", MsgId = " .. tostring(notice.MsgId) .. ", TotalTimes = " .. tostring(displayRecord[key]))
  playerPrefsSystem.SaveTableToFile_N(displayRecord, playerPrefsSystem.ePlayerPrefsType.eNoticeDisplayTotalTimes)
end
function NoticesUtil.SetLastLogoutTime(time)
  log(bWriteLog and "NoticesUtil:SetLastLogoutTime. time:" .. tostring(time))
  if not time or type(time) ~= "number" or time <= 0 then
    log_error("NoticesUtil:SetLastLogoutTime. invalid time parameter:" .. tostring(time))
    return
  end
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local cache = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeLoginTimes)
  if not cache then
    cache = {LastLogoutTime = time, LoginTimesToday = 1}
    log(bWriteLog and "NoticesUtil:SetLastLogoutTime. create new cache, LoginTimesToday:1")
  else
    local lastSaveLogoutTime = cache.LastLogoutTime or 0
    local loginTimes = cache.LoginTimesToday or 0
    if TimeUtil.IsSameDay(lastSaveLogoutTime, time) then
      cache.LoginTimesToday = loginTimes + 1
      log(bWriteLog and "NoticesUtil:SetLastLogoutTime. same day, LoginTimesToday:" .. tostring(cache.LoginTimesToday))
    else
      cache.LoginTimesToday = 1
      log(bWriteLog and "NoticesUtil:SetLastLogoutTime. different day, reset LoginTimesToday to 1")
    end
    cache.LastLogoutTime = time
  end
  playerPrefsSystem.SaveTableToFile_N(cache, playerPrefsSystem.ePlayerPrefsType.eNoticeLoginTimes)
  log(bWriteLog and "NoticesUtil:SetLastLogoutTime. save completed, final LoginTimesToday:" .. tostring(cache.LoginTimesToday))
end
function NoticesUtil.GetTodayLoginTimes()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eNoticeLoginTimes) or {}
  return cache.LoginTimesToday or 1
end
function NoticesUtil.HasGlobalNotices()
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  return NoticesModule:CanShowNotice(NoticesConst.Scene.Lobby)
end
function NoticesUtil.HasTxMissionNotices()
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  return NoticesModule:CanShowNotice(NoticesConst.Scene.TxMission)
end
function NoticesUtil.HasGameletNotices()
  local pak_util = require("client.common.pak_util")
  if not pak_util.IsFileExist(UIManager.UI_Config.Notices_Gamelet_UIBP.path) then
    log(bWriteLog and "NoticesUtil.HasGameletNotices. ui not exist")
    return false
  end
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  return NoticesModule:CanShowNotice(NoticesConst.Scene.Gamelet)
end
function NoticesUtil.CanShowForBaseParamsExpectTimes(notice)
  if not NoticesUtil.CheckForLoginTimes(notice) then
    log(notice.MsgId .. " NoticesUtil.CanShowForBaseParamsExpectTimes return of not CheckForLoginTimes ")
    return false
  end
  if not NoticesUtil.CheckForValidTime(notice) then
    log(notice.MsgId .. " NoticesUtil.CanShowForBaseParamsExpectTimes return of not CheckForValidTime ")
    return false
  end
  if not NoticesUtil.CheckForStartEndDaily(notice) then
    log(notice.MsgId .. " NoticesUtil.CanShowForBaseParamsExpectTimes return of not CheckForStartEndDaily ")
    return false
  end
  if not NoticesUtil.CheckForStartEndVersion(notice) then
    log(notice.MsgId .. " NoticesUtil.CanShowForBaseParamsExpectTimes return of not CheckForStartEndVersion ")
    return false
  end
  if not NoticesUtil.CheckForBluetoothUpdate(notice) then
    log(notice.MsgId .. " NoticesUtil.CanShowForBaseParamsExpectTimes return of not CheckForBluetoothUpdate ")
    return false
  end
  if not NoticesUtil.CheckForDownload(notice) then
    log(notice.MsgId .. " NoticesUtil.CanShowForBaseParamsExpectTimes return of not CheckForDownload ")
    return false
  end
  if not NoticesUtil.CheckForBlockChannelpak(notice) then
    log(notice.MsgId .. " NoticesUtil.CanShowForBaseParamsExpectTimes return of not CheckForBlockChannelpak ")
    return false
  end
  if not NoticesUtil.CheckForDolphinId(notice) then
    log(notice.MsgId .. " NoticesUtil.CanShowForBaseParamsExpectTimes return of not CheckForDolphinId ")
    return false
  end
  if not NoticesUtil.CheckForUnownedItems(notice) then
    log(notice.MsgId .. " NoticesUtil.CanShowForBaseParamsExpectTimes return of not CheckForUnownedItems ")
    return false
  end
  return true
end
function NoticesUtil.GetActivityNoticeArray()
  local realActList = {}
  local TempActivityNoticeArray = {}
  NoticesUtil.GetITopNotices(TempActivityNoticeArray, NoticesConst.ITopScene.SLAP_SCENE_AFTER_LOGIN)
  for k, v in pairs(TempActivityNoticeArray) do
    if NoticesUtil.CanShowForBaseParamsExpectTimes(v) then
      local TableUtil = require("common.table_util")
      local notice = TableUtil.CopyTable(v)
      realActList[notice.MsgId] = notice
    end
  end
  log_tree("NoticesUtil.GetActivityNoticeArray, ActivityNoticeArray = ", realActList)
  return realActList
end
function NoticesUtil.GetDependResourcePath(noticeData)
  if not (noticeData and noticeData.PicPath) or noticeData.PicPath == "" or noticeData.PicPath == "none" then
    return ""
  end
  if NoticesUtil.IsUMGNotice(noticeData.VideoPath) then
    local STExtraGameInstance = import("STExtraGameInstance")
    local GameInstance = STExtraGameInstance.GetInstance()
    local nDeviceLevel = GameInstance:GetDeviceLevel()
    if 1 <= nDeviceLevel then
      return ""
    end
  end
  local util = require("client.slua_ui_framework.util")
  if util.IsOnlineImageUrl(noticeData.PicPath) then
    return noticeData.PicPath
  end
  return ""
end
function NoticesUtil.HandleDependResources(list, noticeData)
  if not noticeData then
    return
  end
  local util = require("client.slua_ui_framework.util")
  local path = NoticesUtil.GetDependResourcePath(noticeData)
  if not path or path == "" or path == "none" then
    return
  end
  path = util.GetUrlByLanguage(path)
  if not list[path] then
    list[path] = 1
  end
  if noticeData.ThumbNail and noticeData.ThumbNail ~= "" and noticeData.ThumbNail ~= "none" then
    local thumbNailPath = util.GetUrlByLanguage(noticeData.ThumbNail)
    if not list[thumbNailPath] then
      list[thumbNailPath] = 1
    end
  end
end
function NoticesUtil.HandleDownloadResource(resourceList)
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  local OnSuccess = function(texture, url)
    log(bWriteLog and string.format("NoticesUtil.HandleDownloadResource. OnSuccess, url=%s", tostring(url)))
  end
  local OnFailed = function(url)
    log(bWriteLog and string.format("NoticesUtil.HandleDownloadResource. OnFailed, url=%s", tostring(url)))
  end
  local image_download_config = require("client.slua.logic.image_download.image_download_config")
  for path, _ in pairs(resourceList) do
    log(bWriteLog and string.format("NoticesUtil.HandleDownloadResource.. Path:%s", path))
    image_download_mgr:DownloadImageByHttpWrapper(path, OnSuccess, OnFailed, {
      diskCacheType = image_download_config.EnumDiskCacheType.VersionUpdate
    })
  end
end
function NoticesUtil.IsBlockingCloseByHDmpve()
  local loginPercent = HDmpveRemote.HDmpveRemoteConfigGetInt("LoginPercent", 100)
  log(bWriteLog and "NoticesUtil.IsBlockingCloseByHDmpve get LoginPercent from HDmpve is " .. loginPercent)
  if 100 <= loginPercent then
    return false
  end
  local deviceID = Client.GetPhoneDeviceID()
  log(bWriteLog and string.format("NoticesUtil.IsBlockingCloseByHDmpve deviceID: %s", tostring(deviceID)))
  local deviceValue = NoticesUtil.CalcDeviceValueByDeviceID(deviceID, 100)
  log(bWriteLog and string.format("NoticesUtil.IsBlockingCloseByHDmpve deviceValue: %d", deviceValue))
  if loginPercent >= deviceValue then
    return false
  end
  return true
end
function NoticesUtil.CalcDeviceValueByDeviceID(deviceID, defaultValue)
  defaultValue = defaultValue or 100
  if type(deviceID) ~= "string" or deviceID == "" then
    return defaultValue
  end
  local bAllZero = true
  for i = 1, #deviceID do
    if deviceID[i] ~= "0" and deviceID[i] ~= "-" then
      bAllZero = false
      break
    end
  end
  if bAllZero then
    return defaultValue
  end
  local UEMathUtilityMethods = import("UEMathUtilityMethods")
  local hash = UEMathUtilityMethods.BKDRHash(deviceID, 86028157)
  return hash % 100
end
return NoticesUtil