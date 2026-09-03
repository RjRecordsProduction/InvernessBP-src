local store_reddot_manager = {}
local StoreRedDotModel = {
  MODEL_ID_TAB1 = 1,
  MODEL_ID_TAB2 = 2,
  MODEL_ID_SUPPLY = 3,
  ENUM_RedDot_Style = {
    ENUM_NEW = 1,
    ENUM_AWARD = 2,
    ENUM_WORKSHOP = 3,
    ENUM_SPECIAL_DISCOUNT = 4
  },
  ENUM_ReddotType = {
    Enum_Store = 1,
    Enum_Crate = 2,
    Enum_Activity = 3
  }
}
local workshopTabIdGroup = {
  [StoreConst.workshop_supply_role] = true,
  [StoreConst.workshop_supply_modify_vehicle] = true
}
local generateNodeTab = function(mark)
  return {
    tabMark = mark,
    newCount = 0,
    isDynamic = true
  }
end
local generateLeafTab = function(category, subID, mark, showItemRedDot)
  local data = {
    tabMark = mark,
    newCount = 1,
    category = category,
      }
  if showItemRedDot then
    data.newCount = 0
    data.instanceId = {_isLeaf = true}
  end
  return data
end
local getRedSystemName = function(isSupply)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  if isSupply then
    return reddot_macro.SystemName.SupplyM
  end
  if GlobalData.IsJapanOrKorea() then
    return reddot_macro.SystemName.ShopJK
  else
    return reddot_macro.SystemName.Shop
  end
end
local isTabData = function(tab, mark)
  return tab and type(tab) == "table" and tab.tabMark == mark
end
function store_reddot_manager:DefineAndResetData()
  self.storeSupplyRedDotRawData = {}
  self.activityRedDotRawData = {}
  self.supplyRedDotData = nil
  self.storeRedDotData = nil
end
function store_reddot_manager:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    self:OnRecRedDotRsp(LobbySystem.roleData.show_market_red)
  end
end
function store_reddot_manager:OnLogOut()
  self.storeSupplyRedDotRawData = nil
  self.activityRedDotRawData = nil
  self.supplyRedDotData = nil
  self.storeRedDotData = nil
end
function store_reddot_manager:OnRecRedDotRsp(res)
  log_tree(bWriteLog and "store_reddot_manager:OnRecRedDotRsp :", res)
  if res == nil then
    return
  end
  self:CullSpecialTabRedData(res)
  self.storeSupplyRedDotRawData = res or {}
end
function store_reddot_manager:CullSpecialTabRedData(res)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local isPrimeOpen = subscribeModuleObj:GetIsPrimeOpen()
  for k, v in pairs(res) do
    if k ~= StoreRedDotModel.MODEL_ID_SUPPLY then
      for tabId, _ in pairs(v) do
        local tabMark = math.modf(tabId / 100)
        if tabMark == StoreConst.Page_New_ID_Recommend or tabId == StoreConst.Page_New_ID_Recommend then
          v[tabId] = nil
        elseif not isPrimeOpen and tabId == StoreConst.subtype_new_exchange_bps then
          v[tabId] = nil
        end
      end
    end
  end
end
function store_reddot_manager:OnInitSupplyBanner()
  local StringUtil = require("common.string_util")
  local logic_lobby_mid_banner = require("client.slua.logic.lobby.Mid.logic_lobby_mid_banner")
  local bannerList = logic_lobby_mid_banner.GetShowSupplyBannerList()
  self.activityRedDotRawData = {}
  for bannerID, data in ipairs(bannerList) do
    local params = StringUtil.ParseURLParams(data.JumpUrl or "")
    local activityId = tonumber(params and params.activityid)
    local moduleId = tonumber(params and params.module)
    local category, subID = self:GetActRedPointCategory(activityId, moduleId, data)
    if category then
      self.activityRedDotRawData[activityId] = {
        moduleId = moduleId,
        category = category,
              }
    end
  end
  self:ConstructActivityData()
