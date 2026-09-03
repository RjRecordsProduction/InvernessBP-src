local enter_guide = {NewbieGuideLevelModID = 24001}
function enter_guide.Reset()
  enter_guide.executeFightGuide = false
  enter_guide.initGuideTimer = false
  enter_guide.MatchId = enter_guide.NewbieGuideLevelModID
  enter_guide.PingTime = 7
  enter_guide.bEnterLobby = false
  enter_guide.bEnterMatch = false
  enter_guide.bPingDefeated = false
  enter_guide.show3C1 = false
  enter_guide.bLinkFightServer = false
  enter_guide.waitPingTimer = nil
  enter_guide.growup_novice_level = nil
  enter_guide.bFinishFight = false
  enter_guide.ZoneListInfoRspTimer = nil
  enter_guide.SelectZoneRspTimer = nil
  enter_guide.MatchRspTimer = nil
  enter_guide.Save_growup_novice_level = nil
  enter_guide.Manual_EnterFightGuide = false
end
function enter_guide.Init()
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_ZONELIST_RSP, enter_guide.WaitAutoChooseZoneID)
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, enter_guide.LinkFightServer)
  EventSystem:unregistEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_FIGHTING, enter_guide.MatchFightNotice)
  EventSystem:unregistEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_LOBBY_LOAD_DONE, enter_guide.LobbyFinishDone)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, enter_guide.OnEntetLobby)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, enter_guide.UpdateSwitch)
  EventSystem:unregistEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, enter_guide.OnWidgetHide)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_ZONELIST_RSP, enter_guide.WaitAutoChooseZoneID)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, enter_guide.LinkFightServer)
  EventSystem:registEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_FIGHTING, enter_guide.MatchFightNotice)
  EventSystem:registEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_LOBBY_LOAD_DONE, enter_guide.LobbyFinishDone)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, enter_guide.OnEntetLobby)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, enter_guide.UpdateSwitch)
  enter_guide.Reset()
end
function enter_guide.SaveData(growup_novice_level)
  enter_guide.Save_  log_tree("[qintong] enter_guide.SaveData type =" .. type(growup_novice_level), growup_novice_level)
end
function enter_guide.IsEnterGuide140Version()
  local enter = false
  if type(enter_guide.Save_growup_novice_level) == "boolean" then
    if enter_guide.Save_growup_novice_level then
      enter = true
    end
  elseif type(enter_guide.Save_growup_novice_level) == "table" then
    local TableUtil = require("common.table_util")
    if TableUtil.CountTable(enter_guide.Save_growup_novice_level) == 1 and enter_guide.Save_growup_novice_level[-1] == 1 then
      enter = true
    end
  end
  return enter
end
function enter_guide.Start(growup_novice_level)
  local tempData = true
  local executeFightGuide = false
  if tempData then
    if type(growup_novice_level) == "boolean" then
      if growup_novice_level then
        executeFightGuide = true
      else
        executeFightGuide = false
      end
    elseif type(growup_novice_level) == "table" then
      executeFightGuide = false
    elseif type(growup_novice_level) == "nil" then
      executeFightGuide = false
    end
  end
  enter_guide.  log_tree("[qintong] enter_guide  growup_novice_level = " .. type(growup_novice_level) .. " growup_novice_level = ", growup_novice_level)
  if _G.IsEditor then
    enter_guide.executeFightGuide = false
  else
    enter_guide.  end
