local LogicPetCfg = {}
local Trait = require("common.trait")
local TLogicPetCfg = Trait(Trait.TraitPrototype, nil, LogicPetCfg)
local EActionPattern = import("EPetActionPattern")
local PetExhibitConfig = require("client.lobby_ue_object.Actor.PetExhibit.PetExhibitConfig")
local DEFAULT_EFFECT_CFG = {
  Appear = PetExhibitConfig.PetAppear,
  PetDisappear = PetExhibitConfig.PetDisappear,
  Scale = 1.0
}
local BuildPetConfig = function(v)
  local temp = {
    PetID = v.PetID,
    PetName = v.PetName,
    PetMaxLevel = v.PetMaxLevel,
    FoodCnt = v.FoodCnt,
    BrandLogo = v.BrandLogo,
    Foods = {
      [1] = v.FoodID1,
      [2] = v.FoodID2,
      [3] = v.FoodID3
    },
    JumpType = v.JumpType,
    JumpUrl = v.JumpUrl,
    PetImage = v.PetImage,
    ShareBgUrl = v.ShareBgUrl,
    DefaultAction = v.DefaultAction,
    EatAction = v.EatAction,
    ClickAction = v.ClickAction,
    IndiaShareBgUrl = v.IndiaShareBgUrl
  }
  log(bWriteLog and "BuildPetConfig PetID:" .. v.PetID)
  return temp
end
local BuildPetLevelItemCfg = function(v)
  local temp = {
    KeyID = v.KeyID,
    PetID = v.PetID,
    PetLevel = v.PetLevel,
    PetNeedExp = v.PetNeedExp,
    PetLevelRewards = v.PetLevelRewards or "",
    ActionCnt = v.ActionCnt,
    Actions = {
      [1] = v.ActionID1,
      [2] = v.ActionID2,
      [3] = v.ActionID3,
      [4] = v.ActionID4,
      [5] = v.ActionID5
    },
    AllAction = v.AllAction,
    LobbyPetBP = v.LobbyPetBP
  }
  log(bWriteLog and "BuildPetLevelItemCfg LobbyPetBP:" .. v.LobbyPetBP)
  return temp
end
function LogicPetCfg:GetFoodCfg()
  if self.FoodCfg == nil then
    self.FoodCfg = {}
    for _, v in pairs(CDataTable.GetTable("FoodTable")) do
      local temp = {}
      temp.FoodID = v.FoodID
      temp.FoodAddExp = v.FoodAddExp
      table.insert(self.FoodCfg, temp)
    end
  end
  return self.FoodCfg
end
function LogicPetCfg:GetPetCfgs()
  if self.PetCfg == nil then
    self.PetCfg = {}
    for _, v in pairs(CDataTable.GetTable("PetTable")) do
      local temp = BuildPetConfig(v)
      table.insert(self.PetCfg, temp)
    end
  end
  return self.PetCfg
end
function LogicPetCfg:GetPetLevelCfg()
  if self.PetLevelCfg == nil then
    self.PetLevelCfg = {}
    for _, v in pairs(CDataTable.GetTable("PetLevelTable")) do
      local temp = BuildPetLevelItemCfg(v)
      table.insert(self.PetLevelCfg, temp)
    end
  end
  return self.PetLevelCfg
end
function LogicPetCfg:GetPetActionCfg()
  self.PetActionMap = self.PetActionMap or {}
  if self.PetActionCfg == nil then
    self.PetActionCfg = {}
    for _, v in pairs(CDataTable.GetTable("PetActionTable")) do
      self.PetActionMap[v.PetID] = self.PetActionMap[v.PetID] or {}
      table.insert(self.PetActionMap[v.PetID], v.PetActionID)
      if v.IsShowInWorkshop == 1 then
        local temp = {
          PetActionID = v.PetActionID,
          PetID = v.PetID,
          PetActionName = v.PetActionName,
          PetActionQuality = v.PetActionQuality,
          PetActionDes = v.PetActionDes,
          SortKey = v.SortKey,
          PetAnimRes = v.PetAnimRes,
          PetActionIcon = v.PetActionIcon,
          ShowInLobby = v.ShowInLobby
        }
        table.insert(self.PetActionCfg, temp)
      end
    end
    if self.ActionDressMap == nil then
      self:GetActionDressMap()
    end
    table.sort(self.PetActionCfg, function(a, b)
      if self.ActionDressMap[a.PetActionID] and next(self.ActionDressMap[a.PetActionID]) then
        a.SortKey = 0
      end
      if self.ActionDressMap[b.PetActionID] and next(self.ActionDressMap[b.PetActionID]) then
        b.SortKey = 0
      end
      return a.SortKey < b.SortKey
    end)
  end
  return self.PetActionCfg
