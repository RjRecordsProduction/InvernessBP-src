local CorpsTabType = {
  List = 1,
  Create = 2,
  HomePage = 3,
  EnergyMissionHasType = 4,
  EnergyMissionNoType = 5,
  Info = 6,
  Shop = 7,
  Rank = 8,
  Welfare = 9,
  Fight = 10
}
local CorpsTabMgr = {
  currTabs = nil,
  lastOpenCorpsTime = 0,
  tabType = nil,
  showAnimation = true,
  CorpsTabType = CorpsTabType,
  isJumpFromMall = false,
  bNeedReOpenRoleInfo = false,
  selectTab = nil,
  lastSelectTab = nil
}
local TabsSort = {
  [CorpsTabType.List] = 1,
  [CorpsTabType.Create] = 2,
  [CorpsTabType.HomePage] = 3,
  [CorpsTabType.Fight] = 4,
  [CorpsTabType.EnergyMissionHasType] = 5,
  [CorpsTabType.EnergyMissionNoType] = 6,
  [CorpsTabType.Info] = 7,
  [CorpsTabType.Shop] = 8,
  [CorpsTabType.Rank] = 9,
  [CorpsTabType.Welfare] = 10
}
local CorpsTabsConfig
function CorpsTabMgr.InitCorpsTabsConfig()
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
  CorpsTabsConfig = {
    [CorpsTabType.List] = {
      uiConfig = "corps_suggestion",
      checkShowFunc = function()
        return LobbySystem.roleData.is_low_corps or DataMgr.corpsInfo.id == 0
      end,
      page_id = CorpsRedPointData.page_id.suggestion_panel,
      localize = 10068,
      bShowBg = true
    },
    [CorpsTabType.Create] = {
      uiConfig = "corps_create",
      checkShowFunc = function()
        return DataMgr.corpsInfo.id == 0
      end,
      localize = 10069,
      bShowBg = true
    },
    [CorpsTabType.HomePage] = {
      uiConfig = "CorpsHomepageNewUI2",
      localize = 10071,
      checkShowFunc = function()
        return DataMgr.corpsInfo.id ~= 0
      end,
      page_id = CorpsRedPointData.page_id.home_panel,
      bShowBg = true
    },
    [CorpsTabType.EnergyMissionHasType] = {
      bShowBg = true,
      uiConfig = "Corps_Energy_Mission_Has_Type",
      localize = 10072,
      page_id = CorpsRedPointData.page_id.EnergyMissionTab,
      checkShowFunc = function()
        return LogicCorps.HasCorps() and LogicCorps.IsNewCorpsEnabled() and LogicCorps.HasEnergyType()
      end
    },
    [CorpsTabType.EnergyMissionNoType] = {
      bShowBg = true,
      uiConfig = "Corps_Energy_Mission_No_Type",
      localize = 10072,
      page_id = CorpsRedPointData.page_id.EnergyMissionTab,
      checkShowFunc = function()
        return LogicCorps.HasCorps() and LogicCorps.IsNewCorpsEnabled() and not LogicCorps.HasEnergyType()
      end
    },
    [CorpsTabType.Info] = {
      uiConfig = "corps_member_info",
      localize = 10073,
      checkShowFunc = function()
        return DataMgr.corpsInfo.id ~= 0
      end,
      page_id = CorpsRedPointData.page_id.info_panel,
      bShowBg = false
    },
    [CorpsTabType.Shop] = {
      uiConfig = "Corps_Shop_UIBP",
      localize = 10074,
      checkShowFunc = function()
        return DataMgr.corpsInfo.id ~= 0
      end,
      page_id = CorpsRedPointData.page_id.store_panel,
      bShowBg = false
    },
    [CorpsTabType.Rank] = {
      uiConfig = "corps_rank_new",
      localize = 10075,
      checkShowFunc = function()
        return true
      end,
      bShowBg = false
    },
    [CorpsTabType.Fight] = {
      showFunc = function()
        local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
        return logic_corps_fight.ShowTabUI()
      end,
      closeFunc = function()
        local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
        logic_corps_fight.CloseTabUI()
      end,
      localize = 23733,
      checkShowFunc = function()
        local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
        return logic_corps_fight.CheckShowTab()
      end,
      page_id = CorpsRedPointData.page_id.fight_panel,
      bShowBgFunc = function()
        local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
        return logic_corps_fight.CheckShowBgFunc()
      end
    }
  }
  if LobbySystem.roleData.is_low_corps then
    TabsSort = {
      [CorpsTabType.List] = 10,
      [CorpsTabType.Create] = 1,
      [CorpsTabType.HomePage] = 2,
      [CorpsTabType.Fight] = 3,
      [CorpsTabType.EnergyMissionHasType] = 4,
      [CorpsTabType.EnergyMissionNoType] = 5,
      [CorpsTabType.Info] = 6,
      [CorpsTabType.Shop] = 7,
      [CorpsTabType.Rank] = 8,
      [CorpsTabType.Welfare] = 9
    }
  else
    TabsSort = {
      [CorpsTabType.List] = 1,
      [CorpsTabType.Create] = 2,
      [CorpsTabType.HomePage] = 3,
      [CorpsTabType.Fight] = 4,
      [CorpsTabType.EnergyMissionHasType] = 5,
      [CorpsTabType.EnergyMissionNoType] = 6,
      [CorpsTabType.Info] = 7,
      [CorpsTabType.Shop] = 8,
      [CorpsTabType.Rank] = 9,
      [CorpsTabType.Welfare] = 10
    }
  end
