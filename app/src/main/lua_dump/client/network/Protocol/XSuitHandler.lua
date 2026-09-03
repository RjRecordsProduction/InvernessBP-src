local NetManager = require("client.network.comm.NetManager")
local XSuitHandler = {}
function XSuitHandler.send_get_gold_dress_activity_req()
  NetManager.SendPkg(746699151)
end
function XSuitHandler.on_get_gold_dress_activity_rsp(err_code, draw_info)
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  logic_xsuit_activity:OnGetDrawActivityInfo(err_code, draw_info)
end
function XSuitHandler.send_draw_gold_dress_req(cost_times, currency_id, voucher_id, pool_id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SPIN_STOP_COIN_UPDATE)
  NetManager.SendPkg(1099270815, cost_times, currency_id, voucher_id, pool_id)
end
function XSuitHandler.on_draw_gold_dress_rsp(err_code, item_list, decompose_list, pool_accumulate_info, pool_draw_times, is_can_first, accumulate_coin_count)
  log(bWriteLog and "XSuitHandler.on_draw_gold_dress_rsp err_code = " .. tostring(err_code))
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if err_code ~= 0 then
    ShowNotice(err_code)
    LogicXSuit.ShowErrCode(err_code)
    return
  end
  if err_code == 0 then
    log_tree("XSuitHandler.on_draw_gold_dress_rsp = ", item_list)
    local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
    logic_xsuit_activity:SetAccumulateStateInfo(pool_accumulate_info)
    logic_xsuit_activity:SetAccumulateDrawTime(pool_draw_times)
    logic_xsuit_activity:SetAccumulateCoinCount(accumulate_coin_count)
    log(bWriteLog and "xcc XSuitHandler.on_draw_gold_dress_rsp is_can_first" .. tostring(is_can_first))
    logic_xsuit_activity:SetIsFirstDiscount(is_can_first)
    XSuitHandler.send_get_gold_dress_activity_req()
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SPIN_STOP_COIN_UPDATE_TIMER)
    EventSystem:postEvent(EVENTTYPE_XSUIT, EVENTID_XSUIT_SPIN_DRAW_RSP, item_list, decompose_list)
  end
end
function XSuitHandler.send_get_rise_star_info_req(id)
  NetManager.SendPkg(936041735, id)
end
function XSuitHandler.on_get_rise_star_info_rsp(err_code, open, info_table, unlock_info)
  if err_code ~= 0 then
    log(bWriteLog and "XSuitHandler.on_get_rise_star_info_rsp error code = " .. tostring(err_code))
    return
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  LogicXSuit.OnGetXSuitDrawInfo(open, info_table, unlock_info)
end
function XSuitHandler.send_rise_star_req(id, item_id)
  NetManager.SendPkg(1249575219, id, item_id)
end
function XSuitHandler.on_rise_star_rsp(err_code, cur_level, period)
  log(bWriteLog and "on_rise_star_rsp err_code = " .. tostring(err_code) .. " || cur_level = " .. tostring(cur_level))
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if err_code ~= 0 then
    LogicXSuit.ShowErrCode(err_code)
    return
  end
  local baseInfo = LogicXSuit.GetBaseInfo(period)
  if baseInfo then
    baseInfo.now_level = cur_level
  end
  XSuitHandler.send_get_rise_star_info_req()
  EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPGRADE_SUCCESS, cur_level, period)
  LogicXSuit.ShowUpgradeSuccessUI(cur_level, period)
end
function XSuitHandler.send_get_give_condtion_req()
  NetManager.SendPkg(1056513879)
end
function XSuitHandler.on_get_give_condtion_rsp(err_code, friend_time, friend_intimacy, role_level)
  if err_code ~= 0 then
    return
  end
  local t = {
    friend_time = friend_time,
    friend_intimacy = friend_intimacy,
      }
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  LogicXSuit.SetSendCondtionInfo(t)
end
XSuitHandler.open_instid = nil
function XSuitHandler.send_open_gold_dress_req(instid, state)
  XSuitHandler.open_  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = WardrobeData:GetHallDepotItemDataByInsID(instid)
  XSuitHandler.res_id = itemInfo.resID
  NetManager.SendPkg(413309359, instid, state)
