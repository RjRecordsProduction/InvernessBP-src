local UnknowPassBuySystem = {
  tabId = 40,
  subId = 0,
  normalPassShopInfo = nil,
  elitePassShopInfo = nil,
  normalPassDirectPurchaseInfo = nil,
  elitePassDirectPurchaseInfo = nil,
  normalPassDirectPurchasePrice = "",
  elitePassDirectPurchasePrice = "",
  normalPassCentauriPrice = nil,
  elitePassCentauriPrice = nil,
  Normal_Pass_ItemID = nil,
  Super_Pass_ItemID = nil,
  Normal_Pass_ItemIDs = {},
  Super_Pass_ItemIDs = {},
  Experience_Pass_ItemIDs = {},
  NewUser_Privleges_ItemID = {},
  seasonBuyIDs = {},
  Super_Award_Item_Id = 0,
  Super_Award_Item_Num = 0,
  nUCCountLackTip = 0,
  nCurDataVersion = nil,
  IsBuyEliteCloseUI = false,
  bRpJump = false,
  nGroupActId = nil,
  bIsShowRPBuyUI = false
}
local UnknowPass_Show_Award_UC_ID = 1006
UnknowPassBuySystem.TlogSourceEnum = {
  MainUI = 1,
  CreateTeam = 2,
  GetReward = 3,
  TeamJoint = 4,
  InviteJoint = 5,
  Link = 6,
  Chat = 7,
  Operation = 8,
  Insurance = 9,
  WarPreset = 10
}
function UnknowPassBuySystem.UpdateRPPackId()
  local curSeries = UnknowPassSystem.GetSeriesBySeason(UnknowPassSystem.Season)
  if curSeries == UnknowPassSystem.ESeries.S then
    UnknowPassBuySystem.normalRPPackId = 1603098
    UnknowPassBuySystem.eliteRPPackId = 1603099
  elseif curSeries == UnknowPassSystem.ESeries.M then
    UnknowPassBuySystem.normalRPPackId = 1616007
    UnknowPassBuySystem.eliteRPPackId = 1616013
  elseif curSeries == UnknowPassSystem.ESeries.A then
    UnknowPassBuySystem.normalRPPackId = 1616101
    UnknowPassBuySystem.eliteRPPackId = 1616017
  end
end
function UnknowPassBuySystem.OpenBuyUI(isFromIntroduce, ExperienceType, buyLevel, bRpJump)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.CheckCanShowPass() == false then
    return
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if UnknowPassSystem.IsBuyElite and not UnknowPassSystem.CanExtraUpgrade and (not PassDataSystem.is_experience or PassDataSystem.is_experience ~= 1) and not UnknowPassTunnelSystem.isShowRP then
    UnknowPassTunnelSystem.ShowRP()
    return
  end
  if UnknowPassSystem.IsBuyElite and not UnknowPassSystem.CanExtraUpgrade and not ExperienceType and not UnknowPassTunnelSystem.isShowRP then
    UnknowPassTunnelSystem.ShowRP()
    return
  end
  if UnknowPassSystem.IsBuyElite and ExperienceType and ExperienceType == 1 and not UnknowPassTunnelSystem.isShowRP then
    if ExperienceType and 0 < ExperienceType then
      local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
      UnknowPassOpenUISystem.isExperienceUI = true
    end
    UnknowPassTunnelSystem.ShowRP()
    return
  end
  local type = 0
  if isFromIntroduce == true then
    type = 2
  end
  UnknowPassBuySystem.OpenRpBuyUI(type, nil, ExperienceType, buyLevel, bRpJump)
end
function UnknowPassBuySystem.ShowBuyUI(fromtype, fromForTlog, callback, buyLevel, bRpJump)
  local ctorData = {
    fromtype = fromtype,
    fromForTlog = fromForTlog,
    callback = callback,
      }
  UnknowPassBuySystem.bIsShowRPBuyUI = true
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  if type(buyLevel) == "number" and buyLevel <= 50 then
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS_SEG1, ctorData)
  else
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS, ctorData)
  end
end
function UnknowPassBuySystem.OpenRpBuyUI(fromtype, fromForTlog, ExperienceType, buyLevel, bRpJump)
  UnknowPassBuySystem.ShowBuyUI(fromtype, fromForTlog, nil, buyLevel, bRpJump)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.isShowRP then
    local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
    PassPreviewSystem.HideExistPanels()
  end
end
function UnknowPassBuySystem.OpenGiftUI()
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if not UnknowPassTunnelSystem.CheckCanShowPass() then
    return
  end
  local type = 1
  UnknowPassBuySystem.OpenRpBuyUI(type)
end
function UnknowPassBuySystem.OpenRpBuyUIByTlog(fromForTlog)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.CheckCanShowPass() == false then
    return
  end
  if UnknowPassSystem.IsBuyElite and not UnknowPassTunnelSystem.isShowRP then
    UnknowPassTunnelSystem.ShowRP()
    return
  end
  UnknowPassBuySystem.OpenRpBuyUI(0, fromForTlog)
end
function UnknowPassBuySystem.OpenRpBuyUIWithCallBack(fromForTlog, callBack)
  log(bWriteLog and "god test OpenRpBuyUIWithCallBack")
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.CheckCanShowPass() == false then
    return
  end
  if UnknowPassSystem.IsBuyElite and not UnknowPassTunnelSystem.isShowRP then
    UnknowPassTunnelSystem.ShowRP()
    return
  end
  UnknowPassBuySystem.ShowBuyUI(0, fromForTlog, callBack)
  if UnknowPassTunnelSystem.isShowRP then
    local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
    PassPreviewSystem.HideExistPanels()
  end
end
function UnknowPassBuySystem.HideBuyUI(isClickClose)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UIManager then
    if isClickClose then
      local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
      ui_jump_manager.CloseJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS_SEG1)
      ui_jump_manager.CloseJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS)
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      if LogicTxMissionMain.IsInXMission() then
        if not UnknowPassTunnelSystem.isShowRP then
        end
        local logic_xmission_insurance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_insurance)
        logic_xmission_insurance:RPJumpBackInsurance()
        local LogicXMissionBlackMarket = require("client.slua.logic.TxMission.logic_xmission_black_market")
        LogicXMissionBlackMarket.RPJumpBackMarket()
      end
    else
      local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
      ui_jump_manager.CloseJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS_SEG1)
      ui_jump_manager.CloseJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS)
    end
    UIManager.CloseUI(UIManager.UI_Config.unknowpass_buy_super)
    UIManager.CloseUI(UIManager.UI_Config.GivingGifts_Popup_UIBP)
  end
  if UnknowPassTunnelSystem.isShowRP then
    local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
    PassPreviewSystem.ShowExistPanels()
  end
end
function UnknowPassBuySystem.OpenBuySuperUI(isSuper, isAskFor, tlogType)
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.unknowpass_buy_super, isSuper, isAskFor, tlogType)
  end
end
function UnknowPassBuySystem.OpenAwardBuyScoreUI(bIsRpBranchOpen, bIsFromRPAward)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local panelType = PassDataSystem.GetPanelType()
  local curType = PassDataSystem.GetCurRpPanelType()
  if bIsRpBranchOpen and curType == panelType.BranchRp then
    UIManager.ShowUI(UIManager.UI_Config.unknowpass_branch_award_buyscore)
  else
    UIManager.ShowUI(UIManager.UI_Config.unknowpass_award_buyscore, bIsFromRPAward)
  end
end
function UnknowPassBuySystem.HideAwardBuyScoreUI()
  UIManager.CloseUI(UIManager.UI_Config.unknowpass_award_buyscore)
  UIManager.CloseUI(UIManager.UI_Config.unknowpass_branch_award_buyscore)
end
function UnknowPassBuySystem.GetBuyPassString(isSuper, price, buyType)
  local tip
  local strUPass = ""
  if isSuper then
    strUPass = LocUtil.GetLocalizeResStr(502507)
    tip = LocUtil.LocalizeResFormat(44542, price, strUPass)
  else
    strUPass = LocUtil.GetLocalizeResStr(502508)
    tip = LocUtil.LocalizeResFormat(44542, price, strUPass)
  end
  local TimeUtil = require("client.common.time_util")
  local eastTicketTips = not (not (UnknowPassSystem.GetKeeyBuy() >= 2) or UnknowPassSystem.CanExtraUpgrade) and LocUtil.GetLocalizeResStr("9332") or ""
  if UnknowPassBuySystem.IsPassNearExpire() then
    if UnknowPassBuySystem.Super_Pass_Info and UnknowPassBuySystem.Super_Pass_Info.expireTips ~= "" then
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      local strRegion = Client.GetPublishRegion()
      local expire_tips = ""
      if strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
        expire_tips = LocUtil.LocalizeResFormat(42944, TimeUtil.FormatTime_YMDHM(UnknowPassSystem.SeasonInfo.cfg.end_timestamp, true))
      else
        expire_tips = LocUtil.LocalizeResFormat(24967, TimeUtil.FormatTime_YMD(UnknowPassSystem.SeasonInfo.cfg.end_timestamp))
      end
      local bHasUpgradeCard = UnknowPassBuySystem.HasUpgradeCard(true)
      if bHasUpgradeCard and buyType == 3 then
        local nUpgradeCardId = UnknowPassBuySystem.GetUpgradeCardId()
        local tItemCfg = CDataTable.GetTableData("Item", nUpgradeCardId)
        local sBuyTips = ""
        if tItemCfg then
          sBuyTips = LocUtil.LocalizeResFormat(50036, tItemCfg.ItemName)
        end
        tip = string.format([[
%s
%s
%s]], tip, sBuyTips, expire_tips)
      else
        tip = string.format([[
%s
%s]], tip, expire_tips)
      end
    end
  else
    local bHasUpgradeCard = UnknowPassBuySystem.HasUpgradeCard(true)
    if bHasUpgradeCard and buyType == 3 then
      local nUpgradeCardId = UnknowPassBuySystem.GetUpgradeCardId()
      local tItemCfg = CDataTable.GetTableData("Item", nUpgradeCardId)
      local sBuyTips = ""
      if tItemCfg then
        sBuyTips = LocUtil.LocalizeResFormat(50036, tItemCfg.ItemName)
      end
      tip = string.format([[
%s
%s
%s]], tip, sBuyTips, eastTicketTips)
    else
      tip = string.format([[
%s
%s]], tip, eastTicketTips)
    end
  end
  return tip
end
function UnknowPassBuySystem.GetAskForString()
  return LocUtil.GetLocalizeResStr(502507)
end
function UnknowPassBuySystem.GetSuperBuyTitle(isAskFor)
  if isAskFor then
    return LocUtil.GetLocalizeResStr(501066)
  else
    return LocUtil.GetLocalizeResStr(6177)
  end
