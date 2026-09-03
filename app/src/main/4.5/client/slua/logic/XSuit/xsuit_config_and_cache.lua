local xsuit_config_and_cache = {}
function xsuit_config_and_cache.GetSpinArgsConfig()
  if not xsuit_config_and_cache.spinArgsCfg then
    xsuit_config_and_cache.spinArgsCfg = CDataTable.GetTable("xsuit_spin_args_config")
  end
  if not xsuit_config_and_cache.spinArgsCache then
    xsuit_config_and_cache.spinArgsCache = {}
    for name, config in pairs(xsuit_config_and_cache.spinArgsCfg) do
      xsuit_config_and_cache.spinArgsCache[name] = config.value
    end
  end
  return xsuit_config_and_cache.spinArgsCache
end
function xsuit_config_and_cache.GetVersionArgConfig()
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region == PublishRegionMacros.CE then
    return xsuit_config_and_cache.GetCEVersionArgConfig()
  end
  if not xsuit_config_and_cache.versionArgsCfg then
    xsuit_config_and_cache.versionArgsCfg = CDataTable.GetTable("xsuit_version_config")
  end
  if not xsuit_config_and_cache.versionArgsCache then
    xsuit_config_and_cache.versionArgsCache = {}
    for name, config in pairs(xsuit_config_and_cache.versionArgsCfg) do
      xsuit_config_and_cache.versionArgsCache[name] = config.value
    end
  end
  return xsuit_config_and_cache.versionArgsCache
end
function xsuit_config_and_cache.GetCEVersionArgConfig()
  if not xsuit_config_and_cache.ceVersionArgsCfg then
    xsuit_config_and_cache.ceVersionArgsCfg = CDataTable.GetTable("xsuit_ce_version_config")
  end
  if not xsuit_config_and_cache.ceVersionArgsCache then
    xsuit_config_and_cache.ceVersionArgsCache = {}
    for name, config in pairs(xsuit_config_and_cache.ceVersionArgsCfg) do
      xsuit_config_and_cache.ceVersionArgsCache[name] = config.value
    end
  end
  return xsuit_config_and_cache.ceVersionArgsCache
