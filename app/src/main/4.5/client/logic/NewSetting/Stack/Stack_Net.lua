local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
local Stack_Net = {
  {
    Key = "GromeLinkOpen",
    OnVersion = "4.5.0",
    UI = AliasMap.Switcher,
    Text = 612401105,
    Help = 612401107,
    Decoration = UIManager.UI_Config.Setting_Decoration_Beta,
    EventType = EVENTTYPE_SETTING,
    EventID = EVENTID_SETTING_GROME_LINK_SUCCESS,
    GetFunc = function()
      local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
      return LogicSettingBasic.nGromeLinkOpenValue == 1
    end,
    SetFunc = function(key, bValue)
      local SettingSystem = require("client.logic.setting.logic_setting")
      SettingSystem.send_set_grome_link_open_req(bValue and 1 or 0)
      return true
    end,
    VisibilityFunc = function()
      local logic_grome_link = require("client.slua.logic.gromelink.logic_grome_link")
      return logic_grome_link:ValidateGRomelinkActivation()
    end
  },
  {
    Key = "NetOptimizationOpen",
    OnVersion = "4.5.0",
    UI = AliasMap.Switcher,
    Text = 612401120,
    Help = 612401121,
    Decoration = UIManager.UI_Config.Setting_Decoration_Beta,
    EventType = EVENTTYPE_SETTING,
    EventID = EVENTID_SETTING_NET_FEC_SWITCHER_SUCCESS,
    GetFunc = function()
      local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
      return LogicSettingBasic.nGromeLinkFECSwitcher == 1
    end,
    SetFunc = function(key, bValue)
      local SettingSystem = require("client.logic.setting.logic_setting")
      SettingSystem.send_set_grome_link_fec_req(bValue and 1 or 0)
      return true
    end,
    VisibilityFunc = function()
      local logic_grome_link = require("client.slua.logic.gromelink.logic_grome_link")
      return logic_grome_link:GRomeLinkFECSwitcherEnable()
    end
  }
}
return Stack_Net