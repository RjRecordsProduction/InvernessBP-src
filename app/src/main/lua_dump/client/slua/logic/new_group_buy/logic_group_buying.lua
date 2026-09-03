local logic_group_buying = {}
logic_group_buying.GROUP_BUY_STATUS = {
  FORMING = 1,
  ACTIVE = 2,
  FAILED = 3
}
logic_group_buying.CLIENT_BUY_TYPE = {
  NOT_BUY = 0,
  GROUP_BUY = 1,
  DIRECT_BUY = 2,
  COUPON_BUY = 3
}
logic_group_buying.GROUP_BUY_SHOW_STATUS = {
  CANFORMING = 1,
  LIMITED = 2,
  FORMING = 3,
  ACTIVE = 4
}
logic_group_buying.GROUP_BUY_LABEL_SHOW = {
  ALL = 1,
  CANBUY = 2,
  FORMING = 3,
  BOUGHT = 4,
  FAILED = 5
}
logic_group_buying.DEPOSIT_DEDUCTION_VOUCHER_ID = {
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
  [1702155] = 1660012
}
logic_group_buying.COST_ID = {
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
  [1660012] = 1702155
}
logic_group_buying.SHOW_ICON_NAME = {
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
  [1702155] = "GreenWhiteCrystal"
}
local hasShowGuide
function logic_group_buying:DefineAndResetData()
  log(bWriteLog and "logic_group_buying:DefineAndResetData.  ")
  self.group_list = {}
  self.gifts_id_list = {}
  self.gifts_config = {}
  self.gifts_buy_config = {}
  self.gifts_buy_info = {}
  self.groups_info = {}
  self.other_config = {}
  self.nActStartTime = nil
  self.nGroupMaxStartTime = nil
  self.redData = nil
  self.order_cfg = {}
  self.chatData = {}
  self.region_config = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.popupData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyRedSuc) or {}
end
function logic_group_buying:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    local NewGroupBuyHandler = RequireMod("client.network.Protocol.NewGroupBuyHandler")
    NewGroupBuyHandler.send_get_new_group_buy_info_req()
    NewGroupBuyHandler.send_get_new_group_buy_simple_info_req()
  end
end
function logic_group_buying:RegistEvents()
end
function logic_group_buying:OnGetNewGroupInfo(group_list, gifts_id_list, gifts_config, gifts_buy_config, gifts_buy_info, groups_info, other_config)
  self.group_list = {}
  for k, v in pairs(group_list) do
    if not self.group_list[v.group_cfg_id] then
      self.group_list[v.group_cfg_id] = {}
    end
    if gifts_buy_config and gifts_buy_config[v.group_cfg_id] then
      v.package_id = gifts_buy_config[v.group_cfg_id].package_id
      table.insert(self.group_list[v.group_cfg_id], v)
    end
  end
  self.gifts_id_list = {}
  for id, v in pairs(gifts_id_list) do
    if v then
      local TimeUtil = require("client.common.time_util")
      if gifts_config[id] and gifts_config[id].begin_time < TimeUtil.GetServerTimeInSec() and gifts_config[id].end_time > TimeUtil.GetServerTimeInSec() then
        table.insert(self.gifts_id_list, id)
      end
    end
  end
  self.  self.  self.  self.  self.  self:InitOrderCfg()
  local nGroupMaxStartTime = 0
  for _, cfg in pairs(gifts_config) do
    if nGroupMaxStartTime < cfg.begin_time then
      nGroupMaxStartTime = cfg.begin_time
    end
  end
  self.  self:StartCheckGroupToInvite()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_NEW_GROUP_BUY_GET_INFO)
  self:IsGroupBuySuccess()
end
function logic_group_buying:OnGetCreateNewGroupBuy(gift_id, group_id, group_info)
  if self.chatData[group_id] then
    self.chatData[group_id] = group_info
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_NEW_GROUP_CREAT_NEW_GROUP, group_info)
  ShowNotice(166054)
end
function logic_group_buying:OnGetJoinNewGroupBuy(gift_id, group_id, group_info)
  if self.chatData[group_id] then
    self.chatData[group_id] = group_info
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_NEW_GROUP_JOIN_NEW_GROUP, group_info)
  ShowNotice(166031)
end
function logic_group_buying:OnGetPayNewGroupBuy(gift_id, group_id, item_id, item_num, total_num)
  if self.chatData[group_id] then
    self.chatData[group_id].buy_type = self.CLIENT_BUY_TYPE.GROUP_BUY
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_NEW_GROUP_PAY)
  if item_id and item_id ~= 0 and item_num and 0 < item_num then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle({
      {res_id = item_id, count = item_num}
    })
  end
