local NewCharacterNetSystem = {
  character_info = nil,
  UnLockTable = nil,
  LevelUpData = nil
}
function NewCharacterNetSystem:OnInitialize()
  NewCharacterNetSystem.__super.OnInitialize(self)
  self:_ResetData()
end
function NewCharacterNetSystem:OnLogOut()
  self:_ResetData()
end
function NewCharacterNetSystem:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    if not self.character_info then
      local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
      self.character_info = {
        cur_id = CharacterUtils.DEFAULT_CHARACTER_ID,
        characters = {}
      }
      if LobbySystem.roleData.character then
        self.character_info.cur_id = LobbySystem.roleData.character.id or CharacterUtils.DEFAULT_CHARACTER_ID
        table.insert(self.character_info.characters, LobbySystem.roleData.character)
      else
        log(bWriteLog and string.format("NewCharacterNetSystem:OnPostSwitchGameStatus LobbySystem.roleData.character is nil."))
      end
    end
    if not self.hasSent then
      local CharacterHandler = require("client.network.Protocol.CharacterHandler")
      CharacterHandler.send_character_info_req()
    end
  end
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:_ResetData()
  end
end
function NewCharacterNetSystem:HasReqed()
  return self.hasSent
end
function NewCharacterNetSystem:GetCharacterDataByID(CharacterID)
  if not (self.character_info and CharacterID) or CharacterID <= 0 then
    return nil
  end
  if not self.character_info.characters or not next(self.character_info.characters) then
    return nil
  end
  return self.character_info.characters[CharacterID]
end
function NewCharacterNetSystem:GetCurUsedCharacterData()
  local CharacterID = self:GetCurUsedCharacterID()
  if not CharacterID or CharacterID <= 0 then
    return nil
  end
  return self:GetCharacterDataByID(CharacterID)
end
function NewCharacterNetSystem:InitUnLockTable(ids)
  if not ids then
    return
  end
  self.UnLockTable = {}
  for i, v in pairs(ids) do
    self.UnLockTable[v] = true
  end
end
function NewCharacterNetSystem:SetUnLockTable(CharacterID)
  if not CharacterID or CharacterID <= 0 then
    return
  end
  self.UnLockTable = self.UnLockTable or {}
  self.UnLockTable[CharacterID] = true
end
function NewCharacterNetSystem:IsUnLockedCharacter(CharacterID)
  if not CharacterID or CharacterID <= 0 then
    return
  end
  if not self.UnLockTable then
    local ids = DataMgr.roleData.character_ids or {}
    self:InitUnLockTable(ids)
  end
  local characterData = self:GetCharacterDataByID(CharacterID)
  if characterData and characterData.expired_time then
    return false
  end
  return self.UnLockTable[CharacterID] or false
end
function NewCharacterNetSystem:GetCurUsedCharacterID()
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  return self.character_info and self.character_info.cur_id or CharacterUtils.DEFAULT_CHARACTER_ID
end
function NewCharacterNetSystem:IsUsedCharacter(CharacterID)
  if self.character_info == nil or not next(self.character_info) then
    return false
  end
  if CharacterID == self.character_info.cur_id then
    return true
  end
  return false
end
function NewCharacterNetSystem:IsUnLockedItem(ItemID)
  if not ItemID or ItemID <= 0 then
    return false
  end
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if not (itemCfg and itemCfg.ItemType) or 0 >= itemCfg.ItemType then
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  if itemCfg.ItemType == CharacterUtils.Enum_Item_Type.EnumType_Sound then
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
    if ActorVoiceSystem.CheckIsVoiceValidByItemID(ItemID) then
      return true
    end
  elseif wardrobe_data:GetHallDepotItemDataByResID(ItemID) then
    return true
  end
  return false
end
function NewCharacterNetSystem:ShowErrorTips(error_id)
  local TextData = LocUtil.GetLocalizeResStr(error_id)
  if TextData ~= "" then
    ShowNotice(TextData)
  else
    ShowNotice(error_id)
  end
end
function NewCharacterNetSystem:UpdateCharacterExpLevel(character_id, exp, level)
  if not self.character_info or not self.character_info.characters then
    return
  end
  if self.character_info.characters[character_id] then
    self.character_info.characters[character_id].    self.character_info.characters[character_id].  end
