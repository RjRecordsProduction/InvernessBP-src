local logic_unknowpass_gift = {
  curStatus = nil,
  realPoint = 0,
  totalPoint = 10000,
  perPoint = 2000,
  curGiftNumber = 0,
  totalGiftNumber = 5,
  limitRPLevel = 0,
  limitDay = 0,
  giftPerCost = 0,
  totalCollectedScore = 0,
  totalPrePrizeScore = 0,
  pre_prize_score = 0,
  cur_prize_score = 0,
  giftStatusArr = {
    [1] = {
      [1] = true,
      [2] = false
    }
  },
  bShowUnLockFlag = false,
  localTableData = {},
  tCacheLocalTableData = {},
  videoPath = "./MoviesPakDir/PUBGM_V130_RPPoints.mp4",
  IconType = {ENTRANCE = 1, TASK = 2},
  PointType = {ACT = 1, NORMAL = 2},
  AnimType = {Progress = 1, TextShine = 2},
  EProgressStatus = {
    Lock = 1,
    inProgress = 2,
    Achieve = 3
  }
}
local ACT_RP_ICON_ID = 1098
local NORMAL_RP_ICON_ID = 1099
local getSaveData = function(key)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType[key])
  if saveData == nil then
    local seasonId = UnknowPassSystem.Season or 0
    local reserved = 1
    saveData = {
      count = 0,
      seasonId = seasonId,
          }
  end
  return saveData
end
local setSaveData = function(key, savedata)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(savedata, PlayerPrefsSystem.ePlayerPrefsType[key])
end
local solvePerPrizeAward = function(award)
  local tempArr = {}
  local totalGiftNumber = logic_unknowpass_gift.totalGiftNumber
  for i = 1, totalGiftNumber do
    tempArr[i] = {false, false}
  end
  if not award then
    return tempArr
  end
  for k, v in pairs(award) do
    local StringUtil = require("common.string_util")
    local temp = StringUtil.Split(k, ":")
    local index = tonumber(temp[1])
    local phase = tonumber(temp[2])
    tempArr[index] = tempArr[index] or {}
    tempArr[index][phase] = v
  end
  return tempArr
end
function logic_unknowpass_gift.InitPrizeGiftData(pre_prize)
  logic_unknowpass_gift.upass_new_get_rsp(pre_prize)
end
function logic_unknowpass_gift.updatePrize(per_prize)
  logic_unknowpass_gift.curGiftNumber = per_prize.index
  logic_unknowpass_gift.realPoint = per_prize.score
  logic_unknowpass_gift.giftStatusArr = solvePerPrizeAward(per_prize.award)
  logic_unknowpass_gift.totalCollectedScore = per_prize.total_collected_score or 0
