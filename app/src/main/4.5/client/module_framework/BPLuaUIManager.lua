local BPLuaUIManager = {}
local local local local local local local local _GlobalNameList = {
  "UpdateAndLoginFSM",
  "LobbyUI",
  "GlobalData",
  "BattleResultUI",
  "BattleResultInfectionUI",
  "BattleResultVehicleUI",
  "DeathMatchResultUI"
}
local _RequiredNameList = {
  "client.slua.logic.match.logic_mode_mgr",
  "client.slua.logic.match.logic_match",
  "client.slua.logic.match.logic_lobby_ping_report",
  "client.slua.logic.actor_voice.logic_actor_voice",
  "client.slua.logic.lobby_activity.logic_luckyback_activity",
  "client.slua.logic.lobby_activity.logic_luckyunback_activity",
  "client.slua.logic.lobby_activity.logic_luckydouble_activity",
  "client.slua.logic.weapon_diy.logic_weapon_diy",
  "client.slua.logic.activity.logic_activity_entry_set",
  "client.slua.logic.subscribe.logic_subscribe_base",
  "client.slua.logic.lobby_chat.logic_chat_main",
  "GameLua.Mod.SocialIsland.Client.Alias.IslandAliasClientLogic",
  "client.slua.logic.teamup.logic_lobby_my_team",
  "client.slua.logic.teamup.logic_team_platform",
  "client.network.Protocol.WeaponDiyHandler",
  "client.logic.common.logic_bottomright_messagebox",
  "client.slua.logic.activity.logic_bottomright_tips",
  "client.logic.activity.logic_activity_rebate",
  "client.slua.logic.activity.logic_quick_question",
  "client.slua.logic.TxMission.logic_xmission_main",
  "client.slua.logic.TxMission.logic_xmission_team",
  "client.slua.logic.TxMission.logic_xmission_conversation",
  "client.slua.logic.TxMission.logic_xmission_beginner_guide",
  "client.logic.recharge.logic_recharge",
  "client.logic.recharge.logic_recharge_jk",
  "client.common.image_style",
  "client.slua.logic.esport.logic_esport_allstar",
  "client.slua.logic.championship.logic_championship_sponsor",
  "client.slua.logic.subscribe.logic_subscribe_carnival_activity",
  "client.slua.logic.player_return.logic_player_return",
  "client.slua.logic.esport.logic_esport_squad",
  "client.slua.logic.esport.logic_esport_squad_other",
  "client.slua.logic.live_video.logic_live_video",
  "client.slua.logic.activity.logic_recharge_gas_station",
  "client.slua.logic.unknow_pass.logic_unknowpass_subscription",
  "client.slua.logic.subscribe.logic_subscribe_carnival_activity",
  "client.slua.logic.subscribe.logic_subscribe_base",
  "client.slua.logic.common.logic_notice_mgr",
  "client.slua.logic.loading.logic_loading",
  "client.slua.logic.loading.logic_teamcomp_loading",
  "client.logic.roleinfo.logic_new_roleinfo",
  "client.slua.logic.teamup.logic_team_up",
  "client.slua.logic.manager.LobbySceneMgr",
  "client.slua.logic.teamup.logic_shadow_zone",
  "client.slua.logic.pubgm_music.logic_pubgm_music",
  "client.slua.logic.esport.logic_esport_center",
  "client.slua.logic.growth_project.logic_growth_project_b",
  "client.logic.lobby.hall_theme_utils",
  "client.logic.levelup.logic_levelup",
  "client.slua.logic.moment.logic_moment",
  "client.slua.logic.lobby_activity.logic_ladder_draw",
  "client.slua.logic.plot.logic_plot_activity",
  "client.slua.logic.luck_airdrop.logic_luck_air_drop",
  "client.slua.logic.lobby.Left.logic_social_preview_bag",
  "client.slua.logic.activity.logic_bind_facebook",
  "client.slua.logic.activity.bind_discord.logic_bind_discord",
  "client.slua.logic.room.logic_create_room",
  "client.slua.logic.lobby.logic_lobby_ob",
  "client.logic.login.logic_room",
  "client.slua.logic.XSuit.logic_xsuit",
  "client.slua.logic.store.logic_store_gift",
  "client.slua.logic.mini_tv.logic_mini_tv",
  "client.slua.logic.team_evaluation.logic_team_evaluation_view",
  "client.slua.logic.corps.logic_corps_fight",
  "client.slua.logic.player_return.logic_longline_task",
  "client.slua.logic.lobby.logic_mode_entry",
  "client.logic.season.logic_season",
  "client.slua.logic.gdpr.logic_gdpr",
  "client.slua.logic.rank.logic_rank",
  "client.slua.logic.replay.logic_replay",
  "client.slua.logic.replay.logic_share_replay",
  "client.slua.logic.SmallPayment.Logic_SmallPayment",
  "client.slua.logic.Appraise.logic_appraise",
  "client.slua.logic.lobby_activity.logic_godzilla_ban",
  "client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel",
  "client.slua.logic.activity.logic_activitycenter_notice",
  "client.slua.logic.wardrobe.logic_wardrobe_new",
  "client.slua.logic.unknow_pass.logic_unknowpass_activity_collection",
  "client.logic.setting.logic_setting_account",
  "client.slua.logic.mentor.logic_mentor",
  "client.slua.logic.achievement.logic_achievement",
  "client.slua.logic.mail.logic_mail",
  "client.slua.logic.activity.ActivityUtil",
  "client.slua.logic.lobby.Mid.logic_lobby_mid_pmgc_entry",
  "client.slua.logic.unknow_pass.logic_unknowpass_crt_score",
  "client.slua.logic.unknow_pass.logic_unknowpass_gift",
  "client.logic.share.logic_avatar_capture",
  "client.slua.logic.security.logic_security",
  "client.slua.logic.audio.logic_ak_audio",
  "client.logic.personspace.logic_person_space",
  "client.slua.logic.lobby_watermark.logic_lobby_watermark",
  "client.slua.logic.home.Lobby.logic_lobby_home_entrance_tips_File"
}
local _EditorRunBattleWhiteGlobalNameList = {
  "BattleResultUI",
  "BattleResultInfectionUI",
  "BattleResultVehicleUI",
  "DeathMatchResultUI"
}
local _EditorRunBattleWhiteRequiredNameList = {
  "client.slua.logic.manager.LobbySceneMgr"
}
if IsEditor then
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local sLevel = UGameplayStatics.GetCurrentLevelName(UIUtil.GetGameInstance(), true)
  if not string.find(sLevel, "Editor_login") and not string.find(sLevel, "Untitled") then
    print(bWriteLog and "PIE NOT Start from Editor_login, return" .. sLevel)
    _GlobalNameList = _EditorRunBattleWhiteGlobalNameList
    _RequiredNameList = _EditorRunBattleWhiteRequiredNameList
  end
