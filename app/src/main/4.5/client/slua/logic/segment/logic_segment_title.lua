local logic_segment_title = {}
function logic_segment_title:OnInitialize()
  logic_segment_title.__super.OnInitialize(self)
  self:InitData()
end
function logic_segment_title:IsSegmentTitleSwitchOpen()
  local switch = false
  if DataMgr and DataMgr.isHsegmentTitleOpen then
    switch = true
  end
  return switch
end
function logic_segment_title:GetProfileSegmentTitleIdByTeamNum(profileData, zoneId, teamNum, perspective)
  log(bWriteLog and "logic_segment_title:GetProfileSegmentTitleIdByTeamNum")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:GetProfileSegmentTitleIdByTeamNum not open")
    return
  end
  if not (zoneId and teamNum and perspective) or type(profileData) ~= "table" then
    log(bWriteLog and "logic_segment_title:GetProfileSegmentTitleIdByTeamNum params is invalid")
    return
  end
  if not profileData.hsegment_title_det then
    log(bWriteLog and "logic_segment_title:GetProfileSegmentTitleIdByTeamNum no TitleData")
    return
  end
  return self:GetSegmentTitleIdByTeamNum(profileData.hsegment_title_det, zoneId, teamNum, perspective)
end
function logic_segment_title:GetProfileSegmentTitleId(profileData, zoneId, modeId)
  log(bWriteLog and "logic_segment_title:GetProfileSegmentTitleId")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:GetProfileSegmentTitleId not open")
    return
  end
  if not (zoneId and modeId) or type(profileData) ~= "table" then
    log(bWriteLog and "logic_segment_title:GetProfileSegmentTitleId params is invalid")
    return
  end
  if not profileData.hsegment_title_det then
    log(bWriteLog and "logic_segment_title:GetProfileSegmentTitleId no TitleData")
    return
  end
  return self:GetSegmentTitleId(profileData.hsegment_title_det, zoneId, modeId)
end
function logic_segment_title:GetSegmentTitleIdByTeamNum(segmentTitleList, zoneId, teamNum, perspective)
  log(bWriteLog and "logic_segment_title:GetSegmentTitleIdByTeamNum")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:GetSegmentTitleIdByTeamNum not open")
    return
  end
  if not (zoneId and teamNum and perspective) or type(segmentTitleList) ~= "table" then
    log(bWriteLog and "logic_segment_title:GetSegmentTitleIdByTeamNum params is invalid")
    return
  end
  log(bWriteLog and "logic_segment_title:GetSegmentTitleIdByTeamNum zoneid:" .. tostring(zoneId) .. " teamNum:" .. tostring(teamNum) .. " perspective:" .. tostring(perspective))
  local modeId = self:GetModeIdByNumAndPerspective(teamNum, perspective)
  if not (modeId and segmentTitleList[zoneId]) or not segmentTitleList[zoneId][modeId] then
    log(bWriteLog and "logic_segment_title:GetSegmentTitleIdByTeamNum zone segmentTitleList is invalid")
    return
  end
  return segmentTitleList[zoneId][modeId].id
end
function logic_segment_title:GetSegmentTitleId(segmentTitleList, zoneId, modeId)
  log(bWriteLog and "logic_segment_title:GetSegmentTitleId")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:GetSegmentTitleId not open")
    return
  end
  if not (zoneId and modeId) or type(segmentTitleList) ~= "table" then
    log(bWriteLog and "logic_segment_title:GetSegmentTitleId params is invalid")
    return
  end
  log(bWriteLog and "logic_segment_title:GetSegmentTitleId zoneid:" .. zoneId .. " modeId:" .. modeId)
  if not segmentTitleList[zoneId] or not segmentTitleList[zoneId][modeId] then
    log(bWriteLog and "logic_segment_title:GetSegmentTitleId zone segmentTitleList is invalid")
    return
  end
  return segmentTitleList[zoneId][modeId].id
