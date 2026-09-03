local CustomAssetDefine = require("common.CustomAsset.CustomAssetDefine")
local PrefabType = CustomAssetDefine.ENUM_PREFAB_TYPE
local IsEditor = _G.IsEditor
local pak_util = require("client.common.pak_util")
local PufferConst = require("client.slua.logic.download.puffer_const")
local _bCreativeBasicPakMounted = false
local _SelectorIconConfig = {
  [0] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Icon/Scene/Tex_Icon_None.Tex_Icon_None",
    Name = 8202324
  },
  [1] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Beibao.Common_Item_Beibao",
    Name = "1"
  },
  [2] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Biaoqing.Common_Item_Biaoqing",
    Name = "2"
  },
  [3] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Daoju.Common_Item_Daoju",
    Name = "3"
  },
  [4] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Duihuan.Common_Item_Duihuan",
    Name = "4"
  },
  [5] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Fushi_7.Common_Item_Fushi_7",
    Name = "5"
  },
  [6] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Lei.Common_Item_Lei",
    Name = "6"
  },
  [7] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Ornament.Common_Item_Ornament",
    Name = "7"
  },
  [8] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Pet.Common_Item_Pet",
    Name = "8"
  },
  [9] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Pistol.Common_Item_Pistol",
    Name = "9"
  },
  [10] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Qiangxie_0001.Common_Item_Qiangxie_0001",
    Name = "10"
  },
  [11] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Qiangxie_0002.Common_Item_Qiangxie_0002",
    Name = "11"
  },
  [12] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Qiangxie_0004.Common_Item_Qiangxie_0004",
    Name = "12"
  },
  [13] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Qiangxie_0005.Common_Item_Qiangxie_0005",
    Name = "13"
  },
  [14] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Qiangxie_0006.Common_Item_Qiangxie_0006",
    Name = "14"
  },
  [15] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Qiangxie_0007.Common_Item_Qiangxie_0007",
    Name = "15"
  },
  [16] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Qiangxie_0008.Common_Item_Qiangxie_0008",
    Name = "16"
  },
  [17] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Sale.Common_Item_Sale",
    Name = "17"
  },
  [18] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Toukui.Common_Item_Toukui",
    Name = "18"
  },
  [19] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Voice.Common_Item_Voice",
    Name = "19"
  },
  [20] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zaijutubiao_01.Common_Item_Zaijutubiao_01",
    Name = "20"
  },
  [21] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zaijutubiao_02.Common_Item_Zaijutubiao_02",
    Name = "21"
  },
  [22] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zaijutubiao_03.Common_Item_Zaijutubiao_03",
    Name = "22"
  },
  [23] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zaijutubiao_04.Common_Item_Zaijutubiao_04",
    Name = "23"
  },
  [24] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zaijutubiao_05.Common_Item_Zaijutubiao_05",
    Name = "24"
  },
  [25] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zaijutubiao_06.Common_Item_Zaijutubiao_06",
    Name = "25"
  },
  [26] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zaijutubiao_07.Common_Item_Zaijutubiao_07",
    Name = "26"
  },
  [27] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zaijutubiao_08.Common_Item_Zaijutubiao_08",
    Name = "27"
  },
  [28] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zaijutubiao_09.Common_Item_Zaijutubiao_09",
    Name = "28"
  },
  [29] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zhanbei.Common_Item_Zhanbei",
    Name = "29"
  },
  [30] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zhuangbeitubiao_2.Common_Item_Zhuangbeitubiao_2",
    Name = "30"
  },
  [31] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zhuangbeitubiao_3.Common_Item_Zhuangbeitubiao_3",
    Name = "31"
  },
  [32] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zhuangbeitubiao_4.Common_Item_Zhuangbeitubiao_4",
    Name = "32"
  },
  [33] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zhuangbeitubiao_5.Common_Item_Zhuangbeitubiao_5",
    Name = "33"
  },
  [34] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zhuangbeitubiao_6.Common_Item_Zhuangbeitubiao_6",
    Name = "34"
  },
  [35] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zhuangbeitubiao_10.Common_Item_Zhuangbeitubiao_10",
    Name = "35"
  },
  [36] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zhuangbeitubiao_11.Common_Item_Zhuangbeitubiao_11",
    Name = "36"
  },
  [37] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Zhuangbeitubiao_13.Common_Item_Zhuangbeitubiao_13",
    Name = "37"
  },
  [38] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_bixin.Icon_bixin",
    Name = "38"
  },
  [39] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_chipaomian.Icon_chipaomian",
    Name = "39"
  },
  [40] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_dengdai.Icon_dengdai",
    Name = "40"
  },
  [41] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Eat.Icon_Eat",
    Name = "41"
  },
  [42] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Fanzjao.Icon_Fanzjao",
    Name = "42"
  },
  [43] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Fireworks.Icon_Fireworks",
    Name = "43"
  },
  [44] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Graffiti.Icon_Graffiti",
    Name = "44"
  },
  [45] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_hudong.Icon_hudong",
    Name = "45"
  },
  [46] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_juqijiangbei.Icon_juqijiangbei",
    Name = "46"
  },
  [47] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_kaorou.Icon_kaorou",
    Name = "47"
  },
  [48] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_liushengji_bofang.Icon_liushengji_bofang",
    Name = "48"
  },
  [49] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_liushengji_guanbi.Icon_liushengji_guanbi",
    Name = "49"
  },
  [50] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Muma.Icon_Muma",
    Name = "50"
  },
  [51] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Picnic.Icon_Picnic",
    Name = "51"
  },
  [52] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Preview.Icon_Preview",
    Name = "52"
  },
  [53] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_qianghongbao.Icon_qianghongbao",
    Name = "53"
  },
  [54] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_qifu.Icon_qifu",
    Name = "54"
  },
  [55] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_qurou.Icon_qurou",
    Name = "55"
  },
  [56] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_reqiqiu.Icon_reqiqiu",
    Name = "56"
  },
  [57] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Rocket101.Icon_Rocket101",
    Name = "57"
  },
  [58] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_songkai.Icon_songkai",
    Name = "58"
  },
  [59] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_tianchai.Icon_tianchai",
    Name = "59"
  },
  [60] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_VendingMachine.Icon_VendingMachine",
    Name = "60"
  },
  [61] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_bone.Pet_bone",
    Name = "61"
  },
  [62] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Cat_01.Pet_Cat_01",
    Name = "62"
  },
  [63] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Cat_02.Pet_Cat_02",
    Name = "63"
  },
  [64] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Cat_03.Pet_Cat_03",
    Name = "64"
  },
  [65] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Cat_04.Pet_Cat_04",
    Name = "65"
  },
  [66] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Cat_06.Pet_Cat_06",
    Name = "66"
  },
  [67] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Cat_07.Pet_Cat_07",
    Name = "67"
  },
  [68] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Cat_08.Pet_Cat_08",
    Name = "68"
  },
  [69] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Cat_09.Pet_Cat_09",
    Name = "69"
  },
  [70] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Dance.Pet_Dance",
    Name = "70"
  },
  [71] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Dog_09.Pet_Dog_09",
    Name = "71"
  },
  [72] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Flaunt.Pet_Flaunt",
    Name = "72"
  },
  [73] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_flying.Pet_flying",
    Name = "73"
  },
  [74] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Godzilla_Idle.Pet_Godzilla_Idle",
    Name = "74"
  },
  [75] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Godzilla_Show.Pet_Godzilla_Show",
    Name = "75"
  },
  [76] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_HelmetTeddy_idle.Pet_HelmetTeddy_idle",
    Name = "76"
  },
  [77] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_idle01.Pet_idle01",
    Name = "77"
  },
  [78] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Iidle.Pet_Iidle",
    Name = "78"
  },
  [79] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Kong_Cloth.Pet_Kong_Cloth",
    Name = "79"
  },
  [80] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_leave.Pet_leave",
    Name = "80"
  },
  [81] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Look_Back.Pet_Look_Back",
    Name = "81"
  },
  [82] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_New_Victory.Pet_New_Victory",
    Name = "82"
  },
  [83] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Penguin__slip.Pet_Penguin__slip",
    Name = "83"
  },
  [84] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Penguin_sleep.Pet_Penguin_sleep",
    Name = "84"
  },
  [85] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_PersianCat_Walk.Pet_PersianCat_Walk",
    Name = "85"
  },
  [86] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Pumpkin_idle.Pet_Pumpkin_idle",
    Name = "86"
  },
  [87] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Pumpkin_parachuting.Pet_Pumpkin_parachuting",
    Name = "87"
  },
  [88] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Pumpkin_run.Pet_Pumpkin_run",
    Name = "88"
  },
  [89] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Pumpkin_walk.Pet_Pumpkin_walk",
    Name = "89"
  },
  [90] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Puppy_02.Pet_Puppy_02",
    Name = "90"
  },
  [91] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Puppy_03.Pet_Puppy_03",
    Name = "91"
  },
  [92] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Puppy_06.Pet_Puppy_06",
    Name = "92"
  },
  [93] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Puppy_08.Pet_Puppy_08",
    Name = "93"
  },
  [94] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Rousseau_archery.Pet_Rousseau_archery",
    Name = "94"
  },
  [95] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Rousseau_idle.Pet_Rousseau_idle",
    Name = "95"
  },
  [96] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Rousseau_polished.Pet_Rousseau_polished",
    Name = "96"
  },
  [97] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Run.Pet_Run",
    Name = "97"
  },
  [98] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_scare.Pet_scare",
    Name = "98"
  },
  [99] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Scarecrow_Ask.Pet_Scarecrow_Ask",
    Name = "99"
  },
  [100] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_TylRegor_01.Pet_TylRegor_01",
    Name = "100"
  },
  [101] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_TylRegor_03.Pet_TylRegor_03",
    Name = "101"
  },
  [102] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_TylRegor_04.Pet_TylRegor_04",
    Name = "102"
  },
  [103] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_TylRegor_05.Pet_TylRegor_05",
    Name = "103"
  },
  [104] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_TylRegor_08.Pet_TylRegor_08",
    Name = "104"
  },
  [105] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_vigilance.Pet_vigilance",
    Name = "105"
  },
  [106] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_win.Pet_win",
    Name = "106"
  },
  [107] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Wolf_Howl.Pet_Wolf_Howl",
    Name = "107"
  },
  [108] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Wolf_Idel.Pet_Wolf_Idel",
    Name = "108"
  },
  [109] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Pet_Wolf_Intimidate.Pet_Wolf_Intimidate",
    Name = "109"
  },
  [110] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/RhythmHero_A_01.RhythmHero_A_01",
    Name = "110"
  },
  [111] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/RhythmHero_B_01.RhythmHero_B_01",
    Name = "111"
  },
  [112] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/RhythmHero_C_01.RhythmHero_C_01",
    Name = "112"
  },
  [113] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/SummerPool_Icon_Assault.SummerPool_Icon_Assault",
    Name = "113"
  },
  [114] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/SummerPool_Icon_IceWall.SummerPool_Icon_IceWall",
    Name = "114"
  },
  [115] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/SummerPool_Icon_Treatment.SummerPool_Icon_Treatment",
    Name = "115"
  },
  [116] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/Ugc_Transform_Icon.Ugc_Transform_Icon",
    Name = "116"
  },
  [117] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/Rolepaly_Icon_Rise_dianliang.Rolepaly_Icon_Rise_dianliang",
    Name = "117"
  },
  [118] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/Rune_Ice_skill_1.Rune_Ice_skill_1",
    Name = "118"
  },
  [119] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Accelerate.RuneDevice_Icon_Accelerate",
    Name = "119"
  },
  [120] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_BloodReturn.RuneDevice_Icon_BloodReturn",
    Name = "120"
  },
  [121] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_BossDamageUp.RuneDevice_Icon_BossDamageUp",
    Name = "121"
  },
  [122] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_BuffBoost.RuneDevice_Icon_BuffBoost",
    Name = "122"
  },
  [123] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Deceleration.RuneDevice_Icon_Deceleration",
    Name = "123"
  },
  [124] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_EarnGold.RuneDevice_Icon_EarnGold",
    Name = "124"
  },
  [125] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_ExtendedMagazine.RuneDevice_Icon_ExtendedMagazine",
    Name = "125"
  },
  [126] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_FireRateUp.RuneDevice_Icon_FireRateUp",
    Name = "126"
  },
  [127] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Gunslinger.RuneDevice_Icon_Gunslinger",
    Name = "127"
  },
  [128] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_GunUniversal.RuneDevice_Icon_GunUniversal",
    Name = "128"
  },
  [129] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_HarmReduction.RuneDevice_Icon_HarmReduction",
    Name = "129"
  },
  [130] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_HealthBoost.RuneDevice_Icon_HealthBoost",
    Name = "130"
  },
  [131] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_HitSuckBlood.RuneDevice_Icon_HitSuckBlood",
    Name = "131"
  },
  [132] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_IncendiaryBullet.RuneDevice_Icon_IncendiaryBullet",
    Name = "132"
  },
  [133] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Invincible.RuneDevice_Icon_Invincible",
    Name = "133"
  },
  [134] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_MeleeWeapon.RuneDevice_Icon_MeleeWeapon",
    Name = "134"
  },
  [135] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_PlayerDamageUp.RuneDevice_Icon_PlayerDamageUp",
    Name = "135"
  },
  [136] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_ReloadSpeedUp.RuneDevice_Icon_ReloadSpeedUp",
    Name = "136"
  },
  [137] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_RespiratoryReturn.RuneDevice_Icon_RespiratoryReturn",
    Name = "137"
  },
  [138] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Rifle.RuneDevice_Icon_Rifle",
    Name = "138"
  },
  [139] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_RuneDevice.RuneDevice_Icon_RuneDevice",
    Name = "139"
  },
  [140] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Shotgun.RuneDevice_Icon_Shotgun",
    Name = "140"
  },
  [141] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_ShowEnemiesFull_Picture.RuneDevice_Icon_ShowEnemiesFull_Picture",
    Name = "141"
  },
  [142] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_SniperRifle.RuneDevice_Icon_SniperRifle",
    Name = "142"
  },
  [143] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_SubmachineGun.RuneDevice_Icon_SubmachineGun",
    Name = "143"
  },
  [144] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_SubWeapon.RuneDevice_Icon_SubWeapon",
    Name = "144"
  },
  [145] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Throwable.RuneDevice_Icon_Throwable",
    Name = "145"
  },
  [146] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_ToxicFog.RuneDevice_Icon_ToxicFog",
    Name = "146"
  },
  [147] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_VehicleRepair.RuneDevice_Icon_VehicleRepair",
    Name = "147"
  },
  [148] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Vertigo.RuneDevice_Icon_Vertigo",
    Name = "148"
  },
  [149] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/skills_amelia_icon.skills_amelia_icon",
    Name = "149"
  },
  [150] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/skills_Laith_icon.skills_Laith_icon",
    Name = "150"
  },
  [151] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/skills_sara_icon.skills_sara_icon",
    Name = "151"
  },
  [152] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/Skill_Icon_Cat.Skill_Icon_Cat",
    Name = "152"
  },
  [153] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/Skill_Icon_Mouse.Skill_Icon_Mouse",
    Name = "153"
  },
  [154] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Ball.RuneDevice_Icon_Ball",
    Name = "154"
  },
  [155] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Dais.RuneDevice_Icon_Dais",
    Name = "155"
  },
  [156] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Guard.RuneDevice_Icon_Guard",
    Name = "156"
  },
  [157] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_liftingSpeed.RuneDevice_Icon_liftingSpeed",
    Name = "157"
  },
  [158] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_SuperJump.RuneDevice_Icon_SuperJump",
    Name = "158"
  },
  [159] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Sprint.RuneDevice_Icon_Sprint",
    Name = "159"
  },
  [160] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_AddDefense.RuneDevice_Icon_AddDefense",
    Name = "160"
  },
  [161] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_AddGuard.RuneDevice_Icon_AddGuard",
    Name = "161"
  },
  [162] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_AmplifyPan.RuneDevice_Icon_AmplifyPan",
    Name = "162"
  },
  [163] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_CriticalHit.RuneDevice_Icon_CriticalHit",
    Name = "163"
  },
  [164] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_FenShen.RuneDevice_Icon_FenShen",
    Name = "164"
  },
  [165] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_FireBall.RuneDevice_Icon_FireBall",
    Name = "165"
  },
  [166] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_FixedPosition.RuneDevice_Icon_FixedPosition",
    Name = "166"
  },
  [167] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_FixedPositionUnlock.RuneDevice_Icon_FixedPositionUnlock",
    Name = "167"
  },
  [168] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_FlashGrenade.RuneDevice_Icon_FlashGrenade",
    Name = "168"
  },
  [169] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Floating.RuneDevice_Icon_Floating",
    Name = "169"
  },
  [170] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Freeze.RuneDevice_Icon_Freeze",
    Name = "170"
  },
  [171] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_InstantSmokeBomb.RuneDevice_Icon_InstantSmokeBomb",
    Name = "171"
  },
  [172] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_InvestigationCircle.RuneDevice_Icon_InvestigationCircle",
    Name = "172"
  },
  [173] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_ObtainItems.RuneDevice_Icon_ObtainItems",
    Name = "173"
  },
  [174] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Rescue.RuneDevice_Icon_Rescue",
    Name = "174"
  },
  [175] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_SlowForceField.RuneDevice_Icon_SlowForceField",
    Name = "175"
  },
  [176] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_UsingMedication.RuneDevice_Icon_UsingMedication",
    Name = "176"
  },
  [177] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_WaveAir.RuneDevice_Icon_WaveAir",
    Name = "177"
  },
  [178] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/ZD_Icon_Transformation.ZD_Icon_Transformation",
    Name = "178"
  },
  [179] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Completed.Common_Item_Completed",
    Name = "179"
  },
  [180] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Down.Common_Item_Down",
    Name = "180"
  },
  [181] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_ExclamationMark.Common_Item_ExclamationMark",
    Name = "181"
  },
  [182] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Left.Common_Item_Left",
    Name = "182"
  },
  [183] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_PlusSign.Common_Item_PlusSign",
    Name = "183"
  },
  [184] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Question.Common_Item_Question",
    Name = "184"
  },
  [185] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Right.Common_Item_Right",
    Name = "185"
  },
  [186] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Store.Common_Item_Store",
    Name = "186"
  },
  [187] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Common_Item_Up.Common_Item_Up",
    Name = "187"
  },
  [188] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Icon/Common/Icon_Chicken_01_256.Icon_Chicken_01_256",
    Name = "188"
  },
  [189] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Icon/Common/Icon_Chicken_02_256.Icon_Chicken_02_256",
    Name = "189"
  },
  [190] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Icon/Common/Icon_Chicken_03_256.Icon_Chicken_03_256",
    Name = "190"
  },
  [191] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Icon/Common/Icon_Map_Eggs.Icon_Map_Eggs",
    Name = "191"
  },
  [192] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Monster/Monster_Icon_024.Monster_Icon_024",
    Name = "192"
  },
  [193] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Monster/Monster_Icon_025.Monster_Icon_025",
    Name = "193"
  },
  [194] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Monster/Monster_Icon_026.Monster_Icon_026",
    Name = "194"
  },
  [195] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Monster/Monster_Icon_027.Monster_Icon_027",
    Name = "195"
  },
  [196] = {
    IconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Monster/Monster_Icon_028.Monster_Icon_028",
    Name = "196"
  },
  [197] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Image_RugbyGate.Icon_Image_RugbyGate",
    Name = "197"
  },
  [198] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/Icon_Image_Rugby.Icon_Image_Rugby",
    Name = "198"
  },
  [199] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_AirRaid.RuneDevice_Icon_AirRaid",
    Name = "199"
  },
  [200] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Burn.RuneDevice_Icon_Burn",
    Name = "200"
  },
  [201] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Vehicle.RuneDevice_Icon_Vehicle",
    Name = "201"
  },
  [202] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Scan.RuneDevice_Icon_Scan",
    Name = "202"
  },
  [203] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_DefenseTower.RuneDevice_Icon_DefenseTower",
    Name = "203"
  },
  [204] = {
    IconPath = "/Game/Library/CreativeDL/IG2200/Arts/Icon/Common/SummerPool_Icon_SurvivalRoad.SummerPool_Icon_SurvivalRoad",
    Name = "204"
  },
  [205] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/Skill_Icon_VampiresMaharaja.Skill_Icon_VampiresMaharaja",
    Name = "205"
  },
  [206] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Driftlessness.RuneDevice_Icon_Driftlessness",
    Name = "206"
  },
  [207] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Throw.RuneDevice_Icon_Throw",
    Name = "207"
  },
  [208] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Place.RuneDevice_Icon_Place",
    Name = "208"
  },
  [209] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Thunderbolt.RuneDevice_Icon_Thunderbolt",
    Name = "209"
  },
  [210] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_HeavenlyThunder.RuneDevice_Icon_HeavenlyThunder",
    Name = "210"
  },
  [211] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_EnergyCannon.RuneDevice_Icon_EnergyCannon",
    Name = "211"
  },
  [212] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_SwordFlash.RuneDevice_Icon_SwordFlash",
    Name = "212"
  },
  [213] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_EnhancedState.RuneDevice_Icon_EnhancedState",
    Name = "213"
  },
  [214] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_MoveForward.RuneDevice_Icon_MoveForward",
    Name = "214"
  },
  [215] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_MoveBack.RuneDevice_Icon_MoveBack",
    Name = "215"
  },
  [216] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Gathering.RuneDevice_Icon_Gathering",
    Name = "216"
  },
  [217] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Penetrate.RuneDevice_Icon_Penetrate",
    Name = "217"
  },
  [218] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_ThrowDarts.RuneDevice_Icon_ThrowDarts",
    Name = "218"
  },
  [219] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Frozen.RuneDevice_Icon_Frozen",
    Name = "219"
  },
  [220] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_IceThorn.RuneDevice_Icon_IceThorn",
    Name = "220"
  },
  [221] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_IceCrystal.RuneDevice_Icon_IceCrystal",
    Name = "221"
  },
  [222] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_ShieldEffect.RuneDevice_Icon_ShieldEffect",
    Name = "222"
  },
  [223] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_DevilPumpkin.RuneDevice_Icon_DevilPumpkin",
    Name = "223"
  },
  [224] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/skill/RuneDevice_Icon_Melee_claw_strike.RuneDevice_Icon_Melee_claw_strike",
    Name = "224"
  },
  [225] = {
    IconPath = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/skill/FlamePalm_Icon_ZombieStrike.FlamePalm_Icon_ZombieStrike",
    Name = "225"
  }
}
local OldLuaConfigLength = #_SelectorIconConfig
local DefaultIconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/Icon/Scene/Tex_Icon_None.Tex_Icon_None"
local DefaultCategory = 1
local PublishRegionMacros = Client and require("client.slua.config.ClientMacros.PublishRegionMacros")
local SelectorIconConfig = {}
SelectorIconConfig.UnDownloadedIconPath = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Ugc_Icon_NotDownloaded_png.Ugc_Icon_NotDownloaded_png"
SelectorIconConfig.TabDefine = {Custom = 1, Official = 2}
SelectorIconConfig.TabDefineName = {
  [SelectorIconConfig.TabDefine.Official] = 18710105,
  [SelectorIconConfig.TabDefine.Custom] = 8880083
}
local TabDefine = SelectorIconConfig.TabDefine
local TabDefineName = SelectorIconConfig.TabDefineName
SelectorIconConfig.OldLuaIconConfigIdMap = {}
local function _GetAllIconConfig(Idx)
  if Idx ~= nil then
    local IconConfigList = _GetAllIconConfig()
    if SelectorIconConfig.OldLuaIconConfigIdMap[Idx] ~= nil then
      return IconConfigList[SelectorIconConfig.OldLuaIconConfigIdMap[Idx]]
    else
      return IconConfigList[Idx]
    end
    return nil
  end
  local GetAllIconConfigFunc = function()
    local OutIconConfig = {}
    local OldLuaIconConfigIdMap = SelectorIconConfig.OldLuaIconConfigIdMap
    local IsDTValid = CDataTable and not bInUGCLuaTool
    for SelectorKey, IconConfig in pairs(_SelectorIconConfig) do
      local IconLuaConfig = {
        ID = SelectorKey,
        IconPath = IconConfig.IconPath,
        Category = 1
      }
      if SelectorKey < OldLuaConfigLength + 1 then
        local ImageData
        if SelectorKey == 0 then
          ImageData = IsDTValid and CDataTable.GetTableData("UGCImageTable", 0)
        else
          ImageData = IsDTValid and CDataTable.GetTableDataByFilter("UGCImageTable", "SelectorKey", SelectorKey)
        end
        if ImageData then
          OldLuaIconConfigIdMap[SelectorKey] = ImageData.ID
        else
          OutIconConfig[SelectorKey] = IconLuaConfig
        end
      end
    end
    if IsDTValid then
      local UGCImageTable = CDataTable.GetTable("UGCImageTable")
      if UGCImageTable then
        for _, ImageConfigData in pairs(UGCImageTable) do
          OutIconConfig[ImageConfigData.ID] = {
            ID = ImageConfigData.ID,
            IconPath = ImageConfigData.ImagePath,
            Category = ImageConfigData.Category,
            Tags_a = ImageConfigData.Tags_a
          }
        end
      end
    end
    return OutIconConfig
  end
  if SelectorIconConfig then
    if SelectorIconConfig.CachedSelectorIconConfig == nil then
      SelectorIconConfig.CachedSelectorIconConfig = GetAllIconConfigFunc()
    end
    return SelectorIconConfig.CachedSelectorIconConfig
  end
  return GetAllIconConfigFunc()
