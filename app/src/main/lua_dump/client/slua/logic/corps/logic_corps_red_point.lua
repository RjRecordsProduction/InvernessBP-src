local logic_corps_red_point = {
  NewCorpsSlapDay1 = 1,
  NewCorpsSlapDay2 = 2,
  NewCorpsEnergyMissionRedPoint = 3,
  SeasonBeginEnergyTypeRedPoint = 4,
  NewCorpsLeReplaceEv = 5,
  NewCorpAppVersion = 6
}
function logic_corps_red_point.HasNewbie(ID)
  return DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS, ID)
end
function logic_corps_red_point.ClearNewbie(ID)
  if logic_corps_red_point.HasNewbie(ID) then
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS, ID)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_REDDOT)
    local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
    CorpsRedPointData.UpdateRedDot(CorpsRedPointData.reddot_id.corps_energy_new)
  end
end
function logic_corps_red_point.GetRedPoint(ID)
  return DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS, ID)
end
function logic_corps_red_point.ClearRedPoint(ID, value)
  DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS, ID, value)
end
function logic_corps_red_point.EnergyMissionRedPoint()
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  if not LogicCorps.HasCorps() or not LogicCorps.IsNewCorpsEnabled() then
    return false
  end
  local LogicCorpsEnergy = require("client.slua.logic.corps.logic_corps_energy_mission")
  if logic_corps_red_point.HasNewbie(logic_corps_red_point.NewCorpsEnergyMissionRedPoint) or LogicCorps.HasEnergyType() and LogicCorpsEnergy.HasAvailableEnergyReward() then
    return true
  else
    return false
  end
end
function logic_corps_red_point.EnergyMissionReward()
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if not CorpsMgr.IsInCorps() then
    return false
  end
  if not LogicCorps.HasCorps() or not LogicCorps.IsNewCorpsEnabled() then
    log(bWriteLog and "[v_ywuyuan] EnergyMissionReward")
    return false
  end
  local LogicCorpsEnergy = require("client.slua.logic.corps.logic_corps_energy_mission")
  if not DataMgr.corpsInfo.isInit and LogicCorpsEnergy.energy_mission_reddot then
    log(bWriteLog and "[v_ywuyuan] energy_mission_reddot")
    log(bWriteLog and "corpsgreendata EnergyMissionReward")
    return true
  end
  if LogicCorps.HasEnergyType() and LogicCorpsEnergy.HasAvailableEnergyReward() then
    log(bWriteLog and "[v_ywuyuan] HasEnergyType")
    log(bWriteLog and "corpsgreendata EnergyMissionReward")
    return true
  else
    log(bWriteLog and "[v_ywuyuan] not HasEnergyType")
    return false
  end
end
function logic_corps_red_point.EnergyMissionNew()
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if not CorpsMgr.IsInCorps() then
    return false
  end
  if not LogicCorps.HasCorps() or not LogicCorps.IsNewCorpsEnabled() then
    return false
  end
  if logic_corps_red_point.HasNewbie(logic_corps_red_point.NewCorpsEnergyMissionRedPoint) then
    log(bWriteLog and "corpsgreendata EnergyMissionNew")
    return true
  else
    return false
  end
end
function logic_corps_red_point.ManageButtonRedPoint()
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  if not CorpsMgr.IsInCorps() then
    return false
  end
  if not CorpsMemberSystem.IsSelfCommander() then
    return false
  end
  if not LogicCorps.HasCorps() or not LogicCorps.IsNewCorpsEnabled() then
    return false
  end
  if not LogicCorps.IsFirstOrSecCommander() then
    return false
  else
    return logic_corps_red_point.TypeChangeEnableRedPoint()
  end
end
function logic_corps_red_point.TypeChangeEnableRedPoint()
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  if not CorpsMgr.IsInCorps() then
    return false
  end
  if not CorpsMemberSystem.IsSelfCommander() then
    return false
  end
  if not LogicCorps.CanModifyType() then
    return false
  end
  local lastShowRedSeasonID = logic_corps_red_point.GetRedPoint(logic_corps_red_point.SeasonBeginEnergyTypeRedPoint)
  if not lastShowRedSeasonID or lastShowRedSeasonID ~= DataMgr.season_id then
    return true
  else
    return false
  end
end
function logic_corps_red_point.FightButtonOpenRedPoint()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if not CorpsMgr.IsInCorps() then
    return false
  end
  local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
  return logic_corps_fight.FightButtonOpenRedPoint()
