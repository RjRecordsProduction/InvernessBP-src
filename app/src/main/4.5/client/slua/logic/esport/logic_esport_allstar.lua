local ESportAllStarSystem = {
  nGraySwitchType = 0,
  grayZones = nil,
  gray_season_starttime = nil,
  common_season_starttime = 0,
  has_appointment = nil,
  svrZoneCfg = {},
  svrProcessCfg = {},
  svrGameCfg = {},
  svrAwardCfg = {},
  svrJoinAwardCfg = {},
  svrSegmentAwardCfg = {},
  svrActiveAwardCfg = {},
  svrGameList = {},
  svrGameData = {},
  svrPromoteAwardData = {},
  svrJoinAwardData = {},
  svrSegmentRankAwardStatus = {},
  svrActiveAwardStatus = {},
  nSeasonID = 0,
  nStage = -1,
  nStageID = -1,
  nMatchID = 0,
  nReqDataCount = 0,
  nSelectGameID = 0,
  nSelectGameIndex = 0,
  nNextTime = 0,
  panelType = 0,
  nLastTipTime = nil,
  globalFinalWinnersList = {},
  isGM = false,
  HasInvolved = false,
  isGM_OneTeam = false,
  firstLoginTimer = nil
}
local C_NeedReqDataNum = 3
local C_PopupDelayTime = 3
local E_GameAreaID = {
  NA = 1,
  EU = 2,
  AS = 3,
  SA = 4,
  ME = 5,
  KJ = 6
}
ESportAllStarSystem.local E_GameScheduleStage = {
  Off = 0,
  Sign = 1,
  AllIn = 2,
  Group = 3,
  ExtraGroup = 4,
  Final = 5,
  Over = 6
}
ESportAllStarSystem.local E_GameStatus = {
  Not = -1,
  Prepare = 0,
  Wait = 1,
  Match = 2,
  Over = 3,
  Next = 4
}
ESportAllStarSystem.local E_InviteType = {Team = 1, Room = 2}
ESportAllStarSystem.local E_PanelType = {
  None = 0,
  Rank = 1,
  History = 2
}
ESportAllStarSystem.local E_GraySwitchType = {
  NotOpen = 1,
  Normal = 2,
  Gray = 3
}
local ESport_PushID = {
  332,
  333,
  334,
  335,
  336,
  518
}
local table_pool = require("common.table_pool")
local tablePool = table_pool.Create()
function ESportAllStarSystem.GetAllStarInfo(bEntryOpen)
  if not ESportAllStarSystem.IsAllStarOpen() then
    return
  end
  if bEntryOpen and ESportAllStarSystem.HasGetGrayData() and ESportAllStarSystem.HasGetCfgData() then
    return
  end
  local AllStarHandler = require("client.network.Protocol.AllStarHandler")
  AllStarHandler.send_get_allstar_gray_info_req()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimer(0, function()
    local AllStarHandler = require("client.network.Protocol.AllStarHandler")
    AllStarHandler.send_get_allstar_cfg_req()
    coroutine.yield(0.01)
    AllStarHandler.send_get_allstar_stage_req()
    coroutine.yield(0.01)
    AllStarHandler.send_get_allstar_can_join_game_info_req(true)
  end)
end
function ESportAllStarSystem.IsAllStarOpen()
  return LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_ALLSTAR)
end
function ESportAllStarSystem.IsCarTeamOpen()
  return LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_ALLIANCE)
end
function ESportAllStarSystem.HasGetGrayData()
  if ESportAllStarSystem.nGraySwitchType == 0 then
    return false
  end
  if ESportAllStarSystem.nGraySwitchType == E_GraySwitchType.NotOpen then
    return false
  end
  return true
end
function ESportAllStarSystem.HasGetCfgData()
  if ESportAllStarSystem.svrZoneCfg and next(ESportAllStarSystem.svrZoneCfg) then
    return true
  end
  if ESportAllStarSystem.svrProcessCfg and next(ESportAllStarSystem.svrProcessCfg) then
    return true
  end
  if ESportAllStarSystem.svrGameCfg and next(ESportAllStarSystem.svrGameCfg) then
    return true
  end
  return false
end
function ESportAllStarSystem.IsSeasonOpen()
  local isGray
  if ESportAllStarSystem.nGraySwitchType == E_GraySwitchType.NotOpen then
    isGray = false
  elseif ESportAllStarSystem.nGraySwitchType == E_GraySwitchType.Normal then
    isGray = true
  else
    isGray = ESportAllStarSystem.CheckInGrayZone()
  end
  return ESportAllStarSystem.IsAllStarOpen() and isGray
end
function ESportAllStarSystem.IsInGray()
  return ESportAllStarSystem.nGraySwitchType == E_GraySwitchType.Gray
end
function ESportAllStarSystem.IsNewVersion()
  local min_version = "2.2.0"
  local current_version = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  if version_util.LowerVersion(current_version, min_version) then
    return false
  end
  return true
end
function ESportAllStarSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "[YY]ESportAllStarSystem.OnModePostSwitch==" .. tostring(nextState))
  if nextState == GameStatus.Login then
    ESportAllStarSystem.ClearCfgAndData()
  elseif nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    if RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.room_type == "allstar" then
      log(bWriteLog and "ESportAllStarSystem.OnModePostSwitch RoomSystem.CurrentRoomInfo.room_type is allstar")
      RoomSystem.SetCurrentRoomInfo({})
    end
  else
    ESportAllStarSystem.Release()
  end
end
function ESportAllStarSystem.IsAppointment()
  if ESportAllStarSystem.has_appointment then
    return true
  end
  return false
end
function ESportAllStarSystem.CheckInGrayZone()
  if ESportAllStarSystem.nGraySwitchType == E_GraySwitchType.Gray then
    local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
    local areaID = ESportSquadSystem.GetAllStarAreaID()
    if not areaID or areaID == 0 then
      local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
      areaID = ZoneSystem.nChooseZoneID or 0
    end
    for k, v in pairs(ESportAllStarSystem.grayZones) do
      if areaID == v then
        return true
      end
    end
  end
  return false
end
function ESportAllStarSystem.InitOnlyOne()
  EventSystem:registEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, ESportAllStarSystem.OnNextDayZeroCome)
  EventSystem:registEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_AUTHENTICATION_CHECK_SUCCESS, ESportAllStarSystem.OnEnterRoomByAuth)
end
function ESportAllStarSystem.OnNextDayZeroCome()
  local AllStarHandler = require("client.network.Protocol.AllStarHandler")
  AllStarHandler.send_get_allstar_gray_info_req()
  AllStarHandler.send_get_allstar_cfg_req()
  AllStarHandler.send_get_allstar_stage_req()
  AllStarHandler.send_get_allstar_can_join_game_info_req(true)
end
function ESportAllStarSystem.OnEnterRoomByAuth()
  if ESportAllStarSystem.nStage == ESportAllStarSystem.E_GameScheduleStage.AllIn then
    local AllStarHandler = require("client.network.Protocol.AllStarHandler")
    AllStarHandler.send_participate_competition_req()
  elseif ESportAllStarSystem.nStage == E_GameScheduleStage.Off or ESportAllStarSystem.nStage == E_GameScheduleStage.Sign or ESportAllStarSystem.nStage == E_GameScheduleStage.Over then
    log(bWriteLog and "[YY]OnEnterRoomByAuth==stage=" .. tostring(ESportAllStarSystem.nStage))
    ShowNotice(505058)
  else
    local AllStarHandler = require("client.network.Protocol.AllStarHandler")
    AllStarHandler.send_enter_allstar_room_req()
  end
end
function ESportAllStarSystem.ClearCfgAndData()
  ESportAllStarSystem.svrZoneCfg = {}
  ESportAllStarSystem.svrProcessCfg = {}
  ESportAllStarSystem.svrGameCfg = {}
  ESportAllStarSystem.svrAwardCfg = {}
  ESportAllStarSystem.svrJoinAwardCfg = {}
  ESportAllStarSystem.svrSegmentAwardCfg = {}
  ESportAllStarSystem.svrActiveAwardCfg = {}
  ESportAllStarSystem.svrGameList = {}
  ESportAllStarSystem.svrGameData = {}
  ESportAllStarSystem.svrPromoteAwardData = {}
  ESportAllStarSystem.svrJoinAwardData = {}
  ESportAllStarSystem.svrSegmentRankAwardStatus = {}
  ESportAllStarSystem.svrActiveAwardStatus = {}
  ESportAllStarSystem.nSeasonID = 0
  ESportAllStarSystem.nStage = -1
  ESportAllStarSystem.nStageID = -1
  ESportAllStarSystem.nMatchID = 0
  ESportAllStarSystem.nReqDataCount = 0
  ESportAllStarSystem.nSelectGameID = 0
  ESportAllStarSystem.nSelectGameIndex = 0
  ESportAllStarSystem.nNextTime = 0
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  esport_reddot_data.UpdatePromoteCount(0)
  esport_reddot_data.UpdateGameStartCount(nil)
  esport_reddot_data.UpdateSponsorCount()
  esport_reddot_data.UpdateBonusCount(0)
  esport_reddot_data.UpdateWeeklyAwardsCount(nil)
  local center_reddot_data = require("client.slua.logic.esport.center_reddot_data")
  center_reddot_data.UpdateCenterCount(0)
  ESportAllStarSystem.Release()
end
function ESportAllStarSystem.ClearData()
  ESportAllStarSystem.svrGameList = {}
  ESportAllStarSystem.svrGameData = {}
  ESportAllStarSystem.svrPromoteAwardData = {}
  ESportAllStarSystem.svrJoinAwardData = {}
  ESportAllStarSystem.svrSegmentRankAwardStatus = {}
  ESportAllStarSystem.svrActiveAwardStatus = {}
  ESportAllStarSystem.globalFinalWinnersList = {}
  ESportAllStarSystem.nSelectGameID = 0
  ESportAllStarSystem.nSelectGameIndex = 0
  ESportAllStarSystem.nNextTime = 0
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  esport_reddot_data.UpdatePromoteCount(0)
  esport_reddot_data.UpdateGameStartCount(nil)
  esport_reddot_data.UpdateSponsorCount()
  esport_reddot_data.UpdateBonusCount(0)
  esport_reddot_data.UpdateWeeklyAwardsCount(nil)
  local center_reddot_data = require("client.slua.logic.esport.center_reddot_data")
  center_reddot_data.UpdateCenterCount(0)
  ESportAllStarSystem.Release()
