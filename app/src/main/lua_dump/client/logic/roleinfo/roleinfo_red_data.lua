local roleinfo_red_data = {}
local isRegisted = false
local super_data = require("common.super_data")
local spData = super_data.CreateSuperData({
  baseInfoRed = false,
  levelTaskRed = false,
  settingRed = false,
  avatarRed = false,
  avatarFrameRed = false,
  nameFrameRed = false,
  aliasRed = false,
  teamupFrameRed = false,
  carteFrameRed = false,
  soicalcardRed = false,
  nicknameFrameRed = false,
  chatFrameRed = false,
  lightBoardRed = false,
  homeDoorPlateRed = false,
  backgroundRed = false,
  openingRed = false,
  nicknameColorRed = false,
  historyRed = false,
  newCardRed = false,
  honorRed = false,
  achievementRed = false,
  aliasShowRed = false,
  honourCertificateRed = false,
  partnerRed = false,
  chatRoomBGRed = false,
  collectRed = false
})
local RoleRed2CollectRed = {
  collectRoad = "road",
  collectLib = "lib",
  collectRank = "rank"
}
function roleinfo_red_data.OnLoadingFinish()
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  local tTask = {
    module = roleinfo_red_data,
    protect = true,
    funcName = "RedPointInit",
    debugInfo = "roleinfo_red_data#RedPointInit"
  }
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, tTask)
end
function roleinfo_red_data.RedPointInit()
  if isRegisted then
    return
  end
  roleinfo_red_data.RegistRedEvent()
  roleinfo_red_data.RefreshAll()
end
function roleinfo_red_data.OnLogout()
  isRegisted = false
end
function roleinfo_red_data.RegistRedEvent()
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_INFO, roleinfo_red_data.RefreshAvatarRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_REDDOT, roleinfo_red_data.RefreshAvatarRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_PORTRAIT, roleinfo_red_data.RefreshAvatarFrameRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NEW_ALIAS_REDDOT, roleinfo_red_data.RefreshAliasRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NAME_FRAME_REDDOT, roleinfo_red_data.RefreshNameFrameRed)
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_LEVLE_TASK_CHANGE, roleinfo_red_data.RefreshLevelTaskRed)
  EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, roleinfo_red_data.RefreshPartnerRed)
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, roleinfo_red_data.OnLevelChange)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARD, roleinfo_red_data.RefreshCardRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO, roleinfo_red_data.RefreshCardRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_TEAMUP_FRAME_REDDOT, roleinfo_red_data.RefreshTeamupFrameRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NICKNAME_FRAME_UPDATE, roleinfo_red_data.RefreshNicknameFrameRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHAT_FRAME_UPDATE, roleinfo_red_data.RefreshChatFrameRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARTE_FRAME_REDDOT, roleinfo_red_data.RefreshCarteFrameRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SOCIAL_CARD_REDDOT, roleinfo_red_data.RefreshSoicalCardRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_DOORPLATE_REDDOT, roleinfo_red_data.RefreshHomeDoorPlateRed)
  EventSystem:registEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_UPDATE_LIGHT_BOARD_RED_POINT, roleinfo_red_data.RefreshLightBoardRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_BACKGROUND_REDDOT, roleinfo_red_data.RefreshBackGroundRed)
  EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_OPENING_REDDOT, roleinfo_red_data.RefreshOpeningRed)
  EventSystem:registEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_GET_OWNED_BG_LIST, roleinfo_red_data.OnGetOwnedBGList)
  EventSystem:registEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_READ_BG_RSP, roleinfo_red_data.OnReadBG)
  EventSystem:registEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_NOTIFY_NEW_BG, roleinfo_red_data.OnNotifyNewBG)
  roleinfo_red_data.BindAchievementRed()
  isRegisted = true
end
function roleinfo_red_data.BindAchievementRed()
  local achievement_red = require("client.logic.achievement.achievement_red")
  local achievementRedData = achievement_red.GetRedData()
  roleinfo_red_data.bAchievementRedBinding = true
  achievementRedData:AddListener("newCount", roleinfo_red_data.OnRefreshAchievementRed)
  roleinfo_red_data.bAchievementRedBinding = false
end
function roleinfo_red_data.OnLevelChange()
  roleinfo_red_data.RefreshLevelTaskRed()
end
function roleinfo_red_data.CheckSettingRed()
  return spData.avatarRed or spData.avatarFrameRed or spData.aliasRed or spData.nameFrameRed or spData.teamupFrameRed or spData.carteFrameRed or spData.soicalcardRed or spData.nicknameFrameRed or spData.chatFrameRed or spData.lightBoardRed or spData.backgroundRed or spData.openingRed or spData.homeDoorPlateRed or spData.nicknameColorRed or spData.chatRoomBGRed
