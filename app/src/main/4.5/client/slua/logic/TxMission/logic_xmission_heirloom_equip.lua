local logic_xmission_heirloom_equip = {}
local xmission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
function logic_xmission_heirloom_equip:DefineAndResetData()
  self.result = nil
  self.tTakeoutHeirloomData = nil
  self.tHeirloomWeaponMap = nil
  self.tHeirloomWeaponInstList = nil
  self.tHeirloomLock = false
  self.tHeirloomGiftMap = nil
  self.bGMSwitch = false
end
function logic_xmission_heirloom_equip:GetGMSwitch(bOpen)
  return self.bGMSwitch
end
function logic_xmission_heirloom_equip:SetGMSwitch(bOpen)
  self.bGMSwitch = bOpen
end
function logic_xmission_heirloom_equip:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, self.OnLoadingFinish, self)
  self:AddCommonEvent(EVENTTYPE_T_XMISSION, EVENTID_T_METRO_INFO_RSP, self.OnGetMetroInfoRsp, self)
  self:AddCommonEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_WARDROBE_DATA_CHANGE, self.UpdateAllItemHeirloom, self)
  self:AddCommonEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_BAG_ITEM_CHANGE, self.UpdateAllItemHeirloom, self)
end
function logic_xmission_heirloom_equip:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:DefineAndResetData()
  end
end
function logic_xmission_heirloom_equip:OnGetMetroInfoRsp()
  self:UpdateAllItemHeirloom()
end
function logic_xmission_heirloom_equip:GetAllItemHeirloom()
  if not self.tHeirloomWeaponInstList then
    self:UpdateAllItemHeirloom()
  end
  return self.tHeirloomWeaponInstList
end
function logic_xmission_heirloom_equip:AddHeirloomData(data)
  table.insert(self.tHeirloomWeaponInstList, data)
end
function logic_xmission_heirloom_equip:UpdateAllItemHeirloom(eventID, eventSubID, item)
  log(bWriteLog and "logic_xmission_heirloom_equip:UpdateAllItemHeirloom enter " .. tostring(eventID) .. ":" .. tostring(eventSubID))
  if item and not self:CheckIsHeirloomEuqip(item.item_id) then
    return
  end
  local xMission_Wardrobe_Data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local xMission_Prepare_Data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  local itemList = xMission_Wardrobe_Data.GetItemList()
  local slotItemList = xMission_Prepare_Data:GetSlotItemTable()
  local bagItemList = xMission_Prepare_Data:GetBagList()
  local safeBagItemList = xMission_Prepare_Data:GetSafeBagList()
  self.tHeirloomWeaponInstList = {}
  if slotItemList and next(slotItemList) then
    for _, v in pairs(slotItemList) do
      if self:CheckIsHeirloomEuqip(v.item_id) then
        self:AddHeirloomData(v)
      end
    end
  end
  if bagItemList and next(bagItemList) then
    for _, v in pairs(bagItemList) do
      if self:CheckIsHeirloomEuqip(v.item_id) then
        self:AddHeirloomData(v)
      end
    end
  end
  if safeBagItemList and next(safeBagItemList) then
    for _, v in pairs(safeBagItemList) do
      if self:CheckIsHeirloomEuqip(v.item_id) then
        self:AddHeirloomData(v)
      end
    end
  end
  if itemList and next(itemList) then
    for _, v in pairs(itemList) do
      if self:CheckIsHeirloomEuqip(v.item_id) then
        self:AddHeirloomData(v)
      end
    end
  end
  local item_table = {}
  if not self.tHeirloomLock then
    log(bWriteLog and "logic_xmission_heirloom_equip:UpdateAllItemHeirloom not return of tHeirloomLock")
    for _, v in pairs(self.tHeirloomWeaponInstList) do
      if v and not item_table[v.item_id] and not self:IsHaveHeirloomWeapon(v.item_id) then
        item_table[v.item_id] = true
        log(bWriteLog and "logic_xmission_heirloom_equip:UpdateAllItemHeirloom update data is " .. tostring(v.item_id))
        local TimeUtil = require("client.common.time_util")
        local TxMissionHeirloomHandler = require("client.network.Protocol.TxMissionHeirloomHandler")
        TxMissionHeirloomHandler.send_metro_heirloom_weapon_set_req(v.item_id, "", TimeUtil.GetServerTimeInSec(), 0):Then(function(err)
          if err == 0 then
            local data = {
              sub_mode = 0,
              pic_url = "",
              time = TimeUtil.GetServerTimeInSec()
            }
            self:SetHeirloomWeaponInfo(v.item_id, data)
          end
        end)
      end
    end
  end
  log_tree(bWriteLog and "logic_xmission_heirloom_equip:UpdateAllItemHeirloom tHeirloomWeaponInstList", self.tHeirloomWeaponInstList)
