local UGC_Assistant_Define = {}
UGC_Assistant_Define.AssistantTabType = {
  None = -1,
  Assistant = 0,
  GuideEntrance = 999
}
local AssistantTabConfigDefine = {
  TabType = UGC_Assistant_Define.AssistantTabType.None,
  SubUIKey = "",
  Title = "",
  Condition = function()
    return true
  end,
  GetRedDotDataHandle = nil,
  EnterTabHideRedDot = false,
  CanDefaultSelect = nil,
  EnterTabHandle = nil,
  ExitTabHandle = nil
}
function UGC_Assistant_Define.CheckAssistantAvaliable(bAgeGateCheckParam)
  if IsEditor then
    return true
  end
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if LogicUGCAuthor:GetCopilotState() then
    return true
  end
  local bHornSwitch = LobbySystem.CheckOpen(BP_ENUM_WOW_AI_COPILOT_SWITCH)
  if not bHornSwitch then
    log(bWriteLog and "UGC_Assistant_Define.CheckAssistantAvaliable!!!!switch OFF!!!")
    return false
  end
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  log(bWriteLog and string.format("Logic_UGC_Copilot:CheckWoWCopilotDisplay bWoWCopilotDisplay = %s", tostring(LogicSettingBasic.bWoWCopilotDisplay)))
  if not LogicSettingBasic.bWoWCopilotDisplay then
    return false
  end
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local logic_AIChat_Adult = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_AIChat_Adult)
  logic_AIChat_Adult:CallAgegateSDK()
  if not logic_AIChat_Adult:CheckAgeGateForUGCAssistant(bAgeGateCheckParam) and region ~= PublishRegionMacros.CE then
    log(bWriteLog and "UGC_Assistant_Define.AgeGate()!!!! IsWoWEditor")
    if not IsWoWEditor then
      log(bWriteLog and "UGC_Assistant_Define.AgeGate()!!!!out!!!")
      return false
    end
  end
  local ModuleManager = require("client.module_framework.ModuleManager")
  local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  if Logic_UGC_Copilot.NetworkProtocolFeature:GetInterfaceVersion() == 1 then
    local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
    if WardrobeData:GetHallDepotItemDataByResID(AiCopilotLimtItemId) then
      log(bWriteLog and "UGC_Assistant_Define.CheckAssistantAvaliable!!!!white list")
      return true
    end
    local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
    if regionGroupConfig then
      log(bWriteLog and "UGC_Assistant_Define.CheckAssistantAvaliable!!!! regionGroupConfig = " .. tostring(regionGroupConfig.Region))
    end
    if not regionGroupConfig or regionGroupConfig.WOWAICopilotSwitch == 0 then
      log(bWriteLog and "UGC_Assistant_Define.CheckAssistantAvaliable!!!!WOWAICopilotSwitch == 0")
      return false
    end
    local cfgLevelOs = tonumber(CDataTable.GetTableData("SystemConfig", "WOW_AI_Helper_Switch_Level").ConfigValue)
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    local level = LogicUGCAuthor:GetMineAuthorLevel() or 1
    if cfgLevelOs > level then
      log(bWriteLog and "UGC_Assistant_Define.level()!!!!out!!!" .. tostring(cfgLevelOs) .. "--" .. tostring(level))
      return false
    end
    local cfgLanguageOs = CDataTable.GetTableData("SystemConfig", "WOW_AI_Helper_Language").ConfigValue
    local LanguageType = {}
    for word in string.gmatch(cfgLanguageOs, "\"([^\"]+)\"") do
      table.insert(LanguageType, word)
    end
    local isTargetLanguage = false
    local Language = Client.GetCurrentLanguage()
    for k, word in pairs(LanguageType) do
      if Language == word then
        isTargetLanguage = true
      end
    end
    if not isTargetLanguage then
      log(bWriteLog and "UGC_Assistant_Define.CheckAssistantAvaliable! is not TargetLanguage currLanguage = " .. tostring(Language))
      return false
    end
  end
  log(bWriteLog and "UGC_Assistant_Define. final return true")
  return true
