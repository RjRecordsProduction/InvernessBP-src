BattleResultUI = BattleResultUI or {
  battle_id = "",
  team_id = "",
  result_time = 0,
  uid_back = 0,
  result_back = {},
  AlreadyUpvotedUID = {},
  InBattleScene = false,
  isShow = false,
  UseTXTResultData = false
}
function bp_battleresult_RegisterUI()
  log(bWriteLog and "bp_battleresult_RegisterUI")
end
UPassgameEndShowFinishTasksList = {}
Complaint_IsRePlayClick = false
function BattleResultUI.InitOnlyOne()
  log(bWriteLog and "BattleResultUI.InitOnlyOne()")
  BattleResult.ShowingExitWatchGame = false
  EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK, BattleResultUI.HandleIOSCheck)
  EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, BattleResultUI.OnCollectedResult)
  EventSystem:registEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_RESERVE_RESPONSE, BattleResultUI.HandleReverseReponse)
end
function BattleResultUI.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "BattleResultUI.OnModePostSwitch nextState:" .. tostring(nextState))
  BattleResultUI.mSendGiftFriendName = {}
  BattleResultUI.GiftNotifyMap = {}
  BattleResultUI.UpvoteNotifyMap = {}
  BattleResultUI.AddFriendMap = {}
  BattleResultUI.bShowUpvoteNotify = false
  local logic_friend_apply_battle = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply_battle)
  logic_friend_apply_battle:ResetResultAddFriendReq(0, nil)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.InitLoginChannel()
  BattleResult.ShowingExitWatchGame = false
  BP_ShouldDelayShowBattleResult = true
  Complaint_IsRePlayClick = false
  BP_IsReceiveResult = false
  BP_DirectShow = false
  BPRecordOneMoreLeaderUin = 0
  if ResultToSpectate then
    ResultToSpectate.canceled = false
  end
  BattleResultUI.ResetBattleResultData(nextState)
  BattleResultUI.InResultProcess = false
  BattleResultUI.InBattleScene = nextState == GameStatus.Fighting
  if nextState == GameStatus.Fighting then
    BattleResultUI.AlreadyUpvotedUID = {}
    BattleResult.IgnoreDSError = false
    BattleResult.BP_IsShowResultPanel = false
    BattleResult.EvaluatedUIDList = {}
    BattleResult.USE_TEST = false
    local TestShowPlayerNum = 2
    if _G.IsEditor then
      local ResultAvatarRootPointClass = slua.loadClass("/Game/BluePrints/ControlInput/ResultsshareUI/Item/ResultRoleTransform.ResultRoleTransform")
      local uActor = import("/Script/Engine.Actor")
      local UGameplayStatics = import("GameplayStatics")
      local UIUtil = require("client.common.ui_util")
      local uTargetArray = UGameplayStatics.GetAllActorsOfClass(UIUtil.GetGameInstance(), ResultAvatarRootPointClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      for _, uTarget in pairs(uTargetArray) do
        if uTarget and slua.isValid(uTarget) then
          if uTarget.DebugMode then
            BattleResult.USE_TEST = true
          end
          TestShowPlayerNum = uTarget.PlayerNum
        end
      end
    end
    log(bWriteLog and "BattleResultUI Set false!!!!!")
    BattleResultUI.ScrollBox_MissionList = nil
    if BattleResult.USE_TEST then
      BP_ShowFeedBack = true
      g_game_id = 893163251483017251
      testResult = true
      BattleResult.RESULTLEVEL_TEST = true
      local battleResultsTestUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultsTestUtil")
      local result = battleResultsTestUtil.GetTestBattleResult(TestShowPlayerNum)
      local TimeTicker = require("common.time_ticker")
      TimeTicker.AddTimer(5, function()
        log(bWriteLog and "resulttest OnBattleResult 1111")
        BattleResultUI.OnBattleResult(0, result)
      end)
    end
  end
end
function BattleResultUI.ResetBattleResultData(nextState)
  log(bWriteLog and "BattleResultUI.ResetBattleResultData nextState:" .. tostring(nextState))
  if nextState ~= GameStatus.Fighting then
    BP_STRUCT_BattleResultData.battle_id = 0
    BP_STRUCT_BattleResultData.add_gold = 0
    BP_STRUCT_BattleResultData.add_exp = 0
    BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL = _G.BP_STRUCT_GOLD_DETAIL
    BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL = _G.BP_STRUCT_EXP_DETAIL
  end
end
InGame_IsMyFriend = true
Ingame_OBPlayer_BattleData_UID = ""
function EventGetIsMyFriend()
  local selfUid = 0
  if DataMgr ~= nil and DataMgr.roleData ~= nil then
    selfUid = tonumber(DataMgr.roleData.uid)
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  InGame_IsMyFriend = LogicFriend.IsMyFriend("" .. Ingame_OBPlayer_BattleData_UID)
  log(bWriteLog and "EventGetIsMyFriend InGame_IsMyFriend = " .. tostring(InGame_IsMyFriend))
end
function EventOBViewAddFriendRequest()
  log(bWriteLog and "EventOBViewAddFriendRequest start add friend  " .. tostring(Ingame_OBPlayer_BattleData_UID))
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:add_inner_friend_req(tostring(Ingame_OBPlayer_BattleData_UID), "", BP_ENUM_ADD_FRIEND_FROM_OB_PLAYER_INFO, 39)
end
function BattleResultUI.OnCollectedResult()
  log(bWriteLog and "BattleResultUI.OnCollectedResult")
  WatchGameUI:OnCollectedResult()
end
function BattleResultUI.HandleIOSCheck()
  if GlobalData.IsIOSCheck() then
    log(bWriteLog and "bp_battleresult_RegisterUI start")
    LuaClassObj.SubCollapseWidgetList(bp_battleresult, "ResultsRanking_BP_C", {
      "Overlay_ShareBtn",
      "FlauntBox",
      "Overlay_ShareTips",
      "Button_ShareTitle"
    })
    LuaClassObj.HandleCollapseWidgetList(bp_battleresult, "ResultsRanking_BP_C")
  end
end
BP_STRUCT_BTRating = {
  rank_rating = 0,
  kill_rating = 0,
  win_rating = 0,
  change_rank_rating = 0,
  change_kill_rating = 0,
  change_win_rating = 0,
  old_segment = 0,
  new_segment = 0
}
BP_STRUCT_BTRatingProtect = {protect_type = "", value = 0}
BP_STRUCT_DailyWinActivity = {
  CurrentNum = 0,
  MaxNum = 10,
  ExtraScore = 10,
  Desc1 = "",
  Desc2 = "",
  Desc3 = ""
}
BP_STRUCT_ReturnDailyWinActivity = {back_user_daily_win_score = 0}
BP_STRUCT_CHAR_EXP_DETAIL = {
  level = 0,
  max_level = 0,
  daily_exp = 0,
  daily_exp_max = 0
}
BP_STRUCT_BattleResultData = {
  Reason = "",
  RemainingPlayerCount = 0,
  TotalPlayerCount = 100,
  RemainingTeamCount = 0,
  TotalTeamCount = 25,
  IsSolo = false,
  ShootWeaponShotNum = 0,
  ShootWeaponShotAndHitPlayerNum = 0,
  HealTimes = 0,
  destroyVehicleNum = 0,
  HeadShotRatio = 0.2,
  add_exp = 0,
  add_gold = 0,
  char_id = 0,
  char_add_exp = 0,
  add_veteran_exp = 0,
  add_vaccinum = 0,
  add_carteam_coin = 0,
  rank_score = 0,
  kill_score = 0,
  league_seq = 0,
  carteam_id = 0,
  tournament_id = 0,
  is_pug_result = false,
  battle_id = 0,
  max_game_num = 2,
  person_rank = 1,
  team_rank = 1,
  final_level = "",
  is_team_result = false,
  is_last_survive = false,
  is_version_match = false,
  battle_type = 101,
  get_gold_today = 0,
  famous_id = 0,
  isobserver = false,
  is_anchor_ob = false,
  battle_owner = 0,
  sub_mode = 0,
  segment_protect = false,
  double_rating = false,
  is_activity_protect = false,
  delay_time = 0,
  common_omb_team_id = 0,
  new_year_team_str = "",
  RelationInfo = {},
  BP_ARRAY_TeammateList = {
    tmp_UseExist_BP_STRUCT_MemBTResultData = {}
  },
  BP_STRUCT_BTRating = _G.BP_STRUCT_BTRating,
  BP_STRUCT_BTRatingProtect = _G.BP_STRUCT_BTRatingProtect,
  BP_STRUCT_GOLD_DETAIL = _G.BP_STRUCT_GOLD_DETAIL,
  BP_STRUCT_EXP_DETAIL = _G.BP_STRUCT_EXP_DETAIL,
  BP_STRUCT_RADAR = _G.BP_STRUCT_RADAR,
  BP_STRUCT_CHAR_EXP_DETAIL = _G.BP_STRUCT_CHAR_EXP_DETAIL,
  BP_STRUCT_SegmentProtect = _G.BP_STRUCT_SegmentProtect,
  score_version = 1,
  SeasonBestRank = 301,
  SeasonNumber = 14,
  BP_STRUCT_DailyWinActivity = _G.BP_STRUCT_DailyWinActivity,
  BP_STRUCT_ReturnDailyWinActivity = _G.BP_STRUCT_ReturnDailyWinActivity,
  is_player_return_protect = false,
  player_return_protect_times = 0,
  player_return_protect_count = 0,
  is_rank_protect = false,
  is_time_card_protect = false,
  is_times_card_protect = false,
  careerScore = 50,
  SeasonCoinInfo = {},
  seasonGold = 0,
  ChallengeScore = 100,
  IsRevivalMode = false,
  corps_add_active_type = {},
  WorldCupAddRatingActivity = {world_cup_daily_win_score = 10, world_cup_times_challenge = 2}
}
BP_ARRAY_TeammateProfile = {}
BP_STRUCT_SpawnPlayerRoleInfo = {}
BP_ARRAY_TeammateRoleInfo = {
  BP_STRUCT_SpawnPlayerRoleInfo = _G.BP_STRUCT_SpawnPlayerRoleInfo
}
BP_WATCHUI_SEND_GIFT_MSG = ""
BP_ARRAY_OBBattleResult = {
  tmp_UseExist_BP_STRUCT_OBTeamResult = {}
}
BP_STRUCT_OBTeamResult = {
  BP_ARRAY_OBPersonalResult = {
    tmp_UseExist_BP_STRUCT_OBPersonalResult = {}
  }
}
BP_STRUCT_OBPersonalResult = {
  uid = "",
  rank = 0,
  kill = 0,
  name = "",
  gender = 0
}
BP_IsShowOBGender = true
BP_myname = "12345678901234"
BP_mystate = ""
BP_Terminator = ""
BP_EnterSpectateMode = false
testResult = false
BP_ServerTimeSecNow = 0
BP_IsReportComplaintShow = false
BP_TeamModeName = ""
BP_DirectShow = false
BattleResult_TeamList_ForReportComplaint = {}
BP_IsReceiveResult = false
BP_IsShowResultPanel = false
BP_WatchExitReason = "game_over"
BP_ShouldDelayShowBattleResult = true
BP_IsDelayShowBattleRankingUI = false
BP_MyPetAddExp = 0
BP_ShowFeedBack = false
BP_FeedBackScore = 1
BATTLETYPE_MODE = 101
function BattleResultUI.UpdateShareBtnState()
  if GlobalData.IsIOSCheck() then
    return
  end
  local ShareAwardMgr = require("client.logic.share_award.logic_share_award")
end
function BattleResultUI.SortTeammateList(result)
  local teammateList = result.TeammateList
  if result.ranklist == nil or #result.ranklist ~= #result.TeammateList then
    return teammateList
  end
  local outputList = {}
  local swapObject = function(obj1, obj2)
    return obj2, obj1
  end
  for k1, v1 in pairs(result.ranklist) do
    for k2, v2 in pairs(teammateList) do
      if v2.Name == v1 then
        v2.rankIndex = k1
      end
    end
  end
  table.sort(teammateList, function(a, b)
    return a.rankIndex < b.rankIndex
  end)
  for k, v in pairs(teammateList) do
    if v.Name == BP_myname then
      table.insert(outputList, 1, v)
    else
      table.insert(outputList, v)
    end
  end
  if #teammateList == 1 then
    outputList[1].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseAim)
  end
  if #teammateList == 2 then
    outputList[1].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseCrouch)
    outputList[2].resultAvatarPose = outputList[1].resultAvatarPose
  end
  if #teammateList == 3 then
    outputList[3].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseCrouch)
    outputList[2].resultAvatarPose = outputList[3].resultAvatarPose
    outputList[1].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, outputList[2].resultAvatarPose)
    outputList[1], outputList[2] = swapObject(outputList[1], outputList[2])
  end
  if 4 <= #teammateList then
    outputList[4].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseCrouch)
    outputList[3].resultAvatarPose = outputList[4].resultAvatarPose
    outputList[2].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, outputList[3].resultAvatarPose)
    outputList[1].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, outputList[2].resultAvatarPose)
    outputList[2], outputList[3] = swapObject(outputList[2], outputList[3])
    outputList[1], outputList[2] = swapObject(outputList[1], outputList[2])
    for i = 5, #teammateList do
      outputList[i].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseCrouch)
    end
  end
  return outputList