end
function ESportAllStarSystem.StartTimer()
  local time_ticker = require("common.time_ticker")
  if not ESportAllStarSystem.nTimer then
    ESportAllStarSystem.nTimer = time_ticker.AddTimerLoop(0.1, function()
      ESportAllStarSystem.RefreshTime()
    end, TIMER_INFINITE, 10)
  end
end
function ESportAllStarSystem.Release()
  if ESportAllStarSystem.nTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ESportAllStarSystem.nTimer)
    ESportAllStarSystem.nTimer = nil
  end
  ESportAllStarSystem.nLatestApplyData = nil
  ESportAllStarSystem.nLastTipTime = nil
  if ESportAllStarSystem.firstLoginTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ESportAllStarSystem.firstLoginTimer)
    ESportAllStarSystem.firstLoginTimer = nil
  end
end
function ESportAllStarSystem.IsDataReady()
  if not (ESportAllStarSystem.nSeasonID and ESportAllStarSystem.nStage) or not ESportAllStarSystem.nStageID then
    return false
  end
  return ESportAllStarSystem.nReqDataCount >= C_NeedReqDataNum
end
function ESportAllStarSystem.GetEntryInfo()
  local info = {
    nNameID = 12585,
    nDescID = 12585,
    sIcon_close = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_bg_05.Esport_Game_bg_05",
    sIcon_open = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_bg_04.Esport_Game_bg_04",
    logo_close = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_logo_hui_05.Esport_Game_logo_hui_05",
    logo_open = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_logo_05.Esport_Game_logo_05",
    color_open = FLinearColor(0.947307, 0.775822, 0.158961, 1),
    color_close = FLinearColor(0.814847, 0.814847, 0.814847, 1),
    stateFunc = ESportAllStarSystem.GetState,
    clickFunc = ESportAllStarSystem.ShowUI,
    readyDataFunc = ESportAllStarSystem.GetReadyData
  }
  return info
end
function ESportAllStarSystem.ShowUI()
  local TimeUtil = require("client.common.time_util")
  if not ESportAllStarSystem.IsSeasonOpen() then
    local grayOpenTime = ESportAllStarSystem.gray_season_starttime
    local commonOpenTime = ESportAllStarSystem.common_season_starttime
    local isInGrayZone = ESportAllStarSystem.CheckInGrayZone()
    local str
    if ESportAllStarSystem.IsInGray() then
      str = LocUtil.LocalizeResFormat(23900, TimeUtil.FormatTime_MD(commonOpenTime, true))
      ShowNotice(str)
    else
      local now = TimeUtil.GetServerTimeInSec()
      if grayOpenTime and grayOpenTime > now then
        if isInGrayZone then
          str = LocUtil.LocalizeResFormat(23900, TimeUtil.FormatTime_MD(grayOpenTime, true))
        else
          str = LocUtil.LocalizeResFormat(23900, TimeUtil.FormatTime_MD(commonOpenTime, true))
        end
        ShowNotice(str)
      else
        ShowNotice(4036)
      end
    end
    return
  end
  if ESportAllStarSystem.nStage == E_GameScheduleStage.Off then
    ShowNotice(4036)
    return false
  end
  if not ESportAllStarSystem.IsDataReady() then
    ShowNotice(4036)
    return false
  end
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local minVersion
  local TableUtil = require("common.table_util")
  local processCfg = TableUtil.GetTableValue(ESportAllStarSystem, "svrProcessCfg", ESportAllStarSystem.nStageID)
  minVersion = processCfg and processCfg.min_client_ver or "1.9.0"
  log(bWriteLog and "[YY]processCfg.min_client_ver" .. tostring(processCfg and processCfg.min_client_ver or ""))
  if version_util.CompareVersionStandard(ClientVersion, minVersion) < 0 then
    ShowNotice(9409)
    return
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if PufferMapManager:CheckClassicMapNotDownload() then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.allstar_main)
  return true
end
function ESportAllStarSystem.OpenFace()
  UIManager.ShowUI(UIManager.UI_Config.allstar_face)
end
function ESportAllStarSystem.ShowBan()
  UIManager.ShowUI(UIManager.UI_Config.allstar_ban)
end
function ESportAllStarSystem.GetState()
  if ESportAllStarSystem.nStage == -1 then
    local AllStarHandler = require("client.network.Protocol.AllStarHandler")
    AllStarHandler.send_get_allstar_cfg_req()
    return ENUM_GameProgress.Off
  end
  if not ESportAllStarSystem.nStage then
    return ENUM_GameProgress.Off
  end
  if not ESportAllStarSystem.IsSeasonOpen() then
    return ENUM_GameProgress.Off
  end
  if ESportAllStarSystem.nStage == E_GameScheduleStage.Over then
    return ENUM_GameProgress.Over
  elseif ESportAllStarSystem.nStage > E_GameScheduleStage.Off then
    if not ESportAllStarSystem.HasGetCfgData() then
      local AllStarHandler = require("client.network.Protocol.AllStarHandler")
      AllStarHandler.send_get_allstar_cfg_req()
    end
    return ENUM_GameProgress.On
  else
    return ENUM_GameProgress.Off
  end
end
function ESportAllStarSystem.GetReadyData()
  local AllStarHandler = require("client.network.Protocol.AllStarHandler")
  AllStarHandler.send_get_allstar_stage_req()
end
function ESportAllStarSystem.GetTabInfo()
  if ESportAllStarSystem.nStage <= E_GameScheduleStage.Off then
    return nil
  end
  local info = {
    nNameID = 12585,
    sUIKey = "allstar_lobby",
    clickFunc = ESportAllStarSystem.ShowLobbyUI,
    redFunc = ESportAllStarSystem.UpdateTabRed,
    bHideBg = false
  }
  return info
end
function ESportAllStarSystem.UpdateTabRed()
  return false
end
function ESportAllStarSystem.ShowLobbyUI()
  UIManager.ShowUI(UIManager.UI_Config.allstar_lobby)
end
function ESportAllStarSystem.ShowTeamShareUI(eventType, eventID, param)
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  local teamData = ESportSquadSystem.GetTeamData()
  if teamData then
    UIManager.ShowUI(UIManager.UI_Config.allstar_main)
  else
    UIManager.ShowUI(UIManager.UI_Config.esport_team_create, param.name)
  end
end
function ESportAllStarSystem.OpenWeeklyAwardsUI()
  UIManager.ShowUI(UIManager.UI_Config.allstar_rank_main, true)
end
function ESportAllStarSystem.GetCurrZoneCfg()
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  local areaID = ESportSquadSystem.GetAllStarAreaID()
  areaID = areaID or 0
  return ESportAllStarSystem.svrZoneCfg[areaID] or ESportAllStarSystem.svrZoneCfg[1]
end
function ESportAllStarSystem.GetCurrZoneID()
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  local areaID = ESportSquadSystem.GetAllStarAreaID()
  areaID = areaID or 0
  if not ESportAllStarSystem.svrZoneCfg[areaID] then
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    return ZoneSystem.nChooseZoneID
  end
  return ESportAllStarSystem.svrZoneCfg[areaID].zone_id
