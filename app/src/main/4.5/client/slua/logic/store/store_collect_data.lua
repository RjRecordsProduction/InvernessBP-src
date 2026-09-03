local store_collect_data = {}
function store_collect_data:DefineAndResetData()
  self:ClearCollectData()
end
function store_collect_data:OnInitialize()
  self:AddTimer(30, function()
    if GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and "store_collect_data:OnInitialize RequestJumpMapInfo")
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      store_supply_manager:get_market_collect_jump_info_req()
      coroutine.yield(0.25)
      log(bWriteLog and "store_collect_data:OnInitialize GetCollectTipsJumpInfoReq")
      local StoreHandler = require("client.network.Protocol.StoreHandler")
      StoreHandler.send_get_market_collect_tips_jump_info_req()
    else
      log(bWriteLog and "store_collect_data:OnInitialize isn't in the lobby")
    end
  end)
end
function store_collect_data:OnLogOut()
  self.MarkPageID = nil
  self.CollectNumData = nil
  self.ReqCollectCache = nil
  self.SelfCollectMark = nil
  self.MyCollectionData = nil
  self.CollectReddotReq = false
  self.RequestCollectInfo = {}
  self.CollectJumpInfo = {}
  self.CollectTipJumpUrl = nil
  self.CollectTipJumpItemList = {}
end
function store_collect_data:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_JUMP, EVENTID_JUMP_GAME_URL_DOWNLOAD_BREAK, self.DownloadBreakJump, self)
end
function store_collect_data:ClearCollectData()
  self.MarkPageID = {}
  self.CollectNumData = {}
  self.SelfCollectMark = false
  self.MyCollectionData = {}
  self.CollectReddotReq = false
  self.RequestCollectInfo = {}
  self.CollectJumpInfo = {}
end
function store_collect_data:GetSelfCollectData()
  if not self.SelfCollectMark then
    local StoreHandler = require("client.network.Protocol.StoreHandler")
    StoreHandler.send_get_self_global_mcollect_data_req()
  end
end
function store_collect_data:RespondSelfCollectData(collect_tbl)
  if not self.CollectNumData then
    self.CollectNumData = {}
  end
  self.SelfCollectMark = true
  for itemID, num in pairs(collect_tbl) do
    self.CollectNumData[itemID] = num
  end
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT_DATA_UPDATED)
  self:RequestSavedCollectInfo()
end
function store_collect_data:GetCollectDataByPageId(page_id)
  if self.MarkPageID and self.MarkPageID[page_id] then
    return
  end
  log(bWriteLog and string.format("[HZQ][store_collect_data] store_collect_data:GetCollectDataByPageId(page_id = %s)", page_id))
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_global_mcollect_data_by_page_req(page_id)
end
function store_collect_data:RespondCollectData(page_id, collect_tbl)
  if not self.CollectNumData then
    self.CollectNumData = {}
  end
  if not self.MarkPageID then
    self.MarkPageID = {}
  end
  self.MarkPageID[page_id] = true
  for itemID, num in pairs(collect_tbl) do
    self.CollectNumData[itemID] = num
  end
end
function store_collect_data:ExistedCollectData(itemID)
  if not itemID then
    return false
  end
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local originID, state = multi_state_manager:GetOriginClothIDAndState(itemID)
  if originID and state ~= 1 then
    itemID = originID
  end
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    return false
  end
  if itemCfg.ItemType == ENUM_ITEM_TYPE.Weapon then
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local upgradeWeaponCfg = ItemUpgradeMgr:GetUpgradeCfg(itemID)
    if upgradeWeaponCfg then
      itemID = upgradeWeaponCfg.FavourateItemID
    end
  end
  if not self.CollectNumData or self.CollectNumData and self.CollectNumData[itemID] == nil then
    return false
  end
  return true
end
function store_collect_data:CanReqCollectData(itemID)
  if not self.ReqCollectCache then
    self.ReqCollectCache = {}
  end
  if not self.ReqCollectCache[itemID] then
    self.ReqCollectCache[itemID] = 1
    return true
  end
  return false