end
function enter_guide.UpdateSwitch()
end
function enter_guide.WaitAutoChooseZoneID()
  log(bWriteLog and "[qintong] : in game WaitAutoChooseZoneID " .. slua.getMicroseconds())
  log(bWriteLog and "[qintong] enter_guide" .. tostring(enter_guide.executeFightGuide) .. " ,initGuideTimer=" .. tostring(enter_guide.initGuideTimer))
  if not enter_guide.executeFightGuide then
    return
  end
  if enter_guide.initGuideTimer then
    return
  end
  enter_guide.initGuideTimer = true
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local MaxDelayTime = enter_guide.PingTime
  local time_ticker = require("common.time_ticker")
  local TimeUtil = require("client.common.time_util")
  local beginTime = TimeUtil.OSTime()
  enter_guide.waitPingTimer = time_ticker.AddTimerLoop(0, function()
    log(bWriteLog and TimeUtil.OSTime() .. "[qintong] FuncUtil.GetServerTimeInSec " .. TimeUtil.GetServerTimeInSec())
    if TimeUtil.OSTime() - beginTime <= MaxDelayTime then
      enter_guide.bPingDefeated = false
      log(bWriteLog and "[qintong] enter_guide ZoneSystem.nChooseZoneID  " .. ZoneSystem.nChooseZoneID)
      if ZoneSystem.nChooseZoneID ~= 0 then
        time_ticker.RemoveTimer(enter_guide.waitPingTimer)
        enter_guide.waitPingTimer = nil
        return
      end
    else
      enter_guide.bPingDefeated = true
      if ZoneSystem.nChooseZoneID == 0 and GameStatus.IsInLobbyOrMainCity() then
        local LoadingSystem = require("client.slua.logic.loading.logic_loading")
        LoadingSystem.RefreshLoadPercent(0.5)
        enter_guide.OnEntetLobby()
        time_ticker.RemoveTimer(enter_guide.waitPingTimer)
        enter_guide.waitPingTimer = nil
        return
      end
    end
  end, TIMER_INFINITE, 0.2)
end
function enter_guide.LinkFightServer(_, _, ret)
  log(bWriteLog and "[qintong] : in game LinkFightServer" .. slua.getMicroseconds())
  log(bWriteLog and tostring(ret) .. " [qintong] enter_guide LinkFightServer" .. tostring(enter_guide.executeFightGuide) .. "self.bEnterLobby= " .. tostring(enter_guide.bEnterLobby))
  if not enter_guide.executeFightGuide then
    return
  end
  if ret == NetErrorCode_NONE then
    enter_guide.bLinkFightServer = true
    if enter_guide.bEnterLobby then
      enter_guide.EnterMatch()
    end
  else
    enter_guide.executeFightGuide = false
    enter_guide.show3C1 = true
  end
end
function enter_guide.OnEntetLobby()
  log(bWriteLog and "[qintong] : in game  OnEntetLobby" .. slua.getMicroseconds())
  log(bWriteLog and "[qintong] enter_guide.OnEntetLobby" .. tostring(enter_guide.bPingDefeated) .. tostring(enter_guide.show3C1))
  if not enter_guide.executeFightGuide then
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return
  end
  if enter_guide.bPingDefeated then
    enter_guide.bPingDefeated = false
    log(bWriteLog and "[qintong] enter_guide ShowUI UIManager.UI_Config.Setting_ChangeServe")
    UIManager.ShowUI(UIManager.UI_Config.Setting_ChangeServer, function()
      log(bWriteLog and "[qintong] :enter_guide  OnEntetLobby  ShowUI:UIManager.UI_Config.Setting_ChangeServer")
      enter_guide.SendMsg()
    end)
  end
  if enter_guide.show3C1 then
    enter_guide.show3C1 = false
    log(bWriteLog and "[qintong] enter_guide ShowUI UIManager.UI_Config.new_player_gifts_panel")
    UIManager.ShowUI(UIManager.UI_Config.new_player_gifts_panel)
  end
end
function enter_guide.LobbyFinishDone()
  log(bWriteLog and "[qintong] : in game LobbyFinishDone" .. slua.getMicroseconds())
  log(bWriteLog and "[qintong] enter_guide LobbyFinishDone self.bLinkFightServer= " .. tostring(enter_guide.bLinkFightServer))
  enter_guide.bEnterLobby = true
  if not enter_guide.executeFightGuide then
    return
  end
  if enter_guide.bLinkFightServer then
    enter_guide.EnterMatch()
  end
end
function enter_guide.MatchFightNotice(_, _, msg)
  log(bWriteLog and "[qintong] : in game MatchFightNotice" .. slua.getMicroseconds())
  if not enter_guide.executeFightGuide then
    return
  end
  if msg ~= NetErrorCode_NONE then
    enter_guide.executeFightGuide = false
    enter_guide.show3C1 = true
  end
