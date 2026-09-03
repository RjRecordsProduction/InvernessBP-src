function _ENV:observe_RegisterUI()
  InGameUIManager.SubUIWidgetList(self, {
    {
      Path = "/Game/BluePrints/UI/OBUI/OBUI_UIBP.OBUI_UIBP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    },
    {
      Path = "/Game/BluePrints/UI/OBUI/OB_AirDropList_BP.OB_AirDropList_BP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    },
    {
      Path = "/Game/BluePrints/ControlInput/ResultsshareUI/ResultsOB/ResultsOB_UIBP.ResultsOB_UIBP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    }
  }, {"Fighting"}, false, true, true)
end
ObserverUI = ObserverUI or {}
local ObserverUI_UIRoot = function()
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetWidgetByLogicName("observe")
end
function OB_AirDropList_RegisterUI()
end
function ObserverUI.EnterOvserving()
  if observe then
    InGameUIManager.HandleDynamicCreation(observe)
    InGameUIManager.HandleUIMessage(observe, "ShowOBUI")
    ObserverUI.ShowVideoPlayer(true)
    EventSystem:postEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_ENTER_OBSERVING)
  end
  if ingame then
    InGameUIManager.HandleUIMessage(ingame, "EnterSpectatingStatus")
    InGameUIManager.HandleUIMessage(ingame, "EnterObserverStatus")
  end
end
function ObserverUI.ShowVideoPlayer(bIsShow)
  local uiRoot = ObserverUI_UIRoot()
  local Parent = uiRoot.CanvasPanel_PlayControl
  if not slua.isValid(Parent) then
    return
  end
  local Logic_Ob_Lobby = require("client.slua.logic.lobby.logic_lobby_ob")
  if bIsShow and Logic_Ob_Lobby.PlayFrom == Logic_Ob_Lobby.E_PlayerType.ReplayMode and not UIManager.GetUI(UIManager.UI_Config.OB_Replay_PlayVideoInfo_UIBP) then
    local PlayerUI = UIManager.ShowUI(UIManager.UI_Config.OB_Replay_PlayVideoInfo_UIBP)
    Parent:AddChildToCanvas(PlayerUI.UIRoot)
    PlayerUI.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    PlayerUI.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
  end
end
function ObserverUI.Hide()
  local Logic_Ob_Lobby = require("client.slua.logic.lobby.logic_lobby_ob")
  if Logic_Ob_Lobby.PlayFrom == Logic_Ob_Lobby.E_PlayerType.ReplayMode then
    local uiRoot = ObserverUI_UIRoot()
    if not uiRoot then
      return
    end
    local Parent = uiRoot.CanvasPanel_PlayControl
    if slua.isValid(Parent) then
      Parent:ClearChildren()
    end
  end
end