end
function store_collect_data:GetCollectCountByItemID(itemID, default)
  log(bWriteLog and "  store_collect_data:GetCollectCountByItemID. itemID: " .. tostring(itemID))
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local originID, state = multi_state_manager:GetOriginClothIDAndState(itemID)
  if originID and state ~= 1 then
    itemID = originID
  end
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    return 0
  end
  if IsEditor then
    local chars = {
      [0] = "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z",
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "+",
      "/",
      "="
    }
    local collect_info = require("client.slua.logic.store.collect_info")
    local collect_cnt = 0
    if itemCfg.ItemType == ENUM_ITEM_TYPE.Weapon then
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      local upgradeWeaponCfg = ItemUpgradeMgr:GetUpgradeCfg(itemID)
      if upgradeWeaponCfg then
        itemID = upgradeWeaponCfg.FavourateItemID
      end
    end
    local computer_name = Client.ComputerName() or ""
    local name = string.match(computer_name, "(%a_?%a+)-PC")
    if not name then
      name = computer_name
    else
      name = string.lower(name)
    end
    local calc_val = function(name)
      local name_len = #name
      local res = ""
      for i = 1, name_len, 3 do
        local idx1 = 64
        local idx2 = 64
        local idx3 = 64
        local idx4 = 64
        local a = string.byte(name, i, i)
        idx1 = a >> 2
        if i == name_len then
          idx2 = (a & 3) << 4
        elseif i + 1 == name_len then
          local b = string.byte(name, i + 1, i + 1)
          idx2 = (a & 3) << 4 | (b & 240) >> 4
          idx3 = (b & 15) << 2
        else
          local b = string.byte(name, i + 1, i + 1)
          local c = string.byte(name, i + 2, i + 2)
          idx2 = (a & 3) << 4 | (b & 240) >> 4
          idx3 = (b & 15) << 2 | (c & 192) >> 6
          idx4 = c & 63
        end
        res = res .. chars[idx1] .. chars[idx2] .. chars[idx3] .. chars[idx4]
      end
      log(bWriteLog and "[vico] collect key: " .. res)
      return res
    end
    local res = calc_val(name)
    collect_cnt = collect_info[res] or 0
    if collect_cnt ~= 0 then
      collect_cnt = collect_cnt + itemID % 100
      local bCollect = self:IsCollectedByItemID(itemID)
      if bCollect then
        collect_cnt = collect_cnt + 1
      end
      collect_cnt = tostring(collect_cnt)
    else
      collect_cnt = calc_val(computer_name)
    end
    return collect_cnt
  end
  if itemCfg.ItemType == ENUM_ITEM_TYPE.Weapon then
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local upgradeWeaponCfg = ItemUpgradeMgr:GetUpgradeCfg(itemID)
    if upgradeWeaponCfg then
      itemID = upgradeWeaponCfg.FavourateItemID
    end
  end
  default = default or 0
  if self.CollectNumData then
    return self.CollectNumData[itemID] or default
  end
  return default
end
function store_collect_data:UpdateCollectCount(itemList)
  if not itemList then
    return
  end
  if not self.CollectNumData then
    self.CollectNumData = {}
  end
  for itemID, data in pairs(itemList) do
    if not self.CollectNumData[itemID] then
      local net_data = data.count or 1
      self.CollectNumData[itemID] = data.result and net_data or 0
    else
      local var = data.result and 1 or -1
      if self.CollectNumData[itemID] + var < 0 then
        self.CollectNumData[itemID] = 0
      else
        self.CollectNumData[itemID] = self.CollectNumData[itemID] + var
      end
    end
  end
end
function store_collect_data:ReceivedCollectionData(data)
  log_tree("ReceivedCollectionData, data = ", data)
  LobbySystem.roleData.market_collect_  self.MyCollectionData = data
end
function store_collect_data:SetNeedRedPointTabData(need_red_point_table)
  self:AddReddotDataToList(need_red_point_table)
end
function store_collect_data:WriteNeedRedPointTabData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.NeedRedPointTab, PlayerPrefsSystem.ePlayerPrefsType.eCollectReddotData)
end
function store_collect_data:ReadNeedRedPointTabData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local datas = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectReddotData)
  self:AddReddotDataToList(datas)
