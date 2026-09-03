IntimacyAwardSystem = IntimacyAwardSystem or {
  cur_posture = 0,
  posture_list = nil,
  intimacy_reward_info = nil,
  has_intimacy_reward = false,
  cache_period = 10,
  cache_req_last_time = {},
  cur_interact_avatar_posture = 2207001,
  interact_avatar_posture_list = {}
}
function IntimacyAwardSystem.GetAllAward()
  local tb = CDataTable.GetTable("IntimacyPartnerAward")
  local awards = {}
  for i, v in pairs(tb) do
    local reward_status = 0
    if IntimacyAwardSystem.intimacy_reward_info then
      local reward = IntimacyAwardSystem.intimacy_reward_info.reward_record[v.ID]
      if reward then
        reward_status = reward.status
      end
    end
    table.insert(awards, {Info = v, status = reward_status})
  end
  table.sort(awards, function(a, b)
    return a.Info.RequireIntimacy < b.Info.RequireIntimacy
  end)
  local firstAwardID = -1
  for i, award in ipairs(awards) do
    if award.status == 1 then
      firstAwardID = award.Info.ID
      break
    end
  end
  return awards, firstAwardID
end
function IntimacyAwardSystem.get_intimacy_reward_info_req(force)
  log(bWriteLog and "IntimacyAwardSystem.get_intimacy_reward_info_req")
  local IntimacyRewardHandler = require("client.network.Protocol.IntimacyRewardHandler")
  if IntimacyAwardSystem.intimacy_reward_info then
    local lastTime = IntimacyAwardSystem.cache_req_last_time.get_intimacy_reward_info or 0
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.GetServerTimeInSec() - lastTime >= IntimacyAwardSystem.cache_period or force then
      IntimacyRewardHandler.send_get_lobby_intimacy_partner_info_req()
    else
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_GET_INTIMACY_REWARD_INFO_RSP)
    end
  else
    IntimacyRewardHandler.send_get_lobby_intimacy_partner_info_req()
  end
end
function IntimacyAwardSystem.Handle_LogOut()
  log(bWriteLog and "IntimacyAwardSystem.Handle_LogOut")
  IntimacyAwardSystem.intimacy_reward_info = nil
  IntimacyAwardSystem.posture_list = nil
  IntimacyAwardSystem.has_intimacy_reward = false
end
function IntimacyAwardSystem.get_intimacy_reward_info_rsp(intimacy_reward_info)
  local TimeUtil = require("client.common.time_util")
  IntimacyAwardSystem.cache_req_last_time.get_intimacy_reward_info = TimeUtil.GetServerTimeInSec()
  log_tree("IntimacyAwardSystem.get_intimacy_reward_info_rsp", intimacy_reward_info)
  IntimacyAwardSystem.  if IntimacyAwardSystem.intimacy_reward_info ~= nil then
    local hasReward = false
    for i, v in pairs(IntimacyAwardSystem.intimacy_reward_info.reward_record) do
      if v.status == 1 then
        hasReward = true
      end
    end
    if not hasReward then
      IntimacyAwardSystem.has_intimacy_reward = false
    end
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_GET_INTIMACY_REWARD_INFO_RSP)
end
function IntimacyAwardSystem.get_intimacy_reward_req(reward_id)
  log(bWriteLog and "IntimacyAwardSystem.get_intimacy_reward_req:" .. tostring(reward_id))
  local IntimacyRewardHandler = require("client.network.Protocol.IntimacyRewardHandler")
  IntimacyRewardHandler.send_get_partner_reward_req(reward_id)
end
function IntimacyAwardSystem.get_intimacy_reward_rsp(res, reward_id)
  log(bWriteLog and "IntimacyAwardSystem.get_intimacy_reward_rsp:" .. tostring(res) .. ",reward_id:" .. tostring(reward_id))
  if res ~= 0 then
    return
  end
  if IntimacyAwardSystem.intimacy_reward_info ~= nil then
    local info = IntimacyAwardSystem.intimacy_reward_info.reward_record[reward_id]
    if info then
      info.status = 2
    end
    local hasReward = false
    for i, v in pairs(IntimacyAwardSystem.intimacy_reward_info.reward_record) do
      if v.status == 1 then
        hasReward = true
      end
    end
    if not hasReward then
      IntimacyAwardSystem.has_intimacy_reward = false
    end
  end
  ShowNotice(7577)
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_GET_INTIMACY_REWARD_RSP)
end
function IntimacyAwardSystem.set_posture_req(posture_id)
  log(bWriteLog and "IntimacyAwardSystem.set_posture_req:" .. tostring(posture_id))
  local IntimacyRewardHandler = require("client.network.Protocol.IntimacyRewardHandler")
  IntimacyRewardHandler.send_set_posture_req(posture_id)
