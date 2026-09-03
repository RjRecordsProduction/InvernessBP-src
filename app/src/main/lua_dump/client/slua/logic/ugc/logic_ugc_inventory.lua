local logic_ugc_inventory = {}
local UGC_Inventory = require("client.slua.logic.ugc.ugc_Inventory")
function logic_ugc_inventory:ctor()
  self.SettingList = nil
  self.SelectTab = 1
  self.SelectSubTab = 1
  self.personal_depot = nil
  self.OldPersonalDepot = nil
  self.defaultItem = {
    [30101] = 301010003,
    [30102] = 301020003
  }
  self.bIsOwnCheckedMap = {}
end
function logic_ugc_inventory:SetOwnChecked(bool, tabID)
  if not self.bIsOwnCheckedMap then
    self.bIsOwnCheckedMap = {}
  end
  local key = tabID or self:GetSelectTabID()
  self.bIsOwnCheckedMap[key] = bool
end
function logic_ugc_inventory:GetOwnChecked(tabID)
  if not self.bIsOwnCheckedMap then
    self.bIsOwnCheckedMap = {}
  end
  local key = tabID or self:GetSelectTabID()
  return self.bIsOwnCheckedMap[key] or false
end
function logic_ugc_inventory:InventoryReq()
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_personal_setting_get_req()
end
function logic_ugc_inventory:InventoryRsp(ugc_personal_setting, ugc_personal_depot)
  if not ugc_personal_setting and not ugc_personal_depot then
    log(bWriteLog and "logic_ugc_inventory:InventoryRsp: invalid parameters")
    return
  end
  self.personal_depot = ugc_personal_depot
  self.SettingList = ugc_personal_setting
  for subtabID, defaultItemId in pairs(self.defaultItem) do
    if ugc_personal_depot and ugc_personal_depot[defaultItemId] then
      self.SettingList[301] = self.SettingList[301] or {}
      self.SettingList[301][subtabID] = self.SettingList[301][subtabID] or {}
      if not next(self.SettingList[301][subtabID]) then
        table.insert(self.SettingList[301][subtabID], defaultItemId)
        self:SaveOldPersonalDepot(defaultItemId)
        local res_ids = {}
        table.insert(res_ids, defaultItemId)
        local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
        UGCPassHandler.send_ugc_personal_setting_set_req(301, subtabID, res_ids)
      end
    end
  end
  self:SavePersonalDepot()
end
function logic_ugc_inventory:FindTabIndexByTabId(tabId)
  for tabIndex, tabData in pairs(UGC_Inventory.InventoryList) do
    if tabData.TabID == tabId then
      return tabIndex
    end
  end
  return nil
end
function logic_ugc_inventory:FindSubTabIndexBySubTabId(tabIndex, subTabId)
  local tabData = UGC_Inventory.InventoryList[tabIndex]
  if tabData then
    for subTabIndex, subTabData in pairs(tabData) do
      if type(subTabIndex) == "number" and subTabData.SubTabID == subTabId then
        return subTabIndex
      end
    end
  end
  return nil
end
function logic_ugc_inventory:SettingInventoryReq(inst_id, bool)
  local maintype = self:GetSelectTabID()
  local subtype = self:GetSelectSubTabID()
  local res_ids = {}
  if bool then
    if not inst_id then
      log(bWriteLog and "logic_ugc_inventory:SettingInventoryReq Ues inst_id is nil !!")
      return
    end
    log(bWriteLog and "logic_ugc_inventory:SettingInventoryReq Ues inst_id: " .. inst_id)
    table.insert(res_ids, inst_id)
  else
    res_ids = {}
  end
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_personal_setting_set_req(maintype, subtype, res_ids)
end
function logic_ugc_inventory:SettingInventoryRsp(maintype, subtype, subtype_list)
  if not self.SettingList then
    self.SettingList = {}
  end
  if not self.SettingList[maintype] then
    self.SettingList[maintype] = {}
  end
  if not subtype_list or not next(subtype_list) then
    self.SettingList[maintype][subtype] = {}
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INVENTORY_SET_ITEM, false)
  else
    self.SettingList[maintype][subtype] = subtype_list
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INVENTORY_SET_ITEM, true)
  end
