local DragonChangeForm = {}
local DragonLevelUpCfg = {
  Before = nil,
  Next = nil,
  Series = 1
}
function DragonChangeForm:OnInitialize()
  self.CONST_ACTION_TYPE = {CHANGE = 0, RECOVER = 1}
  self:LoadDragonChangeFormConfig()
  self.bUpdateShowNum = false
  self.bShowCardGuide = false
end
function DragonChangeForm:RegistEvents()
  if Client and GameStatus.IsInLobbyOrMainCity() then
    self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_FAIL, self.OnPutOnFail, self)
    self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_RECEIVE_INHERIT_DATA, self.OnReceiveInheritData, self)
  end
end
function DragonChangeForm:OnPreSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    log(bWriteLog and "DragonChangeForm:OnPreSwitchGameStatus bUpdateShowNum init false")
    self.bUpdateShowNum = false
    self.CachePutOn = false
  end
end
function DragonChangeForm:LoadDragonChangeFormConfig()
  self.LevelUpCfgMap = {}
  local cfgList = CDataTable.GetTableByFilter("DragonChangeFormConfig", "ActionType", self.CONST_ACTION_TYPE.CHANGE)
  if cfgList then
    for _, cfg in pairs(cfgList) do
      if not self.LevelUpCfgMap[cfg.BeforeClothID] then
        self.LevelUpCfgMap[cfg.BeforeClothID] = {
          Before = nil,
          Next = nil,
          Series = cfg.Series
        }
      end
      if not self.LevelUpCfgMap[cfg.AfterClothID] then
        self.LevelUpCfgMap[cfg.AfterClothID] = {
          Before = nil,
          Next = nil,
          Series = cfg.Series
        }
      end
      self.LevelUpCfgMap[cfg.BeforeClothID].Next = cfg.AfterClothID
      self.LevelUpCfgMap[cfg.AfterClothID].Before = cfg.BeforeClothID
    end
  end
end
function DragonChangeForm:GetMainAvatarEqupItemid()
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  logic_wardrobe_avatar:InitCurrentWearPreviewMap()
  local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(BP_ENUM_AVATAR_CLOTH)
  if wearInfo ~= nil then
    return wearInfo.resID
  end
  return nil
end
function DragonChangeForm:GetChangeFormConfigByItemId(BeforeClothID)
  log(bWriteLog and "DragonChangeForm:GetEmoteId BeforeClothID = " .. tostring(BeforeClothID))
  if BeforeClothID == nil then
    return nil, nil
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local checkFunc = function(ItemID)
    return true
  end
  local config = self:GetConfigByItemIdAndCheck(BeforeClothID, checkFunc)
  if not config then
    log(bWriteLog and "DragonChangeForm:GetChangeFormConfigByItemId not config match")
    return nil, nil
  end
  log(bWriteLog and "DragonChangeForm:GetEmoteId emoteId = " .. tostring(config.ActionID))
  return config
end
function DragonChangeForm:GetSelfConfigByCurWear()
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  logic_wardrobe_avatar:InitCurrentWearPreviewMap()
  local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(BP_ENUM_AVATAR_CLOTH)
  if wearInfo == nil then
    return nil
  end
  local BeforeClothID = wearInfo.resID
  log(bWriteLog and "DragonChangeForm:GetSelfConfigByCurWear BeforeClothID = " .. tostring(BeforeClothID))
  local myAvatar
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local isInXMission = XMissionSystem.IsInXMission()
  if isInXMission then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    myAvatar = XMissionAvatarMgr.GetMainAvatar()
  else
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    myAvatar = TeamAvatarManager.GetMainAvatar()
  end
  if myAvatar == nil then
    log(bWriteLog and "DragonChangeForm:GetSelfConfigByCurWear main avatar is nil")
    return nil
  elseif not myAvatar:HasEquiped(BeforeClothID) then
    log(bWriteLog and "DragonChangeForm:GetSelfConfigByCurWear not equip")
    local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
    local CartoonStyleCfg = LogicMultiItemModule:GetCartoonStyleCfg(BeforeClothID)
    if CartoonStyleCfg then
      if BeforeClothID == CartoonStyleCfg.BaseID and myAvatar:HasEquiped(CartoonStyleCfg.CartoonStyleID) then
        log(bWriteLog and "DragonChangeForm:GetSelfConfigByCurWear equip CartoonStyleID")
      elseif BeforeClothID == CartoonStyleCfg.CartoonStyleID and myAvatar:HasEquiped(CartoonStyleCfg.BaseID) then
        log(bWriteLog and "DragonChangeForm:GetSelfConfigByCurWear equip BaseID")
      else
        return nil
      end
    else
      return nil
    end
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local source = wardrobe_data:GetItemSource(wearInfo.insID)
  if source == EWardrobeDataSource.InheritWardrobe and GlobalData.IsJapanOrKorea() then
    local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
    if not LogicInheritWardrobe:GetDragonBallUnlockState() then
      log(bWriteLog and "DragonChangeForm:GetSelfConfigByCurWear InheritWardrobe and JK not Unlock")
      return nil
    end
  end
  local checkFunc = function(ItemID)
    return wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(ItemID, source) ~= nil
  end
  local config = self:GetConfigByItemIdAndCheck(BeforeClothID, checkFunc)
  if not config then
    log(bWriteLog and "DragonChangeForm:GetSelfConfigByCurWear not config match")
    return nil, nil
  end
  log(bWriteLog and "DragonChangeForm:GetSelfConfigByCurWear emoteId = " .. tostring(config.ActionID))
  return config, source
