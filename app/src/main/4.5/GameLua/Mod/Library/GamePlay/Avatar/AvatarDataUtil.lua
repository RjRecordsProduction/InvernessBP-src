local AvatarDataUtil = {}
function AvatarDataUtil.GeneratePlayerAvatarData(uPlayerController)
  if not uPlayerController or not Game then
    log_error("AvatarDataUtil.GeneratePlayerAvatarData not uPlayerController or not Game")
    return
  end
  print(bWriteLog and "AvatarDataUtil.GeneratePlayerAvatarData UID:" .. uPlayerController.UID)
  local PlayerInfo = AvatarDataUtil.GetPlayerInfo(uPlayerController)
  if not PlayerInfo then
    log_error("AvatarDataUtil.GeneratePlayerAvatarData not not PlayerInfo")
    return
  end
  uPlayerController:OverrideAvatarInfo(PlayerInfo)
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local utility = require("common.utility")
  xpcall(function()
    CommerAvatarDataUtil:GeneratePlayerAvatarData(PlayerInfo, uPlayerController)
  end, utility.ErrorMessageHandler)
  print(bWriteLog and "AvatarDataUtil.GeneratePlayerAvatarData RolewearIndex:" .. uPlayerController.RolewearIndex)
  AvatarDataUtil.InitAdvanceVehicleData(PlayerInfo, uPlayerController)
  AvatarDataUtil.InitialEquipmentAvatar(PlayerInfo, uPlayerController)
  AvatarDataUtil.InitPlayerEmoteFeature(PlayerInfo, uPlayerController)
end
function AvatarDataUtil.GetPlayerInfo(uPlayerController)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  print(bWriteLog and "AvatarDataUtil.GeneratePlayerAvatarData UID:" .. uPlayerController.UID)
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local PlayerInfo = PlayerDataMgr.GetPlayerInfo(uPlayerController.UID)
  if PlayerInfo == nil then
    local hasData = false
    if UKismetSystemLibrary.IsStandalone(uPlayerController) then
      PlayerInfo, hasData = AvatarDataUtil.GetAvatarStandaloneData()
    end
    if IsEditor and not hasData then
      PlayerInfo = AvatarDataUtil.GetAvatarTestData()
    end
    if IsEditor then
      PlayerDataMgr.OnSyncPlayerInfo(uPlayerController.UID, PlayerInfo)
    end
  end
  return PlayerInfo
end
function AvatarDataUtil.InitAdvanceVehicleData(PlayerInfo, uPlayerController)
  if not PlayerInfo.car_info or not PlayerInfo.car_info.car_list then
    return
  end
  local vehicleAvatarList = {}
  for i, v in pairs(PlayerInfo.car_info.car_list) do
    local styleList = {}
    styleList.VehicleSkinID = i
    styleList.VehicleStyleIDList = {}
    styleList.VehicleAvatarStyle = {}
    if v ~= nil then
      for ii, vv in pairs(v) do
        local oneStyleData = {}
        if vv ~= nil and next(vv) ~= nil and vv[1] then
          oneStyleData.ModelID = vv[1]
          oneStyleData.ColorID = vv[2] or 0
          oneStyleData.PatternID = vv[3] or 0
          oneStyleData.ParticleID = vv[4] or 0
          table.insert(styleList.VehicleAvatarStyle, oneStyleData)
        end
      end
    end
    table.insert(vehicleAvatarList, styleList)
  end
  uPlayerController.InitialVehicleAdvanceAvatarList = vehicleAvatarList
  log_tree("AvatarDataUtil.GeneratePlayerAvatarData InitAdvanceVehicleData: ", vehicleAvatarList)
