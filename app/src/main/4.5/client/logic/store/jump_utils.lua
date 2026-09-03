local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local jump_utils = {
  MODEL_ID_STORE = 10001,
  MODEL_ID_SUPPLY = 10002,
  MODEL_ID_PASS = 10003,
  MODEL_ID_BACKBOX_PASS = 1002502,
  MODEL_ID_LOBBY = 10004,
  MODEL_ID_PET = 10006,
  MODEL_ID_GIFT = 20001,
  jumpMap = {},
  itemJumpMap = {},
  _itemJumpSeverData = {},
  storeJumpMap = {},
  bGetJumpMap = nil,
  bAllJumpMapRecv = false,
  Enum_GetJump_Type = {Market = 1, Shop = 2},
  GetJumpMapCallBack = {
    MaxDelayTime = 10,
    RequestTime = 0,
    CallBackFunc = nil
  },
  region = PublishRegionMacros.GLOBAL,
  Enum_LOBBY_DETAIL = {
    Banner = 1,
    BusinessPanel = 2,
    FaceSlap = 3,
    Wardrobe = 4,
    StoreIcon = 5
  },
  ENUM_JUMP_TYPE = {
    Store = 1,
    Supply = 102,
    JKStore = 101,
    Pass = 62,
    BP = 170,
    SmallRPTask = 142,
    SupplyOrStoreReward = 306
  },
  StoreCrateJumpModuleID = {
    [BP_ENUM_MODULE_SUPPLY] = true,
    [BP_ENUM_MODULE_MALL_CHILD] = true,
    [BP_ENUM_MODULE_MALL_GIVE] = true,
    [BP_ENUM_MODULE_SUPPLY_WORKSHOP] = true
  },
  FitHideJumpModuleID = {
    [BP_ENUM_MODULE_THEME_SYSTEM] = true,
    [BP_ENUM_MODULE_WorkShop] = true,
    [BP_ENUM_MODULE_CORPS] = true,
    [BP_ENUM_MODULE_WARZONE_RANK] = true,
    [BP_ENUM_MODULE_MAIN_CITY_ENTER] = true,
    [BP_ENUM_MODULE_TEAM_PLATFORM] = true,
    [BP_ENUM_MODULE_MALL] = true,
    [BP_ENUM_MODULE_MALL_CHILD] = true,
    [BP_ENUM_MODULE_MALL_GIVE] = true,
    [BP_ENUM_MODULE_SUPPLY] = true,
    [BP_ENUM_MODULE_SUPPLY_WORKSHOP] = true,
    [BP_ENUM_MODULE_ACHIEVEMENT] = true,
    [BP_ENUM_MODULE_Friend_Intimacy_Main] = true,
    [BP_ENUM_MODULE_INTIMACY_PARTNER_PREVIEW] = true,
    [BP_ENUM_MODULE_INTIMACY_LEVEL_UP_SLAP] = true,
    [BP_ENUM_MODULE_PUBGM_MUSIC] = true
  },
  SmallRPJumpModuleID = {
    [BP_ENUM_MODULE_SPECIAL_OFFER] = true,
    [BP_ENUM_MODULE_SMALL_RP_BUY_SCORE] = true,
    [BP_ENUM_MODULE_SMALL_RP_TASK] = true
  },
  RPJumpModuleID = {
    [BP_ENUM_MODULE_UNKNOW_PASS] = true,
    [BP_ENUM_MODULE_UNKNOW_PASS_REWARD_PREVIEW] = true,
    [BP_ENUM_MODULE_UNKNOW_PASS_BUY_SCORE] = true,
    [BP_ENUM_MODULE_UNKNOW_ENCOREBOXLOTTERY] = true,
    [BP_ENUM_MODULE_UNKNOW_ENCOREBOXSHOP] = true,
    [BP_ENUM_MODULE_UNKNOW_XYEARBOX_PREVIEW] = true,
    [BP_ENUM_MODULE_UNKNOW_RECORD_PREVIEW] = true
  }
}
function jump_utils.Init()
  log(bWriteLog and "jump_utils.Init")
  jump_utils.region = Client.GetPublishRegion()
  jump_utils.TryResetJumpMap()
  local OpenUISystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_opentab")
  jump_utils.RegisterJump(jump_utils.MODEL_ID_PET, jump_utils.MODEL_ID_PASS, OpenUISystem.JumpToPass)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CHARACTER, jump_utils._JumpFromUrlToCharacter)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PET_ENTER, jump_utils._JumpFromUrlToPet)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WEAPON_DIY_BOX, jump_utils._JumpFromUrlToDiyBox)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WEAPON_DIY, jump_utils._JumpFromUrlToDiy)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_VEHICLE_MAIN, jump_utils._JumpFromUrlToVehicleMain)
