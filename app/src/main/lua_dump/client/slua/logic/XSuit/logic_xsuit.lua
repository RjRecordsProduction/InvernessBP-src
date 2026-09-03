local LogicXSuit = {
  baseInfo = {},
  upgradeInfo = {},
  unlockFeatureInfo = nil,
  switchLevel = nil,
  stateInfo = nil,
  levelAction = nil,
  RunAction = {},
  bItemInfoInited = false,
  bBaseInfoInited = false,
  condtion = {},
  gridExchangeData = {},
  itemInfoList = {},
  needShowRelicID = 0,
  needShowRelicUid = 0,
  relicInfoList = {},
  inviteActionMap = nil,
  actionPeriodMap = {},
  lastSendInviteTime = 0,
  openUpgrade = false,
  playerEquipItemID = 0,
  shareTimeList = {},
  currencyIconPath = nil,
  materialItemIDMap = {},
  unlockStateMatMap = {},
  needPlayActionMember = {},
  playedActionUidMap = {},
  bVersionInit = false,
  ItemBeClick = {}
}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local LogicXSuitConfig = require("client.slua.logic.XSuit.logic_xsuit_config")
local xsuit_config_and_cache = require("client.slua.logic.XSuit.xsuit_config_and_cache")
local XSuitHandler = require("client.network.Protocol.XSuitHandler")
local maxFeatureCount = 5
function LogicXSuit.GetConfig(key)
  if key then
    return LogicXSuitConfig[key]
  end
end
function LogicXSuit.OnLogin(bReLogin)
  if not bReLogin or LogicXSuit.openUpgrade == false then
    LogicXSuit.openUpgrade = LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_XSUIT_WORK_SHOP, false)
    log(bWriteLog and "LogicXSuit.openUpgrade = " .. tostring(LogicXSuit.openUpgrade))
    XSuitHandler.send_get_rise_star_info_req()
    XSuitHandler.send_get_gold_dress_new_level_req()
    LogicXSuit.stateInfo = nil
    LogicXSuit.SendGetGoldDressStateReq()
  end
end
function LogicXSuit.OnModePreSwitch(_, currentStatus)
  if not GameStatus.IsInLobbyOrMainCity() then
    LogicXSuit.needPlayActionMember = {}
  end
end
function LogicXSuit.GetCurrentEqualItemData(period)
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  local equipItem = logic_xsuit_activity:GetEqualItemID(period)
  if equipItem and equipItem ~= 0 then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local data = wardrobe_data:GetHallDepotItemDataByResID(equipItem)
    return data
  end
  return nil
end
function LogicXSuit.GetMaxPeriod()
  local config = xsuit_config_and_cache.GetVersionArgConfig()
  local maxPeriod = config.MAX_PERIOD or 1
  for i = maxPeriod, 1, -1 do
    if LogicXSuit.CheckShowTime(i) then
      return i
    end
  end
  return 0
end
function LogicXSuit.GetItemBeClick()
  return LogicXSuit.ItemBeClick
end
function LogicXSuit.GetShareTime(itemId)
  local period = LogicXSuit.GetPeriodByItemId(itemId)
  local periodList = LogicXSuit.shareTimeList[period]
  if periodList then
    local infoList = LogicXSuit.shareTimeList[period].level_time
    if infoList then
      local maxLv = 0
      for lv, _ in pairs(infoList) do
        if lv > maxLv then
          maxLv = lv
        end
      end
      return infoList[maxLv] or nil
    end
    return nil
  end
  return nil
end
function LogicXSuit.CheckSpinDownloadState()
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  local actId = logic_xsuit_activity:GetDrawActivityID()
  if not actId then
    if not logic_xsuit_activity:IsDrawActivityInfoNotFound() then
      XSuitHandler.send_get_gold_dress_activity_req()
      ShowNotice(120164)
    end
    log(bWriteLog and "LogicXSuit.ShowSelectStateUI false, not actId")
    return false
  end
  local state = PufferManager.GetStateByModuleIDActivityID(BP_ENUM_MODULE_GOLDENSUIT_LOTTERY)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "LogicXSuit.ShowSelectStateUI false, state = " .. tostring(state))
    return false
  end
  return true
end
function LogicXSuit.ShowSelectStateUI(ins_id, res_id, notClose)
  if not LogicXSuit.CheckSpinDownloadState() then
    return
  end
  if not ins_id then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByResID(res_id)
    if itemData then
      ins_id = itemData.insID
    else
      log(bWriteLog and "LogicXSuit.ShowSelectStateUI ins_id not found")
      return
    end
  end
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  local period = logic_xsuit_activity:GetCurrentPeriod()
  if period and LogicXSuit.GetLevelByPeriod(period) > 0 then
    XSuitHandler.send_open_gold_dress_req(ins_id, 1)
    return
  end
end
function LogicXSuit.ShowGiftPacketUI(giftInfo, mailInfo)
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  if not LogicXSuit.CheckSpinDownloadState() then
    if not mailInfo then
      return
    end
    if logic_xsuit_activity:IsDrawActivityInfoNotFound() then
      if mailInfo.isFetched == false then
        local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
        ShopGiftPacketLogic.SendMarketGiftTakeReq(mailInfo.index)
      else
        ShowNotice(102036)
      end
    end
    return
  end
  local Config = require("client.slua.umg.lobby_activity.xsuit_spin.Config.XSuitSpinConfig")
  local GiftPacketCfg = Config.GiftPacket
  if not mailInfo then
    UIManager.ShowUIWithLuaAndBpPath(UIManager.UI_Config.MainUIWithoutLuaAndBpPathAsy, GiftPacketCfg.BaseLua, GiftPacketCfg.BPPath, giftInfo, mailInfo)
  else
    UIManager.ShowUI(UIManager.UI_Config.Xsuit_Gift_Confirm_UIBP, nil, function()
      UIManager.ShowUIWithLuaAndBpPath(UIManager.UI_Config.MainUIWithoutLuaAndBpPathAsy, GiftPacketCfg.BaseLua, GiftPacketCfg.BPPath, giftInfo, mailInfo)
    end)
  end
end
function LogicXSuit.ShowUpgradeUI(period, itemID, state, subtab, bScroll)
  log(bWriteLog and "LogicXSuit.ShowUpgradeUI period = " .. tostring(period) .. " || itemID = " .. tostring(itemID))
  if not GlobalData.ActResourceDownloaded({
    PufferConst.EODPackID.XSuit
  }, nil, nil, PufferConst.ENUM_DownloadType.ODPACK) then
    return false
  end
  if LogicXSuit.openUpgrade then
    UIManager.ShowUI(UIManager.UI_Config.golden_suit_upgrade, period, itemID, state, subtab, bScroll)
    return true
  else
    ShowNotice(120001)
    return false
  end
end
function LogicXSuit.ShowUpgradeSuccessUI(curLevel, period)
  local upgradeInfo = LogicXSuit.GetUpgradeInfo(period)
  if not upgradeInfo or not upgradeInfo[curLevel] then
    return
  end
  local info = {
    item_id = upgradeInfo[curLevel].item_id,
    level = curLevel,
    max_level = LogicXSuit.GetActSuitMaxLevelByPeriod(period),
    need_jump = upgradeInfo[curLevel].cfg.NeedJump
  }
  UIManager.ShowUI(UIManager.UI_Config.golden_suit_upgrade_popup, info)
end
function LogicXSuit.ShowUnlockStateSuccessUI(oldInfo, info)
  for period, data in pairs(info) do
    local oldData = oldInfo[period]
    for state, v in pairs(data.unlock_state) do
      local oldV = oldData.unlock_state[state]
      if not oldV or v ~= oldV then
        local ItemGetModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.rare_item_get_module)
        ItemGetModule:ShowOneXSuit(period, state)
      end
    end
  end
  log(bWriteLog and "LogicXSuit.ShowUnlockStateSuccessUI not diff found")
end
function LogicXSuit.ShowUpgradeUIFromURL()
  local isOpen = LogicXSuit.openUpgrade
  if not isOpen then
    ShowNotice(120001)
    return
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.workshop) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.workshop))
    return
  end
  LogicXSuit.ShowUpgradeUI(nil, nil, nil, nil, true)
end
function LogicXSuit.CanShowUpgradeBtn(itemID)
  local level = LogicXSuit.GetLevelByItemId(itemID)
  local period = LogicXSuit.GetPeriodByItemId(itemID)
  local info = LogicXSuit.GetBaseInfo(period)
  if level ~= nil and info ~= nil and level ~= info.max_level then
    return true
  else
    return false
  end
end
function LogicXSuit.GetUpgradeScrollViewList()
  local list = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local redPointData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGoldenSuitLotteryRedPoint)
  local version = LogicXSuit.GetMaxPeriod()
  for i = 1, version do
    if not LogicXSuit.GetUpgradeInfo(i) then
      break
    end
    local info = LogicXSuit.GetBaseInfo(i)
    local scrollInfo = {}
    scrollInfo.period = i
    scrollInfo.hasSuit = LogicXSuit.CheckHasSameGroupItem(info.item_id)
    local uiCfg = LogicXSuit.GetUpgradeUIInfo(i)
    if uiCfg then
      scrollInfo.imagePath = uiCfg.ItemImagePath
    end
    local redCfg = i and xsuit_config_and_cache.GetReddotWithWorkShopByPeriod(i)
    if redCfg and redCfg.version and version >= redCfg.version and (not (redPointData and redPointData[i] and redPointData[i].version) or version > redPointData[i].version) then
      scrollInfo.redPoint = true
    end
    if LogicXSuit.CheckShowTime(i) then
      table.insert(list, scrollInfo)
    end
  end
  table.sort(list, function(a, b)
    return a.period > b.period
  end)
  return list
