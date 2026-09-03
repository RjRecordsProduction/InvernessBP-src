local C_SORT_PRICE = 1
local C_SORT_TIME = 2
local C_EXPIRE_SOON = 259200
local currentSelectCouponId, currentSelectScene
local CouponSystem = {
  _Ori_Coupon_List = {},
  _bIsBuildIndex = false,
  _Scene_Coupon_List = {},
  _RP_Coupon_List = {},
  _Enum_Scene = {
    _ClothesBuy = 1,
    _TresureBuy = 2,
    _SupplyBox1 = 3,
    _SupplyBox2 = 4,
    _Draw = 5,
    _LuckySpin = 6,
    _UnknowPass = 7,
    _LuckyDouble = 8,
    _HolaMonster = 9,
    _LadderDraw = 10,
    _GoldenSuit = 11,
    _GodzillaBan = 12,
    _SupplyBoxAct = 13,
    _TeddyBear = 14,
    _SupplyBoxCst = 15,
    _RechargePurchase = 16,
    _LuckMix = 17,
    Black5 = 18,
    _ScrapGold = 19,
    _UCGiftBag = 20,
    _RPBackBox = 21,
    _TarotCard = 22,
    _PrizePathChest = 23,
    _SubscribeLimit = 24,
    _GoldenSuitSpin = 25,
    _SpecialOfferCondition = 26,
    _LukcyOptionalTurntable = 27,
    _Lucky_Draw_Virtul = 28,
    _LuckyMidCarSpin = 29,
    _FridayRPGroup = 30,
    _CharacterBox = 31
  },
  _Enum_CouponPopupType = {
    _Normally = 1,
    _FixedDiscount = 2,
    _TheBest = 3
  },
  _cur_coupon_showing_item_id = 0,
  _cur_coupon_scene = 0,
  sortStyleList = {
    [C_SORT_PRICE] = {Id = 31068},
    [C_SORT_TIME] = {Id = 31069}
  },
  FromModule = {store = 1, crate = 2},
  isGMOpen = false
}
local getSceneNum = function(value)
  local num = 0
  if value and value.scenes and type(value.scenes) == "table" then
    for i, v in pairs(value.scenes) do
      num = num + 1
    end
  end
  return num
end
function CouponSystem.OnLogin()
  log(bWriteLog and "[chub]CouponSystem.OnLogin(bReLogin)")
  local cfg = LobbySystem.roleData.discount_cfg
  if next(cfg or {}) then
    CouponSystem._Ori_Coupon_List = cfg
  end
  CouponSystem._bIsBuildIndex = false
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  local task = {
    module = CouponSystem,
    funcName = "BuildCouponListIndex",
    debugInfo = "CouponSystem",
    protect = true
  }
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Login, task)
end
function CouponSystem._GetSceneCouponList()
  CouponSystem._BuildCouponListIndex()
  return CouponSystem._Scene_Coupon_List
end
function CouponSystem.BuildCouponListIndex()
  CouponSystem._BuildCouponListIndex()
end
function CouponSystem._BuildCouponListIndex()
  local ori_table = CouponSystem._Ori_Coupon_List
  if not next(ori_table or {}) then
    return
  end
  if not CouponSystem._bIsBuildIndex then
    CouponSystem._Scene_Coupon_List = {}
    for itemId, v in pairs(ori_table or {}) do
      for ii, scene in pairs(v.scenes or {}) do
        if not CouponSystem._Scene_Coupon_List[scene] then
          CouponSystem._Scene_Coupon_List[scene] = {}
        end
        CouponSystem._Scene_Coupon_List[scene][itemId] = v
      end
    end
    CouponSystem._bIsBuildIndex = true
    log(bWriteLog and "CouponSystem._BuildCouponListIndex()")
  end
end
function CouponSystem.GetOriCouponList()
  return CouponSystem._Ori_Coupon_List
end
function CouponSystem.GetCouponListByScene(Enum_Scene)
  if not Enum_Scene then
    return nil
  end
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(CouponSystem._GetSceneCouponList(), Enum_Scene)
end
function CouponSystem.GetCouponListBySceneWithoutChildScene(Enum_Scene)
  if not Enum_Scene then
    return nil
  end
  local list = CouponSystem._GetSceneCouponList() or {}
  if not list[Enum_Scene] then
    return nil
  end
  local couponlist = list[Enum_Scene]
  local SubCouponSceneList = {}
  local TableUtil = require("common.table_util")
  for i, v in pairs(couponlist) do
    if TableUtil.CountTable(v.child_scene_list) == 0 then
      SubCouponSceneList[i] = v
    end
  end
  return SubCouponSceneList
