local GodzillaBanSystem = {frameTime = 0.05}
local Items, SortedItems, Rewards, ExtInfo, BanTable, GetAwards, Decs
local BJumpAnim = false
local ActId, BCanDiscount, ShowProbabilities, Decomposes
local QUALITYlocal QUALITYlocal NBannerId
local ruleKeys = {
  24881,
  24882,
  24883,
  24884,
  24885,
  24886,
  24887,
  47419,
  24889
}
local super_data = require("common.super_data")
local ChangAbleData = super_data.CreateSuperData({coinNum = 0})
function GodzillaBanSystem.ReqData()
  local GodzillaHandler = require("client.network.Protocol.GodzillaBanHandler")
  GodzillaHandler.send_get_goslar_ban_info_req()
end
local SortFunc = function(a, b)
  return a.display_sort > b.display_sort
end
function GodzillaBanSystem.OnGetData(err_code, item_list, acc_reward_list, ext_info, decompose_list)
  if not GodzillaBanSystem.HandleError(err_code) then
    return
  end
  Items = item_list
  local TableUtil = require("common.table_util")
  SortedItems = TableUtil.CopyTable(item_list)
  for i, v in pairs(SortedItems) do
    v.oldIndex = i
  end
  table.sort(SortedItems, SortFunc)
  log_tree("  : SortedItems", SortedItems)
  Rewards = acc_reward_list
  log_tree("  : Rewards", Rewards)
  ExtInfo = ext_info
  log_tree("  : ExtInfo", ExtInfo)
  Decomposes = decompose_list
  ActId = ExtInfo.exchange_act_id
  log(bWriteLog and "  : ActId" .. tostring(ActId))
  GodzillaBanSystem.RefreshBanInfo()
  GodzillaBanSystem.RefreshProbabilities()
  GodzillaBanSystem.RefreshCoinNum()
  EventSystem:postEvent(EVENTTYPE_GODZILLA_BAN, EVENTID_GODZILLA_BAN_INFO)
end
function GodzillaBanSystem.RefreshBanInfo()
  local bans = ExtInfo and ExtInfo.ban_item_index
  BanTable = {}
  if bans and next(bans) then
    for _, v in pairs(bans) do
      BanTable[v] = true
    end
  end
end
function GodzillaBanSystem.RefreshProbabilities()
  local allWeight = 0
  local itemNum = #SortedItems
  for i = 1, itemNum do
    allWeight = SortedItems[i].weight + allWeight
  end
  ShowProbabilities = {
    0,
    0,
    0,
    0,
    0
  }
  for i = 1, itemNum do
    ShowProbabilities[i] = SortedItems[i].weight / allWeight
  end
end
function GodzillaBanSystem.GetProbabilities()
  return ShowProbabilities or {}
end
function GodzillaBanSystem.ReqBan(banData, newBanNums)
  local qualities = {}
  for v, _ in pairs(banData) do
    if not qualities[SortedItems[v].quality] then
      qualities[SortedItems[v].quality] = 1
    else
      qualities[SortedItems[v].quality] = qualities[SortedItems[v].quality] + 1
    end
  end
  local ban_info = {}
  local num
  for qua, _ in pairs(qualities) do
    local info = GodzillaBanSystem.CanBanPriceAndNum(qua)
    num = newBanNums[qua]
    local lost = info.free_times - (info.free_use_times or 0)
    local freeNum = num
    if num > lost then
      freeNum = lost
    end
    local costNum = num - freeNum
    if costNum < 0 then
      costNum = 0
    end
    ban_info[qua] = {
      free_times = freeNum,
      cost_times = costNum,
      item_list = {}
    }
  end
  for v, _ in pairs(banData) do
    ban_info[SortedItems[v].quality].item_list[SortedItems[v].oldIndex] = SortedItems[v].item_id
  end
  log_tree("  : ban_info", ban_info)
  local GodzillaHandler = require("client.network.Protocol.GodzillaBanHandler")
  GodzillaHandler.send_goslar_ban_confirm_req(ban_info)