end
function LogicXSuit.CheckShowTime(period)
  local config = xsuit_config_and_cache.GetVersionArgConfig()
  local maxPeriod = config.MAX_PERIOD or 1
  if not period or period > maxPeriod then
    return false
  end
  if LogicXSuit.shareTimeList and LogicXSuit.shareTimeList[period] then
    local init_show_time = LogicXSuit.shareTimeList[period].init_show_time
    if init_show_time and 0 < init_show_time then
      local TimeUtil = require("client.common.time_util")
      if init_show_time <= TimeUtil.GetServerTimeInSec() then
        log(bWriteLog and "LogicXSuit:CheckShowTime true, period = " .. tostring(period))
        return true
      end
    end
  end
  return false
end
function LogicXSuit.CheckShowByLevel(period, level)
  local maxPeriod = LogicXSuit.GetMaxPeriod()
  if not period or period > maxPeriod then
    return false
  end
  local redCfg = xsuit_config_and_cache.GetReddotWithWorkShopByPeriod(period)
  local version = redCfg and redCfg[level] and redCfg[level].version or maxPeriod
  return maxPeriod >= version
end
function LogicXSuit.CheckShowByLevelAndFeature(period, level, feature)
  local maxPeriod = LogicXSuit.GetMaxPeriod()
  if not period or period > maxPeriod then
    return false
  end
  local redCfg = xsuit_config_and_cache.GetReddotWithWorkShopByPeriod(period)
  local version = redCfg and redCfg[level] and redCfg[level] and redCfg[level][feature] and redCfg[level][feature].version or maxPeriod
  return maxPeriod >= version
end
function LogicXSuit.GetBaseInfo(period_id)
  if not period_id then
    return nil
  end
  if not LogicXSuit.bBaseInfoInited then
    LogicXSuit.InitXSuitBaseInfo()
  end
  if LogicXSuit.baseInfo then
    local info = LogicXSuit.baseInfo[period_id]
    if not info then
      return nil
    end
    local TableUtil = require("common.table_util")
    local newInfo = TableUtil.FastCopyTable(info)
    for i = newInfo.max_level, 1, -1 do
      if LogicXSuit.CheckShowByLevel(period_id, i) then
        newInfo.max_level = i
        newInfo.max_item_id = LogicXSuit.upgradeInfo[period_id][i].item_id
        return newInfo
      end
    end
  else
    return nil
  end
end
function LogicXSuit.GetUpgradeInfo(period_id)
  if not LogicXSuit.bBaseInfoInited then
    LogicXSuit.InitXSuitBaseInfo()
  end
  local info = LogicXSuit.upgradeInfo[period_id]
  local TableUtil = require("common.table_util")
  local newInfo = TableUtil.FastCopyTable(info)
  for index = #newInfo, 1, -1 do
    if not LogicXSuit.CheckShowByLevel(period_id, index) then
      table.remove(newInfo, index)
    else
      for featureIndex = maxFeatureCount, 1 do
        if info["SubTabID" .. featureIndex] and not LogicXSuit.CheckShowByLevelAndFeature(period_id, index, featureIndex) then
          table.remove(newInfo[index], featureIndex)
        end
      end
    end
  end
  return newInfo
end
function LogicXSuit.GetUpgradeUIInfo(period_id)
  local cfg = CDataTable.GetTableData("GoldenSuitUpgradeUICfg", period_id)
  return cfg
end
function LogicXSuit._InitOneUpgradeInfo(data)
  if LogicXSuit.upgradeInfo[data.Period] == nil then
    LogicXSuit.upgradeInfo[data.Period] = {}
  end
  LogicXSuit.materialItemIDMap[data.MatID1] = true
  LogicXSuit.materialItemIDMap[data.MatID2] = true
  if data.SecondMatID and data.SecondMatID ~= 0 and data.SecondMatID ~= data.MatID1 and data.SecondMatID ~= data.MatID2 then
    LogicXSuit.unlockStateMatMap[data.SecondMatID] = data.Period
  end
  if data.SecondMatID2 and data.SecondMatID2 ~= 0 and data.SecondMatID2 ~= data.MatID1 and data.SecondMatID2 ~= data.MatID2 then
    LogicXSuit.unlockStateMatMap[data.SecondMatID2] = data.Period
  end
  local info = {
    cfg = data,
    item_id = data.ItemID,
    tab_name_array = {
      data.SubTabID1,
      data.SubTabID2,
      data.SubTabID3,
      data.SubTabID4,
      data.SubTabID5
    },
    tab_desc_array = {
      data.TabDesc1,
      data.TabDesc2,
      data.TabDesc3,
      data.TabDesc4,
      data.TabDesc5
    },
    effect_id_array = {
      data.Effect1,
      data.Effect2,
      data.Effect3,
      data.Effect4,
      data.Effect5
    }
  }
  LogicXSuit.upgradeInfo[data.Period][data.Star] = info
end
function LogicXSuit.OnGetXSuitDrawInfo(open, info, unlock_info)
  log_shipping_client("v_byyyang LogicXSuit.OnGetXSuitDrawInfo open:" .. tostring(open))
  log(bWriteLog and "LogicXSuit.OnGetXSuitDrawInfo open = " .. tostring(open) .. " || is : " .. tostring(open == 1))
  if info then
    local config = xsuit_config_and_cache.GetVersionArgConfig()
    local maxPeriod = config.MAX_PERIOD or 1
    for i, _ in ipairs(info) do
      if i > maxPeriod then
        info[i] = nil
      end
    end
  end
  if info then
    LogicXSuit.shareTimeList = info
  end
  log_tree("LogicXSuit.shareTimeList = ", LogicXSuit.shareTimeList)
  if unlock_info then
    LogicXSuit.unlockFeatureInfo = unlock_info
    log_tree("LogicXSuit.unlockFeatureInfo = ", LogicXSuit.unlockFeatureInfo)
  else
    log(bWriteLog and "LogicXSuit.OnGetXSuitDrawInfo not unlock_info")
  end
  EventSystem:postEvent(EVENTTYPE_SHARECOMPONENT, EVENTID_SHARECOMPONENT_UPDATE_SHARE_TIME)
end
function LogicXSuit._InitOneBaseInfo(data)
  if LogicXSuit.baseInfo[data.Period] == nil then
    LogicXSuit.baseInfo[data.Period] = {}
  end
  local info = LogicXSuit.baseInfo[data.Period]
  if data.RelicID ~= 0 and data.RelicID ~= "" then
    info.relic_id = data.RelicID
  end
  if data.Star == 1 then
    info.item_id = data.ItemID
  end
  if info.max_level == nil or data.Star > info.max_level then
    info.max_level = data.Star
    info.max_item_id = data.ItemID
  end
  if data.ActID ~= 0 then
    info.act_id = data.ActID
  end
end
function LogicXSuit.InitXSuitItemList()
  if LogicXSuit.bItemInfoInited then
    return
  end
  local cfg
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    cfg = CDataTable.GetTable("GoldenSuitUpgradeCfgKJ")
  elseif PublishRegionMacros.IsBLUEHOLE() then
    cfg = CDataTable.GetTable("GoldenSuitUpgradeCfgIN")
  else
    cfg = CDataTable.GetTable("GoldenSuitUpgradeCfg")
  end
  for _, data in pairs(cfg) do
    LogicXSuit.itemInfoList[data.ItemID] = {
      period = data.Period,
      level = data.Star
    }
  end
  LogicXSuit.bItemInfoInited = true
end
function LogicXSuit.InitXSuitBaseInfo()
  if LogicXSuit.bBaseInfoInited then
    return
  end
  local cfg
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    cfg = CDataTable.GetTable("GoldenSuitUpgradeCfgKJ")
  elseif PublishRegionMacros.IsBLUEHOLE() then
    cfg = CDataTable.GetTable("GoldenSuitUpgradeCfgIN")
  else
    cfg = CDataTable.GetTable("GoldenSuitUpgradeCfg")
  end
  for _, j in pairs(cfg) do
    LogicXSuit._InitOneBaseInfo(j)
    LogicXSuit._InitOneUpgradeInfo(j)
  end
  LogicXSuit.bBaseInfoInited = true
end
function LogicXSuit.SetSendCondtionInfo(condtion)
  LogicXSuit.  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_GOLDSUIT_INTIMACY_RETURN, condtion)
end
function LogicXSuit.SetItemBeClick(Index, data)
  LogicXSuit.ItemBeClick[tostring(Index)] = data
end
function LogicXSuit.GetCondtion()
  if next(LogicXSuit.condtion) then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_GOLDSUIT_INTIMACY_RETURN, LogicXSuit.condtion)
  else
    local logic_give_item = require("client.slua.logic.give_item.logic_give_item")
    local condition = logic_give_item.GetGiveConditionByType(logic_give_item.EnumGiveType.goldSuit)
    local t = {
      friend_time = math.tointeger((condition.sendMinSeconds or 0) / 3600),
      friend_intimacy = condition.sendMinIntimacy,
      role_level = condition.sendMinLevel
    }
    LogicXSuit.SetSendCondtionInfo(t)
  end
end
function LogicXSuit.ShowSendGiftUI(itemId, isFromExchange)
  local Logic_FriendGiftPopupShow = require("client.slua.logic.ItemGiveAndAsk.Logic_FriendGiftPopupShow")
  local Logic_ItemGiveAndAskConst = require("client.slua.logic.ItemGiveAndAsk.Logic_ItemGiveAndAskConst")
  local nGiveType = Logic_ItemGiveAndAskConst.Enum_GiveGiftType.XSuit
  Logic_FriendGiftPopupShow.ShowOnlyGiveFriendGift(nGiveType, itemId, nil, {bGiveXSuitFormExchange = isFromExchange})
end
function LogicXSuit.GetSuitItemIDByPeriod(period)
  if period then
    local info = LogicXSuit.GetBaseInfo(period)
    if info then
      return info.item_id, info.max_item_id
    end
  end
end
function LogicXSuit.CheckShareReady(itemId)
  local period = LogicXSuit.GetPeriodByItemId(itemId)
  if period then
    local baseCfg = LogicXSuit.CreateXsuitShareConfig(period)
    local pak_util = require("client.common.pak_util")
    local isDownloaded = pak_util.IsPufferDownloaded(baseCfg.path)
    return isDownloaded, baseCfg.path
  end
  return true
