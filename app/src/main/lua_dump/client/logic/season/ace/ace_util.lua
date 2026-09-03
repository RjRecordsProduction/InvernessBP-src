local ace_util = {}
local season_year_util = require("client.logic.season_year.util.season_year_util")
function ace_util.GetShowListData(target_uid)
  log(bWriteLog and "ace_util.GetShowListData target_uid = " .. tostring(target_uid))
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  local AceImprintDetailS20 = AceImprintLogic.GetAceImprintDetailS20(target_uid)
  local summaryMap = AceImprintDetailS20 and AceImprintDetailS20.summary or nil
  local summaryList = {}
  local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
  for _, id in pairs(ace_config.ImprintBaseIDList) do
    local data = {
      id = id,
      base_id = 0,
      count = 0
    }
    if summaryMap then
      local info = summaryMap[id]
      if info and info.base_id and 0 < info.count then
        data.base_id = info.base_id
        data.count = info.count
      end
    end
    table.insert(summaryList, data)
  end
  table.sort(summaryList, function(a, b)
    return a.id < b.id
  end)
  local highestImprintIndex = 0
  local highestImprintBaseId = 0
  for index, data in ipairs(summaryList) do
    if highestImprintBaseId < data.base_id and summaryMap and summaryMap[data.id] and 0 < data.count then
      highestImprintBaseId = data.base_id
      highestImprintIndex = index
    end
  end
  if season_year_util.CheckFunctionIsOpen() then
    summaryList = ace_util.ClassicalAceDataProcess(summaryList, target_uid)
  end
  return summaryList, highestImprintIndex
end
function ace_util.GetSetListData(target_uid)
  log(bWriteLog and "ace_util.GetSetListData target_uid = " .. tostring(target_uid))
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  local AceImprintDetailS20 = AceImprintLogic.GetAceImprintDetailS20(target_uid)
  local summaryMap = AceImprintDetailS20 and AceImprintDetailS20.summary or nil
  local setList = {}
  local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
  for _, id in pairs(ace_config.ImprintBaseIDList) do
    if summaryMap then
      local info = summaryMap[id]
      if info and info.base_id and info.count > 0 then
        local data = {
          id = id,
          base_id = info.base_id,
          count = info.count
        }
        table.insert(setList, data)
      end
    end
  end
  table.sort(setList, function(a, b)
    return a.id < b.id
  end)
  local highestImprintIndex = 0
  local highestImprintBaseId = 0
  for index, info in ipairs(setList) do
    if highestImprintBaseId < info.base_id then
      highestImprintBaseId = info.base_id
      highestImprintIndex = index
    end
  end
  log_tree(bWriteLog and "ace_util.GetSetListData setList = ", setList)
  log(bWriteLog and "ace_util.GetSetListData highestImprintIndex = " .. tostring(highestImprintIndex))
  return setList, highestImprintIndex
end
function ace_util.CalAceGetNum(getList, max_segment_id)
  log(bWriteLog and "ace_util.CalAceGetNum max_segment_id = " .. tostring(max_segment_id))
  local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
  for _, id in pairs(ace_config.peakGameAceIDList) do
    if id <= max_segment_id then
      if getList[id] then
        getList[id] = getList[id] + 1
      else
        getList[id] = 1
      end
    end
  end
  log_tree(bWriteLog and "ace_util.CalAceGetNum getList = ", getList)
  return getList
end
function ace_util.GetPeakGameShowListData(segment_info)
  log(bWriteLog and "ace_util.GetPeakGameShowListData")
  log_tree(bWriteLog and "ace_util.GetPeakGameShowListData segment_info = ", segment_info)
  local getList = {}
  for season_id, info in pairs(segment_info or {}) do
    local max_segment_id = tonumber(info.max_segment_id)
    if max_segment_id then
      ace_util.CalAceGetNum(getList, max_segment_id)
    end
  end
  log_tree(bWriteLog and "ace_util.GetPeakGameShowListData getList = ", getList)
  local showList = {}
  local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
  for _, id in pairs(ace_config.peakGameAceIDList) do
    local data = {
      id = id,
      count = getList[id] or 0
    }
    table.insert(showList, data)
  end
  table.sort(showList, function(a, b)
    return a.id < b.id
  end)
  local highestImprintIndex = 0
  local highestImprintId = 0
  for index, data in ipairs(showList) do
    if highestImprintId < data.id and data.count > 0 then
      highestImprintId = data.id
      highestImprintIndex = index
    end
  end
  return showList, highestImprintIndex
