local TableUtil = require("common.table_util")
local Logic_SocialLobbyConst = require("client.slua.logic.lobby.Left.SocialHallConst.Logic_SocialLobbyConst")
local Logic_SocialLobbyEditMgrModule = {}
local Enum_DataReqSource = Logic_SocialLobbyConst.Enum_DataReqSource
local Enum_SocialLobbySlotType = Logic_SocialLobbyConst.Enum_SocialLobbySlotType
local Enum_WeaponListPage = Logic_SocialLobbyConst.Enum_WeaponListPage
function Logic_SocialLobbyEditMgrModule:DefineAndResetData()
  Logic_SocialLobbyEditMgrModule.__super.DefineAndResetData(self)
  self:_ResetData()
end
function Logic_SocialLobbyEditMgrModule:OnPreSwitchGameStatus(preState, nextState)
  Logic_SocialLobbyEditMgrModule.__super.OnPreSwitchGameStatus(self, preState, nextState)
  self:_ResetData()
end
function Logic_SocialLobbyEditMgrModule:_ResetData()
  self._bIsEditing = false
  self._nEditSlotType = nil
  self._nEditSlotIndex = nil
  self._tDataBeforeEditing = nil
  self._bAchievementSlotDataIsLatest = false
  self._bCollectionHallSlotIsLatest = false
  self._bBgWallPicIsLatest = false
  self._bSaveFailAfterTriggeredReq = false
end
function Logic_SocialLobbyEditMgrModule:GetIsEditing()
  return self._bIsEditing
end
function Logic_SocialLobbyEditMgrModule:GetCurSlotSelect()
  return self._nEditSlotType, self._nEditSlotIndex
end
function Logic_SocialLobbyEditMgrModule:GetCurIsLatestData()
  log(bWriteLog and "Logic_SocialLobbyEditMgrModule:GetCurIsLatestData >>> self._bCollectionHallSlotIsLatest: " .. tostring(self._bCollectionHallSlotIsLatest) .. ", self._bAchievementSlotDataIsLatest: " .. tostring(self._bAchievementSlotDataIsLatest) .. ", self._bBgWallPicIsLatest: " .. tostring(self._bBgWallPicIsLatest))
  return self._bCollectionHallSlotIsLatest and self._bAchievementSlotDataIsLatest and self._bBgWallPicIsLatest
end
function Logic_SocialLobbyEditMgrModule:_AvatarShowSlotConvertSaveReqData(tAvatarShowSlotAllData)
  local tSaveData = {}
  for nIndex, tSlotData in pairs(tAvatarShowSlotAllData) do
    if not tSaveData[nIndex] then
      tSaveData[nIndex] = {
        gender = tSlotData.gender,
        pose_type = tSlotData.pose_type,
        item_info = {},
        origin_resid = {}
      }
    end
    local tAllItemInfo = tSlotData.item_info or {}
    for k, v in pairs(tAllItemInfo) do
      tSaveData[nIndex].item_info[k] = tonumber(v.instid)
      if v.origin_resid and v.origin_resid > 0 then
        tSaveData[nIndex].origin_resid[k] = v.origin_resid
      end
    end
  end
  return tSaveData
end
function Logic_SocialLobbyEditMgrModule:ReqLatestDataResetEditFlag()
  self._bSaveFailAfterTriggeredReq = false
  self._bCollectionHallSlotIsLatest = true
  self._bAchievementSlotDataIsLatest = true
  self._bBgWallPicIsLatest = true
end
function Logic_SocialLobbyEditMgrModule:GetSaveFailAfterTriggeredReq()
  return self._bSaveFailAfterTriggeredReq
end
function Logic_SocialLobbyEditMgrModule:_CheckSocialLobbySlotDataIsSame(tAllSlotData1, tAllSlotData2)
  if tAllSlotData1 == nil or tAllSlotData2 == nil then
    return tAllSlotData1 == tAllSlotData2
  end
  local bAchievementSlotDataIsSame = self:_CheckAchievementSlotDataIsSame(tAllSlotData1.honor_display_data, tAllSlotData2.honor_display_data)
  local bBGWallSlotDataIsSame = self:_CheckBGWallSlotDataIsSame(tAllSlotData1.common_data, tAllSlotData2.common_data)
  local bOtherSlotMixedDataIsSame = self:_CheckMixedDataIsSame(tAllSlotData1.mixed_data, tAllSlotData2.mixed_data)
  local bAllIsSame = bAchievementSlotDataIsSame and bBGWallSlotDataIsSame and bOtherSlotMixedDataIsSame
  return bAllIsSame, bAchievementSlotDataIsSame, bBGWallSlotDataIsSame, bOtherSlotMixedDataIsSame
