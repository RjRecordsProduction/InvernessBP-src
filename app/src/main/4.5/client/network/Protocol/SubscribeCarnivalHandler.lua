local NetManager = require("client.network.comm.NetManager")
local SubscribeCarnivalHandler = {}
function SubscribeCarnivalHandler.send_carnival_query_req(attr_name_list, cfg_name_list)
  NetManager.SendPkg(2119330714, attr_name_list, cfg_name_list)
end
function SubscribeCarnivalHandler.on_carnival_notify(is_open, is_prime, carnival_data, cfg)
  local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
  SubscribeCarnivalSystem.OnActivityCfgRsp(is_open, is_prime, carnival_data, cfg)
end
function SubscribeCarnivalHandler.send_take_daily_reward(day)
  NetManager.SendPkg(1377528086, day)
end
function SubscribeCarnivalHandler.on_take_daily_reward_rsp(errcode, day)
  local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
  SubscribeCarnivalSystem.OnGetAwardRsp(errcode, day)
end
function SubscribeCarnivalHandler.send_prime_direct_buy(prime_item_id, combine_id)
  NetManager.SendPkg(1139257292, prime_item_id, combine_id)
end
function SubscribeCarnivalHandler.on_prime_direct_buy_rsp(err_str)
  local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
  SubscribeCarnivalSystem.OnSubscribeRsp(err_str)
end
function SubscribeCarnivalHandler.on_get_subscribe_gift(type)
  local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
  SubscribeCarnivalSystem.OnAwardNotify(type)
end
return SubscribeCarnivalHandler