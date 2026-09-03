local logic_corps = {
  opentime = 0,
  ChangeTypeDuration = 7,
  isFirstEnter = true,
  isShowRecommendCorpsPopup = false,
  createCorpsData = nil,
  Enum_CorpTag = {
    Leader = 1,
    Deputy = 2,
    Elite = 3,
    ActingLeader = 5,
    Member = 11
  }
}
local CorpsMacro = require("client.slua.logic.corps.corps_macro")
function logic_corps.SetCreateCorpsData(iconText, selectIconID, selectColuorID)
  logic_corps.createCorpsData = {}
  logic_corps.createCorpsData.  logic_corps.createCorpsData.  logic_corps.createCorpsData.end
function logic_corps.ClearCreateCorpsData()
  logic_corps.createCorpsData = nil
end
function logic_corps.HasCorps()
  if DataMgr.corpsInfo.id and DataMgr.corpsInfo.id ~= 0 then
    return true
  else
    return false
  end
end
function logic_corps.IsNewCorpsEnabled()
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetServerTimeInSec() - logic_corps.opentime >= 0
end
function logic_corps.IsCorpsRank(rank)
  if CorpsMacro.RankIndexToType[rank] then
    return true
  else
    return false
  end
end
function logic_corps.IsFirstCommander()
  return tonumber(DataMgr.roleData.uid) == DataMgr.corpsInfo.commanderId
end
function logic_corps.IsFirstOrSecCommander()
  local myUID = tonumber(DataMgr.roleData.uid)
  return myUID == DataMgr.corpsInfo.commanderId or DataMgr.corpsInfo.secCommanderList[myUID] ~= nil
end
function logic_corps.HasEnergyType()
  if DataMgr.corpsInfo.energyType and DataMgr.corpsInfo.energyType ~= CorpsMacro.EnergyType.NoType then
    return true
  else
    return false
  end
end
function logic_corps.GetMyEnergyType()
  if logic_corps.HasCorps() and logic_corps.HasEnergyType() then
    return DataMgr.corpsInfo.energyType
  else
    return CorpsMacro.EnergyType.Active
  end
end
function logic_corps.GetEnergyTypes()
  local CorpsEnergyType = CDataTable.GetTable("CorpsEnergyType")
  local EnergyTypeTb = {}
  for _, energyType in pairs(CorpsEnergyType) do
    if LobbySystem.CheckOpen(BP_ENUM_MODULE_CORPS_LEREPLACEEV) then
      if energyType.ID == 3 then
        table.insert(EnergyTypeTb, {
          ID = energyType.ID,
          Order = energyType.Order,
          cfg = CDataTable.GetTableData("CorpsEnergyType", 5)
        })
      elseif energyType.ID ~= 5 then
        table.insert(EnergyTypeTb, {
          ID = energyType.ID,
          Order = energyType.Order,
          cfg = energyType
        })
      end
    elseif energyType.ID ~= 5 then
      table.insert(EnergyTypeTb, {
        ID = energyType.ID,
        Order = energyType.Order,
        cfg = energyType
      })
    end
  end
  table.sort(EnergyTypeTb, function(l, r)
    return l.Order < r.Order
  end)
  return EnergyTypeTb
end
function logic_corps.GetEnergyTypeConfig(energyType)
  if LobbySystem.CheckOpen(BP_ENUM_MODULE_CORPS_LEREPLACEEV) and energyType == 3 then
    energyType = 5
  end
  return CDataTable.GetTableData("CorpsEnergyType", energyType)
