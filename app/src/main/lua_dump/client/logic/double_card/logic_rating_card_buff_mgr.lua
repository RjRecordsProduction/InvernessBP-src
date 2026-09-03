local logic_rating_card_buff_mgr = {}
function logic_rating_card_buff_mgr:OnInitialize()
  logic_rating_card_buff_mgr.__super.OnInitialize(self)
  self.buffData = nil
  self.protect_info = nil
  self.add_score_info = nil
end
function logic_rating_card_buff_mgr:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
end
function logic_rating_card_buff_mgr:GetSegmentProtectList(bIsPeakView)
  log(bWriteLog and " logic_rating_card_buff_mgr.GetSegmentProtectList")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local isPakegame = bIsPeakView or logic_mode_selection:IsPeakGameView()
  if not self.protect_info then
    log(bWriteLog and " logic_rating_card_buff_mgr.GetSegmentProtectList no insId")
    return nil, false
  end
  local segProtectData = self:ProcessingBackendDataList(self.protect_info)
  local segProtectList = {}
  if segProtectData and 0 < #segProtectData then
    local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
    if isPakegame then
      log(bWriteLog and " logic_rating_card_buff_mgr.GetSegmentProtectList isPakegame")
      for k, v in pairs(segProtectData) do
        local isCurPeak = false
        if v.res_id and v.res_id == PeakGameConfig.ProtectCard.PointsProtectionCard then
          isCurPeak = true
        end
        if v.protect_activity_type == ActivityType.Peak_GAME_NOT_SCORE then
          isCurPeak = true
        end
        for _, type in pairs(PeakGameConfig.E_AddScoreTipsType) do
          if type == v.protect_id then
            isCurPeak = true
          end
        end
        if isCurPeak then
          table.insert(segProtectList, v)
        end
      end
    else
      log(bWriteLog and " logic_rating_card_buff_mgr.GetSegmentProtectList not isPakegame")
      for k, v in pairs(segProtectData) do
        if not self:IsPeakGameActivity(v) then
          table.insert(segProtectList, v)
        end
      end
    end
    if not segProtectList or not next(segProtectList) then
      return nil, false
    end
    local firstProtect = segProtectList[1]
    local RatingCardBuffConfig = require("client.logic.double_card.rating_card_buff_config")
    if firstProtect.type and firstProtect.type == RatingCardBuffConfig.BuffSourceType.ChallengeProtect then
      return segProtectList, true
    else
      return segProtectList, false
    end
  else
    return nil, false
  end
end
function logic_rating_card_buff_mgr:IsPeakGameActivity(data)
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if data.protect_activity_type and data.protect_activity_type == PeakGameConfig.ActivityType.NotScoreActivity then
    return true
  end
  if data.res_id and data.res_id == PeakGameConfig.ProtectCard.PointsProtectionCard then
    return true
  end
  return false
end
function logic_rating_card_buff_mgr:GetAddScoreList(isPeakGameShowIcon)
  if not self.add_score_info then
    log(bWriteLog and "logic_rating_card_buff_mgr:GetAddScoreList data is nil")
    return nil
  end
  local addScoreList = self:ProcessingBackendDataList(self.add_score_info)
  local isPakegame = isPeakGameShowIcon or false
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local filterAddScoreList = {}
  for k, v in pairs(addScoreList) do
    local isCurPeak = false
    for Cardk, Cardv in pairs(PeakGameConfig.ProtectCard) do
      if Cardv == v.res_id then
        isCurPeak = true
      end
    end
    for _, type in pairs(PeakGameConfig.E_AddScoreTipsType) do
      if type == v.protect_id then
        isCurPeak = true
      end
    end
    if isCurPeak == isPakegame then
      table.insert(filterAddScoreList, v)
    end
  end
  if filterAddScoreList and 0 < #filterAddScoreList then
    return filterAddScoreList
  else
    return nil
  end