end
function BattleResultUI.get_one_user_rank_rsp(client_data, ok, zoneId, rank_info)
end
function BattleResultUI.OnBattleResult(uid, result)
  Client.CrashLog(NetInterface, 4, "Battle", "BattleResultS")
  if result.battle_type then
    BATTLETYPE_MODE = result.battle_type
    log(bWriteLog and "BattleResultUI.OnBattleResult BATTLETYPE_MODE:" .. tostring(BATTLETYPE_MODE))
  end
  BP_IsReceiveResult = true
  if not result.is_team_result then
    LobbySystem.SetFeedBackFlag(result.need_game_evaluation == 1)
  end
  if result.EvaluationLabels and next(result.EvaluationLabels) then
    BattleResult.TeammateEvaluationLabels = result.EvaluationLabels
  end
  BattleResult.HasShowEvaluationTips = false
  BattleResultUI.uid_back = uid
  BattleResultUI.result_back = result
  BattleResultUI.battle_id = tostring(result.battle_id)
  BattleResultUI.team_id = tostring(result.team_id)
  local TimeUtil = require("client.common.time_util")
  BattleResultUI.result_time = TimeUtil.GetServerTimeInSec()
  BP_BattleResultShouldShowMVPScene = false
  if BattleResultUI.UseTXTResultData then
    g_game_id = result.battle_id
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  if g_game_id ~= result.battle_id then
    return
  end
  if DataMgr ~= nil and DataMgr.roleData ~= nil then
    for _, TeammateInfo in pairs(result.TeammateList) do
      if DataMgr.roleData.uid and TeammateInfo.UID == tonumber(DataMgr.roleData.uid) then
        BP_myname = TeammateInfo.Name
      end
    end
  end
  if BattleResult.USE_TEST and DataMgr and DataMgr.roleData then
    BP_myname = "jojo"
    DataMgr.roleData.uid = "54300001779"
  end
  BattleResult_TeamList_ForReportComplaint = {}
  log(bWriteLog and "myname is " .. BP_myname)
  if result.title_id_list == nil then
    result.title_id_list = {}
  end
  if result.terminator ~= nil then
    BP_Terminator = result.terminator
  else
    BP_Terminator = ""
  end
  log(bWriteLog and "BP_Terminator:" .. BP_Terminator)
  local singleAddExp = BP_STRUCT_BattleResultData.add_exp
  local singleAddGold = BP_STRUCT_BattleResultData.add_gold
  BP_STRUCT_BattleResultData = result
  BP_STRUCT_BattleResultData.segment_protect = result.segment_protect or false
  local SeasonSystem = require("client.logic.season.logic_season")
  if result.segment_protect then
    SeasonSystem.UpdateProtectTimes()
  end
  printf("result.add_exp:%s result.add_gold:%s", result.add_exp, result.add_gold)
  if result.add_exp and result.add_exp > 0 then
    BP_STRUCT_BattleResultData.add_exp = result.add_exp
  else
    BP_STRUCT_BattleResultData.add_exp = singleAddExp
  end
  if result.add_gold and result.add_gold > 0 then
    BP_STRUCT_BattleResultData.add_gold = result.add_gold
  else
    BP_STRUCT_BattleResultData.add_gold = singleAddGold
  end
  BP_STRUCT_BattleResultData.char_add_exp = result.char_add_exp or 0
  BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList = {}
  BP_STRUCT_BattleResultData.BP_STRUCT_BTRating = result.rating
  BP_STRUCT_BattleResultData.BP_STRUCT_BTRatingProtect = {}
  BP_STRUCT_BattleResultData.BP_STRUCT_CHAR_EXP_DETAIL = {}
  BP_STRUCT_BattleResultData.IsSolo = 1 >= result.max_game_num
  BP_STRUCT_BattleResultData.max_game_num = result.max_game_num
  BP_STRUCT_BattleResultData.score_version = result.score_version or 1
  if DataMgr then
    BP_STRUCT_BattleResultData.SeasonNumber = DataMgr.season_id or 1
  end
  if result.rating then
    BP_STRUCT_BattleResultData.SeasonBestRank = result.rating.max_cur_segment_level or 101
  end
  if result.rating ~= nil and result.rating.new_segment ~= nil and result.rating.new_segment > 700 then
    local RankHandler = require("client.network.Protocol.RankHandler")
    if RankHandler then
      log(bWriteLog and "Battleresult send_get_one_user_rank zoneID " .. tostring(ZoneSystem.nChooseZoneID) .. " rating_type " .. tostring(result.rating.rating_type))
      RankHandler.send_get_one_user_rank("result", ZoneSystem.nChooseZoneID, 0, result.rating.rating_type)
    end
  end
  if result.rating_protect ~= nil then
    BP_STRUCT_BattleResultData.BP_STRUCT_BTRatingProtect.protect_type = result.rating_protect.protect_type or ""
    BP_STRUCT_BattleResultData.BP_STRUCT_BTRatingProtect.value = result.rating_protect.value or 0
  else
    BP_STRUCT_BattleResultData.BP_STRUCT_BTRatingProtect.protect_type = ""
    BP_STRUCT_BattleResultData.BP_STRUCT_BTRatingProtect.value = 0
  end
  if result.league_seq == nil or 0 >= result.league_seq then
    BP_STRUCT_BattleResultData.league_seq = 0
  end
  if result.tournament_id == nil or 0 >= result.tournament_id then
    BP_STRUCT_BattleResultData.tournament_id = 0
  end
  if result.carteam_id == nil or 0 >= result.carteam_id then
    BP_STRUCT_BattleResultData.carteam_id = 0
  end
  BP_STRUCT_BattleResultData.rank_score = result.rank_score or 0
  BP_STRUCT_BattleResultData.kill_score = result.kill_score or 0
  BP_STRUCT_BattleResultData.add_carteam_coin = result.add_carteam_coin or 0
  BP_STRUCT_BattleResultData.char_add_exp = result.char_add_exp or 0
  BP_STRUCT_BattleResultData.add_veteran_exp = result.mentor_exp or 0
  BP_STRUCT_BattleResultData.char_id = result.char_id or 0
  BP_STRUCT_BattleResultData.double_rating = result.double_rating or false
  BP_STRUCT_BattleResultData.is_activity_protect = result.is_activity_protect or false
  local selfUid = 0
  if DataMgr ~= nil and DataMgr.roleData ~= nil then
    selfUid = tonumber(DataMgr.roleData.uid)
  end
  BP_STRUCT_BattleResultData.BP_STRUCT_CHAR_EXP_DETAIL.level = result.char_level or 0
  BP_STRUCT_BattleResultData.BP_STRUCT_CHAR_EXP_DETAIL.max_level = result.char_max_level or 0
  BP_STRUCT_BattleResultData.BP_STRUCT_CHAR_EXP_DETAIL.daily_exp = result.char_daily_exp or 0
  BP_STRUCT_BattleResultData.BP_STRUCT_CHAR_EXP_DETAIL.daily_exp_max = result.char_daily_exp_max or 0
  BP_STRUCT_BattleResultData.add_vaccinum = 0
  if result.SpecialCollectionList ~= nil then
    for i, v in pairs(result.SpecialCollectionList) do
      log(bWriteLog and "BattleResultUI.OnBattleResult SpecialCollectionList, i:" .. tostring(i) .. " v: " .. v.item_id)
      if v.item_id == 3001014 then
        log(bWriteLog and "BattleResultUI.OnBattleResult add_vaccinum count:" .. tostring(v.count))
        BP_STRUCT_BattleResultData.add_vaccinum = v.count
        break
      end
    end
  end
  BP_TeamModeName = GetTeamModeName()
  BattleResultUI.GetStrategyBtnStatus()
  log(bWriteLog and "BattleResultUI.OnBattleResult Reason:" .. tostring(BP_STRUCT_BattleResultData.Reason) .. " IsSolo:" .. tostring(BP_STRUCT_BattleResultData.IsSolo) .. " is_last_survive:" .. tostring(BP_STRUCT_BattleResultData.is_last_survive) .. " is_team_result:" .. tostring(BP_STRUCT_BattleResultData.is_team_result))
  if BP_STRUCT_BattleResultData.IsSolo == false then
    if BP_STRUCT_BattleResultData.is_last_survive then
      log(bWriteLog and "BattleResultUI last survive!!!!!")
      BP_EnterSpectateMode = false
    elseif BP_STRUCT_BattleResultData.is_team_result then
      BP_EnterSpectateMode = false
    else
      BP_EnterSpectateMode = true
    end
  else
    BP_STRUCT_BattleResultData.is_last_survive = true
    BP_EnterSpectateMode = false
  end
  local uidList = {}
  result.TeammateList = BattleResultUI.SortTeammateList(result)
  if result.pet_add_exp ~= nil then
    BP_MyPetAddExp = result.pet_add_exp
  end
  local CareerSystem = require("client.slua.logic.career.logic_career")
  if CareerSystem.IsOpen() then
    if CareerSystem.svrChangeData then
      BP_STRUCT_BattleResultData.careerScore = (CareerSystem.svrChangeData.pro_new or 0) - (CareerSystem.svrChangeData.pro_old or 0)
    else
      BP_STRUCT_BattleResultData.careerScore = -1
    end
  else
    BP_STRUCT_BattleResultData.careerScore = -1
  end
  local logic_friend_apply_battle = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply_battle)
  logic_friend_apply_battle:ResetResultAddFriendReq(result.battle_id, result.TeammateList)
  for k, v in pairs(result.TeammateList) do
    if v.Name == BP_myname then
      BP_mystate = v.State
      local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
      logic_player_return.UpdateWarmData(v.Kill, v.surviveTime)
    end
    if DataMgr ~= nil and DataMgr.roleData ~= nil then
      if tonumber(v.UID) ~= tonumber(DataMgr.roleData.uid) then
        table.insert(uidList, v.UID)
      end
    else
      table.insert(uidList, v.UID)
    end
    log(bWriteLog and "BattleResultUI Name " .. v.Name)
    log(bWriteLog and "BattleResultUI Kill " .. v.Kill)
    log(bWriteLog and "BattleResultUI Damage " .. v.DamageAmount)
    v.UID = "" .. v.UID
    log(bWriteLog and "BattleResultUI is solo " .. tostring(BP_STRUCT_BattleResultData.IsSolo))
    if type(v.FinalScore) == "number" then
      if v.FinalScore > 100 then
        v.FinalScore = 100
      end
      v.FinalScore_f = string.format("%.1f", v.FinalScore)
    else
      v.FinalScore_f = 0
    end
    log(bWriteLog and "v.FinalScore_f :" .. type(v.FinalScore_f) .. "value:" .. tostring(v.FinalScore_f))
    if v.NewSurviveScore and type(v.NewSurviveScore) == "number" then
      v.NewSurviveScore_s = string.format("%.1f", v.NewSurviveScore)
    end
    if v.NewAssistScore and type(v.NewAssistScore) == "number" then
      v.NewAssistScore_s = string.format("%.1f", v.NewAssistScore)
    end
    if v.NewEquipScore and type(v.NewEquipScore) == "number" then
      v.NewEquipScore_s = string.format("%.1f", v.NewEquipScore)
    end
    if v.NewBattleScore and type(v.NewBattleScore) == "number" then
      v.NewBattleScore_s = string.format("%.1f", v.NewBattleScore)
    end
    v.NewTitleID = v.new_title_id or 0
    if v.title_id_list == nil then
      v.title_id_list = {}
    end
    v.BP_ARRAY_Title_List = v.title_id_list
    if v.mainWeaponID then
      local weaponItem = CDataTable.GetTableData("Item", v.mainWeaponID)
      if weaponItem then
        v.mainWeaponName = weaponItem.ItemName
        v.mainWeaponWhiteIcon = weaponItem.ItemWhiteIcon
      end
    end
    table.insert(BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList, v)
    local teamItem = {}
    if v.Name ~= nil then
      teamItem.Name = v.Name
      teamItem.UID = v.UID
    end
    table.insert(BattleResult_TeamList_ForReportComplaint, teamItem)
  end
  if 0 < #uidList then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidList, BattleResultUI.ImageCallBack, Enum_PROFILE_REPORT_CFG.BATTLE_RESULT, 0, true)
  else
    local list = {}
    BattleResultUI.ImageCallBack(list)
  end
  Client.OnBattleResult(GameFrontendHUD, BP_STRUCT_BattleResultData)
  BP_ServerTimeSecNow = TimeUtil.GetServerTimeInSec()
  if result.IsKickedFromGame then
    log(bWriteLog and "result.IsKickedFromGame is true !!!!!!")
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(6276)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, content, function()
      print(bWriteLog and "BattleResultUI.OnBattleResult, true kicked from game")
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.ShowLoading(true)
      LobbySystem.ReturnToLobby()
    end, nil)
    return
  end
  if LuaClassObj.GetGameStatus(bp_global) ~= GameStatus.Fighting then
    log(bWriteLog and "result not fighting")
  end
  log(bWriteLog and "battle_result enter")
  if result.team_score_addition or result.gun_parts_drop_addition then
    if result.team_score_addition and result.gun_parts_drop_addition then
      log(bWriteLog and "battle_result" .. tostring(result.team_score_addition) .. tostring(result.gun_parts_drop_addition))
      BP_STRUCT_BattleResultData.new_year_team_str = LocUtil.GetLocalizeResStr(8416)
    elseif result.gun_parts_drop_addition and result.gun_parts_drop_addition == true then
      log(bWriteLog and "battle_result" .. tostring(result.gun_parts_drop_addition))
      BP_STRUCT_BattleResultData.new_year_team_str = LocUtil.GetLocalizeResStr(8413)
    elseif result.team_score_addition and 0 < result.team_score_addition then
      log(bWriteLog and "battle_result" .. tostring(result.team_score_addition))
      BP_STRUCT_BattleResultData.new_year_team_str = LocUtil.GetLocalizeResStr(8414)
    elseif result.team_score_addition and 0 > result.team_score_addition then
      log(bWriteLog and "battle_result" .. tostring(result.team_score_addition))
      BP_STRUCT_BattleResultData.new_year_team_str = LocUtil.GetLocalizeResStr(8415)
    end
  else
    log(bWriteLog and "battle_result no new_year_match_activity")
    BP_STRUCT_BattleResultData.new_year_team_str = ""
  end
  if testResult == false then
    BattleResultUI.UpdateShareBtnState()
  end
  BattleResultUI.HasInitResultPlayerDetailData = false
  if result.rating_protect_type and result.rating_protect_type == "back_user_privilege" then
    BP_STRUCT_BattleResultData.is_player_return_protect = true
    BP_STRUCT_BattleResultData.player_return_protect_times = result.back_user_protect_left or 0
    BP_STRUCT_BattleResultData.player_return_protect_count = result.back_user_protect_count or 0
    if DataMgr and DataMgr.roleData and DataMgr.roleData.back_user_data then
      DataMgr.roleData.back_user_data.seg_protect_times = BP_STRUCT_BattleResultData.player_return_protect_times
    end
  else
    BP_STRUCT_BattleResultData.is_player_return_protect = false
  end
  Client.CrashLog(NetInterface, 4, "Battle", "BattleResultE")
  if result.rating_protect_type and result.rating_protect_type == "rating_protect_mark" then
    BP_STRUCT_BattleResultData.is_rank_protect = true
  else
    BP_STRUCT_BattleResultData.is_rank_protect = false
  end
  if result.rating_protect_type and result.rating_protect_type == "time_card" then
    BP_STRUCT_BattleResultData.is_time_card_protect = true
  else
    BP_STRUCT_BattleResultData.is_time_card_protect = false
  end
  if result.rating_protect_type and result.rating_protect_type == "times_card" then
    BP_STRUCT_BattleResultData.is_times_card_protect = true
  else
    BP_STRUCT_BattleResultData.is_times_card_protect = false
  end
  BattleResultUI.ChallengeScore = result.challenge
  BattleResultUI.WorldCupAddRatingActivity = result.WorldCupAddRatingActivity
  log_tree(bWriteLog and "BattleResultUI ChallengeScore", result.challenge)
  if result.add_season_coin and next(result.add_season_coin) then
    BP_STRUCT_BattleResultData.SeasonCoinInfo = result.add_season_coin
    BP_STRUCT_BattleResultData.seasonGold = result.add_season_coin.add_coin_cnt
  end
  BP_STRUCT_BattleResultData.IsRevivalMode = result.IsRevivalMode
  log(bWriteLog and "BP_STRUCT_BattleResultData.IsRevivalMode = " .. tostring(result.IsRevivalMode))
  log(bWriteLog and "BP_STRUCT_BattleResultData.is_team_result = " .. tostring(BP_STRUCT_BattleResultData.is_team_result))
  if not BP_STRUCT_BattleResultData.is_team_result then
    log(bWriteLog and "reset corps_add_active_type")
    local logic_corps_energy_mission = require("client.slua.logic.corps.logic_corps_energy_mission")
    logic_corps_energy_mission.corps_add_active_type = {}
    logic_corps_energy_mission.corps_active_type = 0
  end
  BattleResultUI.NewBattleScore = {
    real_battle_rank_rating = result.real_battle_rank_rating,
    real_battle_kill_rating = result.real_battle_kill_rating,
    real_battle_win_rating = result.real_battle_win_rating
  }
  BattleResultUI.real_cancel_rating = result.real_cancel_rating
  log(bWriteLog and "real_cancel_rating = " .. tostring(result.real_cancel_rating))
  log(bWriteLog and "real_battle_rank_rating = " .. tostring(result.real_battle_rank_rating))
  log(bWriteLog and "real_battle_kill_rating = " .. tostring(result.real_battle_kill_rating))
  log(bWriteLog and "real_battle_win_rating = " .. tostring(result.real_battle_win_rating))
  BattleResultUI.season_add_score_card_add_rating = result.season_add_score_card_add_rating
  log(bWriteLog and "season_add_score_card_add_rating = " .. tostring(result.season_add_score_card_add_rating))
