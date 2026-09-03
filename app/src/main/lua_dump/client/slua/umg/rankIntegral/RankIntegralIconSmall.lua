local RankIntegralIconSmall = {}
function RankIntegralIconSmall:OnClose()
  self:_ResetParam()
end
function RankIntegralIconSmall:_CreateSubItem(type)
  log(bWriteLog and "RankIntegralIconSmall:_CreateSubItem")
  local param_data = {
    type = type,
    RankTextColor = self.RankTextColor,
    RankTextShadowColor = self.RankTextShadowColor,
    RankFontInfo = self.RankFontInfo,
    rankIntegral = self.rankIntegral,
    textIntegralName = self.textIntegralName,
    seasonId = self.seasonId,
    segmentTitleId = self.segmentTitleId,
    rating = self.rating
  }
  if self.subItemUI then
    log(bWriteLog and "RankIntegralIconSmall:_CreateSubItem self.subItemUI is exist")
    self.subItemUI:RefreshUI(param_data)
    return
  end
  local RankIntegral_Config = require("client.slua.umg.rankIntegral.RankIntegral_Config")
  local BPTypeToUIConfigMap = RankIntegral_Config.BPTypeToUIConfigMap
  local ui_config = BPTypeToUIConfigMap[self.RankIntegralType]
  if ui_config then
    self.subItemUI = self:CreateChildWindow(self.Root, ui_config, param_data)
    self.subItemUI:SetAutoSize(true)
  end
end
function RankIntegralIconSmall:_ResetParam()
  self.rankIntegral = nil
  self.textIntegralName = nil
  self.seasonId = nil
  self.segmentTitleId = nil
  self.rating = nil
  self.subItemUI = nil
end
function RankIntegralIconSmall:SetRankInteral(rankIntegral, textIntegralName)
  log(bWriteLog and "RankIntegralIconSmall:SetRankInteral rankIntegral = " .. tostring(rankIntegral) .. " textIntegralName = " .. tostring(textIntegralName))
  self:SetRankInteralCommon(rankIntegral, textIntegralName, 0)
end
function RankIntegralIconSmall:SetRankCustomColor(rankIntegral, textIntegralName, color, seasonId)
  log(bWriteLog and "RankIntegralIconSmall:SetRankCustomColor rankIntegral = " .. tostring(rankIntegral) .. " textIntegralName = " .. tostring(textIntegralName) .. " seasonId = " .. tostring(seasonId) .. " color = " .. tostring(color))
  if color then
    self.RankTextColor = color
  end
  self:SetRankInteralCommon(rankIntegral, textIntegralName, 0)
end
function RankIntegralIconSmall:SetRankInteralBySeason(rankIntegral, textIntegralName, seasonId)
  log(bWriteLog and "RankIntegralIconSmall:SetRankInteralBySeason rankIntegral = " .. tostring(rankIntegral) .. " textIntegralName = " .. tostring(textIntegralName) .. " seasonId = " .. tostring(seasonId))
  self:SetRankInteralCommon(rankIntegral, textIntegralName, seasonId)
end
function RankIntegralIconSmall:SetRankInteralCommon(rankIntegral, textIntegralName, seasonId)
  log(bWriteLog and "RankIntegralIconSmall:SetRankInteralCommon rankIntegral = " .. tostring(rankIntegral) .. " textIntegralName = " .. tostring(textIntegralName) .. " seasonId = " .. tostring(seasonId))
  self.  self.  self.  local RankIntegral_Config = require("client.slua.umg.rankIntegral.RankIntegral_Config")
  self:_CreateSubItem(RankIntegral_Config.ESetRankType.Rank)
end
function RankIntegralIconSmall:SetRankInteralWithSegmentTitle(segment, TextBlockRankName, seasonId, segmentTitleId, rating)
  log(bWriteLog and "RankIntegralIconSmall:SetRankInteralWithSegmentTitle")
  self.rankIntegral = segment
  self.textIntegralName = TextBlockRankName
  self.  self.  self.  local RankIntegral_Config = require("client.slua.umg.rankIntegral.RankIntegral_Config")
  self:_CreateSubItem(RankIntegral_Config.ESetRankType.RankWithsSegmentTitle)
end
function RankIntegralIconSmall:SetRankCustomColorWithSegmentTitle(segment, TextBlockRankName, rankTextColor, seasonId, segmentTitleId, rating)
  log(bWriteLog and "RankIntegralIconSmall:SetRankCustomColorWithSegmentTitle")
  if rankTextColor then
    self.RankTextColor = rankTextColor
  end
  self:SetRankInteralWithSegmentTitle(segment, TextBlockRankName, seasonId, segmentTitleId, rating)
end
function RankIntegralIconSmall:SetArenaRankInteral(rankIntegral, textIntegralName)
  log(bWriteLog and "RankIntegralIconSmall:SetArenaRankInteral rankIntegral = " .. tostring(rankIntegral) .. " textIntegralName = " .. tostring(textIntegralName))
  self.  self.  local RankIntegral_Config = require("client.slua.umg.rankIntegral.RankIntegral_Config")
  self:_CreateSubItem(RankIntegral_Config.ESetRankType.ArenaRank)
end
function RankIntegralIconSmall:SetArenaRankInteralWithCustomColor(rankIntegral, textIntegralName, color)
  self.  self.  if color then
    self.RankTextColor = color
  end
  self:SetArenaRankInteral(rankIntegral, textIntegralName)
end
function RankIntegralIconSmall:SetRankInteralInXMission(rankIntegral, textIntegralName)
  log(bWriteLog and "RankIntegralIconSmall:SetRankInteralInXMission rankIntegral = " .. tostring(rankIntegral) .. " textIntegralName = " .. tostring(textIntegralName))
  self.  self.  local RankIntegral_Config = require("client.slua.umg.rankIntegral.RankIntegral_Config")
  self:_CreateSubItem(RankIntegral_Config.ESetRankType.XMission)
end
function RankIntegralIconSmall:SetSpecifiedStarNumText(starNum)
  if self.subItemUI then
    self.subItemUI:SetSpecifiedStarNumText(starNum)
  end
end
function RankIntegralIconSmall:PlayResultUIStarAnim()
  if self.subItemUI then
    self.subItemUI:PlayResultUIStarAnim()
  end
end
function RankIntegralIconSmall:SetRankTextPrefix(prefixStr)
  if self.subItemUI then
    self.subItemUI:SetRankTextPrefix(prefixStr)
  end
end
function RankIntegralIconSmall:ChangeRankInteralColor(color)
  log(bWriteLog and "RankIntegralIconSmall:ChangeRankInteralColor")
  if color then
    self.RankTextColor = color
  end
  if not self.subItemUI then
    return
  end
  local RankIntegral_Config = require("client.slua.umg.rankIntegral.RankIntegral_Config")
  self:_CreateSubItem(RankIntegral_Config.ESetRankType.RankWithsSegmentTitle)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, RankIntegralIconSmall)