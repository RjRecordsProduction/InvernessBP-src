local UGCLevelFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function UGCLevelFeature:ctor()
  self.UGCLevel = -1
  self.UGCConfigID = 0
end
function UGCLevelFeature:_PostConstruct()
  UGCLevelFeature.__super._PostConstruct(self)
end
function UGCLevelFeature:ReceiveBeginPlay()
  print(bWriteLog and "UGCLevelFeature:ReceiveBeginPlay")
  UGCLevelFeature.__super.ReceiveBeginPlay(self)
end
function UGCLevelFeature:ReceiveEndPlay()
  print(bWriteLog and "UGCLevelFeature:ReceiveEndPlay")
  UGCLevelFeature.__super.ReceiveEndPlay(self)
end
function UGCLevelFeature:InitUGCLevelFeature(UGCConfigID, Level)
  if not Level then
    print(bWriteLog and "UGCLevelFeature:InitUGCLevelFeature ,Level = nil")
    Level = 1
  end
  if self.Owner.ChangeAttributeFeature then
    self.bFakePlayer = true
  else
    self.bFakePlayer = false
  end
  self.  self:SetLevel(Level)
  print(bWriteLog and "UGCLevelFeature:Init ,UGCConfigID = %s,, Level = %s", tostring(UGCConfigID), tostring(Level))
end
function UGCLevelFeature:SetLevel(Level)
  if not self:HasAuthority() then
    return
  end
  print(bWriteLog and "UGCLevelFeature:SetLevel ,Level = %s", Level)
  local CodePlan = 0
  if self.bFakePlayer then
    local CreativeModeCustomFakePlayerSubsystem = SubsystemMgr:Get("CreativeModeCustomFakePlayerSubsystem")
    local Config = CreativeModeCustomFakePlayerSubsystem:GetCustomFakePlayerConfig(self.UGCConfigID)
    CodePlan = Config.FakePlayerAttributeCode
    if Level > Config.FakePlayerMaxLevel then
      Level = Config.FakePlayerMaxLevel
      printf(bWriteLog and "UGCLevelFeature:SetLevel ,Level > MaxLevel,Force set to MaxLevel,NewLevel = " .. Level)
    end
  else
    local CreativeModeCustomMonsterSubsystem = SubsystemMgr:Get("CreativeModeCustomMonsterSubsystem")
    local Config = CreativeModeCustomMonsterSubsystem:GetCustomMonsterConfig(self.UGCConfigID)
    if Config then
      CodePlan = Config.MonsterAttributeCode
      if Level > Config.MonsterMaxLevel then
        Level = Config.MonsterMaxLevel
        printf(bWriteLog and "UGCLevelFeature:SetLevel ,Level > MaxLevel,Force set to MaxLevel,NewLevel = " .. Level)
      end
    end
  end
  self.UGC  if self.Owner and self.Owner.Object then
    EventSystem:postEvent(EVENTTYPE_CREATIVE, EVENTID_PAWN_UGCLEVEL_CHANGED, self.Owner.Object, Level, CodePlan, self.bFakePlayer)
  end
end
function UGCLevelFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "UGCLevel",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
  if UGCLevelFeature.__super.GetLifetimeReplicatedProps then
    local BaseRepTable = UGCLevelFeature.__super.GetLifetimeReplicatedProps(self)
    table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  end
  return RepTable
end
function UGCLevelFeature:OnRep_UGCLevel(OldLevel)
  printf(bWriteLog and "UGCLevelFeature:OnRep_Level ,Level = %s", self.UGCLevel)
  if self.Owner then
    local Pawn = self.Owner.Object
    if Pawn then
      local BossUI = UIManager.GetUI(UIManager.UI_Config_InGame.IngameHPUIBase)
      if BossUI and BossUI.CurFocusActor == Pawn then
        print(bWriteLog and "UGCLevelFeature:OnRep_Level ,Update HPBar")
        EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_ADD_HPBAR, Pawn)
      end
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, UGCLevelFeature)