end
function enter_guide.EnterMatch()
  log(bWriteLog and "[qintong] : in game EnterMatch" .. slua.getMicroseconds())
  log(bWriteLog and "[qintong] : enter_guide.EnterMatch" .. tostring(enter_guide.bPingDefeated) .. tostring(enter_guide.bEnterMatch))
  if not enter_guide.executeFightGuide then
    return
  end
  if enter_guide.bPingDefeated then
    return
  end
  if enter_guide.bEnterMatch then
    return
  end
  enter_guide.bEnterMatch = true
  enter_guide.SendMsg()
end
function enter_guide.SendMsg()
  if not enter_guide.executeFightGuide then
    return
  end
  log(bWriteLog and "[qintong] :enter_guide.SendMsg ")
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  local arrayMapId = {
    enter_guide.MatchId
  }
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  enter_guide.StartMatchRspTimer()
  MatchHandler.send_on_match_req(enter_guide.MatchId, 1, arrayMapId, DeviceOSInfo.InfoList)
end
function enter_guide.GetNewbieLevelModTeamId()
  return 24001
end
function enter_guide.Version140EnterGuide()
  enter_guide.Manual_EnterFightGuide = true
  log(bWriteLog and "[qintong] :enter_guide.Version140EnterGuide")
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  local arrayMapId = {
    enter_guide.MatchId
  }
  local modGroupId = enter_guide.GetNewbieLevelModTeamId()
  if modGroupId then
    arrayMapId = {modGroupId}
  end
  log(bWriteLog and string.format("enter_guide.Version140EnterGuide use %s", tostring(arrayMapId[1])))
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  MatchHandler.send_on_match_req(enter_guide.MatchId, 1, arrayMapId, DeviceOSInfo.InfoList)
end
function enter_guide.CheckIsDoing()
  log(bWriteLog and "[qintong] enter_guide.CheckIsDoing" .. tostring(enter_guide.executeFightGuide))
  return enter_guide.executeFightGuide
end
function enter_guide.StartZoneListInfoRspTimer()
  if enter_guide.ZoneListInfoRspTimer then
    return
  end
  if not enter_guide.executeFightGuide then
    return
  end
  log(bWriteLog and "[qintong] enter_guide.StartZoneListInfoRspTimer")
  local time_ticker = require("common.time_ticker")
  enter_guide.ZoneListInfoRspTimer = time_ticker.AddTimerOnce(7, function()
    enter_guide.executeFightGuide = false
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.RefreshLoadPercent(1)
  end)
end
function enter_guide.StopZoneListInfoRspTimer()
  log(bWriteLog and "[qintong] enter_guide.StopZoneListInfoRspTimer")
  if enter_guide.ZoneListInfoRspTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(enter_guide.ZoneListInfoRspTimer)
    enter_guide.ZoneListInfoRspTimer = nil
  end
end
function enter_guide.StartSelectZoneRspTimer()
  if enter_guide.SelectZoneRspTimer then
    return
  end
  if not enter_guide.executeFightGuide then
    return
  end
  log(bWriteLog and "[qintong] enter_guide.StartSelectZoneRspTimer")
  local time_ticker = require("common.time_ticker")
  enter_guide.SelectZoneRspTimer = time_ticker.AddTimerOnce(7, function()
    enter_guide.executeFightGuide = false
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.RefreshLoadPercent(1)
  end)
end
function enter_guide.StopSelectZoneRspTimer(ret)
  log(bWriteLog and "[qintong] enter_guide.StopSelectZoneRspTimer")
  if enter_guide.SelectZoneRspTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(enter_guide.SelectZoneRspTimer)
    enter_guide.SelectZoneRspTimer = nil
  end
end
function enter_guide.StartMatchRspTimer()
  if enter_guide.MatchRspTimer then
    return
  end
  if not enter_guide.executeFightGuide then
    return
  end
  log(bWriteLog and "[qintong] enter_guide.StartMatchRspTimer")
  local time_ticker = require("common.time_ticker")
  enter_guide.MatchRspTimer = time_ticker.AddTimerOnce(7, function()
    enter_guide.executeFightGuide = false
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.RefreshLoadPercent(1)
  end)
end
function enter_guide.StopMatchRspTimer()
  log(bWriteLog and "[qintong] enter_guide.StopMatchRspTimer")
  if enter_guide.MatchRspTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(enter_guide.MatchRspTimer)
    enter_guide.MatchRspTimer = nil
  end
end
return enter_guide