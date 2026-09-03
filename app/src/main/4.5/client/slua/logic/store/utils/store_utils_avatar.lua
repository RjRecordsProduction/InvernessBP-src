local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
function StoreUtils.IsEquippedByItemId(itemId)
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if not itemCfg then
    return false
  end
  if ModelDisplayTypeHelper._Is2DModelByItemId(itemId) then
    return false
  end
  if ModelDisplayTypeHelper.IsCarOrPlane(itemCfg.ItemType) or ModelDisplayTypeHelper.IsVoiceBag(itemCfg.ItemType, itemCfg.ItemSubType) or ModelDisplayTypeHelper.IsPet(itemCfg.ItemType) then
    return false
  end
  local avatar = ModelDisplayer.GetShowingAvatar()
  if not avatar then
    return false
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local period = LogicXSuit.GetPeriodByItemId(itemId)
  if period then
    local branchId = LogicXSuit.GetBranchByItemId(itemId)
    local groupList = LogicXSuit.GetUpgradeInfo(period, true, branchId)
    if groupList then
      for _, cfg in ipairs(groupList) do
        if avatar:HasEquiped(cfg.item_id) then
          return true
        end
      end
    end
  end
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local otherId = multi_state_manager:GetOtherStateClothID(itemId)
  if otherId then
    return avatar:HasEquiped(itemId) or avatar:HasEquiped(otherId)
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local Cfg = LogicMultiItemModule:GetCartoonStyleCfg(itemId)
  if Cfg then
    return avatar:HasEquiped(Cfg.BaseID) or avatar:HasEquiped(Cfg.CartoonStyleID)
  end
  local multiLevelCfg = CDataTable.GetTableData("MultiLevelItem", itemId)
  if multiLevelCfg then
    local groupID = multiLevelCfg.GroupID
    local groupList = CDataTable.GetTableByFilter("MultiLevelItem", "GroupID", groupID)
    if groupList then
      for _, cfg in pairs(groupList) do
        if avatar:HasEquiped(cfg.ItemID) then
          return true
        end
      end
    end
  end
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  if LogicFusionModule:IsFusionItem(itemId) then
    local config = LogicFusionModule:GetFusionConfig(itemId)
    local targetItem = config.targetItem
    if itemId == targetItem then
      return avatar:HasEquiped(targetItem)
    end
    if avatar:HasEquiped(itemId) then
      return true
    end
    if avatar:HasEquiped(targetItem) then
      local sourceItemId = LogicFusionModule:GetFusionPreviewPre(config.period)
      return sourceItemId == itemId
    end
    return false
  end
  local hasEquip = avatar:HasEquiped(itemId)
  return hasEquip
end
function StoreUtils.HasGoldSuitInDataList(DataList)
  if not DataList or not next(DataList) then
    return false
  end
  local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  for _, item in pairs(DataList) do
    local itemID = 0
    if type(item) == "number" and 0 < tonumber(item) then
      itemID = tonumber(item)
    else
      itemID = item.itemId or item.DropItemID or itemID
    end
    local itemCfg = CDataTable.GetTableData("Item", itemID)
    if itemCfg and ModelDisplayTypeHelper.IsGoldenSuitByQuality(itemCfg.ItemType, itemCfg.ItemQuality) and not ConstAvatarDislay.IsOldGolden(itemCfg.ItemID) then
      return true
    end
  end
  return false
end
function StoreUtils.PlayEmotion(emotionId, isGlide, enableCameraAnim, isFullScreen)
  log_warning(bWriteLog and "StoreOtherUtils.PlayEmotion , isGlide = " .. tostring(isGlide) .. " emotionId = " .. tostring(emotionId))
  log(bWriteLog and string.format("StoreUtils.PlayEmotion enableCameraAnim = %s", enableCameraAnim))
  if emotionId and emotionId ~= 0 then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local keyList = {emotionId}
    if emotionId == 12219385 then
      table.insert(keyList, 1406474)
    end
    local emoteState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, keyList)
    if emoteState ~= PufferConst.ENUM_DownloadState.Done then
      local PufferSwitch = require("client.slua.logic.download.puffer_switch")
      if not PufferSwitch.BanDownload then
        log(bWriteLog and string.format("StoreUtils.PlayEmotion emotionId = %s, The current item has not been downloaded yet", emotionId))
      end
      log(bWriteLog and "StoreOtherUtils.PlayEmotion not download ")
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, keyList)
      if ModelDisplayer.GetHideAvatarBeforeEmote() then
        ModelDisplayer.HideAvatarBeforeEmote(false)
      end
      return
    end
  else
    log(bWriteLog and "StoreOtherUtils.PlayEmotion not emotionId")
  end
  local audio_util = require("client.common.audio_util")
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local fStartFunc = function(id)
    log(bWriteLog and string.format("StoreUtils.PlayEmotion fStartFunc id = %s, emotionId = %s, isFullScreen = %s", id, emotionId, isFullScreen))
    if emotionId ~= id then
      return
    end
    if isFullScreen then
      EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_CRATE_HIDEUI, false)
    end
  end
  local fEndFunc = function(id)
    log(bWriteLog and string.format("StoreUtils.PlayEmotion fEndFunc id = %s, emotionId = %s, isFullScreen = %s", id, emotionId, isFullScreen))
    if isFullScreen then
      local isShowVideo = UIManager.IsUIShow(UIManager.UI_Config.video_player_system_pure)
      if not isShowVideo then
        EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_CRATE_HIDEUI, true, id)
      end
    end
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_EMOTION_STOP, id)
    if userSettings.BGMVolumSwitcher and not isGlide then
      audio_util.SetRTPCValue("VolumeControl_Music", userSettings.BGMVolumValue * 100, 200)
    end
  end
  if enableCameraAnim == nil then
    enableCameraAnim = true
  end
  if userSettings.BGMVolumSwitcher and not isGlide then
    audio_util.SetRTPCValue("VolumeControl_Music", 30, 200)
  end
  ModelDisplayer.Display(emotionId, true, {
    emotionStartCallback = fStartFunc,
    emotionEndCallback = fEndFunc,
      })
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  local frame = store_supply_manager:GetCurrentFrame()
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if frame and frame.type == StoreConst.supply_tab then
    LobbyAvatarManager.PlayEmotionSound(emotionId, 1, 0, DataMgr.roleData.uid, 3)
  else
    LobbyAvatarManager.PlayEmotionSound(emotionId, 1, 0, DataMgr.roleData.uid, 2)
  end