end
function Logic_SocialLobbyEditMgrModule:_CheckAchievementSlotDataIsSame(tAchievementSlotData1, tAchievementSlotData2)
  if not TableUtil.IsSameTable(tAchievementSlotData1, tAchievementSlotData2) then
    return false
  end
  return true
end
function Logic_SocialLobbyEditMgrModule:_CheckBGWallSlotDataIsSame(tBGWallSlotData1, tBGWallSlotData2)
  if tBGWallSlotData1 == nil or tBGWallSlotData2 == nil then
    return tBGWallSlotData1 == tBGWallSlotData2
  end
  local nBGPicItemId1 = tBGWallSlotData1.background_id
  local nBGPicItemId2 = tBGWallSlotData2.background_id
  return self:_CheckBGWallUseItemIsSame(nBGPicItemId1, nBGPicItemId2)
end
function Logic_SocialLobbyEditMgrModule:_CheckBGWallUseItemIsSame(nBGPicItemId1, nBGPicItemId2)
  return nBGPicItemId1 == nBGPicItemId2
end
function Logic_SocialLobbyEditMgrModule:_CheckMixedDataIsSame(tMixedData1, tMixedData2)
  if tMixedData1 == nil or tMixedData2 == nil then
    return tMixedData1 == tMixedData2
  end
  for nSlotType = Enum_SocialLobbySlotType.AvatarShow, Enum_SocialLobbySlotType.Pet do
    if nSlotType == Enum_SocialLobbySlotType.Vehicle then
      if not self:_CheckVehicleSlotDataIsSame(tMixedData1[nSlotType], tMixedData2[nSlotType]) then
        return false
      end
    elseif nSlotType == Enum_SocialLobbySlotType.AvatarShow then
      if not self:_CheckAvatarShowAllSlotDataIsSame(tMixedData1[nSlotType], tMixedData2[nSlotType]) then
        return false
      end
    elseif not TableUtil.IsSameTable(tMixedData1[nSlotType], tMixedData2[nSlotType]) then
      return false
    end
  end
  return true
end
function Logic_SocialLobbyEditMgrModule:_CheckVehicleSlotDataIsSame(tAllVehicleSlotData1, tAllVehicleSlotData2)
  if tAllVehicleSlotData1 == nil or tAllVehicleSlotData2 == nil then
    return tAllVehicleSlotData1 == tAllVehicleSlotData2
  end
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local nUId = Logic_SocialLobbyModule:GetCurUId()
  local nSlotMaxCount = Logic_SocialLobbyModule:GetSlotTypeMaxCount(nUId, Enum_SocialLobbySlotType.Vehicle)
  for i = 1, nSlotMaxCount do
    local tVehicleSlotData1 = tAllVehicleSlotData1[i] or {}
    local tVehicleSlotData2 = tAllVehicleSlotData2[i] or {}
    if tVehicleSlotData1.resid ~= tVehicleSlotData2.resid then
      return false
    end
  end
  return true
end
function Logic_SocialLobbyEditMgrModule:_CheckAvatarShowAllSlotDataIsSame(tAllAvatarShowSlotData1, tAllAvatarShowSlotData2)
  if tAllAvatarShowSlotData1 == nil or tAllAvatarShowSlotData2 == nil then
    return tAllAvatarShowSlotData1 == tAllAvatarShowSlotData2
  end
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local nUId = Logic_SocialLobbyModule:GetCurUId()
  local nSlotMaxCount = Logic_SocialLobbyModule:GetSlotTypeMaxCount(nUId, Enum_SocialLobbySlotType.AvatarShow)
  for i = 1, nSlotMaxCount do
    if not self:_CheckAvatarShowSlotDataIsSame(tAllAvatarShowSlotData1[i], tAllAvatarShowSlotData2[i]) then
      return false
    end
  end
  return true