end
function logic_group_buying:OnGetDirectPayNewGroupBuy(gift_id, item_id, item_num, total_number)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_NEW_GROUP_DIRECT_PAY)
  if item_id and item_id ~= 0 and item_num and 0 < item_num then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle({
      {res_id = item_id, count = item_num}
    })
  end
end
function logic_group_buying:OnGetCouponPayNewGroupBuy(gift_id, item_id, item_num, total_number)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_NEW_GROUP_COUPON_PAY)
  if item_id and item_id ~= 0 and item_num and 0 < item_num then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle({
      {res_id = item_id, count = item_num}
    })
  end
end
function logic_group_buying:OnGetBatchGetNewGroupBuyInfo(group_info)
  local chatData = self.chatData
  if group_info then
    if not next(chatData) then
      self.chatData = group_info
    else
      for i, v in pairs(group_info) do
        self.chatData[i] = v
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_NEW_GROUP_GET_GROUP_BUY_INFO, group_info)
end
function logic_group_buying:OnGetNewGroupBuySimpleInfo(activity_info)
  self.FCMTimer = self:AddTimerLoop(5, function()
    local TimeUtil = require("client.common.time_util")
    local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
    if LocalPushSystem.cfg then
      local curTime = TimeUtil.GetServerTimeInSec()
      local timeLeft = 0
      local id = LocalPushSystem:CalculateLocalId(167, 119)
      for k, v in pairs(activity_info) do
        local act_timeLeft = v.begin_time - curTime
        local IntlHelper = import("IntlHelper")
        local isEnable = IntlHelper.IsRemoteNotificationsEnabled()
        if isEnable and 0 < act_timeLeft and (timeLeft > act_timeLeft or timeLeft == 0) then
          timeLeft = act_timeLeft
        end
      end
      log(bWriteLog and string.format("NewGroupBuyHandler SET PUSH  id = %s, timeLeft = %s", id, timeLeft))
      if 0 < timeLeft then
        LocalPushSystem:CancelPush(id)
        LocalPushSystem:SetPushByIdAndTime(id, timeLeft)
      else
        LocalPushSystem:CancelPush(id)
      end
      if self.FCMTimer then
        self:RemoveTimer(self.FCMTimer)
        self.FCMTimer = nil
      end
    end
  end, 0, 5)
end
function logic_group_buying:GetChatInfoById(id)
  return self.chatData[id]
end
function logic_group_buying:GetGiftStatus(package_id)
  local status = self.GROUP_BUY_SHOW_STATUS.CANFORMING
  if self:GetGiftLimited(package_id) then
    return self.GROUP_BUY_SHOW_STATUS.LIMITED
  end
  for _, v in pairs(self.group_list) do
    for _, group in pairs(v) do
      if package_id == group.package_id and group and group.buy_type == self.CLIENT_BUY_TYPE.NOT_BUY then
        if group.status == self.GROUP_BUY_STATUS.ACTIVE then
          status = self.GROUP_BUY_SHOW_STATUS.ACTIVE
          break
        elseif group.status == self.GROUP_BUY_STATUS.FORMING then
          status = self.GROUP_BUY_SHOW_STATUS.FORMING
        end
      end
    end
  end
  return status
end
function logic_group_buying:GetLastGroupInfo(package_id)
  local lastGroup
  for k, group in pairs(self.group_list) do
    for _, v in pairs(group) do
      if v.package_id == package_id and v.status == self.GROUP_BUY_STATUS.ACTIVE and v.buy_type == self.CLIENT_BUY_TYPE.NOT_BUY and (not lastGroup or v.create_time > lastGroup.create_time) then
        lastGroup = v
      end
    end
  end
  return lastGroup
end
function logic_group_buying:GetGroupInfoByGroupBuyID(group_buy_id)
  for k, group in pairs(self.group_list) do
    for _, v in pairs(group) do
      if v.group_buy_id == group_buy_id then
        return v
      end
    end
  end
  return nil