end
function LogicXSuit.CreateXsuitShareConfig(period)
  local shareCfg = xsuit_config_and_cache.GetShareWithWorkshopByPeriod(period or 0)
  local config = {
    moduleName = "client.slua.umg.golden_suit.share.golden_suit_share_base",
    path = shareCfg and shareCfg.path,
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\156\163\232\163\133-\229\136\134\228\186\171\231\149\140\233\157\162"
    },
    AndroidBackType = 2,
    keyName = string.format("golden_suit_share_base_%d", period or 0)
  }
  return config
end
function LogicXSuit.ShowGoldSuitShareUI(itemId, bReleaseMoment)
  local period = LogicXSuit.GetPeriodByItemId(itemId)
  local baseCfg = LogicXSuit.CreateXsuitShareConfig(period)
  if bReleaseMoment then
    local logic_moment = require("client.slua.logic.moment.logic_moment")
    logic_moment.ShowMomentShare()
  else
    local Util = require("client.slua_ui_framework.util")
    local cfg = {
      campaign = "golden_suit",
      isOld = true,
      nItemId = itemId,
      share_type = ShareBtnTLogShareTypeDefine.HolyCostume,
      reasonStr = json.encode({
        uid = DataMgr.roleData.uid,
              })
    }
    local ShareMgr = require("client.logic.share.share_logic")
    ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.HolyCostume, nil, nil)
    Util.ShowShare(cfg, baseCfg, itemId)
  end
end
function LogicXSuit.PopCommonTip(msglist)
  if not msglist or not next(msglist) then
    return
  end
  if IsWoWEditor then
    return
  end
  local uidlist = {}
  for i, v in ipairs(msglist) do
    table.insert(uidlist, v.uid)
  end
  local cb = function()
    local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
    if logic_achievement_float_tip.IslenthZeroNewAchievementList() then
      local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
      local logic_tarotcard_exchange_sendgift = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tarotcard_exchange_sendgift)
      for i, v in ipairs(msglist) do
        if logic_xsuit_activity:GetPeriodByCardItem(nil, v.item, nil) ~= 0 then
          LogicXSuit.CheckXsuitAssert({
            PufferConst.EODPackID.XSuit
          }, function()
            UIManager.ShowUI(UIManager.UI_Config.XSuitGiftReceiveTips, v)
          end, nil, {bFirst = true})
        elseif logic_tarotcard_exchange_sendgift:CanPop(v.item) then
          UIManager.ShowUI(UIManager.UI_Config.TarotCardGiftReceiveTips, v)
        else
          UIManager.ShowUI(UIManager.UI_Config.Common_Receive_UIBP, v)
        end
      end
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetFriendProfiles(0, uidlist, cb)
end
function LogicXSuit.ClosePopTip()
  local ui = UIManager.GetUI(UIManager.UI_Config.Common_Receive_UIBP)
  if ui then
    UIManager.CloseUI(UIManager.UI_Config.Common_Receive_UIBP)
  end
end
function LogicXSuit.TipDecompose(instid, decomposeInfo)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = WardrobeData:GetHallDepotItemDataByInsID(instid)
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  local period_id = logic_xsuit_activity:GetPeriodByCardItem(itemInfo.resID, itemInfo.resID, itemInfo.resID)
  local itemId = LogicXSuit.GetSuitItemIDByPeriod(period_id)
  if not itemId then
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  local decomposeItemCfg = CDataTable.GetTableData("Item", decomposeInfo.itemid)
  local InstCfg = CDataTable.GetTableData("Item", itemInfo.resID)
  local title = LocUtil.GetLocalizeResStr(5077)
  local tip = LocUtil.LocalizeResFormat(9975, itemCfg.ItemName, decomposeItemCfg.ItemName, decomposeInfo.count, InstCfg.ItemName)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tip, function()
    local logic_decompose = require("client.logic.decompose.logic_decompose")
    logic_decompose.SendDecomposeMsg(tonumber(instid), 1, true)
  end)
end
function LogicXSuit.GetPriceList(itemData)
  local PriceList = itemData[StoreConst.label_item_index_price_list]
  local t1 = {}
  local t2 = {}
  if PriceList and next(PriceList) then
    local firstType = PriceList[1][StoreConst.label_price_index_price_type]
    for i, v in ipairs(PriceList) do
      local conversion = {}
      conversion.validHours = v[StoreConst.label_price_index_valid_hours]
      conversion.moneytype = v[StoreConst.label_price_index_price_type]
      if v[StoreConst.label_price_index_one_discount_price] and v[StoreConst.label_price_index_one_discount_price] > 0 then
        conversion.price = v[StoreConst.label_price_index_one_discount_price]
      else
        conversion.price = v[StoreConst.label_price_index_one_original_price]
      end
      if v[StoreConst.label_price_index_price_type] == firstType then
        table.insert(t1, conversion)
      else
        table.insert(t2, conversion)
      end
    end
  end
  if next(t1) then
    return t1
  else
    return t2
  end
end
function LogicXSuit.GetSendGiftId(exchange_id)
  local cfg = CDataTable.GetTable("GoldenSuitMapCfg")
  local sendId
  for i, info in pairs(cfg) do
    if info.ExchangeID == exchange_id then
      sendId = info.AcceptID
      break
    end
  end
  return sendId
end
function LogicXSuit.GetEnterActionByPeriod(period, state)
  local config = CDataTable.GetTableData("GoldenSuitMapCfg", period)
  if not config then
    return nil
  end
  local enterActionID
  if config.EnterActionID and config.EnterActionID ~= 0 then
    enterActionID = config.EnterActionID
  end
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  enterActionID = multi_state_manager:ChangeEmoteByState(enterActionID, state)
  return enterActionID
end
function LogicXSuit.GetExchagngeGiftIdOnCfg(send_id)
  local cfg = CDataTable.GetTable("GoldenSuitMapCfg")
  local exchangeID
  for i, info in pairs(cfg) do
    if send_id == info.AcceptID then
      exchangeID = info.ExchangeID
      break
    end
  end
  return exchangeID
end
function LogicXSuit.RefreshPlayActionUidList(info)
  if not info or not info.members then
    return
  end
  for k, v in pairs(LogicXSuit.playedActionUidMap) do
    if not info.members[k] then
      LogicXSuit.playedActionUidMap[k] = false
    end
  end
end
function LogicXSuit.RefreshSharedRelicInfo(info)
  log(bWriteLog and "LogicXSuit.RefreshSharedRelicInfo")
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local team_info = info or TeamUpNewSystem.teamInfo
  if not team_info or not team_info.members then
    return
  end
  LogicXSuit.needShowRelicID = 0
  LogicXSuit.needShowRelicUid = 0
  LogicXSuit.playerEquipItemID = 0
  local needShowRating = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(team_info.members) do
    local golden_suit_id = 0
    if v.uid == tonumber(DataMgr.roleData.uid) then
      local tRoleWear = AvatarData.GetRoleWear()
      for _, instId in ipairs(tRoleWear) do
        local data = wardrobe_data:GetHallDepotItemDataByInsID(instId)
        if data and data.resID and LogicXSuit.IsXSuit(data.resID) and wardrobe_data:GetItemSource(instId) ~= EWardrobeDataSource.InheritWardrobe and LogicXSuit.CheckHasEquipXSuit() then
          golden_suit_id = data.resID
          LogicXSuit.playerEquipItemID = golden_suit_id
          break
        end
      end
    elseif v.wear_ext and v.wear_ext[3] and v.wear_ext[3][1] and v.wear_ext[3][ENUM_AVATAR_DATA_TYPE.Source] ~= EWardrobeDataSource.InheritWardrobe then
      local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
      local OriginItemID = multi_state_manager:GetOriginClothIDAndState(v.wear_ext[3][1]) or v.wear_ext[3][1]
      if LogicXSuit.IsXSuit(OriginItemID) then
        golden_suit_id = OriginItemID
      end
    end
    local relicID = LogicXSuit.GetShowRelicID(golden_suit_id)
    if relicID and needShowRating < v.max_segment_rating then
      LogicXSuit.needShowRelicID = relicID
      LogicXSuit.needShowRelicUid = tostring(v.uid)
      needShowRating = v.max_segment_rating
    end
  end
  log(bWriteLog and string.format("[Debug][Suit][Team] LogicXSuit.RefreshSharedRelicInfo needShowRelicId: %d, needShowRelicUid: %d", LogicXSuit.needShowRelicID or 0, LogicXSuit.needShowRelicUid or 0))
  EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_REFRESH_RELIC_STATUS)
end
function LogicXSuit.GetXSuitTeamupAction(member_info)
  if not member_info then
    return
  end
  local action_info = LogicXSuit.needPlayActionMember[tostring(member_info.uid)]
  if not action_info then
    return
  end
  return action_info.actionID