end
function logic_rating_card_buff_mgr:ProcessingBackendDataList(dataList)
  if not dataList or not next(dataList) then
    log(bWriteLog and " logic_rating_card_buff_mgr.ProcessingBackendDataList no insId")
    return nil
  end
  local RatingCardBuffConfig = require("client.logic.double_card.rating_card_buff_config")
  local cardBuffToIndex = {}
  local segmentBuffList = {}
  for _, data in ipairs(dataList) do
    if data.type == RatingCardBuffConfig.BuffSourceType.Normal then
      local buffData = self:GetNormalTypeBuffData(data)
      if buffData then
        table.insert(segmentBuffList, buffData)
      end
    elseif data.type == RatingCardBuffConfig.BuffSourceType.Activity then
      if not data.protect_activity_type or not RatingCardBuffConfig.MultiProtect[data.protect_activity_type] then
        local bShow, buffData = self:CheckActDataShouldShow(data.protect_activity_type, data.protect_id, data)
        if bShow and buffData then
          table.insert(segmentBuffList, buffData)
        end
      else
        local result = self:CheckActDataShouldShowList(data.protect_activity_type, data.protect_id, data)
        for k, v in ipairs(result or {}) do
          table.insert(segmentBuffList, v)
        end
      end
    elseif data.type == RatingCardBuffConfig.BuffSourceType.ItemCard then
      self:AddOneCardItemToList(data.res_id, data, segmentBuffList, cardBuffToIndex)
    elseif data.type == RatingCardBuffConfig.BuffSourceType.ChallengeProtect then
      table.insert(segmentBuffList, {type = 4})
    end
  end
  return segmentBuffList
end
function logic_rating_card_buff_mgr:OnNextDayZeroCome()
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_rating_card_buff_mgr:OnNextDayZeroCome not in lobby")
    return
  end
  self:ReqRatingProtectBuffData()
  self:ReqAddScoreBuffData()
end
function logic_rating_card_buff_mgr:ReqRatingProtectBuffData()
  log(bWriteLog and "logic_rating_card_buff_mgr:ReqRatingProtectBuffData")
  local DoubleCardHandler = require("client.network.Protocol.DoubleCardHandler")
  DoubleCardHandler.send_get_rating_protect_list_req()
end
function logic_rating_card_buff_mgr:OnGetRatingtProtectData(protect_info)
  log(bWriteLog and "logic_rating_card_buff_mgr:OnGetRatingtProtectData")
  if not protect_info or type(protect_info) ~= "table" then
    log(bWriteLog and "logic_rating_card_buff_mgr:OnGetRatingtProtectData protect_info is invalid")
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_DOUBLECARD, EVENTID_SYNC_SEGMENT_PROTECT_BUFF_DATA)
end
function logic_rating_card_buff_mgr:ReqAddScoreBuffData()
  log(bWriteLog and "logic_rating_card_buff_mgr:ReqAddScoreBuffData")
  local DoubleCardHandler = require("client.network.Protocol.DoubleCardHandler")
  DoubleCardHandler.send_get_add_rating_list_req()