end
function ESportAllStarSystem.GetAreaID()
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  return ESportSquadSystem.GetAllStarAreaID() or 0
end
local _GetStageInfo = function(cfg, matchID, areaID, getIndex, isGetAll)
  local sortList = {}
  if not cfg then
    return sortList, 0
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(cfg) do
    local stageInfo = v[matchID] and v[matchID][areaID]
    if stageInfo then
      table.insert(sortList, stageInfo)
    end
  end
  table.sort(sortList, function(a, b)
    return a.begin_time < b.begin_time
  end)
  if isGetAll then
    return sortList
  end
  local count = #sortList
  if getIndex and getIndex <= count then
    return sortList[getIndex]
  end
  for i, v in ipairs(sortList) do
    if now >= v.begin_time and now <= v.end_time or now < v.begin_time and now < v.end_time then
      if v.stage == ESportAllStarSystem.E_GameScheduleStage.Group and type(v.promote_rela) == "table" and i == 1 then
        local promote_rela_data = v.promote_rela
        local maxStageId = promote_rela_data[#promote_rela_data]
        local curWeekStageId = ESportAllStarSystem.GetWeekStageID()
        if maxStageId >= curWeekStageId then
          return v, i
        end
        local _, promoteStageIds, _ = ESportAllStarSystem.GetStagePromoteList(ESportAllStarSystem.E_GameScheduleStage.AllIn)
        if promoteStageIds and next(promoteStageIds) then
          for _, stageId in pairs(promoteStageIds) do
            if ESportAllStarSystem.IsExist(promote_rela_data, stageId) then
              return v, i
            end
          end
        end
      else
        return v, i
      end
    end
  end
  return sortList[count], count
end
function ESportAllStarSystem.GetCurrStageList()
  if not ESportAllStarSystem.svrGameCfg then
    return nil
  end
  local areaID = ESportAllStarSystem.GetRealAreaID()
  local map = {}
  for i = E_GameScheduleStage.AllIn, E_GameScheduleStage.Final do
    map[i] = _GetStageInfo(ESportAllStarSystem.svrGameCfg[i], ESportAllStarSystem.nMatchID, areaID)
  end
  return map
end
function ESportAllStarSystem.GetAllStageList()
  if not ESportAllStarSystem.svrGameCfg then
    return nil
  end
  local areaID = ESportAllStarSystem.GetRealAreaID()
  local map = {}
  for i = E_GameScheduleStage.AllIn, E_GameScheduleStage.Final do
    map[i] = _GetStageInfo(ESportAllStarSystem.svrGameCfg[i], ESportAllStarSystem.nMatchID, areaID, nil, true)
  end
  return map
end
local _GetAwardInfo = function(cfg, stage_id)
  local list = {}
  if cfg and cfg[stage_id] then
    list = cfg[stage_id]
  end
  return list
end
function ESportAllStarSystem.GetAllSegmentAwardList()
  if not ESportAllStarSystem.svrSegmentAwardCfg or not next(ESportAllStarSystem.svrSegmentAwardCfg) then
    return nil
  end
  local list = {}
  local stageId = 0
  for i = 1, 4 do
    stageId = ESportAllStarSystem.GetStageIDByTabAndWeekIndex(3, i)
    list[stageId] = _GetAwardInfo(ESportAllStarSystem.svrSegmentAwardCfg, stageId)
  end
  return list
end
function ESportAllStarSystem.GetAllActiveAwardList()
  if not ESportAllStarSystem.svrActiveAwardCfg or not next(ESportAllStarSystem.svrActiveAwardCfg) then
    return nil
  end
  local list = {}
  local stageId = 0
  for i = 1, 4 do
    stageId = ESportAllStarSystem.GetStageIDByTabAndWeekIndex(3, i)
    list[stageId] = _GetAwardInfo(ESportAllStarSystem.svrActiveAwardCfg, stageId)
  end
  return list
end
function ESportAllStarSystem.GetWeekStageID()
  local list = {}
  local stageId = 1
  for i = 1, 4 do
    stageId = ESportAllStarSystem.GetStageIDByTabAndWeekIndex(3, i)
    table.insert(list, stageId)
  end
  if not next(list) or not ESportAllStarSystem.nStageID then
    return -1
  end
  for _, v in pairs(list) do
    if v == ESportAllStarSystem.nStageID then
      return v, true
    end
  end
  if ESportAllStarSystem.nStageID < list[1] then
    return list[1], false
  end
  if ESportAllStarSystem.nStageID > list[2] and ESportAllStarSystem.nStageID < list[3] then
    return list[2], false
  end
  if ESportAllStarSystem.nStageID > list[4] then
    return list[4], false
  end
  return -1
end
function ESportAllStarSystem.GetRealAreaID()
  local areaID = ESportAllStarSystem.GetAreaID()
  if areaID <= 0 then
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    local zoneID = ZoneSystem.nChooseZoneID
    if zoneID == 0 then
      zoneID = 1
    end
    if zoneID then
      for k, v in pairs(ESportAllStarSystem.svrZoneCfg) do
        if v.zone_id == zoneID then
          areaID = tonumber(k)
          break
        end
      end
    else
      areaID = 1
    end
  end
  return areaID
end
function ESportAllStarSystem.GetFastJoinAreaID()
  local areaID = ESportAllStarSystem.GetRealAreaID()
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  if areaID <= 0 then
    areaID = ZoneSystem.nChooseZoneID
  end
  return areaID
end
local _GetStageCfg = function(stageInfo)
  if stageInfo == nil then
    return
  end
  local itemData = {
    begin_time = stageInfo.begin_time,
    end_time = stageInfo.end_time,
    mode = stageInfo.mode,
    sub_mode = stageInfo.sub_mode,
    stage_id = stageInfo.stage_id,
    stage = stageInfo.stage,
    desc = stageInfo.desc
  }
  return itemData
end
function ESportAllStarSystem.GetStageList()
  local areaID = ESportAllStarSystem.GetRealAreaID()
  local data = ESportAllStarSystem.svrGameCfg
  if not data or not next(data) then
    return nil
  end
  local GetStageInfoList = function(stage)
    local stageInfoList = data[stage]
    if not stageInfoList then
      return
    end
    local result = {}
    result.stageList = {}
    for _, v in pairs(stageInfoList) do
      local stageInfo = v[ESportAllStarSystem.nMatchID] and v[ESportAllStarSystem.nMatchID][areaID]
      if stageInfo then
        local itemData = _GetStageCfg(stageInfo)
        table.insert(result.stageList, itemData)
      end
    end
    table.sort(result.stageList, function(a, b)
      return a.stage_id < b.stage_id
    end)
    return result
  end
  local map = {}
  for i = E_GameScheduleStage.AllIn, E_GameScheduleStage.Final do
    map[i] = GetStageInfoList(i)
  end
  return map
end
function ESportAllStarSystem.GetWeekIndexByStageID(stage, stageID)
  local stageConfigMap = ESportAllStarSystem.GetStageList()
  if not stageConfigMap then
    return
  end
  local weekIndex = 1
  local stageInfo = stageConfigMap[stage]
  if not stageInfo or not next(stageInfo.stageList) then
    return
  end
  local finalStageID = ESportAllStarSystem.GetFinalStageID()
  if stageID == finalStageID then
    return weekIndex
  end
  if stageInfo and stageInfo.stageList then
    for i, v in pairs(stageInfo.stageList) do
      if v.stage_id == stageID then
        if stage == ESportAllStarSystem.E_GameScheduleStage.AllIn then
          weekIndex = tonumber(v.desc)
          break
        elseif stage == ESportAllStarSystem.E_GameScheduleStage.Group then
          weekIndex = tonumber(v.desc)
          break
        elseif stage == ESportAllStarSystem.E_GameScheduleStage.ExtraGroup then
          weekIndex = tonumber(v.desc)
          break
        elseif stage == ESportAllStarSystem.E_GameScheduleStage.Final then
          weekIndex = 1
        end
      end
    end
  end
  return weekIndex
end
function ESportAllStarSystem.GetSegmentAwardStatus()
  local data = ESportAllStarSystem.svrSegmentRankAwardStatus
  if not data then
    return
  end
  local getInfo = data[ESportAllStarSystem.nSeasonID]
  if not getInfo or not next(getInfo) then
    return
  end
  local stage = ESportAllStarSystem.E_GameScheduleStage.AllIn
  local list = {}
  local weekIndex3 = 1
  for i, v in pairs(getInfo) do
    weekIndex3 = ESportAllStarSystem.GetWeekIndexByStageID(stage, i)
    list[weekIndex3] = v
  end
  return list
end
function ESportAllStarSystem.GetActiveAwardStatus()
  local data = ESportAllStarSystem.svrActiveAwardStatus
  if not data then
    return
  end
  local getInfo = data[ESportAllStarSystem.nSeasonID]
  if not getInfo or not next(getInfo) then
    return
  end
  local stage = ESportAllStarSystem.E_GameScheduleStage.AllIn
  local list = {}
  local weekIndex2 = 1
  for i, v in pairs(getInfo) do
    weekIndex2 = ESportAllStarSystem.GetWeekIndexByStageID(stage, i)
    list[weekIndex2] = v
  end
  return list
end
function ESportAllStarSystem.GetStageDescByStage(stage, IsShowExtra)
  if stage == ESportAllStarSystem.E_GameScheduleStage.AllIn then
    return LocUtil.GetLocalizeResStr(12595)
  elseif stage == ESportAllStarSystem.E_GameScheduleStage.Group then
    return LocUtil.GetLocalizeResStr(12596)
  elseif stage == ESportAllStarSystem.E_GameScheduleStage.ExtraGroup then
    if IsShowExtra then
      return LocUtil.GetLocalizeResStr(24104)
    end
    return LocUtil.GetLocalizeResStr(12596)
  elseif stage == ESportAllStarSystem.E_GameScheduleStage.Final then
    return LocUtil.GetLocalizeResStr(12597)
  end
  return ""
end
function ESportAllStarSystem.GetStageIDByTabAndWeekIndex(tabIndex, weekIndex)
  local stage_id = 0
  local stageConfigMap = ESportAllStarSystem.GetStageList()
  if not stageConfigMap then
    return
  end
  local result = {}
  if tabIndex == 3 then
    result = stageConfigMap[ESportAllStarSystem.E_GameScheduleStage.AllIn]
  elseif tabIndex == 2 then
    result = stageConfigMap[ESportAllStarSystem.E_GameScheduleStage.Group]
  elseif tabIndex == 1 then
    result = stageConfigMap[ESportAllStarSystem.E_GameScheduleStage.Final]
  elseif tabIndex == 4 then
    result = stageConfigMap[ESportAllStarSystem.E_GameScheduleStage.ExtraGroup]
  end
  stage_id = result.stageList[weekIndex].stage_id
  return stage_id
end
function ESportAllStarSystem.GetFinalStageID()
  local stageConfigMap = ESportAllStarSystem.GetStageList()
  if not stageConfigMap then
    return
  end
  local list = stageConfigMap[ESportAllStarSystem.E_GameScheduleStage.Final]
  if list then
    for _, v in pairs(list.stageList) do
      if v.stage == ESportAllStarSystem.E_GameScheduleStage.Final then
        return v.stage_id
      end
    end
  end
end
function ESportAllStarSystem.GetStageStr(stage, stageID)
  local stageConfigMap = ESportAllStarSystem.GetStageList()
  if not stageConfigMap then
    return
  end
  local list = stageConfigMap[stage]
  local stageStr = ""
  local sub_mode = 0
  for _, v in pairs(list.stageList) do
    if v.stage_id == stageID then
      stageStr = v.desc
      sub_mode = v.sub_mode
      break
    end
  end
  return stageStr, sub_mode
end
function ESportAllStarSystem.IsDoubleWeek(stageID)
  local stageConfigMap = ESportAllStarSystem.GetStageList()
  if not stageConfigMap then
    return false
  end
  local list = stageConfigMap[ESportAllStarSystem.E_GameScheduleStage.Group]
  if list then
    for _, v in pairs(list.stageList) do
      if stageID == v.stage_id then
        return true
      end
    end
  end
  return false
end
function ESportAllStarSystem.GetLatestWeekIndexByStage(stage)
  local stageId = 0
  local weekIndex = 1
  local stageConfig = ESportAllStarSystem.GetLatestStageInfo()
  if not stageConfig or not next(stageConfig) then
    return nil
  end
  for i = E_GameScheduleStage.AllIn, E_GameScheduleStage.Final do
    if stage == i then
      if stageConfig[stage] then
        stageId = stageConfig[stage].stage_id
        weekIndex = ESportAllStarSystem.GetWeekIndexByStageID(stage, stageId)
      end
      break
    end
  end
  return weekIndex, stage, stageId
end
function ESportAllStarSystem.GetLatestStageInfo()
  local stageConfigMap = ESportAllStarSystem.GetCurrStageList()
  if not stageConfigMap or not next(stageConfigMap) then
    return nil
  end
  local GetLatestStateInfo = function(stage)
    local stageConfig = stageConfigMap[stage]
    if not stageConfig then
      return nil
    end
    local result = _GetStageCfg(stageConfig)
    return result
  end
  local map = {}
  for i = E_GameScheduleStage.AllIn, E_GameScheduleStage.Final do
    map[i] = GetLatestStateInfo(i)
  end
  return map
end
function ESportAllStarSystem.GetWeekProcessCfg(stage)
  if not ESportAllStarSystem.svrProcessCfg or not next(ESportAllStarSystem.svrProcessCfg) then
    return nil
  end
  local result = {}
  for _, oneData in pairs(ESportAllStarSystem.svrProcessCfg) do
    if oneData.stage == stage then
      table.insert(result, oneData)
    end
  end
  return result
end
function ESportAllStarSystem.GetOneGameItem(stage, stageId)
  local TableUtil = require("common.table_util")
  local curItem = TableUtil.GetTableValue(ESportAllStarSystem.svrGameCfg, stage, stageId, ESportAllStarSystem.nMatchID, ESportAllStarSystem.GetRealAreaID(), "valid_game_time_slot", 1)
  return curItem
end
function ESportAllStarSystem.GetWeekLocalizeRes()
  local desc = LocUtil.GetLocalizeResStr("410047")
  local StringUtil = require("common.string_util")
  local data = StringUtil.Split(desc, "|")
  return data
end
function ESportAllStarSystem.GetProcessStartAndEndTime()
  if not ESportAllStarSystem.svrProcessCfg or not next(ESportAllStarSystem.svrProcessCfg) then
    return nil
  end
  local begin_time = ESportAllStarSystem.svrProcessCfg[1].begin_time or 0
  local end_time = ESportAllStarSystem.svrProcessCfg[#ESportAllStarSystem.svrProcessCfg].end_time or 0
  return begin_time, end_time
end
function ESportAllStarSystem.GetChampionStartAndEndTime()
  if not ESportAllStarSystem.svrProcessCfg or not next(ESportAllStarSystem.svrProcessCfg) then
    return nil
  end
  local begin_time = ESportAllStarSystem.svrProcessCfg[#ESportAllStarSystem.svrProcessCfg].begin_time or 0
  local end_time = ESportAllStarSystem.svrProcessCfg[#ESportAllStarSystem.svrProcessCfg].end_time or 0
  return begin_time, end_time
end
function ESportAllStarSystem.GetGameTimeList(areaID)
  local list = {}
  for i = E_GameScheduleStage.AllIn, E_GameScheduleStage.Final do
    if i ~= E_GameScheduleStage.ExtraGroup then
      local info = _GetStageInfo(ESportAllStarSystem.svrGameCfg[i], ESportAllStarSystem.nMatchID, areaID) or {}
      table.insert(list, info)
    end
  end
  return list
end
function ESportAllStarSystem.IsApplyGame(stageID, gameIndex)
  local applyGames = ESportAllStarSystem.svrGameData and next(ESportAllStarSystem.svrGameData) and ESportAllStarSystem.svrGameData.apply_games[stageID]
  if not applyGames then
    return false
  end
  if not applyGames.day_games then
    return false
  end
  return applyGames.day_games[gameIndex]
end
function ESportAllStarSystem.IsPromoteExtraMatch(curStage)
  local gamelist = ESportAllStarSystem.svrGameList
  if not gamelist or not next(gamelist) then
    return false
  end
  for stageId, v in pairs(gamelist) do
    if v and v[ESportAllStarSystem.nMatchID] then
      local data = v[ESportAllStarSystem.nMatchID]
      if ESportAllStarSystem.StageId2Stage(stageId) == curStage and data.is_enrolled then
        return true
      end
    end
  end
  return false
end
function ESportAllStarSystem.GetOneGameStatus(stageID, gameIndex, config)
  stageID = stageID or 0
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if not config then
    local areaID = ESportAllStarSystem.GetAreaID()
    if stageID == 0 then
      local stageConfig = ESportAllStarSystem.svrGameCfg[ESportAllStarSystem.nStage] or {}
      for k, v in pairs(stageConfig) do
        local cfg = v[ESportAllStarSystem.nMatchID] and v[ESportAllStarSystem.nMatchID][areaID]
        if cfg then
          for ii, timeSlot in ipairs(cfg.valid_game_time_slot) do
            if now >= timeSlot[1] and now <= timeSlot[2] then
              stageID = tonumber(k)
              break
            end
          end
          if 0 < stageID then
            break
          end
        end
      end
    end
    config = config or ESportAllStarSystem.svrGameCfg[ESportAllStarSystem.nStage] and ESportAllStarSystem.svrGameCfg[ESportAllStarSystem.nStage][stageID] and ESportAllStarSystem.svrGameCfg[ESportAllStarSystem.nStage][stageID][ESportAllStarSystem.nMatchID] and ESportAllStarSystem.svrGameCfg[ESportAllStarSystem.nStage][stageID][ESportAllStarSystem.nMatchID][areaID]
  end
  if not config then
    ShowNotice(6497)
    return
  end
  local matchTimeSlot = {}
  local gameCount = #config.match_time or 1
  local beginIndex = (gameIndex - 1) * gameCount
  for i = 1, gameCount do
    matchTimeSlot[i] = config.vaild_match_time_slot[i + beginIndex]
  end
  if ESportAllStarSystem.svrGameList[stageID] then
    local isSigned, isAlarmed
    if config.stage == E_GameScheduleStage.AllIn then
      isSigned = true
      if ESportAllStarSystem.svrGameData and next(ESportAllStarSystem.svrGameData) and ESportAllStarSystem.svrGameData.apply_games[stageID] then
        local applyGames = ESportAllStarSystem.svrGameData.apply_games[stageID]
        if applyGames and applyGames.day_games then
          isAlarmed = applyGames.day_games[gameIndex]
        else
          isAlarmed = false
        end
      else
        isAlarmed = false
      end
    else
      isSigned = ESportAllStarSystem.svrGameList[stageID][ESportAllStarSystem.nMatchID] and ESportAllStarSystem.svrGameList[stageID][ESportAllStarSystem.nMatchID].is_enrolled
      isAlarmed = true
    end
    if isSigned then
      for i, timeSlot in ipairs(matchTimeSlot) do
        if now >= timeSlot[1] and now <= timeSlot[2] then
          return E_GameStatus.Match, timeSlot[2], i
        elseif now > timeSlot[2] then
          local nextTimeSlot = matchTimeSlot[i + 1]
          if nextTimeSlot then
            if now < nextTimeSlot[1] then
              return E_GameStatus.Next, nextTimeSlot[1], i
            else
            end
          else
            return E_GameStatus.Over
          end
        elseif now < timeSlot[1] and i == 1 and not isAlarmed then
          return E_GameStatus.Prepare, timeSlot[1], i
        end
      end
      local nextTime = matchTimeSlot[1] and matchTimeSlot[1][1] or TimeUtil.GetServerTimeInSec() + 86400
      return E_GameStatus.Wait, nextTime, 1
    end
  end
  if config.stage == E_GameScheduleStage.AllIn then
    local isAlarmed = false
    if ESportAllStarSystem.nStage == E_GameScheduleStage.Sign then
      if ESportAllStarSystem.svrGameData and next(ESportAllStarSystem.svrGameData) and ESportAllStarSystem.svrGameData.apply_games[stageID] then
        local applyGames = ESportAllStarSystem.svrGameData.apply_games[stageID]
        if applyGames and applyGames.day_games then
          isAlarmed = applyGames.day_games[gameIndex] and applyGames.day_games[gameIndex].apply_games
        else
          isAlarmed = false
        end
      else
        isAlarmed = false
      end
    end
    for i, timeSlot in ipairs(matchTimeSlot) do
      if now >= timeSlot[1] and now <= timeSlot[2] then
        if isAlarmed then
          return E_GameStatus.Match, timeSlot[2], i
        else
          return E_GameStatus.Prepare, timeSlot[2], i
        end
      elseif now > timeSlot[2] then
        local nextTimeSlot = matchTimeSlot[i + 1]
        if not nextTimeSlot then
          return E_GameStatus.Over
        end
      elseif now < timeSlot[1] then
        if isAlarmed then
          return E_GameStatus.Wait, timeSlot[1], 1
        else
          return E_GameStatus.Prepare, timeSlot[1], 1
        end
      end
    end
  end
  return E_GameStatus.Not
end
local _ResetPromote = function(stage, currStageID, competingInfo)
  local currProcssCfg = ESportAllStarSystem.svrProcessCfg[currStageID]
  local groupPromoteRela, timeDiff
  for k, v in pairs(ESportAllStarSystem.svrProcessCfg) do
    if v.stage == stage and type(v.promote_rela) == "table" and currProcssCfg.end_time <= v.end_time then
      if not timeDiff then
        timeDiff = v.end_time - currProcssCfg.end_time
        groupPromoteRela = v.promote_rela
      elseif timeDiff > v.end_time - currProcssCfg.end_time then
        timeDiff = v.end_time - currProcssCfg.end_time
        groupPromoteRela = v.promote_rela
      end
    end
  end
  if not groupPromoteRela then
    return
  end
  local stageResult = competingInfo[stage]
  if stageResult and stageResult.game_promote then
    for stageID, v in pairs(stageResult.game_promote) do
      if not v.is_promote then
        local processCfg = ESportAllStarSystem.svrProcessCfg[stageID]
        if processCfg and processCfg.promote_rela then
          for ii, vv in ipairs(processCfg.promote_rela) do
            local targetProcessCfg = ESportAllStarSystem.svrProcessCfg[vv]
            local targetStage = targetProcessCfg.stage
            local stageInfo = competingInfo[targetStage]
            if stageInfo and stageInfo.game_promote then
              stageInfo = stageInfo.game_promote[vv]
              if stageInfo then
                stageInfo.is_promote = false
              end
            end
          end
        end
      end
    end
  else
    for _stage, v in pairs(competingInfo) do
      if v.game_promote then
        for _stageID, vv in pairs(v.game_promote) do
          local isExist = false
          for iii, relaStegeID in ipairs(groupPromoteRela) do
            if relaStegeID == _stageID then
              isExist = true
              break
            end
          end
          if not isExist then
            vv.is_promote = false
          end
        end
      end
    end
  end
end
function ESportAllStarSystem.GetStagePromoteList(Stage)
  if not ESportAllStarSystem.svrGameData or not next(ESportAllStarSystem.svrGameData) then
    return nil
  end
  local competingInfo = ESportAllStarSystem.svrGameData.competing_info
  if not competingInfo or not next(competingInfo) then
    return nil
  end
  local TableUtil = require("common.table_util")
  local sourceInfo = TableUtil.CopyTable(competingInfo)
  local promoteStageIds = {}
  local promoteExtraData = {}
  local _GetStagePromote = function(_stage)
    local result = {bIsCompeting = false, bIsPromote = false}
    local stageResult = sourceInfo[_stage]
    if stageResult and stageResult.game_promote then
      result.bIsCompeting = true
      for stageId, v in pairs(stageResult.game_promote) do
        if v.is_promote and v.is_promote == true then
          result.bIsPromote = true
          if v.is_playoff then
            result.bIsPlayOff = true
          end
          if Stage == ESportAllStarSystem.StageId2Stage(stageId) then
            table.insert(promoteStageIds, stageId)
            if v.is_playoff then
              table.insert(promoteExtraData, stageId)
            end
          end
          break
        end
      end
    end
    return result
  end
  local map = {}
  for i = E_GameScheduleStage.AllIn, E_GameScheduleStage.Final do
    map[i] = _GetStagePromote(i)
  end
  if not next(promoteStageIds) then
    promoteStageIds = nil
  else
    table.sort(promoteStageIds)
  end
  return map, promoteStageIds, promoteExtraData
end
function ESportAllStarSystem.GetCurrStageAndGame()
  if ESportAllStarSystem.nStage ~= E_GameScheduleStage.AllIn then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local areaID = ESportAllStarSystem.GetAreaID()
  local stageConfig = ESportAllStarSystem.svrGameCfg[ESportAllStarSystem.nStage] or {}
  for k, v in pairs(stageConfig) do
    local config = v[ESportAllStarSystem.nMatchID] and v[ESportAllStarSystem.nMatchID][areaID]
    if config then
      for ii, timeSlot in ipairs(config.vaild_match_time_slot) do
        if now >= timeSlot[1] and now <= timeSlot[2] then
          local gameCount = #config.match_time or 1
          return tonumber(k), math.ceil(tonumber(ii) / gameCount)
        end
      end
    end
  end
  return nil
end
function ESportAllStarSystem.GetPromoteGameEndTime()
  if ESportAllStarSystem.nStage ~= E_GameScheduleStage.Group and ESportAllStarSystem.nStage ~= E_GameScheduleStage.ExtraGroup and ESportAllStarSystem.nStage ~= E_GameScheduleStage.Final then
    return 0
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local areaID = ESportAllStarSystem.GetAreaID()
  local stageConfig = ESportAllStarSystem.svrGameCfg[ESportAllStarSystem.nStage] or {}
  for k, v in pairs(stageConfig) do
    local config = v[ESportAllStarSystem.nMatchID] and v[ESportAllStarSystem.nMatchID][areaID]
    if config then
      for ii, timeSlot in ipairs(config.vaild_match_time_slot) do
        if now >= timeSlot[1] and now <= timeSlot[2] then
          return timeSlot[2]
        end
      end
    end
  end
  return 0
end
function ESportAllStarSystem.PostTeamProfile(uid)
  if not uid then
    return
  end
  local ids = {}
  table.insert(ids, uid)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(ids, ESportAllStarSystem.GetTeamProfile, Enum_PROFILE_REPORT_CFG.ALLSTAR_TEAM)
end
function ESportAllStarSystem.GetTeamProfile(data)
  if data then
    EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_CHAMPION_PROFILE_RSP)
  end
end
function ESportAllStarSystem.GetChampionData()
  return ESportAllStarSystem.globalFinalWinnersList
end
function ESportAllStarSystem.GetChampionDataById(zone_id)
  local finalWinner = ESportAllStarSystem.globalFinalWinnersList
  if not finalWinner or not next(finalWinner) then
    return nil
  end
  for _, v in pairs(finalWinner) do
    if v.zone_id == zone_id then
      return v
    end
  end
  return nil
end
function ESportAllStarSystem.ShowEnterGameTeamUI()
  UIManager.ShowUI(UIManager.UI_Config.allstar_match_team)
end
function ESportAllStarSystem.CloseEnterGameTeamUI()
  if UIManager.IsUIShow(UIManager.UI_Config.allstar_match_team) then
    UIManager.CloseUI(UIManager.UI_Config.allstar_match_team)
  end
end
function ESportAllStarSystem.ShowInviteUIByTeam()
  UIManager.ShowUI(UIManager.UI_Config.allstar_invite_list, E_InviteType.Team)
end
function ESportAllStarSystem.ShowInviteUIByRoom()
  UIManager.ShowUI(UIManager.UI_Config.allstar_invite_list, E_InviteType.Room)
end
function ESportAllStarSystem.CreateGameUIData(config, list)
  if not config then
    return {}
  end
  list = list or {}
  if not config or not next(config) then
    return {}
  end
  local TimeUtil = require("client.common.time_util")
  for i, v in ipairs(config.valid_game_time_slot) do
    local info = {
      sName = LocUtil.LocalizeResFormat(12422, tostring(#list + 1)),
      nGameID = config.stage_id or 0,
      config = config,
      nIndex = i
    }
    local beginTimeStr = TimeUtil.FormatTime_HM(v[1], true)
    local endTimeStr = TimeUtil.FormatTime_HM(v[2], true)
    info.sTime = LocUtil.LocalizeResFormat(7545, beginTimeStr, endTimeStr)
    info.sDate = TimeUtil.FormatTime_YMD(v[1], true)
    info.nStatus, info.nNextTime = ESportAllStarSystem.GetOneGameStatus(info.nGameID, i, config)
    table.insert(list, info)
  end
  return list
end
function ESportAllStarSystem.HandleApplyTime()
  local TimeUtil = require("client.common.time_util")
  local nNow = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[ : nNow" .. nNow)
  local TableUtil = require("common.table_util")
  local apply_games = TableUtil.GetTableValue(ESportAllStarSystem.svrGameData, "apply_games")
  local latestTime, curLogo
  if apply_games and next(apply_games) then
    for id, tData in pairs(apply_games) do
      local begin_time, _, logo = ESportAllStarSystem.FindApplyGame(id, tData.apply_mode, ESportAllStarSystem.GetTableKeys(tData.day_games))
      if begin_time and nNow < begin_time and (not latestTime or latestTime > begin_time) and ESportAllStarSystem.nLastTipTime ~= begin_time then
        latestTime = begin_time
        curLogo = logo
      end
    end
  end
  local promoteTimes = ESportAllStarSystem.FindPromoteNextGame(ESportAllStarSystem.nMatchID)
  if promoteTimes then
    latestTime = latestTime or promoteTimes[1]
    for _, t in pairs(promoteTimes) do
      if t < latestTime then
        latestTime = t
      end
    end
  end
  if not latestTime then
    ESportAllStarSystem.nLatestApplyData = nil
    return
  end
  ESportAllStarSystem.nLatestApplyData = {}
  ESportAllStarSystem.nLatestApplyData.time = latestTime
  ESportAllStarSystem.nLatestApplyData.logo = curLogo
  log(bWriteLog and "[ :self.nLastTipTime" .. ESportAllStarSystem.nLatestApplyData.time)
  local leftTime = ESportAllStarSystem.nLatestApplyData.time - nNow
  log(bWriteLog and "[ : ESportAllStarSystem.leftTime" .. leftTime)
  ESportAllStarSystem.StartTimer()
end
function ESportAllStarSystem.GetTableKeys(tData)
  if type(tData) ~= "table" then
    return nil
  end
  if not next(tData) then
    return nil
  end
  local keys = {}
  for key, _ in pairs(tData) do
    table.insert(keys, key)
  end
  return keys
end
function ESportAllStarSystem.IsExist(tData, value)
  if type(tData) ~= "table" then
    return nil
  end
  if not next(tData) then
    return nil
  end
  for _, oneValue in pairs(tData) do
    if value == oneValue then
      return true
    end
  end
  return false
end
function ESportAllStarSystem.FindApplyGame(id, apply_mode, applyKeys)
  local TimeUtil = require("client.common.time_util")
  local nNow = TimeUtil.GetServerTimeInSec()
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  local apply_area = ESportSquadSystem.GetAllStarAreaID()
  if not ESportAllStarSystem.svrGameCfg or not next(ESportAllStarSystem.svrGameCfg) then
    return nil
  end
  local curData, curStage
  for stage, tData in pairs(ESportAllStarSystem.svrGameCfg) do
    if type(tData) == "table" then
      for key, value in pairs(tData) do
        if key == id then
          curData = value
          curStage = stage
          break
        end
      end
    end
  end
  local TableUtil = require("common.table_util")
  local curItem = TableUtil.GetTableValue(curData, apply_mode, apply_area)
  if not curItem then
    return nil
  end
  local timeData = TableUtil.GetTableValue(curItem, "valid_game_time_slot")
  if not timeData or not next(timeData) then
    return nil
  end
  local nTime
  for key, time in pairs(timeData) do
    if ESportAllStarSystem.IsExist(applyKeys, key) and nNow < time[1] and (not nTime or nTime > time[1]) then
      nTime = time[1]
    end
  end
  if nTime then
    log(bWriteLog and "[ : nTime" .. nTime)
  end
  local logo = TableUtil.GetTableValue(ESportAllStarSystem, "svrProcessCfg", id, "logo")
  return nTime, curStage, logo
end
function ESportAllStarSystem.FindPromoteNextGame(apply_mode, Stage)
  log(bWriteLog and "[ : FindPromoteNextGame")
  local apply_area = ESportAllStarSystem.GetRealAreaID()
  local _, promoteList, promoteExtraData = ESportAllStarSystem.GetStagePromoteList(Stage)
  if Stage then
    log(bWriteLog and "[ :Stage" .. Stage)
  end
  if not promoteList then
    return
  end
  local maxStageId = promoteList[#promoteList]
  if ESportAllStarSystem.StageId2Stage(maxStageId) == E_GameScheduleStage.Final then
    log(bWriteLog and "[ : E_GameScheduleStage.Final")
    return
  end
  if not ESportAllStarSystem.svrGameCfg or not next(ESportAllStarSystem.svrGameCfg) then
    log(bWriteLog and "[ : not self.svrGameCfg")
    return
  end
  local list = {}
  for _, tData in pairs(ESportAllStarSystem.svrGameCfg) do
    if type(tData) == "table" then
      for _, value in pairs(tData) do
        local TableUtil = require("common.table_util")
        local curItem = TableUtil.GetTableValue(value, apply_mode, apply_area)
        if curItem then
          ESportAllStarSystem.HandlePromoteList(promoteList, curItem, list, promoteExtraData)
        end
      end
    end
  end
  if not next(list) then
    list = nil
  end
  local isPlayOff = false
  if promoteExtraData and next(promoteExtraData) then
    isPlayOff = true
  end
  return list, isPlayOff
end
function ESportAllStarSystem.HandlePromoteList(promoteList, curItem, list, promoteExtraData)
  local TimeUtil = require("client.common.time_util")
  local nNow = TimeUtil.GetServerTimeInSec()
  for _, stageId in pairs(promoteList) do
    if ESportAllStarSystem.IsExist(curItem.promote_rela, stageId) then
      local TableUtil = require("common.table_util")
      local times = TableUtil.GetTableValue(curItem, "valid_game_time_slot")
      log_tree("[ :curItem", curItem)
      if times and next(times) then
        for _, time in pairs(times) do
          local t = time[1]
          if t and nNow < t and ESportAllStarSystem.nLastTipTime ~= t then
            if promoteExtraData and next(promoteExtraData) then
              if curItem.stage == ESportAllStarSystem.E_GameScheduleStage.ExtraGroup then
                table.insert(list, t)
              end
            else
              table.insert(list, t)
            end
          end
        end
      end
    end
  end
end
function ESportAllStarSystem.StageId2Stage(stageId)
  if not ESportAllStarSystem.svrProcessCfg or not next(ESportAllStarSystem.svrProcessCfg) then
    return nil
  end
  for _, oneData in pairs(ESportAllStarSystem.svrProcessCfg) do
    if oneData.id == stageId then
      return oneData.stage
    end
  end
  return 0
end
function ESportAllStarSystem.RefreshTime()
  if IsWoWEditor then
    return
  end
  if not ESportAllStarSystem.nLatestApplyData then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nNow = TimeUtil.GetServerTimeInSec()
  local leftTime = ESportAllStarSystem.nLatestApplyData.time - nNow
  log(bWriteLog and "[ : leftTime" .. leftTime)
  if leftTime <= 600 then
    ESportAllStarSystem.nLastTipTime = ESportAllStarSystem.nLatestApplyData.time
    local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local queueParam = ui_show_queue_config.GetParamTable(LobbyQueuePopUIKeyDefine.UIKey_allstar_begin_popup_SelfBuildMatch)
    UIManager.ShowUI(UIManager.UI_Config.allstar_begin_popup, ESportAllStarSystem.nLatestApplyData.logo, queueParam)
    ESportAllStarSystem.nLatestApplyData = nil
    ESportAllStarSystem.HandleApplyTime()
  end
end
function ESportAllStarSystem.ShowAllStarFirstLoginPopupUI()
  if not ESportAllStarSystem.IsSeasonOpen() then
    return
  end
  if not ESportAllStarSystem.IsDataReady() then
    return
  end
  local lv = tonumber(DataMgr.roleData.level)
  local openLvStr = DataMgr.GetSystemConfig("MinCarTeamLevel")
  local openLv = openLvStr == nil and 0 or tonumber(openLvStr)
  if not (not (lv < openLv) and DataMgr.roleData.eugdpr and (not DataMgr.roleData.eugdpr or DataMgr.roleData.eugdpr.user_type)) or DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.user_type and DataMgr.roleData.eugdpr.user_type == 0 then
    log(bWriteLog and "[YY]lv===" .. tostring(lv))
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg
  if ESportAllStarSystem.nStage == ESportAllStarSystem.E_GameScheduleStage.Sign then
    cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.AllStarOpenSign)
    if not cfg or not cfg.seasonId then
      ESportAllStarSystem.ShowPopupAndSaveData(PlayerPrefsSystem.ePlayerPrefsType.AllStarOpenSign)
    elseif cfg and cfg.seasonId and ESportAllStarSystem.nSeasonID > cfg.seasonId then
      ESportAllStarSystem.ShowPopupAndSaveData(PlayerPrefsSystem.ePlayerPrefsType.AllStarOpenSign)
    end
  elseif ESportAllStarSystem.nStage == ESportAllStarSystem.E_GameScheduleStage.AllIn then
    cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.AllStarAllInSign)
    if not cfg or not cfg.seasonId then
      ESportAllStarSystem.ShowPopupAndSaveData(PlayerPrefsSystem.ePlayerPrefsType.AllStarAllInSign)
    elseif cfg and cfg.seasonId and ESportAllStarSystem.nSeasonID > cfg.seasonId then
      ESportAllStarSystem.ShowPopupAndSaveData(PlayerPrefsSystem.ePlayerPrefsType.AllStarAllInSign)
    end
  end
end
function ESportAllStarSystem.IsInPopupTime(stage)
  local data = ESportAllStarSystem.GetWeekProcessCfg(stage)
  if not data then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if ESportAllStarSystem.nLatestApplyData and ESportAllStarSystem.nLatestApplyData.time - now <= 600 then
    return
  end
  log_tree("data===", data)
  for _, v in pairs(data) do
    if v.begin_time and v.end_time and now >= v.begin_time and now <= v.end_time then
      return true
    end
  end
  return false
end
function ESportAllStarSystem.ShowPopupAndSaveData(prefsKey)
  local logoPath = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_logo_01.Esport_Game_logo_01"
  local localizeId = 24340
  local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local queueParam = ui_show_queue_config.GetParamTable(LobbyQueuePopUIKeyDefine.UIKey_allstar_begin_popup_WholePeopleMatch)
  UIManager.ShowUI(UIManager.UI_Config.allstar_begin_popup, logoPath, localizeId, queueParam)
  if not prefsKey then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = {
    seasonId = ESportAllStarSystem.nSeasonID
  }
  PlayerPrefsSystem.SaveTableToFile_N(cfg, prefsKey)
end
function ESportAllStarSystem.ShowSharePanel(logo, gameName, stageName, stage, rank)
  local LogicESportCenter = require("client.slua.logic.esport.logic_esport_center")
  local acceptor = "module=" .. BP_ENUM_MODULE_ESPORT_AllSTAR
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  local cfg = {
    shareTitle = LogicESportCenter.GetShareDesc(),
    shareContent = LocUtil.GetLocalizeResStr("4366"),
    share_type = ShareBtnTLogShareTypeDefine.ShareOfPromotion,
    sceneType = ShareSceneType.EsportWin,
    tokenType = AdjustSystem.E_TokenType.Esport,
    moduleParams = acceptor,
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      allstarId = ESportAllStarSystem.nSeasonID,
          })
  }
  local Util = require("client.slua_ui_framework.util")
  Util.ShowShare(cfg, UIManager.UI_Config.allstar_share, logo, gameName, stageName, stage, rank)
end
function ESportAllStarSystem.ShowSharePanel2()
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  local num = ESportSquadSystem.GetMemberNum()
  local MaxCount = 6
  local LogicESportCenter = require("client.slua.logic.esport.logic_esport_center")
  local content
  if num < MaxCount then
    content = LocUtil.GetLocalizeResStr("16197")
  else
    content = LocUtil.GetLocalizeResStr("16196")
  end
  local cfg = {
    shareTitle = content,
    shareContent = LocUtil.GetLocalizeResStr("4366"),
    sceneType = ShareSceneType.EsportWin,
    shareUrl = LogicESportCenter:GetShareUrl2(),
    GetUrlFunc = LogicESportCenter.GetShareUrl2,
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      allstarId = ESportAllStarSystem.nSeasonID
    })
  }
  local Util = require("client.slua_ui_framework.util")
  Util.ShowShare(cfg, UIManager.UI_Config.esport_share, cfg.shareTitle)
end
local GetLatestTime = function(promoteTimes)
  local latestTime
  if promoteTimes and next(promoteTimes) then
    latestTime = promoteTimes[1]
    for _, time in pairs(promoteTimes) do
      if time < latestTime then
        latestTime = time
      end
    end
  else
    return false
  end
  log(bWriteLog and "[ :latestTime" .. latestTime)
  return true, latestTime
end
function ESportAllStarSystem.CheckPushConditionTime(label_id)
  log(bWriteLog and "[ : label_id" .. label_id)
  local TimeUtil = require("client.common.time_util")
  local nNow = TimeUtil.GetServerTimeInSec()
  local TableUtil = require("common.table_util")
  local apply_games = TableUtil.GetTableValue(ESportAllStarSystem.svrGameData, "apply_games")
  local result2 = ESportAllStarSystem.CheckPromoteGamePushCondition(2)
  local result3 = ESportAllStarSystem.CheckPromoteGamePushCondition(3)
  local result4 = ESportAllStarSystem.CheckPromoteGamePushCondition(4)
  local latestTime
  if label_id == 1 then
    if result4 or result3 or result2 then
      log(bWriteLog and "[ : result4 or result3 or result2")
      return false
    end
    if apply_games and next(apply_games) then
      for id, tData in pairs(apply_games) do
        local begin_time, stage = ESportAllStarSystem.FindApplyGame(id, tData.apply_mode, ESportAllStarSystem.GetTableKeys(tData.day_games))
        if begin_time and nNow < begin_time and tonumber(stage) == E_GameScheduleStage.AllIn and (not latestTime or latestTime > begin_time) then
          latestTime = begin_time
        end
      end
    end
  elseif label_id == 2 then
    if result4 or result3 then
      log(bWriteLog and "[ : result4 or result3 or result5")
      return false
    end
    return ESportAllStarSystem.CheckPromoteGamePushCondition(label_id)
  elseif label_id == 3 then
    if result4 then
      log(bWriteLog and "[ : result4")
      return false
    end
    return ESportAllStarSystem.CheckPromoteGamePushCondition(label_id)
  elseif label_id == 4 then
    return ESportAllStarSystem.CheckPromoteGamePushCondition(label_id)
  elseif label_id == 5 then
    log(bWriteLog and "[YY]warmup_push")
    if not ESportAllStarSystem.CheckAppointmentMailState(10531) then
      return false
    end
    if ESportAllStarSystem.nStage ~= ESportAllStarSystem.E_GameScheduleStage.Sign then
      return false
    end
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.AllStarSignMail)
    if cfg and cfg.seasonId and cfg.seasonId == ESportAllStarSystem.nSeasonID then
      return false
    end
    local data = ESportAllStarSystem.GetWeekProcessCfg(ESportAllStarSystem.nStage)
    if data and next(data) then
      for _, v in pairs(data) do
        if v.begin_time and v.end_time and nNow >= v.begin_time and nNow <= v.end_time then
          latestTime = nNow + 600 + 600 + 10
          cfg = {
            seasonId = ESportAllStarSystem.nSeasonID
          }
          PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.AllStarSignMail)
        end
      end
    end
    if latestTime then
      log(bWriteLog and "[YY]warmup_push==22222==" .. tostring(latestTime))
    end
  else
    log(bWriteLog and "[YY]CheckPushConditionTime=====wrong_parameter")
    return false
  end
  if latestTime then
    return true, latestTime - 600
  end
  return false