end
function NewCharacterNetSystem:AddCharacterSkill(character_id, skill_type, skill_id)
  if not self.character_info or not self.character_info.characters then
    return
  end
  if self.character_info.characters[character_id] then
    self.character_info.characters[character_id].skills = self.character_info.characters[character_id].skills or {}
    self.character_info.characters[character_id].skills[skill_type] = skill_id
  end
end
function NewCharacterNetSystem:UpdateCharacterBoxExp(character_id, box_exp)
  if not self.character_info or not self.character_info.characters then
    return
  end
  if self.character_info.characters[character_id] then
    self.character_info.characters[character_id].  end
end
function NewCharacterNetSystem:GetLabCurUseCharacterID()
  local version_util = require("client.common.version_util")
  local version = version_util.GetClientFormat(version_util.sClientVersion)
  local defaultVersionCharacterCfg = CDataTable.GetTableData("LabVersionDefaultCfg", version)
  if defaultVersionCharacterCfg and defaultVersionCharacterCfg.DefaultCharacterID then
    log(bWriteLog and "NewCharacterNetSystem.GetLabCurUseCharacterID DefaultCharacterID: " .. tostring(defaultVersionCharacterCfg.DefaultCharacterID))
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local ePath = PlayerPrefsSystem.ePlayerPrefsType.eWorkShopCharacter
    local tableData = PlayerPrefsSystem.LoadFileToTable_N(ePath) or {}
    if tableData.versionDefaultCharacter == nil then
      tableData.versionDefaultCharacter = {}
    end
    log(bWriteLog and "NewCharacterNetSystem.GetLabCurUseCharacterID version:" .. tostring(tableData.versionDefaultCharacter[version]))
    if not tableData.versionDefaultCharacter[version] then
      tableData.versionDefaultCharacter[version] = true
      PlayerPrefsSystem.SaveTableToFile_N(tableData, ePath)
      return defaultVersionCharacterCfg.DefaultCharacterID
    end
  end
  return self:GetCurUsedCharacterID()
end
function NewCharacterNetSystem:ShowCharacterLevelUpView()
  if not self.LevelUpData then
    return
  end
  log(bWriteLog and "NewCharacterNetSystem:ShowCharacterLevelUpView")
  self:AddTimerOnce(1, function()
    if GameStatus.IsInLobbyOrMainCity() and self.LevelUpData then
      UIManager.ShowUI(UIManager.UI_Config.CharacterLevelUpAward, self.LevelUpData)
      self.LevelUpData = nil
    end
  end)
end
function NewCharacterNetSystem:GetLevelBoxInfo(CharacterID)
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  if not CharacterID or CharacterID <= CharacterUtils.DEFAULT_CHARACTER_ID then
    return
  end
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  LobbyModUtils.GetSplitTableByFilter("Lobby", "NewCharacter", "character_level", function(cfgChar)
    if not cfgChar then
      return
    end
    local BasicDataChestTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataChestTable)
    for i, v in pairs(cfgChar) do
      if v.unlock_id1 and v.unlock_id1 > 0 then
        local itemCfg = CDataTable.GetTableData("Item", v.unlock_id1)
        if itemCfg and itemCfg.ItemType == CharacterUtils.Enum_Item_Type.EnumType_Box then
          BasicDataChestTable:GetOrReqData(v.unlock_id1)
        end
      end
    end
  end, "character_id", CharacterID)
end
function NewCharacterNetSystem:CurRoleIsCharacter()
  local charID = self:GetCurUsedCharacterID()
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  return charID > CharacterUtils.DEFAULT_CHARACTER_ID
end
function NewCharacterNetSystem:IsCharacterSkillUnlock(CharacterID, skill_id)
  local CharData = self:GetCharacterDataByID(CharacterID)
  if not (CharData and CharData.skills) or not next(CharData.skills) then
    return false
  end
  local SkillCfg = CDataTable.GetTableData("character_skill", skill_id)
  if not SkillCfg then
    return false
  end
  for type, _ in pairs(CharData.skills) do
    if type == SkillCfg.skill_type then
      return true
    end
  end
  return false