end
function DragonChangeForm:GetConfigByItemIdAndCheck(BeforeClothID, checkFunc)
  local Series = self:GetSeriesByItemID(BeforeClothID)
  if not Series then
    return nil
  end
  if self.LevelUpCfgMap[BeforeClothID].Next and checkFunc(self.LevelUpCfgMap[BeforeClothID].Next) then
    return self:GetCfgByPreAndNext(BeforeClothID, self.LevelUpCfgMap[BeforeClothID].Next)
  else
    return self:GetFirstCfgOfSeries(BeforeClothID, checkFunc)
  end
end
function DragonChangeForm:GetFirstCfgOfSeries(BeforeItem, checkFunc)
  if not BeforeItem or not checkFunc then
    return nil
  end
  local AfterClothID = BeforeItem
  while self.LevelUpCfgMap[AfterClothID] and self.LevelUpCfgMap[AfterClothID].Before and checkFunc(self.LevelUpCfgMap[AfterClothID].Before) do
    AfterClothID = self.LevelUpCfgMap[AfterClothID].Before
  end
  if AfterClothID == BeforeItem then
    return nil
  end
  log(bWriteLog and string.format("DragonChangeForm:GetFirstCfgOfSeries Before = %s, After = %s", tostring(BeforeItem), tostring(AfterClothID)))
  return self:GetCfgByPreAndNext(BeforeItem, AfterClothID)
end
function DragonChangeForm:GetLastItemOfSeries(BeforeItem)
  local AfterClothID = BeforeItem
  while self.LevelUpCfgMap[AfterClothID] and self.LevelUpCfgMap[AfterClothID].Next do
    AfterClothID = self.LevelUpCfgMap[AfterClothID].Next
  end
  return AfterClothID
end
function DragonChangeForm:GetAllItemOfSeries(ItemID)
  local list = {}
  local Series = self:GetSeriesByItemID(ItemID)
  if not Series then
    return list
  end
  local FirstItem = ItemID
  while self.LevelUpCfgMap[FirstItem].Before do
    FirstItem = self.LevelUpCfgMap[FirstItem].Before
  end
  while self.LevelUpCfgMap[FirstItem] do
    table.insert(list, FirstItem)
    FirstItem = self.LevelUpCfgMap[FirstItem].Next
  end
  return list
end
function DragonChangeForm:GetSeriesByItemID(ItemID)
  if ItemID and self.LevelUpCfgMap[ItemID] then
    return self.LevelUpCfgMap[ItemID].Series
  end
  return nil
end
function DragonChangeForm:GetCfgByPreAndNext(PreItem, NextItem)
  if not PreItem or not NextItem then
    return nil
  end
  return CDataTable.GetTableDataByFilter("DragonChangeFormConfig", "BeforeClothID", PreItem, "AfterClothID", NextItem)
end
function DragonChangeForm:GetCfgByEmoteIDAndSeries(EmoteID, Series)
  if not EmoteID or not Series then
    return nil
  end
  return CDataTable.GetTableDataByFilter("DragonChangeFormConfig", "ActionID", EmoteID, "Series", Series)
