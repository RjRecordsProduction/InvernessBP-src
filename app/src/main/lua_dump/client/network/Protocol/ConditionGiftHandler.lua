local NetManager = require("client.network.comm.NetManager")
local ConditionGiftHandler = {}
function ConditionGiftHandler.send_get_cond_page_active_days_req(ss)
  NetManager.SendPkg(697384539, ss)
end
function ConditionGiftHandler.on_get_cond_page_active_days_rsp(errcode, active_days, unlock_tbl)
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  log_tree("on_get_cond_page_active_days_rsp:", active_days)
  local logic_special_offer_condition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_condition)
  logic_special_offer_condition:SetLoginDays(active_days, unlock_tbl)
end
function ConditionGiftHandler.on_notify_active_days_change()
  local logic_special_offer_condition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_condition)
  logic_special_offer_condition:OnGetLoginDaysReq(true)
end
function ConditionGiftHandler.send_unlock_cond_page_by_group_req(group_id, total_price)
  NetManager.SendPkg(109215127, group_id, total_price)
end
function ConditionGiftHandler.on_unlock_cond_page_by_group_rsp(err_code, group_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
end
function ConditionGiftHandler.on_notify_cond_page_unlock_success(group_id)
  local logic_special_offer_condition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_condition)
  logic_special_offer_condition:UpdateSkipLoginIdList(group_id)
end
return ConditionGiftHandler