end
function jump_utils.CheckUrlCanJump(jumpUrl, bIgnoreDownload)
  if not jumpUrl or jumpUrl == "" then
    log(bWriteLog and "jump_utils.CheckUrlCanJump jumpUrl is unvalid!")
    return false
  end
  local LuckUtil = require("client.slua.logic.lobby_activity.luck_util")
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  jumpUrl = string.lower(jumpUrl)
  jumpUrl = webModule:URLDecode(jumpUrl)
  jumpUrl = GlobalData.PreprocessUrl(jumpUrl)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(jumpUrl)
  local moduleId
  if not params.module or params.module == "" then
    log(bWriteLog and "jump_utils.CheckUrlCanJump module is unvalid!")
    return false
  else
    if #params == 1 then
      log(bWriteLog and "jump_utils.CheckUrlCanJump only module id, can jump!")
      return true
    end
    moduleId = tonumber(params.module)
  end
  log_tree("params = ", params)
  if moduleId == BP_ENUM_MODULE_MALL or moduleId == BP_ENUM_MODULE_SUPPLY then
    if not params or not params.itemid then
      return true
    end
    local itemId = tonumber(params.itemid)
    local shopInfo
    if GlobalData.IsJapanOrKorea() then
      shopInfo = jump_utils.FindJumpInfoAll(itemId)
    else
      local toModelId = jump_utils.MODEL_ID_STORE
      if moduleId == BP_ENUM_MODULE_SUPPLY then
        toModelId = jump_utils.MODEL_ID_SUPPLY
      end
      shopInfo = jump_utils.FindJumpInfoAllByToModelId(itemId, toModelId)
    end
    return shopInfo ~= nil
  elseif moduleId == BP_ENUM_MODULE_UNKNOW_PASS then
    if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_UNKNOW_PASS) then
      return false
    end
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    if not bIgnoreDownload and PassDataSystem.GetRpResourceDownloadState() ~= ENUM_DownloadState.Done then
      return false
    end
    if not UnknowPassSystem.IsInCurSession then
      return false
    end
    local season = params.season
    if season and UnknowPassSystem.GetSeasonId() ~= tonumber(season) then
      return false
    end
    local panelType = tonumber(params.paneltype)
    if panelType and panelType == 2 then
      local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
      local seasonCfg = Logic_BonusPass:GetBranchSeasonData()
      if seasonCfg then
        local TimeUtil = require("client.common.time_util")
        if TimeUtil.UnixTimeStrBetween(seasonCfg.realStartTime, seasonCfg.endTime) ~= 0 then
          return false
        end
      else
        return false
      end
    end
    return true
  elseif moduleId == BP_ENUM_MODULE_TAROTCARD_DARWCARD and not LuckUtil.isJapan() then
    return false
  elseif moduleId == BP_ENUM_MODULE_TAROTCARD_DARWCARD and not GlobalData.IsJapanOrKorea() then
    return false
  elseif moduleId == BP_ENUM_MODULE_SPECIAL_OFFER then
    local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
    local id = tonumber(params.id)
    if id then
      if not cfg.id2CheckShow[id] then
        id = cfg.ActId2Id[id]
      end
      if id == cfg.golden then
        return true
      elseif cfg.id2CheckShow[id] then
        local checkShowFunc = cfg.id2CheckShow[id]
        if not (id and cfg.uiCdg[id]) or checkShowFunc and not checkShowFunc(params) then
          return false
        end
      end
    end
  elseif moduleId == BP_ENUM_MODULE_ITEM_UPGRADE then
    return true
  elseif LobbySystem.CheckUrlCanJump(jumpUrl) then
    return true
  end
  return false
