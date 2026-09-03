local BattleResultShowAvatarLogic = {}
local UGameplayStatics = import("GameplayStatics")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
local BattleResultHandler = require("client.network.Protocol.BattleResultHandler")
function BattleResultShowAvatarLogic:OnInit()
  print(bWriteLog and "BattleResultShowAvatarLogic:OnInit")
  self.ResultData = {
    BPRecordOneMoreLeaderUin = 0,
    USE_TEST = self.USE_TEST
  }
  self.GiftNotifyCacheMap = {}
  self.bHasViewReplay = false
  self.FriendGuideTipsType = -1
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_SHOW_AVATAR_CLOSE, self.OnShowAvatarClose, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_SEND_GIFT_NOTIFY_RSP, self.SendGiftNotify, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_INVITE_GAME, self.OnInviteGameRsp, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INNERADD_NOTIFY, self.OnAddFriendNofity, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_ENTER_WONDERFUL, self.OnEnterWonderful, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_ENTER_BATTLE_REPLAY, self.OnEnterBattleReplay, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_SHOW_FRIEND_GUIDE_TIPS, self.OnFriendGuideTips, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_SEND_UPVOTE, function(_, _, uid, giftSource)
    local nUID = tonumber(uid)
    if nUID ~= nil then
      local BattleResultRanking_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.BattleResultRanking_UIBP)
      if UIManager.IsUIShow(UIManager.UI_Config_InGame.BattleResultRanking_UIBP) and BattleResultRanking_UIBP.OnSendLike then
        BattleResultRanking_UIBP:OnSendLike()
      end
    end
  end)
  BattleResultUI.AlreadyUpvotedUID = {}
  BattleResultUI.UpvoteNotifyMap = {}
  BattleResultUI.AddFriendMap = {}
  self.SendGiftText = {}
  self.UpvoteCount = {}
  self.MyUpvote = {}
  self.UpvoteMe = {}
  self.UpvoteEachOther = {}
  self.TriggeredFeedbackData = {score = -1}
  self.PermanentFeedbackData = {
    feedback = {},
    suggest = ""
  }
end
function BattleResultShowAvatarLogic:OnRelease()
  print(bWriteLog and "BattleResultShowAvatarLogic:OnRelease")
  self.ResultData = {BPRecordOneMoreLeaderUin = 0}
  self.GiftNotifyCacheMap = {}
  self.bHasViewReplay = false
  self.SendGiftText = {}
  self.UpvoteCount = {}
  self.MyUpvote = {}
  self.UpvoteMe = {}
  self.UpvoteEachOther = {}
  if UIManager.UI_Config.ResultsAddFriendsPopUp then
    UIManager.CloseUI(UIManager.UI_Config.ResultsAddFriendsPopUp)
  end
  if UIManager.UI_Config_InGame.BattleResultRanking_UIBP then
    UIManager.CloseUI(UIManager.UI_Config_InGame.BattleResultRanking_UIBP)
  end