end
function Logic_SocialLobbyEditMgrModule:_CheckAvatarShowSlotDataIsSame(tAvatarShowSlotData1, tAvatarShowSlotData2)
  if tAvatarShowSlotData1 == nil or tAvatarShowSlotData2 == nil then
    return tAvatarShowSlotData1 == tAvatarShowSlotData2
  end
  if tAvatarShowSlotData1.gender ~= tAvatarShowSlotData2.gender then
    return false
  end
  if tAvatarShowSlotData1.pose_type ~= tAvatarShowSlotData2.pose_type then
    return false
  end
  local tItemInfo1 = tAvatarShowSlotData1.item_info or {}
  local tItemInfo2 = tAvatarShowSlotData2.item_info or {}
  local Logic_AvatarWardrobeDataTools = require("client.slua.logic.lobby.Left.SocialLobby.Logic_AvatarWardrobeDataTools")
  local tAllEquipSlot = Logic_AvatarWardrobeDataTools.GetAvatarAllEquipSlot()
  for _, v in ipairs(tAllEquipSlot) do
    if not tItemInfo1[v] and tItemInfo2[v] or tItemInfo1[v] and not tItemInfo2[v] then
      return false
    elseif tItemInfo1[v] then
      local nSlotItemId1 = tItemInfo1[v].resid
      local nSlotInstId1 = tItemInfo1[v].instid
      local nSlotItemId2 = tItemInfo2[v].resid
      local nSlotInstId2 = tItemInfo2[v].instid
      if nSlotItemId1 ~= nSlotItemId2 or nSlotInstId1 ~= nSlotInstId2 then
        return false
      end
      if tItemInfo1[v].origin_resid ~= tItemInfo2[v].origin_resid then
        return false
      end
    end
  end
  return true
