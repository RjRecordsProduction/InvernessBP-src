local BattleResultShowMvpLogic = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
local UBackpackUtils = import("BackpackUtils")
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
local pak_util = require("client.common.pak_util")
local DefaultMVPID = 4100000
local DefaultImprintID = 41030001
function BattleResultShowMvpLogic:OnInit()
  print(bWriteLog and "BattleResultShowMvpLogic:OnInit")
  self.BattleResultShouldShowMVPScene = false
  self.ResultMVPID = DefaultMVPID
  self.SubModeId = 0
  self.ResultMvpAreaSegmentLevel = 0
  self.MVPSpawnPlayerRoleInfo = {}
  self.MVPResultType = 0
  self.MVPShowChickenLogo = false
  self.ResultTeamRank = 0
  self.ResultMVPDelay = 0
  self.MVPPlayerProfile = {
    Signature = "",
    UId = 0,
    PicUrl = "",
    Level = 0,
    AvatarBoxId = 0
  }
  self.MVPPeakGameSegmentId = nil
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_SHOW_MVP_CLOSE, self.OnShowMvpSceneClose, self)
end
function BattleResultShowMvpLogic:OnRelease()
  print(bWriteLog and "BattleResultShowMvpLogic:OnRelease")
  self.BattleResultShouldShowMVPScene = false
  self.ResultMVPID = DefaultMVPID
  self.SubModeId = 0
  self.ResultMvpAreaSegmentLevel = 0
  self.MVPSpawnPlayerRoleInfo = {}
  self.MVPShowChickenLogo = false
  self.MVPResultType = 0
  self.MVPPlayerProfile = nil
  self.MVPPeakGameSegmentId = nil
end
function BattleResultShowMvpLogic:OnBattleResult(result)
  local bNeedShowMVP = ResultUtil.NeedShowMVP()
  print(bWriteLog and "BattleResultShowMvpLogic:OnBattleResult is_team_result:" .. tostring(result.is_team_result) .. " team_rank:" .. tostring(result.team_rank) .. " bNeedShowMVP:" .. tostring(bNeedShowMVP))
  if ResultUtil.SkipShowMVPScene() then
    print(bWriteLog and "BattleResultShowMvpLogic:OnBattleResult SkipShowMVPScene")
    return
  end
  self.battle_type = result.battle_type
  self.SubModeId = result.sub_mode
  self.battle_owner = result.battle_owner
  self.isGlobalOB = result.isGlobalOB
  if result.rating then
    self.new_segment = result.rating.new_segment and result.rating.new_segment > 0 and result.rating.new_segment
    local is_promotion_cross_mode = false
    local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
    local IsNoPromoRating = false
    if result.promotion_result_info and result.promotion_result_info.cur_promotion_data then
      local result_promotion_util = require("client.logic.season.promotion_match.Result.result_promotion_util")
      is_promotion_cross_mode = result_promotion_util.CheckIsPromotionCrossMode(result.promotion_result_info.cur_promotion_data, result.promotion_layer, result.battle_type)
      IsNoPromoRating = logic_promotion_homepage.IsNoPromoRating(result.promotion_result_info.cur_promotion_data.season_id)
      if IsNoPromoRating and is_promotion_cross_mode then
        self.new_segment = result.promotion_result_info.promo_unlock_mode_new_segment_lv or self.new_segment
      end
    end
  end
  self.TeammateList = result.TeammateList
  local commonData = self:GetBattleResultData()
  self.MyName = commonData.BP_myname
  if result.TeammateList and bNeedShowMVP then
    self:InitBRModeMvpInfo(result)
  elseif result.IsDeathMatchResult then
    self:InitTDMModeMvpInfo(result)
  end
end
function BattleResultShowMvpLogic:OnSwitchCheck()
  local BattleResultData = self:GetBattleResultData()
  EventSystem:postEventSafety(EVENTTYPE_INGAME_MAP, EVENTID_HIDE_MAP)
  if not BattleResultData then
    return false
  end
  print(bWriteLog and "BattleResultShowMvpLogic:OnSwitchCheck " .. tostring(self.BattleResultShouldShowMVPScene), self.MVPResultType, self.isGlobalOB, BattleResultData.BP_TDMResult_ShouldShowMVP)
  if self.MVPResultType == 0 then
    if self.BattleResultShouldShowMVPScene then
      return true
    end
  elseif self.MVPResultType == 1 then
    return BattleResultData.BP_TDMResult_ShouldShowMVP and not self.isGlobalOB
  end
  return false