end
function LogicPetCfg:GetPetActionList(pet_item_id)
  self:GetPetActionCfg()
  return self.PetActionMap[pet_item_id]
end
function LogicPetCfg:GetPetDressCfg()
  if self.PetDressCfg == nil then
    self.PetDressCfg = {}
    for _, v in pairs(CDataTable.GetTable("PetDressTable")) do
      local temp = {
        DressItemID = v.DressItemID,
        DressBPID = v.DressBPID,
        PetID = v.PetID,
        ActionID = v.ActionID,
        DressNeedLevel = v.DressNeedLevel
      }
      table.insert(self.PetDressCfg, temp)
    end
  end
  if self.DressActionMap == nil then
    self:GetDressActionMap()
  end
  if self.DressPetMap == nil then
    self:GetDressPetMap()
  end
  return self.PetDressCfg
end
function LogicPetCfg:GetDressAttachedAction(dress_id)
  local actionCfg = CDataTable.GetTableData("PetDressTable", dress_id)
  if actionCfg and actionCfg.ActionID and actionCfg.ActionID ~= 0 and actionCfg.ActionID ~= "" then
    return actionCfg.ActionID
  else
    return nil
  end
end
function LogicPetCfg:GetDressActionMap()
  if self.DressActionMap == nil then
    self.DressActionMap = {}
  end
  if self.PetDressCfg == nil or next(self.PetDressCfg) == nil then
    self:GetPetDressCfg()
  end
  if self.PetActionCfg == nil or next(self.PetActionCfg) == nil then
    self:GetPetActionCfg()
  end
  for k, v in pairs(self.PetDressCfg) do
    if v.ActionID ~= nil and v.ActionID ~= 0 then
      for kk, vv in pairs(self.PetActionCfg) do
        if v.ActionID == vv.PetActionID then
          self.DressActionMap[v.DressItemID] = vv
        end
      end
    end
  end
  return self.DressActionMap
end
function LogicPetCfg:GetActionDressMap()
  if self.ActionDressMap == nil then
    local StringUtil = require("common.string_util")
    self.ActionDressMap = {}
    for k, v in pairs(CDataTable.GetTable("PetActionTable")) do
      if v.DependingClothesID ~= nil and v.DependingClothesID ~= "" then
        if self.ActionDressMap[v.PetActionID] == nil then
          self.ActionDressMap[v.PetActionID] = {}
        end
        local DependingStrIDList = StringUtil.Split(v.DependingClothesID, "|")
        for __, vv in ipairs(DependingStrIDList) do
          local DependingID = tonumber(vv)
          if DependingID then
            table.insert(self.ActionDressMap[v.PetActionID], DependingID)
          end
        end
      end
    end
  end
  return self.ActionDressMap
end
function LogicPetCfg:GetDressPetMap()
  if self.DressPetMap == nil then
    self.DressPetMap = {}
  end
  if self.PetDressCfg == nil or next(self.PetDressCfg) == nil then
    self:GetPetDressCfg()
  end
  for k, v in pairs(self.PetDressCfg) do
    self.DressPetMap[v.DressItemID] = v.PetID
  end
  return self.DressPetMap