end
function logic_unknowpass_gift.upass_new_get_rsp(pre_prize)
  log(bWriteLog and "upass_new_get_rsp" .. tostring(pre_prize))
  log_tree("[chub]upass_new_get_rsp, pre_prize = ", pre_prize)
  if pre_prize == nil then
    logic_unknowpass_gift.localTableData = {}
    return
  end
  logic_unknowpass_gift.updatePrize(pre_prize)
  if not UnknowPassSystem.SeasonInfo or not UnknowPassSystem.SeasonInfo.cfg then
    log(bWriteLog and "upass_new_get_rsp - SeasonInfo or cfg is nil")
    return
  end
  logic_unknowpass_gift.totalPrePrizeScore = UnknowPassSystem.SeasonInfo.cfg.total_pre_prize_score
  local appid = Client.GetITopGameId()
  logic_unknowpass_gift.localTableData = logic_unknowpass_gift.readTableBySeasonAndAPPID(UnknowPassSystem.Season, appid)
  if #logic_unknowpass_gift.localTableData == 0 then
    return
  end
  log(bWriteLog and "totalpreprsizeScore : " .. tostring(logic_unknowpass_gift.totalPrePrizeScore) .. "totalCollectedScore : " .. tostring(logic_unknowpass_gift.totalCollectedScore))
  local bUseNew = logic_unknowpass_gift.IsEvenNumberGift()
  if not bUseNew then
    logic_unknowpass_gift.perPoint = logic_unknowpass_gift.localTableData[1].BonusPoint2 or 0
  else
    logic_unknowpass_gift.perPoint = logic_unknowpass_gift.localTableData[1].BonusPoint1 or 0
  end
  log(bWriteLog and UnknowPassSystem.Season .. "upass_new_get_rsp perPoint = " .. tostring(bUseNew) .. logic_unknowpass_gift.perPoint)
  logic_unknowpass_gift.giftPerCost = logic_unknowpass_gift.localTableData[1].Cost
  logic_unknowpass_gift.totalPoint = logic_unknowpass_gift.GetResultBounsPoint(logic_unknowpass_gift.localTableData[#logic_unknowpass_gift.localTableData])
  logic_unknowpass_gift.totalGiftNumber = #logic_unknowpass_gift.localTableData
  logic_unknowpass_gift.totalGiftNumber = 10
  logic_unknowpass_gift.notifyPointStatusChanged()
end
function logic_unknowpass_gift.send_upass_pre_prize_buy_req(cur_index, num)
  log(bWriteLog and "send_upass_pre_prize_buy_req " .. tostring(cur_index) .. " " .. tostring(num))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_pre_prize_buy_req(cur_index, num)
end
function logic_unknowpass_gift.on_upass_pre_prize_buy_rsp(pre_prize, all_awards)
  log(bWriteLog and "on_upass_pre_prize_buy_rsp " .. tostring(pre_prize) .. " " .. tostring(all_awards))
  logic_unknowpass_gift.updatePrize(pre_prize)
  logic_unknowpass_gift.notifyGiftPurchaseSuccess(all_awards)
end
function logic_unknowpass_gift.send_upass_pre_prize_take_progress_award_req(index, progress)
  log(bWriteLog and "send_upass_pre_prize_take_progress_award_req " .. tostring(index) .. " " .. tostring(progress))
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_pre_prize_take_progress_award_req(index, progress)
end
function logic_unknowpass_gift.on_upass_pre_prize_take_progress_award_rsp(pre_prize, all_awards)
  log_tree("[chub]on_upass_pre_prize_take_progress_award_rsp, pre_prize = ", pre_prize)
  log_tree("[chub]on_upass_pre_prize_take_progress_award_rsp, all_awards = ", all_awards)
  logic_unknowpass_gift.updatePrize(pre_prize)
  logic_unknowpass_gift.notifyGiftPorfitSuccess(all_awards)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(all_awards)
end
local bShowRpGiftGetProfitFlag = false
function logic_unknowpass_gift.on_upass_pre_prize_score_chg_notify(old_score, cur_score)
  log(bWriteLog and "on_upass_pre_prize_score_chg_notify" .. tostring(old_score) .. " " .. tostring(cur_score))
  logic_unknowpass_gift.notifyActPointProgressChanged(old_score, cur_score)
  logic_unknowpass_gift.realPoint = cur_score
  if logic_unknowpass_gift.CheckHasNewGift(old_score, cur_score) then
    if GameStatus.IsInLobbyOrMainCity() then
      logic_unknowpass_gift.ShowRpGiftGetProfitUI()
      logic_unknowpass_gift.notifyGiftPorfitNotify()
      bShowRpGiftGetProfitFlag = false
    else
      bShowRpGiftGetProfitFlag = true
    end
  end
end
function logic_unknowpass_gift.on_upass_score_notify_chg(value, pre_prize_score, total_collected_pre_prize_score)
  log(bWriteLog and "on_upass_score_notify_chg " .. tostring(pre_prize_score) .. " " .. tostring(total_collected_pre_prize_score))
  if logic_unknowpass_gift.addFlag then
    logic_unknowpass_gift.cur_prize_score = logic_unknowpass_gift.cur_prize_score + value
    logic_unknowpass_gift.pre_prize_score = logic_unknowpass_gift.pre_prize_score + pre_prize_score
  else
    logic_unknowpass_gift.cur_prize_score = value
    logic_unknowpass_gift.  end
end
function logic_unknowpass_gift.SetAddFlag(bAdd)
  log(bWriteLog and "SetAddFlag " .. tostring(bAdd))
  logic_unknowpass_gift.addFlag = bAdd
  if bAdd then
    logic_unknowpass_gift.cur_prize_score = 0
    logic_unknowpass_gift.pre_prize_score = 0
  end
end
function logic_unknowpass_gift.OnModePostSwitch()
  local curStatus = GameStatus.GetGameStatus()
  local lastStatus = GameStatus.GetLastGameStatus()
  if lastStatus == GameStatus.Fighting and curStatus == GameStatus.Lobby and bShowRpGiftGetProfitFlag then
    logic_unknowpass_gift.ShowRpGiftGetProfitUI()
    logic_unknowpass_gift.notifyGiftPorfitNotify()
    bShowRpGiftGetProfitFlag = false
  end
end
function logic_unknowpass_gift.readTableBySeasonAndAPPID(SeasonId, AppID)
  local tbl = CDataTable.GetTableByFilter("UnKnownPassPrePrizeTable", "SeasonId", SeasonId, "AppID", tonumber(AppID))
  local _resTbl = {}
  local getConfig = function(cfgTab)
    for _, v in pairs(cfgTab) do
      _resTbl[#_resTbl + 1] = v
    end
  end
  getConfig(tbl)
  if #_resTbl == 0 then
    tbl = CDataTable.GetTableByFilter("UnKnownPassPrePrizeTable", "SeasonId", SeasonId, "AppID", 1320)
    getConfig(tbl)
  end
  table.sort(_resTbl, function(v1, v2)
    return v1.GiftId < v2.GiftId
  end)
  return _resTbl
end
function logic_unknowpass_gift.CheckBonusOK(bonusPoint)
  if bonusPoint and 0 < bonusPoint then
    return true
  end
  return false
end
function logic_unknowpass_gift.GetResultBounsPoint(gift)
  if gift then
    local bounsPoint = gift.BonusPoint1 or 0
    if gift.BonusPoint2 and logic_unknowpass_gift.CheckBonusOK(gift.BonusPoint2) then
      bounsPoint = gift.BonusPoint2
    end
    return bounsPoint
  else
    return 0
  end
end
function logic_unknowpass_gift.CheckHasNewGift(old_score, cur_score)
  if not next(logic_unknowpass_gift.localTableData) then
    logic_unknowpass_gift.InitPrizeGiftData(logic_unknowpass_gift.tCacheLocalTableData)
  end
  local oldBpIndex = 0
  local newBpIndex = 0
  local tempArr = {}
  for i, v in ipairs(logic_unknowpass_gift.localTableData) do
    if v.BonusPoint1 and logic_unknowpass_gift.CheckBonusOK(v.BonusPoint1) then
      tempArr[#tempArr + 1] = v.BonusPoint1
    end
    if v.BonusPoint2 and logic_unknowpass_gift.CheckBonusOK(v.BonusPoint2) then
      tempArr[#tempArr + 1] = v.BonusPoint2
    end
  end
  for i, v in ipairs(tempArr) do
    oldBpIndex = v <= old_score and i or oldBpIndex
    newBpIndex = v <= cur_score and i or newBpIndex
  end
  return oldBpIndex < newBpIndex
end
local saveKeyTbl = {
  {
    key = "eUnknowPassGiftPoster",
    count = 1
  },
  {
    key = "eUnknowPassGiftGuide",
    count = 1
  },
  {
    key = "eUnknowPassGiftVideo",
    count = 1
  },
  {
    key = "eUnknowPassGiftStrongGuide",
    count = 1
  }
}
local getCount = function(keyname)
  for i, v in ipairs(saveKeyTbl) do
    if v.key == keyname then
      return v.count
    end
  end
end
local checkStatus = function(keyname)
  local cnt = getCount(keyname)
  local saveData = getSaveData(keyname)
  if saveData and saveData.count and cnt > saveData.count then
    return true
  end
  return false
end
local updateStatus = function(keyname)
  local cnt = getCount(keyname)
  local saveData = getSaveData(keyname)
  if saveData and cnt > saveData.count then
    saveData.count = saveData.count + 1
    setSaveData(keyname, saveData)
  end
end
function logic_unknowpass_gift.CheckSeasonIsCurrentSeason(seasonId)
  return seasonId == 1
end
function logic_unknowpass_gift.CheckCanShowRpGiftPoster()
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "logic_unknowpass_gift.CheckCanShowRpGiftPoster UI responsiveness testing")
    return false
  end
  if logic_unknowpass_gift.CheckOpenRpGift() and logic_unknowpass_gift.GetActGiftNumber() == 0 then
    local saveData = getSaveData("eUnknowPassGiftPoster")
    if logic_unknowpass_gift.CheckSeasonIsCurrentSeason(1) == true and checkStatus("eUnknowPassGiftPoster") then
      return true
    end
    if logic_unknowpass_gift.CheckSeasonIsCurrentSeason(1) == false then
      return true
    end
  end
  return false
end
function logic_unknowpass_gift.UpdateShowRpGiftPosterStatus()
  local saveData = getSaveData("eUnknowPassGiftPoster")
  if saveData.seasonId == nil or saveData.seasonId ~= 1 then
    saveData.count = 1
  else
    saveData.count = saveData.count + 1
  end
  saveData.seasonId = 1
  setSaveData("eUnknowPassGiftPoster", saveData)
end
function logic_unknowpass_gift.CheckCanShowRpGiftGuide()
  if logic_unknowpass_gift.CheckOpenRpGift() then
    return checkStatus("eUnknowPassGiftGuide")
  end
  return false
end
function logic_unknowpass_gift.UpdateShowRpGiftGuide()
  updateStatus("eUnknowPassGiftGuide")
end
function logic_unknowpass_gift.CheckCanShowRpGfitVideo()
  return checkStatus("eUnknowPassGiftVideo")
end
function logic_unknowpass_gift.UpdateShowRpGfitVideo()
  updateStatus("eUnknowPassGiftVideo")
end
function logic_unknowpass_gift.CheckCanShowLevelToGiftGuide()
  if logic_unknowpass_gift.CheckOpenRpGift() and logic_unknowpass_gift.CheckHasBoughtGift() == false then
    return checkStatus("eUnknowPassGiftStrongGuide")
  end
  return false
end
function logic_unknowpass_gift.UpdateShowLevelToGiftGuide()
  updateStatus("eUnknowPassGiftStrongGuide")
end
function logic_unknowpass_gift.CheckValidSeason()
  if not next(logic_unknowpass_gift.localTableData) then
    logic_unknowpass_gift.InitPrizeGiftData(logic_unknowpass_gift.tCacheLocalTableData)
  end
  if logic_unknowpass_gift.localTableData and type(logic_unknowpass_gift.localTableData) == "table" and #logic_unknowpass_gift.localTableData > 0 then
    return true
  end
  return false
end
function logic_unknowpass_gift.CheckOpenRpGift()
  if logic_unknowpass_gift.CheckValidSeason() and logic_unknowpass_gift.CheckGlobalSwitch() and UnknowPassSystem.IsInCurSession then
    if logic_unknowpass_gift.CheckLocalSwitch() == false then
      if logic_unknowpass_gift.curGiftNumber > 0 and logic_unknowpass_gift.CheckNotFullPoint() then
        log(bWriteLog and "[chub]logic_unknowpass_gift.CheckOpenRpGift return 1")
        return true
      else
        log(bWriteLog and "[chub]logic_unknowpass_gift.CheckOpenRpGift return 2")
        return false
      end
    end
    log(bWriteLog and "[chub]logic_unknowpass_gift.CheckOpenRpGift return 3")
    return true
  end
  log(bWriteLog and "[chub]logic_unknowpass_gift.CheckOpenRpGift return 4")
  return false
end
function logic_unknowpass_gift.CheckShowUnlockRpProgressBar()
  return logic_unknowpass_gift.CheckOpenRpGift() and not logic_unknowpass_gift.AllGiftReceive()
end
function logic_unknowpass_gift.CheckActRPStatus()
  return logic_unknowpass_gift.pre_prize_score > 0
end
function logic_unknowpass_gift.GetRPChangeValue()
  return logic_unknowpass_gift.pre_prize_score
end
function logic_unknowpass_gift.GetNormalRPChangeValue()
  return logic_unknowpass_gift.cur_prize_score + logic_unknowpass_gift.pre_prize_score
end
function logic_unknowpass_gift.IsActPointStatus()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  if logic_unknowpass_gift.curStatus == UnknowPassMacro.ENUM_POINT_STATUS.ACT then
    return true
  end
  return false
end
function logic_unknowpass_gift.GetActGiftNumber()
  return logic_unknowpass_gift.curGiftNumber
end
function logic_unknowpass_gift.GetTotalGiftNumber()
  return logic_unknowpass_gift.totalGiftNumber
end
function logic_unknowpass_gift.GetLimitRpLevel()
  return logic_unknowpass_gift.limitRPLevel
end
function logic_unknowpass_gift.GetLimitDay()
  return logic_unknowpass_gift.limitDay
end
function logic_unknowpass_gift.GetTotalActPoint()
  log(bWriteLog and logic_unknowpass_gift.perPoint .. "=====GetTotalActPoint=========" .. logic_unknowpass_gift.curGiftNumber)
  local totalPoint = logic_unknowpass_gift.curGiftNumber * logic_unknowpass_gift.perPoint
  return totalPoint
end
function logic_unknowpass_gift.GetRealActPoint()
  return logic_unknowpass_gift.realPoint
end
function logic_unknowpass_gift.GetPerPoint()
  return logic_unknowpass_gift.perPoint
end
function logic_unknowpass_gift.CheckShowRpGiftGuide()
  return logic_unknowpass_gift.bCheckShowRpGiftGuide
end
function logic_unknowpass_gift.CheckShowRpGiftUnlockPopupUI()
  return logic_unknowpass_gift.bShowUnLockFlag
end
function logic_unknowpass_gift.GetGfitStatusArr()
  return logic_unknowpass_gift.giftStatusArr
end
function logic_unknowpass_gift.CheckCanBuy()
  if logic_unknowpass_gift.CheckLocalSwitch() == false then
    return false
  end
  return logic_unknowpass_gift.curGiftNumber < logic_unknowpass_gift.totalGiftNumber
end
function logic_unknowpass_gift.CheckHasBoughtGift()
  return logic_unknowpass_gift.curGiftNumber > 0
end
function logic_unknowpass_gift.CheckGlobalSwitch()
  return LobbySystem.CheckOpen(10233)
end
function logic_unknowpass_gift.CheckLocalSwitch()
  return LobbySystem.CheckOpen(10234)
end
function logic_unknowpass_gift.GetLocalTableData()
  if not next(logic_unknowpass_gift.localTableData) then
    logic_unknowpass_gift.InitPrizeGiftData(logic_unknowpass_gift.tCacheLocalTableData)
  end
  return logic_unknowpass_gift.localTableData
end
function logic_unknowpass_gift.GetGiftPerCost()
  return logic_unknowpass_gift.giftPerCost
end
function logic_unknowpass_gift.CheckVideoRedDot()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  return VideoLibrary.IsVideoFileReady(logic_unknowpass_gift.videoPath)
end
function logic_unknowpass_gift.GetVideoPath()
  return logic_unknowpass_gift.videoPath
end
function logic_unknowpass_gift.PlayVideo()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  if VideoLibrary.IsCanPlayVideo() then
    VideoLibrary.PlayVideo(logic_unknowpass_gift.videoPath)
    return true
  end
  return false
end
function logic_unknowpass_gift.CheckHasNotOpenGift()
  if not next(logic_unknowpass_gift.localTableData) then
    logic_unknowpass_gift.InitPrizeGiftData(logic_unknowpass_gift.tCacheLocalTableData)
  end
  local realPoint = logic_unknowpass_gift.realPoint
  local giftStatusArr = logic_unknowpass_gift.giftStatusArr
  for i, v in ipairs(logic_unknowpass_gift.localTableData) do
    local statuArr = giftStatusArr[i]
    if statuArr then
      if v.BonusPoint1 and logic_unknowpass_gift.CheckBonusOK(v.BonusPoint1) and realPoint >= v.BonusPoint1 and statuArr[1] == false then
        return true
      end
      if v.BonusPoint2 and logic_unknowpass_gift.CheckBonusOK(v.BonusPoint2) and realPoint >= v.BonusPoint2 and statuArr[2] == false then
        return true
      end
    end
  end
  return false
end
function logic_unknowpass_gift.GetAllUC()
  if not next(logic_unknowpass_gift.localTableData) then
    logic_unknowpass_gift.InitPrizeGiftData(logic_unknowpass_gift.tCacheLocalTableData)
  end
  local realPoint = logic_unknowpass_gift.realPoint
  local giftStatusArr = logic_unknowpass_gift.giftStatusArr
  local ret = 0
  for i, v in ipairs(logic_unknowpass_gift.localTableData) do
    local statuArr = giftStatusArr[i]
    if v.BonusPoint1 and logic_unknowpass_gift.CheckBonusOK(v.BonusPoint1) and realPoint >= v.BonusPoint1 and statuArr[1] == false then
      local StringUtil = require("common.string_util")
      local data = StringUtil.Split(v.PhaseReward1, ";")
      local count = tonumber(data[2]) or 0
      ret = ret + count
    end
    if v.BonusPoint2 and logic_unknowpass_gift.CheckBonusOK(v.BonusPoint2) and realPoint >= v.BonusPoint2 and statuArr[2] == false then
      local StringUtil = require("common.string_util")
      local data = StringUtil.Split(v.PhaseReward2, ";")
      local count = tonumber(data[2]) or 0
      ret = ret + count
    end
  end
  return ret
end
function logic_unknowpass_gift.GetFirstOpenGift()
  if not next(logic_unknowpass_gift.localTableData) then
    logic_unknowpass_gift.InitPrizeGiftData(logic_unknowpass_gift.tCacheLocalTableData)
  end
  local realPoint = logic_unknowpass_gift.realPoint
  local giftStatusArr = logic_unknowpass_gift.giftStatusArr
  local targetIndex
  for i, v in ipairs(logic_unknowpass_gift.localTableData) do
    local statuArr = giftStatusArr[i]
    if v.BonusPoint1 and logic_unknowpass_gift.CheckBonusOK(v.BonusPoint1) and realPoint >= v.BonusPoint1 and statuArr[1] == false then
      targetIndex = i
      break
    end
    if v.BonusPoint2 and logic_unknowpass_gift.CheckBonusOK(v.BonusPoint2) and realPoint >= v.BonusPoint2 and statuArr[2] == false then
      targetIndex = i
      break
    end
  end
  return targetIndex
end
function logic_unknowpass_gift.CheckIconEntrance(_type)
  return _type == logic_unknowpass_gift.IconType.ENTRANCE
end
function logic_unknowpass_gift.CheckIconTask(_type)
  return _type == logic_unknowpass_gift.IconType.TASK
end
function logic_unknowpass_gift.GetLastProgressAnimNeedPlayedPoint()
  local saveData = getSaveData("eUnknowPassGiftProgress")
  if saveData.seasonId ~= UnknowPassSystem.Season then
    return 0
  end
  return saveData.count
end
function logic_unknowpass_gift.CheckLastProgressAnimNeedPlayed()
  local realPoint = logic_unknowpass_gift.realPoint
  local saveData = getSaveData("eUnknowPassGiftProgress")
  if realPoint > saveData.count then
    return true
  elseif realPoint < saveData.count and saveData.seasonId <= UnknowPassSystem.Season then
    return true
  end
end
function logic_unknowpass_gift.UpdateLastProgressAnimPlayed(realPoint)
  realPoint = realPoint or logic_unknowpass_gift.realPoint
  local saveData = getSaveData("eUnknowPassGiftProgress")
  saveData.count = realPoint
  saveData.seasonId = UnknowPassSystem.Season
  setSaveData("eUnknowPassGiftProgress", saveData)
end
function logic_unknowpass_gift.GetActiveStatu()
  if logic_unknowpass_gift.CheckOpenRpGift() and logic_unknowpass_gift.CheckHasBoughtGift() and logic_unknowpass_gift.CheckNotFullPoint() then
    return logic_unknowpass_gift.PointType.ACT
  end
  return logic_unknowpass_gift.PointType.NORMAL
end
function logic_unknowpass_gift.AllGiftReceive()
  for i = 1, logic_unknowpass_gift.totalGiftNumber do
    local bStatus1 = logic_unknowpass_gift.giftStatusArr[i] and logic_unknowpass_gift.giftStatusArr[i][1] or false
    if not bStatus1 then
      log(bWriteLog and "[chub]logic_unknowpass_gift.AllGiftReceive, has not receive: i = " .. i)
      return false
    end
  end
  log(bWriteLog and "[chub]logic_unknowpass_gift.AllGiftReceive, has receive all")
  return true
end
function logic_unknowpass_gift.CheckNotFullPoint()
  if not next(logic_unknowpass_gift.localTableData) then
    logic_unknowpass_gift.InitPrizeGiftData(logic_unknowpass_gift.tCacheLocalTableData)
  end
  local giftIndex = logic_unknowpass_gift.curGiftNumber
  local realPoint = logic_unknowpass_gift.realPoint
  local localTableData = logic_unknowpass_gift.localTableData
  local gift = localTableData[giftIndex]
  local bounsPoint = logic_unknowpass_gift.GetResultBounsPoint(gift)
  if realPoint < bounsPoint then
    return true
  end
  return false
end
function logic_unknowpass_gift.GetIconItemDataByRpStatus(rpStatus)
  local itemData
  if rpStatus == logic_unknowpass_gift.PointType.ACT then
    local UIUtil = require("client.common.ui_util")
    itemData = UIUtil.GetItemCfg(ACT_RP_ICON_ID)
  elseif rpStatus == logic_unknowpass_gift.PointType.NORMAL then
    local UIUtil = require("client.common.ui_util")
    itemData = UIUtil.GetItemCfg(NORMAL_RP_ICON_ID)
  end
  return itemData
end
function logic_unknowpass_gift.GetRpResIDByPointType(resID)
  local bAct = logic_unknowpass_gift.GetActiveStatu() == logic_unknowpass_gift.PointType.ACT
  return logic_unknowpass_gift.GetRpResID(bAct, resID)
end
function logic_unknowpass_gift.GetRpResIDByPointChange(resID)
  local status = logic_unknowpass_gift.CheckActRPStatus()
  return logic_unknowpass_gift.GetRpResID(status, resID)
end
function logic_unknowpass_gift.GetRpResID(bAct, resID)
  if resID == NORMAL_RP_ICON_ID then
    return logic_unknowpass_gift.GetRpItemID(bAct)
  end
  return resID
end
function logic_unknowpass_gift.GetRpItemID(bAct)
  if bAct then
    return ACT_RP_ICON_ID
  else
    return NORMAL_RP_ICON_ID
  end
end
function logic_unknowpass_gift.CheckNormalRPIcon(resID)
  return resID == NORMAL_RP_ICON_ID
end
function logic_unknowpass_gift.GetNeedActivityPoint(index, num)
  if not next(logic_unknowpass_gift.localTableData) then
    logic_unknowpass_gift.InitPrizeGiftData(logic_unknowpass_gift.tCacheLocalTableData)
  end
  local localTableData = logic_unknowpass_gift.localTableData
  local newIndex = index + num
  local tPoint = logic_unknowpass_gift.GetResultBounsPoint(localTableData[newIndex])
  local needPoint = tPoint - logic_unknowpass_gift.realPoint
  return needPoint
end
function logic_unknowpass_gift.CheckShowWarningUI(cost)
  if cost > logic_unknowpass_gift.totalPrePrizeScore - logic_unknowpass_gift.totalCollectedScore then
    return true
  end
  return false
end
function logic_unknowpass_gift.GetActRPPointDesc()
  local score = logic_unknowpass_gift.cur_prize_score
  local actscore = logic_unknowpass_gift.pre_prize_score
  local tip = ""
  if score == 0 then
    tip = LocUtil.LocalizeResFormat(13009, actscore)
  elseif actscore == 0 then
    tip = LocUtil.LocalizeResFormat(4585, tostring(score))
  else
    tip = LocUtil.LocalizeResFormat(13010, actscore, score)
  end
  return tip
end
function logic_unknowpass_gift.CheckUCEnough(cost)
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local info = StoreUtils.GetMoneyInfo()
  local uc = info.nUC
  return cost > uc
end
function logic_unknowpass_gift.CheckJK()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return true
  end
  return false
end
function logic_unknowpass_gift.HandleBuyReq(num, cost)
  if logic_unknowpass_gift.CheckUCEnough(cost) then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(cost)
    return
  end
  local curIndex = logic_unknowpass_gift.GetActGiftNumber()
  local okFunc = function()
    logic_unknowpass_gift.send_upass_pre_prize_buy_req(curIndex, num)
  end
  local needPoint = logic_unknowpass_gift.GetNeedActivityPoint(curIndex, num)
  if logic_unknowpass_gift.CheckShowWarningUI(needPoint) then
    logic_unknowpass_gift.ShowWarningUI(okFunc, needPoint)
  else
    okFunc()
  end
end
function logic_unknowpass_gift.HandleShowLevelToGiftGuide(func)
  local okFunc = function(bToggled)
    logic_unknowpass_gift.ShowRpGiftMainPageUI()
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.PassGiftFromStrongGuide)
    if bToggled then
      logic_unknowpass_gift.UpdateShowLevelToGiftGuide()
    end
  end
  local cancelFunc = function(bToggled)
    if type(func) == "function" then
      func()
    end
    if bToggled then
      logic_unknowpass_gift.UpdateShowLevelToGiftGuide()
    end
  end
  logic_unknowpass_gift.ShowRpLevelToGuideUI(okFunc, cancelFunc)
end
function logic_unknowpass_gift.ShowRpLevelToGuideUI(okfunc, cancelfunc)
  local ui = logic_unknowpass_gift.showUI("UnknowPass_ActivePack_StrongGuide_UIBP", logic_unknowpass_gift, okfunc, cancelfunc)
  local strTips = LocUtil.GetLocalizeResStr(12238)
  local strCancel = LocUtil.GetLocalizeResStr(12239)
  local strTrue = LocUtil.GetLocalizeResStr(12240)
  local content = LocUtil.GetLocalizeResStr(12241)
  ui:SetText(strTips, strCancel, strTrue, content)
end
function logic_unknowpass_gift.ShowRpGiftPosterUI()
  UIManager.ShowUI(UIManager.UI_Config.UnknowPass_ActivePackSlap_UIBP)
end
function logic_unknowpass_gift.ShowRpGiftGetProfitUI()
  UIManager.ShowUI(UIManager.UI_Config.UnknowPass_ActivePackGet_UIBP)
end
function logic_unknowpass_gift.ShowRpGiftMainPageUI()
  UIManager.ShowUI(UIManager.UI_Config.UnknowPass_ActivePack_UIBP)
end
function logic_unknowpass_gift.ShowRpGiftUnlockPopupUI()
  logic_unknowpass_gift.bShowUnLockFlag = false
  UIManager.ShowUI(UIManager.UI_Config.UnknowPass_ActivePack_UnlockPopup_UIBP)
end
function logic_unknowpass_gift.ShowRpGiftGuide()
  UIManager.ShowUI(UIManager.UI_Config.UnknowPass_ActivePack_UIBP_GUIDE)
end
function logic_unknowpass_gift.ShowRpGiftBuyUI()
  if not next(logic_unknowpass_gift.localTableData) then
    logic_unknowpass_gift.InitPrizeGiftData(logic_unknowpass_gift.tCacheLocalTableData)
  end
  local curGiftNumber = logic_unknowpass_gift.curGiftNumber
  local totalGiftNumber = logic_unknowpass_gift.totalGiftNumber
  local limitNumber = totalGiftNumber
  local itemId = logic_unknowpass_gift.localTableData[1].GiftItemId
  local giftPerCost = logic_unknowpass_gift.giftPerCost
  local showData = {
    exchange_item_id = itemId,
    cost_item_id = 1006,
    buy_num = curGiftNumber,
    limit_num = limitNumber,
    unit_price = giftPerCost,
    dont_show_coupon = true
  }
  local logic_unknowpass_exchange_confirm = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange_confirm")
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  logic_unknowpass_exchange_confirm.OpenExchangeConfirmUI(UnknowPassMacro.ENUM_EXCHANGE_CONFIRM_TYPE.RPGIFT, showData)
end
function logic_unknowpass_gift.GetBuyItemDesc(selectCount)
  local desc
  if logic_unknowpass_gift.IsEvenNumberGift() == false then
    desc = logic_unknowpass_gift.GetBuyItemDescBySingle(selectCount)
  else
    desc = logic_unknowpass_gift.GetBuyItemDescByEven(selectCount)
  end
  return desc
end
function logic_unknowpass_gift.GetBuyItemDescByEven(selectCount)
  local desc = ""
  local maxLevel = 100
  local level = UnknowPassSystem.Level
  local s1, s2, s3, descid
  if level <= maxLevel - 10 * selectCount then
    s1 = level + 10 * selectCount
    s2 = selectCount
    s3 = 1000 * selectCount
    descid = 21269
    desc = LocUtil.LocalizeResFormat(descid, s1, s2 * 120, s3)
  elseif level > maxLevel - 10 * selectCount and maxLevel > level then
    s1 = (level + 10 * selectCount - maxLevel) * 100
    s2 = selectCount
    s3 = 1000 * selectCount
    descid = 21270
    desc = LocUtil.LocalizeResFormat(descid, s1, s2 * 120, s3)
  else
    s1 = 1000 * selectCount
    s2 = selectCount
    s3 = 1000 * selectCount
    descid = 21271
    desc = LocUtil.LocalizeResFormat(descid, s1, s2 * 120, s3)
  end
  return desc
end
function logic_unknowpass_gift.GetBuyItemDescBySingle(selectCount)
  local desc = ""
  local level = UnknowPassSystem.Level
  local bJK = logic_unknowpass_gift.CheckJK()
  local s1, s2, s3, s4, descid
  if level <= 100 - 20 * selectCount then
    s1 = level + 20 * selectCount
    s2 = 1 * selectCount
    s3 = bJK and 1 * selectCount or 3 * selectCount
    s4 = 2000 * selectCount
    descid = bJK and 18820 or 12261
    desc = LocUtil.LocalizeResFormat(descid, s1, s2, s3, s4)
  elseif level > 100 - 20 * selectCount and level < 100 then
    s1 = (level + 20 * selectCount) * 100 - 10000
    s2 = 1 * selectCount
    s3 = bJK and 1 * selectCount or 3 * selectCount
    s4 = 2000 * selectCount
    desc = LocUtil.LocalizeResFormat(12262, s1, s2, s3, s4)
  else
    s1 = 2000 * selectCount
    s2 = 1 * selectCount
    s3 = bJK and 1 * selectCount or 3 * selectCount
    s4 = 2000 * selectCount
    descid = bJK and 18822 or 12263
    desc = LocUtil.LocalizeResFormat(descid, s1, s2, s3, s4)
  end
  return desc
end
function logic_unknowpass_gift.GetLimitDayTip()
  local numDay = 0
  local endTime = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassSystem.Season).SeasonEndTime
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local time = TimeUtil.TimeStringToUnixstamp(endTime)
  local dif = time - now
  local dayDif = dif / 86400
  local day = 0
  if dayDif < 0 then
  elseif dayDif <= 0.1 then
    day = 0.1
  elseif dayDif < 1 then
    day = string.format("%.1f", dayDif)
  elseif dayDif <= 10 then
    day = math.floor(tonumber(string.format("%.1f", dayDif)))
  end
  if day ~= 0 then
    return LocUtil.LocalizeResFormat(9687, day)
  end
  return ""
end
function logic_unknowpass_gift.ShowWarningUI(okFunc, needPoint)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local TitleStr = LocUtil.GetLocalizeResStr(12237)
  local TipStr = LocUtil.LocalizeResFormat(12236, needPoint)
  CommonMsgBoxMgr.Show(2, TitleStr, TipStr, function()
    if okFunc then
      okFunc()
    end
  end)
end
function logic_unknowpass_gift.showUI(configName, ...)
  log(bWriteLog and "showUI " .. tostring(configName))
  local config = UIManager.UI_Config[configName]
  local ui = UIManager.ShowUI(config, ...)
  return ui
end
function logic_unknowpass_gift.notifyPointStatusChanged()
  log(bWriteLog and "notifyPointStatusChanged")
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RP_GIFT_ENTRANCE_UI, 1)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RP_GIFT_TASK_REFRESH, 2)
end
function logic_unknowpass_gift.notifyActPointProgressChanged(old_score, new_score)
  log(bWriteLog and "notifyActPointProgressChanged " .. tostring(old_score) .. " " .. tostring(new_score))
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RP_GIFT_ENTRANCE_UI, 2, old_score, new_score)
end
function logic_unknowpass_gift.notifyGiftPurchaseSuccess(all_awards)
  log(bWriteLog and "notifyGiftPurchaseSuccess" .. tostring(all_awards))
  local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
  local UnknowPassGiftSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  local unknowpassSubwaySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subway")
  local tExtendData = {
    fCloseCallback = function()
      logic_unknowpass_gift.bShowUnLockFlag = true
      if UnknowPassSystem.Level > UnknowPassSystem.BuyBeforeLevel then
        UnknowPassLevelupSystem.OpenLevelUpUI()
      else
        UnknowPassGiftSystem.ShowRpGiftUnlockPopupUI()
      end
    end
  }
  unknowpassSubwaySystem.SetShowCoinTipFlag(false)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_RPRewardGet(all_awards, tExtendData)
  UnknowPassLevelupSystem.HideLevelUpUI()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RP_GIFT_ENTRANCE_UI, 1)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RP_GIFT_MAIN_UI, 1)