end
function logic_segment_title:GetSelfSegmentTitleIdByTeamNum(zoneId, teamNum, perspective)
  log(bWriteLog and "logic_segment_title:GetSelfSegmentTitleIdByTeamNum")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:GetSelfSegmentTitleIdByTeamNum not open")
    return
  end
  if not (zoneId and teamNum) or not perspective then
    log(bWriteLog and "logic_segment_title:GetSelfSegmentTitleIdByTeamNum params is invalid")
    return
  end
  if not (DataMgr and DataMgr.roleData) or not DataMgr.roleData.allzoneSegmentTitle then
    log(bWriteLog and "logic_segment_title:GetSelfSegmentTitleIdByTeamNum DataMgr is invalid")
    return
  end
  local segTitleList = DataMgr.roleData.allzoneSegmentTitle
  return self:GetSegmentTitleIdByTeamNum(segTitleList, zoneId, teamNum, perspective)
end
function logic_segment_title:GetSelfSegmentTitleId(zoneId, modeId)
  log(bWriteLog and "logic_segment_title:GetSelfSegmentTitleId")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:GetSelfSegmentTitleId not open")
    return
  end
  if not zoneId or not modeId then
    log(bWriteLog and "logic_segment_title:GetSelfSegmentTitleId params is invalid")
    return
  end
  if not (DataMgr and DataMgr.roleData) or not DataMgr.roleData.allzoneSegmentTitle then
    log(bWriteLog and "logic_segment_title:GetSelfSegmentTitleId DataMgr is invalid")
    return
  end
  local segTitleList = DataMgr.roleData.allzoneSegmentTitle
  return self:GetSegmentTitleId(segTitleList, zoneId, modeId)
end
function logic_segment_title:GetTitleModeIdbyBattleType(battleType)
  log(bWriteLog and "logic_segment_title:GetTitleModeIdbyBattleType")
  if not battleType then
    log(bWriteLog and "logic_segment_title:GetTitleModeIdbyBattleType battleType is invalid")
    return nil
  end
  local enumSegmentType = enum_SegmentType
  if battleType == 101 then
    return enumSegmentType.solo
  elseif battleType == 102 then
    return enumSegmentType.double
  elseif battleType == 103 then
    return enumSegmentType.team
  elseif battleType == 401 then
    return enumSegmentType.fpp_solo
  elseif battleType == 402 then
    return enumSegmentType.fpp_double
  elseif battleType == 403 then
    return enumSegmentType.fpp_team
  end
end
function logic_segment_title:IsHighestSegment(segmentID)
  return segmentID == 801
end
function logic_segment_title:GetMaxSegementLevelWithZoneAndModeId(allSegmentInfo)
  if not allSegmentInfo or type(allSegmentInfo) ~= "table" then
    log(bWriteLog and "logic_segment_title:GetMaxSegementLevelWithZoneAndModeId segmentinfo is nil 1")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    allSegmentInfo = {
      [3] = allSegmentInfo[3]
    }
  else
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    if logic_multiple_area:IsConnectToRussiaArea() then
      allSegmentInfo = {
        [2] = allSegmentInfo[2]
      }
    end
  end
  if not allSegmentInfo then
    log(bWriteLog and "logic_segment_title:GetMaxSegementLevelWithZoneAndModeId segmentinfo is nil 2")
    return
  end
  local maxSegment = -1
  local maxSegmentZoneId, maxSegmentModeId
  for zoneId, segInfo in pairs(allSegmentInfo) do
    for modeId, segId in pairs(segInfo) do
      if segId > maxSegment then
        maxSegment = segId
        maxSegmentModeId = modeId
        maxSegmentZoneId = zoneId
      end
    end
  end
  return maxSegment, maxSegmentZoneId, maxSegmentModeId