end
function ESportAllStarSystem.CheckPromoteGamePushCondition(label_id)
  local promoteTimes, isPlayOff
  if label_id == 2 then
    log(bWriteLog and "[ : ESportAllStarSystem.FindPromoteNextGame2")
    promoteTimes = ESportAllStarSystem.FindPromoteNextGame(ESportAllStarSystem.nMatchID, E_GameScheduleStage.AllIn)
    return GetLatestTime(promoteTimes)
  elseif label_id == 3 then
    log(bWriteLog and "[ : ESportAllStarSystem.FindPromoteNextGame3")
    promoteTimes, isPlayOff = ESportAllStarSystem.FindPromoteNextGame(ESportAllStarSystem.nMatchID, E_GameScheduleStage.Group)
    if isPlayOff then
      return GetLatestTime(promoteTimes)
    end
  elseif label_id == 4 then
    log(bWriteLog and "[ : ESportAllStarSystem.FindPromoteNextGame4")
    promoteTimes, isPlayOff = ESportAllStarSystem.FindPromoteNextGame(ESportAllStarSystem.nMatchID, E_GameScheduleStage.Group)
    local bIsPromote = GetLatestTime(promoteTimes)
    if bIsPromote and not isPlayOff then
      log(bWriteLog and "[ : ESportAllStarSystem.FindPromoteNextGame4====group_to_final")
      return GetLatestTime(promoteTimes)
    end
    log(bWriteLog and "[ : ESportAllStarSystem.FindPromoteNextGame4====extra_to_final")
    promoteTimes = ESportAllStarSystem.FindPromoteNextGame(ESportAllStarSystem.nMatchID, E_GameScheduleStage.ExtraGroup)
    return GetLatestTime(promoteTimes)
  end