end
function jump_utils.CheckUrlModuleID(jumpUrl1, jumpUrl2)
  if jump_utils.IsGameJumpUrl(jumpUrl1) and jump_utils.IsGameJumpUrl(jumpUrl2) then
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    local jump1 = webModule:URLDecode(jumpUrl1)
    local jump2 = webModule:URLDecode(jumpUrl2)
    if not jump1 or not jump2 then
      return false
    end
    local StringUtil = require("common.string_util")
    local params1 = StringUtil.ParseURLParams(jump1)
    local params2 = StringUtil.ParseURLParams(jump2)
    local moduleId1 = tonumber(params1.module)
    local moduleId2 = tonumber(params2.module)
    local activityId1 = tonumber(params1.activityid)
    local activityId2 = tonumber(params2.activityid)
    if moduleId1 == 1009665 or moduleId1 == BP_ENUM_MODULE_SPECIAL_OFFER then
      activityId1 = tonumber(params1.id)
      activityId2 = tonumber(params2.id)
    end
    local bCheckActId = activityId1 and activityId2
    if moduleId1 ~= nil and moduleId1 == moduleId2 and (bCheckActId and activityId1 == activityId2 or not bCheckActId) then
      return true
    end
    if moduleId1 and moduleId2 and moduleId1 == BP_ENUM_MODULE_LUCKY_BACK and moduleId2 == BP_ENUM_MODULE_LUCKY_BACK_EXCHANGE and activityId1 == activityId2 then
      return true
    end
  end
  return false
end
function jump_utils.RegisterJump(fromModelId, toModuleId, func)
  if jump_utils.jumpMap[fromModelId] == nil then
    jump_utils.jumpMap[fromModelId] = {}
  end
  log(bWriteLog and "jump_utils.RegisterJump from=" .. fromModelId .. ",to=" .. toModuleId)
  jump_utils.jumpMap[fromModelId][toModuleId] = func
end
function jump_utils._JumpReal(fromModelId, toModuleId, para)
  if jump_utils.jumpMap[fromModelId] == nil then
    log(bWriteLog and "jump_utils.Jump no support jump 1 from=" .. fromModelId .. ",to=" .. toModuleId)
    return
  end
  if jump_utils.jumpMap[fromModelId][toModuleId] == nil then
    log(bWriteLog and "jump_utils.Jump no support jump 2 from=" .. fromModelId .. ",to=" .. toModuleId)
    return
  end
  log(bWriteLog and "jump_utils.Jump from=" .. fromModelId .. ",to=" .. toModuleId)
  jump_utils.jumpMap[fromModelId][toModuleId](para)
end
function jump_utils.Jump(fromModelId, itemId)
  log(bWriteLog and "jump_utils.Jump fromModelId=" .. fromModelId .. ",itemId=" .. itemId)
  if not jump_utils.bAllJumpMapRecv then
    log(bWriteLog and "jump_utils.Jump RequestJumpMapInfo")
    jump_utils.RequestJumpMapInfo(false, function()
      local info = jump_utils.FindJumpInfo(itemId, fromModelId)
      if info == nil then
        log_warning("Jump Info is nil")
        return
      end
      log_tree("FindJumpInfo=", info)
      jump_utils._JumpReal(fromModelId, info.moduleId, info)
    end)
    return
  end
  local info = jump_utils.FindJumpInfo(itemId, fromModelId)
  if info == nil then
    log_warning("Jump Info is nil")
    return
  end
  log_tree("FindJumpInfo=", info)
  jump_utils._JumpReal(fromModelId, info.moduleId, info)
end
function jump_utils.TryResetJumpMap()
  log(bWriteLog and "jump_utils.TryResetJumpMap")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if serverTime - jump_utils.GetJumpMapCallBack.RequestTime <= jump_utils.GetJumpMapCallBack.MaxDelayTime then
    log(bWriteLog and "TryResetJumpMap false")
    return
  end
  jump_utils.bGetJumpMap = nil
  jump_utils.bAllJumpMapRecv = false
