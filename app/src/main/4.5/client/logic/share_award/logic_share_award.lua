local ShareAwardMgr = {arrDelayAwardItems = nil}
function ShareAwardMgr.Init()
  EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, ShareAwardMgr.EventHandler)
end
function ShareAwardMgr.EventHandler(eventType, eventID, vars)
  if eventType ~= EVENTTYPE_SHARE then
    return
  end
  if eventID == EVENTID_SHARE_SUCESSFUL and GameStatus.IsInLobbyOrMainCity() then
    ShareAwardMgr.CheckDelayAward()
  end
end
function ShareAwardMgr.GetShareTimes()
  return DataMgr.ShareAwardInfo.share_times
end
function ShareAwardMgr.IsTodayShareDone()
  local TimeUtil = require("client.common.time_util")
  local lastShareTime = DataMgr.ShareAwardInfo.daily_share_time
  local curTime = TimeUtil.GetServerTimeInSec()
  if TimeUtil.IsSameDay(curTime, lastShareTime) then
    return true
  else
    return false
  end
end
function ShareAwardMgr.GetShareAwardState(day)
  local state = DataMgr.ShareAwardInfo.AwardState[day]
  if nil == state then
    return 0
  end
  return state
end
function ShareAwardMgr.GetAwardItemByDropId(dropId)
  local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
  local list = BasicDataDropTable:GetOrReqData(dropId)
  if not list or #list <= 0 then
    return 0, 0, ""
  end
  return list[1].DropItemID, list[1].DropItemNum, list[1].Desc, list[1].Hours, list[1].DropMoney
end
function ShareAwardMgr.Release()
  EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, ShareAwardMgr.EventHandler)
  DataMgr.ShareAwardInfo.daily_share_time = 0
  DataMgr.ShareAwardInfo.share_times = 0
  DataMgr.ShareAwardInfo.AwardState = {}
  ShareAwardMgr.arrDelayAwardItems = nil
end
function ShareAwardMgr.CheckDelayAward()
  if ShareAwardMgr.arrDelayAwardItems ~= nil then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(ShareAwardMgr.arrDelayAwardItems)
    ShareAwardMgr.arrDelayAwardItems = nil
  end
end
function ShareAwardMgr.CheckAwardRedPoint()
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_SHARE_AWARD, false)
end
function ShareAwardMgr.IsAllAwardHasGet()
  if ShareAwardMgr.GetShareTimes() < 7 then
    return false
  end
  return true
end
function ShareAwardMgr.OnShareAwardInfoUpdate()
  ShareAwardMgr.CheckAwardRedPoint()
  if BattleResult.IsPopUpBattleResult then
    BattleResultUI.UpdateShareBtnState()
  end
  EventSystem:postEvent(EVENTTYPE_SHARE_AWARD, EVENTID_SHARE_AWARD_SYNCINFO)
end
function ShareAwardMgr.ReqShareGetAward(id, gender)
  local ShareHandler = require("client.network.Protocol.ShareHandler")
  ShareHandler.send_share_get_award_req(id, gender)
end
function ShareAwardMgr.RspShareGetAward(ret, id, itemlist)
  log(bWriteLog and "ShareAwardMgr.RspShareGetAward ret=" .. tostring(ret))
  if ret ~= nil and string.lower(ret) == NetErrorCode_NONE then
    log(bWriteLog and "ShareAwardMgr.RspShareGetAward id=" .. tostring(id))
    if 0 < id then
      DataMgr.UpdateShareAwardState(id, 1)
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(itemlist)
    else
      ShareAwardMgr.arrDelayAwardItems = itemlist
    end
  else
    ShowNotice(ret)
  end
end
return ShareAwardMgr