local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UGameplayStatics = import("GameplayStatics")
local ENetRole = import("ENetRole")
local EBattleItemOperationType = import("EBattleItemOperationType")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local PlayEmoteFeature = {}
function PlayEmoteFeature:ctor()
  self.EmoteLevelList = slua.Array(UEnums.EPropertyClass.Int)
  self.CollectionList = slua.Array(UEnums.EPropertyClass.Int)
  self.PlacardList = slua.Array(UEnums.EPropertyClass.Int)
  self.PopularPKList = slua.Array(UEnums.EPropertyClass.Int)
  if Client then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    self.ClientCacheShowEmoteEffect = logic_emote.GetShowEffect_Battle()
    print(bWriteLog and "PlayEmoteFeature:ctor", self.ClientCacheShowEmoteEffect)
    self.EmoteLevelMap = {}
  else
    self.EffectEmoteIDList = {}
    self.EffectEmoteIDDicForSocialisland = {}
  end
  self.CollectionEmoteMap = {}
  self.ReliableEmoteList = {PlayEmoteFeature}
end
function PlayEmoteFeature:ReceiveBeginPlay()
  PlayEmoteFeature.__super.ReceiveBeginPlay(self)
end
function PlayEmoteFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "EmoteLevelList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "CollectionList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "PlacardList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "PopularPKList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
end
function PlayEmoteFeature:InitEmoteLevelInfo(tEmoteLevelMap)
  log_tree(bWriteLog and "PlayEmoteFeature:InitEmoteLevelInfo tEmoteLevelMap", tEmoteLevelMap)
  self.EmoteLevelMap = tEmoteLevelMap
  self.EffectEmoteIDList = {}
  for EmoteID, Level in pairs(tEmoteLevelMap) do
    if EmoteID and Level then
      self.EmoteLevelList:Add(EmoteID)
      self.EmoteLevelList:Add(Level)
      local EmoteConfig = CDataTable.GetTableData("ParticleEmoteCfg", EmoteID)
      if EmoteConfig and Level >= EmoteConfig.Level then
        local TypeSpecificID = EmoteConfig.EmoteIDLevel2
        self.EffectEmoteIDList[TypeSpecificID] = true
      end
    end
  end
  log_tree(bWriteLog and "PlayEmoteFeature:InitEmoteLevelInfo EffectEmoteIDList", self.EffectEmoteIDList)
end
function PlayEmoteFeature:InitCollectionList(tCollectionMap)
  log_tree(bWriteLog and "PlayEmoteFeature:InitCollectionList tCollectionMap", tCollectionMap)
  for idx, EmoteID in pairs(tCollectionMap) do
    if EmoteID then
      self.CollectionList:Add(EmoteID)
      self.CollectionEmoteMap[EmoteID] = true
    end
  end
end
function PlayEmoteFeature:InitPlacardList(extAttr)
  log_tree(bWriteLog and "PlayEmoteFeature:InitPlacardList extAttr", extAttr)
  for idx, EmoteID in pairs(extAttr) do
    if EmoteID then
      self.PlacardList:Add(EmoteID)
    end
  end
end
function PlayEmoteFeature:InitPopularPKList(extAttr)
  log_tree(bWriteLog and "PlayEmoteFeature:InitPopularPKList extAttr", extAttr)
  for idx, EmoteID in pairs(extAttr) do
    if EmoteID then
      self.PopularPKList:Add(EmoteID)
    end
  end
end
function PlayEmoteFeature:SetShowEmoteEffect(bShow)
  if bShow == self.ClientCacheShowEmoteEffect then
    return
  end
  self.ClientCacheShowEmoteEffect = bShow
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  logic_emote.RecordShowEffect_Battle(bShow)
end
function PlayEmoteFeature:OnRep_EmoteLevelList()
  local ArrayNum = self.EmoteLevelList:Num()
  print(bWriteLog and "PlayEmoteFeature:OnRep_EmoteLevelList", ArrayNum)
  if ArrayNum == 0 then
    return
  end
  self.EmoteLevelMap = {}
  for i = 0, ArrayNum / 2 - 1 do
    local EmoteID = self.EmoteLevelList:Get(i * 2)
    local level = self.EmoteLevelList:Get(i * 2 + 1)
    print(bWriteLog and "PlayEmoteFeature:OnRep_EmoteLevelList", i, EmoteID, level)
    if EmoteID and level then
      self.EmoteLevelMap[EmoteID] = level
    end
  end
