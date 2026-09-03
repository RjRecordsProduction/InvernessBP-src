local LogicPHomeStore = {}
local PHomeStoreConst = require("client.slua.logic.homestore.PHomeStoreConst")
local version_util = require("client.common.version_util")
local PHomeStoreUtils = require("GameLua.Mod.SocialIsland.Client.UI.PHome.PHomeStoreUtils")
local TimeUtil = require("client.common.time_util")
local transfer = function(src, dst)
  dst.Name = src.Name
  dst.IconPath = src.IconPath
  dst.Quality = src.Quality
  dst.Prosperity = src.Prosperity
  dst.Style = src.Style
  dst.StyleValue = src.StyleValue
  dst.BPPath = src.BPPath
  dst.MatPath = src.MatPath
  dst.AttachType = src.AttachType
  dst.RepActor = src.RepActor
  dst.SubType = src.SubType
  dst.StoreZOffset = src.StoreZOffset
  dst.StoreScale = src.StoreScale
end
local DepotDataState = {
  None = 1,
  Requesting = 2,
  Requested = 3
}
function LogicPHomeStore:DefineAndResetData()
  print(bWriteLog and " LogicPHomeStore:DefineAndResetData")
  self.storeMap = {}
  self.itemBasicMap = {}
  self.storeCfgMap = {}
  self._tabData = nil
  self.manorItems = nil
  self.depotItems = {}
  self.pile_items = {}
  self.depotCoins = {}
  self.expire_list = {}
  self.buy_history = nil
  self.partnerDepotItems = {}
  self.partnerDepotCoins = {}
  self.partner_expire_list = {}
  self.partner_pile_items = {}
  self.cachedDrawActivityCfg = nil
  self.validDrawActivityCfgArray = {}
  self.daily_draw_cnt = nil
  self.extra_draw_cnt = nil
  self.CachedIgnoreSpinAnimation = nil
  self.depotDataState = DepotDataState.None
  self.callbackList = {}
  self.cachedChestCfg = nil
  self.daily_chest_cnt = 0
  self.box_energy = 0
  self.guraanteAwardProgress = {}
  self.exchange_coin = 0
  self.DrawGuaranteeAwardInfo = {}
  self.homeStoreCfgMap = self:initHomeStoreCfgMap()
  self._homeStoreMerged = nil
end
function LogicPHomeStore:RegistEvents()
  log(bWriteLog and "LogicPHomeStore:RegistEvents")
  if BP_ENUM_MODULE_PLANPH_HOME_STORE then
    self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PLANPH_HOME_STORE, self.OnUrlEvent, self)
    self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_JUMP_HOME_STORE_SPIN_2D, self.OnUrlEventSpin2D, self)
  end
  if EVENTTYPE_NEXTDAY then
    self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayHandler, self)
  end
  if BP_ENUM_MODULE_JUMP_SOCIAL_ISLAND_STORE then
    self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_JUMP_SOCIAL_ISLAND_STORE, self.OnJumpSocialIslandStore, self)
  end
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, self.OnLoginSuccess, self)
end
function LogicPHomeStore:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and " LogicPHomeStore.OnPreSwitchGameStatus " .. nextState .. "  " .. preState)
end
function LogicPHomeStore:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and " LogicPHomeStore.OnPostSwitchGameStatus " .. nextState .. "  " .. preState)
  if nextState == GameStatus.Lobby then
    self.cachedDrawActivityCfg = nil
  end
end
function LogicPHomeStore:OnPostEnterBattle()
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsLocalBoot() then
    local Promise = require("common.Promise")
    local lobbySvrConnectPromise = Promise.Helper.MakeEventPromise(EVENTTYPE_SOCIAL_ISLAND, EVENTID_ISLAND_EDITOR_ON_LOBBY_CONNECT)
    lobbySvrConnectPromise:Then(function()
      self:AddGameTimer(2, false, function()
        self:ReqDepotIfEmpty()
      end)
    end)
  else
    self:ReqDepotIfEmpty()
  end
end
function LogicPHomeStore:lazyConstructTabs()
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local _tabData = {}
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_shop_page_table)
  if not cfgs and IsEditor then
    assert(false, "server data table not found")
  end
  local firstTab = {}
  local count = 0
  for k, v in pairs(cfgs) do
    count = count + 1
    local versionMatch = 0 <= version_util.CompareVersionStandard(clientVersion, v.min_ver)
    if v.max_ver and v.max_ver ~= "" then
      versionMatch = versionMatch and 0 >= version_util.CompareVersionStandard(clientVersion, v.max_ver)
    end
    if versionMatch and firstTab[v.label_A_ID] == nil then
      firstTab[v.label_A_ID] = true
      table.insert(_tabData, {
        text = LocUtil.GetLocalizeResStr(v.label_A_name),
        FirstTab = v.label_A_ID,
        sort = v.label_sequence or 0,
        tabCfg = v
      })
    end
  end
  printf("LogicPHomeStore:lazyConstructTabs cfgs count:%s", count)
  local cfg = self:GetAvailableChestCfg(true)
  local bRemoveChestTab = cfg == nil
  for index, value in ipairs(_tabData) do
    if bRemoveChestTab and value.FirstTab == PHomeStoreConst.TabType.Chest then
      printf("LogicPHomeStore:lazyConstructTabs remove chest tab by no chest cfg")
      table.remove(_tabData, index)
      count = count - 1
    end
    if value.FirstTab == PHomeStoreConst.TabType.Mould then
      table.remove(_tabData, index)
      count = count - 1
    end
  end
  printf("LogicPHomeStore:lazyConstructTabs _tabData after remove count:%s", count)
  table.sort(_tabData, function(a, b)
    return a.sort < b.sort
  end)
  for k, v in pairs(_tabData) do
    local secondTabs = {}
    for kk, vv in pairs(cfgs) do
      if vv.label_B_ID ~= 0 and vv.label_A_ID == v.FirstTab then
        if vv.label_B_ID == PHomeStoreConst.SubTabType.Discount then
          local logic_home_anniversary_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_anniversary_activity)
          if not logic_home_anniversary_activity:IsActivityOpen() then
            goto lbl_230
          end
        end
        local versionMatch = 0 <= version_util.CompareVersionStandard(clientVersion, vv.min_ver)
        if vv.max_ver and vv.max_ver ~= "" then
          versionMatch = versionMatch and 0 >= version_util.CompareVersionStandard(clientVersion, vv.max_ver)
        end
        if versionMatch then
          local storeObj = self:GetStoreObj(vv.label_A_ID, vv.label_B_ID)
          local items = storeObj.items
          if items and 0 < #items then
            table.insert(secondTabs, {
              tabCfg = vv,
              SecondTab = vv.label_B_ID,
              bMatchSize = true,
              activePath = vv.active_icon,
              inactivePath = vv.inactive_icon
            })
          else
            printf("LogicPHomeStore:lazyConstructTabs %s %s %s", v.FirstTab, vv.label_B_ID, " no items")
          end
        end
      end
      ::lbl_230::
    end
    table.sort(secondTabs, function(a, b)
      return a.SecondTab < b.SecondTab
    end)
    local discountTabIndex
    for index, tab in ipairs(secondTabs) do
      if tab.SecondTab == PHomeStoreConst.SubTabType.Discount then
        discountTabIndex = index
        break
      end
    end
    if discountTabIndex then
      local discountTab = table.remove(secondTabs, discountTabIndex)
      table.insert(secondTabs, 2, discountTab)
    end
    v.subTabs = secondTabs
  end
  self.  return self._tabData
