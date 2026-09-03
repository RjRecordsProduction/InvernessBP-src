local UnknowPassSubwaySystem = {
  labelType = {subLabelGold = 2, subLabelScore = 3},
  resultTyppe = {
    fail = 1,
    stop = 2,
    success = 3
  },
  pay_type = {feel = 1, pay = 2},
  localSaveType = {
    collect = 1,
    feelAdventure = 2,
    guide = 3,
    labelReddot = 4,
    saveAdventureGuide = 5
  },
  guideType = {
    fristGuide = 1,
    noGuide = 2,
    adventureGuide = 3
  },
  adventureStationData = {},
  adventureAwardData = {},
  adventureResultData = {},
  adventureReduceData = {},
  currStaationData = {},
  localAwardData = {},
  localDiscCostItemNum = {},
  animSwitch = false
}
function UnknowPassSubwaySystem.OpenSubwayExchnageUI()
  if UnknowPassSubwaySystem.IsExchangeSubwayData() then
    return
  end
  log(bWriteLog and "UnknowPassExchangeSystem.OpenSubwayExchnageUI")
  EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EXCHANGE_LIST, UnknowPassSubwaySystem.OpenSubwayUI)
end
function UnknowPassSubwaySystem.OpenSubwayUI()
  EventSystem:unregistEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EXCHANGE_LIST, UnknowPassSubwaySystem.OpenSubwayUI)
  if not UnknowPassSubwaySystem.IsExchangeSubwayData() then
    local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
    UnknowPassTunnelSystem.CloseRP()
    return
  end
end
function UnknowPassSubwaySystem.IsExchangeSubwayData()
  local label = 2
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  if not UnknowPassExchangeSystem.ExchangeItemListMap[label] or #UnknowPassExchangeSystem.ExchangeItemListMap[label] <= 0 then
    log(bWriteLog and "UnknowPassExchangeSystem.ExchangeItemListMap[label] data is nil")
    return false
  end
  return true
end
function UnknowPassSubwaySystem.OpenSubwayEntryUI()
end
function UnknowPassSubwaySystem.HideSubwayExchnageUI()
end
function UnknowPassSubwaySystem.OpenMainUIByReq()
  local curSeasonID = UnknowPassSystem.Season
  if UnknowPassSubwaySystem._curSeasonID ~= curSeasonID then
    UnknowPassSubwaySystem.ClearData()
    UnknowPassSubwaySystem._  end
  local callback = function()
    UnknowPassSubwaySystem.OpenMainUI()
  end
  UnknowPassSubwaySystem.GetAllInfoReq(callback)
  callback()
end
function UnknowPassSubwaySystem.GetAllInfoReq(callback)
  if next(UnknowPassSubwaySystem.adventureStationData) == nil then
    UnknowPassSubwaySystem.GetAdventureExploreDataInfo(callback)
  end
  if next(UnknowPassSubwaySystem.adventureAwardData) == nil then
    UnknowPassSubwaySystem.GetAdventureAwardDataInfo(callback)
  end
  if next(UnknowPassSubwaySystem.adventureReduceData) == nil then
    UnknowPassSubwaySystem.GetAdventureReduceDataInfo(callback)
  end
  if next(UnknowPassSubwaySystem.adventureResultData) == nil then
    UnknowPassSubwaySystem.GetAdventureResultDataInfo(callback)
  end
end
function UnknowPassSubwaySystem.CallBackByAdventureStation(table_name, data)
  UnknowPassSubwaySystem.adventureStationData = data
end
function UnknowPassSubwaySystem.OpenMainUI()
  local seasonIdMap = UnknowPassSubwaySystem.GetSeasonId()
  log_tree("CallBackByAdventureStation seasonIdMap", seasonIdMap)
  log(bWriteLog and "UnknowPassSystem.Season" .. tostring(UnknowPassSystem.Season))
  if next(UnknowPassSubwaySystem.adventureAwardData) ~= nil and next(UnknowPassSubwaySystem.adventureStationData) ~= nil and next(UnknowPassSubwaySystem.adventureReduceData) ~= nil and next(UnknowPassSubwaySystem.adventureResultData) ~= nil then
    local label = 2
    if not UnknowPassSubwaySystem.GetExchangeDataByLabel(label) or #UnknowPassSubwaySystem.GetExchangeDataByLabel(label) <= 0 then
      local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
      UnknowPassExchangeSystem.upass_exchange_list_req()
    end
  end