end
function XSuitHandler.on_open_gold_dress_rsp(err_code, info)
  if not XSuitHandler.open_instid then
    return
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local instid = XSuitHandler.open_instid
  XSuitHandler.open_instid = nil
  if err_code == 100170010 then
    LogicXSuit.TipDecompose(instid, info)
  else
    local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
    local period_id = logic_xsuit_activity:GetPeriodByCardItem(XSuitHandler.res_id, XSuitHandler.res_id, XSuitHandler.res_id)
    local itemId = LogicXSuit.GetSuitItemIDByPeriod(period_id)
    if not itemId then
      return
    end
    local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemInfo = WardrobeData:GetHallDepotItemDataByResID(itemId)
    if not itemInfo then
      return
    end
    local itemList = {}
    local itemData = {
      res_id = itemInfo.resID,
      count = 1,
      valid_hours = 0,
      expire_ts = 0,
      color_id = 0,
      pattern_id = 0
    }
    table.insert(itemList, itemData)
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(itemList)
    XSuitHandler.res_id = nil
    EventSystem:postEvent(EVENTTYPE_XSUIT, EVENTID_XSUIT_MEMORY_OPEN)
  end
end
function XSuitHandler.send_change_emtion_action_req(action_id)
  log(bWriteLog and "XSuitHandler.send_change_emtion_action_req id = " .. tostring(action_id))
  NetManager.SendPkg(980620199, action_id)
end
function XSuitHandler.on_change_emtion_action_rsp(err_code)
end
function XSuitHandler.on_notify_change_emtion_action(inviter_id, action_id)
  log(bWriteLog and "XSuitHandler.on_notify_change_emtion_action inviter_id = " .. tostring(inviter_id) .. " || action_id = " .. tostring(action_id))
  if IsWoWEditor then
    return
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if action_id == 12215504 then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local tRoleWear = AvatarData.GetRoleWear()
    for _, v in pairs(tRoleWear) do
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if itemInfo then
        local id = itemInfo.resID
        if id and LogicXSuit.IsMuNaiYiBlockItem(id) then
          log(bWriteLog and "XSuitHandler.on_notify_change_emtion_action IsMuNaiYiBlockItem!  " .. tostring(id))
          return
        end
      end
    end
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    log(bWriteLog and "XSuitHandler.on_notify_change_emtion_action  not lobby")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.golden_suit_invite_tip, action_id, inviter_id)
end
function XSuitHandler.send_emtion_action_reply_req(is_play, action_id, random_sound_id, inviter_id)
  log(bWriteLog and "XSuitHandler.send_emtion_action_reply_req " .. tostring(is_play) .. " || action_id = " .. tostring(action_id))
  NetManager.SendPkg(880490923, is_play, action_id, random_sound_id, inviter_id)
end
function XSuitHandler.on_emtion_action_reply_rsp(err_code)
end
function XSuitHandler.send_wear_gold_dress_req(status, itemid)
  NetManager.SendPkg(2093412579, status, itemid)
end
function XSuitHandler.on_wear_gold_dress_rsp(err_code)
  if err_code ~= 0 then
    log(bWriteLog and "XSuitHandler.on_wear_gold_dress_rsp error code = " .. tostring(err_code))
  end
end
function XSuitHandler.on_team_update_gold_dress(uid, itemid, status)
  log(bWriteLog and "on_team_update_gold_dress uid = " .. tostring(uid) .. " || itemid = " .. tostring(itemid) .. " || status = " .. tostring(status))
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  LogicXSuit.OnRelicStatusChange(tostring(uid), itemid, status)
  EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_REFRESH_RELIC_STATUS)
end
function XSuitHandler.send_set_wish_pool_id_req(pool_id)
  NetManager.SendPkg(1261786215, pool_id)
end
function XSuitHandler.on_set_wish_pool_id_rsp(err_code, pool_id)
  log(bWriteLog and "XSuitHandler.on_set_wish_pool_id_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  logic_xsuit_activity:SetWishPoolID(pool_id)
  EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_LOTTERY_UPDATE_WISHPOOL)
end
function XSuitHandler.send_get_wish_pool_req()
  log(bWriteLog and "XSuitHandler.send_get_wish_pool_req")
  NetManager.SendPkg(248126303)
