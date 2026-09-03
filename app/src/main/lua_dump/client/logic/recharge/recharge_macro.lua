local Recharge_Macro = {TLogRechargeType = 1}
local Enum_ShowBgType = {
  None = 0,
  NewDefaultBg = 1,
  Image_Bg = 2
}
local Enum_Subscribe_SubTabType = {buySubscribe = 1, subscribed = 2}
Recharge_Macro.local SubscribeSubTabDataConfig = {
  [Enum_Subscribe_SubTabType.buySubscribe] = {
    iconNormal = "/Game/UMG/Texture/Atlas/Supply_UI/Frames/Supply_icon_exchange_png.Supply_icon_exchange_png",
    iconSelect = "/Game/UMG/Texture/Atlas/Supply_UI/Frames/Supply_icon_exchange_png.Supply_icon_exchange_png",
    UIConfig = function()
      return "Subscribe_HomePage_New_UIBP"
    end,
    NameId = 6177,
    BgType = Enum_ShowBgType.NewDefaultBg
  }
}
Recharge_Macro.return Recharge_Macro