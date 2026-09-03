local Logic_BonusPass_Buy = {}
local Enum_RP_TYPE = {Normal = 1, Plus = 2}
function Logic_BonusPass_Buy:DefineAndResetData()
  self.bOpenBuyUI = false
  self.tExNorReward = nil
  self.tExMulReward = nil
  self.tBindRPReward = {}
  self.nCurSeason = nil
  self.tRpRewardInfo = nil
  self.bNotPopup = false
  self.bIsLoadBPScene = false
  self.nLevel1To30BPCard = nil
  self.nLevel31To60BPCard = nil
  self.nLevel1To60BPCard = nil
  self.nCurSeasonID = nil
end
function Logic_BonusPass_Buy:OnPostSwitchGameStatus(preState, nextState)
  self:AddTimerOnce(3, function()
    self:InitBPUpgradeCardConfig()
  end)
end
function Logic_BonusPass_Buy:InitBPUpgradeCardConfig()
  local bIsHadInitBPUpgradeCardConfig = self:IsHadInitBPUpgradeCardConfig()
  if bIsHadInitBPUpgradeCardConfig and self.nCurSeasonID and self.nCurSeasonID == UnknowPassSystem.Season then
    return
  end
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  self.nCurSeasonID = UnknowPassSystem.Season
  local ENUM_BP_BUY_TYPE = Logic_BonusPass_Const_Config.ENUM_BP_BUY_TYPE
  local tBonusPassBuyCfg = CDataTable.GetTableByFilter("BonusPassBuyCfg", "SeasonID", UnknowPassSystem.Season)
  for _, v in pairs(tBonusPassBuyCfg) do
    if v.BuyType == ENUM_BP_BUY_TYPE.BuyType10 then
      self.nLevel1To30BPCard = v.BuyItem1Id
    elseif v.BuyType == ENUM_BP_BUY_TYPE.BuyType11 then
      self.nLevel1To60BPCard = v.BuyItem1Id
    elseif v.BuyType == ENUM_BP_BUY_TYPE.BuyType12 then
      self.nLevel31To60BPCard = v.BuyItem1Id
    end
  end
end
function Logic_BonusPass_Buy:IsHadInitBPUpgradeCardConfig()
  return self.nLevel1To30BPCard and self.nLevel1To60BPCard and self.nLevel31To60BPCard
end
function Logic_BonusPass_Buy:GetBuyId(buyType, couponid)
  local buyID
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  local rawBuyType = buyType == Enum_RP_TYPE.Normal and 2 or 3
  local raw_buy_cfg = UnknowPassBuySystem.GetBuyConfigViaBuyType(rawBuyType)
  if not raw_buy_cfg then
    return
  end
  if buyType == Enum_RP_TYPE.Plus then
    if couponid and couponid ~= 0 then
      buyID = UnknowPassBuySystem.GetBuyIdByCouponID(couponid, 2, raw_buy_cfg)
    else
      buyID = UnknowPassBuySystem.Super_Pass_Info and UnknowPassBuySystem.Super_Pass_Info.id
    end
  elseif couponid and couponid ~= 0 then
    buyID = UnknowPassBuySystem.GetBuyIdByCouponID(couponid, 1, raw_buy_cfg)
  else
    buyID = tonumber(raw_buy_cfg.ID)
  end
  return buyID
end
function Logic_BonusPass_Buy:SetIsNotPopup(bNotPopup)
  self.end
function Logic_BonusPass_Buy:GetIsNotPopup()
  return self.bNotPopup
end
function Logic_BonusPass_Buy:BuyBonusPassExperienceNew(nCurBuyExperType)
  local tBonusPassBuyCfg = self:GetBuyPriceCfgByBuyType(nCurBuyExperType)
  if not tBonusPassBuyCfg then
    log(bWriteLog and "Logic_BonusPass_Buy:BuyBonusPassExperienceNew tBonusPassBuyCfg is nil" .. tostring(nCurBuyExperType))
    return
  end
  local tFullBuyPriceTypeInfo = self:GetFullBuyPriceTypeInfo(tBonusPassBuyCfg.BuyItem1Id, tBonusPassBuyCfg.BuyItem2Id, tBonusPassBuyCfg.BuyItem3Id, tBonusPassBuyCfg.BuyItem4Id)
  local nUCPriceIndex = 0
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_FULL_BP_PRICE_TYPE = Logic_BonusPass_Const_Config.ENUM_FULL_BP_PRICE_TYPE
  for i = 1, 4 do
    if tFullBuyPriceTypeInfo[i] == ENUM_FULL_BP_PRICE_TYPE.UC then
      nUCPriceIndex = i
      break
    end
  end
  local nCurrency1ItemId, nCurrency1Num
  local nCurrentPrice = tBonusPassBuyCfg["BuyCurPrice" .. nUCPriceIndex] or 0
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local buyString = ""
  if 0 < nUCPriceIndex then
    buyString = LocUtil.LocalizeResFormat(69944, nCurrentPrice)
  else
    nCurrency1ItemId = tBonusPassBuyCfg.BuyItem1Id or 0
    nCurrency1Num = tBonusPassBuyCfg.BuyCurPrice1 or 0
    local tItemCfg = CDataTable.GetTableData("Item", nCurrency1ItemId)
    buyString = LocUtil.LocalizeResFormat(18130143, 1, tItemCfg.ItemName)
  end
  local tShowCfg = {
    nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
    sTitle = LocUtil.GetLocalizeResStr(301185),
    sTipContent = buyString,
    nCurPrice = nCurrentPrice,
    nCurrency1ItemId = nCurrency1ItemId,
    nCurrency1Num = nCurrency1Num,
    bIsHideUCCurrency = nCurrentPrice == 0,
    fConfirmCallback = function()
      local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
      UpassBranchHandler.send_rp_branch_common_buy_req(tBonusPassBuyCfg.BuyID, {})
      UIManager.CloseUI(UIManager.UI_Config.UnknowPass_NewBranchBuy_UIBP)
      self:SetBuyUIIsOpen(false)
    end,
    fNotEnoughCallback = function()
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(nCurrentPrice)
    end
  }
  UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_General, tShowCfg)