end
local _bInit = false
local _OnModePreSwitch = function(preState, nextState)
  local utility = require("common.utility")
  for _, v in ipairs(_GlobalNameList) do
    local manager = _G[v]
    local func = manager and manager.OnModePreSwitch
    if func then
      xpcall(func, utility.ErrorMessageHandler, preState, nextState)
    end
  end
  for _, v in ipairs(_RequiredNameList) do
    local manager = require(v)
    local func = manager.OnModePreSwitch
    if func then
      xpcall(func, utility.ErrorMessageHandler, preState, nextState)
    end
  end
end
local _OnModePostSwitch = function(preState, nextState)
  local utility = require("common.utility")
  local LobbySystem = require("client.logic.login.logic_lobby")
  for _, v in pairs(_GlobalNameList) do
    local manager = _G[v]
    local func = manager and manager.OnModePostSwitch
    if func ~= nil then
      xpcall(func, utility.ErrorMessageHandler, preState, nextState)
    end
  end
  for k, v in pairs(_RequiredNameList) do
    local manager = require(v)
    local func = manager and manager.OnModePostSwitch
    if func ~= nil then
      xpcall(func, utility.ErrorMessageHandler, preState, nextState)
    end
  end
end
local _RegEvent = function()
  local game_frontend_hud = require("game_frontend_hud")
  game_frontend_hud.SetPreSwitchGameStatusListener(_OnModePreSwitch)
  game_frontend_hud.SetPostSwitchGameStatusListener(_OnModePostSwitch)
end
function BPLuaUIManager.InitOnlyOne()
  log(bWriteLog and "BPLuaUIManager.InitOnlyOne.  ")
  if _bInit then
    log_error("BPLuaUIManager Already Init")
    return
  end
  _bInit = true
  _RegEvent()
  for _, v in ipairs(_GlobalNameList) do
    local manager = _G[v]
    if manager == nil then
      log_error("BPLuaUIManager.InitOnlyOne == nil " .. v)
    else
      local func = manager.InitOnlyOne
      if func then
        local utility = require("common.utility")
        xpcall(func, utility.ErrorMessageHandler)
      end
    end
  end
  for k, v in pairs(_RequiredNameList) do
    local manager = require(v)
    if manager == nil then
      log_error("RequiredName BPLuaUIManager.InitOnlyOne == nil " .. v)
    else
      local func = manager.InitOnlyOne
      if func then
        local utility = require("common.utility")
        xpcall(func, utility.ErrorMessageHandler)
      end
    end
  end
  log(bWriteLog and "BPLuaUIManager.InitOnlyOne()")
end
return BPLuaUIManager