end
local _GetSortedIdx = function(bUpdateCache)
  if bUpdateCache or SelectorIconConfig._cache == nil then
    local CacheTable = {}
    local TInsert = table.insert
    local CustomPrefabConfig = require("GameLua.Mod.CreativeBase.Gameplay.Config.Asset.Logic.CustomPrefab.CustomPrefabConfig")
    local ConfigRelease = CustomPrefabConfig.ReleaseState
    local CanUse = false
    local IconMetaInfo = SelectorIconConfig.GetAllIconMeta()
    local AllConfigs = _GetAllIconConfig()
    for Idx, Info in pairs(AllConfigs) do
      CanUse = false
      if Info._IsDynamic then
        local MetaInfo = IconMetaInfo[Idx]
        if MetaInfo then
          local State = MetaInfo.StateRelease
          CanUse = State == ConfigRelease.EDIT or State == ConfigRelease.PUBLISH
        end
      else
        CanUse = true
      end
      if CanUse then
        TInsert(CacheTable, Idx)
      end
    end
    table.sort(CacheTable, function(a, b)
      return a < b
    end)
    SelectorIconConfig._cache = CacheTable
  end
  return SelectorIconConfig._cache
end
function SelectorIconConfig.GetOptionValue()
  local Ret = {}
  local Idxs = _GetSortedIdx()
  for _, Idx in pairs(Idxs) do
    table.insert(Ret, Idx)
  end
  return Ret