end
function roleinfo_red_data.RefreshAvatarRed()
  local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
  spData.avatarRed = RoleInfoAvatarSystem.HaveNewHeadportrait()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshAll()
  roleinfo_red_data.RefreshAvatarFrameRed()
  roleinfo_red_data.RefreshAliasRed()
  roleinfo_red_data.RefreshNameFrameRed()
  roleinfo_red_data.RefreshLevelTaskRed()
  roleinfo_red_data.RefreshPartnerRed()
  roleinfo_red_data.RefreshCardRed()
  roleinfo_red_data.RefreshTeamupFrameRed()
  roleinfo_red_data.RefreshCarteFrameRed()
  roleinfo_red_data.RefreshSoicalCardRed()
  roleinfo_red_data.RefreshNicknameFrameRed()
  roleinfo_red_data.RefreshChatFrameRed()
  roleinfo_red_data.RefreshLightBoardRed()
  roleinfo_red_data.RefreshBackGroundRed()
  roleinfo_red_data.RefreshOpeningRed()
  roleinfo_red_data.RefreshAchievementRed()
  roleinfo_red_data.RefreshHomeDoorPlateRed()
end
function roleinfo_red_data.RefreshLightBoardRed()
  local logic_light_board = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_light_board)
  spData.lightBoardRed = logic_light_board:HasNew()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshCardRed()
  spData.newCardRed = false
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local birthdayRed = false
  local birthdayData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBirthdaySettingReddot)
  if not birthdayData or not birthdayData.BirthdaySettingReddot then
    log(bWriteLog and string.format("roleinfo_red_data.RefreshCardRed birthday red"))
    birthdayRed = true
  end
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if birthdayRed and SocialCardSystem.MySocialCard.birthday and SocialCardSystem.MySocialCard.birthday ~= "" then
    birthdayRed = false
    local data = {}
    data.BirthdaySettingReddot = true
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eBirthdaySettingReddot)
  end
  local lbsRed = false
  local lbsData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLBSSettingReddot)
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  local lbsSwitch = LbsMgr.IsLbsAllSwitchOpen()
  if lbsSwitch and (not lbsData or not lbsData.LBSSettingReddot) then
    log(bWriteLog and string.format("roleinfo_red_data.RefreshCardRed lbs red lbsSwitch = %s", tostring(lbsSwitch)))
    lbsRed = true
  end
  local genderRed = false
  local genderData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGenderSettingReddot)
  if not genderData or not genderData.GenderSettingReddot then
    log(bWriteLog and string.format("roleinfo_red_data.RefreshCardRed gender red"))
    genderRed = true
  end
  if genderRed and SocialCardSystem.MySocialCard and SocialCardSystem.MySocialCard.new_sex then
    genderRed = false
    local data = {}
    data.GenderSettingReddot = true
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eGenderSettingReddot)
  end
  spData.newCardRed = birthdayRed or lbsRed or genderRed
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshAvatarFrameRed()
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  spData.avatarFrameRed = RoleInfoAvatarFrameSystem.HaveNew()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshAliasRed()
  local RoleInfoAliasSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  spData.aliasRed = RoleInfoAliasSystem.hasRedpoint()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshNameFrameRed()
  local RoleInfoNameFrameSystem = require("client.slua.logic.person_space.logic_roleinfo_nameframe")
  spData.nameFrameRed = RoleInfoNameFrameSystem.HaveNew()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshLevelTaskRed()
  local Logic_Level_Task = require("client.slua.logic.task.logic_level_task")
  spData.levelTaskRed = Logic_Level_Task.GetLevelTaskRedDot()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshPartnerRed()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  spData.partnerRed = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE) or PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE) or PersonSpaceSystem.HasIntimacyCanGetRewardReddot()
end
function roleinfo_red_data.RefreshTeamupFrameRed()
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  spData.teamupFrameRed = logic_roleInfo_TeamUpFrame:HaveNew()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshCarteFrameRed()
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  spData.carteFrameRed = logic_roleinfo_carte_frame:HaveRed()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshSoicalCardRed()
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  spData.soicalcardRed = logic_social_card_bg:HaveRedDot()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshBackGroundRed()
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  spData.backgroundRed = logic_roleInfo_background:HaveRedDot()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshOpeningRed()
  local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
  spData.openingRed = logic_roleInfo_opening:HaveRedDot()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshNicknameFrameRed()
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
  spData.nicknameFrameRed = logic_roleInfo_nicknameframe:HaveNew()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshChatFrameRed()
  local logic_roleInfo_chatframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_chatframe)
  spData.chatFrameRed = logic_roleInfo_chatframe:HaveNew()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.RefreshHomeDoorPlateRed()
  local logic_home_door_plate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_door_plate)
  spData.homeDoorPlateRed = logic_home_door_plate:HaveNew()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.OnGetOwnedBGList()
  log(bWriteLog and "roleinfo_red_data.OnGetOwnedBGList")
  roleinfo_red_data.RefreshChatRoomBGRed()
