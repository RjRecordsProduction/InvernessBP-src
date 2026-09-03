local CompletePlaybackUISwitch = {}
local WidgetConfig = {
  MainControlPanelTochButton = {bOldStyle = true, Parent = ""},
  CompletePlayback_UIBP = {bOldStyle = true, Parent = ""},
  CanvasPanel_MiniMapAndSetting = {
    bOldStyle = true,
    Parent = "MainControlBaseUI"
  },
  NavigatorPanel = {
    bOldStyle = false,
    Parent = "MainControlBaseUI"
  },
  WatchGame_PlayerInfo_UIBP = {
    bOldStyle = true,
    Parent = "CompletePlayback_UIBP"
  },
  CanvasPanel_VehicleChild = {
    bOldStyle = true,
    Parent = "CompletePlayback_UIBP"
  },
  OtherInfoPanel = {
    bOldStyle = true,
    Parent = "Ingame_TeamPanel_BP"
  },
  CanvasPanel_DistanceUI = {
    bOldStyle = true,
    Parent = "CompletePlayback_UIBP"
  },
  CanvasPanelSurviveKill = {
    bOldStyle = true,
    Parent = "MainControlBaseUI"
  },
  Common_Logo_UIBP = {bOldStyle = false},
  LeftKillInfo = {bOldStyle = true, Parent = "ingamesub"},
  Ingame_TeamPanel_BP = {bOldStyle = true, Parent = ""},
  PhoneStateUI = {bOldStyle = false},
  TextBlock_BID = {
    bOldStyle = true,
    Parent = "MainControlBaseUI"
  },
  TextBlock_Hour = {
    bOldStyle = true,
    Parent = "MainControlBaseUI"
  },
  TextBlock_DeathPlaybackTips1 = {
    bOldStyle = true,
    Parent = "CompletePlayback_UIBP"
  },
  CanvasPanel_time = {
    bOldStyle = true,
    Parent = "CompletePlayback_UIBP"
  },
  CanvasPanel_VideoInspection = {
    bOldStyle = true,
    Parent = "WatchGame_PlayerInfo_UIBP"
  },
  BattlePopTips = {bOldStyle = true, Parent = ""},
  EntireMapWindow = {bOldStyle = true}
}
local TypeToWidgetConfigNames = {
  [0] = {
    "MainControlPanelTochButton",
    "CompletePlayback_UIBP"
  },
  [1] = {
    "CanvasPanel_MiniMapAndSetting",
    "NavigatorPanel"
  },
  [2] = {
    "WatchGame_PlayerInfo_UIBP"
  },
  [3] = {
    "CanvasPanel_VehicleChild",
    "OtherInfoPanel",
    "CanvasPanel_DistanceUI"
  },
  [4] = {
    "CanvasPanelSurviveKill"
  },
  [5] = {
    "Common_Logo_UIBP",
    "LeftKillInfo",
    "BottomKillInfo",
    "PhoneStateUI",
    "TextBlock_BID",
    "TextBlock_Hour",
    "CanvasPanel_time"
  },
  [6] = {
    "Ingame_TeamPanel_BP"
  },
  [7] = {
    "TextBlock_DeathPlaybackTips1",
    "CanvasPanel_VideoInspection"
  },
  [8] = {
    "BattlePopTips"
  },
  [9] = {
    "EntireMapWindow"
  }
}
function CompletePlaybackUISwitch.OnInit()
  print(bWriteLog and "CompletePlaybackUISwitch.OnInit")
  local TimeTicker = require("common.time_ticker")
  if CompletePlaybackUISwitch.Timeticker then
    TimeTicker.RemoveTimer(CompletePlaybackUISwitch.Timeticker)
    CompletePlaybackUISwitch.Timeticker = nil
  end
  CompletePlaybackUISwitch.Timeticker = TimeTicker.AddTimer(0, function()
    while true do
      if CompletePlaybackUISwitch.Record then
        for Type, Visible in pairs(CompletePlaybackUISwitch.Record) do
          CompletePlaybackUISwitch.ShowCompletePlaybackUI(Type, Visible)
        end
      end
      coroutine.yield(TimeTicker.NEXT_FRAME)
    end
  end)
