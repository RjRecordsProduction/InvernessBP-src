function _ENV:death_playback_RegisterUI()
  InGameUIManager.SubUIWidgetList(self, {
    {
      Path = "/Game/BluePrints/ControlInput/ResultsshareUI/CompletePlayback_UIBP.CompletePlayback_UIBP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    }
  }, {"Fighting"}, false, true, true)
  log(bWriteLog and "death_playback_RegisterUI")
end
DeathplaybackUI = DeathplaybackUI or {}
function DeathplaybackUI:Init()
  log(bWriteLog and "----DeathplaybackUI:Init----")
  if death_playback then
    InGameUIManager.HandleDynamicCreation(death_playback)
    DeathplaybackUI:Show()
  end
end
function DeathplaybackUI:Show()
  log(bWriteLog and "----DeathplaybackUI:Show----")
  if death_playback ~= nil then
    InGameUIManager.HandleUIMessage(death_playback, "Deathplayback_ShowUI")
  end
end
function DeathplaybackUI:Hide()
  log(bWriteLog and "----DeathplaybackUI:Hide----")
  if death_playback ~= nil then
    InGameUIManager.HandleUIMessage(death_playback, "Deathplayback_HideUI")
  end
end
function DeathplaybackUI:OnPreLoadMap()
  log(bWriteLog and "----DeathplaybackUI:OnPreLoadMap----")
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetDeathPlayback ~= nil then
    local DeathPlaybackInstance = GameInstance:GetDeathPlayback()
    if slua.isValid(DeathPlaybackInstance) then
      DeathPlaybackInstance:ResetPlaybackData()
    end
  end
end
function DeathplaybackUI:UISetting_Weapon()
  log(bWriteLog and "----DeathplaybackUI:UISetting_Weapon----")
  if death_playback ~= nil then
    InGameUIManager.HandleUIMessage(death_playback, "UISetting_Weapon")
  end
end
function DeathplaybackUI:UISetting_Bullet()
  log(bWriteLog and "----DeathplaybackUI:UISetting_Bullet----")
  if death_playback ~= nil then
    InGameUIManager.HandleUIMessage(death_playback, "UISetting_Bullet")
  end
end