end
function logic_xmission_heirloom_equip:OnLoadingFinish()
  self:ShowHeirloomEquipSlap()
end
function logic_xmission_heirloom_equip:CacheResultData(result)
  if self.result then
    return
  end
  log_tree(bWriteLog and "logic_xmission_heirloom_equip:CacheResultData result", result)
  log_tree(bWriteLog and "logic_xmission_heirloom_equip:CacheResultData metro", result.metro)
  self.  self:HandlerResultData()
end
function logic_xmission_heirloom_equip:HandlerResultData()
  local xmission_battle_result_util = require("client.slua.umg.TxMission.xMission.battleResult.xmission_battle_result_util")
  local bIsHaveHeirloom, heirloomItemData = xmission_battle_result_util.CheckItemTakeOutByItemType(self.result.metro, xmission_macro.Enum_Type.EnumType_Knife, xmission_macro.Enum_Sub_Type.EnumType_Sub_Heirloom)
  if not bIsHaveHeirloom then
    log(bWriteLog and "logic_xmission_heirloom_equip:HandlerResultData return of not bIsHaveHeirloom")
    return
  end
  if not heirloomItemData then
    log(bWriteLog and "logic_xmission_heirloom_equip:HandlerResultData return of not heirloomItemData")
    return
  end
  if not self:IsHaveHeirloomWeapon(heirloomItemData.item_id) then
    heirloomItemData.bIsfirst = true
  end
  self.tTakeoutHeirloomData = heirloomItemData
  self:UploadCapture()
end
function logic_xmission_heirloom_equip:ShowHeirloomEquipSlap(itemId, bFromClick)
  itemId = itemId or self.tTakeoutHeirloomData and self.tTakeoutHeirloomData.item_id
  if not itemId then
    log(bWriteLog and "logic_xmission_heirloom_equip:ShowHeirloomEquipSlap return of not itemId")
    return
  end
  local data = self:GetHeirloomWeaponData(itemId)
  if not data then
    log(bWriteLog and "logic_xmission_heirloom_equip:ShowHeirloomEquipSlap return of not data")
    return
  end
  local itemData = {
    itemId = itemId,
    submode = data.sub_mode,
    picurl = data.pic_url,
    time = data.time,
    bIsFirst = self.tTakeoutHeirloomData and self.tTakeoutHeirloomData.bIsfirst
  }
  if bFromClick then
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local ParamTable = ui_show_queue_config.GetParamTable(nil, "Click")
    UIManager.ShowUI(UIManager.UI_Config.HeritageArmed_Share_UIBP, itemData, ParamTable)
  else
    UIManager.ShowUI(UIManager.UI_Config.HeritageArmed_Share_UIBP, itemData)
  end
  log(bWriteLog and "logic_xmission_heirloom_equip:ShowHeirloomEquipSlap ShowQueueUI Xmission_Popup_Equipment_UIBP")
  self.result = nil
  self.tTakeoutHeirloomData = nil
end
function logic_xmission_heirloom_equip:ShowHeirloomEquipMainUI(jumpParams)
  UIManager.ShowUI(UIManager.UI_Config.HeritageArmed_Show_UIBP, jumpParams)
