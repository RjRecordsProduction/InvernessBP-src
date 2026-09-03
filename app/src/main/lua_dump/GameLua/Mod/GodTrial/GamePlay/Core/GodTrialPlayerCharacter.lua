local GodTrialPlayerCharacter = {
  LuaEventContainer = {
    "EVENTID_TAKE_DAMAGE"
  }
}
function GodTrialPlayerCharacter:ctor()
  self.bOnNTPreheat = false
  self.CacheNTPreHeatActor = nil
end
function GodTrialPlayerCharacter:_PostConstruct()
  GodTrialPlayerCharacter.__super._PostConstruct(self)
end
function GodTrialPlayerCharacter:ReceiveBeginPlay()
  GodTrialPlayerCharacter.__super.ReceiveBeginPlay(self)
  if Client then
    local EPawnState = import("EPawnState")
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) and not uPlayerController:IsSpectator() and uPlayerController:GetPlayerCharacterSafety() == self.Object then
      do
        local HandleOnCharacterEnterState = function(self, uCharacter, state)
          if state == EPawnState.InParachute then
            FuncUtil.UE4ExecuteConsoleCommand("a.newLimitPitch 0")
          end
        end
        local HandleOnCharacterExitState = function(self, uCharacter, state)
          if state == EPawnState.InParachute then
            FuncUtil.UE4ExecuteConsoleCommand("a.newLimitPitch 1")
          end
        end
        self:AddControlEvent(self, "OnCharacterEnterState", HandleOnCharacterEnterState, self)
        self:AddControlEvent(self, "OnCharacterExitState", HandleOnCharacterExitState, self)
      end
    end
  end
end
function GodTrialPlayerCharacter:GetLifetimeReplicatedProps()
  local BaseRepTable = GodTrialPlayerCharacter.__super.GetLifetimeReplicatedProps(self) or {}
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "bOnNTPreheat",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function GodTrialPlayerCharacter:OnRep_bOnNTPreheat()
  print(bWriteLog and "GodTrialPlayerCharacter:OnRep_bOnNTPreheat, bOnNTPreheat = " .. tostring(self.bOnNTPreheat) .. ", PlayerKey = " .. tostring(self.PlayerKey))
end
function GodTrialPlayerCharacter:ReceiveEndPlay(EndPlayReason)
  GodTrialPlayerCharacter.__super.ReceiveEndPlay(self, EndPlayReason)
end
function GodTrialPlayerCharacter:HandleOnRespawn()
  GodTrialPlayerCharacter.__super.HandleOnRespawn(self)
  print(bWriteLog and "ZNQ8thPlayerCharacter:OnSelfDeath")
  self:SetAttrValue("MapID", 0, -1)
  self:SetAttrValue("AreaID", 0, -1)
  local uPlayerState = self:GetPlayerStateSafety()
  if slua.isValid(uPlayerState) then
    uPlayerState.MapID = 0
  end
end
function GodTrialPlayerCharacter:CharacterAttrChangeEvent(uPawn, AttrName, AttrVal)
  GodTrialPlayerCharacter.__super.CharacterAttrChangeEvent(self, uPawn, AttrName, AttrVal)
  if self.Object == uPawn and AttrName == "MapID" and self:IsAuthority() then
    local uPlayerState = self:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      uPlayerState.MapID = AttrVal
    end
  end
end
function GodTrialPlayerCharacter:DoModChangeToBT()
  GodTrialPlayerCharacter.__super.DoModChangeToBT(self)
  print(bWriteLog and string.format("GodTrialPlayerCharacter:DoModChangeToBT, PlayerKey=%s", tostring(self.PlayerKey)))
  if self.GetSkillManager then
    local uSkillManager = self:GetSkillManager()
    if slua.isValid(uSkillManager) then
      local CurSkillID = uSkillManager:GetCurSkillID()
      if CurSkillID and CurSkillID == 4401003 then
        local EUAESkillEvent = import("EUAESkillEvent")
        uSkillManager:TriggerCurSkillEvent(EUAESkillEvent.PlayerRequestCancel, -1)
        print(bWriteLog and string.format("GodTrialPlayerCharacter:DoModChangeToBT, PlayerKey=%s, CurSkillID == 4401003", tostring(self.PlayerKey)))
      end
    end
  end
end
local class = require("class")
local CCharacterBase = require("GameLua.Mod.BRMod.Gameplay.Core.BRPlayerCharacterBase")
local CGodTrialPlayerCharacter = class(CCharacterBase, nil, GodTrialPlayerCharacter)
return require("combine_class").DeclareFeature(CGodTrialPlayerCharacter, {
  {
    TrialFeature = "GameLua.Mod.GodTrial.Gameplay.Feature.PlayerCharacterTrialFeature"
  },
  {
    MercenaryFeature = "GameLua.ExtraModule.MLAI.Mercenary.Feature.PlayerCharacterMercenaryFeature"
  },
  {
    PlayerAttachToFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.PlayerAttachToFeature"
  },
  {
    FramePlatformFeature = "GameLua.Mod.GodTrial.Gameplay.Feature.PlayerCharacterFramePlatformFeature"
  },
  {
    BattleFlagFeature = "GameLua.ExtraModule.SkillCore.Gameplay.BattleFlag.Feature.PlayerCharacterBattleFlagFeature"
  },
  {
    StrongestSquadFeature = "GameLua.Mod.Library.GamePlay.Feature.StrongestSquad.CharacterStrongestSquadFeature"
  }
}, "GodTrialPlayerCharacter")