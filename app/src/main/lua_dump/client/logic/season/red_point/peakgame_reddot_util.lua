local peakgame_reddot_util = {}
function peakgame_reddot_util:DefineAndResetData()
  log(bWriteLog and "peakgame_reddot_util:DefineAndResetData")
end
function peakgame_reddot_util:OnInitialize()
end
function peakgame_reddot_util:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_SEASON_INFO, self.OnGetPeakGameSeasonInfo, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_RANK_CHANGE, self.OnClassicSegmentChange, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_PEAKGAME_INFO_CHANGE_NOTIFY, self.OnPeakGameInfoChangeNotify, self)
  self:AddCommonEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_INFO_UPDATE, self.RefreshPeakGameSegRewardReddot, self)
  self:AddCommonEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_WONDERFULPLAYBACK_REDDOT_REFRESH, self.RefreshPeakGameWoderfulPlayBackReddot, self)
end
function peakgame_reddot_util:OnGetPeakGameSeasonInfo()
  log(bWriteLog and "peakgame_reddot_util:OnGetPeakGameSeasonInfo")
  local LogicPeakGameReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameReward)
  local canTakeAward = LogicPeakGameReward:CanTakeAward()
  DataMgr.roleData.peakgame_can_take_reward = canTakeAward
  self:RefreshPeakGameSegRewardReddot()
end
function peakgame_reddot_util:OnClassicSegmentChange()
  log(bWriteLog and "peakgame_reddot_util:OnClassicSegmentChange")
  self:RefreshPeakGameNewSeasonReddot()
end
function peakgame_reddot_util:OnPeakGameInfoChangeNotify()
  log(bWriteLog and "peakgame_reddot_util:OnPeakGameInfoChangeNotify")
  self:AddTimerOnce(0.1, function()
    log(bWriteLog and "peakgame_reddot_util:OnPeakGameInfoChangeNotify 1")
    self:RefreshPeakGameSegRewardReddot()
    self:RefreshPeakGameNewSeasonReddot()
  end)
end
function peakgame_reddot_util:OnLoginSuccess()
  log(bWriteLog and "peakgame_reddot_util:OnLoginSuccess")
  self:RefreshPeakGameSegRewardReddot()
  self:RefreshPeakGameNewSeasonReddot()
  local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
  if regionGroupConfig and regionGroupConfig.CommunityEntranceSwitch ~= 0 then
    local wonderfulPBReddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_WonderfulPlayBack_Reddot)
    wonderfulPBReddot:RequestWonderfulPlayBackState("main")
  end
end
function peakgame_reddot_util:SetPeakGameReddotByType(_reddotType, count)
  log(bWriteLog and "peakgame_reddot_util:SetPeakGameReddotByType _reddotType = " .. tostring(_reddotType) .. " count = " .. tostring(count))
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local redpoint = season_redpoint_data.GetRedData()
  local ReddotType = season_redpoint_data.ReddotType
  if redpoint then
    if redpoint.types[_reddotType] then
      log(bWriteLog and "peakgame_reddot_util:SetPeakGameReddotByType 1")
      redpoint.types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[_reddotType] then
      log(bWriteLog and "peakgame_reddot_util:SetPeakGameReddotByType 2")
      redpoint.types[ReddotType.seasonCombReward].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.peakGameSeasonEntry].types[_reddotType] then
      log(bWriteLog and "peakgame_reddot_util:SetPeakGameReddotByType 3")
      redpoint.types[ReddotType.seasonCombReward].types[ReddotType.peakGameSeasonEntry].types[_reddotType].newCount = count
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.peakGameSeasonEntry].types[ReddotType.peakGameSeasonReward].types[_reddotType] then
      log(bWriteLog and "peakgame_reddot_util:SetPeakGameReddotByType 4")
      redpoint.types[ReddotType.seasonCombReward].types[ReddotType.peakGameSeasonEntry].types[ReddotType.peakGameSeasonReward].types[_reddotType].newCount = count
    end
  end
