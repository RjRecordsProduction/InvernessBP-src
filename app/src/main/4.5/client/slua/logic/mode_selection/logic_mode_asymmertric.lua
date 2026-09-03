local logic_mode_asymmertric = {}
local ENUM_CAMP = {
  Hunter = 1,
  Survivor = 2,
  Random = 3
}
local AsymModViewID = 90112
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
function logic_mode_asymmertric:OnInitialize()
  self.leftDialogCount = {}
  self.totalDialogCount = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionAsym) or {}
  self.campType = saveData.campType or 2
  self.bIsRandomCamp = saveData.bIsRandomCamp or false
end
function logic_mode_asymmertric:RegistEvents()
  logic_mode_asymmertric.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ADD_OTHER_PLAYER, self.OnTeamChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_JOIN_TEAM, self.OnTeamChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREATE_TEAM, self.OnTeamChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT, self.OnTeamChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_EXIT_OTHER_PLAYER, self.OnTeamChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.OnTeamChange, self)
end
function logic_mode_asymmertric:GetCamp()
  return self.campType
end
function logic_mode_asymmertric:GetCampForMatch()
  if TeamUpNewSystem.GetTeamNum() > 1 then
    return ENUM_CAMP.Survivor
  end
  if self.bIsRandomCamp then
    return ENUM_CAMP.Random
  end
  return self.campType
end
function logic_mode_asymmertric:GetIsHunter()
  return self.campType == ENUM_CAMP.Hunter
end
function logic_mode_asymmertric:SetCamp(campType)
  if TeamUpNewSystem.GetTeamNum() > 1 then
    campType = ENUM_CAMP.Survivor
  end
  self.  self:SavaFile()
end
function logic_mode_asymmertric:GetHasSelectedCamp()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local _, subViewId = logic_mode_selection:GetCurSelectInfo()
  return subViewId and subViewId == AsymModViewID
end
function logic_mode_asymmertric:GetIsRandomCamp()
  if TeamUpNewSystem.GetTeamNum() > 1 then
    self.bIsRandomCamp = false
  end
  return self.bIsRandomCamp
end
function logic_mode_asymmertric:SetIsRandomCamp(bIsRandom)
  log(bWriteLog and string.format("logic_mode_asymmertric:SetIsRandomCamp %s =bIsRandom %s", bIsRandom, TeamUpNewSystem.GetTeamNum()))
  if TeamUpNewSystem.GetTeamNum() > 1 then
    bIsRandom = false
  end
  self.bIsRandomCamp = bIsRandom
  self:SavaFile()
end
function logic_mode_asymmertric:SavaFile()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionAsym) or {}
  saveData.campType = self.campType
  saveData.bIsRandomCamp = self.bIsRandomCamp
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionAsym)
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_ASYM_INFO_CHANGE, self.campType, self.bIsRandomCamp)
  printf("logic_mode_asymmertric:SavaFile campType = %s, bIsRandomCamp = %s", self.campType, self.bIsRandomCamp)
  if self:GetIsHunter() then
    local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
    local recruitInfo = TeamPlatformSystem.GetRecruitInfo()
    if recruitInfo then
      log_tree("logic_mode_asymmertric:SavaFile recruitInfo = %s", recruitInfo)
      local conscribe = recruitInfo.conscribe
      if conscribe then
        local mode = conscribe.mode
        if mode == 64814 then
          local logic_lobby_my_team = require("client.slua.logic.teamup.logic_lobby_my_team")
          logic_lobby_my_team.CancelRecruit()
          ShowNotice(78281)
        end
      end
    end
  end
end
function logic_mode_asymmertric:GetCampEnum()
  return ENUM_CAMP
end
function logic_mode_asymmertric:OnTeamChange()
  if not self:GetHasSelectedCamp() then
    return
  end
  if TeamUpNewSystem.GetTeamNum() <= 1 then
    return
  end
  local needChange = false
  if self.campType ~= ENUM_CAMP.Survivor then
    self.campType = ENUM_CAMP.Survivor
    needChange = true
  end
  if self.bIsRandomCamp then
    self.bIsRandomCamp = false
    needChange = true
  end
  if needChange then
    ShowNotice(4002106)
    self:SavaFile()
  end
end
function logic_mode_asymmertric:GetCareerData()
  return self.career_data
end
local descList = {
  num = LocUtil.GetLocalizeResStr(4002049),
  win_ratio = LocUtil.GetLocalizeResStr(4002050),
  hunted_survivor = LocUtil.GetLocalizeResStr(4002051),
  behavior_score = LocUtil.GetLocalizeResStr(4002052),
  hunter_kill = LocUtil.GetLocalizeResStr(4002053)
}
function logic_mode_asymmertric:GetHunterScoreDetail()
  log(bWriteLog and "logic_escape_camp_score:GetHunterScoreDetail")
  local data = self.career_data
  data = data or {}
  local scoreData = {
    [1] = {
      desc = descList.num,
      score = data.hunter_game_num or "-"
    },
    [2] = {
      desc = descList.win_ratio,
      score = data.hunter_win_ratio and LocUtil.LocalizeResFormat(20082, string.format("%.1f", data.hunter_win_ratio * 100)) or "-"
    },
    [3] = {
      desc = descList.hunter_kill,
      score = data.hunter_avg_kill_num and string.format("%.1f", data.hunter_avg_kill_num) or "-"
    },
    [4] = {
      desc = descList.behavior_score,
      score = data.hunter_avg_behavior_score and string.format("%.1f", data.hunter_avg_behavior_score) or "-"
    }
  }
  return scoreData
end
function logic_mode_asymmertric:GetSurvivorScoreDetail()
  local data = self.career_data
  log(bWriteLog and "logic_escape_camp_score:GetHuntedScoreDetail")
  if not data then
    log(bWriteLog and "logic_escape_camp_score.GetHuntedScoreDetail: data is nil")
    data = {}
  end
  local scoreData = {
    [1] = {
      desc = descList.num,
      score = data.hunted_game_num or "-"
    },
    [2] = {
      desc = descList.win_ratio,
      score = data.hunted_win_ratio and LocUtil.LocalizeResFormat(20082, string.format("%.1f", data.hunted_win_ratio * 100)) or "-"
    },
    [3] = {
      desc = descList.hunted_survivor,
      score = data.hunted_avg_survivor_ratio and LocUtil.LocalizeResFormat(20082, string.format("%.1f", data.hunted_avg_survivor_ratio * 100)) or "-"
    },
    [4] = {
      desc = descList.behavior_score,
      score = data.hunted_avg_behavior_score and string.format("%.1f", data.hunted_avg_behavior_score) or "-"
    }
  }
  return scoreData
end
function logic_mode_asymmertric:GetSurvivorTotalScore()
  local data = self.career_data
  log(bWriteLog and "logic_escape_camp_score:GetSurvivorTotalScore")
  if not data then
    log(bWriteLog and "logic_escape_camp_score.GetHuntedTotalScore: data is nil")
    return 0
  end
  return data.hunted_rating or 0
end
function logic_mode_asymmertric:GetHunterTotalScore()
  local data = self.career_data
  log(bWriteLog and "logic_escape_camp_score:GetHunterTotalScore")
  if not data then
    log(bWriteLog and "logic_escape_camp_score.GetHunterTotalScore: data is nil")
    return 0
  end
  return data.hunter_rating or 0
end
function logic_mode_asymmertric:proc_get_hunter_vs_hunted_career_data_rsp(career_data)
  self.  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_ASYM_CAREER_INFO, self.career_data)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_mode_asymmertric)