end
function logic_group_buying:GetGiftLimited(gift_id)
  local base_config = self:GetGiftBaseConfigById(gift_id)
  local boughtGroupList = {}
  for config_id, groups in pairs(self.group_list) do
    for k, v in pairs(groups) do
      if v.status == self.GROUP_BUY_STATUS.ACTIVE and v.buy_type ~= self.CLIENT_BUY_TYPE.NOT_BUY then
        v.type = self.CLIENT_BUY_TYPE.GROUP_BUY
        table.insert(boughtGroupList, v)
      end
    end
  end
  for k, v in pairs(self.gifts_buy_info.direct_buy) do
    local group = {}
    group.group_cfg_id = v.cfg_id
    group.create_time = v.buy_time
    group.status = self.GROUP_BUY_STATUS.ACTIVE
    group.buy_type = self.CLIENT_BUY_TYPE.DIRECT_BUY
    group.package_id = self:GetPackageIDByID(v.cfg_id)
    group.type = self.CLIENT_BUY_TYPE.DIRECT_BUY
    table.insert(boughtGroupList, group)
  end
  for k, v in pairs(self.gifts_buy_info.coupon_buy) do
    local group = {}
    group.group_cfg_id = v.cfg_id
    group.create_time = v.buy_time
    group.status = self.GROUP_BUY_STATUS.ACTIVE
    group.buy_type = self.CLIENT_BUY_TYPE.COUPON_BUY
    group.package_id = self:GetPackageIDByID(v.cfg_id)
    group.type = self.CLIENT_BUY_TYPE.COUPON_BUY
    table.insert(boughtGroupList, group)
  end
  local num = 0
  local list = boughtGroupList
  for k, v in pairs(list) do
    if self:GetPackageIDByID(v.group_cfg_id) == gift_id then
      num = num + 1
    end
  end
  if base_config then
    return num >= base_config.limit_count
  end
  return false
end
function logic_group_buying:GetGiftsBuyConfig(gift_id)
  local buy_config = {}
  for k, v in pairs(self.gifts_buy_config) do
    if v.package_id == gift_id then
      table.insert(buy_config, v)
    end
  end
  return buy_config
end
function logic_group_buying:GetGiftBuyConfigById(id)
  for k, v in pairs(self.gifts_buy_config) do
    if v.id == id then
      return v
    end
  end
end
function logic_group_buying:GetGiftBaseConfigById(id)
  return self.gifts_config[id]
end
function logic_group_buying:GetGiftsInfo(gift_id)
  local gifts_info = {}
  for k, v in pairs(self.groups_info[gift_id]) do
    table.insert(gifts_info, v)
  end
  return gifts_info
end
function logic_group_buying:IsShow()
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = logic_activity_mgr.GetActivityByType(ActivityType.New_Group_Buying)
  if ActivityData then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    self.nActStartTime = ActivityData.StartTime
    local isOpen = now > ActivityData.StartTime and now < ActivityData.EndTime
    return isOpen
  else
    return false
  end
end
function logic_group_buying:SortGiftIdListByPriority(gift_id_list)
  if not gift_id_list then
    return {}
  end
  local list = {}
  for _, id in ipairs(gift_id_list) do
    table.insert(list, id)
  end
  local priority = {}
  priority[self.GROUP_BUY_SHOW_STATUS.ACTIVE] = 1
  priority[self.GROUP_BUY_SHOW_STATUS.CANFORMING] = 2
  priority[self.GROUP_BUY_SHOW_STATUS.FORMING] = 3
  priority[self.GROUP_BUY_SHOW_STATUS.LIMITED] = 4
  local order_cfg = self.order_cfg
  local get_priority = function(id)
    local status = self:GetGiftStatus(id) or self.GROUP_BUY_SHOW_STATUS.CANFORMING
    return priority[status] or 99
  end
  table.sort(list, function(a, b)
    local pa = get_priority(a)
    local pb = get_priority(b)
    if pa ~= pb then
      return pa < pb
    end
    local order_a = order_cfg[a] or 0
    local order_b = order_cfg[b] or 0
    if order_a ~= order_b then
      return order_a < order_b
    end
    return a < b
  end)
  return list
end
local sort_by_create_time_desc = function(list)
  if not list then
    return
  end
  table.sort(list, function(a, b)
    local at = a and a.create_time or 0
    local bt = b and b.create_time or 0
    return at > bt
  end)
end
function logic_group_buying:GetCanBuyGroupList()
  local canBuyGroupList = {}
  for config_id, groups in pairs(self.group_list) do
    for k, v in pairs(groups) do
      if v.status == self.GROUP_BUY_STATUS.ACTIVE and v.buy_type == self.CLIENT_BUY_TYPE.NOT_BUY and not self:GetGiftLimited(v.package_id) then
        table.insert(canBuyGroupList, v)
      end
    end
  end
  sort_by_create_time_desc(canBuyGroupList)
  return canBuyGroupList