end
function BattleResultShowMvpLogic:CheckAllBPPathsExistByItemID(ItemID)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local passive_resource_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.passive_resource_downloader)
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if not (itemCfg and PufferODPakManager) or not passive_resource_downloader then
    return false
  end
  local paths = PufferODPakManager:GetBPPathsByItemID(ItemID, itemCfg)
  if not paths then
    return false
  end
  local result = true
  for _, path in pairs(paths) do
    if not passive_resource_downloader:CheckTextureHasBeenDownloaded(path) then
      print(bWriteLog and "BattleResultShowMvpLogic:CheckAllBPPathsExistByItemID not exist:", path, Download)
      result = false
    else
      print(bWriteLog and "BattleResultShowMvpLogic:CheckAllBPPathsExistByItemID exist:", path)
    end
  end
  return result
end
function BattleResultShowMvpLogic:OnResultProcessStart()
  print(bWriteLog and "BattleResultShowMvpLogic:OnResultProcessStart-", self.MVPResultType, self.ResultMVPID, self.MVPImprintID)
  if self.MVPImprintID and self.MVPImprintID > 0 and self.MVPImprintID ~= DefaultImprintID then
    local ImprintCfg = CDataTable.GetTableData("MVPImprintTable", self.MVPImprintID)
    if not ImprintCfg or not ImprintCfg.Path then
      self.MVPImprintID = DefaultImprintID
    else
      local bExist = self:CheckAllBPPathsExistByItemID(self.MVPImprintID)
      print(bWriteLog and "BattleResultShowMvpLogic:OnResultProcessStart Imprint:", bExist, self.MVPImprintID, ImprintCfg.Path)
      if not bExist then
        self.MVPImprintID = DefaultImprintID
      end
    end
  end
  if self.ResultMVPID and self.ResultMVPID > 0 and self.ResultMVPID ~= DefaultMVPID then
    local Cfg = CDataTable.GetTableData("MVPActionInfo", self.ResultMVPID)
    if Cfg then
      local bExist = self:CheckAllBPPathsExistByItemID(Cfg.ItemID)
      local bEmotionExist = self:CheckAllBPPathsExistByItemID(Cfg.EmotionID)
      print(bWriteLog and "BattleResultShowMvpLogic:OnResultProcessStart Item exist:", self.ResultMVPID, bEmotionExist, bExist, Cfg.EmotionID, Cfg.ItemID)
      if not bExist or not bEmotionExist then
        self.ResultMVPID = DefaultMVPID
        print(bWriteLog and "BattleResultShowMvpLogic:OnResultProcessStart Item not exist:", self.ResultMVPID)
      else
        local LevelPath = Cfg.LevelPath
        print(bWriteLog and "BattleResultShowMvpLogic:OnResultProcessStart LevelPath:", LevelPath)
        if LevelPath and LevelPath ~= "" then
          local passive_resource_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.passive_resource_downloader)
          self.MvpSceneActorPath = LevelPath
          if not passive_resource_downloader or not passive_resource_downloader:CheckTextureHasBeenDownloaded(LevelPath) then
            print(bWriteLog and "BattleResultShowMvpLogic:OnResultProcessStart Level not exist:", LevelPath)
            self.MvpSceneActorPath = nil
            self.ResultMVPID = DefaultMVPID
          end
        end
      end
    end
  end
  local mvpCfg = {
    ResultMVPID = self.ResultMVPID,
    ResultMvpAreaSegmentLevel = self.ResultMvpAreaSegmentLevel,
    MVPSpawnPlayerRoleInfo = self.MVPSpawnPlayerRoleInfo,
    ResultTeamRank = self.ResultTeamRank,
    ResultMVPDelay = self.ResultMVPDelay,
    MVPShowChickenLogo = self.MVPShowChickenLogo,
    MVPResultType = self.MVPResultType,
    SubModeId = self.SubModeId,
    TeamModeName = self:GetBattleResultData().BP_TeamModeName,
    Battle_owner = self.battle_owner,
    New_segment = self.new_segment,
    TeammateList = self.TeammateList,
    MyName = self.MyName,
    MVPPlayerProfile = self.MVPPlayerProfile,
    MVPPeakGameSegmentId = self.MVPPeakGameSegmentId,
    battle_type = self.battle_type,
    MvpSceneActorPath = self.MvpSceneActorPath,
    MVPImprintID = self.MVPImprintID
  }
  if self.MVPResultType == 1 then
    if UIManager and UIManager.ShowUI(UIManager.UI_Config_InGame.BattleResultShowMvp_UIBP, mvpCfg) then
      print(bWriteLog and "BattleResultShowMvpLogic:OnResultProcessStart Show Suc TDM")
    end
  elseif UIManager and UIManager.ShowUI(UIManager.UI_Config_InGame.BattleResultShowMvp_UIBP, mvpCfg) then
    print(bWriteLog and "BattleResultShowMvpLogic:OnResultProcessStart Show Suc")
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.SetIsShowBlood then
    uPlayerController:SetIsShowBlood(false)
  end
  if WatchGameUI then
    WatchGameUI:HideSpectatingUI()
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.bIsEnterBattleResultStep ~= nil then
    PlayerController.bIsEnterBattleResultStep = true
  end
  return true
