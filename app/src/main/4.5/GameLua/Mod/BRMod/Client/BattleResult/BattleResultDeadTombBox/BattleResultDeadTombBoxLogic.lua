local BattleResultDeadTombBoxLogic = {}
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
function BattleResultDeadTombBoxLogic:OnInit()
  print(bWriteLog and "BattleResultDeadTombBoxLogic:OnInit")
  self.isDead = false
  self.ShowDeadTombBoxTimer = 5
  self.ShowDeadTombBoxTimeObjId = 0
end
function BattleResultDeadTombBoxLogic:OnRelease()
  print(bWriteLog and "BattleResultDeadTombBoxLogic:OnRelease")
  self.ShowDeadTombBoxTimeObjId = 0
end
function BattleResultDeadTombBoxLogic:OnBattleResult(result)
  print(bWriteLog and "BattleResultDeadTombBoxLogic:OnBattleResult sub_mode:" .. tostring(result.sub_mode) .. " battle_owner:" .. tostring(result.battle_owner))
  if result.Reason == "win" then
    self.isDead = false
  else
    self.isDead = true
  end
end
function BattleResultDeadTombBoxLogic:OnSwitchCheck()
  local is_ob = false
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsSpectator and uPlayerController.IsInPetSpectator then
    print(bWriteLog and "BattleResultDeadTombBoxLogic:OnSwitchCheck", uPlayerController:IsSpectator(), uPlayerController.bIsForReplay, uPlayerController:IsInPetSpectator())
    if uPlayerController:IsSpectator() or uPlayerController.bIsForReplay or uPlayerController:IsInPetSpectator() then
      is_ob = true
    end
  end
  return self.isDead and not is_ob
end
function BattleResultDeadTombBoxLogic:OnResultProcessStart()
  print(bWriteLog and "BattleResultDeadTombBoxLogic:OnResultProcessStart")
  self.ShowDeadTombBoxTimeObjId = self:AddGameTimer(self.ShowDeadTombBoxTimer, false, function()
    self.ShowDeadTombBoxTimeObjId = 0
    self:OnShowDeadTombBoxEnd()
  end)
  return true
end
function BattleResultDeadTombBoxLogic:OnPostReconnection(curProcessIndex)
  print(bWriteLog and "BattleResultDeadTombBoxLogic:OnPostReconnection", curProcessIndex)
end
function BattleResultDeadTombBoxLogic:OnShowDeadTombBoxEnd()
  print(bWriteLog and "BattleResultDeadTombBoxLogic:OnShowDeadTombBoxEnd Executing:" .. tostring(self:ResultProcessExecuting()))
  if not self:ResultProcessExecuting() then
    return
  end
  if self.ShowDeadTombBoxTimeObjId ~= 0 then
    self:RemoveGameTimer(self.ShowDeadTombBoxTimeObjId)
    self.ShowDeadTombBoxTimeObjId = 0
  end
  self:EndResultProcess()
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CBattleResultDeadTombBoxLogic = class(BattleResultProcessBaseLogic, nil, BattleResultDeadTombBoxLogic)
return CBattleResultDeadTombBoxLogic