end
function logic_ugc_inventory:GetInventoryList()
  if self.SettingList then
    return self.SettingList
  end
end
function logic_ugc_inventory:GetSubTabList()
  if self.SettingList and self.SettingList[self.SelectTab] then
    return self.SettingList[self.SelectTab]
  end
end
function logic_ugc_inventory:SetSelectTab(tab)
  if not tab then
    self.SelectTab = 1
  else
    self.SelectTab = tab
  end
end
function logic_ugc_inventory:SetSelectSubTab(subtab)
  if not subtab then
    self.SelectSubTab = 1
  else
    self.SelectSubTab = subtab
  end
end
function logic_ugc_inventory:GetSelectTab()
  return self.SelectTab
end
function logic_ugc_inventory:GetSelectTabID()
  return UGC_Inventory.InventoryList[self.SelectTab].TabID
end
function logic_ugc_inventory:GetSelectSubTab()
  return self.SelectSubTab
end
function logic_ugc_inventory:GetSelectSubTabID()
  return UGC_Inventory.InventoryList[self.SelectTab][self.SelectSubTab].SubTabID
end
function logic_ugc_inventory:SavePersonalDepot()
  if not self.personal_depot then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.OldPersonalDepot = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCInventoryRedDot) or {}
  local hasNewItems = false
  local isFirstLoad = not next(self.OldPersonalDepot)
  for itemId, itemData in pairs(self.personal_depot) do
    if not self.OldPersonalDepot[itemId] then
      self.OldPersonalDepot[itemId] = {isNew = true}
      hasNewItems = true
    end
    if self:IsDefaultItem(itemId) then
      self.OldPersonalDepot[itemId].isNew = false
    end
  end
  for itemId, itemData in pairs(self.OldPersonalDepot) do
    if not self.personal_depot[itemId] and itemData.isNew then
      itemData.isNew = false
      hasNewItems = true
    end
  end
  if isFirstLoad or hasNewItems then
    PlayerPrefsSystem.SaveTableToFile_N(self.OldPersonalDepot, PlayerPrefsSystem.ePlayerPrefsType.eUGCInventoryRedDot)
  end
  self.  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INVENTORY_SELECT_TAB)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INVENTORY_SET_NEWITEM)
end
function logic_ugc_inventory:HasNewItems()
  return self.hasNewItems
end
function logic_ugc_inventory:SaveOldPersonalDepot(itemId)
  if not itemId or not self.OldPersonalDepot then
    return
  end
  local item = self.OldPersonalDepot[itemId]
  if not item or not item.isNew then
    return
  end
  item.isNew = false
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.OldPersonalDepot, PlayerPrefsSystem.ePlayerPrefsType.eUGCInventoryRedDot)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INVENTORY_SET_NEWITEM)
end
function logic_ugc_inventory:IsDefaultItem(itemId)
  for _, defaultId in pairs(self.defaultItem) do
    if itemId == defaultId then
      return true
    end
  end
  return false