end
function BattleResultShowAvatarLogic:OnBattleResult(result)
  log_tree(bWriteLog and "BattleResultShowAvatarLogic:OnBattleResult result:", result)
  log(bWriteLog and "BattleResultShowAvatarLogic:OnBattleResult sub_mode:" .. tostring(result.sub_mode) .. " battle_owner:" .. tostring(result.battle_owner))
  local ResultData = self.ResultData
  ResultData.TotalTeamCount = result.TotalTeamCount
  ResultData.peakgame_team_rank = result.peakgame_team_rank
  local commonData = self:GetBattleResultData()
  ResultData.BP_myname = commonData.BP_myname
  ResultData.BP_EnterSpectateMode = commonData.BP_EnterSpectateMode
  ResultData.BP_TeamModeName = commonData.BP_TeamModeName
  ResultData.BP_Terminator = commonData.BP_Terminator
  ResultData.battle_id = result.battle_id
  ResultData.sub_mode = result.sub_mode
  ResultData.battle_type = result.battle_type
  ResultData.battle_owner = result.battle_owner
  if result.rating then
    ResultData.rating_new_segment = result.rating.new_segment
  end
  ResultData.Reason = result.Reason
  ResultData.IsSolo = result.IsSolo
  ResultData.is_team_result = result.is_team_result
  ResultData.team_rank = result.team_rank
  ResultData.person_rank = result.person_rank
  ResultData.TotalPlayerCount = result.TotalPlayerCount
  ResultData.score_version = result.score_version or 1
  ResultData.final_level = result.final_level
  ResultData.zone_id = result.zone_id
  ResultData.char_id = result.char_id or 0
  ResultData.char_add_exp = result.char_add_exp or 0
  ResultData.BP_STRUCT_CHAR_EXP_DETAIL = {
    level = result.char_level or 0,
    max_level = result.char_max_level or 0,
    daily_exp = result.char_daily_exp or 0,
    daily_exp_max = result.char_daily_exp_max or 0
  }
  ResultData.pet_add_exp = result.pet_add_exp or 0
  ResultData.add_veteran_exp = result.mentor_exp or 0
  ResultData.BP_STRUCT_RADAR = result.radar or {}
  if result.radar ~= nil then
    ResultData.BP_STRUCT_RADAR.SurviveScore_f = string.format("%.1f", result.radar.SurviveScore / 100)
    ResultData.BP_STRUCT_RADAR.HurtScore_f = string.format("%.1f", result.radar.HurtScore / 100)
    ResultData.BP_STRUCT_RADAR.SupportScore_f = string.format("%.1f", result.radar.SupportScore / 100)
    ResultData.BP_STRUCT_RADAR.SupplyScore_f = string.format("%.1f", result.radar.SupplyScore / 100)
    ResultData.BP_STRUCT_RADAR.KillScore_f = string.format("%.1f", result.radar.KillScore / 100)
    ResultData.BP_STRUCT_RADAR.SurviveScore_s = string.format("%.1f", result.radar.SurviveScore)
    ResultData.BP_STRUCT_RADAR.HurtScore_s = string.format("%.1f", result.radar.HurtScore)
    ResultData.BP_STRUCT_RADAR.SupportScore_s = string.format("%.1f", result.radar.SupportScore)
    ResultData.BP_STRUCT_RADAR.SupplyScore_s = string.format("%.1f", result.radar.SupplyScore)
    ResultData.BP_STRUCT_RADAR.KillScore_s = string.format("%.1f", result.radar.KillScore)
    if result.radar.MonsterKillScore ~= nil then
      ResultData.BP_STRUCT_RADAR.MonsterKillScore_f = string.format("%.1f", result.radar.MonsterKillScore / 100)
      ResultData.BP_STRUCT_RADAR.MonsterKillScore_s = string.format("%.1f", result.radar.MonsterKillScore)
    end
    if result.radar.MonsterDamageScore ~= nil then
      ResultData.BP_STRUCT_RADAR.MonsterDamageScore_f = string.format("%.1f", result.radar.MonsterDamageScore / 100)
      ResultData.BP_STRUCT_RADAR.MonsterDamageScore_s = string.format("%.1f", result.radar.MonsterDamageScore)
    end
    if result.radar.MonsterHeadShotScore ~= nil then
      ResultData.BP_STRUCT_RADAR.MonsterHeadShotScore_f = string.format("%.1f", result.radar.MonsterHeadShotScore / 100)
      ResultData.BP_STRUCT_RADAR.MonsterHeadShotScore_s = string.format("%.1f", result.radar.MonsterHeadShotScore)
    end
  end
  ResultData.league_seq = result.league_seq or 0
  ResultData.is_pug_result = result.is_pug_result or false
  ResultData.tournament_id = result.tournament_id or 0
  ResultData.carteam_id = result.carteam_id or 0
  ResultData.rank_score = result.rank_score or 0
  ResultData.kill_score = result.kill_score or 0
  ResultData.is_anchor_ob = result.is_anchor_ob or false
  ResultData.One_More_Game_Team_ID = result.common_omb_team_id or 0
  local singleAddExp = ResultData.add_exp or 0
  local singleAddGold = ResultData.add_gold or 0
  local singleGoldDetail = ResultData.BP_STRUCT_GOLD_DETAIL or nil
  local singleExpDetail = ResultData.BP_STRUCT_EXP_DETAIL or {}
  ResultData.get_gold_today = result.get_gold_today
  print(bWriteLog and "BattleResultShowAvatarLogic:OnBattleResult add_exp:%s result.add_gold:%s", result.add_exp, result.add_gold)
  if result.add_exp and 0 < result.add_exp then
    ResultData.add_exp = result.add_exp
    ResultData.BP_STRUCT_EXP_DETAIL = {}
    if result.exp_detail ~= nil then
      ResultData.BP_STRUCT_EXP_DETAIL.survive_exp = result.exp_detail.survive_exp
      ResultData.BP_STRUCT_EXP_DETAIL.kill_exp = result.exp_detail.kill_exp
      ResultData.BP_STRUCT_EXP_DETAIL.first_exp = result.exp_detail.first_exp
      ResultData.BP_STRUCT_EXP_DETAIL.top10_exp = result.exp_detail.top10_exp
      ResultData.BP_STRUCT_EXP_DETAIL.watch_exp = result.exp_detail.watch_exp
      ResultData.BP_STRUCT_EXP_DETAIL.team_add = (result.exp_detail.team_add or 0) * 100
      ResultData.BP_STRUCT_EXP_DETAIL.plat_add = (result.exp_detail.plat_add or 0) * 100
      ResultData.BP_STRUCT_EXP_DETAIL.qq_super_vip_add = (result.exp_detail.qq_super_vip_add or 0) * 100
      ResultData.BP_STRUCT_EXP_DETAIL.exp_card_add = (result.exp_detail.exp_card_add or 0) * 100
      ResultData.BP_STRUCT_EXP_DETAIL.famous_master_add = (result.exp_detail.famous_master_add or 0) * 100
      ResultData.BP_STRUCT_EXP_DETAIL.sm_add = (result.exp_detail.sm_add or 0) * 100
      ResultData.BP_STRUCT_EXP_DETAIL.clan_add = (result.exp_detail.clan_add or 0) * 100
      ResultData.BP_STRUCT_EXP_DETAIL.limitact_double_exp_rate = 0
      if result.exp_detail.limitact_double_exp_rate ~= nil then
        ResultData.BP_STRUCT_EXP_DETAIL.limitact_double_exp_rate = (result.exp_detail.limitact_double_exp_rate or 0) * 100
      end
      ResultData.BP_STRUCT_EXP_DETAIL.kill_monster_exp = result.exp_detail.kill_monster_exp or 0
      ResultData.BP_STRUCT_EXP_DETAIL.survived_exp = result.exp_detail.survived_exp or 0
    end
  else
    ResultData.add_exp = singleAddExp
    ResultData.BP_STRUCT_EXP_DETAIL = singleExpDetail
  end
  if result.add_gold and 0 < result.add_gold or singleGoldDetail == nil then
    ResultData.add_gold = result.add_gold or 0
    ResultData.BP_STRUCT_GOLD_DETAIL = {}
    if result.gold_detail ~= nil then
      ResultData.BP_STRUCT_GOLD_DETAIL.up_limit = result.gold_detail.up_limit
      ResultData.BP_STRUCT_GOLD_DETAIL.rank_gold = result.gold_detail.rank_gold
      ResultData.BP_STRUCT_GOLD_DETAIL.kill_gold = result.gold_detail.kill_gold
      ResultData.BP_STRUCT_GOLD_DETAIL.hurt_gold = result.gold_detail.hurt_gold
      ResultData.BP_STRUCT_GOLD_DETAIL.watch_gold = result.gold_detail.watch_gold
      ResultData.BP_STRUCT_GOLD_DETAIL.team_add = result.gold_detail.team_add * 100
      ResultData.BP_STRUCT_GOLD_DETAIL.famous_master_add = (result.gold_detail.famous_master_add or 0) * 100
      ResultData.BP_STRUCT_GOLD_DETAIL.sm_add = (result.gold_detail.sm_add or 0) * 100
      ResultData.BP_STRUCT_GOLD_DETAIL.gold_card_add = (result.gold_detail.gold_card_add or 0) * 100
      ResultData.BP_STRUCT_GOLD_DETAIL.limitact_double_gold_rate = 0
      if result.gold_detail.limitact_double_gold_rate ~= nil then
        ResultData.BP_STRUCT_GOLD_DETAIL.limitact_double_gold_rate = (result.gold_detail.limitact_double_gold_rate or 0) * 100
      end
      ResultData.BP_STRUCT_GOLD_DETAIL.survive_gold = result.gold_detail.survive_gold or 0
      ResultData.BP_STRUCT_GOLD_DETAIL.survived_gold = result.gold_detail.survived_gold or 0
      ResultData.BP_STRUCT_GOLD_DETAIL.kill_monster_gold = result.gold_detail.kill_monster_gold or 0
    end
  else
    ResultData.add_gold = singleAddGold
    ResultData.BP_STRUCT_GOLD_DETAIL = singleGoldDetail
  end
  result.TeammateList = self:SortTeammateList(result)
  self:InitRoleInfoList(result)
  local logic_friend_apply_battle = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply_battle)
  logic_friend_apply_battle:ResetResultAddFriendReq(result.battle_id, result.TeammateList)
  ResultData.TeammateProfile = {}
  self:InitTeammateList(result)
  ResultData.SeasonCoinInfo = {}
  if result.add_season_coin and next(result.add_season_coin) then
    ResultData.SeasonCoinInfo = result.add_season_coin
  end
  ResultData.BattleResultNeedShowAd = false
  ResultData.EvaluationTipsID = result.game_evaluation_id and result.game_evaluation_id or ResultData.EvaluationTipsID
  print(bWriteLog and "BattleResultShowAvatarLogic:OnBattleResult", result.game_evaluation_id, ResultData.EvaluationTipsID)
  if result.push_ad ~= nil and result.push_ad == true then
    print(bWriteLog and "BattleResultShowAvatarLogic:OnBattleResult push_ad:" .. tostring(result.push_ad))
    ResultData.BattleResultNeedShowAd = true
  end
  local CareerSystem = require("client.slua.logic.career.logic_career")
  if CareerSystem.IsOpen() then
    if CareerSystem.svrChangeData then
      ResultData.careerScore = (CareerSystem.svrChangeData.pro_new or 0) - (CareerSystem.svrChangeData.pro_old or 0)
    else
      ResultData.careerScore = -1
    end
  else
    ResultData.careerScore = -1
  end
  ResultData.WeaponDamageRecordList = result.WeaponDamageRecordList
  ResultData.GrenadeDamageRecord = result.GrenadeDamageRecord
  ResultData.KniveDamageRecord = result.KniveDamageRecord
  ResultData.global_stat_data = result.global_stat_data
  ResultData.rating = result.rating
  ResultData.NormalItemNum = result.NormalItemNum
  ResultData.SeniorItemNum = result.SeniorItemNum
  ResultData.IsRevivalMode = result.IsRevivalMode
  if result.is_world_cup_battle_id ~= nil then
    ResultData.is_world_cup_battle_id = result.is_world_cup_battle_id
  end
  if type(result.act_personal_exp_times) == "number" and 0 < result.act_personal_exp_times then
    log(bWriteLog and "BattleResultShowAvatarLogic:OnBattleResult act_personal_exp_times = " .. tostring(result.act_personal_exp_times))
    ResultData.act_personal_exp_times = result.act_personal_exp_times
  end
  ResultData.video_plan_id = result.video_plan_id
  log(bWriteLog and "BattleResultShowAvatarLogic:OnBattleResult video_plan_id = " .. tostring(result.video_plan_id))
  local ResultsRankingLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ResultsRankingLogic")
  ResultsRankingLogic:Init(result.sub_mode)
  ResultData.promotion_result_info = result.promotion_result_info
  ResultData.promotion_layer = result.promotion_layer
  ResultData.flash_squad_rapport_changes = result.flash_squad_rapport_changes
