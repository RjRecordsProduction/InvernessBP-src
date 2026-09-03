local logic_lobby_home_main = {}
local home_macros = require("client.slua.logic.home.home_macros")
local home_collection_task_redpoint = require("client.slua.logic.home.Collection.home_collection_task_redpoint")
local LobbyTabConfig = {
  [home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Recommend] = {
    tabType = home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Recommend,
    activePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_Main_XuanZhong_png.Home_Tab_Icon_Main_XuanZhong_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_Main_png.Home_Tab_Icon_Main_png",
    title = 64741,
    uiConfig = UIManager.UI_Config.Lobby_Home_Details_UIBP,
    panel = "CanvasPanel_Home_Details_UIBP",
    hideTitle = false,
    BGName = "CanvasPanel_13",
    showFunc = function()
      local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
      if PlanPH_GamePlay_Tools.IsPHomeMode() then
        return false
      end
      return true
    end,
    redData = function()
      local logic_home_anniversary_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_anniversary_activity)
      local logic_home_promotion_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_promotion_activity)
      return not logic_home_anniversary_activity:NeedShowReddot() and logic_home_promotion_activity:IsNewStyleActivityShouldShow() and logic_home_promotion_activity:IsHaveReddot()
    end
  },
  [home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Task] = {
    tabType = home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Task,
    activePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_Task_XuanZhong_png.Home_Tab_Icon_Task_XuanZhong_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_Task_png.Home_Tab_Icon_Task_png",
    title = 64787,
    uiConfig = UIManager.UI_Config.Home_Collection_Task_UIBP,
    BGName = "Common_UIPanelBG",
    hideCoinBar = true,
    panel = "CanvasPanel_Content03",
    hideTitle = true,
    redData = home_collection_task_redpoint.GetData,
    reqDataFunc = function()
      local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
      local data_config_marco = require("client.logic.data.data_config_marco")
      if BasicDataServerTable:GetCacheData(data_config_marco.manor_task_cfg) then
        return false
      end
      local logic_home_collection_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_collection_task)
      logic_home_collection_task:RequestManorTaskCfg()
      return true
    end,
    rspEventID = EVENTTYPE_PLANPH_LOBBY,
    rspEventType = EVENTID_PLANPH_HOME_TASK_CONFIG_UPDATE,
    showFunc = function()
      local logic_home_collection_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_collection_task)
      return logic_home_collection_task:GetIsRun()
    end
  },
  [home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Loot] = {
    tabType = home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Loot,
    activePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_Loot_XuanZhong_png.Home_Tab_Icon_Loot_XuanZhong_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_Loot_png.Home_Tab_Icon_Loot_png",
    title = 62401,
    uiConfig = UIManager.UI_Config.Home_Task_Loot_UIBP,
    hideCoinBar = true,
    panel = "CanvasPanel_Content03",
    hideTitle = true,
    showFunc = function()
      local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
      if PlanPH_GamePlay_Tools.IsPHomeMode() then
        return false
      end
      local logic_manor_draw_reward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_manor_draw_reward)
      return logic_manor_draw_reward:GetIsRun()
    end
  },
  [home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Spin] = {
    tabType = home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Spin,
    activePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_Prize_XuanZhong_png.Home_Tab_Icon_Prize_XuanZhong_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_Prize_png.Home_Tab_Icon_Prize_png",
    title = 655631,
    uiConfig = UIManager.UI_Config.PlanPH_Store_LuckySpin2D_Child_UIBP,
    hideCoinBar = false,
    panel = "CanvasPanel_Content",
    hideTitle = false,
    reqDataFunc = function()
      local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
      local data_config_marco = require("client.logic.data.data_config_marco")
      if BasicDataServerTable:GetCacheData(data_config_marco.manor_draw_back_global_table) then
        return false
      end
      BasicDataServerTable:GetOrReqData(data_config_marco.manor_draw_back_global_table, function()
        EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_SPIN_CONFIG_UPDATE)
      end)
      return true
    end,
    rspEventID = EVENTTYPE_PLANPH_LOBBY,
    rspEventType = EVENTID_PLANPH_SPIN_CONFIG_UPDATE,
    showFunc = function()
      local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
      if PlanPH_GamePlay_Tools.IsPHomeMode() then
        return false
      end
      local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
      local data_config_marco = require("client.logic.data.data_config_marco")
      if not BasicDataServerTable:GetCacheData(data_config_marco.manor_draw_back_global_table) then
        return false
      end
      return true
    end
  },
  [home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Competition] = {
    tabType = home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Competition,
    activePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_PK_XuanZhong_png.Home_Tab_Icon_PK_XuanZhong_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/Home/Home_New_Atlas/Frames/Home_Tab_Icon_PK_png.Home_Tab_Icon_PK_png",
    title = 62500,
    uiConfig = UIManager.UI_Config.HomePK_Main_Child_UIBP,
    panel = "CanvasPanel_Content",
    hideTitle = false,
    redData = function()
      local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
      local logic_popular_home_pk_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk_task)
      local awardFlag = logic_popular_home_pk_task:GetAwardFlag()
      return logic_popular_home_pk:IsShowLevelAwardRedDot() or awardFlag
    end,
    reqDataFunc = function()
      local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
      if logic_popular_home_pk:GetActConfig() then
        return false
      end
      logic_popular_home_pk:ReqGetActConfigTable()
      return true
    end,
    rspEventID = EVENTTYPE_POPULAR_HOMEPK,
    rspEventType = EVENTID_POPULAR_HOME_PK_CONFIG_UPDATE,
    showFunc = function()
      local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
      if PlanPH_GamePlay_Tools.IsPHomeMode() then
        return false
      end
      local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
      local logic_popular_home_pk_util = require("client.slua.logic.popular_home_pk.logic_popular_home_pk_util")
      local actState = logic_popular_home_pk_util.GetActState()
      if actState == PopularHomePKMacros.ENUM_STATE.CLOSE then
        return false
      end
      local logic_popular_home_pk_tab = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk_tab)
      local tabList = logic_popular_home_pk_tab:GetTabList(tonumber(DataMgr.roleData.uid))
      if #tabList == 0 then
        return false
      end
      return true
    end
  }
}
function logic_lobby_home_main:DefineAndResetData()
end
function logic_lobby_home_main:OnInitialize()
end
function logic_lobby_home_main:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_HOME_LOBBY_ENTRY, self.OnJumpHomeLobbyEntry, self)
end
function logic_lobby_home_main:OnLogin(bReLogin)
end
function logic_lobby_home_main:OnLogOut()
end
function logic_lobby_home_main:OnPreSwitchGameStatus(preState, nextState)
end
function logic_lobby_home_main:OnPostSwitchGameStatus(preState, nextState)
end
function logic_lobby_home_main:ShowMainUI(tabType, showInfo)
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch:CheckHomeSwitchOpen(true) then
    return
  end
  if logic_home_switch:CheckHomeLimit(true) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Home_Main_UIBP, tabType, showInfo)