end
function logic_segment_title:GetProfileRankdataMaxRating(profileRankdata)
  if not profileRankdata or type(profileRankdata) ~= "table" then
    log(bWriteLog and "logic_segment_title:GetProfileRankdataMaxRating profileRankdata is nil 1")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    profileRankdata = {
      [3] = profileRankdata[3]
    }
  else
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    if logic_multiple_area:IsConnectToRussiaArea() then
      profileRankdata = {
        [2] = profileRankdata[2]
      }
    end
  end
  if not profileRankdata then
    log(bWriteLog and "logic_segment_title:GetProfileRankdataMaxRating profileRankdata is nil 2")
    return
  end
  local C_ModeMap = {
    [1] = "solo",
    [2] = "duo",
    [3] = "squad",
    [4] = "fppsolo",
    [5] = "fppduo",
    [6] = "fppsquad"
  }
  local maxRating = 0
  for _, rankinfo in pairs(profileRankdata) do
    for _, modeStr in ipairs(C_ModeMap) do
      if rankinfo[modeStr] and rankinfo[modeStr].rank_rating then
        local rating = rankinfo[modeStr].rank_rating
        if maxRating < rating then
          maxRating = rating
        end
      end
    end
  end
  log(bWriteLog and "logic_segment_title:GetProfileRankdataMaxRating maxRating:" .. tostring(maxRating))
  return maxRating
end
function logic_segment_title:SetMaxSegmentRankInteralWithTitle(RankIntegral_Small_UIBP, allSegmentInfo, allZoneSegmentTitle, seasonId)
  if not slua.isValid(RankIntegral_Small_UIBP) then
    log(bWriteLog and "logic_segment_title:SetMaxSegmentRankInteralWithTitle widget is nil")
    return
  end
  if not allSegmentInfo then
    log(bWriteLog and "logic_segment_title:SetMaxSegmentRankInteralWithTitle allSegmentInfo is nil")
    RankIntegral_Small_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local maxSegment, zoneid, modeid = self:GetMaxSegementLevelWithZoneAndModeId(allSegmentInfo)
  if not maxSegment or maxSegment <= 0 then
    log(bWriteLog and "logic_segment_title:SetMaxSegmentRankInteralWithTitle maxSegment is nil")
    RankIntegral_Small_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  RankIntegral_Small_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if seasonId and seasonId ~= 0 and seasonId ~= DataMgr.season_id then
    log(bWriteLog and "logic_segment_title:SetMaxSegmentRankInteralWithTitle not cur season")
    RankIntegral_Small_UIBP:SetRankInteralBySeason(maxSegment, nil, seasonId)
    return
  end
  local segmentTitleId = self:GetSegmentTitleId(allZoneSegmentTitle, zoneid, modeid)
  if not segmentTitleId or tonumber(segmentTitleId) == 0 then
    RankIntegral_Small_UIBP:SetRankInteralBySeason(maxSegment, nil, seasonId or DataMgr.season_id)
  else
    RankIntegral_Small_UIBP:SetRankInteralWithSegmentTitle(maxSegment, nil, seasonId, segmentTitleId)
  end
end
function logic_segment_title:SendSetOneSegmentTitle(segmentTitleId, zoneId, modeId)
  log(bWriteLog and "logic_segment_title:SendSetOneSegmentTitle")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:SendSetOneSegmentTitle not open")
    return
  end
  if not (zoneId and modeId) or not segmentTitleId then
    log(bWriteLog and "logic_segment_title:SendSetOneSegmentTitle params is invalid")
    return
  end
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_set_high_segment_title_pursuit(zoneId, modeId, segmentTitleId)
end
function logic_segment_title:OnSetOneSegmentTitleRsp(segmentTitleId, zoneId, modeId)
  log(bWriteLog and "logic_segment_title:OnSetOneSegmentTitleRsp")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title not open")
    return
  end
  if not (zoneId and modeId) or not segmentTitleId then
    log(bWriteLog and "logic_segment_title:OnSetOneSegmentTitleRsp params is invalid")
    return
  end
  log(bWriteLog and "logic_segment_title:OnSetOneSegmentTitleRsp zoneid is " .. tostring(zoneId) .. " modeId is " .. tostring(modeId))
  log(bWriteLog and "logic_segment_title:OnSetOneSegmentTitleRsp segmentTitleId", segmentTitleId)
  if not DataMgr.roleData.allzoneSegment[zoneId][modeId] then
    log(bWriteLog and "logic_segment_title:OnSetOneSegmentTitleRsp segment is invalid")
    return
  end
  local segmentTitleInfo = DataMgr.roleData.allzoneSegmentTitle or {}
  segmentTitleInfo[zoneId] = segmentTitleInfo[zoneId] or {}
  segmentTitleInfo[zoneId][modeId] = segmentTitleInfo[zoneId][modeId] or {}
  segmentTitleInfo[zoneId][modeId].id = segmentTitleId
  DataMgr.roleData.allzoneSegmentTitle = segmentTitleInfo
  if self.seaseonSegmentTitleDetail and self.seaseonSegmentTitleDetail[zoneId] and self.seaseonSegmentTitleDetail[zoneId][modeId] then
    self.seaseonSegmentTitleDetail[zoneId][modeId].id = segmentTitleId
  end
  EventSystem:postEvent(EVENTTYPE_SEGMENT_TITLE, EVENTID_SEGMENT_TITLE_SET_RSP, segmentTitleId, zoneId, modeId)
