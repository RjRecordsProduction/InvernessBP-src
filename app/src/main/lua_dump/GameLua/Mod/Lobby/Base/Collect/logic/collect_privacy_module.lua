local collect_privacy_module = {}
local cantShowRegionTb = {}
local cantShowRegion = function(uid, region)
  return FuncUtil.IsUidJPKR(uid) and cantShowRegionTb[region]
end
function collect_privacy_module:DefineAndResetData()
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  self.privacyCfg = collect_cfg.privacy
  self.privacy = {}
end
function collect_privacy_module:CheckCollectPrivacy(profile)
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_COLLECT) then
    log_warning(bWriteLog and "  collect_module:CanShowCollect.  CheckOpen() is not")
    return
  end
  local myUid = DataMgr.roleData.uid
  local isJK = cantShowRegion(myUid, DataMgr.RegionData.region)
  if not profile or profile.uid == tonumber(myUid) then
    if isJK then
      return false
    end
  else
    if not profile.collect_data then
      return false
    end
    if isJK or cantShowRegion(profile.uid, profile.region) then
      return false
    end
    local TableUtil = require("common.table_util")
    local privacy = TableUtil.GetTableValue(profile, "collect_data", "privacy")
    if not privacy then
      return true
    end
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if LogicFriend.IsMyFriend(profile.uid) then
      return privacy[self.privacyCfg.DoubleFriendCDetail] ~= false
    else
      return privacy[self.privacyCfg.DoubleStrangerCDetail] ~= false
    end
  end
  return true
end
function collect_privacy_module:CanShowCollectLevel(privacy)
  if not privacy or not next(privacy) then
    return true
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_COLLECT) then
    log_warning(bWriteLog and "  collect_privacy_module:CanShowCollectLevel.  CheckOpen() is not")
    return
  end
  log_tree("collect_privacy_module:CanShowCollectLevel", privacy)
  return privacy[self.privacyCfg.DoubleShowCollectLevel] ~= false
end
function collect_privacy_module:ChangePrivacySetting(settingKey)
  local index = self.privacyCfg[settingKey]
  local value = self.privacy[index]
  if value == nil then
    value = true
  end
  value = not value
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  CollectHandler.send_set_collect_sys_privacy_req(index, value)
  self.privacy[index] = value
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local TLogReasonStr = json.encode({
    uid = DataMgr.roleData.uid or 0,
    slotIndex = index or 0,
    switch = value or false
  })
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ChangeCollectionPrivacy, 0, TLogReasonStr)
end
function collect_privacy_module:OnChangePrivacySetting(err_code, index, value)
  self.privacy[index] = value
  local roleData = DataMgr.roleData
  if roleData.brief_collect_data then
    if not roleData.brief_collect_data.privacy then
      roleData.brief_collect_data.privacy = {}
    end
    roleData.brief_collect_data.privacy[index] = value
  end
  log_warning(bWriteLog and string.format("collect_module:OnChangePrivacySetting. err_code:%s, index:%s, value:%s", err_code, index, value))
  local key
  for k, i in pairs(self.privacyCfg) do
    if i == index then
      key = k
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_COLLECT, key)
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_DATA_NOTIFY)
end
function collect_privacy_module:OnGetPrivacy(err_code, privacy)
  self.  log_tree("  collect_module:OnGetPrivacy. privacy ", privacy)
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_PRIVACY_DATA)
end
function collect_privacy_module:GetPrivacyData(settingKey)
  local index = self.privacyCfg[settingKey]
  local open = self.privacy[index]
  if nil == open then
    return true
  end
  return open
end
function collect_privacy_module:CanShowMyCollectLevel()
  local open = self.privacy[self.privacyCfg.DoubleShowCollectLevel]
  if nil == open then
    return true
  end
  return open
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_privacy_module)
return CModuleTemplate