end
function BattleResultUI.IsCanShowQuickAddFriend(TeammateList)
  local bAllFriend = true
  for k, v in pairs(TeammateList) do
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if LogicFriend.IsMyFriend("" .. v.UID) ~= true and tonumber(DataMgr.roleData.uid) ~= tonumber(v.UID) then
      bAllFriend = false
      break
    end
  end
  return not bAllFriend
end
function EventFeedBackResult()
  log(bWriteLog and "EventFeedBackResult g_game_id:" .. g_game_id .. " BP_FeedBackScore:" .. BP_FeedBackScore)
  local BattleResultHandler = require("client.network.Protocol.BattleResultHandler")
  BattleResultHandler.send_report_battle_feedback(g_game_id, BP_FeedBackScore)
end
function BattleResultUI.OnResultMVPShowEnd()
  local MVPShowEndResumeResult = function()
    log(bWriteLog and "MVPShowEndResumeResult excute")
    LuaClassObj.HandleUIMessage(bp_battleresult, "MVPShowEndResumeResult")
  end
  log(bWriteLog and "BattleResultUI.OnResultMVPShowEnd")
  if BP_IsReceiveResult then
    MVPShowEndResumeResult()
  end
end
function BattleResultUI.CheckShowSingleResult()
  log(bWriteLog and "BattleResultUI.CheckShowSingleResult battle_id" .. BP_STRUCT_BattleResultData.battle_id)
  if BP_STRUCT_BattleResultData.battle_id == 0 then
    ResultToSpectate.canceled = true
    EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_LEAVE_SPECTATING)
    local TimeTicker = require("common.time_ticker")
    TimeTicker.AddTimer(5, function()
      log(bWriteLog and "BattleResultUI.CheckShowSingleResult in timer battle_id" .. BP_STRUCT_BattleResultData.battle_id)
      if BP_STRUCT_BattleResultData.battle_id == 0 then
        BattleResultUI.ShowSingleResult()
      end
    end)
  else
    BattleResultUI.ShowSingleResult()
  end