end
function CompletePlaybackUISwitch.OnRelease()
  print(bWriteLog and "CompletePlaybackUISwitch.OnRelease")
  if CompletePlaybackUISwitch.Timeticker then
    local TimeTicker = require("common.time_ticker")
    TimeTicker.RemoveTimer(CompletePlaybackUISwitch.Timeticker)
    CompletePlaybackUISwitch.Timeticker = nil
  end
end
function CompletePlaybackUISwitch.ShowCompletePlaybackUI(Type, Visible)
  print(bWriteLog and "CompletePlaybackUISwitch.ShowCompletePlaybackUI Type=" .. tostring(Type) .. " Visible=" .. tostring(Visible))
  local WidgetConfigNames = TypeToWidgetConfigNames[Type]
  if not WidgetConfigNames then
    print(bWriteLog and "CompletePlaybackUISwitch.ShowCompletePlaybackUI Fail No Type=" .. Type)
    return
  end
  if not CompletePlaybackUISwitch.Record then
    CompletePlaybackUISwitch.Record = {}
  end
  CompletePlaybackUISwitch.Record[Type] = Visible
  CompletePlaybackUISwitch.ShowOrHideUI(WidgetConfigNames, Visible == 1)
  if Type == 3 then
    local PlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(PlayerController) then
      PlayerController.bShouldDisplayHitFinalDamage = Visible == 1
    end
    local UIUtil = require("client.common.ui_util")
    local CompletePlaybackUI = UIUtil.GetWidgetByLogicName("complete_playback")
    if slua.isValid(CompletePlaybackUI) then
      CompletePlaybackUI.HideEnemyDistance = Visible == 0
      CompletePlaybackUI:UpdateEnemyDistanceUI()
      print(bWriteLog and "CompletePlaybackUISwitch.ShowCompletePlaybackUI CompletePlaybackUI.HideEnemyDistance=" .. tostring(CompletePlaybackUI.HideEnemyDistance))
    end
  end
