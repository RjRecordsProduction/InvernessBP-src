local RankSmall_Sub_Base_UIBP = {}
local logic_rank_component = require("client.slua.umg.rankIntegral.logic.logic_rank_component")
function RankSmall_Sub_Base_UIBP:ctor(_, param_data)
  self:InitData(param_data)
end
function RankSmall_Sub_Base_UIBP:OnInitialize()
  self.bLoaded = true
end
function RankSmall_Sub_Base_UIBP:OnPostInitialize()
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:OnPostInitialize")
  self:UpdateUI()
end
function RankSmall_Sub_Base_UIBP:OnClose()
end
function RankSmall_Sub_Base_UIBP:SetSpecifiedStarNumText(starNum)
end
function RankSmall_Sub_Base_UIBP:PlayResultUIStarAnim()
end
function RankSmall_Sub_Base_UIBP:RefreshUI(param_data)
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:RefreshUI")
  self:InitData(param_data)
  if self.bLoaded then
    self:UpdateUI()
  end
end
function RankSmall_Sub_Base_UIBP:SetRankTextPrefix(prefixStr)
end
function RankSmall_Sub_Base_UIBP:InitData(param_data)
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:InitData")
  self.RankTextColor = param_data.RankTextColor
  self.RankTextShadowColor = param_data.RankTextShadowColor
  self.RankFontInfo = param_data.RankFontInfo
  self.type = param_data.type
  self.rankIntegral = param_data.rankIntegral
  self.textIntegralName = param_data.textIntegralName
  self.seasonId = param_data.seasonId
  self.segmentTitleId = param_data.segmentTitleId
  self.rating = param_data.rating
end
function RankSmall_Sub_Base_UIBP:UpdateUI()
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:UpdateUI")
  local RankIntegral_Config = require("client.slua.umg.rankIntegral.RankIntegral_Config")
  if self.type == RankIntegral_Config.ESetRankType.Rank then
    self:_SetRankIntegral()
  elseif self.type == RankIntegral_Config.ESetRankType.RankWithsSegmentTitle then
    self:SetRankInteralWithSegmentTitle()
  elseif self.type == RankIntegral_Config.ESetRankType.ArenaRank then
    self:_SetArenaRankInteral()
  elseif self.type == RankIntegral_Config.ESetRankType.XMission then
    self:_SetRankInteralInXMission()
  end
end
function RankSmall_Sub_Base_UIBP:_SetRankIntegral()
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:_SetRankIntegral")
  self:Collapsed()
  local rankIntegral = self.rankIntegral
  local seasonId = self.seasonId
  if not rankIntegral then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:_SetRankIntegral not rankIntegral")
    return
  end
  local rankCfg = FuncUtil.GetRankTableData(rankIntegral, seasonId)
  if not rankCfg then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankInteralCommon rankCfg is nil")
    return
  end
  self:SelfHitTestInvisible()
  self:SafeSetTexture(self.UIRoot.Image_Icon, rankCfg.SmallIcon)
  self:SafeSetText(self.UIRoot.TextBlock_Rank, rankCfg.Name)
  self:SafeSetRankFontStyle(self.UIRoot.TextBlock_Rank)
  self:SafeSetWidgetVisible(self.UIRoot.CanvasPanel_Star, false)
  if rankCfg.StarNum > 0 then
    self:SetRankStarShow(rankCfg)
  end
  self:SafeSetWidgetVisible(self.UIRoot.vx_Image_Quality, false)
  self:SafeSetWidgetVisible(self.UIRoot.Image_Quality, false)