end
function SelectorIconConfig.GetTexturePathArray()
  local Ret = {}
  local Idxs = _GetSortedIdx()
  for _, Idx in pairs(Idxs) do
    table.insert(Ret, SelectorIconConfig.GetTexturePathById(Idx))
  end
  return Ret
end
function SelectorIconConfig.GetNameArray()
  local Ret = {}
  local Idxs = _GetSortedIdx()
  for _, Idx in pairs(Idxs) do
    table.insert(Ret, SelectorIconConfig.GetTextureNameById(Idx))
  end
  return Ret
end
function SelectorIconConfig.GetTexturePathById(Idx, bCheckResourceValid)
  print(bWriteLog and "SelectorIconConfig.GetTexturePathById, Idx=" .. tostring(Idx))
  if Idx == nil then
    return ""
  end
  local bIsCustomAsset = SelectorIconConfig.IsDynamicTexture(Idx)
  local Config = _GetAllIconConfig(Idx)
  local IconPath = Config and Config.IconPath
  if bIsCustomAsset then
    if _G.bPreparingInstancesParameterData then
      return Config and Config.AssetKey
    end
    if IconPath == nil or #IconPath <= 0 then
      print(bWriteLog and "SelectorIconConfig.GetTexturePathById, CustomAsset no IconPath")
      return DefaultIconPath
    end
    return IconPath
  end
  if bCheckResourceValid and Client and not Client.bEditorSkipDownload then
    if IconPath and pak_util and pak_util.IsFileExist(IconPath) then
      print(bWriteLog and "SelectorIconConfig.GetTexturePathById, FileExist Path=" .. tostring(IconPath))
      return IconPath
    end
    if IconPath and not _bCreativeBasicPakMounted then
      local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
      if PufferMapManager then
        local bMounted = PufferMapManager:MountMapPak(PufferConst.UGC_BASIC_MAPKEY)
        print(bWriteLog and "SelectorIconConfig.GetTexturePathById, MountMapPak result=" .. tostring(bMounted))
        if bMounted then
          _bCreativeBasicPakMounted = true
          if pak_util.IsFileExist(IconPath) then
            print(bWriteLog and "SelectorIconConfig.GetTexturePathById, MountSuccess FileExist Path=" .. tostring(IconPath))
            return IconPath
          end
        end
      end
    end
    return SelectorIconConfig.UnDownloadedIconPath
  else
    print(bWriteLog and "SelectorIconConfig.GetTexturePathById, not need Check, Path=" .. tostring(IconPath))
    return IconPath or DefaultIconPath
  end