end
function UnknowPassBuySystem.GetSuperBuyContent(isAskFor)
  if isAskFor then
    if UnknowPassBuySystem.normalPassDirectPurchaseInfo then
      local itemid = UnknowPassBuySystem.normalPassDirectPurchaseInfo.item_id
      if itemid then
        local itemConfig = CDataTable.GetTableData("Item", 1603098)
        if itemConfig then
          local itemName = "Elite Pass"
          local info = UnknowPassBuySystem.normalPassDirectPurchaseInfo
          local price = CentauriManager.GetPriceByProductId(info.CentauriProductId, info.CentauriCurrency, info.configPrice, true)
          return LocUtil.LocalizeResFormat(7764, itemName, price)
        end
      end
    end
    return ""
  else
    return UnknowPassBuySystem.GetBuyPassString(false)
  end
end
function UnknowPassBuySystem.GetSuperYellowButtonContent(isAskFor)
  if isAskFor then
    return LocUtil.GetLocalizeResStr(7276)
  else
    return LocUtil.GetLocalizeResStr(7274)
  end
end
function UnknowPassBuySystem.GetSuperWhiteButtonContent(isAskFor)
  if isAskFor then
    return LocUtil.GetLocalizeResStr(7275)
  else
    return LocUtil.GetLocalizeResStr(7273)
  end
end
function UnknowPassBuySystem.IsPassNearExpire()
  local seasonEndTime = UnknowPassSystem.SeasonInfo.cfg.end_timestamp
  local TimeUtil = require("client.common.time_util")
  return seasonEndTime - TimeUtil.GetServerTimeInSec() < 604800
end
function UnknowPassBuySystem.OnUpdateSeriesABuyData(tb)
  UnknowPassBuySystem.Normal_Pass_ItemIDs = {}
  UnknowPassBuySystem.Super_Pass_ItemIDs = {}
  UnknowPassBuySystem.Experience_Pass_ItemIDs = {}
  UnknowPassBuySystem.NewUser_Privleges_ItemID = {}
  UnknowPassBuySystem.seasonBuyIDs = {}
  for k, v in pairs(tb) do
    table.insert(UnknowPassBuySystem.seasonBuyIDs, k)
    local info = {
      id = k,
      price = 0,
      discountPrice = 0,
      desc1 = v.reward_desc1,
      desc2 = v.reward_desc2,
      expireTips = v.expire_tips or ""
    }
    for i, price in pairs(v.prices) do
      info.price = price.ori_price
      info.discountPrice = price.discount_price
      break
    end
    if v.buy_type == 1 then
      UnknowPassBuySystem.Normal_Pass_Info_50 = info
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_UPDATE_NORMALPASS_INFO)
    elseif v.buy_type == 2 then
      UnknowPassBuySystem.Normal_Pass_Info = info
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_UPDATE_NORMALPASS_INFO)
    elseif v.buy_type == 3 then
      UnknowPassBuySystem.Super_Pass_Info = info
      if 0 < #v.reward then
        UnknowPassBuySystem.Super_Award_Item_Id = v.reward[1].item_id
        UnknowPassBuySystem.Super_Award_Item_Num = v.reward[1].item_num
        if v.reward[2] and v.reward[2].label then
          UnknowPassSystem.UpgradeExtraLabel = v.reward[2].label
        end
      end
    elseif v.buy_type == 4 then
      for i, _ in pairs(v.prices) do
        UnknowPassBuySystem.Normal_Pass_ItemID = i
        local item = {
          itemId = i,
          sortId = v.sort
        }
        table.insert(UnknowPassBuySystem.Normal_Pass_ItemIDs, item)
        break
      end
    elseif v.buy_type == 5 then
      for i, _ in pairs(v.prices) do
        UnknowPassBuySystem.Super_Pass_ItemID = i
        local item = {
          itemId = i,
          sortId = v.sort
        }
        table.insert(UnknowPassBuySystem.Super_Pass_ItemIDs, item)
        break
      end
    elseif v.buy_type == 40 then
      for i, _ in pairs(v.prices) do
        local item = {
          itemId = i,
          sortId = v.sort
        }
        table.insert(UnknowPassBuySystem.Experience_Pass_ItemIDs, item)
        break
      end
    elseif v.buy_type == 45 then
      for i, _ in pairs(v.prices) do
        local item = {
          itemId = i,
          sortId = v.sort
        }
        table.insert(UnknowPassBuySystem.NewUser_Privleges_ItemID, item)
        break
      end
    end
  end
  table.sort(UnknowPassBuySystem.Normal_Pass_ItemIDs, function(a, b)
    return a.sortId < b.sortId
  end)
  table.sort(UnknowPassBuySystem.Super_Pass_ItemIDs, function(a, b)
    return a.sortId < b.sortId
  end)
  log_tree("UnknowPassBuySystem.Normal_Pass_ItemIDs", UnknowPassBuySystem.Normal_Pass_ItemIDs)
end
function UnknowPassBuySystem.CheckBuyType(buy_cfg, raw_buy_cfg)
  if not raw_buy_cfg or not buy_cfg then
    return true
  end
  if UnknowPassSystem.CanExtraUpgrade then
    return buy_cfg.buyType == raw_buy_cfg.buyType
  end
  return buy_cfg.TicketType == raw_buy_cfg.TicketType
end
function UnknowPassBuySystem.GetBuyIdByCouponID(nCouponId, nPassType, tRawBuyCfg)
  local tAllBuyCfg = CDataTable.GetTableByFilter("UnknowPassBuyCfg", "SeasonID", UnknowPassSystem.Season, "BuyItemId", nCouponId, "PassType", nPassType)
  for _, v in pairs(tAllBuyCfg) do
    if UnknowPassBuySystem.CheckBuyType(v, tRawBuyCfg) then
      return v.ID
    end
  end
end
function UnknowPassBuySystem.ComfirmBuyPass(isSuper, couponid, vouchers, fromType, nCurPrice, rawBuyType, buyType)
  local buyID
  log(bWriteLog and "UnknowPassBuySystem.upass_buy_pass_rsp " .. (buyID or "!!"))
  local raw_buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(rawBuyType)
  if not raw_buy_cfg then
    log(bWriteLog and " UnknowPassBuySystem.ComfirmBuyPass >>>>> not raw_buy_cfg")
    return
  end
  if isSuper then
    if UnknowPassSystem.CanExtraUpgrade then
      for i, v in pairs(CDataTable.GetTable("UnknowPassBuyCfg")) do
        if UnknowPassBuySystem.IsCurSeason(v.ID) and v.IsExtra == 1 and UnknowPassBuySystem.CheckBuyType(v, raw_buy_cfg) then
          buyID = tonumber(i)
          break
        end
      end
    end
    if couponid and couponid ~= 0 then
      buyID = UnknowPassBuySystem.GetBuyIdByCouponID(couponid, 2, raw_buy_cfg)
    end
    UnknowPassBuySystem.upass_buy_pass_req(buyID or UnknowPassBuySystem.Super_Pass_Info and UnknowPassBuySystem.Super_Pass_Info.id, vouchers, nCurPrice, fromType)
  else
    if couponid and couponid ~= 0 then
      buyID = UnknowPassBuySystem.GetBuyIdByCouponID(couponid, 1, raw_buy_cfg)
    else
      buyID = tonumber(raw_buy_cfg.ID)
    end
    UnknowPassBuySystem.upass_buy_pass_req(buyID or UnknowPassBuySystem.Normal_Pass_Info.id, vouchers, nCurPrice, fromType)
  end
  if fromType and 0 < fromType then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local TLogReasonTable = {
      event_name = "UnknowpassBuyFrom",
      rp_type = isSuper and "super" or "normal"
    }
    local TLogReasonStr = json.encode(TLogReasonTable)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.UnknowpassBuyFrom, fromType, TLogReasonStr)
    log(bWriteLog and "TLog new format, UnknowPassBuySystem.ComfirmBuyPass, reason : " .. tostring(fromType) .. " reasonStr : " .. tostring(TLogReasonStr))
  end
  if buyType and 0 < buyType then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ClickBuyRpByNewCoupon, buyType)
  end
end
function UnknowPassBuySystem.ShowItemTips(itemId, item)
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowItemTips(itemId, item.Button_item)
end
function UnknowPassBuySystem.HideItemTips()
  local UIUtil = require("client.common.ui_util")
  UIUtil.CloseItemTips()
end
function UnknowPassBuySystem.GetSpecialAwards()
  local award_list = {}
  local UnknowPassSpecialAward = CDataTable.GetTable("UnknowPassSpecialAward")
  if UnknowPassSpecialAward then
    for _, award_cfg in pairs(UnknowPassSpecialAward) do
      if award_cfg.season_index == UnknowPassSystem.Season then
        table.insert(award_list, {
          item_id = award_cfg.res_id,
          item_num = award_cfg.count
        })
      end
    end
  end
  return award_list
end
function UnknowPassBuySystem.GetAllSuperAwards(isGift, isNormal, maxLevel, startLevel, bUserNewUserPrivelege)
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local reward_map = {}
  local curLevel = UnknowPassSystem.Level
  if isGift then
    curLevel = 1
  end
  local deltaLevel = 24
  local highLevel = isNormal and curLevel or curLevel + deltaLevel
  if UnknowPassSystem.Season >= 59 and (not maxLevel or 50 < maxLevel) then
    local DeltaLevelMap = {
      [true] = {
        [true] = 0,
        [false] = 24
      },
      [false] = {
        [true] = 3,
        [false] = 27
      }
    }
    local bIsNormal = isNormal == true
    deltaLevel = DeltaLevelMap[UnknowPassSystem.IsBuyElite][bIsNormal]
    highLevel = curLevel + deltaLevel
  end
  if maxLevel and maxLevel < highLevel then
    highLevel = maxLevel
  end
  local awardLevelList = UnknowPassAwardSystem.GetAwardLevelList(true, false)
  if not awardLevelList then
    return nil
  end
  startLevel = startLevel or 1
  for i = startLevel, highLevel do
    local item = awardLevelList[i]
    if not item then
      break
    end
    for j = 1, #item.OrdinaryAwardList do
      if i <= curLevel then
        break
      end
      local item0 = item.OrdinaryAwardList[j]
      local reward = reward_map[item0.resId]
      if reward then
        reward.item_num = reward.item_num + item0.number
      else
        local cfgItem = CDataTable.GetTableData("Item", item0.resId)
        if cfgItem then
          local reward_item = {
            item_id = item0.resId,
            item_num = item0.number,
            item_show_type = item0.item_show_type,
            item_quality = cfgItem.ItemQuality
          }
          reward_map[item0.resId] = reward_item
        end
      end
    end
    for j = 1, #item.EliteAwardList do
      if item.eliteAwardState == UnknowPassAwardSystem.ENUM_UNKNOWPASS_HasGet then
        break
      end
      local item0 = item.EliteAwardList[j]
      if isNormal and j == 2 and item0.resId ~= UnknowPass_Show_Award_UC_ID and item0.isPlus then
        break
      end
      local reward = reward_map[item0.resId]
      local rewardNum = item0.number
      if UnknowPassSystem.Season == 59 and item0.resId == UnknowPass_Show_Award_UC_ID then
        if bUserNewUserPrivelege then
          if j == 2 then
            break
          end
        elseif j == 2 then
          rewardNum = rewardNum - item.EliteAwardList[1].number
        end
      end
      if reward then
        reward.item_num = reward.item_num + rewardNum
      else
        local cfgItem = CDataTable.GetTableData("Item", item0.resId)
        if cfgItem then
          local reward_item = {
            item_id = item0.resId,
            item_num = rewardNum,
            item_show_type = item0.item_show_type,
            item_quality = cfgItem.ItemQuality
          }
          reward_map[item0.resId] = reward_item
        end
      end
    end
  end
  local reward_array = {}
  local uc = {}
  local hasUC = false
  if highLevel > UnknowPassSystem.MaxLevel then
    local scoreItem = {
      item_id = 1099,
      item_num = (highLevel - UnknowPassSystem.MaxLevel) * 100,
      item_show_type = 0,
      item_quality = 10
    }
    table.insert(reward_array, scoreItem)
  end
  for _, award in pairs(reward_map) do
    local item = {
      item_id = award.item_id,
      item_num = award.item_num,
      item_show_type = award.item_show_type,
      item_quality = award.item_quality
    }
    if award.item_id == UnknowPass_Show_Award_UC_ID then
      uc = item
      hasUC = true
    else
      table.insert(reward_array, item)
    end
  end
  table.sort(reward_array, function(a, b)
    return a.item_quality > b.item_quality
  end)
  if hasUC then
    table.insert(reward_array, 1, uc)
  end
  return reward_array