end
function AvatarDataUtil.InitialEquipmentAvatar(PlayerInfo, uPlayerController)
  local EquipmentAvatar = {}
  local bSubscribeBagOpened = uPlayerController.bSubscribeBagOpened
  if bSubscribeBagOpened then
    EquipmentAvatar.BagAvatar = PlayerInfo.bag_skin
  elseif PlayerInfo.all_knapsack_ext_info and PlayerInfo.use_rolewear and PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear] and PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear].bag_skin_list and next(PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear].bag_skin_list) then
    EquipmentAvatar.BagAvatarList = PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear].bag_skin_list
  elseif PlayerInfo.bag_skin ~= nil then
    EquipmentAvatar.BagAvatar = PlayerInfo.bag_skin
  end
  if bSubscribeBagOpened then
    EquipmentAvatar.HelmetAvatar = PlayerInfo.helmet_skin
  elseif PlayerInfo.all_knapsack_ext_info and PlayerInfo.use_rolewear and PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear] and PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear].helmet_skin_list and next(PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear].helmet_skin_list) then
    EquipmentAvatar.HelmetAvatarList = PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear].helmet_skin_list
  elseif PlayerInfo.helmet_skin ~= nil then
    EquipmentAvatar.HelmetAvatar = PlayerInfo.helmet_skin
  end
  if PlayerInfo.armor_skin ~= nil then
    EquipmentAvatar.ArmorAvatar = PlayerInfo.armor_skin
  end
  uPlayerController.Initial  if slua.isValid(uPlayerController.PlayerState) and uPlayerController.PlayerState.MetroPlayerStateAvatarFeature then
    uPlayerController.PlayerState.MetroPlayerStateAvatarFeature.InitialEquipmentAvatar = uPlayerController.InitialEquipmentAvatar
  end
  log_tree("AvatarDataUtil.GeneratePlayerAvatarData InitialEquipmentAvatar: ", EquipmentAvatar)
end
function AvatarDataUtil.InitPlayerEmoteFeature(PlayerInfo, uPlayerController)
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local SpecialEffectEmoteData = ServerPlayerDataMgr.GetPlayerProgressFromServer(tonumber(uPlayerController.UID), ExtendAttribute.SpecialEffectEmote)
  log_tree(bWriteLog and "AvatarDataUtil.GeneratePlayerAvatarData SpecialEffectEmoteData" .. uPlayerController.UID, SpecialEffectEmoteData)
  if SpecialEffectEmoteData and SpecialEffectEmoteData.motion_effect_level and uPlayerController.PlayEmoteFeature then
    uPlayerController.PlayEmoteFeature:InitEmoteLevelInfo(SpecialEffectEmoteData.motion_effect_level)
  end
  if PlayerInfo.ext_attr then
    if PlayerInfo.ext_attr[47] and #PlayerInfo.ext_attr[47] > 0 then
      uPlayerController.PlayEmoteFeature:InitCollectionList(PlayerInfo.ext_attr[47])
    end
    local ExtendAttribute = require("Server.config.ExtendAttribute")
    if PlayerInfo.ext_attr[ExtendAttribute.PlacardEmote] and 0 < #PlayerInfo.ext_attr[ExtendAttribute.PlacardEmote] then
      uPlayerController.PlayEmoteFeature:InitPlacardList(PlayerInfo.ext_attr[ExtendAttribute.PlacardEmote])
    end
    if PlayerInfo.ext_attr[ExtendAttribute.PopularPKEmote] and 0 < #PlayerInfo.ext_attr[ExtendAttribute.PopularPKEmote] then
      uPlayerController.PlayEmoteFeature:InitPopularPKList(PlayerInfo.ext_attr[ExtendAttribute.PopularPKEmote])
    end
    if PlayerInfo.ext_attr[ExtendAttribute.QuickEmoteAndDecalList] then
      uPlayerController.PlayEmoteFeature:InitQuickEmoteAndDecalList(PlayerInfo.ext_attr[ExtendAttribute.QuickEmoteAndDecalList])
    end
  end
end
function AvatarDataUtil.TryGetGrenadeAvatarID(uPlayerController, ItemID)
  local avatarID
  if uPlayerController ~= nil and slua.isValid(uPlayerController) then
    local avatarDic = uPlayerController.InitialConsumableAvatar
    if avatarDic ~= nil then
      if ItemID == 602001 then
        avatarID = avatarDic.GrenadeAvatarStun
      elseif ItemID == 602002 then
        avatarID = avatarDic.GrenadeAvatarSmoke
      elseif ItemID == 602003 then
        avatarID = avatarDic.GrenadeAvatarBurn
      elseif ItemID == 602004 then
        avatarID = avatarDic.GrenadeAvatarShoulei
      end
    end
  end
  return avatarID
end
local GetTestWearExt = function()
  local TDMUtil = require("GameLua.Mod.TDM.Gameplay.TDMUtil")
  return {
    [9] = {401993}
  }
