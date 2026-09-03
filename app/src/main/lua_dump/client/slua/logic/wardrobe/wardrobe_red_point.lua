local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local Weapon = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
local Vehicle = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Vehicle
local C_Quick_Msg = "quickMsg"
local wardrobe_red_point = {}
function wardrobe_red_point:DefineAndResetData()
  self.EntranceRedDot = nil
  self.RedDot = nil
  self.res2TabIdCache = {}
  self.NEW_MARK = true
  self.C_Wardrobe_RedPoint_Style = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item01.Reddot_Anchor_Item01"
  local ScriptHelperEngine = import("ScriptHelperEngine")
  self.IsLowMemoryDevice = ScriptHelperEngine.IsLowMemoryDevice()
end
function wardrobe_red_point:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_CHANGE, self.OnItemChange, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_QUICK_MESSAGE_NEW, self.OnQuickMessageNew, self)
  self:AddCommonEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_SYSTEM_LOGIN, self.OnRedPointReddy, self)
  self:InitPageSwitch()
end
function wardrobe_red_point:OnLogin(bReLogin)
  print(bWriteLog and "redpoint data OnLogin")
  if LobbySystem.roleData.depot then
    self:InitData()
  end
end
function wardrobe_red_point:OnPreSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Lobby and not GameStatus.IsInLobbyOrMainCity() then
    local WardrobeUtils = require("client.slua.logic.wardrobe.wardrobe_utils")
    WardrobeUtils.ClearSubTabs()
  end
end
function wardrobe_red_point:OnLogOut()
  self.EntranceRedDot = nil
  self.RedDot = nil
  self.res2TabIdCache = nil
end
function wardrobe_red_point:GetWardrobeRedData()
  if self.EntranceRedDot == nil or not next(self.EntranceRedDot) then
    local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
    local defaultData = {
      newCount = 0,
      desc = reddot_macro.SystemName.Wardrobe,
      subID = 1,
      category = reddot_macro.Category.NewArrivals
    }
    local super_data = require("common.super_data")
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    self.EntranceRedDot = super_data.CreateSuperData(defaultData)
    reddot_manager:Regist(self.EntranceRedDot)
  end
  return self.EntranceRedDot
end
function wardrobe_red_point:ShowWardrobeRedData()
  local redPoint = self:GetWardrobeRedData()
  if redPoint.newCount > 0 then
    return
  end
  redPoint.newCount = 1
end
function wardrobe_red_point:HideWardrobeRedData()
  local redPoint = self:GetWardrobeRedData()
  if redPoint.newCount <= 0 then
    return
  end
  redPoint.newCount = 0
end
function wardrobe_red_point:UpdateOutSideRedPoint()
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetData(true)
  local red = false
  local subTabMap
  for _, v in pairs(data) do
    if v.isNew and not self:IsHighLevelItem(v.resID, v.insID) then
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local itemData = CDataTable.GetTableData("Item", v.resID)
      if itemData then
        local page = itemData.WardrobeMainTab
        local tabID = itemData.WardrobeTab
        if page == Weapon then
          red = true
          break
        end
        if not subTabMap then
          subTabMap = {}
          local WardrobeUtils = require("client.slua.logic.wardrobe.wardrobe_utils")
          local subTabConfig = WardrobeUtils.GetSubTabConfig()
          for _, subtab in pairs(subTabConfig) do
            for _, v in pairs(subtab.subTabs) do
              subTabMap[v.subTabID] = true
            end
          end
        end
        if tabID ~= 0 and subTabMap[tabID] then
          log_tree("wardrobe_red_point:UpdateOutSideRedPoint item", v)
          red = true
          break
        end
      end
    end
  end
  log(bWriteLog and "wardrobe_red_point:UpdateOutSideRedPoint " .. tostring(red))
  if red then
    self:ShowWardrobeRedData()
  else
    self:HideWardrobeRedData()
  end
end
function wardrobe_red_point:OnRedPointReddy()
  log(bWriteLog and "wardrobe_red_point:OnRedPointReddy")
  self:AddTimerOnce(0, function()
    self:UpdateOutSideRedPoint()
  end)