end
function DragonChangeForm:GetAfterClothIDByLobbyPawn(lobbyPawn)
  if not slua.isValid(lobbyPawn) then
    log(bWriteLog and "DragonChangeForm:GetAfterClothIDByLobbyPawn lobbyPawn is invalid")
    return
  end
  local uAvatarComp2 = lobbyPawn.CharacterAvatarComp2_BP
  if not slua.isValid(uAvatarComp2) then
    log(bWriteLog and "DragonChangeForm:GetAfterClothIDByLobbyPawn uAvatarComp2 is invalid")
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  log(bWriteLog and "DragonChangeForm.GetAfterClothIDByLobbyPawn TypeSpecificID = " .. tostring(AvatarItem.TypeSpecificID))
  local Series = self:GetSeriesByItemID(AvatarItem.TypeSpecificID)
  if not Series then
    return
  end
  local emoteId = lobbyPawn:GetCurrentActionID()
  if not emoteId or emoteId == 0 then
    log(bWriteLog and "DragonChangeForm:GetAfterClothIDByLobbyPawn not emotePlaying")
    return nil
  end
  log(bWriteLog and "DragonChangeForm:GetAfterClothIDByLobbyPawn emoteId = " .. tostring(emoteId))
  local config = self:GetCfgByEmoteIDAndSeries(emoteId, Series)
  if config then
    return config.AfterClothID
  end
  log(bWriteLog and "DragonChangeForm:GetAfterClothIDByLobbyPawn config not found" .. tostring(emoteId) .. tostring(Series))
  return nil
end
function DragonChangeForm:OnPutOnFail(_, __, item, olditem)
  log_tree("DragonChangeForm:OnPutOnFail", item)
  log(bWriteLog and "DragonChangeForm:OnPutOnFail item = " .. tostring(item) .. " olditem = " .. tostring(olditem))
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if myAvatar == nil then
    log(bWriteLog and "ExpressionPopUIBP:OnClickChangeFormButton main avatar is nil")
    return
  end
  local avatar = myAvatar:GetModel()
  if avatar == nil then
    log(bWriteLog and "ExpressionPopUIBP:OnClickChangeFormButton avatar is nil")
    return
  end
  avatar:PutOnEquipmentByResID(olditem)
end
function DragonChangeForm:ChangeForm(uObject)
  log(bWriteLog and "DragonChangeForm:ChangeForm")
  local owner = uObject:GetOwningActor()
  if not slua.isValid(owner) then
    log(bWriteLog and "DragonChangeForm:ChangeForm owner is invalid")
    return
  end
  local AfterClothID = self:GetAfterClothIDByLobbyPawn(owner)
  if not AfterClothID then
    log(bWriteLog and "DragonChangeForm:ChangeForm not AfterClothID")
    return
  end
  local uid = owner:GetPlayerUID()
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    owner:PutOnEquipmentByResID(AfterClothID)
    local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
    logic_wardrobe_avatar:InitCurrentWearPreviewMap()
    local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(BP_ENUM_AVATAR_CLOTH)
    if not wearInfo then
      log(bWriteLog and "DragonChangeForm:ChangeForm not wearInfo")
      return
    end
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local source = wardrobe_data:GetItemSource(wearInfo.insID)
    self:PutOnItem(AfterClothID, source)
  else
    owner:PutOnEquipmentByResID(AfterClothID)
  end
end
function DragonChangeForm:OnReceiveInheritData()
  if self.CachePutOn then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_depot_put_on_req(self.CachePutOn)
    self.CachePutOn = nil
  end
end
function DragonChangeForm:PutOnItem(ItemID, Source)
  log(bWriteLog and "DragonChangeForm:PutOnItem ItemID = " .. tostring(ItemID) .. ", Source = " .. tostring(Source))
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local afterItemData = wardrobe_data:GetHallDepotItemDataByResID(ItemID, Source)
  if not afterItemData then
    log(bWriteLog and "DragonChangeForm:PutOnItem not afterItemData")
    return
  end
  if Source == EWardrobeDataSource.InheritWardrobe then
    local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
    if not LogicInheritWardrobe.bBackendIsOK then
      self.CachePutOn = tonumber(afterItemData.insID)
      local InheritHandle = require("client.network.Protocol.InheritHandle")
      InheritHandle.send_get_inherit_data_req()
      return
    end
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_depot_put_on_req(tonumber(afterItemData.insID))
end
function DragonChangeForm:CheckDownloadState(config)
  if config == nil then
    return false
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local itemIdList = {}
  table.insert(itemIdList, config.BeforeClothID)
  table.insert(itemIdList, config.ActionID)
  table.insert(itemIdList, config.AfterClothID)
  for _, id in pairs(itemIdList) do
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {id})
    log(bWriteLog and "DragonChangeForm CheckDownloadState check item_id: " .. tostring(id) .. " state: " .. tostring(state))
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return false
    end
  end
  return true