end
function logic_unknowpass_gift.notifyGiftPorfitNotify()
  log(bWriteLog and "notifyGiftPorfitNotify")
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RP_GIFT_ENTRANCE_UI, 3)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RP_GIFT_TASK_REFRESH, 2)
end
function logic_unknowpass_gift.notifyGiftPorfitSuccess(all_awards)
  log(bWriteLog and "notifyGiftPorfitSuccess" .. tostring(all_awards))
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RP_GIFT_ENTRANCE_UI, 3)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RP_GIFT_MAIN_UI, 1)
end
function logic_unknowpass_gift.ResetLocal()
  for i, v in ipairs(saveKeyTbl) do
    local keyname = v.key
    local data = getSaveData(keyname)
    data.count = 0
    setSaveData(keyname, data)
  end
  local saveData = getSaveData("eUnknowPassGiftProgress")
  saveData.count = 0
  saveData.seasonId = UnknowPassSystem.Season
  setSaveData("eUnknowPassGiftProgress", saveData)
end
function logic_unknowpass_gift.FixItemDataByType(arrayItemData, type)
  if type == 1 then
    return logic_unknowpass_gift.FixItemData(arrayItemData, "res_id", "count")
  elseif type == 2 then
    return logic_unknowpass_gift.FixItemData(arrayItemData, "resId", "number")
  end
  return arrayItemData