end
UGC_Assistant_Define.AssistantTabConfig = {
  [UGC_Assistant_Define.AssistantTabType.Assistant] = {
    TabType = UGC_Assistant_Define.AssistantTabType.Assistant,
    SubUIKey = "UGC_Assistant_Copilot_Sub_UIBP",
    Title = 8801009,
    Condition = function(...)
      return UGC_Assistant_Define.CheckAssistantAvaliable(...)
    end,
    GetRedDotDataHandle = function()
      local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
      return UGCCenterRedDotData.GetAiCopilotRedDotData()
    end,
    EnterTabHideRedDot = true,
    CanDefaultSelect = function()
      return UGC_Assistant_Define.CheckAssistantAvaliable()
    end
  },
  [UGC_Assistant_Define.AssistantTabType.GuideEntrance] = {
    TabType = UGC_Assistant_Define.AssistantTabType.GuideEntrance,
    SubUIKey = "UGC_Assistant_GuideEntrance_Sub_UIBP",
    Title = 8801010,
    Condition = function()
      if GameStatus and GameStatus.IsInFightingNotMainCity() then
        return false
      end
      return true
    end,
    GetRedDotDataHandle = function()
      local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
      return UGCCenterRedDotData.GetCreateGuideRedDotData()
    end,
    EnterTabHideRedDot = true,
    CanDefaultSelect = function()
      local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
      local ExAwardInfo, ExAwardStates, ExAwardCondition = LogicUGCAuthor:GetAuthorExAwardInfo()
      local bAllGet = true
      if ExAwardInfo ~= nil and ExAwardStates ~= nil then
        local E_        for Level, AwardInfos in pairs(ExAwardInfo) do
          local bAwardContains = false
          for _, AwardInfo in pairs(AwardInfos) do
            if LogicUGCAuthor:AwardInfoIsValid(AwardInfo) then
              bAwardContains = true
              break
            end
          end
          if bAwardContains then
            local AwardState = ExAwardStates[Level]
            if 0 < Level and AwardState ~= nil and AwardState ~= E_ActivityProgressStatus.Get then
              bAllGet = false
              break
            end
          end
        end
      end
      return not bAllGet
    end
  }
}
UGC_Assistant_Define.GuideEntranceJumpType = {
  VideoTeaching = 1,
  CreatorCommunity = 2,
  Discord = 4,
  CreatorAcademy = 5,
  Condition = nil
}
local GuideEntranceJumpConfigDefine = {
  JumpType = UGC_Assistant_Define.GuideEntranceJumpType.VideoTeaching,
  Title = "",
  Desc = "",
  JumpHandle = nil,
  JumpCloseSelf = false
}
UGC_Assistant_Define.GuideEntranceJumpConfig = {
  [UGC_Assistant_Define.GuideEntranceJumpType.VideoTeaching] = {
    JumpType = UGC_Assistant_Define.GuideEntranceJumpType.VideoTeaching,
    Title = 8800194,
    Desc = 8801011,
    JumpHandle = function()
      local url = "game://?module=300006&tabId=2&subtabId=201"
      GlobalData.JumpGameUrl(url)
    end,
    Condition = function()
      local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
      local TabID = Config_UGC_Center.Config_UGC_Center_TabID
      local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
      local SubTabList = LogicUGCCenter:GetSubTab()
      if SubTabList ~= nil then
        local SchoolConfig = SubTabList[TabID.School]
        if SchoolConfig ~= nil then
          local VideoSchoolConfig
          for i = 1, #SchoolConfig do
            if SchoolConfig[i].ID == TabID.Video then
              VideoSchoolConfig = SchoolConfig[i]
              break
            end
          end
          if VideoSchoolConfig ~= nil then
            if VideoSchoolConfig.Open == nil then
              return true
            end
            return VideoSchoolConfig.Open()
          end
        end
      end
      return false
    end,
    JumpCloseSelf = false
  },
  [UGC_Assistant_Define.GuideEntranceJumpType.CreatorCommunity] = {
    JumpType = UGC_Assistant_Define.GuideEntranceJumpType.CreatorCommunity,
    Title = 8800195,
    Desc = 8801012,
    JumpHandle = function()
      local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
      if not LogicUGCCenter:GetCreatorForumPandoraState() then
        ShowNotice(8801008)
        return
      end
      local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
      if not logic_gamelet_interface:gamelet_enable() then
        local gamelet_define = require("client.slua.logic.gamelet.gamelet_define")
        if logic_gamelet_interface.DisableReason == gamelet_define.DisableReason.LowMem then
          log(bWriteLog and "UGC_Center_Challenge:OnClickWOWCreatorForum--Low Mem--return false")
          ShowNotice(8801021)
          return
        end
      end
      local JumpUtils = require("client.logic.store.jump_utils")
      JumpUtils.OpenJumpModule(BP_ENUM_MODULE_HOSTED_WOW_BBS)
    end,
    Condition = function()
      if Client == nil then
        return false
      end
      local strRegion = Client.GetPublishRegion()
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if strRegion == PublishRegionMacros.BLUEHOLE or strRegion == PublishRegionMacros.JAPAN or strRegion == PublishRegionMacros.KOREA then
        return false
      end
      return true
    end,
    JumpCloseSelf = false
  },
  [UGC_Assistant_Define.GuideEntranceJumpType.Discord] = {
    JumpType = UGC_Assistant_Define.GuideEntranceJumpType.Discord,
    Title = 8800197,
    Desc = 8801013,
    JumpHandle = function()
      local Link = "https://discord.gg/r766Q9ruyY"
      local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
      local url = webModule:AddParameterByPersonalInfo(Link, true, true)
      GlobalData.JumpUrl(url)
    end,
    Condition = function()
      if Client == nil then
        return false
      end
      local strRegion = Client.GetPublishRegion()
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if strRegion == PublishRegionMacros.BLUEHOLE or strRegion == PublishRegionMacros.JAPAN or strRegion == PublishRegionMacros.KOREA then
        return false
      end
      return true
    end,
    JumpCloseSelf = false
  },
  [UGC_Assistant_Define.GuideEntranceJumpType.CreatorAcademy] = {
    JumpType = UGC_Assistant_Define.GuideEntranceJumpType.CreatorAcademy,
    Title = 8800198,
    Desc = 8801014,
    JumpHandle = function()
      local url = "game://?module=300006&tabId=2&subtabId=202"
      GlobalData.JumpGameUrl(url)
    end,
    Condition = function()
      return true
    end,
    JumpCloseSelf = false
  }
}
return UGC_Assistant_Define