end
function RankSmall_Sub_Base_UIBP:SetRankInteralWithSegmentTitle()
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankInteralWithSegmentTitle")
  local segment = self.rankIntegral
  local TextBlockRankName = self.textIntegralName
  local seasonId = self.seasonId
  local segmentTitleId = self.segmentTitleId
  local rating = self.rating
  if not segment then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankInteralWithSegmentTitle not segment")
    return
  end
  self:_SetRankIntegral()
  if rating and rating ~= 0 and segment == 801 then
    rating = math.floor(rating + 0.5 + FLOAT_NUMBER_TRAIL)
    local starNum = math.floor((rating - 4200) / 100) + 1
    starNum = math.max(0, starNum)
    self:SafeSetRankFontStyle(self.UIRoot.TextBlock_Star)
    self:SafeSetText(self.UIRoot.TextBlock_Star, starNum)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Star, true)
    local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
    local bigSegmentUpConfig = promotion_match_util.GetBigSementUpConfig(10)
    self:SafeSetTexture(self.UIRoot.Image_Star, bigSegmentUpConfig.SegStarIconPath)
  end
  if not logic_rank_component.IsSegmentTitleSwitchOpen() then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankInteralWithSegmentTitle not open")
    return
  end
  if not segmentTitleId or tonumber(segmentTitleId) == 0 then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankInteralWithSegmentTitle no segmentTitleId")
    return
  end
  local segTitleId = tonumber(segmentTitleId)
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankInteralWithSegmentTitle segmentTitleId is " .. tostring(segmentTitleId))
  local segCfg = FuncUtil.GetRankTableData(segment, seasonId)
  if not segCfg then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankInteralWithSegmentTitle segment config is nil")
    return
  end
  local segmentType = segCfg.IntegralTypeNew or 1
  local segmentTitleShowCfg = CDataTable.GetTableData("SegmentTitleShowConfig", segmentType)
  local segmentTitleCfg = CDataTable.GetTableData("SegmentTitleConfig", segTitleId)
  if not (segmentTitleCfg and segmentTitleShowCfg) or not segmentTitleShowCfg.IfShowSegmentTitle then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankInteralWithSegmentTitle no config or not show")
    return
  end
  if not segmentTitleCfg.IfDefaultTitle then
    local segmentTitleName = LocUtil.GetLocalizeResStr(segmentTitleCfg.TitleNameId) or ""
    local rankName = LocUtil.GetLocalizeResStr(segmentTitleShowCfg.IntegralTypeShowId) or ""
    local showStr = LocUtil.LocalizeResFormat(43635, rankName, segmentTitleName)
    if TextBlockRankName then
      TextBlockRankName:SetText(showStr or "")
    end
    self:SafeSetText(self.UIRoot.TextBlock_Rank, showStr or "")
    self:SafeSetRankFontStyle(self.UIRoot.TextBlock_Rank)
  end
  if segmentTitleShowCfg.BackgroundIconPath and segmentTitleShowCfg.BackgroundIconPath ~= "" then
    self:SafeSetTexture(self.UIRoot.Image_Quality, segmentTitleShowCfg.BackgroundIconPath)
    self:SafeSetWidgetVisible(self.UIRoot.Image_Quality, true, false)
    self:SetSegmentTitleBgEffect(self.UIRoot.vx_Image_Quality, segmentTitleShowCfg.BackgroundIconPath)
  else
    self:SafeSetWidgetVisible(self.UIRoot.Image_Quality, false, false)
  end
end
function RankSmall_Sub_Base_UIBP:SetSegmentTitleBgEffect(effectWidget, imagePath)
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetSegmentTitleBgEffect")
  if not effectWidget then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetSegmentTitleBgEffect not effectWidget")
    return
  end
  local asset_util = require("common.asset_util")
  asset_util.GetAssetAsync(imagePath, function(Asset)
    local mat = effectWidget:GetDynamicMaterial()
    if mat and slua.isValid(Asset) then
      mat:SetTextureParameterValue("MainTex", Asset)
      effectWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end)
end
function RankSmall_Sub_Base_UIBP:_SetArenaRankInteral()
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:_SetArenaRankInteral")
  self:Collapsed()
  local rankIntegral = self.rankIntegral
  if not rankIntegral then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:_SetArenaRankInteral not rankIntegral")
    return
  end
  local rankCfg = CDataTable.GetTableData("ArenaSegmentConfig", rankIntegral)
  if not rankCfg then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:_SetArenaRankInteral rankCfg is nil")
    return
  end
  self:SelfHitTestInvisible()
  self:SafeSetTexture(self.UIRoot.Image_Icon, rankCfg.SmallIcon)
  self:SafeSetText(self.UIRoot.TextBlock_Rank, rankCfg.SegmentName)
  self:SafeSetRankFontStyle(self.UIRoot.TextBlock_Rank)
  self:SafeSetWidgetVisible(self.UIRoot.CanvasPanel_Star, false)
  self:SafeSetWidgetVisible(self.UIRoot.vx_Image_Quality, false)
  self:SafeSetWidgetVisible(self.UIRoot.Image_Quality, false)