end
function store_reddot_manager:GetActRedPointCategory(activityId, moduleId, activityData)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = ActivityNewSystem.GetServerDataByID(activityId)
  if ActivityData and ActivityData.data and ActivityData.data.other then
    if ActivityData.data.other.red_point_new and ActivityData.data.other.red_point_new == 1 then
      log(bWriteLog and string.format("getActRedPointCategory red_point_new : activityId = %s", activityId))
      return StoreRedDotModel.ENUM_RedDot_Style.ENUM_NEW, StoreRedDotModel.ENUM_RedDot_Style.ENUM_NEW
    elseif ActivityData.data.other.red_point_award and ActivityData.data.other.red_point_award == 1 then
      log(bWriteLog and string.format("getActRedPointCategory red_point_award : activityId = %s", activityId))
      return StoreRedDotModel.ENUM_RedDot_Style.ENUM_AWARD, StoreRedDotModel.ENUM_RedDot_Style.ENUM_AWARD
    elseif ActivityData.data.other.red_point_has_discount and ActivityData.data.other.red_point_has_discount == 1 then
      log(bWriteLog and string.format("getActRedPointCategory red_point_has_discount : activityId = %s", activityId))
      return StoreRedDotModel.ENUM_RedDot_Style.ENUM_SPECIAL_DISCOUNT, StoreRedDotModel.ENUM_RedDot_Style.ENUM_SPECIAL_DISCOUNT
    end
  elseif moduleId == BP_ENUM_MODULE_CHARACTER_BOX then
    local timeUtil = require("client.common.time_util")
    local curTime = timeUtil.GetServerTimeInSec()
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local reddotData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSupplyReddot) or {}
    local bShowCache = activityData.ID and reddotData[activityData.ID]
    if curTime and activityData.StartTimeUTC and curTime > activityData.StartTimeUTC and curTime < activityData.StartTimeUTC + 1728000 and not bShowCache then
      return StoreRedDotModel.ENUM_RedDot_Style.ENUM_NEW, StoreRedDotModel.ENUM_RedDot_Style.ENUM_NEW
    end
  end
  return nil
end
function store_reddot_manager:GetSupplyRedData()
  if self.supplyRedDotData == nil or not next(self.supplyRedDotData) then
    local defaultDataSupply = {
      newCount = 0,
      desc = getRedSystemName(true),
      isDynamic = true
    }
    local super_data = require("common.super_data")
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    self.supplyRedDotData = super_data.CreateSuperData(defaultDataSupply)
    reddot_manager:Regist(self.supplyRedDotData)
  end
  return self.supplyRedDotData
end
function store_reddot_manager:GetStoreRedData()
  if self.storeRedDotData == nil or not next(self.storeRedDotData) then
    local defaultDataSupply = {
      newCount = 0,
      desc = getRedSystemName(),
      isDynamic = true
    }
    local super_data = require("common.super_data")
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    self.storeRedDotData = super_data.CreateSuperData(defaultDataSupply)
    reddot_manager:Regist(self.storeRedDotData)
  end
  return self.storeRedDotData