end
function jump_utils.RequestJumpMapInfo(force, callback)
  log(bWriteLog and "jump_utils.RequestJumpMapInfo " .. tostring(force))
  if force then
    jump_utils.TryResetJumpMap()
  end
  if jump_utils.bAllJumpMapRecv then
    if callback then
      callback()
    end
    return
  end
  if not jump_utils.bGetJumpMap then
    jump_utils.bGetJumpMap = {}
    for _, v in pairs(jump_utils.Enum_GetJump_Type) do
      jump_utils.bGetJumpMap[v] = false
    end
  end
  log_tree("jump_utils.RequestJumpMapInfo bGetJumpMap = ", jump_utils.bGetJumpMap)
  local TimeUtil = require("client.common.time_util")
  jump_utils.GetJumpMapCallBack.RequestTime = TimeUtil.GetServerTimeInSec()
  if callback ~= nil then
    jump_utils.GetJumpMapCallBack.CallBackFunc = callback
  end
  local NetJumpHandler = require("client.network.Protocol.NetJumpHandler")
  local OnlyOneReq = false
  if not jump_utils.bGetJumpMap[jump_utils.Enum_GetJump_Type.Market] then
    NetJumpHandler.send_get_market_jump_info()
    OnlyOneReq = true
  end
  if not jump_utils.bGetJumpMap[jump_utils.Enum_GetJump_Type.Shop] then
    NetJumpHandler.send_get_shop_jump_info()
  end
  if OnlyOneReq then
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    store_supply_manager:get_market_collect_jump_info_req()
    local store_limited_subscribe_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
    store_limited_subscribe_data:ReqGiftData()
    local StoreHandler = require("client.network.Protocol.StoreHandler")
    local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
    if not store_collect_data.CollectReddotReq then
      StoreHandler.send_get_market_collect_red_point_req()
      store_collect_data.CollectReddotReq = true
    end
    local moneyComponentSystem = require("client.slua.logic.store.logic_money_component")
    moneyComponentSystem.GetStoreCurrencyConfig()
  end
end
function jump_utils.OnRecvMarketJumpInfo(res)
  if res == nil then
    log(bWriteLog and "jump_utils.OnRecvMarketJumpInfo res is nil")
    return
  end
  jump_utils.itemJumpMap[jump_utils.MODEL_ID_STORE] = {}
  jump_utils._itemJumpSeverData[jump_utils.MODEL_ID_STORE] = res
end
function jump_utils.TryGetJumpItemMap(type)
  if not jump_utils._itemJumpSeverData[type] then
    log(bWriteLog and "[SY]jump_utils.TryGetJumpItemMap. No _itemJumpSeverData  type:" .. type)
    return
  end
  if not jump_utils.itemJumpMap[type] then
    jump_utils.itemJumpMap[type] = {}
  end
  if not next(jump_utils.itemJumpMap[type]) and next(jump_utils._itemJumpSeverData[type]) then
    if type == jump_utils.MODEL_ID_STORE then
      jump_utils.InitStoreJumpMap()
    elseif type == jump_utils.MODEL_ID_SUPPLY then
      jump_utils.InitSupplyJumpMap()
    end
  end
  return jump_utils.itemJumpMap[type]
end
function jump_utils.TryGetJumpItemByItemID(type, itemID)
  local map = jump_utils.TryGetJumpItemMap(type)
  if not map then
    return nil
  end
  return map[itemID]
end
function jump_utils.OnRecvShopJumpInfo(res)
  if res == nil then
    log(bWriteLog and "jump_utils.OnRecvShopJumpInfo res is nil")
    return
  end
  jump_utils.itemJumpMap[jump_utils.MODEL_ID_SUPPLY] = {}
  jump_utils._itemJumpSeverData[jump_utils.MODEL_ID_SUPPLY] = res
end
function jump_utils.InitSupplyJumpMap()
  log(bWriteLog and "[SY]jump_utils.InitSupplyJumpMap.")
  local res = jump_utils._itemJumpSeverData[jump_utils.MODEL_ID_SUPPLY]
  if not res then
    log_error(bWriteLog and "[SY]jump_utils.InitStoreJumpMap. _itemJumpSeverData[jump_utils.MODEL_ID_STORE] is nil")
    return
  end
  local itemMap = jump_utils.itemJumpMap[jump_utils.MODEL_ID_SUPPLY]
  for k, v in pairs(res) do
    local info = {}
    info.moduleId = jump_utils.MODEL_ID_SUPPLY
    info.itemId = k
    info.Tab1 = v[1]
    info.vipType = v[3]
    itemMap[k] = info
  end