end
function peakgame_reddot_util:GetPeakGameReddotByType(_reddotType)
  log(bWriteLog and "peakgame_reddot_util:GetPeakGameReddotByType _reddotType = " .. tostring(_reddotType))
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local redpoint = season_redpoint_data.GetRedData()
  local ReddotType = season_redpoint_data.ReddotType
  if redpoint then
    if redpoint.types[_reddotType] then
      log(bWriteLog and "peakgame_reddot_util:GetPeakGameReddotByType 1")
      return redpoint.types[_reddotType]
    elseif redpoint.types[ReddotType.seasonCombReward].types[_reddotType] then
      log(bWriteLog and "peakgame_reddot_util:GetPeakGameReddotByType 2")
      return redpoint.types[ReddotType.seasonCombReward].types[_reddotType]
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.peakGameSeasonEntry].types[_reddotType] then
      log(bWriteLog and "peakgame_reddot_util:GetPeakGameReddotByType 3")
      return redpoint.types[ReddotType.seasonCombReward].types[ReddotType.peakGameSeasonEntry].types[_reddotType]
    elseif redpoint.types[ReddotType.seasonCombReward].types[ReddotType.peakGameSeasonEntry].types[ReddotType.peakGameSeasonReward].types[_reddotType] then
      log(bWriteLog and "peakgame_reddot_util:GetPeakGameReddotByType 4")
      return redpoint.types[ReddotType.seasonCombReward].types[ReddotType.peakGameSeasonEntry].types[ReddotType.peakGameSeasonReward].types[_reddotType]
    end
  end
  log(bWriteLog and "peakgame_reddot_util:GetPeakGameReddotByType 4")
  return nil
end
function peakgame_reddot_util:RefreshPeakGameSegRewardReddot()
  log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameSegRewardReddot")
  if DataMgr and DataMgr.roleData then
    local canTakeAward = DataMgr.roleData.peakgame_can_take_reward
    log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameSegRewardReddot canTakeAward = " .. tostring(canTakeAward))
    local count = 0
    if canTakeAward then
      count = 1
    end
    local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
    local bCheckCanPlayPeakGame = LogicPeakGame:CheckCanPlayPeakGame()
    if not bCheckCanPlayPeakGame then
      count = 0
    end
    local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
    local ReddotType = season_redpoint_data.ReddotType
    self:SetPeakGameReddotByType(ReddotType.peakGameSegReward, count)
  end
end
function peakgame_reddot_util:RefreshPeakGameNewSeasonReddot()
  log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameNewSeasonReddot")
  local season_id = DataMgr.season_id
  log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameNewSeasonReddot season_id = " .. tostring(season_id))
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if not season_id or season_id < PeakGameConfig.MinPeakGameSeasonId then
    return
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local ReddotType = season_redpoint_data.ReddotType
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local flagTab1 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePeakGameNewSeason) or {}
  if flagTab1 and flagTab1[season_id] and flagTab1[season_id] == 1 then
    log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameNewSeasonReddot 1")
  else
    log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameNewSeasonReddot 2")
    self:SetPeakGameReddotByType(ReddotType.peakGameNewSeason, 1)
  end
  local flagTab2 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePeakGameNewSeasonCanPlay) or {}
  if flagTab2 and flagTab2[season_id] and flagTab2[season_id] == 1 then
    log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameNewSeasonReddot 3")
  else
    local logic_season_util = require("client.logic.season.logic_season_util")
    local segmentLevel, maxMode, zoneId = logic_season_util:GetCurrZoneMaxSegment(DataMgr.roleData.allzoneSegment)
    local peakGameParamCfg = CDataTable.GetTableData("PeakGameParam", "min_segment_id")
    if peakGameParamCfg and peakGameParamCfg.PeakGameParamValue then
      local minSegment = peakGameParamCfg.PeakGameParamValue
      local last_season_max_segment = DataMgr.roleData.last_season_max_segment
      log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameNewSeasonReddot segmentLevel = " .. tostring(segmentLevel) .. " minSegment = " .. tostring(minSegment) .. " last_season_max_segment = " .. tostring(last_season_max_segment))
      if segmentLevel and minSegment and segmentLevel >= minSegment or last_season_max_segment and minSegment <= last_season_max_segment then
        local TimeUtil = require("client.common.time_util")
        local nNowTime = TimeUtil.GetServerTimeInSec()
        local peakgame_start_time = DataMgr.roleData.peakgame_start_time
        log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameNewSeasonReddot peakgame_start_time = " .. tostring(peakgame_start_time) .. " nNowTime = " .. tostring(nNowTime))
        if peakgame_start_time and nNowTime >= peakgame_start_time then
          log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameNewSeasonReddot 4")
          self:SetPeakGameReddotByType(ReddotType.peakGameNewSeason, 1)
        end
      end
    end
  end
