local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
local FuncLib = require("client.logic.NewSetting.Stack.FuncLib")
local Stack_Pickup = {
  {
    Key = "AutoPickupSwitcher",
    UI = AliasMap.Switcher,
    Text = 69624,
    Help = 10255,
    ExpandIndex = 0,
    SetFunc = function(_, value)
      local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
      SettingModule:SetOptionValue("AutoPickupSwitcher", value)
      if value == false then
        SettingModule:SetOptionValue("AutoPickupSwitcherTPlan", false)
      end
      return true
    end
  },
  {
    Key = "AutoPickupSwitcherTPlan",
    UI = AliasMap.Switcher,
    Text = 880012,
    Help = 880013,
    ExpandHandle = "AutoPickupSwitcher",
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      return not PublishRegionMacros.IsBLUEHOLE()
    end
  },
  {
    Key = "AutoPickUpLevel3Backpack",
    UI = AliasMap.Switcher,
    Text = 69625,
    ExpandHandle = "AutoPickupSwitcher"
  },
  {
    Key = "AutoPickUpPistol",
    UI = AliasMap.Switcher,
    Text = 69626,
    ExpandHandle = "AutoPickupSwitcher"
  },
  {
    Key = "AutoPickMirror",
    UI = AliasMap.Switcher,
    Text = 69627,
    ExpandHandle = "AutoPickupSwitcher"
  },
  {
    Key = "AutoPickUpSideSight",
    UI = AliasMap.Switcher,
    Text = 69628,
    ExpandHandle = "AutoPickupSwitcher"
  },
  {
    Key = "DisableAutoPickDropMirror",
    UI = AliasMap.Switcher,
    Text = 69629,
    Help = 21146,
    ExpandHandle = "AutoPickupSwitcher"
  },
  {
    Key = "DisableAutoPickupSwitcher",
    UI = AliasMap.Switcher,
    Text = 69630,
    ExpandHandle = "AutoPickupSwitcher"
  },
  {
    Key = "AutoPickClipType",
    UI = AliasMap.Switcher,
    Text = 69631,
    SwitcherText = {
      69634,
      69635,
      69636
    },
    SwitcherValue = FuncLib.SEQ120,
    ExpandHandle = "AutoPickupSwitcher"
  },
  {
    Key = "AutoPickMeleeType",
    UI = AliasMap.Switcher,
    Text = 69632,
    SwitcherText = {
      8340468,
      64649,
      18734
    },
    ExpandHandle = "AutoPickupSwitcher"
  },
  {
    Key = "bDropUnusefulMelee",
    UI = AliasMap.Switcher,
    Text = 69633,
    Help = 45674,
    RecommendedIndex = 0
  }
}
return Stack_Pickup