end
function UnknowPassBuySystem.GetBuyAwards(buyLevel)
  local awardtb = {}
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local ENUM_NEWUSER_STATE = UnknowPassMacro.ENUM_NEWUSER_STATE
  local maxEliteRewardLevel = UnknowPassSystem.MaxLevel
  if UnknowPassSystem.IsBuyElite and not UnknowPassSystem.IsBuyEliteSeg2 then
    maxEliteRewardLevel = 50
  end
  if UnknowPassSystem.Level < UnknowPassSystem.MaxLevel then
    for k, data in pairs(UnknowPassAwardSystem.AwardLevelList) do
      if data.level > UnknowPassSystem.Level and data.level <= UnknowPassSystem.Level + buyLevel then
        for k2, award in pairs(data.OrdinaryAwardList) do
          local itemCfg = CDataTable.GetTableData("Item", award.resId)
          award.ItemQuality = itemCfg and itemCfg.ItemQuality or 5
          if awardtb[award.resId] == nil then
            local TableUtil = require("common.table_util")
            awardtb[award.resId] = TableUtil.CopyTable(award)
          else
            awardtb[award.resId].number = awardtb[award.resId].number + award.number
          end
        end
        if UnknowPassSystem.IsBuyElite and maxEliteRewardLevel >= data.level then
          for k3, award in pairs(data.EliteAwardList) do
            local eliteCfg = CDataTable.GetTableData("Item", award.resId)
            award.ItemQuality = eliteCfg and eliteCfg.ItemQuality or 5
            local isOnlyAddFirstEliteAward = UnknowPassSystem.Season == 59 and UnknowPassSystem.PassType < 2 and award.resId == UnknowPass_Show_Award_UC_ID and UnknowPassSystem.upass_newuser_state == ENUM_NEWUSER_STATE.NEVER_BUY_USED
            local isPlusEliteAward = award.isPlus and award.resId ~= UnknowPass_Show_Award_UC_ID
            if k3 == 2 and (isOnlyAddFirstEliteAward or isPlusEliteAward and UnknowPassSystem.PassType < 2) then
              break
            end
            if awardtb[award.resId] == nil then
              local TableUtil = require("common.table_util")
              awardtb[award.resId] = TableUtil.CopyTable(award)
            else
              awardtb[award.resId].number = awardtb[award.resId].number + award.number
            end
          end
        end
      end
    end
  else
    local item = {}
    item.resId = 2199002
    item.ItemQuality = CDataTable.GetTableData("Item", item.resId).ItemQuality
    awardtb[item.resId] = item
  end
  local awards = {}
  for k, v in pairs(awardtb) do
    table.insert(awards, v)
  end
  table.sort(awards, function(a, b)
    if a.resId == 1006 then
      return true
    elseif b.resId == 1006 then
      return false
    elseif a.ItemQuality < b.ItemQuality then
      return false
    elseif a.ItemQuality > b.ItemQuality then
      return true
    else
      return a.resId < b.resId
    end
  end)
  return awards
end
function UnknowPassBuySystem.BuyScore(level, couponid, discountPrice, vouchers)
  local strBuy = LocUtil.GetLocalizeResStr(301185)
  local itemName = ""
  if UnknowPassSystem.Level < 100 then
    itemName = GlobalData.GetLocalizeStringWithNum(4576, 0, level)
  else
    itemName = GlobalData.GetLocalizeStringWithNum(4576, 0, tostring(level * 100))
  end
  local price = discountPrice or level * 100 - UnknowPassSystem.Score
  local tip = GlobalData.GetLocalizeStringWithNum(44542, 0, tostring(price), itemName)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local msgData = {
    styleType = 2,
    title = strBuy,
    msg = tip,
    clickOkCallback = function()
      UIManager.CloseUI(UIManager.UI_Config.unknowpass_award_buyscore)
      UnknowPassBuySystem.ConfirmBuyScore(level, couponid, vouchers, price)
    end
  }
  CommonMsgBoxMgr.ShowUSPolicyTip(msgData)
end
function UnknowPassBuySystem.ConfirmBuyScore(level, couponid, vouchers, nCurPrice)
  log_tree("UnknowPassBuySystem.ConfirmBuyScore ", vouchers)
  local diff_score = level * 100 - UnknowPassSystem.Score
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_buy_score_req(diff_score, UnknowPassSystem.Level, UnknowPassSystem.Score, couponid, vouchers, nCurPrice)
end
function UnknowPassBuySystem.OnGetStoreData(eventType, eventID, svrData)
  local data = svrData.data[StoreConst.label_market_index_market_list]
  if not data then
    return
  end
  local _, elite_itemid = UnknowPassBuySystem.FindBuyId(false, false)
  local _, nomal_itemid = UnknowPassBuySystem.FindBuyId(false, true)
  log(bWriteLog and "OnGetStoreData eliteID:" .. tostring(elite_itemid) .. "normalID:" .. tostring(nomal_itemid))
  for i, v in pairs(data) do
    local priceList = v[StoreConst.label_item_index_price_list]
    if priceList and priceList[1] and priceList[1][StoreConst.label_price_index_price_type] == StoreConst.label_price_type_iap then
      if priceList[1][StoreConst.label_price_index_one_original_price] == UnknowPassBuySystem.normalRPPackId and nomal_itemid and v[StoreConst.label_item_index_id] == nomal_itemid then
        UnknowPassBuySystem.normalPassShopInfo = v
      end
      if priceList[1][StoreConst.label_price_index_one_original_price] == UnknowPassBuySystem.eliteRPPackId and elite_itemid and v[StoreConst.label_item_index_id] == elite_itemid then
        UnknowPassBuySystem.elitePassShopInfo = v
      end
    end
  end
end
function UnknowPassBuySystem.UpdateNormalPassDirectPurchaseInfo()
  local MallSystem = require("client.logic.mall.logic_mall")
  if UnknowPassBuySystem.normalPassDirectPurchaseInfo then
    UnknowPassBuySystem.normalPassDirectPurchasePrice = UnknowPassBuySystem.normalPassDirectPurchaseInfo.productPriceDesc
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_NORMAL_IAP_PRICE)
  else
    local normalRPPackId = UnknowPassBuySystem.normalRPPackId
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0, function()
      MallSystem.GetDirectPurchaseInfoReq(normalRPPackId)
    end)
  end
end
function UnknowPassBuySystem.UpdateElitePassDirectPurchaseInfo()
  local MallSystem = require("client.logic.mall.logic_mall")
  if UnknowPassBuySystem.elitePassDirectPurchaseInfo then
    UnknowPassBuySystem.elitePassDirectPurchasePrice = UnknowPassBuySystem.elitePassDirectPurchaseInfo.productPriceDesc
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ELITE_IAP_PRICE)
  else
    local eliteRPPackId = UnknowPassBuySystem.eliteRPPackId
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0, function()
      MallSystem.GetDirectPurchaseInfoReq(eliteRPPackId)
    end)
  end
end
function UnknowPassBuySystem.OnGetDirectPurchaseInfo(eventType, eventID)
  local MallSystem = require("client.logic.mall.logic_mall")
  local info = MallSystem.GetRewardPkgInfo()
  log_tree("UnknowPassBuySystem.OnGetDirectPurchaseInfo info:", info)
  local normalRPPackId = UnknowPassBuySystem.normalRPPackId
  local eliteRPPackId = UnknowPassBuySystem.eliteRPPackId
  if info.item_id == normalRPPackId then
    info.productPriceDesc = info.configPrice
    UnknowPassBuySystem.normalPassDirectPurchaseInfo = DeepCopy(info)
    UnknowPassBuySystem.normalPassDirectPurchasePrice = info.productPriceDesc
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_NORMAL_IAP_PRICE)
  elseif info.item_id == eliteRPPackId then
    info.productPriceDesc = info.configPrice
    UnknowPassBuySystem.elitePassDirectPurchaseInfo = DeepCopy(info)
    UnknowPassBuySystem.elitePassDirectPurchasePrice = info.productPriceDesc
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ELITE_IAP_PRICE)
  end
end
function UnknowPassBuySystem.OnGetCentauriGoodsInfo(evenType, eventID, resultTable)
  log(bWriteLog and "UnknowPassBuySystem.GetCentauriGoodsInfo")
  log_tree("UnknowPassBuySystem.GetCentauriGoodsInfo(evenType, eventID, resultTable)", resultTable)
  if resultTable == nil then
    log(bWriteLog and "\230\139\137\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
    return
  end
  local product = resultTable[1]
  if not product then
    log_warning("product is nil!")
    return
  end
  if product.productId ~= nil and product.price ~= nil then
    local priceDesc = product.price
    if UnknowPassBuySystem.normalPassDirectPurchaseInfo and product.productId == UnknowPassBuySystem.normalPassDirectPurchaseInfo.CentauriProductId then
      UnknowPassBuySystem.normalPassCentauriPrice = priceDesc
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_NORMAL_IAP_PRICE)
    elseif UnknowPassBuySystem.elitePassDirectPurchaseInfo and product.productId == UnknowPassBuySystem.elitePassDirectPurchaseInfo.CentauriProductId then
      UnknowPassBuySystem.elitePassCentauriPrice = priceDesc
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ELITE_IAP_PRICE)
    end
  end
