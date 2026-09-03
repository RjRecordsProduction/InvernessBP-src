local CorpGiftExchangeSystem = {
  valid_corps_exchange_conf = {},
  item_exchange_list = {},
  chip_list = {},
  coin_exchange_limit = 1,
  exchange_log = {},
  coin_num = 0,
  exchange_act_data = {},
  coin_id = 0,
  daily_exchange_times = 0,
  self_exchange_list = {},
  self_log_list = {},
  is_show_redPoint = false,
  is_req = false,
  callback = nil,
  target_seq_id = nil,
  filter_id = 0,
  is_from_main = false,
  clicked_item_id = nil,
  is_compose = false
}
function CorpGiftExchangeSystem.Init()
  CorpGiftExchangeSystem.valid_corps_exchange_conf = {}
  CorpGiftExchangeSystem.item_exchange_list = {}
  CorpGiftExchangeSystem.chip_list = {}
  CorpGiftExchangeSystem.coin_exchange_limit = 1
  CorpGiftExchangeSystem.exchange_log = {}
  CorpGiftExchangeSystem.coin_num = 0
  CorpGiftExchangeSystem.exchange_act_data = {}
  CorpGiftExchangeSystem.is_req = true
end
function CorpGiftExchangeSystem.Clear()
end
function CorpGiftExchangeSystem.ShowUI()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local limitLevel = CorpsMgr.GetConfigToNumber("CreateCorpsLevel") or 0
  if limitLevel > DataMgr.roleData.level then
    CorpsMgr.ShowCorpsLimitError()
    return
  end
  if not CorpGiftExchangeSystem.is_req then
    local CorpsGiftExchangeHandler = require("client.network.Protocol.CorpsGiftExchangeHandler")
    CorpGiftExchangeSystem.callback = CorpGiftExchangeSystem.ShowUI
    CorpsGiftExchangeHandler.send_get_corps_exchange_data_req()
    return
  end
  if CorpGiftExchangeSystem.IsStart() then
    CorpGiftExchangeSystem.is_req = false
  else
    ShowNotice(120106)
  end
end
function CorpGiftExchangeSystem.JumpFromChat(target_seq_id)
  if not CorpGiftExchangeSystem.is_req then
    local CorpsGiftExchangeHandler = require("client.network.Protocol.CorpsGiftExchangeHandler")
    CorpGiftExchangeSystem.callback = CorpGiftExchangeSystem.JumpFromChat
    CorpGiftExchangeSystem.    CorpsGiftExchangeHandler.send_get_corps_exchange_data_req()
    return
  end
  if CorpGiftExchangeSystem.IsStart() then
    local CorpsGiftExchangeHandler = require("client.network.Protocol.CorpsGiftExchangeHandler")
    CorpsGiftExchangeHandler.send_corps_exchange_personal_list_req()
    CorpsGiftExchangeHandler.send_corps_exchange_market_req(0)
    CorpGiftExchangeSystem.is_req = false
  else
    ShowNotice(120106)
  end
end
function CorpGiftExchangeSystem.GetChipsTotalNum()
  local totalNum = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for i, v in pairs(CorpGiftExchangeSystem.chip_list) do
    local itemcount = wardrobe_data:GetHallDepotItemCountByResIDAndValidInfo(i) or 0
    totalNum = totalNum + itemcount
  end
  return totalNum
end
function CorpGiftExchangeSystem.IsStart()
  if not CorpGiftExchangeSystem.valid_corps_exchange_conf or not CorpGiftExchangeSystem.valid_corps_exchange_conf.end_time then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.GetServerTimeInSec() > CorpGiftExchangeSystem.valid_corps_exchange_conf.end_time then
    return false
  end
  return true
end
function CorpGiftExchangeSystem.Initreq()
  local CorpsGiftExchangeHandler = require("client.network.Protocol.CorpsGiftExchangeHandler")
  CorpsGiftExchangeHandler.send_get_corps_exchange_data_req()
end
return CorpGiftExchangeSystem