end
function store_collect_data:AddReddotDataToList(datas)
  if not datas then
    return
  end
  if not self.NeedRedPointTab then
    self.NeedRedPointTab = {}
  end
  if datas and next(datas) then
    for k, v in pairs(datas) do
      if not self.NeedRedPointTab[k] then
        self.NeedRedPointTab[k] = v
      end
    end
  end
  self:SetCollectShowRedDotNum()
  self:WriteNeedRedPointTabData()
end
function store_collect_data:ClearReddot()
  self.NeedRedPointTab = {}
  self:WriteNeedRedPointTabData()
  self:ReadNeedRedPointTabData()
end
function store_collect_data:RemoveFormNeedRedPointTab(itemId)
  if self.NeedRedPointTab and itemId and self.NeedRedPointTab[itemId] then
    self.NeedRedPointTab[itemId] = nil
    local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
    store_reddot_manager:RemoveCollectShowRedDot(itemId)
    self:WriteNeedRedPointTabData()
  end
end
function store_collect_data:SetCollectShowRedDotNum()
  if not self.NeedRedPointTab then
    return
  end
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  store_reddot_manager:SetCollectShowRedDotNum(self.NeedRedPointTab)
end
function store_collect_data:MatchReddotList(itemId)
  if itemId and self.NeedRedPointTab and self.NeedRedPointTab[itemId] then
    return true
  end
  return false
end
function store_collect_data:GetCollectionData()
  return self.MyCollectionData or {}
end
function store_collect_data:IsCollectedByItemID(itemID)
  if self.MyCollectionData == nil or self.MyCollectionData.market_collect_item_table == nil then
    return false
  end
  local result = self.MyCollectionData.market_collect_item_table[itemID]
  if result ~= nil then
    return true
  else
    local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
    local originID, state = multi_state_manager:GetOriginClothIDAndState(itemID)
    if originID and state ~= 1 then
      return self.MyCollectionData.market_collect_item_table[originID] ~= nil
    end
    local Logic_DetailUtils = require("client.slua.logic.common.Logic_DetailUtils")
    local itemCfg = CDataTable.GetTableData("Item", itemID)
    local itemList, nUpLevelType = Logic_DetailUtils.GetMultiLevelItems(itemID, itemCfg.ItemType, true)
    local Enum_LevelUpItemType = Logic_DetailUtils.Enum_LevelUpItemType
    if nUpLevelType and nUpLevelType ~= Enum_LevelUpItemType.BackPack and next(itemList) then
      return self.MyCollectionData.market_collect_item_table[itemList[1]] ~= nil
    end
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local itemUpgradeCfg = ItemUpgradeMgr:GetUpgradeCfg(itemID)
    if not itemUpgradeCfg then
      return false
    end
    local minLevelItemID = itemUpgradeCfg.FavourateItemID
    if minLevelItemID ~= nil then
      return self.MyCollectionData.market_collect_item_table[minLevelItemID] ~= nil
    else
      return false
    end
  end
end
local noCollectTb = {
  [1407425] = 1,
  [1410752] = 1,
  [1407726] = 1,
  [1410945] = 1,
  [1407918] = 1
}
function store_collect_data:CanShowCollect(itemId, itemType, subType)
  if not itemType or not subType then
    local itemCfg = CDataTable.GetTableData("Item", itemId)
    if itemCfg and itemCfg.ItemType and itemCfg.ItemSubType then
      itemType = itemCfg.ItemType
      subType = itemCfg.ItemSubType
    else
      log(bWriteLog and "store_collect_data:CanShowCollect itemId is unvalid!")
      return false
    end
  end
  log(bWriteLog and string.format("store_collect_data:CanShowCollect itemId=%s, itemType=%s, subType=%s", tostring(itemId), tostring(itemType), tostring(subType)))
  if noCollectTb[itemId] then
    return false
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsThemeSystemTaskItem(itemId) then
    return false
  elseif ModelDisplayTypeHelper.IsVehicle(itemType) or ModelDisplayTypeHelper.IsParachute(itemType, subType) or ModelDisplayTypeHelper.IsGrenade(itemType, subType) then
    return true
  elseif ModelDisplayTypeHelper._IsSpecialModel(itemType, subType) and not ModelDisplayTypeHelper.IsHeirloomEuqip(itemId) and not ModelDisplayTypeHelper.IsLegendEuqip(itemId) then
    return true
  elseif ModelDisplayTypeHelper.IsPet(itemType) or ModelDisplayTypeHelper.IsPetSkin(itemType) == true then
    return true
  elseif ModelDisplayTypeHelper.IsLobbyScene(itemType) then
    return true
  elseif ModelDisplayTypeHelper.IsClothes(itemType) then
    return true
  elseif ModelDisplayTypeHelper.IsBag(itemType, subType) or ModelDisplayTypeHelper.IsNoLevelBag(itemType, subType) then
    return true
  elseif ModelDisplayTypeHelper.IsHelmet(itemType, subType) or ModelDisplayTypeHelper.IsNoLevelHelmet(itemType, subType) then
    return true
  end
  return false
