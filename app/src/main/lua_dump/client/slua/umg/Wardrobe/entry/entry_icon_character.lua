local EntryIconCharacter = {}
function EntryIconCharacter:OnInitialize()
  EntryIconCharacter.__super.OnInitialize(self)
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  local OnCharDownloaded = function()
    if not NewCharacterNetSystem:HasReqed() then
      local CharacterHandler = require("client.network.Protocol.CharacterHandler")
      CharacterHandler.send_character_info_req()
    end
  end
  if not LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_NewCharacter) then
    local extraParams = {callback = OnCharDownloaded}
    LobbyModUtils.CreateDownloadUIByModKey(LobbyModUtils.Enum_Mod_Name.EName_NewCharacter, self.UIRoot.CP_Download, extraParams)
  else
    OnCharDownloaded()
  end
  if NewCharacterNetSystem:HasReqed() then
    self:InitCharacterIcon()
  end
end
function EntryIconCharacter:RegistEvents()
  EntryIconCharacter.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_SWITCH_SUC, self.InitCharacterIcon, self)
  self:AddCommonEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_GET_INFO, self.OnGetCharacterInfo, self)
end
function EntryIconCharacter:OnGetCharacterInfo(eventType, eventID, error_code)
  if error_code == 0 then
    self:InitCharacterIcon()
  end
end
function EntryIconCharacter:InitCharacterIcon(eventType, eventID, characterID)
  local curCharacterID
  if characterID then
    curCharacterID = characterID
  else
    local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
    curCharacterID = NewCharacterNetSystem:GetCurUsedCharacterID()
  end
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  if CharacterUtils.DEFAULT_CHARACTER_ID == curCharacterID then
    self:SetTexture(self.UIRoot.IconImage, "/Game/UMG/Texture_200/Atlas/WardrobeUI_New2/Frames/WH_icon_CharacterExchange_png.WH_icon_CharacterExchange_png")
    return
  end
  local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
  NewCharacterSystem:SetCharacterImage(curCharacterID, self.UIRoot.IconImage)
end
function EntryIconCharacter:OnShowEntryIcon(eventType, eventID, show)
  if show then
    self:Show()
  else
    self:Hide()
  end
end
function EntryIconCharacter:OnEntryButtonClick()
  self:PlayAudio(sound_config.click_v1)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.workshop) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.workshop))
    return
  end
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  UIManager.ShowUI(UIManager.UI_Config.CharacterSelect, CharacterUtils.Enum_From.From_Wardrobe)
end
local class = require("class")
local ui_EntryIconBase = require("client.slua.umg.Wardrobe.entry.entry_icon_base")
local CEntryIconCharacter = class(ui_EntryIconBase, nil, EntryIconCharacter)
return CEntryIconCharacter