end
function peakgame_reddot_util:RefreshPeakGameWoderfulPlayBackReddot(_, _, hasRedDoted, Source)
  log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameWoderfulPlayBackReddot hasRedDoted =" .. tostring(hasRedDoted) .. "Source:" .. tostring(Source))
  if Source ~= "main" then
    return
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local reddotData = self:GetPeakGameReddotByType(season_redpoint_data.ReddotType.peakGameWonderfulPlayBack)
  local count = 0
  if reddotData and reddotData.newCount then
    count = tonumber(reddotData.newCount) or 0
  else
    log(bWriteLog and "peakgame_reddot_util:RefreshPeakGameWoderfulPlayBackReddot reddotData is nil, use default count 0")
  end
  if hasRedDoted then
    count = 1
  else
    local wonderfulPBReddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_WonderfulPlayBack_Reddot)
    if wonderfulPBReddot:ReadIsClicked(Source) then
      count = 1
    end
  end
  local ReddotType = season_redpoint_data.ReddotType
  self:SetPeakGameReddotByType(ReddotType.peakGameWonderfulPlayBack, count)
end
function peakgame_reddot_util:ClearPeakGameNewSeasonReddot()
  log(bWriteLog and "peakgame_reddot_util:ClearPeakGameNewSeasonReddot")
  local season_id = DataMgr.season_id
  log(bWriteLog and "peakgame_reddot_util:ClearPeakGameNewSeasonReddot season_id = " .. tostring(season_id))
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if not season_id or season_id < PeakGameConfig.MinPeakGameSeasonId then
    return
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local redpoint = season_redpoint_data.GetRedData()
  local ReddotType = season_redpoint_data.ReddotType
  if redpoint and redpoint.types[ReddotType.seasonCombReward].types[ReddotType.peakGameSeasonEntry].types[ReddotType.peakGameNewSeason].newCount > 0 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local flagTab1 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePeakGameNewSeason) or {}
    if flagTab1 and flagTab1[season_id] and flagTab1[season_id] == 1 then
      log(bWriteLog and "peakgame_reddot_util:ClearPeakGameNewSeasonReddot 1")
    else
      log(bWriteLog and "peakgame_reddot_util:ClearPeakGameNewSeasonReddot 2")
      flagTab1[season_id] = 1
      PlayerPrefsSystem.SaveTableToFile_N(flagTab1, PlayerPrefsSystem.ePlayerPrefsType.ePeakGameNewSeason)
      self:SetPeakGameReddotByType(ReddotType.peakGameNewSeason, 0)
    end
    local flagTab2 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePeakGameNewSeasonCanPlay) or {}
    if flagTab2 and flagTab2[season_id] and flagTab2[season_id] == 1 then
      log(bWriteLog and "peakgame_reddot_util:ClearPeakGameNewSeasonReddot 3")
    else
      local logic_season_util = require("client.logic.season.logic_season_util")
      local segmentLevel, maxMode, zoneId = logic_season_util:GetCurrZoneMaxSegment(DataMgr.roleData.allzoneSegment)
      local peakGameParamCfg = CDataTable.GetTableData("PeakGameParam", "min_segment_id")
      if peakGameParamCfg and peakGameParamCfg.PeakGameParamValue then
        local minSegment = peakGameParamCfg.PeakGameParamValue
        local last_season_max_segment = DataMgr.roleData.last_season_max_segment
        log(bWriteLog and "peakgame_reddot_util:ClearPeakGameNewSeasonReddot segmentLevel = " .. tostring(segmentLevel) .. " minSegment = " .. tostring(minSegment) .. " last_season_max_segment = " .. tostring(last_season_max_segment))
        if segmentLevel and minSegment and segmentLevel >= minSegment or last_season_max_segment and minSegment <= last_season_max_segment then
          local TimeUtil = require("client.common.time_util")
          local nNowTime = TimeUtil.GetServerTimeInSec()
          local peakgame_start_time = DataMgr.roleData.peakgame_start_time
          log(bWriteLog and "peakgame_reddot_util:ClearPeakGameNewSeasonReddot peakgame_start_time = " .. tostring(peakgame_start_time) .. " nNowTime = " .. tostring(nNowTime))
          if peakgame_start_time and nNowTime >= peakgame_start_time then
            log(bWriteLog and "peakgame_reddot_util:ClearPeakGameNewSeasonReddot 4")
            flagTab2[season_id] = 1
            PlayerPrefsSystem.SaveTableToFile_N(flagTab2, PlayerPrefsSystem.ePlayerPrefsType.ePeakGameNewSeasonCanPlay)
            self:SetPeakGameReddotByType(ReddotType.peakGameNewSeason, 0)
          end
        end
      end
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cpeakgame_reddot_util = class(CModuleBase, nil, peakgame_reddot_util)
return Cpeakgame_reddot_util