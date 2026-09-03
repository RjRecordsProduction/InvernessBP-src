local NetManager = require("client.network.comm.NetManager")
local EAceImprintStyle = {
  IconAndTextBg1 = 1,
  IconAndTextBg2 = 2,
  IconAndTextNoBg = 3
}
local EImprintStatus = {
  Lighted = 1,
  GetNotLighted = 2,
  NotGet = 3
}
local AceImprintLogic = {
  EAceImprintStyle = EAceImprintStyle,
  HasGetNew = false,
  AceImprintDetailS20 = {},
  MakeUpProgress = nil,
  ImprintStatus = EImprintStatus
}
local Cycle0AceImprintCfg = {
  [1] = {
    iconPath = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_16.iCON_KingMark_16",
    fontPath = "/Game/Arts/UI/UI_Mat/Font_Mat/KingMark/UIFont_Kingmark_09.UIFont_Kingmark_09"
  },
  [2] = {
    iconPath = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_20.iCON_KingMark_20",
    fontPath = "/Game/Arts/UI/UI_Mat/Font_Mat/KingMark/UIFont_Kingmark_10.UIFont_Kingmark_10"
  },
  [3] = {
    iconPath = "/Game/Arts/UI/TableIcons/KingMark/iCON_KingMark_21.iCON_KingMark_21",
    fontPath = "/Game/Arts/UI/UI_Mat/Font_Mat/KingMark/UIFont_Kingmark_11.UIFont_Kingmark_11"
  }
}
function AceImprintLogic.on_get_ace_imprint_detail_rsp(res, target_uid, data_new, progress_info)
  if res ~= 0 then
    return
  end
  AceImprintLogic.AceImprintDetailS20[target_uid] = data_new
  AceImprintLogic.MakeUpProgress = progress_info
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_ACE_IMPRINT_LIST)
end
function AceImprintLogic.GetAceImprintDetailS20(uid)
  uid = tonumber(uid)
  return AceImprintLogic.AceImprintDetailS20[uid]
end
function AceImprintLogic.OnGameStateChange(eventType, eventID, vars)
  AceImprintLogic.MakeUpProgress = nil
  log(bWriteLog and "AceImprintLogic.OnGameStateChange  " .. tostring(vars.current) .. "  " .. tostring(vars.pre))
  if vars.current == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    AceImprintLogic.HasGetNew = false
  end
end
local SetAceImprintIconFont = function(TextBlock_Num, fontMaterialPath)
  if TextBlock_Num == nil or fontMaterialPath == nil or fontMaterialPath == "" then
    return
  end
  local asset_util = require("common.asset_util")
  local fontMaterial = asset_util.GetAssetSync(fontMaterialPath)
  if fontMaterial then
    local fontInfo = TextBlock_Num.Font
    fontInfo.FontMaterial = fontMaterial
    TextBlock_Num:SetFont(fontInfo)
  end