end
function NewCharacterNetSystem:CanUseExperienceCard(CharacterID)
  if self:IsUnLockedCharacter(CharacterID) then
    local characterData = self:GetCharacterDataByID(CharacterID)
    if characterData and not characterData.expired_time then
      return false
    end
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local list = wardrobe_data:GetHallDepotItemListByItemSubType(1663, true)
  for _, data in pairs(list) do
    local characterIDList = CDataTable.GetSplitTableData("Lobby", "NewCharacter", "character_experience_card_table", data.ResID)
    for charID in string.gmatch(characterIDList.unlock_characters, "([^|]+)") do
      if tonumber(charID) == CharacterID then
        return true
      end
    end
  end
  return false
end
function NewCharacterNetSystem:GetExperienceCardInsID(CharacterID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local list = wardrobe_data:GetHallDepotItemListByItemSubType(1663, true)
  for _, data in pairs(list) do
    local characterIDList = CDataTable.GetSplitTableData("Lobby", "NewCharacter", "character_experience_card_table", data.ResID)
    for charID in string.gmatch(characterIDList.unlock_characters, "([^|]+)") do
      if tonumber(charID) == CharacterID then
        return data.InsID
      end
    end
  end
  return false
end
function NewCharacterNetSystem:on_character_info_rsp(character_info, error_code)
  log_tree("NewCharacterNetSystem.on_character_info_rsp character_info: ", character_info)
  if error_code == 0 then
    self.hasSent = true
    self.character_info = character_info or {}
    self.character_info.characters = self.character_info.characters or {}
    DataMgr.roleData.character_ids = {}
    for _, v in pairs(self.character_info.characters) do
      table.insert(DataMgr.roleData.character_ids, v.id)
    end
    self:InitUnLockTable(DataMgr.roleData.character_ids)
    local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
    NewCharacterSystem:InitData()
  end
  EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_GET_INFO, error_code)
end
function NewCharacterNetSystem:on_create_character_notify(character)
  log_tree("NewCharacterNetSystem.on_create_character_notify character: ", character)
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  self.character_info = self.character_info or {
    cur_id = CharacterUtils.DEFAULT_CHARACTER_ID
  }
  self.character_info.characters = self.character_info.characters or {}
  self.character_info.characters[character.id] = character
  DataMgr.roleData.character_ids = DataMgr.roleData.character_ids or {
    CharacterUtils.DEFAULT_CHARACTER_ID
  }
  table.insert(DataMgr.roleData.character_ids, character.id)
  self:SetUnLockTable(character.id)
  local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
  NewCharacterSystem:SortCharacterIDList()
  EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_CREATE, character)
end
function NewCharacterNetSystem:on_switch_character_rsp(character)
  log_tree("NewCharacterNetSystem.on_switch_character_rsp character: ", character)
  self:PutOffOldCharacterWear()
  self.character_info = self.character_info or {
    cur_id = LobbySystem.roleData.character.id
  }
  self.character_info.characters = self.character_info.characters or {}
  self.character_info.cur_id = character.id
  local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
  NewCharacterSystem:SortCharacterIDList()
  AvatarData.SetHeadID(character.avatar.headid)
  AvatarData.SetHairID(character.avatar.hairid)
  AvatarData.SetGameGender(character.avatar.gamegender)
  AvatarData.SetBeardID(character.avatar.beardid or 0)
  AvatarData.SetBeardColorID(character.avatar.beardcolor or 0)
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  BasicDataAvatarWearInfo:UpdateRoleSexByUid(DataMgr.roleData.uid, character.avatar.gamegender)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.UpdatePlayer(true)
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  logic_wardrobe_avatar:InitCurrentWearPreviewMap(true)
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  logic_share_bag_team_util:DeselectShareBagItems()
  local CharCfg = CDataTable.GetTableData("Item", character.id)
  if CharCfg and CharCfg.ItemName ~= "" then
    local switchTips = LocUtil.LocalizeResFormat(7016, CharCfg.ItemName)
    ShowNotice(switchTips)
  end
  EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_SWITCH_SUC, character.id)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_AVATAR_LIST)
end
function NewCharacterNetSystem:on_character_exchange_rsp(exchange_id)
  log(bWriteLog and "NewCharacterNetSystem.on_character_exc hange_rsp exchange_id: " .. tostring(exchange_id))
  local arrayItemList = {}
  table.insert(arrayItemList, {res_id = exchange_id, count = 1})
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
  EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_EXCHANGE_SUC, exchange_id)
