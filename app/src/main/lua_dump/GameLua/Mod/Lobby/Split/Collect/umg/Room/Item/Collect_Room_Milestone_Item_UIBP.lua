local Collect_Room_Milestone_Item_UIBP = {}
function Collect_Room_Milestone_Item_UIBP:OnInitialize()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  self.nUid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
  self.bIsSelf = self.nUid == tonumber(DataMgr.roleData.uid)
end
function Collect_Room_Milestone_Item_UIBP:OnRefresh()
  local itemID = self.data.itemID
  if itemID == 0 then
    if self.data.bIsShowNone then
      self.UIRoot.WidgetSwitcher_EquipState:SetActiveWidgetIndex(2)
    else
      self.UIRoot.WidgetSwitcher_EquipState:SetActiveWidgetIndex(0)
    end
  else
    self.UIRoot.WidgetSwitcher_EquipState:SetActiveWidgetIndex(1)
    local commonItem = self.UIRoot.Lua_CommonItems
    commonItem:InitView(itemID, nil, nil, {bIsShowTip = false})
    commonItem:SetClickItemCallback(self.OnClickButton_Operation, self)
    commonItem:HideQuality()
  end
  self:SetWidgetVisible(self.UIRoot.Image_Add, self.bIsSelf)
end
function Collect_Room_Milestone_Item_UIBP:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.Button_Add, "OnClicked", self.OnClickButton_Add, self)
end
function Collect_Room_Milestone_Item_UIBP:JumpMilestoneDetailView()
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  UIManager.ShowUI(UIManager.UI_Config.Collect_Milestone_Detail_UIBP, collect_cfg.E_Milestone_Server_Type.outfits, nil, RoleInfoMainSystem.CollectRoom, self.index)
end
function Collect_Room_Milestone_Item_UIBP:JumpVisitorMilestoneDetailView(itemID)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  local sysType = LobbyEmoteManager:GetMilestoneTypeByItemID(itemID)
  UIManager.ShowUI(UIManager.UI_Config.Collect_Milestone_Detail_Visitor_UIBP, sysType, itemID, RoleInfoMainSystem.CollectRoom, self.index, RoleInfoSystem.CurShowPlayerInfoUid)
end
function Collect_Room_Milestone_Item_UIBP:OnClickButton_Add()
  local Collect_Room_UIBP = self:GetLoopScrollBoxParentUI()
  if not Collect_Room_UIBP.bIsSelf or Collect_Room_UIBP:GetIsSharing() then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  self:JumpMilestoneDetailView()
end
function Collect_Room_Milestone_Item_UIBP:OnClickButton_Operation()
  local Collect_Room_UIBP = self:GetLoopScrollBoxParentUI()
  if Collect_Room_UIBP:GetIsSharing() then
    return
  end
  self:PlayAudio(sound_config.click_v1)
  local itemID = self.data.itemID
  if not Collect_Room_UIBP.bIsSelf then
    self:JumpVisitorMilestoneDetailView(itemID)
    return
  end
  local tipsParams = {
    widget = self.UIRoot
  }
  if itemID ~= 0 then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local tItemCfg = CDataTable.GetTableData("Item", itemID)
    tipsParams.title = tItemCfg.ItemName
    tipsParams.content = tItemCfg.ItemDesc
  end
  local remove = function()
    local collect_pavilions_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_pavilions_module)
    collect_pavilions_module:SetShowMilestoneSlot(nil, self.index)
  end
  local replace = function()
    self:JumpMilestoneDetailView()
  end
  tipsParams.detailText = LocUtil.GetLocalizeResStr(150020)
  tipsParams.detailText2 = LocUtil.GetLocalizeResStr(47185)
  tipsParams.detailCallback = remove
  tipsParams.detailCallback2 = replace
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tipsParams)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CCollect_RLevel_Item_UIBP = class(ui_base, nil, Collect_Room_Milestone_Item_UIBP)
return CCollect_RLevel_Item_UIBP