end
function wardrobe_red_point:GetPage(page)
  self:InitData()
  return self.RedDot:GetSubNode(page)
end
function wardrobe_red_point:GetTab(tabId)
  self:InitData()
  if self.subTabMap then
    return self.subTabMap[tabId]
  else
    return nil
  end
end
function wardrobe_red_point:GetWeaponPage()
  return self:GetPage(Weapon)
end
function wardrobe_red_point:GetWeaponType(weaponType)
  return self:GetWeaponPage():GetSubNode(weaponType)
end
function wardrobe_red_point:GetVehiclePage()
  return self:GetPage(Vehicle)
end
function wardrobe_red_point:GetVehicleType(vehicleType)
  return self:GetVehiclePage():GetSubNode(vehicleType)
end
function wardrobe_red_point:GetTabByResId(resId)
  local tab = self:GetTabIdByRes(resId)
  if tab and 0 < tab then
    return self:GetTab(tab)
  end
  return nil
end
function wardrobe_red_point:GetTabByWardrobeTab(wardrobeTab)
  return self:GetTab(wardrobeTab)
end
function wardrobe_red_point:Touch(insID, item)
  if item then
    local tab = self:GetTabByResId(item.resID)
    if tab == nil then
      log_warning("Cannot GetTabByResId:" .. item.resID)
      return false
    end
    return tab:CheckInstance(insID)
  end
  return false
end
function wardrobe_red_point:UpdateAllRedPoint()
  log(bWriteLog and "wardrobe_red_point:OnHallDepotDataInit")
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetData()
  for _, v in pairs(data) do
    if v.isNew and not self:IsHighLevelItem(v.resID, v.insID) then
      local tab = self:GetTabByResId(v.resID)
      if tab then
        tab:SetInstance(v.insID)
      end
    end
  end
  self:SetQuickMsgReddot()
end
function wardrobe_red_point:IsHighLevelItem(resId, insID)
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  if LogicMultiItemModule:IsWardRobeMultiLevelItem(resId) and LogicMultiItemModule:CheckIsHeightLevelItem(resId) then
    log(bWriteLog and string.format("wardrobe_red_point:IsHighLevelItem instID = %s", insID))
    local WardrobeNewHandler = require("client.network.Protocol.WardrobeNewHandler")
    WardrobeNewHandler.send_select_item(tonumber(insID))
    return true
  end
  return false
end
function wardrobe_red_point:InitData()
  if not self.RedDot then
    self:CreateRedData()
    self:UpdateAllRedPoint()
  end
end
function wardrobe_red_point:RemoveAllWidget()
  if self.RedDot then
    self.RedDot:RemoveAllWidget()
  end
end
function wardrobe_red_point:CreateRedData()
  local redPointTree = {
    [C_Quick_Msg] = 1
  }
  local red_point_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.red_point_manager)
  self.RedDot = red_point_manager:GenerateRedPointTree(redPointTree, "Wardrobe")
  self.RedDot:BindEvent(function(count)
    if count <= 0 then
      self:HideWardrobeRedData()
    else
      self:ShowWardrobeRedData()
    end
  end)
  self.subTabMap = {}
  local WardrobeUtils = require("client.slua.logic.wardrobe.wardrobe_utils")
  local tabConfig = WardrobeUtils.GetTabConfig()
  local subTabConfig = WardrobeUtils.GetSubTabConfig()
  local taxonomiesPage = {
    [Weapon] = true,
    [Vehicle] = true
  }
  for _, pageConfig in pairs(tabConfig) do
    if not taxonomiesPage[pageConfig.pageId] then
      local page = {}
      local subTabs = subTabConfig[pageConfig.pageId].subTabs
      for _, subPageConfig in pairs(subTabs) do
        page[subPageConfig.subTabID] = 1
      end
      local branch = red_point_manager:GenerateRedPointTree(page, pageConfig.pageId)
      self.RedDot:MergeChildNode(branch)
      for subTab, element in pairs(branch:GetSubNodes()) do
        self.subTabMap[subTab] = element
      end
    end
  end
  local weapon = WardrobeUtils.GetTabStructure(Weapon)
  local weaponBranch = red_point_manager:GenerateRedPointTree(weapon, Weapon)
  self.RedDot:MergeChildNode(weaponBranch)
  local vehicle = WardrobeUtils.GetTabStructure(Vehicle)
  local vehicleBranch = red_point_manager:GenerateRedPointTree(vehicle, Vehicle)
  self.RedDot:MergeChildNode(vehicleBranch)
  for _, parentElement in pairs(weaponBranch:GetSubNodes()) do
    for subTab, element in pairs(parentElement:GetSubNodes()) do
      self.subTabMap[subTab] = element
    end
  end
  for _, parentElement in pairs(vehicleBranch:GetSubNodes()) do
    for subTab, element in pairs(parentElement:GetSubNodes()) do
      self.subTabMap[subTab] = element
    end
  end
  self.quickMsg = {msgTabNew = false, signTabNew = false}