end
local SetCycle0AceImprintIcon = function(Common_KingMark_UIBP, aceImprintCfg, ace_imprint_base_id, ace_num)
  if Common_KingMark_UIBP == nil or aceImprintCfg == nil or ace_num == nil or ace_num <= 0 then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local util = require("client.slua_ui_framework.util")
  if ace_imprint_base_id == 5000 or ace_imprint_base_id == 6000 then
    util.SetTexture(Common_KingMark_UIBP.Image_Icon_Bg, aceImprintCfg.Icon)
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    Common_KingMark_UIBP.TextBlock_Num:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif ace_imprint_base_id == 7000 then
    local fontMaterialPath = aceImprintCfg.FontMaterial
    if ace_num <= 5 then
      util.SetTexture(Common_KingMark_UIBP.Image_Icon_Bg, aceImprintCfg.Icon)
    elseif ace_num <= 10 then
      util.SetTexture(Common_KingMark_UIBP.Image_Icon_Bg, Cycle0AceImprintCfg[2].iconPath)
      fontMaterialPath = Cycle0AceImprintCfg[2].fontPath
    else
      util.SetTexture(Common_KingMark_UIBP.Image_Icon_Bg, Cycle0AceImprintCfg[3].iconPath)
      fontMaterialPath = Cycle0AceImprintCfg[3].fontPath
    end
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    Common_KingMark_UIBP.TextBlock_Num:SetText(tostring(ace_num))
    Common_KingMark_UIBP.TextBlock_Num:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    SetAceImprintIconFont(Common_KingMark_UIBP.TextBlock_Num, fontMaterialPath)
  else
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local SetOtherCycleAceImprintIcon = function(Common_KingMark_UIBP, aceImprintCfg, _, ace_num)
  if Common_KingMark_UIBP == nil or aceImprintCfg == nil or ace_num == nil or ace_num <= 0 then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(Common_KingMark_UIBP.Image_Icon_Bg, aceImprintCfg.Icon)
  Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  Common_KingMark_UIBP.TextBlock_Num:SetText(tostring(ace_num))
  Common_KingMark_UIBP.TextBlock_Num:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local fontMaterialPath = aceImprintCfg.FontMaterial
  SetAceImprintIconFont(Common_KingMark_UIBP.TextBlock_Num, fontMaterialPath)
end
local SetAceImprintIcon = function(Common_KingMark_UIBP, aceImprintCfg, ace_imprint_base_id, ace_num)
  if Common_KingMark_UIBP == nil or aceImprintCfg == nil or ace_imprint_base_id == nil or ace_imprint_base_id <= 0 or ace_num == nil or ace_num <= 0 then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  Common_KingMark_UIBP.Image_Icon_Bg:SetRenderScale(FVector2D(1, 1))
  if ace_imprint_base_id == 5000 or ace_imprint_base_id == 6000 or ace_imprint_base_id == 7000 then
    SetCycle0AceImprintIcon(Common_KingMark_UIBP, aceImprintCfg, ace_imprint_base_id, ace_num)
  else
    SetOtherCycleAceImprintIcon(Common_KingMark_UIBP, aceImprintCfg, ace_imprint_base_id, ace_num)
  end
end
function AceImprintLogic.SetAceImprintItem(AceImprintItem, ace_imprint_show_id, ace_imprint_base_id, AceImprintStyle)
  if AceImprintItem == nil then
    return
  end
  if not slua.isValid(AceImprintItem) then
    return
  end
  if ace_imprint_show_id == nil or ace_imprint_show_id <= 0 then
    AceImprintItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local ace_base_id, ace_num = AceImprintLogic.GetAceImprintBaseId(ace_imprint_show_id, ace_imprint_base_id)
  if ace_base_id <= 0 or ace_num <= 0 then
    AceImprintItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local ace_util = require("client.logic.season.ace.ace_util")
  ace_base_id = ace_util.GetFinalBaseId(ace_base_id)
  local aceImprintCfg = CDataTable.GetTableData("AceImprintIcon", ace_base_id)
  if not aceImprintCfg then
    AceImprintItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  AceImprintItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  SetAceImprintIcon(AceImprintItem.Common_KingMark_UIBP, aceImprintCfg, ace_base_id, ace_num)
  AceImprintItem.TextBlock_Name:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  AceImprintItem.TextBlock_Name:SetText(aceImprintCfg.Name)
  local UIUtil = require("client.common.ui_util")
  AceImprintItem.Image_Bg:SetWidgetVisibility(UIUtil.BoolToVisible(AceImprintStyle == EAceImprintStyle.IconAndTextBg1 or AceImprintStyle == EAceImprintStyle.IconAndTextBg2))
  if AceImprintStyle == EAceImprintStyle.IconAndTextBg1 then
    AceImprintItem.Image_Bg:SetColorAndOpacity(AceImprintItem.BgColor1)
  elseif AceImprintStyle == EAceImprintStyle.IconAndTextBg2 then
    AceImprintItem.Image_Bg:SetColorAndOpacity(AceImprintItem.BgColor2)
  end