end
function LogicXSuit.RefreshTeamInfo(info)
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local team_  if team_info == nil then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    team_info = TeamUpNewSystem.teamInfo
  end
  if not (team_info.members ~= nil and team_info.player_count) or team_info.player_count <= 1 then
    LogicXSuit.ClearPlayedActionUid()
  end
  if team_info.members == nil then
    return false
  end
  LogicXSuit.RefreshPlayActionUidList(info)
  LogicXSuit.needPlayActionMember = {}
  local team_member = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(team_info.members) do
    local golden_suit_id = 0
    local golden_suit_source = EWardrobeDataSource.Wardrobe
    local unlockLevel
    local state = 0
    LogicXSuit.playerEquipItemID = 0
    if v.uid == tonumber(DataMgr.roleData.uid) then
      local tRoleWear = AvatarData.GetRoleWear()
      for _, instId in pairs(tRoleWear) do
        local data = wardrobe_data:GetHallDepotItemDataByInsID(instId)
        if data and data.resID and LogicXSuit.IsXSuit(data.resID) and LogicXSuit.CheckHasEquipXSuit() then
          golden_suit_source = wardrobe_data:GetItemSource(instId)
          local period = LogicXSuit.GetPeriodByItemId(data.resID)
          if period and v.gold_dress_set_info and v.gold_dress_set_info[period] and golden_suit_source ~= EWardrobeDataSource.InheritWardrobe then
            golden_suit_id = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(data.resID, v.gold_dress_set_info[period])
            LogicXSuit.playerEquipItemID = golden_suit_id
          else
            golden_suit_id = data.resID
            LogicXSuit.playerEquipItemID = golden_suit_id
          end
          if period then
            unlockLevel = LogicXSuit.GetLevelByItemId(data.resID)
            state = LogicXSuit.GetCurStateByInsID(instId)
          end
          break
        end
      end
    elseif v.wear_ext and v.wear_ext[3] and v.wear_ext[3][1] then
      local period = LogicXSuit.GetPeriodByItemId(v.wear_ext[3][1])
      if LogicXSuit.IsXSuit(v.wear_ext[3][1]) then
        unlockLevel = LogicXSuit.GetLevelByItemId(v.wear_ext[3][1])
        golden_suit_source = v.wear_ext[3][ENUM_AVATAR_DATA_TYPE.Source] or golden_suit_source
        if golden_suit_source ~= EWardrobeDataSource.InheritWardrobe and period and v.gold_dress_set_info and v.gold_dress_set_info[period] then
          golden_suit_id = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(v.wear_ext[3][1], v.gold_dress_set_info[period])
        else
          golden_suit_id = v.wear_ext[3][ENUM_AVATAR_DATA_TYPE.ItemID]
        end
        if period and v.gold_dress_set_info_all and v.gold_dress_set_info_all[period] then
          state = v.gold_dress_set_info_all[period].bicolor_state
        end
      end
    end
    local isOtherPlayer = tostring(v.uid) ~= DataMgr.roleData.uid
    local actionID = LogicXSuit.GetActionByItemId(golden_suit_id, isOtherPlayer, state, unlockLevel, v) or 0
    log(bWriteLog and "v.uid  = " .. tostring(v.uid) .. " || actionID = " .. tostring(actionID))
    if actionID and actionID ~= 0 then
      LogicXSuit.needPlayActionMember[tostring(v.uid)] = {actionID = actionID, itemID = golden_suit_id}
    end
    team_member = team_member + 1
  end
  LogicXSuit.RefreshSharedRelicInfo(info)
end
function LogicXSuit.CheckHasEquipXSuit(uid, tarAvatar, period)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar
  if tarAvatar then
    avatar = tarAvatar
  elseif uid ~= nil then
    avatar = TeamAvatarManager.GetAvatarByUid(uid)
  else
    avatar = TeamAvatarManager.GetMainAvatar()
  end
  if not avatar then
    return false
  end
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  if not LogicXSuit.bItemInfoInited then
    LogicXSuit.InitXSuitItemList()
  end
  for i, j in pairs(LogicXSuit.itemInfoList) do
    if not period or j.period == period then
      if avatar:HasEquiped(i) then
        return true
      end
      local allDisplayID = multi_state_manager:GetAllDisplayClothIDByOriginID(i)
      if allDisplayID then
        for _, disPlayID in pairs(allDisplayID) do
          if avatar:HasEquiped(disPlayID) then
            return true
          end
        end
      end
    end
  end
  return false
end
function LogicXSuit.GetShowRelicID(itemID)
  local level = LogicXSuit.GetLevelByItemId(itemID)
  if not level or level < 2 then
    return nil
  end
  local period = LogicXSuit.GetPeriodByItemId(itemID)
  if period then
    local baseInfo = LogicXSuit.GetBaseInfo(period)
    if baseInfo then
      return baseInfo.relic_id
    end
  end
  return nil
end
function LogicXSuit.CheckHasEquipXSuitByAction(action_id)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local period = LogicXSuit.actionPeriodMap[action_id]
  if period == nil or LogicXSuit.GetUpgradeInfo(period) == nil then
    return false, false
  end
  local avatar = TeamAvatarManager.GetMainAvatar()
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  for i, info in pairs(LogicXSuit.GetUpgradeInfo(period)) do
    if avatar:HasEquiped(info.item_id) then
      return true, 1 < i
    end
    local allDisplayID = multi_state_manager:GetAllDisplayClothIDByOriginID(info.item_id)
    if allDisplayID then
      for _, disPlayID in pairs(allDisplayID) do
        if avatar:HasEquiped(disPlayID) then
          return true, 1 < i
        end
      end
    end
  end
  return false, false
end
function LogicXSuit.IsBattleEmotion(action_id)
  log(bWriteLog and "LogicXSuit.IsBattleEmotion " .. tostring(action_id))
  local cfg = CDataTable.GetTable("GoldenSuitMapCfg")
  for i, j in pairs(cfg) do
    if action_id == j.BattleActionID then
      return true, i
    end
  end
  return false
end
function LogicXSuit.GetItemIDByLevel(period, level)
  local cfgList = LogicXSuit.GetUpgradeInfo(tonumber(period))
  if cfgList and cfgList[level] then
    return cfgList[level].item_id
  end
end
function LogicXSuit.RefreshAllTeammateRelic()
  for uid, data in pairs(LogicXSuit.relicInfoList) do
    if data and data.status and data.wearID ~= 0 then
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      TeamAvatarManager.PutonEquipment(uid, data.wearID)
    end
  end
end
function LogicXSuit.OnRelicStatusChange(uid, itemid, status)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  uid = tostring(uid)
  if not LogicXSuit.relicInfoList[uid] then
    LogicXSuit.relicInfoList[uid] = {status = false, wearID = 0}
  end
  local relicInfo = LogicXSuit.relicInfoList[uid]
  local oldStatus = relicInfo.status or false
  local afterStatus = status == 2 and itemid ~= 0
  if itemid == 0 then
    afterStatus = false
  end
  log(bWriteLog and "[Debug][Suit][Team] GetPlayerRelicStatus change uid = " .. tostring(uid) .. "|| oldStatus = " .. tostring(oldStatus) .. " || afterStatus = " .. tostring(afterStatus))
  local oldWearID = relicInfo.wearID
  relicInfo.status = afterStatus
  relicInfo.wearID = afterStatus and itemid or 0
  if oldStatus and not afterStatus then
    if itemid ~= 0 then
      TeamAvatarManager.PutoffEquipment(uid, itemid)
    end
    if oldWearID ~= 0 and oldWearID ~= itemid then
      TeamAvatarManager.PutoffEquipment(uid, oldWearID)
    end
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    local selectSharedItems = logic_share_bag_team_util:GetLastSelectSharedItemsByUID(uid)
    logic_share_bag_team_util:UpdateTeamAvatar(uid, selectSharedItems, true)
    EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_REFRESH_RELIC_STATUS)
    if uid == tostring(DataMgr.roleData.uid) then
      EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_RELIC_STATUS, oldWearID, false)
    end
  elseif not oldStatus and afterStatus then
    TeamAvatarManager.PutonEquipment(uid, itemid)
    EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_REFRESH_RELIC_STATUS)
    if uid == tostring(DataMgr.roleData.uid) then
      EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_RELIC_STATUS, itemid, true)
    end
  elseif oldStatus and afterStatus then
    TeamAvatarManager.PutoffEquipment(uid, oldWearID)
    TeamAvatarManager.PutonEquipment(uid, itemid)
    EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_REFRESH_RELIC_STATUS)
    if uid == tostring(DataMgr.roleData.uid) then
      EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_RELIC_STATUS, itemid, true)
    end
  end
end
function LogicXSuit.CheckAndPlayEnterAction(AvatarUID)
  local actionID = LogicXSuit.GetNeedPlayActionID(AvatarUID)
  if actionID == nil then
    return false
  end
  log(bWriteLog and "LogicXSuit.CheckAndPlayEnterAction" .. actionID)
  LogicXSuit.SetPlayedActionUid(AvatarUID)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.StopAction(AvatarUID)
  local isSelf = tonumber(AvatarUID) == tonumber(DataMgr.roleData.uid)
  local enterActionReplaceCfg = CDataTable.GetTableData("GoldenSuitEnterReplaceTable", actionID)
  if isSelf and enterActionReplaceCfg and enterActionReplaceCfg.CameraActionID ~= 0 and not LobbySceneManager.CheckCanSwitchToLobbyCamera() then
    if LogicXSuit.CheckSingleItemDownloadStatus(enterActionReplaceCfg.CameraActionID) then
      log(bWriteLog and "LogicXSuit.CheckAndPlayEnterAction Play CameraAction")
      local logic_lobby = require("client.slua.logic.lobby.logic_lobby_main")
      logic_lobby.HideLobbyUI()
      UIManager.ShowUI(UIManager.UI_Config.XSuit_EnterAction, AvatarUID, enterActionReplaceCfg.CameraActionID)
      return true
    else
      return false
    end
  else
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.01, function()
      log(bWriteLog and "CheckAndPlayEnterAction GoldenSuit actionID:" .. tostring(actionID))
      TeamAvatarManager.PlayAction(AvatarUID, actionID)
    end)
    return true
  end
end
function LogicXSuit.GetNeedPlayActionID(uid)
  local numberUid = tonumber(uid)
  if numberUid and LogicXSuit.playedActionUidMap[numberUid] then
    return nil
  end
  local info = LogicXSuit.needPlayActionMember[tostring(uid)]
  if info and info.itemID and LogicXSuit.CheckSingleItemDownloadStatus(info.itemID) then
    return info.actionID
  end
  return nil
end
function LogicXSuit.SetPlayedActionUid(uid)
  local numberUid = tonumber(uid)
  if numberUid then
    LogicXSuit.playedActionUidMap[numberUid] = true
  end
end
function LogicXSuit.ClearPlayedActionUidById(nUid)
  local numberUid = tonumber(nUid)
  if numberUid then
    LogicXSuit.playedActionUidMap[numberUid] = nil
  end
end
function LogicXSuit.ClearPlayedActionUid()
  LogicXSuit.playedActionUidMap = {}
end
function LogicXSuit.CheckNeedPutOnRelic(uid)
  log(bWriteLog and "[jonahwei][Suit][Team] CheckNeedPutOnRelic uid = " .. tostring(uid))
  local relicInfo = LogicXSuit.relicInfoList[uid]
  if relicInfo and relicInfo.status == true and relicInfo.wearID ~= 0 then
    return true, relicInfo.wearID
  end
  return false
