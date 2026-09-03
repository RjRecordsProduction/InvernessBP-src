local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
local FuncLib = require("client.logic.NewSetting.Stack.FuncLib")
local Spacer = {
  UI = AliasMap.Spacer
}
local Stack_Game_Basic = {
  {
    UI = AliasMap.Title,
    Text = 25392
  },
  {
    Key = "LeftHandFire",
    UI = AliasMap.Switcher,
    Text = 33157,
    SwitcherText = {
      33210,
      33223,
      6402
    },
    SwitcherValue = FuncLib.SEQ120
  },
  {
    Key = "SingleShotWeaponShootMode",
    UI = AliasMap.Switcher,
    Text = 4368,
    SwitcherText = {4369, 4370}
  },
  {
    Key = "ShotGunShootMode",
    UI = AliasMap.Switcher,
    Text = 4371,
    SwitcherText = {4369, 4370}
  },
  Spacer,
  {
    UI = AliasMap.Title,
    Text = 25245
  },
  {
    Key = "OpenMirrorMode",
    UI = AliasMap.Switcher,
    Text = 33160,
    SwitcherText = {
      33215,
      33216,
      33217
    },
    Help = 10272
  },
  {
    Key = "RotateViewWithSniperSwitch",
    UI = AliasMap.Switcher,
    Text = 33161,
    Help = 116031
  },
  {
    Key = "QuasiMirrorSwitch",
    UI = AliasMap.Switcher,
    Text = 33162
  },
  {
    Key = "SideMirrorMode",
    UI = AliasMap.Switcher,
    Text = 33163,
    SwitcherText = {33220, 33221}
  },
  {
    Key = "FocalLengthModifySwitch",
    UI = AliasMap.Switcher,
    Text = 33164,
    SwitcherText = {33215, 33216},
    SwitcherValue = FuncLib.BOOL_FT
  },
  Spacer,
  {
    UI = AliasMap.Title,
    Text = 25247
  },
  {
    Key = "LeftRightShoot",
    UI = AliasMap.Switcher,
    Text = 25248,
    ExpandIndex = 0,
    RecommendedIndex = 0
  },
  {
    Key = "SidewaysMode",
    UI = AliasMap.Switcher,
    Text = 33166,
    SwitcherText = {
      33215,
      33216,
      33217
    },
    Help = 10271,
    ExpandHandle = "LeftRightShoot"
  },
  {
    Key = "LRShootSniperSwitch",
    UI = AliasMap.Switcher,
    Text = 33167,
    ExpandHandle = "LeftRightShoot"
  },
  {
    Key = "RotateViewWithPeekSwitch",
    UI = AliasMap.Switcher,
    Text = 33168,
    Help = 116030,
    ExpandHandle = "LeftRightShoot"
  }
}
return Stack_Game_Basic