end
function AceImprintLogic.SetAceImprintImage(Common_KingMark_UIBP, ace_imprint_show_id, ace_imprint_base_id)
  if Common_KingMark_UIBP == nil then
    return
  end
  if not slua.isValid(Common_KingMark_UIBP) then
    return
  end
  if ace_imprint_show_id == nil or ace_imprint_show_id <= 0 then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local ace_base_id, ace_num = AceImprintLogic.GetAceImprintBaseId(ace_imprint_show_id, ace_imprint_base_id)
  if ace_base_id <= 0 or ace_num <= 0 then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local ace_util = require("client.logic.season.ace.ace_util")
  ace_base_id = ace_util.GetFinalBaseId(ace_base_id)
  local aceImprintCfg = CDataTable.GetTableData("AceImprintIcon", ace_base_id)
  if not aceImprintCfg then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  SetAceImprintIcon(Common_KingMark_UIBP, aceImprintCfg, ace_base_id, ace_num)
end
function AceImprintLogic.SetAceImprintImageWithGrey(Common_KingMark_UIBP, ace_imprint_show_id, ace_imprint_base_id, isGrey)
  if Common_KingMark_UIBP == nil then
    return
  end
  if not slua.isValid(Common_KingMark_UIBP) then
    return
  end
  if ace_imprint_show_id == nil or ace_imprint_show_id <= 0 then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  isGrey = isGrey or false
  local ace_base_id, ace_num = AceImprintLogic.GetAceImprintBaseId(ace_imprint_show_id, ace_imprint_base_id)
  if ace_base_id <= 0 or ace_num <= 0 then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local ace_util = require("client.logic.season.ace.ace_util")
  ace_base_id = ace_util.GetFinalBaseId(ace_base_id)
  local aceImprintCfg = CDataTable.GetTableData("AceImprintIcon", ace_base_id)
  if not aceImprintCfg then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  SetAceImprintIcon(Common_KingMark_UIBP, aceImprintCfg, ace_base_id, ace_num)
  local asset_util = require("common.asset_util")
  local tex = asset_util.GetAssetSync(aceImprintCfg.Icon)
  local material = Common_KingMark_UIBP.Image_Icon_Bg:GetDynamicMaterial()
  if material then
    if tex then
      material:SetTextureParameterValue("diffuse", tex)
    end
    material:SetScalarParameterValue("quse", isGrey and 1 or 0)
  end
end
function AceImprintLogic.SetAceImprintImageByBaseId(Common_KingMark_UIBP, ace_imprint_base_id, ace_num, isNotLimitNewSeason)
  if Common_KingMark_UIBP == nil then
    return
  end
  if not slua.isValid(Common_KingMark_UIBP) then
    return
  end
  if ace_imprint_base_id == nil or ace_imprint_base_id <= 0 or ace_num == nil or ace_num <= 0 then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if not isNotLimitNewSeason then
    local ace_util = require("client.logic.season.ace.ace_util")
    ace_imprint_base_id = ace_util.GetFinalBaseId(ace_imprint_base_id)
  end
  local aceImprintCfg = CDataTable.GetTableData("AceImprintIcon", ace_imprint_base_id)
  if not aceImprintCfg then
    Common_KingMark_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  SetAceImprintIcon(Common_KingMark_UIBP, aceImprintCfg, ace_imprint_base_id, ace_num)
end
function AceImprintLogic.SetSelfAceImprintItem(AceImprintItem, AceImprintStyle)
  AceImprintStyle = AceImprintStyle or EAceImprintStyle.IconAndTextBg1
  AceImprintLogic.SetAceImprintItem(AceImprintItem, DataMgr.ace_imprint_show_id, DataMgr.ace_imprint_base_id, AceImprintStyle)
end
function AceImprintLogic.SetSelfAceImprintImage(Common_KingMark_UIBP)
  AceImprintLogic.SetAceImprintImage(Common_KingMark_UIBP, DataMgr.ace_imprint_show_id, DataMgr.ace_imprint_base_id)