end
function store_collect_data:SaveCollectInfo(itemId)
  if not self.RequestCollectInfo then
    self.RequestCollectInfo = {}
  end
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local originID, state = multi_state_manager:GetOriginClothIDAndState(itemId)
  if originID and state ~= 1 then
    itemId = originID
  end
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if not itemCfg then
    return 0
  end
  if itemCfg.ItemType == ENUM_ITEM_TYPE.Weapon then
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local upgradeWeaponCfg = ItemUpgradeMgr:GetUpgradeCfg(itemId)
    if upgradeWeaponCfg then
      itemId = upgradeWeaponCfg.FavourateItemID
    end
  end
  table.insert(self.RequestCollectInfo, itemId)
end
function store_collect_data:RequestSavedCollectInfo()
  if not self.RequestCollectInfo or not next(self.RequestCollectInfo) then
    return
  end
  if #self.RequestCollectInfo > 50 then
    local nowRequest = {}
    local leftRequest = {}
    table.move(self.RequestCollectInfo, 1, 50, 1, nowRequest)
    table.move(self.RequestCollectInfo, 51, #self.RequestCollectInfo, 1, leftRequest)
    local StoreHandler = require("client.network.Protocol.StoreHandler")
    StoreHandler.send_get_global_collect_data_by_itemlist_req(nowRequest)
    self.RequestCollectInfo = leftRequest
  else
    local StoreHandler = require("client.network.Protocol.StoreHandler")
    StoreHandler.send_get_global_collect_data_by_itemlist_req(self.RequestCollectInfo)
    self.RequestCollectInfo = {}
  end
end
function store_collect_data:ReceiveCollectTipsData(collect_jump_info)
  local sortSeqFunc = function(list)
    table.sort(list, function(a, b)
      if a.seq and b.seq then
        return a.seq > b.seq
      end
      return true
    end)
  end
  self.CollectJumpInfo = {}
  for itemId, data in pairs(collect_jump_info) do
    if data.seq then
      data.      table.insert(self.CollectJumpInfo, data)
    else
      sortSeqFunc(data)
      for _, subData in pairs(data) do
        if subData.begin_time and subData.end_time then
          if self:CheckBeginEndTime(subData.begin_time, subData.end_time) then
            subData.            table.insert(self.CollectJumpInfo, subData)
            break
          end
        elseif subData.jump_url ~= "" then
          subData.          table.insert(self.CollectJumpInfo, subData)
          break
        end
      end
    end
  end
  sortSeqFunc(self.CollectJumpInfo)
  log_tree("CollectJumpInfo = ", self.CollectJumpInfo)
  self.CollectTipJumpUrl, self.CollectTipJumpItemList = self:GenerateTipsData()
  self.CollectJumpInfo = {}
  log(bWriteLog and "store_collect_data:ReceiveCollectTipsData JumpUrl : " .. tostring(self.CollectTipJumpUrl))
  log_tree("CollectJumpInfo = ", self.CollectTipJumpItemList)
  if self.CollectTipJumpUrl == "" or not next(self.CollectTipJumpItemList) then
    log(bWriteLog and "store_collect_data:ReceiveCollectTipsData no item need show tips")
    return
  end
  self:ShowItemsTip()
end
function store_collect_data:CheckJumpValid(data)
  local JumpUtil = require("client.logic.store.jump_utils")
  if not data then
    return false
  end
  if data.begin_time and data.end_time and not self:CheckBeginEndTime(data.begin_time, data.end_time) then
    log(bWriteLog and "store_collect_data:ReceiveCollectTipsData isn't in the data time!")
    return false
  end
  if data.jump_url and not JumpUtil.CheckUrlCanJump(data.jump_url) then
    log(bWriteLog and "store_collect_data:ReceiveCollectTipsData jump url is unvalid!")
    return false
  end
  return true
end
function store_collect_data:CheckBeginEndTime(beginTime, endTime)
  local TimeUtil = require("client.common.time_util")
  if beginTime and endTime and TimeUtil.UnixTimeBetween(beginTime, endTime) == 0 then
    return true
  end
  return false
end
function store_collect_data:GenerateTipsData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local doActionData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyCollectTipsActionData) or {}
  local ignoreData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyCollectTipsIgnoreData) or {}
  local TipsJumpUrl = ""
  local TempJumpUrl = ""
  local TipsItemList = {}
  for index, data in pairs(self.CollectJumpInfo) do
    local itemId = data.itemId
    log(bWriteLog and string.format("store_collect_data:GenerateTipsData itemId=%s", tostring(itemId)))
    if self:CheckCollectInfo(itemId, data, doActionData, ignoreData, TempJumpUrl, TipsItemList) then
      if TipsJumpUrl == "" then
        TempJumpUrl = data.jump_url
        TipsJumpUrl = self:CheckDiffJumpUrl(data.jump_url)
      end
      table.insert(TipsItemList, itemId)
    end
  end
  return TipsJumpUrl, TipsItemList