end
function ESportAllStarSystem.CheckAppointmentMailState(mailId)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local mailInfoList = logic_mail.GetMailInfoList()
  if mailInfoList and next(mailInfoList) then
    for mail_id, _ in pairs(mailInfoList) do
      if mailId == mail_id then
        return true
      end
    end
  end
  return false
end
local _CheckStageAward = function(data, stage)
  if not data then
    return nil
  end
  local stageAwardData = data[stage]
  for k, v in pairs(stageAwardData) do
    if v == ActivityProgressStatus.Done then
      return {stage, k}
    end
  end
  return nil
end
function ESportAllStarSystem.CheckPromoteRedDot()
  if not ESportAllStarSystem.svrPromoteAwardData then
    return
  end
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  local result = ESportAllStarSystem.GetPromoteResult()
  if result then
    esport_reddot_data.UpdatePromoteCount(ActivityProgressStatus.Done)
  else
    esport_reddot_data.SendRemovePromoteTlog()
    esport_reddot_data.UpdatePromoteCount(0)
  end
end
local _UpdateMatchRedDotData = function(stage, cfg)
  if not cfg or not next(cfg) then
    return
  end
  local list = ESportAllStarSystem.CreateGameUIData(cfg)
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  if not list or not next(list) then
    esport_reddot_data.SendRemoveGameStartTlog(stage)
    esport_reddot_data.UpdateGameStartStageCount(stage, nil)
    return
  end
  for _, v in pairs(list) do
    if v.nStatus == ESportAllStarSystem.E_GameStatus.Match or v.nStatus == ESportAllStarSystem.E_GameStatus.Prepare then
      if not v.config or not next(v.config) then
        esport_reddot_data.UpdateGameStartStageCount(stage, true)
        return
      end
      local TableUtil = require("common.table_util")
      local timeData = TableUtil.GetTableValue(v.config, "vaild_match_time_slot")
      if not timeData or not next(timeData) then
        esport_reddot_data.UpdateGameStartStageCount(stage, true)
        return
      end
      local TimeUtil = require("client.common.time_util")
      local now = TimeUtil.GetServerTimeInSec()
      for _, timeSlot in pairs(timeData) do
        if now >= timeSlot[1] and now < timeSlot[1] + 600 then
          local day, round = timeSlot[3], timeSlot[4]
          local isDone = ESportAllStarSystem.HasInvolvedCurMatch(stage, v.nGameID or 0, day, round)
          if isDone then
            ESportAllStarSystem.HasInvolved = true
            esport_reddot_data.SendRemoveGameStartTlog(stage)
            esport_reddot_data.UpdateGameStartStageCount(stage, nil)
          else
            ESportAllStarSystem.HasInvolved = false
            esport_reddot_data.UpdateGameStartStageCount(stage, true)
          end
          return
        end
      end
      esport_reddot_data.UpdateGameStartStageCount(stage, true)
    else
      esport_reddot_data.SendRemoveGameStartTlog(stage)
      esport_reddot_data.UpdateGameStartStageCount(stage, nil)
    end
  end