end
function Logic_BonusPass_Buy:BuyBonusPassFullNew(nCurBuyFullType)
  local tBonusPassBuyCfg = self:GetBuyPriceCfgByBuyType(nCurBuyFullType)
  if not tBonusPassBuyCfg then
    log(bWriteLog and "Logic_BonusPass_Buy:BuyBonusPassFullNew. Invalid buy type: " .. tostring(nCurBuyFullType))
    return
  end
  local tPriceData = self:_GetBPFullPriceData(tBonusPassBuyCfg)
  if not tPriceData then
    log(bWriteLog and "Logic_BonusPass_Buy:BuyBonusPassFullNew. Failed to get price data")
    return
  end
  local buyString = self:_GenerateBPFullBuyString(tPriceData, tBonusPassBuyCfg)
  if not buyString or buyString == "" then
    log(bWriteLog and "Logic_BonusPass_Buy:BuyBonusPassFullNew. Failed to generate buy string")
    return
  end
  self:_ShowBPFullBuyPopup(tPriceData, buyString, tBonusPassBuyCfg)
end
function Logic_BonusPass_Buy:_GetBPFullPriceData(tBonusPassBuyCfg)
  local tFullBuyPriceTypeInfo = self:GetFullBuyPriceTypeInfo(tBonusPassBuyCfg.BuyItem1Id, tBonusPassBuyCfg.BuyItem2Id, tBonusPassBuyCfg.BuyItem3Id, tBonusPassBuyCfg.BuyItem4Id)
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_FULL_BP_PRICE_TYPE = Logic_BonusPass_Const_Config.ENUM_FULL_BP_PRICE_TYPE
  local nUCPriceIndex = 0
  for i = 1, 4 do
    if tFullBuyPriceTypeInfo[i] == ENUM_FULL_BP_PRICE_TYPE.UC then
      nUCPriceIndex = i
      break
    end
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  local bIsBuyExperienceBP = Logic_BonusPass:IsUnlockExperienceBP()
  return {
    nUCPriceIndex = nUCPriceIndex,
    nCurrentPrice = tBonusPassBuyCfg["BuyCurPrice" .. nUCPriceIndex] or 0,
    nCurrency1ItemId = tBonusPassBuyCfg.BuyItem1Id or 0,
    nCurrency1Num = tBonusPassBuyCfg.BuyCurPrice1 or 0,
    nCurrency2ItemId = tBonusPassBuyCfg.BuyItem2Id or 0,
    nCurrency2Num = tBonusPassBuyCfg.BuyCurPrice2 or 0,
    bIsBuyExperienceBP = bIsBuyExperienceBP,
    bHasUCPrice = 0 < nUCPriceIndex
  }
end
function Logic_BonusPass_Buy:_GenerateBPFullBuyString(tPriceData, tBonusPassBuyCfg)
  local buyString = ""
  if tPriceData.bHasUCPrice then
    if tPriceData.bIsBuyExperienceBP then
      buyString = LocUtil.LocalizeResFormat(69945, tPriceData.nCurrentPrice)
    else
      buyString = self:_GenerateUCWithCardBuyString(tPriceData)
    end
  else
    buyString = self:_GenerateCardOnlyBuyString(tPriceData, tBonusPassBuyCfg)
  end
  return buyString
end
function Logic_BonusPass_Buy:_GenerateUCWithCardBuyString(tPriceData)
  local nUCPriceIndex = tPriceData.nUCPriceIndex
  local nCurrency1ItemId = tPriceData.nCurrency1ItemId
  local nCurrency1Num = tPriceData.nCurrency1Num
  local nCurrency2ItemId = tPriceData.nCurrency2ItemId
  local nCurrency2Num = tPriceData.nCurrency2Num
  local bHasUpgradeCard = false
  local nUpgradeCardItemId = 0
  local nUpgradeCardNum = 0
  local nUCPrice = 0
  if nUCPriceIndex == 1 then
    nUCPrice = nCurrency1Num
    if 0 < nCurrency2ItemId then
      bHasUpgradeCard = true
      nUpgradeCardItemId = nCurrency2ItemId
      nUpgradeCardNum = nCurrency2Num
    end
  elseif nUCPriceIndex == 2 then
    nUCPrice = nCurrency2Num
    if 0 < nCurrency1ItemId then
      bHasUpgradeCard = true
      nUpgradeCardItemId = nCurrency1ItemId
      nUpgradeCardNum = nCurrency1Num
    end
  elseif nUCPriceIndex == 3 then
    nUCPrice = tPriceData.nCurrency3Num or 0
    if 0 < nCurrency1ItemId then
      bHasUpgradeCard = true
      nUpgradeCardItemId = nCurrency1ItemId
      nUpgradeCardNum = nCurrency1Num
    elseif 0 < nCurrency2ItemId then
      bHasUpgradeCard = true
      nUpgradeCardItemId = nCurrency2ItemId
      nUpgradeCardNum = nCurrency2Num
    end
  end
  if bHasUpgradeCard then
    local tItemCfg = CDataTable.GetTableData("Item", nUpgradeCardItemId)
    return LocUtil.LocalizeResFormat(18130145, nUpgradeCardNum, tItemCfg.ItemName, nUCPrice)
  else
    return LocUtil.LocalizeResFormat(69945, nUCPrice)
  end
end
function Logic_BonusPass_Buy:_GenerateCardOnlyBuyString(tPriceData, tBonusPassBuyCfg)
  local nCurrency1ItemId = tPriceData.nCurrency1ItemId
  local nCurrency1Num = tPriceData.nCurrency1Num
  local nCurrency2ItemId = tPriceData.nCurrency2ItemId
  local nCurrency2Num = tPriceData.nCurrency2Num
  local bIsBuyExperienceBP = tPriceData.bIsBuyExperienceBP
  if bIsBuyExperienceBP then
    if nCurrency1ItemId == self.nLevel31To60BPCard then
      local tItemCfg = CDataTable.GetTableData("Item", nCurrency1ItemId)
      return LocUtil.LocalizeResFormat(18130148, 1, tItemCfg.ItemName)
    elseif nCurrency1ItemId == self.nLevel1To60BPCard then
      local tItemCfg = CDataTable.GetTableData("Item", nCurrency1ItemId)
      return LocUtil.LocalizeResFormat(18130147, tBonusPassBuyCfg.ReturnItem1Num, nCurrency1Num, tItemCfg.ItemName)
    end
  else
    local tItemCfg1 = CDataTable.GetTableData("Item", nCurrency1ItemId)
    if 0 < nCurrency2ItemId then
      local tItemCfg2 = CDataTable.GetTableData("Item", nCurrency2ItemId)
      return LocUtil.LocalizeResFormat(18130146, nCurrency1Num, tItemCfg1.ItemName, nCurrency2Num, tItemCfg2.ItemName)
    else
      return LocUtil.LocalizeResFormat(18130144, nCurrency1Num, tItemCfg1.ItemName)
    end
  end
  return ""
