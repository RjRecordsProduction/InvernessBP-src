local BattleResultMedalDisplayLogic = {}
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function BattleResultMedalDisplayLogic:OnInit()
  print(bWriteLog and "BattleResultMedalDisplayLogic:OnInit")
  self.battle_id = 0
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_CLOSE_MEDAL_DISPLAY, self.OnMedalDisplayUIClose, self)
end
function BattleResultMedalDisplayLogic:OnRelease()
  print(bWriteLog and "BattleResultMedalDisplayLogic:OnRelease")
  if UIManager.UI_Config_InGame.BattleResultMedalDisplayUI then
    UIManager.CloseUI(UIManager.UI_Config_InGame.BattleResultMedalDisplayUI)
  end
end
function BattleResultMedalDisplayLogic:OnBattleResult(result)
  print(bWriteLog and "BattleResultMedalDisplayLogic:OnBattleResult sub_mode:" .. tostring(result.sub_mode) .. " battle_owner:" .. tostring(result.battle_owner))
  self.TeammateList = result.TeammateList
  local CommonData = self:GetBattleResultData()
  if CommonData and CommonData.MedalConfig then
    self.MedalConfig = CommonData.MedalConfig
  end
  self.AchievementList = {}
  for i, info in pairs(self.TeammateList) do
    if CommonData.BP_myname == info.Name and info.Achievements and self.MedalConfig then
      for _, i in pairs(self.MedalConfig.MedalIndexList) do
        if info.Achievements[i] then
          local data = info.Achievements[i]
          data.Type = i
          table.insert(self.AchievementList, data)
        end
      end
      break
    end
  end
  table.sort(self.AchievementList, function(a, b)
    return (a.Priority or 99) < (b.Priority or 99)
  end)
  self.MedalDisplayData = {
    TeammateList = result.TeammateList,
    sub_mode = result.sub_mode,
    battle_type = result.battle_type,
    MyName = CommonData.BP_myname,
    Rating = result.Rating,
    AchievementList = self.AchievementList,
    TotalTeamCount = result.TotalTeamCount,
    peakgame_team_rank = result.peakgame_team_rank,
    team_rank = result.team_rank,
    person_rank = result.person_rank,
    is_team_result = result.is_team_result,
    TotalPlayerCount = result.TotalPlayerCount,
    Reason = result.Reason,
    BP_TeamModeName = CommonData.BP_TeamModeName
  }
end
function BattleResultMedalDisplayLogic:OnResultProcessStart()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  print(bWriteLog and "BattleResultMedalDisplayLogic:OnResultProcessStart", slua.isValid(uPlayerController) and uPlayerController.CharacterTouchMove or false)
  if slua.isValid(uPlayerController) and uPlayerController.ShowTouchInterface then
    uPlayerController.CharacterTouchMove = false
    uPlayerController:ShowTouchInterface(false)
  end
  if not self:OnSwitchCheck() then
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config_InGame.BattleResultMedalDisplayUI, self.MedalDisplayData)
  return true
end
function BattleResultMedalDisplayLogic:OnMedalDisplayUIClose()
  print(bWriteLog and "BattleResultMedalDisplayLogic:OnMedalDisplayUIClose")
  self:EndResultProcess()
end
function BattleResultMedalDisplayLogic:OnSwitchCheck()
  return self.AchievementList and #self.AchievementList > 0
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CBattleResultMedalDisplayLogic = class(BattleResultProcessBaseLogic, nil, BattleResultMedalDisplayLogic)
return CBattleResultMedalDisplayLogic