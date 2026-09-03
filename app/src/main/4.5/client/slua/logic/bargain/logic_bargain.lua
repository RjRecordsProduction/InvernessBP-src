local logic_bargain = {}
logic_bargain.SERVER_STATUS = {
  NEW = 0,
  ACTIVE = 1,
  BOUGHT = 2
}
logic_bargain.BARGAIN_STATUS = {
  NEW = 1,
  CUTTING = 2,
  READY_TO_BUY = 3,
  BOUGHT = 4,
  OFFLINE_BUYABLE = 5,
  OFFLINE_CANNOT_BUY = 6
}
logic_bargain.SHOW_STATUS_PRIORITY = {
  [logic_bargain.BARGAIN_STATUS.READY_TO_BUY] = 1,
  [logic_bargain.BARGAIN_STATUS.CUTTING] = 2,
  [logic_bargain.BARGAIN_STATUS.NEW] = 3,
  [logic_bargain.BARGAIN_STATUS.BOUGHT] = 4,
  [logic_bargain.BARGAIN_STATUS.OFFLINE_BUYABLE] = 5
}
logic_bargain.ORDER_TAB = {
  ALL = 1,
  READY_TO_BUY = 2,
  CUTTING = 3,
  BOUGHT = 4,
  OFFLINE = 5
}
logic_bargain.TASK_TYPE = {DAILY = 1, CHALLENGE = 2}
logic_bargain.CANNOT_HELP_REASON = {
  OK = 0,
  ALREADY_HELPED = 1,
  OWNER_LIMIT = 2,
  HELPER_LIMIT = 3,
  AT_FLOOR = 4,
  BOUGHT = 5
}
logic_bargain.DEPOSIT_DEDUCTION_VOUCHER_ID = {
  [1006] = 1660001,
  [1000] = 1660002,
  [1109] = 1660003,
  [1001] = 1660004,
  [1703072] = 1660005,
  [1702149] = 1660006,
  [1702150] = 1660007,
  [1702151] = 1660008,
  [1702152] = 1660009,
  [1702153] = 1660010,
  [1702154] = 1660011,
  [1702155] = 1660012,
  [1101] = 1660013
}
logic_bargain.VOUCHER_TO_COST_ID = {
  [1660001] = 1006,
  [1660002] = 1000,
  [1660003] = 1109,
  [1660004] = 1001,
  [1660005] = 1703072,
  [1660006] = 1702149,
  [1660007] = 1702150,
  [1660008] = 1702151,
  [1660009] = 1702152,
  [1660010] = 1702153,
  [1660011] = 1702154,
  [1660012] = 1702155,
  [1660013] = 1101
}
logic_bargain.SHOW_ICON_NAME = {
  [1006] = "UC_New",
  [1000] = "BP_New",
  [1109] = "AG_New",
  [1001] = "Silver_New",
  [1703072] = "Currency_ScrapGold",
  [1702149] = "RedCrystal",
  [1702150] = "BlueCrystal",
  [1702151] = "TiffanyBlueCrystal",
  [1702152] = "OrangeGreenCrystal",
  [1702153] = "BlueWhiteCrystal",
  [1702154] = "OrangeCrystal",
  [1702155] = "GreenWhiteCrystal",
  [1101] = "Donkatsu_New"
}
local hasShowGuide
local NEAR_FLOOR_PROGRESS_THRESHOLD = 85
local RoundAmount = function(v)
  if not v or v == 0 then
    return 0
  end
  return math.floor(v + 0.5)
end
logic_bargain.local ReportBargainTLog = function(action, extras)
  if type(action) ~= "number" then
    log_error(bWriteLog and "logic_bargain:ReportBargainTLog - invalid action: " .. tostring(action))
    return
  end
  extras = extras or {}
  local parts = {}
  if extras.extra1 ~= nil then
    parts[#parts + 1] = "extra1=" .. tostring(extras.extra1)
  end
  if extras.extra2 ~= nil then
    parts[#parts + 1] = "extra2=" .. tostring(extras.extra2)
  end
  if extras.extra3 ~= nil then
    parts[#parts + 1] = "extra3=" .. tostring(extras.extra3)
  end
  if extras.extra4 ~= nil then
    parts[#parts + 1] = "extra4=" .. tostring(extras.extra4)
  end
  local reason_str = "{" .. table.concat(parts, ",") .. "}"
  log(bWriteLog and string.format("logic_bargain:ReportBargainTLog - action=%d reason_str=%s", action, reason_str))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewBargainActivity, action, reason_str)
end
logic_bargain.
function logic_bargain:DefineAndResetData()
  log(bWriteLog and "logic_bargain:DefineAndResetData")
  self.bargain_orders = {}
  self.gifts_config = {}
  self.task_pool_config = {}
  self.activity_durations = {}
  self.region_config = {}
  self.helper_award = {}
  self.buy_award = {}
  self.task_list_cache = {}
  self.activated_orders = {}
  self.help_given_list = nil
  self.chat_data = {}
  self.focus_package_id = nil
  self.help_cut_limit = 0
  self.today_help_cut_count = 0
  self.nActStartTime = nil
  self.nGiftMaxStartTime = nil
  self.redData = nil
  self.popupData = {}
  self.pending_feedback_package_ids = {}
  self.pending_activate_bargain_id = nil
end
function logic_bargain:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    local BargainHandler = RequireMod("client.network.Protocol.BargainHandler")
    BargainHandler.send_get_bargain_simple_info_req()
    BargainHandler.send_get_bargain_info_req()
  end
end
function logic_bargain:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_AT_FLOOR_PRICE, self.OnBargainAtFloorPrice, self)
end
function logic_bargain:OnBargainAtFloorPrice(_, _, package_id)
  if not package_id or package_id == 0 then
    return
  end
  log(bWriteLog and "logic_bargain:OnBargainAtFloorPrice package_id=" .. tostring(package_id))
  self:EnqueuePendingFeedback(package_id)
  self:_ShowAtFloorPopup(package_id)
end
function logic_bargain:EnqueuePendingFeedback(package_id)
  self.pending_feedback_package_ids = self.pending_feedback_package_ids or {}
  for _, v in ipairs(self.pending_feedback_package_ids) do
    if v == package_id then
      return
    end
  end
  table.insert(self.pending_feedback_package_ids, package_id)
end
function logic_bargain:DequeuePendingFeedback()
  self.pending_feedback_package_ids = self.pending_feedback_package_ids or {}
  return table.remove(self.pending_feedback_package_ids, 1)
end
function logic_bargain:ClearPendingFeedbackQueue()
  self.pending_feedback_package_ids = {}
end
function logic_bargain:RemovePendingFeedbackByPackageId(package_id)
  if not package_id then
    return
  end
  self.pending_feedback_package_ids = self.pending_feedback_package_ids or {}
  for i = #self.pending_feedback_package_ids, 1, -1 do
    if self.pending_feedback_package_ids[i] == package_id then
      table.remove(self.pending_feedback_package_ids, i)
    end
  end
end
function logic_bargain:CollectPendingFeedbackOnEnterTab()
  self.pending_feedback_package_ids = self.pending_feedback_package_ids or {}
  self:LoadPopupData()
  for bargain_id, order in pairs(self.bargain_orders or {}) do
    if not self.popupData[bargain_id] then
      local cfg_id = order.cfg_id
      local status = self:GetGiftStatus(cfg_id)
      local should_pop = false
      if status == self.BARGAIN_STATUS.READY_TO_BUY then
        should_pop = true
      elseif status == self.BARGAIN_STATUS.CUTTING and self:GetBargainProgress(cfg_id) >= NEAR_FLOOR_PROGRESS_THRESHOLD then
        should_pop = true
      end
      if should_pop then
        self:EnqueuePendingFeedback(cfg_id)
        self.popupData[bargain_id] = true
      end
    end
  end
  if next(self.pending_feedback_package_ids) then
    self:SavePopupData()
  end
end
function logic_bargain:ShowNextPendingFeedback()
  local package_id = self:DequeuePendingFeedback()
  if not package_id then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Discount_Feedback_Popup_UIBP, package_id)
end
function logic_bargain:OnGetBargainInfo(bargain_orders, buy_records)
  log(bWriteLog and "logic_bargain:OnGetBargainInfo")
  self.bargain_orders = self:_FilterOrdersByRegion(bargain_orders)
  self.buy_records = buy_records or {}
  self:RefreshActivityTime()
  self:LoadRedData()
  if self.nActStartTime and self.redData.popupActStartTime ~= self.nActStartTime then
    self.popupData = {}
    self:SavePopupData()
  else
    self:LoadPopupData()
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_GET_INFO)
  self:TryTriggerCanBuyPopup()
  self:_PostRedDotChange()