end
function IntimacyAwardSystem.set_posture_rsp(res, posture_id)
  log(bWriteLog and "IntimacyAwardSystem.set_posture_rsp:" .. res .. ",posture_id:" .. tostring(posture_id))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  IntimacyAwardSystem.cur_posture = posture_id
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  local roleData = BasicDataAvatarWearInfo:GetCacheData(DataMgr.roleData.uid)
  if roleData then
    roleData.pspace_wear_ext = roleData.pspace_wear_ext or {}
    roleData.pspace_wear_ext[105] = {
      [1] = posture_id
    }
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_SET_POSTURE_RSP)
end
function IntimacyAwardSystem.get_posture_info_req()
  log(bWriteLog and "IntimacyAwardSystem.get_posture_info_req")
  if IntimacyAwardSystem.posture_list then
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_GET_POSTURE_INFO_RSP)
  else
    local IntimacyRewardHandler = require("client.network.Protocol.IntimacyRewardHandler")
    IntimacyRewardHandler.send_get_posture_info_req()
  end
end
function IntimacyAwardSystem.get_posture_info_rsp(res, cur_posture, posture_list, cur_interact_avatar_posture, interact_avatar_posture_list)
  log(bWriteLog and "IntimacyAwardSystem.get_posture_info_rsp:" .. tostring(res) .. ",cur_posture:" .. tostring(cur_posture))
  log_tree("IntimacyAwardSystem.get_posture_info_rsp posture_list", posture_list)
  if res ~= 0 then
    return
  end
  IntimacyAwardSystem.  IntimacyAwardSystem.  IntimacyAwardSystem.  IntimacyAwardSystem.  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_GET_POSTURE_INFO_RSP)
end
function IntimacyAwardSystem.notify_posture_chg(cur_posture_id, posture_id, one_posture_info)
  log(bWriteLog and "IntimacyAwardSystem.notify_posture_chg:" .. tostring(cur_posture_id) .. ",cur_posture:" .. tostring(posture_id))
  log(bWriteLog and "IntimacyAwardSystem.notify_posture_chg one_posture_info", one_posture_info)
  IntimacyAwardSystem.cur_posture = cur_posture_id
  if IntimacyAwardSystem.posture_list then
    IntimacyAwardSystem.posture_list[posture_id] = one_posture_info
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_GET_POSTURE_INFO_NOTIFY)
end
function IntimacyAwardSystem.notify_new_intimacy_reward()
  log(bWriteLog and "IntimacyAwardSystem.notify_new_intimacy_reward")
  IntimacyAwardSystem.has_intimacy_reward = true
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_GET_INTIMACY_REWARD_INFO_RSP)
end
function IntimacyAwardSystem.HasGetPosture(posture_id)
  if IntimacyAwardSystem.posture_list and IntimacyAwardSystem.posture_list[posture_id] then
    return true
  end
  local ShareSuit = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ShareSuit)
  if ShareSuit:CheckSharePostureItem(posture_id) then
    return true
  end
  return false
end
function IntimacyAwardSystem.IsPostureLimitTime(posture_id)
  if not IntimacyAwardSystem.posture_list or not IntimacyAwardSystem.posture_list[posture_id] then
    log(bWriteLog and "IntimacyAwardSystem.IsPostureLimitTime no posture")
    return false
  end
  local postureData = IntimacyAwardSystem.posture_list[posture_id]
  if not postureData.expire_time or postureData.expire_time <= 0 then
    log(bWriteLog and "IntimacyAwardSystem.IsPostureLimitTime no expire_time")
    return false
  end
  return true
end
function IntimacyAwardSystem.HasIntimacyRewardReddot()
  return IntimacyAwardSystem.has_intimacy_reward
