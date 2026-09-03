local Collect_Room_Item01_UIBP = {}
local bShowGuideDelete
local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
local noDataCfg = {
  [0] = 1,
  [collect_cfg.dataInOther] = 1
}
local type2Index = {
  0,
  1,
  2,
  3
}
local DynamiceBadgeSwitcherIndex = 4
local NMaxNum = 100
function Collect_Room_Item01_UIBP:OnRefresh(_, _)
  local root = self.UIRoot
  local data = self.data
  local Collect_Room_UIBP = self:GetLoopScrollBoxParentUI()
  self.isLock = 0 < data and data < NMaxNum
  self.nRealIndex = self.index
  self.nItemId = data
  if self.isLock then
    self.nRealIndex = data
    local parentData = self:GetLoopScrollBox():GetSetData()
    self.nItemId = parentData[data]
  end
  self.nType = nil
  self:CloseDynamiceBadgeItem()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local CollectBadge = collect_module:GetSplitTableData("CollectBadge", collect_module.E_ColCfgMode.Def, data)
  if not (not noDataCfg[data] and CollectBadge) or not CollectBadge.ShowType then
    log_warning(bWriteLog and "  Collect_Room_Item01_UIBP:OnRefresh. self.index: " .. tostring(self.index))
    local switcherIndex = 0
    if data == collect_cfg.dataInOther or not Collect_Room_UIBP.bIsSelf then
      switcherIndex = 1
    end
    root.WidgetSwitcher_0:SetActiveWidgetIndex(switcherIndex)
    self:SetWidgetVisible(root.Image_other, not Collect_Room_UIBP.bIsSelf)
  else
    root.WidgetSwitcher_0:SetActiveWidgetIndex(2)
    if CollectBadge then
      local _type = CollectBadge.ShowType
      local index = type2Index[_type]
      self.nType = _type
      if CollectBadge.DynamicBadgeBPPath and CollectBadge.DynamicBadgeBPPath ~= "" then
        index = DynamiceBadgeSwitcherIndex
        self:UpdateDynamiceBadgeItemShow()
        self:SetTexture(root.frame_TagEffect, CollectBadge.Frame)
      else
        self:SetTexture(root["Image_Banner" .. _type], CollectBadge.Icon)
        self:SetTexture(root["frame" .. _type], CollectBadge.Frame)
      end
      root.WidgetSwitcher_Banner:SetActiveWidgetIndex(index)
      self:ShowGuide1(root["CanvasPanel_guide" .. _type])
    else
      log_warning(bWriteLog and "  Collect_Room_Item01_UIBP:OnRefresh. id error  data: " .. tostring(data))
    end
  end
end
function Collect_Room_Item01_UIBP:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.Button_0, "OnClicked", self.OnClickButton_Enter, self)
end
function Collect_Room_Item01_UIBP:OnClickButton_Enter()
  local Collect_Room_UIBP = self:GetLoopScrollBoxParentUI()
  if Collect_Room_UIBP:GetIsSharing() then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  if self.data > 0 then
    self:ShowTips()
  elseif Collect_Room_UIBP.bIsSelf then
    UIManager.ShowUI(UIManager.UI_Config.Collect_Popup_Room_UIBP, self.index, function(id)
      Collect_Room_UIBP = self:GetLoopScrollBoxParentUI()
      Collect_Room_UIBP:EquipBadge(self.nRealIndex, id)
    end)
  end
end
function Collect_Room_Item01_UIBP:ShowTips()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local data = self.data
  local itemId = self.nItemId
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local CollectBadge = collect_module:GetSplitTableData("CollectBadge", collect_module.E_ColCfgMode.Def, itemId)
  if noDataCfg[data] or not CollectBadge then
    log_warning(bWriteLog and "  Collect_Room_Item01_UIBP:ShowTips. self.nItemId: " .. tostring(self.nItemId))
    return
  end
  local tItemCfg = CDataTable.GetTableData("Item", self.nItemId)
  local tipsParams = {
    widget = self.UIRoot,
    title = tItemCfg.ItemName,
    content = tItemCfg.ItemDesc
  }
  local Collect_Room_UIBP = self:GetLoopScrollBoxParentUI()
  if Collect_Room_UIBP.bIsSelf then
    local remove = function()
      log_warning(bWriteLog and "  remove.  ")
      Collect_Room_UIBP:RemoveBadge(self.nItemId)
    end
    local replace = function()
      log_warning(bWriteLog and "  replace.  ")
      UIManager.ShowUI(UIManager.UI_Config.Collect_Popup_Room_UIBP, self.nRealIndex, function(id)
        Collect_Room_UIBP:Replace(self.nItemId, self.nRealIndex, id)
      end)
    end
    tipsParams.detailText = LocUtil.GetLocalizeResStr(150020)
    tipsParams.detailText2 = LocUtil.GetLocalizeResStr(47185)
    tipsParams.detailCallback = remove
    tipsParams.detailCallback2 = replace
  end
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tipsParams)
end
function Collect_Room_Item01_UIBP:ShowGuide1(widget)
  log_warning(bWriteLog and "  Collect_Room_Item01_UIBP:ShowGuide1. " .. tostring(bShowGuideDelete))
  if bShowGuideDelete then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local show = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectRoomDelete)
  bShowGuideDelete = show
  log_warning(bWriteLog and "  Collect_Room_UIBP:ShowGuide1. show: " .. tostring(show))
  if not show or show == 0 then
    local callBack = function()
      PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eCollectRoomDelete)
    end
    local word = LocUtil.GetLocalizeResStr(77552)
    UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 1, word, widget, callBack, true, 1)
    bShowGuideDelete = true
  end
end
function Collect_Room_Item01_UIBP:UpdateDynamiceBadgeItemShow()
  log(bWriteLog and "Collect_Room_Item01_UIBP:UpdateDynamiceBadgeItemShow. nItemId:" .. tostring(self.nItemId))
  if not self.nItemId then
    return
  end
  local collect_item_util = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_item_util")
  self.DynamicBadgeItem = collect_item_util.ShowDynamicBadgeItem(self, self.UIRoot.CanvasPanel_TagEffect, self.nItemId, false)
end
function Collect_Room_Item01_UIBP:CloseDynamiceBadgeItem()
  log(bWriteLog and "Collect_Room_Item01_UIBP:CloseDynamiceBadgeItem")
  if not self.DynamicBadgeItem then
    return
  end
  self.DynamicBadgeItem:Close()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CCollect_RLevel_Item_UIBP = class(ui_base, nil, Collect_Room_Item01_UIBP)
return CCollect_RLevel_Item_UIBP