end
function logic_bargain:_FilterOrdersByRegion(orders)
  if not orders or not next(orders) then
    return {}
  end
  if not self.gifts_config or not next(self.gifts_config) then
    return orders
  end
  local filtered = {}
  for bid, order in pairs(orders) do
    local cfg_id = order and order.cfg_id
    if not cfg_id then
      filtered[bid] = order
    elseif self.gifts_config[cfg_id] then
      filtered[bid] = order
    else
      log(bWriteLog and string.format("logic_bargain:_FilterOrdersByRegion - drop order bid=%s cfg_id=%s (not in filtered gifts_config)", tostring(bid), tostring(cfg_id)))
    end
  end
  return filtered
end
function logic_bargain:OnGetBargainSimpleInfo(activity_durations, gifts_config, task_pool_config, helper_award, buy_award)
  log(bWriteLog and "logic_bargain:OnGetBargainSimpleInfo")
  self.activity_durations = activity_durations or {}
  self.gifts_config = self:_FilterGiftsByRegion(gifts_config) or {}
  self.helper_award = helper_award or {}
  self.buy_award = buy_award or {}
  self.task_pool_config = {}
  if task_pool_config then
    for pool_id, task_array in pairs(task_pool_config) do
      local pool_map = {}
      for _, task_cfg in pairs(task_array) do
        if task_cfg and task_cfg.task_id then
          pool_map[task_cfg.task_id] = task_cfg
        end
      end
      self.task_pool_config[pool_id] = pool_map
    end
  end
  local maxStartTime = 0
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  for _, cfg in pairs(self.gifts_config) do
    if cfg.begin_time and now >= cfg.begin_time and maxStartTime < cfg.begin_time then
      maxStartTime = cfg.begin_time
    end
  end
  self.nGiftMaxStartTime = maxStartTime
  self:RefreshActivityTime()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_SIMPLE_INFO_UPDATE)
  self:_PostRedDotChange()
end
function logic_bargain:_FilterGiftsByRegion(gifts)
  if not gifts or not next(gifts) then
    return {}
  end
  if not self.region_config or not next(self.region_config) then
    return gifts
  end
  local filtered = {}
  for pid, cfg in pairs(gifts) do
    if cfg then
      if not (cfg.regions and next(cfg.regions)) or cfg.regions[0] then
        filtered[pid] = cfg
      else
        local my_uid = DataMgr and DataMgr.roleData and DataMgr.roleData.uid or nil
        if not my_uid then
          filtered[pid] = cfg
        else
          local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
          local my_profile = logic_profile and logic_profile:GetLocalProfile(my_uid) or nil
          local my_region = my_profile and my_profile.region or nil
          if not my_region or my_region == "" then
            filtered[pid] = cfg
          else
            local my_group_id = self.region_config[my_region]
            if my_group_id == nil then
              filtered[pid] = cfg
            elseif cfg.regions[my_group_id] then
              filtered[pid] = cfg
            else
              log(bWriteLog and string.format("logic_bargain:_FilterGiftsByRegion - drop gift pid=%s (region=%s group_id=%s not in regions)", tostring(pid), tostring(my_region), tostring(my_group_id)))
            end
          end
        end
      end
    end
  end
  return filtered
end
function logic_bargain:OnFriendCutNotify(bargain_id, package_id, helper_uid, cut_amount, current_price)
  local was_near_or_over = self:_IsNearOrOverFloor(package_id)
  local order = self.bargain_orders[bargain_id]
  if order then
    order.    order.friend_cuts = order.friend_cuts or {}
    local TimeUtil = require("client.common.time_util")
    table.insert(order.friend_cuts, {
      uid = helper_uid,
      amount = cut_amount,
      time = TimeUtil.GetServerTimeInSec()
    })
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_FRIEND_CUT, bargain_id, package_id, helper_uid, cut_amount, current_price)
  self:SetFriendCutRedDot(true, bargain_id)
  local cfg = self.gifts_config[package_id]
  local floor = cfg and cfg.floor_price or 0
  if current_price > floor then
    if not was_near_or_over and self:_IsNearOrOverFloor(package_id) then
      self:_ShowNearFloorPopup(package_id)
    else
      local helper_name = self:_GetUserName(helper_uid)
      if helper_name ~= "" then
        self:_ShowFriendCutPopup(package_id, helper_name, cut_amount)
      elseif helper_uid and helper_uid ~= 0 then
        local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
        logic_profile_get_wrap.GetNormalProfiles({helper_uid}, function(profile_list)
          local fetched_name = tostring(helper_uid)
          if profile_list and profile_list[1] and profile_list[1].nickName then
            fetched_name = profile_list[1].nickName
            log(bWriteLog and string.format("[Bargain] stranger profile fetched | uid=%s name=[%s]", tostring(helper_uid), tostring(fetched_name)))
          end
          self:_ShowFriendCutPopup(package_id, fetched_name, cut_amount)
        end, Enum_PROFILE_REPORT_CFG.BARGAIN_HELPER)
      else
        self:_ShowFriendCutPopup(package_id, "", cut_amount)
      end
    end
  end
  self:TryTriggerCanBuyPopup()
end
function logic_bargain:OnTaskCompleteNotify(bargain_id, package_id, task_id, cut_amount, current_price)
  local was_near_or_over = self:_IsNearOrOverFloor(package_id)
  local order = self.bargain_orders[bargain_id]
  if order then
    order.    order.task_cuts = order.task_cuts or {}
    local TimeUtil = require("client.common.time_util")
    table.insert(order.task_cuts, {
      task_id = task_id,
      amount = cut_amount,
      time = TimeUtil.GetServerTimeInSec()
    })
  end
  local task_data = self.task_list_cache[bargain_id]
  if task_data and task_data.task_list then
    for _, task in pairs(task_data.task_list) do
      if task.task_id == task_id then
        task.is_completed = true
        task.current_count = task.required_count
        break
      end
    end
    task_data.task_cut_total = (task_data.task_cut_total or 0) + cut_amount
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_TASK_COMPLETE, bargain_id, package_id, task_id, cut_amount, current_price)
  self:SetTaskRedDot(true, bargain_id)
  local cfg = self.gifts_config[package_id]
  local floor = cfg and cfg.floor_price or 0
  if current_price > floor and not was_near_or_over and self:_IsNearOrOverFloor(package_id) then
    self:_ShowNearFloorPopup(package_id)
  end
  self:TryTriggerCanBuyPopup()
end
function logic_bargain:ActivateBargainOrder(bargain_id)
  if not bargain_id or bargain_id == "" then
    return
  end
  local order = self.bargain_orders[bargain_id]
  if not order then
    return
  end
  if order.status ~= self.SERVER_STATUS.NEW then
    return
  end
  self.pending_activate_  local BargainHandler = RequireMod("client.network.Protocol.BargainHandler")
  if BargainHandler and BargainHandler.send_activate_bargain_order_req then
    BargainHandler.send_activate_bargain_order_req(bargain_id)
  end