end
function BattleResultUI.ShowSingleResult()
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  print(bWriteLog and "BattleResultUI.ShowSingleResult", IngameEntry.UseCustomGameResult(), IngameEntry.UseBattleResultSubSystem())
  if IngameEntry.UseCustomGameResult() then
    if IngameEntry.UseBattleResultSubSystem() then
      EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_WATCH_TO_RESULT)
      GameStatus.SetCombatActiveState(false)
    else
      IngameEntry.ShowCustomGameResult()
    end
    return
  end
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_WATCH_TO_RESULT)
end
function BattleResultUI.OnResultCountDownShowEnd()
  log(bWriteLog and "BattleResultUI.OnResultCountDownShowEnd")
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_END)
  if UIManager.UI_Config_InGame.MVPStatueMainRT ~= nil then
    UIManager.CloseUI(UIManager.UI_Config_InGame.MVPStatueMainRT)
  end
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  IngameLikeClientSubSystem:CloseAllLikeUI()
  if BP_IsReceiveResult then
    BattleResultUI.ShowBattleResultUI()
  end
end
function BattleResultUI.ImageCallBack(list)
  BP_ARRAY_TeammateProfile = {}
  for i = 1, #list do
    table.insert(BP_ARRAY_TeammateProfile, {
      uid = list[i].uid,
      picUrl = list[i].picUrl,
      level = list[i].level,
      cur_avatar_box_id = list[i].cur_avatar_box_id
    })
  end
  table.insert(BP_ARRAY_TeammateProfile, {
    uid = DataMgr.roleData.uid,
    picUrl = DataMgr.roleData.headIconUrl,
    level = DataMgr.roleData.level,
    cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
  })
  LuaClassObj.HandleUIMessage(bp_battleresult, "ImageCallBack")
  ResultMVPUI.ImageCallBack(list)