end
function BattleResultShowAvatarLogic:GetRecommendGuideData(planId)
  log(bWriteLog and "BattleResultShowAvatarLogic:GetRecommendGuideData planId = " .. tostring(planId))
  if planId == nil then
    return nil
  end
  local guidePlan = CDataTable.GetTableData("ResultRecommendedPlan", tonumber(planId))
  if guidePlan == nil then
    log(bWriteLog and "BattleResultShowAvatarLogic:GetRecommendGuideData guidePlan is nil")
    return nil
  end
  local urlID = guidePlan.URLID
  local titleID = guidePlan.TitleID
  local contentID = guidePlan.ContentID
  local picCDN = guidePlan.PicCDN
  log(bWriteLog and "BattleResultShowAvatarLogic:GetRecommendGuideData urlID = " .. tostring(urlID) .. " TitleID = " .. tostring(titleID) .. " ContentID = " .. tostring(contentID) .. " picCDN = " .. tostring(picCDN))
  local VideoUrlConfig = CDataTable.GetTableByFilter("VideoMap", "ID", urlID)
  local url
  for _, value in pairs(VideoUrlConfig) do
    if value.VideoUrl then
      url = value.VideoUrl
      break
    end
  end
  if url == nil or url == "" then
    log(bWriteLog and "BattleResultShowAvatarLogic:GetRecommendGuideData url is nil")
    return nil
  end
  return url, picCDN, LocUtil.GetLocalizeResStr(titleID), LocUtil.GetLocalizeResStr(contentID)
end
function BattleResultShowAvatarLogic:OnSwitchCheck()
  return true
end
function BattleResultShowAvatarLogic:OnResultProcessStart()
  print(bWriteLog and "BattleResultShowAvatarLogic:OnResultProcessStart")
  local CommonUtility = require("common.utility")
  local callOb, curDataTable = xpcall(self.OnNetShutDown, CommonUtility.ErrorMessageHandler, self)
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) then
    if PlayerController.NotifyIsInResultView then
      PlayerController:NotifyIsInResultView(true)
    end
    PlayerController.bPauseUpdateStreamingState = false
  end
  if UIManager and UIManager.ShowUI(UIManager.UI_Config_InGame.BattleResultRanking_UIBP, self.ResultData) then
    print(bWriteLog and "BattleResultShowAvatarLogic:OnResultProcessStart Show Suc")
    self:ShowTeammateAddGuideTips()
    if WatchGameUI then
      WatchGameUI:HideSpectatingUI()
    end
    print(bWriteLog and "BattleResultShowAvatarLogic:OnResultProcessStart EvaluationTipsID", self.ResultData.EvaluationTipsID)
    if self.ResultData.EvaluationTipsID then
      local TriggerBasedQuestionnaireConfig = CDataTable.GetTableData("TriggerBasedQuestionnaire", self.ResultData.EvaluationTipsID)
      print(bWriteLog and "BattleResultShowAvatarLogic:OnResultProcessStart TriggerBasedQuestionnaireConfig", TriggerBasedQuestionnaireConfig)
      if TriggerBasedQuestionnaireConfig then
        UIManager.ShowUI(UIManager.UI_Config_InGame.BattleResultFeedbackTipsUI, TriggerBasedQuestionnaireConfig)
      end
    end
    return true
  end
  return false
end
function BattleResultShowAvatarLogic:OnResultProcessEnd()
  print(bWriteLog and "BattleResultShowAvatarLogic:OnResultProcessEnd")
  if UIManager.UI_Config.BattleResultFeedbackTipsUI then
    UIManager.CloseUI(UIManager.UI_Config.BattleResultFeedbackTipsUI)
  end
  if UIManager.UI_Config.BattleResultNewFeedbackUI then
    UIManager.CloseUI(UIManager.UI_Config.BattleResultNewFeedbackUI)
  end
end
function BattleResultShowAvatarLogic:SortTeammateList(result)
  local teammateList = result.TeammateList
  if result.ranklist == nil or #result.ranklist ~= #result.TeammateList then
    return teammateList
  end
  local outputList = {}
  local swapObject = function(obj1, obj2)
    return obj2, obj1
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.GetPlayerCharacterSafety then
    return teammateList
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return teammateList
  end
  local PlayerState = PlayerCharacter:GetPlayerStateSafety()
  if not slua.isValid(PlayerState) then
    return teammateList
  end
  local TeammatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, false)
  if TeammatePlayerState then
    local UID2Index = {}
    for k, Teammatestate in pairs(TeammatePlayerState) do
      if Teammatestate then
        UID2Index[Teammatestate.uid] = k
      end
    end
    local canSort = true
    for k, v in pairs(teammateList) do
      if not UID2Index[v.UID] then
        canSort = false
      end
    end
    if canSort then
      for k, v in pairs(teammateList) do
        local idx = UID2Index[v.UID]
        v.sortIdx = idx
      end
      table.sort(teammateList, function(a, b)
        return a.sortIdx < b.sortIdx
      end)
    end
  end
  outputList = teammateList
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
  end
  if 4 <= #teammateList then
    outputList[4].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseCrouch)
    outputList[3].resultAvatarPose = outputList[4].resultAvatarPose
    outputList[2].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, outputList[3].resultAvatarPose)
    outputList[1].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, outputList[2].resultAvatarPose)
    for i = 5, #teammateList do
      outputList[i].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseCrouch)
    end
  end
  return outputList
