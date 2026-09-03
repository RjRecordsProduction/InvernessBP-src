local Setting_Haptics_Config = {
  ChildSwitchConfig = {
    {
      HighButtonName = "Button_Haptics_Voice_High",
      MiddleButtonName = "Button_Haptics_Voice_Middle",
      LowButtonName = "Button_Haptics_Voice_Low",
      CloseButtonName = "Button_Haptics_Voice_Close",
      HighWidget = "Voice_High_On",
      MiddleWidget = "Voice_High_Middle",
      LowWidget = "Voice_High_Low",
      CloseWidget = "Voice_High_Close",
      SettingKey = "HapticVoiceSwitch",
      HideWidgetOnClose = {
        "VerticalBox_Voice"
      },
      CanvasPanelContent = "CanvasPanel_01"
    },
    {
      HighButtonName = "Button_3",
      MiddleButtonName = "Button_4",
      LowButtonName = "Button_5",
      CloseButtonName = "Button_6",
      HighWidget = "GridPanel_9",
      MiddleWidget = "GridPanel_12",
      LowWidget = "GridPanel_14",
      CloseWidget = "GridPanel_16",
      SettingKey = "HapticCharacterSwitch",
      HideWidgetOnClose = {
        "CanvasPanel_Character1"
      },
      CanvasPanelContent = "CanvasPanel_02"
    },
    {
      HighButtonName = "Button_7",
      MiddleButtonName = "Button_8",
      LowButtonName = "Button_9",
      CloseButtonName = "Button_10",
      HighWidget = "GridPanel_18",
      MiddleWidget = "GridPanel_20",
      LowWidget = "GridPanel_22",
      CloseWidget = "GridPanel_24",
      SettingKey = "HapticWeaponSwitch",
      HideWidgetOnClose = {
        "CanvasPanel_Weapon1",
        "CanvasPanel_Weapon2",
        "HorizontalBox_Weapon"
      },
      CanvasPanelContent = "CanvasPanel_03"
    },
    {
      HighButtonName = "Button_11",
      MiddleButtonName = "Button_12",
      LowButtonName = "Button_13",
      CloseButtonName = "Button_14",
      HighWidget = "GridPanel_26",
      MiddleWidget = "GridPanel_28",
      LowWidget = "GridPanel_30",
      CloseWidget = "GridPanel_65",
      SettingKey = "HapticVehicleSwitch",
      HideWidgetOnClose = {
        "CanvasPanel_Vehicle1",
        "HorizontalBox_Vehicle"
      },
      CanvasPanelContent = "CanvasPanel_04"
    }
  },
  NormalSwitchConfig = {
    {
      ButtonName = "Button_Voice_Step",
      SwitchName = "Setting_Switch_Voice_Step",
      SettingConfigKey = "bHapticVoiceStep"
    },
    {
      ButtonName = "Button_Voice_Grass",
      SwitchName = "Setting_Switch_Voice_Grass",
      SettingConfigKey = "bHapticVoiceGrass"
    },
    {
      ButtonName = "Button_Voice_Gun",
      SwitchName = "Setting_Switch_Voice_Gun",
      SettingConfigKey = "bHapticVoiceGun"
    },
    {
      ButtonName = "Button_Voice_Vehicle",
      SwitchName = "Setting_Switch_Voice_Vehicle",
      SettingConfigKey = "bHapticVoiceVehicle"
    },
    {
      ButtonName = "Button_Character_BeGunAttack",
      SwitchName = "Setting_Switch_Item_Character_BeGunAttack",
      SettingConfigKey = "bHapticCharacterBeGunAttack"
    },
    {
      ButtonName = "Button_Weapon_Attachment",
      SwitchName = "Setting_Switch_Item_Weapon_Attachment",
      SettingConfigKey = "bHapticWeaponAttachment"
    },
    {
      ButtonName = "Button_Weapon_Auto",
      SwitchName = "Setting_Switch_Item_Weapon_Auto",
      SettingConfigKey = "bHapticWeaponAuto"
    },
    {
      ButtonName = "Button_Weapon_SemiAuto",
      SwitchName = "Setting_Switch_Item_Weapon_SemiAuto",
      SettingConfigKey = "bHapticWeaponSemiAuto"
    },
    {
      ButtonName = "Button_Weapon_Sniper",
      SwitchName = "Setting_Switch_Item_Weapon_Sniper",
      SettingConfigKey = "bHapticWeaponSniper"
    },
    {
      ButtonName = "Button_Weapon_Other",
      SwitchName = "Setting_Switch_Item_Weapon_Other",
      SettingConfigKey = "bHapticWeaponOther"
    },
    {
      ButtonName = "Button_Vehicle_Drive",
      SwitchName = "Setting_Switch_Item_Vehicle_Drive",
      SettingConfigKey = "bHapticVehicleDrive"
    },
    {
      ButtonName = "Button_Vehicle_BeAttack",
      SwitchName = "Setting_Switch_Item_Vehicle_BeAttack",
      SettingConfigKey = "bHapticVehicleBeAttack"
    },
    {
      ButtonName = "Button_Vehicle_Hit",
      SwitchName = "Setting_Switch_Item_Vehicle_Hit",
      SettingConfigKey = "bHapticVehicleHit"
    }
  }
}
return Setting_Haptics_Config