end
function logic_ugc_inventory:GetSubTabData()
  local TimeUtil = require("client.common.time_util")
  local SelectTabID = self:GetSelectTabID()
  local SelectSubTabID = self:GetSelectSubTabID()
  local List = (self.SettingList or {})[SelectTabID] and self.SettingList[SelectTabID][SelectSubTabID] or {}
  local sortedData = {}
  local DataList = CDataTable.GetTable(UGC_Inventory.InventoryList[self.SelectTab][self.SelectSubTab].DataName)
  local NewDataList = {}
  for k, v in pairs(DataList) do
    if type(k) == "number" then
      table.insert(NewDataList, v)
    end
  end
  for k, v in pairs(NewDataList) do
    local Item = CDataTable.GetTableData("Item", v.ID)
    local IsUsing = false
    local cnt, expire_time
    local Now = false
    local isNew = false
    if List then
      for _, item in ipairs(List) do
        if item == v.ID then
          IsUsing = true
          break
        end
      end
    end
    if self.personal_depot and self.personal_depot[v.ID] then
      cnt = self.personal_depot[v.ID].cnt
      expire_time = self.personal_depot[v.ID].expire_time
      Now = true
    end
    if self.OldPersonalDepot and self.OldPersonalDepot[v.ID] then
      isNew = self.OldPersonalDepot[v.ID].isNew
    end
    if v.IsShow == 1 or Now then
      table.insert(sortedData, {
        ID = v.ID,
        Name = v.Name,
        sort = v.sort,
        LoopAnimation = v.LoopAnimation,
        InfoCardBluprint = v.InfoCardBluprint,
        InfoCardBackground = v.InfoCardBackground,
        InterfaceBluprint = v.InterfaceBluprint,
        InterfaceBackground = v.InterfaceBackground,
        GetLink = v.GetLink,
        GetString = v.GetString,
        StartLinkTime = v.StartLinkTime,
        EndLinkTime = v.EndLinkTime,
        WidgetPath = v.WidgetPath,
        WidgetPath_L = v.WidgetPath_L,
        WidgetPath_R = v.WidgetPath_R,
        IsUsing = IsUsing,
        cnt = cnt,
        expire_time = expire_time,
        Now = Now,
        ItemQuality = Item.ItemQuality,
        ItemBigIcon = v.ShowIcon,
        isNew = isNew,
        SelectTabID = SelectTabID,
              })
      if v.StartLinkTime and v.StartLinkTime ~= "" and v.EndLinkTime and v.EndLinkTime ~= "" then
        local Start = TimeUtil.TimeStringToUnixstamp(v.StartLinkTime)
        local End = TimeUtil.TimeStringToUnixstamp(v.EndLinkTime)
        local IsHidenLink = TimeUtil.UnixTimeBetween(Start, End)
        if IsHidenLink ~= 0 then
          sortedData[#sortedData].GetLink = ""
        end
      end
    end
  end
  table.sort(sortedData, function(a, b)
    if a.IsUsing and not b.IsUsing then
      return true
    elseif not a.IsUsing and b.IsUsing then
      return false
    end
    if a.Now and not b.Now then
      return true
    elseif not a.Now and b.Now then
      return false
    end
    return a.sort < b.sort
  end)
  return sortedData
end
function logic_ugc_inventory:NowGetList()
  local List = self:GetSubTabData()
  local NowList = {}
  for k, v in pairs(List) do
    if v.Now then
      table.insert(NowList, v)
    end
  end
  return NowList
end
function logic_ugc_inventory:HasNewItemsInTab(TabID)
  if not self.OldPersonalDepot or not TabID then
    return
  end
  for k, v in pairs(self.OldPersonalDepot) do
    if v.isNew then
      local NowTab = self:GetTabIDDigits(k)
      if NowTab == TabID then
        return true
      end
    end
  end
  return false
end
function logic_ugc_inventory:HasNewItemsAllTab()
  if not self.OldPersonalDepot then
    return
  end
  for k, v in pairs(self.OldPersonalDepot) do
    if v.isNew then
      return true
    end
  end
  return false
end
function logic_ugc_inventory:HasNewItemsInSubTab(SubTabID)
  if not self.OldPersonalDepot or not SubTabID then
    return
  end
  for k, v in pairs(self.OldPersonalDepot) do
    if v.isNew then
      local NowSubTab = self:GetSubTabIDDigits(k)
      if NowSubTab == SubTabID then
        return true
      end
    end
  end
  return false
end
function logic_ugc_inventory:GetTabIDDigits(itemId)
  local idStr = tostring(itemId or "")
  local firstThree = string.sub(idStr, 1, 3)
  return tonumber(firstThree) or 0
end
function logic_ugc_inventory:GetSubTabIDDigits(itemId)
  local idStr = tostring(itemId or "")
  local firstThree = string.sub(idStr, 1, 5)
  return tonumber(firstThree) or 0
end
function logic_ugc_inventory:CheckTabIdIsInventory(tabId)
  if type(tabId) ~= "number" then
    return false
  end
  if not UGC_Inventory or not UGC_Inventory.InventoryList then
    return false
  end
  for _, tabData in pairs(UGC_Inventory.InventoryList) do
    if tabData.TabID == tabId then
      return true
    end
  end
  return false
end
function logic_ugc_inventory:GetPersonalData(ID)
  if self.personal_depot[ID] then
    return self.personal_depot[ID]
  end
end
function logic_ugc_inventory:GetInforCardData(ID)
  if not ID then
    return nil
  end
  return CDataTable.GetTableData(UGC_Inventory.DataNameList.Dress_HomePageConfig, ID)
end
function logic_ugc_inventory:GetUpRoomTipsData(ID)
  if not ID then
    return nil
  end
  return CDataTable.GetTableData(UGC_Inventory.DataNameList.Dress_UpInRoomNotice, ID)
end
function logic_ugc_inventory:AddEffectSkinByCreateChildWindow(parentUIBase, bgPath, parentPanel, aniName, extraData)
  if not parentUIBase.effectRoots then
    parentUIBase.effectRoots = {}
  end
  if parentUIBase.effectRoots[parentPanel] then
    parentUIBase.effectRoots[parentPanel]:Close()
    parentUIBase.effectRoots[parentPanel] = nil
  end
  local pak_util = require("client.common.pak_util")
  if bgPath and bgPath ~= "" and pak_util.IsFileExist(bgPath) then
    local uiConfig = UIManager.UI_Config.UGC_Inventory_EffectSkin_Item_UIBP
    local childUI = parentUIBase:CreateChildWindowWithBpPath(parentPanel, uiConfig, bgPath, aniName, extraData)
    parentUIBase.effectRoots[parentPanel] = childUI
    return childUI
  else
    log(bWriteLog and "logic_ugc_inventory.AddEffectSkinByCreateChildWindow Error bgPath" .. tostring(bgPath))
  end
  return nil
end
function logic_ugc_inventory:AddUpBPEffectByCreateChildWindow(parentUIBase, bgPath, parentPanel, IsLoop, playerName, ShowKey)
  if not parentUIBase.effectRoots then
    parentUIBase.effectRoots = {}
  end
  if parentUIBase.effectRoots[parentPanel] then
    parentUIBase.effectRoots[parentPanel]:Close()
    parentUIBase.effectRoots[parentPanel] = nil
  end
  local pak_util = require("client.common.pak_util")
  if bgPath and bgPath ~= "" and pak_util.IsFileExist(bgPath) then
    local uiConfig = UIManager.UI_Config.UGC_Inventory_UpInRoomEffect_Item_UIBP
    local childUI = parentUIBase:CreateChildWindowWithBpPath(parentPanel, uiConfig, bgPath, IsLoop, playerName, ShowKey)
    parentUIBase.effectRoots[parentPanel] = childUI
    return childUI
  else
    log(bWriteLog and "logic_ugc_inventory.AddUpBPEffectByCreateChildWindow Error bgPath" .. tostring(bgPath))
  end
  return nil
end
function logic_ugc_inventory:GetDownloadList(Data)
  if not Data or not Data.ID then
    log(bWriteLog and "logic_ugc_inventory:GetDownloadList Data or Data.ID is nil")
    return {}
  end
  local tDownloadList = {
    Data.ID
  }
  local tempListForCheck = {
    [Data.ID] = true
  }
  local InfoCardBluprint = Data.InfoCardBluprint
  if InfoCardBluprint and InfoCardBluprint ~= "" and not tempListForCheck[InfoCardBluprint] then
    table.insert(tDownloadList, InfoCardBluprint)
    tempListForCheck[InfoCardBluprint] = true
  end
  local InfoCardBackground = Data.InfoCardBackground
  if InfoCardBackground and InfoCardBackground ~= "" and not tempListForCheck[InfoCardBackground] then
    table.insert(tDownloadList, InfoCardBackground)
    tempListForCheck[InfoCardBackground] = true
  end
  local InterfaceBluprint = Data.InterfaceBluprint
  if InterfaceBluprint and InterfaceBluprint ~= "" and not tempListForCheck[InterfaceBluprint] then
    table.insert(tDownloadList, InterfaceBluprint)
    tempListForCheck[InterfaceBluprint] = true
  end
  local InterfaceBackground = Data.InterfaceBackground
  if InterfaceBackground and InterfaceBackground ~= "" and not tempListForCheck[InterfaceBackground] then
    table.insert(tDownloadList, InterfaceBackground)
    tempListForCheck[InterfaceBackground] = true
  end
  local WidgetPath = Data.WidgetPath
  if WidgetPath and WidgetPath ~= "" and not tempListForCheck[WidgetPath] then
    table.insert(tDownloadList, WidgetPath)
    tempListForCheck[WidgetPath] = true
  end
  local WidgetPath_L = Data.WidgetPath_L
  if WidgetPath_L and WidgetPath_L ~= "" and not tempListForCheck[WidgetPath_L] then
    table.insert(tDownloadList, WidgetPath_L)
    tempListForCheck[WidgetPath_L] = true
  end
  local WidgetPath_R = Data.WidgetPath_R
  if WidgetPath_R and WidgetPath_R ~= "" and not tempListForCheck[WidgetPath_R] then
    table.insert(tDownloadList, WidgetPath_R)
    tempListForCheck[WidgetPath_R] = true
  end
  local ItemBigIcon = Data.ItemBigIcon
  if ItemBigIcon and ItemBigIcon ~= "" and not tempListForCheck[ItemBigIcon] then
    table.insert(tDownloadList, ItemBigIcon)
    tempListForCheck[ItemBigIcon] = true
  end
  log(bWriteLog and string.format("logic_ugc_inventory:GetDownloadList itemId=%s, downloadList count=%s", tostring(Data.ID), tostring(#tDownloadList)))
  return tDownloadList
end
function logic_ugc_inventory:AutoDownloadResource(Data, callback, bForce)
  if not Data or not Data.ID then
    log(bWriteLog and "logic_ugc_inventory:AutoDownloadResource Data or Data.ID is nil")
    if callback then
      callback(false, "Invalid parameters")
    end
    return false
  end
  local downloadList = self:GetDownloadList(Data)
  if #downloadList == 0 then
    log(bWriteLog and "logic_ugc_inventory:AutoDownloadResource downloadList is empty")
    if callback then
      callback(true, "No resources to download")
    end
    return true
  end
  local pak_util = require("client.common.pak_util")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, downloadList)
  local bDownloaded = state == PufferConst.ENUM_DownloadState.Done
  if bDownloaded and not bForce then
    if callback then
      callback(true, "Resources already downloaded")
    end
    return true
  end
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local onDownloadComplete = function(errCode, downloadType, keyList)
    if errCode == 0 or errCode == PufferConst.ENUM_DownloadErrorCode.Success then
      if callback then
        callback(true, "Download success")
      end
    elseif callback then
      callback(false, "Download failed: " .. tostring(errCode))
    end
  end
  local bSuccess = PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, downloadList, PufferTlog.Enum_TLog_From.UGCInventory, onDownloadComplete, {bAutoDownload = true})
  if not bSuccess then
    if callback then
      callback(false, "Download trigger failed")
    end
    return false
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_inventory = class(CModuleBase, nil, logic_ugc_inventory)
return Clogic_ugc_inventory