end
function LogicPHomeStore:ClearStoreObj(FirstTab, SecondTab)
  local storeMap = self.storeMap
  local storeObj = storeMap[FirstTab]
  if storeObj then
    storeObj[SecondTab] = nil
  end
end
function LogicPHomeStore:GetStoreObj(FirstTab, SecondTab)
  local storeMap = self.storeMap
  local storeObj = storeMap[FirstTab]
  if IsEditor then
    storeObj = nil
  end
  if FirstTab == PHomeStoreConst.TabType.Prop or FirstTab == PHomeStoreConst.TabType.Chest then
    if not storeObj then
      storeObj = {
        FirstTab = FirstTab,
        SecondTab = SecondTab,
        items = {}
      }
      storeMap[FirstTab] = storeObj
      self:fillStoreObj(storeObj)
    end
    return storeObj
  else
    if not storeObj then
      storeMap[FirstTab] = {}
    end
    if SecondTab == nil then
      storeObj = {
        FirstTab = FirstTab,
        SecondTab = SecondTab,
        items = {}
      }
      assert_format(false, "LogicPHomeStore:GetStoreObj SecondTab is nil. FirstTab\239\188\154%s", FirstTab)
      self:fillStoreObj(storeObj)
      return storeObj
    end
    storeObj = storeMap[FirstTab][SecondTab]
    local bIsDiscountTab = SecondTab == PHomeStoreConst.SubTabType.Discount
    if not storeObj or bIsDiscountTab then
      storeObj = {
        FirstTab = FirstTab,
        SecondTab = SecondTab,
        items = {}
      }
      storeMap[FirstTab][SecondTab] = storeObj
      self:fillStoreObj(storeObj)
    end
    return storeObj
  end
