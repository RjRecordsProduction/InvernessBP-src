local SpecialLuckNetWork = {
  Config = {
    [122020803] = {
      moduleName = "client.slua.logic.lobby_activity.logic_luckmix_activity",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspExtraRewardFuncName = "OnExtraRewardRsp"
    },
    [123020801] = {
      moduleName = "client.slua.logic.lobby_activity.logic_luckmix_activity",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspExtraRewardFuncName = "OnExtraRewardRsp"
    },
    [223020801] = {
      moduleName = "client.slua.logic.lobby_activity.logic_luckmix_activity",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspExtraRewardFuncName = "OnExtraRewardRsp"
    },
    [223020802] = {
      moduleName = "client.slua.logic.lobby_activity.logic_luckmix_activity",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspExtraRewardFuncName = "OnExtraRewardRsp"
    },
    [124020801] = {
      moduleName = "client.slua.logic.lobby_activity.logic_luckmix_activity",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspExtraRewardFuncName = "OnExtraRewardRsp"
    },
    [125020801] = {
      moduleName = "client.slua.logic.lobby_activity.logic_luckmix_activity",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspExtraRewardFuncName = "OnExtraRewardRsp"
    },
    [426020801] = {
      moduleName = "client.slua.logic.lobby_activity.logic_luckmix_activity",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspExtraRewardFuncName = "OnExtraRewardRsp"
    },
    [427020801] = {
      moduleName = "client.slua.logic.lobby_activity.logic_luckmix_activity",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspExtraRewardFuncName = "OnExtraRewardRsp"
    },
    [140022080] = {
      moduleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunReceiver",
      RspInfoFuncName = "OnGetDrawInfo",
      DoDrawFuncName = "OnDoDrawActRsp",
      DrawSumFuncName = "OnDrawSumRsp"
    },
    [235022080] = {
      moduleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunReceiver",
      RspInfoFuncName = "OnGetDrawInfo",
      DoDrawFuncName = "OnDoDrawActRsp",
      DrawSumFuncName = "OnDrawSumRsp"
    },
    [145022080] = {
      moduleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunReceiver",
      RspInfoFuncName = "OnGetDrawInfo",
      DoDrawFuncName = "OnDoDrawActRsp",
      DrawSumFuncName = "OnDrawSumRsp"
    },
    [123022101] = {
      moduleName = "client.slua.logic.lobby_activity.logic_scrapgold_draw",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspDrawDiscount = "OnDrawEventExchangeDiscountRsp"
    },
    [227022101] = {
      moduleName = "client.slua.logic.lobby_activity.logic_scrapgold_draw",
      RspInfoFuncName = "OnActInfoRsp",
      DoDrawFuncName = "OnDoDrawRsp",
      DrawSumFuncName = "OnDrawSumRsp",
      RspDrawDiscount = "OnDrawEventExchangeDiscountRsp"
    }
  },
  Enum_Extra_Type = {Extra_Type_Egg = 1}
}
local tSupplyTurntableModuleCfg
function SpecialLuckNetWork.send_get_draw_act_info_req(activity_id)
  local LuckySpecialHandler = require("client.network.Protocol.LuckySpecialHandler")
  LuckySpecialHandler.send_get_draw_act_info_req(activity_id)
end
function SpecialLuckNetWork.on_get_draw_act_info_rsp(activity_id, pool_info, price_info, ext_info)
  local config = SpecialLuckNetWork.Config
  local value = config[activity_id]
  SpecialLuckNetWork.GetSupplyTurntableModuleCfg()
  if value then
    assert_format(value.moduleName ~= nil, "Event config module name is nil! Function name: %s", config.funcName)
    local m = require(value.moduleName)
    assert_format(type(m) == "table", "Module[%s] not return as table! FunctionName[%s]", config.moduleName, config.funcName)
    local func = m[value.RspInfoFuncName]
    assert_format(func ~= nil, "Function[%s] not found in module[%s]", config.funcName, config.moduleName)
    local utility = require("common.utility")
    xpcall(func, utility.ErrorMessageHandler, activity_id, pool_info, price_info, ext_info)
  elseif tSupplyTurntableModuleCfg and tSupplyTurntableModuleCfg[activity_id] then
    local moduleName = tSupplyTurntableModuleCfg[activity_id].ActivityModuleName
    local module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig[moduleName])
    if module.OnGetDrawActInfoRsp then
      module:OnGetDrawActInfoRsp(activity_id, pool_info, price_info, ext_info)
    end
  else
    log_error("SpecialLuckNetWork on_get_draw_act_info_rsp not found activity_id" .. tostring(activity_id))
  end
end
function SpecialLuckNetWork.send_do_draw_act_req(activity_id, voucher_id, currency_id, cost_times, ext_info)
  local LuckySpecialHandler = require("client.network.Protocol.LuckySpecialHandler")
  LuckySpecialHandler.send_do_draw_act_req(activity_id, voucher_id, currency_id, cost_times, ext_info)