end
function IntimacyAwardSystem.CreateRoleData(roleData, posture, gender)
  local TableUtil = require("common.table_util")
  local copyRoleData = TableUtil.CopyTable(roleData)
  local pspace_wear_ext = copyRoleData.pspace_wear_ext or {}
  if gender then
    if copyRoleData.gender ~= gender and copyRoleData.pspace_wear_ext and copyRoleData.pspace_wear_ext[9] and copyRoleData.pspace_wear_ext[9][1] then
      local isCommonHead = false
      for _, v in pairs(CDataTable.GetTable("AvatarInit")) do
        if v.AvatarType == 1 and v.BodyID == copyRoleData.pspace_wear_ext[9][1] then
          isCommonHead = true
          break
        end
      end
      if not isCommonHead then
        copyRoleData.pspace_wear_ext[9][1] = 401993
        pspace_wear_ext = {
          [9] = {
            [1] = 401993
          }
        }
      end
    end
    copyRoleData.  end
  copyRoleData.  copyRoleData.pspace_wear_ext[105] = {
    [1] = posture
  }
  return copyRoleData
end
function IntimacyAwardSystem.GetAllPoses()
  local IntimacyPoseMapping = CDataTable.GetTable("IntimacyPoseMapping")
  local Poses = {}
  for i, v in pairs(IntimacyPoseMapping) do
    if not v.OtherSys or v.OtherSys == 0 then
      local IntimacyPose = CDataTable.GetTableData("IntimacyPose", v.PoseType)
      if IntimacyPose then
        table.insert(Poses, {
          PoseType = v.PoseType,
          ID = v.ID,
          Icon = IntimacyPose.Icon
        })
      end
    end
  end
  table.sort(Poses, function(pose1, pose2)
    return pose1.ID < pose2.ID
  end)
  return Poses
end
function IntimacyAwardSystem.GetPoseId(PoseType)
  local IntimacyPoseMapping = CDataTable.GetTable("IntimacyPoseMapping")
  for i, v in pairs(IntimacyPoseMapping) do
    if v.PoseType == PoseType then
      return v.ID
    end
  end
  return 0
end
function IntimacyAwardSystem.GetEquipPose(notReadCacheData)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if IntimacyAwardSystem.cur_posture ~= 0 then
    local intimacyPoseMapping = CDataTable.GetTableData("IntimacyPoseMapping", IntimacyAwardSystem.cur_posture)
    if intimacyPoseMapping then
      return intimacyPoseMapping.PoseType
    end
  end
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  local SelectUID_roleData = BasicDataAvatarWearInfo:GetCacheData(RoleInfoSystem.CurShowPlayerInfoUid)
  if not SelectUID_roleData then
    return 0
  end
  local partner_uid = SelectUID_roleData.partner_info and SelectUID_roleData.partner_info.partner_uid or 0
  if partner_uid == 0 then
    return 0
  end
  local wear_ext = SelectUID_roleData.pspace_wear_ext or {}
  local wear = wear_ext[105]
  if not notReadCacheData and wear then
    local itemId = wear[1]
    if itemId and itemId ~= 0 then
      local intimacyPoseMapping = CDataTable.GetTableData("IntimacyPoseMapping", itemId)
      if intimacyPoseMapping then
        return intimacyPoseMapping.PoseType
      end
    end
  end
  local SelectUID_IntimacyFriend_roleData = BasicDataAvatarWearInfo:GetCacheData(RoleInfoSystem.partner_uid)
  if not SelectUID_IntimacyFriend_roleData then
    return 0
  end
  local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
  return logic_couple_avatar_util.GetDefaultPoseId(SelectUID_roleData.gender - 1, SelectUID_IntimacyFriend_roleData.gender - 1)
end
function IntimacyAwardSystem.GetInitimacyLvCfg(score)
  if not score or type(score) ~= "number" then
    return nil
  end
  for k, v in pairs(CDataTable.GetTable("IntimacyLevel")) do
    if score >= v.MinExp and score <= v.MaxExp then
      return v
    end
    if v.Level == 99 and score > v.MaxExp then
      return v
    end
  end
  return nil