end
function LogicPHomeStore:fillStoreObj(storeObj)
  local FirstTab = storeObj.FirstTab
  local SecondTab = storeObj.SecondTab
  local items = storeObj.items
  local itop_app_id = tostring(Client.GetITopGameId())
  log(bWriteLog and string.format("LogicPHomeStore:fillStoreObj FirstTab:%s, SecondTab:%s", FirstTab, SecondTab))
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local StringUtil = require("common.string_util")
  local clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable
  clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  now = TimeUtil.GetServerTimeInSec()
  FnCmpVersion = version_util.CompareVersionStandard
  FnCmpTime = TimeUtil.TimeStringToUnixstamp_LoopOptimize
  timeZone = TimeUtil.GetTimeZone(nil, true)
  refTimeTable = {}
  if FirstTab == PHomeStoreConst.TabType.Recommend and SecondTab == PHomeStoreConst.SubTabType.Discount then
    local logic_home_anniversary_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_anniversary_activity)
    local discountShopList = logic_home_anniversary_activity:GetDiscountShopList()
    local group_list = {}
    for id, info in pairs(discountShopList) do
      group_list[info.good_id] = 1
    end
    table.insert(items, {group_list = group_list})
  elseif FirstTab == PHomeStoreConst.TabType.Recommend then
    local recommendCfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_recomment_shop_table) or {}
    for id, recommendCfg in pairs(recommendCfgs) do
      if SecondTab == id then
        if false == PHomeStoreUtils.CheckVersionPassed_LoopOptimize(recommendCfg.open_ver, recommendCfg.close_ver, recommendCfg.sale_begin_time, recommendCfg.sale_end_time, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
          log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj recommendCfg not CheckVersionPassed id:%s", id))
        else
          local str = recommendCfg.set_items_list
          local setItems = StringUtil.Split(str, "|")
          local group_list = {}
          for _, setItem in ipairs(setItems) do
            if setItem ~= "" then
              local storeId = tonumber(setItem)
              local storeCfg = self:GetHomeStoreCfg(storeId)
              if storeCfg then
                if false == PHomeStoreUtils.CheckVersionPassed_LoopOptimize(storeCfg.open_ver, storeCfg.close_ver, storeCfg.sale_begin_time, storeCfg.sale_end_time, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
                  log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckVersionPassed failed. storeId:%s", storeId))
                elseif false == PHomeStoreUtils.CheckAppIdList(storeCfg.app_list, itop_app_id) then
                  log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckAppIdList failed. storeId:%s", storeId))
                else
                  group_list[storeId] = 1
                end
              end
            end
          end
          table.insert(items, {
            show_priority = recommendCfg.show_priority,
            textId = recommendCfg.recomment_items_name,
            style = recommendCfg.recomment_items_style,
            b_url = recommendCfg.banner_bg,
            group_list = group_list,
                      })
        end
      end
    end
    table.sort(items, function(a, b)
      return a.show_priority < b.show_priority
    end)
  elseif FirstTab == PHomeStoreConst.TabType.Set then
    if SecondTab == PHomeStoreConst.SubTabType.Mould then
      local shopCfgs = self.homeStoreCfgMap
      for storeId, storeCfg in pairs(shopCfgs) do
        if storeCfg.label_A_ID == PHomeStoreConst.TabType.Mould then
          if false == PHomeStoreUtils.CheckVersionPassed_LoopOptimize(storeCfg.open_ver, storeCfg.close_ver, storeCfg.sale_begin_time, storeCfg.sale_end_time, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
            log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckVersionPassed failed. storeId:%s", storeId))
          elseif false == PHomeStoreUtils.CheckAppIdList(storeCfg.app_list, itop_app_id) then
            log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckAppIdList failed. storeId:%s", storeId))
          else
            table.insert(items, storeId)
          end
        end
      end
    else
      local setCfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_set_shop_table) or {}
      for storeId, setCfg in pairs(setCfgs) do
        if SecondTab == setCfg.label_ID then
          local storeCfg = self:GetHomeStoreCfg(storeId)
          if nil == storeCfg then
            LogExceptionAndReport(string.format("LogicPHomeStore.fillStoreObj storeCfg is nil. storeId:%s", storeId), 6)
          elseif false == PHomeStoreUtils.CheckVersionPassed_LoopOptimize(storeCfg.open_ver, storeCfg.close_ver, storeCfg.sale_begin_time, storeCfg.sale_end_time, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
            log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckVersionPassed failed. storeId:%s", storeId))
          elseif false == PHomeStoreUtils.CheckAppIdList(storeCfg.app_list, itop_app_id) then
            log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckAppIdList failed. storeId:%s", storeId))
          else
            local set_items_num = setCfg.set_items_num
            local set_items_num = StringUtil.Split(set_items_num, "|")
            local set_items_list = setCfg.set_items_list
            local set_items_list = StringUtil.Split(set_items_list, "|")
            local child_items = {}
            for i, setItem in ipairs(set_items_list) do
              if setItem ~= "" and set_items_num[i] ~= "" then
                child_items[#child_items + 1] = {
                  phomeStoreId = tonumber(setItem),
                  count = tonumber(set_items_num[i])
                }
              end
            end
            table.insert(items, {
              storeId = storeId,
              child_items = child_items,
              b_url = setCfg.banner_bg,
              icon = setCfg.set_items_icon,
              quality = setCfg.set_items_quality,
                          })
            table.sort(items, function(a, b)
              return a.storeId < b.storeId
            end)
          end
        end
      end
    end
  elseif FirstTab == PHomeStoreConst.TabType.Prop or FirstTab == PHomeStoreConst.TabType.Mould then
    local shopCfgs = self.homeStoreCfgMap
    for storeId, storeCfg in pairs(shopCfgs) do
      if storeCfg.label_A_ID == FirstTab then
        if false == PHomeStoreUtils.CheckVersionPassed_LoopOptimize(storeCfg.open_ver, storeCfg.close_ver, storeCfg.sale_begin_time, storeCfg.sale_end_time, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
          log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckVersionPassed failed. storeId:%s", storeId))
        elseif false == PHomeStoreUtils.CheckAppIdList(storeCfg.app_list, itop_app_id) then
          log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckAppIdList failed. storeId:%s", storeId))
        else
          table.insert(items, storeId)
        end
      end
    end
  elseif FirstTab == PHomeStoreConst.TabType.Chest then
    local chestCfg = self:GetAvailableChestCfg()
    if chestCfg then
      local chestId = chestCfg.activity_id
      local chestWeightCfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_chest_weight_table)
      if chestWeightCfgs then
        local arr = chestWeightCfgs[chestId]
        for i, chestWeightCfg in pairs(arr) do
          table.insert(items, {
            award_item_id = chestWeightCfg.award_item_id,
            award_item_num = chestWeightCfg.award_item_num
          })
        end
      else
        table.insert(items, {award_item_id = 66630418, award_item_num = 1})
        table.insert(items, {award_item_id = 66631109, award_item_num = 1})
        table.insert(items, {award_item_id = 66611004, award_item_num = 1})
        table.insert(items, {award_item_id = 66611005, award_item_num = 1})
        table.insert(items, {award_item_id = 66611006, award_item_num = 1})
        table.insert(items, {award_item_id = 66620108, award_item_num = 2})
        table.insert(items, {award_item_id = 66620109, award_item_num = 2})
        table.insert(items, {award_item_id = 66620210, award_item_num = 2})
        table.insert(items, {award_item_id = 66620211, award_item_num = 2})
        table.insert(items, {award_item_id = 66620309, award_item_num = 2})
        table.insert(items, {award_item_id = 80060002, award_item_num = 1})
        table.insert(items, {award_item_id = 1208, award_item_num = 500})
      end
    end
  else
    local shopCfgs = self.homeStoreCfgMap
    for storeId, storeCfg in pairs(shopCfgs) do
      if storeCfg.label_A_ID == FirstTab and SecondTab == storeCfg.label_B_ID then
        if false == PHomeStoreUtils.CheckVersionPassed_LoopOptimize(storeCfg.open_ver, storeCfg.close_ver, storeCfg.sale_begin_time, storeCfg.sale_end_time, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
          log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckVersionPassed failed. storeId:%s", storeId))
        elseif false == PHomeStoreUtils.CheckAppIdList(storeCfg.app_list, itop_app_id) then
          log(bWriteLog and string.format("LogicPHomeStore.fillStoreObj CheckAppIdList failed. storeId:%s", storeId))
        else
          table.insert(items, storeId)
        end
      end
    end
  end
end
function LogicPHomeStore:getPHomeItemCfg(phomeItemId)
  local itemBasic = self.itemBasicMap[phomeItemId]
  if not itemBasic then
    local cfg_PlanPH_StructureItemCfg = CDataTable.GetTableData("PlanPH_StructureItemCfg", phomeItemId)
    if cfg_PlanPH_StructureItemCfg then
      itemBasic = {}
      transfer(cfg_PlanPH_StructureItemCfg, itemBasic)
      self.itemBasicMap[phomeItemId] = itemBasic
      return itemBasic
    end
    local cfg_PlanPH_DecorateItemCfg = CDataTable.GetTableData("PlanPH_DecorateItemCfg", phomeItemId)
    if cfg_PlanPH_DecorateItemCfg then
      itemBasic = {}
      transfer(cfg_PlanPH_DecorateItemCfg, itemBasic)
      self.itemBasicMap[phomeItemId] = itemBasic
      return itemBasic
    end
    local cfg_PlanPH_WallpaperItemCfg = CDataTable.GetTableData("PlanPH_WallpaperItemCfg", phomeItemId)
    if cfg_PlanPH_WallpaperItemCfg then
      itemBasic = {}
      transfer(cfg_PlanPH_WallpaperItemCfg, itemBasic)
      self.itemBasicMap[phomeItemId] = itemBasic
      return itemBasic
    end
    local cfg_PlanPH_OtherItemCfg = CDataTable.GetTableData("PlanPH_OtherItemCfg", phomeItemId)
    if cfg_PlanPH_OtherItemCfg then
      itemBasic = {}
      transfer(cfg_PlanPH_OtherItemCfg, itemBasic)
      self.itemBasicMap[phomeItemId] = itemBasic
      return itemBasic
    end
    print(bWriteLog and string.format(" LogicPHomeStore:GetPHomeItemCfg phomeItemId:%s not found", phomeItemId))
  end
  return itemBasic
end
function LogicPHomeStore:GetHomeStoreCfg(phomeStoreId)
  phomeStoreId = tonumber(phomeStoreId)
  if phomeStoreId == nil then
    log_error_format("LogicPHomeStore:getPHomeStoreCfg phomeStoreId is nil")
    return nil
  end
  local cfg = self.homeStoreCfgMap[phomeStoreId]
  if cfg then
    return cfg
  end
  log_error(string.format("LogicPHomeStore:getPHomeStoreCfg(%s) is nil", phomeStoreId))
end
function LogicPHomeStore:GetHomeStoreCfgMap()
  return self.homeStoreCfgMap
end
function LogicPHomeStore:getPHomeStoreSetCfg(setId)
  setId = tonumber(setId)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfgList = BasicDataServerTable:GetCacheData(data_config_marco.manor_set_shop_table)
  if not cfgList then
    local data_config_marco = require("client.logic.data.data_config_marco")
    BasicDataServerTable:GetOrReqData(data_config_marco.manor_set_shop_table)
    return nil
  end
  local cfg = cfgList[setId]
  if cfg then
    return cfg
  end
  if IsEditor then
    assert(false, string.format("LogicPHomeStore:getPHomeStoreSetCfg setId:%s not found", setId))
  end
end
function LogicPHomeStore:ReqDrawCfgAndData(callback)
  local count = 2
  local stepCounter = function()
    count = count - 1
    if count == 0 and callback then
      printf("LogicPHomeStore.ReqDrawCfgAndData callback.")
      callback()
    end
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local tableList = {
    data_config_marco.manor_shop_page_table,
    data_config_marco.manor_recomment_shop_table,
    data_config_marco.manor_set_shop_table,
    data_config_marco.manor_draw_back_global_table,
    data_config_marco.manor_draw_back_weight_table,
    data_config_marco.manor_draw_guarantee_award_table,
    data_config_marco.manor_draw_exchange_shop_table
  }
  local needReqList = {}
  for _, v in ipairs(tableList) do
    local data = BasicDataServerTable:GetCacheData(v)
    if not data then
      table.insert(needReqList, v)
    end
  end
  if next(needReqList) then
    BasicDataServerTable:BatchGetOrReqData(needReqList, function(info)
      stepCounter()
    end)
  else
    stepCounter()
  end
  if self.daily_draw_cnt == nil or self.daily_draw_cnt > 0 then
    local PHomeStoreHandler = require("client.network.Protocol.PHomeStoreHandler")
    PHomeStoreHandler.send_manor_draw_info_req():Then(function(ret_code, daily_draw_cnt)
      stepCounter()
    end)
  else
    stepCounter()
  end
end
function LogicPHomeStore:GetValidActivityCfgArray()
  return self.validDrawActivityCfgArray
end
function LogicPHomeStore:SetCurrentDrawActivityCfg(cfg)
  if self.cachedDrawActivityCfg and cfg.activity_id == self.cachedDrawActivityCfg.activity_id then
    return
  end
  self.cachedDrawActivityCfg = cfg
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_DRAW_ACTIVITY_CHANGE, cfg)
end
function LogicPHomeStore:IsRecommendStoreInValidActivity(manor_draw_id)
  for _, cfg in pairs(self.validDrawActivityCfgArray) do
    if cfg.activity_id == manor_draw_id then
      return true
    end
  end
  return false
end
function LogicPHomeStore:InitDrawActivityCfg()
  print(bWriteLog and "[DeanJYT] LogicPHomeStore:InitDrawActivityCfg")
  if self.cachedDrawActivityCfg then
    return
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_draw_back_global_table)
  if not cfgs then
    if IsEditor then
      assert(false, "server data table not found")
    end
    return
  end
  self.validDrawActivityCfgArray = {}
  local itop_app_id = tostring(Client.GetITopGameId())
  for k, cfg in pairs(cfgs) do
    if PHomeStoreUtils.CheckVersionPassed(cfg.open_version, cfg.close_version, cfg.begin_time, cfg.end_time) and PHomeStoreUtils.CheckAppIdList(cfg.appids, itop_app_id) then
      cfg.activity_id = k
      self.validDrawActivityCfgArray[#self.validDrawActivityCfgArray + 1] = cfg
      printf("LogicPHomeStore:InitDrawActivityCfg cfg.activity_id: %s", cfg.activity_id)
    end
  end
  if #self.validDrawActivityCfgArray > 1 then
    table.sort(self.validDrawActivityCfgArray, function(a, b)
      return a.activity_id > b.activity_id
    end)
  end
  self.cachedDrawActivityCfg = self.validDrawActivityCfgArray[1]
end
function LogicPHomeStore:GetCurrentDrawActivityCfg()
  if self.cachedDrawActivityCfg == nil then
    self:InitDrawActivityCfg()
  end
  return self.cachedDrawActivityCfg
end
function LogicPHomeStore:UpdateDrawActivityCfg()
  print(bWriteLog and " LogicPHomeStore:UpdateDrawActivityCfg")
  local actId = self.cachedDrawActivityCfg and self.cachedDrawActivityCfg.activity_id
  self.cachedDrawActivityCfg = nil
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local tableList = {
    data_config_marco.manor_draw_back_global_table,
    data_config_marco.manor_draw_back_weight_table
  }
  BasicDataServerTable:BatchGetOrReqData(tableList, function(info)
    self:InitDrawActivityCfg()
    local afterActivityCfg = self:GetCurrentDrawActivityCfg()
    if not afterActivityCfg then
      print(bWriteLog and " LogicPHomeStore:UpdateDrawActivityCfg afterActivityCfg is nil")
      return
    end
    print(bWriteLog and string.format(" LogicPHomeStore:UpdateDrawActivityCfg actId:%s afterActId:%s", actId, afterActivityCfg.activity_id))
    EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_DRAW_ACTIVITY_CHANGE, afterActivityCfg)
  end)
end
function LogicPHomeStore:InitGuraanteAwardProgress(ret_code, exchange_coin, guarantee_cnts_bin, take_record_bin)
  log(bWriteLog and "LogicPHomeStore:InitGuraanteAwardProgress ret_code:" .. tostring(ret_code))
  if ret_code ~= 0 then
    return
  end
  exchange_coin = tonumber(exchange_coin)
  if exchange_coin then
    self:SetExchangeCoin(exchange_coin)
  end
  local guraanteAward = slua.LuaArchiverDecode(LuaStateWrapper, guarantee_cnts_bin)
  local take_record = slua.LuaArchiverDecode(LuaStateWrapper, take_record_bin)
  log_tree("LogicPHomeStore:InitGuraanteAwardProgress guraanteAward", guraanteAward)
  log_tree("LogicPHomeStore:InitGuraanteAwardProgress take_record", take_record)
  if guraanteAward and next(guraanteAward) then
    self.guraanteAwardProgress = guraanteAward
  end
  if take_record and next(take_record) then
    self.DrawGuaranteeAwardInfo = take_record
  end
  log(bWriteLog and "LogicPHomeStore:InitGuraanteAwardProgress completed")
end
function LogicPHomeStore:SetGuraanteAwardProgress(err_code, activity_id, cnt)
  if err_code ~= 0 then
    return
  end
  activity_id = tonumber(activity_id)
  cnt = tonumber(cnt)
  log(bWriteLog and "LogicPHomeStore:SetGuraanteAwardProgress activity_id:" .. tostring(activity_id) .. " cnt:" .. tostring(cnt))
  if not activity_id or not cnt then
    return
  end
  if not self.guraanteAwardProgress then
    self.guraanteAwardProgress = {}
  end
  if not self.guraanteAwardProgress[activity_id] then
    self.guraanteAwardProgress[activity_id] = {}
  end
  self.guraanteAwardProgress[activity_id].guarantee_  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_DRAW_MANOR_DRAW_CHANGE)
end
function LogicPHomeStore:OnTakeDrawGuaranteeAward(activity_id, progress, award_items, take_record)
  activity_id = tonumber(activity_id)
  progress = tonumber(progress)
  log_format(bWriteLog and "LogicPHomeStore:OnTakeDrawGuaranteeAward activity_id: %s  progress: %s ", activity_id, progress)
  log_tree("LogicPHomeStore:OnTakeDrawGuaranteeAward award_items", award_items)
  log_tree("LogicPHomeStore:OnTakeDrawGuaranteeAward take_record", take_record)
  if not activity_id then
    return
  end
  if not self.guraanteAwardProgress then
    self.guraanteAwardProgress = {}
  end
  if not self.guraanteAwardProgress[activity_id] then
    self.guraanteAwardProgress[activity_id] = {}
  end
  self.guraanteAwardProgress[activity_id].  local allData = {}
  for k, v in pairs(award_items) do
    local data = {
      res_id = k,
      count = v,
      valid_hours = 0,
      expire_time = 0
    }
    table.insert(allData, data)
  end
  log_tree("LogicPHomeStore:OnTakeDrawGuaranteeAward allData", allData)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(allData)
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_DRAW_MANOR_DRAW_CHANGE)
end
function LogicPHomeStore:OnManorDrawExchage(exchange_id, exchange_items, exchange_record)
  log(bWriteLog and "LogicPHomeStore:OnManorDrawExchage exchange_id:" .. tostring(exchange_id))
  log_tree(" LogicPHomeStore:OnManorDrawExchage exchange_items", exchange_items)
  log_tree(" LogicPHomeStore:OnManorDrawExchage exchange_record", exchange_record)
  local allData = {}
  for k, v in pairs(exchange_items) do
    local data = {
      res_id = k,
      count = v,
      valid_hours = 0,
      expire_time = 0
    }
    table.insert(allData, data)
  end
  log_tree(" LogicPHomeStore:OnManorDrawExchage allData", allData)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(allData)
  if not self.DrawGuaranteeAwardInfo then
    self.DrawGuaranteeAwardInfo = {}
  end
  for key, value in pairs(exchange_record) do
    self.DrawGuaranteeAwardInfo[key] = value
  end
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_MANORDRAW_BUY_HISTORY_CHANGE)
end
function LogicPHomeStore:GetGuraanteAwardProgressByActivityId(activity_id)
  if self.guraanteAwardProgress then
    return self.guraanteAwardProgress[activity_id]
  end