end
function ESportAllStarSystem.HasInvolvedCurMatch(stage, stageId, day, round)
  local data = ESportAllStarSystem.svrGameData
  if not data or not next(data) then
    return nil
  end
  local competingInfo = data.competing_info
  if not competingInfo or not next(competingInfo) then
    return nil
  end
  local stageInfo = competingInfo[stage]
  if not (stageInfo and stageInfo.game_competing) or not next(stageInfo.game_competing) then
    return nil
  end
  for k, v1 in pairs(stageInfo.game_competing) do
    if not v1.game_res and not next(v1.game_res) then
      return nil
    end
    for k3, _ in pairs(v1.game_res) do
      local StringUtil = require("common.string_util")
      local info = StringUtil.Split(k3, ":")
      local DayIndex = tonumber(info[2])
      local RoundIndex = tonumber(info[3])
      if day == DayIndex and round == RoundIndex and k == stageId then
        return true
      else
        return false
      end
    end
  end
  return false
end
function ESportAllStarSystem.CheckFinishAtLeastOneMatch()
  local data = ESportAllStarSystem.svrGameData
  if not data or not next(data) then
    return nil
  end
  local competingInfo = data.competing_info
  if not competingInfo or not next(competingInfo) then
    return nil
  end
  local stageInfo = competingInfo[E_GameScheduleStage.AllIn]
  if not (stageInfo and stageInfo.game_competing) or not next(stageInfo.game_competing) then
    return nil
  end
  for _, v1 in pairs(stageInfo.game_competing) do
    if not v1.game_res and not next(v1.game_res) then
      return nil
    end
  end
  return true
