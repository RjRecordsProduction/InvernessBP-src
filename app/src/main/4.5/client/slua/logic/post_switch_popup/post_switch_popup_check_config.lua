local post_switch_popup_check_config = {}
function post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_DELAY_NOTICES()
  log(bWriteLog and "post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_DELAY_NOTICES")
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  return NoticesModule:CanShowNotice(NoticesConst.Scene.DelayNotices)
end
function post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_SEASON_SLAP()
  log(bWriteLog and "post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_SEASON_SLAP")
  local SeasonSystem = require("client.logic.season.logic_season")
  return SeasonSystem.CheckCanShowSeasonSlap()
end
function post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_SEASON_YEAR_BADGE_SLAP()
  log(bWriteLog and "post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_SEASON_YEAR_BADGE_SLAP")
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  return logic_season_year_badge:CheckCanShowLevelUpSlap()
end
function post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_PVP_LEVEL_UP_PANEL()
  log(bWriteLog and "post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_PVP_LEVEL_UP_PANEL")
  local LevelUpSystem = require("client.logic.levelup.logic_levelup")
  return LevelUpSystem.CheckCanShowLevelUpPanel()
end
function post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_LEVEL_UP_PANEL()
  log(bWriteLog and "post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_LEVEL_UP_PANEL")
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  return level_unlock_manager:NeedShowLevelup()
end
function post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_KEY_PLAY_VIDEO_NOW()
  log(bWriteLog and "post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_KEY_PLAY_VIDEO")
  local KeyPlayVideoSystem = require("client.slua.logic.lobby_activity.logic_keyplayvideo")
  return KeyPlayVideoSystem.NeedPlay(true)
end
function post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_VERSION_UPDATE_SLAP()
  log(bWriteLog and "post_switch_popup_check_config.CheckCanJump_BP_ENUM_MODULE_VERSION_UPDATE_SLAP")
  local logic_version_update_slap = require("client.slua.logic.version_update_slap.logic_version_update_slap")
  return logic_version_update_slap:CheckCanSlap()
end
return post_switch_popup_check_config