end
function IntimacyAwardSystem.GetInitimacyLevel(score)
  if not score or type(score) ~= "number" then
    return 1
  end
  score = math.floor(score)
  local IntimacyLevelCfg = CDataTable.GetTable("IntimacyLevel")
  local maxLevel = 1
  for _, v in pairs(IntimacyLevelCfg) do
    maxLevel = v.Level
    if score >= v.MinExp and score <= v.MaxExp then
      return v.Level
    end
  end
  return maxLevel
end
local EIntimacyType = {
  None = 0,
  Bromance = 1,
  Lover = 2,
  Buddy = 3,
  BFF = 4,
  Family = 5,
  Bonding = 6
}
IntimacyAwardSystem.local IntimacyTypeColor = {
  [1] = FLinearColor(0.119538, 0.53948, 0.863157, 1),
  [2] = FLinearColor(0.708376, 0.246201, 0.327778, 1),
  [3] = FLinearColor(0.814847, 0.423268, 0.082283, 1),
  [4] = FLinearColor(0.617207, 0.102242, 0.491021, 1),
  [5] = FLinearColor(0.894118, 0.262745, 0.145098, 1)
}
function IntimacyAwardSystem.GetInitimacyColor(InitimacyType)
  if not InitimacyType or type(InitimacyType) ~= "number" then
    return nil
  end
  return IntimacyTypeColor[InitimacyType]
end
local IntimacyIcon = {
  [1] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0002_png.PersonSpace_icon_color_0002_png",
  [2] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0004_png.PersonSpace_icon_color_0004_png",
  [3] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0003_png.PersonSpace_icon_color_0003_png",
  [4] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0001_png.PersonSpace_icon_color_0001_png",
  [5] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_Icon_Family_png.PersonSpace_Icon_Family_png",
  [6] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0008_png.PersonSpace_icon_color_0008_png"
}
local IntimacyIcon_New = {
  [1] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0002_png.PersonSpace_icon_color_0002_png",
  [2] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0004_png.PersonSpace_icon_color_0004_png",
  [3] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0003_png.PersonSpace_icon_color_0003_png",
  [4] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0001_png.PersonSpace_icon_color_0001_png",
  [5] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_Icon_Family_png.PersonSpace_Icon_Family_png",
  [6] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0008_png.PersonSpace_icon_color_0008_png"
}
local IntimacyIcon_battle = {
  [1] = "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/PersonSpace_icon_GayFriend_01_png.PersonSpace_icon_GayFriend_01_png",
  [2] = "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/PersonSpace_icon_lover_01_png.PersonSpace_icon_lover_01_png",
  [3] = "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/PersonSpace_icon_Partner_01_png.PersonSpace_icon_Partner_01_png",
  [4] = "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/PersonSpace_icon_BestFriend_01_png.PersonSpace_icon_BestFriend_01_png",
  [5] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_Icon_Family_png.PersonSpace_Icon_Family_png",
  [6] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_FatefulConnection_png.PersonSpace_icon_FatefulConnection_png"
}
local IntimacyIconNew = {
  [1] = "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/PersonSpace_icon_white_0002_png.PersonSpace_icon_white_0002_png",
  [2] = "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/PersonSpace_icon_white_0004_png.PersonSpace_icon_white_0004_png",
  [3] = "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/PersonSpace_icon_white_0003_png.PersonSpace_icon_white_0003_png",
  [4] = "/Game/Arts/UI/Atlas/BattleUI/GameResultsUI/Frames/PersonSpace_icon_white_0001_png.PersonSpace_icon_white_0001_png",
  [5] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_Icon_Family_png.PersonSpace_Icon_Family_png",
  [6] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0008_png.PersonSpace_icon_color_0008_png"
}
local IntimacyIconCrystal = {
  [1] = "/Game/UMG/Texture_200/Lobby_NoAtlas/PersonSpace/Interact_Icon_011.Interact_Icon_011",
  [2] = "/Game/UMG/Texture_200/Lobby_NoAtlas/PersonSpace/Interact_Icon_09.Interact_Icon_09",
  [3] = "/Game/UMG/Texture_200/Lobby_NoAtlas/PersonSpace/Interact_Icon_08.Interact_Icon_08",
  [4] = "/Game/UMG/Texture_200/Lobby_NoAtlas/PersonSpace/Interact_Icon_010.Interact_Icon_010",
  [5] = "/Game/UMG/Texture_200/Lobby_NoAtlas/PersonSpace/Interact_Icon_012.Interact_Icon_012",
  [6] = "/Game/UMG/Texture_200/Lobby_NoAtlas/PersonSpace/Interact_Icon_032.Interact_Icon_032"
}
local IntimacyIconRelationship = {
  [1] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0002_png.PersonSpace_icon_color_0002_png",
  [2] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0004_png.PersonSpace_icon_color_0004_png",
  [3] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0003_png.PersonSpace_icon_color_0003_png",
  [4] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0001_png.PersonSpace_icon_color_0001_png",
  [5] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_0005_png.PersonSpace_icon_0005_png",
  [6] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_color_0008_png.PersonSpace_icon_color_0008_png"
}
function IntimacyAwardSystem.GetInitimacyIcon_other(InitimacyType)
  if not InitimacyType or type(InitimacyType) ~= "number" then
    return nil
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  if not bIsBondingSystem and InitimacyType == 6 then
    InitimacyType = 2
  end
  return IntimacyIcon[InitimacyType]
