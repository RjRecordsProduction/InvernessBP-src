local SettingStyleLibrary = {
  DefaultSwitcherText = {39268, 39267}
}
local Init = function()
  local SettingResourceLibrary = import("/Game/UMG/UI_BP/Setting25/SettingResourceLibrary.SettingResourceLibrary_C")
  SettingStyleLibrary.GeneralBGColor = SettingResourceLibrary.GetOptionBackgroundColor(false)
  SettingStyleLibrary.ExpandedBGColor = SettingResourceLibrary.GetOptionBackgroundColor(true)
  SettingStyleLibrary.GeneralMargin = SettingResourceLibrary.GetOptionMargin(false)
  SettingStyleLibrary.ExpandedMargin = SettingResourceLibrary.GetOptionMargin(true)
  SettingStyleLibrary.H1Style = SettingResourceLibrary.GetH1Style()
  SettingStyleLibrary.H1Style_Dark = SettingResourceLibrary.GetH1Style_Dark()
  SettingStyleLibrary.H2Style = SettingResourceLibrary.GetH2Style()
  SettingStyleLibrary.H2Style_Dark = SettingResourceLibrary.GetH2Style_Dark()
  SettingStyleLibrary.H3Style = SettingResourceLibrary.GetH3Style()
  SettingStyleLibrary.H3Style_Dark = SettingResourceLibrary.GetH3Style_Dark()
  SettingStyleLibrary.H4Style_Dark = SettingResourceLibrary.GetH4Style_Dark()
end
Init()
return SettingStyleLibrary