end
local _GetIconNameById = function(Idx)
  if Idx == nil then
    return ""
  end
  local DefaultName = ""
  if IsEditor then
    DefaultName = tostring(Idx)
  end
  local Config = _GetAllIconConfig(Idx)
  if not Config then
    return DefaultName
  end
  if Config._IsDynamic then
    local IconMeta = SelectorIconConfig.GetAllIconMeta()[Idx]
    if IconMeta and IconMeta.Name then
      return IconMeta.Name
    end
    return DefaultName
  end
  local IsDTValid = CDataTable and not bInUGCLuaTool
  if Idx < OldLuaConfigLength + 1 then
    if IsDTValid then
      local ImageData
      if Idx == 0 then
        ImageData = CDataTable.GetTableData("UGCImageTable", 0)
      else
        ImageData = CDataTable.GetTableDataByFilter("UGCImageTable", "SelectorKey", Idx)
      end
      if ImageData and ImageData.Name then
        return ImageData.Name
      end
    end
    if _SelectorIconConfig[Idx] and _SelectorIconConfig[Idx].Name then
      return _SelectorIconConfig[Idx].Name
    end
  elseif IsDTValid then
    local ImageData = CDataTable.GetTableData("UGCImageTable", Idx)
    if ImageData and ImageData.Name then
      return ImageData.Name
    end
  end
  return DefaultName