end
function Logic_SocialLobbyEditMgrModule:on_edit_honor_display_rsp(display_info)
  local nUId = DataMgr.roleData.uid
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local tAchievementSlotAllSlotData = Logic_SocialLobbyModule:GetSlotTypeAllSlotData(nUId, Enum_SocialLobbySlotType.Achievement)
  if not tAchievementSlotAllSlotData then
    log(bWriteLog and "Logic_SocialLobbyModule:on_edit_honor_display_rsp >>> tSocialLobbySlotData is nil")
    return
  end
  local bIsSame = self:_CheckAchievementSlotDataIsSame(tAchievementSlotAllSlotData, display_info)
  self._bAchievementSlotDataIsLatest = bIsSame
  log(bWriteLog and "Logic_SocialLobbyEditMgrModule:on_edit_honor_display_rsp >>> bIsSame: " .. tostring(bIsSame))
  if self._bIsEditing then
    self._tDataBeforeEditing.honor_display_data = display_info
  else
    Logic_SocialLobbyModule:SetSocialDataByKey(nUId, "honor_display_data", display_info)
    if not bIsSame then
      EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_GOT_SOCIAL_LOBBY_SHOW_DATA, nUId)
    end
  end
  if self._bCollectionHallSlotIsLatest and self._bAchievementSlotDataIsLatest and self._bBgWallPicIsLatest then
    ShowNotice(9826)
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_SOCIAL_LOBBY_SAVED_DATA)
end
function Logic_SocialLobbyEditMgrModule:on_set_collect_hall_background_rsp(background_id)
  local nUId = DataMgr.roleData.uid
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local nBgWallPicItemId = Logic_SocialLobbyModule:GetSocialLobbyBGWallItemId(nUId)
  local bIsSame = self:_CheckBGWallUseItemIsSame(nBgWallPicItemId, background_id)
  self._bBgWallPicIsLatest = bIsSame
  if self._bIsEditing then
    local tCommonData = self._tDataBeforeEditing.common_data or {}
    tCommonData.    self._tDataBeforeEditing.common_data = tCommonData
  else
    Logic_SocialLobbyModule:SetBGWallPicItemId(nUId, background_id)
    if not bIsSame then
      EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_GOT_SOCIAL_LOBBY_SHOW_DATA, nUId)
    end
  end
  if self._bCollectionHallSlotIsLatest and self._bAchievementSlotDataIsLatest and self._bBgWallPicIsLatest then
    ShowNotice(9826)
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_SOCIAL_LOBBY_SAVED_DATA)
end
function Logic_SocialLobbyEditMgrModule:on_edit_all_collect_hall_rsp(_, _, tSaveLobbyData)
  if not tSaveLobbyData or not tSaveLobbyData[Logic_SocialLobbyConst.SOCIAL_LOBBY_DATA_INDEX] then
    return
  end
  local nUId = DataMgr.roleData.uid
  local tSaveMixedData = tSaveLobbyData[Logic_SocialLobbyConst.SOCIAL_LOBBY_DATA_INDEX]
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local tSocialSlotData = Logic_SocialLobbyModule:GetSocialData(nUId)
  local bIsSame = self:_CheckMixedDataIsSame(tSocialSlotData.mixed_data, tSaveMixedData)
  self._bCollectionHallSlotIsLatest = bIsSame
  log(bWriteLog and "Logic_SocialLobbyEditMgrModule:OnEditedSaveSucEvent >>> bIsSame: " .. tostring(bIsSame))
  if self._bIsEditing then
    self._tDataBeforeEditing.mixed_data = TableUtil.CopyTable(tSaveMixedData)
  else
    Logic_SocialLobbyModule:SetSocialDataByKey(nUId, "mixed_data", tSaveMixedData)
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_GOT_SOCIAL_LOBBY_SHOW_DATA, nUId)
  end
  if self._bCollectionHallSlotIsLatest and self._bAchievementSlotDataIsLatest and self._bBgWallPicIsLatest then
    ShowNotice(9826)
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_SOCIAL_LOBBY_SAVED_DATA)
end
function Logic_SocialLobbyEditMgrModule:EnterEditState(nUId, nSlotType, nSlotIndex)
  if UIManager.IsUIShow(UIManager.UI_Config.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP) then
    return
  end
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if Lobby_Main_Control.GetBAniData() then
    log(bWriteLog and "Logic_SocialLobbyEditMgrModule:EnterEditor - Is Ani Data = true")
    return
  end
  if not nSlotType or not nSlotIndex then
    log(bWriteLog and "Logic_SocialLobbyEditMgrModule:EnterEditor >>> nSlotType or nSlotIndex Is nil")
    return
  end
  if tonumber(nUId) ~= tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "Logic_SocialLobbyEditMgrModule:EnterEditor >>> nUId Is nil")
    return
  end
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local tSocialData = Logic_SocialLobbyModule:GetSocialData(nUId)
  if not tSocialData then
    log(bWriteLog and "Logic_SocialLobbyEditMgrModule:EnterEditor >>> tSocialData Is nil")
    return
  end
  if nSlotType ~= Enum_SocialLobbySlotType.BGWall then
    local bIsUnlock = Logic_SocialLobbyModule:GetSlotIsUnlockBySlotTypeAndIndex(nUId, nSlotType, nSlotIndex)
    if not bIsUnlock then
      log(bWriteLog and "Logic_SocialLobbyEditMgrModule:EnterEditor >>> nSlotType Is Not Unlock", nSlotType, nSlotIndex)
      self:ShowUnlockSlotPopup(nUId, nSlotType, nSlotIndex)
    end
  end
  local bIsEditing = self._bIsEditing
  self._bIsEditing = true
  self._nEditSlotType = nSlotType
  self._nEditSlotIndex = nSlotIndex
  if not bIsEditing then
    local tSocialAllSlotData = Logic_SocialLobbyModule:GetSocialData(DataMgr.roleData.uid)
    self._tDataBeforeEditing = TableUtil.CopyTable(tSocialAllSlotData)
    UIManager.ShowUI(UIManager.UI_Config.SocialLobby_SlotEdit_UIBP, nUId)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SWITCH_PAGE_SHOW_HIDE, false)
    EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_DOWNLOADER_BTN_SHOWHIDE, true)
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_OPEN_ITEM_SHOW)
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_EDIT_STATUS, true, nSlotType)
  if nSlotType == Enum_SocialLobbySlotType.Weapon and not Logic_SocialLobbyModule:GetWeaponSlotIsShowBySlotIndex(nSlotIndex) then
    local nCurPage = Logic_SocialLobbyModule:GetWeaponShowPage()
    local bIsUp = nCurPage ~= Enum_WeaponListPage.Page_1
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_SOCIAL_LOBBY_SWITCH_WEAPON_UP_PAGE, bIsUp)
  end