end
function GodzillaBanSystem.OnBan(err_code, details, ban_item_index, _, banList)
  if not GodzillaBanSystem.HandleError(err_code) then
    return
  end
  log_tree("  : details", details)
  log_tree("  : ban_item_index", ban_item_index)
  log_tree("  : banList", banList)
  ExtInfo.cost_uc_ban_list = banList
  for quality, v in pairs(details) do
    local banInfo = GodzillaBanSystem.CanBanPriceAndNum(quality)
    banInfo.free_times = v.free_times
    banInfo.free_use_times = v.free_use_times
    banInfo.cost_times = v.cost_times
  end
  ExtInfo.  GodzillaBanSystem.RefreshBanInfo()
  EventSystem:postEvent(EVENTTYPE_GODZILLA_BAN, EVENTID_GODZILLA_BAN_BAN_CHANGE)
end
function GodzillaBanSystem.HaveTicket()
  local onePrice = GodzillaBanSystem.GetPrices()
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local showCoupon = CouponSystem.IsHaveCouldUseCoupon(CouponSystem._Enum_Scene._GodzillaBan, onePrice, NBannerId)
  return showCoupon
end
function GodzillaBanSystem.NoTicket(needTicket)
  log(bWriteLog and "  :NoTicket   DataMgr.ticket" .. tostring(DataMgr.ticket))
  if needTicket > DataMgr.ticket then
    GodzillaBanSystem.AskRecharge(needTicket)
    return true
  end
end
function GodzillaBanSystem.SendDraw(type, again)
  local onePrice, tenPrice = GodzillaBanSystem.GetPrices()
  local GodzillaHandler = require("client.network.Protocol.GodzillaBanHandler")
  local content = LocUtil.GetLocalizeResStr(7625)
  local title = LocUtil.GetLocalizeResStr(6177)
  log(bWriteLog and "  : type" .. tostring(type))
  log(bWriteLog and "  : BCanDiscount" .. tostring(BCanDiscount))
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  log(bWriteLog and "  : NBannerId" .. tostring(NBannerId))
  local showCoupon = CouponSystem.IsHaveCouldUseCoupon(CouponSystem._Enum_Scene._GodzillaBan, onePrice, NBannerId)
  local price = onePrice
  if type == 10 then
    price = tenPrice
    content = LocUtil.GetLocalizeResStr(7626)
    BCanDiscount = false
    showCoupon = false
  end
  log(bWriteLog and "  : showCoupon: " .. tostring(showCoupon))
  if BCanDiscount or not showCoupon then
    content = LocUtil.LocalizeResFormat(10624, price)
    if type == 10 then
      content = LocUtil.LocalizeResFormat(10625, price)
    end
    if GodzillaBanSystem.NoTicket(price) then
      return
    end
    if again then
      GodzillaHandler.send_goslar_ban_draw_req(type, BCanDiscount)
    else
      log(bWriteLog and "  :CommonMsgBoxMgr GodzillaHandler.send_goslar_ban_draw_req")
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, title, content, function()
        GodzillaHandler.send_goslar_ban_draw_req(type, BCanDiscount)
      end)
    end
    return
  end
  CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._GodzillaBan
  local tShowCfg = {
    nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
    sTitle = title,
    sTipContent = content,
    nMainScene = CouponSystem._Enum_Scene._GodzillaBan,
    nChildScene = NBannerId,
    nCurPrice = price,
    fConfirmCallback = function(confirmData)
      if CouponSystem.IsLimitCoupon(confirmData.nCurCouponId) then
        local IsReachLimitPrice, couponPrice = CouponSystem.IsReachLimitPrice(price)
        if IsReachLimitPrice then
          log(bWriteLog and "  : couponPrice" .. tostring(couponPrice))
          if GodzillaBanSystem.NoTicket(price - (couponPrice or 0)) then
            return
          end
          log(bWriteLog and "  : coupon_id" .. tostring(confirmData.nCurCouponId))
          GodzillaHandler.send_goslar_ban_draw_req(type, BCanDiscount, confirmData.nCurCouponId)
          return
        end
      end
      if GodzillaBanSystem.NoTicket(price) then
        return
      end
      GodzillaHandler.send_goslar_ban_draw_req(type, BCanDiscount)
    end
  }
  UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_General, tShowCfg)