end
function logic_group_buying:GetInGroupList()
  local inGroupList = {}
  for config_id, groups in pairs(self.group_list) do
    for k, v in pairs(groups) do
      if v.status == self.GROUP_BUY_STATUS.FORMING and v.buy_type == self.CLIENT_BUY_TYPE.NOT_BUY and not self:GetGiftLimited(v.package_id) then
        table.insert(inGroupList, v)
      end
    end
  end
  sort_by_create_time_desc(inGroupList)
  return inGroupList
end
function logic_group_buying:GetBoughtGroupList()
  local boughtGroupList = {}
  for config_id, groups in pairs(self.group_list) do
    for k, v in pairs(groups) do
      if v.status == self.GROUP_BUY_STATUS.ACTIVE and v.buy_type ~= self.CLIENT_BUY_TYPE.NOT_BUY then
        v.type = self.CLIENT_BUY_TYPE.GROUP_BUY
        table.insert(boughtGroupList, v)
      end
    end
  end
  for k, v in pairs(self.gifts_buy_info.direct_buy) do
    local group = {}
    group.group_cfg_id = v.cfg_id
    group.create_time = v.buy_time
    group.status = self.GROUP_BUY_STATUS.ACTIVE
    group.buy_type = self.CLIENT_BUY_TYPE.DIRECT_BUY
    group.package_id = self:GetPackageIDByID(v.cfg_id)
    group.type = self.CLIENT_BUY_TYPE.DIRECT_BUY
    table.insert(boughtGroupList, group)
  end
  for k, v in pairs(self.gifts_buy_info.coupon_buy) do
    local group = {}
    group.group_cfg_id = v.cfg_id
    group.create_time = v.buy_time
    group.status = self.GROUP_BUY_STATUS.ACTIVE
    group.buy_type = self.CLIENT_BUY_TYPE.COUPON_BUY
    group.package_id = self:GetPackageIDByID(v.cfg_id)
    group.type = self.CLIENT_BUY_TYPE.COUPON_BUY
    group.is_low_coupon = v.is_low_coupon
    table.insert(boughtGroupList, group)
  end
  sort_by_create_time_desc(boughtGroupList)
  return boughtGroupList
end
function logic_group_buying:GetFailedGroupList(bCheckPopup)
  local failedGroupList = {}
  for config_id, groups in pairs(self.group_list) do
    for k, v in pairs(groups) do
      if v.status == self.GROUP_BUY_STATUS.FAILED then
        if bCheckPopup and not self:CheckGroupPopupById(v.group_buy_id) then
          table.insert(failedGroupList, v)
        elseif not bCheckPopup then
          table.insert(failedGroupList, v)
        end
      end
    end
  end
  sort_by_create_time_desc(failedGroupList)
  return failedGroupList
end
function logic_group_buying:ContainFriendInGroup(members)
  for k, v in pairs(members) do
    local FriendSystem = require("client.slua.logic.friend.logic_new_friend")
    local isFriend = FriendSystem.IsMyFriend(v.uid)
    if isFriend then
      return true
    end
  end
  return false
end
function logic_group_buying:GetGroupListByTab(tab_index)
  local list = {}
  if tab_index == self.GROUP_BUY_LABEL_SHOW.ALL then
    local allList = {}
    local appendList = function(list)
      if not list then
        return
      end
      for _, v in ipairs(list) do
        table.insert(allList, v)
      end
    end
    appendList(self:GetCanBuyGroupList())
    appendList(self:GetInGroupList())
    appendList(self:GetBoughtGroupList())
    appendList(self:GetFailedGroupList())
    return allList
  elseif tab_index == self.GROUP_BUY_LABEL_SHOW.CANBUY then
    return self:GetCanBuyGroupList()
  elseif tab_index == self.GROUP_BUY_LABEL_SHOW.FORMING then
    return self:GetInGroupList()
  elseif tab_index == self.GROUP_BUY_LABEL_SHOW.BOUGHT then
    return self:GetBoughtGroupList()
  elseif tab_index == self.GROUP_BUY_LABEL_SHOW.FAILED then
    return self:GetFailedGroupList()
  end
end
function logic_group_buying:GetBoughtNum(gift_id)
  local num = 0
  local list = self:GetBoughtGroupList()
  for k, v in pairs(list) do
    if self:GetPackageIDByID(v.group_cfg_id) == gift_id then
      num = num + 1
    end
  end
  return num
end
function logic_group_buying:GetPackageIDByID(cfg_id)
  if not self.gifts_buy_config[cfg_id] then
    return 0
  end
  return self.gifts_buy_config[cfg_id].package_id or 0