end
function CompletePlaybackUISwitch.ShowOrHideUI(WidgetConfigNames, bVisible)
  print(bWriteLog and "CompletePlaybackUISwitch.ShowOrHideUI bVisible=" .. tostring(bVisible))
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not slua.isValid(MainControlPanelTochButton) then
    print(bWriteLog and "CompletePlaybackUISwitch.ShowOrHideUI not slua.isValid(MainControlPanelTochButton)")
    return
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(MainControlBaseUI) then
    print(bWriteLog and "CompletePlaybackUISwitch.ShowOrHideUI not slua.isValid(MainControlBaseUI)")
    return
  end
  local UIUtil = require("client.common.ui_util")
  local CompletePlaybackUI = UIUtil.GetWidgetByLogicName("complete_playback")
  if not slua.isValid(CompletePlaybackUI) then
    print(bWriteLog and "CompletePlaybackUISwitch.ShowOrHideUI not slua.isValid(CompletePlaybackUI)")
    return
  end
  for Index, WidgetConfigName in pairs(WidgetConfigNames) do
    print(bWriteLog and "CompletePlaybackUISwitch.ShowOrHideUI WidgetConfigName=" .. WidgetConfigName)
    if WidgetConfigName == "CanvasPanelSurviveKill" then
      MainControlBaseUI.IsNeedSurviveKillPanel = false
    end
    local WidgetConfig = WidgetConfig[WidgetConfigName]
    if WidgetConfig.bOldStyle then
      if WidgetConfigName == "MainControlPanelTochButton" then
        CompletePlaybackUISwitch.SetWidgetVisibility(MainControlPanelTochButton, bVisible)
      elseif WidgetConfigName == "CompletePlayback_UIBP" then
        CompletePlaybackUISwitch.SetWidgetVisibility(CompletePlaybackUI, bVisible)
      elseif WidgetConfigName == "Ingame_TeamPanel_BP" then
        local TeamPanel = InGameSubUIManager.GetWidgetByName("Ingame_TeamPanel_BP")
        if TeamPanel and slua.isValid(TeamPanel) then
          CompletePlaybackUISwitch.SetWidgetVisibility(TeamPanel, bVisible)
        end
      elseif WidgetConfigName == "BattlePopTips" then
        local BattlePopTips = UIUtil.GetLuaTableByName("BattlePopTips")
        if BattlePopTips then
          BattlePopTips.Disable = not bVisible
          BattlePopTips:ClearTips()
        end
      elseif WidgetConfigName == "EntireMapWindow" then
        local EntireMapWindow = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
        if EntireMapWindow then
          local Visible = UEnums.ESlateVisibility.Visible
          if not bVisible then
            Visible = UEnums.ESlateVisibility.Collapsed
          end
          local Buttons = {
            "Button_SelfMark",
            "Button_SelfLock",
            "Button_DelMarkIcon",
            "Button_MultiMark",
            "Button_ClearMultiMark",
            "Button_RevertMultiMark",
            "Button_HideMap",
            "Button_ZoomOut",
            "Button_ZoomIn",
            "Button_0",
            "Slider_MapZoom",
            "Image_SliderLine"
          }
          for _, ButtonName in pairs(Buttons) do
            EntireMapWindow.UIRoot[ButtonName]:SetWidgetVisibility(Visible)
          end
        end
      elseif WidgetConfig.Parent == "MainControlBaseUI" then
        local Widget = MainControlBaseUI[WidgetConfigName]
        CompletePlaybackUISwitch.SetWidgetVisibility(Widget, bVisible)
      elseif WidgetConfig.Parent == "CompletePlayback_UIBP" then
        local Widget = CompletePlaybackUI[WidgetConfigName]
        CompletePlaybackUISwitch.SetWidgetVisibility(Widget, bVisible)
      elseif WidgetConfig.Parent == "WatchGame_PlayerInfo_UIBP" then
        local WatchGame_PlayerInfo_UIBP = CompletePlaybackUI.WatchGame_PlayerInfo_UIBP
        local Widget = WatchGame_PlayerInfo_UIBP[WidgetConfigName]
        CompletePlaybackUISwitch.SetWidgetVisibility(Widget, bVisible)
      elseif WidgetConfig.Parent == "Ingame_TeamPanel_BP" then
        local TeamPanel = InGameSubUIManager.GetWidgetByName("Ingame_TeamPanel_BP")
        if TeamPanel and slua.isValid(TeamPanel) then
          local Widget = TeamPanel[WidgetConfigName]
          CompletePlaybackUISwitch.SetWidgetVisibility(Widget, bVisible)
        end
      elseif WidgetConfig.Parent == "ingamesub" then
        local Widget = InGameSubUIManager.GetWidgetByName(WidgetConfigName)
        CompletePlaybackUISwitch.SetWidgetVisibility(Widget, bVisible)
      end
    elseif UIManager.UI_Config_InGame then
      local Widget = UIManager.GetUI(UIManager.UI_Config_InGame[WidgetConfigName])
      if Widget then
        if not bVisible then
          UIManager.CloseUI(UIManager.UI_Config_InGame[WidgetConfigName])
        else
          UIManager.ShowUI(UIManager.UI_Config_InGame[WidgetConfigName])
        end
      elseif bVisible then
        UIManager.ShowUI(UIManager.UI_Config_InGame[WidgetConfigName])
      end
    end
  end
end
function CompletePlaybackUISwitch.SetWidgetVisibility(Widget, bVisible)
  if not slua.isValid(Widget) then
    print(bWriteLog and "CompletePlaybackUISwitch.SetWidgetVisibility not slua.isValid(Widget)")
    return
  end
  if not bVisible then
    Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
return CompletePlaybackUISwitch