end
function DragonChangeForm:DownloadAllItems(config)
  if not config then
    log(bWriteLog and "DragonChangeForm:DownloadAllItems value is nil")
    return
  end
  log(bWriteLog and "DragonChangeForm:DownloadAllItems BeforeClothID = " .. tostring(config.BeforeClothID) .. " AfterClothID = " .. tostring(config.AfterClothID))
  local itemIdList = {}
  table.insert(itemIdList, config.BeforeClothID)
  table.insert(itemIdList, config.AfterClothID)
  table.insert(itemIdList, config.ActionID)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, itemIdList)
end
function DragonChangeForm:GetGuideState()
  log(bWriteLog and "DragonChangeForm:GetGuideState")
  local config = self:GetSelfConfigByCurWear()
  if not config then
    log(bWriteLog and "DragonChangeForm:GetGuideState config is nil")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local isClickTab1 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyChangeFormState1)
  local lobbyState1 = false
  if isClickTab1 and isClickTab1.isClick and isClickTab1.isClick == 1 then
    lobbyState1 = true
  end
  local isClickTab2 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyChangeFormState2)
  local lobbyState2 = false
  if isClickTab2 and isClickTab2.isClick and isClickTab2.isClick == 1 then
    lobbyState2 = true
  end
  if lobbyState1 and lobbyState2 then
    log(bWriteLog and "DragonChangeForm:GetGuideState lobbyState1 and lobbyState2 both true")
    return false
  end
  local showNumTab = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyShowNum)
  local showNum = 0
  if showNumTab and showNumTab.num then
    showNum = showNumTab.num
  end
  if 3 <= showNum then
    log(bWriteLog and "DragonChangeForm:GetGuideState showNum>=3")
    return false
  end
  if self.bShowCardGuide then
    log(bWriteLog and "DragonChangeForm:GetGuideState show card guide tips")
    return false
  end
  log(bWriteLog and "DragonChangeForm:GetGuideState return true")
  return true
end
function DragonChangeForm:UpdateGuideState(state)
  log(bWriteLog and "DragonChangeForm:UpdateGuideState state = " .. tostring(state))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if state == 1 then
    local isClickTab = {isClick = 1}
    PlayerPrefsSystem.SaveTableToFile_N(isClickTab, PlayerPrefsSystem.ePlayerPrefsType.eLobbyChangeFormState1)
  elseif state == 2 then
    local isClickTab = {isClick = 1}
    PlayerPrefsSystem.SaveTableToFile_N(isClickTab, PlayerPrefsSystem.ePlayerPrefsType.eLobbyChangeFormState2)
  end
end
function DragonChangeForm:UpdateShowGuideNum()
  log(bWriteLog and "DragonChangeForm:UpdateShowGuideNum")
  if self.bUpdateShowNum then
    print(bWriteLog and "DragonChangeForm:UpdateShowGuideNum bUpdateShowNum")
    return
  end
  self.bUpdateShowNum = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local showNumTab = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyShowNum)
  local showNum = 0
  if showNumTab and showNumTab.num then
    showNum = showNumTab.num
  end
  log(bWriteLog and "DragonChangeForm:UpdateShowGuideNum showNum = " .. tostring(showNum))
  showNum = showNum + 1
  showNumTab = {num = showNum}
  PlayerPrefsSystem.SaveTableToFile_N(showNumTab, PlayerPrefsSystem.ePlayerPrefsType.eLobbyShowNum)
end
function DragonChangeForm:SetShowCardGuide(bShow)
  self.bShowCardGuide = bShow
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CDragonChangeForm = class(CModuleBase, nil, DragonChangeForm)
return CDragonChangeForm