end
function Logic_BonusPass_Buy:_ShowBPFullBuyPopup(tPriceData, buyString, tBonusPassBuyCfg)
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local nGradeCardItemId1, nGradeCardNum1, nGradeCardItemId2, nGradeCardNum2 = self:_GetGradeCardInfo(tPriceData)
  local tShowCfg = {
    nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
    sTitle = LocUtil.GetLocalizeResStr(301185),
    sTipContent = buyString,
    nCurPrice = tPriceData.nCurrentPrice,
    nCurrency1ItemId = nGradeCardItemId1,
    nCurrency1Num = nGradeCardNum1,
    nCurrency3ItemId = nGradeCardItemId2,
    nCurrency3Num = nGradeCardNum2,
    bIsHideUCCurrency = tPriceData.nCurrentPrice == 0,
    fConfirmCallback = function()
      local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
      UpassBranchHandler.send_rp_branch_common_buy_req(tBonusPassBuyCfg.BuyID, {})
      UIManager.CloseUI(UIManager.UI_Config.UnknowPass_NewBranchBuy_UIBP)
      self:SetBuyUIIsOpen(false)
    end,
    fNotEnoughCallback = function()
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(tPriceData.nCurrentPrice)
    end
  }
  UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_General, tShowCfg)
end
function Logic_BonusPass_Buy:_GetGradeCardInfo(tPriceData)
  if tPriceData.bHasUCPrice then
    if tPriceData.nUCPriceIndex == 1 then
      return tPriceData.nCurrency2ItemId, tPriceData.nCurrency2Num
    elseif tPriceData.nUCPriceIndex == 2 then
      return tPriceData.nCurrency1ItemId, tPriceData.nCurrency1Num
    end
  else
    return tPriceData.nCurrency1ItemId, tPriceData.nCurrency1Num, tPriceData.nCurrency2ItemId, tPriceData.nCurrency2Num
  end
end
function Logic_BonusPass_Buy:BuyBonusPassCombinationNew(nCurComposeBuyType, nCurRPGrade)
  local tBonusPassBuyCfg = self:GetBuyPriceCfgByBuyType(nCurComposeBuyType)
  if not tBonusPassBuyCfg then
    log(bWriteLog and "Logic_BonusPass_Buy:BuyBonusPassCombinationNew. Invalid buy type: " .. tostring(nCurComposeBuyType))
    return
  end
  local tCombinationData = self:_GetCombinationBuyData(tBonusPassBuyCfg)
  if not tCombinationData then
    log(bWriteLog and "Logic_BonusPass_Buy:BuyBonusPassCombinationNew. Failed to get combination data")
    return
  end
  local buyString = self:_GenerateCombinationBuyString(tCombinationData, tBonusPassBuyCfg, nCurRPGrade)
  if not buyString or buyString == "" then
    log(bWriteLog and "Logic_BonusPass_Buy:BuyBonusPassCombinationNew. Failed to generate buy string")
    return
  end
  self:_ShowCombinationBuyPopup(tCombinationData, buyString, tBonusPassBuyCfg, nCurRPGrade)
end
function Logic_BonusPass_Buy:_GetCombinationBuyData(tBonusPassBuyCfg)
  local tFullBuyPriceTypeInfo = self:GetFullBuyPriceTypeInfo(tBonusPassBuyCfg.BuyItem1Id, tBonusPassBuyCfg.BuyItem2Id, tBonusPassBuyCfg.BuyItem3Id, tBonusPassBuyCfg.BuyItem4Id)
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_FULL_BP_PRICE_TYPE = Logic_BonusPass_Const_Config.ENUM_FULL_BP_PRICE_TYPE
  local nUCPriceIndex = 0
  for i = 1, 4 do
    if tFullBuyPriceTypeInfo[i] == ENUM_FULL_BP_PRICE_TYPE.UC then
      nUCPriceIndex = i
      break
    end
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  local bIsBuyExperienceBP = Logic_BonusPass:IsUnlockExperienceBP()
  return {
    nUCPriceIndex = nUCPriceIndex,
    nCurrentPrice = tBonusPassBuyCfg["BuyCurPrice" .. nUCPriceIndex] or 0,
    nCurrency1ItemId = tBonusPassBuyCfg.BuyItem1Id or 0,
    nCurrency1Num = tBonusPassBuyCfg.BuyCurPrice1 or 0,
    nCurrency2ItemId = tBonusPassBuyCfg.BuyItem2Id or 0,
    nCurrency2Num = tBonusPassBuyCfg.BuyCurPrice2 or 0,
    nCurrency3ItemId = tBonusPassBuyCfg.BuyItem3Id or 0,
    nCurrency3Num = tBonusPassBuyCfg.BuyCurPrice3 or 0,
    nCurrency4ItemId = tBonusPassBuyCfg.BuyItem4Id or 0,
    nCurrency4Num = tBonusPassBuyCfg.BuyCurPrice4 or 0,
    bIsBuyExperienceBP = bIsBuyExperienceBP,
    bHasUCPrice = 0 < nUCPriceIndex
  }
end
function Logic_BonusPass_Buy:_GenerateCombinationBuyString(tData, tBonusPassBuyCfg, nCurRPGrade)
  if tData.bHasUCPrice then
    return self:_GenerateUCCombinationString(tData, tBonusPassBuyCfg, nCurRPGrade)
  else
    return self:_GenerateCardOnlyCombinationString(tData, tBonusPassBuyCfg, nCurRPGrade)
  end
