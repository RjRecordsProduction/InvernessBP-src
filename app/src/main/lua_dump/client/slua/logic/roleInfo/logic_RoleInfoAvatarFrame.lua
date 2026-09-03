local ENUM_State = {
  Has = 1,
  None = 2,
  Use = 3
}
local RoleInfoAvatarFrameSystem = {
  RedPointList = {},
  HasGet = false,
  AvatarFrameList = {},
  ENUM_State = ENUM_State,
  _hasGotData = false
}
local _UpdateCache = function()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRoleInfoRedDot) or {}
  if cacheInfo.avatarFrame == nil then
    cacheInfo.avatarFrame = {}
  end
  cacheInfo.avatarFrame = RoleInfoAvatarFrameSystem.RedPointList
  PlayerPrefsSystem.SaveTableToFile_N(cacheInfo, PlayerPrefsSystem.ePlayerPrefsType.eRoleInfoRedDot)
end
function RoleInfoAvatarFrameSystem.HasGetData()
  return RoleInfoAvatarFrameSystem.HasGet
end
function RoleInfoAvatarFrameSystem.SetHasGetData(hasGet)
  RoleInfoAvatarFrameSystem.HasGet = hasGet
end
function RoleInfoAvatarFrameSystem.HaveNew()
  for k, v in pairs(RoleInfoAvatarFrameSystem.RedPointList) do
    if not CDataTable.GetTableData("AvatarFrame", k) then
      log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.HaveNew can not find " .. tostring(k))
      RoleInfoAvatarFrameSystem.RedPointList[k] = nil
    end
  end
  if next(RoleInfoAvatarFrameSystem.RedPointList) == nil then
    log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.HaveNew false")
    return false
  else
    log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.HaveNew true")
    return true
  end
end
function RoleInfoAvatarFrameSystem.HasAvatarFrame(avatarFrameId)
  if RoleInfoAvatarFrameSystem.AvatarFrameList[avatarFrameId] ~= nil then
    local cfg = RoleInfoAvatarFrameSystem.AvatarFrameList[avatarFrameId]
    local expireTime
    if cfg and cfg.expire_time then
      expireTime = cfg.expire_time
    end
    if expireTime and expireTime ~= 1 then
      return false
    end
    return true
  else
    return false
  end
end
function RoleInfoAvatarFrameSystem.HasAvatarFrameCond(avatarFrameId, forever)
  local data = RoleInfoAvatarFrameSystem.AvatarFrameList[avatarFrameId]
  if not data then
    return false
  end
  if forever then
    return data.expire_time <= 1
  end
  return true
end
function RoleInfoAvatarFrameSystem.ResetRedPointData()
  log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.ResetRedPointData")
  RoleInfoAvatarFrameSystem.RedPointList = {}
end
function RoleInfoAvatarFrameSystem.OnHeadFrameNotify(avatarBoxId, expireTime)
  avatarBoxId = tonumber(avatarBoxId)
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.OnHeadFrameNotify " .. tostring(avatarBoxId) .. ", " .. tostring(expireTime) .. ", " .. tostring(now))
  if expireTime ~= 1 and expireTime <= now then
    return
  end
  if not RoleInfoAvatarFrameSystem.AvatarFrameList[avatarBoxId] then
    RoleInfoAvatarFrameSystem.AvatarFrameList[avatarBoxId] = {}
  end
  RoleInfoAvatarFrameSystem.AvatarFrameList[avatarBoxId].expire_time = expireTime
  if RoleInfoAvatarFrameSystem.HasAvatarFrame(avatarBoxId) then
    RoleInfoAvatarFrameSystem.RedPointList[avatarBoxId] = expireTime
    _UpdateCache()
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_PORTRAIT)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_FRAME_INFO)
end
function RoleInfoAvatarFrameSystem.UpdateRedpoint(item_id)
  item_id = tonumber(item_id)
  log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.UpdateRedpoint, id = " .. tostring(item_id))
  if not RoleInfoAvatarFrameSystem.RedPointList[item_id] then
    return
  end
  RoleInfoAvatarFrameSystem.RedPointList[item_id] = nil
  log(bWriteLog and "[cw][RIAF][L] Remove red point #" .. #RoleInfoAvatarFrameSystem.RedPointList)
  _UpdateCache()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_PORTRAIT)