end
function NewCharacterNetSystem:on_character_use_exp_card_rsp(character_id, exp, level)
  log(bWriteLog and "NewCharacterNetSystem.on_character_use_exp_card_rsp character_id: " .. tostring(character_id) .. ", exp\239\188\154" .. tostring(exp) .. "\239\188\140level\239\188\154" .. tostring(level))
end
function NewCharacterNetSystem:on_character_exp_notify(character_id, after_exp, exp, after_level, before_level)
  log(bWriteLog and "NewCharacterNetSystem.on_character_exp_notify character_id: " .. tostring(character_id) .. ", after_exp\239\188\154" .. tostring(after_exp) .. "\239\188\140exp\239\188\154" .. tostring(exp) .. "\239\188\140after_level\239\188\154" .. tostring(after_level) .. "\239\188\140before_level\239\188\154" .. tostring(before_level))
  self:UpdateCharacterExpLevel(character_id, after_exp, after_level)
  if before_level < after_level then
    local data = {
      CharacterID = character_id,
      CurLevel = before_level,
      NextLevel = after_level,
      TotalExp = exp,
      CurLevelExp = after_exp
    }
    if GameStatus.IsInLobbyOrMainCity() then
      UIManager.ShowUI(UIManager.UI_Config.CharacterLevelUpAward, data)
    else
      self.LevelUpData = data
    end
  elseif GameStatus.IsInLobbyOrMainCity() then
    local CharCfg = CDataTable.GetTableData("Item", character_id)
    local switchTips = LocUtil.LocalizeResFormat(7492, CharCfg and CharCfg.ItemName or "", tostring(exp))
    ShowNotice(switchTips)
  end
  EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_EXP_UPDATE)
end
function NewCharacterNetSystem:on_character_del_notify(character_id)
  log(bWriteLog and "NewCharacterNetSystem.on_character_del_notify character_id: " .. character_id)
end
function NewCharacterNetSystem:on_character_skill_upgrade_notify(character_id, skill_type, after_skill, before_skill)
  log(bWriteLog and "NewCharacterNetSystem.on_character_skill_upgrade_notify character_id: " .. tostring(character_id) .. ", skill_type\239\188\154" .. tostring(skill_type) .. "\239\188\140after_skill\239\188\154" .. tostring(after_skill) .. "\239\188\140after_skill\239\188\154" .. tostring(before_skill))
  self:AddCharacterSkill(character_id, skill_type, after_skill)
  self:AddTimerOnce(0.2, function()
    EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_SKILL_UPDATE)
  end)
end
function NewCharacterNetSystem:on_decompose_character_notify(item_id, items)
  log_tree("NewCharacterNetSystem.on_decompose_character_notify item_id " .. tostring(item_id) .. ", items:", items)
  local itemCfg = CDataTable.GetTableData("Item", item_id)
  local str1 = itemCfg and itemCfg.ItemName
  local str2 = ""
  local str3 = ""
  if items then
    for key, v in pairs(items) do
      itemCfg = CDataTable.GetTableData("Item", key)
      if itemCfg and itemCfg.ItemName then
        str2 = v
        str3 = itemCfg.ItemName
        break
      end
    end
  end
  ShowNotice(LocUtil.LocalizeResFormat(6345, str1, str2, str3))
end
function NewCharacterNetSystem:on_character_open_box_rsp(character_id, cnt, after_box_exp, items, decompose_list)
  log_tree("CharacterNetSystem.on_character_open_box_rsp character_id: " .. tostring(character_id) .. ",cnt:" .. tostring(cnt) .. ",after_box_exp:" .. tostring(after_box_exp) .. ", items:", items)
  self:UpdateCharacterBoxExp(character_id, after_box_exp)
  EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_BOX_EXP_UPDATE)
  for _, v in pairs(items) do
    local preKeyValue = v.resid
    v.res_id = preKeyValue
    v.resid = nil
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(items)
  if decompose_list and next(decompose_list) then
    log_tree("CharacterNetSystem.on_character_open_box_rsp decompose_list:", decompose_list)
    local fromeItemName
    local toItemID = 0
    local toItemCount = 0
    local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
    for key, v in pairs(decompose_list) do
      if items[key] then
        local fromeItemCfg = CDataTable.GetTableData("Item", items[key].res_id)
        if fromeItemCfg and fromeItemCfg.ItemType == CharacterUtils.Enum_Item_Type.EnumType_Sound then
          if fromeItemName == nil and fromeItemCfg.ItemName then
            fromeItemName = fromeItemCfg.ItemName
          end
          for id, cnt in pairs(v) do
            if toItemID == 0 then
              toItemID = id
            end
            toItemCount = toItemCount + cnt
          end
        end
      end
    end
    local toItemCfg = CDataTable.GetTableData("Item", toItemID)
    if fromeItemName ~= nil and 0 < toItemID and toItemCfg then
      local toCnt = tostring(toItemCount)
      local content = LocUtil.LocalizeResFormat(6345, fromeItemName, toCnt, toItemCfg.ItemName)
      ShowNotice(content)
    end
  end