end
function Logic_BonusPass_Buy:_GenerateUCCombinationString(tData, tBonusPassBuyCfg, nCurRPGrade)
  local nUCPriceIndex = tData.nUCPriceIndex
  local bIsBuyExperienceBP = tData.bIsBuyExperienceBP
  local tNonUCItems = self:_GetNonUCItems(tData, nUCPriceIndex)
  local nUCPrice = self:_GetUCPrice(tData, nUCPriceIndex)
  if bIsBuyExperienceBP then
    return self:_GenerateExperienceBPUCString(tNonUCItems, nUCPrice, tBonusPassBuyCfg, nCurRPGrade)
  else
    return self:_GenerateNormalUCString(tNonUCItems, nUCPrice, nCurRPGrade)
  end
end
function Logic_BonusPass_Buy:_GenerateCardOnlyCombinationString(tData, tBonusPassBuyCfg, nCurRPGrade)
  local nCurrency1ItemId = tData.nCurrency1ItemId
  local nCurrency1Num = tData.nCurrency1Num
  local nCurrency2ItemId = tData.nCurrency2ItemId
  local nCurrency2Num = tData.nCurrency2Num
  local bIsBuyExperienceBP = tData.bIsBuyExperienceBP
  local tItemCfg1 = CDataTable.GetTableData("Item", nCurrency1ItemId)
  local tItemCfg2 = CDataTable.GetTableData("Item", nCurrency2ItemId)
  if bIsBuyExperienceBP then
    if nCurrency1ItemId == self.nLevel31To60BPCard or nCurrency2ItemId == self.nLevel31To60BPCard then
      local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18130157 or 18140103
      return LocUtil.LocalizeResFormat(key, nCurrency1Num, tItemCfg1.ItemName, nCurrency2Num, tItemCfg2.ItemName)
    elseif nCurrency1ItemId == self.nLevel1To60BPCard or nCurrency2ItemId == self.nLevel1To60BPCard then
      local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18130156 or 18140102
      return LocUtil.LocalizeResFormat(key, tBonusPassBuyCfg.ReturnItem1Num, nCurrency1Num, tItemCfg1.ItemName, nCurrency2Num, tItemCfg2.ItemName)
    end
  else
    local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18130155 or 18140101
    return LocUtil.LocalizeResFormat(key, nCurrency1Num, tItemCfg1.ItemName, nCurrency2Num, tItemCfg2.ItemName)
  end
  return ""
end
function Logic_BonusPass_Buy:_GetNonUCItems(tData, nUCPriceIndex)
  local tItems = {}
  for i = 1, 4 do
    if i ~= nUCPriceIndex then
      local nItemId = tData["nCurrency" .. i .. "ItemId"]
      local nItemNum = tData["nCurrency" .. i .. "Num"]
      if 0 < nItemId then
        table.insert(tItems, {
          nItemId = nItemId,
          nItemNum = nItemNum,
          tItemCfg = CDataTable.GetTableData("Item", nItemId)
        })
      end
    end
  end
  return tItems
end
function Logic_BonusPass_Buy:_GetUCPrice(tData, nUCPriceIndex)
  return tData["nCurrency" .. nUCPriceIndex .. "Num"] or 0
end
function Logic_BonusPass_Buy:_GenerateExperienceBPUCString(tNonUCItems, nUCPrice, tBonusPassBuyCfg, nCurRPGrade)
  if #tNonUCItems == 0 then
    local key = nCurRPGrade == Enum_RP_TYPE.Normal and 69946 or 71113
    return LocUtil.LocalizeResFormat(key, nUCPrice)
  elseif #tNonUCItems == 1 then
    local tItem = tNonUCItems[1]
    if tItem.nItemId == self.nLevel1To60BPCard then
      local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18130151 or 18140097
      return LocUtil.LocalizeResFormat(key, tBonusPassBuyCfg.ReturnItem1Num, tItem.nItemNum, tItem.tItemCfg.ItemName, nUCPrice)
    else
      local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18130153 or 18140099
      return LocUtil.LocalizeResFormat(key, tItem.nItemNum, tItem.tItemCfg.ItemName, nUCPrice)
    end
  elseif #tNonUCItems == 2 then
    local tItem1, tItem2 = tNonUCItems[1], tNonUCItems[2]
    if tItem1.nItemId == self.nLevel1To60BPCard or tItem2.nItemId == self.nLevel1To60BPCard then
      local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18130152 or 18140098
      return LocUtil.LocalizeResFormat(key, tBonusPassBuyCfg.ReturnItem1Num, tItem1.nItemNum, tItem1.tItemCfg.ItemName, tItem2.nItemNum, tItem2.tItemCfg.ItemName, nUCPrice)
    else
      local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18130154 or 18140100
      return LocUtil.LocalizeResFormat(key, tItem1.nItemNum, tItem1.tItemCfg.ItemName, tItem2.nItemNum, tItem2.tItemCfg.ItemName, nUCPrice)
    end
  end
  return ""
end
function Logic_BonusPass_Buy:_GenerateNormalUCString(tNonUCItems, nUCPrice, nCurRPGrade)
  if #tNonUCItems == 0 then
    local key = nCurRPGrade == Enum_RP_TYPE.Normal and 69946 or 71113
    return LocUtil.LocalizeResFormat(key, nUCPrice)
  elseif #tNonUCItems == 1 then
    local tItem = tNonUCItems[1]
    local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18130149 or 18140095
    return LocUtil.LocalizeResFormat(key, tItem.nItemNum, tItem.tItemCfg.ItemName, nUCPrice)
  elseif #tNonUCItems == 2 then
    local tItem1, tItem2 = tNonUCItems[1], tNonUCItems[2]
    local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18130150 or 18140096
    return LocUtil.LocalizeResFormat(key, tItem1.nItemNum, tItem1.tItemCfg.ItemName, tItem2.nItemNum, tItem2.tItemCfg.ItemName, nUCPrice)
  elseif #tNonUCItems == 3 then
    local tItem1, tItem2, tItem3 = tNonUCItems[1], tNonUCItems[2], tNonUCItems[3]
    local key = nCurRPGrade == Enum_RP_TYPE.Normal and 18140113 or 18140115
    return LocUtil.LocalizeResFormat(key, tItem1.nItemNum, tItem1.tItemCfg.ItemName, tItem2.nItemNum, tItem2.tItemCfg.ItemName, tItem3.nItemNum, tItem3.tItemCfg.ItemName, nUCPrice)
  end
  return ""
