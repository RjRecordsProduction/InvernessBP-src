local suit_dye_macros = {
  COLOR_DISPLAY_FORMAT = "R:%.0f G:%.0f B:%.0f",
  MAX_HUE = 360,
  MAX_SATURATION = 100,
  MAX_BRIGHTNESS = 100,
  MAX_RGB = 255,
  SUIT_DYE_SCENE = "Lobby_Roulettebackground_mesh",
  SUIT_DYE_CAMERA = 10113,
  UNLOCK_LINEAR_COLOR = FLinearColor(1, 1, 1, 1),
  LOCK_LINEAR_COLOR = FLinearColor(1, 1, 1, 0.3),
  UNLOCK_SLATE_COLOR = FSlateColor(FLinearColor(1, 1, 1, 1)),
  LOCK_SLATE_COLOR = FSlateColor(FLinearColor(1, 1, 1, 0.3)),
  MAX_PART_COUNT = 6,
  MAX_SUIT_LEVEL = 3,
  PURCHASE_COLOR_TEXT = "\231\161\174\229\174\154\232\138\177\232\180\185<img src=\"ClothingCoinImage\"/>{0}\228\191\174\230\148\185\233\162\156\232\137\178\229\144\151\239\188\159",
  PURCHASE_COLOR_FREE_TEXT = "\231\161\174\229\174\154\228\191\174\230\148\185\233\162\156\232\137\178\229\144\151\239\188\159",
  USE_PRESET_PLAN_TIP1 = "\229\183\178\228\189\191\231\148\168\233\162\132\232\174\190\230\150\185\230\161\136{0}\239\188\140\230\156\170\232\167\163\233\148\129\233\131\168\228\189\141\228\184\141\231\148\159\230\149\136",
  USE_PRESET_PLAN_TIP2 = "\229\183\178\228\189\191\231\148\168\233\162\132\232\174\190\230\150\185\230\161\136{0}",
  CURRENT_PRICE_INFO = "\229\189\147\229\137\141\230\148\185\232\137\178\228\187\183\230\160\188\239\188\154<img src=\"ClothingCoinImage\"/>{0}",
  UPGRATE_TIP = "\230\152\175\229\144\166\230\182\136\232\128\151<ShopRecharge_Font>{0}\228\184\170{1}</>\230\143\144\229\141\135\232\135\179<ShopRecharge_Font>LV{2}</>",
  PRICE_ENOUGH_FORMAT = "<ShopRecharge_Font>%d</>",
  PRICE_NOT_ENOUGH_FORMAT = "<Setting_Font08>%d</>",
  TEXT_ITEM_NAME_FORMAT = "<ShopRecharge_Font>%s</s>",
  TEXT_LEVEL_FORMAT = "<ShopRecharge_Font>LV%d</s>",
  PART_COUNT_PER_LEVEL = 2,
  DEFAULT_HSB = {
    H = 0,
    S = 100,
    B = 100
  },
  SUIT_LEVEL_NAME = {
    48740,
    48741,
    48742
  },
  ENUM_CHANGE_TYPE = {COLOR = 1, PLAN = 2},
  MoneyEnoughTextId = {
    [1000] = 48751,
    [1001] = 48753,
    [1109] = 48755
  },
  DefaultMoneyEnoughTextId = 48753,
  MoneyNotEnoughTextId = {
    [1000] = 48750,
    [1001] = 48752,
    [1109] = 48754
  },
  DefaultMoneyNotEnoughTextId = 48752,
  MoneyNotEnoughNoticeId = {
    [1000] = 110053,
    [1001] = 4496,
    [1109] = 48760
  },
  DefaultMoneyNotEnoughNoticeId = 18070007,
  ENUM_SUITDYE_TYPE = {
    Custom = 0,
    Preset = 1,
    Default = 2
  },
  ENUM_COLORSETTING_SOURCE = {
    Auto = 0,
    Recommend = 1,
    Custom = 2
  }
}
return suit_dye_macros