end
function wardrobe_red_point:InitPageSwitch()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local pageAndTabData = logic_wardrobe:GetCurrentPageAndTabData()
  local pageChange = false
  self:AddDataListener(pageAndTabData, "pageId", function(oldValue, value)
    log(bWriteLog and string.format("wardrobe_red_point:InitPageSwitch oldValue = %s", oldValue))
    if oldValue ~= -1 then
      pageChange = true
    end
  end)
  self:AddDataListener(pageAndTabData, "tabId", function(oldValue, value)
    log(bWriteLog and "AddDataListener tabId oldValue:" .. tostring(oldValue))
    log(bWriteLog and "AddDataListener tabId value:" .. tostring(value))
    log(bWriteLog and "AddDataListener tabId pageChange:" .. tostring(pageChange))
    if oldValue ~= "" then
      if pageChange then
        pageChange = false
      else
        self:OnSelectTab(oldValue)
        if value ~= "" then
          self:AddTimerOnce(0.5, function()
            self:OnSelectTab(value)
          end)
        end
      end
    end
  end)
end
function wardrobe_red_point:OnSelectTab(tabId)
  if tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_empty or tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag or tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_emoji_bubble or tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_interactive_action or tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_character_MVP_MOTION or tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_plane then
    return
  end
  self:ProcessOnSelectTab(tabId)
end
function wardrobe_red_point:ProcessOnSelectTab(tabId)
  if tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quickmessage then
    self:OnSelectQuickMessageTab()
    return
  end
  if tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quicksign then
    self:OnSelectQuickSignTab()
    return
  end
  local tab = self:GetTab(tabId)
  if not tab then
    log_error("Can't select tabId: " .. tostring(tabId))
    return
  end
  local instIds = {}
  for instId, _ in pairs(tab:GetInstances()) do
    instIds[tonumber(instId)] = true
  end
  tab:ClearInstances()
  log_tree("wardrobe_red_point:ProcessOnSelectTab select_item_list:", instIds)
  local RedpointHandler = require("client.network.Protocol.RedpointHandler")
  RedpointHandler.send_select_item_list(instIds)
  if tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_voucher then
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    local dueCoupons = CouponSystem.GetDepotCoupons()
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    local records = {}
    for _, v in pairs(dueCoupons) do
      if v.expireTS ~= 0 and v.expireTS < now + 604800 and not v.notified1Week then
        table.insert(records, {
          instid = tonumber(v.insID),
          type = 2
        })
        v.notified1Week = true
      end
    end
    if 0 < #records then
      local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
      WardRobeHandler.send_set_item_expired_notified(records)
    end
  end