end
function store_collect_data:CheckCollectInfo(itemId, data, doActionData, ignoreData, curSelectJumpUrl)
  local TimeUtil = require("client.common.time_util")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if not data or not data.jump_url then
    log(bWriteLog and "store_collect_data:CheckCollectInfo data or data.JumpUrl is unvalid!")
    return false
  end
  if curSelectJumpUrl ~= "" and not self:CompareJumpUrl(data.jump_url, curSelectJumpUrl) then
    log(bWriteLog and "store_collect_data:CheckCollectInfo isn't the same source!")
    return false
  end
  if not self:CheckJumpValid(data) then
    log(bWriteLog and "store_collect_data:CheckCollectInfo jump is unvalid!")
    return false
  end
  if wardrobe_data:HasItem(itemId) then
    log(bWriteLog and "store_collect_data:CheckCollectInfo owned the item!")
    return false
  end
  if ignoreData[itemId] then
    local ignoreTime = ignoreData[itemId]
    local ignoreTimeYMD = TimeUtil.FormatTime_YMD(ignoreTime)
    local curTimeYMD = TimeUtil.FormatTime_YMD(TimeUtil.GetServerTimeInSec())
    if ignoreTimeYMD == curTimeYMD then
      log(bWriteLog and "store_collect_data:CheckCollectInfo last tips time is in the same day!")
      return false
    end
  end
  if doActionData[itemId] then
    local actionData = doActionData[itemId]
    local actionYM = TimeUtil.FormatTime_YM(actionData)
    local curYM = TimeUtil.FormatTime_YM(TimeUtil.GetServerTimeInSec())
    if actionYM == curYM then
      log(bWriteLog and "store_collect_data:CheckCollectInfo user has processed in the current month!")
      return false
    end
  end
  return true
end
function store_collect_data:CompareJumpUrl(url1, url2)
  url1 = string.lower(url1)
  url2 = string.lower(url2)
  local clean_url1 = string.gsub(url1, "&itemid=%d+", "")
  local clean_url2 = string.gsub(url2, "&itemid=%d+", "")
  return clean_url1 == clean_url2
