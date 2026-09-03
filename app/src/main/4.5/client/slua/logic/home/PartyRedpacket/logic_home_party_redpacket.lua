local logic_home_party_redpacket = {}
local E_RecordReqOpType = {Receive = 1, Send = 2}
local C_RecordReqCD = 3
function logic_home_party_redpacket:DefineAndResetData()
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:DefineAndResetData")
  self.giftBoxForPlacing = {
    redpacket_id = 0,
    redpacket_item_id = 0,
    not_place_rp_list = {}
  }
  self.lastGiftBoxRecordReqTime = {sendGiftReqTime = 0, receiveGiftReqTime = 0}
  self.receiveDataList = nil
  self.sendDataList = nil
  self.cacheGrabedGifts = {}
end
function logic_home_party_redpacket:OnInitialize()
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:OnInitialize")
  self:ReqHomePartyGiftCfg()
end
function logic_home_party_redpacket:OnLogin()
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:OnLogin")
  self:ReqHomePartyGiftCfg()
end
function logic_home_party_redpacket:OnPostSwitchGameStatus(_, next)
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:OnPostSwitchGameStatus next = " .. tostring(next))
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if next == GameStatus.Fighting and PlanPH_GamePlay_Tools.IsPHomeMode() then
    log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:OnPostSwitchGameStatus should req for data")
    self:ReqHomePartyPrepareGift()
    self:ReqGiftBoxReceiveRecords()
  end
end
function logic_home_party_redpacket:ReqHomePartyGiftCfg()
  print(bWriteLog and "[DeanJYT] logic_home_party_redpacket:ReqHomePartyGiftCfg")
  local OnGetPartyGiftCfg = function(_, data)
    self.partyGiftCfg = data
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GET_PARTY_GIFT_CFG, data)
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.manor_redpacket_cfg, OnGetPartyGiftCfg)
end
function logic_home_party_redpacket:ReqHomePartyPrepareGift()
  print(bWriteLog and "[DeanJYT] logic_home_party_redpacket:ReqHomePartyPrepareGift")
  local PHomeGiftBoxHandler = require("client.network.Protocol.PHomeGiftBoxHandler")
  PHomeGiftBoxHandler.send_manor_redpacket_prepare_req()
end
function logic_home_party_redpacket:SaveHomePartyPrepareGiftData(redpacket_id, redpacket_item_id, not_place_rp_list)
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:SaveHomePartyPrepareGiftData redpacket_id = " .. tostring(redpacket_id) .. ", redpacket_item_id = " .. tostring(redpacket_item_id))
  self.giftBoxForPlacing.redpacket_id = redpacket_id or 0
  self.giftBoxForPlacing.redpacket_item_id = redpacket_item_id or 0
  self.giftBoxForPlacing.not_place_rp_list = not_place_rp_list or {}
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_PARTY_GIFT_PLACING_UPDATE)
end
function logic_home_party_redpacket:ClearHomePartyPrepareGiftData(redpacket_id)
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:ClearHomePartyPrepareGiftData redpacket_id = " .. tostring(redpacket_id))
  if redpacket_id == self.giftBoxForPlacing.redpacket_id then
    self.giftBoxForPlacing.redpacket_id = 0
    self.giftBoxForPlacing.redpacket_item_id = 0
  else
    for _, GiftBoxData in pairs(self.giftBoxForPlacing.not_place_rp_list) do
      if GiftBoxData.ret_rp_id == redpacket_id then
        GiftBoxData.ret_rp_id = 0
        GiftBoxData.ret_item_id = 0
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_PARTY_GIFT_PLACING_UPDATE)
end
function logic_home_party_redpacket:GetGiftBoxCfgByID(giftBoxID)
  if not self.partyGiftCfg then
    return nil
  end
  return self.partyGiftCfg[giftBoxID]
end
function logic_home_party_redpacket:GetGiftBoxCfgs()
  return self.partyGiftCfg