end
function GodzillaBanSystem.OneDraw(again)
  GodzillaBanSystem.SendDraw(1, again)
end
function GodzillaBanSystem.TenDraw(again)
  GodzillaBanSystem.SendDraw(10, again)
end
function GodzillaBanSystem.OnDraw(err_code, item_list, decompose_list, ext_info)
  if not GodzillaBanSystem.HandleError(err_code) then
    if tonumber(err_code) == 112900014 then
      GodzillaBanSystem.ReqData()
    end
    return
  end
  log_tree("  : item_list", item_list)
  log_tree("  : decompose_list", decompose_list)
  GetAwards = item_list
  Decs = decompose_list
  if ext_info then
    log_tree("  : ext_info", ext_info)
    for i, v in pairs(ext_info) do
      ExtInfo[i] = v
    end
    ExtInfo.draw_price.can_dis_cost = ext_info.can_dis_cost
  end
  local type = 1
  if 1 < #item_list then
    type = 10
  end
  EventSystem:postEvent(EVENTTYPE_GODZILLA_BAN, EVENTID_GODZILLA_BAN_DRAW, type, item_list)
end
function GodzillaBanSystem.OnGetAward(err_code, item_list, acc_reward)
  if not GodzillaBanSystem.HandleError(err_code) then
    return
  end
  log_tree("  : item_list", item_list)
  log_tree("  : acc_reward", acc_reward)
  if acc_reward and next(acc_reward) then
    for i, v in pairs(acc_reward) do
      Rewards.acc_reward[i].status = v.status
    end
  end
  EventSystem:postEvent(EVENTTYPE_GODZILLA_BAN, EVENTID_GODZILLA_BAN_AWARD)
  Decs = {}
  GetAwards = item_list
  GodzillaBanSystem.ShowRewardCommon()
end
function GodzillaBanSystem.HandleError(code)
  log(bWriteLog and "  : code" .. tostring(code))
  if code == 0 then
    return true
  elseif tonumber(code) == 112900016 or tonumber(code) == 112900015 then
    GodzillaBanSystem.AskRecharge()
    return
  end
  if tonumber(code) == 112900011 then
  end
  ShowNotice(code)
end
function GodzillaBanSystem.GetSortedItems()
  return SortedItems
end
function GodzillaBanSystem.GetRewards()
  return Rewards
end
function GodzillaBanSystem.GetExtInfo()
  return ExtInfo
end
function GodzillaBanSystem.CanBanPriceAndNum(quality)
  return ExtInfo.ban_info.details[quality]
end
function GodzillaBanSystem.GetAllFreeTimes()
  local num = 0
  for i = QUALITY5, QUALITY7 do
    local info = GodzillaBanSystem.CanBanPriceAndNum(i)
    num = num + (info and info.free_times or 0)
  end
  return num
end
function GodzillaBanSystem.GetLeftFreeTimes()
  local num = 0
  for i = QUALITY5, QUALITY7 do
    local info = GodzillaBanSystem.CanBanPriceAndNum(i)
    num = num + (info and info.free_times or 0) - (info and info.free_use_times or 0)
  end
  return num
end
function GodzillaBanSystem.HasFreeNum()
  for i = QUALITY5, QUALITY7 do
    local info = GodzillaBanSystem.CanBanPriceAndNum(i)
    if info.free_times > (info.free_use_times or 0) then
      return true
    end
  end
end
function GodzillaBanSystem.GetCurBanPrice(quality, length)
  local info = GodzillaBanSystem.CanBanPriceAndNum(quality)
  if info then
    local lostNum = length - (info.free_times - (info.free_use_times or 0))
    log(bWriteLog and "  : lostNum" .. tostring(lostNum))
    if 0 < lostNum then
      local priceTb = info.price[lostNum]
      if priceTb then
        return priceTb.value
      else
        log_error("priceTb error")
        log_tree("GetCurBanPrice info", info)
        return 0
      end
    else
      return 0
    end
  end
  log_error(bWriteLog and "  : GodzillaBanSystem.GetCurBanPrice error")
  return 0