end
function Logic_BonusPass_Buy:_ShowCombinationBuyPopup(tData, buyString, tBonusPassBuyCfg, nCurRPGrade)
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local nGradeCardItemId1, nGradeCardNum1, nGradeCardItemId2, nGradeCardNum2, nGradeCardItemId3, nGradeCardNum3 = self:_GetCombinationGradeCardInfo(tData)
  local extra_data = {}
  function extra_data.dynamicFunc()
    local couponUI = UIManager.GetUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass)
    if couponUI then
      local newprice = tData.nCurrentPrice - couponUI.voucherValue - CouponSystem.GetCouponValue(tData.nCurrentPrice)
      newprice = newprice < 0 and 0 or newprice
      local nUCPriceIndex = tData.nUCPriceIndex
      local bIsBuyExperienceBP = tData.bIsBuyExperienceBP
      local tNonUCItems = self:_GetNonUCItems(tData, nUCPriceIndex)
      if bIsBuyExperienceBP then
        buyString = self:_GenerateExperienceBPUCString(tNonUCItems, newprice, tBonusPassBuyCfg, nCurRPGrade)
      else
        buyString = self:_GenerateNormalUCString(tNonUCItems, newprice, nCurRPGrade)
      end
      EventSystem:postEvent(EVENTTYPE_COUPON, EVENTID_COUPON_CHANGE_TEXT, buyString, true)
    end
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  extra_data.except_map = PassDataSystem.GetBuyExceptCouponMap()
  local tShowCfg = {
    nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
    sTitle = LocUtil.GetLocalizeResStr(301185),
    sTipContent = buyString,
    nMainScene = CouponSystem._Enum_Scene._UnknowPass,
    nChildScene = UnknowPassSystem.Season,
    nCurPrice = tData.nCurrentPrice,
    nCurrency1ItemId = nGradeCardItemId1,
    nCurrency1Num = nGradeCardNum1,
    nCurrency3ItemId = nGradeCardItemId2,
    nCurrency3Num = nGradeCardNum2,
    nCurrency4ItemId = nGradeCardItemId3,
    nCurrency4Num = nGradeCardNum3,
    bIsForbidUseCoupon = tBonusPassBuyCfg.UseCoupon == 0,
    bIsHideUCCurrency = tData.nCurrentPrice == 0,
    fConfirmCallback = function(confirmData)
      confirmData = confirmData or {}
      if (not confirmData.tVoucherList or #confirmData.tVoucherList == 0) and confirmData.nCurCouponId and 0 < confirmData.nCurCouponId then
        confirmData.tVoucherList[confirmData.nCurCouponId] = 1
      end
      local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
      UpassBranchHandler.send_rp_branch_common_buy_req(tBonusPassBuyCfg.BuyID, confirmData.tVoucherList or {})
      self:SetIsNotPopup(true)
      UIManager.CloseUI(UIManager.UI_Config.UnknowPass_NewBranchBuy_UIBP)
      self:SetBuyUIIsOpen(false)
    end,
    fNotEnoughCallback = function()
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(tData.nCurrentPrice)
    end,
    tExtraData = extra_data
  }
  UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_UnknowPass, tShowCfg)
end
function Logic_BonusPass_Buy:_GetCombinationGradeCardInfo(tData)
  local nUCPriceIndex = tData.nUCPriceIndex
  if tData.bHasUCPrice then
    if nUCPriceIndex == 1 then
      return tData.nCurrency2ItemId, tData.nCurrency2Num, tData.nCurrency3ItemId, tData.nCurrency3Num, tData.nCurrency4ItemId, tData.nCurrency4Num
    elseif nUCPriceIndex == 2 then
      return tData.nCurrency1ItemId, tData.nCurrency1Num, tData.nCurrency3ItemId, tData.nCurrency3Num, tData.nCurrency4ItemId, tData.nCurrency4Num
    elseif nUCPriceIndex == 3 then
      return tData.nCurrency1ItemId, tData.nCurrency1Num, tData.nCurrency2ItemId, tData.nCurrency2Num, tData.nCurrency4ItemId, tData.nCurrency4Num
    elseif nUCPriceIndex == 4 then
      return tData.nCurrency1ItemId, tData.nCurrency1Num, tData.nCurrency2ItemId, tData.nCurrency2Num, tData.nCurrency3ItemId, tData.nCurrency3Num
    end
  else
    return tData.nCurrency1ItemId, tData.nCurrency1Num, tData.nCurrency2ItemId, tData.nCurrency2Num, tData.nCurrency3ItemId, tData.nCurrency3Num
  end
  return 0, 0, 0, 0
end
function Logic_BonusPass_Buy:HandBuyBpRsp()
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  if not UIManager.IsUIShow(UIManager.UI_Config.UnknowPass_Award_Branch_BP) then
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    if UIManager.IsUIShow(UIManager.UI_Config.UnknowPass_BranchRP_RewardsPreview_UIBP) then
      UIManager.CloseUI(UIManager.UI_Config.UnknowPass_BranchRP_RewardsPreview_UIBP)
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_TAB)
    end
    PassDataSystem.TurnToBPAwardPanel()
  end
  Logic_BonusPass:SetIsShowUnlockUp(true)
  Logic_BonusPass:send_rp_branch_player_data_req()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_SHOW_AVATAR, true)
