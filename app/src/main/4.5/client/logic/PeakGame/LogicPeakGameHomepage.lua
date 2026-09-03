local LogicPeakGameHomepage = {}
function LogicPeakGameHomepage:DefineAndResetData()
  self.EnumRuleContentType = {
    TEXT = 1,
    SUBITEM = 2,
    PICTURE = 3
  }
end
function LogicPeakGameHomepage:OnInitialize()
  LogicPeakGameHomepage.__super.OnInitialize(self)
end
function LogicPeakGameHomepage:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PEAKGAME_HOMEPAGE, self.JumpUrl, self)
end
function LogicPeakGameHomepage:JumpUrl()
  log(bWriteLog and "LogicPeakGameHomepage:JumpUrl")
  self:ShowPeakGameHomepage()
end
function LogicPeakGameHomepage:ShowPeakGameHomepage()
  log(bWriteLog and "LogicPeakGameHomepage:ShowPeakGameHomepage")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHomepage:ShowPeakGameHomepage not open")
    return
  end
  local logic_season_util = require("client.logic.season.logic_season_util")
  logic_season_util.CheckModWithFunc(function()
    local logic_season_const = require("client.logic.season.logic_season_const")
    local DefaultSeasonType = logic_season_const.ESeasonType.Classic
    UIManager.ShowUI(UIManager.UI_Config.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP, logic_season_const.ESeasonType.PeakGame)
  end)
end
function LogicPeakGameHomepage:RequestHomepageShowData()
  log(bWriteLog and "LogicPeakGameHomepage:RequestHomepageShowData")
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:ReqPeakGameTimeInfo(true)
  LogicPeakGame:ReqPeakGameInfo(false)
  LogicPeakGame:ReqPeakGameAllRatingInfo(false)
  local LogicPeakGameReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameReward)
  LogicPeakGameReward:ReqPeakGameSeasonInfo()
  LogicPeakGameReward:ReqPeakTierRewardList()
end
function LogicPeakGameHomepage:GetPeakGameRules(type, title)
  log(bWriteLog and "LogicPeakGameHomepage:GetPeakGameRules type = " .. tostring(type) .. " title = " .. tostring(title))
  local rulesConfig = CDataTable.GetTableByFilter("PeakGameRulesConfig", "Type", type)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bBlueHoleVersion = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  log(bWriteLog and "LogicPeakGameHomepage:GetPeakGameRules bBlueHoleVersion = " .. tostring(bBlueHoleVersion))
  local showRuleList = {}
  for _, tabConfig in pairs(rulesConfig) do
    local blueHoleBlock = tabConfig.BlueHoleBlock
    if blueHoleBlock and blueHoleBlock == 1 and bBlueHoleVersion then
    else
      local infoTab = self:ConstructOneRuleTabShowTable(tabConfig, title)
      if infoTab and infoTab.tab then
        table.insert(showRuleList, infoTab)
      end
    end
  end
  table.sort(showRuleList, function(a, b)
    return a.ruleSortPriority < b.ruleSortPriority
  end)
  return showRuleList
