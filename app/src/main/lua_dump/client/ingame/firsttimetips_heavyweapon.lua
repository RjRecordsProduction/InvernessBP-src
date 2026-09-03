function _ENV:firsttimetips_heavyweapon_RegisterUI()
  InGameUIManager.SubUIWidgetList(self, {
    {
      Path = "/Game/BluePrints/ControlInput/IngameFirstTimeTips/FirstTimeTips_Heavyweapon.FirstTimeTips_Heavyweapon_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    }
  }, {"Fighting"}, false, true, true)
  log(bWriteLog and "PVEVP_TIPSUI:ShowhEeavyWeaponModeTips firsttimetips_heavyweapon_RegisterUI")
end
HEAVYWEAPON_TIPSUI = HEAVYWEAPON_TIPSUI or {}
function HEAVYWEAPON_TIPSUI:ShowModeTips()
end
function HEAVYWEAPON_TIPSUI:DebugShow()
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) then
    local bUIAutoTest = GameAutotest:IsUIAutoTest()
    if bUIAutoTest then
      return
    end
  end
  if firsttimetips_heavyweapon then
    InGameUIManager.HandleDynamicCreation(firsttimetips_heavyweapon)
    InGameUIManager.HandleUIMessage(firsttimetips_heavyweapon, "Show")
    InGameUIManager.HandleUIMessage(firsttimetips_heavyweapon, "DebugShow")
  end
end
function HEAVYWEAPON_TIPSUI:HideModeTips()
  if firsttimetips_heavyweapon then
    InGameUIManager.HandleUIMessage(firsttimetips_heavyweapon, "Hide")
    InGameUIManager.HandleDynamicDestroy(firsttimetips_heavyweapon)
  end
end