end
function store_reddot_manager:SetActAvailableRedDot(activityId, moduleId, isNormal)
  local supplyData = self:GetSupplyRedData()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  if moduleId == BP_ENUM_MODULE_LUCKY_BACK then
    local _parentType = StoreConst.Supply_Page_Lucky_Back
    if not supplyData[_parentType] then
      supplyData[_parentType] = generateNodeTab(StoreRedDotModel.ENUM_ReddotType.Enum_Activity)
    end
    local _subNode = supplyData[_parentType][activityId]
    if _subNode then
      _subNode.category = reddot_macro.Category.Receive
      _subNode.subID = StoreRedDotModel.ENUM_RedDot_Style.ENUM_AWARD
      _subNode.newCount = 1
    else
      supplyData[_parentType][activityId] = generateLeafTab(reddot_macro.Category.Receive, StoreRedDotModel.ENUM_RedDot_Style.ENUM_AWARD, StoreRedDotModel.ENUM_ReddotType.Enum_Activity)
    end
  else
    local subID = isNormal and StoreRedDotModel.ENUM_RedDot_Style.ENUM_SPECIAL_DISCOUNT or StoreRedDotModel.ENUM_RedDot_Style.ENUM_AWARD
    if supplyData[activityId] then
      supplyData[activityId].category = reddot_macro.Category.Receive
      supplyData[activityId].      supplyData[activityId].newCount = 1
    else
      supplyData[activityId] = generateLeafTab(reddot_macro.Category.Receive, subID, StoreRedDotModel.ENUM_ReddotType.Enum_Activity)
    end
  end
  EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_SUPPLY_REFRESH_TAB_REDDOT)
end
function store_reddot_manager:CloseActAvailableRedDot(activityId, moduleId)
  if not activityId or activityId == 0 then
    return
  end
  local supplyData = self:GetSupplyRedData()
  if moduleId == BP_ENUM_MODULE_LUCKY_BACK then
    local _parentType = StoreConst.Supply_Page_Lucky_Back
    if supplyData[_parentType] and supplyData[_parentType][activityId] then
      supplyData[_parentType][activityId].newCount = 0
    end
  elseif supplyData[activityId] then
    supplyData[activityId].newCount = 0
  end
end
function store_reddot_manager:ConstructSupplyRedDot()
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  local supplyTabData = store_supply_manager:GetOptimizeSupplyInfo()
  local supplyRawData = self.storeSupplyRedDotRawData[StoreRedDotModel.MODEL_ID_SUPPLY] or {}
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local supplyData = self:GetSupplyRedData()
  local _tryRemoveRed = function(data, id)
    if not supplyTabData[id] then
      data.newCount = 0
    end
  end
  local _hasSub = false
  local _hasGrandson = false
  for tabID, tabData in pairs(supplyData) do
    if isTabData(tabData, StoreRedDotModel.ENUM_ReddotType.Enum_Crate) then
      _hasSub = false
      for subTabID, subTabData in pairs(tabData) do
        if isTabData(subTabData, StoreRedDotModel.ENUM_ReddotType.Enum_Crate) then
          _hasGrandson = false
          for grandsonTabID, grandsonData in pairs(subTabData) do
            if isTabData(grandsonData, StoreRedDotModel.ENUM_ReddotType.Enum_Crate) then
              _hasGrandson = true
              _tryRemoveRed(grandsonData, grandsonTabID)
            end
          end
          _hasSub = true
          if not _hasGrandson then
            _tryRemoveRed(subTabData, subTabID)
          end
        end
      end
      if not _hasSub then
        _tryRemoveRed(tabData, tabID)
      end
    end
  end
  local _addRed = function(data, id, redDotStyle)
    if not data[id] then
      data[id] = generateLeafTab(reddot_macro.Category.NewArrivals, redDotStyle or StoreRedDotModel.ENUM_RedDot_Style.ENUM_NEW, StoreRedDotModel.ENUM_ReddotType.Enum_Crate)
    else
      data[id].newCount = 1
    end
  end
  local _addSubRed = function(data, id, subId, redDotStyle)
    if not data[id] then
      data[id] = generateNodeTab(StoreRedDotModel.ENUM_ReddotType.Enum_Crate)
    end
    _addRed(data[id], subId, redDotStyle)
  end
  local _addGrandRed = function(data, id, subId, grandId, redDotStyle)
    if not data[id] then
      data[id] = generateNodeTab(StoreRedDotModel.ENUM_ReddotType.Enum_Crate)
    end
    _addSubRed(data[id], subId, grandId, redDotStyle)
  end
  for tabId, tabData in pairs(supplyTabData) do
    if supplyRawData[tabId] then
      local pageId = tabData.page_id or 0
      if 0 < pageId then
        if workshopTabIdGroup[pageId] then
          _addGrandRed(supplyData, StoreConst.workshop_supply_entrance, pageId, tabId, StoreRedDotModel.ENUM_RedDot_Style.ENUM_WORKSHOP)
        else
          _addSubRed(supplyData, pageId, tabId)
        end
      else
        _addRed(supplyData, tabId)
      end
    end
  end
