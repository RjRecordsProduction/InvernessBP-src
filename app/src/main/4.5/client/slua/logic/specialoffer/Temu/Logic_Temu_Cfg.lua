local Logic_Temu_Cfg = {
  seasonID = 0,
  allSeverCfg = {},
  priceInfo = {},
  lastReqTime = 0
}
function Logic_Temu_Cfg.ResetData()
  Logic_Temu_Cfg.seasonID = 0
  Logic_Temu_Cfg.allSeverCfg = {}
  Logic_Temu_Cfg.priceInfo = {}
  Logic_Temu_Cfg.lastReqTime = 0
end
local GetModule = function()
  return ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
end
function Logic_Temu_Cfg.InitCfg(cfg_name, cfgList)
  local data_config_marco = require("client.logic.data.data_config_marco")
  if cfg_name ~= data_config_marco.temu_activity_cfg then
    return
  end
  log_tree("Logic_Temu_Cfg.InitCfg = ", cfgList)
  local time_util = require("client.common.time_util")
  Logic_Temu_Cfg.lastReqTime = time_util.GetServerTimeInSec()
  local gameId = Client.GetITopGameId()
  Logic_Temu_Cfg.allSeverCfg = cfgList[gameId]
  if Logic_Temu_Cfg.allSeverCfg == nil then
    return
  end
  Logic_Temu_Cfg.CheckCurSeason()
  Logic_Temu_Cfg.GetPurchaseInfo()
  local Logic_Temu = GetModule()
  Logic_Temu:GetRedot()
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TENU_UPDATE_CFG)
end
function Logic_Temu_Cfg.TryGetCfg()
  log(bWriteLog and "[SY]Logic_Temu_Cfg:TryGetCfg.")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.temu_activity_cfg, Logic_Temu_Cfg.InitCfg)
end
function Logic_Temu_Cfg.GetCurEndTime()
  local time = 0
  local cfg = Logic_Temu_Cfg.GetSeasonCfg()
  if cfg then
    time = cfg.end_time
  end
  return time
end
function Logic_Temu_Cfg.GetCurActivityTime()
  local beginTime = 0
  local endTime = 0
  local cfg = Logic_Temu_Cfg.GetSeasonCfg()
  if cfg then
    beginTime = cfg.begin_time
    endTime = cfg.end_time
  end
  return beginTime, endTime
end
function Logic_Temu_Cfg.GetAllSeverCfg()
  return Logic_Temu_Cfg.allSeverCfg
end
function Logic_Temu_Cfg.GetCurSeasonID()
  return Logic_Temu_Cfg.seasonID
end
function Logic_Temu_Cfg.GetSeasonCfg(seasonID)
  seasonID = seasonID or Logic_Temu_Cfg.GetCurSeasonID()
  local allCfg = Logic_Temu_Cfg.GetAllSeverCfg()
  if not allCfg then
    log(bWriteLog and "[SY]Logic_Temu_Cfg.GetSeasonCfg.allCfg is nil.")
    return nil
  end
  return allCfg[seasonID]
end
function Logic_Temu_Cfg.GetAllStageCfg(seasonID)
  local cfg = Logic_Temu_Cfg.GetSeasonCfg(seasonID)
  if not cfg or not cfg.stages then
    return
  end
  return cfg.stages
end
function Logic_Temu_Cfg.GetStageCfg(stage)
  local cfg = Logic_Temu_Cfg.GetSeasonCfg()
  if not cfg or not cfg.stages then
    return
  end
  return cfg.stages[stage]
end
function Logic_Temu_Cfg.GetStagePackageId(stage, number)
  local stages = Logic_Temu_Cfg.GetStageCfg(stage)
  number = number or 1
  if not stages and stages[number] then
    return
  end
  return stages[number].pkg_id
end
function Logic_Temu_Cfg.GetStageOriginPackageId(stage, number)
  local stages = Logic_Temu_Cfg.GetStageCfg(stage)
  number = number or 1
  if not stages and stages[number] then
    return
  end
  return stages[number].ori_pkg_id
end
function Logic_Temu_Cfg.GetStageAllDisCount(stageId)
  local discountValue = {}
  local stages = Logic_Temu_Cfg.GetStageCfg(stageId)
  for i, data in pairs(stages) do
    local priceInfo = Logic_Temu_Cfg.GetPriceInfo(data.pkg_id)
    discountValue[i] = priceInfo and priceInfo.discount or 0
  end
  return discountValue
end
function Logic_Temu_Cfg.GetStageAllTask(stage, number)
  local Logic_Temu = GetModule()
  number = number or Logic_Temu:GetStartTaskMemberNum()
  local stageCfg = Logic_Temu_Cfg.GetStageCfg(stage, number)
  if not stageCfg then
    return
  end
  return stageCfg[number].tasks
end
function Logic_Temu_Cfg.GetPurchaseInfo()
  local allStage = Logic_Temu_Cfg.GetAllStageCfg()
  if allStage then
    local reqList = {}
    local isNeedReq = false
    for _, stageData in pairs(allStage) do
      for _, data in pairs(stageData) do
        if not Logic_Temu_Cfg.priceInfo[data.pkg_id] then
          table.insert(reqList, data.pkg_id)
          isNeedReq = true
        end
        if not Logic_Temu_Cfg.priceInfo[data.ori_pkg_id] then
          table.insert(reqList, data.ori_pkg_id)
          isNeedReq = true
        end
      end
    end
    if isNeedReq then
      local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
      RechargePurchaseSystem.GetPurchaseInfoReq(reqList)
    end
  end