end
function LogicPHomeStore:GetDrawGuaranteeAwardInfo()
  return self.DrawGuaranteeAwardInfo
end
function LogicPHomeStore:SetExchangeCoin(exchange_coin)
  self.  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_DRAW_MANOR_DRAW_CHANGE)
end
function LogicPHomeStore:GetExchangeCoin()
  return self.exchange_coin
end
function LogicPHomeStore:ShowErrNotice(err_code)
  log(bWriteLog and "LogicPHomeStore:ShowErrNotice" .. tostring(err_code))
  if not err_code or err_code == 0 then
    return
  end
  ShowNotice(err_code)
end
function LogicPHomeStore:OnUrlEvent(_, _, vars)
  local StoreId, Tab1, Tab2
  local From = PHomeStoreConst.EOpenSceneFrom.Lobby
  if vars ~= nil then
    StoreId = tonumber(vars.StoreId)
    Tab1 = tonumber(vars.Tab1)
    Tab2 = tonumber(vars.Tab2)
    From = tonumber(vars.From) or From
  end
  local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
  PHomeStoreProxy:ShowPHomeMain(From, Tab1, Tab2, StoreId)
end
function LogicPHomeStore:OnUrlEventSpin2D(_, _, vars)
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  if not LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_Home) then
    printf("LogicPHomeStore:OnUrlEventSpin2D not downloaded")
    ShowNotice(LocUtil.GetLocalizeResStr(7421))
    LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.EName_Home, function()
      printf("LogicPHomeStore:OnUrlEventSpin2D downloaded")
    end)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.PlanPH_Store_LuckySpin2D_UIBP)