end
function AvatarDataUtil.GetAvatarTestData()
  local TestAvatarInfo = {
    wear_ext = GetTestWearExt(),
    is_robot = false,
    expression = {
      2203601,
      12220484,
      2203901,
      2202901,
      2203001,
      2203101,
      2203201,
      2203301
    },
    wheel_list = {
      [1] = 2301082,
      [2] = 2301083,
      [3] = 2301084,
      [6] = 12220054,
      [7] = 12219623,
      [8] = 12220010
    },
    emoji_bubble = {
      2206022,
      2206023,
      2206024,
      2206025
    },
    interactive_action = {
      10001,
      10002,
      10003
    },
    motion_effect_level = {
      [12219623] = 1,
      [12220010] = 1
    },
    show_effect = false,
    fireworks_info = {},
    ingame_use_item_info = {
      [2301008] = {count = 8},
      [2301009] = {count = 9},
      [2301010] = {count = 10},
      [2301011] = {count = 11},
      [2301012] = {count = 12},
      [2301001] = {count = 1},
      [2301002] = {count = 2},
      [2301003] = {count = 3},
      [2301004] = {count = 4},
      [2301005] = {count = 5},
      [2301006] = {count = 6},
      [2301007] = {count = 7},
      [4151024] = {count = 1},
      [602128] = {count = 1}
    },
    equip_plating_list = {
      [1] = 2301001,
      [2] = 2301002,
      [3] = 2301003,
      [4] = 2301004,
      [5] = 2301005,
      [6] = 2301006,
      [7] = 2301007,
      [8] = 2301008,
      [9] = 2301009,
      [10] = 2301010,
      [11] = 2301011,
      [12] = 2301012
    },
    vst_in_battle = {
      [901] = {
        1901005,
        1901003,
        1901004
      },
      [902] = {1902015, 1902010},
      [903] = {1903197},
      [904] = {},
      [905] = {0},
      [906] = {0},
      [907] = {1907044},
      [908] = {},
      [909] = {},
      [910] = {},
      [911] = {},
      [912] = {0},
      [913] = {0},
      [914] = {0},
      [915] = {1915008},
      [916] = {1916004},
      [917] = {1917005},
      [918] = {0},
      [919] = {1919010},
      [920] = {0},
      [953] = {1953008, 1953003},
      [960] = {1960002},
      [961] = {
        1961015,
        1961041,
        1961045,
        1961046
      },
      [968] = {1981002},
      [982] = {1980002},
      [987] = {1987001, 1987002},
      [988] = {1988002}
    },
    all_wear_ext = {
      {
        [3] = {1407995},
        [4] = {404026}
      },
      {
        [1] = {1402690},
        [3] = {1407625},
        [4] = {404026},
        [6] = {402009}
      },
      {
        [2] = {1403224},
        [3] = {1407618}
      },
      {
        [1] = {1402543},
        [2] = {1403224},
        [3] = {1405703}
      },
      [6] = {
        [1] = {1402543},
        [2] = {1403224},
        [3] = {1405983}
      },
      [9] = {
        [1] = {1402543},
        [2] = {1403224},
        [3] = {1405983}
      }
    },
    share_wear = {
      in_left_times = 5,
      out_left_times = 5,
      friend_out_left_times = 5,
      friend_uid = 54300001000,
      trigger_time = 0,
      wear_list = {
        [4] = {
          404015,
          6,
          4
        },
        [3] = {
          403017,
          6,
          4
        },
        [6] = {402024}
      },
      knapsack_ext_info = {
        throw_object_list = {},
        fly_skin = 0,
        wingman_skin = 0,
        helmet_skin = 1505000014,
        wingman_skin = 0,
        weapon_list = {},
        grenade_skin = 0,
        parachute = 0,
        bag_skin = 1501000627,
        pendants = {}
      }
    },
    use_rolewear = 9,
    weapon_skin_list = {
      1101003167,
      1101003203,
      1103001202
    },
    weaponattach_skin_list = {
      [1101007065] = {1010070654},
      [1103001202] = {1010070654}
    },
    car_info = {
      car_list = {
        [1908056] = {
          [1] = {80101003, 34},
          [8] = {80108010, 41},
          [3] = {80103001}
        },
        [1901041] = {
          [1] = {10101001, 33},
          [2] = {10102000},
          [3] = {10103000},
          [4] = {10104000},
          [10] = {10110000}
        }
      }
    },
    bag_skin = 1501000047,
    helmet_skin = 1505000014,
    all_knapsack_ext_info = {
      {
        throw_object_list = {
          [613] = 613004009,
          [614] = 614004000,
          [615] = 615004000
        },
        fly_skin = 1801180,
        gliding = 4151115,
        wingman_skin = 181101001,
        helmet_skin = 1505000014,
        wingman_skin = 181101001,
        weapon_list = {1101003195},
        weapon_attach_list = {
          [1101007065] = {1010070654}
        },
        grenade_skin = 612004188,
        parachute = 1401119,
        bag_skin = 1501000168,
        weapon_pendant = {
          [1101102024] = {417004006},
          [1102105010] = {417004347}
        },
        bag_skin_list = {
          [1] = 1501000054,
          [2] = 1501000055,
          [3] = 1501000056
        },
        pendants = {}
      },
      {
        throw_object_list = {
          [612] = 612004023,
          [613] = 613004000,
          [614] = 614004000,
          [615] = 615004000
        },
        fly_skin = 1801125,
        gliding = 4151110,
        helmet_skin = 1505000014,
        weapon_list = {1101003188},
        weapon_attach_list = {
          [1101007065] = {1010070654}
        },
        weapon_pendant = {
          [1101102024] = {417004006},
          [1102105010] = {417004347}
        },
        grenade_skin = 612004196,
        parachute = 1401619,
        bag_skin_list = {
          [1] = 1501000051,
          [2] = 1501000052,
          [3] = 1501000053
        },
        pendants = {}
      },
      {
        throw_object_list = {
          [613] = 613004000,
          [614] = 614004000,
          [615] = 615004000
        },
        gliding = 4151115,
        fly_skin = 1801124,
        helmet_skin = 1505000014,
        weapon_list = {1101001030, 841003017},
        weapon_attach_list = {
          [1101007065] = {1010070654}
        },
        weapon_pendant = {
          [1101102024] = {417004006},
          [1102105010] = {417004347}
        },
        grenade_skin = 612004196,
        parachute = 1401620,
        bag_skin = 1501000047,
        pendants = {}
      },
      {
        throw_object_list = {
          [613] = 613004000,
          [614] = 614004000,
          [615] = 615004000
        },
        fly_skin = 1801101,
        helmet_skin = 1505000014,
        weapon_list = {},
        weapon_attach_list = {
          [1101007065] = {1010070654}
        },
        weapon_pendant = {
          [1101007065] = {417004306}
        },
        grenade_skin = 612004196,
        parachute = 703001,
        bag_skin = 0,
        pendants = {}
      },
      [9] = {
        throw_object_list = {
          [613] = 613004000,
          [614] = 614004000,
          [615] = 615004000
        },
        fly_skin = 1801101,
        helmet_skin = 1505000014,
        weapon_list = {},
        weapon_attach_list = {
          [1101007065] = {1010070654}
        },
        weapon_pendant = {
          [1101007065] = {417004306}
        },
        grenade_skin = 612004196,
        parachute = 1401619,
        bag_skin = 0,
        bag_skin_list = {
          [1] = 1501000048,
          [2] = 1501000066,
          [3] = 1501000050
        },
        pendants = {}
      }
    },
    gold_dress_set_info = {
      [3] = 3
    },
    ext_attr = {
      [97] = {
        [1] = 2301103,
        [3] = 2301003,
        [5] = 2301001,
        [6] = 12220484,
        [7] = 12219623,
        [8] = 12220010
      },
      [24] = {},
      [28] = {
        motion_effect_level = {
          [12219623] = 1,
          [12219678] = 1
        }
      },
      [32] = {
        [1] = {
          plate_number = "ZXQ666",
          collect_num = 7,
          collect_list = {
            1961049,
            1908085,
            1961048,
            1908084,
            1915005,
            1915006,
            1915007
          },
          unlock_data = {
            [3] = {
              [1961049] = {},
              [1908085] = {},
              [1961048] = {},
              [1908084] = {},
              [1915005] = {},
              [1915006] = {},
              [1915007] = {}
            }
          }
        },
        [2] = {
          plate_number = "ZXQ666",
          collect_num = 7,
          collect_list = {
            1961051,
            1961052,
            1961053,
            1961054,
            1961055,
            1961056,
            1961057
          },
          unlock_data = {
            [3] = {
              [1961051] = {},
              [1961052] = {},
              [1961053] = {},
              [1961054] = {},
              [1961055] = {},
              [1961056] = {},
              [1961057] = {}
            },
            [8] = {
              [1961051] = {},
              [1961052] = {},
              [1961053] = {},
              [1961054] = {},
              [1961055] = {},
              [1961056] = {},
              [1961057] = {}
            }
          }
        },
        [3] = {
          plate_number = "ZXQ666",
          collect_num = 9,
          collect_list = {
            1903191,
            1903192,
            1903193,
            1961033,
            1961034,
            1961035,
            1908068,
            1908069,
            1908070
          },
          unlock_data = {
            [3] = {
              [1903191] = {},
              [1903192] = {},
              [1903193] = {},
              [1961033] = {},
              [1961034] = {},
              [1961035] = {},
              [1908068] = {},
              [1908069] = {},
              [1908070] = {}
            },
            [8] = {
              [1903191] = {},
              [1903192] = {},
              [1903193] = {},
              [1961033] = {},
              [1961034] = {},
              [1961035] = {},
              [1908068] = {},
              [1908069] = {},
              [1908070] = {}
            }
          }
        },
        [10] = {
          collect_num = 9,
          collect_list = {
            1961138,
            1961139,
            1961137,
            1908094,
            1908095,
            1915008,
            1915009,
            1903200,
            1903201
          }
        }
      },
      [36] = {
        [612004188] = 1101003203
      },
      [42] = {
        [1101102024] = {417004006},
        [1102105010] = {417004347}
      },
      [47] = {
        12220069,
        12220068,
        12220067,
        12220072,
        12220071,
        12220070
      },
      [53] = {
        [1] = {
          stone_data = {
            [1] = 25010002,
            [3] = 25010004
          },
          expression_list = {22080001}
        },
        [2] = {
          stone_data = {
            [1] = 25010007,
            [2] = 25010008,
            [3] = 25010009,
            [4] = 25010010
          },
          expression_list = {22080002}
        },
        [3] = {
          stone_data = {
            [1] = 25010014,
            [2] = 25010015
          },
          expression_list = {22080003}
        }
      },
      [62] = {
        [1903211] = {
          [1991011] = 1,
          [1991012] = 1
        },
        [1903204] = {
          [1991001] = 1,
          [1991002] = 1
        },
        [1953019] = {
          [1991025] = 1,
          [1991026] = 1
        },
        [1961061] = {
          [1991020] = 1,
          [1991021] = 1
        }
      },
      [65] = {
        6701001,
        6702001,
        6702002
      },
      [66] = {
        switch_effect_info = 1,
        chassis_light_info = {
          [1961145] = 7302001,
          [1961147] = 7302001
        },
        plate_background_info = {
          [7] = 7301001
        },
        brake_caliper_info = {
          [1908117] = 7304003
        },
        wheel_hub_info = {
          [19116002] = 7305007,
          [19116003] = 7305007,
          [19116004] = 7305007,
          [1908117] = 7305004,
          [1908118] = 7305004,
          [1961070] = 7305006,
          [1961071] = 7305005,
          [1961072] = 7305005,
          [1961073] = 7305006
        },
        sunroof_info = {
          [1908117] = 7305011,
          [1908118] = 7305011,
          [1908119] = 7305012
        }
      },
      [68] = {12220336},
      [78] = {
        22090001,
        22090002,
        22090003,
        22090004,
        22090005,
        22090006
      }
    }
  }
  return TestAvatarInfo