end
function Logic_BonusPass_Buy:on_rp_branch_common_buy_rsp(err_code, RPBranchCommonBuyClientSync)
  self:HandBuyBpRsp()
  if RPBranchCommonBuyClientSync and RPBranchCommonBuyClientSync.rp_buy then
    self.tRpRewardInfo = {
      err_code = err_code,
      awards = RPBranchCommonBuyClientSync.rp_buy.show_awards,
      score = RPBranchCommonBuyClientSync.rp_buy.upass_score,
      level = RPBranchCommonBuyClientSync.rp_buy.upass_level,
      before_level = RPBranchCommonBuyClientSync.rp_buy.before_level,
      experience_level = RPBranchCommonBuyClientSync.rp_buy.experience_level,
      refund_infos = RPBranchCommonBuyClientSync.rp_buy.refund_infos,
      continuous_buy = RPBranchCommonBuyClientSync.rp_buy.ret_cont_buy
    }
  end
end
function Logic_BonusPass_Buy:GetRpRewrdInfo()
  return self.tRpRewardInfo
end
function Logic_BonusPass_Buy:ClearRpRewardInfo()
  self.tRpRewardInfo = nil
end
function Logic_BonusPass_Buy:OpenBPBuyPopup()
  self:SetBuyUIIsOpen(true)
  self:ShowBPBuyPopup()
end
function Logic_BonusPass_Buy:ShowBPBuyPopup()
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local ver = UnknowPassUtil.GetVersionNumber()
  local bpKeyName = "UnknowPass_NewBranchBuy_UIBP"
  local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
  UpassBranchHandler.send_unknown_pass_type_req()
  if UnknowPassSystem.IsBuyElite then
    bpKeyName = "UnknowPass_NewBranchSingleBuy_UIBP"
  end
  local bpPath = string.format("/Game/Arts_UI/UnknowPass/%s/RP_BranchBuy/%s.%s", ver, bpKeyName, bpKeyName)
  UIManager.ShowUIWithBpPath(UIManager.UI_Config.UnknowPass_NewBranchBuy_UIBP, bpPath)
end
function Logic_BonusPass_Buy:GetExperienceReward()
  if self.tExNorReward and self.tExMulReward and self.nCurSeason and self.nCurSeason == UnknowPassSystem.Season then
    return self.tExNorReward, self.tExMulReward
  end
  self.nCurSeason = UnknowPassSystem.Season
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  local tAllReward = Logic_BonusPass:GetBranchLevelAward()
  if not tAllReward or not next(tAllReward) then
    return
  end
  local tExNorReward = {}
  local tExMulReward = {}
  for index = 1, 30 do
    local data = tAllReward[index]
    if data.awardLevel == 30 and data.twoItemSelect > 0 then
      if #tExMulReward == 0 then
        for i = 1, 2 do
          tExMulReward[#tExMulReward + 1] = {
            resId = data["awardItemID" .. i],
            count = data["awardItemCount" .. i],
            valid_hours = data["awardItemValidHours" .. i]
          }
        end
      end
    else
      local nTableLen = 1
      local nRewardItemId1 = data.awardItemID1
      local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
      local bIsColorShapeItem = Logic_ColorShapeUtils.CheckIsColorShapeItemId(nRewardItemId1)
      if 0 < data.awardItemID2 and (not bIsColorShapeItem or not (data.twoItemSelect > 0)) then
        nTableLen = 2
      end
      for i = 1, nTableLen do
        tExNorReward[#tExNorReward + 1] = {
          resId = data["awardItemID" .. i],
          count = data["awardItemCount" .. i],
          valid_hours = data["awardItemValidHours" .. i]
        }
      end
    end
  end
  tExNorReward = self:AccumulateSameIdCount(tExNorReward)
  tExNorReward = self:GetSortRewardByQuality(tExNorReward)
  tExMulReward = self:GetSortRewardByQuality(tExMulReward)
  self.  self.  return tExNorReward, tExMulReward
end
function Logic_BonusPass_Buy:GetFullReward()
  local tFullNorReward = {}
  local tExMulReward = {}
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  local bIsBuyExperienceBp = Logic_BonusPass:IsUnlockExperienceBP()
  local nInitLevel = bIsBuyExperienceBp and 30 or 1
  local tAllReward = Logic_BonusPass:GetBranchLevelAward()
  for index = nInitLevel, #tAllReward do
    local data = tAllReward[index]
    if 30 <= data.awardLevel and data.twoItemSelect > 0 then
      if #tExMulReward == 0 then
        for i = 1, 2 do
          tExMulReward[#tExMulReward + 1] = {
            resId = data["awardItemID" .. i],
            count = data["awardItemCount" .. i],
            valid_hours = data["awardItemValidHours" .. i]
          }
        end
      end
    else
      local nTableLen = 1
      local nRewardItemId1 = data.awardItemID1
      local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
      local bIsColorShapeItem = Logic_ColorShapeUtils.CheckIsColorShapeItemId(nRewardItemId1)
      if 0 < data.awardItemID2 and (not bIsColorShapeItem or not (data.twoItemSelect > 0)) then
        nTableLen = 2
      end
      for i = 1, nTableLen do
        tFullNorReward[#tFullNorReward + 1] = {
          resId = data["awardItemID" .. i],
          count = data["awardItemCount" .. i],
          valid_hours = data["awardItemValidHours" .. i]
        }
      end
    end
  end
  tFullNorReward = self:AccumulateSameIdCount(tFullNorReward)
  tFullNorReward = self:GetSortRewardByQuality(tFullNorReward)
  tExMulReward = self:GetSortRewardByQuality(tExMulReward)
  return tFullNorReward, tExMulReward
end
function Logic_BonusPass_Buy:GetBindExRPReward(nRpType)
  if self.tBindRPReward and self.tBindRPReward[nRpType] and self.tBindRPReward.Season == UnknowPassSystem.Season then
    return self.tBindRPReward[nRpType]
  end
  self.tBindRPReward.Season = UnknowPassSystem.Season
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  local tTempData = {}
  if nRpType == Enum_RP_TYPE.Normal then
    tTempData = UnknowPassBuySystem.GetAllSuperAwards(false, true)
  elseif nRpType == Enum_RP_TYPE.Plus then
    tTempData = UnknowPassBuySystem.GetAllSuperAwards(false)
  end
  local tBindRPReward = {}
  for index, data in pairs(tTempData) do
    tBindRPReward[index] = {
      resId = data.item_id,
      count = data.item_num
    }
  end
  tBindRPReward = self:AccumulateSameIdCount(tBindRPReward)
  tBindRPReward = self:GetSortRewardByQuality(tBindRPReward)
  self.tBindRPReward[nRpType] = {}
  self.tBindRPReward[nRpType] = tBindRPReward
  return tBindRPReward