end
function Logic_SocialLobbyEditMgrModule:IsSlotSelected(nSlotType, nSlotIndex)
  if not self._bIsEditing then
    return false
  end
  return self._nEditSlotType == nSlotType and self._nEditSlotIndex == nSlotIndex
end
function Logic_SocialLobbyEditMgrModule:ShowExistEditPopup()
  if not self._bIsEditing then
    return
  end
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local tSocialLobbyData = Logic_SocialLobbyModule:GetSocialData(DataMgr.roleData.uid)
  local bIsSameTable, bAchIsSame, bBgIsSame, bMixedIsSame = self:_CheckSocialLobbySlotDataIsSame(tSocialLobbyData, self._tDataBeforeEditing)
  if not bIsSameTable then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local sTitle = LocUtil.GetLocalizeResStr(5077)
    local sContent = LocUtil.GetLocalizeResStr(69125)
    local sOKBtn = LocUtil.GetLocalizeResStr(65102)
    local sCancelBtn = LocUtil.GetLocalizeResStr(4486)
    local fOkFunction = function()
      self:SaveEditedData(tSocialLobbyData, self._tDataBeforeEditing, bAchIsSame, bBgIsSame, bMixedIsSame)
      self:QuitEditState()
    end
    local fCancelFunction = function()
      Logic_SocialLobbyModule:ResetDataAndQuitSlotEdit(self._tDataBeforeEditing)
      self:QuitEditState()
    end
    CommonMsgBoxMgr.Show(4, sTitle, sContent, fOkFunction, fCancelFunction, sOKBtn, sCancelBtn)
    return
  end
  self:QuitEditState()
end
function Logic_SocialLobbyEditMgrModule:ResetEditDataAndExistEdit()
  if not self._bIsEditing then
    return
  end
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  Logic_SocialLobbyModule:ResetDataAndQuitSlotEdit(self._tDataBeforeEditing)
  self:QuitEditState()
end
function Logic_SocialLobbyEditMgrModule:GetWhetherNeedToSave()
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local tSocialLobbyData = Logic_SocialLobbyModule:GetSocialData(DataMgr.roleData.uid)
  local bIsSameTable = self:_CheckSocialLobbySlotDataIsSame(tSocialLobbyData, self._tDataBeforeEditing)
  return not bIsSameTable
end
function Logic_SocialLobbyEditMgrModule:SaveEditData()
  if not self._bIsEditing then
    return
  end
  local bIsNeedSave = self:GetWhetherNeedToSave()
  if bIsNeedSave then
    local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
    local tSocialLobbyData = Logic_SocialLobbyModule:GetSocialData(DataMgr.roleData.uid)
    self:SaveEditedData(tSocialLobbyData, self._tDataBeforeEditing)
  end
end
function Logic_SocialLobbyEditMgrModule:QuitEditState()
  self._bIsEditing = false
  self._nEditSlotType = nil
  self._nEditSlotIndex = nil
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(Logic_SocialLobbyConst.SOCIAL_LOBBY_SHOW_CAMERA_ID, 0.2)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SWITCH_PAGE_SHOW_HIDE, true)
  EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_DOWNLOADER_BTN_SHOWHIDE, false)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_CLOSE_ITEM_SHOW)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_EDIT_STATUS, false)
  self._tDataBeforeEditing = nil