end
function BattleResultShowAvatarLogic:InitRoleInfoList(result)
  local list = result.TeammateList
  print(bWriteLog and "BattleResultShowAvatarLogic:InitRoleInfoList", #list)
  local TeammateRoleInfos = {}
  for i = 1, #list do
    local rolewear = {}
    local wear_ext = list[i].wear_ext or {}
    for k, v in pairs(wear_ext) do
      if ResultUtil.CanApplyAvatarShowType(k) then
        table.insert(rolewear, AvatarData.ConvertToAvatarCustom(v))
      end
    end
    local pet_id = 0
    local pet_level = 0
    local pet_avatar_id = 0
    if list[i].pet_id ~= nil and list[i].pet_id ~= -1 then
      pet_id = list[i].pet_id
    end
    if list[i].pet_level ~= nil then
      pet_level = list[i].pet_level
    end
    if list[i].pet_avatar_id ~= nil then
      pet_avatar_id = list[i].pet_avatar_id
    end
    table.insert(TeammateRoleInfos, {
      uid = list[i].UID,
      sex = list[i].gamegender,
      headId = wear_ext[9] and wear_ext[9][1] or 0,
      index = i - 1,
      weaponId = wear_ext[13] and wear_ext[13][1] or 0,
      weaponSkinId = wear_ext[14] and wear_ext[14][1] or 0,
      weaponPendantID = wear_ext[14] and wear_ext[14][6] and wear_ext[14][6][1] or 0,
      weaponSkinDIYPlanId = wear_ext[14] and wear_ext[14][4] or 0,
      secondWeaponId = wear_ext[121] and wear_ext[121][1] or 0,
      secondWeaponSkinId = wear_ext[122] and wear_ext[122][1] or 0,
      secondWeaponSkinDIYPlanId = wear_ext[122] and wear_ext[122][4] or 0,
      secondWeaponPendantID = wear_ext[122] and wear_ext[122][6] and wear_ext[122][6][1] or 0,
      playerName = list[i].Name,
      resultAvatarPose = list[i].resultAvatarPose or 0,
      PetId = pet_id,
      PetLevel = pet_level,
      PetAvatarID = pet_avatar_id,
      BP_ARRAY_AvatarList = rolewear,
      AvatarEmoteID = list[i].AvatarEmoteID,
      clothSchemeList = ResultUtil:GetClothSchemeList(result, list[i].UID)
    })
  end
  log_tree("TeammateRoleInfos ", TeammateRoleInfos)
  self.ResultData.end
function BattleResultShowAvatarLogic:InitTeammateList(result)
  local teammateList = {}
  local uidList = {}
  for k, v in pairs(result.TeammateList) do
    if DataMgr ~= nil and DataMgr.roleData ~= nil then
      if tonumber(v.UID) ~= tonumber(DataMgr.roleData.uid) then
        table.insert(uidList, v.UID)
      end
    else
      table.insert(uidList, v.UID)
    end
    log(bWriteLog and "BattleResultShowAvatarLogic Name " .. v.Name)
    log(bWriteLog and "BattleResultShowAvatarLogic Kill " .. v.Kill)
    log(bWriteLog and "BattleResultShowAvatarLogic Damage " .. v.DamageAmount)
    v.UID = "" .. v.UID
    local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
    logic_player_return.UpdateWarmData(v.Kill, v.surviveTime)
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
      if 100 < v.NewSurviveScore then
        v.NewSurviveScore = 100
      end
      v.NewSurviveScore_s = string.format("%.1f", v.NewSurviveScore)
    end
    if v.NewAssistScore and type(v.NewAssistScore) == "number" then
      if 100 < v.NewAssistScore then
        v.NewAssistScore = 100
      end
      v.NewAssistScore_s = string.format("%.1f", v.NewAssistScore)
    end
    if v.NewEquipScore and type(v.NewEquipScore) == "number" then
      if 100 < v.NewEquipScore then
        v.NewEquipScore = 100
      end
      v.NewEquipScore_s = string.format("%.1f", v.NewEquipScore)
    end
    if v.NewBattleScore and type(v.NewBattleScore) == "number" then
      if 100 < v.NewBattleScore then
        v.NewBattleScore = 100
      end
      v.NewBattleScore_s = string.format("%.1f", v.NewBattleScore)
    end
    v.NewTitleID = v.new_title_id or 0
    if v.title_id_list == nil then
      v.title_id_list = {}
    end
    if v.pve_total_score == nil then
      v.pve_total_score = 0
    end
    v.BP_ARRAY_Title_List = v.title_id_list
    if v.mainWeaponID then
      local weaponItem = CDataTable.GetTableData("Item", v.mainWeaponID)
      if weaponItem then
        v.mainWeaponName = weaponItem.ItemName
        v.mainWeaponWhiteIcon = weaponItem.ItemWhiteIcon
      end
    end
    v.GiftNotifyMap = {}
    table.insert(teammateList, v)
  end
  if 0 < #uidList then
    print(bWriteLog and "BattleResultShowAvatarLogic:GetProfileListByIntTag")
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidList, function(list)
      self:OnImageCallBack(list)
    end, Enum_PROFILE_REPORT_CFG.BATTLE_RESULT, 0, true)
  else
    self:OnImageCallBack({})
  end
  self.ResultData.TeammateList = teammateList
  self:HandleTeammateListFavorInfo()
  local gift_sorted_list = self:SortGiftRecord(self.GiftNotifyCacheMap)
  for _, value in pairs(gift_sorted_list) do
    self:HandleBattleBriefPanelNotifyRsp(value.sender, value.reciver, value.giftType, value.gift_count)
  end
  self.GiftNotifyCacheMap = {}
end
function BattleResultShowAvatarLogic:SortGiftRecord(gift_record_map)
  if not gift_record_map or not next(gift_record_map) then
    return {}
  end
  local PopularityGift = CDataTable.GetTable("PopularityGift")
  local sorted_gift_list = {}
  for _, gift_record in pairs(gift_record_map) do
    local giftType = gift_record.giftType or gift_record.gift_type
    local gift_cfg = PopularityGift[giftType]
    if gift_cfg then
      gift_record.price = gift_cfg.Price or 0
      table.insert(sorted_gift_list, gift_record)
    else
      log(bWriteLog and "[BattleResultShowAvatarLogic] invalid gift cfg: " .. tostring(giftType))
    end
  end
  table.sort(sorted_gift_list, function(gift1, gift2)
    return gift1.price < gift2.price
  end)
  return sorted_gift_list
end
function BattleResultShowAvatarLogic:OnImageCallBack(list)
  print(bWriteLog and "BattleResultShowAvatarLogic:OnImageCallBack")
  log_tree("list:", list)
  if self.ResultData.TeammateProfile ~= nil then
    for i = 1, #list do
      table.insert(self.ResultData.TeammateProfile, {
        uid = list[i].uid,
        picUrl = list[i].picUrl,
        level = list[i].level,
        cur_avatar_box_id = list[i].cur_avatar_box_id,
        auth_type = list[i].auth_type,
        auth_end_time = list[i].auth_end_time
      })
    end
    table.insert(self.ResultData.TeammateProfile, {
      uid = DataMgr.roleData.uid,
      picUrl = DataMgr.roleData.headIconUrl,
      level = DataMgr.roleData.level,
      cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id,
      auth_type = DataMgr.roleData.auth_type,
      auth_end_time = DataMgr.roleData.auth_end_time
    })
    log(bWriteLog and "BattleResultShowAvatarLogic:OnImageCallBack auth_type = " .. tostring(DataMgr.roleData.auth_type) .. ", auth_end_time = " .. tostring(DataMgr.roleData.auth_end_time))
  end
  EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_SHOW_AVATAR_IMAGE_DATA_REFRESH)
end
function BattleResultShowAvatarLogic:HandleTeammateListFavorInfo()
  log(bWriteLog and "BattleResultShowAvatarLogic.HandleTeammateListFavorInfo")
  if self.ResultData.TeammateList then
    local aimIndex = -1
    local finalScore = 0
    local myID = DataMgr.roleData.uid
    for index = 1, #self.ResultData.TeammateList do
      local teammate = self.ResultData.TeammateList[index]
      if teammate then
        teammate.isFavorOther = false
      end
      if teammate and teammate.FinalScore and finalScore < teammate.FinalScore and teammate.UID ~= myID then
        finalScore = teammate.FinalScore
        aimIndex = index
      end
    end
    if aimIndex ~= -1 then
      self.ResultData.TeammateList[aimIndex].isFavorOther = true
    end
  end
end
function BattleResultShowAvatarLogic:OnEnterWonderful()
  log(bWriteLog and "BattleResultShowAvatarLogic.OnEnterWonderful")
  self.bHasViewReplay = true
end
function BattleResultShowAvatarLogic:OnEnterBattleReplay()
  log(bWriteLog and "BattleResultShowAvatarLogic.OnEnterBattleReplay")
  self.bHasViewReplay = true
