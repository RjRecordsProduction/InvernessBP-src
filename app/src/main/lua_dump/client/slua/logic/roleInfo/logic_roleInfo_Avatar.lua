local EAvatarState = {
  Has = 1,
  None = 2,
  Use = 3
}
local RoleInfoAvatarSystem = {
  EAvatarState = EAvatarState,
  HeadportraitList = {},
  RedPointList = {},
  headerProgress = nil
}
local C_SocialHeadID = 10002
function RoleInfoAvatarSystem.ResetRedPointData()
  RoleInfoAvatarSystem.RedPointList = {}
end
function RoleInfoAvatarSystem.ClearData()
  RoleInfoAvatarSystem.HeadportraitList = {}
end
local _UpdateCache = function()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheInfo = RoleInfoAvatarSystem.RedPointList
  PlayerPrefsSystem.SaveTableToFile_N(cacheInfo, PlayerPrefsSystem.ePlayerPrefsType.eRoleInfoAvatarRedDot)
end
function RoleInfoAvatarSystem.UpdateRedpoint(item_id)
  if RoleInfoAvatarSystem.RedPointList[item_id] ~= nil then
    RoleInfoAvatarSystem.RedPointList[item_id] = nil
  end
  _UpdateCache()
  if next(RoleInfoAvatarSystem.RedPointList) == nil then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_REDDOT)
  end
end
function RoleInfoAvatarSystem.ReadRedDotCacheData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRoleInfoAvatarRedDot)
  if cacheInfo and next(cacheInfo) then
    for k, v in pairs(cacheInfo) do
      if RoleInfoAvatarSystem.HeadportraitList[k] then
        RoleInfoAvatarSystem.RedPointList[k] = v
      end
    end
  end
  log_tree("RoleInfoAvatarSystem.RedPointList = ", RoleInfoAvatarSystem.RedPointList)
end
function RoleInfoAvatarSystem.HaveNewHeadportrait()
  if next(RoleInfoAvatarSystem.RedPointList) then
    return true
  end
  return false
end
function RoleInfoAvatarSystem.HasOwnHeadPortrait(headId)
  if RoleInfoAvatarSystem.HeadportraitList[tostring(headId)] == 1 then
    return true
  end
  return false
end
function RoleInfoAvatarSystem.GetHeadProgress()
  return RoleInfoAvatarSystem.headerProgress
end
function RoleInfoAvatarSystem.HasAvatar(itemId, forever)
  local data = RoleInfoAvatarSystem.HeadportraitList[tostring(itemId)]
  if not data then
    return false
  end
  if type(data) == "string" then
    return true
  end
  if forever then
    return data <= 1
  end
  return true
end
function RoleInfoAvatarSystem.send_get_user_avatar_list()
  local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
  RoleInfoHandler.send_get_user_avatar_list()
end
function RoleInfoAvatarSystem.send_change_user_avatar(item_url)
  log(bWriteLog and "[YY]RoleInfoAvatarSystem.send_change_user_avatar=" .. tostring(item_url))
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_change_user_avatar(item_url)
end
function RoleInfoAvatarSystem.send_get_unlock_progress_req()
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_get_unlock_progress_req()
end
function RoleInfoAvatarSystem.get_user_avatar_list_rsp(ok, list, headportraiturl)
  local TableUtil = require("common.table_util")
  if ok == 0 then
    DataMgr.UpdateHeadIconUrl(headportraiturl)
    local SocialHeadID = tostring(C_SocialHeadID) or ""
    local listSocialURL = list[SocialHeadID]
    log(bWriteLog and "[YY]listSocialURL==1==" .. tostring(listSocialURL))
    log(bWriteLog and "[YY]listSocialURL==2==" .. tostring(type(listSocialURL)))
    if list[SocialHeadID] and listSocialURL and type(listSocialURL) == "string" and string.find(listSocialURL, "twimg") ~= nil then
      list[SocialHeadID] = string.gsub(listSocialURL, "_normal", "_bigger")
      log(bWriteLog and "[YY] RoleInfoAvatarSystem.get_user_avatar_list_rsp -> social icon: list[\"10002\"]  = " .. tostring(list[SocialHeadID]))
    end
    RoleInfoAvatarSystem.HeadportraitList = list
    RoleInfoAvatarSystem.ReadRedDotCacheData()
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_INFO, headportraiturl)
  else
    DataMgr.ShowMessageBoxByID(ok)
  end
end
function RoleInfoAvatarSystem.change_user_avatar_rsp(err_code, item_url, endtime)
  local TimeUtil = require("client.common.time_util")
  log_tree("change_user_avatar_rsp==", {
    err_code = err_code,
    item_url = item_url,
      })
  if err_code == 0 then
    DataMgr.UpdateHeadIconUrl(item_url)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_USE_AVATAR)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_AVATAR)
    local RoleInfoBigAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_BigAvatar")
    RoleInfoBigAvatarSystem.RefreshBigImage(item_url)
    RoomSystem.RefreshMyProfileInRoom()
  elseif err_code == 507002 then
    local starTimeStr = TimeUtil.FormatTime_YMD(endtime)
    local noticeStr = LocUtil.LocalizeResFormat(22106, starTimeStr)
    ShowNotice(noticeStr)
  elseif err_code == 100243002 then
    local LegalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
    if not LegalMsgSystem.IsCanShowAvatarPrivacy() then
      DataMgr.ShowMessageBoxByID(err_code)
      return
    end
    local title = LocUtil.GetLocalizeResStr(102012)
    local msg = LocUtil.GetLocalizeResStr(24225)
    local strOK = LocUtil.GetLocalizeResStr(4410)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, msg, function()
      LegalMsgSystem.ShowlegalAvatarRule()
    end, nil, strOK)
  else
    DataMgr.ShowMessageBoxByID(err_code)
  end
end
function RoleInfoAvatarSystem.update_user_avatar_url(item_url)
  log(bWriteLog and "[YY]RoleInfoAvatarSystem.update_user_avatar_url" .. tostring(item_url))
  RoleInfoAvatarSystem.change_user_avatar_rsp(0, item_url)
end
function RoleInfoAvatarSystem.notify_unlock_new_avatar(list)
  log_tree("[chub]notify_unlock_new_avatar,===list===", list)
  local itemid, expireTime
  if list and next(list) then
    for k, v in pairs(list) do
      if k ~= "expire_time" then
        if RoleInfoAvatarSystem.RedPointList[k] == nil then
          RoleInfoAvatarSystem.RedPointList[k] = v
        end
        if RoleInfoAvatarSystem.HeadportraitList[k] == nil then
          RoleInfoAvatarSystem.HeadportraitList[k] = v
          itemid = k
        end
      else
        expireTime = v
      end
    end
    if itemid and expireTime then
      RoleInfoAvatarSystem.HeadportraitList[itemid] = expireTime
    end
  end
  _UpdateCache()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_INFO, DataMgr.roleData.headIconUrl)
end
function RoleInfoAvatarSystem.get_unlock_progress_rsp(res, headerProgress)
  RoleInfoAvatarSystem.end
return RoleInfoAvatarSystem