end
function logic_xmission_heirloom_equip:UploadCapture()
  self.tHeirloomLock = true
  local itemId = self.tTakeoutHeirloomData.item_id
  local completeFunc = function(bSuccess, imgUrl)
    if bSuccess then
      local TimeUtil = require("client.common.time_util")
      local TxMissionHeirloomHandler = require("client.network.Protocol.TxMissionHeirloomHandler")
      TxMissionHeirloomHandler.send_metro_heirloom_weapon_set_req(itemId, imgUrl, TimeUtil.GetServerTimeInSec(), self.result.sub_mode):Then(function(err)
        if err == 0 then
          local data = {
            sub_mode = self.result.sub_mode,
            pic_url = imgUrl,
            time = TimeUtil.GetServerTimeInSec()
          }
          self:SetHeirloomWeaponInfo(itemId, data)
        end
        self.tHeirloomLock = false
      end)
    else
      self.tHeirloomLock = false
    end
  end
  local uploadFile = function(fileSuffix)
    local PlatName = Client.GetDevicePlatformName()
    local filePath = Client.ProjectSavedDir() .. "Screenshots/" .. PlatName .. "/Heirloom_" .. itemId .. fileSuffix
    log(bWriteLog and string.format("logic_xmission_heirloom_equip:UploadCapture, filePath:%s", filePath))
    local bIsExist = Client.IsFileExistsWithOutPakCheck(filePath)
    if bIsExist then
      local LogicHDmpveUpload = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicHDmpveUpload)
      LogicHDmpveUpload:UploadImage(filePath, ShareMgr.ShareFileType.Heirloom, function(bSuccess, imgUrl)
        log(bWriteLog and string.format("logic_xmission_heirloom_equip:UploadCapture, bSuccess:%s", bSuccess))
        log(bWriteLog and string.format("logic_xmission_heirloom_equip:UploadCapture, imgUrl:%s", imgUrl))
        completeFunc(bSuccess, imgUrl)
        if bSuccess then
          Client.DeleteFile(filePath)
        end
      end, nil, {dontShowWaitingUI = true})
      self.tHeirloomLock = false
      return true
    end
    return false
  end
  if uploadFile("_WeaponCheck.jpg") then
    return
  end
  if uploadFile("_Tips.jpg") then
    return
  end
  completeFunc(true, "")
end
function logic_xmission_heirloom_equip:IsHaveHeirloomWeapon(itemId)
  local heirloomInfo = self:GetHeirloomWeaponInfo()
  if not heirloomInfo then
    return false
  end
  if heirloomInfo[itemId] then
    return true
  end
  return false
end
function logic_xmission_heirloom_equip:GetDefaultCapturePath(itemId)
  local heirloomConfig = CDataTable.GetTableData("HeirloomWeapon", itemId)
  if not heirloomConfig then
    return "/Game/Mod/TPlan/XMission/NoAtlas/HeritageArmed/HeritageArmed_Share_Image_Photo_02.HeritageArmed_Share_Image_Photo_02"
  end
  return heirloomConfig.shareIcon
end
function logic_xmission_heirloom_equip:GetShareBGPath(itemId)
  local heirloomConfig = CDataTable.GetTableData("HeirloomWeapon", itemId)
  if not heirloomConfig then
    return "/Game/Mod/TPlan/XMission/NoAtlas/HeritageArmed/HeritageArmed_Share_Image_Bg_02_01.HeritageArmed_Share_Image_Bg_02_01"
  end
  return heirloomConfig.shareBG
end
function logic_xmission_heirloom_equip:GetItemCaptureUrl(itemId)
  local sDefaultCapturePath = self:GetDefaultCapturePath(itemId)
  local heirloomInfo = self:GetHeirloomWeaponInfo()
  if not heirloomInfo then
    return sDefaultCapturePath
  end
  if not heirloomInfo[itemId] then
    local checkFileExists = function(fileSuffix)
      local PlatName = Client.GetDevicePlatformName()
      local filePath = Client.ProjectSavedDir() .. "Screenshots/" .. PlatName .. "/Heirloom_" .. itemId .. fileSuffix
      return Client.IsFileExistsWithOutPakCheck(filePath) and filePath or nil
    end
    return checkFileExists("_WeaponCheck.jpg") or checkFileExists("_Tips.jpg") or sDefaultCapturePath
  end
  local picUrl = heirloomInfo[itemId] and heirloomInfo[itemId].pic_url
  if picUrl == "" then
    picUrl = sDefaultCapturePath
  end
  return picUrl
end
function logic_xmission_heirloom_equip:CheckIsHeirloomEuqip(itemId)
  if not itemId then
    return false
  end
  local itemCfg = CDataTable.GetTableData("TxMissionItem", itemId)
  if not itemCfg then
    return false
  end
  return itemCfg.ItemType == xmission_macro.Enum_Type.EnumType_Knife and itemCfg.ItemSubType == xmission_macro.Enum_Sub_Type.EnumType_Sub_Heirloom
end
function logic_xmission_heirloom_equip:GetIsGiftedHeirloomEuqipData(itemId)
  if not self:CheckIsHeirloomEuqip(itemId) then
    return -1
  end
  local weaponCfg = CDataTable.GetTableData("HeirloomWeapon", itemId)
  if not weaponCfg then
    return -1
  end
  return weaponCfg.originWeaponId