end
function BattleResultShowAvatarLogic:OnFriendGuideTips(_, _, friendGuideTipsType)
  log(bWriteLog and "BattleResultShowAvatarLogic.OnShowBattleResultTips friendGuideTipsType:" .. tostring(friendGuideTipsType))
  self.FriendGuideTipsType = tonumber(friendGuideTipsType)
  if self:ResultProcessExecuting() then
    self:ShowTeammateAddGuideTips()
  end
end
function BattleResultShowAvatarLogic:SendUpvote(uid, giftSource)
  log(bWriteLog and "BattleResultShowAvatarLogic send upvote to " .. tostring(uid) .. " with source: " .. tostring(giftSource))
  local nUID = tonumber(uid)
  if nUID ~= nil then
    local BattleResultHandler = require("client.network.Protocol.BattleResultHandler")
    BattleResultHandler.send_upvote_req(nUID, giftSource)
    if BattleResultUI.AlreadyUpvotedUID then
      BattleResultUI.AlreadyUpvotedUID[tostring(nUID)] = true
    end
    local BattleResultRanking_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.BattleResultRanking_UIBP)
    if UIManager.IsUIShow(UIManager.UI_Config_InGame.BattleResultRanking_UIBP) and BattleResultRanking_UIBP.OnSendLike then
      BattleResultRanking_UIBP:OnSendLike()
    end
  end
end
function BattleResultShowAvatarLogic:SendGiftNotify(eventType, eventID, uid, giftType, sender, gift_count, gift_source, _, __, battle_id)
  log(bWriteLog and "BattleResultShowAvatarLogic.SendGiftNotify:" .. tostring(uid))
  local gift_const = require("client.slua.logic.gift.gift_const")
  if GameStatus.IsInFightingStatus() and not self:ResultProcessExecuting() and gift_const.GiftSourceType.IngameWatch == gift_source then
    log(bWriteLog and "BattleResultShowAvatarLogic: ingame watch gift notify")
    return
  end
  self:HandleBattleBriefPanelNotifyRsp(sender, uid, giftType, gift_count)
  if gift_const.GiftSourceType.BattleOB == gift_source then
    log(bWriteLog and "BattleResultShowAvatarLogic: GiftSourceType.BattleOB")
    return
  end
  self:HandleResultViewNotifyRsp(eventType, eventID, uid, giftType, sender, gift_count, gift_source)
  self:HandleUpvoteNotifyRsp(eventType, eventID, sender, uid, giftType, gift_source, battle_id, gift_count)
end
function BattleResultShowAvatarLogic:HandleUpvoteNotifyRsp(_, _, sender, reciver, gift_type, gift_source, battle_id, gift_count)
  log(bWriteLog and "BattleResultShowAvatarLogic.HandleUpvoteNotifyRsp, sender " .. tostring(sender) .. " reciver " .. tostring(reciver) .. " type " .. tostring(gift_type) .. " source " .. tostring(gift_source))
  log(bWriteLog and "BattleResultShowAvatarLogic:HandleUpvoteNotifyRsp battle_id = " .. tostring(battle_id) .. " g_game_id = " .. tostring(g_game_id))
  log(bWriteLog and "BattleResultShowAvatarLogic:HandleUpvoteNotifyRsp gift_count = " .. tostring(gift_count))
  if tostring(battle_id) ~= tostring(g_game_id) then
    log(bWriteLog and "BattleResultShowAvatarLogic:HandleUpvoteNotifyRsp battle_id is not match")
    return
  end
  if gift_type == 11 or gift_type == 667 then
    if reciver and tostring(reciver) ~= tostring(DataMgr.roleData.uid) then
      if self.UpvoteCount[tostring(reciver)] ~= nil and type(self.UpvoteCount[tostring(reciver)]) == "number" then
        self.UpvoteCount[tostring(reciver)] = self.UpvoteCount[tostring(reciver)] + 1
      else
        self.UpvoteCount[tostring(reciver)] = 1
      end
    end
    local bMyselfSender = sender and tostring(sender) == tostring(DataMgr.roleData.uid)
    if bMyselfSender then
      self.MyUpvote[tostring(reciver)] = true
      if self.UpvoteMe[tostring(reciver)] then
        self.UpvoteEachOther[tostring(reciver)] = true
      end
    end
    if reciver and tostring(reciver) == tostring(DataMgr.roleData.uid) then
      self.UpvoteMe[tostring(sender)] = true
      if self.MyUpvote[tostring(sender)] then
        self.UpvoteEachOther[tostring(sender)] = true
      end
    end
    EventSystem:postEventSafety(EVENTTYPE_INGAME, EVENTID_INGAME_UPVOTE_INFO_UPDATE, sender, reciver)
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local mvpResultUIConfig = UIManager.UI_Config_InGame.BattleResultShowMvp_UIBP
  if gift_source == RoleInfoPopularitySystem.GiftSourceType.MVP and mvpResultUIConfig and UIManager.IsUIShow(mvpResultUIConfig) then
    local logic_gift_notice = require("client.slua.logic.gift.logic_gift_notice")
    logic_gift_notice.AddGiftNotice(gift_type, gift_count or 1, sender, reciver)
    return
  end
  if self:ResultProcessExecuting() then
    local BattleResultRanking_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.BattleResultRanking_UIBP)
    if BattleResultRanking_UIBP and BattleResultRanking_UIBP.HandleResultUpvoteNotify then
      BattleResultRanking_UIBP:HandleResultUpvoteNotify(sender, reciver, gift_type, gift_source, gift_count)
    else
      log(bWriteLog and "BattleResultShowAvatarLogic: no method named HandleResultUpvoteNotify")
    end
    return
  end
  local notifyItem = {
    sender = sender,
    reciver = reciver,
    gift_type = gift_type,
    gift_source = gift_source,
      }
  log(bWriteLog and "BattleResultShowAvatarLogic: insert to UpvoteNotifyMap")
  table.insert(BattleResultUI.UpvoteNotifyMap, #BattleResultUI.UpvoteNotifyMap + 1, notifyItem)
end
function BattleResultShowAvatarLogic:HandleResultViewNotifyRsp(eventType, eventID, uid, giftType, sender, gift_count)
  log(bWriteLog and "BattleResultShowAvatarLogic.HandleResultViewNotifyRsp:" .. tostring(uid))
  local mvpResultUIConfig = UIManager.UI_Config_InGame.BattleResultShowMvp_UIBP
  if self:ResultProcessExecuting() or mvpResultUIConfig and UIManager.IsUIShow(mvpResultUIConfig) then
    EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_SHOW_AVATAR_RECEIVE_GIFT, uid, giftType, sender, gift_count)
  end
end
function BattleResultShowAvatarLogic:HandleBattleBriefPanelNotifyRsp(sender, reciver, giftType, gift_count)
  log(bWriteLog and "BattleResultShowAvatarLogic.HandleBattleBriefPanelNotifyRsp:" .. tostring(reciver) .. ",giftType" .. tostring(giftType) .. ",count:" .. tostring(gift_count))
  if self.ResultData.TeammateList then
    local notifyItem = {}
    local findPlayer
    for index = 1, #self.ResultData.TeammateList do
      local player_id = self.ResultData.TeammateList[index].UID
      if tostring(player_id) == tostring(reciver) then
        findPlayer = self.ResultData.TeammateList[index]
      elseif tostring(player_id) == tostring(sender) then
        notifyItem.FName = self.ResultData.TeammateList[index].Name
      end
    end
    notifyItem.GiftType = giftType
    notifyItem.GiftCount = gift_count
    if findPlayer then
      table.insert(findPlayer.GiftNotifyMap, notifyItem)
      EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_SHOW_AVATAR_GIFT_DATA_REFRESH)
    end
  else
    table.insert(self.GiftNotifyCacheMap, {
      sender = sender,
      reciver = reciver,
      giftType = giftType,
          })
  end