end
function AceImprintLogic.GetAceImprintBaseId(ace_imprint_show_id, ace_imprint_base_id)
  if ace_imprint_base_id and 0 < ace_imprint_base_id then
    return ace_imprint_base_id, ace_imprint_show_id - ace_imprint_base_id
  end
  local ace_num = ace_imprint_show_id % 1000
  if 7000 <= ace_imprint_show_id then
    ace_num = ace_num % 21
  else
    ace_num = ace_num % 20
  end
  return ace_imprint_show_id - ace_num, ace_num
end
function AceImprintLogic.on_set_show_ace_imprint_rsp(err)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_SET_SHOW_IMPRINT_RES)
end
function AceImprintLogic.ShowAceMarkUI(target_uid)
  if tonumber(target_uid) == tonumber(DataMgr.roleData.uid) then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_AceMark_Summary_Self_UIBP, target_uid)
  else
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_AceMark_Summary_Other_UIBP, target_uid)
  end
end
function AceImprintLogic.GetNextImprintCfg(imprintID)
  local imprintList = AceImprintLogic.GetImprintConfigList(DataMgr.season_id)
  if not imprintList or not next(imprintList) then
    return nil
  end
  for _, id in ipairs(imprintList) do
    if imprintID < id then
      return CDataTable.GetTableData("AceImprint", id)
    end
  end
  return nil
end
function AceImprintLogic.GetImprintConfigList(season_id)
  local seasonCfg = CDataTable.GetTableData("SeasonInfo", season_id)
  if not seasonCfg then
    return nil
  end
  local aceImprintTbl = CDataTable.GetTable("AceImprint")
  if not aceImprintTbl then
    return nil
  end
  local imprintList = {}
  for _, cfg in pairs(aceImprintTbl) do
    if cfg.SeasonYearID == seasonCfg.SeasonYearID then
      table.insert(imprintList, cfg.ID)
    end
  end
  table.sort(imprintList, function(a, b)
    return a < b
  end)
  return imprintList
