local NetManager = require("client.network.comm.NetManager")
local SupplyOptionalHandler = {}
local cruPriceType = 0
function SupplyOptionalHandler.send_get_role_custom_chest_info_req()
  NetManager.SendPkg(1429324679)
end
function SupplyOptionalHandler.on_get_role_custom_chest_info_rsp(err_code, ret_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "SupplyOptionalHandler.on_get_role_custom_chest_info_rsp", ret_info)
  EventSystem:postEvent(EVENTTYPE_CHARACTER_BOX, EVENTID_CHARACTER_INFO, ret_info)
end
function SupplyOptionalHandler.send_role_chest_custom_set_must_reward_req(resid)
  log(bWriteLog and "SupplyOptionalHandler.send_role_chest_custom_set_must_reward_req", resid)
  NetManager.SendPkg(816971439, resid)
end
function SupplyOptionalHandler.on_role_chest_custom_set_must_reward_rsp(err_code, resid)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "SupplyOptionalHandler.on_role_chest_custom_set_must_reward_rsp", resid)
  EventSystem:postEvent(EVENTTYPE_CHARACTER_BOX, EVENTID_CHARACTER_SELECT_MUST_AWARD, resid)
end
function SupplyOptionalHandler.send_role_chest_custom_buy_req(priceData)
  cruPriceType = priceData.price_type
  NetManager.SendPkg(795703999, priceData)
  log_tree(bWriteLog and "SupplyOptionalHandler.send_role_chest_custom_buy_req", priceData)
end
function SupplyOptionalHandler.on_role_chest_custom_buy_rsp(err_code, item_list, decompose_list, other_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "SupplyOptionalHandler.on_role_chest_custom_buy_rsp item_list", item_list)
  log_tree(bWriteLog and "SupplyOptionalHandler.on_role_chest_custom_buy_rsp decompose_list", decompose_list)
  log_tree(bWriteLog and "SupplyOptionalHandler.on_role_chest_custom_buy_rsp other_info", other_info)
  local bMustReward = false
  for index, data in pairs(item_list) do
    data.res_id = data.resid
    data.to_res_id = decompose_list[index] and decompose_list[index].resid or 0
    data.to_res_cnt = decompose_list[index] and decompose_list[index].count or 0
    if not bMustReward and data.must_reward then
      bMustReward = true
    end
  end
  local bDrawTen = #item_list == 10
  local tLogData = {
    must_reward = bMustReward,
    draw_times = #item_list,
    price_type = cruPriceType,
    openId = DataMgr.roleData.openID
  }
  EventSystem:postEvent(EVENTTYPE_CHARACTER_BOX, EVENTID_CHARACTER_DRAW, other_info, tLogData)
  if UIManager.IsUIShow(UIManager.UI_Config.new_supply_get_panel) then
    local boxUI = UIManager.GetUI(UIManager.UI_Config.new_supply_get_panel)
    boxUI:TryShowSupplyGetPanel(item_list, bDrawTen, {needShowMovie = true})
  else
    UIManager.ShowUI(UIManager.UI_Config.new_supply_get_panel, item_list, bDrawTen, {needShowMovie = true})
  end
end
function SupplyOptionalHandler.send_get_role_exchange_history_info_req()
  NetManager.SendPkg(992182951)
end
function SupplyOptionalHandler.on_get_role_exchange_history_info_rsp(err_code, list, wait_decompose_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "SupplyOptionalHandler.on_get_role_exchange_history_info_rsp", list)
  log_tree(bWriteLog and "SupplyOptionalHandler.on_get_role_exchange_history_info_rsp wait_decompose_list", wait_decompose_list)
  local supply_optional_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.supply_optional_data)
  supply_optional_data:SetExchangeHistory(list)
  EventSystem:postEvent(EVENTTYPE_CHARACTER_BOX, EVENTID_CHARACTER_EXCHANGE_HISTORY)
  supply_optional_data:SetWaitDecomposeList(wait_decompose_list)
end
function SupplyOptionalHandler.send_role_chest_exchange_temp_item_req(operation_type, temp_list)
  NetManager.SendPkg(1943224863, operation_type and 2 or 1, temp_list)
  log_tree(bWriteLog and "SupplyOptionalHandler.send_role_chest_exchange_temp_item_req", temp_list)
  log(bWriteLog and "SupplyOptionalHandler.send_role_chest_exchange_temp_item_req", operation_type)
end
function SupplyOptionalHandler.on_role_chest_exchange_temp_item_rsp(err_code, ret_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "SupplyOptionalHandler.on_role_chest_exchange_temp_item_rsp", ret_info)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DecomposeStyle(ret_info.item_info, ret_info.decompose_list or {})
  EventSystem:postEvent(EVENTTYPE_CHARACTER_BOX, EVENTID_CHARACTER_DECOMPOSE, ret_info.waiting_decompose_list)
  EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_EXCHANGE_SUC, ret_info.item_info[1].resid)
  local supply_optional_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.supply_optional_data)
  supply_optional_data:SetWaitDecomposeList(ret_info.waiting_decompose_list)
end
return SupplyOptionalHandler