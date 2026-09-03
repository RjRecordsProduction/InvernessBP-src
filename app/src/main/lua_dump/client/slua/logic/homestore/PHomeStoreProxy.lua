local PHomeStoreProxy = {}
local Promise = require("common.Promise")
local PHomeStoreConst = require("client.slua.logic.homestore.PHomeStoreConst")
function PHomeStoreProxy:GetStoreTabObj(FirstTab, SecondTab)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore:GetStoreObj(FirstTab, SecondTab)
end
function PHomeStoreProxy:ClearStoreObjNewMark(storeTabObj)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore:ClearStoreObjNewMark(storeTabObj)
end
function PHomeStoreProxy:GetPHomeItemCfg(phomeItemId)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore:getPHomeItemCfg(phomeItemId)
end
function PHomeStoreProxy:GetPHomeStoreCfg(phomeStoreId)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore:GetHomeStoreCfg(phomeStoreId)
end
function PHomeStoreProxy:getPHomeStoreSetCfg(setId)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore:getPHomeStoreSetCfg(setId)
end
function PHomeStoreProxy:GetMyCoinsByType(type)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  local count = LogicPHomeStore.depotCoins[type] or 0
  return math.floor(count)
end
function PHomeStoreProxy:GetDepotItemCount(phomeItemId, bDoReqIfEmpty)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  local allCountMap = LogicPHomeStore:GetDepotAndUsedItemCount()
  if allCountMap == nil then
    if bDoReqIfEmpty then
      LogicPHomeStore:ReqDepotIfEmpty()
      return -1
    end
    return 0
  end
  return allCountMap[phomeItemId] or 0
end
function PHomeStoreProxy:IsHaveItem(phomeItemId, storeId)
  local hasBuyNum = PHomeStoreProxy:GetHasBuyStoreCount(storeId)
  return self:GetDepotItemCount(phomeItemId) > 0 or 0 < hasBuyNum
end
function PHomeStoreProxy:GetHasBuyStoreCount(phomeStoreId)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  local buyHistory = LogicPHomeStore.buy_history
  if not buyHistory then
    LogExceptionAndReport("PHomeStoreProxy:GetHasBuyStoreCount buyHistory is nil", 6)
    return 0
  end
  return buyHistory[phomeStoreId] or 0
end
function PHomeStoreProxy:GetIsDailyDiscount()
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore:GetIsDailyDiscount()
end
function PHomeStoreProxy:GetDailyDrawCnt()
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore.daily_draw_cnt or 0
end
function PHomeStoreProxy:SetDailyDrawCnt(daily_draw_cnt)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  LogicPHomeStore.daily_draw_cnt = daily_draw_cnt or 0
end
function PHomeStoreProxy:GetExtraDrawCnt()
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore.extra_draw_cnt or 0
end
function PHomeStoreProxy:SetExtraDrawCnt(extra_draw_cnt)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  LogicPHomeStore.extra_draw_cnt = extra_draw_cnt or 0
end
function PHomeStoreProxy:ShowPHomeMain(from, page1, page2, storeId, extraData)
  printf("PHomeStoreProxy:ShowPHomeMain from = %s, page1 = %s, page2 = %s, storeId = %s", from, page1, page2, storeId)
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  local isHomeOpen = logic_home_switch:CheckHomeStoreSwitchOpen(true)
  if not isHomeOpen then
    print(bWriteLog and "PHomeStoreProxy:ShowPHomeMain isHomeOpen = false")
    return
  end
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  if not LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_Home) then
    printf("PHomeStoreProxy:ShowPHomeMain not downloaded")
    ShowNotice(LocUtil.GetLocalizeResStr(7421))
    LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.EName_Home, function()
      printf("PHomeStoreProxy:ShowPHomeMain downloaded")
    end)
    return
  end
  local gotoFunc = function()
    PHomeStoreProxy:DoShowPHomeMain(from, page1, page2, storeId, extraData)
  end
  local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
  logic_home_download.CheckHomeChildModuleReady(logic_home_download.HomeChileModuleType.HomeShopType, gotoFunc)