end
function UnknowPassSubwaySystem.GetAdventureResultDataInfo(callback)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.upass_explore_result_table, function(table_name, data)
    UnknowPassSubwaySystem.CallBackByAdventureResult(table_name, data)
    if callback then
      callback()
    end
  end)
end
function UnknowPassSubwaySystem.CallBackByAdventureResult(table_name, data)
  UnknowPassSubwaySystem.adventureResultData = data
end
function UnknowPassSubwaySystem.GetAdventureAwardDataInfo(callback)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.upass_explore_award_table, function(table_name, data)
    UnknowPassSubwaySystem.CallBackAdventureAward(table_name, data)
    if callback then
      callback()
    end
  end)
end
function UnknowPassSubwaySystem.CallBackAdventureAward(table_name, data)
  UnknowPassSubwaySystem.adventureAwardData = data
end
function UnknowPassSubwaySystem.GetParamByCurStationId(station, season_index, isPaid, isOnlyFrist)
  if UnknowPassSubwaySystem.adventureStationData and next(UnknowPassSubwaySystem.adventureStationData) then
    for k, v in pairs(UnknowPassSubwaySystem.adventureStationData) do
      if tonumber(station) == tonumber(v.station) and tonumber(season_index) == tonumber(v.season_index) then
        if isOnlyFrist then
          return k
        end
        if isPaid and tonumber(v.pay_type) ~= 0 then
          return k
        elseif not isPaid and tonumber(v.pay_type) == 0 then
          return k
        end
      end
    end
  end
  return {}
end
function UnknowPassSubwaySystem.GetSeasonId()
  local seasonIdMap = {}
  if UnknowPassSubwaySystem.adventureStationData and next(UnknowPassSubwaySystem.adventureStationData) then
    for k, v in pairs(UnknowPassSubwaySystem.adventureStationData) do
      if v then
        seasonIdMap[v.season_index] = true
      end
    end
  end
  return seasonIdMap
end
function UnknowPassSubwaySystem.GetStationInfo(isFrist, station)
  if UnknowPassSubwaySystem.adventureStationData and next(UnknowPassSubwaySystem.adventureStationData) then
    local arrayStationData = {}
    for key, value in pairs(UnknowPassSubwaySystem.adventureStationData) do
      table.insert(arrayStationData, {id = key, data = value})
    end
    table.sort(arrayStationData, function(a, b)
      return a.id < b.id
    end)
    if isFrist then
      return arrayStationData[1].data
    end
    for index = 1, #arrayStationData do
      if tonumber(station) == tonumber(arrayStationData[index].data.station) then
        return arrayStationData[index].data
      end
    end
  end
  return {}
end
function UnknowPassSubwaySystem.GetAdventurePayNum(station, season_index)
  if UnknowPassSubwaySystem.adventureStationData and next(UnknowPassSubwaySystem.adventureStationData) then
    for k, v in pairs(UnknowPassSubwaySystem.adventureStationData) do
      if tonumber(station) == tonumber(v.station) and tonumber(season_index) == tonumber(v.season_index) and tonumber(v.pay_type) ~= 0 then
        log_tree("[v_gpingba] GetAdventurePayNum", v)
        return v.pay_num
      end
    end
  end
  return 0
end
function UnknowPassSubwaySystem.GetAwardDataByAwardId(award_id)
  if UnknowPassSubwaySystem.adventureStationData and next(UnknowPassSubwaySystem.adventureStationData) then
    for k, v in pairs(UnknowPassSubwaySystem.adventureStationData) do
      if tonumber(v.award_id) == tonumber(award_id) and next(UnknowPassSubwaySystem.adventureAwardData) then
        log(bWriteLog and "GetAwardDataByAwardId-----" .. tostring(award_id))
        local awards = UnknowPassSubwaySystem.adventureAwardData[award_id]
        if awards and next(awards) then
          local itemId, itemNum = UnknowPassSubwaySystem.GetAwardInfoByTable(awards)
          log_tree("[v_gpingba] GetAwardDataByAwardId", awards)
          return {
            id = k,
            item_id = itemId,
            item_num = itemNum
          }
        end
      end
    end
  end
  return {}
end
function UnknowPassSubwaySystem.GetAwardInfoByTable(award_data)
  for k, v in pairs(award_data.awards) do
    return k, v
  end
  return 0, 0