end
function logic_rating_card_buff_mgr:OnGetAddScoreData(add_score_info)
  log(bWriteLog and "logic_rating_card_buff_mgr:OnGetAddScoreData")
  if not add_score_info or type(add_score_info) ~= "table" then
    log(bWriteLog and "logic_rating_card_buff_mgr:OnGetAddScoreData add_score_info is invalid")
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_DOUBLECARD, EVENTID_SYNC_ADD_SCORE_BUFF_DATA)
end
function logic_rating_card_buff_mgr:CheckActDataShouldShow(activityType, buffId, itemData)
  if not activityType or not buffId then
    log(bWriteLog and "logic_rating_card_buff_mgr:CheckActDataShouldShow no id")
    return false, nil
  end
  if not self:CheckRatingBuffShowInLobby(buffId) then
    log(bWriteLog and "logic_rating_card_buff_mgr:CheckActDataShouldShow CheckRatingBuffShowInLobby false")
    return false, nil
  end
  local RatingCardBuffConfig = require("client.logic.double_card.rating_card_buff_config")
  local extarCheckMap = RatingCardBuffConfig.ExtraCheckActivityList or {}
  local bShow = true
  local checkData = extarCheckMap[activityType]
  local actvityId
  local progressNum = 0
  local totalNum = 0
  local expire_ts, groupModID
  if checkData and checkData.modulePath then
    log(bWriteLog and "logic_rating_card_buff_mgr:CheckActDataShouldShow need check")
    local checkModule
    if checkData.isModuleBase then
      checkModule = ModuleManager.GetModule(checkData.modulePath)
      if checkModule and checkData.checkFunc and checkModule[checkData.checkFunc] then
        local func = checkModule[checkData.checkFunc]
        bShow, actvityId, expire_ts = func(checkModule, buffId)
      end
      if bShow and checkModule and checkData.countFunc and checkModule[checkData.countFunc] then
        local countFunc = checkModule[checkData.countFunc]
        progressNum, totalNum, groupModID = countFunc(checkModule, actvityId)
      end
    else
      checkModule = require(checkData.modulePath)
      if checkModule and checkData.checkFunc and checkModule[checkData.checkFunc] then
        local func = checkModule[checkData.checkFunc]
        bShow, actvityId = func(buffId)
      end
      if bShow and checkModule and checkData.countFunc and checkModule[checkData.countFunc] then
        local countFunc = checkModule[checkData.countFunc]
        progressNum, totalNum = countFunc(actvityId)
      end
    end
  end
  local actData = {
    type = itemData.type,
    protect_id = itemData.protect_id,
    protect_activity_type = itemData.protect_activity_type,
    act_id = actvityId,
    progressNum = progressNum,
    totalNum = totalNum,
    expire_ts = expire_ts,
      }
  return bShow, actData
end
function logic_rating_card_buff_mgr:CheckActDataShouldShowList(activityType, buffId, itemData)
  if not activityType or not buffId then
    log(bWriteLog and "logic_rating_card_buff_mgr:CheckActDataShouldShowList no id")
    return {}
  end
  if not self:CheckRatingBuffShowInLobby(buffId) then
    log(bWriteLog and "logic_rating_card_buff_mgr:CheckActDataShouldShowList CheckRatingBuffShowInLobby false")
    return {}
  end
  local RatingCardBuffConfig = require("client.logic.double_card.rating_card_buff_config")
  local extarCheckMap = RatingCardBuffConfig.ExtraCheckActivityList or {}
  local checkData = extarCheckMap[activityType]
  if not checkData or not checkData.modulePath then
    log(bWriteLog and "logic_rating_card_buff_mgr:CheckActDataShouldShowList no modulePath")
    return {}
  end
  local checkModule
  if checkData.isModuleBase then
    checkModule = ModuleManager.GetModule(checkData.modulePath)
  else
    checkModule = require(checkData.modulePath)
  end
  if not checkModule then
    log(bWriteLog and "logic_rating_card_buff_mgr:CheckActDataShouldShowList no checkModule")
    return {}
  end
  if not checkData.checkAndCountListFunc or not checkModule[checkData.checkAndCountListFunc] then
    log(bWriteLog and "logic_rating_card_buff_mgr:CheckActDataShouldShowList no checkAndCountListFunc")
    return {}
  end
  local actDataList
  if checkData.isModuleBase then
    actDataList = checkModule[checkData.checkAndCountListFunc](checkModule, buffId, itemData)
  else
    actDataList = checkModule[checkData.checkAndCountListFunc](buffId, itemData)
  end
  local result = {}
  for k, v in ipairs(actDataList or {}) do
    local actData = {
      type = itemData.type,
      protect_id = itemData.protect_id,
      protect_activity_type = itemData.protect_activity_type,
      act_id = v.actvityId,
      progressNum = v.progressNum,
      totalNum = v.totalNum,
      groupModID = v.groupModID
    }
    table.insert(result, actData)
  end
  return result