end
function store_reddot_manager:ConstructActivityData()
  local supplyData = self:GetSupplyRedData()
  local actData = self.activityRedDotRawData
  for tabID, tabData in pairs(supplyData) do
    if isTabData(tabData, StoreRedDotModel.ENUM_ReddotType.Enum_Activity) then
      if tabID == StoreConst.Supply_Page_Lucky_Back then
        for subTabID, subTabData in pairs(tabData) do
          if isTabData(subTabData, StoreRedDotModel.ENUM_ReddotType.Enum_Activity) and not actData[subTabID] then
            subTabData.newCount = 0
          end
        end
      elseif tabID == StoreConst.Supply_Page_Character_Box then
        log(bWriteLog and "store_reddot_manager:ConstructActivityData 999997")
      elseif isTabData(tabData, StoreRedDotModel.ENUM_ReddotType.Enum_Activity) and not actData[tabID] then
        tabData.newCount = 0
      end
    end
  end
  for actId, data in pairs(actData) do
    if data.moduleId == BP_ENUM_MODULE_LUCKY_BACK then
      local _parentType = StoreConst.Supply_Page_Lucky_Back
      if not supplyData[_parentType] then
        supplyData[_parentType] = generateNodeTab(StoreRedDotModel.ENUM_ReddotType.Enum_Activity)
      end
      if supplyData[_parentType][actId] then
        supplyData[_parentType][actId].newCount = 1
      else
        supplyData[_parentType][actId] = generateLeafTab(data.category, data.subID, StoreRedDotModel.ENUM_ReddotType.Enum_Activity)
      end
    elseif supplyData[actId] then
      supplyData[actId].newCount = 1
    else
      supplyData[actId] = generateLeafTab(data.category, data.subID, StoreRedDotModel.ENUM_ReddotType.Enum_Activity)
    end
  end
end
function store_reddot_manager:ConstructStoreRedDot()
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  local storeTabData = store_supply_manager:GetStoreTabList()
  local storeRawData = self.storeSupplyRedDotRawData[StoreRedDotModel.MODEL_ID_TAB1] or {}
  local storeSubRawData = self.storeSupplyRedDotRawData[StoreRedDotModel.MODEL_ID_TAB2] or {}
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local storeData = self:GetStoreRedData()
  for tabID, tabData in pairs(storeData) do
    if isTabData(tabData, StoreRedDotModel.ENUM_ReddotType.Enum_Store) then
      if storeTabData[tabID] then
        local subTabList = storeTabData[tabID][StoreConst.label_market_index_sub_list] or {}
        for subTabID, subTabData in pairs(tabData) do
          if isTabData(subTabData, StoreRedDotModel.ENUM_ReddotType.Enum_Store) and not subTabList[subTabID] then
            subTabData.newCount = 0
          end
        end
      else
        for subTabID, subTabData in pairs(tabData) do
          if isTabData(subTabData, StoreRedDotModel.ENUM_ReddotType.Enum_Store) then
            storeData[tabID][subTabID].newCount = 0
          end
          storeData[tabID].newCount = 0
        end
      end
    end
  end
  for tabId, tabData in pairs(storeTabData) do
    if storeRawData[tabId] then
      if not storeData[tabId] then
        storeData[tabId] = generateNodeTab(StoreRedDotModel.ENUM_ReddotType.Enum_Store)
      end
      local subTabData = tabData[StoreConst.label_market_index_sub_list] or {}
      for subTabId, subTabData in pairs(subTabData) do
        if storeSubRawData[subTabId] then
          if storeData[tabId][subTabId] then
            storeData[tabId][subTabId].newCount = 1
          else
            storeData[tabId][subTabId] = generateLeafTab(reddot_macro.Category.NewArrivals, StoreRedDotModel.ENUM_RedDot_Style.ENUM_NEW, StoreRedDotModel.ENUM_ReddotType.Enum_Store)
          end
        end
      end
    end
  end
