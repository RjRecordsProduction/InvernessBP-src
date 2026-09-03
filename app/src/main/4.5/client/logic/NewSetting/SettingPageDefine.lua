local Stack_Game_Basic = require("client.logic.NewSetting.Stack.Stack_Game_Basic")
local Stack_Game_Advanced = require("client.logic.NewSetting.Stack.Stack_Game_Advanced")
local Stack_VehicleControl = require("client.logic.NewSetting.Stack.Stack_VehicleControl")
local Stack_Pickup = require("client.logic.NewSetting.Stack.Stack_Pickup")
local Stack_Privacy = require("client.logic.NewSetting.Stack.Stack_Privacy")
local Stack_Social = require("client.logic.NewSetting.Stack.Stack_Social")
local Stack_Language = require("client.logic.NewSetting.Stack.Stack_Language")
local Stack_Net = require("client.logic.NewSetting.Stack.Stack_Net")
local SettingPageDefine = {
  Account = {
    Key = "Account",
    Text = 87189,
    UIKey = "setting_account"
  },
  Game = {
    Key = "Game",
    Text = 87195,
    UIKey = "Setting_Page_Game",
    Category = {
      {
        Key = "Game_Basic",
        Text = 87347,
        Stack = Stack_Game_Basic
      },
      {
        Key = "Game_Advanced",
        Text = 87348,
        Stack = Stack_Game_Advanced
      }
    }
  },
  Graphic = {
    Key = "Graphic",
    Text = 87191,
    UIKey = "setting_graphics_new"
  },
  CustomLayout = {
    Key = "CustomLayout",
    Text = 87196,
    Category = {
      {
        Key = "CustomLayout_Character",
        Text = 6259,
        UIKey = "Setting_Page_Layout_Character"
      },
      {
        Key = "CustomLayout_Vehicle",
        Text = 4663,
        UIKey = "Setting_Page_Layout_Vehicle",
        Stack = Stack_VehicleControl
      },
      {
        Key = "CustomLayout_Special",
        Text = 7307061,
        UIKey = "Setting_Page_Layout_Special"
      },
      {
        Key = "CustomLayout_MainCity",
        Text = 648005,
        UIKey = "WBP_Setting_Page_Layout_Special_Maincity",
        VisibilityFunc = function()
          return GameStatus.IsInMainCity()
        end
      }
    },
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      return true
    end
  },
  Sens = {
    Key = "Sens",
    Text = 87182,
    Category = {
      {
        Key = "Sens_Global",
        Text = 87583,
        UIKey = "Setting_Page_Sens"
      },
      {
        Key = "Sens_Weapon",
        Text = 21110,
        UIKey = "Setting_Page_WeaponSens"
      }
    }
  },
  Pickup = {
    Key = "Pickup",
    Text = 87183,
    Category = {
      {
        Key = "Pickup_AutoLoot",
        Text = 29927,
        UIKey = "Setting_Page_Pickup",
        Stack = Stack_Pickup
      },
      {
        Key = "Pickup_Attachment",
        Text = 29928,
        UIKey = "Setting_Page_Attachment"
      }
    }
  },
  VFX = {
    Key = "VFX",
    Text = 87184,
    Category = {
      {
        Key = "VFX_Crosshair",
        Text = 79709,
        UIKey = "Setting_Mirror_Main_UIBP"
      },
      {
        Key = "VFX_Effect",
        Text = 370100,
        UIKey = "setting_effect"
      }
    }
  },
  Audio = {
    Key = "Audio",
    Text = 87192,
    UIKey = "setting_haptics"
  },
  PrivacyAndSocial = {
    Key = "PrivacyAndSocial",
    Text = 25243,
    UIKey = "Setting_Page_Privacy",
    Category = {
      {
        Key = "Privacy",
        Text = 4309024,
        Stack = Stack_Privacy
      },
      {
        Key = "Social",
        Text = 25256,
        Stack = Stack_Social
      }
    }
  },
  LanguageAndNet = {
    Key = "LanguageAndNet",
    Text = 87185,
    UIKey = "Setting_Page_Language",
    Category = {
      {
        Key = "Language",
        Text = 62373,
        Stack = Stack_Language
      },
      {
        Key = "Net",
        Text = 612401104,
        Stack = Stack_Net,
        VisibilityFunc = function()
          local logic_grome_link = require("client.slua.logic.gromelink.logic_grome_link")
          print(bWriteLog and string.format("SettingPageDefine.LanguageAndNet:VisibilityFunc open1 = %s , open2 = %s ", tostring(logic_grome_link:ValidateGRomelinkActivation()), tostring(logic_grome_link:GRomeLinkFECSwitcherEnable())))
          return logic_grome_link:ValidateGRomelinkActivation() or logic_grome_link:GRomeLinkFECSwitcherEnable()
        end
      }
    }
  },
  Notif = {
    Key = "Notif",
    Text = 87194,
    UIKey = "setting_notifycations",
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      local region = Client.GetPublishRegion()
      return region ~= PublishRegionMacros.BLUEHOLE
    end
  },
  TV = {
    Key = "TV",
    Text = 87186,
    UIKey = "setting_tv",
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local region = Client.GetPublishRegion()
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      local gameID = Client.GetITopGameId()
      if region == PublishRegionMacros.JAPAN and string.find(gameID, "1321") then
        return not BP_IOS_CHECK
      end
      return false
    end
  },
  Other = {
    Key = "Other",
    Text = 644,
    UIKey = "setting_other",
    VisibilityFunc = function()
      local SettingPlatformSystem = require("client.slua.logic.setting.logic_platform")
      local AntiaddctionSystem = require("client.logic.antiaddction.logic_antiaddction")
      local MinorVerificationSystem = require("client.slua.logic.minor_verification.logic_minor_verification")
      return AntiaddctionSystem.is_show_setting or SettingPlatformSystem.CanShowTabInSetting() or MinorVerificationSystem.CanShowTabInSetting
    end
  }
}
if IsWoWEditor then
  SettingPageDefine.PrivacyAndSocial.Category[2] = nil
end
return SettingPageDefine