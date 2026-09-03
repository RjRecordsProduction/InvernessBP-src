local store_jump_manager = {}
local C_Banner_Type_Supply = "supply"
function store_jump_manager:DefineAndResetData()
  self.jumpInfo = nil
  self.bannerInfo = nil
  self.jumpBackData = nil
  self.buySource = nil
end
function store_jump_manager:OnLogOut()
  self.jumpInfo = nil
  self.bannerInfo = nil
  self.jumpBackData = nil
  self:ClearBuySource()
end
function store_jump_manager:SetJumpInfo(info)
  self.jumpInfo = info or {}
end
function store_jump_manager:SetBannerInfo(info)
  self.bannerInfo = info or {}
end
function store_jump_manager:SetJumpBackData(data)
  self.jumpBackData = data
end
function store_jump_manager:ClearJumpInfo()
  self.jumpInfo = nil
  self.bannerInfo = nil
  self.jumpBackData = nil
end
function store_jump_manager:ClearBannerInfo()
  self.bannerInfo = nil
end
function store_jump_manager:ClearJumpBackData()
  self.jumpBackData = nil
end
function store_jump_manager:GetJumpInfo()
  return self.jumpInfo or {}
end
function store_jump_manager:GetBannerInfo()
  return self.bannerInfo or {}
end
function store_jump_manager:GetJumpBackData()
  return self.jumpBackData
end
function store_jump_manager:GetItemIdByJumpInfo()
  if self.jumpInfo and self.jumpInfo.itemId then
    return tonumber(self.jumpInfo.itemId)
  end
  return nil
end
function store_jump_manager:SetBuySource(buySource)
  self.buySource = tonumber(buySource)
end
function store_jump_manager:GetBuySource()
  return self.buySource
end
function store_jump_manager:ClearBuySource()
  self.buySource = nil
end
function store_jump_manager:ClearItemIdByJumpInfo(tabType)
  if tabType == StoreConst.supply_tab and self.jumpInfo and self.jumpInfo.itemId then
    self.jumpInfo.itemId = nil
  end
end
function store_jump_manager:GetShopIdByJumpInfo()
  if self.jumpInfo and self.jumpInfo.shopId then
    return tonumber(self.jumpInfo.shopId)
  end
  return nil
end
function store_jump_manager:GetShowSubByJumpInfo()
  if self.jumpInfo and self.jumpInfo.ShowSub then
    return self.jumpInfo.ShowSub
  end
  return nil
end
function store_jump_manager:GetBannerIDByJumpInfo()
  if self.jumpInfo and self.jumpInfo.bannerID then
    return self.jumpInfo.bannerID
  end
  return nil
end
function store_jump_manager:GetTabIDByJumpInfo()
  if self.jumpInfo then
    return self.jumpInfo.Tab1, self.jumpInfo.Tab2, self.jumpInfo.subTabIndex
  end
  return nil, nil, nil
end
function store_jump_manager:GetCustomByJumpInfo()
  if self.jumpInfo and self.jumpInfo.custom then
    return self.jumpInfo.custom
  end
  return nil
end
function store_jump_manager:GetCreditJumpTabInfo(tabId)
  local supply_credit_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_credit_manager)
  local isCredit, parentTabId, subTabId = supply_credit_manager:IsPointCrateSubTab(tabId)
  return isCredit, parentTabId, subTabId
end
function store_jump_manager:GetLuckyBagTabInfo(tabId)
  local supply_luckybag_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_luckybag_manager)
  local isLuckyBag, parentTabId, subTabId = supply_luckybag_manager:IsLuckyBagCrateSubTab(tabId)
  return isLuckyBag, parentTabId, subTabId