end
function logic_xmission_heirloom_equip:CheckHeirloomVaild(itemId)
  local data = self:GetHeirloomWeaponData(itemId)
  if not data then
    return false
  end
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  local itemNum = logic_xmission_warpre.GetItemNumByItemId(itemId)
  if 0 < itemNum then
    return true
  end
  return false
end
function logic_xmission_heirloom_equip:IsHaveAnyHeirloom()
  local heirloomInfo = self:GetHeirloomWeaponInfo()
  if not heirloomInfo then
    return false
  end
  for itemId, v in pairs(heirloomInfo) do
    if self:CheckHeirloomVaild(itemId) then
      return true
    end
  end
  return false
end
function logic_xmission_heirloom_equip:GetHeirloomWeaponData(itemId)
  local heirloomInfo = self:GetHeirloomWeaponInfo()
  if not heirloomInfo then
    return nil
  end
  return heirloomInfo[itemId]
end
function logic_xmission_heirloom_equip:GetHeirloomWeaponInfo()
  if self.tHeirloomWeaponMap then
    return self.tHeirloomWeaponMap
  end
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  self.tHeirloomWeaponMap = logic_xmission_info:GetMetroValueByKey("heirloom_weapon_info")
  return self.tHeirloomWeaponMap
end
function logic_xmission_heirloom_equip:SetHeirloomWeaponInfo(itemId, itemData)
  if not self.tHeirloomWeaponMap then
    self.tHeirloomWeaponMap = {}
  end
  self.tHeirloomWeaponMap[itemId] = itemData
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  logic_xmission_info:SetMetroValueByKey("heirloom_weapon_info", self.tHeirloomWeaponMap)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_HEIRLOOM_WEAPON_UPDATE)
end
function logic_xmission_heirloom_equip:GetFirstNotGiftedHeirloomWeaponInstId()
  local check = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_HEIRLOOM, 1)
  if check and check == 1 then
    return 0
  end
  local heirloomItemData = self:GetAllItemHeirloom()
  log_tree(bWriteLog and "logic_xmission_heirloom_equip:GetFirstNotGiftedHeirloomWeaponInstId heirloomItemData", heirloomItemData)
  local dataList = {}
  for k, v in pairs(heirloomItemData) do
    local count, maxCount = self:GetHeirloomGiftCount(v.inst_id)
    if 0 < self:GetIsGiftedHeirloomEuqipData(v.item_id) then
      count = -1
    end
    local itemData = {
      itemId = v.item_id,
      inst_id = v.inst_id,
      isGifted = count
    }
    table.insert(dataList, itemData)
  end
  table.sort(dataList, function(a, b)
    if a.isGifted == b.isGifted then
      return a.itemId > b.itemId
    else
      return a.isGifted > b.isGifted
    end
  end)
  for _, value in pairs(dataList) do
    if value.item_id ~= 1081201 and self:GetIsGiftedHeirloomEuqipData(value.itemId) == 0 and 0 < self:GetHeirloomGiftCount(value.inst_id) then
      log(bWriteLog and "logic_xmission_heirloom_equip:GetFirstNotGiftedHeirloomWeaponInstId inst_id = " .. value.inst_id)
      return value.inst_id
    end
  end
  log(bWriteLog and "logic_xmission_heirloom_equip:GetFirstNotGiftedHeirloomWeaponInstId inst_id = 0")
  return 0
end
function logic_xmission_heirloom_equip:ClearFirstNotGiftedHeirloomWeaponFlag()
  DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_HEIRLOOM, 1, 1)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_HEIRLOOM_WEAPON_GIFT_REDDOT_UPDATE)
end
function logic_xmission_heirloom_equip:SetHeirloomSelectInstId(inst_id)
  if not inst_id then
    return
  end
  log(bWriteLog and "logic_xmission_heirloom_equip:SetHeirloomSelectInstId inst_id = " .. inst_id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = {selectId = inst_id}
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsConfig.eHeirloomSelectData)
end
function logic_xmission_heirloom_equip:GetHeirloomSelectInstId()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsConfig.eHeirloomSelectData)
  if data and data.selectId then
    log(bWriteLog and "logic_xmission_heirloom_equip:GetHeirloomSelectInstId data = " .. tostring(data.selectId))
    return data.selectId
  end
  return nil
end
function logic_xmission_heirloom_equip:GetHeirloomGiftCount(inst_id)
  local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  if not itemInfo then
    return 0, 0
  end
  if self:GetIsGiftedHeirloomEuqipData(itemInfo.item_id) ~= 0 then
    return 0, 0
  end
  if itemInfo.item_id == 1081201 then
    return 0, 0
  end
  local giftMap = self:GetGiftAvailableMap()
  if not giftMap[itemInfo.item_id] then
    return 0, 0
  end
  local max_count = 1
  local metro_gift_count = itemInfo.metro_gift_count or 0
  return max_count - metro_gift_count, max_count
