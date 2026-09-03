local common_config = {
  BTN_BLUE_IMAGE_PATH = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lanse_png.Common_Btn_Lanse_png",
  BTN_YELLOW_IMAGE_PATH = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Huangse_png.Common_Btn_Huangse_png",
  blockPopupTip = nil,
  UpdateIniFile = Client.ProjectDir() .. "Config/DefaultUpdater.ini",
  PufferIniFile = Client.ProjectDir() .. "Config/DefaultPufferDownloader.ini",
  bShowAvatarInRank = true
}
function common_config:LoadBlackPopupCache()
  if self.blockPopupTip ~= nil then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUIShowTimeTest)
  if tCacheData then
    self.blockPopupTip = tCacheData.isTest
    self:BlockPopupTip(self.blockPopupTip)
  else
    self.blockPopupTip = false
  end
end
function common_config:BlockPopupTip(bIsBlocking, bNeedToSave)
  bIsBlocking = bIsBlocking and bIsBlocking or false
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  PufferSwitch.BanAutoDownload = bIsBlocking
  PufferSwitch.BanDownload = bIsBlocking
  log(bWriteLog and "common_config:BlockPopupTip UI responsiveness testing State : " .. tostring(bIsBlocking))
  if bNeedToSave then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({isTest = bIsBlocking}, PlayerPrefsSystem.ePlayerPrefsType.eUIShowTimeTest)
    Client.SetConfigBool(self.UpdateIniFile, "/Script/Client.GDolphinUpdater", "Disable", bIsBlocking)
    Client.SetConfigBool(self.PufferIniFile, "/Script/Client.GCPufferDownloader", "Disable", bIsBlocking)
    if bIsBlocking then
      ShowDevNotice("###\229\188\128\229\144\175UI\229\147\141\229\186\148\230\181\139\232\175\149: \229\177\143\232\148\189\230\139\141\232\132\184\227\128\129\230\136\144\229\176\177\227\128\129\231\187\132\233\152\159\229\188\128\233\187\145\227\128\129\230\184\184\229\174\162\233\153\144\229\136\182\231\173\137\229\188\185\231\170\151\239\188\140\229\177\143\232\148\189\231\137\136\230\156\172\230\155\180\230\150\176\227\128\129\228\184\139\232\189\189\227\128\129\232\135\170\229\138\168\228\184\139\232\189\189\227\128\129\230\142\146\232\161\140\230\166\156\228\186\186\231\137\169\229\177\149\231\164\186\231\173\137\229\138\159\232\131\189\239\188\140\230\157\128\232\191\155\231\168\139\231\148\159\230\149\136", false)
    end
  elseif bIsBlocking then
    ShowDevNotice("###\229\183\178\229\188\128\229\144\175UI\229\147\141\229\186\148\230\181\139\232\175\149: \229\177\143\232\148\189\228\186\134\230\139\141\232\132\184\227\128\129\230\136\144\229\176\177\227\128\129\231\187\132\233\152\159\229\188\128\233\187\145\227\128\129\230\184\184\229\174\162\233\153\144\229\136\182\231\173\137\229\188\185\231\170\151\239\188\140\229\177\143\232\148\189\231\137\136\230\156\172\230\155\180\230\150\176\227\128\129\228\184\139\232\189\189\227\128\129\232\135\170\229\138\168\228\184\139\232\189\189\227\128\129\230\142\146\232\161\140\230\166\156\228\186\186\231\137\169\229\177\149\231\164\186\231\173\137\229\138\159\232\131\189")
  end
  log(bWriteLog and "common_config:BlockPopupTip UI responsiveness testing State : " .. tostring(bIsBlocking))
  self.blockPopupTip = bIsBlocking
  self.bShowAvatarInRank = not bIsBlocking
end
function common_config:IsBlockingPopupTip()
  if IsWoWEditor then
    return true
  end
  if self.blockPopupTip == nil then
    self:LoadBlackPopupCache()
  end
  return self.blockPopupTip
end
function common_config:IsShowAvatarInRank()
  return self.bShowAvatarInRank
end
return common_config