end
function XSuitHandler.on_get_wish_pool_rsp(res, wish_pool)
  log(bWriteLog and "XSuitHandler.on_get_wish_pool_rsp res = " .. res)
  if res ~= 0 then
    return
  end
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  logic_xsuit_activity:SetWishPoolID(wish_pool == 0 and 1001 or wish_pool)
  EventSystem:postEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_LOTTERY_UPDATE_WISHPOOL)
end
function XSuitHandler.send_do_onshot_exchange_by_activity_id_req(activity_id, award_item_list)
  NetManager.SendPkg(2120963335, activity_id, award_item_list)
end
function XSuitHandler.on_do_onshot_exchange_by_activity_id_rsp(err_code, my_activity_data, award_list, activity_id)
  if err_code == 0 then
    local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
    LuckybackActivitySystem.do_exchange_by_activity_id_rsp(err_code, my_activity_data, award_list, activity_id)
  else
    log_error("XSuitHandler.on_do_onshot_exchange_by_activity_id_rsp err_code: " .. tostring(err_code))
  end
end
function XSuitHandler.send_set_gold_dress_new_level_req(periodic_id, level_id)
  NetManager.SendPkg(1293078951, periodic_id, level_id)
end
function XSuitHandler.on_set_gold_dress_new_level_rsp(err_code, periodic_id, level_id)
  if err_code == 0 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.OnSetGoldDressNewLevelRsp(periodic_id, level_id)
  else
    log_error("XSuitHandler.on_set_gold_dress_new_level_rsp err_code: " .. tostring(err_code))
  end
end
function XSuitHandler.send_get_gold_dress_new_level_req()
  NetManager.SendPkg(1624245415)
end
function XSuitHandler.on_get_gold_dress_new_level_rsp(err_code, set_info)
  if err_code == 0 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.OnGetGoldDressNewLevelRsp(set_info)
  else
    log_error("XSuitHandler.on_get_gold_dress_new_level_rsp err_code: " .. tostring(err_code))
  end
end
function XSuitHandler.send_unlock_gold_dress_state_req(period, itemid, state)
  NetManager.SendPkg(2016980015, period, itemid, state)
end
function XSuitHandler.on_unlock_gold_dress_state_rsp(err_code, info)
  if err_code == 0 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.OnUnlockGoldDressStateRsp(info)
  else
    if err_code == 100170122 then
      ShowNotice(40036)
    end
    log_error("XSuitHandler.on_unlock_gold_dress_state_rsp err_code: " .. tostring(err_code))
  end
end
function XSuitHandler.send_set_gold_dress_state_req(period, state, source)
  NetManager.SendPkg(1938023015, period, state, source)
end
function XSuitHandler.on_set_gold_dress_state_rsp(err_code, info, source)
  if err_code == 0 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.OnSetGoldDressStateRsp(info, source)
  else
    log_error("XSuitHandler.on_set_gold_dress_state_rsp err_code: " .. tostring(err_code))
  end
end
function XSuitHandler.send_get_gold_dress_state_req()
  NetManager.SendPkg(139747687)
end
function XSuitHandler.on_get_gold_dress_state_rsp(err_code, info, inherit_all_state_info)
  log_tree("XSuitHandler.on_get_gold_dress_state_rsp", {
    err_code,
    info,
    inherit_all_state_info
  })
  if err_code == 0 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.OnGetGoldDressStateRsp(info, inherit_all_state_info)
  else
    log_error("XSuitHandler.on_get_gold_dress_state_rsp err_code: " .. tostring(err_code))
  end
end
function XSuitHandler.on_refresh_gold_dress_state_rsp(err_code, info)
  if err_code == 0 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.onRefreshGoldDressStateRsp(info)
  else
    log_error("XSuitHandler.on_get_gold_dress_state_rsp err_code: " .. tostring(err_code))
    ShowNotice(err_code)
  end
end
function XSuitHandler.send_unlock_gold_dress_level_feature_req(period, level, index)
  NetManager.SendPkg(1297130967, period, level, index)
end
function XSuitHandler.on_unlock_gold_dress_level_feature_rsp(err_code, period, level, index, gold_dress_set_info_all)
  if err_code == 0 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.on_unlock_gold_dress_level_feature_rsp(period, level, index, gold_dress_set_info_all)
  else
    log_error("XSuitHandler.on_unlock_gold_dress_level_feature_rsp err_code: " .. tostring(err_code))
    if err_code == 100170124 then
      ShowNotice(40036)
    end
  end