end
function GodzillaBanSystem.ToNewIndex(oldIndex)
  for i, v in pairs(SortedItems) do
    if v.oldIndex == oldIndex then
      return i
    end
  end
  log_error("GodzillaBanSystem.ToNewIndex error oldIndex" .. tostring(oldIndex))
  return 1
end
function GodzillaBanSystem.GetBan(index)
  if not BanTable then
    return false
  end
  local oldIndex = SortedItems[index].oldIndex
  return BanTable[oldIndex] or false
end
function GodzillaBanSystem.GetPrices()
  local ext = GodzillaBanSystem.GetExtInfo()
  local prices = ext and ext.draw_price
  local onePrice = 101
  local tenPrice = 101
  if prices then
    onePrice = prices.single_cost
    BCanDiscount = prices.can_dis_cost
    if prices.can_dis_cost then
      onePrice = prices.first_draw_price
    end
    tenPrice = prices.ten_cost
  end
  return onePrice, tenPrice, BCanDiscount, prices and prices.single_cost
end
function GodzillaBanSystem.SetJump(jump)
  BJumpAnim = jump
end
function GodzillaBanSystem.GetJump()
  return BJumpAnim
end
function GodzillaBanSystem.GetDrawAwards()
  return GetAwards
end
function GodzillaBanSystem.GetCoinNum()
  if ActId then
    local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
    return LuckybackActivitySystem.GetDebrisItemCountInExchange(ActId)
  end
  return 0
end
function GodzillaBanSystem.GetCoinPath()
  if not ActId then
    GodzillaBanSystem.ReqData()
    return ""
  end
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  local resId = LuckybackActivitySystem.GetDebrisItemIdInExchange(ActId)
  if resId == 0 then
    return
  end
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetItemSmallIcon(resId)
end
function GodzillaBanSystem.GetActTime()
  local TimeUtil = require("client.common.time_util")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local back_act_list = ActivityNewSystem.GetActivityListByType(ActivityType.GODZILLA_BAN)
  local act = back_act_list and back_act_list[1]
  if not act then
    return ""
  end
  local startTime = act and act.StartTime or 0
  local endTime = act and act.EndTime or 0
  local timeStr = TimeUtil.FormatTime_timeFrame(startTime, endTime, false, true)
  NBannerId = act.ID
  return timeStr
end
function GodzillaBanSystem.GetHelpStr()
  local   local words = {}
  for _, v in pairs(ruleKeys) do
    table.insert(words, LocUtil.GetLocalizeResStr(v))
  end
  local probabilities = GodzillaBanSystem.GetProbabilities()
  local _items = GodzillaBanSystem.GetSortedItems()
  if not _items then
    GodzillaBanSystem.ReqData()
    return ""
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if not GlobalData.IsJapanOrKorea() then
    table.insert(words, LocUtil.GetLocalizeResStr(24890))
    local itemNum = #_items
    local itemData
    for i = 1, itemNum do
      itemData = CDataTable.GetTableData("Item", _items[i].item_id)
      local day = tonumber(_items[i].valid_hours) / 24
      if day == 0 then
        table.insert(words, LocUtil.LocalizeResFormat(37253, itemData.itemName, _items[i].count, string.format("%.2f", (probabilities[i] or 0) * 100)))
      else
        table.insert(words, LocUtil.LocalizeResFormat(37254, itemData.itemName, day, _items[i].count, string.format("%.2f", (probabilities[i] or 0) * 100)))
      end
    end
  end
  table.insert(words, LocUtil.GetLocalizeResStr(25294))
  local resData, desData
  if Decomposes then
    for res, des in pairs(Decomposes) do
      resData = CDataTable.GetTableData("Item", res)
      desData = CDataTable.GetTableData("Item", des)
      if resData and desData then
        table.insert(words, LocUtil.LocalizeResFormat(25295, resData.itemName, desData.itemName))
      end
    end
  end
  local sHelpWords = table.concat(words, "\n")
  return sHelpWords
end
function GodzillaBanSystem.DontBan()
  local result
  if not BanTable or not next(BanTable) then
    result = true
  end
  return result
end
function GodzillaBanSystem.GetBtnSound()
  return sound_config.click_v1
end
function GodzillaBanSystem.GetChangAbleData()
  return ChangAbleData
