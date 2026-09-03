local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
local special_offer_net_cfg = {}
local _nIntervalTime = 5
local _tMapActSendTime = {}
local _tAllNetCfg = {
  [special_offer_cfg.SmallRP] = function()
    local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
    Logic_SmallRP:send_small_rp_player_data_req()
  end
}
function special_offer_net_cfg.SendActNet()
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  for nActType, fun in pairs(_tAllNetCfg) do
    local nLastTime = _tMapActSendTime[nActType] or 0
    if nCurTime - nLastTime > _nIntervalTime then
      _tMapActSendTime[nActType] = nCurTime
      fun(nCurTime)
    end
  end
end
function special_offer_net_cfg.SendActNetByType(nActType)
  if not _tAllNetCfg[nActType] then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  local nLastTime = _tMapActSendTime[nActType] or 0
  if nCurTime - nLastTime > _nIntervalTime then
    _tMapActSendTime[nActType] = nCurTime
    _tAllNetCfg[nActType](nCurTime)
  end
end
return special_offer_net_cfg