end
function logic_segment_title:send_get_high_segment_title_pursuit()
  log(bWriteLog and "logic_segment_title:SendSetOneSegmentTitle")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title not open")
    return
  end
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_high_segment_title_pursuit()
end
function logic_segment_title:on_get_high_segment_title_pursuit_rsp(titleData, archiveData)
  log(bWriteLog and "logic_segment_title:on_get_high_segment_title_pursuit_rsp")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title not open")
    return
  end
  if not titleData or not next(titleData) then
    log(bWriteLog and "logic_segment_title:on_get_high_segment_title_pursuit_rsp titleData is invalid")
    return
  end
  log_tree(bWriteLog and "logic_segment_title:on_get_high_segment_title_pursuit_rsp titleData", titleData)
  log_tree(bWriteLog and "logic_segment_title:on_get_high_segment_title_pursuit_rsp archiveData", archiveData)
  self.seaseonSegmentTitleDetail = titleData
  self.titleArchive = archiveData
  EventSystem:postEvent(EVENTTYPE_SEGMENT_TITLE, EVENTID_SEGMENT_TITLE_GET_DETAIL_RSP)
end
function logic_segment_title:RequestOtherSegmentTitle(target_uid)
  log(bWriteLog and "logic_segment_title:send_get_other_high_segment_title")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title not open")
    return
  end
  if self.curTargetUid and target_uid ~= self.curTargetUid then
    self.otherTitleDetail = nil
    self.othertitleArchive = nil
  end
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_other_high_segment_title(target_uid)
end
function logic_segment_title:OnGetOtherSegmentTitleRsp(target_uid, title_data, archive_data)
  log(bWriteLog and "logic_segment_title:on_get_other_high_segment_title_rsp")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:on_get_other_high_segment_title_rsp not open")
    return
  end
  if not title_data or not next(title_data) then
    log(bWriteLog and "logic_segment_title:on_get_other_high_segment_title_rsp title_data is invalid")
    return
  end
  self.curTargetUid = target_uid
  self.otherTitleDetail = title_data
  self.othertitleArchive = archive_data
  EventSystem:postEvent(EVENTTYPE_SEGMENT_TITLE, EVENTID_SEGMENT_TITLE_GET_OTHER_DETAIL_RSP)
end
function logic_segment_title:CheckSegmentTitleShouldSlap(segmentTitleDetail)
  log(bWriteLog and "logic_segment_title:CheckSegmentTitleShouldSlap")
  if not segmentTitleDetail then
    return false
  end
  if not segmentTitleDetail.id or segmentTitleDetail.id ~= 0 then
    return false
  end
