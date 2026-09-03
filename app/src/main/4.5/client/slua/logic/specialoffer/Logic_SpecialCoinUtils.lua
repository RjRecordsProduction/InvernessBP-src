local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
local Logic_SpecialCoinUtils = {}
function Logic_SpecialCoinUtils.GetUcCoinIsShowAddBtn()
  local cObj_ui = UIManager.GetUI(UIManager.UI_Config.SpecialOffer_Main_UIBP)
  if cObj_ui and cObj_ui:IsUc() then
    return false
  end
  return true
end
function Logic_SpecialCoinUtils.GetSpecialOfferCoinsData(nId)
  local coinsData = {}
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  if nId == cfg.NewGroupBuy then
    cfg.id2Coins[cfg.NewGroupBuy] = Logic_SpecialCoinUtils._MergeGroupBuyAndBargainShowCfg()
  end
  local id2Coins = cfg.id2Coins
  local aCoinsCfg = id2Coins[nId]
  if type(aCoinsCfg) == "function" then
    aCoinsCfg = aCoinsCfg()
  end
  if not aCoinsCfg then
    return coinsData
  end
  local bIsSimpleLobby = cfg.IsSimpleLobby and cfg.IsSimpleLobby()
  for i, aData in ipairs(aCoinsCfg) do
    if type(aData) == "table" then
      if aData.nItemId then
        local nItemId
        if type(aData.nItemId) == "function" then
          nItemId = aData.nItemId()
        elseif type(aData.nItemId) == "number" then
          nItemId = aData.nItemId
        end
        if not bIsSimpleLobby or not Logic_SpecialCoinUtils.IsSmallTicketCoin(nItemId) then
          coinsData[#coinsData + 1] = {
            nItemId = nItemId,
            tExtraData = aData.tExtraData
          }
        end
      end
    elseif type(aData) == "number" and (not bIsSimpleLobby or not Logic_SpecialCoinUtils.IsSmallTicketCoin(aData)) then
      coinsData[#coinsData + 1] = {nItemId = aData}
    end
  end
  return coinsData
end
function Logic_SpecialCoinUtils.IsSmallTicketCoin(nItemId)
  return nItemId == CoinMacro.SmallTicket or nItemId == CoinMacro.SmallTicket_JK
end
function Logic_SpecialCoinUtils.GetSmallRPCoinShowCfg()
  local tIPScoreShowCfg = Logic_SpecialCoinUtils.GetIPScoreShowCfg()
  return {
    tIPScoreShowCfg,
    CoinMacro.Uc
  }
end
function Logic_SpecialCoinUtils.GetIPScoreShowCfg()
  local tShowCfg = {}
  function tShowCfg.nItemId()
    local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
    local nIPScoreId = Logic_SmallRP:GetIPScoreId()
    if nIPScoreId and 0 < nIPScoreId then
      return nIPScoreId
    end
  end
  tShowCfg.tExtraData = {
    bIsShowAddBtn = true,
    fAddBtnClickCallback = function(node_btn)
      if not slua.isValid(node_btn) then
        return
      end
      local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
      local nIPScoreId = Logic_SmallRP:GetIPScoreId()
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local uObj_itemCfg = CDataTable.GetTableData("Item", nIPScoreId) or {}
      local tipsParam = {
        iconItem = nIPScoreId,
        widget = node_btn,
        content = uObj_itemCfg.ItemDesc,
        jumpText = LocUtil.GetLocalizeResStr(7031),
        jumpCallback = function()
          local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", nIPScoreId)
          if not jumpConfig then
            return
          end
          GlobalData.JumpUrl(jumpConfig.JumpExchangeUrl)
        end,
        offsetX = -280,
        offsetY = 60
      }
      UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tipsParam)
    end
  }
  return tShowCfg
end
function Logic_SpecialCoinUtils._MergeGroupBuyAndBargainShowCfg()
  local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  local nCoinTab = logic_group_buying and logic_group_buying.nCoinTab or 0
  if nCoinTab == 2 then
    local bargainCfg = logic_bargain and logic_bargain.GetBargainShowCfg and logic_bargain:GetBargainShowCfg() or {}
    return Logic_SpecialCoinUtils._FilterVoucherCoins(bargainCfg)
  elseif nCoinTab == 1 then
    local groupBuyCfg = logic_group_buying and logic_group_buying:GetGroupBuyShowCfg() or {}
    return groupBuyCfg
  end
  local groupBuyCfg = logic_group_buying and logic_group_buying:GetGroupBuyShowCfg() or {}
  local bargainCfg = logic_bargain and logic_bargain.GetBargainShowCfg and logic_bargain:GetBargainShowCfg() or {}
  if not bargainCfg or #bargainCfg == 0 then
    return groupBuyCfg
  end
  if not groupBuyCfg or #groupBuyCfg == 0 then
    return bargainCfg
  end
  local seen = {}
  local merged = {}
  for _, coinId in ipairs(groupBuyCfg) do
    if not seen[coinId] then
      seen[coinId] = true
      merged[#merged + 1] = coinId
    end
  end
  for _, coinId in ipairs(bargainCfg) do
    if not seen[coinId] then
      seen[coinId] = true
      merged[#merged + 1] = coinId
    end
  end
  return merged
end
function Logic_SpecialCoinUtils._FilterVoucherCoins(coinList)
  if not coinList or #coinList == 0 then
    return coinList
  end
  local filtered = {}
  for _, coinId in ipairs(coinList) do
    if not Logic_SpecialCoinUtils._IsVoucherCoin(coinId) then
      filtered[#filtered + 1] = coinId
    end
  end
  return filtered
end
function Logic_SpecialCoinUtils._IsVoucherCoin(coinId)
  if not coinId then
    return false
  end
  if coinId == CoinMacro.DepositDeductionVoucher or coinId == CoinMacro.GeneralCoupon or coinId == CoinMacro.PremiumCoupon then
    return true
  end
  local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
  if logic_group_buying and logic_group_buying.COST_ID and logic_group_buying.COST_ID[coinId] then
    return true
  end
  return false
end
return Logic_SpecialCoinUtils