end
function Logic_SocialLobbyEditMgrModule:SaveEditedData(tSocialLobbyData, tDataBeforeEditing, bAchIsSame, bBgIsSame, bMixedIsSame)
  bAchIsSame = bAchIsSame == nil and self:_CheckAchievementSlotDataIsSame(tSocialLobbyData.honor_display_data, tDataBeforeEditing.honor_display_data) or bAchIsSame
  bBgIsSame = bBgIsSame == nil and self:_CheckBGWallSlotDataIsSame(tSocialLobbyData.common_data, tDataBeforeEditing.common_data) or bBgIsSame
  bMixedIsSame = bMixedIsSame == nil and self:_CheckMixedDataIsSame(tSocialLobbyData.mixed_data, tDataBeforeEditing.mixed_data) or bMixedIsSame
  if not bAchIsSame then
    tSocialLobbyData.honor_display_data = tSocialLobbyData.honor_display_data or {}
    self._bAchievementSlotDataIsLatest = false
    local SocialAndCollection_LobbyHandler = require("client.network.Protocol.SocialAndCollection_LobbyHandler")
    SocialAndCollection_LobbyHandler.send_edit_honor_display_req(tSocialLobbyData.honor_display_data)
  end
  if not bBgIsSame then
    self._bBgWallPicIsLatest = false
    local nCurBgWallPicItemId = tSocialLobbyData.common_data and tSocialLobbyData.common_data.background_id
    local CollectionHallEditHandler = require("client.network.Protocol.CollectionHallEditHandler")
    CollectionHallEditHandler.send_set_collect_hall_common_equipment_req(1, nCurBgWallPicItemId, Enum_DataReqSource.SocialLobby)
  end
  if not bMixedIsSame then
    local tAllSlotData = {}
    for i = Enum_SocialLobbySlotType.AvatarShow, Enum_SocialLobbySlotType.Pet do
      if i == Enum_SocialLobbySlotType.AvatarShow then
        local tSlotTypeAllSlotData = tSocialLobbyData.mixed_data[i] or {}
        tAllSlotData[i] = self:_AvatarShowSlotConvertSaveReqData(tSlotTypeAllSlotData)
      elseif i == Enum_SocialLobbySlotType.Vehicle then
        tAllSlotData[i] = {}
        local tSlotTypeAllSlotData = tSocialLobbyData.mixed_data[i] or {}
        for k, v in pairs(tSlotTypeAllSlotData) do
          if v.bIsEditData ~= nil then
            local tTempData = TableUtil.CopyTable(v)
            tTempData.bIsEditData = nil
            tAllSlotData[i][k] = tTempData
          else
            tAllSlotData[i][k] = v
          end
        end
      else
        tSocialLobbyData.mixed_data[i] = tSocialLobbyData.mixed_data[i] or {}
        tAllSlotData[i] = tSocialLobbyData.mixed_data[i]
      end
    end
    self._bCollectionHallSlotIsLatest = false
    local CollectionHallEditHandler = require("client.network.Protocol.CollectionHallEditHandler")
    local tSendData = {
      [Logic_SocialLobbyConst.SOCIAL_LOBBY_DATA_INDEX] = tAllSlotData
    }
    CollectionHallEditHandler.send_edit_all_collect_hall_req(tSendData, Enum_DataReqSource.SocialLobby)
    log(bWriteLog and "Logic_SocialLobbyEditMgrModule:SaveEditedData >>> Save Edited Data, self._bCollectionHallSlotIsLatest = " .. tostring(self._bCollectionHallSlotIsLatest) .. ", self._bAchievementSlotDataIsLatest = " .. tostring(self._bAchievementSlotDataIsLatest) .. ", self._bBgWallPicIsLatest = " .. tostring(self._bBgWallPicIsLatest))
  end
  self:ReportTLogBySaveEdited()
end
function Logic_SocialLobbyEditMgrModule:ReportTLogBySaveEdited()
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local nUId = tonumber(Logic_SocialLobbyModule:GetCurUId())
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local TLogReasonStr = json.encode({
    uid = nUId or 0,
    slotType = self._nEditSlotType or 0,
    slotIndex = self._nEditSlotIndex or 0
  })
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.EditSocialHallSlot, 0, TLogReasonStr)
end
function Logic_SocialLobbyEditMgrModule:CheckIsShowUnlockPopup()
  if not self._bIsEditing then
    return false
  end
  local nSlotType = self._nEditSlotType
  if nSlotType == Enum_SocialLobbySlotType.BGWall then
    return false
  end
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local nUId = tonumber(Logic_SocialLobbyModule:GetCurUId())
  local nSlotIndex = self._nEditSlotIndex
  local bIsUnlock = Logic_SocialLobbyModule:GetSlotIsUnlockBySlotTypeAndIndex(nUId, nSlotType, nSlotIndex)
  if not bIsUnlock then
    log(bWriteLog and "Logic_SocialLobbyEditMgrModule:CheckIsShowUnlockPopup >>> nSlotType Is Not Unlock", nSlotType, nSlotIndex)
    self:ShowUnlockSlotPopup(nUId, nSlotType, nSlotIndex)
    return true
  end
  return false