end
function CorpsTabMgr.OpenCorpsUIWithForceReq()
  CorpsTabMgr.OpenCorpsUI()
end
function CorpsTabMgr.OpenCorpUIWithTab(tabType, extra)
  CorpsTabMgr.OpenCorpsUI(tabType, extra)
end
function CorpsTabMgr.OpenCorpsUI(tabType, extra)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local limitLevel = CorpsMgr.GetConfigToNumber("CreateCorpsLevel") or 0
  if limitLevel > DataMgr.roleData.level then
    CorpsMgr.ShowCorpsLimitError()
    return
  end
  CorpsTabMgr.  CorpsTabMgr.  CorpsTabMgr.OnGetCorpsDataRsp()
  if CorpsMgr.new_corps_exchange then
    local CorpsGiftExchangeHandler = require("client.network.Protocol.CorpsGiftExchangeHandler")
    CorpsGiftExchangeHandler.send_get_corps_exchange_data_req()
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({unlockMark = true}, PlayerPrefsSystem.ePlayerPrefsType.CorpsUnlockRedDot)
  local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
  logic_corps_fight.req_enemy_summary = true
  logic_corps_fight.InitCfgTable()
  logic_corps_fight.DelayInitCfgTable()
  logic_corps_fight.ReqNecessaryInfoForFight()
end
function CorpsTabMgr.OnGetCorpsDataRsp()
  if GameStatus.IsInLobbyOrMainCity() then
    CorpsTabMgr.UpdateRedPoint()
    CorpsTabMgr.OpenCorpsTabMgr(CorpsTabMgr.tabType)
    local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
    store_supply_switcher:CloseStore()
    store_supply_switcher:CloseSupply()
  end
end
function CorpsTabMgr.OpenCorpsTabMgr(tabType)
  log(bWriteLog and "[v_ywuyuan] CorpsTabMgr.OpenCorpsTabMgr" .. ":" .. tostring(tabType))
  CorpsTabMgr.RefreshTab(tabType)
  local isExist = UIManager.GetUI(UIManager.UI_Config.CorpsTabMgr) ~= nil
  if isExist then
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TAB_REFRESH_UI, 1)
  else
    UIManager.ShowUI(UIManager.UI_Config.CorpsTabMgr)
  end
end
function CorpsTabMgr.RefreshTab(tabType)
  local allTabs = {}
  CorpsTabMgr.InitCorpsTabsConfig()
  for tab, config in pairs(CorpsTabsConfig) do
    if config.checkShowFunc and config.checkShowFunc() then
      table.insert(allTabs, {
        tabType = tab,
        config = config,
        text = LocUtil.LocalizeResFormat(config.localize)
      })
    end
  end
  table.sort(allTabs, function(l, r)
    return TabsSort[l.tabType] < TabsSort[r.tabType]
  end)
  CorpsTabMgr.currTabs = allTabs
  if 1 <= #allTabs then
    local selectTab
    local config = CorpsTabMgr.GetConfigByTab(tabType)
    if config and tabType then
      selectTab = tabType
    else
      selectTab = CorpsTabMgr.currTabs[1].tabType
    end
    CorpsTabMgr.    log(bWriteLog and "[v_ywuyuan] CorpsTabMgr.OpenCorpsTabMgr" .. ":" .. tostring(CorpsTabMgr.selectTab))
  end
end
function CorpsTabMgr.GetConfigByTab(tabType)
  return CorpsTabsConfig[tabType]
end
function CorpsTabMgr.GetIndexByTab(tabType)
  if not CorpsTabMgr.currTabs then
    return nil
  end
  for i, v in ipairs(CorpsTabMgr.currTabs) do
    if v.tabType == tabType then
      return i
    end
  end
  return nil
end
function CorpsTabMgr.JumpUrl(_, _, vars)
  local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
  local extra
  if vars and vars.extra then
    extra = tonumber(vars.extra)
  end
  if vars and vars.id and (tonumber(vars.id) ~= CorpsTabType.Create and tonumber(vars.id) ~= CorpsTabType.List or tonumber(vars.id) ~= CorpsTabType.Rank) and DataMgr.corpsInfo.id == 0 then
    ShowNotice(411008)
    return
  end
  logic_corps_tab_mgr.OpenCorpUIWithTab(vars and tonumber(vars.id), extra)
end
function CorpsTabMgr.CheckReOpenRoleInfo()
  if CorpsTabMgr.bNeedReOpenRoleInfo then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.Show()
    CorpsTabMgr.bNeedReOpenRoleInfo = false
  end
end
function CorpsTabMgr.OpenByRoleInfo()
  CorpsTabMgr.bNeedReOpenRoleInfo = true
end
function CorpsTabMgr.UpdateRedPoint()
  local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
  CorpsRedPointData.UpdateLobbyRedDot()
end
function CorpsTabMgr.GetTabTypes()
  return CorpsTabType
end
function CorpsTabMgr.CloseCorps()
  UIManager.CloseUI(UIManager.UI_Config.CorpsTabMgr)
end
return CorpsTabMgr