end
function logic_segment_title:GetSegTitleSlapData(segmentTitleDetail)
  log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData not open")
    return false, nil
  end
  if not segmentTitleDetail or not segmentTitleDetail.should_slap_segment_title then
    log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData not shouldSlap")
    return false, nil
  end
  if not segmentTitleDetail.id or segmentTitleDetail.id ~= 0 then
    log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData has slap")
    return false, nil
  end
  if type(segmentTitleDetail.progress) ~= "table" then
    log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData no progress data")
    return false, nil
  end
  local titleGetDetailData = {}
  local hasNewTitle = false
  local titleCfgList = CDataTable.GetTable("SegmentTitleConfig")
  for titleId, detailData in pairs(segmentTitleDetail.progress) do
    if titleCfgList[titleId] and detailData.hasGet == 1 then
      local titleCfg = titleCfgList[titleId]
      local data = {
        titleId = titleCfg.ID,
        descId = titleCfg.TitleDescId,
        nameId = titleCfg.TitleNameId,
        paramLimit = titleCfg.Param1_f * titleCfg.Param1Coefficient,
        realParam = detailData.param * titleCfg.Param1Coefficient,
        ifDefaultTitle = titleCfg.IfDefaultTitle,
        priority = titleCfg.Priority
      }
      if not titleCfg.IfDefaultTitle then
        hasNewTitle = true
      end
      table.insert(titleGetDetailData, data)
    end
  end
  if not hasNewTitle then
    log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData no new title")
    return false, nil
  end
  table.sort(titleGetDetailData, function(a, b)
    return a.priority > b.priority
  end)
  log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData slap")
  return true, titleGetDetailData
end
function logic_segment_title:ShowSegmentTitleSlapUI(segmentId, zoneid, modeId, segmentTitleDetail, callback)
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:ShowSegmentTitleSlapUI not open")
    if callback then
      callback()
    end
    return
  end
  if not (segmentId and segmentTitleDetail) or not segmentTitleDetail.should_slap_segment_title then
    log(bWriteLog and "logic_segment_title:ShowSegmentTitleSlapUI should_slap_segment_title no")
    if callback then
      callback()
    end
    return
  end
  local shouldSlap, slapData = self:GetSegTitleSlapData(segmentTitleDetail)
  if not shouldSlap or type(slapData) ~= "table" or not next(slapData) then
    log(bWriteLog and "logic_segment_title:ShowSegmentTitleSlapUI should_slap_segment_title slap false")
    if callback then
      callback()
    end
    return
  end
  log(bWriteLog and "logic_segment_title:ShowSegmentTitleSlapUI should_slap_segment_title slap true")
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_AceExcellence_UIBP, segmentId, zoneid, modeId, slapData, callback)
end
function logic_segment_title:ShowSegmentTitleSlapUIBySlapData(segmentId, zoneid, modeId, segmentTitleSlapData, callback)
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:ShowSegmentTitleSlapUIBySlapData not open")
    if callback then
      callback()
    end
    return
  end
  if not segmentId or type(segmentTitleSlapData) ~= "table" or not next(segmentTitleSlapData) then
    log(bWriteLog and "logic_segment_title:ShowSegmentTitleSlapUIBySlapData segmentTitleSlapData no")
    if callback then
      callback()
    end
    return
  end
  log(bWriteLog and "logic_segment_title:ShowSegmentTitleSlapUIBySlapData should_slap_segment_title slap true")
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_AceExcellence_UIBP, segmentId, zoneid, modeId, segmentTitleSlapData, callback)
end
function logic_segment_title:GetSeasonSegmentTitleDetail(zoneId, modeId)
  if not zoneId or not modeId then
    return nil
  end
  if not self:IsSegmentTitleSwitchOpen() then
    return nil
  end
  if type(self.seaseonSegmentTitleDetail) ~= "table" or not self.seaseonSegmentTitleDetail[zoneId] then
    return nil
  end
  if type(self.seaseonSegmentTitleDetail[zoneId]) ~= "table" then
    return nil
  end
  return self.seaseonSegmentTitleDetail[zoneId][modeId]