end
function Logic_SocialLobbyEditMgrModule:ShowUnlockSlotPopup(nUId, nSlotType, nSlotIndex, fCloseFunc)
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local tSocialLobbyData = Logic_SocialLobbyModule:GetSocialData(nUId)
  if not tSocialLobbyData then
    return
  end
  local bIsUCUnlockSlot = Logic_SocialLobbyModule:CheckSlotTypeIsUCUnlock(nSlotType, nSlotIndex)
  if not bIsUCUnlockSlot then
    local nMinLevel = Logic_SocialLobbyModule:GetUnlockSlotByCollectHallMinLevel(nSlotType, nSlotIndex)
    ShowNotice(LocUtil.LocalizeResFormat(880060001, nMinLevel))
    return
  end
  local sTitle = LocUtil.LocalizeResFormat(5077)
  local nUCUnlockedCount = Logic_SocialLobbyModule:GetSlotTypeUCUnlockedCount(nUId, nSlotType)
  if not nUCUnlockedCount then
    log(bWriteLog and "Logic_SocialLobbyEditMgrModule:ShowUnlockSlotPopup >>> nUnlockedCount Is nil")
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  local nCurUnlockNum = nUCUnlockedCount + 1
  local uUnlockCfg = CDataTable.GetTableDataByFilter("PlanCH_MixHallUnlockConfig", "SlotType", nSlotType, "UnlockCount", nCurUnlockNum)
  if not uUnlockCfg then
    log(bWriteLog and "Logic_SocialLobbyEditMgrModule:ShowUnlockSlotPopup >>> uUnlockCfg Is nil, nSlotType: " .. nSlotType .. ", nCurUnlockNum: " .. nCurUnlockNum)
    return
  end
  local nUnlockCost = uUnlockCfg.UnlockCost
  if nUnlockCost == 0 then
    log(bWriteLog and "Logic_SocialLobbyEditMgrModule:ShowUnlockSlotPopup >>> nUnlockCost Is 0")
    return
  end
  local TextId = 199609
  if nSlotType == Enum_SocialLobbySlotType.AvatarShow then
    TextId = 880060108
  elseif nSlotType == Enum_SocialLobbySlotType.Vehicle then
    TextId = 880060110
  elseif nSlotType == Enum_SocialLobbySlotType.Weapon then
    TextId = 880060109
  elseif nSlotType == Enum_SocialLobbySlotType.Pet then
    TextId = 880060111
  end
  local sMsg = LocUtil.LocalizeResFormat(TextId, nUnlockCost)
  sMsg = string.gsub(sMsg, "UnlockSlotIcon", "Social_lobby_Keyicon1")
  local logic_common_msg_box = require("client.slua.logic.common.logic_common_msg_box")
  local extraData = {}
  if DataMgr.CheckIsNeedUSAPolicy() then
    extraData.policyTips = LocUtil.GetLocalizeResStr(300000)
    function extraData.policyHandler()
      local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
      long_txt_manager:ShowUserAgreement()
    end
  end
  logic_common_msg_box.Show(2, sTitle, sMsg, function()
    if nUnlockCost > DataMgr.ticket then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(nUnlockCost)
      return
    end
    local SocialAndCollection_LobbyHandler = require("client.network.Protocol.SocialAndCollection_LobbyHandler")
    SocialAndCollection_LobbyHandler.send_unlock_collect_hall_slot_req(nSlotType, nSlotIndex, Enum_DataReqSource.SocialLobby)
    if fCloseFunc then
      fCloseFunc()
    end
  end, fCloseFunc, nil, nil, extraData)
end
function Logic_SocialLobbyEditMgrModule:CheckBGWallSlotIfCanEquipItemId(nItemId)
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local nUId = tonumber(Logic_SocialLobbyModule:GetCurUId())
  local nCurUseItemId = Logic_SocialLobbyModule:GetSocialLobbyBGWallItemId(nUId)
  if nCurUseItemId == nItemId then
    return false
  end
  return true
end
function Logic_SocialLobbyEditMgrModule:TriggerReqLatestData()
  if self._bSaveFailAfterTriggeredReq then
    return
  end
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  Logic_SocialLobbyModule:ReqSocialLobbyShowData(DataMgr.roleData.uid)
  self._bSaveFailAfterTriggeredReq = true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_SocialLobbyEditMgr = class(CModuleBase, nil, Logic_SocialLobbyEditMgrModule)
return CLogic_SocialLobbyEditMgr