end
function logic_home_party_redpacket:EnterSendGiftBox()
  print(bWriteLog and "[DeanJYT] logic_home_party_redpacket:EnterSendGiftBox")
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if self.giftBoxForPlacing.redpacket_id ~= 0 or PlanPH_GamePlay_Tools.IsLocalBoot() then
    self:EnterPlacingGiftBox(self.giftBoxForPlacing.redpacket_id)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.PlanPH_Party_Gift_Popup_UIBP)
end
function logic_home_party_redpacket:EnterPlacingGiftBox(redpacket_id)
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:EnterPlacingGiftBox")
  local PlanPH_GiftBox_Placing_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.PlanPH_GiftBox_Placing_UIBP)
  if not PlanPH_GiftBox_Placing_UIBP then
    return
  end
  PlanPH_GiftBox_Placing_UIBP:EnterPlacingRedpacket(redpacket_id)
  local PlanPH_HomeArea_Manager = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.PlanPH_HomeArea_Manager")
  local homeAreaInfo = PlanPH_HomeArea_Manager.GetCurHome()
  if not homeAreaInfo then
    return
  end
  local logic_home_party_personalise = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_party_personalise)
  local skinID = logic_home_party_personalise.CurrentRedEnvelope
  local redpacket_item_id = self:FindGiftIdByRedpacketId(redpacket_id)
  local homeEditorSystem = homeAreaInfo.sceneObjectSystem
  homeEditorSystem.editGiftBox:CreateEditGiftBox(skinID, redpacket_item_id)
  local Common_Home_Details_InGame_UIBP = UIManager.GetUI(UIManager.UI_Config.Common_Home_Details_InGame_UIBP)
  if Common_Home_Details_InGame_UIBP then
    UIManager.CloseUI(UIManager.UI_Config.Common_Home_Details_InGame_UIBP)
  end
  local PlanPH_Party_Gift_Popup_UIBP = UIManager.GetUI(UIManager.UI_Config.PlanPH_Party_Gift_Popup_UIBP)
  if PlanPH_Party_Gift_Popup_UIBP then
    UIManager.CloseUI(UIManager.UI_Config.PlanPH_Party_Gift_Popup_UIBP)
  end
end
function logic_home_party_redpacket:ExitPlacingGiftBox()
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:ExitPlacingGiftBox")
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if not PlanPH_GamePlay_Tools.IsPHomeMode() then
    log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:ExitPlacingGiftBox not in home, do not proceed")
    return
  end
  local PlanPH_GiftBox_Placing_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.PlanPH_GiftBox_Placing_UIBP)
  if not PlanPH_GiftBox_Placing_UIBP then
    return
  end
  PlanPH_GiftBox_Placing_UIBP:ExitPlacingRedpacket()
  local PlanPH_HomeArea_Manager = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.PlanPH_HomeArea_Manager")
  local homeAreaInfo = PlanPH_HomeArea_Manager.GetCurHome()
  if not homeAreaInfo then
    return
  end
  local homeEditorSystem = homeAreaInfo.sceneObjectSystem
  homeEditorSystem.editGiftBox:DestroyEditGiftBox()
end
function logic_home_party_redpacket:EnterGiftBoxRecords()
  UIManager.ShowUI(UIManager.UI_Config.PlanPH_Party_GiftRecord_Popup_UIBP)
end
function logic_home_party_redpacket:ReqGiftBoxReceiveRecords()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if curTime - self.lastGiftBoxRecordReqTime.receiveGiftReqTime < C_RecordReqCD then
    return
  end
  self.lastGiftBoxRecordReqTime.receiveGiftReqTime = curTime
  local PHomeGiftBoxHandler = require("client.network.Protocol.PHomeGiftBoxHandler")
  PHomeGiftBoxHandler.send_manor_redpacket_records_req(E_RecordReqOpType.Receive)
end
function logic_home_party_redpacket:ReqGiftBoxSendRecords()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if curTime - self.lastGiftBoxRecordReqTime.sendGiftReqTime < C_RecordReqCD then
    return
  end
  self.lastGiftBoxRecordReqTime.sendGiftReqTime = curTime
  local PHomeGiftBoxHandler = require("client.network.Protocol.PHomeGiftBoxHandler")
  PHomeGiftBoxHandler.send_manor_redpacket_records_req(E_RecordReqOpType.Send)