end
function logic_segment_title:GetTitleArchive(zoneId, modeId, titleId)
  if not (zoneId and modeId) or not titleId then
    return
  end
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:GetTitleArchive switch close")
    return
  end
  if not self.titleArchive then
    log(bWriteLog and "logic_segment_title:GetTitleArchive not self.titleArchive")
    return
  end
  if not self.titleArchive[zoneId] then
    log(bWriteLog and "logic_segment_title:GetTitleArchive not data, zoneId = " .. tostring(zoneId))
    return
  end
  if not self.titleArchive[zoneId][modeId] then
    log(bWriteLog and "logic_segment_title:GetTitleArchive not data, zoneId = " .. tostring(zoneId) .. ", modeId = " .. tostring(modeId))
    return
  end
  return self.titleArchive[zoneId][modeId][titleId]
end
function logic_segment_title:GetOtherSeasonSegmentTitleDetail(zoneId, modeId)
  if not zoneId or not modeId then
    return
  end
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:GetOtherSeasonSegmentTitleDetail switch close")
    return
  end
  if not self.otherTitleDetail then
    log(bWriteLog and "logic_segment_title:GetTitleArchive not self.otherTitleDetail")
    return
  end
  if not self.otherTitleDetail[zoneId] then
    log(bWriteLog and "logic_segment_title:GetTitleArchive not data, zoneId = " .. tostring(zoneId))
    return
  end
  if not self.otherTitleDetail[zoneId][modeId] then
    log(bWriteLog and "logic_segment_title:GetTitleArchive not data, zoneId = " .. tostring(zoneId) .. ", modeId = " .. tostring(modeId))
    return
  end
  return self.otherTitleDetail[zoneId][modeId]
end
function logic_segment_title:GetOtherTitleArchive(zoneId, modeId, titleId)
  if not (zoneId and modeId) or not titleId then
    return
  end
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:GetTitleArchive switch close")
    return
  end
  if not self.othertitleArchive then
    log(bWriteLog and "logic_segment_title:GetTitleArchive not self.othertitleArchive")
    return
  end
  if not self.othertitleArchive[zoneId] then
    log(bWriteLog and "logic_segment_title:GetTitleArchive not data, zoneId = " .. tostring(zoneId))
    return
  end
  if not self.othertitleArchive[zoneId][modeId] then
    log(bWriteLog and "logic_segment_title:GetTitleArchive not data, zoneId = " .. tostring(zoneId) .. ", modeId = " .. tostring(modeId))
    return
  end
  return self.othertitleArchive[zoneId][modeId][titleId]
end
function logic_segment_title:GetSegTitleDetailData(segmentTitleDetail)
  log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData")
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData not open")
    return nil
  end
  if not segmentTitleDetail or type(segmentTitleDetail.progress) ~= "table" then
    log(bWriteLog and "logic_segment_title:ProcessingTitleDetailData not shouldSlap or data is invalid")
    return nil
  end
  local selectTitleId = segmentTitleDetail.id
  local titleDetailList = {}
  local titleGetDetailList = {}
  local titleNotGetDetailList = {}
  local titleCfgList = CDataTable.GetTable("SegmentTitleConfig")
  for titleId, detailData in pairs(segmentTitleDetail.progress) do
    if titleCfgList[titleId] then
      local titleCfg = titleCfgList[titleId]
      local data = {
        titleId = titleCfg.ID,
        descId = titleCfg.TitleDescId,
        nameId = titleCfg.TitleNameId,
        paramLimit = titleCfg.Param1_f * titleCfg.Param1Coefficient,
        realParam = detailData.param * titleCfg.Param1Coefficient,
        ifDefaultTitle = titleCfg.IfDefaultTitle,
        priority = titleCfg.Priority,
        hasGet = detailData.hasGet,
        ParamCoefficient = titleCfg.Param1Coefficient
      }
      if selectTitleId and selectTitleId ~= 0 and titleId == selectTitleId then
        table.insert(titleDetailList, data)
      elseif detailData.hasGet == 1 then
        table.insert(titleGetDetailList, data)
      else
        table.insert(titleNotGetDetailList, data)
      end
    end
  end
  table.sort(titleGetDetailList, function(a, b)
    return a.priority > b.priority
  end)
  table.sort(titleNotGetDetailList, function(a, b)
    return a.priority > b.priority
  end)
  for _, titleData in ipairs(titleGetDetailList) do
    table.insert(titleDetailList, titleData)
  end
  for _, titleData in ipairs(titleNotGetDetailList) do
    table.insert(titleDetailList, titleData)
  end
  return titleDetailList, selectTitleId
