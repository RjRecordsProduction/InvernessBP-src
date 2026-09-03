local NetManager = require("client.network.comm.NetManager")
local SeasonShopHandler = {}
function SeasonShopHandler.send_get_season_shop_config_req()
  NetManager.SendPkg(1521969151)
end
function SeasonShopHandler.on_season_coin_exchange_shop_conf(season_coin_exchange_shop_conf, season_exchange_params_conf)
  log(bWriteLog and "SeasonShopHandler.on_season_coin_exchange_shop_conf")
  log_tree("SeasonShopHandler.on_season_coin_exchange_shop_conf season_coin_exchange_shop_conf", season_coin_exchange_shop_conf)
  log_tree("SeasonShopHandler.on_season_coin_exchange_shop_conf season_exchange_params_conf", season_exchange_params_conf)
  local logic_season_shop_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_shop_system)
  logic_season_shop_system:OnGetSeasonShopConfig(season_coin_exchange_shop_conf, season_exchange_params_conf)
  local logic_season_const = require("client.logic.season.logic_season_const")
  EventSystem:postEvent(EVENTTYPE_SEASON_CONFIG, EVENTID_GET_SHOP_CONFIG, logic_season_const.ESeasonType.Classic)
end
function SeasonShopHandler.on_notify_coin_exchange_info(coin_exchange_info)
  log_tree(bWriteLog and "SeasonShopHandler.on_notify_coin_exchange_info coin_exchange_info = ", coin_exchange_info)
  local logic_season_shop_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_shop_system)
  logic_season_shop_system:OnGetShopExchangeInfo(coin_exchange_info)
end
function SeasonShopHandler.send_coin_exchange_req(res_id, cnt)
  NetManager.SendPkg(521295784, res_id, cnt)
end
function SeasonShopHandler.on_coin_exchange_res(err, param)
  if err == 0 then
    ShowNotice(3016)
    EventSystem:postEvent(EVENTTYPE_SEASON_CONFIG, EVENTID_EXCHANGE_SUCCESS, param)
  else
    ShowNotice(err)
  end
end
return SeasonShopHandler