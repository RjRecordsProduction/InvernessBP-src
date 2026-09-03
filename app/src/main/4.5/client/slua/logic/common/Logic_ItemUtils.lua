local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
local Logic_ItemUtils = {}
function Logic_ItemUtils.GetItemCount(nItemId, bForever)
  if not nItemId then
    return 0
  end
  nItemId = tonumber(nItemId)
  if nItemId == CoinMacro.Bp then
    return DataMgr.gold or 0
  elseif nItemId == CoinMacro.Silver then
    return DataMgr.diamond or 0
  elseif nItemId == CoinMacro.Uc then
    return DataMgr.ticket or 0
  elseif nItemId == CoinMacro.WowScore then
    return DataMgr.wow_creation_score or 0
  elseif nItemId == CoinMacro.RPScore then
    return UnknowPassSystem.Score or 0
  elseif nItemId == CoinMacro.PigCoin then
    return DataMgr.fp_token or 0
  elseif nItemId == CoinMacro.CarteamCoin then
    return DataMgr.carteam_coin_count or 0
  elseif nItemId == CoinMacro.BattleCoin then
    return DataMgr.battle_coin or 0
  elseif nItemId == CoinMacro.Gold then
    return DataMgr.gold_chip or 0
  elseif nItemId == CoinMacro.Ag then
    return DataMgr.eternal_diamond or 0
  elseif nItemId == CoinMacro.Allstar then
    return LobbySystem.roleData.allstar_score
  elseif nItemId == CoinMacro.SmallRPScore then
    return Logic_ItemUtils.GetSmallRPScore()
  elseif nItemId == CoinMacro.UGCAdvancedCrystal then
    return DataMgr.ugc_advanced_crystal or 0
  elseif nItemId == CoinMacro.HomeCoin or nItemId == CoinMacro.HomeSuperCoin then
    local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
    return PHomeStoreProxy:GetMyCoinsByType(nItemId)
  elseif nItemId == CoinMacro.TxTicket or nItemId == CoinMacro.XMissionCoin then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    return LogicTxMissionMain.GetMoney()
  elseif nItemId == CoinMacro.UGCSeasonCoin then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local count = wardrobe_data:GetHallDepotItemCountByResID(CoinMacro.UGCSeasonCoin, true)
    return count or 0
  elseif Logic_ItemUtils.GetIsScoreCurrencyType(nItemId) then
    return DataMgr.GetItemStoreByItemId(nItemId) or 0
  end
  local ItemCfg = CDataTable.GetTableData("Item", nItemId)
  if not ItemCfg then
    return 0
  end
  if ItemCfg.ItemType == ENUM_ITEM_TYPE.Voice_Pack then
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
    return ActorVoiceSystem.CheckIsActorValidByItemID(nItemId) and 1 or 0
  elseif ItemCfg.ItemType == ENUM_ITEM_TYPE.HeadIcon then
    local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
    return RoleInfoAvatarSystem.HasAvatar(nItemId, bForever) == true and 1 or 0
  elseif ItemCfg.ItemType == ENUM_ITEM_TYPE.HeadBorder then
    local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
    return RoleInfoAvatarFrameSystem.HasAvatarFrameCond(nItemId, bForever) == true and 1 or 0
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local nOwnCurrencyCount = wardrobe_data:GetItemCountOnlyForever(nItemId, bForever)
  return nOwnCurrencyCount
end
function Logic_ItemUtils.GetSmallRPScore()
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  return Logic_SmallRP:GetCanExchangeScore()
end
function Logic_ItemUtils.GetIsScoreCurrencyType(nItemId)
  local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
  if uObj_itemCfg and uObj_itemCfg.ItemType == ENUM_ITEM_TYPE.Materials and uObj_itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.ScoreCurrency then
    return true
  end
  return false
end
local _tShowIcon2Item = {
  [CoinMacro.Silver] = true,
  [CoinMacro.Bp] = true,
  [CoinMacro.HomeCoin] = true,
  [CoinMacro.HomeSuperCoin] = true
}
local _tItemIconMapping = {
  [CoinMacro.SmallRPScore] = function()
    local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
    return Logic_SmallRP:GetScoreShowItemId()
  end
}
function Logic_ItemUtils.GetCurrencyIconPath(nItemId)
  nItemId = tonumber(nItemId)
  local nShowItemId = nItemId
  if _tItemIconMapping[nItemId] and type(_tItemIconMapping[nItemId]) == "function" then
    nShowItemId = _tItemIconMapping[nItemId]()
  end
  local UIUtil = require("client.common.ui_util")
  local uObj_currencyCfg = CDataTable.GetTableData("Item", nShowItemId)
  if not uObj_currencyCfg then
    return
  end
  if _tShowIcon2Item[nShowItemId] then
    return UIUtil.GetIconCheckDownloaded(uObj_currencyCfg.ItemSmallIcon2)
  else
    return UIUtil.GetIconCheckDownloaded(uObj_currencyCfg.ItemSmallIcon)
  end
end
return Logic_ItemUtils