end
function SelectorIconConfig.GetTextureNameById(Idx)
  return _GetIconNameById(Idx)
end
function SelectorIconConfig.GetTextureTags(Idx)
  if Idx == nil then
    return {}
  end
  return _GetAllIconConfig(Idx) and _GetAllIconConfig(Idx).Tags_a or {}
end
function SelectorIconConfig.GetTextureCategoryById(Idx)
  if Idx == nil then
    return DefaultCategory
  end
  return _GetAllIconConfig(Idx) and _GetAllIconConfig(Idx).Category or DefaultCategory
end
function SelectorIconConfig.IsDynamicTexture(Idx)
  if Idx == nil then
    return false
  end
  return _GetAllIconConfig(Idx) and _GetAllIconConfig(Idx)._IsDynamic
end
local _GetOfficialCategoryNameArray = function()
  if SelectorIconConfig._CategoryNameConfig and next(SelectorIconConfig._CategoryNameConfig) then
    return SelectorIconConfig._CategoryNameConfig
  end
  SelectorIconConfig._CategoryNameConfig = {}
  local IsDTValid = CDataTable and not bInUGCLuaTool
  if IsDTValid then
    local ImageCategoryTable = CDataTable.GetTable("UGCImageCategoryTable")
    if ImageCategoryTable then
      for ID, TableData in pairs(ImageCategoryTable) do
        SelectorIconConfig._CategoryNameConfig[ID] = TableData.CategoryName
      end
    end
  end
  return SelectorIconConfig._CategoryNameConfig
