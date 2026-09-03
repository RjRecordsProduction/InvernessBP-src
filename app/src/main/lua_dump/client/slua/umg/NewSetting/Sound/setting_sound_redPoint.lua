local UI = require("client.slua.umg.NewSetting.Sound.setting_sound_data")
function UI:RefreshSettingRedPoint()
  local SettingMacro = require("client.slua.logic.setting.setting_macro")
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_RED_POINT, SettingMacro.Tab.PictureAndAudio)
  if not GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    if MatchModeMgrSystem.IsSocialIslandMode() then
      return
    end
    LobbySystem.UpdateSettingRedPoint()
  end
end