end
function BattleResultShowAvatarLogic:GetInGameGiftRecord()
  log(bWriteLog and "[BattleResultShowAvatarLogic] GetInGameGiftRecord")
  local BattleResultHandler = require("client.network.Protocol.BattleResultHandler")
  BattleResultHandler.send_get_battle_pspace_gift_record_req(self.ResultData.battle_id)
end
function BattleResultShowAvatarLogic:OnGetInGameGiftRecord(err_code, gift_record_info, battle_id)
  log(bWriteLog and "[BattleResultShowAvatarLogic] OnGetInGameGiftRecord: " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  if tostring(battle_id) ~= tostring(self.ResultData.battle_id) then
    log(bWriteLog and "[BattleResultShowAvatarLogic] battle id not match: " .. tostring(battle_id))
    return
  end
  if not gift_record_info or not next(gift_record_info) then
    log(bWriteLog and "[BattleResultShowAvatarLogic] nil gift record")
    return
  end
  local gift_const = require("client.slua.logic.gift.gift_const")
  local gift_record_list = {}
  for receiver_uid, receive_record in pairs(gift_record_info) do
    for sender_uid, gift_map in pairs(receive_record) do
      for gift_id, gift_count in pairs(gift_map) do
        local gift_record = {
          sender = sender_uid,
          reciver = receiver_uid,
          gift_type = gift_id,
          gift_count = gift_count,
          gift_source = gift_const.GiftSourceType.IngameWatch
        }
        table.insert(gift_record_list, gift_record)
      end
    end
  end
  gift_record_list = self:SortGiftRecord(gift_record_list)
  for _, gift_record in ipairs(gift_record_list) do
    table.insert(BattleResultUI.UpvoteNotifyMap, gift_record)
    self:HandleBattleBriefPanelNotifyRsp(gift_record.sender, gift_record.reciver, gift_record.gift_type, gift_record.gift_count)
  end
  EventSystem:postEventSafety(EVENTTYPE_INGAME, EVENTID_INGAME_GIFT_RECORD_UPDATE, gift_record_list)
end
function BattleResultShowAvatarLogic:OnInviteGameRsp(eventType, eventID, leaderUid)
  log(bWriteLog and "BattleResultShowAvatarLogic.OnInviteGameRsp:" .. tostring(leaderUid))
  if not self:ResultProcessExecuting() then
    self.ResultData.BPRecordOneMoreLeaderUin = leaderUid
    return
  end
  local BattleResultRanking_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.BattleResultRanking_UIBP)
  if BattleResultRanking_UIBP and BattleResultRanking_UIBP.HandleInviteTeam then
    BattleResultRanking_UIBP:HandleInviteTeam(leaderUid)
  else
    log(bWriteLog and "BattleResultShowAvatarLogic: no method named HandleInviteTeam")
  end
end
function BattleResultShowAvatarLogic:OnAddFriendNofity(_, _, sender)
  log(bWriteLog and "BattleResultShowAvatarLogic.OnAddFriendNofity: " .. tostring(sender))
  if not GameStatus.IsInFightingStatus() then
    log(bWriteLog and "BattleResultShowAvatarLogic: not fighting state")
    return
  end
  if ResultUtil.IsPVEMode(BATTLETYPE_MODE) then
    log(bWriteLog and "BattleResultShowAvatarLogic: pve mode return")
    return
  end
  if self:ResultProcessExecuting() then
    local BattleResultRanking_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.BattleResultRanking_UIBP)
    if BattleResultRanking_UIBP and BattleResultRanking_UIBP.HandleAddFriendNotify then
      BattleResultRanking_UIBP:HandleAddFriendNotify(sender)
    else
      log(bWriteLog and "BattleResultShowAvatarLogic: no method named HandleAddFriendNotify")
    end
    return
  end
  log(bWriteLog and "BattleResultUI: insert to AddFriendMap")
  table.insert(BattleResultUI.AddFriendMap, #BattleResultUI.AddFriendMap + 1, sender)
end
function BattleResultShowAvatarLogic:GetTeammaterByID(uid)
  if self.ResultData.TeammateList then
    for index, teammater in pairs(self.ResultData.TeammateList) do
      local player_id = teammater.UID
      if tostring(player_id) == tostring(uid) then
        return teammater
      end
    end
  end
  return nil
end
function BattleResultShowAvatarLogic:GetHighestAlivePlayerUID()
  local HighestAlivePlayerUID = 0
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) and self.ResultData.TeammateList then
    local HightestfinalScore = 0
    for key, teammate in pairs(self.ResultData.TeammateList) do
      if teammate ~= nil and teammate.IsMVP then
        local PlayerState = uGameState:GetPlayerStateByUID(tonumber(teammate.UID))
        print(bWriteLog and "BattleResultShowAvatarLogic.GetHighestAlivePlayerUID ", tonumber(teammate.UID), PlayerState)
        if slua.isValid(PlayerState) and PlayerState.IsAlive and PlayerState:IsAlive() then
          HighestAlivePlayerUID = tonumber(teammate.UID)
          print(bWriteLog and "BattleResultShowAvatarLogic.GetHighestAlivePlayerUID ", HighestAlivePlayerUID, " myuid:", DataMgr.roleData.uid)
          return HighestAlivePlayerUID
        end
      end
    end
    local HightestfinalKill = 0
    local HightestfinalDamage = 0
    for key, teammate in pairs(self.ResultData.TeammateList) do
      if teammate ~= nil then
        teammate.FinalScore = teammate.FinalScore or 0
        teammate.Kill = teammate.Kill or 0
        teammate.DamageAmount = teammate.DamageAmount or 0
        if HightestfinalScore < teammate.FinalScore or teammate.FinalScore == HightestfinalScore and HightestfinalKill < tonumber(teammate.Kill) or teammate.FinalScore == HightestfinalScore and tonumber(teammate.Kill) == HightestfinalKill and HightestfinalDamage < tonumber(teammate.DamageAmount) or teammate.FinalScore == HightestfinalScore and tonumber(teammate.Kill) == HightestfinalKill and tonumber(teammate.DamageAmount) == HightestfinalDamage and HighestAlivePlayerUID < tonumber(teammate.UID) then
          local PlayerState = uGameState:GetPlayerStateByUID(tonumber(teammate.UID))
          print(bWriteLog and "BattleResultShowAvatarLogic.GetHighestAlivePlayerUID", key, tonumber(teammate.UID), PlayerState)
          if slua.isValid(PlayerState) and PlayerState.IsAlive and PlayerState:IsAlive() then
            HightestfinalScore = teammate.FinalScore
            HighestAlivePlayerUID = tonumber(teammate.UID)
            HightestfinalKill = tonumber(teammate.Kill)
            HightestfinalDamage = tonumber(teammate.DamageAmount)
          end
        end
      end
    end
  end
  print(bWriteLog and "BattleResultShowAvatarLogic.GetHighestAlivePlayerUID ", HighestAlivePlayerUID, " myuid:", DataMgr.roleData.uid)
  return HighestAlivePlayerUID