end
function PHomeStoreProxy:DoShowPHomeMain(from, page1, page2, storeId, extraData)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsVisitMode() then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPC = GameplayData.GetPlayerController()
    local uChar = GameplayData.GetPlayerCharacter()
    if Game:IsValid(uPC) and Game:IsValid(uChar) then
      local viewtarget = uPC:GetViewTarget()
      printf("PHomeStoreProxy:ShowPHomeMain viewtarget = %s", viewtarget)
      if viewtarget ~= uChar then
        printf("PHomeStoreProxy:ShowPHomeMain viewtarget ~= uChar, ignore")
        return
      end
    else
      printf("PHomeStoreProxy:ShowPHomeMain invalid uPC or uChar")
      return
    end
  end
  local PlanPH_Common_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_Common_Tools")
  PlanPH_Common_Tools.LockUIInput()
  self:onShowPHomeMainPhase(1)
  if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.PlanPH_Clothing_Show_UIBP and UIManager.IsUIShow(UIManager.UI_Config_InGame.PlanPH_Clothing_Show_UIBP) then
    log(bWriteLog and "PHomeStoreProxy:ShowPHomeMain close PlanPH_Clothing_Show_UIBP before show store")
    UIManager.CloseUI(UIManager.UI_Config_InGame.PlanPH_Clothing_Show_UIBP)
  end
  local PHomeUISceneManager = require("client.slua.logic.homestore.PHomeUISceneManager")
  local args = {
    dftTabIndex = page1,
    dftSubTabIndex = page2,
    storeId = storeId,
    from = from or 1
  }
  if type(extraData) == "table" then
    for k, v in pairs(extraData) do
      args[k] = v
    end
  end
  self:onShowPHomeMainPhase(2)
  PHomeUISceneManager:ShowUIWithScene(UIManager.UI_Config.PlanPH_Store_Main_UIBP, from, args, function()
    printf("xPHomeStoreProxy:ShowPHomeMain UI and scene ready")
    self:onShowPHomeMainPhase(3)
    logic_connection_waiting:Hide(0)
  end)
end
function PHomeStoreProxy:onShowPHomeMainPhase(phase)
  log(bWriteLog and "PHomeStoreProxy:onShowPHomeMainPhase. phase  = " .. tostring(phase))
  self.showingPhase = phase
  if phase == 2 then
    self.isShowingPHomeMain = true
  elseif phase == 3 then
    self.isShowingPHomeMain = false
  end
end
function PHomeStoreProxy:GetTabData()
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore:lazyConstructTabs()
end
function PHomeStoreProxy:SendBuyItemReq(good_id, good_cnt, price_type, buyFrom, callback)
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  local PHomeStoreHandler = require("client.network.Protocol.PHomeStoreHandler")
  local reqPromise = PHomeStoreHandler.send_manor_buy_req(good_id, good_cnt, price_type, buyFrom)
  return reqPromise:Then(function(err_code, good_id, good_cnt, item_list)
    if err_code == 0 then
      item_list = slua.LuaArchiverDecode(LuaStateWrapper, item_list)
      if bWriteLog and item_list then
        local id, count = next(item_list)
        print(bWriteLog and string.format("PHomeStoreProxy:SendBuyItemReq rsp good_id:%s, good_cnt:%s, id:%s count:%s", good_id, good_cnt, id, count))
      end
      local PHomeStoreUtils = require("GameLua.Mod.SocialIsland.Client.UI.PHome.PHomeStoreUtils")
      PHomeStoreUtils.ShowCommonItemGetKV(item_list)
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.Home_Store_Buy, 0, tostring(buyFrom))
      local logic_home_pass = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_pass)
      logic_home_pass:SetPaidPopup(true)
    else
    end
    if callback then
      callback()
    end
  end)
end
function PHomeStoreProxy:ShowStoreBuyPopupUI(storeId, kwargs)
  local Logic_HomeBuyPopup = require("client.slua.logic.homestore.Logic_HomeBuyPopup")
  local openFrom
  local storeType = PHomeStoreConst.StoreType.Store
  local buyCount
  if kwargs then
    openFrom = kwargs.openFrom
    storeType = kwargs.storeType or storeType
    buyCount = kwargs.buyCount
  end
  local storeCfg = self:GetPHomeStoreCfg(storeId)
  if not storeCfg then
    log_error("PHomeStoreProxy:ShowStoreBuyPopupUI storeCfg is nil. storeId = " .. tostring(storeId))
    return
  end
  Logic_HomeBuyPopup.ShowPlanPHStoreBuyPopup(storeCfg, storeId, openFrom, storeType, buyCount)