end
function logic_bargain:OnActivateBargainOrderSucc()
  local bargain_id = self.pending_activate_bargain_id
  self.pending_activate_bargain_id = nil
  local BargainHandler = RequireMod("client.network.Protocol.BargainHandler")
  if BargainHandler and BargainHandler.send_get_bargain_info_req then
    BargainHandler.send_get_bargain_info_req()
  end
end
function logic_bargain:OnPurchaseSucc(bargain_id, package_id, cost_id, cost_amount, items)
  local order = self.bargain_orders[bargain_id]
  if order then
    order.status = self.SERVER_STATUS.BOUGHT
  end
  local chat_info = self.chat_data[bargain_id]
  if chat_info then
    chat_info.status = self.SERVER_STATUS.BOUGHT
  end
  self:ClearOrderRedDots(bargain_id)
  self:RemovePendingFeedbackByPackageId(package_id)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_PURCHASE, bargain_id, package_id, cost_id, cost_amount, items)
  if items and next(items) then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local item_list = {}
    for _, it in ipairs(items) do
      if it and it.item_id then
        table.insert(item_list, {
          res_id = it.item_id,
          count = it.item_count or 1
        })
      end
    end
    if next(item_list) then
      Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list)
    end
  end
  self:_PostRedDotChange()
end
function logic_bargain:OnBatchGetBargainInfo(bargain_data)
  if bargain_data then
    for bargain_id, info in pairs(bargain_data) do
      self.chat_data[bargain_id] = info
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_GET_CHAT_INFO, bargain_data)
end
function logic_bargain:OnGetBargainTaskList(bargain_id, package_id, is_first_activate, task_cut_total, task_cut_limit, task_list)
  if not bargain_id or not package_id then
    return
  end
  self.task_list_cache[bargain_id] = {
    package_id = package_id,
    task_cut_total = task_cut_total or 0,
    task_cut_limit = task_cut_limit or 0,
    task_list = task_list or {}
  }
  if is_first_activate then
    self.activated_orders[bargain_id] = true
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_TASK_LIST_UPDATE, bargain_id, package_id, is_first_activate)
end
function logic_bargain:OnGetHelpGivenList(help_given, global_info)
  self.help_given_list = help_given or {}
  if global_info then
    self.help_cut_limit = global_info.help_cut_limit or 0
    self.today_help_cut_count = global_info.today_help_cut_count or 0
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_HELP_CUT_DETAIL_UPDATE, help_given)
end
function logic_bargain:OnDoHelpCutSucc(bargain_id, package_id, cut_amount, today_help_cut_count)
  self.today_help_cut_count = today_help_cut_count or self.today_help_cut_count + 1
  local old_total_help_count = self.help_given_list and #self.help_given_list or 0
  local BargainHandler = RequireMod("client.network.Protocol.BargainHandler")
  if BargainHandler and BargainHandler.send_get_help_cut_detail_req then
    BargainHandler.send_get_help_cut_detail_req()
  end
  if BargainHandler and BargainHandler.send_batch_get_bargain_info_req then
    BargainHandler.send_batch_get_bargain_info_req({bargain_id})
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_DO_HELP_CUT_SUCC, {
    bargain_id = bargain_id,
    package_id = package_id,
    cut_amount = cut_amount,
    today_help_cut_count = self.today_help_cut_count
  })
  local total_help_count = self.help_given_list and #self.help_given_list or 0
  if old_total_help_count == total_help_count then
    total_help_count = total_help_count + 1
  end
  self:_ShowMeHelpFriendPopup(bargain_id, package_id, cut_amount, total_help_count)
end
function logic_bargain:_ShowMeHelpFriendPopup(bargain_id, package_id, cut_amount, total_help_count)
  local cfg = self:GetGiftConfigById(package_id)
  local cost_id = cfg and cfg.cost_id or 0
  local gift_name = self:GetGiftName(package_id)
  local chat_info = self.chat_data[bargain_id]
  local order = self:GetOrderByBargainId(bargain_id)
  local owner_uid = order and order.owner_uid or chat_info and chat_info.owner_uid or 0
  local owner_name = self:_GetUserName(owner_uid)
  local helper_rewards = self:GetHelperRewards() or {}
  local reward_item_id, reward_count = 0, 0
  local before_count = total_help_count - 1
  for _, reward in pairs(helper_rewards) do
    local threshold = reward.threshold or 0
    if before_count < threshold and total_help_count >= threshold then
      reward_item_id = reward.reward_item_id or 0
      reward_count = reward.reward_count or 0
      break
    end
  end
  if reward_item_id ~= 0 then
    UIManager.ShowUI(UIManager.UI_Config.Discount_Bargain_UIBP, cut_amount, reward_item_id, reward_count, owner_name, owner_uid, gift_name, cost_id, package_id, total_help_count)
  else
    local amount_text = self:GetCostIconTag(cost_id) .. tostring(cut_amount)
    local _, cut_max = self:GetFriendCutRange(package_id)
    local is_super = cut_max and 0 < cut_max and cut_amount >= cut_max * 0.85
    local text_id = is_super and 167044 or 167043
    ShowNotice(LocUtil.LocalizeResFormat(text_id, owner_name, amount_text))
  end
end
function logic_bargain:OnDoHelpCutFail(err_code)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_DO_HELP_CUT_FAIL, err_code)
end
function logic_bargain:GetGiftConfigById(package_id)
  return self.gifts_config[package_id]
end
function logic_bargain:GetOrderByBargainId(bargain_id)
  return self.bargain_orders[bargain_id]
end
function logic_bargain:GetActiveOrderByPackageId(package_id)
  if not package_id then
    return nil
  end
  for _, order in pairs(self.bargain_orders) do
    if order.cfg_id == package_id and (order.status == self.SERVER_STATUS.ACTIVE or order.status == self.SERVER_STATUS.NEW) then
      return order
    end
  end
  return nil
end
function logic_bargain:GetOrderByCfgId(package_id)
  return self:GetActiveOrderByPackageId(package_id)
end
function logic_bargain:GetBoughtOrdersByPackageId(cfg_id)
  local list = {}
  if not cfg_id then
    return list
  end
  for _, order in pairs(self.bargain_orders) do
    if order.cfg_id == cfg_id and order.status == self.SERVER_STATUS.BOUGHT then
      table.insert(list, order)
    end
  end
  return list
end
function logic_bargain:GetChatInfoByBargainId(bargain_id)
  return self.chat_data[bargain_id]
end
function logic_bargain:HasHelpedBargain(bargain_id)
  if not bargain_id or bargain_id == "" then
    return false
  end
  if not self.help_given_list then
    return false
  end
  for _, record in ipairs(self.help_given_list) do
    if record.bargain_id == bargain_id then
      return true
    end
  end
  return false
end
function logic_bargain:GetMyHelpCutAmount(bargain_id)
  if not bargain_id or bargain_id == "" then
    return 0
  end
  if not self.help_given_list then
    return 0
  end
  local total = 0
  for _, record in ipairs(self.help_given_list) do
    if record.bargain_id == bargain_id then
      total = total + (record.cut_amount or 0)
    end
  end
  return total
end
function logic_bargain:GetHelpGivenList()
  return self.help_given_list
end
function logic_bargain:GetHelperListByBargainId(bargain_id)
  local order = self.bargain_orders[bargain_id]
  if not order or not order.friend_cuts then
    return {}
  end
  local uid_to_record = {}
  for _, cut in ipairs(order.friend_cuts) do
    local uid = cut.uid
    if uid then
      if not uid_to_record[uid] then
        uid_to_record[uid] = {
          uid = uid,
          cut_amount = 0,
          cut_time = cut.time
        }
      end
      uid_to_record[uid].cut_amount = uid_to_record[uid].cut_amount + (cut.amount or 0)
      if (cut.time or 0) < (uid_to_record[uid].cut_time or 0) then
        uid_to_record[uid].cut_time = cut.time
      end
    end
  end
  local list = {}
  for _, v in pairs(uid_to_record) do
    table.insert(list, v)
  end
  return list