end
function BattleResultUI.ShowLoadingUI()
  log(bWriteLog and "RecordingReplay ShowLoadingUI")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(true)
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_SHOWHIDE_LOADINGUI, true)
end
function BattleResultUI.HideLoadingUI()
  log(bWriteLog and "RecordingReplay HideLoadingUI")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.RefreshLoadPercent(1)
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_SHOWHIDE_LOADINGUI, false)
end
function BattleResultUI.ShowTrainingOverUI()
  log(bWriteLog and "ShowTrainingOver")
  UIManager.ShowUI(UIManager.UI_Config_InGame.ResultTrainingEnd_UIBP)
end
function BattleResultUI.SetIsReportComplaintShow(IsShow)
  log(bWriteLog and "BattleResultUI.SetIsReportComplaintShow" .. tostring(IsShow))
  BP_IsReportComplaintShow = IsShow
end
function BattleResultUI.SetIsDirectShow(IsShow)
  BP_DirectShow = IsShow
  if IsShow then
    log(bWriteLog and "SetIsDirectShow true")
  end
end
function EventBattleResult_BackToLobby()
  log(bWriteLog and "byron EventBattleResult_BackToLobby")
  BattleResult.IgnoreDSError = true
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.HidePanel()
  log(bWriteLog and "Client.EnableIosStuckWork(GameFrontendHUD, false);")
  Client.EnableIosStuckWork(GameFrontendHUD, false)
  BattleResultUI.UseTXTResultData = false
  LobbySystem.ReturnToLobby()