end
function store_reddot_manager:GetCrateTabPageReddotData(tabId, subTabId, grandsonTabId)
  local supplyRed = self:GetSupplyRedData()
  if supplyRed[tabId] then
    if subTabId and 0 < subTabId then
      if supplyRed[tabId][subTabId] and grandsonTabId and 0 < grandsonTabId then
        return supplyRed[tabId][subTabId][grandsonTabId]
      end
      return supplyRed[tabId][subTabId]
    else
      return supplyRed[tabId]
    end
  end
  return nil
end
function store_reddot_manager:GetStoreSubTabPageReddotData(tabId, subTabId)
  local storeRed = self:GetStoreRedData()
  if storeRed[tabId] then
    if subTabId and 0 < subTabId then
      return storeRed[tabId][subTabId] or {}
    else
      return storeRed[tabId] or {}
    end
  end
  return {}
end
function store_reddot_manager:SaveClickReddot(bannerId)
  log(bWriteLog and "store_reddot_manager:SaveClickReddot id: " .. tostring(bannerId))
  if not bannerId then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local reddotData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSupplyReddot) or {}
  if not reddotData[bannerId] then
    reddotData[bannerId] = true
    PlayerPrefsSystem.SaveTableToFile_N(reddotData, PlayerPrefsSystem.ePlayerPrefsType.eSupplyReddot)
  end
end
function store_reddot_manager:RemoveSupplyRed(tabId, subTabId, grandsonTabId, bannerId)
  local supplyRed = self:GetSupplyRedData()
  log(bWriteLog and string.format("store_reddot_manager:RemoveSupplyRed tabId = %s, subTabId = %s, grandsonTabId = %s ", tabId, subTabId, grandsonTabId))
  local _tryRemoveRed = function(data)
    if data.subID ~= StoreRedDotModel.ENUM_RedDot_Style.ENUM_AWARD and data.subID ~= StoreRedDotModel.ENUM_RedDot_Style.ENUM_SPECIAL_DISCOUNT then
      data.newCount = 0
    end
    self:SaveClickReddot(bannerId)
  end
  if supplyRed[tabId] then
    if subTabId and 0 < subTabId then
      if supplyRed[tabId][subTabId] then
        if grandsonTabId and 0 < grandsonTabId and supplyRed[tabId][subTabId][grandsonTabId] then
          _tryRemoveRed(supplyRed[tabId][subTabId][grandsonTabId])
        else
          _tryRemoveRed(supplyRed[tabId][subTabId])
        end
      end
    else
      _tryRemoveRed(supplyRed[tabId])
    end
  end
end
function store_reddot_manager:RemoveStoreRed(tabId, subTabId)
  log(bWriteLog and string.format("store_reddot_manager:RemoveStoreRed tabId = %s, subTabId = %s", tabId, subTabId))
  local storeRed = self:GetStoreRedData()
  if storeRed[tabId] then
    if subTabId and 0 < subTabId then
      if storeRed[tabId][subTabId] and not storeRed[tabId][subTabId].instanceId then
        storeRed[tabId][subTabId].newCount = 0
      end
    else
      storeRed[tabId].newCount = 0
    end
  end
