DefaultInGameWidgetDataList = {
  VideoPlayer = {
    bAutoShow = 1,
    GameWidgetConfig = {
      Path = "/Game/BluePrints/ControlInput/IngameUI/VideoPlayer/VideoPlayer_UIBP.VideoPlayer_UIBP_C",
      Container = "Default",
      ZOrder = 80
    },
    WidgetMountData = {
      MarginData = {
        Left = 0.0,
        Top = 0.0,
        Right = 0.0,
        Bottom = 0.0
      },
      AnchorsData = {
        Minimum = {0.0, 0.0},
        Maximum = {1.0, 1.0}
      },
      Position = {0.0, 0.0},
      MountName = "CanvasPanel_42",
      MountOuterName = "MainControlBaseUI"
    }
  },
  TopKillInfo = {
    bAutoShow = 1,
    GameWidgetConfig = {
      Path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/TopKillInfoItem.TopKillInfoItem_C",
      Container = "Default",
      ZOrder = 0
    },
    WidgetMountData = {
      MarginData = {
        Left = 0.0,
        Top = 0.0,
        Right = 0.0,
        Bottom = 0.0
      },
      AnchorsData = {
        Minimum = {0.0, 0.0},
        Maximum = {1.0, 1.0}
      },
      Position = {0.0, 0.0},
      MountName = "CanvasPanel_1",
      MountOuterName = "MainControlBaseUI"
    }
  }
}
DefaultInGameWidget = {}
for Key, _ in pairs(DefaultInGameWidgetDataList) do
  table.insert(DefaultInGameWidget, Key)
end
function _ENV:ingamesub_RegisterUI()
  ingamesub = self
  InGameUIManager.SubUIWidgetListWithMountData(ingamesub, {}, {"Fighting"}, false, true, true, 0)
end
INGAMESUBUI = INGAMESUBUI or {}
InGameSubUIManager = {
  AutoCreateUIConfigQueue = {}
}
function InGameSubUIManager.ClearQueue()
  InGameSubUIManager.AutoCreateUIConfigQueue = {}
end
function InGameSubUIManager.AddUIConfigName(UIConfig)
  InGameSubUIManager.AutoCreateUIConfigQueue[#InGameSubUIManager.AutoCreateUIConfigQueue + 1] = UIConfig
end
function InGameSubUIManager.GetWidgetByName(WidgetName)
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  for _, UIConfig in ipairs(InGameSubUIManager.AutoCreateUIConfigQueue) do
    local UIInstance = UIManager.GetUI(UIConfig)
    local UIRoot = UIInstance and UIInstance.UIRoot or nil
    if type(UIRoot) == "table" then
      log_warning(string.format("[%s] need to load sync", UIConfig.moduleName))
    elseif UIRoot then
      local UserWidgetName = STExtraBlueprintFunctionLibrary.GetUserWidgetName(UIRoot)
      if string.find(UserWidgetName, WidgetName) then
        return UIRoot
      end
    end
  end
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetWidgetByName("ingamesub", WidgetName)
end
function ingamesub_CreateSubBattleUI(InGameWidgetKeyList, ModAddWidgetList)
  if ingamesub then
    local InGameWidgetDataList = {}
    log(bWriteLog and "ingamesub_CreateSubBattleUI SubUIWidgetListWithMountData CustomList")
    if InGameWidgetKeyList == "default" then
      InGameWidgetKeyList = DefaultInGameWidget
    end
    for i, v in pairs(InGameWidgetKeyList) do
      if not UIManager.UI_Config_InGame[v] then
        if DefaultInGameWidgetDataList[v] == nil then
          log(bWriteLog and "ingamesub_CreateSubBattleUI key " .. v .. " is invalid")
        else
          log(bWriteLog and "ingamesub_CreateSubBattleUI AddVal: " .. v)
          table.insert(InGameWidgetDataList, DefaultInGameWidgetDataList[v])
        end
      end
    end
    if ModAddWidgetList then
      for Key, Value in pairs(ModAddWidgetList) do
        log(bWriteLog and "ingamesub_CreateSubBattleUI ModVal: " .. Key)
        table.insert(InGameWidgetDataList, Value)
      end
    end
    InGameUIManager.SubUIWidgetListWithMountData(ingamesub, InGameWidgetDataList, {"Fighting"}, false, true, true, 0)
    local CurrentConfig = require("GameLua.GameCore.Main.ClientGameMain").CurrentConfig
    if not CurrentConfig then
      local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
      CurrentConfig = GameMainConfig.GetConfig(true)
    end
    local AutoCreateUIConfig = CurrentConfig.UIConfig.AutoCreateUIConfig or {}
    local AutoCreateUIName = {}
    for _, UIName in pairs(AutoCreateUIConfig) do
      AutoCreateUIName[UIName] = UIName
    end
    for _, UIName in pairs(InGameWidgetKeyList) do
      if UIManager.UI_Config_InGame[UIName] and not AutoCreateUIName[UIName] then
        local UIConfig = UIManager.UI_Config_InGame[UIName]
        if UIConfig then
          UIManager.ShowUI(UIConfig)
          InGameSubUIManager.AddUIConfigName(UIConfig)
        end
      end
    end
    InGameUIManager.HandleDynamicCreation(ingamesub)
    InGameUIManager.HandleMountWidget(ingamesub, ingame)
  end
end