end
function SelectorIconConfig.GetOfficialCategoryNameById(CategoryId)
  return _GetOfficialCategoryNameArray()[CategoryId] or _GetOfficialCategoryNameArray()[1]
end
local _CustomAssetCategoryDefine = CustomAssetDefine.CustomAssetCategoryType
function SelectorIconConfig.GetTabList()
  local BaseTab = {}
  if PublishRegionMacros and not PublishRegionMacros.IsBLUEHOLE() then
    table.insert(BaseTab, {
      TabName = TabDefineName[TabDefine.Custom],
      SubNameList = {
        [_CustomAssetCategoryDefine.MyShares] = 8880408,
        [_CustomAssetCategoryDefine.MyFavorites] = 99009831,
        [_CustomAssetCategoryDefine.Private] = 99009830
      }
    })
  end
  table.insert(BaseTab, {
    TabName = TabDefineName[TabDefine.Official],
    SubNameList = _GetOfficialCategoryNameArray()
  })
  return BaseTab
end
local _GetIconTabDefineIndex = {
  [TabDefine.Custom] = 1,
  [TabDefine.Official] = PublishRegionMacros and PublishRegionMacros.IsBLUEHOLE() and 1 or 2
}
function SelectorIconConfig.GetItemTabMap()
  local Ret = {}
  local Idxs = _GetSortedIdx()
  local IsBlueHole = PublishRegionMacros and PublishRegionMacros.IsBLUEHOLE()
  local CustomAssetTab = IsBlueHole and _GetIconTabDefineIndex[TabDefine.Official] or _GetIconTabDefineIndex[TabDefine.Custom]
  for _, Idx in pairs(Idxs) do
    local IsCustomAsset = CustomAssetMgr:IsCustomAssetKeyHashID(Idx)
    Ret[Idx] = IsCustomAsset and CustomAssetTab or _GetIconTabDefineIndex[TabDefine.Official]
  end
  return Ret