end
function logic_home_party_redpacket:SaveGiftBoxRecords(opType, dataList)
  if E_RecordReqOpType.Receive == opType then
    self.receiveDataList = dataList
  elseif E_RecordReqOpType.Send == opType then
    self.sendDataList = dataList
  end
  local profileReqList = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, v in ipairs(dataList) do
    if v.redpacket_owner_uid ~= DataMgr.roleData.uid and not logic_profile:GetLocalProfile(v.redpacket_owner_uid) then
      profileReqList[#profileReqList + 1] = v.redpacket_owner_uid
    end
  end
  local OnGetProfileCallback = function()
    EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_GIFTBOX_RECORD_DATA_CHANGE, opType, dataList)
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(profileReqList, OnGetProfileCallback, Enum_PROFILE_REPORT_CFG.PLANPH_HOME_PARTY_GIFTBOX)
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_GIFTBOX_RECORD_DATA_CHANGE, opType, dataList)
end
function logic_home_party_redpacket:GetGiftBoxRecordsByType(opType)
  if E_RecordReqOpType.Receive == opType then
    return self.receiveDataList
  elseif E_RecordReqOpType.Send == opType then
    return self.sendDataList
  end
end
function logic_home_party_redpacket:BuyGiftBoxForPlacing(giftBoxID, count)
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manor_key_id = logic_home_entry:GetManorKey()
  local PHomeGiftBoxHandler = require("client.network.Protocol.PHomeGiftBoxHandler")
  PHomeGiftBoxHandler.send_manor_redpacket_build_req(manor_key_id, giftBoxID, count)
end
function logic_home_party_redpacket:PlaceGiftBox(redpacket_id, transformData, extraData)
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:PlaceGiftBox redpacket_id = " .. tostring(redpacket_id) .. " transformData = " .. tostring(transformData) .. ", extraData = " .. tostring(extraData))
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if not PlanPH_GamePlay_Tools.IsLocalBoot() and redpacket_id == 0 then
    ShowNotice(77200)
    return
  end
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manor_key_id = logic_home_entry:GetManorKey()
  local PHomeGiftBoxHandler = require("client.network.Protocol.PHomeGiftBoxHandler")
  PHomeGiftBoxHandler.send_manor_redpacket_place_req(manor_key_id, redpacket_id, transformData, extraData)
  if PlanPH_GamePlay_Tools.IsLocalBoot() then
    local manor_owner_id = logic_home_entry.manor_owner_id
    local PlanPH_PutAsset_GiftBox_Client_Handler = require("GameLua.Mod.PlanPH.Client.Handler.PlanPH_PutAsset_GiftBox_Client_Handler")
    PlanPH_PutAsset_GiftBox_Client_Handler.send_giftbox_test_create_req(transformData, manor_owner_id, math.floor(math.random(1, 500)), 602082 + math.floor(math.random(0, 5)), extraData)
  end
end
function logic_home_party_redpacket:TakeFromGiftBox(redpacketOwnerId, redpacketId, redpacketItemId)
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:TakeFromGiftBox redpacketOwnerId = " .. tostring(redpacketOwnerId) .. ", redpacketId = " .. tostring(redpacketId) .. ", redpacketItemId = " .. tostring(redpacketItemId))
  local PHomeGiftBoxHandler = require("client.network.Protocol.PHomeGiftBoxHandler")
  PHomeGiftBoxHandler.send_manor_redpacket_grab_req(redpacketOwnerId, redpacketId, redpacketItemId)
end
function logic_home_party_redpacket:CacheGiftTaken(redpacketId)
  self.cacheGrabedGifts[redpacketId] = true
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_PLANPH_PARTY_GIFT_TAKEN, redpacketId)
end
function logic_home_party_redpacket:GetUnplacedGiftBoxByType(giftBoxType)
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:GetUnplacedGiftBoxByType giftBoxType=" .. tostring(giftBoxType))
  if not self.giftBoxForPlacing.not_place_rp_list[giftBoxType] then
    self.giftBoxForPlacing.not_place_rp_list[giftBoxType] = {ret_rp_id = 0, ret_item_id = 0}
  end
  return self.giftBoxForPlacing.not_place_rp_list[giftBoxType]