end
function ace_util.GetPeakGameSetListData(segment_info)
  log(bWriteLog and "ace_util.GetPeakGameSetListData")
  log_tree(bWriteLog and "ace_util.GetPeakGameSetListData segment_info = ", segment_info)
  local getList = {}
  for season_id, info in pairs(segment_info or {}) do
    local max_segment_id = tonumber(info.max_segment_id)
    if max_segment_id then
      ace_util.CalAceGetNum(getList, max_segment_id)
    end
  end
  log_tree(bWriteLog and "ace_util.GetPeakGameShowListData getList = ", getList)
  local setList = {}
  local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
  for _, id in pairs(ace_config.peakGameAceIDList) do
    if getList[id] and 0 < getList[id] then
      local data = {
        id = id,
        count = getList[id]
      }
      table.insert(setList, data)
    end
  end
  table.sort(setList, function(a, b)
    return a.id < b.id
  end)
  local highestImprintIndex = 0
  local highestImprintId = 0
  for index, data in ipairs(setList) do
    if highestImprintId < data.id then
      highestImprintId = data.id
      highestImprintIndex = index
    end
  end
  return setList, highestImprintIndex
end
function ace_util.GetUnlockPeakGameAceBySeasonId(segment_info, season_id)
  log(bWriteLog and "ace_util.GetUnlockPeakGameAceBySeasonId season_id = " .. tostring(season_id))
  log_tree(bWriteLog and "ace_util.GetUnlockPeakGameAceBySeasonId segment_info = ", segment_info)
  if segment_info == nil or not next(segment_info) then
    return nil
  end
  local info = segment_info[season_id]
  if info == nil or not next(info) then
    return nil
  end
  local max_segment_id = info.max_segment_id
  if not max_segment_id then
    return nil
  end
  local getList = {}
  local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
  for _, id in ipairs(ace_config.peakGameAceIDList) do
    if id <= max_segment_id then
      table.insert(getList, id)
    end
  end
  log_tree(bWriteLog and "ace_util.GetUnlockPeakGameAceBySeasonId getList = ", getList)
  return getList
end
function ace_util.SetPeakGameAceImage(Common_KingMark_UIBP, ace_id, ace_num)
  log(bWriteLog and "ace_util.SetPeakGameAceImage ace_id = " .. tostring(ace_id) .. " ace_num = " .. tostring(ace_num))
  if Common_KingMark_UIBP == nil or not slua.isValid(Common_KingMark_UIBP) then
    return
  end
  if ace_id == nil or ace_id <= 0 or ace_num == nil or ace_num <= 0 then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local peakGameAceCfg = CDataTable.GetTableData("PeakGameAce", ace_id)
  if not peakGameAceCfg then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local util = require("client.slua_ui_framework.util")
  Common_KingMark_UIBP.Image_Icon_Bg:SetRenderScale(FVector2D(1.1, 1.1))
  util.SetTexture(Common_KingMark_UIBP.Image_Icon_Bg, peakGameAceCfg.Icon)
  Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  Common_KingMark_UIBP.TextBlock_Num:SetText(tostring(ace_num))
  Common_KingMark_UIBP.TextBlock_Num:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local fontMaterialPath = peakGameAceCfg.FontMaterial
  local asset_util = require("common.asset_util")
  local fontMaterial = asset_util.GetAssetSync(fontMaterialPath)
  if fontMaterial then
    local fontInfo = Common_KingMark_UIBP.TextBlock_Num.Font
    fontInfo.FontMaterial = fontMaterial
    Common_KingMark_UIBP.TextBlock_Num:SetFont(fontInfo)
  end