end
function logic_bargain:GetFriendCutAmount(uid, bargain_id)
  if not uid or not bargain_id then
    return 0
  end
  local order = self.bargain_orders[bargain_id]
  if not order or not order.friend_cuts then
    return 0
  end
  local total = 0
  for _, cut in ipairs(order.friend_cuts) do
    if cut.uid == uid then
      total = total + (cut.amount or 0)
    end
  end
  return total
end
function logic_bargain:GetFriendCutTotalByBargainId(bargain_id)
  local order = self.bargain_orders[bargain_id]
  if not order or not order.friend_cuts then
    return 0
  end
  local total = 0
  for _, cut in ipairs(order.friend_cuts) do
    total = total + (cut.amount or 0)
  end
  return total
end
function logic_bargain:GetFriendCutCountByBargainId(bargain_id)
  local order = self.bargain_orders[bargain_id]
  if not order or not order.friend_cuts then
    return 0
  end
  local seen = {}
  local cnt = 0
  for _, cut in ipairs(order.friend_cuts) do
    if cut.uid and not seen[cut.uid] then
      seen[cut.uid] = true
      cnt = cnt + 1
    end
  end
  return cnt
end
function logic_bargain:GetTaskCutTotalByBargainId(bargain_id)
  local order = self.bargain_orders[bargain_id]
  if not order or not order.task_cuts then
    return 0
  end
  local total = 0
  for _, cut in ipairs(order.task_cuts) do
    total = total + (cut.amount or 0)
  end
  return total
end
function logic_bargain:GetTaskListCache(bargain_id)
  return self.task_list_cache[bargain_id]
end
function logic_bargain:GetTaskCfg(task_pool_id, task_id)
  if not task_pool_id or not task_id then
    return nil
  end
  local pool = self.task_pool_config[task_pool_id]
  if not pool then
    return nil
  end
  return pool[task_id]
end
function logic_bargain:GetBuyCount()
  local cnt = 0
  if self.buy_records then
    for _ in pairs(self.buy_records) do
      cnt = cnt + 1
    end
  end
  return cnt
end
function logic_bargain:GetGiftBoughtNum(cfg_id)
  if not cfg_id then
    return 0
  end
  local cnt = 0
  for _, order in pairs(self.bargain_orders) do
    if order.cfg_id == cfg_id and order.status == self.SERVER_STATUS.BOUGHT then
      cnt = cnt + 1
    end
  end
  return cnt
end
function logic_bargain:IsGiftLimited(package_id)
  local cfg = self.gifts_config[package_id]
  if not cfg then
    return false
  end
  local bought = self:GetGiftBoughtNum(package_id)
  return bought >= (cfg.limit or 1)
end
function logic_bargain:GetBoughtCostAmount(cfg_id)
  if not cfg_id or not self.buy_records then
    return 0
  end
  for _, record in pairs(self.buy_records) do
    if record.cfg_id == cfg_id and record.cost_amount then
      return record.cost_amount
    end
  end
  return 0
end
function logic_bargain:GetBoughtCostAmountByBargainId(bargain_id)
  if not bargain_id or bargain_id == "" or not self.buy_records then
    return 0
  end
  local record = self.buy_records[bargain_id]
  if record and record.cost_amount then
    return record.cost_amount
  end
  return 0
end
function logic_bargain:GetHelpCutLimit()
  return self.help_cut_limit or 0
end
function logic_bargain:GetTodayHelpCutCount()
  return self.today_help_cut_count or 0
end
function logic_bargain:GetTodayHelpCutRemaining()
  local limit = self:GetHelpCutLimit()
  if limit <= 0 then
    return 0
  end
  local remaining = limit - self:GetTodayHelpCutCount()
  return 0 < remaining and remaining or 0
end
function logic_bargain:IsHelpCutDailyLimitReached()
  local limit = self:GetHelpCutLimit()
  if limit <= 0 then
    return false
  end
  return limit <= self:GetTodayHelpCutCount()
end
function logic_bargain:GetTodayFriendCutAmount(bargain_id)
  local order = self.bargain_orders and self.bargain_orders[bargain_id]
  return order and order.today_friend_cut_price_sum or 0
end
function logic_bargain:GetTodayStrangerCutAmount(bargain_id)
  local order = self.bargain_orders and self.bargain_orders[bargain_id]
  return order and order.today_stranger_cut_price_sum or 0
end
function logic_bargain:GetTodayFriendCutRemainingByBargainId(bargain_id)
  local order = self.bargain_orders and self.bargain_orders[bargain_id]
  if not order then
    return -1
  end
  local cfg = self.gifts_config and self.gifts_config[order.cfg_id]
  if not cfg then
    return -1
  end
  local limit = cfg.friend_daily_price_limit or 0
  if limit <= 0 then
    return -1
  end
  local remaining = limit - self:GetTodayFriendCutAmount(bargain_id)
  return 0 < remaining and remaining or 0
end
function logic_bargain:GetTodayFriendCutRemaining(package_id)
  if not package_id then
    return -1
  end
  local order = self:GetActiveOrderByPackageId(package_id)
  if not order then
    return -1
  end
  return self:GetTodayFriendCutRemainingByBargainId(order.bargain_id)
end
function logic_bargain:IsFriendCutDailyAmountLimited(package_id)
  local remaining = self:GetTodayFriendCutRemaining(package_id)
  return remaining ~= -1 and remaining <= 0
end
function logic_bargain:GetTodayCutAmountTotal(bargain_id)
  return self:GetTodayFriendCutAmount(bargain_id) + self:GetTodayStrangerCutAmount(bargain_id)
end
function logic_bargain:GetTodayCutAmountLimitTotal(package_id)
  local cfg = self.gifts_config and self.gifts_config[package_id]
  if not cfg then
    return 0
  end
  return (cfg.friend_daily_price_limit or 0) + (cfg.stranger_daily_price_limit or 0)
end
function logic_bargain:GetTodayCutAmountRemainingByBargainId(bargain_id)
  local order = self.bargain_orders and self.bargain_orders[bargain_id]
  if not order then
    return -1
  end
  local limit = self:GetTodayCutAmountLimitTotal(order.cfg_id)
  if limit <= 0 then
    return -1
  end
  local remaining = limit - self:GetTodayCutAmountTotal(bargain_id)
  return 0 < remaining and remaining or 0
end
function logic_bargain:IsOrderTaskActivated(bargain_id)
  return self.activated_orders[bargain_id] == true
end
function logic_bargain:IsBargainTaskActivated(package_id)
  local order = self:GetActiveOrderByPackageId(package_id)
  return order and self:IsOrderTaskActivated(order.bargain_id) or false
end
function logic_bargain:GetMainGiftList()
  local list = {}
  local TimeUtils = require("client.common.time_util")
  local ServerTime = TimeUtils.GetServerTimeInSec()
  for package_id, cfg in pairs(self.gifts_config) do
    if self:IsGiftVisibleInRegion(package_id) then
      local giftStatus = self:GetGiftStatus(package_id)
      local bIsOffline = giftStatus == self.BARGAIN_STATUS.OFFLINE_CANNOT_BUY or giftStatus == self.BARGAIN_STATUS.OFFLINE_BUYABLE
      local bIsGiftOpen = ServerTime >= cfg.begin_time
      if not bIsOffline and bIsGiftOpen then
        local order = self:GetActiveOrderByPackageId(package_id)
        local bargain_id = order and order.bargain_id or ""
        table.insert(list, {cfg_id = package_id, bargain_id = bargain_id})
      end
    end
  end
  return list
end
function logic_bargain:GetCostIconName(cost_id)
  return self.SHOW_ICON_NAME[cost_id] or "UC_New"
end
function logic_bargain:GetCostIconTag(cost_id)
  local icon_name = self:GetCostIconName(cost_id)
  return "<img src=\"" .. icon_name .. "\"/>"
end
function logic_bargain:GetVoucherIdByCostId(cost_id)
  return self.DEPOSIT_DEDUCTION_VOUCHER_ID[cost_id]
