local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
local NewCharacterSystem = {IDList = nil, DataList = nil}
function NewCharacterSystem:OnInitialize()
  NewCharacterSystem.__super.OnInitialize(self)
  self:_ResetData()
end
function NewCharacterSystem:OnLogOut()
  self:_ResetData()
end
function NewCharacterSystem:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:_ResetData()
  end
end
function NewCharacterSystem:JumpToCharacter(para)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_CHARACTER, true) then
    return
  end
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  if not LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_NewCharacter) then
    LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.EName_NewCharacter)
    local str = LocUtil.LocalizeResFormat(511044)
    ShowNotice(str)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.CharacterMain, para)
end
function NewCharacterSystem:JumpToVideo(ItemID)
  self:JumpToCharacter({itemId = ItemID})
end
function NewCharacterSystem:InitData()
  if self.IDList then
    self:SortCharacterIDList()
    return
  end
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  if not LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_NewCharacter) then
    return
  end
  self.IDList = {}
  local character_table = CDataTable.GetTable("character_table")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isCEVersion = PublishRegionMacros.IsCEVersion()
  for _, v in pairs(character_table) do
    if not isCEVersion or v.is_ce_open then
      table.insert(self.IDList, v.id)
    end
  end
  self:SortCharacterIDList()
end
function NewCharacterSystem:GetIDList()
  if not self.IDList or not next(self.IDList) then
    self:InitData()
  end
  return self.IDList
end
function NewCharacterSystem:GetCharacterIDByIndex(index)
  if not index or index <= 0 or index > self:GetMaxCharacterCount() then
    return 0
  end
  return self.IDList and self.IDList[index] or 0
end
function NewCharacterSystem:GetMaxCharacterCount()
  return self.IDList and #self.IDList or 0
end
function NewCharacterSystem:GetDataList(CharacterID, ItemType)
  if not self.IDList or not next(self.IDList) then
    self:InitData()
  end
  if not (self.DataList and self.DataList[CharacterID]) or not next(self.DataList[CharacterID]) then
    return nil
  end
  if not self.DataList[CharacterID][ItemType] or not next(self.DataList[CharacterID][ItemType]) then
    return nil
  end
  return self.DataList[CharacterID][ItemType]
end
function NewCharacterSystem:SortCharacterIDList()
  if not self.IDList or not next(self.IDList) then
    return
  end
  CharacterUtils:SortCharacterIDList(self.IDList)
end
function NewCharacterSystem:SetDataListByType(CharacterID, ItemType)
  local cfgChar = CDataTable.GetTableByFilter("character_param_table", "character_param", CharacterID)
  if not cfgChar then
    return
  end
  self.DataList = self.DataList or {}
  self.DataList[CharacterID] = self.DataList[CharacterID] or {}
  if self.DataList[CharacterID][ItemType] and next(self.DataList[CharacterID][ItemType]) then
    self:SortCharacterDataList(CharacterID, ItemType)
    return
  end
  local supply_optional_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.supply_optional_data)
  if not self.DataList[CharacterID] then
    self.DataList[CharacterID] = {}
  end
  for _, v in pairs(cfgChar) do
    local cfgItem = CDataTable.GetTableData("Item", v.item_id)
    if v.only_show ~= 1 and cfgItem and cfgItem.ItemType == ItemType then
      local Sort = cfgItem.ItemSubType
      local ItemTypeKey = ItemType
      if ItemType == CharacterUtils.Enum_Item_Type.EnumType_Sound and v.is_second_language then
        ItemTypeKey = CharacterUtils.Enum_Item_Type.EnumType_Sound_Box
        Sort = cfgItem.WeightforOrder
      end
      self.DataList[CharacterID][ItemTypeKey] = self.DataList[CharacterID][ItemTypeKey] or {}
      if supply_optional_data:CheckCharacterSystemCanExchange(v.item_id) then
        table.insert(self.DataList[CharacterID][ItemTypeKey], {
          ID = v.item_id,
                  })
      end
    end
  end
  self:SortCharacterDataList(CharacterID, ItemType)
end
function NewCharacterSystem:SortCharacterDataList(CharacterID, ItemType)
  if not (self.DataList and self.DataList[CharacterID]) or not next(self.DataList[CharacterID]) then
    return
  end
  CharacterUtils:SortCharacterDataList(self.DataList[CharacterID], ItemType)
end
function NewCharacterSystem:GetCharacterIndexByID(CharacterID)
  self:InitData()
  for i, v in pairs(self.IDList) do
    if CharacterID == v then
      return i
    end
  end
  return 1
end
function NewCharacterSystem:GetCurCharSkinList()
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  local CharacterID = NewCharacterNetSystem:GetCurUsedCharacterID()
  local SkinList = self:GetDataList(CharacterID, CharacterUtils.Enum_Item_Type.EnumType_Skin)
  if not SkinList and CharacterID > CharacterUtils.DEFAULT_CHARACTER_ID then
    self:SetDataListByType(CharacterID, CharacterUtils.Enum_Item_Type.EnumType_Skin)
    SkinList = self:GetDataList(CharacterID, CharacterUtils.Enum_Item_Type.EnumType_Skin)
  end
  return SkinList
end
function NewCharacterSystem:SetCharacterImage(CharacterID, Widget)
  if not (CharacterID and Widget) or CharacterID <= 0 then
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", CharacterID)
  if not itemCfg then
    return
  end
  local asset_util = require("common.asset_util")
  asset_util.GetAssetAsync(CharacterUtils.CHARACTER_UI_MASK_PATH, function(material)
    if not material or not slua.isValid(Widget) then
      return
    end
    local KismetMaterialLibrary = import("KismetMaterialLibrary")
    local UIUtil = require("client.common.ui_util")
    local dynamicMatIns = KismetMaterialLibrary.CreateDynamicMaterialInstance(UIUtil.GetGameInstance(), material)
    if not dynamicMatIns then
      return
    end
    local texObj
    if CharacterUtils.DEFAULT_CHARACTER_ID == CharacterID then
      texObj = asset_util.GetAssetSync(CharacterUtils.DEFAULT_CHARACTER_HEAD_PATH)
    else
      texObj = asset_util.GetAssetSync(itemCfg.ItemSmallIcon)
    end
    if not texObj or not slua.isValid(texObj) then
      return
    end
    dynamicMatIns:SetTextureParameterValue("Tile", texObj)
    Widget:SetBrushFromMaterial(dynamicMatIns)
  end)
end
function NewCharacterSystem:_ResetData()
  self.IDList = nil
  self.DataList = nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CNewCharacterSystem = class(CModuleBase, nil, NewCharacterSystem)
return CNewCharacterSystem