end
function LogicXSuit.GetPlayerRelicStatus(uid)
  uid = tostring(uid)
  log(bWriteLog and "[Debug][Suit][Team] GetPlayerRelicStatus uid = " .. tostring(uid) .. "|| LogicXSuit.needShowUid = " .. tostring(LogicXSuit.needShowRelicUid) .. "|| relicInfoList[uid].status = " .. tostring(LogicXSuit.relicInfoList[uid] and LogicXSuit.relicInfoList[uid].status) .. " CheckHasEquipXSuit(): " .. tostring(LogicXSuit.CheckHasEquipXSuit()) .. " LogicXSuit.playerEquipItemID: " .. tostring(LogicXSuit.playerEquipItemID))
  if LogicXSuit.needShowRelicUid == tonumber(DataMgr.roleData.uid) or LogicXSuit.needShowRelicUid == 0 or LogicXSuit.CheckHasEquipXSuit() then
    return nil
  end
  if LogicXSuit.playerEquipItemID ~= 0 then
    return nil
  end
  local relicInfo = LogicXSuit.relicInfoList[uid]
  return relicInfo and relicInfo.status or false
end
function LogicXSuit.GetPeriodByItemId(itemID)
  if not LogicXSuit.bItemInfoInited then
    LogicXSuit.InitXSuitItemList()
  end
  if LogicXSuit.itemInfoList[itemID] then
    return LogicXSuit.itemInfoList[itemID].period
  end
  return nil
end
function LogicXSuit.GetLevelByItemId(itemID)
  if not LogicXSuit.bItemInfoInited then
    LogicXSuit.InitXSuitItemList()
  end
  if LogicXSuit.itemInfoList[itemID] then
    return LogicXSuit.itemInfoList[itemID].level
  end
  return nil
end
function LogicXSuit.GetActionByItemId(itemID, isOtherPlayer, state, unlockLevel, v)
  local gold_dress_set_info_all = v.gold_dress_set_info_all
  local action_type_set_info = v.action_type_set_info
  local period = LogicXSuit.GetPeriodByItemId(itemID)
  if period ~= nil then
    local level = LogicXSuit.GetLevelByItemId(itemID)
    if level < 2 then
      return 0
    end
    local cfg = CDataTable.GetTableData("GoldenSuitMapCfg", period)
    if not cfg then
      return 0
    end
    local low_action_id = cfg.LowTeamupActionID
    local UnLockFeatureType = require("GameLua.Activity.Commercialize.GamePlay.XSuit.UnLockFeatureType")
    local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
    local isUnLockFeature, FeatureLevel, FeatureIndex = XSuitUtil:IsUnlockedFeature(period, UnLockFeatureType.TeamEnterAction2)
    if not isUnLockFeature or gold_dress_set_info_all[period] and gold_dress_set_info_all[period].unlock_info and gold_dress_set_info_all[period].unlock_info[FeatureLevel] and gold_dress_set_info_all[period].unlock_info[FeatureLevel][FeatureIndex] and gold_dress_set_info_all[period].unlock_info[FeatureLevel][FeatureIndex].state == 1 then
    else
      low_action_id = 0
    end
    if level == 2 and 0 < low_action_id then
      return low_action_id
    end
    if level < 5 then
      local LowLevelEffect = require("GameLua.Activity.Commercialize.GamePlay.XSuit.LowLevelEffect")
      if not XSuitUtil:IsValidXSuitEffect(itemID, LowLevelEffect.TeamEnterAction5, unlockLevel) then
        return low_action_id
      end
    end
    if isOtherPlayer then
      if action_type_set_info and action_type_set_info[period] == 2 then
        return low_action_id
      end
      local otherActionId = cfg.OtherTeamupActionID
      if otherActionId and otherActionId ~= 0 then
        return otherActionId
      end
    else
      local levelAction = LogicXSuit.GetLevelAction(period)
      if levelAction == 2 then
        return low_action_id
      end
    end
    local action = cfg.TeamupActionID
    local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
    action = multi_state_manager:ChangeEmoteByState(action, state)
    return action
  end
  return nil
end
function LogicXSuit.IsXSuit(itemID)
  if not LogicXSuit.bItemInfoInited then
    LogicXSuit.InitXSuitItemList()
  end
  return LogicXSuit.itemInfoList[itemID] ~= nil
end
function LogicXSuit.IsXSuitEmotion(itemID)
  local cfg = CDataTable.GetTable("GoldenSuitMapCfg")
  for i, v in pairs(cfg) do
    if itemID == v.BattleActionID or itemID == v.InviterActionID then
      return true
    end
  end
  return false
end
function LogicXSuit.IsMuNaiYiBlockItem(itemID)
  if not itemID then
    return false
  end
  local config = CDataTable.GetTableData("MuNaiYiBlockCfg", itemID)
  return config ~= nil
end
function LogicXSuit.GetLevelByPeriod(period, source)
  if LogicXSuit.GetUpgradeInfo(period) then
    local level = 0
    for i, info in pairs(LogicXSuit.GetUpgradeInfo(period)) do
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      if wardrobe_data:GetHallDepotItemDataByResIDAndSource(info.item_id, source) ~= nil then
        level = i
      end
    end
    log(bWriteLog and "LogicXSuit.GetLevelByPeriod level = " .. tostring(level))
    return level
  else
    return 0
  end
end
function LogicXSuit.GetItemIDByPeriod(period, source)
  local level = LogicXSuit.GetLevelByPeriod(period, source)
  if level then
    if not LogicXSuit.bItemInfoInited then
      LogicXSuit.InitXSuitItemList()
    end
    for i, j in pairs(LogicXSuit.itemInfoList) do
      if j.level == level and j.period == period then
        return i
      end
    end
  end
  return nil
end
function LogicXSuit.GetItemIDListByPeriod(period)
  local itemList = {}
  if not LogicXSuit.bItemInfoInited then
    LogicXSuit.InitXSuitItemList()
  end
  for itemID, v in pairs(LogicXSuit.itemInfoList) do
    if v.period == period then
      table.insert(itemList, itemID)
      local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
      local changeStateAction = multi_state_manager:GetStateChangeAction(itemID)
      if changeStateAction then
        for beforeCloth, action in pairs(changeStateAction) do
          table.insert(itemList, beforeCloth)
          table.insert(itemList, action)
        end
      end
    end
  end
  local config = CDataTable.GetTableData("GoldenSuitMapCfg", period)
  if config and config.BattleActionID and config.BattleActionID ~= 0 then
    table.insert(itemList, config.BattleActionID)
  end
  return itemList
end
function LogicXSuit.CheckHasSameGroupItem(resID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local period = LogicXSuit.GetPeriodByItemId(resID)
  if not period then
    return false
  end
  local groupList = LogicXSuit.GetUpgradeInfo(period)
  if groupList then
    for _, info in ipairs(groupList) do
      if wardrobe_data:GetHallDepotItemDataByResID(info.item_id) ~= nil then
        return true, info.item_id
      end
    end
  end
  return false
end
function LogicXSuit.PutOffSameGroupItem(resID)
  local period = LogicXSuit.GetPeriodByItemId(resID)
  if not period then
    return
  end
  local groupList = LogicXSuit.GetUpgradeInfo(period)
  if groupList then
    for _, info in ipairs(groupList) do
      local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
      if ModelDisplayer.HasEquiped(info.item_id) then
        ModelDisplayer.Display(info.item_id, false)
      end
    end
  end
end
function LogicXSuit.IsNeedStopActionWhenPutOn(actionID)
  if not LogicXSuit.inviteActionMap then
    LogicXSuit.InitInviteAction()
  end
  for i, j in pairs(LogicXSuit.inviteActionMap) do
    if i == actionID then
      return true
    end
    for _, jj in pairs(j) do
      if jj == actionID then
        return true
      end
    end
  end
  return false
end
function LogicXSuit.CheckDownloadStatus(resID)
  log(bWriteLog and "LogicXSuit.CheckDownloadStatus resID: " .. tostring(resID) .. " " .. type(resID))
  if not _G.IsEditor and not PufferDownloader.PufferJsonDownloadReturn then
    return false
  end
  local period = LogicXSuit.GetPeriodByItemId(resID)
  if not period then
    return false
  end
  local groupList = LogicXSuit.GetUpgradeInfo(period)
  if groupList then
    local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
    for _, info in ipairs(groupList) do
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
        info.item_id
      })
      log(bWriteLog and "CheckDownloadStatus check item_id: " .. tostring(info.item_id) .. " state: " .. tostring(state))
      if state ~= PufferConst.ENUM_DownloadState.Done then
        return false
      end
      local allDisplayID = multi_state_manager:GetAllDisplayClothIDByOriginID(info.item_id)
      if allDisplayID then
        state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, allDisplayID)
        log(bWriteLog and "CheckDownloadStatus check allDisplayID: " .. tostring(info.item_id) .. " state: " .. tostring(state))
        if state ~= PufferConst.ENUM_DownloadState.Done then
          return false
        end
      end
    end
  else
    log(bWriteLog and "groupList if nil")
  end
  log(bWriteLog and "LogicXSuit.CheckDownloadStatus return true")
  return true
end
function LogicXSuit.CheckSingleItemDownloadStatus(resID)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {resID})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    return false
  else
    return true
  end
end
function LogicXSuit.SuitNeedUpgrading(period)
  local level = LogicXSuit.GetLevelByPeriod(period)
  local maxLevel = LogicXSuit.GetActSuitMaxLevelByPeriod(period)
  return 0 < level and level < maxLevel
end
function LogicXSuit.GetActSuitMaxLevelByPeriod(period)
  if not period then
    return nil
  end
  local _, maxItemID = LogicXSuit.GetSuitItemIDByPeriod(period)
  if maxItemID then
    return LogicXSuit.GetLevelByItemId(maxItemID)
  end
  return 0