end
function logic_bargain:GetVoucherConfigByCostId(cost_id)
  local voucher_id = self:GetVoucherIdByCostId(cost_id)
  if not voucher_id then
    return nil
  end
  return CDataTable.GetTableData("Item", voucher_id)
end
function logic_bargain:GetGiftCostId(cfg_id)
  local cfg = self.gifts_config[cfg_id]
  if cfg and cfg.cost_id then
    return cfg.cost_id
  end
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  return CoinMacro.Uc
end
function logic_bargain:GetBargainShowCfg()
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  local showCfg = {}
  if not self.gifts_config or not next(self.gifts_config) then
    table.insert(showCfg, CoinMacro.Uc)
    return showCfg
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local seenCost = {}
  local buyCfg = {}
  local voucherCfg = {}
  for _, gift_cfg in pairs(self.gifts_config) do
    local cost_id = gift_cfg.cost_id
    if cost_id and cost_id ~= CoinMacro.Uc and not seenCost[cost_id] and gift_cfg.begin_time and gift_cfg.end_time and serverTime > gift_cfg.begin_time and serverTime < gift_cfg.end_time then
      seenCost[cost_id] = true
      table.insert(buyCfg, cost_id)
      local voucher_id = self.DEPOSIT_DEDUCTION_VOUCHER_ID[cost_id]
      if voucher_id then
        table.insert(voucherCfg, voucher_id)
      end
    end
  end
  table.insert(showCfg, CoinMacro.DepositDeductionVoucher)
  for _, v in ipairs(voucherCfg) do
    table.insert(showCfg, v)
  end
  for _, v in ipairs(buyCfg) do
    table.insert(showCfg, v)
  end
  table.insert(showCfg, CoinMacro.Uc)
  return showCfg
end
function logic_bargain:GetCurPrice(package_id)
  local order = self:GetActiveOrderByPackageId(package_id)
  if order and order.current_price and order.current_price > 0 then
    return order.current_price
  end
  local cfg = self.gifts_config[package_id]
  return cfg and cfg.original_price or 0
end
function logic_bargain:GetBargainProgress(package_id)
  local cfg = self.gifts_config[package_id]
  if not cfg then
    return 0
  end
  local origin = cfg.original_price or 0
  local floor = cfg.floor_price or 0
  local cur = self:GetCurPrice(package_id)
  if origin <= floor then
    return 100
  end
  local cut_total = origin - cur
  local cut_max = origin - floor
  if cut_total <= 0 then
    return 0
  end
  if cut_total >= cut_max then
    return 100
  end
  local progress = math.floor(cut_total / cut_max * 100)
  if 100 <= progress then
    progress = 99
  end
  return progress
end
function logic_bargain.CalcBargainPercent(origin, floor, cur)
  origin = origin or 0
  floor = floor or 0
  cur = cur or origin
  if origin <= floor then
    return 100
  end
  local cut_total = origin - cur
  local cut_max = origin - floor
  if cut_total <= 0 then
    return 0
  end
  if cut_total >= cut_max then
    return 100
  end
  return cut_total / cut_max * 100
end
function logic_bargain.ApplyBargainProgress(uiRoot, origin, floor, cur)
  if not uiRoot then
    return
  end
  local percent = logic_bargain.CalcBargainPercent(origin, floor, cur)
  if uiRoot.ProgressBar_0 then
    uiRoot.ProgressBar_0:SetPercent(percent / 100)
  end
  if uiRoot.TextBlock_Progress then
    local text = string.format("%.1f", percent)
    text = string.gsub(text, "%.0$", "")
    uiRoot.TextBlock_Progress:SetText(text .. "%")
  end
end
function logic_bargain:GetCutAmount(package_id)
  local cfg = self.gifts_config[package_id]
  if not cfg then
    return 0
  end
  return math.max(0, (cfg.original_price or 0) - self:GetCurPrice(package_id))
end
function logic_bargain:IsAtFloorPrice(package_id)
  local cfg = self.gifts_config[package_id]
  if not cfg then
    return false
  end
  return self:GetCurPrice(package_id) <= (cfg.floor_price or 0)
end
function logic_bargain:IsGiftBought(package_id)
  return self:GetGiftBoughtNum(package_id) > 0
end
function logic_bargain:IsGiftOffline(package_id)
  local cfg = self.gifts_config[package_id]
  if not cfg then
    return true
  end
  if not cfg.end_time then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  return cfg.end_time < TimeUtil.GetServerTimeInSec()
end
function logic_bargain:GetGiftStatus(package_id)
  local cfg = self.gifts_config[package_id]
  if not cfg then
    return self.BARGAIN_STATUS.OFFLINE_BUYABLE
  end
  local active = self:GetActiveOrderByPackageId(package_id)
  if active then
    local IsOffline = self:IsGiftOffline(package_id)
    if active.status == self.SERVER_STATUS.NEW then
      if IsOffline then
        return self.BARGAIN_STATUS.OFFLINE_CANNOT_BUY
      end
      return self.BARGAIN_STATUS.NEW
    end
    local cur = active.current_price or cfg.original_price or 0
    local floor = active.floor_price or cfg.floor_price or 0
    if IsOffline then
      return self.BARGAIN_STATUS.OFFLINE_BUYABLE
    end
    if cur <= floor then
      return self.BARGAIN_STATUS.READY_TO_BUY
    end
    return self.BARGAIN_STATUS.CUTTING
  else
    if self:IsGiftLimited(package_id) then
      return self.BARGAIN_STATUS.BOUGHT
    end
    return self.BARGAIN_STATUS.OFFLINE_CANNOT_BUY
  end
end
function logic_bargain:SortGiftIdListByPriority(id_list)
  if not id_list then
    return {}
  end
  local list = {}
  for _, id in ipairs(id_list) do
    table.insert(list, id)
  end
  local get_cfg_id = function(item)
    return type(item) == "table" and item.cfg_id or item
  end
  local get_priority = function(item)
    local cfg_id = get_cfg_id(item)
    local status = self:GetGiftStatus(cfg_id) or self.BARGAIN_STATUS.NEW
    return self.SHOW_STATUS_PRIORITY[status] or 99
  end
  local gifts_config = self.gifts_config
  table.sort(list, function(a, b)
    local pa = get_priority(a)
    local pb = get_priority(b)
    if pa ~= pb then
      return pa < pb
    end
    local cfg_a = get_cfg_id(a)
    local cfg_b = get_cfg_id(b)
    local order_a = gifts_config[cfg_a] and gifts_config[cfg_a].show_order or 0
    local order_b = gifts_config[cfg_b] and gifts_config[cfg_b].show_order or 0
    if order_a ~= order_b then
      return order_a < order_b
    end
    return cfg_a < cfg_b
  end)
  return list
end
function logic_bargain:GetTargetCfgIdToFocus()
  local can_buy_list = self:GetReadyToBuyOrderList()
  if next(can_buy_list) then
    local target = can_buy_list[1]
    for _, record in ipairs(can_buy_list) do
      local order_a = self.gifts_config[record.package_id] and self.gifts_config[record.package_id].show_order or 0
      local order_b = self.gifts_config[target.package_id] and self.gifts_config[target.package_id].show_order or 0
      if order_a < order_b then
        target = record
      end
    end
    return target.package_id
  end
  return self.focus_package_id
end
function logic_bargain:SetFocusCfgId(package_id)
  self.focus_end
function logic_bargain:ClearFocusCfgId()
  self.focus_package_id = nil
end
function logic_bargain:GetFocusCfgId()
  return self.focus_package_id or 0
end
function logic_bargain:JumpToBargainMain(cfg_id)
  if cfg_id and cfg_id ~= 0 then
    self:SetFocusCfgId(cfg_id)
  end
  local urlParam = {tabId = 2, internal = 1}
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  if special_offer_module and special_offer_module.OpenOneAct then
    special_offer_module:OpenOneAct(special_offer_cfg.NewGroupBuy, urlParam)
  else
    log_warning(bWriteLog and "[WARN] logic_bargain:JumpToBargainMain - special_offer_module not found")
  end
