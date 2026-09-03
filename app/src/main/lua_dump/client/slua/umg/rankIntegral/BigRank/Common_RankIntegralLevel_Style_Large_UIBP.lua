local Common_RankIntegralLevel_Style_Large_UIBP = {}
function Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteral(rankIntegral, textIntegralName)
  log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteral")
  if not rankIntegral then
    log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteral not rankIntegral")
    return
  end
  local rankCfg = FuncUtil.GetRankTableData(rankIntegral, 0)
  if not rankCfg then
    log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteral rankCfg is nil")
    return
  end
  local uiUtil = require("client.slua_ui_framework.util")
  uiUtil.SetTexture(self.Image_Base, rankCfg.BigIcon)
  if rankCfg.SubIcon and rankCfg.SubIcon ~= "" then
    self.Image_Level_S20:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    uiUtil.SetTexture(self.Image_Level_S20, rankCfg.SubIcon)
  else
    self.Image_Level_S20:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.Image_Level:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if textIntegralName then
    textIntegralName:SetText(rankCfg.Name)
  end
end
function Common_RankIntegralLevel_Style_Large_UIBP:SetMetroRank(rankIntegral)
  log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetMetroRank")
  local logic_TxMission_in_lobby = require("client.slua.logic.lobby.TxMission.logic_TxMission_in_lobby")
  local rankCfg = logic_TxMission_in_lobby.GetTPlanIconInLobby(rankIntegral)
  if not rankCfg then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:_SetRankInteralInXMission rankCfg is nil")
    return
  end
  local DefaultIcon = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/RanklntegralLevel_M_01.RanklntegralLevel_M_01"
  local asset_util = require("common.asset_util")
  local Texture = asset_util.GetAssetSync(rankCfg.BigIcon)
  log_format(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetMetroRank rankCfg.BigIcon: %s, Texture = %s", rankCfg.BigIcon, tostring(Texture))
  if Texture then
    self.Image_Base:SetBrushFromTexture(Texture, false)
  else
    self:SetTexture(self.Image_Base, DefaultIcon)
  end
  if rankCfg.SubIcon and rankCfg.SubIcon ~= "" then
    local SubTexture = asset_util.GetAssetSync(rankCfg.SubIcon)
    if SubTexture then
      self:SetWidgetVisible(self.Image_Level_S20, true, false)
      self.Image_Level_S20:SetBrushFromTexture(SubTexture, false)
    else
      self:SetWidgetVisible(self.Image_Level_S20, false, false)
    end
  else
    self:SetWidgetVisible(self.Image_Level_S20, false, false)
  end
end
function Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteralBySeason(rankIntegral, textIntegralName, seasonId)
  log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteralBySeason")
  if not rankIntegral then
    log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteralBySeason not rankIntegral")
    return
  end
  local rankCfg = FuncUtil.GetRankTableData(rankIntegral, seasonId)
  if not rankCfg then
    log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteralBySeason rankCfg is nil")
    return
  end
  local uiUtil = require("client.slua_ui_framework.util")
  uiUtil.SetTexture(self.Image_Base, rankCfg.BigIcon)
  if rankCfg.SubIcon and rankCfg.SubIcon ~= "" then
    self.Image_Level_S20:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    uiUtil.SetTexture(self.Image_Level_S20, rankCfg.SubIcon)
  else
    self.Image_Level_S20:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.Image_Level:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if textIntegralName then
    textIntegralName:SetText(rankCfg.Name)
  end
end
function Common_RankIntegralLevel_Style_Large_UIBP:SetArenaRankInteral(rankIntegral, textIntegralName)
  log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetArenaRankInteral")
  if not rankIntegral then
    log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetArenaRankInteral not rankIntegral")
    return
  end
  local rankCfg = CDataTable.GetTableData("ArenaSegmentConfig", rankIntegral)
  if not rankCfg then
    log(bWriteLog and "Common_RankIntegralLevel_Style_Large_UIBP:SetArenaRankInteral rankCfg is nil")
    return
  end
  local uiUtil = require("client.slua_ui_framework.util")
  uiUtil.SetTexture(self.Image_Base, rankCfg.BigIcon)
  if rankCfg.SubIcon and rankCfg.SubIcon ~= "" then
    self.Image_Level:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    uiUtil.SetTexture(self.Image_Level, rankCfg.SubIcon)
  else
    self.Image_Level:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.Image_Level_S20:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if textIntegralName then
    textIntegralName:SetText(rankCfg.SegmentName)
  end
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Common_RankIntegralLevel_Style_Large_UIBP)