end
function UnknowPassBuySystem.IsCurSeason(buyId)
  for _, v in pairs(UnknowPassBuySystem.seasonBuyIDs) do
    if v == buyId then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.IsUniversalRP(itemID)
  local universals = {
    1603198,
    1603199,
    1603196,
    1603197
  }
  for _, id in pairs(universals) do
    if itemID == id then
      log(bWriteLog and "[   IsUniversalRP" .. tostring(itemID))
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.GetBuyTypeWithCoupon(rawBuyType)
  return rawBuyType
end
function UnknowPassBuySystem.GetBuyConfigViaBuyType(EliteBuyType)
  for _, BuyID in pairs(UnknowPassBuySystem.seasonBuyIDs) do
    local cfg = CDataTable.GetTableData("UnknowPassBuyCfg", BuyID)
    if cfg and cfg.buyType == EliteBuyType then
      return cfg
    end
  end
end
local _FindMatchInCardList = function(tCardList, tBuyCfgList, nBuyItem2Id, bIsOwn, bIsExtra, tRawBuyCfg, nRawBuyType)
  for _, tCard in pairs(tCardList) do
    for _, tCfg in pairs(tBuyCfgList) do
      local bItemMatch = tCfg.BuyItemId == tCard.itemId and tCfg.BuyItem2Id == nBuyItem2Id
      local bExtraMatch = not bIsExtra or tCfg.IsExtra == 1
      local bBuyTypeMatch = not nRawBuyType or tCfg.buyType == nRawBuyType
      local bTypeCheck = not bIsExtra or UnknowPassBuySystem.CheckBuyType(tCfg, tRawBuyCfg)
      if bItemMatch and bExtraMatch and bBuyTypeMatch and bTypeCheck then
        if not bIsOwn then
          return tCfg.ID, tCard.itemId
        end
        if UnknowPassBuySystem.IsCurSeason(tCfg.ID) and UnknowPassBuySystem.HasItem(tCard.itemId) then
          return tCfg.ID, tCard.itemId
        end
      end
    end
  end
  return 0, 0
end
function UnknowPassBuySystem.FindBuyId(byUC, isNormal, isOwn, CanExtraUpgrade, rawBuyType)
  local tMainCardList = isNormal and UnknowPassBuySystem.Normal_Pass_ItemIDs or UnknowPassBuySystem.Super_Pass_ItemIDs
  local tRawBuyCfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(rawBuyType)
  local tAllBuyCfg = CDataTable.GetTableByFilter("UnknowPassBuyCfg", "SeasonID", UnknowPassSystem.Season, "buyType", rawBuyType)
  local nBuyItem2Id = byUC and 1006 or 0
  local nBuyId, nItemId
  if byUC then
    nBuyId, nItemId = _FindMatchInCardList(tMainCardList, tAllBuyCfg, nBuyItem2Id, isOwn, false, nil, rawBuyType)
    if 0 < nBuyId then
      return nBuyId, nItemId
    end
    nBuyId, nItemId = _FindMatchInCardList(UnknowPassBuySystem.Experience_Pass_ItemIDs, tAllBuyCfg, nBuyItem2Id, isOwn, false, nil, rawBuyType)
    if 0 < nBuyId then
      return nBuyId, nItemId
    end
    nBuyId, nItemId = _FindMatchInCardList(UnknowPassBuySystem.NewUser_Privleges_ItemID, tAllBuyCfg, nBuyItem2Id, isOwn, false, nil, nil)
    return nBuyId, nItemId
  else
    if CanExtraUpgrade then
      nBuyId, nItemId = _FindMatchInCardList(tMainCardList, tAllBuyCfg, nBuyItem2Id, true, true, tRawBuyCfg, nil)
      if 0 < nBuyId then
        return nBuyId, nItemId
      end
    end
    nBuyId, nItemId = _FindMatchInCardList(tMainCardList, tAllBuyCfg, nBuyItem2Id, isOwn, false, nil, nil)
    if 0 < nBuyId then
      return nBuyId, nItemId
    end
    nBuyId, nItemId = _FindMatchInCardList(UnknowPassBuySystem.Experience_Pass_ItemIDs, tAllBuyCfg, nBuyItem2Id, isOwn, false, nil, nil)
    return nBuyId, nItemId
  end
end
function UnknowPassBuySystem.FindExperienceCardBuyId()
  local tb = UnknowPassBuySystem.Experience_Pass_ItemIDs
  local cfg = CDataTable.GetTableByFilter("UnknowPassBuyCfg", "SeasonID", UnknowPassSystem.Season)
  for _, id in pairs(tb) do
    for _, v in pairs(cfg) do
      if v.BuyItemId == id.itemId and v.BuyItem2Id == 0 and UnknowPassBuySystem.IsCurSeason(v.ID) and UnknowPassBuySystem.HasItem(id.itemId) then
        return v.ID, id.itemId
      end
    end
  end
  return 0, 0
end
function UnknowPassBuySystem.FindNewUserPrivlegesBuyId(rawBuyType)
  local tb = UnknowPassBuySystem.NewUser_Privleges_ItemID
  local cfg = CDataTable.GetTableByFilter("UnknowPassBuyCfg", "SeasonID", UnknowPassSystem.Season)
  for _, id in pairs(tb) do
    for _, v in pairs(cfg) do
      if v.BuyItemId == id.itemId and v.buyType == rawBuyType and UnknowPassBuySystem.IsCurSeason(v.ID) and UnknowPassBuySystem.HasItem(id.itemId) then
        return v.ID, id.itemId
      end
    end
  end
  return 0, 0
end
function UnknowPassBuySystem.IsUseNewUserPrivlegesCard(buyType)
  local typeList = {
    45,
    46,
    47,
    48
  }
  for _, v in pairs(typeList) do
    if buyType == v then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.HasItem(id)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local item = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(id)
  if item and item.count > 0 then
    return true
  end
  return false
end
function UnknowPassBuySystem.IsPassIdWithType(id, isNormal)
  if isNormal then
    for i, v in pairs(UnknowPassBuySystem.Normal_Pass_ItemIDs) do
      if id == v.itemId then
        return true
      end
    end
    return false
  else
    for i, v in pairs(UnknowPassBuySystem.Super_Pass_ItemIDs) do
      if id == v.itemId then
        return true
      end
    end
    return false
  end
end
function UnknowPassBuySystem.IsPassId(id, isNormal)
  for i, v in pairs(UnknowPassBuySystem.Normal_Pass_ItemIDs) do
    if id == v.itemId then
      return true
    end
  end
  if isNormal then
    return false
  end
  for i, v in pairs(UnknowPassBuySystem.Super_Pass_ItemIDs) do
    if id == v.itemId then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.IsRpExperienceCard(id)
  for _, v in pairs(UnknowPassBuySystem.Experience_Pass_ItemIDs) do
    if id == v.itemId then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.IsNewUserPrivlegesCard(id)
  for _, v in pairs(UnknowPassBuySystem.NewUser_Privleges_ItemID) do
    if id == v.itemId then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.IsRPCard(nItemId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
  if uObj_itemCfg and uObj_itemCfg.itemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item and uObj_itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Upass_Upgrade then
    return true
  end
  return false
end
function UnknowPassBuySystem.HasUpCard(isNormal)
  local tb = UnknowPassBuySystem.Super_Pass_ItemIDs
  if isNormal then
    tb = UnknowPassBuySystem.Normal_Pass_ItemIDs
  end
  if not tb then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for i, v in pairs(tb) do
    local item = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.itemId)
    if item and item.count > 0 then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.HasExperienceCard()
  local tb = UnknowPassBuySystem.Experience_Pass_ItemIDs
  if not tb then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(tb) do
    local item = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.itemId)
    if item and item.count > 0 then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.HasNewUserPrivlegesCard()
  local tb = UnknowPassBuySystem.NewUser_Privleges_ItemID
  if not tb then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(tb) do
    local item = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.itemId)
    if item and item.count > 0 then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.GetUpgradeCardId()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(UnknowPassBuySystem.Super_Pass_ItemIDs) do
    local item = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.itemId)
    if item and item.count > 0 then
      return v.itemId, LocUtil.GetLocalizeResStr(502507)
    end
  end
  for _, v in pairs(UnknowPassBuySystem.Normal_Pass_ItemIDs) do
    local item = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.itemId)
    if item and item.count > 0 then
      return v.itemId, LocUtil.GetLocalizeResStr(502508)
    end
  end
  for _, v in pairs(UnknowPassBuySystem.NewUser_Privleges_ItemID) do
    local item = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.itemId)
    if item and item.count > 0 then
      return v.itemId, LocUtil.GetLocalizeResStr(502508)
    end
  end
end
function UnknowPassBuySystem.HasUpgradeCard(bIsIgnoreExperience)
  local haveNormal = UnknowPassBuySystem.HasUpCard(true)
  local haveSuper = UnknowPassBuySystem.HasUpCard(false)
  if not bIsIgnoreExperience and UnknowPassBuySystem.HasExperienceCard() then
    return not UnknowPassSystem.IsBuyElite
  end
  if UnknowPassBuySystem.HasNewUserPrivlegesCard() then
    return not UnknowPassSystem.IsBuyElite
  end
  if haveSuper or haveNormal then
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    if PassDataSystem.is_experience and PassDataSystem.is_experience == 1 then
      return true
    end
    return not UnknowPassSystem.IsBuyElite
  end
  return false
end
function UnknowPassBuySystem.IsHasExperienceUpgradeCard()
  local tCardsData = UnknowPassBuySystem.Experience_Pass_ItemIDs
  if not tCardsData then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for i, v in pairs(tCardsData) do
    local item = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.itemId)
    if item and item.count > 0 then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.GetRPAllUpgradeCardId()
  local nRP_1_50CardId, nRP_1_100_NormalCarId, nRP_1_100_PlusCarId
  for _, v in pairs(UnknowPassBuySystem.Experience_Pass_ItemIDs) do
    nRP_1_50CardId = v.itemId
  end
  for _, v in pairs(UnknowPassBuySystem.Normal_Pass_ItemIDs) do
    nRP_1_100_NormalCarId = v.itemId
  end
  for _, v in pairs(UnknowPassBuySystem.Super_Pass_ItemIDs) do
    nRP_1_100_PlusCarId = v.itemId
  end
  return nRP_1_50CardId, nRP_1_100_NormalCarId, nRP_1_100_PlusCarId
end
function UnknowPassBuySystem.CheckSuper(itemId)
  local tb = UnknowPassBuySystem.Super_Pass_ItemIDs
  for _, cfg in pairs(tb) do
    if cfg.itemId == itemId then
      return true
    end
  end
  return false