end
function logic_rating_card_buff_mgr:GetNormalTypeBuffData(itemData)
  if not itemData or not itemData.protect_id then
    log(bWriteLog and "logic_rating_card_buff_mgr:GetNormalTypeItemData invalid itemData")
    return nil
  end
  if not self:CheckRatingBuffShowInLobby(itemData.protect_id) then
    log(bWriteLog and "logic_rating_card_buff_mgr:GetNormalTypeItemData not show")
    return nil
  end
  if itemData.max_segment_level and itemData.max_segment_level > 101 then
    local SeasonSystem = require("client.logic.season.logic_season")
    local segment = SeasonSystem.GetCurrentSegment() or 101
    if segment >= itemData.max_segment_level then
      log(bWriteLog and "logic_rating_card_buff_mgr:GetNormalTypeItemData high segment max_segment_level:" .. tostring(itemData.max_segment_level) .. " curSeg:" .. tostring(segment))
      return nil
    end
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if itemData.protect_time and itemData.protect_time > 0 and curTime >= itemData.protect_time then
    log(bWriteLog and "logic_rating_card_buff_mgr:GetNormalTypeItemData overdue")
    return nil
  end
  local buffData = {
    type = itemData.type,
    protect_id = itemData.protect_id,
    progressNum = itemData.protect_cnt,
    totalNum = itemData.protect_cnt_limit,
    count = itemData.count,
    expire_ts = itemData.protect_time
  }
  return buffData
end
function logic_rating_card_buff_mgr:AddOneCardItemToList(itemId, itemData, toList, cardBuffToIndexList)
  if not (itemId and itemData and toList) or not cardBuffToIndexList then
    log(bWriteLog and "logic_rating_card_buff_mgr:AddOneCardItemToList invalid params")
    return
  end
  if not itemData.count or itemData.count <= 0 then
    log(bWriteLog and "logic_rating_card_buff_mgr:AddOneCardItemToList invalid count")
    return
  end
  if itemData.max_segment_level and itemData.max_segment_level > 101 then
    local SeasonSystem = require("client.logic.season.logic_season")
    local segment = SeasonSystem.GetCurrentSegment() or 101
    if segment >= itemData.max_segment_level then
      log(bWriteLog and "logic_rating_card_buff_mgr:AddOneCardItemToList high segment max_segment_level:" .. tostring(itemData.max_segment_level) .. " curSeg:" .. tostring(segment))
      return
    end
  end
  local itemCfg = CDataTable.GetTableData("SeasonCardsConfig", itemId)
  if not (itemCfg and itemCfg.ProtectTypeID) or itemCfg.ProtectTypeID == 0 then
    log(bWriteLog and "logic_rating_card_buff_mgr:AddOneCardItemToList invalid itemid")
    return
  end
  if not self:CheckRatingBuffShowInLobby(itemCfg.ProtectTypeID) then
    log(bWriteLog and "logic_rating_card_buff_mgr:AddOneCardItemToList CheckRatingBuffShowInLobby false")
    return
  end
  local listIndex = cardBuffToIndexList[itemCfg.ProtectTypeID]
  if listIndex and toList[listIndex] and toList[listIndex].count then
    toList[listIndex].count = toList[listIndex].count + itemData.count
    if toList[listIndex].expire_ts and itemData.expire_ts and 0 < itemData.expire_ts and (0 >= toList[listIndex].expire_ts or 0 < toList[listIndex].expire_ts and itemData.expire_ts < toList[listIndex].expire_ts) then
      log(bWriteLog and "logic_rating_card_buff_mgr:AddOneCardItemToLis expire_ts changed")
      toList[listIndex].expire_ts = itemData.expire_ts
    end
  else
    local buffData = {
      type = itemData.type,
      res_id = itemData.res_id,
      count = itemData.count,
      expire_ts = itemData.expire_ts,
      protect_id = itemCfg.ProtectTypeID
    }
    cardBuffToIndexList[itemCfg.ProtectTypeID] = #toList + 1
    table.insert(toList, buffData)
  end
end
function logic_rating_card_buff_mgr:CheckRatingBuffShowInLobby(buffId)
  if not buffId then
    log(bWriteLog and "logic_rating_card_buff_mgr:AddOneCardBuffToList invalid params")
    return false
  end
  local buffCfg = CDataTable.GetTableData("SegmentProtected", buffId)
  if not buffCfg or not buffCfg.IsLobbyShow then
    log(bWriteLog and "logic_rating_card_buff_mgr:AddOneCardBuffToList invalid itemid")
    return false
  end
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_rating_card_buff_mgr = class(CModuleBase, nil, logic_rating_card_buff_mgr)
return Clogic_rating_card_buff_mgr