end
function XSuitHandler.send_get_accumulate_pool_reward_req(pool_id, times, opt_flag, is_take_all)
  NetManager.SendPkg(1910843783, pool_id, times, opt_flag, is_take_all)
end
function XSuitHandler.on_get_accumulate_pool_reward_rsp(err_code, times_info_conf, pool_accumulate_info, decompose_list)
  log(bWriteLog and "XSuitHandler.on_get_accumulate_pool_reward_rsp  " .. tostring(err_code))
  local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
  if err_code == 0 then
    logic_xsuit_activity:on_get_accumulate_pool_reward_rsp(times_info_conf, pool_accumulate_info, decompose_list)
  elseif err_code == 100170125 then
    local decomposeInfo = times_info_conf
    local reqInfo = pool_accumulate_info
    local resId = logic_xsuit_activity:GetXSuitOneLevelID()
    local itemCfg = CDataTable.GetTableData("Item", resId)
    local decomposeItemCfg = CDataTable.GetTableData("Item", decomposeInfo.resid)
    local title = LocUtil.GetLocalizeResStr(5077)
    local tip = LocUtil.LocalizeResFormat(9975, itemCfg.ItemName, decomposeItemCfg.ItemName, decomposeInfo.count, itemCfg.ItemName)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tip, function()
      XSuitHandler.send_get_accumulate_pool_reward_req(reqInfo.pool_id, nil, 1, true)
    end)
  end
end
function XSuitHandler.send_unlock_xsuit_glide_req(resid)
  NetManager.SendPkg(169817159, resid)
end
function XSuitHandler.on_unlock_xsuit_glide_rsp(err_code, resid)
  if err_code == 0 then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local allData = {
      [1] = {
        res_id = resid,
        count = 1,
        valid_hours = 0,
        expire_time = 0
      }
    }
    Logic_CommonItemGet.ShowPanel_FullCustom(allData, {})
    EventSystem:postEvent(EVENTTYPE_XSUIT, EVENTID_XSUIT_GLIDE_UNLOCK)
  else
    ShowNotice(err_code)
  end
end
function XSuitHandler.send_gold_dress_get_level_action_req()
  NetManager.SendPkg(1151944727)
end
function XSuitHandler.on_gold_dress_get_level_action_rsp(err_code, info)
  if err_code == 0 then
    log_tree("XSuitHandler.on_gold_dress_get_level_action_rsp ", info)
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.levelAction = info or {}
    EventSystem:postEvent(EVENTTYPE_XSUIT, EVENTID_XSUIT_LEVEL_ACTION_UPDATE)
  else
    ShowNotice(err_code)
  end
end
function XSuitHandler.send_gold_dress_set_level_action_req(period_id, action_type)
  NetManager.SendPkg(1441847655, period_id, action_type)
end
function XSuitHandler.on_gold_dress_set_level_action_rsp(err_code, period_id, action_type)
  if err_code == 0 then
    log(bWriteLog and "XSuitHandler.on_gold_dress_set_level_action_rsp " .. tostring(period_id) .. "  " .. tostring(action_type))
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.levelAction[period_id] = action_type
    EventSystem:postEvent(EVENTTYPE_XSUIT, EVENTID_XSUIT_LEVEL_ACTION_UPDATE)
  else
    ShowNotice(err_code)
  end
end
function XSuitHandler.send_gold_dress_flag_operation_req(period_id, level_id, index, operation_type, flag_value)
  log(bWriteLog and "XSuitHandler.send_gold_dress_flag_operation_req period_id:" .. tostring(period_id) .. "  level_id:" .. tostring(level_id) .. "  index:" .. tostring(index) .. "  operation_type:" .. tostring(operation_type) .. "  flag_value:" .. tostring(flag_value))
  NetManager.SendPkg(1126377351, period_id, level_id, index, operation_type, flag_value)
end
function XSuitHandler.on_gold_dress_flag_operation_rsp(err_code, info)
  log_tree(bWriteLog and "XSuitHandler.on_gold_dress_flag_operation_rsp ", info)
  if err_code == 0 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.SetRunAction(info)
  else
    log(bWriteLog and "XSuitHandler.on_gold_dress_flag_operation_rsp " .. tostring(err_code))
  end
end
return XSuitHandler