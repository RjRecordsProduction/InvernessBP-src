local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameComponentData = require("GameLua.GameCore.Data.GameComponentData")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local version_util = require("client.common.version_util")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local GameGuideUIConfigSubsystem = {}
function GameGuideUIConfigSubsystem:ctor()
  self.GameGuideUIConfigTable = nil
  self.ConditionPickUpID = nil
  self.GuideTextID = 81134
  self.TipMaxShowTime = 5
  self.bIsBluehole = false
end
function GameGuideUIConfigSubsystem:OnInit()
  GameGuideUIConfigSubsystem.__super.OnInit(self)
  self:RegistEvents()
  self:InitConfig()
end
function GameGuideUIConfigSubsystem:OnRelease()
  GameGuideUIConfigSubsystem.__super.OnRelease(self)
  local PickUpTipsSubsystem = SubsystemMgr:Get("PickUpTipsSubsystem")
  if PickUpTipsSubsystem and self.ConditionPickUpID then
    PickUpTipsSubsystem:RemovePickUpTipsCondition(self.ConditionPickUpID)
    self.ConditionPickUpID = nil
  end
end
function GameGuideUIConfigSubsystem:RegistEvents()
  local PickUpTipsSubsystem = SubsystemMgr:Get("PickUpTipsSubsystem")
  if PickUpTipsSubsystem then
    self.ConditionPickUpID = PickUpTipsSubsystem:AddPickUpTipsCondition(self.ConditionDisplayPickUpTips, self)
  end
end
function GameGuideUIConfigSubsystem:ConditionDisplayPickUpTips(nItemID, sItemName)
  if self:CheckIsSpecialTips(nItemID) then
    local TipsValue = {
      duration = nil,
      InAnimation = "Anim_Tips_In",
      OutAnimation = "Anim_Tips_Out",
      AllShowUIWidget = {
        "Border_GameGuide"
      },
      AllHideUIWidget = {
        "ImageBorder"
      },
      TipsTextBlockStr = "TipsContent01",
      MinShowTime = self.TipMaxShowTime,
      OnTipsEnd = function()
        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
        if slua.isValid(MainControlBaseUI) then
          MainControlBaseUI:StartPickTipGuide(nItemID)
        end
      end
    }
    print(bWriteLog and "GameGuideUIConfigSubsystem:ConditionDisplayPickUpTips")
    IngameTipsTools.BattleNormalTipsByTextIDAndTipsValue(self.GuideTextID, sItemName, nil, nil, TipsValue)
    return false
  end
  return true
end
function GameGuideUIConfigSubsystem:CheckIsSpecialTips(nItemID)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerState = GameplayData.GetPlayerState()
  if not Game:IsValid(uPlayerState) then
    return false
  end
  local TlogIDFeature = uPlayerState.TlogIDFeature
  if not TlogIDFeature then
    print(bWriteLog and "GameGuideUIConfigSubsystem:CheckIsSpecialTips TlogIDFeature invalid")
    return false
  end
  if TlogIDFeature:CheckIsSpecialTips(nItemID) then
    return true
  end
  return false
end
function GameGuideUIConfigSubsystem:GetGameGuideConfig()
  if not self.GameGuideUIConfigTable then
    self:InitConfig()
  end
  if not self.GameGuideUIConfigTable then
    return
  end
  if self.GameGuideUIConfigTable.SubConfig then
    local ModeID = GameMainConfig.GetModeID()
    local GameGuideUITable = CDataTable.GetTableData("GameGuideUITable", ModeID)
    if GameGuideUITable then
      local Tag = GameGuideUITable.Tag
      if Tag then
        local SubConfig = self.GameGuideUIConfigTable.SubConfig[Tag]
        if SubConfig then
          return SubConfig
        end
      end
    end
  end
  local bHasItem = false
  for _, Config in pairs(self.GameGuideUIConfigTable.GameGuideConfig) do
    if Config then
      bHasItem = true
      break
    end
  end
  if not bHasItem then
    return nil
  end
  return self.GameGuideUIConfigTable.GameGuideConfig
