local ModeSelectionUtil = {}
local CardCollectionSeasonUIConfig = require("GameLua.Mod.Lobby.Base.CardCollection.logic.CardCollectionSeasonUIConfig")
local EPaneltype = CardCollectionSeasonUIConfig.ECardCollectionPanelType
local EPopuptype = CardCollectionSeasonUIConfig.ECardCollectionPopupType
local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
function ModeSelectionUtil.IsModeSelectionModDownloaded()
  if LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_ModeSelection) then
    return true
  else
    LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.EName_ModeSelection, function()
      log(bWriteLog and "ModeSelectionUtil.IsModeSelectionModDownloaded DownloadMod")
    end)
    return false
  end
end
return ModeSelectionUtil