end
function LogicXSuit.GetNextLevelMaterialInfo(period)
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  local exchangeGridData = logic_xsuit_activity:GetExchangeData()
  if not (wardrobeData and exchangeGridData) or not next(exchangeGridData) then
    return nil
  end
  period = period or logic_xsuit_activity:GetCurrentPeriod()
  local level = 0
  if period then
    level = LogicXSuit.GetLevelByPeriod(period)
    local maxLevel = LogicXSuit.GetActSuitMaxLevelByPeriod(period)
    if not (level and maxLevel) or level <= 0 or level >= maxLevel then
      return nil
    end
  end
  local result = {
    matInfo = {},
    currency = logic_xsuit_activity:GetDrawCurrencyCount(),
    needCurrency = 0,
    isCurrencyEnough = false,
    isMaterialEnough = true,
    period = period,
    level = level + 1
  }
  local upgradeInfo = LogicXSuit.GetUpgradeInfo(period)
  local cfg = upgradeInfo and upgradeInfo[level + 1].cfg
  if cfg then
    for i = 1, 2 do
      local matID = cfg["MatID" .. i]
      local exchangeInfo = logic_xsuit_activity:GetExchangeDataByItemID(matID)
      local limitMatID = cfg["LimitMatID" .. i]
      local limitExchangeInfo = logic_xsuit_activity:GetExchangeDataByItemID(limitMatID)
      local unShowDiscount = limitExchangeInfo and limitExchangeInfo.hasDiscount and not limitExchangeInfo.drawDiscount
      local limitPos = limitExchangeInfo and limitExchangeInfo.pos or nil
      if exchangeInfo then
        local itemCfg = CDataTable.GetTableData("Item", matID)
        local needNum = cfg["MatNum" .. i] or 0
        local itemData = wardrobeData:GetHallDepotItemDataByResID(matID)
        local hasNum = itemData and itemData.count or 0
        if limitMatID then
          local limitItemData = wardrobeData:GetHallDepotItemDataByResID(limitMatID)
          local limitNum = limitItemData and limitItemData.count or 0
          hasNum = hasNum + limitNum
        end
        local price = exchangeInfo.needItemNum
        local lackNum = 0
        local exchangeLimitNum = 0
        if needNum > hasNum then
          result.isMaterialEnough = false
          lackNum = needNum - hasNum
          if not (limitExchangeInfo and limitExchangeInfo.drawDiscount) or limitExchangeInfo.timeLimits == limitExchangeInfo.hasExchangeCount then
            result.needCurrency = result.needCurrency + price * lackNum
          elseif lackNum <= limitExchangeInfo.timeLimits - limitExchangeInfo.hasExchangeCount then
            local discountPrice = math.ceil(limitExchangeInfo.needItemNum / 100.0 * limitExchangeInfo.drawDiscount)
            result.needCurrency = result.needCurrency + discountPrice * lackNum
            exchangeLimitNum = lackNum
          else
            local discountPrice = math.ceil(limitExchangeInfo.needItemNum / 100.0 * limitExchangeInfo.drawDiscount)
            local limitNum = limitExchangeInfo.timeLimits - limitExchangeInfo.hasExchangeCount
            exchangeLimitNum = limitNum
            result.needCurrency = result.needCurrency + price * (lackNum - limitNum) + discountPrice * limitNum
          end
        end
        local info = result.matInfo
        info[i] = {
          itemID = matID,
          iconPath = itemCfg.ItemSmallIcon,
          needNum = needNum,
          hasNum = hasNum,
          price = price,
          lackNum = lackNum,
          limitNum = exchangeLimitNum,
          limitItemID = limitMatID,
          unShowDiscount = unShowDiscount,
          pos = exchangeInfo.pos,
                  }
      end
    end
  end
  result.isCurrencyEnough = result.currency >= result.needCurrency
  return result
end
function LogicXSuit.IsUpgradeMaterial(itemID)
  if not itemID then
    return false
  end
  if not LogicXSuit.materialItemIDMap then
    return false
  end
  return LogicXSuit.materialItemIDMap[itemID]
end
function LogicXSuit.IsUnlockStateMaterial(itemID)
  if not itemID then
    return nil
  end
  if not LogicXSuit.unlockStateMatMap then
    return nil
  end
  return LogicXSuit.unlockStateMatMap[itemID]
end
function LogicXSuit.GetMaterialLackNum(itemID, nextLevelMaterialInfo)
  if not itemID or not nextLevelMaterialInfo then
    return 0
  end
  local matInfo = nextLevelMaterialInfo.matInfo
  local lackNum = 0
  for i = 1, #matInfo do
    if itemID == matInfo[i].itemID then
      lackNum = matInfo[i].lackNum
      break
    end
  end
  return lackNum
end
function LogicXSuit.IsCurrencyEnoughForThisMaterial(itemID, nextLevelMaterialInfo)
  if not itemID or not nextLevelMaterialInfo then
    return false
  end
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  for i = 1, #nextLevelMaterialInfo.matInfo do
    local matInfo = nextLevelMaterialInfo.matInfo[i]
    if matInfo and itemID == matInfo.itemID then
      return logic_xsuit_activity:GetDrawCurrencyCount() >= matInfo.lackNum * matInfo.price
    end
  end
  return false
end
function LogicXSuit.GetXSuitLocalizeResStr(id)
  local str = LocUtil.GetLocalizeResStr(id)
  if str then
    str = string.gsub(str, "%$%$", "\"")
  else
    str = ""
  end
  return str
end
function LogicXSuit.InitInviteAction()
  LogicXSuit.inviteActionMap = {}
  local cfg = CDataTable.GetTable("GoldenSuitMapCfg")
  for _, j in pairs(cfg) do
    local StringUtil = require("common.string_util")
    local inviteeActionIDStrList = StringUtil.Split(j.InviteeActionID, "|")
    local inviteeActionIDList = {}
    for _, v in pairs(inviteeActionIDStrList) do
      local inviteeActionID = tonumber(v)
      if inviteeActionID then
        table.insert(inviteeActionIDList, inviteeActionID)
        LogicXSuit.actionPeriodMap[inviteeActionID] = j.Period
      end
    end
    LogicXSuit.inviteActionMap[j.InviterActionID] = inviteeActionIDList
    LogicXSuit.actionPeriodMap[j.InviterActionID] = j.Period
  end
end
function LogicXSuit.IsInviteAction(action_id)
  if not action_id or action_id == 0 then
    return false
  end
  if not LogicXSuit.inviteActionMap then
    LogicXSuit.InitInviteAction()
  end
  return LogicXSuit.inviteActionMap[action_id] ~= nil
end
function LogicXSuit.GetInviteeActionList(action_id)
  if not LogicXSuit.inviteActionMap then
    LogicXSuit.InitInviteAction()
  end
  return LogicXSuit.inviteActionMap[action_id]
end
function LogicXSuit.CheckNeedSendInvite(inviter_action_id)
  log(bWriteLog and "CheckNeedSendInvite inviter_action_id = " .. tostring(inviter_action_id) .. " || value  = " .. tostring(LogicXSuit.inviteActionMap[inviter_action_id]))
  LogicXSuit.GetBaseInfo(1)
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.GetServerTimeInSec()
  if time - LogicXSuit.lastSendInviteTime <= 5.0 then
    log(bWriteLog and "CheckNeedSendInvite inviter_action_id is in CD ,cd = " .. tostring(time - LogicXSuit.lastSendInviteTime))
    return
  end
  LogicXSuit.lastSendInviteTime = time
  local inviteeActionIDs = LogicXSuit.inviteActionMap[inviter_action_id]
  if inviteeActionIDs ~= nil then
    XSuitHandler.send_change_emtion_action_req(inviter_action_id)
  end
end
function LogicXSuit.JumpToVideo(id)
  LogicXSuit.ShowUpgradeUI(nil, nil, nil, nil, true)
end
function LogicXSuit.IsMatchAction(uid, actionID, suitID)
  if not (uid and actionID) or not suitID then
    return false
  end
  local actionInfo = LogicXSuit.needPlayActionMember[uid]
  if not actionInfo then
    return false
  end
  if actionInfo.itemID ~= suitID then
    return false
  end
  if actionInfo.actionID == actionID then
    return true
  end
  if actionInfo.actionID == 12219234 and actionID == 12219233 or actionInfo.actionID == 12219260 and actionID == 12219259 then
    return true
  end
  return false
end
function LogicXSuit.GetSwitchItemIDByItemID(itemID)
  local period = LogicXSuit.GetPeriodByItemId(itemID)
  local switchLevel = LogicXSuit.GetSwitchLevelByPeriod(period)
  return LogicXSuit.GetSwitchItemByItemAndSwitchLevel(itemID, switchLevel)