end
function BattleResultShowAvatarLogic:OnNetShutDown()
  print(bWriteLog and "BattleResultShowAvatarLogic:OnNetShutDown bHasViewReplay:" .. tostring(self.bHasViewReplay))
  if self.bHasViewReplay then
    return
  end
  if slua_GameFrontendHUD then
    slua_GameFrontendHUD:ShutdownUnrealNetwork()
  end
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  local uActorClass = import("/Script/Engine.Actor")
  local uPawnClass = import("/Game/BluePrints/Core/BP_PlayerPawn.BP_PlayerPawn_C")
  local uPawnArray = UGameplayStatics.GetAllActorsOfClass(GameInstance, uPawnClass, slua.Array(UEnums.EPropertyClass.Object, uActorClass))
  if uPawnArray and uPawnArray:Num() > 0 then
    for index = 0, uPawnArray:Num() - 1 do
      local uPawn = uPawnArray:Get(index)
      if Game:IsValid(uPawn) then
        local USTCharacterMovementComponent = import("STCharacterMovementComponent")
        local uMovementComponent = uPawn:GetComponentByClass(USTCharacterMovementComponent)
        if slua.isValid(uMovementComponent) then
          uMovementComponent:Deactivate()
        end
        local WeaponCompCls = import("CharacterWeaponManagerComponent")
        local WeaponComp = uPawn:GetComponentByClass(WeaponCompCls)
        if slua.isValid(WeaponComp) then
          WeaponComp:HideAllWeapon(true, 0, nil)
        end
        print(bWriteLog and "BattleResultShowAvatarLogic:OnNetShutDown playerName:" .. tostring(uPawn:GetPlayerNameSafety()) .. " OnNetSHutDown")
      end
    end
  end
  local ASTExtraShootWeapon = import("STExtraShootWeapon")
  local uWeaponArray = UGameplayStatics.GetAllActorsOfClass(GameInstance, ASTExtraShootWeapon, slua.Array(UEnums.EPropertyClass.Object, uActorClass))
  if uWeaponArray and uWeaponArray:Num() > 0 then
    local EFreshWeaponStateType = import("EFreshWeaponStateType")
    for index = 0, uWeaponArray:Num() - 1 do
      local uWeapon = uWeaponArray:Get(index)
      if Game:IsValid(uWeapon) then
        uWeapon:StopFire(EFreshWeaponStateType.FreshWeaponStateType_Idle)
      end
    end
  end
end
function BattleResultShowAvatarLogic:OnShowAvatarClose(_, _, isTimeOut, isGotoAnchorObserver)
  print(bWriteLog and "BattleResultShowAvatarLogic:OnShowAvatarClose")
  if isGotoAnchorObserver then
    self.BattleResultSubSystem:ForcedFinishResultProcess()
    BattleResult.enter_room_battle_watch()
  else
    self:EndResultProcess()
  end
end
function BattleResultShowAvatarLogic:ShowTeammateAddGuideTips()
  print(bWriteLog and "BattleResultShowAvatarLogic:ShowTeammateAddGuideTips FriendGuideTipsType:" .. tostring(self.FriendGuideTipsType))
  if self.FriendGuideTipsType ~= -1 then
    local teammateInfo = self:GetBubbleTeammateIdx(self.FriendGuideTipsType)
    if not teammateInfo then
      log(bWriteLog and "BattleResultShowAvatarLogic:ShowTeammateAddGuideTips not teammateInfo FriendGuideTipsType:" .. tostring(self.FriendGuideTipsType))
      return
    end
    local teammateUID = teammateInfo.UID
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if LogicFriend.IsMyFriend(tostring(teammateUID)) or tonumber(DataMgr.roleData.uid) == tonumber(teammateUID) then
      log(bWriteLog and "BattleResultShowAvatarLogic:ShowTeammateAddGuideTips teammateUID:" .. teammateUID)
      return
    end
    local textStr = ""
    if self.FriendGuideTipsType == 1 then
      textStr = LocUtil.LocalizeResFormat(10986)
    elseif self.FriendGuideTipsType == 2 then
      local rescueTimes = teammateInfo.rescueTimes
      textStr = LocUtil.LocalizeResFormat(11821, rescueTimes)
    elseif self.FriendGuideTipsType == 3 then
      textStr = LocUtil.LocalizeResFormat(11822)
    elseif self.FriendGuideTipsType == 4 then
      textStr = LocUtil.LocalizeResFormat(13158)
    end
    UIManager.ShowUI(UIManager.UI_Config.ResultsAddFriendsPopUp, teammateUID, textStr)
    self.FriendGuideTipsType = -1
  end
end
function BattleResultShowAvatarLogic:GetBubbleTeammateIdx(GuideTipsType)
  local mvpTeammateIdx = -1
  local maxRescueTeammateIdx = 1
  local maxDamageTeammateIdx = 1
  local finishFirstPvPIdx = -1
  if self.ResultData.TeammateList ~= nil then
    local teammateList = self.ResultData.TeammateList
    if teammateList ~= nil then
      for index = 1, #teammateList do
        if teammateList[index] ~= nil then
          local teammateInfo = teammateList[index]
          if teammateInfo.IsMVP then
            mvpTeammateIdx = index
          end
          if teammateInfo.rescueTimes > teammateList[maxRescueTeammateIdx].rescueTimes then
            maxRescueTeammateIdx = index
          elseif teammateInfo.rescueTimes == teammateList[maxRescueTeammateIdx].rescueTimes and teammateInfo.DamageAmount > teammateList[maxRescueTeammateIdx].DamageAmount then
            maxRescueTeammateIdx = index
          end
          if teammateInfo.DamageAmount > teammateList[maxDamageTeammateIdx].DamageAmount then
            maxDamageTeammateIdx = index
          end
          if finishFirstPvPIdx == -1 and tonumber(DataMgr.roleData.uid) ~= tonumber(teammateInfo.UID) then
            finishFirstPvPIdx = index
          end
        end
      end
      if teammateList[maxRescueTeammateIdx].rescueTimes == 0 then
        maxRescueTeammateIdx = -1
      end
      if teammateList[maxDamageTeammateIdx].DamageAmount < 0.001 then
        maxDamageTeammateIdx = -1
      end
      if GuideTipsType == nil then
        return nil
      elseif GuideTipsType == 1 then
        return self.ResultData.TeammateList[mvpTeammateIdx]
      elseif GuideTipsType == 2 then
        return self.ResultData.TeammateList[maxRescueTeammateIdx]
      elseif GuideTipsType == 3 then
        return self.ResultData.TeammateList[maxDamageTeammateIdx]
      elseif GuideTipsType == 4 then
        return self.ResultData.TeammateList[finishFirstPvPIdx]
      else
        return nil
      end
    end
  end
  return nil
end
function BattleResultShowAvatarLogic:GetSendGiftTipsText()
  if self.SendGiftText and next(self.SendGiftText) then
    log(bWriteLog and "BattleResultShowAvatarLogic:GetSendGiftTipsText self.SendGiftText has already get data")
    return self.SendGiftText
  end
  if self.ResultData.TeammateList == nil then
    log(bWriteLog and "BattleResultShowAvatarLogic:GetSendGiftTipsText teammateList is nil")
    return {}
  end
  local tipsTextConfig = CDataTable.GetTable("ResultTipsTextConfig")
  local tipsTextConfigArray = {}
  for _, value in pairs(tipsTextConfig) do
    table.insert(tipsTextConfigArray, value)
  end
  table.sort(tipsTextConfigArray, function(a, b)
    local priority1 = a.Priority
    local priority2 = b.Priority
    if priority1 and priority2 then
      return priority1 < priority2
    end
    return false
  end)
  local paramMap = prealloctable(4, 0)
  for _, teammate in pairs(self.ResultData.TeammateList) do
    if tonumber(teammate.UID) ~= tonumber(DataMgr.roleData.uid) then
      paramMap[1] = teammate.rescueTimes or 0
      paramMap[2] = teammate.recall_team_mate_count or 0
      paramMap[3] = teammate.AssistNum or 0
      paramMap[4] = teammate.IsMVP or false
      for _, value in ipairs(tipsTextConfigArray) do
        local condition = value.Condition
        local paramValue = paramMap[condition]
        if paramValue == nil then
          log(bWriteLog and "BattleResultShowAvatarLogic:GetSendGiftTipsText no map with condition = " .. tostring(condition))
          break
        end
        local param1 = value.Param1
        if type(paramValue) == "boolean" and self.SendGiftText then
          if paramValue then
            self.SendGiftText[tonumber(teammate.UID)] = value.ShowTextID
            break
          end
        elseif paramValue >= param1 and self.SendGiftText then
          self.SendGiftText[tonumber(teammate.UID)] = value.ShowTextID
          break
        end
      end
    end
  end
  return self.SendGiftText