end
function logic_corps_red_point.FightButtonDailyRedPoint()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if not CorpsMgr.IsInCorps() then
    return false
  end
  local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
  return logic_corps_fight.FightButtonDailyRedPoint()
end
function logic_corps_red_point.FightButtonOccupyRedPoint()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if not CorpsMgr.IsInCorps() then
    return false
  end
  local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
  return logic_corps_fight.FightButtonOccupyRedPoint()
end
function logic_corps_red_point.FightButtonScoreRedPoint()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if not CorpsMgr.IsInCorps() then
    return false
  end
  local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
  return logic_corps_fight.FightButtonScoreRedPoint()
end
function logic_corps_red_point.FightButtonRewardRedPoint()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if not CorpsMgr.IsInCorps() then
    return false
  end
  local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
  return logic_corps_fight.FightButtonRewardRedPoint()
end
function logic_corps_red_point.ClearTypeChangeEnableRedPoint()
  if logic_corps_red_point.TypeChangeEnableRedPoint() then
    logic_corps_red_point.ClearRedPoint(logic_corps_red_point.SeasonBeginEnergyTypeRedPoint, DataMgr.season_id)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_CLEAR_SEASON_ENERGY_RED_POINT)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_REDDOT)
  end
end
function logic_corps_red_point.ShowSlap()
  local TimeUtil = require("client.common.time_util")
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  if not LogicCorps.IsNewCorpsEnabled() then
    return
  end
  local firstTimeStamp = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS, logic_corps_red_point.NewCorpsSlapDay1)
  local secondTimeStamp = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS, logic_corps_red_point.NewCorpsSlapDay2)
  local time = TimeUtil.GetServerTimeInSec()
  if time == math.huge or time == -math.huge then
    time = 0
  end
  if not firstTimeStamp or firstTimeStamp == 0 then
    UIManager.ShowUI(UIManager.UI_Config.NewCorpsSlap)
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS, logic_corps_red_point.NewCorpsSlapDay1, time)
  elseif (not secondTimeStamp or secondTimeStamp == 0) and not TimeUtil.IsSameDay(firstTimeStamp, time) then
    UIManager.ShowUI(UIManager.UI_Config.NewCorpsSlap)
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS, logic_corps_red_point.NewCorpsSlapDay2, time)
  else
    logic_corps_red_point.ShowSlapLeReplaceEv()
  end
end
function logic_corps_red_point.ShowSlapLeReplaceEv()
  log(bWriteLog and "logic_corps_red_point.ShowSlapLeReplaceEv ")
  if not LobbySystem.CheckOpen(BP_ENUM_H5_CORPS_BATTLE_SHIELD) then
    log(bWriteLog and "logic_corps_red_point.ShowSlapLeReplaceEv BP_ENUM_H5_CORPS_BATTLE_SHIELD = false")
    return
  end
  local leReplaceEvTimeStamp = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS_LEREPLACEEV, logic_corps_red_point.NewCorpsLeReplaceEv)
  local bisOpen = LobbySystem.CheckOpen(BP_ENUM_MODULE_CORPS_LEREPLACEEV)
  log(bWriteLog and "leReplaceEvTimeStamp = " .. tostring(leReplaceEvTimeStamp) .. ",bisOpen = " .. tostring(bisOpen))
  local alreadyOpen = false
  if not leReplaceEvTimeStamp and bisOpen then
    local TimeUtil = require("client.common.time_util")
    local val = TimeUtil.GetServerTimeInSec()
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS_LEREPLACEEV, logic_corps_red_point.NewCorpsLeReplaceEv, val)
    alreadyOpen = true
    if alreadyOpen then
      local ClientVersion = TimeUtil.GetServerTimeInSec()
      DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS_LEREPLACEEV, logic_corps_red_point.NewCorpAppVersion, ClientVersion)
    end
  end
  local newCorpAppVersion = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS_LEREPLACEEV, logic_corps_red_point.NewCorpAppVersion)
  log(bWriteLog and "newCorpAppVersion = " .. tostring(newCorpAppVersion))
  local TimeUtil = require("client.common.time_util")
  local ClientVersion = TimeUtil.GetServerTimeInSec()
  if not newCorpAppVersion then
    if alreadyOpen then
      DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS_LEREPLACEEV, logic_corps_red_point.NewCorpAppVersion, ClientVersion)
      return
    end
    local version_util = require("client.common.version_util")
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_CORPS_LEREPLACEEV, logic_corps_red_point.NewCorpAppVersion, ClientVersion)
  end
end
return logic_corps_red_point