end
function UnknowPassBuySystem.CheckExtraUpgrade()
  if not UnknowPassSystem.IsBuyElite then
    return false
  end
  if not UnknowPassSystem.IsBuyEliteSeg2 then
    return true
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if UnknowPassSystem.PassType ~= 1 or PassDataSystem.is_experience == 1 then
    return false
  end
  local startTime = UnknowPassSystem.upgrade_buy_opentime
  local endTime = UnknowPassSystem.upgrade_buy_endtime
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "UnknowPassSystem.PassType " .. UnknowPassSystem.PassType)
  log(bWriteLog and "UnknowPassSystem.PassType " .. tostring(startTime) .. " " .. FuncUtil.GetServerTimeInSec() .. " " .. tostring(endTime))
  if startTime and startTime <= FuncUtil.GetServerTimeInSec() and endTime and endTime >= TimeUtil.GetServerTimeInSec() then
    return true
  end
  if endTime and endTime == 0 then
    return true
  end
  return false
end
function UnknowPassBuySystem.CheckInExtraTime()
  local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassSystem.Season)
  local startTime = UnknowPassSystem.upgrade_buy_opentime
  local endTime = UnknowPassSystem.upgrade_buy_endtime
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "UnknowPassBuySystem.CheckInExtraTime " .. tostring(cfg.UpgradeStartTime) .. " " .. tostring(cfg.UpgradeEndTime) .. " " .. tostring(TimeUtil.GetServerTimeInSec()))
  if startTime and startTime <= FuncUtil.GetServerTimeInSec() and endTime and endTime >= TimeUtil.GetServerTimeInSec() then
    return true
  end
  if endTime and endTime == 0 then
    return true
  end
  return false
end
function UnknowPassBuySystem.GetExtraUpgradePrice(isNormal)
  if not UnknowPassSystem.CanExtraUpgrade then
    log(bWriteLog and "[UnknowPassBuySystem] no valid upgrade service")
    return 0
  end
  if isNormal then
    if not UnknowPassSystem.IsBuyEliteSeg2 then
      local buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(18)
      if buy_cfg then
        return buy_cfg.PriceDiscount1
      end
    end
  elseif UnknowPassSystem.PassType ~= 2 then
    if not UnknowPassSystem.IsBuyEliteSeg2 then
      local buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(19)
      if buy_cfg then
        return buy_cfg.PriceDiscount1
      end
    else
      local buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(20)
      if buy_cfg then
        return buy_cfg.PriceDiscount1
      end
    end
  end
end
function UnknowPassBuySystem.HandleBuySuperPopup(hasCardType, fromType, rawBuyType, disLevel, buyType, bIsExperienceCard, bIsExperienceCardBuyNormal)
  if not hasCardType or hasCardType == 0 then
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._UnknowPass
    local price = 0
    if UnknowPassBuySystem.Super_Pass_Info and UnknowPassBuySystem.Super_Pass_Info.discountPrice then
      price = UnknowPassBuySystem.Super_Pass_Info.discountPrice
    end
    if UnknowPassSystem.CanExtraUpgrade then
      price = UnknowPassBuySystem.GetExtraUpgradePrice(false)
    end
    local extra_data = {}
    function extra_data.dynamicFunc()
      local couponUI = UIManager.GetUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass)
      if couponUI then
        local price = price or 0
        local newprice = price - couponUI.voucherValue - CouponSystem.GetCouponValue(price, disLevel)
        newprice = newprice < 0 and 0 or newprice
        local tip = UnknowPassBuySystem.GetBuyPassString(true, newprice)
        EventSystem:postEvent(EVENTTYPE_COUPON, EVENTID_COUPON_CHANGE_TEXT, tip)
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_UPDATE_COUPON_PRICE, price, newprice)
      end
    end
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    extra_data.except_map = PassDataSystem.GetBuyExceptCouponMap()
    extra_data.    log_tree("extra_data.except_map ", extra_data.except_map)
    local buyString = UnknowPassBuySystem.GetBuyPassString(true, price)
    local tShowCfg = {
      nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
      sTitle = LocUtil.GetLocalizeResStr("301185"),
      sTipContent = buyString,
      nMainScene = CouponSystem._Enum_Scene._UnknowPass,
      nChildScene = UnknowPassSystem.Season,
      nCurPrice = price,
      fConfirmCallback = function(confirmData)
        if confirmData then
          UnknowPassBuySystem.ComfirmBuyPass(true, confirmData.nCurCouponId, confirmData.tVoucherList, fromType, confirmData.nShowNewPrice, rawBuyType, buyType)
        end
      end,
      tExtraData = extra_data
    }
    UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass, tShowCfg)
  elseif not bIsExperienceCardBuyNormal and (hasCardType == 1 or hasCardType == 2 or hasCardType == 45) then
    local isNormal = hasCardType == 1
    local buyId, ItemId
    local bIsNewUserPrivlegesCard = UnknowPassBuySystem.IsUseNewUserPrivlegesCard(rawBuyType)
    if bIsExperienceCard then
      buyId, ItemId = UnknowPassBuySystem.FindExperienceCardBuyId()
    elseif bIsNewUserPrivlegesCard then
      buyId, ItemId = UnknowPassBuySystem.FindNewUserPrivlegesBuyId(rawBuyType)
    else
      buyId, ItemId = UnknowPassBuySystem.FindBuyId(false, isNormal, true, UnknowPassSystem.CanExtraUpgrade, rawBuyType)
    end
    log(bWriteLog and "buyid" .. buyId .. ItemId)
    local content1 = CDataTable.GetTableData("Item", ItemId).ItemName
    local content2 = hasCardType == 1 and LocUtil.LocalizeResFormat("4547") or LocUtil.LocalizeResFormat("7275")
    local tip = LocUtil.LocalizeResFormat("7865", 1, content1, content2)
    local ExperienceCardType = 45
    if bIsNewUserPrivlegesCard and rawBuyType > ExperienceCardType then
      local buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(rawBuyType)
      tip = LocUtil.LocalizeResFormat("7866", 1, content1, buy_cfg.PriceDiscount2, content2)
    end
    if UnknowPassBuySystem.CheckInExtraTime() then
      tip = LocUtil.LocalizeResFormat("27721", 1, content1, content2)
      if bIsNewUserPrivlegesCard and rawBuyType > ExperienceCardType then
        local buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(rawBuyType)
        tip = LocUtil.LocalizeResFormat("27722", 1, content1, buy_cfg.PriceDiscount2, content2)
      end
    end
    if UnknowPassSystem.IsBuyElite then
      if UnknowPassSystem.IsBuyEliteSeg2 then
        tip = string.format([[
%s
%s]], LocUtil.GetLocalizeResStr(18130139), tip)
      else
        tip = string.format([[
%s
%s]], LocUtil.GetLocalizeResStr(18130138), tip)
      end
    end
    local title = LocUtil.GetLocalizeResStr("101001")
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tip, function()
      local season = UnknowPassSystem.Season
      local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", season)
      if cfg == nil then
        return
      end
      if fromType and 0 < fromType then
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        local TLogReasonTable = {
          event_name = "UnknowpassBuyFrom",
          rp_type = hasCardType ~= 1 and "super" or "normal"
        }
        local TLogReasonStr = json.encode(TLogReasonTable)
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.UnknowpassBuyFrom, fromType, TLogReasonStr)
        log(bWriteLog and "TLog new format, UnknowPassBuySystem.HandleBuySuperPopup hasCardType == 1 or hasCardType == 2, reason : " .. tostring(fromType) .. " reasonStr : " .. tostring(TLogReasonStr))
      end
      UnknowPassBuySystem.upass_buy_pass_req(buyId, nil, nil, fromType)
      return true
    end)
  elseif hasCardType == 3 or bIsExperienceCardBuyNormal then
    local buyId, ItemId
    local bIsNewUserPrivlegesCard = UnknowPassBuySystem.IsUseNewUserPrivlegesCard(rawBuyType)
    if bIsExperienceCard then
      buyId, ItemId = UnknowPassBuySystem.FindExperienceCardBuyId()
    elseif bIsNewUserPrivlegesCard then
      buyId, ItemId = UnknowPassBuySystem.FindNewUserPrivlegesBuyId(rawBuyType)
    else
      buyId, ItemId = UnknowPassBuySystem.FindBuyId(true, true, true, nil, rawBuyType)
    end
    log(bWriteLog and "buyId222 = " .. buyId .. "     " .. ItemId)
    local price = 1200
    local buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(rawBuyType)
    if buy_cfg then
      price = buy_cfg.PriceDiscount2
    end
    local content1 = CDataTable.GetTableData("Item", ItemId).ItemName
    local content2 = LocUtil.LocalizeResFormat("7275")
    if bIsExperienceCardBuyNormal then
      content2 = LocUtil.LocalizeResFormat(4547)
    end
    local tip = LocUtil.LocalizeResFormat("7866", 1, content1, price, content2)
    if UnknowPassBuySystem.CheckInExtraTime() then
      tip = LocUtil.LocalizeResFormat("27722", 1, content1, content2)
    end
    local title = LocUtil.GetLocalizeResStr("101001")
    local extra_data = {}
    function extra_data.dynamicFunc()
      local couponUI = UIManager.GetUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass)
      if couponUI then
        local sTipContent = LocUtil.LocalizeResFormat("7866", 1, content1, price - couponUI.voucherValue, content2)
        if UnknowPassSystem.IsBuyElite and not UnknowPassSystem.IsBuyEliteSeg2 then
          sTipContent = string.format([[
%s
%s]], LocUtil.GetLocalizeResStr(18130138), sTipContent)
        end
        EventSystem:postEvent(EVENTTYPE_COUPON, EVENTID_COUPON_CHANGE_TEXT, sTipContent)
      end
    end
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    extra_data.except_map = PassDataSystem.GetBuyExceptCouponMap()
    extra_data.    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._UnknowPass
    local tShowCfg = {
      nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
      sTitle = title,
      sTipContent = tip,
      nMainScene = CouponSystem._Enum_Scene._UnknowPass,
      nChildScene = UnknowPassSystem.Season,
      nCurPrice = price,
      fConfirmCallback = function(confirmData)
        local season = UnknowPassSystem.Season
        local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", season)
        if cfg == nil then
          return
        end
        if fromType and 0 < fromType then
          local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
          local TLogReasonTable = {
            event_name = "UnknowpassBuyFrom",
            rp_type = "super"
          }
          local TLogReasonStr = json.encode(TLogReasonTable)
          tlog_report_utils.ReportTLogEvent(TLogEventDefine.UnknowpassBuyFrom, fromType, TLogReasonStr)
          log(bWriteLog and "TLog new format, UnknowPassBuySystem.HandleBuySuperPopup hasCardType == 3, reason : " .. tostring(fromType) .. " reasonStr : " .. tostring(TLogReasonStr))
        end
        UnknowPassBuySystem.upass_buy_pass_req(buyId, confirmData.tVoucherList, confirmData.nShowNewPrice, fromType)
        return true
      end,
      tExtraData = extra_data
    }
    UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass, tShowCfg)
  end