end
function jump_utils.InitStoreJumpMap()
  log(bWriteLog and "[SY]jump_utils.InitStoreJumpMap.")
  local res = jump_utils._itemJumpSeverData[jump_utils.MODEL_ID_STORE]
  if not res then
    log_error(bWriteLog and "[SY]jump_utils.InitStoreJumpMap. _itemJumpSeverData[jump_utils.MODEL_ID_STORE] is nil")
    return
  end
  local itemMap = jump_utils.itemJumpMap[jump_utils.MODEL_ID_STORE]
  local isJPOrKR = jump_utils.region == PublishRegionMacros.JAPAN or jump_utils.region == PublishRegionMacros.KOREA
  local curModID = isJPOrKR and jump_utils.MODEL_ID_SUPPLY or jump_utils.MODEL_ID_STORE
  for k, v in pairs(res) do
    local info = {}
    info.moduleId = curModID
    info.itemId = v.item_id
    info.Tab1 = math.floor(v.page_id / 100)
    info.Tab2 = v.page_id
    info.chestItemIdList = v.chest_item_ids
    info.vipType = v.vip
    info.cant_buy = v.cant_buy
    info.begin_time = v.begin_time
    info.end_time = v.end_time
    local needAdd = true
    if info.cant_buy ~= nil and itemMap[v.item_id] and itemMap[v.item_id].cant_buy == nil then
      needAdd = false
    end
    if needAdd then
      itemMap[v.item_id] = info
    end
    if v.chest_item_ids ~= nil then
      for index, item_id in pairs(v.chest_item_ids) do
        local sub_info = {}
        sub_info.moduleId = curModID
        sub_info.itemId = info.itemId
        sub_info.Tab1 = info.Tab1
        sub_info.Tab2 = info.Tab2
        if itemMap[item_id] ~= nil and itemMap[item_id].cant_buy == nil then
        else
          itemMap[item_id] = sub_info
        end
      end
    end
    local productInfo = {
      itemId = v.item_id,
      Tab1 = math.floor(v.page_id / 100),
      Tab2 = v.page_id,
      moduleId = jump_utils.MODEL_ID_STORE
    }
    jump_utils.storeJumpMap[k] = productInfo
  end
end
function jump_utils.OnRecvJumpMapInfo(type)
  if not jump_utils.bGetJumpMap then
    log(bWriteLog and "jump_utils.OnRecvJumpMapInfo bGetJumpMap is nil")
    return
  end
  jump_utils.bGetJumpMap[type] = true
  log_tree("jump_utils.OnRecvJumpMapInfo bGetJumpMap = ", jump_utils.bGetJumpMap)
  local allRecv = true
  for _, v in pairs(jump_utils.bGetJumpMap) do
    if not v then
      allRecv = false
      break
    end
  end
  jump_utils.TryGetJumpItemMap(type == jump_utils.Enum_GetJump_Type.Market and jump_utils.MODEL_ID_STORE or jump_utils.MODEL_ID_SUPPLY)
  if allRecv then
    jump_utils.bAllJumpMapRecv = true
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_JUMP_DATA_RECEIVE)
    if jump_utils.GetJumpMapCallBack.CallBackFunc then
      local TimeUtil = require("client.common.time_util")
      local serverTime = TimeUtil.GetServerTimeInSec()
      if serverTime - jump_utils.GetJumpMapCallBack.RequestTime <= jump_utils.GetJumpMapCallBack.MaxDelayTime then
        jump_utils.GetJumpMapCallBack.CallBackFunc()
      else
        log(bWriteLog and "jump_utils.OnRecvJumpMapInfo Timeout!")
      end
      jump_utils.GetJumpMapCallBack.CallBackFunc = nil
    end
  end
end
function jump_utils.FindJumpInfo(itemId, fromModelId)
  log(bWriteLog and "jump_utils.FindJumpInfo itemId=" .. itemId)
  for k, v in pairs(jump_utils.itemJumpMap) do
    if k ~= fromModelId then
      local info = jump_utils.TryGetJumpItemByItemID(k, tonumber(itemId))
      if info ~= nil then
        info.bValid = true
        return info
      end
    end
  end
  return nil
end
function jump_utils.FindJumpInfoFirst(itemId, moduleId)
  local backup
  for k, v in pairs(jump_utils.itemJumpMap) do
    local info = jump_utils.TryGetJumpItemByItemID(k, tonumber(itemId))
    if info ~= nil then
      info.bValid = true
      if k == moduleId then
        if info.cant_buy ~= nil then
          if backup == nil then
            backup = info
          end
        else
          return info
        end
      else
        backup = info
      end
    end
  end
  return backup