end
function xsuit_config_and_cache.GetNowPoolConfig()
  if not xsuit_config_and_cache.nowPoolCfg then
    xsuit_config_and_cache.nowPoolCfg = {}
    local config = CDataTable.GetTable("xsuit_now_pool_config")
    for k, v in pairs(config) do
      if v.is_branch == 0 then
        table.insert(xsuit_config_and_cache.nowPoolCfg, {poolConfig = v})
      else
        if not xsuit_config_and_cache.nowPoolCfg[#xsuit_config_and_cache.nowPoolCfg].branchList then
          xsuit_config_and_cache.nowPoolCfg[#xsuit_config_and_cache.nowPoolCfg].branchList = {}
        end
        table.insert(xsuit_config_and_cache.nowPoolCfg[#xsuit_config_and_cache.nowPoolCfg].branchList, {poolConfig = v})
      end
    end
  end
  return xsuit_config_and_cache.nowPoolCfg
end
function xsuit_config_and_cache.GetNowPoolConfigByPoolId(pool_id)
  if not pool_id then
    return
  end
  return CDataTable.GetTableDataByFilter("xsuit_now_pool_config", "pool_id", pool_id)
end
function xsuit_config_and_cache.GetNowPoolConfigByPeriod(period)
  if not period then
    return
  end
  return CDataTable.GetTableDataByFilter("xsuit_now_pool_config", "period", period)
end
function xsuit_config_and_cache.GetNowPoolConfigByBranchId(period, branchId)
  if not period then
    return
  end
  branchId = branchId or 0
  return CDataTable.GetTableDataByFilter("xsuit_now_pool_config", "period", period, "is_branch", 1, "branch_id", branchId)
end
function xsuit_config_and_cache.GetNowMainConfig()
  return CDataTable.GetTable("xsuit_now_main_config")
end
function xsuit_config_and_cache.GetGiftShareConfigByPeriod(period)
  if not period then
    return
  end
  return CDataTable.GetTableData("xsuit_gift_share_config", period)
end
function xsuit_config_and_cache.GetFeatureConfigByPeriod(period)
  if not period then
    return
  end
  if not xsuit_config_and_cache.featureCfg then
    xsuit_config_and_cache.featureCfg = {}
  end
  if not xsuit_config_and_cache.featureCfg[period] then
    local feature = {}
    feature.featureList = {}
    local configs = CDataTable.GetTableByFilter("xsuit_feature_config", "period", period)
    if not configs then
      return
    end
    for k, config in pairs(configs) do
      if config.index == 1 then
        feature.imagePath = config.background
        feature.title = config.title > 0 and config.title or nil
        local versionCfg = xsuit_config_and_cache.GetVersionArgConfig()
        if 0 < config.new_feature_version and config.new_feature_version == versionCfg.MAX_PERIOD then
          feature.newFeature = true
        end
      end
      table.insert(feature.featureList, {
        name = config.feature_id,
        item = config.jump_item_id,
        subtabIndex = config.choose_index
      })
    end
    xsuit_config_and_cache.featureCfg[period] = feature
  end
  return xsuit_config_and_cache.featureCfg[period]
end
function xsuit_config_and_cache.GetFeatureBpPathByPeriod(period, bNew)
  if not period then
    return
  end
  period = bNew and period or 0
  return CDataTable.GetTableData("xsuit_feature_bp_config", period)
end
function xsuit_config_and_cache.GetChatConfigByPeriod(period)
  if not period then
    return
  end
  return CDataTable.GetTableData("xsuit_chat_config", period)
end
function xsuit_config_and_cache.GetGiftPopupConfigByPeriod(period)
  if not period then
    return
  end
  return CDataTable.GetTableData("xsuit_gift_popup_config", period)
end
function xsuit_config_and_cache.GetShareWithWorkshopByPeriod(period, branchId)
  if not period then
    return
  end
  return CDataTable.GetTableDataByFilter("xsuit_workshop_share_config", "period", period, "branchId", branchId)
end
function xsuit_config_and_cache.GetReddotWithWorkShopByPeriod(period, BranchId, level, index)
  if not period then
    return
  end
  if not xsuit_config_and_cache.reddotWithWorkShop then
    xsuit_config_and_cache.reddotWithWorkShop = {}
  end
  if not xsuit_config_and_cache.reddotWithWorkShop[period] then
    local config = CDataTable.GetTableDataByFilter("xsuit_workshop_reddot_config", "period", period, "is_branch", 0)
    if config then
      xsuit_config_and_cache.reddotWithWorkShop[period] = {
        version = config.version,
        reddot_version = config.reddot_version,
        branchReddotList = {}
      }
    end
  end
  if BranchId and xsuit_config_and_cache.reddotWithWorkShop[period] and not xsuit_config_and_cache.reddotWithWorkShop[period].branchReddotList[BranchId] then
    local configs = CDataTable.GetTableByFilter("xsuit_workshop_reddot_config", "period", period, "is_branch", 1, "branchId", BranchId)
    if configs then
      local reddot = {}
      for k, config in pairs(configs) do
        if config.period > 0 and config.level == 0 and config.index == 0 then
          reddot.version = config.version
          reddot.reddot_version = config.reddot_version
        end
        if config.period > 0 and 0 < config.level and config.index == 0 then
          reddot[config.level] = reddot[config.level] or {}
          reddot[config.level].version = config.version
          reddot[config.level].reddot_version = config.reddot_version
        end
        if config.period > 0 and 0 < config.level and 0 < config.index then
          reddot[config.level] = reddot[config.level] or {}
          reddot[config.level][config.index] = reddot[config.level][config.index] or {}
          reddot[config.level][config.index].version = config.version
          reddot[config.level][config.index].reddot_version = config.reddot_version
        end
      end
      xsuit_config_and_cache.reddotWithWorkShop[period].branchReddotList[BranchId] = reddot
    end
  end
  local periodReddot = xsuit_config_and_cache.reddotWithWorkShop[period]
  local branchReddot = periodReddot and periodReddot.branchReddotList[BranchId]
  if period and BranchId and level and index then
    return branchReddot and branchReddot[level] and branchReddot[level][index]
  elseif period and BranchId and level then
    return branchReddot and branchReddot[level]
  elseif period and BranchId then
    return branchReddot
  elseif period then
    return periodReddot
  end
end
function xsuit_config_and_cache.GetLimitSceneConfigByActionId(action_id)
  if not action_id then
    return
  end
  if not xsuit_config_and_cache.limitSceneCfg then
    xsuit_config_and_cache.limitSceneCfg = {}
  end
  if not xsuit_config_and_cache.limitSceneCfg[action_id] then
    local data = {}
    local config = CDataTable.GetTableDataByFilter("xsuit_limit_scene_config", "action_id", action_id)
    if not config then
      return
    end
    data.newAction = config.new_action_id > 0 and config.new_action_id or nil
    data.sceneName = config.scene_name ~= "" and config.scene_name or nil
    data.scenePath = config.scene_path ~= "" and config.scene_path or nil
    data.showLimit = {}
    local showLimitStr = config.play_scenes
    local StringUtil = require("common.string_util")
    local showLimitTab = StringUtil.Split(showLimitStr, "|")
    for index, name in pairs(showLimitTab) do
      data.showLimit[name] = true
    end
    xsuit_config_and_cache.limitSceneCfg[action_id] = data
  end
  return xsuit_config_and_cache.limitSceneCfg[action_id]
end
function xsuit_config_and_cache.GetMultiTypeUnlockConfigByPeriod(period)
  if not period then
    return
  end
  return CDataTable.GetTableData("xsuit_multi_unlock_config", period)
end
function xsuit_config_and_cache.GetPutOnRelicConfigByPeriod(period)
  if not period then
    return
  end
  local config = CDataTable.GetTableData("xsuit_put_on_relic_config", period)
  return config and config.allow == 1
end
function xsuit_config_and_cache.GetSpinVideoAndAudioConfigByPeriod(period)
  if not period then
    return
  end
  return CDataTable.GetTableData("xsuit_entry_video_and_audio_config", period)
end
function xsuit_config_and_cache.GetDRGlideByXSuit7(XSuit7)
  if not XSuit7 then
    return
  end
  return CDataTable.GetTableData("xsuit_double_ride_config", XSuit7)
end
function xsuit_config_and_cache.IsBanSwitchGenderByPeriod(period)
  if not period then
    return
  end
  local commonCfg = CDataTable.GetTableData("xsuit_workshop_common_config", period)
  return commonCfg and commonCfg.ban_gender_switch == 1
end
function xsuit_config_and_cache.IsShowSwitchGlideByPeriod(period)
  if not period then
    return
  end
  local commonCfg = CDataTable.GetTableData("xsuit_workshop_common_config", period)
  return commonCfg and commonCfg.glide_switch == 1
end
function xsuit_config_and_cache.GetSpinVideoDownloadConfigByPeriod(period)
  if not period then
    return
  end
  return CDataTable.GetTableByFilter("xsuit_draw_video_and_audio_config", "period", period)
end
function xsuit_config_and_cache.GetSpinVideoPathByVideoName(videoName)
  if not videoName or videoName == "" then
    return
  end
  return CDataTable.GetTableDataByFilter("xsuit_draw_video_and_audio_config", "video_name", videoName)
end
return xsuit_config_and_cache