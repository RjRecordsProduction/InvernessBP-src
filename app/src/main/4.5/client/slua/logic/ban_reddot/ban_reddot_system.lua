local BanReddotSystem = {}
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
BanReddotSystem.ReddotId = {
  article = 1009701,
  receive = 1009703,
  other = 1009702
}
BanReddotSystem.Reddot_ID_Map = {
  [BanReddotSystem.ReddotId.article] = reddot_macro.Category.NewArrivals,
  [BanReddotSystem.ReddotId.other] = reddot_macro.Category.Other,
  [BanReddotSystem.ReddotId.receive] = reddot_macro.Category.Receive
}
function BanReddotSystem.GetBanReddotType(red_id)
  return BanReddotSystem.Reddot_ID_Map[red_id] or 0
end
function BanReddotSystem.HasArticleReddot()
  log(bWriteLog and "BanReddotSystem.HasArticleReddot")
  local ban_reddot_data = require("client.slua.logic.ban_reddot.ban_reddot_data")
  local articleId = BanReddotSystem.ReddotId.article
  local RedDotType = BanReddotSystem.Reddot_ID_Map[articleId]
  local superData = ban_reddot_data.GetBanSuperData(articleId, RedDotType)
  if superData and superData.instanceId[articleId] then
    return true
  end
  return false
end
function BanReddotSystem.GetCurArticleRedDotNotifyTime()
  local RedDotSystem = require("client.slua.logic.common.logic_reddot")
  local nArticleId = BanReddotSystem.ReddotId.article
  local nCurNotifyTime = RedDotSystem.dataList[nArticleId] and RedDotSystem.dataList[nArticleId].notify_time
  return nCurNotifyTime
end
function BanReddotSystem.GetNewArticleInfo()
  local ban_reddot_data = require("client.slua.logic.ban_reddot.ban_reddot_data")
  local reddot_id = BanReddotSystem.ReddotId.article
  local superData = ban_reddot_data.GetBanSuperData(reddot_id, reddot_macro.Category.NewArrivals)
  if superData and superData.instanceId[reddot_id] then
    return reddot_id
  end
  return 0
end
function BanReddotSystem.EnterSafeStation(bSelectReport)
  local url = "game://?module=1000092&from=7&appPage=index&page=index"
  log(bWriteLog and "bgp BanReddotSystem.EnterSafeStation->url: " .. tostring(url))
  GlobalData.JumpUrl(url)
  GlobalData.StopLobbyBGM()
end
function BanReddotSystem.AddBanSystemReddot(id)
  local ban_reddot_data = require("client.slua.logic.ban_reddot.ban_reddot_data")
  if BanReddotSystem.Reddot_ID_Map[id] ~= nil then
    local redType = BanReddotSystem.Reddot_ID_Map[id]
    log(bWriteLog and "AddBanSystemReddot----redType" .. tostring(redType))
    ban_reddot_data.AddReddot(id, id, redType)
  end
end
function BanReddotSystem.RemoveBanSystemReddot(id)
  local ban_reddot_data = require("client.slua.logic.ban_reddot.ban_reddot_data")
  if BanReddotSystem.Reddot_ID_Map[id] ~= nil then
    local redType = BanReddotSystem.Reddot_ID_Map[id]
    log(bWriteLog and "RemoveBanSystemReddot----redType" .. tostring(redType))
    ban_reddot_data.RemoveBanSuperData(id, id, redType)
    local RedDotSystem = require("client.slua.logic.common.logic_reddot")
    RedDotSystem.DismissRedDotNtf(id)
  end
end
function BanReddotSystem.RemoveAllRedData()
  local RedDotSystem = require("client.slua.logic.common.logic_reddot")
  local ban_reddot_data = require("client.slua.logic.ban_reddot.ban_reddot_data")
  for type, redId in pairs(BanReddotSystem.ReddotId) do
    log(bWriteLog and "RemoveAllRedData----redid" .. tostring(redId))
    RedDotSystem.DismissRedDotNtf(redId)
    local redType = BanReddotSystem.Reddot_ID_Map[redId]
    ban_reddot_data.RemoveBanSuperData(redId, redId, redType)
  end
end
function BanReddotSystem.OpenSafeStationTips()
  log(bWriteLog and "BanReddotSystem.OpenSafeStationTips")
  if IsWoWEditor then
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if GlobalData.IsJapanOrKorea() or Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and "BanReddotSystem.OpenSafeStationTips disable in newbie guide")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.SecurityStation, 8)
  BanReddotSystem.SaveLastNewArticleTime()
end
function BanReddotSystem.SaveLastNewArticleTime()
  local RedDotSystem = require("client.slua.logic.common.logic_reddot")
  local nArticleId = BanReddotSystem.ReddotId.article
  local nCurArticleReddotTime = RedDotSystem.dataList[nArticleId] and RedDotSystem.dataList[nArticleId].notify_time or 0
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({LastTime = nCurArticleReddotTime}, PlayerPrefsSystem.ePlayerPrefsType.SafeStationNewArticleTime)
end
function BanReddotSystem.CanNotifySafeStationTips()
  log(bWriteLog and "[chub] BanReddotSystem.CanOpenSafeStationTips()")
  local lobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not lobbyMainUI or not lobbyMainUI:IsShow() then
    return false
  end
  return BanReddotSystem.HasNewArticleReddot()
end
function BanReddotSystem.HasNewArticleReddot()
  if not BanReddotSystem.HasArticleReddot() then
    return false
  end
  local nCurNotifyTime = BanReddotSystem.GetCurArticleRedDotNotifyTime()
  log(bWriteLog and "\229\174\137\229\133\168\228\184\173\229\191\131\231\186\162\231\130\185nCurNotifyTime = " .. tostring(nCurNotifyTime))
  if not nCurNotifyTime then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.SafeStationNewArticleTime) or {}
  log(bWriteLog and "\229\174\137\229\133\168\228\184\173\229\191\131\231\186\162\231\130\185cfg.LastTime = " .. tostring(cfg.LastTime))
  log(bWriteLog and "\229\174\137\229\133\168\228\184\173\229\191\131\231\186\162\231\130\185CurRedDotTime = " .. tostring(nCurNotifyTime))
  if cfg.LastTime and cfg.LastTime == nCurNotifyTime then
    return false
  end
  return true
end
return BanReddotSystem