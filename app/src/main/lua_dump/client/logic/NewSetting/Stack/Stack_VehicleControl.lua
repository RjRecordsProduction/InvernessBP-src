local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
local SEQ10 = {1, 0}
local Stack_VehicleControl = {
  {
    UI = AliasMap.Title,
    Text = 876169
  },
  {
    UI = AliasMap.Title,
    Text = 876170
  },
  {
    Key = "DrivingViewMode",
    UI = AliasMap.Switcher,
    Text = 78541,
    SwitcherText = {99009927, 99009926},
    Help = 11482
  },
  {
    Key = "CarMusicSwitch",
    UI = AliasMap.Switcher,
    Text = 78542
  },
  {
    Key = "CarPreciseChangeSeat",
    UI = AliasMap.Switcher,
    Text = 78543
  },
  {
    Key = "DriftMode",
    UI = AliasMap.Switcher,
    Text = 876160,
    SwitcherValue = SEQ10
  }
}
return Stack_VehicleControl