end
function LogicPHomeStore:OnNextDayHandler()
  log(bWriteLog and " LogicPHomeStore:OnNextDayHandler")
  local PHomeStoreHandler = require("client.network.Protocol.PHomeStoreHandler")
  PHomeStoreHandler.send_manor_draw_info_req():Then(function(ret_code, daily_draw_cnt)
    self:UpdateDrawActivityCfg()
  end)
  self.storeMap = {}
end
function LogicPHomeStore:OnLoginSuccess()
  log(bWriteLog and " LogicPHomeStore:OnLoginSuccess")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.manor_shop_table, function(table_name, table_data)
    printf("LogicPHomeStore:OnLoginSuccess manor_shop_table done 222")
    self:mergeHomeStoreCfg(table_data)
  end)
end
function LogicPHomeStore:initHomeStoreCfgMap()
  local t1 = slua.getMicroseconds()
  local tb = {}
  local cfgList = CDataTable.GetTable("PlanPH_StoreCfg")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  for shopId, cfg in pairs(cfgList) do
    local bShowNew = PHomeStoreUtils.CheckIsCurrentVersion(cfg.open_ver, clientVersion)
    tb[shopId] = {
      PH_shop_id = cfg.PH_shop_id,
      PH_item_id = cfg.PH_item_id,
      app_list = cfg.app_list,
      open_ver = cfg.open_ver,
      close_ver = cfg.close_ver,
      items_name = cfg.items_name,
      label_A_ID = cfg.label_A_ID,
      label_B_ID = cfg.label_B_ID,
      item_count = cfg.item_count,
      money1_type = cfg.money1_type,
      money1_price = cfg.money1_price,
      money2_type = cfg.money2_type,
      money2_price = cfg.money2_price,
      off_rate = cfg.off_rate,
      item_title = cfg.item_title,
      shop_rank = cfg.shop_rank,
      sale_begin_time = cfg.sale_begin_time,
      sale_end_time = cfg.sale_end_time,
      daily_buy_limit = cfg.daily_buy_limit,
      week_buy_limit = cfg.week_buy_limit,
      permanet_buy_limit = cfg.permanet_buy_limit,
      item_des = cfg.item_des,
      default_music = cfg.default_music,
      is_new = cfg.is_new,
      manor_draw_id = cfg.manor_draw_id,
      is_pdp = cfg.is_pdp,
      off_rate_hours = cfg.off_rate_hours,
      isCurrentVersion = bShowNew
    }
  end
  local t2 = slua.getMicroseconds()
  local diff = t2 - t1
  log(bWriteLog and "LogicPHomeStore:initHomeStoreCfgMap", diff)
  return tb