end
function LogicPeakGameHomepage:ConstructOneRuleTabShowTable(tabConfig, title)
  if not tabConfig then
    log(bWriteLog and "LogicPeakGameHomepage ConstructOneRuleTabShowTable no config")
    return nil
  end
  local tabContentTypeList = tabConfig.TabContentType_a
  if not tabContentTypeList or tabContentTypeList:Num() <= 0 then
    log(bWriteLog and "LogicPeakGameHomepage ConstructOneRuleTabShowTable tabContentTypeList is invalid")
    return nil
  end
  if tabConfig.TabTextId == 68547 then
    local season_id = DataMgr.season_id
    log(bWriteLog and "LogicPeakGameHomepage:ConstructOneRuleTabShowTable season_id = " .. tostring(season_id))
    if season_id < 41 then
      return nil
    end
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bBlueHoleVersion = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  log(bWriteLog and "LogicPeakGameHomepage:ConstructOneRuleTabShowTable bBlueHoleVersion = " .. tostring(bBlueHoleVersion))
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local select_zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  local contentList = {}
  local E_StyleType = require("client.slua.umg.common.questionmark.questionmark_style_cfg").E_StyleType
  for i = 0, tabContentTypeList:Num() - 1 do
    local contentType = tabContentTypeList:Get(i)
    if contentType then
      if contentType == self.EnumRuleContentType.TEXT then
        local tabContentId = tabConfig.TabContentId
        if tabConfig.TabTextId == 68206 and (bBlueHoleVersion or select_zone_id == 6) then
          log(bWriteLog and "LogicPeakGameHomepage:ConstructOneRuleTabShowTable refresh id")
          tabContentId = 68512
        end
        local tabContentIdForChallengeTarget = self:_GetPeakGameRulesTabContentIdForChallengeTarget(tabConfig)
        if tabContentIdForChallengeTarget then
          tabContentId = tabContentIdForChallengeTarget
        end
        local tabContentIdForTeamRequirement = self:_GetPeakGameRulesTabContentIdForTeamRequirement(tabConfig)
        if tabContentIdForTeamRequirement then
          tabContentId = tabContentIdForTeamRequirement
        end
        if tabContentId and tonumber(tabContentId) then
          table.insert(contentList, {
            type = E_StyleType.TEXT,
            content1 = LocUtil.GetLocalizeStrConcatenation(tonumber(tabContentId))
          })
        end
      elseif contentType == self.EnumRuleContentType.SUBITEM then
        local chartBlueprintPath = tabConfig.ChartBlueprintPath
        if tabConfig.TabTextId == 68238 then
          local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
          local peakgame_change_rank_rule_info = LogicPeakGame:GetChangeRankRuleInfo()
          if peakgame_change_rank_rule_info and peakgame_change_rank_rule_info.change_day_ts then
            local TimeUtil = require("client.common.time_util")
            local nowTime = TimeUtil.GetServerTimeInSec()
            if nowTime < peakgame_change_rank_rule_info.change_day_ts then
              chartBlueprintPath = "Lobby_PeakGame_Rank_Chart_Default_UIBP"
            end
          end
        end
        if chartBlueprintPath and chartBlueprintPath ~= "" then
          table.insert(contentList, {
            type = E_StyleType.SUBITEM,
            content1 = chartBlueprintPath
          })
        end
      elseif contentType == self.EnumRuleContentType.PICTURE then
        local picturePath = tabConfig.PicturePath
        if picturePath and picturePath ~= "" then
          table.insert(contentList, {
            type = E_StyleType.PICTURE,
            content1 = picturePath
          })
        end
      end
    end
  end
  local infoTab = {
    tab = LocUtil.GetLocalizeResStr(tabConfig.TabTextId),
    title = LocUtil.GetLocalizeResStr(title),
    textInfo = contentList,
    ruleSortPriority = tabConfig.Priority or 0
  }
  return infoTab
end
function LogicPeakGameHomepage:_GetPeakGameRulesTabContentIdForChallengeTarget(tabConfig)
  local tabContentId
  if tabConfig.TabTextId == 85267 then
    local season_id = DataMgr.season_id
    log(bWriteLog and "LogicPeakGameHomepage:_GetPeakGameRulesTabContentIdForChallengeTarget season_id = " .. tostring(season_id))
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local bBlueHoleVersion = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
    log(bWriteLog and "LogicPeakGameHomepage:_GetPeakGameRulesTabContentIdForChallengeTarget bBlueHoleVersion = " .. tostring(bBlueHoleVersion))
    if bBlueHoleVersion then
      if 47 <= season_id then
        tabContentId = 85391
      else
        tabContentId = 85276
      end
    elseif 48 <= season_id then
      tabContentId = 85391
    else
      tabContentId = 85276
    end
  end
  return tabContentId
end
function LogicPeakGameHomepage:_GetPeakGameRulesTabContentIdForTeamRequirement(tabConfig)
  local tabContentId
  if tabConfig.TabTextId == 85293 then
    local season_id = DataMgr.season_id
    log(bWriteLog and "LogicPeakGameHomepage:_GetPeakGameRulesTabContentIdForTeamRequirement season_id = " .. tostring(season_id))
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local bBlueHoleVersion = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
    log(bWriteLog and "LogicPeakGameHomepage:_GetPeakGameRulesTabContentIdForTeamRequirement bBlueHoleVersion = " .. tostring(bBlueHoleVersion))
    if bBlueHoleVersion then
      if 47 <= season_id then
        tabContentId = 85398
      else
        tabContentId = 85298
      end
    elseif 48 <= season_id then
      tabContentId = 85398
    else
      tabContentId = 85298
    end
  end
  return tabContentId
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicPeakGameHomepage = class(CModuleBase, nil, LogicPeakGameHomepage)
return CLogicPeakGameHomepage