end
function StoreUtils.PutOnDefaultBackpack(otherFrame)
  local model
  if ModelDisplayer.GetShowingAvatar() then
    model = ModelDisplayer.GetShowingAvatar():GetModel()
  end
  if model ~= nil then
    local itemId = model:GetEquipmentInfoBySlot(8)
    local frame
    if otherFrame then
      frame = otherFrame
    else
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      frame = store_supply_manager:GetCurrentFrame()
    end
    log(bWriteLog and "StoreBackpackPage:PutOnDefaultBackpack, equipedBagId = " .. tostring(itemId) .. ", frame = " .. tostring(frame))
    if itemId ~= 0 then
      local baseConfig = CDataTable.GetTableData("MALL_BAG_HELMET_BASE_ITEM_CONFIG", itemId)
      if baseConfig ~= nil then
        local cfg = CDataTable.GetTableData("Item", baseConfig.baseItemID)
        if cfg ~= nil then
          return true, cfg
        end
      end
      log(bWriteLog and "[tinghaohu]StoreOtherUtils.PutOnDefaultBackpack, current equiped itemId not exist")
    elseif frame ~= nil then
      itemId = 501000
      local cfg = CDataTable.GetTableData("Item", itemId)
      if cfg ~= nil then
        frame:PutOnClothes(itemId, cfg.ItemType, cfg.ItemSubType, nil, nil)
        return true, cfg
      else
        log(bWriteLog and "StoreOtherUtils.PutOnDefaultBackpack, not found itemId = " .. tostring(itemId))
      end
    end
  end
  return false, nil
end
function StoreUtils.PutOffDefaultBackpack()
  local model = ModelDisplayer.GetShowingAvatar():GetModel()
  log(bWriteLog and "StoreOtherUtils.PutOffDefaultBackpack, model = " .. tostring(model))
  if model ~= nil then
    local itemId = model:GetEquipmentInfoBySlot(8)
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    local frame = store_supply_manager:GetCurrentFrame()
    log(bWriteLog and "StoreBackpackPage:PutOffDefaultBackpack, equipedBagId = " .. tostring(itemId) .. ", frame = " .. tostring(frame))
    if itemId == 501003 and frame ~= nil then
      local cfg = CDataTable.GetTableData("Item", itemId)
      if cfg ~= nil then
        frame:PutOffClothes(itemId, cfg.ItemType, cfg.ItemSubType, nil, nil)
        return true, cfg
      else
        log(bWriteLog and "StoreOtherUtils.PutOffDefaultBackpack, not found itemId = " .. tostring(itemId))
      end
    end
  end
  return false, nil
end
function StoreUtils.GetEmotionIDByItemID(itemID, checkHighLevelItem)
  local emotionID = 0
  local playCD = 0
  local featuresItem = CDataTable.GetTableData("FeaturesItems", itemID)
  if featuresItem == nil then
    if checkHighLevelItem == true then
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      local highLevelItemID = ItemUpgradeMgr:GetMaxLevelItem(itemID)
      featuresItem = CDataTable.GetTableData("FeaturesItems", highLevelItemID)
      if featuresItem == nil then
        return emotionID, playCD
      end
    else
      return emotionID, playCD
    end
  end
  if featuresItem ~= nil then
    local StringUtil = require("common.string_util")
    local features = StringUtil.Split(featuresItem.Features, ";")
    for i, v in ipairs(features) do
      local cfg = CDataTable.GetTableData("FeaturesConfig", tonumber(v) or 0)
      if cfg ~= nil then
        if cfg.FeatureType == 3 or cfg.FeatureType == 5 or cfg.FeatureType == 8 then
          emotionID = cfg.ExpressionID
          playCD = cfg.ExpressionCD
          if GlobalData.IsJapanOrKorea() and 0 < cfg.FightExpressionID then
            emotionID = cfg.FightExpressionID
          end
          break
        end
      else
        log(bWriteLog and "StoreOtherUtils.GetEmotionIDByItemID, not found key = " .. tostring(v) .. " in table FeaturesConfig.")
      end
    end
  end
  return emotionID, playCD
end