end
function LogicPHomeStore:mergeHomeStoreCfg(serverCfg)
  if self._homeStoreMerged then
    log(bWriteLog and "LogicPHomeStore:mergeHomeStoreCfg already merged")
    return
  end
  for shopId, cfg in pairs(serverCfg) do
    local clientCfg = self.homeStoreCfgMap[shopId]
    if clientCfg then
      clientCfg.money1_type = cfg.money1_type
      clientCfg.money1_price = cfg.money1_price
      clientCfg.money2_type = cfg.money2_type
      clientCfg.money2_price = cfg.money2_price
      clientCfg.sale_begin_time = cfg.sale_begin_time
      clientCfg.sale_end_time = cfg.sale_end_time
      clientCfg.off_rate_hours = cfg.off_rate_hours
    end
  end
  log(bWriteLog and "LogicPHomeStore:mergeHomeStoreCfg merged")
  self._homeStoreMerged = true
end
function LogicPHomeStore:GetIsDailyDiscount()
  printf("LogicPHomeStore.GetIsDailyDiscount self.daily_draw_cnt:%s self.extra_draw_cnt:%s", self.daily_draw_cnt, self.extra_draw_cnt)
  local dailyCnt = self.daily_draw_cnt or 0
  local extraCnt = self.extra_draw_cnt or 0
  return dailyCnt < extraCnt + 1
end
function LogicPHomeStore:OnJumpSocialIslandStore()
  log(bWriteLog and "LogicPHomeStore:OnJumpSocialIslandStore")
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  local home_macros = require("client.slua.logic.home.home_macros")
  local ret = SocialIslandHandler.ReqEnterSystemIsland(nil, home_macros.Enter_SocialIsland_Start.Store)
end
function LogicPHomeStore:ReqDepotIfEmpty(callback)
  local uid = DataMgr.roleData.uid
  if self.depotDataState == DepotDataState.Requested then
    if callback then
      callback()
    end
    return
  else
    if callback then
      table.insert(self.callbackList, callback)
    end
    if self.depotDataState == DepotDataState.Requesting then
      return
    end
  end
  self.depotDataState = DepotDataState.Requesting
  local PHomeDetailHandler = require("client.network.Protocol.PHomeDetailHandler")
  local PHomeStoreHandler = require("client.network.Protocol.PHomeStoreHandler")
  local now = os.clock()
  local count = 3
  local stepCounter = function()
    count = count - 1
    if count == 0 then
      printf("LogicPHomeStore.ReqDepotIfEmpty callback. total time:%s", os.clock() - now)
      self.depotDataState = DepotDataState.Requested
      local list = self.callbackList
      self.callbackList = {}
      for _, callback in pairs(list) do
        callback()
      end
    end
  end
  self:AddTimerOnce(2, function()
    self.depotDataState = DepotDataState.None
  end)
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if logic_home_joint:HasJointHome() then
    count = count + 2
    PHomeStoreHandler.send_get_manor_mate_depot_req():Then(function(err, depot)
      printf("LogicPHomeStore.ReqDepotIfEmpty send_get_manor_mate_depot_req err:%s", err)
      stepCounter()
    end)
    PHomeDetailHandler.send_manor_item_in_scene_req():Then(function(err, uid, use_items)
      print(bWriteLog and "LogicPHomeStore.ReqDepotIfEmpty send_manor_item_in_scene_req err:" .. err)
      stepCounter()
    end)
  end
  PHomeDetailHandler.send_manor_use_item_detail_req(uid):Then(function(err, uid, use_items)
    print(bWriteLog and "LogicPHomeStore.ReqDepotIfEmpty send_manor_use_item_detail_req 1 err:" .. err)
    stepCounter()
  end)
  PHomeStoreHandler.send_get_manor_depot_req():Then(function(err, depot)
    printf("LogicPHomeStore.ReqDepotIfEmpty send_get_manor_depot_req 2 err:%s", err)
    stepCounter()
  end)
  PHomeStoreHandler.send_manor_shop_buy_record_req():Then(function(err, buy_record)
    printf("LogicPHomeStore.ReqDepotIfEmpty send_manor_shop_buy_record_req 3 err:%s", err)
    stepCounter()
  end)
end
function LogicPHomeStore:InitDepot(depot)
  log(bWriteLog and "LogicPHomeStore:initDepot")
  if type(depot) == "string" then
    depot = slua.LuaArchiverDecode(LuaStateWrapper, depot)
  end
  log_tree("LogicPHomeStore:initDepot depot = ", depot)
  self.depotItems = depot.items
  self.depotCoins = depot.coins
  self.expire_list = depot.item_expires or {}
  self.pile_items = depot.pile_items or {}
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HOME_COIN_CHANGE)
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_HOMEDEPOT_CHANGE, self.depotItems)
end
function LogicPHomeStore:InitJointPartnerDepot(depot)
  log(bWriteLog and "LogicPHomeStore:InitJointPartnerDepot")
  if type(depot) == "string" then
    depot = slua.LuaArchiverDecode(LuaStateWrapper, depot)
  end
  log_tree("LogicPHomeStore:InitJointPartnerDepot depot = ", depot)
  self.partnerDepotItems = depot.items
  self.partnerDepotCoins = depot.coins
  self.partner_expire_list = depot.item_expires or {}
  self.partner_pile_items = depot.pile_items or {}
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HOME_COIN_CHANGE)
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_HOMEDEPOT_CHANGE, self.partnerDepotItems)
end
function LogicPHomeStore:InitBuyHistory(buy_record)
  log_tree("LogicPHomeStore:onManorShopBuyRecord buy_record = ", buy_record)
  self.buy_history = buy_record
end
function LogicPHomeStore:AppendBuyHistory(good_id, good_cnt, item_list)
  if not self.buy_history then
    self.buy_history = {}
  end
  self.buy_history[good_id] = (self.buy_history[good_id] or 0) + good_cnt
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_BUY_HISTORY_CHANGE, good_id, good_cnt, item_list)
end
function LogicPHomeStore:SetDraftUsedItemData(draftItems, draftPileItems, draftExpectPileItems)
  log_tree("[DeanJYT] LogicPHomeStore:SetDraftUsedItemData draftItems = ", draftItems)
  log_tree("[DeanJYT] LogicPHomeStore:SetDraftUsedItemData draftPileItems = ", draftPileItems)
  log_tree("[DeanJYT] LogicPHomeStore:SetDraftUsedItemData draftExpectPileItems = ", draftExpectPileItems)
  self.  self.  self.end
function LogicPHomeStore:GetDepotItemCountMap(bWithJoint)
  if self.depotItems == nil then
    print(bWriteLog and "[DeanJYT] LogicPHomeStore:GetDepotItemCountMap depotItems is nil")
    return {}
  end
  local itemCountMap = {}
  for itemId, count in pairs(self.depotItems) do
    if itemCountMap[itemId] == nil then
      itemCountMap[itemId] = count
    else
      itemCountMap[itemId] = itemCountMap[itemId] + count
    end
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if bWithJoint and logic_home_joint:HasJointHome() then
    if self.partnerDepotItems == nil then
      print(bWriteLog and "[DeanJYT] LogicPHomeStore:GetDepotItemCountMap partnerDepotItems is nil")
      return {}
    end
    for itemId, count in pairs(self.partnerDepotItems) do
      if itemCountMap[itemId] == nil then
        itemCountMap[itemId] = count
      else
        itemCountMap[itemId] = itemCountMap[itemId] + count
      end
    end
  end
  return itemCountMap
