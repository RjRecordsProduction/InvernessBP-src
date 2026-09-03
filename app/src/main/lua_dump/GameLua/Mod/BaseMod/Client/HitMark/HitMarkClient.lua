local HitMarkClient = {}
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UGameplayStatics = import("GameplayStatics")
local HitMarkConfig = {HIT_MARK_STAY_TIME = 5.0, HIT_MARK_INTERVAL = 2.0}
function HitMarkClient:OnInit()
  self.HitMarkInfoMap = {}
  local uGameState = GameplayData.GetGameState()
  self.playerController = GameplayData.GetPlayerController()
  print(bWriteLog and "HitMarkClient:OnInit", uGameState, self.playerController)
  if slua.isValid(uGameState) then
    self.GameModeType = uGameState.GameModeType
    local EGameModeType = import("EGameModeType")
    print(bWriteLog and "HitMarkClient:OnInit", self.GameModeType, EGameModeType.EDeathMatchGameMode, EGameModeType.EVehicleWar_CAMP)
    if self.GameModeType and self.GameModeType ~= EGameModeType.EDeathMatchGameMode and self.GameModeType ~= EGameModeType.EVehicleWar_CAMP then
      self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_TAKE_DAMAGE_CLIENT, self.HandleTakeDamage, self)
    end
  end
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
  self.uSettingConfig = uGameFrontendHUD:GetUserSettings()
  if slua.isValid(self.playerController) and self.playerController.OnSpectatorChange then
    self:AddControlEvent(self.playerController, "OnSpectatorChange", self.OnSpectatorChange, self)
  end
end
function HitMarkClient:HandleTakeDamage(_, _, DamageInfo)
  if not DamageInfo then
    return
  end
  if DamageInfo.DamageType ~= UEnums.DamageType.ShootDamage and DamageInfo.DamageType ~= UEnums.DamageType.STPointDamage then
    return
  end
  if not slua.isValid(self.uSettingConfig) then
    local UIUtil = require("client.common.ui_util")
    local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
    self.uSettingConfig = uGameFrontendHUD:GetUserSettings()
  end
  if not slua.isValid(self.uSettingConfig) or not self.uSettingConfig.AutoHitMark then
    return
  end
  if slua.isValid(self.playerController) and slua.isValid(DamageInfo.Caster) and slua.isValid(DamageInfo.Target) and self.playerController:IsTeammate(DamageInfo.Caster) and not self.playerController:IsTeammate(DamageInfo.Target) then
    if slua.isValid(DamageInfo.Caster) and slua.isValid(DamageInfo.Caster.SkillManager) and DamageInfo.Caster.SkillManager:IsSkillActived(1014005) then
      print(bWriteLog and "HitMarkClient:HandleTakeDamage Ignore When DamageMark Skill", DamageInfo.Caster, DamageInfo.Target)
    elseif slua.isValid(DamageInfo.Caster) and DamageInfo.Caster:HasBuffID(430020) then
      print(bWriteLog and "HitMarkClient:HandleTakeDamage Ignore When DamageMark Buff", DamageInfo.Caster, DamageInfo.Target)
    else
      print(bWriteLog and "HitMarkClient:HandleTakeDamage3", DamageInfo.Caster, DamageInfo.Target)
      self:HandleMarkShoot(DamageInfo.Caster, DamageInfo.Target)
    end
  end
end
function HitMarkClient:HandleMarkShoot(uCauserPlayer, uTargetPlayer)
  if slua.isValid(uTargetPlayer) and slua.isValid(uCauserPlayer) then
    local teammateUID = uCauserPlayer.PlayerUID
    if nil == self.HitMarkInfoMap[teammateUID] then
      self.HitMarkInfoMap[teammateUID] = {}
      self.HitMarkInfoMap[teammateUID].ShowIndex = 0
    end
    local currentTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
    if self.HitMarkInfoMap[teammateUID].LastShowTime and currentTime <= self.HitMarkInfoMap[teammateUID].LastShowTime + HitMarkConfig.HIT_MARK_INTERVAL then
      return
    end
    self.HitMarkInfoMap[teammateUID].LastShowTime = currentTime
    if self.HitMarkInfoMap[teammateUID].TargetMarkAction then
      InGameMarkTools.HideMapMark(self.HitMarkInfoMap[teammateUID].TargetMarkAction)
      self.HitMarkInfoMap[teammateUID].TargetMarkAction = nil
    end
    if self.HitMarkInfoMap[teammateUID].HideTimer then
      self:RemoveGameTimer(self.HitMarkInfoMap[teammateUID].HideTimer)
      self.HitMarkInfoMap[teammateUID].HideTimer = nil
    end
    local bIsPVS, targetLoc = uTargetPlayer:GetFuzzyPosition(FVector(0, 0, 0))
    print(bWriteLog and "GetFuzzyPosition", bIsPVS)
    if not bIsPVS then
      targetLoc = uTargetPlayer:GetHeadLocation(false)
    end
    if targetLoc == nil then
      return
    end
    print(bWriteLog and "ClientLogic:HandleMarkShoot", uTargetPlayer.PlayerUID, targetLoc.X, targetLoc.Y, targetLoc.Z)
    self.HitMarkInfoMap[teammateUID].TargetMarkAction = InGameMarkTools.ClientAddMapMark(1003, targetLoc, 0, "", 4, nil)
    self.HitMarkInfoMap[teammateUID].HideTimer = self:AddGameTimer(HitMarkConfig.HIT_MARK_STAY_TIME, false, function()
      if self.HitMarkInfoMap and self.HitMarkInfoMap[teammateUID] then
        if self.HitMarkInfoMap[teammateUID].TargetMarkAction then
          InGameMarkTools.HideMapMark(self.HitMarkInfoMap[teammateUID].TargetMarkAction)
          self.HitMarkInfoMap[teammateUID].TargetMarkAction = nil
        end
        if self.HitMarkInfoMap[teammateUID].HideTimer then
          self:RemoveGameTimer(self.HitMarkInfoMap[teammateUID].HideTimer)
          self.HitMarkInfoMap[teammateUID].HideTimer = nil
        end
      end
    end)
  end
end
function HitMarkClient:OnSpectatorChange()
  print(bWriteLog and "HitMarkClient:OnSpectatorChange")
  self:OnRelease()
end
function HitMarkClient:OnRelease()
  print(bWriteLog and "HitMarkClient:OnRelease")
  HitMarkClient.__super.OnRelease(self)
  if self.HitMarkInfoMap then
    for _, info in pairs(self.HitMarkInfoMap) do
      if info.TargetMarkAction then
        InGameMarkTools.HideMapMark(info.TargetMarkAction)
        info.TargetMarkAction = nil
      end
      if info.HideTimer then
        self:RemoveGameTimer(info.HideTimer)
        info.HideTimer = nil
      end
    end
  end
  self.HitMarkInfoMap = nil
  self.playerController = nil
  self.uSettingConfig = nil
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, HitMarkClient)