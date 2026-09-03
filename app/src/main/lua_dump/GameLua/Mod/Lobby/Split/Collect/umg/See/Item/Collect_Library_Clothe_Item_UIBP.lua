local Collect_Library_Clothe_Item_UIBP = {}
function Collect_Library_Clothe_Item_UIBP:OnRefresh(_, _)
  if not self.data or not self.data.ItemID then
    return
  end
  local UIUtil = require("client.common.ui_util")
  local itemCfg = CDataTable.GetTableData("Item", self.data.ItemID)
  if not itemCfg then
    return
  end
  local nItemId = self.data.ItemID
  local node_commonItem = self.UIRoot
  node_commonItem:InitView(nItemId, 0, itemCfg.ValidTimes)
  node_commonItem:SetClickItemCallback(self.OnClickButton, self)
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  if collect_encryption_module:IsEncryptionSeries(self.data.Version, self.data.Time) then
    local defaultIcon = UIUtil.GetDefaultIcon(itemCfg.ItemID)
    self.UIRoot:SetIconFromPath(defaultIcon)
    self.UIRoot:SetSpecialIconShow(false)
    return
  end
  local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
  if Logic_ColorShapeUtils.CheckIsColorShapeItemId(nItemId) then
    local nShowIcon = Logic_ColorShapeUtils.GetColorShapeItemShowIcon(nItemId)
    node_commonItem:SetIconFromPath(nShowIcon)
  end
end
function Collect_Library_Clothe_Item_UIBP:OnClickButton()
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  if collect_encryption_module:IsEncryptionSeries(self.data.Version, self.data.Time) then
    ShowNotice(4492)
  end
  local Collect_Library_Clothe_UIBP = self:GetLoopScrollBoxParentUI()
  Collect_Library_Clothe_UIBP:OnClickedCollection()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CCollect_Library_Clothe_Item_UIBP = class(ui_base, nil, Collect_Library_Clothe_Item_UIBP)
return CCollect_Library_Clothe_Item_UIBP