end
function logic_segment_title:ConvertSegmentToShow(segment)
  if not segment then
    log(bWriteLog and "logic_segment_title:ConvertSegmentToShow no segment")
    return nil
  end
  local segCfg = FuncUtil.GetRankTableData(segment, DataMgr.season_id)
  if not segCfg then
    log(bWriteLog and "logic_segment_title:ConvertSegmentToShow no segment segment config is nil")
    return nil
  end
  local segmentType = segCfg.IntegralTypeNew or 1
  local segmentTitleShowCfg = CDataTable.GetTableData("SegmentTitleShowConfig", segmentType)
  if not segmentTitleShowCfg then
    log(bWriteLog and "logic_segment_title:ConvertSegmentToShow no config ")
    return segment
  end
  if segmentTitleShowCfg.IfShowSegmentTitle == false and segmentTitleShowCfg.UIShowSegId ~= 0 then
    return segmentTitleShowCfg.UIShowSegId
  end
  return segment
end
function logic_segment_title:CheckSeasonSegmentTitleSlap(segmentId, segmentTitleDetail)
  if not self:IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "logic_segment_title:ShowSegmentTitleSlapUI not open")
    return false, nil
  end
  if not (segmentId and segmentTitleDetail) or not segmentTitleDetail.should_slap_segment_title then
    log(bWriteLog and "logic_segment_title:ShowSegmentTitleSlapUI should_slap_segment_title false")
    return false, nil
  end
  local shouldSlap, slapData = self:GetSegTitleSlapData(segmentTitleDetail)
  if not shouldSlap or type(slapData) ~= "table" or not next(slapData) then
    return false, nil
  end
  return true, slapData
end
function logic_segment_title:ClearTitleDetailData()
  log(bWriteLog and "logic_segment_title:ClearTitleDetailData")
  self.seaseonSegmentTitleDetail = nil
end
function logic_segment_title:InitData()
  log(bWriteLog and "logic_segment_title:InitData")
  self.seaseonSegmentTitleDetail = nil
  self.titleArchive = nil
  self.otherTitleDetail = nil
  self.othertitleArchive = nil
  self.curTargetUid = nil
end
function logic_segment_title:ClearData()
  log(bWriteLog and "logic_segment_title:ClearData")
  self.seaseonSegmentTitleDetail = nil
end
function logic_segment_title:GetModeIdByNumAndPerspective(teamNum, perspective)
  if not teamNum or not perspective then
    log(bWriteLog and "logic_segment_title:GetModeIdByNumAndPerspective params is invalid")
    return
  end
  local enumSegmentType = enum_SegmentType
  local modeId
  if perspective == ENUM_PerspectiveType.TPP then
    if teamNum == 1 then
      modeId = enumSegmentType.solo
    elseif teamNum == 2 then
      modeId = enumSegmentType.double
    elseif teamNum == 4 then
      modeId = enumSegmentType.team
    end
  elseif perspective == ENUM_PerspectiveType.FPP then
    if teamNum == 1 then
      modeId = enumSegmentType.fpp_solo
    elseif teamNum == 2 then
      modeId = enumSegmentType.fpp_double
    elseif teamNum == 4 then
      modeId = enumSegmentType.fpp_team
    end
  end
  return modeId
end
function logic_segment_title:IsSegmentStarSwitchOpen()
  local switch = false
  if DataMgr and DataMgr.isSeasonStarOpen then
    switch = true
  end
  return switch
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicSegmentTitle = class(CModuleBase, nil, logic_segment_title)
return CLogicSegmentTitle