end
function jump_utils.FindJumpInfoAll(itemId)
  for k, v in pairs(jump_utils.itemJumpMap) do
    local info = jump_utils.TryGetJumpItemByItemID(k, tonumber(itemId))
    if info ~= nil and jump_utils.ExceptSomeTabsForJapanVersion(info) then
      info.bValid = true
      return info
    end
  end
  return nil
end
function jump_utils.FindStoreProductJumpInfo(productId)
  if productId == nil or productId == 0 then
    return
  end
  return jump_utils.storeJumpMap[tonumber(productId)]
end
function jump_utils.ExceptSomeTabsForJapanVersion(info)
  if jump_utils.region == PublishRegionMacros.JAPAN or jump_utils.region == PublishRegionMacros.KOREA then
    if info.Tab1 == StoreConst.Page_New_ID_Recommend or info.Tab1 == StoreConst.Page_New_ID_Cloth or info.Tab1 == StoreConst.Page_New_ID_Weapon or info.Tab1 == StoreConst.Page_New_ID_Car or info.Tab1 == StoreConst.Page_New_ID_Other then
      return false
    else
      return true
    end
  else
    return true
  end
end
function jump_utils.GetJumpToChestItemId(itemId)
  log(bWriteLog and "jump_utils.GetJumpToChestItemId, itemId = " .. tostring(itemId))
  local itemJumpMap = jump_utils.TryGetJumpItemMap(jump_utils.MODEL_ID_STORE)
  if itemJumpMap and type(itemJumpMap) == "table" and next(itemJumpMap) then
    for __, info in pairs(itemJumpMap) do
      if info ~= nil and info.chestItemIdList ~= nil then
        for _, id in ipairs(info.chestItemIdList) do
          if id == itemId then
            return info.itemId
          end
        end
      end
    end
  end
  return -1
end
function jump_utils.FindJumpInfoAllByToModelId(itemId, toModelId)
  log(bWriteLog and "jump_utils.FindJumpInfoAll itemId=" .. itemId)
  for k, v in pairs(jump_utils.itemJumpMap) do
    local info = v[tonumber(itemId)]
    if info ~= nil and info.moduleId == toModelId then
      return info
    end
  end
  return nil
end
function jump_utils.IsGameJumpUrl(url)
  local StringUtil = require("common.string_util")
  if StringUtil.Starts(tostring(url), "game://") then
    return true
  else
    return false
  end
end
function jump_utils.IsPanDoraJumpUrl(url)
  local StringUtil = require("common.string_util")
  if StringUtil.Starts(tostring(url), "pandora://") then
    return true
  else
    return false
  end
end
function jump_utils.IsHttpOrHttpsJumpUrl(url)
  local StringUtil = require("common.string_util")
  if StringUtil.Starts(tostring(url), "http://") or StringUtil.Starts(tostring(url), "https://") then
    return true
  else
    return false
  end
end
function jump_utils.IsTwitterJumpUrl(url)
  local StringUtil = require("common.string_util")
  if StringUtil.Starts(tostring(url), "twitter://") then
    return true
  else
    return false
  end
end
function jump_utils.TryJumpFromSubscribeToStore()
  if not jump_utils.bAllJumpMapRecv then
    log(bWriteLog and "jump_utils.TryJumpFromSubscribeToStore RequestJumpMapInfo")
    jump_utils.RequestJumpMapInfo(false, function()
      jump_utils._TryJumpFromSubscribeToStore()
    end)
    return
  end
  jump_utils._TryJumpFromSubscribeToStore()
end
function jump_utils._TryJumpFromSubscribeToStore()
  local dataMap = jump_utils.TryGetJumpItemMap(jump_utils.MODEL_ID_STORE)
  if dataMap ~= nil then
    for itemId, data in pairs(dataMap) do
      if data.vipType ~= nil then
        EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_JUMP)
        local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
        store_supply_manager:ShowStorePrime()
        return
      end
    end
  end
  ShowNotice(6796)
end
function jump_utils.TryJumpFromSubscribeToSupply()
  if not jump_utils.bAllJumpMapRecv then
    log(bWriteLog and "jump_utils.TryJumpFromSubscribeToSupply RequestJumpMapInfo")
    jump_utils.RequestJumpMapInfo(false, function()
      jump_utils._TryJumpFromSubscribeToSupply()
    end)
    return
  end
  jump_utils._TryJumpFromSubscribeToSupply()