end
function GameGuideUIConfigSubsystem:InitConfig()
  if not CGameState then
    return
  end
  if not slua.isValid(CGameState) then
    return
  end
  if self.GameGuideUIConfigTable then
    return
  end
  self.GameGuideUIConfigTable = {
    GameGuideConfig = {},
    SubConfig = {}
  }
  local GameGuideUIConfig = CDataTable.GetTable("GameGuideUIConfig")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() or self.bIsBluehole then
    GameGuideUIConfig = CDataTable.GetTable("GameGuideUIConfigBluehole")
  end
  if not GameGuideUIConfig then
    return
  end
  for _, Config in pairs(GameGuideUIConfig) do
    local bOpen = true
    if Config.TimeID_a and Config.TimeID_a:Num() > 0 then
      bOpen = false
      for _, TimeID in pairs(Config.TimeID_a) do
        if CGameState:HasTimeIDSwitch(TimeID) then
          bOpen = true
          break
        end
      end
    end
    if bOpen then
      for _, Tag in pairs(Config.Tag_as) do
        local OuterConfigTable
        if Tag == "Default" then
          OuterConfigTable = self.GameGuideUIConfigTable.GameGuideConfig
        else
          if not self.GameGuideUIConfigTable.SubConfig[Tag] then
            self.GameGuideUIConfigTable.SubConfig[Tag] = {}
          end
          OuterConfigTable = self.GameGuideUIConfigTable.SubConfig[Tag]
        end
        if not OuterConfigTable[Config.Classification] then
          OuterConfigTable[Config.Classification] = {}
        end
        local ClassificationTable = OuterConfigTable[Config.Classification]
        local ClassificationConfig = CDataTable.GetTableData("ClassificationPresets", Config.Classification)
        if ClassificationConfig then
          ClassificationTable.TitleTextID = ClassificationConfig.TitleTextID
          if not ClassificationTable.TabsConfig then
            ClassificationTable.TabsConfig = {}
          end
          local TabsConfig = ClassificationTable.TabsConfig
          local nVersionNum = version_util.ConvertVersionToNumber(Config.Version, 3)
          TabsConfig[Config.ID] = {
            TabName = Config.TabName,
            TabIcon = Config.TabIcon,
            Version = Config.Version,
            nVersionNum = nVersionNum,
            nPriority = Config.Priority,
            TabContents = {},
            nItemID = Config.Itemid,
            nTlogID = Config.Tlogid
          }
          local TabContents = TabsConfig[Config.ID].TabContents
          for _, TabContentIndex in pairs(Config.TabContents_a) do
            local TabContentConfig = CDataTable.GetTableData("TabContentConfig", TabContentIndex)
            if TabContentConfig then
              table.insert(TabContents, {
                ContentTextID = TabContentConfig.ContentTextID,
                ContentImage = TabContentConfig.ContentImage
              })
            end
          end
        end
      end
    end
  end
  local SortedSubConfig = {}
  for Tag, SubConfig in pairs(self.GameGuideUIConfigTable.SubConfig) do
    SortedSubConfig[Tag] = {}
    local SubConfigKeyTable = {}
    for Key, _ in pairs(SubConfig) do
      table.insert(SubConfigKeyTable, Key)
    end
    table.sort(SubConfigKeyTable)
    for _, TabsConfigUpper in pairs(SubConfig) do
      local SortedTabsConfig = {}
      if TabsConfigUpper.TabsConfig then
        for _, SortedValue in pairs(TabsConfigUpper.TabsConfig) do
          table.insert(SortedTabsConfig, SortedValue)
        end
      end
      table.sort(SortedTabsConfig, function(a, b)
        local aVersionNum = a.nVersionNum
        local bVersionNum = b.nVersionNum
        if aVersionNum == bVersionNum then
          return a.nPriority < b.nPriority
        end
        return aVersionNum > bVersionNum
      end)
      TabsConfigUpper.TabsConfig = SortedTabsConfig
    end
    for _, SortedKey in ipairs(SubConfigKeyTable) do
      table.insert(SortedSubConfig[Tag], SubConfig[SortedKey])
    end
  end
  self.GameGuideUIConfigTable.SubConfig = SortedSubConfig
end
local class = require("class")
local CSubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CSubsystemBase, nil, GameGuideUIConfigSubsystem)