end
function ESportAllStarSystem.CheckStageGameStartRedDot()
  local stageConfigMap = ESportAllStarSystem.GetCurrStageList()
  if not stageConfigMap or not next(stageConfigMap) then
    return
  end
  _UpdateMatchRedDotData(E_GameScheduleStage.AllIn, stageConfigMap[E_GameScheduleStage.AllIn])
  _UpdateMatchRedDotData(E_GameScheduleStage.Group, stageConfigMap[E_GameScheduleStage.Group])
  _UpdateMatchRedDotData(E_GameScheduleStage.ExtraGroup, stageConfigMap[E_GameScheduleStage.ExtraGroup])
  _UpdateMatchRedDotData(E_GameScheduleStage.Final, stageConfigMap[E_GameScheduleStage.Final])
end
function ESportAllStarSystem.CheckSegmentAndActiveAwardRedDot()
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  local canGetSegment = ESportAllStarSystem.CanGetSegmentAward()
  local canGetActive = ESportAllStarSystem.CanGetActiveAward()
  if canGetSegment then
    esport_reddot_data.UpdateWeeklyAwardTypeCount(1, true)
  else
    esport_reddot_data.UpdateWeeklyAwardTypeCount(1, nil)
  end
  if canGetActive then
    esport_reddot_data.UpdateWeeklyAwardTypeCount(2, true)
  else
    esport_reddot_data.UpdateWeeklyAwardTypeCount(2, nil)
  end
end
function ESportAllStarSystem.CanGetSegmentAward()
  local data = ESportAllStarSystem.svrSegmentRankAwardStatus
  if not data or not next(data) then
    return false
  end
  local segmentData = data[ESportAllStarSystem.nSeasonID]
  if not segmentData or not next(segmentData) then
    return false
  end
  for _, v in pairs(segmentData) do
    if v == ActivityProgressStatus.Done then
      return true
    end
  end
  return false
end
function ESportAllStarSystem.CanGetActiveAward()
  local data = ESportAllStarSystem.svrActiveAwardStatus
  if not data or not next(data) then
    return false
  end
  local activeData = data[ESportAllStarSystem.nSeasonID]
  if not activeData or not next(activeData) then
    return false
  end
  for _, v in pairs(activeData) do
    if v and next(v) then
      for _, value in pairs(v) do
        if value == ActivityProgressStatus.Done then
          return true
        end
      end
    end
  end
  return false
end
function ESportAllStarSystem.CheckAward()
  local awardData = ESportAllStarSystem.CheckPromoteAward()
  if not awardData then
    ESportAllStarSystem.CheckJoinAward()
  end
end
function ESportAllStarSystem.CheckPromoteAward()
  if not ESportAllStarSystem.svrPromoteAwardData then
    return nil
  end
  local result = ESportAllStarSystem.GetPromoteResult()
  if result then
    local AllStarHandler = require("client.network.Protocol.AllStarHandler")
    AllStarHandler.send_get_allstar_promote_reward_req(ESportAllStarSystem.nSeasonID, result[1], result[2])
    local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
    esport_reddot_data.UpdatePromoteCount(ActivityProgressStatus.Done)
  end
  return result
end
function ESportAllStarSystem.GetPromoteResult()
  local data = ESportAllStarSystem.svrPromoteAwardData[ESportAllStarSystem.nSeasonID]
  local result = _CheckStageAward(data, E_GameScheduleStage.Final)
  if not result then
    result = _CheckStageAward(data, E_GameScheduleStage.ExtraGroup)
    if not result then
      result = _CheckStageAward(data, E_GameScheduleStage.Group)
      result = result or _CheckStageAward(data, E_GameScheduleStage.AllIn)
    end
  end
  return result
end
function ESportAllStarSystem.CheckJoinAward()
  if not ESportAllStarSystem.svrJoinAwardData then
    return nil
  end
  local data = ESportAllStarSystem.svrJoinAwardData[ESportAllStarSystem.nSeasonID]
  local result = _CheckStageAward(data, E_GameScheduleStage.Final)
  if not result then
    result = _CheckStageAward(data, E_GameScheduleStage.Group)
    result = result or _CheckStageAward(data, E_GameScheduleStage.AllIn)
  end
  if result then
    local AllStarHandler = require("client.network.Protocol.AllStarHandler")
    AllStarHandler.send_get_allstar_join_reward_req(ESportAllStarSystem.nSeasonID, result[1], result[2])
  end
  return result