end
function wardrobe_red_point:OnSelectSecondTab(tabId)
  local realTabId = tabId
  if tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag_pendant then
    realTabId = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag
  end
  if tabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_Wingman then
    realTabId = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_plane
  end
  local tab = self:GetTab(realTabId)
  if not tab then
    log_error("Can't selectBagTab realTabId: " .. tostring(realTabId))
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local instIds = {}
  for instId, _ in pairs(tab:GetInstances()) do
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(instId)
    if itemInfo ~= nil and itemInfo.subTabType == tabId then
      instIds[instId] = true
    end
  end
  for instId, _ in pairs(instIds) do
    tab:RemoveInstance(instId)
  end
  log_tree("wardrobe_red_point:OnSelectSecondTab select_item_list:", instIds)
  local RedpointHandler = require("client.network.Protocol.RedpointHandler")
  RedpointHandler.send_select_item_list(instIds)
end
function wardrobe_red_point:OnItemChange(eventID, eventType, changeList)
  self:InitData()
  for _, v in pairs(changeList) do
    local resId = v.res_id
    local insID = tonumber(v.instid)
    if not insID then
      return
    end
    local tab = self:GetTabByResId(resId)
    if tab then
      if v.isnew == 1 and not v.isRemoved and not self:IsHighLevelItem(resId, insID) then
        tab:SetInstance(insID)
      elseif (v.isRemoved or v.isnew ~= 1) and tab:CheckInstance(insID) then
        tab:RemoveInstance(insID)
      end
    end
  end
end
function wardrobe_red_point:ClearItemNew(insID)
  log(bWriteLog and string.format("wardrobe_red_point:ClearItemNew"))
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local item = WardrobeData:GetHallDepotItemDataByInsID(insID)
  if item then
    local tab = self:GetTabByResId(item.resID)
    if tab and tab:CheckInstance(insID) then
      tab:RemoveInstance(insID)
      log(bWriteLog and string.format("wardrobe_red_point:ClearItemNew instID = %s", insID))
      local WardrobeNewHandler = require("client.network.Protocol.WardrobeNewHandler")
      WardrobeNewHandler.send_select_item(tonumber(insID))
    end
  end
end
function wardrobe_red_point:ClearItemListNew(inst_id_list)
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local instIds = {}
  for _, v in pairs(inst_id_list) do
    local item = WardrobeData:GetHallDepotItemDataByInsID(v)
    if item then
      local tab = self:GetTabByResId(item.resID)
      if tab and tab:CheckInstance(v) then
        instIds[v] = true
        tab:RemoveInstance(v)
      end
    end
  end
  log_tree("wardrobe_red_point:ClearItemListNew select_item_list:", instIds)
  local RedpointHandler = require("client.network.Protocol.RedpointHandler")
  RedpointHandler.send_select_item_list(instIds)
end
function wardrobe_red_point:CheckAndClearMsgPackData()
  local page = self:GetPage(C_Quick_Msg)
  if not self.quickMsg.signTabNew and not self.quickMsg.msgTabNew then
    page:ClearInstances()
  end
  local TableUtil = require("common.table_util")
  local saveData = TableUtil.CopyTable(self.quickMsg)
  saveData.instances = TableUtil.CopyTable(page:GetInstances())
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.wardrobeQuickMsgReddot)
end
function wardrobe_red_point:OnQuickMessageNew(eventID, eventType, newActorList)
  self:InitData()
  local page = self:GetPage(C_Quick_Msg)
  local bIsShowQuickSignRedPoint = false
  for k, v in pairs(newActorList) do
    local actorData = CDataTable.GetTableData("VoiceActorCfg", v)
    if actorData then
      page:SetInstance(actorData.ActorItemID)
      if actorData.IsContainingSign then
        bIsShowQuickSignRedPoint = true
      end
    end
  end
  if next(newActorList) then
    self.quickMsg.msgTabNew = true
    if bIsShowQuickSignRedPoint then
      self.quickMsg.signTabNew = true
    end
  end
  local newCount = newActorList and 1 or 0
  local tabMsg = self:GetTab(wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quickmessage)
  tabMsg:SetRedPointCount(newCount)
  if bIsShowQuickSignRedPoint then
    local tabSign = self:GetTab(wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quicksign)
    tabSign:SetRedPointCount(newCount)
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TableUtil = require("common.table_util")
  local copiedTableToSave = TableUtil.CopyTable(self.quickMsg)
  PlayerPrefsSystem.SaveTableToFile_N(copiedTableToSave, PlayerPrefsSystem.ePlayerPrefsType.wardrobeQuickMsgReddot)