end
function logic_home_party_redpacket:BuildGiftBox(giftBoxType, redpacketItemId, count)
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:BuildGiftBox giftBoxType=" .. tostring(giftBoxType) .. ", redpacketItemId=" .. tostring(redpacketItemId) .. ", count=" .. tostring(count))
  local unplacedGiftBox = self:GetUnplacedGiftBoxByType(giftBoxType)
  if unplacedGiftBox.ret_rp_id ~= 0 then
    self:EnterPlacingGiftBox(unplacedGiftBox.ret_rp_id)
    return
  end
  if unplacedGiftBox.ret_item_id ~= 0 then
    log(bWriteLog and string.format("[DeanJYT] logic_home_party_redpacket:BuildGiftBox Failed to build gift box of type[%d] unplacedGiftBox.ret_item_id=%d", giftBoxType, unplacedGiftBox.ret_item_id))
    ShowNotice(34735)
    self:AddGameTimer(0.5, false, function()
      if unplacedGiftBox.ret_rp_id == 0 and unplacedGiftBox.ret_item_id ~= 0 then
        unplacedGiftBox.ret_item_id = 0
      end
    end)
    return
  end
  unplacedGiftBox.ret_item_id = redpacketItemId
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manor_key_id = logic_home_entry:GetManorKey()
  local PHomeGiftBoxHandler = require("client.network.Protocol.PHomeGiftBoxHandler")
  PHomeGiftBoxHandler.send_manor_redpacket_build_req(manor_key_id, redpacketItemId, count)
end
function logic_home_party_redpacket:HandleBuildGiftBoxFailedEvent(redpacket_item_id)
  log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:HandleBuildGiftBoxFailedEvent redpacket_item_id=" .. tostring(redpacket_item_id))
  for _, GiftBoxData in pairs(self.giftBoxForPlacing.not_place_rp_list) do
    if GiftBoxData.ret_item_id == redpacket_item_id then
      log(bWriteLog and "[DeanJYT] logic_home_party_redpacket:HandleBuildGiftBoxFailedEvent find redpacket_item_id=" .. tostring(redpacket_item_id))
      GiftBoxData.ret_item_id = 0
      EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_PARTY_GIFT_PLACING_UPDATE)
      return
    end
  end
end
function logic_home_party_redpacket:SaveBuildGiftBoxData(redpacket_id, redpacket_item_id)
  for _, GiftBoxData in pairs(self.giftBoxForPlacing.not_place_rp_list) do
    if GiftBoxData.ret_item_id == redpacket_item_id then
      GiftBoxData.ret_rp_id = redpacket_id or 0
      EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_PARTY_GIFT_PLACING_UPDATE)
      return
    end
  end
  self.giftBoxForPlacing.redpacket_id = redpacket_id or 0
  self.giftBoxForPlacing.redpacket_item_id = redpacket_item_id or 0
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_PARTY_GIFT_PLACING_UPDATE)
end
function logic_home_party_redpacket:FindGiftIdByRedpacketId(redpacket_id)
  if self.giftBoxForPlacing.redpacket_id == redpacket_id then
    return self.giftBoxForPlacing.redpacket_item_id
  end
  for _, GiftBoxData in pairs(self.giftBoxForPlacing.not_place_rp_list) do
    if GiftBoxData.ret_rp_id == redpacket_id then
      return GiftBoxData.ret_item_id
    end
  end
  return nil
end
function logic_home_party_redpacket:HasUnplaceRetpacket(redpacket_item_id)
  if self.giftBoxForPlacing.redpacket_item_id == redpacket_item_id then
    return true
  end
  for _, giftBoxData in pairs(self.giftBoxForPlacing.not_place_rp_list) do
    if giftBoxData.ret_item_id == redpacket_item_id then
      return true
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_home_party_redpacket)
return CModuleTemplate