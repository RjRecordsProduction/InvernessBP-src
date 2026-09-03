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
    loc = 87189,
    UIKey = "setting_account"
  },
  Game = {
    Key = "Game",
    loc = 87195,
    UIKey = "Setting_Page_Game",
    Category = {
      {
        Key = "Game_Basic",
        loc = 87347,
        Stack = Stack_Game_Basic
      },
      {
        Key = "Game_Advanced",
        loc = 87348,
        Stack = Stack_Game_Advanced
      }
    }
  },
  Graphic = {
    Key = "Graphic",
    loc = 87191,
    UIKey = "setting_graphics_new"
  },
  CustomLayout = {
    Key = "CustomLayout",
    loc = 87196,
    Category = {
      {
        Key = "CustomLayout_Character",
        loc = 6259,
        UIKey = "Setting_Page_Layout_Character"
      },
      {
        Key = "CustomLayout_Vehicle",
        loc = 4663,
        UIKey = "Setting_Page_Layout_Vehicle",
        Stack = Stack_VehicleControl
      },
      {
        Key = "CustomLayout_Special",
        loc = 7307061,
        UIKey = "Setting_Page_Layout_Special"
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
    loc = 87182,
    Category = {
      {
        Key = "Sens_Global",
        loc = 87583,
        UIKey = "Setting_Page_Sens"
      },
      {
        Key = "Sens_Weapon",
        loc = 21110,
        UIKey = "Setting_Page_WeaponSens"
      }
    }
  },
  Pickup = {
    Key = "Pickup",
    loc = 87183,
    Category = {
      {
        Key = "Pickup_AutoLoot",
        loc = 29927,
        UIKey = "Setting_Page_Pickup",
        Stack = Stack_Pickup
      },
      {
        Key = "Pickup_Attachment",
        loc = 29928,
        UIKey = "Setting_Page_Attachment"
      }
    }
  },
  VFX = {
    Key = "VFX",
    loc = 87184,
    Category = {
      {
        Key = "VFX_Crosshair",
        loc = 79709,
        UIKey = "Setting_Mirror_Main_UIBP"
      },
      {
        Key = "VFX_Effect",
        loc = 370100,
        UIKey = "setting_effect"
      }
    }
  },
  Audio = {
    Key = "Audio",
    loc = 87192,
    UIKey = "setting_haptics"
  },
  PrivacyAndSocial = {
    Key = "PrivacyAndSocial",
    loc = 25243,
    UIKey = "Setting_Page_Privacy",
    Category = {
      {
        Key = "Privacy",
        loc = 4309024,
        Stack = Stack_Privacy
      },
      {
        Key = "Social",
        loc = 25256,
        Stack = Stack_Social
      }
    }
  },
  LanguageAndNet = {
    Key = "LanguageAndNet",
    loc = 87185,
    UIKey = "Setting_Page_Language",
    Category = {
      {
        Key = "Language",
        loc = 62373,
        Stack = Stack_Language
      },
      {
        Key = "Net",
        loc = 612401104,
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
    loc = 87194,
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
    loc = 87186,
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
    loc = 644,
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