end
function RoleInfoAvatarFrameSystem.ReadRedDotCacheData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRoleInfoRedDot)
  if cacheInfo and cacheInfo.avatarFrame and type(cacheInfo.avatarFrame) == "table" and next(cacheInfo.avatarFrame) then
    for k, v in pairs(cacheInfo.avatarFrame) do
      if RoleInfoAvatarFrameSystem.HasAvatarFrame(k) then
        RoleInfoAvatarFrameSystem.RedPointList[k] = v
      end
    end
  end
end
function RoleInfoAvatarFrameSystem.UsedGotData()
  if not RoleInfoAvatarFrameSystem._hasGotData then
    return
  end
  RoleInfoAvatarFrameSystem._hasGotData = false
end
function RoleInfoAvatarFrameSystem.CheckIfHasGotData()
  return RoleInfoAvatarFrameSystem._hasGotData
end
function RoleInfoAvatarFrameSystem.get_avatar_box_list()
  log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.get_avatar_box_list")
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_get_avatar_box_list()
end
function RoleInfoAvatarFrameSystem.get_avatar_box_list_rsp(ok, list, cur_avatar_box_id)
  log_tree("[chub]RoleInfoAvatarFrameSystem.get_avatar_box_list_rsp, list = ", list)
  log(bWriteLog and "[chub]RoleInfoAvatarFrameSystem.get_avatar_box_list_rsp, cur_avatar_box_id = " .. cur_avatar_box_id)
  if ok ~= 0 then
    DataMgr.ShowMessageBoxByID(ok)
    log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.get_avatar_box_list_rsp with error " .. tostring(ok))
    return
  end
  RoleInfoAvatarFrameSystem.UpdateCurAvatarBoxID(cur_avatar_box_id)
  RoleInfoAvatarFrameSystem.AvatarFrameList = list
  RoleInfoAvatarFrameSystem.ReadRedDotCacheData()
  RoleInfoAvatarFrameSystem._hasGotData = true
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_FRAME_INFO)
end
function RoleInfoAvatarFrameSystem.change_avatar_box(item_id)
  item_id = item_id or DataMgr.roleData.cur_avatar_box_id
  log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.change_avatar_box(" .. tostring(item_id) .. ")  ")
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_change_avatar_box(item_id)
end
function RoleInfoAvatarFrameSystem.change_avatar_box_rsp(ok, item_id)
  if ok ~= 0 then
    DataMgr.ShowMessageBoxByID(ok)
    log(bWriteLog and "[cw][RIAF][L] RoleInfoAvatarFrameSystem.change_avatar_box_rsp with error " .. tostring(ok))
    return
  end
  RoleInfoAvatarFrameSystem.UpdateCurAvatarBoxID(item_id)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_FRAME_INFO)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_AVATAR)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local myProfile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if myProfile and myProfile.cur_avatar_box_id then
    myProfile.cur_avatar_box_id = item_id
  end
  RoomSystem.RefreshMyProfileInRoom()
end
function RoleInfoAvatarFrameSystem.UpdateCurAvatarBoxID(item_id)
  log(bWriteLog and "RoleInfoAvatarFrameSystem.UpdateCurAvatarBoxID item_id:" .. tostring(item_id))
  DataMgr.UpdateAvatarBoxId(item_id)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.PersonalBasicInfo.role_avatar_frame = tonumber(DataMgr.roleData.cur_avatar_box_id)
end
return RoleInfoAvatarFrameSystem