end
function SelectorIconConfig.GetItemCategoryMap()
  local Ret = {}
  local Idxs = _GetSortedIdx()
  for _, Idx in pairs(Idxs) do
    local Category = _GetAllIconConfig(Idx).Category or _CustomAssetCategoryDefine.Private
    if Category == 0 then
      Category = 1
    end
    Ret[Idx] = Category
  end
  return Ret
end
function SelectorIconConfig.RegisterDynamicIcon(ID, AssetKey, IconPath)
  if PublishRegionMacros and PublishRegionMacros.IsBLUEHOLE() then
    print(bWriteLog and "SelectorIconConfig.RegisterDynamicIcon BlueHole forbidden")
    return false
  end
  local Config = _GetAllIconConfig(ID)
  local Exist = Config and Config.IconPath == IconPath
  if Exist then
    return true
  end
  local Category = _CustomAssetCategoryDefine.None
  local IconMeta = SelectorIconConfig.GetAllIconMeta()[ID]
  if IconMeta then
    local logic_ugc_prefab_mall = Client and ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
    Category = logic_ugc_prefab_mall:GetPrefabCategory(IconMeta) or Category
  end
  local Inst = {
    ID = ID,
    AssetKey = AssetKey,
    IconPath = IconPath,
    Category = Category,
    Tags_a = {1014},
    _IsDynamic = true
  }
  local AllIconConfig = _GetAllIconConfig()
  AllIconConfig[ID] = Inst
  _GetSortedIdx(true)
  return true