end
function store_jump_manager:ConstructSpecialTabJumpInfo()
  if self.jumpInfo and self.jumpInfo.Tab1 then
    local isSpecialTab, parentTabId, subTabId = self:GetCreditJumpTabInfo(self.jumpInfo.Tab1)
    if not isSpecialTab then
      isSpecialTab, parentTabId, subTabId = self:GetLuckyBagTabInfo(self.jumpInfo.Tab1)
      if isSpecialTab then
        self.jumpInfo.Tab1 = parentTabId
        self.jumpInfo.Tab2 = subTabId
      end
    else
      self.jumpInfo.Tab1 = parentTabId
      self.jumpInfo.Tab2 = subTabId
    end
  end
end
function store_jump_manager:CheckBannerInSupply(params)
  local bannerType
  if params.bannerType and params.bannerType ~= "" then
    bannerType = params.bannerType
  end
  if bannerType and bannerType == C_Banner_Type_Supply then
    return true
  end
  return false
end
function store_jump_manager:IsJumpToLucky(jumpInfo)
  if not jumpInfo or not jumpInfo.activityId then
    return false
  end
  if tonumber(jumpInfo.Tab1) == 0 and tonumber(jumpInfo.itemId) == 0 and tonumber(jumpInfo.activityId) > 0 then
    return true
  end
  return false
end
function store_jump_manager:JumpSupplyBanner(params)
  local activityId = tonumber(params.activityid)
  if not activityId or activityId == 0 then
    log(bWriteLog and "store_jump_manager:JumpSupplyBanner activityId is invalid")
    ShowNotice(120106)
    return
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[activityId]
  if data == nil then
    log(bWriteLog and "store_jump_manager:JumpSupplyBanner no activity data for activityId: " .. tostring(activityId))
    ShowNotice(4002)
    return
  end
  local serverTime = FuncUtil.GetServerTimeInSec()
  local startTime = data.cfg.start_time
  local endTime = data.cfg and data.cfg.end_time
  if startTime and serverTime < startTime or endTime and serverTime > data.cfg.end_time then
    log(bWriteLog and string.format("store_jump_manager:JumpSupplyBanner not in activity open time, current: %s, start: %s, end: %s", tostring(serverTime), tostring(startTime), tostring(endTime)))
    ShowNotice(4002)
    return
  end
  local var = {activityId = activityId}
  EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SUPPLY, var)
end
function store_jump_manager:CheckEndTimeByEmail(vars)
  if vars.from and tonumber(vars.from) == StoreConst.crate_collect_jump_buy_mail then
    local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
    local shopInfo = supply_collect_chest_manager:GetShopTabInfoByShopId(tonumber(vars.Tab1 or 0))
    local endTime = shopInfo and shopInfo.end_time or 0
    local TimeUtil = require("client.common.time_util")
    if shopInfo == nil or endTime == 0 or endTime < TimeUtil.GetServerTimeInSec() then
      ShowNotice(4002)
      return false
    end
  end
  return true
end
function store_jump_manager:CollationJumpInfo(vars)
  vars.activityId = tonumber(vars.activityId or 0)
  vars.itemId = tonumber(vars.itemId or 0)
  vars.Tab1 = tonumber(vars.Tab1 or 0)
  vars.Tab2 = vars.Tab2 and tonumber(vars.Tab2)
  vars.subTabIndex = vars.subTabIndex and tonumber(vars.subTabIndex)
  vars.activityType = tonumber(vars.activityType or 0)
  if vars.activityId == 0 and vars.Tab1 == 0 and vars.itemId ~= 0 then
    local from = vars.from
    local JumpUtils = require("client.logic.store.jump_utils")
    vars = JumpUtils.FindJumpInfoFirst(vars.itemId, JumpUtils.MODEL_ID_SUPPLY)
    if vars and from then
      vars.    end
  end
  return vars
end
function store_jump_manager:CheckIsFromMainCity()
  if self.buySource == StoreConst.label_buy_source_maincity_outfit or self.buySource == StoreConst.label_buy_source_maincity_vehicle then
    return true
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, store_jump_manager)
return CModuleTemplate