end
function UnknowPassBuySystem.HandleBuyNormalPopup(hasCardType, fromType, rawBuyType, disLevel, buyType)
  local bIsNewUserPrivlegesCard = UnknowPassBuySystem.IsUseNewUserPrivlegesCard(rawBuyType)
  if not hasCardType or hasCardType ~= 3 and not bIsNewUserPrivlegesCard and rawBuyType ~= 40 then
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._UnknowPass
    if UnknowPassBuySystem.Normal_Pass_Info == nil then
      return
    end
    local price = UnknowPassBuySystem.Normal_Pass_Info.discountPrice
    if rawBuyType then
      local buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(rawBuyType)
      if buy_cfg then
        price = buy_cfg.PriceDiscount1
      end
    end
    local extra_data = {}
    function extra_data.dynamicFunc()
      local couponUI = UIManager.GetUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass)
      if couponUI then
        local newprice = price - couponUI.voucherValue - CouponSystem.GetCouponValue(price, disLevel)
        newprice = newprice < 0 and 0 or newprice
        local tip = UnknowPassBuySystem.GetBuyPassString(false, newprice, buyType)
        EventSystem:postEvent(EVENTTYPE_COUPON, EVENTID_COUPON_CHANGE_TEXT, tip)
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_UPDATE_COUPON_PRICE, price, newprice)
      end
    end
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    extra_data.except_map = PassDataSystem.GetBuyExceptCouponMap()
    extra_data.    local buyString = UnknowPassBuySystem.GetBuyPassString(false, price, buyType)
    local tShowCfg = {
      nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
      sTitle = LocUtil.GetLocalizeResStr("301185"),
      sTipContent = buyString,
      nMainScene = CouponSystem._Enum_Scene._UnknowPass,
      nChildScene = UnknowPassSystem.Season,
      nCurPrice = price,
      fConfirmCallback = function(confirmData)
        confirmData = confirmData or {}
        UnknowPassBuySystem.ComfirmBuyPass(false, confirmData.nCurCouponId, confirmData.tVoucherList, fromType, confirmData.nShowNewPrice, rawBuyType, buyType)
      end,
      tExtraData = extra_data
    }
    local bHasUpgradeCard = UnknowPassBuySystem.HasUpgradeCard(true)
    if buyType == 3 and bHasUpgradeCard then
      function tShowCfg.fCancelCallback()
        local jumpCtorData = {}
        local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
        ui_jump_manager.CloseJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS_SEG1)
        ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS, jumpCtorData)
      end
      tShowCfg.sCancelBtnText = LocUtil.GetLocalizeResStr(50038)
      tShowCfg.bIsCloseNotExcuteCancelCallback = true
    end
    UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass, tShowCfg)
  else
    local buyId, ItemId = UnknowPassBuySystem.FindBuyId(rawBuyType == 46, true, true, UnknowPassSystem.CanExtraUpgrade)
    local content1 = CDataTable.GetTableData("Item", ItemId).ItemName
    local content2 = LocUtil.LocalizeResFormat("4547")
    local tip = LocUtil.LocalizeResFormat("7865", 1, content1, content2)
    local ExperienceCardType = 45
    if bIsNewUserPrivlegesCard and rawBuyType ~= ExperienceCardType then
      local buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(rawBuyType)
      tip = LocUtil.LocalizeResFormat("7866", 1, content1, buy_cfg.PriceDiscount2, content2)
    end
    if UnknowPassBuySystem.CheckInExtraTime() then
      tip = LocUtil.LocalizeResFormat("27721", 1, content1, content2)
      if bIsNewUserPrivlegesCard and rawBuyType ~= ExperienceCardType then
        local buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(rawBuyType)
        tip = LocUtil.LocalizeResFormat("27722", 1, content1, buy_cfg.PriceDiscount2, content2)
      end
    end
    local title = LocUtil.GetLocalizeResStr("101001")
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tip, function()
      local season = UnknowPassSystem.Season
      local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", season)
      if cfg == nil then
        return
      end
      if fromType and 0 < fromType then
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        local TLogReasonTable = {
          event_name = "UnknowpassBuyFrom",
          rp_type = "normal"
        }
        local TLogReasonStr = json.encode(TLogReasonTable)
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.UnknowpassBuyFrom, fromType, TLogReasonStr)
        log(bWriteLog and "TLog new format, UnknowPassBuySystem.HandleBuyNormalPopup, reason : " .. tostring(fromType) .. " reasonStr : " .. tostring(TLogReasonStr))
      end
      UnknowPassBuySystem.upass_buy_pass_req(buyId, nil, nil, fromType)
      return true
    end)
  end
end
function UnknowPassBuySystem.upass_buy_pass_list_req()
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_buy_pass_list_req(UnknowPassBuySystem.nCurDataVersion)
end
function UnknowPassBuySystem.upass_buy_pass_list_rsp(buyTable, isBuy, passType, level_limit, svr_ver)
  log(bWriteLog and "upass_buy_pass_list_rsp isBuy: " .. isBuy)
  UnknowPassSystem.IsBuyElite = isBuy ~= 0
  UnknowPassSystem.IsBuyEliteSeg2 = UnknowPassSystem.IsBuyElite and level_limit == nil
  log(bWriteLog and "[[  == UnknowPassSystem.IsBuyElite]" .. tostring(UnknowPassSystem.IsBuyElite) .. "   PassType=" .. tostring(UnknowPassSystem.PassType))
  UnknowPassSystem.PassType = passType or 0
  UnknowPassSystem.CanExtraUpgrade = UnknowPassBuySystem.CheckExtraUpgrade()
  log(bWriteLog and "UnknowPassSystem.CanExtraUpgrade " .. tostring(UnknowPassSystem.CanExtraUpgrade))
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  UnknowPassSystem.UpgradeTipsType = PassDataSystem.CheckUpgradeTipsType()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_UPDATE_BUYBUTTON)
  if UnknowPassBuySystem.nCurDataVersion ~= svr_ver then
    UnknowPassBuySystem.OnUpdateSeriesABuyData(buyTable)
  end
  UnknowPassBuySystem.nCurDataVersion = svr_ver
  local LobbyEffect = require("client.logic.login.logic_LobbyEffect")
  LobbyEffect.UpdateEffectUI()
end
function UnknowPassBuySystem.IsNormalPassBuyId(buyId)
  local tb = CDataTable.GetTable("UnknowPassBuyCfg")
  for k, v in pairs(tb) do
    if v.ID == buyId then
      if v.buyType == 1 or v.buyType == 2 then
        return true
      else
        return false
      end
    end
  end
  return false
end
function UnknowPassBuySystem.upass_buy_pass_req(buyid, vouchers, nCurPrice, fromType)
  log(bWriteLog and "UnknowPassSystem.upass_buy_pass_req" .. tostring(buyid))
  log_tree("UnknowPassSystem.upass_buy_pass_req", vouchers)
  log(bWriteLog and string.format("UnknowPassBuySystem.upass_buy_pass_req, fromType:%s", fromType))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  UnknowPassSystem.reqBuyId = buyid
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UnknowPassSystem.bSendBuyReq = true
  UnknowPassBuySystem.nUCCountLackTip = nCurPrice or 0
  if UnknowPassBuySystem.bRpJump then
    local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
    UnknowPassTunnelSystem.UpdateCameraAndBg(true)
    UnknowPassBuySystem.bRpJump = false
  end
  UpassHandle.send_upass_buy_pass_req(buyid, vouchers, nil, fromType)
end
function UnknowPassBuySystem.IsEliteSeg2Buy(buyId)
  local buy_cfg = CDataTable.GetTableData("UnknowPassBuyCfg", buyId)
  if not buy_cfg or not buy_cfg.TicketType then
    return false
  end
  return buy_cfg.TicketType == 102 or buy_cfg.TicketType == 103
end
function UnknowPassBuySystem.IsUnlockBuy(buyId)
  local buy_cfg = CDataTable.GetTableData("UnknowPassBuyCfg", buyId)
  if not buy_cfg then
    return false
  end
  return buy_cfg.IsExtra == 0
