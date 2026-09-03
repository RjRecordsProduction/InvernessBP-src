local GameStateThemeSkillItemFeature = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function GameStateThemeSkillItemFeature:ctor()
  self.DisableSoonTime = 0
  self.DisableTime = 0
  self.bHasDisable = false
  self.DisableItems = slua.Array(UEnums.EPropertyClass.Int)
end
function GameStateThemeSkillItemFeature:_PostConstruct()
  GameStateThemeSkillItemFeature.__super._PostConstruct(self)
end
function GameStateThemeSkillItemFeature:ReceiveBeginPlay()
  GameStateThemeSkillItemFeature.__super.ReceiveBeginPlay(self)
  self:InitThemePropsConfig()
end
function GameStateThemeSkillItemFeature:InitThemePropsConfig()
  if Client then
    return
  end
  self.DisableSoonTime = 0
  self.DisableTime = 0
  self.bHasDisable = false
  local DisableItems = self.DisableItems
  DisableItems:Clear()
  local ThemeSkillItemConfig = GamePlayTools.GetCurrentConfig("ThemeSkillItemConfig")
  local MapType = GameMainConfig.GetMapType()
  if not ThemeSkillItemConfig then
    print(bWriteLog and "GameStateThemeSkillItemFeature:InitThemePropsConfig ThemeSkillItemConfig is nil! MapType=" .. tostring(MapType))
    return
  end
  local DisableCfg = ThemeSkillItemConfig.DisableCfg[MapType]
  print(bWriteLog and "GameStateThemeSkillItemFeature:InitThemePropsConfig:" .. tostring(MapType))
  if not DisableCfg then
    print(bWriteLog and "GameStateThemeSkillItemFeature:InitThemePropsConfig DisableCfg is nil")
    return
  end
  self.DisableSoonTime = DisableCfg.DisableSoonTime
  self.DisableTime = DisableCfg.DisableTime
  for _, ItemID in pairs(DisableCfg.DisableItems) do
    DisableItems:Add(ItemID)
  end
  self.  if self.DisableSoonTime > 0 then
    self:AddGameTimer(self.DisableSoonTime, false, function()
      print(bWriteLog and "GameStateThemeSkillItemFeature:InitThemePropsConfig:DisableSoon:" .. tostring(CGameState:GetServerWorldTimeSeconds()))
      local uPlayerCharacterArray = Game:GetAllPlayerPawns()
      for _, uPlayerCharacter in pairs(uPlayerCharacterArray) do
        if slua.isValid(uPlayerCharacter) and DisableCfg.DisableSoonTipsID > 0 then
          local uPlayerController = uPlayerCharacter:GetPlayerControllerSafety()
          if slua.isValid(uPlayerController) then
            IngameTipsTools.BattleGeneralTip(DisableCfg.DisableSoonTipsID, "", "", uPlayerController.PlayerKey, false)
          end
        end
      end
    end)
  end
  if self.DisableTime > 0 then
    self:AddGameTimer(self.DisableTime, false, function()
      print(bWriteLog and "GameStateThemeSkillItemFeature:InitThemePropsConfig:Disable:" .. tostring(CGameState:GetServerWorldTimeSeconds()))
      local uPlayerCharacterArray = Game:GetAllPlayerPawns()
      for _, uPlayerCharacter in pairs(uPlayerCharacterArray) do
        if slua.isValid(uPlayerCharacter) then
          if DisableCfg.DisableTipsID > 0 then
            local uPlayerController = uPlayerCharacter:GetPlayerControllerSafety()
            if slua.isValid(uPlayerController) then
              IngameTipsTools.BattleGeneralTip(DisableCfg.DisableTipsID, "", "", uPlayerController.PlayerKey, false)
            end
          end
          uPlayerCharacter:SetSkillIDsDisable(DisableCfg.DisableSkills, true, "ThemeSkillItemDisable")
        end
      end
      self.bHasDisable = true
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_THEME_SKILLITEM_DISABLE)
    end)
  end
end
function GameStateThemeSkillItemFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "DisableSoonTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "DisableTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "DisableItems",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "bHasDisable",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
end
function GameStateThemeSkillItemFeature:OnRep_bHasDisable()
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_THEME_SKILLITEM_DISABLE)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, GameStateThemeSkillItemFeature)