end
function BattleResultShowMvpLogic:OnShowMvpSceneClose()
  print(bWriteLog and "BattleResultShowMvpLogic:OnShowMvpSceneClose")
  EventResultMVPEnd()
  self:EndResultProcess()
end
function BattleResultShowMvpLogic:InitBRModeMvpInfo(result)
  print(bWriteLog and "BattleResultShowMvpLogic:InitBRMvpInfo is_team_result:" .. tostring(result.is_team_result) .. " team_rank:" .. tostring(result.team_rank))
  if not result.is_team_result or result.team_rank > 15 then
    print(bWriteLog and "BattleResultShowMvpLogic:InitBRMvpInfo Stop")
    return
  end
  local list = result.TeammateList
  for i = 1, #list do
    print(bWriteLog and "BattleResultShowMvpLogic.InitBRMvpInfo IsMVP:" .. tostring(list[i].IsMVP) .. " settl_motion:" .. tostring(list[i].settl_motion))
    if list[i].IsMVP and list[i].settl_motion ~= nil and list[i].settl_motion > 0 then
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
      local myName = ""
      if DataMgr ~= nil and DataMgr.roleData ~= nil then
        myName = DataMgr.roleData.nickName
      end
      self.MVPSpawnPlayerRoleInfo = {
        uid = list[i].UID,
        sex = list[i].gamegender,
        headId = wear_ext[9] and wear_ext[9][1] or 0,
        index = i - 1,
        weaponId = wear_ext[13] and wear_ext[13][1] or 0,
        weaponSkinId = wear_ext[14] and wear_ext[14][1] or 0,
        weaponSkinDIYPlanId = wear_ext[14] and wear_ext[14][4] or 0,
        weaponPendantID = wear_ext[14] and wear_ext[14][6] and wear_ext[14][6][1] or 0,
        secondWeaponId = wear_ext[121] and wear_ext[121][1] or 0,
        secondWeaponSkinId = wear_ext[122] and wear_ext[122][1] or 0,
        secondWeaponSkinDIYPlanId = wear_ext[122] and wear_ext[122][4] or 0,
        secondWeaponPendantID = wear_ext[122] and wear_ext[122][6] and wear_ext[122][6][1] or 0,
        playerName = list[i].Name,
        resultAvatarPose = list[i].resultAvatarPose or 0,
        PetId = pet_id,
        PetLevel = pet_level,
        PetAvatarID = pet_avatar_id,
        BP_ARRAY_MVP_AvatarList = rolewear,
        isSelf = list[i].Name == myName,
        Kill = list[i].Kill,
        Assists = list[i].AssistNum,
        DamageAmount = list[i].DamageAmount,
        RescueTimes = list[i].rescueTimes,
        surviveTime = list[i].surviveTime,
        SupportScore = list[i].SupportScore
      }
      self.ResultMVPID = list[i].settl_motion
      self.ResultTeamRank = result.team_rank
      self.BattleResultShouldShowMVPScene = true
      self.MVPResultType = 0
      self.MVPPeakGameSegmentId = list[i].peakgame_segment_id
      self.MVPImprintID = list[i].MVPImprintID
      self:GetMvpSignatureProfile()
      local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
      if not Client.IsShipping() and ESportAllStarSystem.isGM_OneTeam then
        self.BattleResultShouldShowMVPScene = false
      end
      log_tree(bWriteLog and "InitMVPRoleInfo11", self.MVPSpawnPlayerRoleInfo)
      return
    end
  end
end
function BattleResultShowMvpLogic:InitTDMModeMvpInfo(result)
  log_tree("BattleResultShowMvpLogic:InitTDMModeMvpInfo", result)
  for j = 1, #result.TeamResultDatas do
    if result.TeamResultDatas[j].TeamID == result.my_result.TeamID then
      local myTeamResult = result.TeamResultDatas[j]
      print(bWriteLog and "MyTeam Result:" .. tostring(myTeamResult.Result), j, myTeamResult.BP_ARRAY_PlayerResultData)
      if myTeamResult.Result ~= "Fail" then
        self:_InitTDMModeMvpInfo(myTeamResult.BP_ARRAY_PlayerResultData)
      end
    end
  end