end
function AvatarDataUtil.GetAvatarStandaloneData()
  local hasData = false
  local StandaloneAvatarInfo = {
    wear_ext = {}
  }
  if DataMgr == nil then
    return StandaloneAvatarInfo, hasData
  end
  local tAllEquip = AvatarData.GetAllWearInfoEnumFormat()
  if tAllEquip and next(tAllEquip) then
    hasData = true
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(tAllEquip) do
    table.insert(StandaloneAvatarInfo.wear_ext, v)
  end
  local nHeadId = AvatarData.GetHeadID() or 0
  local tHeadData = AvatarData.CreateEnumFormatAvatarCustom(nHeadId)
  table.insert(StandaloneAvatarInfo.wear_ext, tHeadData)
  local nHairId = AvatarData.GetHairID() or 0
  local tHairIdData = AvatarData.CreateEnumFormatAvatarCustom(nHairId)
  table.insert(StandaloneAvatarInfo.wear_ext, tHairIdData)
  local nBreadID = AvatarData.GetBeardID() or 0
  local tBreadData = AvatarData.CreateEnumFormatAvatarCustom(nBreadID, AvatarData.GetBeardColorID() or 0)
  table.insert(StandaloneAvatarInfo.wear_ext, tBreadData)
  local TableUtil = require("common.table_util")
  if DataMgr.avatarData.attr_info and next(DataMgr.avatarData.attr_info) then
    for key, value in pairs(DataMgr.avatarData.attr_info) do
      if value and type(value) == "table" then
        local tItemData = TableUtil.CopyTable(value)
        table.insert(StandaloneAvatarInfo.wear_ext, tItemData)
      end
    end
  end
  local bag_data = WardrobeData:GetHallDepotItemDataByInsID(DataMgr.equipmentSkinInsIDTable[504])
  if bag_data then
    StandaloneAvatarInfo.bag_skin = bag_data.resID
  end
  local helmet_data = WardrobeData:GetHallDepotItemDataByInsID(DataMgr.equipmentSkinInsIDTable[505])
  if helmet_data then
    StandaloneAvatarInfo.helmet_skin = helmet_data.resID
  end
  local armor_data = WardrobeData:GetHallDepotItemDataByInsID(DataMgr.equipmentSkinInsIDTable[506])
  if armor_data then
    StandaloneAvatarInfo.armor_skin = armor_data.resID
  end
  StandaloneAvatarInfo.expression = {}
  for k, v in ipairs(DataMgr.MotionSlotList) do
    local data = WardrobeData:GetHallDepotItemDataByInsID(v)
    if data then
      table.insert(StandaloneAvatarInfo.expression, data.resID)
    end
  end
  return StandaloneAvatarInfo, hasData
