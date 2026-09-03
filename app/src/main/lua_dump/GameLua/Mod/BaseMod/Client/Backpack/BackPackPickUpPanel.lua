local BackPackPickUpPanel = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function BackPackPickUpPanel:OnInitialize()
  print(bWriteLog and "BackPackPickUpPanel:OnInitialize")
  BackPackPickUpPanel.__super.OnInitialize(self)
  self.LastPickUpListPanelBoxColumn = 3
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_SHOWHIDE_BACKPACK_PANEL, self.ShowHideBackpackPanel, self)
  self:AddUIMessageEvent("UIMsg_SwitchCameraSatrtHandle", self.UIMsg_SwitchCameraSatrtHandle, self)
  self:AddCommonEvent(EVENTID_ENTER_SPECTATING, EVENTID_ENTER_SPECTATING_FROM_TPLAN, self.OnStartSpectate, self)
end
function BackPackPickUpPanel:GetBackPackPanel()
  local BackPackPanelUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
  if BackPackPanelUI then
    return BackPackPanelUI.UIRoot
  end
  return nil
end
function BackPackPickUpPanel:UIMsg_SwitchCameraSatrtHandle()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not slua.isValid(PlayerController.STExtraBaseCharacter) then
    return
  end
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel then
    PickUpListPanel.bHideForAim = PlayerController.STExtraBaseCharacter.bIsGunADS
    if not PickUpListPanel.bHideForAim then
      PickUpListPanel.bNeedFillBtn = true
      PickUpListPanel:UpdateListData()
      return
    end
    PickUpListPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BackPackPickUpPanel:ShowHideBackpackPanel(_, __, ShowBackpack, bBRTDMStore)
  local BackPackPanelUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
  if ShowBackpack == nil then
    if BackPackPanelUI ~= nil then
      ShowBackpack = not BackPackPanelUI:IsShow()
    end
    print(bWriteLog and "BackPackPickUpPanel:ShowHideBackpackPanel param ShowBackpack is nil, set to %s" .. tostring(ShowBackpack))
  end
  if not ShowBackpack then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_CHANGE_STATE, false)
    if BackPackPanelUI then
      BackPackPanelUI:HideSelf()
    end
  else
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_CHANGE_STATE, true)
    if BackPackPanelUI then
      xpcall(BackPackPanelUI.ShowSelf, function(msg)
        local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
        local BackpackPanelError = "BackpackPanelError"
        if GameReportUtils.CheckCanBugglyPostException(BackpackPanelError) then
          local traceback_util = require("common.traceback_util")
          local ErrorMsg = traceback_util.OriginalTraceBack(msg)
          GameReportUtils.BugglyPostExceptionFull(BackpackPanelError, ErrorMsg, Client.IsEditor() or Client.IsDevelopment())
        end
      end, BackPackPanelUI)
    end
  end
end
function BackPackPickUpPanel:OnStartSpectate()
  print(bWriteLog and "BackPackPickUpPanel:OnStartSpectate")
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel then
    PickUpListPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CBackPackPickUpPanel = class(ui_base, nil, BackPackPickUpPanel)
return CBackPackPickUpPanel