end
function LogicPetCfg:GetPetLevelItemCfg(pet_item_id, pet_level)
  if self.PetLevelCfg then
    local PetLevelCfg = self:GetPetLevelCfg()
    for _, v in pairs(PetLevelCfg) do
      if pet_item_id == v.PetID and pet_level == v.PetLevel then
        return v
      end
    end
  elseif pet_item_id and pet_level then
    local PetLevelID = tonumber(pet_item_id) * 10000 + tonumber(pet_level)
    local PetLevelConfig = CDataTable.GetTableData("PetLevelTable", PetLevelID)
    if PetLevelConfig then
      return BuildPetLevelItemCfg(PetLevelConfig)
    end
  end
  return nil
end
function LogicPetCfg:GetPetAllDressesList(pet_id)
  self.PetDressesLists = self.PetDressesLists or {}
  if self.PetDressesLists[pet_id] then
    return self.PetDressesLists[pet_id]
  end
  local DressesList = {}
  local AllDresses = self:GetPetDressCfg()
  for k, v in pairs(AllDresses) do
    if v.PetID == pet_id then
      table.insert(DressesList, v.DressItemID)
    end
  end
  self.PetDressesLists[pet_id] = DressesList
  return DressesList
end
function LogicPetCfg:GetPetItemCfgByPetItemID(pet_item_id)
  if self.PetCfg ~= nil then
    local PetCfg = self:GetPetCfgs()
    log(bWriteLog and "[ZH] GetPetItemCfgByPetItemID")
    for i, v in pairs(PetCfg) do
      if pet_item_id == v.PetID then
        return v
      end
    end
  else
    local petInfo = CDataTable.GetTableData("PetTable", pet_item_id)
    if petInfo then
      return BuildPetConfig(petInfo)
    end
  end
  return nil
end
function LogicPetCfg:GetAssociatedPetID(id)
  self:InitItemID2PetIDMap()
  return self.ItemID2PetIDMap[id]
end
function LogicPetCfg:InitItemID2PetIDMap()
  if self.PetCfgInited then
    return
  end
  self.PetCfgInited = true
  log(bWriteLog and "LogicPetCfg:InitItemID2PetIDMap.")
  self.ItemID2PetIDMap = {}
  local PetTableArr = CDataTable.GetTable("PetTable")
  for k, v in pairs(PetTableArr) do
    self.ItemID2PetIDMap[k] = v.PetID
  end
  local PetActionTableArr = CDataTable.GetTable("PetActionTable")
  for k, v in pairs(PetActionTableArr) do
    local petCfg = CDataTable.GetTableData("PetTable", v.PetID)
    if petCfg then
      self.ItemID2PetIDMap[k] = petCfg.PetID
    end
  end
  local PetDressTableArr = CDataTable.GetTable("PetDressTable")
  for k, v in pairs(PetDressTableArr) do
    local petCfg = CDataTable.GetTableData("PetTable", v.PetID)
    if petCfg then
      self.ItemID2PetIDMap[k] = petCfg.PetID
    end
  end
end
function LogicPetCfg:GetUnlockActionNeedLevel(pet_item_id, actionID)
  local PetLevelCfg = self:GetPetLevelCfg()
  for _, v1 in pairs(PetLevelCfg) do
    if v1.PetID == pet_item_id then
      local StringUtil = require("common.string_util")
      local allAction = StringUtil.Split(v1.AllAction, "|")
      for _, v2 in pairs(allAction) do
        if tostring(actionID) == v2 then
          return v1.PetLevel
        end
      end
    end
  end
  return 1
end
function LogicPetCfg:IsPetOrDress(pet_id_or_dress_id)
  local DressPetMap = self:GetDressPetMap()
  if DressPetMap[pet_id_or_dress_id] ~= nil then
    return false, DressPetMap[pet_id_or_dress_id]
  else
    return true, pet_id_or_dress_id
  end
end
function LogicPetCfg:IsUpgradablePet(pet_item_id)
  local levelTwoConfig = pet_item_id * 10000 + 2
  return CDataTable.GetTableData("PetLevelTable", levelTwoConfig) ~= nil
end
function LogicPetCfg:IsPetEnlargeEnabled(PetID)
  if not PetID then
    return false
  end
  local Cfg = CDataTable.GetTableData("PetTable", PetID)
  return Cfg and Cfg.CanEnlarge