end
function AvatarDataUtil.FilterWeaponAttachments(uPlayerController, weaponList, bFromCpp)
  if not weaponList then
    return weaponList
  end
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local partsInfo = ServerPlayerDataMgr.GetPlayerProgressFromServer(tonumber(uPlayerController.UID), ExtendAttribute.UpgradeGunAttachments)
  if not partsInfo then
    log(bWriteLog and "AvatarDataUtil.FilterWeaponAttachments not partsInfo")
    return weaponList
  end
  log_tree("AvatarDataUtil.FilterWeaponAttachments partsInfo:", partsInfo)
  log_tree("AvatarDataUtil.FilterWeaponAttachments weaponList Before:", weaponList)
  local RemoveAllAttachments = partsInfo.total_shield == false
  local parts_shield = partsInfo.parts_shield
  for index, weapon in pairs(weaponList) do
    log(bWriteLog and "AvatarDataUtil.FilterWeaponAttachments weapon ItemTableID:" .. weapon.ItemTableID)
    if RemoveAllAttachments then
      if bFromCpp then
        weapon.AdditionIntData:Clear()
      else
        weapon.AdditionIntData = nil
      end
    elseif weapon.AdditionIntData then
      local listNum = bFromCpp and weapon.AdditionIntData:Num() or #weapon.AdditionIntData
      if 0 < listNum then
        local skinId = weapon.ItemTableID
        local weaponId
        local mapping = CDataTable.GetTableData("WeaponSkinMapping", skinId)
        if mapping and mapping.WeaponID and mapping.WeaponID ~= 0 then
          weaponId = mapping.WeaponID
        else
          local armory = CDataTable.GetTableData("ArmoryConfig", skinId)
          if armory then
            weaponId = skinId
          end
        end
        if weaponId and parts_shield[weaponId] then
          log(bWriteLog and "AvatarDataUtil.FilterWeaponAttachments weaponId:" .. weaponId)
          for i = listNum, 1, -1 do
            local attachment = bFromCpp and weapon.AdditionIntData:Get(i - 1) or weapon.AdditionIntData[i]
            local attachmentCfg = CDataTable.GetTableData("Item", attachment)
            if attachmentCfg and attachmentCfg.ItemSubType and parts_shield[weaponId][attachmentCfg.ItemSubType] then
              log(bWriteLog and "AvatarDataUtil.FilterWeaponAttachments attachment:" .. attachment .. " attachmentCfg.ItemSubType:" .. attachmentCfg.ItemSubType)
              if bFromCpp then
                weapon.AdditionIntData:Remove(i - 1)
              else
                table.remove(weapon.AdditionIntData, i)
              end
            end
          end
        end
      end
    end
    if bFromCpp then
      weaponList:Set(index, weapon)
    end
    log_tree("AvatarDataUtil.FilterWeaponAttachments weapon After:", weapon)
  end
  log_tree("AvatarDataUtil.FilterWeaponAttachments weaponList After:", weaponList)
  return weaponList
end
return AvatarDataUtil