end
function UnknowPassBuySystem.upass_buy_pass_rsp(res, reward_list, upass_score, upass_level, before_level, _, _, _, experience_level, refund_infos, continuous_buy)
  UnknowPassSystem.bSendBuyReq = false
  if res == 0 then
    if UnknowPassSystem.RpBuyCallBack then
      UnknowPassSystem.RpBuyCallBack(UnknowPassBuySystem.nGroupActId)
      UnknowPassBuySystem.nGroupActId = nil
    end
    local BlackFridayMainModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayMainModule)
    local BlackFridayMacros = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayMacros")
    local ActType = BlackFridayMacros.ActivityType
    if BlackFridayMainModule:HasActivityData(ActType.RPGroup) then
      local BlackFridayRPGroupModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayRPGroupModule)
      local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
      local bIsReceived = BlackFridayRPGroupModule:GetIsHadReceiveReward()
      local bIsModDownloaded = LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.BlackFriday)
      if bIsModDownloaded and UnknowPassSystem.IsBuyElite and not bIsReceived then
        BlackFridayRPGroupModule:SetIsUpgradeRPPlus(UnknowPassSystem.IsBuyEliteSeg2)
        if BlackFridayRPGroupModule:GetIsBlackFridayJumpToRPBuy() then
          BlackFridayRPGroupModule:SetIsNeedPopUpRewardUpgradePopup(true)
        else
          UIManager.ShowUI(UIManager.UI_Config.BlackFriday_RP_RewardUpgrades_Popup_UIBP)
        end
      end
    end
    UnknowPassBuySystem.IsBuyEliteCloseUI = true
    local UnknowPassBuySyetem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
    UnknowPassBuySyetem.HideBuyUI()
    UnknowPassSystem.Level = upass_level
    UnknowPassSystem.Score = upass_score
    UnknowPassSystem.BuyBeforeLevel = before_level
    UnknowPassSystem.IsBuyElite = true
    UnknowPassSystem.IsBuyEliteSeg2 = UnknowPassSystem.IsBuyElite and UnknowPassBuySystem.IsEliteSeg2Buy(UnknowPassSystem.reqBuyId)
    local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
    passReddotMainSystem.UpdateReddot()
    local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
    UnknowPassAwardSystem.UpdateContinueBuyData(continuous_buy)
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_BLACKMARKET_REDDOT)
    if refund_infos and next(refund_infos) then
      for _, v in pairs(refund_infos) do
        if reward_list[v.src_idx] then
          reward_list[v.src_idx].item_id = v.refund_item_id
          reward_list[v.src_idx].item_num = v.refund_item_num
        end
      end
    end
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, reward_list, UnknowPassSystem.reqBuyId)
    local passType = "OtherPass"
    if UnknowPassBuySystem.IsNormalPassBuyId(UnknowPassSystem.reqBuyId) then
      passType = "NormalPass"
    end
    UnknowPassBuySystem.ReportBuyEvent(true, false, false, passType)
    UnknowPassBuySystem.upass_buy_pass_list_req()
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    PassDataSystem.upass_get_req()
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.GetNeedShowReddot()
    LobbySystem.refresh_activity_display_by_unknow_pass()
    local LobbyEffect = require("client.logic.login.logic_LobbyEffect")
    LobbyEffect.UpdateEffectUI()
  else
    if res == 502006 then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(UnknowPassBuySystem.nUCCountLackTip)
    else
      ShowNotice(res)
    end
    local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
    UnknowPassLevelupSystem.isInExperienceUpgrading = false
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.end
function UnknowPassBuySystem.on_rp_anniversary_bonus_reward_ntf(err_code, bonus_list, reward_list, upass_score, upass_level, before_level, _, _, _, experience_level, refund_infos, continuous_buy)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  log_tree("UnknowPassBuySystem.on_rp_anniversary_bonus_reward_ntf ", bonus_list)
  if reward_list and upass_score and upass_level then
    UnknowPassSystem.Level = upass_level
    UnknowPassSystem.Score = upass_score
    local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
    passReddotMainSystem.UpdateReddot()
    if refund_infos and next(refund_infos) then
      for _, v in pairs(refund_infos) do
        if reward_list[v.src_idx] then
          reward_list[v.src_idx].item_id = v.refund_item_id
          reward_list[v.src_idx].item_num = v.refund_item_num
        end
      end
    end
    local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
    function UnknowPassLevelupSystem.fAnnualCallBack()
      local tExtendData = {
        fCloseCallback = function()
          UIManager.ShowUI(UIManager.UI_Config.Annual_Crit_Award_Popup_UIBP, bonus_list)
          UnknowPassLevelupSystem.fAnnualCallBack = nil
        end
      }
      local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
      local itemList = UnknowPassUtil.GetAwardList(reward_list) or {}
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_RPRewardGet(itemList, tExtendData)
    end
  else
    local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
    function UnknowPassLevelupSystem.fAnnualCallBack()
      UIManager.ShowUI(UIManager.UI_Config.Annual_Crit_Award_Popup_UIBP, bonus_list)
      UnknowPassLevelupSystem.fAnnualCallBack = nil
    end
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_get_req()
end
function UnknowPassBuySystem.on_upass_send_old_user_awards_notify(res_list)
  log_tree("on_upass_send_old_user_awards_notify ", res_list)
  local UnknowPassLevelupSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_levelup")
  function UnknowPassLevelupSystem.fOldUserAwardCallBack()
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local itemList = {}
    for _, v in ipairs(res_list) do
      table.insert(itemList, {
        res_id = v.resid,
        count = v.count,
        valid_hours = v.valid_hours
      })
    end
    Logic_CommonItemGet.ShowPanel_RPRewardGet(itemList)
    UnknowPassLevelupSystem.fOldUserAwardCallBack = nil
  end
end
function UnknowPassBuySystem.GetAwardInfoBySeason()
  local tActionData = CDataTable.GetTable("UnknowPassAction")
  local nCurSeason = UnknowPassSystem.Season
  local awardList = {}
  local curPassAwardNum = 0
  local curGameID = Client.GetITopGameId()
  for i, v in ipairs(tActionData) do
    if v.season_index == nCurSeason and string.find(v.APPID, curGameID) then
      curPassAwardNum = v.SelectCount
      local StringUtil = require("common.string_util")
      local award = StringUtil.Split(v.ActionList, ";")
      for i, v in ipairs(award) do
        local pos = string.find(v, "-")
        if pos then
          local tempID = string.sub(v, 1, pos - 1)
          local tempNum = string.sub(v, pos + 1, #v)
          local tempTable = {ID = tempID, Num = tempNum}
          table.insert(awardList, tempTable)
        else
          local tempTable = {ID = v, Num = 1}
          table.insert(awardList, tempTable)
        end
      end
    end
  end
  return awardList, curPassAwardNum
end
function UnknowPassBuySystem.GetAwardNumByID(awardList, ID)
  local num = 1
  for i, v in ipairs(awardList) do
    if tonumber(v.ID) == ID then
      num = v.Num
      break
    end
  end
  return num
end
function UnknowPassBuySystem.ReportBuyEvent(bPass, bScore, bItem, extra)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local UnknowPassOpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  if UnknowPassOpenUISystem.openFrom == 0 then
    return
  end
  local name = gem_report_utils.SubEventName_JumpBuyPass
  local tLogID = TLogEventDefine.JumpBuyPass
  local TLogReasonTable = {}
  if bPass then
    name = gem_report_utils.SubEventName_JumpBuyPass
    TLogReasonTable = {event_name = name, pass_type = extra}
  elseif bScore then
    name = gem_report_utils.SubEventName_JumpBuyPassScore
    tLogID = TLogEventDefine.JumpBuyPassScore
    TLogReasonTable = {event_name = name, score = extra}
  elseif bItem then
    name = gem_report_utils.SubEventName_JumpBuyPassItem
    tLogID = TLogEventDefine.JumpBuyPassItem
  end
  gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_JumpBuyEvent, name, extra)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local TLogReasonStr = json.encode(TLogReasonTable)
  tlog_report_utils.ReportTLogEvent(tLogID, 0, TLogReasonStr)
  log(bWriteLog and "TLog new format, UnknowPassBuySystem.ReportBuyEvent, reason : " .. tostring(0) .. " reasonStr : " .. tostring(TLogReasonStr))
end
function UnknowPassBuySystem.GetAskForItemID()
  local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassSystem.Season)
  if cfg then
    local ItemIdTable = {}
    ItemIdTable.NormalItemId = cfg.NormalItemId
    ItemIdTable.EliteItemId = cfg.EliteItemId
    return ItemIdTable
  end
end
local _tBuyTypeToMethodMap
local _BuildBuyTypeToMethodMap = function()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local tMap = {}
  local tMethodEnums = {
    {
      tEnum = UnknowPassMacro.ENUM_RP_BUY_TYPE_UC,
      nMethod = 1
    },
    {
      tEnum = UnknowPassMacro.ENUM_RP_BUY_TYPE_CARD,
      nMethod = 2
    },
    {
      tEnum = UnknowPassMacro.ENUM_RP_BUY_TYPE_CARD_UC,
      nMethod = 3
    }
  }
  for _, tItem in ipairs(tMethodEnums) do
    for _, nBuyType in pairs(tItem.tEnum) do
      tMap[nBuyType] = tItem.nMethod
    end
  end
  return tMap
end
local _GetPopupBuyMethod = function(tParams)
  if not _tBuyTypeToMethodMap then
    _tBuyTypeToMethodMap = _BuildBuyTypeToMethodMap()
  end
  local nMethod = _tBuyTypeToMethodMap[tParams.nRawBuyType]
  if not nMethod then
    log(bWriteLog and string.format("_GetPopupBuyMethod - Unknown nRawBuyType:%s", tostring(tParams.nRawBuyType)))
  end
  return nMethod
end
local _GetPureUCPrice = function(tParams)
  if tParams.bIsSuper then
    local nPrice = 0
    if UnknowPassBuySystem.Super_Pass_Info and UnknowPassBuySystem.Super_Pass_Info.discountPrice then
      nPrice = UnknowPassBuySystem.Super_Pass_Info.discountPrice
    end
    if UnknowPassSystem.CanExtraUpgrade then
      nPrice = UnknowPassBuySystem.GetExtraUpgradePrice(false)
    end
    return nPrice
  else
    if UnknowPassBuySystem.Normal_Pass_Info == nil then
      return nil
    end
    local nPrice = UnknowPassBuySystem.Normal_Pass_Info.discountPrice
    if tParams.nRawBuyType then
      local tBuyCfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(tParams.nRawBuyType)
      if tBuyCfg then
        nPrice = tBuyCfg.PriceDiscount1
      end
    end
    return nPrice
  end
end
local _GetCardBuyIdAndItemId = function(tParams, bByUC)
  local bIsNewUserPrivlegesCard = UnknowPassBuySystem.IsUseNewUserPrivlegesCard(tParams.nRawBuyType)
  local nBuyId, nItemId
  if tParams.bIsExperienceCard then
    nBuyId, nItemId = UnknowPassBuySystem.FindExperienceCardBuyId()
  elseif bIsNewUserPrivlegesCard then
    nBuyId, nItemId = UnknowPassBuySystem.FindNewUserPrivlegesBuyId(tParams.nRawBuyType)
  elseif bByUC then
    nBuyId, nItemId = UnknowPassBuySystem.FindBuyId(true, true, true, UnknowPassSystem.CanExtraUpgrade, tParams.nRawBuyType)
  else
    local bIsNormal = tParams.nHasCardType == 1
    if not tParams.bIsSuper then
      bIsNormal = true
    end
    nBuyId, nItemId = UnknowPassBuySystem.FindBuyId(false, bIsNormal, true, UnknowPassSystem.CanExtraUpgrade, tParams.nRawBuyType)
  end
  return nBuyId, nItemId
end
local _BuildCardConfirmTip = function(nItemId, tParams, nPrice)
  local sItemName = CDataTable.GetTableData("Item", nItemId).ItemName
  local sPassTypeName
  local bIsNewUserPrivlegesCard = UnknowPassBuySystem.IsUseNewUserPrivlegesCard(tParams.nRawBuyType)
  local ExperienceCardType = 45
  if tParams.bIsSuper then
    if tParams.bIsExperienceCardBuyNormal then
      sPassTypeName = LocUtil.LocalizeResFormat(4547)
    else
      sPassTypeName = tParams.nHasCardType == 1 and LocUtil.LocalizeResFormat("4547") or LocUtil.LocalizeResFormat("7275")
    end
  else
    sPassTypeName = LocUtil.LocalizeResFormat("4547")
  end
  local sTip
  if nPrice then
    sTip = LocUtil.LocalizeResFormat("7866", 1, sItemName, nPrice, sPassTypeName)
    if UnknowPassBuySystem.CheckInExtraTime() then
      sTip = LocUtil.LocalizeResFormat("27722", 1, sItemName, sPassTypeName)
    end
  else
    sTip = LocUtil.LocalizeResFormat("7865", 1, sItemName, sPassTypeName)
    if bIsNewUserPrivlegesCard and ExperienceCardType < tParams.nRawBuyType then
      local tBuyCfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(tParams.nRawBuyType)
      sTip = LocUtil.LocalizeResFormat("7866", 1, sItemName, tBuyCfg.PriceDiscount2, sPassTypeName)
    end
    if UnknowPassBuySystem.CheckInExtraTime() then
      sTip = LocUtil.LocalizeResFormat("27721", 1, sItemName, sPassTypeName)
      if bIsNewUserPrivlegesCard and ExperienceCardType < tParams.nRawBuyType then
        local tBuyCfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(tParams.nRawBuyType)
        sTip = LocUtil.LocalizeResFormat("27722", 1, sItemName, tBuyCfg.PriceDiscount2, sPassTypeName)
      end
    end
  end
  if UnknowPassSystem.IsBuyElite then
    if UnknowPassSystem.IsBuyEliteSeg2 then
      sTip = string.format([[
%s
%s]], LocUtil.GetLocalizeResStr(18130139), sTip)
    else
      sTip = string.format([[
%s
%s]], LocUtil.GetLocalizeResStr(18130138), sTip)
    end
  end
  return sTip