end
function RankSmall_Sub_Base_UIBP:_SetRankInteralInXMission()
  log(bWriteLog and "RankSmall_Sub_Base_UIBP:_SetRankInteralInXMission")
  local rankIntegral = self.rankIntegral
  self:Collapsed()
  local logic_TxMission_in_lobby = require("client.slua.logic.lobby.TxMission.logic_TxMission_in_lobby")
  local rankCfg = logic_TxMission_in_lobby.GetTPlanIconInLobby(rankIntegral)
  if not rankCfg then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:_SetRankInteralInXMission rankCfg is nil")
    return
  end
  self:SelfHitTestInvisible()
  self:SafeSetTexture(self.UIRoot.Image_Icon, rankCfg.SmallIcon)
  self:SafeSetText(self.UIRoot.TextBlock_Rank, rankCfg.Name)
  self:SafeSetRankFontStyle(self.UIRoot.TextBlock_Rank)
  self:SafeSetWidgetVisible(self.UIRoot.CanvasPanel_Star, false)
  self:SafeSetWidgetVisible(self.UIRoot.vx_Image_Quality, false)
  self:SafeSetWidgetVisible(self.UIRoot.Image_Quality, false)
end
function RankSmall_Sub_Base_UIBP:SetRankStarShow(segmentCfg)
  if not segmentCfg then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankStarShow no param")
    return
  end
  if not self.UIRoot.CanvasPanel_Star then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankStarShow star not show")
    return
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local segUpConfig = promotion_match_util.GetBigSementUpConfig(segmentCfg.IntegralTypeNew)
  if not (segUpConfig and segUpConfig.SegStarIconPath) or segUpConfig.SegStarIconPath == "" then
    log(bWriteLog and "RankSmall_Sub_Base_UIBP:SetRankStarShow no star to show")
    return
  end
  self:SafeSetWidgetVisible(self.UIRoot.CanvasPanel_Star, true)
  self:SafeSetText(self.UIRoot.TextBlock_Star, segmentCfg.StarNum)
  self:SafeSetTexture(self.UIRoot.Image_Star, segUpConfig.SegStarIconPath)
  self:SafeSetRankFontStyle(self.UIRoot.TextBlock_Star)
end
function RankSmall_Sub_Base_UIBP:SafeSetRankFontStyle(textWidget)
  if not textWidget then
    return
  end
  if self.RankTextColor then
    textWidget:SetColorAndOpacity(self.RankTextColor)
  end
  if self.RankTextShadowColor and self.RankTextShadowColor.SpecifiedColor then
    textWidget:SetShadowColorAndOpacity(self.RankTextShadowColor.SpecifiedColor)
  end
  if self.RankFontInfo then
    textWidget:SetFont(self.RankFontInfo)
  end
end
function RankSmall_Sub_Base_UIBP:SafeSetTexture(widget, path)
  if not widget then
    return
  end
  if not path or path == "" then
    return
  end
  self:SetTexture(widget, path)
end
function RankSmall_Sub_Base_UIBP:SafeSetText(widget, textMsg)
  if not widget then
    return
  end
  widget:SetText(textMsg or "")
end
function RankSmall_Sub_Base_UIBP:SafeSetWidgetVisible(widget, visible, isButton)
  if not widget then
    return
  end
  self:SetWidgetVisible(widget, visible, isButton)
end
function RankSmall_Sub_Base_UIBP:SafeSetRankNameVisible(bVisible)
  self:SafeSetWidgetVisible(self.UIRoot.TextBlock_Rank, bVisible)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CRankSmall_Sub_Base_UIBP = class(ui_base, nil, RankSmall_Sub_Base_UIBP)
return CRankSmall_Sub_Base_UIBP