end
function SelectorIconConfig.UnregisterDynamicIcon(ID, IconPath)
  local Config = _GetAllIconConfig(ID)
  if Config and Config._IsDynamic then
    local AllIconConfig = _GetAllIconConfig()
    AllIconConfig[ID] = nil
    _GetSortedIdx(true)
    return true
  end
  return false
end
function SelectorIconConfig.UpdateAllDynamicIconInfo()
  print(bWriteLog and "SelectorIconConfig.UpdateAllDynamicIconInfo")
  local AllConfigs = _GetAllIconConfig()
  local IconMetaInfo = SelectorIconConfig.GetAllIconMeta()
  local logic_ugc_prefab_mall = Client and ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
  for IconID, Config in pairs(AllConfigs) do
    if Config._IsDynamic then
      local MetaInfo = IconMetaInfo[IconID]
      if MetaInfo then
        Config.Category = logic_ugc_prefab_mall:GetPrefabCategory(MetaInfo) or Config.Category
      end
    end
  end
  _GetSortedIdx(true)
end
function SelectorIconConfig.UpdateDynamicIconInfo(ID)
  local Config = _GetAllIconConfig(ID)
  if not Config then
    print(bWriteLog and "[Warning]SelectorIconConfig.UpdateDynamicIconInfo Config not found, ID=" .. tostring(ID))
    return false
  end
  if not Config._IsDynamic then
    print(bWriteLog and "[Warning]SelectorIconConfig.UpdateDynamicIconInfo Config is not Is Dynamic, ID=" .. tostring(ID))
    return false
  end
  local Category = _CustomAssetCategoryDefine.None
  local IconMeta = SelectorIconConfig.GetAllIconMeta()[ID]
  if IconMeta then
    local logic_ugc_prefab_mall = Client and ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
    Category = logic_ugc_prefab_mall:GetPrefabCategory(IconMeta) or Category
  end
  Config.  _GetSortedIdx(true)
  return true
end
function SelectorIconConfig.GetAllIconMeta()
  local CustomIconMetaMap = {}
  if not bInUGCLuaTool then
    local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
    local CustomIconMetaList = logic_ugc_prefab_mall_asset_mgr:GetMyPrefabMallMeta(nil, PrefabType.IMAGE, nil, nil)
    if CustomIconMetaList and type(CustomIconMetaList) == "table" then
      for _, CustomIconMeta in pairs(CustomIconMetaList) do
        CustomIconMetaMap[CustomIconMeta.AssetKeyHasId] = CustomIconMeta
      end
    end
  end
  return CustomIconMetaMap
end
function SelectorIconConfig.GetIconExtendedOptions()
  local ExtendedTabInfo = {
    TabList = SelectorIconConfig.GetTabList(),
    ItemTabIndexMap = SelectorIconConfig.GetItemTabMap(),
    ItemSubTabIndexMap = SelectorIconConfig.GetItemCategoryMap()
  }
  local Options = {
    bEnableSearch = true,
    bUseItemIdentity = true,
    ExtendedTabInfo = ExtendedTabInfo,
    bUseExtendedTab = true,
    ChooseButtonText = 8880457,
    ReturnButtonText = 8880458
  }
  return Options
end
function SelectorIconConfig.GetMapIconId(IconId)
  if SelectorIconConfig.OldLuaIconConfigIdMap and SelectorIconConfig.OldLuaIconConfigIdMap[IconId] then
    return SelectorIconConfig.OldLuaIconConfigIdMap[IconId]
  end
  return IconId
end
function SelectorIconConfig.CheckValid(IconId)
  if IconId == nil then
    return false
  end
  return true, SelectorIconConfig.GetMapIconId(IconId)
end
function SelectorIconConfig.ClearAllCache()
  SelectorIconConfig.CachedSelectorIconConfig = nil
  SelectorIconConfig._cache = nil
end
return SelectorIconConfig