end
function AceImprintLogic.GetCurSeasonBestImprintID()
  local imprintList = AceImprintLogic.GetImprintConfigList(DataMgr.season_id)
  if imprintList and next(imprintList) then
    return imprintList[#imprintList]
  end
end
local CanLightUpMyImprint = function(season_id, imprint_id)
  log(bWriteLog and "AceImprintLogic.CanLightUpImprint season_id:" .. tostring(season_id))
  log(bWriteLog and "AceImprintLogic.CanLightUpImprint imprint_id:" .. tostring(imprint_id))
  if not AceImprintLogic.MakeUpProgress then
    log(bWriteLog and "AceImprintLogic.CanLightUpImprint MakeUpProgress nil")
    return true
  end
  if season_id > AceImprintLogic.MakeUpProgress.last_light_up_season_id then
    log(bWriteLog and "AceImprintLogic.CanLightUpImprint season_id more")
    return true
  end
  local last_light_up_base_id = AceImprintLogic.MakeUpProgress.last_light_up_base_id or 0
  if season_id == AceImprintLogic.MakeUpProgress.last_light_up_season_id and imprint_id > last_light_up_base_id then
    log(bWriteLog and "AceImprintLogic.CanLightUpImprint imprint_id more")
    return true
  end
  log(bWriteLog and "AceImprintLogic.CanLightUpImprint default false")
  return false
end
function AceImprintLogic.GetImprintDetailInfo(uid, season_id, imprint_id)
  local AceImprintDetailS20 = AceImprintLogic.GetAceImprintDetailS20(uid)
  if not (AceImprintDetailS20 and AceImprintDetailS20.details_new) or not next(AceImprintDetailS20.details_new) then
    log(bWriteLog and "AceImprintLogic.GetImprintDetailInfo details_new nil")
    return nil
  end
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local IsBlueHole = region == PublishRegionMacros.BLUEHOLE
  local details_new = AceImprintDetailS20.details_new
  log_tree(bWriteLog and "AceImprintLogic.GetImprintDetailInfo details_new:", details_new)
  for _, yearData in pairs(details_new) do
    for seasonId, seasonData in pairs(yearData) do
      if seasonId == season_id and seasonData[imprint_id] then
        return seasonData[imprint_id]
      end
      if IsBlueHole and seasonId == season_id and season_id == 29 then
        local convertId = AceImprintLogic.ConvertImprintIdByCycleYearId(imprint_id, 4)
        if convertId and seasonData[convertId] then
          return seasonData[convertId]
        end
      end
    end
  end
  return nil
end
function AceImprintLogic.GetMyImprintStatus(season_id, imprint_id)
  local imprintDetailInfo = AceImprintLogic.GetImprintDetailInfo(tonumber(DataMgr.roleData.uid), season_id, imprint_id)
  if not imprintDetailInfo then
    return EImprintStatus.NotGet, imprint_id, 0
  end
  local canLightUp = CanLightUpMyImprint(season_id, imprint_id)
  if canLightUp then
    return EImprintStatus.GetNotLighted, imprint_id, imprintDetailInfo.count
  end
  return EImprintStatus.Lighted, imprint_id, imprintDetailInfo.count
end
function AceImprintLogic.on_ace_imprint_light_up_rsp(err_code, progress_info)
  log(bWriteLog and "AceImprintLogic.on_ace_imprint_light_up_rsp err_code:" .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  if not progress_info or not next(progress_info) then
    return
  end
  AceImprintLogic.MakeUpProgress = progress_info
end
function AceImprintLogic.on_make_up_ace_imprint_rsp(make_up_tbl, summary)
  if not make_up_tbl or not next(make_up_tbl) then
    log(bWriteLog and "AceImprintLogic.on_make_up_ace_imprint_rsp nil make_up_tbl")
    return
  end
  if not summary or not next(summary) then
    log(bWriteLog and "AceImprintLogic.on_make_up_ace_imprint_rsp nil summary")
    return
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_ACE_IMPRINT_MAKEUP, make_up_tbl, summary)
  local AceImprintDetailS20 = AceImprintLogic.GetAceImprintDetailS20(DataMgr.roleData.uid)
  if AceImprintDetailS20 then
    AceImprintDetailS20.  end
end
function AceImprintLogic.ShowAceMarkDetailUI(target_uid)
  if tonumber(target_uid) == tonumber(DataMgr.roleData.uid) then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_AceMark_Detail_Self, target_uid)
  else
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_AceMark_Detail_Other, target_uid)
  end
end
function AceImprintLogic.ConvertImprintIdByCycleYearId(imprintId, toYearId)
  imprintId = tonumber(imprintId)
  if not (imprintId and toYearId) or toYearId < 0 then
    log(bWriteLog and "AceImprintLogic.ConvertImprintIdByCycleYearId invalid param")
    return nil
  end
  local imprintCfg = CDataTable.GetTableData("AceImprint", imprintId)
  if not imprintCfg then
    log(bWriteLog and "AceImprintLogic.ConvertImprintIdByCycleYearId no cfg")
    return nil
  end
  local imprintCfgList = CDataTable.GetTableByFilter("AceImprint", "SeasonYearID", toYearId)
  if not imprintCfgList then
    log(bWriteLog and "AceImprintLogic.ConvertImprintIdByCycleYearId no cfgList")
    return nil
  end
  local curImprintType = math.floor(imprintId / 1000)
  for _, cfg in pairs(imprintCfgList) do
    local id = tonumber(cfg.ID) or 0
    local type = math.floor(id / 1000)
    if type == curImprintType then
      log(bWriteLog and "AceImprintLogic.ConvertImprintIdByCycleYearId id:" .. tostring(id))
      return id
    end
  end
  return nil
end
return AceImprintLogic