end
function logic_group_buying:CanUseCoupon(gift_id)
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  local Logic_ItemUtils = require("client.slua.logic.common.Logic_ItemUtils")
  local generalCouponNum = Logic_ItemUtils.GetItemCount(CoinMacro.GeneralCoupon)
  local premiumCouponNum = Logic_ItemUtils.GetItemCount(CoinMacro.PremiumCoupon)
  for _, v in pairs(self.gifts_buy_config) do
    if v.package_id == gift_id then
      for k, v2 in pairs(self.gifts_buy_config[v.id].can_use_coupon_types) do
        if k == 1 and v2 and 0 < generalCouponNum then
          return true
        elseif k == 2 and v2 and 0 < premiumCouponNum then
          return true
        end
      end
    end
  end
  return false
end
function logic_group_buying:LoadRedData()
  if self.redData then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.redData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyRed) or {}
end
function logic_group_buying:HasClickedAct()
  self:LoadRedData()
  return self.redData.nActStartTime == self.nActStartTime
end
function logic_group_buying:HasNewGroupBag()
  self:LoadRedData()
  return self.redData.nGroupMaxStartTime == self.nGroupMaxStartTime
end
function logic_group_buying:OnOpenAct()
  self:LoadRedData()
  local hasSetRed
  if self.redData.nActStartTime ~= self.nActStartTime then
    self.redData.nActStartTime = self.nActStartTime
    hasSetRed = true
  end
  if self.redData.nGroupMaxStartTime ~= self.nGroupMaxStartTime then
    self.redData.nGroupMaxStartTime = self.nGroupMaxStartTime
    hasSetRed = true
  end
  if hasSetRed then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N(self.redData, PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyRed)
    local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
    EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.NewGroupBuy)
  end
  if not hasShowGuide then
    hasShowGuide = true
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyPopup) or {}
    if not data.hasShowGuide then
      data.hasShowGuide = true
      PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyPopup)
      self:OpenGuide()
    end
  end
end
function logic_group_buying:OpenGuide()
  local center = "/pictures/GroupPurchase/Guide/"
  local head = FuncUtil.GetDomainByID(3366036) .. center
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    head = FuncUtil.GetDomainByID(3366052) .. center
  end
  local tb = {
    list = {
      {
        url = head .. "GuideA_1_en.png"
      },
      {
        url = head .. "GuideB_1_en.png"
      },
      {
        url = head .. "GuideC_1_en.png"
      }
    }
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_PageGuide_UIBP, tb)
end
function logic_group_buying:IsGroupBuySuccess()
  if self.RefreshTimer then
    self:RemoveTimer(self.RefreshTimer)
    self.RefreshTimer = nil
  end
  local TimeUtil = require("client.common.time_util")
  local successList = self:GetCanBuyGroupList()
  log_tree(bWriteLog and "logic_group_buying:IsGroupBuySuccess successList", successList)
  local bSuccess = false
  for index, data in pairs(successList) do
    local bPopup = self:CheckGroupPopupById(data.group_buy_id)
    local bBuy = self:GetGiftLimited(data.package_id)
    if not bBuy and not bPopup then
      self:OnGroupBuySuccess(data.group_cfg_id, data.group_buy_id)
      bSuccess = true
    elseif not bBuy and not bSuccess and self:CheckCanGroupPopupNow() then
      local giftCfg = self.gifts_config[data.package_id]
      if giftCfg and TimeUtil.UnixTimeBetween(giftCfg.begin_time, giftCfg.end_time) == 0 then
        self:OnGroupBuySuccess(data.group_cfg_id, data.group_buy_id)
        bSuccess = true
      end
    end
  end
  local failList = self:GetFailedGroupList(true)
  log_tree(bWriteLog and "logic_group_buying:IsGroupBuySuccess failList", failList)
  for index, data in pairs(failList) do
    self:OnGroupBuyFail(data.group_cfg_id, data.group_buy_id)
  end
  local curList = self:GetInGroupList()
  log_tree(bWriteLog and "logic_group_buying:IsGroupBuySuccess curList", curList)
  local curTime = TimeUtil.GetServerTimeInSec()
  local nextTime
  for index, data in pairs(curList) do
    local giftCfg = self.gifts_config[data.package_id]
    if giftCfg then
      local buy_config = self:GetGiftBuyConfigById(data.group_cfg_id)
      local groupEndTime = data.create_time + buy_config.life_time or 0
      local giftEndTime = giftCfg.end_time or 0
      local time = math.min(groupEndTime, giftEndTime)
      if curTime > time then
        if not self:CheckGroupPopupById(data.group_buy_id) then
          self:OnGroupBuyFail(data.group_cfg_id, data.group_buy_id)
        end
      elseif not nextTime or nextTime > time then
        nextTime = time
        log(bWriteLog and "logic_group_buying:IsGroupBuySuccess nextTime", nextTime)
      end
    end
  end
  if nextTime then
    local delayTime = nextTime - TimeUtil.GetServerTimeInSec() + 5
    log(bWriteLog and "logic_group_buying:IsGroupBuySuccess delayTime", delayTime)
    self.RefreshTimer = self:AddTimerOnce(nextTime - TimeUtil.GetServerTimeInSec(), function()
      local NewGroupBuyHandler = RequireMod("client.network.Protocol.NewGroupBuyHandler")
      NewGroupBuyHandler.send_get_new_group_buy_info_req()
    end)
  end