end
function BattleResultUI.EnableTickSwitch()
  BattleResultUI.UpdateShareBtnState()
  log(bWriteLog and "LuaClassObj.HandleDynamicCreation(bp_battleresult) BattleResultUI.EnableTickSwitch")
  LuaClassObj.HandleDynamicCreation(bp_battleresult)
  LuaClassObj.HandleUIMessage(bp_battleresult, "EnableResultsTick")
end
Retry = false
function EventDelayCall()
  Retry = true
  BattleResultUI.OnModePostSwitch(nil, GameStatus.Fighting)
end
function EventClientFreshData()
end
function EventClientExitTraining()
  log(bWriteLog and "EventClientExitTraining")
  BattleResult.IgnoreDSError = true
  NetUtil.StopCheckDSActive()
  local ClientEntryHandler = require("client.network.Protocol.ClientEntryHandler")
  ClientEntryHandler.send_giveup_enter_game()
end
function EventShowResultsOBTitle()
  local ui = UIManager.GetUI(UIManager.UI_Config.ResultsOB_ResultTitle_UIBP)
  UIManager.ShowUI(UIManager.UI_Config.ResultsOB_ResultTitle_UIBP)
end
function GetTeamModeName()
  local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
  return ResultUtil.GetTeamModeName(BP_STRUCT_BattleResultData.battle_type, BP_STRUCT_BattleResultData.sub_mode)