end
function logic_xmission_heirloom_equip:UpdateHeirloomGiftCount(itemData)
  for _, v in pairs(self.tHeirloomWeaponInstList or {}) do
    if v.inst_id == itemData.inst_id then
      v.metro_gift_count = itemData.metro_gift_count
      return
    end
  end
  log_error("logic_xmission_heirloom_equip:UpdateHeirloomGiftCount not found inst_id " .. tostring(itemData.inst_id))
end
function logic_xmission_heirloom_equip:ShowGuideByWidget(uibase, root, widget, animation)
  log(bWriteLog and "logic_xmission_heirloom_equip:ShowGuideByWidget")
  if self:GetFirstNotGiftedHeirloomWeaponInstId() == 0 then
    return
  end
  if self.guideTimer then
    self:RemoveTimer(self.guideTimer)
    self.guideTimer = nil
  end
  self.guideTimer = self:AddTimerLoop(0, function()
    if not widget or not root then
      log(bWriteLog and "logic_xmission_heirloom_equip:ShowGuideByWidget  return of not widget or not root")
      return
    end
    if not animation or animation:IsAnimationPlaying("Common_Fadein") then
      log(bWriteLog and "logic_xmission_heirloom_equip:ShowGuideByWidget  return of not animation or animation is playing")
      return
    end
    log(bWriteLog and "logic_xmission_heirloom_equip:ShowGuideByWidget create guide ui")
    local newbie_ui = uibase:CreateChildWindow(root, UIManager.UI_Config.NewbieGuide_UIBP, 2, LocUtil.GetLocalizeResStr(81467), widget, function()
      self:ClearFirstNotGiftedHeirloomWeaponFlag()
    end, false, 1)
    newbie_ui:SetZOrder(100)
    if self.guideTimer then
      self:RemoveTimer(self.guideTimer)
      self.guideTimer = nil
    end
  end, 6, 0.33)
end
function logic_xmission_heirloom_equip:IsShowGiftGuide()
  local check = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_HEIRLOOM, 2)
  if check and check == 1 then
    return false
  end
  DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_HEIRLOOM, 2, 1)
  return true
end
function logic_xmission_heirloom_equip:GetGiftAvailableMap()
  if self.tHeirloomGiftMap then
    return self.tHeirloomGiftMap
  end
  local tHeirloomGiftMap = {}
  local tableData = CDataTable.GetTable("HeirloomWeapon")
  for key, value in pairs(tableData) do
    if value.originWeaponId and value.originWeaponId ~= 0 then
      tHeirloomGiftMap[value.originWeaponId] = 1
    end
  end
  self.  return tHeirloomGiftMap
end
function logic_xmission_heirloom_equip:send_gift_metro_item_req(inst_id, receiver_uid, message_text)
  local TxMissionHeirloomHandler = require("client.network.Protocol.TxMissionHeirloomHandler")
  TxMissionHeirloomHandler.send_gift_metro_item_req(inst_id, receiver_uid, message_text)
end
function logic_xmission_heirloom_equip:on_gift_metro_item_rsp(inst_id, item)
  local OnAnimEnd = function()
    local giftPacketSystem = require("client.slua.logic.store.logic_store_gift_packet")
    local sGiftName = giftPacketSystem.GetGiftName()
    local sFriendName = giftPacketSystem.GetFriendDataByKey("nickName") or ""
    local msg = string.format(DataMgr.GetMsgByID(501030), sGiftName, sFriendName)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, DataMgr.GetMsgByID(102012), msg, giftPacketSystem.CloseUI, nil, LocUtil.GetLocalizeResStr("110036"), nil, {
      clickCloseCallback = giftPacketSystem.CloseUI
    })
  end
  local GivingGifts_Popup_UIBP = UIManager.GetUI(UIManager.UI_Config.GivingGifts_Popup_UIBP)
  if GivingGifts_Popup_UIBP then
    GivingGifts_Popup_UIBP:CloseSelf()
  end
  item.  self:UpdateHeirloomGiftCount(item)
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_PLAY_GIFT_PACKET_ANIM, OnAnimEnd)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_xmission_heirloom_equip = class(CModuleBase, nil, logic_xmission_heirloom_equip)
return Clogic_xmission_heirloom_equip