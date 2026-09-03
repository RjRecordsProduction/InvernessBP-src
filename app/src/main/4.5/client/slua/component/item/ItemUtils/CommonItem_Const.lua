local CommonItem_Const = {
  Enum_ItemStatus = {
    Not = 0,
    Done = 1,
    Got = 2,
    TimeOut = 3
  },
  Enum_ChildName = {
    GoldEquipQuality = "_cObj_goldEquipQuality",
    HasGet = "_cObj_hasGet",
    BlackMask = "_cObj_blackMask",
    ContentText = "_cObj_contentText",
    Selected = "_cObj_selected",
    GlowingEffect = "_cObj_glowingEffect",
    Equipping = "_cObj_equipping",
    CoBranded = "_cObj_coBranded",
    Decompose = "_cObj_decompose",
    RedEmotion = "_cObj_redEmotion",
    CollectStatus = "_cObj_collectStatus",
    ProbabilityUp = "_cObj_probabilityUp",
    Using = "_cObj_using",
    Exclusive = "_cObj_exclusiveTip",
    ExculsiveOneYear = "_cObj_exclusiveTipOneYear",
    PetSuitIcon = "_cObj_petSuitIcon",
    PlusSuperscript = "_cObj_PlusSuperscript",
    SpecialIcon = "_cObj_specialIcon",
    NewTip = "_cObj_newTip",
    Lock = "_cObj_lockIcon",
    SharedBackpack = "_cObj_sharedBackpack",
    TryOnText = "_cObj_tryOnText",
    LimitIcon = "_cObj_limitTimeUI",
    AffixPVEIcon = "_cObj_affixIcon",
    ParticleStar = "_cObj_particleStar",
    CollectNum = "_cObj_collectNum",
    DiyClothingIcon = "_cObj_diyClothingIcon",
    InheritIcon = "_cObj_inheritIcon",
    TeamTimes = "_cObj_teamTimes",
    MatchNum = "_cObj_matchNum",
    UpgradeDiscountNum = "_cObj_upgradeDiscountNum",
    Signature = "_cObj_signature"
  }
}
local Enum_UIBP_NodeName = {
  Image_LeftTopIcon = "Image_LeftTopIcon"
}
CommonItem_Const.local CommonItem_Utils = require("client.slua.component.item.ItemUtils.CommonItem_Utils")
CommonItem_Const.Enum_ItemChildZOrder = CommonItem_Utils.CreateZOrderEnum("CommonItemShowCfg", {
  Default = 0,
  BaseElement = 0,
  DownloadIUI = 1000
})
return CommonItem_Const