end
function GodzillaBanSystem.RefreshCoinNum()
  ChangAbleData.coinNum = GodzillaBanSystem.GetCoinNum()
end
function GodzillaBanSystem.RefreshTimes(addTime)
  local TableUtil = require("common.table_util")
  local progress = TableUtil.GetTableValue(Rewards, "progress")
  progress.cur = progress.cur + addTime
  EventSystem:postEvent(EVENTTYPE_GODZILLA_BAN, EVENTID_GODZILLA_BAN_AWARD)
end
function GodzillaBanSystem.AskRecharge(price)
  local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
  CommonPayBoxMgr.ShowUcRechargeMsg(price)
end
function GodzillaBanSystem.ShowExchangeUI()
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.OpenExchangeStoreExternal(true, ActId, "/Game/Arts_UI/LuckySpin/2400/Global/PetLucky/Panda_Spin_Exchange_UIBP.Panda_Spin_Exchange_UIBP", nil, 31)
end
function GodzillaBanSystem.DrawWithAsk(type)
  local callBack = GodzillaBanSystem.OneDraw
  if type == 10 then
    callBack = GodzillaBanSystem.TenDraw
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local ban = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.godzilla_ban_popup)
  if (not ban or not ban.bShow) and GodzillaBanSystem.DontBan() then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local str = LocUtil.GetLocalizeResStr(101001)
    local tip = LocUtil.LocalizeResFormat(25235)
    CommonMsgBoxMgr.Show(2, str, tip, callBack)
    PlayerPrefsSystem.SaveTableToFile_N({bShow = true}, PlayerPrefsSystem.ePlayerPrefsType.godzilla_ban_popup)
  else
    callBack()
  end
end
function GodzillaBanSystem.ShowRewardCommon(showAgain, drawType)
  if not GetAwards then
    return
  end
  GodzillaBanSystem.RefreshCoinNum()
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.delay_item_decompose_notice()
  if drawType then
    GodzillaBanSystem.RefreshTimes(drawType)
  end
  local decomposeList = {}
  for i, v in pairs(Decs) do
    decomposeList[i] = {
      itemid = v.resid,
      count = v.count
    }
  end
  local list = {}
  for _, v in pairs(GetAwards) do
    local item = {}
    item.res_id = v.resid or v.res_id
    item.valid_hours = v.valid_hours
    item.count = v.count
    table.insert(list, item)
  end
  local tExtendData = {}
  if showAgain then
    local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
    local onePrice, tenPrice = GodzillaBanSystem.GetPrices()
    if 1 < #GetAwards then
      local fCallback = function()
        GodzillaBanSystem.TenDraw(true)
      end
      tExtendData.tAllBtnShowData = CommonItemGet_BtnCfgUtils.CreateConsecutiveDrawBtnData(true, tenPrice, fCallback)
    elseif #GetAwards == 1 then
      local fCallback = function()
        GodzillaBanSystem.OneDraw(true)
      end
      tExtendData.tAllBtnShowData = CommonItemGet_BtnCfgUtils.CreateConsecutiveDrawBtnData(false, onePrice, fCallback)
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DecomposeStyle(list, decomposeList)
  GetAwards = nil
end
function GodzillaBanSystem.ShowMain()
  local TimeUtil = require("client.common.time_util")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local back_act_list = ActivityNewSystem.GetActivityListByType(ActivityType.GODZILLA_BAN)
  local act = back_act_list and back_act_list[1]
  local startTime = act and act.StartTime or 0
  local endTime = act and act.EndTime or 0
  local ret = TimeUtil.UnixTimeBetween(startTime, endTime)
  if ret == -1 then
    ShowNotice(120106)
    return
  elseif ret == 1 then
    ShowNotice(4002)
    return
  end
end
function GodzillaBanSystem.ShowBan()
  EventSystem:postEvent(EVENTTYPE_GODZILLA_BAN, EVENTID_GODZILLA_BAN_CLOSE_BAN, false)
end
function GodzillaBanSystem.ShowHelp()
  local title = LocUtil.GetLocalizeResStr(4726)
  UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, GodzillaBanSystem.GetHelpStr())
end
return GodzillaBanSystem