end
function Logic_Temu_Cfg.OnRefreshDircetPriceInfo(list)
  local allStage = Logic_Temu_Cfg.GetAllStageCfg()
  if not allStage then
    return
  end
  log(bWriteLog and "Logic_Temu_Cfg:OnRefreshDircetPriceInfo")
  for _, stageData in pairs(allStage) do
    for i, data in pairs(stageData) do
      if list[data.pkg_id] then
        local price_data = list[data.pkg_id]
        Logic_Temu_Cfg.priceInfo[data.pkg_id] = price_data
        Logic_Temu_Cfg.UpdateDirectPriceInfo(price_data)
      end
      if list[data.ori_pkg_id] then
        local price_data = list[data.ori_pkg_id]
        Logic_Temu_Cfg.priceInfo[data.ori_pkg_id] = price_data
        Logic_Temu_Cfg.UpdateDirectPriceInfo(price_data)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_TENU_PRICE_REFRESH)
end
function Logic_Temu_Cfg.UpdateDirectPriceInfo(price_data)
  price_data.price = CentauriManager.GetPriceByProductId(price_data.productid, price_data.curency_unit, price_data.price, true)
end
function Logic_Temu_Cfg.OnLoadPriceDataCallback(resultCode)
  local allStage = Logic_Temu_Cfg.GetAllStageCfg()
  if not allStage or not resultCode then
    log(bWriteLog and "[SY]Logic_Temu_Cfg.OnLoadPriceDataCallback.return >>>> ")
    return
  end
  local isNeedReGetDirINfo = false
  for _, stageData in pairs(allStage) do
    for i, data in pairs(stageData) do
      local priceInfo = Logic_Temu_Cfg.GetPriceInfo(data.pkg_id)
      if Logic_Temu_Cfg.UpdateUpdatePricePrice(priceInfo) then
        isNeedReGetDirINfo = true
      end
      local oriPriceInfo = Logic_Temu_Cfg.GetPriceInfo(data.ori_pkg_id)
      if Logic_Temu_Cfg.UpdateUpdatePricePrice(oriPriceInfo) then
        isNeedReGetDirINfo = true
      end
    end
  end
  if isNeedReGetDirINfo then
    Logic_Temu_Cfg.GetPurchaseInfo()
  end
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_TENU_PRICE_REFRESH)
end
function Logic_Temu_Cfg.UpdateUpdatePricePrice(priceInfo)
  local isNeedReGetDirINfo = false
  if priceInfo then
    local oldPrice = priceInfo.price
    priceInfo.price = CentauriManager.GetPriceByProductId(priceInfo.productid, priceInfo.curency_unit, oldPrice)
    log(bWriteLog and "[SY]Logic_Temu_Cfg.UpdateUpdatePricePrice Price  >>>>> " .. tostring(oldPrice) .. " >>>> " .. tostring(priceInfo.price))
  else
    isNeedReGetDirINfo = true
  end
  return isNeedReGetDirINfo
end
function Logic_Temu_Cfg.GetPriceInfo(ItemId)
  return Logic_Temu_Cfg.priceInfo[ItemId]
end
function Logic_Temu_Cfg.GetMaxStage()
  local cfg = Logic_Temu_Cfg.GetSeasonCfg()
  if not cfg then
    return 0
  end
  return #cfg.stages
end
function Logic_Temu_Cfg.CheckCurSeason()
  local allCfg = Logic_Temu_Cfg.GetAllSeverCfg()
  if not allCfg then
    log(bWriteLog and "[SY]Logic_Temu_Cfg.CheckCurSeason NoCfg.")
    return
  end
  local version_util = require("client.common.version_util")
  local curVersion = Client.GetAppVersion()
  for i, cfg in pairs(allCfg) do
    if version_util.CompareVersionMain(curVersion, cfg.app_ver) >= 0 and Logic_Temu_Cfg.IsSeasonInTime(cfg.activity_id) then
      if Logic_Temu_Cfg.seasonID and 0 < Logic_Temu_Cfg.seasonID and Logic_Temu_Cfg.seasonID ~= cfg.activity_id then
        local Logic_Temu = GetModule()
        Logic_Temu:ClearTeamData()
      end
      Logic_Temu_Cfg.seasonID = cfg.activity_id
      break
    end
  end
end
function Logic_Temu_Cfg.IsNeedReqCfg()
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  return time_util.IsSameDay(Logic_Temu_Cfg.lastReqTime, curTime)
end
function Logic_Temu_Cfg.IsCurSeasonInTime()
  local curSeasonID = Logic_Temu_Cfg.GetCurSeasonID()
  local isInTime = Logic_Temu_Cfg.IsSeasonInTime(curSeasonID)
  if not isInTime then
    Logic_Temu_Cfg.CheckCurSeason()
    local newSeason = Logic_Temu_Cfg.GetCurSeasonID()
    if newSeason ~= 0 and curSeasonID ~= Logic_Temu_Cfg.GetCurSeasonID() then
      return Logic_Temu_Cfg.IsSeasonInTime(curSeasonID)
    end
  end
  return isInTime
end
function Logic_Temu_Cfg.IsSeasonInTime(seasonID)
  seasonID = seasonID or Logic_Temu_Cfg.GetCurSeasonID()
  if not seasonID or seasonID == 0 then
    return false
  end
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local data = Logic_Temu_Cfg.GetSeasonCfg(seasonID)
  if not data then
    return false
  end
  return curTime >= data.begin_time and curTime < data.end_time
end
function Logic_Temu_Cfg.GetSeasonEndTime()
  local data = Logic_Temu_Cfg.GetSeasonCfg()
  return data and data.end_time or 0
end
function Logic_Temu_Cfg.GetMaxStageCount()
  local allStageCfg = Logic_Temu_Cfg.GetAllStageCfg()
  if not allStageCfg then
    return 0
  end
  return #allStageCfg
end
return Logic_Temu_Cfg