end
function BattleResultShowMvpLogic:_InitTDMModeMvpInfo(list)
  for i = 1, #list do
    print(bWriteLog and "BattleResultShowMvpLogic:_InitTDMModeMvpInfo mvp:" .. tostring(list[i].mvp) .. " settl_motion:" .. tostring(list[i].settl_motion) .. " HasEscape:" .. tostring(list[i].HasEscape))
    if list[i].mvp == 1 and list[i].settl_motion ~= nil and list[i].settl_motion > 0 and list[i].HasEscape == nil or list[i].HasEscape == false then
      local rolewear = {}
      local wear_ext = list[i].wear_ext or {}
      for k, v in pairs(wear_ext) do
        if ResultUtil.CanApplyAvatarShowType(k) then
          table.insert(rolewear, AvatarData.ConvertToAvatarCustom(v))
        end
      end
      local pet_id = 0
      local pet_level = 0
      if list[i].pet_id ~= nil and list[i].pet_id ~= -1 then
        pet_id = list[i].pet_id
      end
      if list[i].pet_level ~= nil then
        pet_level = list[i].pet_level
      end
      local myName = ""
      if DataMgr ~= nil and DataMgr.roleData ~= nil then
        myName = DataMgr.roleData.nickName
      end
      self.MVPSpawnPlayerRoleInfo = {
        uid = list[i].UID,
        sex = list[i].gamegender,
        headId = wear_ext[9] and wear_ext[9][1] or 0,
        index = i - 1,
        weaponId = wear_ext[13] and wear_ext[13][1] or 0,
        weaponSkinId = wear_ext[14] and wear_ext[14][1] or 0,
        weaponSkinDIYPlanId = wear_ext[14] and wear_ext[14][4] or 0,
        weaponPendantID = wear_ext[14] and wear_ext[14][6] and wear_ext[14][6][1] or 0,
        playerName = list[i].PlayerName,
        resultAvatarPose = list[i].resultAvatarPose or 0,
        PetId = pet_id,
        PetLevel = pet_level,
        BP_ARRAY_MVP_AvatarList = rolewear,
        isSelf = list[i].PlayerName == myName,
        Kill = list[i].Kills,
        Assists = list[i].Assists,
        Deaths = list[i].Deaths,
        DamageAmount = list[i].DamageAmount or 0,
        RescueTimes = list[i].rescueTimes or 0,
        surviveTime = list[i].surviveTime or 0,
        SupportScore = list[i].SupportScore or 0
      }
      self.ResultMvpAreaSegmentLevel = list[i].arena_segment_level or 0
      self.ResultMVPID = list[i].settl_motion
      self.MVPImprintID = list[i].MVPImprintID
      self.ResultTeamRank = 1
      self.MVPResultType = 1
      self.BattleResultShouldShowMVPScene = true
      self:GetMvpSignatureProfile()
      log_tree("InitMVPRoleInfo", self.MVPSpawnPlayerRoleInfo)
      return
    end
  end
end
function BattleResultShowMvpLogic:GetMvpSignatureProfile()
  print(bWriteLog and "BattleResultShowMvpLogic:GetMvpSignatureProfile")
  if self.MVPSpawnPlayerRoleInfo ~= nil then
    log(bWriteLog and "BattleResultShowMvpLogic.GetMvpSignatureProfile uid: " .. tostring(self.MVPSpawnPlayerRoleInfo.uid))
    local idlist = {}
    table.insert(idlist, self.MVPSpawnPlayerRoleInfo.uid)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(idlist, function(profileList)
      self:OnBatchGetProfileRsp(profileList)
    end, Enum_PROFILE_REPORT_CFG.RESULT_MVP)
  end
end
function BattleResultShowMvpLogic:OnBatchGetProfileRsp(profileList)
  print(bWriteLog and "BattleResultShowMvpLogic:OnBatchGetProfileRsp")
  if profileList[1] ~= nil and self.MVPPlayerProfile ~= nil then
    log_tree(bWriteLog and "ResultMVPUI.OnBatchGetProfileRsp", profileList[1])
    self.MVPPlayerProfile.Signature = profileList[1].signature or ""
    self.MVPPlayerProfile.UId = profileList[1].uid or 0
    self.MVPPlayerProfile.PicUrl = profileList[1].picUrl or ""
    self.MVPPlayerProfile.Level = profileList[1].level or 0
    self.MVPPlayerProfile.AvatarBoxId = profileList[1].cur_avatar_box_id or 0
    self.MVPPlayerProfile.AuthType = profileList[1].auth_type
    self.MVPPlayerProfile.AuthEndTime = profileList[1].auth_end_time
    EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_SHOW_MVP_PLAYER_PROFILE_UPDATE, self.MVPPlayerProfile)
  end
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CBattleResultShowMvpLogic = class(BattleResultProcessBaseLogic, nil, BattleResultShowMvpLogic)
return CBattleResultShowMvpLogic