end
function LogicPHomeStore:GetDepotPileItemMap(bWithJoint)
  if self.pile_items == nil then
    return {}
  end
  local pileItemMap = {}
  for itemId, pileData in pairs(self.pile_items) do
    pileItemMap[itemId] = {}
    for pileNum, count in pairs(pileData) do
      pileItemMap[itemId][pileNum] = count
    end
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if bWithJoint and logic_home_joint:HasJointHome() then
    if self.partner_pile_items == nil then
      return {}
    end
    for itemId, pileData in pairs(self.partner_pile_items) do
      if not pileItemMap[itemId] then
        pileItemMap[itemId] = {}
      end
      for pileNum, count in pairs(pileData) do
        if 1 < pileNum then
          if not pileItemMap[itemId][pileNum] then
            pileItemMap[itemId][pileNum] = count
          else
            pileItemMap[itemId][pileNum] = pileItemMap[itemId][pileNum] + count
          end
        end
      end
    end
  end
  return pileItemMap
end
function LogicPHomeStore:GetDepotAndUsedItemCount(bWithJoint)
  log(bWriteLog and "[DeanJYT] LogicPHomeStore:GetDepotAndUsedItemCount bWithJoint = " .. tostring(bWithJoint))
  local itemCountMap = self:GetDepotItemCountMap(bWithJoint)
  local manorItems = self.manorItems
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if logic_home_joint:HasJointHome() then
    manorItems = self.manorSelfItems
    if bWithJoint then
      for itemId, count in pairs(self.manorMateItems or {}) do
        if itemCountMap[itemId] == nil then
          itemCountMap[itemId] = count
        else
          itemCountMap[itemId] = itemCountMap[itemId] + count
        end
      end
    end
  end
  if not manorItems then
    log(bWriteLog and "LogicPHomeStore:GetDepotAndUsedItemCount manorItems is nil")
    return nil
  end
  for itemId, count in pairs(manorItems) do
    if itemCountMap[itemId] == nil then
      itemCountMap[itemId] = count
    else
      itemCountMap[itemId] = itemCountMap[itemId] + count
    end
  end
  return itemCountMap
end
function LogicPHomeStore:GetDepotAndUsedPileItemMap(bWithJoint)
  log(bWriteLog and "[DeanJYT] LogicPHomeStore:GetDepotAndUsedPileItemMap bWithJoint = " .. tostring(bWithJoint))
  local pileItemMap = self:GetDepotPileItemMap(bWithJoint)
  local manorPileItems = self.manorPileItems
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if logic_home_joint:HasJointHome() then
    manorPileItems = self.manorSelfPileItems
    if bWithJoint then
      for itemId, pileData in pairs(self.manorMatePileItems or {}) do
        if not pileItemMap[itemId] then
          pileItemMap[itemId] = {}
        end
        for pileNum, count in pairs(pileData) do
          if 1 < pileNum then
            if not pileItemMap[itemId][pileNum] then
              pileItemMap[itemId][pileNum] = count
            else
              pileItemMap[itemId][pileNum] = pileItemMap[itemId][pileNum] + count
            end
          end
        end
      end
    end
  end
  if not manorPileItems then
    log(bWriteLog and "LogicPHomeStore:GetDepotAndUsedPileItemMap LogicPHomeStore.manorPileItems is nil")
    return nil
  end
  for itemId, pileData in pairs(manorPileItems) do
    if not pileItemMap[itemId] then
      pileItemMap[itemId] = {}
    end
    for pileNum, count in pairs(pileData) do
      if 1 < pileNum then
        if not pileItemMap[itemId][pileNum] then
          pileItemMap[itemId][pileNum] = count
        else
          pileItemMap[itemId][pileNum] = pileItemMap[itemId][pileNum] + count
        end
      end
    end
  end
  return pileItemMap
end
function LogicPHomeStore:GetItemExpireList()
  if not self.expire_list then
    return {}
  end
  return self.expire_list
end
function LogicPHomeStore:onNotifyManorCoinsChange(coins)
  for k, v in pairs(coins) do
    self.depotCoins[k] = v
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HOME_COIN_CHANGE)
end
function LogicPHomeStore:OnNotifyManorDepotItemChange(change_list, bAdd)
  for k, v in pairs(change_list) do
    self.depotItems[k] = v
  end
  self.  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_HOMEDEPOT_CHANGE, change_list, bAdd, true)
end
function LogicPHomeStore:OnNotifyMateManorDepotItemChange(change_list, bAdd, expire_list)
  for k, v in pairs(change_list) do
    self.partnerDepotItems[k] = v
  end
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_HOMEDEPOT_CHANGE, change_list, bAdd, true)
end
function LogicPHomeStore:SetManorUseItemDetails(use_items, pile_items)
  log(bWriteLog and "LogicPHomeStore:SetManorUseItemDetails.")
  log_tree("[DeanJYT] LogicPHomeStore:SetManorUseItemDetails use_items", use_items)
  log_tree("[DeanJYT] LogicPHomeStore:SetManorUseItemDetails pile_items", pile_items)
  self.manorItems = use_items or {}
  self.manorPileItems = pile_items or {}
end
function LogicPHomeStore:SetManorSelfUseItemDetails(use_items, pile_items)
  log(bWriteLog and "LogicPHomeStore:SetManorSelfUseItemDetails.")
  log_tree("[DeanJYT] LogicPHomeStore:SetManorSelfUseItemDetails use_items", use_items)
  log_tree("[DeanJYT] LogicPHomeStore:SetManorSelfUseItemDetails pile_items", pile_items)
  self.manorSelfItems = use_items or {}
  self.manorSelfPileItems = pile_items or {}
end
function LogicPHomeStore:SetManorMateUseItemDetails(use_items, pile_items)
  log(bWriteLog and "LogicPHomeStore:SetManorMateUseItemDetails.")
  log_tree("[DeanJYT] LogicPHomeStore:SetManorMateUseItemDetails use_items", use_items)
  log_tree("[DeanJYT] LogicPHomeStore:SetManorMateUseItemDetails pile_items", pile_items)
  self.manorMateItems = use_items or {}
  self.manorMatePileItems = pile_items or {}
end
function LogicPHomeStore:GetStoreItemLocalReadCache()
  if not self._tHomeStoreItemNew then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeStoreItemNew) or {}
    self._tHomeStoreItemNew = cfg
  end
  return self._tHomeStoreItemNew