end
function NewCharacterNetSystem:on_character_box_exp_notify(character_id, after_box_exp, before_box_exp)
  log(bWriteLog and "NewCharacterNetSystem.on_character_box_exp_notify character_id: " .. tostring(character_id) .. ",after_box_exp:" .. tostring(after_box_exp) .. ",before_box_exp:" .. tostring(before_box_exp))
  if before_box_exp < after_box_exp then
    self:UpdateCharacterBoxExp(character_id, after_box_exp)
    local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
    local boxCfg = CDataTable.GetTableData("character_box", character_id)
    if GameStatus.IsInLobbyOrMainCity() and boxCfg and boxCfg.box_id then
      local preBoxNum = CharacterUtils:ConvertBoxExpToNum(character_id, before_box_exp)
      local curBoxNum = CharacterUtils:ConvertBoxExpToNum(character_id, after_box_exp)
      if 0 < curBoxNum - preBoxNum then
        local arrayItemList = {}
        table.insert(arrayItemList, {
          res_id = boxCfg.box_id,
          count = curBoxNum - preBoxNum
        })
        local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
        Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList, false, false)
      else
        local CharCfg = CDataTable.GetTableData("Item", character_id)
        if CharCfg and CharCfg.ItemName ~= "" then
          local addExp = after_box_exp - before_box_exp
          local switchTips = LocUtil.LocalizeResFormat(7492, CharCfg.ItemName, tostring(addExp))
          ShowNotice(switchTips)
        end
      end
    end
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.4, function()
      EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_BOX_EXP_UPDATE)
    end)
  end
end
function NewCharacterNetSystem:on_character_update_hairid(characterid, hairid)
  log(bWriteLog and "NewCharacterNetSystem.on_switch_character_rsp characterid: " .. tostring(characterid) .. " hairid:" .. tostring(hairid))
  if not self.character_info or not self.character_info.characters then
    return
  end
  if self.character_info.characters[characterid] then
    self.character_info.characters[characterid].avatar = self.character_info.characters[characterid].avatar or {}
    self.character_info.characters[characterid].avatar.  end
  if self.character_info.cur_id == characterid then
    AvatarData.SetHairID(hairid)
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.UpdatePlayer()
    EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_HAIRID_NOTIFY, characterid, hairid)
  end
end
function NewCharacterNetSystem:_ResetData()
  self.character_info = nil
  self.UnLockTable = nil
  self.hasSent = nil
end
function NewCharacterNetSystem:PutOffOldCharacterWear()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local showingAvatar = TeamAvatarManager.GetMainAvatar()
  local equips = showingAvatar:GetEquipments() or {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  for i, v in ipairs(equips) do
    local characterId = CharacterUtils:GetCharacterIDByItemID(v.itemID)
    if characterId and 0 < characterId then
      local warDrobeData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.itemID)
      if warDrobeData and (warDrobeData.itemSubType == ENUM_ITEM_SUBTYPE.Helmet or warDrobeData.itemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel or warDrobeData.itemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot) and warDrobeData.insID then
        log(bWriteLog and "NewCharacterNetSystem.PutOffOldCharacterWear itemID: " .. tostring(v.itemID) .. "insID: " .. tostring(warDrobeData.insID))
        WardRobeHandler.send_depot_set_head_show_req(0)
      end
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CNewCharacterNetSystem = class(CModuleBase, nil, NewCharacterNetSystem)
return CNewCharacterNetSystem