end
function jump_utils._TryJumpFromSubscribeToSupply()
  local dataMap = jump_utils.TryGetJumpItemMap(jump_utils.MODEL_ID_SUPPLY)
  if dataMap ~= nil then
    for _, data in pairs(dataMap) do
      if data.vipType ~= nil then
        EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_JUMP)
        local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
        store_supply_manager:JumpToCrateByTabId(data.Tab1)
        return
      end
    end
  end
  ShowNotice(6795)
end
function jump_utils._JumpFromUrlToCharacter(eventType, eventID, para)
  local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
  NewCharacterSystem:JumpToCharacter(para)
end
function jump_utils._JumpFromUrlToPet(eventType, eventID, para)
  log(bWriteLog and "jump_utils.JumpFromUrlToPet,eventType:" .. eventType .. ",eventID:" .. eventID)
  log_tree("jump_utils.JumpFromUrlToPet para:", para)
  if UIManager then
    local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
    logic_pet:OpenPetWorkShop(0)
  end
end
function jump_utils._JumpFromUrlToDiyBox(eventType, eventID, para)
  log(bWriteLog and "jump_utils.JumpFromUrlToDiyBox,eventType:" .. eventType .. ",eventID:" .. eventID)
  log_tree("jump_utils.JumpFromUrlToDiyBox para:", para)
  para = para or {}
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  local activityID = LuckybackActivitySystem.GetActivityIdByDiyWeaponId(tonumber(para.itemId))
  LuckybackActivitySystem.OpenUIWithActId(activityID)
end
function jump_utils._JumpFromUrlToDiy(eventType, eventID, para)
  log(bWriteLog and "jump_utils.JumpFromUrlToDiy,eventType:" .. eventType .. ",eventID:" .. eventID)
  log_tree("jump_utils.JumpFromUrlToDiy para:", para)
  local logic_weapon_diy = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  para = para or {}
  logic_weapon_diy:EnterSystem(para.itemId)
end
function jump_utils._JumpFromUrlToVehicleMain(eventType, eventID, para)
  log(bWriteLog and "jump_utils.JumpFromUrlToVehicleMain")
  local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
  VehicleRefitHandler.CheckAndOpenMainUI()
end
function jump_utils.CheckExistJumpType(jumpTypeID)
  for i, v in pairs(jump_utils.ENUM_JUMP_TYPE) do
    if v == jumpTypeID then
      return true
    end
  end
  return false
end
function jump_utils.OpenJumpModule(moduleId, params)
  if jump_utils.FitHideJumpModuleID[moduleId] then
    local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
    if not LogicPufferBundle.IsFitLobbyResDownloaded() then
      ShowNotice(180110)
      log_format("jump_utils.OpenJumpModule blocked by FIT, moduleId=%s", tostring(moduleId))
      return false
    end
  end
  EventSystem:postEvent(EVENTTYPE_URL, moduleId, params)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.OpenJumpModule(moduleId, params)
end
function jump_utils.IsStoreCrateJumpModule(moduleId)
  if jump_utils.StoreCrateJumpModuleID[moduleId] then
    return true
  end
  return false
end
function jump_utils.IsSmallRPJumpModule(moduleId)
  if jump_utils.SmallRPJumpModuleID[moduleId] then
    return true
  end
  return false
end
function jump_utils.IsRPJumpModule(moduleId)
  if jump_utils.RPJumpModuleID[moduleId] then
    return true
  end
  return false
end
function jump_utils.IsUrl(url)
  if jump_utils.IsGameJumpUrl(url) then
    return true
  end
  if jump_utils.IsPanDoraJumpUrl(url) then
    return true
  end
  if jump_utils.IsHttpOrHttpsJumpUrl(url) then
    return true
  end
  return false
end
function jump_utils.GetSourceTextIdBySourceType(sourceType)
  if sourceType and sourceType > ENUM_ItemSourceType.None and sourceType ~= ENUM_ItemSourceType.Activity then
    return ENUM_SourceTextId[sourceType]
  end
  if GlobalData.IsJapanOrKorea() then
    return ENUM_SourceCommonTextId
  else
    return ENUM_SourceTextId[ENUM_ItemSourceType.Activity]
  end
end
function jump_utils.GenerateGameUrl(moduleId, params)
  if not moduleId then
    return ""
  end
  local url = "game://?module=" .. moduleId
  if params and type(params) == "table" then
    for k, v in pairs(params) do
      url = url .. "&" .. k .. "=" .. v
    end
  end
  return url
end
return jump_utils