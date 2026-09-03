local MainCityCoreConst = {
  NEWBIE_GUIDE_KEY_LONG_PRESS_LARGE_RING = 101,
  NEWBIE_GUIDE_KEY_LONG_PRESS_SUB_RING_CLICK = 102,
  NEWBIE_GUIDE_KEY_CONTINUES_ACTION_UI_SHOW = 103,
  NEWBIE_GUIDE_KEY_HOME_WEDDING_ENTER = 104,
  NEWBIE_GUIDE_KEY_MULTIPOSE_ENTRY = 105,
  NEWBIE_GUIDE_KEY_MULTIPOSE_CAMERA_GUIDE = 106
}
MainCityCoreConst.EMainCityInteractiveStateTypeFlag = {
  ISTF_Seat = 2,
  ISTF_Seesaw = 4,
  ISTF_MultiPhotoCaster = 8,
  ISTF_DanceLead = 16,
  ISTF_DanceFollow = 32,
  ISTF_MagicWand = 64,
  ISTF_Soccer = 128,
  ISTF_Swing = 256,
  ISTF_Carrousel = 512,
  ISTF_DualSkill = 1024,
  ISTF_PartyPopper = 2048,
  ISTF_MultiPhotoJoiner = 4096
}
MainCityCoreConst.StateTextID = {
  [MainCityCoreConst.EMainCityInteractiveStateTypeFlag.ISTF_Seesaw] = 656028,
  [MainCityCoreConst.EMainCityInteractiveStateTypeFlag.ISTF_MultiPhotoCaster] = 656031,
  [MainCityCoreConst.EMainCityInteractiveStateTypeFlag.ISTF_MultiPhotoJoiner] = 656031,
  [MainCityCoreConst.EMainCityInteractiveStateTypeFlag.ISTF_DanceLead] = 656027,
  [MainCityCoreConst.EMainCityInteractiveStateTypeFlag.ISTF_DanceFollow] = 656027,
  [MainCityCoreConst.EMainCityInteractiveStateTypeFlag.ISTF_MagicWand] = 656030,
  [MainCityCoreConst.EMainCityInteractiveStateTypeFlag.ISTF_Soccer] = 656029,
  [MainCityCoreConst.EMainCityInteractiveStateTypeFlag.ISTF_PartyPopper] = 8075898
}
return MainCityCoreConst