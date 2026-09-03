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
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    cfg.id2Coins[cfg.NewGroupBuy] = logic_group_buying:GetGroupBuyShowCfg()
  end
  local id2Coins = cfg.id2Coins
  local aCoinsCfg = id2Coins[nId]
  if type(aCoinsCfg) == "function" then
    aCoinsCfg = aCoinsCfg()
  end
  if not aCoinsCfg then
    return coinsData
  end
  for i, aData in ipairs(aCoinsCfg) do
    if type(aData) == "table" then
      if aData.nItemId then
        local nItemId
        if type(aData.nItemId) == "function" then
          nItemId = aData.nItemId()
        elseif type(aData.nItemId) == "number" then
          nItemId = aData.nItemId
        end
        coinsData[i] = {
          nItemId = nItemId,
          tExtraData = aData.tExtraData
        }
      end
    elseif type(aData) == "number" then
      coinsData[i] = {nItemId = aData}
    end
  end
  return coinsData
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
return Logic_SpecialCoinUtils