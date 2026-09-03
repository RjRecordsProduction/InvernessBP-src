local RoleInfoNameFrameSystem = {
  nUsedID = 0,
  ERRORCODE_NO_NAMEFRAME = 8900001,
  ERRORCODE_NAMEFRAME_INUSED = 8900002
}
function RoleInfoNameFrameSystem.Enter()
  log(bWriteLog and "[edward][logic_roleinfo_nameframe] Enter")
  log_tree("[chub]RoleInfoNameFrameSystem.Enter,DataMgr.roleData.nameFrameData = ", DataMgr.roleData.nameFrameData)
  if not DataMgr.roleData.nameFrameData then
    return
  end
  RoleInfoNameFrameSystem.nUsedID = 0
  for k, v in pairs(DataMgr.roleData.nameFrameData) do
    if RoleInfoNameFrameSystem.IsUseNameFrame(k) then
      RoleInfoNameFrameSystem.nUsedID = k
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_NAME_FRAME)
end
function RoleInfoNameFrameSystem.Release()
  log(bWriteLog and "[edward][logic_roleinfo_nameframe] Release")
end
function RoleInfoNameFrameSystem.use_brand(id)
  log(bWriteLog and "[v_wllwu] RoleInfoNameFrameSystem.use_brand, id is:" .. tostring(id))
  local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
  RoleInfoHandler.send_use_brand(id)
end
function RoleInfoNameFrameSystem.use_brand_rsp(res, id)
  log(bWriteLog and "[edward][logic_roleinfo_nameframe] res = " .. tostring(res) .. ", id = " .. tostring(id))
  if res ~= 0 then
    if res == RoleInfoNameFrameSystem.ERRORCODE_NO_NAMEFRAME then
      ShowNotice(9910101)
    end
    return
  end
  if id == 0 then
    RoleInfoNameFrameSystem.nUsedID = 0
    DataMgr.ResetNameFrame()
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local memberInfo = TeamUpNewSystem.GetMemberInfo(DataMgr.roleData.uid)
    if memberInfo then
      memberInfo.brand_id = 0
    end
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_USE_NAME_FRAME, RoleInfoNameFrameSystem.nUsedID)
  elseif DataMgr.GetNameFrame(id) then
    RoleInfoNameFrameSystem.nUsedID = id
    DataMgr.ResetNameFrame()
    DataMgr.UseNameFrame(id)
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local memberInfo = TeamUpNewSystem.GetMemberInfo(DataMgr.roleData.uid)
    if memberInfo then
      memberInfo.brand_    end
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_USE_NAME_FRAME, RoleInfoNameFrameSystem.nUsedID)
  else
    log(bWriteLog and "[edward][logic_roleinfo_nameframe] use_brand_rsp, no have, id = " .. id)
  end
end
function RoleInfoNameFrameSystem.notify_add_brand(id, expire_ts)
  log(bWriteLog and "[edward][logic_roleinfo_nameframe] id = " .. id .. " expire_ts = " .. tostring(expire_ts))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lastData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLastNameFrameData)
  if not DataMgr.roleData.nameFrameData[id] then
    DataMgr.roleData.nameFrameData[id] = {is_used = 0}
    lastData = lastData or {}
    local TimeUtil = require("client.common.time_util")
    lastData.nLastTime = TimeUtil.GetServerTimeInSec()
    PlayerPrefsSystem.SaveTableToFile_N(lastData, PlayerPrefsSystem.ePlayerPrefsType.eLastNameFrameData)
  end
  DataMgr.roleData.nameFrameData[id].  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_NAME_FRAME)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NAME_FRAME_REDDOT)
end
function RoleInfoNameFrameSystem.IsUseNameFrame(id)
  if not DataMgr.roleData.nameFrameData[id] then
    log_error(bWriteLog and "[v_wllwu] RoleInfoNameFrameSystem.IsUseNameFrame, id not exist and id is\239\188\154" .. tostring(id))
    return
  end
  if DataMgr.roleData.nameFrameData[id].is_used ~= 1 then
    return
  end
  if not RoleInfoNameFrameSystem.IsValidNameFrame(id) then
    return false
  end
  return true
end
function RoleInfoNameFrameSystem.IsValidNameFrame(id)
  if not DataMgr.roleData.nameFrameData[id] then
    log_error(bWriteLog and "[v_wllwu] RoleInfoNameFrameSystem.IsValidNameFrame, id not exist and id is\239\188\154" .. tostring(id))
    return
  end
  local expire_ts = DataMgr.roleData.nameFrameData[id].expire_ts or 0
  if expire_ts ~= 0 then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    if expire_ts <= serverTime then
      return false
    end
  end
  return true
end
function RoleInfoNameFrameSystem.HaveNew()
  log(bWriteLog and "[edward][logic_roleinfo_nameframe] HaveNew")
  return false
end
function RoleInfoNameFrameSystem.RemoveRedDot(ItemId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lastData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLastNameFrameData) or {}
  if not lastData.nameFrame then
    lastData.nameFrame = {}
  end
  lastData.nameFrame[ItemId] = 0
  PlayerPrefsSystem.SaveTableToFile_N(lastData, PlayerPrefsSystem.ePlayerPrefsType.eLastNameFrameData)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NAME_FRAME_REDDOT)
end
return RoleInfoNameFrameSystem