end
function ace_util.SetSelfAceImprintItem(AceImprintItem, AceImprintStyle)
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  AceImprintStyle = AceImprintStyle or AceImprintLogic.EAceImprintStyle.IconAndTextBg1
  ace_util.SetPeakGameAceImage(AceImprintItem.Common_KingMark_UIBP, LobbySystem.roleData.peakgame_ace_id, LobbySystem.roleData.peakgame_ace_count)
  AceImprintItem.Image_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if LobbySystem.roleData.peakgame_ace_id == nil or LobbySystem.roleData.peakgame_ace_id <= 0 then
    AceImprintItem.TextBlock_Name:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local peakGameAceCfg = CDataTable.GetTableData("PeakGameAce", LobbySystem.roleData.peakgame_ace_id)
  AceImprintItem.TextBlock_Name:SetText(LocUtil.GetLocalizeResStr(peakGameAceCfg.TextID))
  AceImprintItem.TextBlock_Name:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function ace_util.GetPeakGameAceData(uid)
  log(bWriteLog and "ace_util.GetPeakGameAceData uid = " .. tostring(uid))
  local peakgame_ace_id, peakgame_ace_count
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "ace_util.GetPeakGameAceData 1")
    peakgame_ace_id = LobbySystem.roleData.peakgame_ace_id
    peakgame_ace_count = LobbySystem.roleData.peakgame_ace_count
  else
    log(bWriteLog and "ace_util.GetPeakGameAceData 2")
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if profile then
      log(bWriteLog and "ace_util.GetPeakGameAceData 3")
      peakgame_ace_id = profile.peakgame_ace_id
      peakgame_ace_count = profile.peakgame_ace_count
    end
  end
  log(bWriteLog and "ace_util.GetPeakGameAceData peakgame_ace_id = " .. tostring(peakgame_ace_id) .. " peakgame_ace_count = " .. tostring(peakgame_ace_count))
  return peakgame_ace_id, peakgame_ace_count
end
function ace_util.GetHonerImprintDataById(uid, imprint_id)
  log(bWriteLog and "ace_util.GetHonerImprintDataById target_uid = " .. tostring(uid))
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  local AceImprintDetailS20 = AceImprintLogic.GetAceImprintDetailS20(uid)
  local summaryMap = AceImprintDetailS20 and AceImprintDetailS20.summary or {}
  local detailsNewMap = AceImprintDetailS20 and AceImprintDetailS20.details_new or {}
  local temp_imprintData = {}
  local final_imprintData = {
    advance_num = 0,
    history_num = 0,
    season_id = 0,
    is_gray = false,
    base_id = 0,
    count = 0
  }
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local IsBlueHole = region == PublishRegionMacros.BLUEHOLE
  local cur_season_id = DataMgr.season_id
  local config = CDataTable.GetTableData("SeasonYear_Param", "start_season_index")
  local startSeasonID = IsBlueHole and 46 or 47
  if config then
    startSeasonID = tonumber(config.Value)
  end
  for _, yearData in pairs(detailsNewMap) do
    for seasonId, seasonData in pairs(yearData) do
      temp_imprintData[seasonId] = seasonData
    end
  end
  if cur_season_id >= startSeasonID then
    local advance_num = 0
    local imprint_type = imprint_id // 1000
    for i = startSeasonID, cur_season_id do
      if temp_imprintData[i] then
        for k, v in pairs(temp_imprintData[i]) do
          if v and imprint_type == k // 1000 then
            advance_num = advance_num + v.count
          end
        end
      end
    end
    final_imprintData.  else
    return false
  end
  final_imprintData.is_gray = final_imprintData.advance_num > 0
  for k, v in pairs(summaryMap) do
    if v.base_id and v.base_id // 1000 == imprint_id // 1000 then
      final_imprintData.history_num = v.count - final_imprintData.advance_num
      final_imprintData.season_id = cur_season_id
      final_imprintData.base_id = v.base_id
      final_imprintData.count = v.count
    end
  end
  return final_imprintData