end
local _ReportBuyTLog = function(nFromType, sRpType, sFuncName)
  if not nFromType or nFromType <= 0 then
    return
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local TLogReasonTable = {
    event_name = "UnknowpassBuyFrom",
    rp_type = sRpType
  }
  local TLogReasonStr = json.encode(TLogReasonTable)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.UnknowpassBuyFrom, nFromType, TLogReasonStr)
  log(bWriteLog and "TLog new format, " .. sFuncName .. ", reason : " .. tostring(nFromType) .. " reasonStr : " .. tostring(TLogReasonStr))
end
local _BuildCouponExtraData = function(tParams, nPrice, sItemName, sPassTypeName)
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local extra_data = {}
  if sItemName and sPassTypeName then
    function extra_data.dynamicFunc()
      local couponUI = UIManager.GetUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass)
      if couponUI then
        local nNewPrice = nPrice - couponUI.voucherValue - CouponSystem.GetCouponValue(nPrice, tParams.nDisLevel)
        nNewPrice = nNewPrice < 0 and 0 or nNewPrice
        local sTipContent = LocUtil.LocalizeResFormat("7866", 1, sItemName, nNewPrice, sPassTypeName)
        if UnknowPassSystem.IsBuyElite and not UnknowPassSystem.IsBuyEliteSeg2 then
          sTipContent = string.format([[
%s
%s]], LocUtil.GetLocalizeResStr(18130138), sTipContent)
        end
        EventSystem:postEvent(EVENTTYPE_COUPON, EVENTID_COUPON_CHANGE_TEXT, sTipContent)
      end
    end
    extra_data.rawBuyType = tParams.nRawBuyType
  else
    function extra_data.dynamicFunc()
      local couponUI = UIManager.GetUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass)
      if couponUI then
        local nNewPrice = nPrice - couponUI.voucherValue - CouponSystem.GetCouponValue(nPrice, tParams.nDisLevel)
        nNewPrice = nNewPrice < 0 and 0 or nNewPrice
        local sTip = UnknowPassBuySystem.GetBuyPassString(tParams.bIsSuper, nNewPrice, tParams.nBuyType)
        EventSystem:postEvent(EVENTTYPE_COUPON, EVENTID_COUPON_CHANGE_TEXT, sTip)
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_UPDATE_COUPON_PRICE, nPrice, nNewPrice)
      end
    end
    extra_data.disLevel = tParams.nDisLevel
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  extra_data.except_map = PassDataSystem.GetBuyExceptCouponMap()
  return extra_data
end
local _HandlePureUCPopup = function(tParams)
  local nPrice = _GetPureUCPrice(tParams)
  if nPrice == nil then
    return
  end
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._UnknowPass
  local tExtraData = _BuildCouponExtraData(tParams, nPrice, nil, nil)
  local sBuyString = UnknowPassBuySystem.GetBuyPassString(tParams.bIsSuper, nPrice, tParams.nBuyType)
  local tShowCfg = {
    nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
    sTitle = LocUtil.GetLocalizeResStr("301185"),
    sTipContent = sBuyString,
    nMainScene = CouponSystem._Enum_Scene._UnknowPass,
    nChildScene = UnknowPassSystem.Season,
    nCurPrice = nPrice,
    fConfirmCallback = function(confirmData)
      if tParams.bIsSuper then
        if confirmData then
          UnknowPassBuySystem.ComfirmBuyPass(true, confirmData.nCurCouponId, confirmData.tVoucherList, tParams.nFromType, confirmData.nShowNewPrice, tParams.nRawBuyType, tParams.nBuyType)
        end
      else
        confirmData = confirmData or {}
        UnknowPassBuySystem.ComfirmBuyPass(false, confirmData.nCurCouponId, confirmData.tVoucherList, tParams.nFromType, confirmData.nShowNewPrice, tParams.nRawBuyType, tParams.nBuyType)
      end
    end,
      }
  if not tParams.bIsSuper and tParams.nBuyType == 3 then
    local bHasUpgradeCard = UnknowPassBuySystem.HasUpgradeCard(true)
    if bHasUpgradeCard then
      function tShowCfg.fCancelCallback()
        local jumpCtorData = {}
        local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
        ui_jump_manager.CloseJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS_SEG1)
        ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_BUY_UNKNOW_PASS, jumpCtorData)
      end
      tShowCfg.sCancelBtnText = LocUtil.GetLocalizeResStr(50038)
      tShowCfg.bIsCloseNotExcuteCancelCallback = true
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass, tShowCfg)
end
local _HandleCardDirectPopup = function(tParams)
  local nBuyId, nItemId = _GetCardBuyIdAndItemId(tParams, false)
  log(bWriteLog and "HandleBuyPopup._HandleCardDirectPopup buyId:" .. tostring(nBuyId) .. " itemId:" .. tostring(nItemId))
  local bIsNewUserPrivlegesCard = UnknowPassBuySystem.IsUseNewUserPrivlegesCard(tParams.nRawBuyType)
  local ExperienceCardType = 45
  local nPrice
  if bIsNewUserPrivlegesCard and ExperienceCardType < tParams.nRawBuyType then
    local tBuyCfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(tParams.nRawBuyType)
    if tBuyCfg then
      nPrice = tBuyCfg.PriceDiscount2
    end
  end
  local sItemName = CDataTable.GetTableData("Item", nItemId).ItemName
  local sTip = _BuildCardConfirmTip(nItemId, tParams, nil)
  local sTitle = LocUtil.GetLocalizeResStr("101001")
  local sRpType = tParams.bIsSuper and (tParams.nHasCardType ~= 1 and "super" or "normal") or "normal"
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._UnknowPass
  local tExtraData = {}
  if nPrice and 0 < nPrice then
    local sPassTypeName
    if tParams.bIsSuper then
      sPassTypeName = tParams.nHasCardType == 1 and LocUtil.LocalizeResFormat("4547") or LocUtil.LocalizeResFormat("7275")
    else
      sPassTypeName = LocUtil.LocalizeResFormat("4547")
    end
    tExtraData = _BuildCouponExtraData(tParams, nPrice, sItemName, sPassTypeName)
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  tExtraData.except_map = PassDataSystem.GetBuyExceptCouponMap()
  local tShowCfg = {
    nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
    sTitle = sTitle,
    sTipContent = sTip,
    nMainScene = CouponSystem._Enum_Scene._UnknowPass,
    nChildScene = UnknowPassSystem.Season,
    nCurPrice = nPrice,
    bIsHideUCCurrency = not nPrice,
    bIsForbidUseCoupon = not nPrice,
    fConfirmCallback = function(confirmData)
      local nSeason = UnknowPassSystem.Season
      local tCfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", nSeason)
      if tCfg == nil then
        return
      end
      _ReportBuyTLog(tParams.nFromType, sRpType, "HandleBuyPopup._HandleCardDirectPopup")
      local tVoucherList = confirmData and confirmData.tVoucherList or nil
      local nShowNewPrice = confirmData and confirmData.nShowNewPrice or nil
      UnknowPassBuySystem.upass_buy_pass_req(nBuyId, tVoucherList, nShowNewPrice, tParams.nFromType)
      return true
    end,
      }
  UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass, tShowCfg)
end
local _HandleCardPlusUCPopup = function(tParams)
  local nBuyId, nItemId = _GetCardBuyIdAndItemId(tParams, true)
  log(bWriteLog and "HandleBuyPopup._HandleCardPlusUCPopup buyId:" .. tostring(nBuyId) .. " itemId:" .. tostring(nItemId))
  local nPrice = 1200
  local tBuyCfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(tParams.nRawBuyType)
  if tBuyCfg then
    nPrice = tBuyCfg.PriceDiscount2
  end
  local sItemName = CDataTable.GetTableData("Item", nItemId).ItemName
  local sPassTypeName = LocUtil.LocalizeResFormat("7275")
  if tParams.bIsExperienceCardBuyNormal then
    sPassTypeName = LocUtil.LocalizeResFormat(4547)
  end
  local sTip = _BuildCardConfirmTip(nItemId, tParams, nPrice)
  local sTitle = LocUtil.GetLocalizeResStr("101001")
  local sRpType = "super"
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._UnknowPass
  local tExtraData = _BuildCouponExtraData(tParams, nPrice, sItemName, sPassTypeName)
  local tShowCfg = {
    nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
    sTitle = sTitle,
    sTipContent = sTip,
    nMainScene = CouponSystem._Enum_Scene._UnknowPass,
    nChildScene = UnknowPassSystem.Season,
    nCurPrice = nPrice,
    fConfirmCallback = function(confirmData)
      local nSeason = UnknowPassSystem.Season
      local tCfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", nSeason)
      if tCfg == nil then
        return
      end
      _ReportBuyTLog(tParams.nFromType, sRpType, "HandleBuyPopup._HandleCardPlusUCPopup")
      UnknowPassBuySystem.upass_buy_pass_req(nBuyId, confirmData.tVoucherList, confirmData.nShowNewPrice, tParams.nFromType)
      return true
    end,
      }
  UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass, tShowCfg)
end
function UnknowPassBuySystem.HandleBuyPopup(tParams)
  if not tParams then
    log(bWriteLog and "UnknowPassBuySystem.HandleBuyPopup - Invalid params")
    return
  end
  log(bWriteLog and string.format("UnknowPassBuySystem.HandleBuyPopup - bIsSuper:%s nHasCardType:%s nRawBuyType:%s nBuyType:%s", tostring(tParams.bIsSuper), tostring(tParams.nHasCardType), tostring(tParams.nRawBuyType), tostring(tParams.nBuyType)))
  local nMethod = _GetPopupBuyMethod(tParams)
  if nMethod == 1 then
    _HandlePureUCPopup(tParams)
  elseif nMethod == 2 then
    _HandleCardDirectPopup(tParams)
  elseif nMethod == 3 then
    tParams.bIsSuper = false
    _HandleCardPlusUCPopup(tParams)
  end
end
return UnknowPassBuySystem