end
function BattleResultUI.GetZoneName()
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  if ZoneSystem == nil then
    return ""
  end
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  return logic_multiple_area:GetDisplayNameByZoneID(ZoneSystem.nChooseZoneID)
end
function BattleResultUI.GetStrategyBtnStatus()
  BP_BattleResultCanShowStrategyBtn = true
  if not LobbySystem.CheckOpen(BP_ENUM_BATTLERESULT_STRATEGYBTN) then
    BP_BattleResultCanShowStrategyBtn = false
  end
end
function BattleResultUI.TestOBResult()
  local battleResultsTestUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultsTestUtil")
  local ob_game_result_room_result, ob_game_result_room_stat = battleResultsTestUtil.GetTestBattleResultPCOB()
  if observe then
    InGameUIManager.HandleDynamicCreation(observe)
  end
  BattleResultUI.ShowOBBattleResult(ob_game_result_room_result, ob_game_result_room_stat)
end
function BattleResultUI.TestTPlanResult(myUID, bisteam)
  local battleResultsTestUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultsTestUtil")
  local data = battleResultsTestUtil.GetTestBattleResultTPlan(myUID)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeName = GameMainConfig.GetModType()
  if ModeName and ModeName ~= "" then
    local TableUtil = require("common.table_util")
    local tModExtraData = battleResultsTestUtil.GetModExtraData(ModeName)
    data = TableUtil.MergeTable(data, tModExtraData or {})
  end
  BattleResult.on_game_result(data)
end
function BattleResultUI.TestTPlanOBResult()
  local battleResultsTestUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultsTestUtil")
  local ob_game_result_room_result = battleResultsTestUtil.GetTestBattleResultTPlanPCOB()
  if observe then
    InGameUIManager.HandleDynamicCreation(observe)
  end
  BattleResultUI.ShowOBBattleResult(ob_game_result_room_result)
end
function BattleResultUI.ShowOBBattleResult(ob_battle_result, room_stat, customize_result)
  log(bWriteLog and "ShowOBBattleResult")
  BattleResult.IgnoreDSError = true
  ResetResultMonitor()
  NetUtil.BBattleResultRecieved = true
  if ob_battle_result ~= nil then
    log_tree("ob_battle_result", ob_battle_result)
    local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
    if BattleResultSubSystem then
      InGameUIManager.HandleUIMessage(observe, "Hide")
      BattleResultSubSystem:OnOBBattleResult(ob_battle_result, room_stat, customize_result)
    else
      log(bWriteLog and "BattleResultSubSystem is nil")
    end
  end
end
function BattleResultUI.OpenSendGiftView(nFriendUID, audioRoot, giftSource, RoleInfoPopularitySystem)
  print(bWriteLog and "BattleResultUI.OpenSendGiftView")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsFITVersion() and PufferManager.ShowDownloadTips(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.SocialLobby
  }) then
    return
  end
  RoleInfoPopularitySystem.enter(nFriendUID)
  if UIManager then
    log(bWriteLog and "open roleinfo_send_gift")
    local forbidGiftMap = {
      [11] = true,
      [667] = true
    }
    UIManager.ShowUI(UIManager.UI_Config.roleinfo_send_gift, giftSource, forbidGiftMap, BattleResultUI.battle_id, nFriendUID)
  end
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click)
end
BattleResultUI.mSendGiftFriendName = {}
function BattleResultUI.SendGifts(nFriendUID, friendName)
  log(bWriteLog and "BattleResultUI.SendGifts  " .. nFriendUID)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  BattleResultUI.mSendGiftFriendName[nFriendUID] = friendName
  BattleResultUI.OpenSendGiftView(nFriendUID, nil, RoleInfoPopularitySystem.GiftSourceType.BattleOB, RoleInfoPopularitySystem)
end
function BattleResultUI.GetTeammaterByID(uid)
  for index = 1, 4 do
    if BP_STRUCT_BattleResultData ~= nil and BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList ~= nil and BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[index] ~= nil then
      local player_id = BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[index].UID
      if tostring(player_id) == tostring(uid) then
        return BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[index]
      end
    end
  end
  return nil
