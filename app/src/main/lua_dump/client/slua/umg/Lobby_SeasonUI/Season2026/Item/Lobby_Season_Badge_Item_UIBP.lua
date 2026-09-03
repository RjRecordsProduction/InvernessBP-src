local Lobby_Season_Badge_Item_UIBP = {}
local season_year_config = require("client.logic.season_year.config.season_year_config")
local BadgeTable = {
  [season_year_config.EBadgePartType.Gem] = {
    WidgetName = {
      "Canvas_GemCrown"
    },
    LevelPanel = "Panel_GemCrown",
    EffAnimationNameList = {
      "AnimGemUpgradeL1",
      "AnimGemUpgradeL2",
      "AnimGemUpgradeL3"
    }
  },
  [season_year_config.EBadgePartType.Base] = {
    WidgetName = {
      "Canvas_Base"
    },
    LevelPanel = "Panel_Base",
    EffAnimationNameList = {
      "AnimBaseUpgradeL1",
      "AnimBaseUpgradeL2",
      "AnimBaseUpgradeL3"
    }
  },
  [season_year_config.EBadgePartType.Glow] = {
    WidgetName = {
      "Canvas_Glow",
      "Canvas_Lingtting",
      "Canvas_Wings"
    },
    EffAnimationNameList = {
      "AnimGlowActivateL1",
      "AnimGlowActivateL2",
      "AnimGlowActivateL3"
    }
  },
  [season_year_config.EBadgePartType.Crown] = {
    WidgetName = {"Canvas_Gem"}
  }
}
function Lobby_Season_Badge_Item_UIBP:ctor(_, badgeData, extraParam)
  self.  if extraParam then
    self.aceAniLevel = extraParam.aceAniLevel
    self.btnClick = extraParam.btnClick
  end
end
function Lobby_Season_Badge_Item_UIBP:OnPostInitialize()
  Lobby_Season_Badge_Item_UIBP.__super.OnPostInitialize(self)
  self.btnClick = self.btnClick or false
  self:SetButtonRouleteeVisible(self.btnClick)
  if self.UIRoot.Border_0 then
    self.UIRoot.Border_0:SetContentColorAndOpacity(FLinearColor(1, 1, 1, 1))
  end
  self:SetBadgeInfo(self.badgeData, true)
  self:PlayAceAction(self.aceAniLevel)
end
function Lobby_Season_Badge_Item_UIBP:OnClose()
  if self.aceAniLevel and self.aceAniLevel > 0 then
    self:StopAnimation("AceImprintAnimation" .. tostring(self.aceAniLevel))
  end
end
function Lobby_Season_Badge_Item_UIBP:SetButtonRouleteeVisible(visible)
  self:SetWidgetVisible(self.UIRoot.Button_Rouletee, true, visible)
end
function Lobby_Season_Badge_Item_UIBP:PlayAceAction(level)
  log(bWriteLog and "Lobby_Season_Badge_Item_UIBP:PlayAceAction level:" .. tostring(level))
  if level and 0 < level then
    self.aceAniLevel = level
    self:SetButtonRouleteeVisible(false)
    self:PlayUserWidgetAnimation(self.UIRoot["AceImprintAnimation" .. tostring(level)], 0, 1, 0, 1)
  end
end
function Lobby_Season_Badge_Item_UIBP:SetBadgeInfo(badgeData, bPlayLevelUpAni)
  log(bWriteLog and "Lobby_Season_Badge_Item_UIBP:SetBadgeInfo")
  badgeData = badgeData or {}
  if bPlayLevelUpAni == nil then
    bPlayLevelUpAni = true
  end
  local EBadgePartType = season_year_config.EBadgePartType
  self:SetBadgeGemInfo(badgeData[EBadgePartType.Crown], nil)
  local level = 0
  if badgeData[EBadgePartType.Gem] then
    for _, task_info in pairs(badgeData[EBadgePartType.Gem]) do
      level = task_info.finish_count
      break
    end
  end
  self:PlayBadgePartLevelUpAnimation(EBadgePartType.Gem, level, bPlayLevelUpAni)
  level = 0
  if badgeData[EBadgePartType.Base] then
    for _, task_info in pairs(badgeData[EBadgePartType.Base]) do
      level = task_info.finish_count
      break
    end
  end
  self:PlayBadgePartLevelUpAnimation(EBadgePartType.Base, level, bPlayLevelUpAni)
  level = 0
  if badgeData[EBadgePartType.Glow] then
    for _, task_info in pairs(badgeData[EBadgePartType.Glow]) do
      level = level + (0 < task_info.finish_count and 1 or 0)
    end
  end
  self:PlayBadgePartLevelUpAnimation(EBadgePartType.Glow, level, true)
