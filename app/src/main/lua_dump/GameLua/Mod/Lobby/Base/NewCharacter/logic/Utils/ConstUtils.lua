local CharacterUtils = {}
CharacterUtils.DEFAULT_CHARACTER_ID = 15000000
CharacterUtils.FIRST_FREE_CHARACTER_ID = 15000001
CharacterUtils.CHARACTER_ID_ANDI = 15000005
CharacterUtils.CHARACTER_EXP_CARD_ID = 2101018
CharacterUtils.CHARACTER_MATERIAL_ID = 2601005
CharacterUtils.UC_ITEM_ID = 1006
CharacterUtils.CHARACTER_TICKET_ID = 2601007
CharacterUtils.CHARACTER_EXP_CARD_VALUE = 500
CharacterUtils.ANDI_SPECIAL_ID = 1405569
CharacterUtils.LEVEL_BOX_PATH = "/Game/Arts/UI/TableIcons/ItemIcon/Box/CharacterUI_box_baoxiang.CharacterUI_box_baoxiang"
CharacterUtils.DIANQUAN_ICON_PATH = "/Game/Arts/UI/TableIcons/ItemIcon/Icon_RichText/Shop_icon_qianbi.Shop_icon_qianbi"
CharacterUtils.CHARACTER_SUIPIAN_ICON_PATH = "/Game/Arts/UI/TableIcons/ItemIcon/Icon_RichText/T_icon_suipian.T_icon_suipian"
CharacterUtils.CHARACTER_DIANQUAN_ICON_PATH = "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Character_currency_64.Character_currency_64"
CharacterUtils.CHARACTER_UI_MASK_PATH = "/Game/UMG/UI_Effect/Materials/M_UIMask_Main_Inst_01.M_UIMask_Main_Inst_01"
CharacterUtils.DEFAULT_CHARACTER_HEAD_PATH = "/Game/UMG/Texture/Lobby_NoAtlas/Common/Character_image_Head_02.Character_image_Head_02"
CharacterUtils.Enum_Item_Type = {
  EnumType_Character = 40,
  EnumType_Sound = 18,
  EnumType_Com_Action = 22,
  EnumType_Mvp_Action = 41,
  EnumType_Skin = 4,
  EnumType_Box = 15,
  EnumType_Character_Item = 44,
  EnumType_Sound_Box = 19
}
CharacterUtils.Enum_Item_SubType = {
  EnumType_Exp = 4401,
  EnumType_Chip = 4402,
  EnumType_Hat = 401,
  EnumType_Clothes = 403,
  EnumType_Pants = 404,
  EnumType_Hair = 406,
  EnumType_Helmet = 505
}
CharacterUtils.Enum_Jump_Type = {
  EnumJump_None = 0,
  EnumJump_Level = 1,
  EnumJump_ItemBuy = 2,
  EnumJump_Default = 3,
  EnumJump_Exchange = 4,
  EnumJump_Supply = 5
}
CharacterUtils.Enum_Main_Tab = {
  EnumTab_HomePage = 1,
  EnumTab_Skin = 2,
  EnumTab_Com_Action = 3,
  EnumTab_Voice = 4
}
CharacterUtils.MainItemTypeList = {
  CharacterUtils.Enum_Item_Type.EnumType_Skin,
  CharacterUtils.Enum_Item_Type.EnumType_Sound,
  CharacterUtils.Enum_Item_Type.EnumType_Com_Action,
  CharacterUtils.Enum_Item_Type.EnumType_Mvp_Action
}
CharacterUtils.Enum_From = {From_Wardrobe = 0, From_Character = 1}
CharacterUtils.NeedPutOffType = {
  401,
  402,
  403,
  404,
  405,
  406,
  407,
  408
}
CharacterUtils.TabViewList = {
  UIManager.UI_Config.CharacterHomePage,
  UIManager.UI_Config.CharacterSkin,
  UIManager.UI_Config.CharacterAction,
  UIManager.UI_Config.CharacterVoice
}
local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
CharacterUtils.DefaultAvatarData = {
  headid = LobbyAvatarManager.Enum_DefaultSetID.Head,
  gamegender = LobbyAvatarManager.Enum_Sex.Female,
  hairid = LobbyAvatarManager.Enum_DefaultSetID.Hair,
  beardid = 0,
  beardcolorid = 0
}
function CharacterUtils.InitConstValue()
  local expCardCfg = CDataTable.GetTableData("character_param_table", CharacterUtils.CHARACTER_EXP_CARD_ID)
  if expCardCfg ~= nil and expCardCfg.character_param ~= nil then
    CharacterUtils.CHARACTER_EXP_CARD_VALUE = expCardCfg.character_param
  end
end
CharacterUtils.InitConstValue()
return CharacterUtils