end
function store_reddot_manager:SetCollectShowRedDotNum(redDotItemList)
  if not redDotItemList then
    return
  end
  log_tree("redDotItemList", redDotItemList)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local storeRed = self:GetStoreRedData()
  local _getGlobalData = function()
    local _parentType = StoreConst.Page_New_ID_Recommend
    local _subType = StoreConst.subtype_new_recommend_col
    if not storeRed[_parentType] then
      storeRed[_parentType] = generateNodeTab(StoreRedDotModel.ENUM_ReddotType.Enum_Store)
    end
    if not storeRed[_parentType][_subType] then
      storeRed[_parentType][_subType] = generateLeafTab(reddot_macro.Category.NewArrivals, StoreRedDotModel.ENUM_RedDot_Style.ENUM_NEW, StoreRedDotModel.ENUM_ReddotType.Enum_Store, true)
    end
    return storeRed[_parentType][_subType]
  end
  local _getJKData = function()
    local _parentType = StoreConst.Page_ID_Collect
    if not storeRed[_parentType] then
      storeRed[_parentType] = generateLeafTab(reddot_macro.Category.NewArrivals, StoreRedDotModel.ENUM_RedDot_Style.ENUM_NEW, StoreRedDotModel.ENUM_ReddotType.Enum_Store, true)
    end
    return storeRed[_parentType]
  end
  local collectNode
  if GlobalData.IsJapanOrKorea() then
    collectNode = _getJKData()
  else
    collectNode = _getGlobalData()
  end
  for itemId, v in pairs(redDotItemList) do
    collectNode.instanceId[itemId] = true
  end
end
function store_reddot_manager:SetLimitedShowRedDotNum(redDotShopList)
  if not redDotShopList then
    return
  end
  log_tree("redDotShopList", redDotShopList)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local storeRed = self:GetStoreRedData()
  local _parentType = StoreConst.Page_New_ID_Recommend
  local _subType = StoreConst.subtype_new_recommend_lim
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    _subType = StoreConst.subtype_new_recommend_lim_In
  end
  if not storeRed[_parentType] then
    storeRed[_parentType] = generateNodeTab(StoreRedDotModel.ENUM_ReddotType.Enum_Store)
  end
  if not storeRed[_parentType][_subType] then
    storeRed[_parentType][_subType] = generateLeafTab(reddot_macro.Category.NewArrivals, StoreRedDotModel.ENUM_RedDot_Style.ENUM_NEW, StoreRedDotModel.ENUM_ReddotType.Enum_Store, true)
  end
  for shopId, v in pairs(redDotShopList) do
    if v.reddot == UEnums.SubscribeState.subscribe then
      storeRed[_parentType][_subType].instanceId[shopId] = true
    end
  end
end
function store_reddot_manager:RemoveCollectShowRedDot(itemId)
  if not itemId then
    return
  end
  local storeRed = self:GetStoreRedData()
  if GlobalData.IsJapanOrKorea() then
    local _parentType = StoreConst.Page_ID_Collect
    if storeRed[_parentType] and storeRed[_parentType].instanceId then
      storeRed[_parentType].instanceId[itemId] = nil
    end
  else
    local _parentType = StoreConst.Page_New_ID_Recommend
    local _subType = StoreConst.subtype_new_recommend_col
    if storeRed[_parentType] and storeRed[_parentType][_subType] and storeRed[_parentType][_subType].instanceId then
      storeRed[_parentType][_subType].instanceId[itemId] = nil
    end
  end
end
function store_reddot_manager:RemoveLimitedShowRedDot(shopId)
  if not shopId then
    return
  end
  local storeRed = self:GetStoreRedData()
  local _parentType = StoreConst.Page_New_ID_Recommend
  local _subType = StoreConst.subtype_new_recommend_lim
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    _subType = StoreConst.subtype_new_recommend_lim_In
  end
  if storeRed[_parentType] and storeRed[_parentType][_subType] and storeRed[_parentType][_subType].instanceId then
    storeRed[_parentType][_subType].instanceId[shopId] = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSceneSwitchLatenQueueSystem = class(CModuleBase, nil, store_reddot_manager)
return CSceneSwitchLatenQueueSystem