end
function LogicPetCfg:GetPetScaleOfEnlargeState(PetID)
  if not PetID then
    return 1
  end
  local ScaleCfg = CDataTable.GetTableData("PetScaleTable", PetID)
  return ScaleCfg and ScaleCfg.EnlargeModeScale_f
end
function LogicPetCfg:GetPetBaseScale(PetID, PetShowType)
  if not PetID then
    return 1
  end
  PetShowType = PetShowType or self.ENUM_PetShowType.Avatar
  local ScaleConfig = CDataTable.GetTableData("PetScaleTable", PetID)
  if not ScaleConfig then
    return 1
  end
  local Scale = 1
  if PetShowType == self.ENUM_PetShowType.Workshop then
    Scale = (ScaleConfig.BaseScale_f or 1) * (ScaleConfig.WorkshopScale_f or 1)
  elseif PetShowType == self.ENUM_PetShowType.Preview then
    Scale = (ScaleConfig.BaseScale_f or 1) * (ScaleConfig.PreviewScale_f or 1)
  else
    Scale = ScaleConfig.BaseScale_f or 1
  end
  return Scale
end
function LogicPetCfg:GetPetAttachOffset(PoseID, bLeft, bRank)
  local Cfg = CDataTable.GetTableData("PetPoseOffset", PoseID)
  local OffsetStr = ""
  if Cfg then
    if bLeft then
      if bRank then
        OffsetStr = Cfg.LeftPetOffsetForRank
      else
        OffsetStr = Cfg.LeftPetOffset
      end
    elseif bRank then
      OffsetStr = Cfg.RightPetOffsetForRank
    else
      OffsetStr = Cfg.RightPetOffset
    end
  end
  if not OffsetStr or OffsetStr == "" then
    return self:GetDefaultPetAttachOffset(bLeft, bRank)
  end
  local StringUtil = require("common.string_util")
  local ValueArray = StringUtil.Split(OffsetStr, ";")
  local Result = {
    x = tonumber(ValueArray[1]),
    y = tonumber(ValueArray[2]),
    z = tonumber(ValueArray[3])
  }
  return Result
end
function LogicPetCfg:GetDefaultPetAttachOffset(bLeft, bRank)
  local PetConfig = require("client.slua.logic.pet.pet_config")
  if bLeft then
    if bRank then
      return PetConfig.LeftAvatarPetPositionForRankDefault
    else
      return PetConfig.LeftAvatarPetPositionDefault
    end
  elseif bRank then
    return PetConfig.RightAvatarPetPositionForRankDefault
  else
    return PetConfig.RightAvatarPetPositionDefault
  end
end
function LogicPetCfg:IsSwimmingAction(ActionID)
  local ActionConfig = CDataTable.GetTableData("PetActionTable", ActionID)
  if not ActionConfig then
    return false
  end
  return ActionConfig.ActionPattern == EActionPattern.Swimming
end
function LogicPetCfg:IsParachuteAction(ActionID)
  local ActionConfig = CDataTable.GetTableData("PetActionTable", ActionID)
  if not ActionConfig then
    return false
  end
  return ActionConfig.ActionPattern == EActionPattern.Parachute
end
function LogicPetCfg:IsInHighPerformanceSystem()
  local PetConfig = require("client.slua.logic.pet.pet_config")
  for _, v in ipairs(PetConfig.HighPerformanceSystem) do
    if UIManager.IsUIShow(UIManager.UI_Config[v]) then
      return true
    end
  end
  return false
end
function LogicPetCfg:HasFullScreenUIShow()
  local PetConfig = require("client.slua.logic.pet.pet_config")
  for _, v in ipairs(PetConfig.FullScreenUIList) do
    if UIManager.IsUIShow(UIManager.UI_Config[v]) then
      return true
    end
  end
  return false
end
function LogicPetCfg:GetEquipEmotionIDByBPID(BPID)
  local DressCfg = CDataTable.GetTableData("PetDressTable", BPID)
  local EquipEmotionID
  if DressCfg then
    EquipEmotionID = tonumber(DressCfg.ActionID) or 0
  end
  return EquipEmotionID
