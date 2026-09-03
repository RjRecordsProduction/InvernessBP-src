DeathMatchResultUI = DeathMatchResultUI or {
  battle_id = "",
  result_time = 0,
  isShow = false,
  TestAvatarNum = 1
}
function DeathMatchResultUI.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "bp_battleresult_deathmatch_OnModeSwitched:" .. tostring(nextState))
  if nextState == GameStatus.Fighting then
    DeathMatchResultUI.USE_TEST = false
    if DeathMatchResultUI.USE_TEST then
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimer(3, function()
        DeathMatchResultUI.OnTestResultData()
      end)
    end
    BattleResultUI.AlreadyUpvotedUID = {}
    DeathMatchResultUI.ScrollBox_MissionList = nil
  end
end
BP_STRUCT_PlayerResultData = {
  PlayerScore = 0,
  Rank = 0,
  SuperGodNum = 0,
  HeadShotNum = 0,
  MaxContinuouKills = 0,
  ShootWeaponShotNum = 0,
  Kills = 0,
  PlayerKey = "",
  PlayerName = "",
  DamageAmount = 0,
  ShootWeaponShotAndHitPlayerNum = 0,
  Deaths = 0,
  UID = "",
  TeamID = 0,
  Assists = 0,
  RescueTimes = 0,
  gender = 0,
  weapon_show_list = {},
  wear = {},
  rela_sex = 1,
  mvp = 0,
  settl_motion = 0,
  is_robot = false,
  pic_url = "",
  player_level = 0,
  segment_level = 0,
  cur_avatar_box_id = 0,
  HasEscape = false
}
BP_IsReceiveResult = false
BP_STRUCT_HeadUrlInfo = {
  uid = "",
  picUrl = "",
  player_level = 0,
  segment_level = 0,
  cur_avatar_box_id = 0
}
function DeathMatchResultUI.OnDeathMatchResult(result, is_global_ob)
  log(bWriteLog and "g_game_id is " .. g_game_id)
  log(bWriteLog and "Lua-(bp_battleresult_deathmatch) result.battle_id is " .. result.battle_id)
  LobbySystem.SetFeedBackFlag(result.need_game_evaluation == 1)
  DeathMatchResultUI.battle_id = tostring(result.battle_id)
  BP_IsReceiveResult = true
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local BattleResultConfig = GamePlayTools.GetCurrentConfig("BattleResultConfig")
  ResetResultMonitor()
  NetUtil.BBattleResultRecieved = true
  if BattleResultConfig and BattleResultConfig.BattleResultProcess then
    local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
    if BattleResultSubSystem then
      result.IsDeathMatchResult = true
      result.isGlobalOB = is_global_ob or false
      BattleResultSubSystem:OnBattleResult(result)
      if LuaClassObj.GetGameStatus(bp_global) ~= GameStatus.Fighting then
        BattleResult.IgnoreDSError = false
      else
        BattleResult.IgnoreDSError = true
        NetUtil.StopCheckDSActive()
      end
      return
    else
      log(bWriteLog and "BattleResultSubSystem is nil")
    end
  end
end
function DeathMatchResultUI.OnTestResultData()
  local BattleResultsTestUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultsTestUtil")
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeName = GameMainConfig.GetModType()
  local test_result = BattleResultsTestUtil.GetTestBattleResultTDM()
  if DeathMatchResultUI.TestAvatarNum > 0 then
    for i = DeathMatchResultUI.TestAvatarNum + 1, 8 do
      if test_result.TeamResultDatas[1].TeamPlayerResultDatas[i] then
        test_result.TeamResultDatas[1].TeamPlayerResultDatas[i] = nil
      end
      if test_result.TeamResultDatas[2].TeamPlayerResultDatas[i] then
        test_result.TeamResultDatas[2].TeamPlayerResultDatas[i] = nil
      end
    end
  end
  if ModeName and ModeName ~= "" then
    local TableUtil = require("common.table_util")
    local tModExtraData = BattleResultsTestUtil.GetModExtraData(ModeName)
    test_result = TableUtil.MergeTable(test_result, tModExtraData or {})
  end
  log_tree("test_result = ", test_result)
  BattleResult.RESULTLEVEL_TEST = true
  DeathMatchResultUI.OnDeathMatchResult(test_result, false)
end