end
function roleinfo_red_data.OnReadBG()
  log(bWriteLog and "roleinfo_red_data.OnReadBG")
  roleinfo_red_data.RefreshChatRoomBGRed()
end
function roleinfo_red_data.OnNotifyNewBG()
  log(bWriteLog and "roleinfo_red_data.OnNotifyNewBG")
  roleinfo_red_data.RefreshChatRoomBGRed()
end
function roleinfo_red_data.RefreshChatRoomBGRed()
  local LogicChatRoomBG = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicChatRoomBG)
  spData.chatRoomBGRed = LogicChatRoomBG:HaveNewBG()
  spData.settingRed = roleinfo_red_data.CheckSettingRed()
  spData.baseInfoRed = spData.settingRed or spData.levelTaskRed
end
function roleinfo_red_data.OnRefreshAchievementRed(oldValue, value)
  if roleinfo_red_data.bAchievementRedBinding then
    return
  end
  log(bWriteLog and "roleinfo_red_data.OnRefreshAchievementRed. value:" .. value)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local bRed = level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.achievement) and 0 < value
  spData.achievementRed = bRed
  spData.honorRed = spData.achievementRed or spData.aliasShowRed or spData.honourCertificateRed
end
function roleinfo_red_data.RefreshAchievementRed()
  local achievement_red = require("client.logic.achievement.achievement_red")
  local achievementRedData = achievement_red.GetRedData()
  local bRed = achievementRedData.newCount > 0
  spData.achievementRed = bRed
  spData.honorRed = spData.achievementRed or spData.aliasShowRed or spData.honourCertificateRed
  log(bWriteLog and "roleinfo_red_data.RefreshAchievementRed. bRed:" .. tostring(bRed))
end
function roleinfo_red_data.RefreshHonourCertificateRed(bRed)
  spData.honourCertificateRed = bRed or false
  spData.honorRed = spData.achievementRed or spData.aliasShowRed or spData.honourCertificateRed
end
function roleinfo_red_data.SetHistoryRed(flag)
  spData.historyRed = flag or false
end
function roleinfo_red_data.RefreshCollectRed()
  for roleRed, collectRed in pairs(RoleRed2CollectRed) do
    if spData[roleRed] then
      spData.collectRed = true
      return
    end
  end
  spData.collectRed = false
end
function roleinfo_red_data.SetCollectRoadRed(road)
  log_warning(bWriteLog and string.format("roleinfo_red_data.SetCollectRoadRed. road %s", road))
  spData.collectRoad = road or false
  roleinfo_red_data.RefreshCollectRed()
end
function roleinfo_red_data.SetCollectLibraryRed(lib)
  log_warning(bWriteLog and string.format("roleinfo_red_data.SetCollectLibraryRed. lib %s", lib))
  spData.collectLib = lib or false
  roleinfo_red_data.RefreshCollectRed()
end
function roleinfo_red_data.SetCollectRankRed(rank)
  log_warning(bWriteLog and string.format("roleinfo_red_data.SetCollectRankRed. rank %s", rank))
  spData.collectRank = rank or false
  roleinfo_red_data.RefreshCollectRed()
end
function roleinfo_red_data.UpdateCareerRedPointData()
  local Logic_Career = require("client.slua.logic.career.logic_career")
  if not Logic_Career.IsOpen() then
    return
  end
  local logic_careerRedPoint = require("client.slua.logic.career.logic_careerRedPoint")
  spData.careerRed = logic_careerRedPoint.IsExistRedPoint()
end
function roleinfo_red_data.GetSuperData()
  return spData
end
function roleinfo_red_data.GetSubRed(subIndex)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local redKeyTb = {
    [RoleInfoMainSystem.CollectMain] = "collectRoad",
    [RoleInfoMainSystem.CollectLib] = "collectLib",
    [RoleInfoMainSystem.CollectRank] = "collectRank"
  }
  return spData[redKeyTb[subIndex]]
end
return roleinfo_red_data