end
function PlayEmoteFeature:OnRep_CollectionList()
  local ArrayNum = self.CollectionList:Num()
  print(bWriteLog and "PlayEmoteFeature:OnRep_CollectionList--", ArrayNum)
  if ArrayNum == 0 then
    return
  end
  for idx, EmoteID in pairs(self.CollectionList) do
    print(bWriteLog and "PlayEmoteFeature:OnRep_CollectionList", idx, EmoteID)
    self.CollectionEmoteMap[EmoteID] = true
  end
end
function PlayEmoteFeature:CheckIsValidEmoteIDBP(EmoteID)
  local bValid = false
  if self.EffectEmoteIDList[EmoteID] then
    bValid = true
  end
  if self.CollectionEmoteMap[EmoteID] then
    bValid = true
  end
  if bValid == false then
    for k, v in pairs(self.PlacardList) do
      if v == EmoteID then
        printf("PlayEmoteFeature:CheckIsValidEmoteIDBP true for placard: %s", EmoteID)
        bValid = true
        break
      end
    end
  end
  if self:CheckIsCardCollectionEmote(EmoteID) then
    bValid = true
  end
  if not bValid then
    for k, v in pairs(self.PopularPKList) do
      if v == EmoteID then
        printf("PlayEmoteFeature:CheckIsValidEmoteIDBP true for popularPK: %s", EmoteID)
        bValid = true
        break
      end
    end
  end
  if not bValid then
    local EGameModeType = import("EGameModeType")
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local GameState = GameplayData.GetGameState()
    if GameState.GameModeType == EGameModeType.ESocialIsland then
      if self.EffectEmoteIDDicForSocialisland[EmoteID] then
        bValid = true
      else
        local cfgList = CDataTable.GetTable("SocialIslandInteractEmote")
        for _, cfg in pairs(cfgList) do
          if cfg.MyEmote == EmoteID or cfg.TargetEmote == EmoteID or cfg.PrepareEmote == EmoteID then
            self.EffectEmoteIDDicForSocialisland[EmoteID] = true
            bValid = true
            break
          end
        end
      end
    end
  end
  if not bValid then
    local HighlightMomentConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig")
    if HighlightMomentConfig and HighlightMomentConfig.CheckFreeEmoteID and HighlightMomentConfig.CheckFreeEmoteID[EmoteID] then
      bValid = true
    end
  end
  bValid = bValid or self:CheckEmoteFromEquippedFeature(EmoteID)
  return bValid
end
function PlayEmoteFeature:CheckEmoteFromEquippedFeature(EmoteID)
  local uPlayerController = self.Owner and self.Owner.Object
  if not slua.isValid(uPlayerController) then
    return false
  end
  local uCharacter = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uCharacter) then
    return false
  end
  local uAvatarComp2 = uCharacter:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    return false
  end
  local AvatarItemIDListTable = uAvatarComp2:GetAllEquipItemsTable()
  if not AvatarItemIDListTable then
    return false
  end
  local StringUtil = require("common.string_util")
  for itemID, _ in pairs(AvatarItemIDListTable) do
    local featuresItems = CDataTable.GetTableData("FeaturesItems", itemID)
    if featuresItems and featuresItems.Features ~= "" then
      local features = StringUtil.Split(featuresItems.Features, ";")
      for _, featureIDStr in ipairs(features) do
        local featureID = tonumber(featureIDStr)
        if featureID then
          local featureCfg = CDataTable.GetTableData("FeaturesConfig", featureID)
          if featureCfg and featureCfg.FeatureType == 49 and featureCfg.FightExpressionID and featureCfg.FightExpressionID == EmoteID then
            printf("PlayEmoteFeature:CheckEmoteFromEquippedFeature true for itemID: %s, EmoteID: %s", itemID, EmoteID)
            return true
          end
        end
      end
    end
  end
  return false
end
function PlayEmoteFeature:CheckIsCardCollectionEmote(EmoteID)
  if not self.CardCollectionEmoteList then
    self.CardCollectionEmoteList = {}
    local ConfigList = CDataTable.GetTable("CardCollectionEmoteConfig")
    for _, Config in pairs(ConfigList) do
      self.CardCollectionEmoteList[Config.EmoteID] = true
    end
  end
  return self.CardCollectionEmoteList[EmoteID]
end
function PlayEmoteFeature:CheckNeedReliable(EmoteID)
  if self.ReliableEmoteList and self.ReliableEmoteList[EmoteID] then
    return true
  end
  return false
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPlayEmoteFeature = class(CFeatureBase, nil, PlayEmoteFeature)
return CPlayEmoteFeature