end
function logic_bargain:GetOrderListByTab(tab)
  if tab == self.ORDER_TAB.ALL then
    local result = {}
    local append = function(list)
      for _, v in ipairs(list) do
        table.insert(result, v)
      end
    end
    append(self:GetReadyToBuyOrderList())
    append(self:GetCuttingOrderList())
    append(self:GetBoughtOrderList())
    append(self:GetOfflineOrderList())
    return result
  elseif tab == self.ORDER_TAB.READY_TO_BUY then
    return self:GetReadyToBuyOrderList()
  elseif tab == self.ORDER_TAB.CUTTING then
    return self:GetCuttingOrderList()
  elseif tab == self.ORDER_TAB.BOUGHT then
    return self:GetBoughtOrderList()
  elseif tab == self.ORDER_TAB.OFFLINE then
    return self:GetOfflineOrderList()
  end
  return {}
end
function logic_bargain:GetReadyToBuyOrderList()
  local list = {}
  for package_id, _ in pairs(self.gifts_config) do
    if self:GetGiftStatus(package_id) == self.BARGAIN_STATUS.READY_TO_BUY then
      local order = self:GetActiveOrderByPackageId(package_id)
      table.insert(list, {
        package_id = package_id,
        cfg_id = package_id,
              })
    end
  end
  return list
end
function logic_bargain:GetCuttingOrderList()
  local list = {}
  for package_id, _ in pairs(self.gifts_config) do
    local status = self:GetGiftStatus(package_id)
    if status == self.BARGAIN_STATUS.CUTTING then
      local order = self:GetActiveOrderByPackageId(package_id)
      table.insert(list, {
        package_id = package_id,
        cfg_id = package_id,
              })
    end
  end
  return list
end
function logic_bargain:GetBoughtOrderList()
  local list = {}
  for _, order in pairs(self.bargain_orders) do
    if order.status == self.SERVER_STATUS.BOUGHT then
      table.insert(list, {
        package_id = order.package_id,
        cfg_id = order.cfg_id,
        order = order,
        buy_time = order.create_time
      })
    end
  end
  table.sort(list, function(a, b)
    return (a.buy_time or 0) > (b.buy_time or 0)
  end)
  return list
end
function logic_bargain:GetOfflineOrderList()
  local list = {}
  for package_id, _ in pairs(self.gifts_config) do
    if self:GetGiftStatus(package_id) == self.BARGAIN_STATUS.OFFLINE_BUYABLE then
      table.insert(list, {
        package_id = package_id,
        cfg_id = package_id,
        order = nil
      })
    end
  end
  return list
end
function logic_bargain:RefreshActivityTime()
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = logic_activity_mgr.GetActivityByType(ActivityType.Bargain)
  if ActivityData then
    self.nActStartTime = ActivityData.StartTime
  end
end
function logic_bargain:RefreshGiftMaxStartTime()
  local maxStartTime = 0
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  for _, cfg in pairs(self.gifts_config) do
    if cfg.begin_time and now >= cfg.begin_time and maxStartTime < cfg.begin_time then
      maxStartTime = cfg.begin_time
    end
  end
  if self.nGiftMaxStartTime ~= maxStartTime then
    self.nGiftMaxStartTime = maxStartTime
    self:_PostRedDotChange()
  end
end
function logic_bargain:IsShow()
  if self.activity_durations and next(self.activity_durations) then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    for _, duration in pairs(self.activity_durations) do
      if duration.begin_time and duration.end_time and now >= duration.begin_time and now < duration.end_time then
        return true
      end
    end
    return false
  end
end
function logic_bargain:SetRegionConfig(region_config)
  self.region_config = region_config or {}
end
local IsRegionsHitGroup = function(cfg, group_id)
  if not (cfg and cfg.regions) or not next(cfg.regions) then
    return true
  end
  if cfg.regions[0] then
    return true
  end
  if group_id == nil then
    return false
  end
  return cfg.regions[group_id] ~= nil
end
logic_bargain.
function logic_bargain:GetGroupIdByRegion(region_code)
  if not region_code or region_code == "" then
    return nil
  end
  return self.region_config and self.region_config[region_code] or nil
end
function logic_bargain:IsGiftVisibleInRegion(cfg_id)
  if not cfg_id then
    return false
  end
  if self.gifts_config and self.gifts_config[cfg_id] then
    return true
  end
  if not self.gifts_config or not next(self.gifts_config) then
    return true
  end
  return false
end
function logic_bargain:IsRegionHitForFriend(cfg_id, other_region)
  local cfg = self.gifts_config and self.gifts_config[cfg_id]
  if not cfg then
    return true
  end
  if not (cfg.regions and next(cfg.regions)) or cfg.regions[0] then
    return true
  end
  if not self.region_config or not next(self.region_config) then
    return true
  end
  local group_id = self:GetGroupIdByRegion(other_region)
  if group_id == nil then
    printf("[WARN] logic_bargain:IsRegionHitForFriend friend region not in region_config, cfg_id=%s region=%s", cfg_id, other_region)
    return false
  end
  return cfg.regions[group_id] ~= nil
end
function logic_bargain:GetVisibleGiftList()
  local result = {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for cfg_id, cfg in pairs(self.gifts_config) do
    if cfg.begin_time and cfg.end_time and serverTime > cfg.begin_time and serverTime < cfg.end_time then
      table.insert(result, cfg_id)
    end
  end
  table.sort(result, function(a, b)
    local ca, cb = self.gifts_config[a], self.gifts_config[b]
    return (ca.show_order or 0) < (cb.show_order or 0)
  end)
  return result
end
function logic_bargain:_IsRegionHit(regions)
  if not regions or not next(regions) then
    return true
  end
  if regions[0] then
    return true
  end
  local my_uid = DataMgr and DataMgr.roleData and DataMgr.roleData.uid or nil
  if not my_uid then
    return true
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local my_profile = logic_profile and logic_profile:GetLocalProfile(my_uid) or nil
  local my_region = my_profile and my_profile.region or nil
  if not my_region or my_region == "" then
    return true
  end
  if not self.region_config or not next(self.region_config) then
    return true
  end
  local my_group_id = self.region_config[my_region]
  if my_group_id == nil then
    return true
  end
  return regions[my_group_id] ~= nil
end
function logic_bargain:GetHelperRewards()
  local result = {}
  if not self.helper_award then
    return result
  end
  for i, r in pairs(self.helper_award) do
    if self:_IsRegionHit(r.regions) then
      result[i] = r
    end
  end
  return result
end
function logic_bargain:GetBuyRewards()
  local result = {}
  if not self.buy_award then
    return result
  end
  for _, r in pairs(self.buy_award) do
    if self:_IsRegionHit(r.regions) then
      table.insert(result, r)
    end
  end
  table.sort(result, function(a, b)
    return (a.threshold or 0) < (b.threshold or 0)
  end)
  return result
end
function logic_bargain:GetFriendCutRange(package_id)
  local cfg = self.gifts_config[package_id]
  if not cfg then
    return 0, 0
  end
  return cfg.friend_cut_min or 0, cfg.friend_cut_max or 0
end
function logic_bargain:GetStrangerCutRange(package_id)
  local cfg = self.gifts_config[package_id]
  if not cfg then
    return 0, 0
  end
  return cfg.stranger_cut_min or 0, cfg.stranger_cut_max or 0
end
function logic_bargain.FormatBargainCountDown(leftTime)
  if not leftTime or leftTime <= 0 then
    return ""
  end
  local total_hours = math.floor(leftTime / 3600)
  local mins = math.floor(leftTime % 3600 / 60)
  local seconds = math.floor(leftTime % 60)
  if total_hours <= 0 then
    return string.format("%02d:%02d", mins, seconds)
  end
  return string.format("%02d:%02d:%02d", total_hours, mins, seconds)
end
function logic_bargain:GetItemLeftTime(cfg_end_time)
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = logic_activity_mgr.GetActivityByType(ActivityType.Bargain)
  local candidates = {}
  if type(cfg_end_time) == "number" then
    table.insert(candidates, cfg_end_time)
  end
  if ActivityData and type(ActivityData.EndTime) == "number" then
    table.insert(candidates, ActivityData.EndTime)
  end
  if #candidates == 0 then
    return cfg_end_time
  end
  local minTime = candidates[1]
  for i = 2, #candidates do
    if minTime > candidates[i] then
      minTime = candidates[i]
    end
  end
  return minTime
end
function logic_bargain:_PostRedDotChange()
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.NewGroupBuy)
end
function logic_bargain:LoadRedData()
  if self.redData then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.redData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBargainRed) or {}