end
function UnknowPassSubwaySystem.GetTotalSuppliesByStation(station, season_index, arrayStation)
  local num = 0
  if not arrayStation or #arrayStation <= 0 then
    return 0
  end
  for i = 1, #arrayStation do
    local data = arrayStation[i]
    local awardData = UnknowPassSubwaySystem.GetAwardDataByAwardId(data.award_id)
    num = num + tonumber(awardData.item_num)
    if tonumber(station) == tonumber(data.station) and tonumber(season_index) == tonumber(data.season_index) then
      return num
    end
  end
  return 0
end
function UnknowPassSubwaySystem.GetAwardArrayData()
  local idAllAarry = {}
  if UnknowPassSubwaySystem.adventureStationData and next(UnknowPassSubwaySystem.adventureStationData) then
    for k, v in pairs(UnknowPassSubwaySystem.adventureStationData) do
      if tonumber(v.backward_rate) ~= 0 then
        v.id = k
        table.insert(idAllAarry, v)
      end
    end
  end
  table.sort(idAllAarry, function(a, b)
    return a.id < b.id
  end)
  local idArray = {}
  local dicList = {}
  for i = 1, #idAllAarry do
    local awardId = idAllAarry[i].award_id
    if not next(dicList) then
      dicList[awardId] = awardId
      table.insert(idArray, idAllAarry[i])
    elseif not dicList[awardId] then
      dicList[awardId] = awardId
      table.insert(idArray, idAllAarry[i])
    end
  end
  dicList = nil
  log_tree("UnknowPassSubwaySystem.GetAwardArrayData", idArray)
  return idArray
end
function UnknowPassSubwaySystem.GetAwardId()
  if UnknowPassSubwaySystem.adventureAwardData and next(UnknowPassSubwaySystem.adventureAwardData) then
    for key, value in pairs(UnknowPassSubwaySystem.adventureAwardData) do
      if value.season_index then
        if tonumber(value.season_index) == tonumber(UnknowPassSystem.Season) then
          for item_id, v in pairs(value.awards) do
            return item_id
          end
        end
      elseif next(value) then
        for _, awards in pairs(value) do
          for item_id, num in pairs(awards) do
            return item_id
          end
        end
      end
    end
  end
  return 0
end
function UnknowPassSubwaySystem.GetPayItemId()
  if UnknowPassSubwaySystem.adventureStationData and next(UnknowPassSubwaySystem.adventureStationData) then
    for key, value in pairs(UnknowPassSubwaySystem.adventureStationData) do
      if value and tonumber(value.pay_type) ~= 0 then
        return value.pay_type
      end
    end
  end
  return 0
end
function UnknowPassSubwaySystem.GetAdventruePayNumList()
  local payNumArray = {}
  if UnknowPassSubwaySystem.adventureStationData and next(UnknowPassSubwaySystem.adventureStationData) then
    for key, value in pairs(UnknowPassSubwaySystem.adventureStationData) do
      if value and tonumber(value.pay_num) ~= 0 and tonumber(value.season_index) == tonumber(UnknowPassSystem.Season) then
        table.insert(payNumArray, value.pay_num)
      end
    end
  end
  table.sort(payNumArray, function(a, b)
    return a < b
  end)
  return payNumArray
end
function UnknowPassSubwaySystem.GetExchangeDataByLabel(label)
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  return UnknowPassExchangeSystem.ExchangeItemListMap[label] or {}
end
function UnknowPassSubwaySystem.GetStationPos(stationArray, station)
  if not stationArray or #stationArray <= 0 then
    return 0
  end
  for i = 1, #stationArray do
    if tonumber(station) == tonumber(stationArray[i].station) then
      return i
    end
  end
  return 0
end
function UnknowPassSubwaySystem.GetPropsNumById(item_id)
  log(bWriteLog and "GetPropsDataToWardrobe-----item_id-------" .. tostring(item_id))
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local _count = wardrobe_data:GetHallDepotItemCountByResID(item_id)
  if not _count then
    return 0
  end
  return tonumber(_count) or 0
end
function UnknowPassSubwaySystem.GetReduceItemNumber()
  local itemID = UnknowPassSubwaySystem.GetReduceItemId()
  local number = UnknowPassSubwaySystem.GetPropsNumById(itemID)
  return number