end
function SpecialLuckNetWork.on_do_draw_act_rsp(activity_id, item_list, decompose_list, ext_info)
  local config = SpecialLuckNetWork.Config
  local value = config[activity_id]
  SpecialLuckNetWork.GetSupplyTurntableModuleCfg()
  if value then
    assert_format(value.moduleName ~= nil, "Event config module name is nil! Function name: %s", config.funcName)
    local m = require(value.moduleName)
    assert_format(type(m) == "table", "Module[%s] not return as table! FunctionName[%s]", config.moduleName, config.funcName)
    local func = m[value.DoDrawFuncName]
    assert_format(func ~= nil, "Function[%s] not found in module[%s]", config.funcName, config.moduleName)
    local utility = require("common.utility")
    xpcall(func, utility.ErrorMessageHandler, activity_id, item_list, decompose_list, ext_info)
  elseif tSupplyTurntableModuleCfg and tSupplyTurntableModuleCfg[activity_id] then
    local moduleName = tSupplyTurntableModuleCfg[activity_id].ActivityModuleName
    local module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig[moduleName])
    if module.OnDoDrawActRsp then
      module:OnDoDrawActRsp(activity_id, item_list, decompose_list, ext_info)
    end
  end
end
function SpecialLuckNetWork.send_get_draw_sum_reward_req(activity_id, sum_times, is_take_all)
  local LuckySpecialHandler = require("client.network.Protocol.LuckySpecialHandler")
  LuckySpecialHandler.send_get_draw_sum_reward_req(activity_id, sum_times, is_take_all)
end
function SpecialLuckNetWork.on_get_draw_sum_reward_rsp(activity_id, award_list, decompose_list)
  local config = SpecialLuckNetWork.Config
  local value = config[activity_id]
  SpecialLuckNetWork.GetSupplyTurntableModuleCfg()
  if value then
    assert_format(value.moduleName ~= nil, "Event config module name is nil! Function name: %s", config.funcName)
    local m = require(value.moduleName)
    assert_format(type(m) == "table", "Module[%s] not return as table! FunctionName[%s]", config.moduleName, config.funcName)
    local func = m[value.DrawSumFuncName]
    assert_format(func ~= nil, "Function[%s] not found in module[%s]", config.funcName, config.moduleName)
    local utility = require("common.utility")
    xpcall(func, utility.ErrorMessageHandler, activity_id, award_list, decompose_list)
  elseif tSupplyTurntableModuleCfg and tSupplyTurntableModuleCfg[activity_id] then
    local moduleName = tSupplyTurntableModuleCfg[activity_id].ActivityModuleName
    local module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig[moduleName])
    if module.OnGetDrawSumRewardRsp then
      module:OnGetDrawSumRewardRsp(activity_id, award_list, decompose_list)
    end
  end
end
function SpecialLuckNetWork.send_get_extra_reward_req(activity_id, reward_type)
  local LuckySpecialHandler = require("client.network.Protocol.LuckySpecialHandler")
  LuckySpecialHandler.send_get_extra_reward_req(activity_id, reward_type)
end
function SpecialLuckNetWork.on_get_extra_reward_rsp(activity_id, item_list)
  local config = SpecialLuckNetWork.Config
  local value = config[activity_id]
  SpecialLuckNetWork.GetSupplyTurntableModuleCfg()
  if value then
    assert_format(value.moduleName ~= nil, "Event config module name is nil! Function name: %s", config.funcName)
    local m = require(value.moduleName)
    assert_format(type(m) == "table", "Module[%s] not return as table! FunctionName[%s]", config.moduleName, config.funcName)
    local func = m[value.RspExtraRewardFuncName]
    assert_format(func ~= nil, "Function[%s] not found in module[%s]", config.funcName, config.moduleName)
    local utility = require("common.utility")
    xpcall(func, utility.ErrorMessageHandler, activity_id, item_list)
  elseif tSupplyTurntableModuleCfg and tSupplyTurntableModuleCfg[activity_id] then
    local moduleName = tSupplyTurntableModuleCfg[activity_id].ActivityModuleName
    local module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig[moduleName])
    if module.OnGetDrawSumRewardRsp then
      module:OnGetExtraRewardRsp(activity_id, item_list)
    end
  end
end
function SpecialLuckNetWork.send_do_draw_discount_req(activity_id)
  local LuckySpecialHandler = require("client.network.Protocol.LuckySpecialHandler")
  LuckySpecialHandler.send_do_draw_discount_req(activity_id)
end
function SpecialLuckNetWork.on_do_draw_discount_rsp(activity_id, discount_value, discount_draw_time)
  local config = SpecialLuckNetWork.Config
  local value = config[activity_id]
  if value then
    local m = require(value.moduleName)
    assert_format(type(m) == "table", "Module[%s] not return as table! FunctionName[%s]", config.moduleName, config.funcName)
    local func = m[value.RspDrawDiscount]
    assert_format(func ~= nil, "Function[%s] not found in module[%s]", config.funcName, config.moduleName)
    local utility = require("common.utility")
    xpcall(func, utility.ErrorMessageHandler, activity_id, discount_value, discount_draw_time)
  end
end
function SpecialLuckNetWork.GetSupplyTurntableModuleCfg()
  if tSupplyTurntableModuleCfg then
    return
  end
  tSupplyTurntableModuleCfg = CDataTable.GetTable("SupplyTurntableModuleCfg")
end
return SpecialLuckNetWork