end
function CouponSystem.GetChildCouponList(Enum_Scene, child_scene)
  local couponlist = CouponSystem.GetCouponListByScene(Enum_Scene)
  if not couponlist then
    return nil
  end
  local SubCouponSceneList = {}
  local TableUtil = require("common.table_util")
  for itemId, v in pairs(couponlist) do
    if TableUtil.CountTable(v.child_scene_list) == 0 or v.child_scene_list and v.child_scene_list[child_scene] then
      SubCouponSceneList[itemId] = v
    end
  end
  return SubCouponSceneList
end
function CouponSystem.GetCouponByList(mainScene, list)
  local couponList = CouponSystem.GetCouponListByScene(mainScene)
  if not couponList then
    return nil
  end
  local SubCouponSceneList = {}
  for i, v in pairs(couponList) do
    for j, k in pairs(list) do
      if i == k then
        SubCouponSceneList[i] = v
      end
      if mainScene == CouponSystem._Enum_Scene._LuckyDouble and j == i then
        SubCouponSceneList[i] = v
      end
    end
  end
  return SubCouponSceneList
end
function CouponSystem.IsHaveTheseCouponAndShowCouponList(mainScene, list)
  local IsShow = false
  local ShowCouponList = CouponSystem.GetCouponByList(mainScene, list) or {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local res = {}
  for i, _ in pairs(ShowCouponList) do
    local itemList = wardrobe_data:GetHallDepotItemListByResID(i)
    if itemList then
      for _, itemdatainfo in pairs(itemList) do
        if DataMgr.IsValidTime(itemdatainfo.expireTS) then
          IsShow = true
          local temptable = {
            scenes = ShowCouponList[itemdatainfo.resID].scenes or {},
            value = ShowCouponList[itemdatainfo.resID].value or 0,
            price_limit = ShowCouponList[itemdatainfo.resID].price_limit or 0,
            expireTS = itemdatainfo.expireTS,
            resID = itemdatainfo.resID,
            count = itemdatainfo.count or 0,
            insID = itemdatainfo.insID
          }
          table.insert(res, temptable)
        end
      end
    end
  end
  return IsShow, res
end
function CouponSystem.IsShowCouponAndShowCouponList(scene, child_scene, except_map)
  local IsShow = false
  local ShowCouponList = {}
  if not scene then
    return false, ShowCouponList
  end
  local Scene_Coupon_List = {}
  if child_scene then
    Scene_Coupon_List = CouponSystem.GetChildCouponList(scene, child_scene)
  else
    Scene_Coupon_List = CouponSystem.GetCouponListBySceneWithoutChildScene(scene)
  end
  if not Scene_Coupon_List then
    return false, ShowCouponList
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local num = 0
  log_tree("except_map ", except_map)
  local LuckyDoubleActivitySystem = require("client.slua.logic.lobby_activity.logic_luckydouble_activity")
  local voucher_list = LuckyDoubleActivitySystem.GetCouponListWithActivityIdAndCurRound()
  local luckDoubleActivityId = LuckyDoubleActivitySystem.ActivityId
  for i, v in pairs(Scene_Coupon_List) do
    local itemList = wardrobe_data:GetHallDepotItemListByResID(i)
    if (not except_map or not except_map[i]) and itemList then
      for k, info in pairs(itemList) do
        if DataMgr.IsValidTime(info.expireTS) then
          local temptable = {}
          temptable.scenes = Scene_Coupon_List[info.resID].scenes or {}
          temptable.value = Scene_Coupon_List[info.resID].value or 0
          temptable.price_limit = Scene_Coupon_List[info.resID].price_limit or 0
          temptable.expireTS = info.expireTS or 0
          temptable.resID = info.resID
          temptable.count = info.count or 0
          temptable.isNew = info.isNew
          temptable.insID = info.insID
          if luckDoubleActivityId and child_scene and luckDoubleActivityId == child_scene then
            if voucher_list and temptable.resID and voucher_list[temptable.resID] then
              IsShow = true
              table.insert(ShowCouponList, temptable)
            end
          else
            local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
            local tCouponList = PassDataSystem.GetPercentCouponInfo()
            if UIManager.IsUIShow(UIManager.UI_Config.UnknowPass_Discount_Buy_UIBP) then
              if info.resID == tCouponList.itemId then
                IsShow = true
                table.insert(ShowCouponList, temptable)
              end
            elseif info.resID ~= tCouponList.itemId then
              IsShow = true
              table.insert(ShowCouponList, temptable)
            end
          end
          num = num + temptable.count
        end
      end
    end
  end
  return IsShow, ShowCouponList, num
end
function CouponSystem.GetCurShowCouponValue(ori_price, Scene, child_scene, except_map)
  if not ori_price or type(ori_price) ~= "number" then
    return 0
  end
  local _, ShowCouponList = CouponSystem.IsShowCouponAndShowCouponList(Scene, child_scene, except_map)
  local maxValue = 0
  if ShowCouponList and next(ShowCouponList) then
    for _, couponCfg in pairs(ShowCouponList) do
      if couponCfg.price_limit and 0 < couponCfg.price_limit and ori_price >= couponCfg.price_limit and maxValue < couponCfg.value then
        maxValue = couponCfg.value
      end
      if (not couponCfg.price_limit or 0 >= couponCfg.price_limit) and maxValue < couponCfg.value then
        maxValue = couponCfg.value
      end
    end
  end
  if ori_price < maxValue then
    maxValue = ori_price
  end
  return maxValue
end
function CouponSystem.SetCurShowingCouponItemId(item_id)
  CouponSystem._cur_coupon_showing_end
function CouponSystem.GetCurShowingCouponItemId()
  return CouponSystem._cur_coupon_showing_item_id
end
function CouponSystem.GetCouponInfoByItemId(item_id)
  if not item_id then
    log_error("GetCouponInfoByItemId item_id = nil")
    return nil
  end
  if not CouponSystem._Ori_Coupon_List[item_id] then
    log(bWriteLog and "GetCouponInfoByItemId_Ori_Coupon_List item_id = nil")
    return nil
  end
  return CouponSystem._Ori_Coupon_List[item_id]
end
function CouponSystem.GetCurShowingCouponInfo()
  local CurShowingCouponItemId = CouponSystem.GetCurShowingCouponItemId()
  if not CurShowingCouponItemId then
    log_error("GetCouponInfoByItemId item_id = nil")
    return nil
  end
  return CouponSystem.GetCouponInfoByItemId(CurShowingCouponItemId)
end
function CouponSystem.IsLimitCoupon(item_id)
  if CouponSystem._Ori_Coupon_List[item_id] and CouponSystem._Ori_Coupon_List[item_id].price_limit > 0 then
    return true
  end
  return false
end
function CouponSystem.IsReachLimitPrice(ori_price)
  if not ori_price then
    log_error("IsReachLimitPrice no ori_price")
    return false
  end
  local cur_coupon_info = CouponSystem.GetCouponInfoByItemId(CouponSystem.GetCurShowingCouponItemId())
  if not cur_coupon_info or not cur_coupon_info.price_limit then
    log_error("IsReachLimitPrice no cur_coupon_info")
    return false
  end
  return ori_price >= cur_coupon_info.price_limit, cur_coupon_info.value
end
function CouponSystem.IsHaveCouldUseCoupon(scene, price, child_scene)
  if not scene then
    log_error("IsHaveCouldUseCoupon no scene")
    return false
  end
  if not price then
    log_error("IsHaveCouldUseCoupon no price")
    return false
  end
  local cur_scene_list = {}
  if child_scene then
    cur_scene_list = CouponSystem.GetChildCouponList(scene, child_scene)
  else
    cur_scene_list = CouponSystem.GetCouponListBySceneWithoutChildScene(scene)
  end
  if not cur_scene_list or not next(cur_scene_list) then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for itemId, v in pairs(cur_scene_list) do
    local value = CouponSystem._Ori_Coupon_List[itemId]
    if value.price_limit == 0 then
      local isHave = wardrobe_data:HasValidItem(tonumber(itemId))
      if isHave then
        return true
      end
    elseif price >= value.price_limit then
      local isHave = wardrobe_data:HasValidItem(tonumber(itemId))
      if isHave then
        return true
      end
    end
  end
  return false
end
function CouponSystem.GetCouponValue(nCurPrice, nDisLevel)
  local nCurCouponItemId = CouponSystem.GetCurShowingCouponItemId()
  if not nCurCouponItemId then
    return 0
  end
  local tCouponData = CouponSystem.GetCouponInfoByItemId(nCurCouponItemId)
  if not tCouponData then
    return 0
  end
  local nCouponValue = tCouponData.value
  if nCouponValue <= 0 then
    return 0
  end
  if CouponSystem.IsLimitCoupon(nCurCouponItemId) then
    local bIsReachLimitPrice = CouponSystem.IsReachLimitPrice(nCurPrice)
    if not bIsReachLimitPrice then
      return 0
    end
  end
  if nDisLevel then
    local keyValue = "value" .. nDisLevel
    if tCouponData[keyValue] then
      nCouponValue = tCouponData[keyValue]
    end
  end
  return nCouponValue, nCurCouponItemId, tCouponData
end
function CouponSystem.JumpByItemInfo(iteminfo, isFromWardrobe)
  if not iteminfo then
    log_error("CouponSystem no this JumpItemId")
    return false
  end
  local item_tips_util = require("client.slua.umg.Wardrobe.tips.item_tips_util")
  local bJumpCharacter = item_tips_util:CanJumpSupplyRolePool(iteminfo.jumpExchangeUrl)
  if bJumpCharacter then
    GlobalData.JumpUrl(iteminfo.jumpExchangeUrl)
    return true
  end
  local coupondata = CouponSystem._Ori_Coupon_List[iteminfo.res_id]
  if not coupondata then
    return false
  end
  if not coupondata.scenes or not next(coupondata.scenes) then
    log_error("NO Scene Data")
    return false
  end
  local TableUtil = require("common.table_util")
  if TableUtil.CountTable(coupondata.scenes) > 1 and iteminfo.jumpExchangeUrl and iteminfo.jumpExchangeUrl ~= "" then
    GlobalData.JumpUrl(iteminfo.jumpExchangeUrl)
    return true
  end
  local scene = 0
  for i, v in pairs(coupondata.scenes) do
    scene = v
  end
  CouponSystem.JumpByScene(scene, iteminfo, isFromWardrobe)
  return true
end
function CouponSystem.JumpByScene(scene, iteminfo, isFromLobbyWardrobe)
  log(bWriteLog and "[cw] CouponSystem.JumpByScene(" .. tostring(scene) .. "," .. tostring(iteminfo) .. ", " .. tostring(isFromLobbyWardrobe) .. ") ")
  local JumpUtils = require("client.logic.store.jump_utils")
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  if scene == CouponSystem._Enum_Scene._ClothesBuy then
    local jump_utils = require("client.logic.store.jump_utils")
    jump_utils.OpenJumpModule(BP_ENUM_MODULE_MALL_CHILD, {
      Tab1 = StoreConst.Page_New_ID_Cloth
    })
  elseif scene == CouponSystem._Enum_Scene._TresureBuy then
    local jump_utils = require("client.logic.store.jump_utils")
    jump_utils.OpenJumpModule(BP_ENUM_MODULE_MALL_CHILD, {
      Tab1 = StoreUtils.GetDirectBuyTab()
    })
  elseif scene == CouponSystem._Enum_Scene._SupplyBoxAct then
    if iteminfo.jumpExchangeUrl and iteminfo.jumpExchangeUrl ~= "" then
      GlobalData.JumpUrl(iteminfo.jumpExchangeUrl)
    end
  elseif scene == CouponSystem._Enum_Scene._SupplyBox1 then
    local DianCangMaxId = 0
    local DianCangLowestID = 0
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() then
      if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
        DianCangMaxId = 201999
        DianCangLowestID = 201001
      else
        DianCangMaxId = 205999
        DianCangLowestID = 205001
      end
    else
      DianCangMaxId = 100999
      DianCangLowestID = 100000
    end
    local dataMap = JumpUtils.TryGetJumpItemMap(JumpUtils.MODEL_ID_SUPPLY)
    if dataMap ~= nil then
      for _, data in pairs(dataMap) do
        if DianCangLowestID <= data.Tab1 and DianCangMaxId >= data.Tab1 then
          local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
          store_supply_manager:JumpToCrateByTabId(data.Tab1)
          return
        end
      end
      ShowNotice(7747)
    else
      log(bWriteLog and "CouponSystem.JumpByScene RequestJumpMapInfo 1")
      JumpUtils.RequestJumpMapInfo(false, function()
        local DataMap = JumpUtils.TryGetJumpItemMap(JumpUtils.MODEL_ID_SUPPLY)
        if DataMap ~= nil then
          for _, data in pairs(DataMap) do
            if data.Tab1 >= DianCangLowestID and data.Tab1 <= DianCangMaxId then
              local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
              store_supply_manager:JumpToCrateByTabId(data.Tab1)
              return
            end
          end
          ShowNotice(7747)
        end
      end)
    end
  elseif scene == CouponSystem._Enum_Scene._SupplyBox2 then
    local JiPinMaxId = 0
    local JiPinLowestID = 0
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() then
      if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
        JiPinMaxId = 203999
        JiPinLowestID = 203001
      else
        JiPinMaxId = 207999
        JiPinLowestID = 207001
      end
    else
      JiPinMaxId = 101999
      JiPinLowestID = 101000
    end
    local dataMap = JumpUtils.TryGetJumpItemMap(JumpUtils.MODEL_ID_SUPPLY)
    if dataMap ~= nil then
      for _, data in pairs(dataMap) do
        if JiPinLowestID <= data.Tab1 and JiPinMaxId >= data.Tab1 then
          log(bWriteLog and "[chub]CouponSystem.JumpByScene, JumpToCrateByTabId, data.Tab1 = " .. data.Tab1)
          local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
          store_supply_manager:JumpToCrateByTabId(data.Tab1)
          return
        end
      end
      log(bWriteLog and "[chub]CouponSystem.JumpByScene, ShowNotice(7747)")
      ShowNotice(7747)
    else
      log(bWriteLog and "CouponSystem.JumpByScene RequestJumpMapInfo 2")
      JumpUtils.RequestJumpMapInfo(false, function()
        local DataMap = JumpUtils.TryGetJumpItemMap(JumpUtils.MODEL_ID_SUPPLY)
        if DataMap ~= nil then
          for _, data in pairs(DataMap) do
            if data.Tab1 >= JiPinLowestID and data.Tab1 <= JiPinMaxId then
              log(bWriteLog and "[chub]CouponSystem.JumpByScene, JumpToCrateByTabId, data.Tab1 = " .. data.Tab1)
              local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
              store_supply_manager:JumpToCrateByTabId(data.Tab1)
              return
            end
          end
          log(bWriteLog and "[chub]CouponSystem.JumpByScene, ShowNotice(7747)")
          ShowNotice(7747)
        end
      end)
      log(bWriteLog and "[chub]CouponSystem.JumpByScene, dataMap == nil")
    end
  elseif scene == CouponSystem._Enum_Scene._Draw then
    GlobalData.JumpUrl(iteminfo.jumpExchangeUrl)
  elseif scene == CouponSystem._Enum_Scene._LuckySpin then
    if iteminfo.jumpExchangeUrl and iteminfo.jumpExchangeUrl ~= "" then
      GlobalData.JumpUrl(iteminfo.jumpExchangeUrl)
    else
      local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
      local back_act_list = ActivityNewSystem.GetActivityListByType(ActivityType.LUCKYBACK)
      if back_act_list and next(back_act_list) then
        local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
        local data_list = {}
        for _, v in pairs(back_act_list) do
          local bShowCoupon, _ = CouponSystem.IsShowCouponAndShowCouponList(CouponSystem._Enum_Scene._LuckySpin, v.ID)
          if bShowCoupon then
            table.insert(data_list, v)
          end
        end
        if not next(data_list) then
          log(bWriteLog and "[SY]CouponSystem.JumpByScene.back_act_list is nil")
          return
        end
        table.sort(data_list, function(a, b)
          return a.ID > b.ID
        end)
        local store_jump_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_jump_manager)
        local params = {
          activityid = data_list[1].ID
        }
        if CouponSystem.IsSupplyLuckySpinDownload(data_list[1].ID) then
          return
        end
        store_jump_manager:JumpSupplyBanner(params)
      else
        GlobalData.JumpUrl("")
      end
    end
  elseif scene == CouponSystem._Enum_Scene._UnknowPass then
    local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    WardrobeLogic.lastSubTabString = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_voucher
    log(bWriteLog and "==============iteminfoiteminfo" .. iteminfo.jumpExchangeUrl)
    GlobalData.JumpUrl(iteminfo.jumpExchangeUrl)
  elseif scene == CouponSystem._Enum_Scene._LuckyDouble then
    log(bWriteLog and "[cw] scene == CouponSystem._Enum_Scene._LuckyDouble ")
    GlobalData.JumpUrl(iteminfo.jumpExchangeUrl)
  elseif iteminfo.jumpExchangeUrl and iteminfo.jumpExchangeUrl ~= "" then
    GlobalData.JumpUrl(iteminfo.jumpExchangeUrl)
  end