end
function LogicPetCfg:GetDressActionWeightID(BPID)
  local DressCfg = CDataTable.GetTableData("PetDressTable", BPID)
  return DressCfg and DressCfg.ActionWeight or 10
end
function LogicPetCfg:IsPetItemValid(itemID)
  if not itemID or itemID == 0 then
    log_warning("LogicPetCfg:IsPetItemValid return false itemID:" .. tostring(itemID))
    return false
  end
  local cfgItem = CDataTable.GetTableData("Item", itemID)
  if not cfgItem then
    log_warning("LogicPetCfg:IsPetItemValid return false cfg is nil itemID:" .. tostring(itemID))
    return false
  end
  if not cfgItem.BPID or 0 >= cfgItem.BPID then
    log_warning("LogicPetCfg:IsPetItemValid return false BPID is nil itemID:" .. tostring(itemID))
    return false
  end
  local cfgBlueprint = CDataTable.GetTableData("PetDressBlueprintTable", cfgItem.BPID)
  if not cfgBlueprint or not cfgBlueprint.Slot then
    log_warning("LogicPetCfg:IsPetItemValid return false cfgBlueprint is nil itemID:" .. tostring(itemID))
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if next(self.DressTimeUrl) and (self.DressTimeUrl[itemID] == nil or nowTime < self.DressTimeUrl[itemID].launch_time) then
    log_warning("LogicPetCfg:IsPetItemValid return false time is not valid itemID:" .. tostring(itemID))
    return false
  end
  return true
end
function LogicPetCfg:IsPetItemID(itemID)
  if not itemID then
    return false
  end
  local cfg = CDataTable.GetTableData("Item", itemID)
  if not cfg then
    return false
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  return ModelDisplayTypeHelper.IsPet(cfg.ItemType)
end
function LogicPetCfg:GetSlotIDByPetDressID(DressItemID)
  if not DressItemID or DressItemID == 0 then
    log_warning("LogicPetCfg:GetSlotIDByPetDressID DressItemID is " .. tostring(DressItemID))
    return nil
  end
  local Cfg = CDataTable.GetTableData("Item", DressItemID)
  if Cfg and Cfg.BPID then
    local cfgBlueprint = CDataTable.GetTableData("PetDressBlueprintTable", Cfg.BPID)
    return cfgBlueprint and cfgBlueprint.Slot
  end
  return nil
end
function LogicPetCfg:GetPetPortalList()
  if not self._petPortalList then
    self._petPortalList = {}
    local petPortalTable = CDataTable.GetTable("PortalEffectTable")
    if petPortalTable then
      for k, cfg in pairs(petPortalTable) do
        self._petPortalList[#self._petPortalList + 1] = k
      end
    end
  end
  return self._petPortalList
end
function LogicPetCfg:GetPortalCfgByItemId(itemId)
  local PetExhibitConfig = require("client.lobby_ue_object.Actor.PetExhibit.PetExhibitConfig")
  if not itemId then
    return DEFAULT_EFFECT_CFG
  end
  local UBackpackUtils = import("BackpackUtils")
  local ItemDefineID = FItemDefineID(ENUM_ITEM_TYPE.PetSwitchEffect, itemId)
  local handle = UBackpackUtils.CreateBattleItemHandle(ItemDefineID, slua_GameFrontendHUD:GetWorld(), false)
  if slua.isValid(handle) then
    return {
      Appear = handle.InParticle:ToString(),
      DisAppear = handle.OutParticle:ToString(),
      Scale = handle.Scale
    }
  end
  return DEFAULT_EFFECT_CFG
end
function LogicPetCfg:GetAssociateBubbleIDList()
  return {
    2206032,
    2206033,
    2206034,
    2206035
  }
end
function LogicPetCfg:GetPetIDForPrivilegePreview()
  return ENUM_LOBBYPET_TYPE.TYPE_LITTLEDOG
end
function LogicPetCfg:IsBubbleForPetBubblePrivilege(ItemID)
  return ItemID == 2206032 or ItemID == 2206033 or ItemID == 2206034 or ItemID == 2206035
end
function LogicPetCfg:IsPetForPrivilegeAssetReady()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
    self:GetPetIDForPrivilegePreview()
  })
  return state == PufferConst.ENUM_DownloadState.Done