end
function UnknowPassSubwaySystem.GetReduceData()
  local itemID = UnknowPassSubwaySystem.GetReduceItemId()
  local number = UnknowPassSubwaySystem.GetReduceDataByReduceId(itemID)
  return number
end
function UnknowPassSubwaySystem.GetReduceItemId()
  local itemID = UnknowPassSubwaySystem.GetReduceItemIdBySeasonID(UnknowPassSystem.Season)
  return itemID
end
function UnknowPassSubwaySystem.GetReduceItemIdBySeasonID(seasonId)
  for k, v in pairs(UnknowPassSubwaySystem.adventureReduceData) do
    if v.season_index == seasonId then
      return k
    end
  end
end
function UnknowPassSubwaySystem.GetWillShowCoinTipType(itemList)
  local payItemID = UnknowPassSubwaySystem.GetPayItemId()
  local reduceItemID = UnknowPassSubwaySystem.GetReduceItemId()
  local bHasPayItem = false
  local bHasReduceItem = false
  if not itemList then
    return 0
  end
  for i, v in ipairs(itemList) do
    if v.res_id == payItemID then
      bHasPayItem = true
    end
    if v.res_id == reduceItemID then
      bHasReduceItem = true
    end
  end
  if bHasPayItem then
    return payItemID
  elseif bHasReduceItem then
    return reduceItemID
  else
    return 0
  end
end
function UnknowPassSubwaySystem.GetReduceDataByReduceId(reduce_id)
  log(bWriteLog and "v_ywuyuan" .. "UnknowPassSubwaySystem.GetReduceDataByReduceId" .. reduce_id)
  for k, v in pairs(UnknowPassSubwaySystem.adventureReduceData) do
    if k == reduce_id then
      return {
        id = k,
        season_index = v.season_index,
        relate_item_id = v.relate_item_id,
        dec_value = v.dec_value,
        enable_value = v.enable_value
      }
    end
  end
end
function UnknowPassSubwaySystem.GetAdventureExploreDataInfo(callback)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.upass_explore_table, function(table_name, data)
    UnknowPassSubwaySystem.CallBackByAdventureStation(table_name, data)
    if callback then
      callback()
    end
  end)
end
function UnknowPassSubwaySystem.GetAdventureReduceDataInfo(callback)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.upass_explore_coupon_table, function(table_name, data)
    UnknowPassSubwaySystem.CallBackAdventureReduce(table_name, data)
    if callback then
      callback()
    end
  end)
end
function UnknowPassSubwaySystem.CallBackAdventureReduce(table_name, data)
  log(bWriteLog and "v_ywuyuan" .. "CallBackAdventureReduce" .. tostring(table_name))
  UnknowPassSubwaySystem.adventureReduceData = data