end
function LogicXSuit.GetItemShowID(InsID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local ShowItemID = WardrobeData:GetItemIDByInsID(InsID)
  local Source = WardrobeData:GetItemSource(InsID)
  if Source == EWardrobeDataSource.InheritWardrobe then
    ShowItemID = LogicXSuit.ChangeItemIDByMyselfState(ShowItemID, Source)
  else
    ShowItemID = LogicXSuit.GetSwitchItemIDByItemID(ShowItemID)
    ShowItemID = LogicXSuit.ChangeItemIDByMyselfState(ShowItemID, Source)
  end
  return ShowItemID
end
function LogicXSuit.GetSwitchItemByItemAndSwitchLevel(itemID, switchLevel)
  log(bWriteLog and "LogicXSuit.GetSwitchItemByItemAndSwitchLevel, itemID = " .. tostring(itemID) .. "; switchLevel = " .. tostring(switchLevel))
  if LogicXSuit.IsXSuit(itemID) then
    local originalLevel = LogicXSuit.GetLevelByItemId(itemID)
    local period = LogicXSuit.GetPeriodByItemId(itemID)
    if switchLevel > originalLevel then
      log(bWriteLog and "LogicXSuit.GetSwitchItemByItemAndSwitchLevel: switchLevel > originalLevel")
      return itemID
    else
      local putOnLevel = originalLevel
      if switchLevel == 1 then
        if originalLevel == 1 then
          putOnLevel = 1
        else
          putOnLevel = 2
        end
      elseif switchLevel == 3 then
        if 5 <= originalLevel then
          putOnLevel = 5
        else
          putOnLevel = originalLevel
        end
      elseif switchLevel == 6 then
        putOnLevel = 6
      elseif switchLevel == 7 then
        putOnLevel = 7
      end
      log(bWriteLog and "LogicXSuit.GetSwitchItemByItemAndSwitchLevel: period = " .. tostring(period) .. "; putOnLevel = " .. tostring(putOnLevel))
      return LogicXSuit.GetItemIDByLevel(period, putOnLevel)
    end
  else
    log(bWriteLog and "LogicXSuit.GetSwitchItemByItemAndSwitchLevel: not GoldenSuit")
    return itemID
  end
end
function LogicXSuit._GetSwitchLevelByItemID(itemID)
  local period = LogicXSuit.GetPeriodByItemId(itemID)
  if period then
    return LogicXSuit.GetSwitchLevelByPeriod(period)
  end
  return nil
end
function LogicXSuit.GetSwitchLevelByInsID(InsID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local Source = WardrobeData:GetItemSource(InsID)
  local ItemID = WardrobeData:GetItemIDByInsID(InsID)
  if Source == EWardrobeDataSource.InheritWardrobe then
    return LogicXSuit.GetDefaultSwitchLevelByItemID(ItemID)
  else
    return LogicXSuit._GetSwitchLevelByItemID(ItemID)
  end
end
function LogicXSuit.GetDefaultSwitchLevelByItemID(itemID)
  local level = LogicXSuit.GetLevelByItemId(itemID)
  if level then
    local switchLevelList = LogicXSuit.GetConfig("switchLevelList")
    return switchLevelList[level]
  else
    return 0
  end
end
function LogicXSuit.GetSwitchLevelByPeriod(period)
  local switchLevelList = LogicXSuit.GetConfig("switchLevelList")
  if not LogicXSuit.switchLevel then
    LogicXSuit.SendGetGoldDressNewLevelReq()
    return switchLevelList[LogicXSuit.GetLevelByPeriod(period)]
  end
  if LogicXSuit.switchLevel[period] then
    return LogicXSuit.switchLevel[period]
  else
    return switchLevelList[LogicXSuit.GetLevelByPeriod(period)]
  end
end
function LogicXSuit.SendGetGoldDressNewLevelReq()
  XSuitHandler.send_get_gold_dress_new_level_req()
end
function LogicXSuit.OnGetGoldDressNewLevelRsp(set_info)
  if set_info then
    LogicXSuit.switchLevel = set_info
  else
    local switchLevel = {}
    local config = xsuit_config_and_cache.GetVersionArgConfig()
    local maxPeriod = config.MAX_PERIOD or 1
    for i = 1, maxPeriod do
      switchLevel[i] = LogicXSuit.GetLevelByPeriod(i)
    end
    LogicXSuit.  end
  LogicXSuit.UpdateLobbyAvatar()
end
function LogicXSuit.SetSwitchLevelByPeriod(period, switchLevel)
  local level = LogicXSuit.GetLevelByPeriod(period)
  if switchLevel > level or switchLevel <= 0 then
    return
  end
  local maxLevel = LogicXSuit.GetActSuitMaxLevelByPeriod(period)
  if not maxLevel or switchLevel > maxLevel then
    return
  end
  if switchLevel ~= 1 and switchLevel ~= 3 and switchLevel ~= 6 and switchLevel ~= 7 then
    return
  end
  XSuitHandler.send_set_gold_dress_new_level_req(period, switchLevel)
end
function LogicXSuit.OnSetGoldDressNewLevelRsp(period, switchLevel)
  LogicXSuit.switchLevel[period] = switchLevel
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local originalLevel = LogicXSuit.GetLevelByPeriod(period)
  if originalLevel == 7 and switchLevel < 7 then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.GoldenSuit_SwitchLevel_From_Seven)
  end
  if originalLevel == 6 and switchLevel < 6 then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.GoldenSuit_SwitchLevel_From_Six)
  end
  if 3 <= originalLevel and originalLevel < 6 and switchLevel == 1 then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.GoldenSuit_SwitchLevel_From_Three)
  end
  EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_DRESS_LEVEL)
  LogicXSuit.UpdateLobbyAvatar()
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  BasicDataAvatarWearInfo:GetOrReqData(DataMgr.roleData.uid, function(callUid, callInfo)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, callUid)
  end, {bForceReq = true}, Enum_AvatarShowSource.WardrobeLogic)
end
function LogicXSuit.UpdateLobbyAvatar(NeedPutOff)
  log(bWriteLog and "LogicXSuit.UpdateLobbyAvatar")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetModel(DataMgr.roleData.uid)
  if avatar then
    local item, itemInsID
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local tRoleWear = AvatarData.GetRoleWear()
    for _, v in pairs(tRoleWear) do
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if itemInfo and LogicXSuit.IsXSuit(itemInfo.resID) then
        item = itemInfo.resID
        itemInsID = itemInfo.insID
        break
      end
    end
    if item then
      local switchItem = LogicXSuit.GetItemShowID(itemInsID)
      if NeedPutOff then
        TeamAvatarManager.ChangeAvatarEquipment(DataMgr.roleData.uid, AvatarData.CreateAvatarCustom(item))
      end
      TeamAvatarManager.ChangeAvatarEquipment(DataMgr.roleData.uid, AvatarData.CreateAvatarCustom(switchItem), true)
    end
  end
end
function LogicXSuit.GetPeriodOfCurrentlyWearing()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local period
  local tRoleData = AvatarData.GetRoleWear()
  for _, v in pairs(tRoleData) do
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
    if itemInfo and itemInfo.resID then
      period = LogicXSuit.GetPeriodByItemId(itemInfo.resID)
      if period ~= nil then
        return period, itemInfo.resID, v
      end
    end
  end
  return nil, nil
end
function LogicXSuit.GetLevelAction(period)
  local default = 5
  if not LogicXSuit.levelAction then
    log(bWriteLog and "LogicXSuit.GetLevelAction not levelAction")
    XSuitHandler.send_gold_dress_get_level_action_req()
    return 5
  end
  return LogicXSuit.levelAction[period] or default
end
function LogicXSuit.GetRunAction(period, level, index)
  local info = LogicXSuit.RunAction
  if not (info and info[period] and info[period][level]) or not info[period][level][index] then
    log(bWriteLog and "LogicXSuit.GetRunAction not RunAction")
    XSuitHandler.send_gold_dress_flag_operation_req(period, level, index, 2)
    return 1
  end
  return info[period][level][index] or 1
end
function LogicXSuit.SetRunAction(info)
  LogicXSuit.RunAction = LogicXSuit.RunAction or {}
  LogicXSuit.RunAction[info.period_id] = LogicXSuit.RunAction[info.period_id] or {}
  LogicXSuit.RunAction[info.period_id][info.level_id] = LogicXSuit.RunAction[info.period_id][info.level_id] or {}
  LogicXSuit.RunAction[info.period_id][info.level_id][info.index] = info.flag_value or 1
  EventSystem:postEvent(EVENTTYPE_XSUIT, EVENTID_XSUIT_RUN_ACTION_UPDATE)
end
function LogicXSuit.SendGetGoldDressStateReq()
  log(bWriteLog and "LogicXSuit.SendGetGoldDressStateReq")
  XSuitHandler.send_get_gold_dress_state_req()
end
function LogicXSuit.OnGetGoldDressStateRsp(info, inherit_all_state_info)
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  LogicInheritWardrobe:CacheXSuitStateInfo(inherit_all_state_info or {})
  if info or inherit_all_state_info then
    if LogicXSuit.stateInfo and info then
      LogicXSuit.ShowUnlockStateSuccessUI(LogicXSuit.stateInfo, info)
    end
    LogicXSuit.stateInfo = info or {}
    LogicXSuit.UpdateLobbyAvatar(true)
    EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_DRESS_STATE)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_DATA_CHANGE)
  else
    log(bWriteLog and "LogicXSuit.OnGetGoldDressStateRsp miss info")
    LogicXSuit.stateInfo = {}
  end
end
function LogicXSuit.SendUnlockGoldDressStateReq(period, state)
  log(bWriteLog and "LogicXSuit.SendUnlockGoldDressStateReq")
  local itemID = LogicXSuit.GetItemIDByPeriod(period)
  XSuitHandler.send_unlock_gold_dress_state_req(period, itemID, state)
end
function LogicXSuit.OnUnlockGoldDressStateRsp(info)
  if info then
    if LogicXSuit.stateInfo and info then
      LogicXSuit.ShowUnlockStateSuccessUI(LogicXSuit.stateInfo, info)
    end
    LogicXSuit.stateInfo = info
    LogicXSuit.UpdateLobbyAvatar()
    EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UNLOCK_STATE_SUCCESS)
  else
    log(bWriteLog and "LogicXSuit.OnUnlockGoldDressStateRsp miss info")
    LogicXSuit.stateInfo = {}
  end
end
function LogicXSuit.onRefreshGoldDressStateRsp(info)
  log_tree("LogicXSuit.onRefreshGoldDressStateRsp", info)
  if not LogicXSuit.stateInfo then
    LogicXSuit.stateInfo = {}
  end
  for k, v in pairs(info) do
    LogicXSuit.stateInfo[k] = v
    local ItemGetModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.rare_item_get_module)
    ItemGetModule:ShowOneXSuit(k, v.cur_state)
    EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_DRESS_STATE, k)
  end
end
function LogicXSuit.SendSetGoldDressStateReq(period, state, source)
  log(bWriteLog and "LogicXSuit.SendSetGoldDressStateReq")
  XSuitHandler.send_set_gold_dress_state_req(period, state, source)
