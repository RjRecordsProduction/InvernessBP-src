local logic_profile_utils = {}
local profile_config = require("client.slua.logic.user.profile.profile_config")
function logic_profile_utils.Binary2Decimal(num)
  if not num or type(num) ~= "number" then
    return 0
  end
  local shift = 1
  local res = 0
  while 0 < num do
    res = res + shift * (num % 10)
    shift = shift * 2
    num = math.floor(num / 10)
  end
  return res
end
function logic_profile_utils.JudgeItemValidByTag(profile, intTag)
  if not (profile and type(profile) == "table" and intTag) or type(intTag) ~= "number" then
    return false
  end
  if not profile.isInit then
    return false
  end
  if intTag == 0 then
    return true
  end
  for k, v in pairs(profile_config.Flag2ProfileKey) do
    if math.floor(intTag / v) % 2 == 1 and not profile[k] then
      return false
    end
  end
  return true
end
function logic_profile_utils.JudgeItemValidByTime(profile)
  if not profile or not profile.timestamp then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetServerTimeInSec() - profile.timestamp < profile_config.CDTime
end
function logic_profile_utils.GetReqCountByTag(intTag, RankFlag)
  if RankFlag and type(RankFlag) == "number" and RankFlag == 1 then
    return profile_config.ENUM_REQ_SIZE.WITH_RANK
  end
  if math.floor(intTag / 2) % 2 == 1 then
    return profile_config.ENUM_REQ_SIZE.WITH_LBS
  else
    return profile_config.ENUM_REQ_SIZE.NORMAL
  end
end
function logic_profile_utils.GetIsShowGRName()
  if LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_REMARK_NAME) then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    return SettingConfig.ShowGameRemarkName
  else
    return false
  end
end
function logic_profile_utils.MergeProfile(newProfile, oldProfile)
  for k, v in pairs(profile_config.Flag2ProfileKey) do
    if not newProfile[k] and oldProfile[k] then
      newProfile[k] = oldProfile[k]
    end
  end
  return newProfile
end
function logic_profile_utils.CreateProfile(uid, profile)
  profile.isInit = true
  profile.  profile.alias = profile.alias or {
    id = 0,
    rank = 0,
    nation = "",
    title = ""
  }
  profile.alias.title = FuncUtil.Gen_title(profile.alias.id, profile.alias.rank, profile.alias.ext_info, profile.alias.rank_id)
  for k, v in pairs(profile_config.InitKeyMap) do
    local value = v.key and profile[v.key] or profile[k]
    value = v.func and v.func(value) or value
    value = value or v.default
    profile[k] = value
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    profile.segment_info = {
      [3] = profile.segment_info[3]
    }
  else
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    if logic_multiple_area:IsConnectToRussiaArea() then
      profile.segment_info = {
        [2] = profile.segment_info[2]
      }
    end
  end
  profile.cur_max_segment_level = FuncUtil.GetCurMaxSegementLevel(profile.segment_info)
  local fixWord = FuncUtil.GetKeywordByID(3377006) .. "_vip"
  profile[fixWord] = GetSafeNumber(profile[fixWord])
  profile.warZoneID = profile.lbs_warzone_info and profile.lbs_warzone_info.warzone_id or 0
  profile.corp_alias_id = profile.corps_alias_info and profile.corps_alias_info.cur_corps_alias_id or 25000001
  profile.offline_invite_setting = profile.role_setting and profile.role_setting[RoleSettingType.OfflineInvite] or 0
  profile.Messagener_invite_setting = profile.role_setting and profile.role_setting[RoleSettingType.GlobalMessagener] or 0
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  profile.upass_is_buy, profile.upass_is_show, profile.upass_keep_buy, profile.upass_cur_value, profile.pass_type = UnknowPassUtil.ParseUpassInfo(profile.upass)
  if profile.picUrl and string.find(profile.picUrl, "twimg") ~= nil then
    profile.picUrl = string.gsub(profile.picUrl, "_normal", "_bigger")
  end
  return profile
end
function logic_profile_utils.FormatInnerFriendProfile(profileData, friendData, uid)
  if not friendData then
    return profileData or {}
  end
  if not profileData then
    return {
      isInit = false,
      uid = tostring(uid),
      remarks_name = "",
      intimacy = friendData.intimacy,
      isPlatFriend = false
    }
  end
  profileData.intimacy = friendData.intimacy
  profileData.isPlatFriend = false
  return profileData
end
function logic_profile_utils.FormatPlatFriendProfile(profileData, friendData, uid)
  local remarksName = ""
  if friendData then
    local StringUtil = require("common.string_util")
    remarksName = StringUtil.CheckNameRetrunName(friendData.remarks_name, nil, 14)
    if string.len(friendData.remarks_name) > string.len(remarksName) then
      remarksName = remarksName .. "..."
    end
  end
  if not profileData then
    return {
      isInit = false,
      uid = tostring(uid),
      remarks_name = remarksName,
      intimacy = 0,
      isPlatFriend = true
    }
  end
  profileData.remarks_name = remarksName
  profileData.isPlatFriend = true
  if not profileData.gameName or profileData.remarks_name == "" then
    return profileData
  end
  profileData.nickName = string.format("%s(%s)", profileData.gameName, remarksName)
  return profileData
end
function logic_profile_utils.FormatFriendProfile(profileData, friendData, isPlatForm)
  if type(isPlatForm) == "nil" then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    isPlatForm = LogicFriend.IsPlatFriend(friendData.uid)
  end
  if not profileData then
    return {
      isInit = false,
      uid = tostring(friendData.uid),
      remarks_name = friendData.remarks_name,
      intimacy = friendData.remarks_name,
      isPlatFriend = isPlatForm
    }
  end
  if friendData.remarks_name then
    profileData.remarks_name = friendData.remarks_name
  end
  if friendData.intimacy then
    profileData.intimacy = friendData.intimacy
  end
  return profileData
end
return logic_profile_utils