end
function logic_bargain:SaveRedData()
  if not self.redData then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.redData, PlayerPrefsSystem.ePlayerPrefsType.eBargainRed)
end
function logic_bargain:HasClickedAct()
  self:LoadRedData()
  return self.redData.nActStartTime == self.nActStartTime
end
function logic_bargain:HasClickedNewGift()
  self:LoadRedData()
  if self.nGiftMaxStartTime == 0 then
    return true
  end
  return self.redData.nGiftMaxStartTime == self.nGiftMaxStartTime
end
function logic_bargain:OnOpenAct()
  self:LoadRedData()
  local hasSetRed
  if self.redData.nActStartTime ~= self.nActStartTime then
    self.redData.nActStartTime = self.nActStartTime
    hasSetRed = true
  end
  if self.redData.nGiftMaxStartTime ~= self.nGiftMaxStartTime then
    self.redData.nGiftMaxStartTime = self.nGiftMaxStartTime
    hasSetRed = true
  end
  if hasSetRed then
    self:SaveRedData()
    self:_PostRedDotChange()
  end
end
function logic_bargain:ClearAllRedData()
  self:LoadRedData()
  self.redData.nActStartTime = 0
  self.redData.nGiftMaxStartTime = 0
  self.redData.popupActStartTime = 0
  self.redData.orderRedDots = nil
  self:SaveRedData()
  self:_PostRedDotChange()
end
function logic_bargain:SetFriendCutRedDot(flag, bargain_id)
  self:LoadRedData()
  if bargain_id then
    self.redData.orderRedDots = self.redData.orderRedDots or {}
    self.redData.orderRedDots[bargain_id] = self.redData.orderRedDots[bargain_id] or {}
    self.redData.orderRedDots[bargain_id].hasFriendCut = flag and true or nil
  elseif self.redData.orderRedDots then
    for orderId, _ in pairs(self.redData.orderRedDots) do
      self.redData.orderRedDots[orderId] = self.redData.orderRedDots[orderId] or {}
      self.redData.orderRedDots[orderId].hasFriendCut = flag and true or nil
    end
  end
  self:SaveRedData()
  self:_PostRedDotChange()
end
function logic_bargain:SetTaskRedDot(flag, bargain_id)
  self:LoadRedData()
  if bargain_id then
    self.redData.orderRedDots = self.redData.orderRedDots or {}
    self.redData.orderRedDots[bargain_id] = self.redData.orderRedDots[bargain_id] or {}
    self.redData.orderRedDots[bargain_id].hasTaskCut = flag and true or nil
  elseif self.redData.orderRedDots then
    for orderId, _ in pairs(self.redData.orderRedDots) do
      self.redData.orderRedDots[orderId] = self.redData.orderRedDots[orderId] or {}
      self.redData.orderRedDots[orderId].hasTaskCut = flag and true or nil
    end
  end
  self:SaveRedData()
  self:_PostRedDotChange()
end
function logic_bargain:HasReadyToBuyGift()
  return next(self:GetReadyToBuyOrderList()) ~= nil
end
function logic_bargain:HasFriendCutRedDotForOrder(bargain_id)
  self:LoadRedData()
  if bargain_id and self.redData.orderRedDots and self.redData.orderRedDots[bargain_id] then
    return self.redData.orderRedDots[bargain_id].hasFriendCut == true
  end
  return false
end
function logic_bargain:HasTaskCutRedDotForOrder(bargain_id)
  self:LoadRedData()
  if bargain_id and self.redData.orderRedDots and self.redData.orderRedDots[bargain_id] then
    return self.redData.orderRedDots[bargain_id].hasTaskCut == true
  end
  return false
end
function logic_bargain:ClearOrderRedDots(bargain_id)
  if not bargain_id or bargain_id == "" then
    return
  end
  self:LoadRedData()
  if self.redData.orderRedDots and self.redData.orderRedDots[bargain_id] then
    self.redData.orderRedDots[bargain_id] = nil
    self:SaveRedData()
    self:_PostRedDotChange()
  end
end
function logic_bargain:HasFriendCutRedDot()
  self:LoadRedData()
  if self.redData.orderRedDots then
    for _, orderRedDot in pairs(self.redData.orderRedDots) do
      if orderRedDot.hasFriendCut == true then
        return true
      end
    end
  end
  return false
end
function logic_bargain:HasTaskCutRedDot()
  self:LoadRedData()
  if self.redData.orderRedDots then
    for _, orderRedDot in pairs(self.redData.orderRedDots) do
      if orderRedDot.hasTaskCut == true then
        return true
      end
    end
  end
  return false
end
function logic_bargain:HasBuyAward()
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = logic_activity_mgr.GetActivityByType(ActivityType.Bargain)
  local List = ActivityData and ActivityData.List
  if List then
    for _, v in ipairs(List) do
      if v.Status == ActivityProgressStatus.Done then
        return true
      end
    end
  end
  return false
end
function logic_bargain:LoadPopupData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.popupData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBargainRedSuc) or {}
end
function logic_bargain:SavePopupData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.popupData, PlayerPrefsSystem.ePlayerPrefsType.eBargainRedSuc)
  self:LoadRedData()
  self.redData.popupActStartTime = self.nActStartTime
  self:SaveRedData()
end
function logic_bargain:TryTriggerCanBuyPopup()
  local readyList = self:GetReadyToBuyOrderList()
  for _, record in pairs(readyList) do
    local bargain_id = record.order and record.order.bargain_id
    if bargain_id and not self.popupData[bargain_id] then
      self.popupData[bargain_id] = true
      self:SavePopupData()
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BARGAIN_AT_FLOOR_PRICE, record.cfg_id)
    end
  end
end
local RIGHT_TOP_POPUP_AUTO_CLOSE_SEC = 10
function logic_bargain:_GetGiftIconPath(cfg_id)
  local cfg = self:GetGiftConfigById(cfg_id)
  if not cfg or not cfg.item_id then
    return ""
  end
  local item_config = CDataTable.GetTableData("Item", cfg.item_id)
  if not item_config then
    return ""
  end
  return item_config.ItemSmallIcon or ""
end
function logic_bargain:GetGiftCfgFromTable(package_id)
  if not package_id or package_id == 0 then
    return nil
  end
  self._gift_table_cache = self._gift_table_cache or {}
  if self._gift_table_cache[package_id] ~= nil then
    local hit = self._gift_table_cache[package_id]
    return hit ~= false and hit or nil
  end
  local data = CDataTable.GetTableDataByFilter("BargainGiftCfg", "package_id", package_id)
  self._gift_table_cache[package_id] = data or false
  return data
end
function logic_bargain:GetGiftName(package_id)
  local row = self:GetGiftCfgFromTable(package_id)
  return row and row.name or ""
end
function logic_bargain:GetGiftSlogan(package_id)
  local row = self:GetGiftCfgFromTable(package_id)
  return row and row.promotion or ""