end
function logic_group_buying:OnGroupBuySuccessNotify(group_id)
  local hitData
  for _, datas in pairs(self.group_list) do
    for _, data in pairs(datas) do
      if data.group_buy_id == group_id then
        if data.status ~= self.GROUP_BUY_STATUS.ACTIVE then
          data.status = self.GROUP_BUY_STATUS.ACTIVE
        end
        hitData = data
        break
      end
    end
    if hitData then
      break
    end
  end
  if not hitData then
    log(bWriteLog and "logic_group_buying:OnGroupBuySuccessNotify - group not found, id: " .. tostring(group_id))
    return
  end
  local bBuy = self:GetGiftLimited(hitData.package_id)
  if not bBuy then
    self:OnGroupBuySuccess(hitData.group_cfg_id, group_id)
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_NEW_GROUP_BUY_GET_INFO)
end
function logic_group_buying:CheckCanGroupPopupNow()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyPopup) or {}
  log_tree(bWriteLog and "logic_group_buying:CheckCanGroupPopupNow data", data)
  local count, interval = 0, true
  local popupCfg = CDataTable.GetTableData("new_group_success_tip_config", 1)
  local countCfg, intervalCfg = popupCfg.daily_count or 1, popupCfg.interval or 1
  log_tree(bWriteLog and "logic_group_buying:CheckCanGroupPopupNow popupCfg", popupCfg)
  data.timeList = data.timeList or {}
  for index, time in pairs(data.timeList) do
    if TimeUtil.IsSameDay(serverTime, time) then
      count = count + 1
    end
    if interval and serverTime - time < intervalCfg * 60 * 60 then
      interval = false
    end
  end
  if countCfg > count and interval then
    table.insert(data.timeList, serverTime)
    if countCfg < #data.timeList then
      table.remove(data.timeList, 1)
    end
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyPopup)
    return true
  end
  return false
end
function logic_group_buying:CheckGroupPopupById(group_id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyPopup) or {}
  data.groupList = data.groupList or {}
  log_tree(bWriteLog and "logic_group_buying:CheckGroupPopupById data", data)
  for groupId, _ in pairs(data.groupList) do
    if groupId == group_id then
      return true
    end
  end
  return false