end
function IntimacyAwardSystem.GetInitimacyIcon_Crystal(InitimacyType)
  if not InitimacyType or type(InitimacyType) ~= "number" then
    return nil
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  if not bIsBondingSystem and InitimacyType == 6 then
    InitimacyType = 2
  end
  return IntimacyIconCrystal[InitimacyType]
end
function IntimacyAwardSystem.GetInitimacyIcon_RelationshipDisplay(InitimacyType)
  if not InitimacyType or type(InitimacyType) ~= "number" then
    return nil
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  if not bIsBondingSystem and InitimacyType == 6 then
    InitimacyType = 2
  end
  return IntimacyIconRelationship[InitimacyType]
end
function IntimacyAwardSystem.GetInitimacyIcon_other_new(InitimacyType)
  if not InitimacyType or type(InitimacyType) ~= "number" then
    return nil
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  if not bIsBondingSystem and InitimacyType == 6 then
    InitimacyType = 2
  end
  return IntimacyIcon_New[InitimacyType]
end
function IntimacyAwardSystem.GetInitimacyIcon_battle(InitimacyType)
  if not InitimacyType or type(InitimacyType) ~= "number" then
    return nil
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  if not bIsBondingSystem and InitimacyType == 6 then
    InitimacyType = 2
  end
  return IntimacyIcon_battle[InitimacyType]
end
function IntimacyAwardSystem.GetUnlockRankTopScore()
  if IntimacyAwardSystem.rankTopScore then
    return IntimacyAwardSystem.rankTopScore
  end
  local info = CDataTable.GetTableDataByFilter("IntimacyLevel", "LoverAwardType", 1)
  IntimacyAwardSystem.rankTopScore = info and info.MinExp or -1
  return IntimacyAwardSystem.rankTopScore
end
function IntimacyAwardSystem.GetUnlockAnimationScore()
  if IntimacyAwardSystem.animationScore then
    return IntimacyAwardSystem.animationScore
  end
  local info = CDataTable.GetTableDataByFilter("IntimacyLevel", "AwardType", 2)
  IntimacyAwardSystem.animationScore = info and info.MinExp or -1
  return IntimacyAwardSystem.animationScore
end
function IntimacyAwardSystem.CheckCanRankTopInFriends(score)
  if not score then
    return false
  end
  local unlockScore = IntimacyAwardSystem.GetUnlockRankTopScore()
  if unlockScore == -1 then
    return false
  end
  return score >= unlockScore
end
function IntimacyAwardSystem.CheckCanShowAnimation(score)
  if not score then
    return false
  end
  local unlockScore = IntimacyAwardSystem.GetUnlockAnimationScore()
  if unlockScore == -1 then
    return false
  end
  return score >= unlockScore
end
function IntimacyAwardSystem.proc_notify_interact_avatar_posture_chg(cur_interact_avatar_posture, resid, one_posture_info)
  log(bWriteLog and "IntimacyAwardSystem.proc_notify_interact_avatar_posture_chg:" .. tostring(cur_interact_avatar_posture) .. ",resid:" .. tostring(resid))
  if resid then
    IntimacyAwardSystem.interact_avatar_posture_list[resid] = one_posture_info
  end
end
return IntimacyAwardSystem