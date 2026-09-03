local logic_main_city_achievement_task_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_achievement_task_report")
local store_supply_switcher = {}
local bUseV280 = true
function store_supply_switcher:OnInitialize()
  store_supply_switcher.__super.OnInitialize(self)
  self.StoreFirstShow = true
  self.SupplyFirstShow = true
end
function store_supply_switcher:HideStore()
  self.StoreFirstShow = true
end
function store_supply_switcher:HideSupply()
  self.SupplyFirstShow = true
end
function store_supply_switcher:OpenStore(param)
  UIManager.ShowUI(UIManager.UI_Config.NewStoreSystem, StoreConst.store_tab, param)
  self.StoreFirstShow = false
  logic_main_city_achievement_task_report.ReportOpenShopInMainCity()
end
function store_supply_switcher:CloseStore()
  UIManager.CloseUI(UIManager.UI_Config.NewStoreSystem)
end
function store_supply_switcher:OpenSupply(jumpInfo)
  if GlobalData.IsJapanOrKorea() then
    UIManager.ShowUI(UIManager.UI_Config.NewSupplySystemJK, StoreConst.supply_tab, jumpInfo)
  else
    UIManager.ShowUI(UIManager.UI_Config.NewSupplySystem, StoreConst.supply_tab, jumpInfo)
  end
  logic_main_city_achievement_task_report.ReportOpenShopInMainCity()
end
function store_supply_switcher:CloseSupply()
  if UIManager.GetUI(UIManager.UI_Config.NewSupplySystem) then
    UIManager.CloseUI(UIManager.UI_Config.NewSupplySystem)
  end
  if UIManager.GetUI(UIManager.UI_Config.NewSupplySystemJK) then
    UIManager.CloseUI(UIManager.UI_Config.NewSupplySystemJK)
  end
end
function store_supply_switcher:OpenGiveStore(param)
  UIManager.ShowUI(UIManager.UI_Config.GiveStoreSystem, StoreConst.give_tab, param)
  self.StoreFirstShow = false
end
function store_supply_switcher:GetSupplySystem()
  local frame
  frame = self:_GetSupplyWorkShop()
  if frame == nil then
    frame = UIManager.GetUI(UIManager.UI_Config.NewSupplySystem)
    if frame == nil then
      frame = UIManager.GetUI(UIManager.UI_Config.NewSupplySystemJK)
    end
  end
  return frame
end
function store_supply_switcher:_GetSupplyWorkShop()
  local frame
  frame = UIManager.GetUI(UIManager.UI_Config.NewSupplyWorkshop)
  if frame == nil then
    frame = UIManager.GetUI(UIManager.UI_Config.NewSupplyWorkshopJK)
  end
  return frame
end
function store_supply_switcher:GetStoreSystem()
  local frame
  frame = UIManager.GetUI(UIManager.UI_Config.NewStoreSystem)
  return frame
end
function store_supply_switcher:GetGiveStore()
  local frame
  frame = UIManager.GetUI(UIManager.UI_Config.GiveStoreSystem)
  return frame
end
function store_supply_switcher:IsInStoreSupplySystem()
  return self:GetStoreSystem() or self:GetSupplySystem() or self:_GetSupplyWorkShop() or self:GetGiveStore()
end
function store_supply_switcher:SetUseNewStoreFlag(bOpen)
  bUseV280 = bOpen
end
function store_supply_switcher:GetUseNewStoreFlag()
  return bUseV280
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CStoreSupplySwitcher = class(CModuleBase, nil, store_supply_switcher)
return CStoreSupplySwitcher