end
function Logic_BonusPass_Buy:GetBindExBPReward()
  local tBindBPReward = {}
  local bHasAddList = false
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  local bIsBuyExperienceBp = Logic_BonusPass:IsUnlockExperienceBP()
  local nInitLevel = bIsBuyExperienceBp and 30 or 1
  local tAllReward = Logic_BonusPass:GetBranchLevelAward()
  for index = nInitLevel, #tAllReward do
    local data = tAllReward[index]
    if 30 <= data.awardLevel and data.twoItemSelect > 0 then
      if not bHasAddList then
        bHasAddList = true
        for i = 1, 2 do
          tBindBPReward[#tBindBPReward + 1] = {
            resId = data["awardItemID" .. i],
            count = data["awardItemCount" .. i],
            valid_hours = data["awardItemValidHours" .. i]
          }
        end
      end
    else
      local nTableLen = 1
      local nRewardItemId1 = data.awardItemID1
      local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
      local bIsColorShapeItem = Logic_ColorShapeUtils.CheckIsColorShapeItemId(nRewardItemId1)
      if 0 < data.awardItemID2 and (not bIsColorShapeItem or not (data.twoItemSelect > 0)) then
        nTableLen = 2
      end
      for i = 1, nTableLen do
        tBindBPReward[#tBindBPReward + 1] = {
          resId = data["awardItemID" .. i],
          count = data["awardItemCount" .. i],
          valid_hours = data["awardItemValidHours" .. i]
        }
      end
    end
  end
  tBindBPReward = self:AccumulateSameIdCount(tBindBPReward)
  tBindBPReward = self:GetSortRewardByQuality(tBindBPReward)
  return tBindBPReward
end
function Logic_BonusPass_Buy:GetSortRewardByQuality(tReward)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  table.sort(tReward, function(a, b)
    local tItemCfgA = CDataTable.GetTableData("Item", a.resId)
    local tItemCfgB = CDataTable.GetTableData("Item", b.resId)
    if tItemCfgA and tItemCfgB then
      return tItemCfgA.ItemQuality > tItemCfgB.ItemQuality
    end
  end)
  return tReward
end
function Logic_BonusPass_Buy:AccumulateSameIdCount(tAwardList)
  local tMergedItems = {}
  for _, item in ipairs(tAwardList) do
    if tMergedItems[item.resId] then
      tMergedItems[item.resId].count = tMergedItems[item.resId].count + item.count
    else
      tMergedItems[item.resId] = {
        resId = item.resId,
        count = item.count
      }
    end
  end
  local tResultList = {}
  for _, item in pairs(tMergedItems) do
    table.insert(tResultList, item)
  end
  return tResultList
end
function Logic_BonusPass_Buy:SetBuyUIIsOpen(bOpen)
  self.bOpenBuyUI = bOpen
end
function Logic_BonusPass_Buy:IsOpenBuyUIJumpBefore()
  return self.bOpenBuyUI
end
function Logic_BonusPass_Buy:SetIsLoadBPScene(bIsLoadBPScene)
  self.end
function Logic_BonusPass_Buy:GetIsLoadBPScene()
  return self.bIsLoadBPScene
end
function Logic_BonusPass_Buy:HasLevel1To30BPUpgradeCard()
  if self.nLevel1To30BPCard then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local tItemInfo = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(self.nLevel1To30BPCard)
    if tItemInfo and tItemInfo.count > 0 then
      return true
    end
  end
  return false
end
function Logic_BonusPass_Buy:HasLevel30To60BPUpgradeCard()
  if self.nLevel31To60BPCard then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local tItemInfo = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(self.nLevel31To60BPCard)
    if tItemInfo and tItemInfo.count > 0 then
      return true
    end
  end
  return false
end
function Logic_BonusPass_Buy:HasLevel1To60BPUpgradeCard()
  if self.nLevel1To60BPCard then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local tItemInfo = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(self.nLevel1To60BPCard)
    if tItemInfo and tItemInfo.count > 0 then
      return true
    end
  end
  return false
end
function Logic_BonusPass_Buy:GetAllBPUpgradeCardIds()
  return self.nLevel1To30BPCard, self.nLevel31To60BPCard, self.nLevel1To60BPCard
end
function Logic_BonusPass_Buy:IsLevel1To30BPUpgradeCard(resId)
  if resId and resId == self.nLevel1To30BPCard then
    return true
  end
  return false
end
function Logic_BonusPass_Buy:IsLevel30To60BPUpgradeCard(resId)
  if resId and resId == self.nLevel31To60BPCard then
    return true
  end
  return false
end
function Logic_BonusPass_Buy:IsLevel1To60BPUpgradeCard(resId)
  if resId and resId == self.nLevel1To60BPCard then
    return true
  end
  return false
end
function Logic_BonusPass_Buy:GetBuyPriceCfgByBuyType(nBuyType)
  local tBonusPassBuyCfg = CDataTable.GetTableDataByFilter("BonusPassBuyCfg", "BuyType", nBuyType, "SeasonID", UnknowPassSystem.Season)
  if tBonusPassBuyCfg then
    return tBonusPassBuyCfg
  end
  return nil
end
function Logic_BonusPass_Buy:GetFullBuyPriceTypeInfo(nBuyItem1Id, nBuyItem2Id, nBuyItem3Id, nBuyItem4Id)
  local tPriceTypes = {}
  local nPriceType1 = self:_GetSinglePriceType(nBuyItem1Id)
  if nPriceType1 then
    tPriceTypes[1] = nPriceType1
  end
  local nPriceType2 = self:_GetSinglePriceType(nBuyItem2Id)
  if nPriceType2 then
    tPriceTypes[2] = nPriceType2
  end
  local nPriceType3 = self:_GetSinglePriceType(nBuyItem3Id)
  if nPriceType3 then
    tPriceTypes[3] = nPriceType3
  end
  local nPriceType4 = self:_GetSinglePriceType(nBuyItem4Id)
  if nPriceType4 then
    tPriceTypes[4] = nPriceType4
  end
  return tPriceTypes