end
function UnknowPassSubwaySystem.GetRewardPreviewConfig()
  local cfg = CDataTable.GetTable("RewardPreviewConfig")
  if cfg == nil then
    return
  end
  local keyTbl = {
    "ID",
    "itemID",
    "season_id",
    "order_id"
  }
  local readTbl = {}
  for _, v in pairs(cfg) do
    if v.season_id == UnknowPassSystem.Season then
      local tmp = {}
      for i, k in ipairs(keyTbl) do
        tmp[k] = v[k]
      end
      readTbl[#readTbl + 1] = tmp
    end
  end
  table.sort(readTbl, function(a, b)
    return b.order_id > a.order_id
  end)
  return readTbl
end
local CoinRpFlag = false
function UnknowPassSubwaySystem.SetShowCoinTipFlag(flag)
  CoinRpFlag = flag
end
function UnknowPassSubwaySystem.GetShowCoinTipFlag()
  return CoinRpFlag
end
local coinRpType = 0
function UnknowPassSubwaySystem.SetShowCoinTipType(type)
  coinRpType = type
end
function UnknowPassSubwaySystem.GetShowCoinTipType()
  return coinRpType
end
function UnknowPassSubwaySystem.LocalSaveData(type, isTure, season)
  local actJson = UnknowPassSubwaySystem.LoadPlayerprefsFile()
  if not actJson.guides then
    actJson.guides = {}
  end
  if not actJson.guides[tostring(season)] then
    actJson.guides[tostring(season)] = {}
  end
  if type == UnknowPassSubwaySystem.localSaveType.guide then
    actJson.guides[tostring(season)].guide = isTure
  elseif type == UnknowPassSubwaySystem.localSaveType.collect then
    actJson.guides[tostring(season)].collect = isTure
  elseif type == UnknowPassSubwaySystem.localSaveType.feelAdventure then
    actJson.guides[tostring(season)].feelAdventure = isTure
  elseif type == UnknowPassSubwaySystem.localSaveType.labelReddot then
    actJson.guides[tostring(season)].labelReddot = isTure
  elseif type == UnknowPassSubwaySystem.localSaveType.saveAdventureGuide then
    actJson.guides[tostring(season)].saveAdventureGuide = isTure
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(actJson, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassSubway)
end
function UnknowPassSubwaySystem.IsLocalSaveTipsData(type, season)
  local actJson = UnknowPassSubwaySystem.LoadPlayerprefsFile()
  if type == UnknowPassSubwaySystem.localSaveType.guide then
    if actJson.guides and actJson.guides[tostring(season)] and actJson.guides[tostring(season)].guide then
      return true
    end
  elseif type == UnknowPassSubwaySystem.localSaveType.collect then
    if actJson.guides and actJson.guides[tostring(season)] and actJson.guides[tostring(season)].collect then
      return true
    end
  elseif type == UnknowPassSubwaySystem.localSaveType.feelAdventure then
    if actJson.guides and actJson.guides[tostring(season)] and actJson.guides[tostring(season)].feelAdventure then
      return true
    end
  elseif type == UnknowPassSubwaySystem.localSaveType.labelReddot then
    if actJson.guides and actJson.guides[tostring(season)] and actJson.guides[tostring(season)].labelReddot then
      return true
    end
  elseif type == UnknowPassSubwaySystem.localSaveType.saveAdventureGuide and actJson.guides and actJson.guides[tostring(season)] and actJson.guides[tostring(season)].saveAdventureGuide then
    return true
  end
  return false
end
function UnknowPassSubwaySystem.LoadPlayerprefsFile()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  return PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassSubway) or {}
end
function UnknowPassSubwaySystem.GetLocalStrKeyBySeason()
  local strKeyTable = {}
  local audioPathTable = {}
  audioPathTable.openUIAudioPath = "/Game/WwiseEvent/Activity/Activity_120/Play_MetroAventure_Entry"
  audioPathTable.playerAudioPath = "/Game/WwiseEvent/Activity/Activity_120/Play_MetroAventure_Move"
  audioPathTable.playerAudioPathStop = "/Game/WwiseEvent/Activity/Activity_120/Stop_MetroAventure_Move"
  audioPathTable.monsterAudioPath = "/Game/WwiseEvent/Activity/Activity_120/Play_MetroAventure_Explosion"
  audioPathTable.returnTableLoopAudio = "/Game/WwiseEvent/Activity/Activity_110/MetroActivity/Play_MetroActivity_MeterRun"
  audioPathTable.returnTableStopAudion = "/Game/WwiseEvent/Activity/Activity_110/MetroActivity/Play_MetroActivity_MeterRun_Stop"
  local cfg = CDataTable.GetTable("DiffAdventureConfig")
  if cfg == nil then
    return
  end
  local curCfg = cfg[1]
  for k, v in pairs(cfg) do
    if v.SeasonId == UnknowPassSystem.Season then
      curCfg = v
      break
    end
  end
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  strKeyTable["11239"] = curCfg.helpTitle
  strKeyTable["11274"] = UnknowPassUtil.GetPeriodText()
  strKeyTable["11252"] = curCfg.guideTxt1
  strKeyTable["11253"] = curCfg.guideTxt2
  strKeyTable["11547"] = curCfg.helpContent
  return strKeyTable, audioPathTable
end
function UnknowPassSubwaySystem.ReSertSystemData()
  UnknowPassSubwaySystem.currStaationData = {}
  UnknowPassSubwaySystem.localAwardData = {}
  UnknowPassSubwaySystem.localDiscCostItemNum = {}
end
function UnknowPassSubwaySystem.ClearData()
  UnknowPassSubwaySystem.adventureStationData = {}
  UnknowPassSubwaySystem.adventureAwardData = {}
  UnknowPassSubwaySystem.adventureResultData = {}
  UnknowPassSubwaySystem.adventureReduceData = {}
end
return UnknowPassSubwaySystem