end
function LogicPetCfg:GetBubbleParticlePath(BubbleItemID)
  local cfg = CDataTable.GetTableData("IngameBubbleCfg", BubbleItemID)
  if cfg and cfg.BubbleEffectType == 2 then
    return "/Game/Arts_Effect/ParticleSystems/Share/P_SocialIsland_Emoji_love.P_SocialIsland_Emoji_love"
  end
  return "/Game/Arts_Effect/ParticleSystems/Share/P_SocialIsland_Emoji.P_SocialIsland_Emoji"
end
function LogicPetCfg:GetBubbleTexturePath(BubbleItemID)
  local cfg = CDataTable.GetTableData("IngameBubbleCfg", BubbleItemID)
  return cfg and cfg.BubbleEffectIcon
end
function LogicPetCfg:GetBubbleTextureCfg(BubbleItemID)
  local cfg = CDataTable.GetTableData("IngameBubbleCfg", BubbleItemID)
  if not cfg then
    return nil
  end
  local bubbleParticlePath = "/Game/Arts_Effect/ParticleSystems/Share/P_SocialIsland_Emoji.P_SocialIsland_Emoji"
  local textParamName = "BaseTex"
  if cfg.BubbleEffectType == 2 then
    bubbleParticlePath = "/Game/Arts_Effect/ParticleSystems/Share/P_SocialIsland_Emoji_love.P_SocialIsland_Emoji_love"
    textParamName = "Texture"
  end
  return {
    bubbleParticlePath = bubbleParticlePath,
    bubbleTexturePath = cfg.BubbleEffectIcon,
      }
end
function LogicPetCfg:NeedProcessPetDependentResource(ActionItemID, ItemType, ItemSubType)
  if ItemType == ENUM_ITEM_TYPE.Buddy or ItemType == ENUM_ITEM_TYPE.Buddy_New then
    return true
  end
  if ItemSubType == ENUM_ITEM_SUBTYPE.Action then
    ActionItemID = ActionItemID or 0
    return 50001000 <= ActionItemID and ActionItemID < 60001000
  end
  return false
end
function LogicPetCfg:GetAttachBiasList(ThemeItemID, TeamPosIndex)
  local PetConfig = require("client.slua.logic.pet.pet_config")
  if not self.TeamPosIndex then
    return PetConfig.BaseAttachBiasList
  end
  if not ThemeItemID then
    return PetConfig.BaseAttachBiasList
  end
  local BiasKey = string.format("%s_%s", tostring(ThemeItemID), tostring(self.TeamPosIndex))
  return PetConfig.AttachBiasListForTheme[BiasKey] or PetConfig.BaseAttachBiasList
end
function LogicPetCfg:HandleOffsetPosByScene(tPetShow, nSceneType)
  local PetConfig = require("client.slua.logic.pet.pet_config")
  local SceneShowPosOffset = PetConfig.SceneShowPosOffset
  if nSceneType and SceneShowPosOffset[nSceneType] and tPetShow then
    local tOffsetPos = SceneShowPosOffset[nSceneType]
    return {
      x = tPetShow.x + tOffsetPos.x,
      y = tPetShow.y + tOffsetPos.y,
      z = tPetShow.z + tOffsetPos.z
    }
  end
  return tPetShow
end
function LogicPetCfg:GetMiniTvSocketScale(PetID)
  if not PetID then
    return 1
  end
  local cfg = CDataTable.GetTableData("PetScaleTable", PetID)
  if cfg and cfg.MiniTvSocketScale_f ~= 0 then
    return cfg.MiniTvSocketScale_f
  end
  return 1
end
function LogicPetCfg:IsPetIDBlocked(PetID, bMiniTvEnabled)
  if PetID == 50000 and not bMiniTvEnabled then
    return true
  end
  return false
end
return TLogicPetCfg