end
function wardrobe_red_point:SetQuickMsgReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local quickMsgSaved = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.wardrobeQuickMsgReddot) or {}
  if not self.quickMsg then
    self.quickMsg = {}
  end
  self.quickMsg.msgTabNew = quickMsgSaved.msgTabNew or false
  self.quickMsg.signTabNew = quickMsgSaved.signTabNew or false
  local instances = quickMsgSaved.instances or {}
  local page = self:GetPage(C_Quick_Msg)
  for k, _ in pairs(instances) do
    if self.quickMsg.msgTabNew or self.quickMsg.signTabNew then
      page:SetInstance(tonumber(k))
    end
    if self.quickMsg.msgTabNew then
      local tab = self:GetTab(wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quickmessage)
      tab:SetRedPointCount(1)
    end
    if self.quickMsg.signTabNew then
      local tab = self:GetTab(wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quicksign)
      tab:SetRedPointCount(1)
    end
  end
end
function wardrobe_red_point:OnSelectQuickMessageTab()
  if self.quickMsg.msgTabNew ~= false then
    self.quickMsg.msgTabNew = false
    self:CheckAndClearMsgPackData()
  end
  local tab = self:GetTab(wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quickmessage)
  tab:SetRedPointCount(0)
end
function wardrobe_red_point:OnSelectQuickSignTab()
  if self.quickMsg.signTabNew ~= false then
    self.quickMsg.signTabNew = false
    self:CheckAndClearMsgPackData()
  end
  local tab = self:GetTab(wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quicksign)
  tab:SetRedPointCount(0)
end
function wardrobe_red_point:OnAvatarPanelOpen()
  local avatarList = DataMgr.avatarData.activate_avatar_list
  for avatarId, v in pairs(avatarList) do
    local avatarCfg = CDataTable.GetTableData("AvatarInit", avatarId)
    if avatarCfg and avatarCfg.Sex == 0 then
      avatarList[avatarId] = nil
      local RedpointHandler = require("client.network.Protocol.RedpointHandler")
      RedpointHandler.send_select_avatar(avatarId)
    end
  end
  DataMgr.avatarData.activate_avatar_list = avatarList
end
function wardrobe_red_point:OnAvatarSelectSex(sex)
  local avatarList = DataMgr.avatarData.activate_avatar_list
  for avatarId, v in pairs(avatarList) do
    local avatarCfg = CDataTable.GetTableData("AvatarInit", avatarId)
    if avatarCfg and avatarCfg.Sex == sex then
      avatarList[avatarId] = nil
      local RedpointHandler = require("client.network.Protocol.RedpointHandler")
      RedpointHandler.send_select_avatar(avatarId)
    end
  end
  DataMgr.avatarData.activate_avatar_list = avatarList
end
function wardrobe_red_point:GetTabIdByRes(resId)
  if self.res2TabIdCache[resId] then
    return self.res2TabIdCache[resId]
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = CDataTable.GetTableData("Item", resId)
  if not itemData then
    return
  end
  local page = itemData.WardrobeMainTab
  local tabID = itemData.WardrobeTab
  if page == Weapon then
    local weaponID = resId
    local cfg = CDataTable.GetTableData("WeaponSkinMapping", resId)
    if cfg then
      weaponID = cfg.WeaponID
    end
    tabID = weaponID
    if tabID == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag_pendant then
      tabID = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag
    end
    if tabID == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_Wingman then
      tabID = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_plane
    end
    if not self.IsLowMemoryDevice then
      self.res2TabIdCache[resId] = tabID
    end
    return tabID
  elseif self:GetTab(tabID) then
    if not self.IsLowMemoryDevice then
      self.res2TabIdCache[resId] = tabID
    end
    return tabID
  end
  return 0
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, wardrobe_red_point)
return CModuleTemplate