end
function BattleResultShowAvatarLogic:GetUpvoteInfo(uid)
  log(bWriteLog and "BattleResultShowAvatarLogic:GetUpvoteInfo uid = " .. tostring(uid))
  if uid == nil then
    return nil, nil, nil
  end
  local currCount = self.UpvoteCount[tostring(uid)]
  log(bWriteLog and "BattleResultShowMvp_UICtrl:GetUpvoteInfo currCount = " .. tostring(currCount))
  local bUpvote = self.MyUpvote[tostring(uid)]
  log(bWriteLog and "BattleResultShowMvp_UICtrl:GetUpvoteInfo bUpvote = " .. tostring(bUpvote))
  local bUpvoteEachOther = self.UpvoteEachOther[tostring(uid)]
  log(bWriteLog and "BattleResultShowMvp_UICtrl:GetUpvoteInfo bUpvoteEachOther = " .. tostring(bUpvoteEachOther))
  return currCount, bUpvote, bUpvoteEachOther
end
function BattleResultShowAvatarLogic:RefreshUpvoteButton(UIRoot, uid, bMyselfSender, bRefreshCount)
  UIRoot.Button_Upvote:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  local upvoteCount = self:GetUpvoteInfo(uid)
  if upvoteCount then
    if bRefreshCount then
      UIRoot.Textblock_UpvoteCount:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      UIRoot.Textblock_UpvoteCount:SetText("+" .. tostring(upvoteCount))
      if UIRoot.Fadein_Likes then
        UIRoot:PlayUserWidgetAnimation(UIRoot.Fadein_Likes, 0, 1, 0, 1)
      end
    end
  else
    UIRoot.Textblock_UpvoteCount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if bMyselfSender then
    if UIRoot.Fadein_Like_3 then
      UIRoot:PlayUserWidgetAnimation(UIRoot.Fadein_Like_3, 0, 1, 0, 1)
    elseif UIRoot.Fadein_Like_1 then
      UIRoot:PlayUserWidgetAnimation(UIRoot.Fadein_Like_1, 0, 1, 0, 1)
    else
      self:RefreshUpvoteButtonStyle(UIRoot, uid)
    end
  else
    self:RefreshUpvoteButtonStyle(UIRoot, uid)
  end
end
function BattleResultShowAvatarLogic:RefreshUpvoteButtonStyle(UIRoot, uid)
  local _, bUpvote, bUpvoteEachOther = self:GetUpvoteInfo(uid)
  local activeIndex = 0
  if bUpvoteEachOther then
    UIRoot.WidgetSwitcher_Upvote:SetActiveWidgetIndex(2)
    UIRoot.Button_Upvote:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    activeIndex = 2
  elseif bUpvote then
    UIRoot.WidgetSwitcher_Upvote:SetActiveWidgetIndex(1)
    UIRoot.Button_Upvote:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    activeIndex = 1
  else
    UIRoot.WidgetSwitcher_Upvote:SetActiveWidgetIndex(0)
    UIRoot.Button_Upvote:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    activeIndex = 0
  end
  log(bWriteLog and "BattleResultShowAvatarLogic:RefreshUpvoteButtonStyle is " .. tostring(activeIndex))
  if self.ResultData and self.ResultData.is_world_cup_battle_id and UIRoot.WidgetSwitcher_ActivityUpvote then
    log(bWriteLog and "BattleResultShowAvatarLogic:RefreshUpvoteButtonStyle worldCup upvote")
    UIRoot.WidgetSwitcher_ActivityUpvote:SetActiveWidgetIndex(activeIndex)
    self:CheckAndSetWidgetVisible(UIRoot.WidgetSwitcher_Upvote, false)
    self:CheckAndSetWidgetVisible(UIRoot.WidgetSwitcher_ActivityUpvote, true)
  else
    self:CheckAndSetWidgetVisible(UIRoot.WidgetSwitcher_Upvote, true)
    self:CheckAndSetWidgetVisible(UIRoot.WidgetSwitcher_ActivityUpvote, false)
  end
end
function BattleResultShowAvatarLogic:CheckAndSetWidgetVisible(widget, isVisible, isButton)
  if not slua.isValid(widget) then
    log(bWriteLog and "BattleResultShowAvatarLogic:CheckAndSetWidgetVisible no widget")
    return
  end
  if isVisible then
    if isButton then
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    else
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BattleResultShowAvatarLogic:CheckNeedBlockUpvoteButton(battle_type)
  log(bWriteLog and "BattleResultShowAvatarLogic:CheckNeedBlockUpvoteButton battle_type = " .. tostring(battle_type))
  if not battle_type then
    return true
  end
  return battle_type == 13001 or battle_type == 13003 or battle_type == 13703 or battle_type == 15103 or battle_type == 15403 or battle_type == 11103 or battle_type == 11403 or battle_type == 12103
end
function BattleResultShowAvatarLogic:SetPermanentFeedbackScore(ID, Score)
  if not self.PermanentFeedbackData then
    return
  end
  print(bWriteLog and "BattleResultShowAvatarLogic:SetPermanentFeedbackScore", ID, Score)
  self.PermanentFeedbackData.feedback[ID] = Score
  self.bNeedSendPermanentFeedback = true
end
function BattleResultShowAvatarLogic:SetPermanentFeedbackSuggestion(Suggestion)
  if not self.PermanentFeedbackData then
    return
  end
  print(bWriteLog and "BattleResultShowAvatarLogic:SetPermanentFeedbackSuggestion", Suggestion)
  self.PermanentFeedbackData.suggest = Suggestion
  self.bNeedSendPermanentFeedback = true
end
function BattleResultShowAvatarLogic:SetTriggeredFeedbackScore(Score)
  print(bWriteLog and "BattleResultShowAvatarLogic:SetTriggeredFeedbackScore", Score)
  if not self.TriggeredFeedbackData then
    return
  end
  self.TriggeredFeedbackData.score = Score
  self.bNeedSendTriggeredFeedback = true
end
function BattleResultShowAvatarLogic:SendPermanentFeedbackData()
  print(bWriteLog and "BattleResultShowAvatarLogic:SendPermanentFeedbackData")
  local Data = {
    is_long_evaluation = 1,
    feedback = self.PermanentFeedbackData.feedback,
    suggest = self.PermanentFeedbackData.suggest
  }
  BattleResultHandler.send_report_battle_evaluation(self.ResultData.battle_id, Data)
end
function BattleResultShowAvatarLogic:SendTriggeredFeedbackData()
  if not self.TriggeredFeedbackData then
    return
  end
  print(bWriteLog and "BattleResultShowAvatarLogic:SendTriggeredFeedbackData", self.TriggeredFeedbackData.score)
  local Data = {
    is_long_evaluation = 0,
    score = self.TriggeredFeedbackData.score
  }
  BattleResultHandler.send_report_battle_evaluation(self.ResultData.battle_id, Data)
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CBattleResultShowAvatarLogic = class(BattleResultProcessBaseLogic, nil, BattleResultShowAvatarLogic)
return CBattleResultShowAvatarLogic