end
function ESportAllStarSystem.GetMapName(subMode, showPP)
  local mapName = ""
  local cfg = CDataTable.GetTableData("BTMode", subMode)
  if cfg then
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    mapName = logic_mode_utils.GetModeNameByModeID(subMode)
    if showPP then
      mapName = string.format("%s (%s)", mapName, LocUtil.GetLocalizeResStr(cfg.IsFpp and ENUM_PerspectiveType.FPP or ENUM_PerspectiveType.TPP))
    end
  end
  return mapName
end
function ESportAllStarSystem.OnGetAllStarCfgRsp(allstar_id, stage, zone_cfg, process_table, game_table, award_table, join_award_table, segment_rank_award_table, active_award_table)
  ESportAllStarSystem.nSeasonID = allstar_id
  ESportAllStarSystem.nStage = stage or -1
  ESportAllStarSystem.svrZoneCfg = zone_cfg
  ESportAllStarSystem.svrProcessCfg = process_table
  ESportAllStarSystem.svrGameCfg = game_table
  ESportAllStarSystem.svrAwardCfg = award_table
  ESportAllStarSystem.svrJoinAwardCfg = join_award_table
  ESportAllStarSystem.svrSegmentAwardCfg = segment_rank_award_table
  ESportAllStarSystem.svrActiveAwardCfg = active_award_table
  ESportAllStarSystem.nReqDataCount = ESportAllStarSystem.nReqDataCount + 1
  if ESportAllStarSystem.svrGameCfg[E_GameScheduleStage.Final] then
    for _, v in pairs(ESportAllStarSystem.svrGameCfg[E_GameScheduleStage.Final]) do
      for kk, _ in pairs(v) do
        ESportAllStarSystem.nMatchID = tonumber(kk)
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_GET_CONFIG)
end
function ESportAllStarSystem.OnGetAllStarStageRsp(allstar_id, stage, stage_id)
  ESportAllStarSystem.nSeasonID = allstar_id
  ESportAllStarSystem.nStage = stage or -1
  ESportAllStarSystem.nStageID = stage_id
  ESportAllStarSystem.nReqDataCount = ESportAllStarSystem.nReqDataCount + 1
end
function ESportAllStarSystem.OnGetAllStarCanJoinGameInfoRsp(game_info, isnot_show_tip)
  ESportAllStarSystem.nReqDataCount = ESportAllStarSystem.nReqDataCount + 1
  if game_info then
    ESportAllStarSystem.svrGameList = game_info
    local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
    if ESportSquadSystem.GetTeamID() then
      local AllStarHandler = require("client.network.Protocol.AllStarHandler")
      AllStarHandler.send_allstar_info_req(isnot_show_tip)
    end
  end
  local time_ticker = require("common.time_ticker")
  if not ESportAllStarSystem.firstLoginTimer then
    ESportAllStarSystem.firstLoginTimer = time_ticker.AddTimerOnce(C_PopupDelayTime, function()
      ESportAllStarSystem.ShowAllStarFirstLoginPopupUI()
    end)
  end
end
function ESportAllStarSystem.OnAllStarInfoRsp(allstar_info, allstar_promote_award, join_award, segment_rank_award, active_award)
  if allstar_info and allstar_info.allstar_id ~= ESportAllStarSystem.nSeasonID then
    return
  end
  ESportAllStarSystem.svrGameData = allstar_info
  ESportAllStarSystem.svrPromoteAwardData = allstar_promote_award
  ESportAllStarSystem.svrJoinAwardData = join_award
  ESportAllStarSystem.svrSegmentRankAwardStatus = segment_rank_award
  ESportAllStarSystem.svrActiveAwardStatus = active_award
  ESportAllStarSystem.HandleApplyTime()
  local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
  for _, push_id in pairs(ESport_PushID) do
    LocalPushSystem:SetLocalPushByCfgID(push_id)
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_GET_SIGN_GAME)
  ESportAllStarSystem.CheckPromoteRedDot()
  ESportAllStarSystem.CheckStageGameStartRedDot()
  ESportAllStarSystem.CheckSegmentAndActiveAwardRedDot()
end
function ESportAllStarSystem.OnSelectAllStarAreaRsp()
  log(bWriteLog and "[edward][logic_esport_allstar] ESportAllStarSystem.OnSelectAllStarAreaRsp")
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  local teamData = ESportSquadSystem.GetTeamData()
  if not teamData then
    ESportSquadSystem.SendQueryCarteamReq()
  end
  ESportAllStarSystem.GetAllStarInfo()
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_SELECT_AREA)
end
function ESportAllStarSystem.OnEnrollAllStarRsp(stage_id)
end
function ESportAllStarSystem.OnParticipateCompetitionRsp()
  UIManager.ShowUI(UIManager.UI_Config.allstar_match_team, ESportAllStarSystem.nSelectGameID, ESportAllStarSystem.nSelectGameIndex)
  UIManager.CloseUI(UIManager.UI_Config.allstar_game_detail)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.RemoveAllInvite()
end
function ESportAllStarSystem.OnQuitTeamRsp()
  UIManager.CloseUI(UIManager.UI_Config.allstar_match_team)
end
function ESportAllStarSystem.OnGetAllStarPromoteStatRsp(stage, is_promote, _)
  local itemData = {}
  itemData.  itemData.end
function ESportAllStarSystem.OnEnterRoomRsp(room, members, carteamInfo)
  if room and room.area_id then
    local zoneCfg = ESportAllStarSystem.svrZoneCfg[room.area_id]
    if zoneCfg then
      room.sAreaName = LocUtil.GetLocalizeResStr(zoneCfg.allstar_desc)
    end
  end
  UIManager.CloseUI(UIManager.UI_Config.allstar_game_detail)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.RemoveAllInvite()
  RoomSystem.EnterRoomByAllStar(room, members, carteamInfo)
end
function ESportAllStarSystem.GetPromoteAwardRsp(allstar_id, stage, game_id, item_info, rank)
  log_tree("ESportAllStarSystem.GetPromoteAwardRsp", {
    allstar_id,
    stage,
    game_id,
    item_info,
    rank
  })
  local data = ESportAllStarSystem.svrPromoteAwardData
  if data then
    data = data[allstar_id]
    if data then
      data = data[stage]
      if data then
        data = data[game_id]
        if data then
          ESportAllStarSystem.svrPromoteAwardData[allstar_id][stage][game_id] = ActivityProgressStatus.Get
          local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
          esport_reddot_data.UpdatePromoteCount(0)
        end
      end
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.allstar_result_popup, true, stage, game_id, item_info, rank)
end
function ESportAllStarSystem.GetJoinAwardRsp(allstar_id, stage, game_id, item_info, num)
  local data = ESportAllStarSystem.svrJoinAwardData
  if data then
    data = data[allstar_id]
    if data then
      data = data[stage]
      if data then
        data = data[game_id]
        if data then
          ESportAllStarSystem.svrJoinAwardData[allstar_id][stage][game_id] = ActivityProgressStatus.Get
        end
      end
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.allstar_result_popup, false, stage, game_id, item_info, num)
end
function ESportAllStarSystem.GetSegmentRankAwardRsp(allstar_id, stage_id, awardlist)
  local data = ESportAllStarSystem.svrSegmentRankAwardStatus
  if data then
    data = data[allstar_id]
    if data then
      data = data[stage_id]
      if data then
        ESportAllStarSystem.svrSegmentRankAwardStatus[allstar_id][stage_id] = ActivityProgressStatus.Get
      end
    end
  end
  if awardlist and 0 < #awardlist then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(awardlist)
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_UPDATE_SEGMENT_AWARD_LIST)
  ESportAllStarSystem.CheckSegmentAndActiveAwardRedDot()
end
function ESportAllStarSystem.GetActiveAwardRsp(allstar_id, stage_id, index, awardlist)
  local data = ESportAllStarSystem.svrActiveAwardStatus
  if data then
    data = data[allstar_id]
    if data then
      data = data[stage_id]
      if data then
        ESportAllStarSystem.svrActiveAwardStatus[allstar_id][stage_id][index] = ActivityProgressStatus.Get
      end
    end
  end
  if awardlist and 0 < #awardlist then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(awardlist)
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_UPDATE_SEGMENT_AWARD_LIST)
  ESportAllStarSystem.CheckSegmentAndActiveAwardRedDot()
end
function ESportAllStarSystem.GetAllStarGrayInfoRsp(result, zone_ids, gray_season_starttime, common_season_starttime, has_appointment)
  ESportAllStarSystem.nGraySwitchType = result
  ESportAllStarSystem.grayZones = zone_ids
  ESportAllStarSystem.  ESportAllStarSystem.  ESportAllStarSystem.has_appointment = has_appointment and true or false
  log(bWriteLog and "[YY]GetAllStarGrayInfoRsp==" .. tostring(has_appointment))
end
function ESportAllStarSystem.GetAllStarFinalWinnerRsp(data)
  tablePool:RecycleRecursive(ESportAllStarSystem.globalFinalWinnersList)
  ESportAllStarSystem.globalFinalWinnersList = tablePool:Get()
  if not data or not next(data) then
    return
  end
  for k, v in pairs(data) do
    local temp = tablePool:Get()
    temp.zone_id = tonumber(k)
    for _, res in pairs(v) do
      temp.team_id = res.team_id
      temp.sum_score = res.sum_score
      temp.members = tablePool:Get()
      for _, v3 in pairs(res.members) do
        table.insert(temp.members, v3)
      end
      temp.team_name = res.team_summary.name
      temp.team_flag = res.team_summary.team_flag
      temp.slogan = LocUtil.GetLocalizeResStr(9434)
    end
    table.insert(ESportAllStarSystem.globalFinalWinnersList, temp)
  end
end
function ESportAllStarSystem.GetAllStarAppointmentRsp(res)
  if res == 0 then
    ShowNotice(24344)
    ESportAllStarSystem.has_appointment = true
    EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_APPOINTMENT_STATE_UPDATE)
  else
    ESportAllStarSystem.has_appointment = nil
  end
end
function ESportAllStarSystem.QuitTeamReq()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.team_quit_request(TeamUpNewSystem.teamInfo.id)
end
function ESportAllStarSystem.AllStarAppointmentReq(zoneId)
  local AllStarHandler = require("client.network.Protocol.AllStarHandler")
  AllStarHandler.send_allstar_appointment_req(zoneId)
end
return ESportAllStarSystem