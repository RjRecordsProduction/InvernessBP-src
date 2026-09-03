local BattleResultChickenDrawLogic = {}
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local CloseDelayTime = 2
function BattleResultChickenDrawLogic:OnInit()
  print(bWriteLog and "BattleResultChickenDrawLogic:OnInit")
end
function BattleResultChickenDrawLogic:OnRelease()
  print(bWriteLog and "BattleResultChickenDrawLogic:OnRelease")
end
function BattleResultChickenDrawLogic:OnBattleResult(result)
  print(bWriteLog and "BattleResultChickenDrawLogic:OnBattleResult sub_mode:" .. tostring(result.sub_mode) .. " battle_owner:" .. tostring(result.battle_owner))
  local commonData = self:GetBattleResultData()
  self.ChickenDrawData = {
    sub_mode = result.sub_mode,
    battle_type = result.battle_type,
    MyName = commonData.BP_myname,
    Rating = result.Rating,
    TotalPlayerCount = result.TotalPlayerCount,
    TotalTeamCount = result.TotalTeamCount,
    peakgame_team_rank = result.peakgame_team_rank,
    team_rank = result.team_rank,
    person_rank = result.person_rank,
    is_team_result = result.is_team_result,
    Reason = result.Reason
  }
  self.Reason = result.Reason
end
function BattleResultChickenDrawLogic:OnResultProcessStart()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  print(bWriteLog and "BattleResultChickenDrawLogic:OnResultProcessStart", slua.isValid(uPlayerController) and uPlayerController.CharacterTouchMove or false)
  if slua.isValid(uPlayerController) and uPlayerController.ShowTouchInterface then
    uPlayerController.CharacterTouchMove = false
    uPlayerController:ShowTouchInterface(false)
    uPlayerController:CastUIMsg("MainControlPanel_HideAllUI", "ingame")
  end
  if not self:OnSwitchCheck() then
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config_InGame.BattleResultChickenUI, self.ChickenDrawData)
  self.CloseTimer = self:AddGameTimer(CloseDelayTime, false, function()
    self:EndResultProcess()
  end)
  return true
end
function BattleResultChickenDrawLogic:OnResultProcessEnd()
  print(bWriteLog and "BattleResultChickenDrawLogic:OnResultProcessEnd", self.CloseTimer)
  UIManager.CloseUI(UIManager.UI_Config_InGame.BattleResultChickenUI)
  if self.CloseTimer then
    self:RemoveGameTimer(self.CloseTimer)
    self.CloseTimer = nil
  end
end
function BattleResultChickenDrawLogic:OnSwitchCheck()
  print(bWriteLog and "BattleResultChickenDrawLogic:OnSwitchCheck", self.Reason)
  EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT)
  return self.Reason == "win"
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CBattleResultChickenDrawLogic = class(BattleResultProcessBaseLogic, nil, BattleResultChickenDrawLogic)
return CBattleResultChickenDrawLogic