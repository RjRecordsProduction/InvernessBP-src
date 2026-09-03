local logic_card_collection_cache = {}
local CardCollectionUIConfig = require("client.slua.logic.card_collection_season.CardCollectionSeasonUIConfig")
local CardSourceType = {
  gift_receive = CardCollectionUIConfig.ECardFromType.FriendGift,
  exchange_sender = CardCollectionUIConfig.ECardFromType.FriendSwap
}
function logic_card_collection_cache.SaveClaimData(award_list, from_type, send_uid, send_name)
  logic_card_collection_cache._SaveCardCacheData("eCardCollectionClaimCard", award_list, from_type, send_uid, send_name)
  local card_collection_reddot_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.card_collection_reddot_data)
  card_collection_reddot_data:SetClaimRedDot()
end
function logic_card_collection_cache.LoadClaimData()
  return logic_card_collection_cache._LoadCardCacheData("eCardCollectionClaimCard")
end
function logic_card_collection_cache.HasClaimData()
  local claimData = logic_card_collection_cache.LoadClaimData()
  return claimData and next(claimData)
end
function logic_card_collection_cache.ClearClaimData()
  logic_card_collection_cache._ClearCardCacheData("eCardCollectionClaimCard")
  local card_collection_reddot_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.card_collection_reddot_data)
  card_collection_reddot_data:CloseClaimRedDot()
end
function logic_card_collection_cache.SaveDriftBottleData(award_list, send_uid)
  logic_card_collection_cache._SaveCardCacheData("eCardCollectionDriftBottle", award_list, CardCollectionUIConfig.ECardFromType.Drift, send_uid, nil)
  local card_collection_reddot_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.card_collection_reddot_data)
  card_collection_reddot_data:SetDriftRedDot()
end
function logic_card_collection_cache.LoadDriftBottleData()
  return logic_card_collection_cache._LoadCardCacheData("eCardCollectionDriftBottle")
end
function logic_card_collection_cache.HasDriftBottleData()
  local driftData = logic_card_collection_cache.LoadDriftBottleData()
  return driftData and next(driftData)
end
function logic_card_collection_cache.ClearDriftBottleData()
  logic_card_collection_cache._ClearCardCacheData("eCardCollectionDriftBottle")
  local card_collection_reddot_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.card_collection_reddot_data)
  card_collection_reddot_data:CloseDriftRedDot()
end
function logic_card_collection_cache.SaveCardGetData(cardList)
  if not cardList or not next(cardList) then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionCardGet) or {}
  for _, v in ipairs(cardList) do
    if v.show_data and v.show_data.CardID then
      local cardKey = tostring(v.show_data.CardID)
      if not cacheMap[cardKey] then
        cacheMap[cardKey] = {
          setID = v.show_data.SetID or 0,
          is_new = v.is_new or false
        }
      end
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(cacheMap, PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionCardGet)
  log(bWriteLog and "[CardCollection] logic_card_collection_cache.SaveCardGetData saved")
end
function logic_card_collection_cache.LoadCardGetData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionCardGet)
  log_tree("[CardCollection] logic_card_collection_cache.LoadCardGetData", cacheMap)
  return cacheMap
end
function logic_card_collection_cache.HasCardGetData()
  local cacheMap = logic_card_collection_cache.LoadCardGetData()
  return cacheMap and next(cacheMap) ~= nil
end
function logic_card_collection_cache.ClearCardGetData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionCardGet)
  log(bWriteLog and "[CardCollection] logic_card_collection_cache.ClearCardGetData cleared")
end
function logic_card_collection_cache.RemoveCardGetDataByCardID(cardID)
  if not cardID then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionCardGet) or {}
  local cardKey = tostring(cardID)
  if cacheMap[cardKey] == nil then
    return
  end
  cacheMap[cardKey] = nil
  PlayerPrefsSystem.SaveTableToFile_N(cacheMap, PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionCardGet)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_cache.RemoveCardGetDataByCardID cardID=%s", tostring(cardID)))
end
function logic_card_collection_cache.GetCardGetDataByCardID(cardID)
  if not cardID then
    return nil
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionCardGet)
  if not cacheMap then
    return nil
  end
  return cacheMap[tostring(cardID)]
end
function logic_card_collection_cache.MarkGunPromoSeen()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({seen = true}, PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionGunPromoSeen)
  log(bWriteLog and "[CardCollection] logic_card_collection_cache.MarkGunPromoSeen saved")
end
function logic_card_collection_cache.IsGunPromoSeen()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionGunPromoSeen)
  return data ~= nil and data.seen == true
end
function logic_card_collection_cache._SaveCardCacheData(prefsType, awardList, fromType, senderUid, senderName)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheList = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType[prefsType]) or {}
  log_tree("[CardCollection] logic_card_collection_cache._SaveCardCacheData cacheList load", cacheList)
  cacheList = cacheList or {}
  table.insert(cacheList, {
    awardList = awardList,
    fromType = fromType,
    senderUid = senderUid,
      })
  PlayerPrefsSystem.SaveTableToFile_N(cacheList, PlayerPrefsSystem.ePlayerPrefsType[prefsType])
  log_tree("[CardCollection] logic_card_collection_cache._SaveCardCacheData cacheList save", cacheList)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_cache._SaveCardCacheData prefsType=%s, fromType=%s, senderUid=%s", tostring(prefsType), tostring(fromType), tostring(senderUid)))
end
function logic_card_collection_cache._LoadCardCacheData(prefsType)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType[prefsType])
  log_tree("[CardCollection] logic_card_collection_cache._LoadCardCacheData " .. tostring(prefsType), cacheData)
  return cacheData
end
function logic_card_collection_cache._HasCardCacheData(prefsType)
  local list = logic_card_collection_cache._LoadCardCacheData(prefsType)
  return list and next(list)
end
function logic_card_collection_cache._ClearCardCacheData(prefsType)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType[prefsType])
  log(bWriteLog and "[CardCollection] logic_card_collection_cache._ClearCardCacheData prefsType=" .. tostring(prefsType))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_card_collection_cache = class(CModuleBase, nil, logic_card_collection_cache)
return Clogic_card_collection_cache