end
function PHomeStoreProxy:GetCurrentDrawActivityCfg()
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  local cfg = LogicPHomeStore:GetCurrentDrawActivityCfg()
  if not cfg then
    log_error("PHomeStoreProxy:GetCurrentDrawActivityCfg cfg is nil")
  end
  return cfg
end
function PHomeStoreProxy:GetCurrentDrawActivityJackpotIndex()
  local cfg = self:GetCurrentDrawActivityCfg()
  if not cfg then
    return 0
  end
  local posArray, cfgArray = PHomeStoreProxy:GetDrawSlotToIndexs(cfg)
  local jackpotItemId = cfg.jackpot_items
  for i, v in ipairs(cfgArray) do
    if v.award_item_id == jackpotItemId then
      return i
    end
  end
end
function PHomeStoreProxy:GetValidActivityCfgArray()
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  return LogicPHomeStore:GetValidActivityCfgArray()
end
function PHomeStoreProxy:IsHitJackpot(total_draw_items)
  local cfg = self:GetCurrentDrawActivityCfg()
  if not cfg then
    return false
  end
  local jackpotId = cfg.jackpot_items
  for _, v in pairs(total_draw_items) do
    if v.item_id == jackpotId then
      return true
    end
  end
end
function PHomeStoreProxy:GetJackpotBroadcastText(msg)
  local name = msg.name
  local cfg = self:GetCurrentDrawActivityCfg()
  if not cfg then
    return ""
  end
  local jackpotId = cfg.jackpot_items
  local jackpotCfg = self:GetPHomeItemCfg(jackpotId)
  if not jackpotCfg then
    return ""
  end
  local jackpotName = jackpotCfg.Name
  local content = LocUtil.LocalizeResFormat(65381, name, jackpotName)
  return content
end
function PHomeStoreProxy:GetDrawItemIndexById(item_id)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_draw_back_weight_table)
  if not cfgs then
    log_error("server data table not found.manor_draw_back_weight_table")
    return
  end
  local cfg = self:GetCurrentDrawActivityCfg()
  if not cfg then
    printf("GetDrawItemIndexById not found cfg")
    return
  end
  for k, cfg in pairs(cfgs[cfg.activity_id]) do
    if cfg.award_item_id == item_id then
      return k
    end
  end
  log_error("GetDrawItemIndexById not found item_id:" .. item_id)
end
function PHomeStoreProxy:GetDrawSlotToIndexs(activityCfg)
  local cfgId = activityCfg.activity_id
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_draw_back_weight_table)
  if not cfgs then
    log_error("server data table not found.manor_draw_back_weight_table")
    return
  end
  local tb = cfgs[cfgId]
  local indexes = {}
  for i = 1, #tb do
    indexes[#indexes + 1] = tb[i].pos_id
  end
  return indexes, tb
end
function PHomeStoreProxy:GetDrawAllAwardItemIds()
  local cfg = self:GetCurrentDrawActivityCfg()
  if not cfg then
    return
  end
  local cfgId = cfg.activity_id
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_draw_back_weight_table)
  if not cfgs and IsEditor then
    assert(false, "server data table not found.manor_draw_back_weight_table")
  end
  return cfgs[cfgId]
end
function PHomeStoreProxy:GetDrawAllAwardItemIdsByActivityId(activity_id)
  if not activity_id then
    return
  end
  local cfgId = activity_id
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local cfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_draw_back_weight_table)
  if not cfgs and IsEditor then
    assert(false, "server data table not found.manor_draw_back_weight_table")
  end
  return cfgs[cfgId]
end
function PHomeStoreProxy:HasNewStoreItem(FirstTab, SecondTab)
  local t1 = slua.getMicroseconds()
  local LogicPHomeStore = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicPHomeStore)
  local r = LogicPHomeStore:HasNewStoreItem(FirstTab, SecondTab)
  local t2 = slua.getMicroseconds()
  local diff = t2 - t1
  printf("PHomeStoreProxy:HasNewStoreItem diff:%s", diff)
  return r
end
return PHomeStoreProxy