end
function BattleResultUI.CheckIsOBMsg(eventType, eventID, info)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  if RoleInfoPopularitySystem.GiftSourceType.BattleOB == info.gift_source then
    local teamMater = BattleResultUI.GetTeammaterByID(info.uid)
    if teamMater then
      WatchGameUI:HandleSendGiftNotify(info.gift_type, info.gift_count, teamMater.Name)
    elseif BattleResultUI.mSendGiftFriendName[info.uid] then
      WatchGameUI:HandleSendGiftNotify(info.gift_type, info.gift_count, BattleResultUI.mSendGiftFriendName[info.uid])
    end
  end
end
function EventReviveStateReturnToLobbyConfirm()
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("7648"), BattleResultUI.ReviveStateReturnToLobbyConfirm_YES, BattleResultUI.ReviveStateReturnToLobbyConfirm_NO)
end
function BattleResultUI.ReviveStateReturnToLobbyConfirm_YES()
  log(bWriteLog and "BattleResultUI.ReviveStateReturnToLobbyConfirm_YES")
  ResultToSpectate.canceled = true
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_LEAVE_SPECTATING)
  WatchGameUI:HandleSpectateGiveUpRevive()
end
function BattleResultUI.ReviveStateReturnToLobbyConfirm_NO()
  log(bWriteLog and "BattleResultUI.ReviveStateReturnToLobbyConfirm_NO")
end
function BattleResultUI.HandleReverseReponse(eventType, eventID)
  if not BattleResult.ShowingExitWatchGame then
    WatchGameUI:HandleReverseResponse()
  end
end
BattleResultUI.BattleResultPlayerDetailData = nil
BattleResultUI.HasInitResultPlayerDetailData = false
function EventBattleResult_OpenDetailView()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  log(bWriteLog and "byron EventBattleResult_OpenDetailView")
  local util = require("client.slua_ui_framework.util")
  util.StartProfile("HasInitResultPlayerDetailData")
  if UIManager then
    log(bWriteLog and "EventBattleResult_OpenDetailView")
    util.StartProfile("BattleResultUI.BattleResultPlayerDetailData:InitData")
    if BattleResultUI.HasInitResultPlayerDetailData == false then
      BattleResultUI.BattleResultPlayerDetailData = require("GameLua.Mod.BaseMod.Client.BattleResult.CResultPlayerDetailData")
      BattleResultUI.BattleResultPlayerDetailData:InitData(BP_STRUCT_BattleResultData, BattleResultUI.GetZoneName(), GetTeamModeName(), BP_STRUCT_BattleResultData.IsSolo, false)
      BattleResultUI.HasInitResultPlayerDetailData = true
    end
    util.StopProfile("BattleResultUI.BattleResultPlayerDetailData:InitData")
    util.StartProfile("BattleResultUI.BattleResultPlayerDetailData ShowUI")
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SHRINK_INVITE_GAME_TIP)
    gem_report_utils.ReportBtnClickEventInBattle(gem_report_utils.BattleResult_PlayerDetailClick)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.BattleResult_PlayerDetailClick)
    UIManager.ShowUI(UIManager.UI_Config.result_player_detail_view, BattleResultUI.BattleResultPlayerDetailData)
    util.StopProfile("BattleResultUI.BattleResultPlayerDetailData ShowUI")
    local common_save_game = require("client.logic.LogicPlayerPrefs.common_save_game")
    local data = common_save_game.GetSaveData(common_save_game.Configs.Battle_Result_Detail_Tips)
    if data == nil or data.hasClickTips == nil or data.hasClickTips == false then
      data = data or {}
      data.hasClickTips = true
      common_save_game.SaveData(common_save_game.Configs.Battle_Result_Detail_Tips, data)
    end
  end
  util.StopProfile("HasInitResultPlayerDetailData")
end
function BattleResultUI.HandleDetailViewClose()
  LuaClassObj.HandleUIMessageNoFetch(bp_battleresult, "UIMSG_HandleCloseDetailView")
end
function BattleResultUI.OnExitWatchGame(bIsDontShowWatchFriendBattleEndTips)
  BattleResult.IgnoreDSError = true
  BattleResult.ShowingExitWatchGame = true
  if GameStatus.GetGameStatus(bp_global) == GameStatus.Fighting then
    log(bWriteLog and "BattleResultUI.OnExitWatchGame call WatchGameUI:ExitWatchGame")
    WatchGameUI:ExitWatchGame(bIsDontShowWatchFriendBattleEndTips)
  end
end
function BattleResultUI.ExitWatchGame()
  FuncUtil.FormatLog("BattleResultUI.ExitWatchGame")
  BattleResultUI._PrivateExitWatchGame(false)
end
function BattleResultUI._PrivateExitWatchGame(bIsDontShowWatchFriendBattleEndTips)
  local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
  if not BattleResult.ShowingExitWatchGame then
    BP_WatchExitReason = "game_over"
    FuncUtil.FormatLog("call BattleResultUI.OnExitWatchGame, %s", bIsDontShowWatchFriendBattleEndTips)
    BattleResultUI.OnExitWatchGame(bIsDontShowWatchFriendBattleEndTips)
    LogicLobbyWatching.leave_battle_watch()
  end
end
function BattleResultUI.ExitWatchGameWithoutShowingWatchFriendBattleEndTips()
  FuncUtil.FormatLog("BattleResultUI.ExitWatchGameWithoutShowingWatchFriendBattleEndTips")
  BattleResultUI._PrivateExitWatchGame(true)
end
function BattleResultUI.ClientInterruptGame()
  log(bWriteLog and "BattleResultUI.ClientInterruptGame")
  local onClickCallBack = function()
    local ClientEntryHandler = require("client.network.Protocol.ClientEntryHandler")
    ClientEntryHandler.send_giveup_enter_game()
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.ShowLoading(true)
    BattleResultUI.UseTXTResultData = false
    LobbySystem.ReturnToLobby()
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(6925), onClickCallBack, onClickCallBack, nil, nil, nil, nil, nil, 3)
end
function BattleResultUI.OnGameOver(game_id)
  log(bWriteLog and "BattleResultUI.OnGameOver")
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_GAMEOVER_TO_RESULT)
end
function BattleResultUI.EnterViewEnemy()
  BattleResult.IgnoreDSError = false
end
function EventComplaintClickReplay()
  Complaint_IsRePlayClick = true
end
return BattleResultUI