end
function Lobby_Season_Badge_Item_UIBP:SetBadgeGemInfo(gemData, newActiveGemData)
  log(bWriteLog and "Lobby_Season_Badge_Item_UIBP:SetBadgeGemInfo")
  log_tree(bWriteLog and "Lobby_Season_Badge_Item_UIBP:SetBadgeGemInfo gemData = ", gemData)
  log_tree(bWriteLog and "Lobby_Season_Badge_Item_UIBP:SetBadgeGemInfo newActiveGemData = ", newActiveGemData)
  gemData = gemData or {}
  local infoTb = {}
  for task_id, task_info in pairs(gemData) do
    table.insert(infoTb, {task_id = task_id})
  end
  table.sort(infoTb, function(a, b)
    return a.task_id < b.task_id
  end)
  local season_year_badge_util = require("client.logic.season_year.util.season_year_badge_util")
  local badge_part_cfg = season_year_badge_util.GetCurSeasonYearBadgePartCfgInfo(season_year_config.EBadgePartType.Crown)
  if badge_part_cfg == nil then
    log(bWriteLog and "Lobby_Season_Badge_Item_UIBP:SetBadgeGemInfo: badge_part_cfg is nil")
    return
  end
  for idx, cfgInfo in ipairs(badge_part_cfg) do
    local gemWidget = self.UIRoot["CompGem" .. string.format("%02d", idx)]
    if gemWidget then
      if newActiveGemData and newActiveGemData[cfgInfo.task_id] and newActiveGemData[cfgInfo.task_id].progress_id > newActiveGemData[cfgInfo.task_id].old_progress_id and newActiveGemData[cfgInfo.task_id].old_progress_id < cfgInfo.task_stage_id and newActiveGemData[cfgInfo.task_id].progress_id >= cfgInfo.task_stage_id then
        if gemWidget.Image_bright then
          gemWidget.Image_bright:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
        gemWidget:PlayUserWidgetAnimation(gemWidget.AnimRingStarL1, 0, 1, 0, 1)
      elseif gemData and gemData[cfgInfo.task_id] and gemData[cfgInfo.task_id].finish_count >= cfgInfo.task_stage_id then
        if gemWidget.Image_bright then
          gemWidget.Image_bright:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
        gemWidget:PlayUserWidgetAnimation(gemWidget.AnimRingStarC1, 0, 1, 0, 1)
      else
        if gemWidget.Image_bright then
          gemWidget.Image_bright:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
        if gemWidget.Image_grey then
          gemWidget.Image_grey:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
        end
      end
    end
  end
end
function Lobby_Season_Badge_Item_UIBP:PlayBadgePartLevelUpAnimation(partType, level, bPlayAnimation)
  log(bWriteLog and "Lobby_Season_Badge_Item_UIBP:PlayBadgePartLevelUpAnimation partType = ", partType, " level = ", level, " bPlayAnimation =", bPlayAnimation)
  if bPlayAnimation == nil then
    bPlayAnimation = true
  end
  if BadgeTable[partType].LevelPanel then
    for lv = 0, 3 do
      local levelPanelName = BadgeTable[partType].LevelPanel .. tostring(lv)
      if self.UIRoot[levelPanelName] then
        self.UIRoot[levelPanelName]:SetVisibility(lv == level and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
  if BadgeTable[partType].EffAnimationNameList then
    for _, aniName in pairs(BadgeTable[partType].EffAnimationNameList) do
      self:StopAnimation(aniName)
    end
  end
  if BadgeTable[partType].EffAnimationNameList and BadgeTable[partType].EffAnimationNameList[level] then
    local aniName = BadgeTable[partType].EffAnimationNameList[level]
    local startAtTime = self:GetAnimationDuration(aniName) or 0
    if bPlayAnimation then
      startAtTime = 0
    end
    self:PlayUserWidgetAnimation(self.UIRoot[aniName], startAtTime, 1, 0, 1)
  end
end
function Lobby_Season_Badge_Item_UIBP:ShowBadgeSinglePart(partType)
  log("Lobby_Season_Badge_Item_UIBP:ShowBadgeSinglePart ", partType)
  for part_type, partData in pairs(BadgeTable) do
    local visibility = part_type == partType and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed
    for _, widgetName in pairs(partData.WidgetName) do
      self.UIRoot[widgetName]:SetVisibility(visibility)
    end
  end
end
function Lobby_Season_Badge_Item_UIBP:ShowBadgePartLight(partType)
  log("Lobby_Season_Badge_Item_UIBP:ShowBadgeShowBadgePartLightSinglePart ", partType)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_Season_Badge_Item_UIBP)