end
function ace_util.GetHonerImprintData(uid)
  log(bWriteLog and "ace_util.GetHonerImprintData target_uid = " .. tostring(uid))
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  local AceImprintDetailS20 = AceImprintLogic.GetAceImprintDetailS20(uid)
  local summaryMap = AceImprintDetailS20 and AceImprintDetailS20.summary or {}
  local result_data = {}
  local advance_num_info = ace_util.GetImprintAdvanceNum(uid)
  for k, v in pairs(summaryMap) do
    if v and 7 <= k then
      local data = {
        base_id = v.base_id or 0,
        count = v.count or 0,
        advance_num = advance_num_info[k]
      }
      result_data[k] = data
    end
  end
  for i = 7, 10 do
    if not result_data[i] then
      result_data[i] = {
        base_id = i,
        count = 0,
        advance_num = 0
      }
    end
  end
  local highestImprintIndex = 0
  local highestImprintBaseId = 0
  for index, data in ipairs(summaryMap) do
    if highestImprintBaseId < data.base_id and summaryMap and summaryMap[data.id] and 0 < data.count then
      highestImprintBaseId = data.base_id
      highestImprintIndex = index
    end
  end
  return result_data, highestImprintIndex
end
function ace_util.GetImprintAdvanceNum(uid)
  log(bWriteLog and "ace_util.GetImprintHistoryNum target_uid = " .. tostring(uid))
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  local AceImprintDetailS20 = AceImprintLogic.GetAceImprintDetailS20(uid)
  local summaryMap = AceImprintDetailS20 and AceImprintDetailS20.summary or {}
  local detailsNewMap = AceImprintDetailS20 and AceImprintDetailS20.details_new or {}
  local temp_imprintData = {}
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local IsBlueHole = region == PublishRegionMacros.BLUEHOLE
  local cur_season_id = DataMgr.season_id
  local config = CDataTable.GetTableData("SeasonYear_Param", "start_season_index")
  local startSeasonID = IsBlueHole and 46 or 47
  if config then
    startSeasonID = tonumber(config.Value)
  end
  local total_imprin = {
    [7] = 0,
    [8] = 0,
    [9] = 0,
    [10] = 0
  }
  for _, yearData in pairs(detailsNewMap) do
    for seasonId, seasonData in pairs(yearData) do
      temp_imprintData[seasonId] = seasonData
    end
  end
  if cur_season_id >= startSeasonID then
    for i = startSeasonID, cur_season_id do
      if temp_imprintData[i] then
        for k, v in pairs(temp_imprintData[i]) do
          if v then
            local process_key = k // 1000
            if 7 <= process_key then
              if total_imprin[process_key] then
                total_imprin[process_key] = total_imprin[process_key] + v.count
              else
                total_imprin[process_key] = v.count
              end
            end
          end
        end
      end
    end
  end
  return total_imprin
end
function ace_util.GetPlayerAllImprintInfo(uid)
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  local imprint_info = AceImprintLogic.GetAceImprintDetailS20(uid)
  if imprint_info then
    return
  end
  local AceImprintHandler = require("client.network.Protocol.AceImprintHandler")
  AceImprintHandler.send_get_ace_imprint_detail_req(uid)
end
function ace_util.ClassicalAceDataProcess(data, uid)
  local advance_num_info = ace_util.GetImprintAdvanceNum(uid)
  for k, v in pairs(data) do
    if v and advance_num_info[v.id] then
      v.count = v.count - advance_num_info[v.id]
      if v.id > 6 then
        v.base_id = v.base_id // 1000 * 1000 + 29
      end
    end
  end
  return data
end
function ace_util.GetFinalBaseId(base_id)
  if season_year_util.CheckFunctionIsOpen() and base_id and base_id // 1000 > 6 then
    return base_id // 1000 * 1000 + 29
  end
  return base_id
end
function ace_util.IsHonerImprint(base_id)
  if season_year_util.CheckFunctionIsOpen() and base_id and base_id // 1000 > 6 and base_id > base_id // 1000 * 1000 + 29 then
    return true
  end
  return false
end
return ace_util