end
function logic_lobby_home_main:OnJumpHomeLobbyEntry(_, _, param)
  local tabType = param and tonumber(param.tabType) or home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Recommend
  local showInfo = param and param.showInfo
  self:ShowMainUI(tabType, showInfo)
end
function logic_lobby_home_main:GetTabConfig()
  return LobbyTabConfig
end
function logic_lobby_home_main:GetRealTabConfig()
  local tabConfigList = {}
  local config = CDataTable.GetTable("HomeMainTabConfig")
  for _, v in ipairs(config) do
    local tabID = v.ID
    local tabConfig = LobbyTabConfig[tabID]
    if tabConfig and self:CheckVersion(v.Version) and tabConfig.showFunc() then
      tabConfig.sortID = v.SortID
      table.insert(tabConfigList, tabConfig)
    end
  end
  table.sort(tabConfigList, function(a, b)
    if a.sortID == 0 and b.sortID == 0 then
      return a.tabType < b.tabType
    elseif a.sortID == 0 and b.sortID ~= 0 then
      return true
    elseif a.sortID ~= 0 and b.sortID == 0 then
      return false
    else
      return a.sortID > b.sortID
    end
  end)
  return tabConfigList
end
function logic_lobby_home_main:GetSwitchCloseTabConfig()
  local tabConfig = {
    [home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Recommend] = {
      tabType = home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Recommend,
      activePath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Party_Atlas/Frames/ZD_Tab_Icon_GiftBox02_XuanZhong_png.ZD_Tab_Icon_GiftBox02_XuanZhong_png",
      inactivePath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Party_Atlas/Frames/ZD_Tab_Icon_GiftBox02_png.ZD_Tab_Icon_GiftBox02_png",
      title = 64741,
      uiConfig = UIManager.UI_Config.Lobby_Home_Details_UIBP,
      panel = "CanvasPanel_Home_Details_UIBP",
      hideTitle = false,
      BGName = "CanvasPanel_13",
      showFunc = function()
        return true
      end
    }
  }
  return tabConfig
end
function logic_lobby_home_main:CheckVersion(targetVersion)
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  log(bWriteLog and string.format("logic_lobby_home_main:CheckVersion, targetVersion:%s", targetVersion))
  log(bWriteLog and string.format("logic_lobby_home_main:CheckVersion, clientVersion:%s", clientVersion))
  if not targetVersion or not clientVersion then
    log(bWriteLog and "logic_lobby_home_main:CheckVersion error version")
    return false
  end
  return version_util.CompareVersionStandard(clientVersion, targetVersion) >= 0
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_home_main = class(CModuleBase, nil, logic_lobby_home_main)
return Clogic_lobby_home_main