end
function logic_unknowpass_gift.ReplaceActRPItemIcon(image)
  local util = require("client.slua_ui_framework.util")
  local status = logic_unknowpass_gift.GetActiveStatu()
  local itemData = logic_unknowpass_gift.GetIconItemDataByRpStatus(status)
  util.SetTexture(image, itemData and itemData.ItemBigIcon or "", {sync = false})
end
function logic_unknowpass_gift.FixItemData(arrayItemData, resIdName, countName)
  if logic_unknowpass_gift.CheckOpenRpGift() and logic_unknowpass_gift.CheckActRPStatus() then
    local rpFlag = false
    local idx = 0
    for i, v in ipairs(arrayItemData) do
      if logic_unknowpass_gift.CheckNormalRPIcon(v[resIdName]) then
        rpFlag = true
        idx = i
        break
      end
    end
    local sumRp = 0
    for i, v in ipairs(arrayItemData) do
      if logic_unknowpass_gift.CheckNormalRPIcon(v[resIdName]) then
        sumRp = sumRp + v[countName]
      end
    end
    if rpFlag then
      local value = logic_unknowpass_gift.GetRPChangeValue()
      local Itemlen = #arrayItemData
      local list = {}
      for i = idx, Itemlen do
        local item = arrayItemData[i]
        if logic_unknowpass_gift.CheckNormalRPIcon(item[resIdName]) and item[countName] then
          if value == 0 then
            break
          end
          if item[countName] == value then
            list[#list + 1] = {rIdx = i, op = "r"}
            value = 0
          elseif value < item[countName] then
            list[#list + 1] = {
              rIdx = i,
              op = "s",
              ct = value
            }
            value = 0
          elseif value > item[countName] then
            list[#list + 1] = {rIdx = i, op = "r"}
            value = value - item[countName]
          end
        end
      end
      local listLen = #list
      for i = listLen, 1, -1 do
        local rIdx = list[i].rIdx
        local op = list[i].op
        local item = arrayItemData[rIdx]
        if op == "r" then
          arrayItemData[rIdx][resIdName] = logic_unknowpass_gift.GetRpResIDByPointChange(item[resIdName])
        elseif op == "s" then
          local ct = list[i].ct
          arrayItemData[rIdx][countName] = arrayItemData[rIdx][countName] - ct
          local newItem = DeepCopy(item)
          newItem[countName] = ct
          newItem[resIdName] = logic_unknowpass_gift.GetRpResIDByPointChange(item[resIdName])
          table.insert(arrayItemData, rIdx + 1, newItem)
        end
      end
      if 0 < listLen then
        local tip = logic_unknowpass_gift.GetActRPPointDesc()
        ShowNotice(tip)
      end
    end
  end
  return arrayItemData
end
function logic_unknowpass_gift.IsEvenNumberGift()
  local Season = UnknowPassSystem.Season
  return true
end
function logic_unknowpass_gift.SetRpGiftAddFlag(bAdd)
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(bAdd)
end
return logic_unknowpass_gift