end
function store_collect_data:CheckDiffJumpUrl(url)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  local moduleId = tonumber(params.module)
  local itemId = tonumber(params.itemid)
  if moduleId == BP_ENUM_MODULE_SUPPLY or moduleId == BP_ENUM_MODULE_MALL or moduleId == BP_ENUM_MODULE_MALL_CHILD then
    local JumpUtils = require("client.logic.store.jump_utils")
    local bSupplyOrStore = JumpUtils.MODEL_ID_STORE
    if moduleId == BP_ENUM_MODULE_SUPPLY then
      bSupplyOrStore = JumpUtils.MODEL_ID_SUPPLY
    elseif moduleId == BP_ENUM_MODULE_MALL_CHILD then
      bSupplyOrStore = JumpUtils.MODEL_ID_STORE
    end
    local jumpParams = JumpUtils.FindJumpInfoFirst(itemId, bSupplyOrStore)
    if jumpParams then
      if jumpParams.Tab1 then
        url = url .. "&Tab1=" .. jumpParams.Tab1
      end
      if jumpParams.Tab2 then
        url = url .. "&Tab2=" .. jumpParams.Tab2
      end
    end
  end
  return url
end
function store_collect_data:ShowItemsTip()
  local UIUtil = require("client.common.ui_util")
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local FirstItemCfg = CDataTable.GetTableData("Item", self.CollectTipJumpItemList[1])
  local showIconPath = FirstItemCfg.ItemBigIcon
  if FirstItemCfg.ItemType == ENUM_ITEM_TYPE.Weapon then
    showIconPath = FirstItemCfg.ItemSmallIcon
  end
  local textContext = self:GetContextText(self.CollectTipJumpItemList)
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ConfigTab = ui_show_queue_config.GetParamTable(nil, "CollectTips")
  local itemListStr = ""
  for index, itemId in pairs(self.CollectTipJumpItemList) do
    if index == 1 then
      itemListStr = itemListStr .. tostring(itemId)
    else
      itemListStr = itemListStr .. "_" .. tostring(itemId)
    end
  end
  local Jump = function()
    self:CollectTipsTLog(itemListStr, 1)
    GlobalData.JumpUrl(self.CollectTipJumpUrl)
  end
  local refuse = function()
    self:DoActionRecord(self.CollectTipJumpItemList)
    self:CollectTipsTLog(itemListStr, 2)
    self.CollectTipJumpItemList = {}
    self.CollectTipJumpUrl = ""
  end
  local timeEnd = function()
    self:IgnoreRecord(self.CollectTipJumpItemList)
    self:CollectTipsTLog(itemListStr, 3)
    self.CollectTipJumpItemList = {}
    self.CollectTipJumpUrl = ""
  end
  local jumpInfo = {
    callback = Jump,
    cancelCallback = refuse,
    timeEndCallBack = timeEnd,
    bUseOKBtn = false
  }
  RightPopSystem.CommonPopup(ConfigTab, "", textContext, showIconPath, jumpInfo, 15, false)
end
function store_collect_data:GetContextText(itemList)
  local textContext = ""
  if #itemList == 1 then
    textContext = self:GetTipsContext(80032, itemList)
  elseif #itemList == 2 then
    textContext = self:GetTipsContext(80033, itemList)
  else
    textContext = self:GetTipsContext(80034, itemList)
  end
  return textContext
end
function store_collect_data:GetTipsContext(localizeId, itemList)
  local UIUtil = require("client.common.ui_util")
  local nameTable = {}
  for _, itemId in pairs(itemList) do
    if #nameTable == 3 then
      break
    end
    local itemCfg = CDataTable.GetTableData("Item", itemId)
    if itemCfg and itemCfg.ItemName then
      table.insert(nameTable, itemCfg.ItemName)
    end
  end
  local text = LocUtil.LocalizeResFormat(localizeId, table.unpack(nameTable))
  return text