end
function LogicXSuit.OnSetGoldDressStateRsp(info, source)
  if info then
    if source == EWardrobeDataSource.InheritWardrobe then
      local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
      for k, v in pairs(info) do
        LogicInheritWardrobe:ChangeXSuitStateInfo(k, v)
        EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_DRESS_STATE, k)
      end
    else
      for k, v in pairs(info) do
        LogicXSuit.stateInfo[k] = v
        EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_DRESS_STATE, k)
      end
    end
    LogicXSuit.UpdateLobbyAvatar()
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    BasicDataAvatarWearInfo:GetOrReqData(DataMgr.roleData.uid, function(callUid, callInfo)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, callUid)
    end, {bForceReq = true}, Enum_AvatarShowSource.LogicXSuit)
  else
    log(bWriteLog and "LogicXSuit.OnSetGoldDressStateRsp miss info")
    LogicXSuit.stateInfo = {}
  end
end
function LogicXSuit.GetStateInfo(source)
  local stateInfo
  if source == EWardrobeDataSource.InheritWardrobe then
    local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
    stateInfo = LogicInheritWardrobe:GetXSuitStateInfo()
  else
    stateInfo = LogicXSuit.stateInfo
  end
  return stateInfo
end
function LogicXSuit.GetCurStateByPeriod(period, source)
  local stateInfo = LogicXSuit.GetStateInfo(source)
  if stateInfo and stateInfo[period] then
    return stateInfo[period].cur_state
  end
  return nil
end
function LogicXSuit.GetCurStateByItemID(itemID, source)
  if not LogicXSuit.bItemInfoInited then
    LogicXSuit.InitXSuitItemList()
  end
  if LogicXSuit.itemInfoList[itemID] then
    local period = LogicXSuit.itemInfoList[itemID].period
    return LogicXSuit.GetCurStateByPeriod(period, source)
  end
  return nil
end
function LogicXSuit.GetCurStateByInsID(InsID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemData = WardrobeData:GetHallDepotItemDataByInsID(InsID)
  if not ItemData then
    log(bWriteLog and "LogicXSuit.GetCurStateByInsID not ItemData InsID:" .. tostring(InsID))
    return
  end
  local Source = WardrobeData:GetItemSource(InsID)
  return LogicXSuit.GetCurStateByItemID(ItemData.resID, Source)
end
function LogicXSuit.IsMultiStateCloth(itemID)
  log_warning(bWriteLog and "  LogicXSuit.IsMultiStateCloth. itemID: " .. tostring(itemID))
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  return multi_state_manager:IsMultiStateCloth(itemID)
end
function LogicXSuit.ChangeItemIDByState(itemID, state)
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  return multi_state_manager:ChangeClothByState(itemID, state)
end
function LogicXSuit.ChangeItemIDByMyselfState(itemID, source)
  if not LogicXSuit.bItemInfoInited then
    LogicXSuit.InitXSuitItemList()
  end
  if itemID and LogicXSuit.itemInfoList[itemID] then
    local period = LogicXSuit.itemInfoList[itemID].period
    local state = LogicXSuit.GetCurStateByPeriod(period, source)
    return LogicXSuit.ChangeItemIDByState(itemID, state)
  end
  return itemID
end
function LogicXSuit.GetXSuitItemIDByLevelAndState(itemID, level, state)
  if not itemID or not LogicXSuit.IsXSuit(itemID) then
    return itemID
  end
  if not LogicXSuit.bItemInfoInited then
    LogicXSuit.InitXSuitItemList()
  end
  local period = LogicXSuit.GetPeriodByItemId(itemID)
  if not period then
    return itemID
  end
  local targetLevelItemID = itemID
  if level and 0 < level then
    targetLevelItemID = LogicXSuit.GetItemIDByLevel(period, level)
    if not targetLevelItemID then
      return itemID
    end
  end
  return LogicXSuit.ChangeItemIDByState(targetLevelItemID, state)
end
function LogicXSuit.ChangeItemIDByInsID(InsID)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local Source = WardrobeData:GetItemSource(InsID)
  local itemID = WardrobeData:GetItemIDByInsID(InsID)
  return LogicXSuit.ChangeItemIDByMyselfState(itemID, Source)
end
function LogicXSuit.GetMyselfState(itemID)
  log(bWriteLog and "LogicXSuit.GetMyselfState itemID = " .. tostring(itemID))
  local state
  if not LogicXSuit.bItemInfoInited then
    LogicXSuit.InitXSuitItemList()
  end
  if itemID and LogicXSuit.itemInfoList[itemID] then
    local period = LogicXSuit.itemInfoList[itemID].period
    state = LogicXSuit.GetCurStateByPeriod(period, EWardrobeDataSource.Wardrobe)
    log(bWriteLog and "LogicXSuit.GetMyselfState state = " .. tostring(state))
  end
  return state
end
function LogicXSuit.CheckUnlockState(period, state, source)
  local stateInfo = LogicXSuit.GetStateInfo(source)
  if stateInfo and stateInfo[period] then
    return stateInfo[period].unlock_state[state] == 1
  end
  return false
end
function LogicXSuit.IsXSuitGlide(itemID)
  local NormalGlideID = LogicXSuit.GetNormalGlideID(itemID)
  local cfg = CDataTable.GetTableData("XSuitGlideCfg", NormalGlideID)
  if not cfg then
    return false
  end
  return true
end
function LogicXSuit.GetLevel1XSuitID(NormalGlideID)
  local cfg = CDataTable.GetTableData("XSuitGlideCfg", NormalGlideID)
  if not cfg then
    return
  end
  return cfg.XSuitID1
end
function LogicXSuit.GetLevel7XSuitID(NormalGlideID)
  local cfg = CDataTable.GetTableData("XSuitGlideCfg", NormalGlideID)
  if not cfg then
    return
  end
  return cfg.XSuitID7
end
function LogicXSuit.GetSpecialGlideID(NormalGlideID)
  local cfg = CDataTable.GetTableData("XSuitGlideCfg", NormalGlideID)
  if not cfg then
    return NormalGlideID
  end
  return cfg.SpecialGlideID
end
function LogicXSuit.GetNormalGlideID(ItemID)
  local XSuitGlideTable = CDataTable.GetTable("XSuitGlideCfg")
  if not XSuitGlideTable then
    log_error("LogicXSuit.GetNormalGlideID XSuitGlideTable is nil")
    return ItemID
  end
  for _, value in pairs(XSuitGlideTable) do
    if value.GlideID == ItemID or value.SpecialGlideID == ItemID then
      return value.GlideID
    end
  end
  return ItemID
end
function LogicXSuit.IsNormalGlideID(ItemID)
  local NormalGlideID = LogicXSuit.GetNormalGlideID(ItemID)
  if ItemID == NormalGlideID then
    return true
  end
  return false
end
function LogicXSuit.HasUnlockFeature(period, level, index)
  if LogicXSuit.unlockFeatureInfo and LogicXSuit.unlockFeatureInfo[period] and LogicXSuit.unlockFeatureInfo[period][level] and LogicXSuit.unlockFeatureInfo[period][level][index] and LogicXSuit.unlockFeatureInfo[period][level][index].unlock_info_state.state == 1 then
    return true
  else
    return false
  end
end
function LogicXSuit.GetUnlockFeatureMaterial(period, level, index)
  if LogicXSuit.unlockFeatureInfo and LogicXSuit.unlockFeatureInfo[period] and LogicXSuit.unlockFeatureInfo[period][level] and LogicXSuit.unlockFeatureInfo[period][level][index] and LogicXSuit.unlockFeatureInfo[period][level][index].need_list then
    return LogicXSuit.unlockFeatureInfo[period][level][index].need_list
  else
    return {}
  end
end
function LogicXSuit.on_unlock_gold_dress_level_feature_rsp(period, level, index, gold_dress_set_info_all)
  log_tree("LogicXSuit.on_unlock_gold_dress_level_feature_rsp gold_dress_set_info_all", gold_dress_set_info_all)
  LogicXSuit.unlockFeatureInfo[period][level][index].unlock_info_state.state = gold_dress_set_info_all[period].unlock_info[level][index].state
  EventSystem:postEvent(EVENTTYPE_XSUIT, EVENTID_XSUIT_UNLOCK_FEATURE)
end
function LogicXSuit.draw_gold_dress_req(cost_times, currency_id, coupon_id, pool_id)
  XSuitHandler.send_draw_gold_dress_req(cost_times, currency_id, coupon_id and coupon_id ~= 0 and coupon_id or nil, pool_id)
  EventSystem:postEvent(EVENTTYPE_XSUIT, EVENTID_XSUIT_SPIN_SHOWORHIDE_MASK, true)
end
function LogicXSuit.ShowErrCode(err_code)
  if err_code == 100170001 then
    ShowNotice(10295)
  elseif err_code == 100170002 then
    ShowNotice(10296)
  elseif err_code == 100170003 then
    ShowNotice(10297)
  elseif err_code == 100170004 then
    ShowNotice(8262)
  elseif err_code == 100170005 then
    ShowNotice(9963)
  elseif err_code == 100170006 then
  elseif err_code == 100170007 then
    ShowNotice(10298)
  elseif err_code == 100170008 then
    ShowNotice(10299)
  elseif err_code == 100170126 then
    ShowNotice(995002)
  elseif err_code == 100170009 then
  elseif err_code == 100170010 then
  elseif err_code == 100170011 then
    local param0 = CDataTable.GetTableData("Item", 1521841).ItemName
    local str = LocUtil.LocalizeResFormat(10334, param0)
    ShowNotice(str)
  elseif err_code == 100170012 then
    ShowNotice(10299)
  elseif err_code == 100170013 then
    local param0 = CDataTable.GetTableData("Item", 1405626).ItemName
    local str = LocUtil.LocalizeResFormat(10335, param0)
    ShowNotice(str)
  elseif err_code == 100170014 then
  elseif err_code == 100170015 then
    ShowNotice(9986)
  end
end
function LogicXSuit.CheckXsuitAssert(keyList, callback, from, extraData)
  log_tree("xcc LogicXSuit:CheckXsuitAssert keyList:", keyList)
  if not PufferManager.CheckAndDownload(PufferConst.ENUM_DownloadType.ODPACK, keyList, callback, from, extraData) and callback and type(callback) == "function" then
    callback()
  end
end
return LogicXSuit