end
function logic_group_buying:RecordGroupPopupById(group_id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyPopup) or {}
  data.groupList = data.groupList or {}
  data.groupList[group_id] = true
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyPopup)
end
function logic_group_buying:OnGroupBuySuccess(gift_id, ground_id)
  self:RecordGroupPopupById(ground_id)
  local giftCfg = self.gifts_buy_config[gift_id]
  if not giftCfg then
    log(bWriteLog and "logic_group_buying:OnGroupBuySuccess gift_id not found")
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", giftCfg.item_id)
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local title = LocUtil.GetLocalizeResStr(166061)
  local content = LocUtil.LocalizeResFormat(166062, itemCfg.ItemName)
  local sIconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby/GroupBuying/GroupBuying_Icon_05.GroupBuying_Icon_05"
  local jumpInfo = {
    callback = function()
      local group_info = self:GetGroupInfoByGroupBuyID(ground_id)
      local buy_config = self.gifts_buy_config[group_info.group_cfg_id]
      local base_config = self:GetGiftBaseConfigById(giftCfg.package_id)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      local title = LocUtil.GetLocalizeResStr(101001)
      local item_config = CDataTable.GetTableData("Item", buy_config.item_id)
      local paiedUC = 0
      if tonumber(DataMgr.roleData.uid) == group_info.creator_uid or tonumber(DataMgr.roleData.uid) == group_info.merge_peer_creator_uid then
        paiedUC = base_config.leader_uc
      else
        paiedUC = base_config.member_uc
      end
      local cost_id = buy_config.cost_id
      local cost_style_name = self.SHOW_ICON_NAME[cost_id]
      local voucher_id = self.DEPOSIT_DEDUCTION_VOUCHER_ID[cost_id]
      local voucher_config = CDataTable.GetTableData("Item", voucher_id)
      local content = LocUtil.LocalizeResFormat(166098, "<img src=\"" .. cost_style_name .. "\"/>", buy_config.group_price - paiedUC, item_config.ItemName)
      local buyFunc
      local Logic_ItemUtils = require("client.slua.logic.common.Logic_ItemUtils")
      local num = Logic_ItemUtils.GetItemCount(cost_id)
      local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
      if buy_config.group_price - paiedUC > tonumber(num) then
        function buyFunc()
          if cost_id == CoinMacro.Uc then
            local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
            CommonPayBoxMgr.ShowUcRechargeMsg(buy_config.group_price - paiedUC)
          else
            ShowNotice(9940211)
          end
        end
      else
        function buyFunc()
          local NewGroupBuyHandler = RequireMod("client.network.Protocol.NewGroupBuyHandler")
          NewGroupBuyHandler.send_pay_new_group_buy_req(group_info.group_buy_id)
        end
      end
      local cancelFunc = function()
        local title = LocUtil.GetLocalizeResStr(101001)
        local content = LocUtil.LocalizeResFormat(166067, paiedUC, voucher_config.ItemName, "<img src=\"" .. cost_style_name .. "\"/>", buy_config.group_price - paiedUC)
        local OKText = LocUtil.GetLocalizeResStr(166066)
        local CancelText = LocUtil.GetLocalizeResStr(166068)
        CommonMsgBoxMgr.Show(2, title, content, buyFunc, nil, OKText, CancelText)
      end
      CommonMsgBoxMgr.Show(2, title, content, buyFunc, cancelFunc)
    end
  }
  RightPopSystem.GroupBuyPopup(title, content, sIconPath, jumpInfo, 10, true)
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.NewGroupBuy)
end
function logic_group_buying:OnGroupBuyFail(gift_id, ground_id)
  self:RecordGroupPopupById(ground_id)
  local giftCfg = self.gifts_buy_config[gift_id]
  if not giftCfg then
    log(bWriteLog and "logic_group_buying:OnGroupBuySuccess gift_id not found")
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", giftCfg.item_id)
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local title = LocUtil.GetLocalizeResStr(166063)
  local content = LocUtil.LocalizeResFormat(166064, itemCfg.ItemName)
  local jumpInfo = {
    callback = function()
      GlobalData.JumpUrl("game://?module=9000230&id=20&group=fail")
    end
  }
  local sIconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby/GroupBuying/GroupBuying_Icon_05.GroupBuying_Icon_05"
  RightPopSystem.GroupBuyPopup(title, content, sIconPath, jumpInfo, 10, true)
end
function logic_group_buying:HasAward()
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = logic_activity_mgr.GetActivityByType(ActivityType.New_Group_Buying)
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
function logic_group_buying:BuyAble()
  local buyData = self:GetCanBuyGroupList()
  if next(buyData) then
    return true
  end
  return false
end
function logic_group_buying:StartCheckGroupToInvite()
  local buyData = self:GetInGroupList()
  log_tree("logic_group_buying:CheckGroupToInvite. buyData ", buyData)
  if not next(buyData) then
    log(bWriteLog and "logic_group_buying:StartCheckGroupToInvite.  buyData is empty")
    self:ClearInviteTimer()
    return
  end
  self:ClearInviteTimer()
  self.nCheckInviteTimer = self:AddTimerLoop(1, function()
    log(bWriteLog and "logic_group_buying:StartCheckGroupToInvite.  once")
    self:CheckGroupToInvite(buyData)
  end, 0, 120)
end
function logic_group_buying:InitOrderCfg()
  local gifts_buy_config = self.gifts_buy_config
  local orderCfg = {}
  for _, one in pairs(gifts_buy_config) do
    local packageId = one.package_id
    if not orderCfg[packageId] then
      orderCfg[packageId] = one.show_order
    end
  end
  self.order_cfg = orderCfg