end
function logic_bargain:GetTaskCfgFromTable(task_id)
  if not task_id or task_id == 0 then
    return nil
  end
  self._task_table_cache = self._task_table_cache or {}
  if self._task_table_cache[task_id] ~= nil then
    local hit = self._task_table_cache[task_id]
    return hit ~= false and hit or nil
  end
  local data = CDataTable.GetTableDataByFilter("RPTaskDesc", "TaskID", task_id)
  self._task_table_cache[task_id] = data or false
  return data
end
function logic_bargain:GetTaskName(task_id, bargain_id)
  local row = self:GetTaskCfgFromTable(task_id)
  local desc = ""
  local sFinishCnt = self:GetTaskFinishCnt(bargain_id, task_id)
  if row and row.Desc then
    local TextID = row.Desc or 0
    if row.Content == "" and row.LocalizeContent == 0 then
      desc = LocUtil.LocalizeResFormat(TextID, sFinishCnt)
    elseif row.Content ~= "" then
      desc = LocUtil.LocalizeResFormat(TextID, row.Content, sFinishCnt)
    elseif row.LocalizeContent ~= 0 then
      local content = LocUtil.LocalizeResFormat(row.LocalizeContent)
      desc = LocUtil.LocalizeResFormat(TextID, content, sFinishCnt)
    end
  end
  return desc
end
function logic_bargain:GetTaskFinishCnt(bargain_id, task_id)
  local taskInfo = self.task_list_cache[bargain_id]
  if taskInfo and taskInfo.task_list then
    for _, task in ipairs(taskInfo.task_list) do
      if task.task_id == task_id then
        return task.required_count
      end
    end
  end
  return 0
end
function logic_bargain:_GetUserName(uid)
  if not uid or uid == 0 then
    return ""
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if not logic_profile then
    return ""
  end
  local profile = logic_profile:GetLocalProfile(uid)
  return profile and profile.nickName or ""
end
function logic_bargain:_IsNearOrOverFloor(cfg_id)
  if not cfg_id or cfg_id == 0 then
    return false
  end
  return self:GetBargainProgress(cfg_id) >= NEAR_FLOOR_PROGRESS_THRESHOLD
end
function logic_bargain:_IsInLobby()
  if not GameStatus then
    return false
  end
  return GameStatus.IsIn2DLobby()
end
function logic_bargain:_BuildBargainJumpInfo(cfg_id)
  return {
    bUseOKBtn = true,
    callback = function()
      log(bWriteLog and "logic_bargain right top popup jump invite, cfg_id=" .. tostring(cfg_id))
      self:JumpToBargainMain(cfg_id)
      UIManager.ShowUI(UIManager.UI_Config.Discount_Invite_Popup_UIBP, cfg_id)
    end
  }
end
function logic_bargain:_BuildMainJumpInfo(cfg_id)
  return {
    bUseOKBtn = true,
    callback = function()
      log(bWriteLog and "logic_bargain right top popup jump main, cfg_id=" .. tostring(cfg_id))
      self:JumpToBargainMain(cfg_id)
    end
  }
end
function logic_bargain:_BuildBuyJumpInfo(cfg_id)
  return {
    bUseOKBtn = true,
    callback = function()
      log(bWriteLog and "logic_bargain right top popup jump main, cfg_id=" .. tostring(cfg_id))
      self:JumpToBargainMain(cfg_id)
    end
  }
end
function logic_bargain:_OpenBuyConfirm(cfg_id)
  local cfg = self:GetGiftConfigById(cfg_id)
  if not cfg then
    log(bWriteLog and "[WARN] logic_bargain:_OpenBuyConfirm no cfg, cfg_id=" .. tostring(cfg_id))
    return
  end
  local gift_name = self:GetGiftName(cfg_id)
  local cur_price = self:GetCurPrice(cfg_id)
  local cost_id = self:GetGiftCostId(cfg_id)
  local coin_tag = self:GetCostIconTag(cost_id)
  local content = LocUtil.LocalizeResFormat(166098, coin_tag, tostring(cur_price), gift_name)
  local title = LocUtil.GetLocalizeResStr(7274)
  local okText = LocUtil.GetLocalizeResStr(167115)
  local buyFunc = function()
    local BargainHandler = RequireMod("client.network.Protocol.BargainHandler")
    if BargainHandler and BargainHandler.send_bargain_purchase_req then
      BargainHandler.send_bargain_purchase_req(cfg_id)
    end
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, content, buyFunc, nil, okText, nil, nil)
end
function logic_bargain:_ShowFriendCutPopup(cfg_id, helper_name, cut_amount)
  if not self:_IsInLobby() then
    log(bWriteLog and "logic_bargain:_ShowFriendCutPopup skip, not in lobby")
    return
  end
  if not cfg_id or cfg_id == 0 then
    return
  end
  local gift_name = self:GetGiftName(cfg_id)
  local cost_id = self:GetGiftCostId(cfg_id)
  local amount_text = self:GetCostIconTag(cost_id) .. tostring(cut_amount or 0)
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local desc = LocUtil.LocalizeResFormat(167057, helper_name or "", gift_name, amount_text)
  local icon = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby/GroupBuying/GroupBuying_Icon_05.GroupBuying_Icon_05"
  local jumpInfo = self:_BuildBargainJumpInfo(cfg_id)
  log(bWriteLog and string.format("logic_bargain:_ShowFriendCutPopup cfg_id=%s helper=%s gift=%s amount=%s", tostring(cfg_id), tostring(helper_name), tostring(gift_name), tostring(cut_amount)))
  RightPopSystem.BargainPopup("", desc, icon, jumpInfo, RIGHT_TOP_POPUP_AUTO_CLOSE_SEC, true)
end
function logic_bargain:_ShowAtFloorPopup(cfg_id)
  if not self:_IsInLobby() then
    log(bWriteLog and "logic_bargain:_ShowAtFloorPopup skip, not in lobby")
    return
  end
  if not cfg_id or cfg_id == 0 then
    return
  end
  local cfg = self:GetGiftConfigById(cfg_id)
  if not cfg then
    log(bWriteLog and "[WARN] logic_bargain:_ShowAtFloorPopup no cfg, cfg_id=" .. tostring(cfg_id))
    return
  end
  local gift_name = self:GetGiftName(cfg_id)
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local desc = LocUtil.LocalizeResFormat(167058, gift_name)
  local icon = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby/GroupBuying/GroupBuying_Icon_05.GroupBuying_Icon_05"
  local jumpInfo = self:_BuildBuyJumpInfo(cfg_id)
  log(bWriteLog and string.format("logic_bargain:_ShowAtFloorPopup cfg_id=%s gift=%s", tostring(cfg_id), tostring(gift_name)))
  RightPopSystem.BargainPopup("", desc, icon, jumpInfo, RIGHT_TOP_POPUP_AUTO_CLOSE_SEC, true)
end
function logic_bargain:_ShowNearFloorPopup(cfg_id)
  if not self:_IsInLobby() then
    log(bWriteLog and "logic_bargain:_ShowNearFloorPopup skip, not in lobby")
    return
  end
  if not cfg_id or cfg_id == 0 then
    return
  end
  local cfg = self:GetGiftConfigById(cfg_id)
  if not cfg then
    log(bWriteLog and "[WARN] logic_bargain:_ShowNearFloorPopup no cfg, cfg_id=" .. tostring(cfg_id))
    return
  end
  local gift_name = self:GetGiftName(cfg_id)
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local desc = LocUtil.LocalizeResFormat(167059, gift_name)
  local icon = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby/GroupBuying/GroupBuying_Icon_05.GroupBuying_Icon_05"
  local jumpInfo = self:_BuildMainJumpInfo(cfg_id)
  log(bWriteLog and string.format("logic_bargain:_ShowNearFloorPopup cfg_id=%s gift=%s", tostring(cfg_id), tostring(gift_name)))
  RightPopSystem.BargainPopup("", desc, icon, jumpInfo, RIGHT_TOP_POPUP_AUTO_CLOSE_SEC, true)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CTemplate = class(CModuleBase, nil, logic_bargain)
return CTemplate