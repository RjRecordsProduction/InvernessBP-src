local _bInit, _GMClickAnimState
local LClicker = {}
local logic_comp_combobox = require("client.slua.logic.clicker.logic_comp_combobox")
function LClicker.InitUDObj()
  if _bInit then
    return
  end
  _bInit = true
  local InputClass = import("ScreenInput")
  local UIUtil = require("client.common.ui_util")
  local worldContextObject = UIUtil.GetGameInstance()
  local _udScreenInput = InputClass(worldContextObject)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local clickStateData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyGMClickAnimationState) or {}
  _GMClickAnimState = clickStateData.state or false
  _udScreenInput:Init()
  local isClickAnimation
  if isClickAnimation == nil then
    isClickAnimation = LobbySystem.CheckOpen(BP_REDUCE_CLICK_ANIMATION)
  end
  if isClickAnimation and not UIManager.IsUIShow(UIManager.UI_Config.ClickEffect_UIBP) then
    local ClickEffectModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ClickEffectModule)
    ClickEffectModule:SetCurrentUse(0)
    UIManager.ShowUI(UIManager.UI_Config.ClickEffect_UIBP)
  end
  local utility = require("common.utility")
  local modeSwitchDelegateContainer = utility.GetOrCreateDelegateContainerWithName(GlobalData, "modeSwitchDelegateContainer")
  modeSwitchDelegateContainer:AddControlEvent(_udScreenInput, "OnMouseButtonUp", function(pos)
    if not GameStatus.IsInFightingNotMainCity() or GameStatus.IsCollectionHallMode() then
      logic_comp_combobox.ProcScreenMouseUp()
    end
  end)
  modeSwitchDelegateContainer:AddControlEvent(_udScreenInput, "OnMouseButtonDown", function(pos)
    if not GameStatus.IsInFightingNotMainCity() or GameStatus.IsCollectionHallMode() then
      if not _GMClickAnimState then
        local LoadingSystem = require("client.slua.logic.loading.logic_loading")
        if not LoadingSystem.IsShowing() then
          EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_GET_CLICK_POSITION, pos)
        end
      end
      logic_comp_combobox.ProcScreenMouseDown()
    end
  end)
end
function LClicker.SetGmClickAnimState(state)
  _GMClickAnimState = state
end
return LClicker