end
function CouponSystem.IsSupplyLuckySpinDownload(activityID)
  local collectResourceList = LobbySystem.GetActivityDownLoadListByModuleID(BP_ENUM_MODULE_LUCKY_BACK, activityID) or {}
  if not GlobalData.ActResourceDownloaded(collectResourceList, BP_ENUM_MODULE_LUCKY_BACK, activityID) then
    log(bWriteLog and string.format("EventJumpUrl not download"))
    return true
  end
  return false
end
function CouponSystem.GetDepotCoupons()
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local list = {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(WardrobeData:GetArrayHallDepotItemInfo()) do
    if WardrobeLogic:IsValidCurrentPageItem(WardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Tool, WardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_voucher, v, serverTime) then
      table.insert(list, v)
    end
  end
  return list
end
function CouponSystem.GetDepotCoupinsListTable()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local Page = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Tool
  local Sub = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_voucher
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local depotItemList = WardrobeDataManager:GetArrayHallDepotItemInfo()
  local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
  local itemListTable = {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(depotItemList) do
    if WardrobeLogicManager:IsValidCurrentPageItem(Page, Sub, v, serverTime) then
      local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
      local is_using = DataMgr.ratingShieldCardID == v.insID or DataMgr.seasonRatingShieldCardID == v.insID or logic_wardrobe_card:IsCardPutOn(v.insID)
      is_using = is_using or LogicAddScordCard:IsPutOnAddScoreCardByInsId(v.insID)
      local itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #itemListTable, is_using, true, false, false, false)
      table.insert(itemListTable, itemInfo)
    end
  end
  return itemListTable
end
function CouponSystem.IsSupplyActCouponScene(scene)
  return scene == CouponSystem._Enum_Scene._SupplyBoxAct
end
function CouponSystem.SortCouponListByComboBox(a, b)
  if a.value == b.value then
    if getSceneNum(a) == getSceneNum(b) then
      return a.expireTS < b.expireTS
    else
      return getSceneNum(a) < getSceneNum(b)
    end
  else
    return a.value > b.value
  end
end
function CouponSystem.GetCouponSceneByShopID(shopID)
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  if StoreUtils.IsPremiumCrate(shopID) then
    return CouponSystem._Enum_Scene._SupplyBox2
  elseif StoreUtils.IsClassicCrate(shopID) then
    return CouponSystem._Enum_Scene._SupplyBox1
  elseif StoreUtils.IsActShopId(shopID) then
    return CouponSystem._Enum_Scene._SupplyBoxAct
  else
    return CouponSystem._Enum_Scene._SupplyBox2
  end
end
function CouponSystem.GetSelectSortStyle()
  local select = C_SORT_PRICE
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eArrangementOfDiscountCoupons)
  if cache_info then
    select = cache_info.sortStlye or C_SORT_PRICE
  end
  return select
end
function CouponSystem.SaveSelectSortStyle(style)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  style = tonumber(style) or C_SORT_PRICE
  local cache_info = {sortStlye = style}
  PlayerPrefsSystem.SaveTableToFile_N(cache_info, PlayerPrefsSystem.ePlayerPrefsType.eArrangementOfDiscountCoupons)
end
local sortFormat_Price = function(a_one, b_one, a_two, b_two, a_three, b_three)
  if a_one == b_one then
    if a_two == b_two then
      return a_three < b_three
    else
      return a_two < b_two
    end
  else
    return b_one < a_one
  end
end
local sortFormat_Expire = function(a_one, b_one, a_two, b_two, a_three, b_three)
  if a_one == b_one then
    if a_two == b_two then
      return a_three < b_three
    else
      return b_two < a_two
    end
  else
    return a_one < b_one
  end
end
function CouponSystem.SortCouponListByComBox(list, style)
  local sort = function(a, b)
    local a_value = a.value or 0
    local b_value = b.value or 0
    local a_expire = a.expireTS or 0
    local b_expire = b.expireTS or 0
    local a_scenes = getSceneNum(a)
    local b_scenes = getSceneNum(b)
    if style == C_SORT_PRICE then
      return sortFormat_Price(a_value, b_value, a_expire, b_expire, a_scenes, b_scenes)
    else
      return sortFormat_Expire(a_expire, b_expire, a_value, b_value, a_scenes, b_scenes)
    end
  end
  table.sort(list, sort)
end
function CouponSystem.SortCouponList(list, style)
  local sort = function(a, b)
    local a_value = a.couponInfo.value or 0
    local b_value = b.couponInfo.value or 0
    local a_expire = a.depotData.expireTS or 0
    local b_expire = b.depotData.expireTS or 0
    local a_scenes = getSceneNum(a.couponInfo)
    local b_scenes = getSceneNum(b.couponInfo)
    if style == C_SORT_PRICE then
      return sortFormat_Price(a_value, b_value, a_expire, b_expire, a_scenes, b_scenes)
    else
      return sortFormat_Expire(a_expire, b_expire, a_value, b_value, a_scenes, b_scenes)
    end
  end
  table.sort(list, sort)
end
function CouponSystem.IsShowCouponRadDotAni(list, scene)
  local hasRed, playAni = false, false
  if list == nil or type(list) ~= "table" then
    return hasRed, playAni
  end
  local newList = {}
  local expireList = {}
  for i, v in ipairs(list) do
    if getSceneNum(v) <= 1 then
      table.insert(newList, v)
      if CouponSystem.CheckCouponExpireSoon(v.expireTS) then
        table.insert(expireList, v)
      end
    end
  end
  if 0 < #newList and not CouponSystem.AlreadyClickedRedDot(scene, newList, false) then
    hasRed = true
  end
  if 0 < #expireList and not CouponSystem.AlreadyClickedRedDot(scene, expireList, true) then
    hasRed = true
    playAni = true
  end
  return hasRed, playAni
end
function CouponSystem.CheckCouponExpireSoon(expireTS)
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local t = tonumber(expireTS) or 0
  local spacing = tonumber(t - now) or 0
  if 0 < spacing and spacing < C_EXPIRE_SOON then
    return true
  end
  return false
end
function CouponSystem.AlreadyClickedRedDot(scene, list, checkTime)
  local TimeUtil = require("client.common.time_util")
  local result = false
  if not scene then
    return result
  end
  list = list or {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localCacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRedDotOfDiscountCoupons)
  if localCacheInfo and localCacheInfo[scene] then
    local info = localCacheInfo[scene].info or {}
    local same = CouponSystem.CheckExist(list, info)
    if same then
      if checkTime then
        local now = TimeUtil.GetServerTimeInSec()
        local time = localCacheInfo[scene].alreadyClickTime or 0
        result = TimeUtil.IsSameDay(time, now)
      else
        result = true
      end
    end
  end
  return result
end
function CouponSystem.CheckExist(list, info)
  local same = true
  for _, v in ipairs(list) do
    local has = false
    for _, vv in ipairs(info) do
      if v.insID == vv.ins_id and v.count <= vv.count then
        has = true
        break
      end
    end
    if not has then
      same = false
      break
    end
  end
  return same
end
function CouponSystem.SaveClickedRedDot(scene, couponList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localCacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRedDotOfDiscountCoupons)
  localCacheInfo = localCacheInfo or {}
  local info = {}
  for i, v in ipairs(couponList) do
    if v.couponInfo and v.depotData.ins_id then
      local temp = {
        ins_id = v.depotData.ins_id,
        count = v.depotData.count
      }
      table.insert(info, temp)
    end
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  localCacheInfo[scene] = {alreadyClickTime = now, info = info}
  PlayerPrefsSystem.SaveTableToFile_N(localCacheInfo, PlayerPrefsSystem.ePlayerPrefsType.eRedDotOfDiscountCoupons)
end
function CouponSystem.CacheCurrentSelectCoupon(id, scene)
  currentSelectCouponId = id
  currentSelectScene = scene
end
function CouponSystem.GetCurrentSelectCoupon()
  return currentSelectCouponId, currentSelectScene
end
return CouponSystem