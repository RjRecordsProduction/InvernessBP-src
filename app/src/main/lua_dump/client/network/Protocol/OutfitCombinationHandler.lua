local NetManager = require("client.network.comm.NetManager")
local OutfitCombinationHandler = {}
function OutfitCombinationHandler.send_put_on_outfit_combinations_req(id)
  log(bWriteLog and string.format("OutfitCombinationHandler:send_put_on_outfit_combinations_req id: %s", id))
  NetManager.SendPkg(560552391, id)
end
function OutfitCombinationHandler.on_put_on_outfit_combinations_rsp(id)
  log(bWriteLog and string.format("OutfitCombinationHandler.on_put_on_outfit_combinations_rsp id : %s", id))
end
function OutfitCombinationHandler.send_get_outfit_combinations_use_times_req()
  NetManager.SendPkg(1653800411)
end
function OutfitCombinationHandler.on_get_outfit_combinations_use_times_rsp(res, combination_list)
  log(bWriteLog and string.format("OutfitCombinationHandler.on_get_outfit_combinations_use_times_rsp res: %s", res))
  log_tree("combination_list", combination_list)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  logic_outfit_combination:OnOutfitCombinationsUseTimes(combination_list)
end
function OutfitCombinationHandler.send_open_combinations_daily_random_req(is_open)
  log(bWriteLog and string.format("OutfitCombinationHandler.send_open_combinations_daily_random_req is_open: %s", is_open))
  NetManager.SendPkg(1702933735, is_open)
end
function OutfitCombinationHandler.on_open_combinations_daily_random_rsp(res, is_open)
  log(bWriteLog and string.format("OutfitCombinationHandler.on_open_combinations_daily_random_rsp res: %s, is_open: %s", res, is_open))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  logic_outfit_combination:OnDailyRandomOutfitCombination(is_open)
end
function OutfitCombinationHandler.send_get_outfit_filter_tags_req()
  NetManager.SendPkg(143976487)
end
function OutfitCombinationHandler.on_get_outfit_filter_tags_rsp(res, filter_info)
  log(bWriteLog and string.format("OutfitCombinationHandler.on_get_outfit_filter_tags_rsp res: %s", res))
  log_tree("filter_info", filter_info)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  logic_outfit_combination:OnOutfitFilterTags(filter_info)
end
function OutfitCombinationHandler.send_set_outfit_filter_tags_req(filter_info)
  log(bWriteLog and string.format("OutfitCombinationHandler.send_set_outfit_filter_tags_req filter_info"))
  log_tree("filter_info", filter_info)
  NetManager.SendPkg(1667835303, filter_info)
end
function OutfitCombinationHandler.on_set_outfit_filter_tags_rsp(res)
  log(bWriteLog and string.format("OutfitCombinationHandler.on_set_outfit_filter_tags_rsp res: %s", res))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
end
return OutfitCombinationHandler