end
function store_collect_data:CollectTipsTLog(itemIdStr, reason)
  local action = "Jump"
  if reason == 2 then
    action = "Refuse"
  elseif reason == 3 then
    action = "Ignore"
  end
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportLobbyClickEvent(gem_report_utils.Lobby_Collect_StrongTip, itemIdStr, 0)
  local TLogReasonStrTable = {
    event_name = gem_report_utils.Lobby_Collect_StrongTip,
    item_id_list = itemIdStr,
      }
  local TLogReasonStr = json.encode(TLogReasonStrTable)
  ClientSendTLogReport(TLogEventDefine.Lobby_Collect_StrongTip, 0, TLogReasonStr)
  log(bWriteLog and "TLog new format, store_collect_data:CollectTipsTLog, reason : " .. tostring(0) .. " reasonStr : " .. tostring(TLogReasonStr))
end
function store_collect_data:DownloadBreakJump(_, __, bBreak, moduleId, activityId)
  if self._processingDownloadBreakJump then
    log(bWriteLog and "store_collect_data:DownloadBreakJump already processing, skip to avoid recursion")
    return
  end
  self._processingDownloadBreakJump = true
  local utility = require("common.utility")
  local success = xpcall(self.BreakJump, utility.ErrorMessageHandler, self, bBreak, moduleId, activityId)
  self._processingDownloadBreakJump = false
  return success
end
function store_collect_data:BreakJump(bBreak, moduleId, activityId)
  log(bWriteLog and string.format("store_collect_data:BreakJump bBreak=%s, moduleId=%s, activityId=%s", tostring(bBreak), tostring(moduleId), tostring(activityId)))
  if not (self.CollectTipJumpItemList and next(self.CollectTipJumpItemList)) or self.CollectTipJumpUrl == nil then
    return
  end
  if self.CollectTipJumpUrl ~= "" then
    log(bWriteLog and string.format("store_collect_data:BreakJump CollectTipJumpUrl=%s", tostring(self.CollectTipJumpUrl)))
    if moduleId and not string.find(self.CollectTipJumpUrl, moduleId) then
      log(bWriteLog and "store_collect_data:BreakJump isn't the same moduleId")
      return
    end
    if activityId and not string.find(self.CollectTipJumpUrl, activityId) then
      log(bWriteLog and "store_collect_data:BreakJump isn't the same activityId")
      return
    end
  end
  if bBreak then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local downloadTriggerData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyCollectTipsDownloadTriggerData) or {}
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local needToDoActionList = {}
    for index, itemId in pairs(self.CollectTipJumpItemList) do
      if downloadTriggerData[itemId] then
        local timestamp = downloadTriggerData[itemId].timestamp
        local actionYM = TimeUtil.FormatTime_YM(timestamp)
        local curYM = TimeUtil.FormatTime_YM(curTime)
        if actionYM == curYM then
          if downloadTriggerData[itemId].times == 1 then
            table.insert(needToDoActionList, itemId)
          end
          downloadTriggerData[itemId] = nil
        else
          downloadTriggerData[itemId].timestamp = curTime
        end
      else
        local triggerInfo = {times = 1, timestamp = curTime}
        downloadTriggerData[itemId] = triggerInfo
      end
    end
    if 0 < #needToDoActionList then
      self:DoActionRecord(needToDoActionList)
    end
    PlayerPrefsSystem.SaveTableToFile_N(downloadTriggerData, PlayerPrefsSystem.ePlayerPrefsType.eLobbyCollectTipsDownloadTriggerData)
  else
    self:DoActionRecord(self.CollectTipJumpItemList)
  end
  self.CollectTipJumpItemList = {}
  self.CollectTipJumpUrl = ""
end
function store_collect_data:DoActionRecord(itemList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local doActionData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyCollectTipsActionData) or {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for _, itemId in pairs(itemList) do
    doActionData[itemId] = curTime
  end
  PlayerPrefsSystem.SaveTableToFile_N(doActionData, PlayerPrefsSystem.ePlayerPrefsType.eLobbyCollectTipsActionData)
end
function store_collect_data:IgnoreRecord(itemList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local ignoreData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyCollectTipsIgnoreData) or {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for _, itemId in pairs(itemList) do
    ignoreData[itemId] = curTime
  end
  PlayerPrefsSystem.SaveTableToFile_N(ignoreData, PlayerPrefsSystem.ePlayerPrefsType.eLobbyCollectTipsIgnoreData)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, store_collect_data)
return CModuleTemplate