end
function LogicPHomeStore:IsStoreItemLocalReaded(itemId)
  local cfg = self:GetStoreItemLocalReadCache()
  local result = cfg[tostring(itemId)] or false
  log(bWriteLog and string.format("LogicPHomeStore:IsStoreItemLocalReaded storeId = %s, result = %s", itemId, result))
  return result
end
function LogicPHomeStore:SetStoreItemLocalReaded(itemId, bNotifyEvent)
  if bNotifyEvent == nil then
    bNotifyEvent = true
  end
  log(bWriteLog and string.format("LogicPHomeStore:SetStoreItemLocalReaded storeId = %s, bNotifyEvent = %s", itemId, bNotifyEvent))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = self:GetStoreItemLocalReadCache()
  cfg[tostring(itemId)] = 1
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eHomeStoreItemNew)
  if bNotifyEvent then
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_STORE_ITEM_RED_CHANGE)
  end
end
function LogicPHomeStore:ClearStoreObjNewMark(storeTabObj)
  log(bWriteLog and string.format("LogicPHomeStore:ClearStoreObjNewMark FirstTab:%s, SecondTab:%s", storeTabObj.FirstTab, storeTabObj.SecondTab))
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local shopCfgs = self.homeStoreCfgMap
  local FirstTab = storeTabObj.FirstTab
  if FirstTab == PHomeStoreConst.TabType.Recommend then
    for _, v in pairs(storeTabObj.items) do
      for storeId, _ in pairs(v.group_list) do
        local storeCfg = shopCfgs[storeId]
        if storeCfg then
          self:SetStoreItemLocalReaded(storeCfg.PH_item_id, false)
        else
          log_error(string.format("LogicPHomeStore:ClearStoreObjNewMark storeCfg is nil. storeId:%s", storeId))
        end
      end
    end
  elseif FirstTab == PHomeStoreConst.TabType.Set then
    for i, storeId in ipairs(storeTabObj.items) do
      local storeCfg
      if storeTabObj.SecondTab == PHomeStoreConst.SubTabType.Mould then
        storeCfg = shopCfgs[storeId]
      else
        storeCfg = shopCfgs[storeId.storeId]
      end
      if storeCfg then
        self:SetStoreItemLocalReaded(storeCfg.PH_item_id, false)
      else
        log(bWriteLog and "LogicPHomeStore:ClearStoreObjNewMark storeCfg = nil")
      end
    end
  else
    for i, storeId in ipairs(storeTabObj.items) do
      local storeCfg = shopCfgs[storeId]
      self:SetStoreItemLocalReaded(storeCfg.PH_item_id, false)
    end
  end
end
function LogicPHomeStore:IsStoreHasNewMark(storeCfg, clientVersion, storeId)
  if not (storeCfg and storeCfg.is_new) or storeCfg.is_new ~= 1 then
    return false
  end
  if PHomeStoreUtils.CheckIsCurrentVersion(storeCfg.open_ver, clientVersion) then
    local bShowNew = not self:IsStoreItemLocalReaded(storeCfg.PH_item_id)
    if bShowNew then
      log(bWriteLog and string.format("LogicPHomeStore:IsStoreHasNewMark shopCfg is_new PH_item_id:%s storeId:%s firstTab:%s, secondTab:%s", storeCfg.PH_item_id, storeId, storeCfg.label_A_ID, storeCfg.label_B_ID))
      return true
    end
  end
  return false
end
function LogicPHomeStore:hasNew(storeId, storeCfg, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable)
  if not (storeCfg and storeCfg.is_new) or storeCfg.is_new ~= 1 then
    log(bWriteLog and string.format("LogicPHomeStore:hasNew storeCfg is nil or is_new is not 1. storeId:%s", storeId))
    return false
  end
  if not storeCfg.isCurrentVersion then
    log(bWriteLog and string.format("LogicPHomeStore:hasNew storeCfg is not current version. storeId:%s", storeId))
    return false
  end
  if self:IsStoreItemLocalReaded(storeCfg.PH_item_id) then
    log(bWriteLog and string.format("LogicPHomeStore:hasNew storeCfg is read. storeId:%s", storeId))
    return false
  else
    if false == PHomeStoreUtils.CheckVersionPassed_LoopOptimize(storeCfg.open_ver, storeCfg.close_ver, storeCfg.sale_begin_time, storeCfg.sale_end_time, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
      log(bWriteLog and string.format("LogicPHomeStore.hasNew CheckVersionPassed failed. storeId:%s", storeId))
      return false
    end
    return true
  end
end
function LogicPHomeStore:HasNewStoreItem(FirstTab, SecondTab)
  local shopCfgs = self.homeStoreCfgMap
  local clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable
  clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  now = TimeUtil.GetServerTimeInSec()
  timeZone = TimeUtil.GetTimeZone(nil, true)
  refTimeTable = {}
  local cmpVerCacheResult = {}
  function FnCmpVersion(constV, mutV)
    if cmpVerCacheResult[mutV] then
      return cmpVerCacheResult[mutV]
    end
    local result = version_util.CompareVersionStandard(constV, mutV)
    cmpVerCacheResult[mutV] = result
    return result
  end
  local cmpTimeCacheResult = {}
  function FnCmpTime(sTimeString, timeZone, refTimeTable)
    if cmpTimeCacheResult[sTimeString] then
      return cmpTimeCacheResult[sTimeString]
    end
    local result = TimeUtil.TimeStringToUnixstamp_LoopOptimize(sTimeString, timeZone, refTimeTable)
    cmpTimeCacheResult[sTimeString] = result
    return result
  end
  if FirstTab ~= nil then
    if FirstTab == PHomeStoreConst.TabType.Recommend then
      local storeObj = self:GetStoreObj(FirstTab, SecondTab)
      for _, v in ipairs(storeObj.items) do
        for storeId, _ in pairs(v.group_list) do
          local storeCfg = shopCfgs[storeId]
          if self:hasNew(storeId, storeCfg, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
            return true
          end
        end
      end
    elseif FirstTab == PHomeStoreConst.TabType.Set then
      return false
    else
      local storeObj = self:GetStoreObj(FirstTab, SecondTab)
      for _, storeId in ipairs(storeObj.items) do
        local storeCfg = shopCfgs[storeId]
        if self:hasNew(storeId, storeCfg, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
          return true
        end
      end
    end
  else
    for storeId, storeCfg in pairs(shopCfgs) do
      if (storeCfg.label_A_ID ~= 0 or storeCfg.label_B_ID ~= 0) and self:hasNew(storeId, storeCfg, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
        return true
      end
    end
  end
  log(bWriteLog and string.format("LogicPHomeStore.HasNewStoreItem no new store item. FirstTab:%s, SecondTab:%s", FirstTab, SecondTab))
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local MergePatialTool = require("GameLua.Mod.SocialIsland.GamePlay.MergePatialTool")
MergePatialTool.Mixin(CModuleBase, LogicPHomeStore, require("client.slua.logic.homestore.HomeStoreChestPatial"))
return class(CModuleBase, nil, LogicPHomeStore)