end
function Logic_BonusPass_Buy:_GetSinglePriceType(nPriceId)
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_FULL_BP_PRICE_TYPE = Logic_BonusPass_Const_Config.ENUM_FULL_BP_PRICE_TYPE
  if nPriceId <= 0 then
    return ENUM_FULL_BP_PRICE_TYPE.None
  end
  if nPriceId == CoinMacro.Uc then
    return ENUM_FULL_BP_PRICE_TYPE.UC
  end
  if nPriceId == self.nLevel1To30BPCard then
    return ENUM_FULL_BP_PRICE_TYPE.ExperienceCard
  end
  if nPriceId == self.nLevel31To60BPCard then
    return ENUM_FULL_BP_PRICE_TYPE.HalfFullBP
  end
  if nPriceId == self.nLevel1To60BPCard then
    return ENUM_FULL_BP_PRICE_TYPE.FullBP
  end
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  local nRP_1_50CardId, nRP_1_100_NormalCarId, nRP_1_100_PlusCarId = UnknowPassBuySystem.GetRPAllUpgradeCardId()
  if nPriceId == nRP_1_50CardId then
    return ENUM_FULL_BP_PRICE_TYPE.ExperienceRPCard
  end
  if nPriceId == nRP_1_100_NormalCarId then
    return ENUM_FULL_BP_PRICE_TYPE.NormalRPCard
  end
  if nPriceId == nRP_1_100_PlusCarId then
    return ENUM_FULL_BP_PRICE_TYPE.PlusRPCard
  end
  return ENUM_FULL_BP_PRICE_TYPE.None
end
function Logic_BonusPass_Buy:ShouldShowUCOptionForBPFull(buyType)
  if not buyType then
    return false
  end
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_BP_BUY_TYPE = Logic_BonusPass_Const_Config.ENUM_BP_BUY_TYPE
  local ucBuyTypesForBPFull = {
    ENUM_BP_BUY_TYPE.BuyType4,
    ENUM_BP_BUY_TYPE.BuyType5,
    ENUM_BP_BUY_TYPE.BuyType6,
    ENUM_BP_BUY_TYPE.BuyType7,
    ENUM_BP_BUY_TYPE.BuyType8,
    ENUM_BP_BUY_TYPE.BuyType9,
    ENUM_BP_BUY_TYPE.BuyType14,
    ENUM_BP_BUY_TYPE.BuyType15,
    ENUM_BP_BUY_TYPE.BuyType16,
    ENUM_BP_BUY_TYPE.BuyType17,
    ENUM_BP_BUY_TYPE.BuyType18,
    ENUM_BP_BUY_TYPE.BuyType19
  }
  for _, ucBuyType in pairs(ucBuyTypesForBPFull) do
    if buyType == ucBuyType then
      return true
    end
  end
  return false
end
function Logic_BonusPass_Buy:ShouldShowUCOption(buyType)
  if not buyType then
    return false
  end
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_BP_BUY_TYPE = Logic_BonusPass_Const_Config.ENUM_BP_BUY_TYPE
  local ucBuyTypes = {
    ENUM_BP_BUY_TYPE.BuyType21,
    ENUM_BP_BUY_TYPE.BuyType22,
    ENUM_BP_BUY_TYPE.BuyType23,
    ENUM_BP_BUY_TYPE.BuyType24,
    ENUM_BP_BUY_TYPE.BuyType25,
    ENUM_BP_BUY_TYPE.BuyType26,
    ENUM_BP_BUY_TYPE.BuyType28,
    ENUM_BP_BUY_TYPE.BuyType29,
    ENUM_BP_BUY_TYPE.BuyType30,
    ENUM_BP_BUY_TYPE.BuyType31,
    ENUM_BP_BUY_TYPE.BuyType32,
    ENUM_BP_BUY_TYPE.BuyType33,
    ENUM_BP_BUY_TYPE.BuyType35,
    ENUM_BP_BUY_TYPE.BuyType36,
    ENUM_BP_BUY_TYPE.BuyType37,
    ENUM_BP_BUY_TYPE.BuyType38,
    ENUM_BP_BUY_TYPE.BuyType39,
    ENUM_BP_BUY_TYPE.BuyType40,
    ENUM_BP_BUY_TYPE.BuyType41,
    ENUM_BP_BUY_TYPE.BuyType42,
    ENUM_BP_BUY_TYPE.BuyType43,
    ENUM_BP_BUY_TYPE.BuyType45,
    ENUM_BP_BUY_TYPE.BuyType46,
    ENUM_BP_BUY_TYPE.BuyType47,
    ENUM_BP_BUY_TYPE.BuyType49,
    ENUM_BP_BUY_TYPE.BuyType50,
    ENUM_BP_BUY_TYPE.BuyType51,
    ENUM_BP_BUY_TYPE.BuyType52,
    ENUM_BP_BUY_TYPE.BuyType53,
    ENUM_BP_BUY_TYPE.BuyType54,
    ENUM_BP_BUY_TYPE.BuyType56,
    ENUM_BP_BUY_TYPE.BuyType57,
    ENUM_BP_BUY_TYPE.BuyType59,
    ENUM_BP_BUY_TYPE.BuyType60,
    ENUM_BP_BUY_TYPE.BuyType61,
    ENUM_BP_BUY_TYPE.BuyType63,
    ENUM_BP_BUY_TYPE.BuyType64,
    ENUM_BP_BUY_TYPE.BuyType66,
    ENUM_BP_BUY_TYPE.BuyType67,
    ENUM_BP_BUY_TYPE.BuyType68,
    ENUM_BP_BUY_TYPE.BuyType70,
    ENUM_BP_BUY_TYPE.BuyType71,
    ENUM_BP_BUY_TYPE.BuyType73,
    ENUM_BP_BUY_TYPE.BuyType74,
    ENUM_BP_BUY_TYPE.BuyType75
  }
  for _, ucBuyType in pairs(ucBuyTypes) do
    if buyType == ucBuyType then
      return true
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CUnknowpassFullLevelSlap = class(CModuleBase, nil, Logic_BonusPass_Buy)
return CUnknowpassFullLevelSlap