end
function logic_corps.GetTypeModifyRange()
  log(bWriteLog and "[LogicCorps] Get type modify range, now in season : " .. tostring(DataMgr.season_id))
  local seasonID = DataMgr.season_id
  local SeasonCfg = CDataTable.GetTableData("SeasonInfo", seasonID)
  if not SeasonCfg then
    log_error("[LogicCorps] No corresponding season config !")
    return 0, 0
  end
  local TimeUtil = require("client.common.time_util")
  local beginTime = TimeUtil.TimeStringToUnixstamp(SeasonCfg.StartTime)
  local endTime = TimeUtil.TimeStringToUnixstamp(SeasonCfg.EndTime)
  local corpsCreatedTime = DataMgr.corpsInfo.create_time
  if seasonID <= 14 then
    beginTime = logic_corps.opentime
  end
  beginTime = math.max(beginTime, corpsCreatedTime)
  endTime = math.min(endTime, beginTime + logic_corps.ChangeTypeDuration * 86400)
  return beginTime, endTime
end
function logic_corps.CanModifyType()
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local beginTime, endTime = logic_corps.GetTypeModifyRange()
  if now >= beginTime and now <= endTime then
    return true
  else
    return false
  end
end
function logic_corps.GetTypeModifyRemainingTime()
  if logic_corps.CanModifyType() then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    local _, endTime = logic_corps.GetTypeModifyRange()
    return tostring(math.floor((endTime - now) / 86400) + 1)
  else
    return tostring(0)
  end
end
function logic_corps.GetLastSeasonRankIndex()
  local lastSetTime = DataMgr.corpsInfo.setup_active_type_time
  local lastEnergyType = DataMgr.corpsInfo.last_season_active_type
  if lastSetTime and lastEnergyType and lastEnergyType ~= CorpsMacro.EnergyType.NoType then
    return CorpsMacro.RankTypeToIndex[lastEnergyType][CorpsMacro.SeasonRank]
  else
    return CorpsMacro.RankTypeToIndex[logic_corps.GetMyEnergyType()][CorpsMacro.SeasonRank]
  end
end
function logic_corps.GetLastWeekRankIndex()
  local TimeUtil = require("client.common.time_util")
  local lastSetTime = DataMgr.corpsInfo.setup_active_type_time
  local lastEnergyType = DataMgr.corpsInfo.last_season_active_type
  if lastEnergyType and lastSetTime then
    if TimeUtil.IsSameWeek(lastSetTime, TimeUtil.GetServerTimeInSec()) then
      return CorpsMacro.RankTypeToIndex[lastEnergyType][CorpsMacro.WeekRank]
    else
      return CorpsMacro.RankTypeToIndex[logic_corps.GetMyEnergyType()][CorpsMacro.WeekRank]
    end
  else
    return CorpsMacro.RankTypeToIndex[logic_corps.GetMyEnergyType()][CorpsMacro.WeekRank]
  end
end
function logic_corps.IDToColor(ID)
  local KismetMathLibrary = import("KismetMathLibrary")
  local Color = CDataTable.GetTableData("CorpsIconColor", ID)
  if not Color then
    return FSlateColor(KismetMathLibrary.Conv_ColorToLinearColor(FColor(0, 0, 0, 255)))
  end
  return FSlateColor(KismetMathLibrary.Conv_ColorToLinearColor(FColor(Color.RNum, Color.GNum, Color.BNum, 255)))
end
function logic_corps.ShowErrorCode(code)
  local msg = LocUtil.GetLocalizeResStr(code)
  if msg and msg ~= "" then
    log(bWriteLog and "[LogicCorps] Server Error " .. tostring(code))
    ShowNotice(msg)
  end
end
function logic_corps.OnLogin()
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, logic_corps.ShowRecommendCorpsPopup)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, logic_corps.ShowRecommendCorpsPopup)
end
function logic_corps:Handle_LogOut()
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, logic_corps.ShowRecommendCorpsPopup)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, logic_corps.ShowRecommendCorpsPopup)
end
function logic_corps.ShowRecommendCorpsPopup()
  if logic_corps.isShowRecommendCorpsPopup then
    log(bWriteLog and "[chub]logic_corps.ShowRecommendCorpsPopup()")
    local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
    CorpsMgr.recommend_corps_popup()
    logic_corps.isShowRecommendCorpsPopup = false
  end
end
return logic_corps