end
function logic_group_buying:CheckGroupToInvite(buyData)
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local day = 86400
  local needPopup
  for _, data in pairs(buyData) do
    local group_buy_id = data.group_buy_id
    if not self.popupData[group_buy_id] then
      local buy_config = self:GetGiftBuyConfigById(data.group_cfg_id)
      local giftConfig = self.gifts_config[buy_config.package_id]
      local leftTime = data.create_time + buy_config.life_time - now
      if day > leftTime and 0 < leftTime then
        self.popupData[group_buy_id] = true
        if not needPopup then
          self:ShowPopupToInvite(giftConfig.id)
          needPopup = true
        end
      end
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.popupData, PlayerPrefsSystem.ePlayerPrefsType.eGroupBuyRedSuc)
  if not needPopup then
    self:ClearInviteTimer()
  end
end
function logic_group_buying:ClearInviteTimer()
  if self.nCheckInviteTimer then
    self:RemoveTimer(self.nCheckInviteTimer)
    self.nCheckInviteTimer = nil
  end
end
function logic_group_buying:ShowPopupToInvite(id)
  local buy_config = self:GetGiftsBuyConfig(id)
  log_tree("logic_group_buying:ShowPopupToInvite. buy_config ", buy_config)
  local itemId = buy_config[1].item_id
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local title = ""
  local content = LocUtil.LocalizeResFormat(166059, itemCfg.ItemName)
  local jumpInfo = {
    callback = function()
      local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
      special_offer_module:OpenGroupBuy()
    end
  }
  local sIconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby/GroupBuying/GroupBuying_Icon_05.GroupBuying_Icon_05"
  RightPopSystem.GroupBuyPopup(title, content, sIconPath, jumpInfo, 10, true)
end
function logic_group_buying:ShowMemberWithCheckDownload(group_info)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local cfg = UIManager.UI_Config.GroupBuying_Members_UIBP
  if PufferManager.ShowDownloadTips(PufferConst.ENUM_DownloadType.ODPACK, {
    cfg.path
  }) then
    return
  end
  local uidList = {}
  for _, v in pairs(group_info.members) do
    if v.uid then
      table.insert(uidList, v.uid)
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uidList, function(profileList)
    UIManager.ShowUI(UIManager.UI_Config.GroupBuying_Members_UIBP, group_info, profileList)
  end, Enum_PROFILE_REPORT_CFG.NEW_GROUP)
end
function logic_group_buying:GetItemLeftTime(time, end_time)
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = logic_activity_mgr.GetActivityByType(ActivityType.New_Group_Buying)
  local candidates = {}
  if type(time) == "number" then
    table.insert(candidates, time)
  end
  if type(end_time) == "number" then
    table.insert(candidates, end_time)
  end
  if ActivityData and type(ActivityData.EndTime) == "number" then
    table.insert(candidates, ActivityData.EndTime)
  end
  if #candidates == 0 then
    return time
  end
  local minTime = candidates[1]
  for i = 2, #candidates do
    if minTime > candidates[i] then
      minTime = candidates[i]
    end
  end
  return minTime
end
function logic_group_buying:GetGroupBuyShowCfg()
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  local showCfg = {}
  if not self.gifts_buy_config then
    return showCfg
  end
  local buyCfg = {}
  local VocherCfg = {}
  for k, buy_config in pairs(self.gifts_buy_config) do
    if buy_config.cost_id ~= CoinMacro.Uc then
      local base_config = self:GetGiftBaseConfigById(buy_config.package_id)
      local serverTime = require("client.common.time_util").GetServerTimeInSec()
      if base_config and base_config.end_time and base_config.begin_time and serverTime > base_config.begin_time and serverTime < base_config.end_time then
        local contain = false
        for k, v in pairs(buyCfg) do
          if v == buy_config.cost_id then
            contain = true
            break
          end
        end
        if not contain then
          table.insert(buyCfg, buy_config.cost_id)
          table.insert(VocherCfg, self.DEPOSIT_DEDUCTION_VOUCHER_ID[buy_config.cost_id])
        end
      end
    end
  end
  table.insert(showCfg, CoinMacro.DepositDeductionVoucher)
  for k, v in pairs(VocherCfg) do
    table.insert(showCfg, v)
  end
  table.insert(showCfg, CoinMacro.GeneralCoupon)
  table.insert(showCfg, CoinMacro.PremiumCoupon)
  table.insert(showCfg, CoinMacro.Uc)
  for k, v in pairs(buyCfg) do
    table.insert(showCfg, v)
  end
  return showCfg
end
function logic_group_buying:SetRegionConfig(region_config)
  self.end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CTemplate = class(CModuleBase, nil, logic_group_buying)
return CTemplate