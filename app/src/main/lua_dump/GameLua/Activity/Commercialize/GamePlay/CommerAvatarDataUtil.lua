local CommerAvatarDataUtil = {}
local UAvatarUtils = import("AvatarUtils")
local TableUtil = require("common.table_util")
require("common.macros.item_macros")
function CommerAvatarDataUtil:GeneratePlayerAvatarData(PlayerInfo, uPlayerController)
  print(bWriteLog and "CommerAvatarDataUtil:GeneratePlayerAvatarData Start")
  local bHasFlyingState = self:_HasFlyingState(uPlayerController)
  local itemList = {}
  self:_SetCommerFeatures(uPlayerController)
  self:_UpdateDragonSource(PlayerInfo, uPlayerController)
  local ShareBagAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.ShareBag.ShareBagAvatarDataUtil")
  ShareBagAvatarDataUtil:GeneratePlayerAvatarData(PlayerInfo, uPlayerController, bHasFlyingState)
  local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
  XSuitAvatarDataUtil:GeneratePlayerAvatarData(PlayerInfo, uPlayerController, itemList, bHasFlyingState)
  self:_FillVehicleSkinList(PlayerInfo, uPlayerController)
  self:_FillGlideList(PlayerInfo, uPlayerController, itemList, bHasFlyingState)
  self:_FillDragonList(PlayerInfo, uPlayerController)
  self:_FillWeaponShowList(PlayerInfo, uPlayerController)
  local SuitMultiShapeDataUtil = require("GameLua.Activity.Commercialize.GamePlay.SuitMultiShape.SuitMultiShapeDataUtil")
  SuitMultiShapeDataUtil:GeneratePlayerAvatarData(PlayerInfo, uPlayerController)
  local PetFormDataUtil = require("GameLua.Activity.Commercialize.GamePlay.Pet.PetFormDataUtil")
  PetFormDataUtil:GeneratePlayerPetFormData(PlayerInfo, uPlayerController)
  self:_FillMileStoneList(PlayerInfo, uPlayerController)
  self:_FillUpgradeVehicleMusicFeature(uPlayerController)
  local MiniTVDataUtil = require("GameLua.Activity.Commercialize.GamePlay.MiniTV.MiniTVDataUtil")
  MiniTVDataUtil:GeneratePlayerMiniTVData(PlayerInfo, uPlayerController)
  local VehicleAccessoryDataUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehicleAccessoryDataUtil")
  VehicleAccessoryDataUtil:GeneratePlayerVehicleAccessoryData(PlayerInfo, uPlayerController)
  self:_FillOtherItemList(PlayerInfo, itemList)
  uPlayerController.InitialItemList = itemList
  local uPawn = uPlayerController:K2_GetPawn()
  if uPawn then
    if next(itemList) ~= nil then
      uPawn.InitialItemList = itemList
    end
    uPawn:RefreshFollowState()
  end
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local WeaponPendantInfo = ServerPlayerDataMgr.GetPlayerProgressFromServer(tonumber(uPlayerController.UID), ExtendAttribute.WeaponPendant)
  self:InitWeaponSkinList(uPlayerController, PlayerInfo.weapon_skin_list, PlayerInfo.weaponattach_skin_list, WeaponPendantInfo)
  print(bWriteLog and "CommerAvatarDataUtil:GeneratePlayerAvatarData End")
  log_tree("CommerAvatarDataUtil.GeneratePlayerAvatarData InitialItemList:", itemList)
end
function CommerAvatarDataUtil:GetAdditionIntData(v)
  if not v or not next(v) then
    return {}
  end
  local color_id = v[ENUM_AVATAR_DATA_TYPE.ColorID] or 0
  local pattern_id = v[ENUM_AVATAR_DATA_TYPE.PatternID] or 0
  local custom_num = v[ENUM_AVATAR_DATA_TYPE.CustomNumber] or -1
  local ShapeInfo = v[ENUM_AVATAR_DATA_TYPE.ShapeInfo] or 0
  return {
    color_id,
    pattern_id,
    custom_num,
    ShapeInfo
  }
end
function CommerAvatarDataUtil:InitWeaponSkinList(uPlayerController, weapon_skin_list, weaponattach_skin_list, WeaponPendantInfo)
  local weaponList = self:ConstructWeaponSkinList(uPlayerController, weapon_skin_list, weaponattach_skin_list, WeaponPendantInfo)
  local AvatarDataUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarDataUtil")
  weaponList = AvatarDataUtil.FilterWeaponAttachments(uPlayerController, weaponList)
  uPlayerController.InitialWeaponAvatarList = weaponList
  log_tree("CommerAvatarDataUtil:InitWeaponSkinList InitialWeaponAvatarList:", weaponList)
end
function CommerAvatarDataUtil:WeaponCanUsePendant(skinID)
  if not skinID then
    return false
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local itemUpgradeCfg = ItemUpgradeMgr:GetUpgradeCfg(skinID)
  if itemUpgradeCfg and itemUpgradeCfg.IsPendant then
    return itemUpgradeCfg.IsPendant == 1
  end
  return false
end
function CommerAvatarDataUtil:ConstructWeaponSkinList(uPlayerController, weapon_skin_list, weaponattach_skin_list, WeaponPendantInfo)
  local weaponList = {}
  if weapon_skin_list then
    for i, v in pairs(weapon_skin_list) do
      local item = {ItemTableID = v, Count = 1}
      local attachMentList = {}
      if weaponattach_skin_list and weaponattach_skin_list[v] ~= nil then
        local WeaponID = v
        local MultiStateCfg = CDataTable.GetTableData("WeaponMultiStateCfg", v)
        if MultiStateCfg and MultiStateCfg.BaseID then
          WeaponID = MultiStateCfg.BaseID
        end
        local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
        local weaponCfg = ItemUpgradeMgr:GetUpgradeCfg(WeaponID)
        for _, attachId in pairs(weaponattach_skin_list[v]) do
          local attachCfg = CDataTable.GetTableDataByFilter("ItemUpgradeUnLockConfig", "PartId", attachId)
          if attachCfg and attachCfg.GroupID and attachCfg.GroupID ~= weaponCfg.GroupID then
            local diffColorPartCfg = CDataTable.GetTableData("ItemUpgradeDiffColorPart", attachId)
            if diffColorPartCfg and diffColorPartCfg.DiffColorPartID and diffColorPartCfg.DiffColorPartID ~= 0 then
              attachId = diffColorPartCfg.DiffColorPartID
            end
            weaponattach_skin_list[v][_] = attachId
          end
        end
        attachMentList = weaponattach_skin_list[v]
      end
      if self:WeaponCanUsePendant(v) and WeaponPendantInfo and WeaponPendantInfo[v] then
        local PendantID = WeaponPendantInfo[v][1]
        if PendantID then
          local MapCfg = CDataTable.GetTableData("PendantMapCfg", PendantID)
          if MapCfg then
            table.insert(attachMentList, MapCfg.WeaponPendantID)
          end
        end
      end
      if 0 < #attachMentList then
        item.AdditionIntData = attachMentList
      end
      table.insert(weaponList, item)
    end
  end
  return weaponList
end
function CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(UID, attr)
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local DataRet = PlayerDataMgr.GetPlayerProgressFromServer(UID, attr)
  if not DataRet and IsEditor then
    DataRet = self:GetTestExtendAttribute(attr)
  end
  return DataRet
end
function CommerAvatarDataUtil:GetTestExtendAttribute(attr)
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local TestData
  if attr == ExtendAttribute.Holography then
    TestData = {7001006, 7002001}
  elseif attr == ExtendAttribute.XSuitState then
    TestData = {
      [7] = {
        unlock_state = {
          [1] = 1,
          [2] = 1
        },
        cur_state = 1
      },
      [11] = {
        unlock_state = {
          [1] = 1,
          [2] = 1
        },
        cur_state = 1
      },
      [14] = {
        unlock_state = {
          [1] = 1,
          [2] = 1
        },
        cur_state = 1
      }
    }
  elseif attr == ExtendAttribute.XSuitLevel then
    TestData = {
      [9] = 2
    }
  elseif attr == ExtendAttribute.DragonSuitState then
    TestData = {
      has_item_list = {
        1406939,
        1406937,
        1406947,
        1406948,
        1407563,
        1407564,
        1407566,
        1407567,
        1407672,
        1407673,
        1407846,
        1407847
      },
      unlock_state = false
    }
  elseif attr == ExtendAttribute.XSuitUnlockFeature then
    TestData = {
      [2] = {
        unlock_info = {
          [2] = {
            [1] = {state = 1},
            [2] = {state = 1}
          }
        },
        flag_info = {
          [2] = {
            [2] = {flag_state = 1}
          }
        }
      },
      [3] = {
        bicolor_state = 2,
        unlock_info = {
          [2] = {
            [1] = {state = 1}
          }
        }
      },
      [15] = {
        flag_info = {
          [2] = {
            [2] = {flag_state = 1}
          }
        }
      }
    }
  elseif attr == ExtendAttribute.WeaponShowEmote then
    TestData = {12219541}
  elseif attr == ExtendAttribute.AdditionPetInfo then
    TestData = {
      [1] = {
        pet_level = 1,
        pet_id = 50008,
        change = 1
      },
      [2] = {pet_level = 1, pet_id = 50009},
      [3] = {pet_level = 1, pet_id = 50001},
      [4] = {
        pet_level = 1,
        pet_id = 50033,
        change = 1
      }
    }
  elseif attr == ExtendAttribute.MileStoneDataNew then
    TestData = {
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
          [4] = 25010007
        },
        expression_list = {22080002}
      },
      [3] = {
        stone_data = {
          [1] = 25010014,
          [2] = 25010015,
          [3] = 25010022
        },
        expression_list = {22080003}
      },
      [4] = {
        stone_data = {
          [1] = 25010026,
          [2] = 25010029,
          [3] = 25010028
        },
        expression_list = {22080004}
      },
      [5] = {
        stone_data = {
          [1] = 25010039,
          [2] = 25010040,
          [3] = 25010041
        },
        expression_list = {22080005}
      },
      [6] = {
        stone_data = {
          [1] = 25010011,
          [2] = 25010011,
          [3] = 25010011,
          [4] = 25010011
        },
        expression_list = {22080006}
      }
    }
  elseif attr == ExtendAttribute.ShareBagList then
    TestData = {
      [1] = {
        wear_list = {
          [3] = {1408572}
        },
        knapsack_ext_info = {
          helmet_skin = 0,
          parachute = 0,
          fly_skin = 0,
          wingman_skin = 0,
          bag_skin = 0,
          pendants = {}
        },
        use_uid = 54300010190
      },
      [3] = {
        pet_list = {
          [50017] = {
            pet_level = 1,
            pet_id = 50017,
            change = 1
          }
        },
        use_uid = 10001
      },
      [4] = {
        weapon_list = {1101001001}
      }
    }
  elseif attr == ExtendAttribute.UpgradeVehicleData then
    TestData = {6701001}
  elseif attr == ExtendAttribute.PetBubblePrivilege then
    return 1
  elseif attr == ExtendAttribute.PetSwitchEffect then
    TestData = {622010001}
  elseif attr == ExtendAttribute.IsShowAliasEnterBroadcast then
    return true
  elseif attr == ExtendAttribute.EliminationKingEffect then
    return 619150001
  elseif attr == ExtendAttribute.InheritData then
    TestData = {
      gold_dress_state_info = {
        [7] = {
          unlock_state = {
            [1] = 0,
            [2] = 1
          },
          cur_state = 2
        }
      },
      dragon_ball_item_info = {
        has_item_list = {},
        unlock_state = true
      }
    }
  elseif attr == ExtendAttribute.WeaponCapabilityAlias then
    TestData = {
      [2490261] = {
        receive_time = 0,
        expire_ts = 0,
        have_used = true,
        nation = "",
        rank = 2,
        ext_info = nil
      }
    }
  elseif attr == ExtendAttribute.MiniTVInfo then
    TestData = {
      minitv_dress_id = 1601020,
      motion_info = {50000001, 50000002}
    }
  elseif attr == ExtendAttribute.DepotCommonPutOn then
    TestData = {}
  end
  return TestData
end
function CommerAvatarDataUtil:GetCommerFeatureByAttr(uPlayerController, Attr)
  if not uPlayerController or not uPlayerController.CommerFeature then
    return nil
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  for _, v in pairs(ExtendAttribute.CommercializeAttr) do
    if v.attr == Attr and v.name and v.name ~= "" then
      return uPlayerController.CommerFeature[v.name]
    end
  end
  return nil
end
function CommerAvatarDataUtil:_SetCommerFeatures(uPlayerController)
  print(bWriteLog and "CommerAvatarDataUtil:_SetCommerFeatures")
  if not uPlayerController or not uPlayerController.CommerFeature then
    return
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  for _, v in pairs(ExtendAttribute.CommercializeAttr) do
    local CommerFeature = self:GetPlayerExtendAttributeAndTest(uPlayerController.UID, v.attr)
    if CommerFeature and v.name and v.name ~= "" then
      uPlayerController.CommerFeature[v.name] = CommerFeature
    end
  end
end
function CommerAvatarDataUtil:_HasFlyingState(uPlayerController)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local BTModeTable
  if _G.ModeID == nil and Client and Client.IsEditor() then
    _G.ModeID = 30000
    BTModeTable = CDataTable.GetTableData("BTMode", _G.ModeID)
  elseif UKismetSystemLibrary.IsStandalone(uPlayerController) then
    if _G.ModeID == nil then
      _G.ModeID = 30000
    end
    BTModeTable = CDataTable.GetTableData("BTMode", _G.ModeID)
  else
    BTModeTable = CDataTable.GetTableData("BTMode", _G.ModeID)
  end
  local bHasFlyingState = BTModeTable ~= nil and BTModeTable.HasFlyState or BTModeTable == nil
  return bHasFlyingState
end
function CommerAvatarDataUtil:_FillVehicleSkinList(PlayerInfo, uPlayerController)
  print(bWriteLog and "CommerAvatarDataUtil:_FillVehicleSkinList")
  local vehicleSkinList = {}
  if PlayerInfo.vst_in_battle ~= nil then
    for _, skinList in pairs(PlayerInfo.vst_in_battle) do
      if skinList and skinList[1] then
        local item = {
          ItemTableID = skinList[1],
          Count = 1
        }
        table.insert(vehicleSkinList, item)
      end
    end
  end
  self:_InsertMechaSkin(vehicleSkinList)
  uPlayerController.InitialVehicleAvatarList = vehicleSkinList
  uPlayerController:InitVehicleAvatarList()
  uPlayerController.ShowVehicleSkin = PlayerInfo.vst_skin or 0
  local vehicleSkinData = {}
  if PlayerInfo.vst_in_battle ~= nil then
    for vehicleSubType, skinList in pairs(PlayerInfo.vst_in_battle) do
      local itemArray = {}
      for _, resid in pairs(skinList) do
        local item = {ItemTableID = resid, Count = 1}
        table.insert(itemArray, item)
      end
      table.insert(vehicleSkinData, {Items = itemArray})
    end
  end
  self:_InsertMechaSkinArray(vehicleSkinData)
  uPlayerController.InitialVehicleAvatarSkinList = vehicleSkinData
  log_tree("CommerAvatarDataUtil._FillVehicleSkinList InitVehicleAvatarData: ", vehicleSkinData)
  uPlayerController:InitVehicleAvatarSkinList()
  local VehicleSwitchEffectId = 0
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local VehicleFeatureTable = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(uPlayerController.UID), ExtendAttribute.VehicleExtendedFeatures)
  if VehicleFeatureTable and VehicleFeatureTable.switch_effect_info then
    VehicleSwitchEffectId = VehicleFeatureTable.switch_effect_info
  end
  uPlayerController.n  log(bWriteLog and "CommerAvatarDataUtil:_FillVehicleSkinList nVehicleSwitchEffectId = " .. tostring(VehicleSwitchEffectId))
end
function CommerAvatarDataUtil:GetClothes2VehicleCfg()
  return CDataTable.GetTable("Clothes2VehicleCfg")
end
function CommerAvatarDataUtil:ChangeVehicleSkinByClothes(MainPlayerController, CharacterAvatarComp2_BP)
  print(bWriteLog and "  CommerAvatarDataUtil:ChangeVehicleSkinByClothes.  ")
  local EAvatarSlotType = import("EAvatarSlotType")
  local ClothSlotDesc = CharacterAvatarComp2_BP.LogicSlotDesc:Get(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local clothesId = ClothSlotDesc and ClothSlotDesc.ItemDefineID.TypeSpecificID
  if not clothesId or clothesId == 0 then
    return
  end
  local Clothes2VehicleCfg = CDataTable.GetTableData("Clothes2VehicleCfg", clothesId)
  if not Clothes2VehicleCfg then
    return
  end
  local VehicleAvatarSkinList = MainPlayerController.VehicleAvatarSkinList
  local VehicleId = Clothes2VehicleCfg.VehicleId
  local VehicleShapeType = UAvatarUtils.GetVehicleShapeBySkinID(VehicleId)
  local VehicleSkinList = VehicleAvatarSkinList:Get(VehicleShapeType)
  if VehicleSkinList and 0 <= TableUtil.Find(VehicleSkinList.SkinList, VehicleId) then
    MainPlayerController.VehicleAvatarList:Add(VehicleShapeType, VehicleId)
    print(bWriteLog and "  CommerAvatarDataUtil:ChangeVehicleSkinByClothes.  VehicleId" .. tostring(VehicleId))
    return VehicleId
  end
end
function CommerAvatarDataUtil:_InsertMechaSkin(vehicleSkinList)
  for key, Item in pairs(vehicleSkinList) do
    if Item and (Item.ItemTableID == 1984002 or Item.ItemTableID == 1985002) then
      table.insert(vehicleSkinList, {ItemTableID = 1982002, Count = 1})
      break
    end
  end
end
function CommerAvatarDataUtil:_InsertMechaSkinArray(vehicleSkinData)
  for _, itemArray in pairs(vehicleSkinData) do
    if itemArray.Items then
      for key, Item in pairs(itemArray.Items) do
        if Item and (Item.ItemTableID == 1984002 or Item.ItemTableID == 1985002) then
          local _Mechaitem = {ItemTableID = 1982002, Count = 1}
          table.insert(vehicleSkinData, {
            Items = {_Mechaitem}
          })
          return
        end
      end
    end
  end
end
function CommerAvatarDataUtil:FillGlideConsumable(id, tBornItems, tInfo)
  local VehicleUseConfig = CDataTable.GetTableData("VehicleUseConfig", id)
  if not VehicleUseConfig then
    return false
  end
  local wear_ext = TableUtil.GetTableValue(tInfo, "wear_ext")
  if wear_ext then
    for _, v in pairs(wear_ext) do
      local clothes = TableUtil.GetTableValue(v, 1)
      if clothes and VehicleUseConfig.SuitID_s:Get(clothes) then
        local Consumable = VehicleUseConfig.Consumable
        log(bWriteLog and "  CommerAvatarDataUtil:_FillGlideConsumable 390:" .. tostring(Consumable))
        local item = {
          BornItemID = Consumable,
          BornItemCount = 1,
          BornItemFlags = 0
        }
        tBornItems[#tBornItems + 1] = item
        return true
      end
    end
  end
end
function CommerAvatarDataUtil:_FillGlideList(PlayerInfo, uPlayerController, itemList, bHasFlyingState)
  print(bWriteLog and "CommerAvatarDataUtil:_FillGlideList bHasFlyingState\239\188\154" .. tostring(bHasFlyingState))
  local IsGlide = function(Table, ItemID)
    if not Table or not Table[ItemID] then
      return false
    end
    local ItemSubType = Table[ItemID].ItemSubType
    if not ItemSubType then
      return false
    end
    if ItemSubType == 413 or ItemSubType == 414 or ItemSubType == 415 then
      return true
    end
    return false
  end
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local InitInGameItems = PlayerDataMgr.GetInitInGameItems(uPlayerController.UID)
  local TemptItemInfo = {}
  if PlayerInfo.equip_plating_list and InitInGameItems then
    for Idx, ID in pairs(PlayerInfo.equip_plating_list) do
      if InitInGameItems[ID] and InitInGameItems[ID].Count then
        local item = {
          ItemTableID = ID,
          Count = InitInGameItems[ID].Count
        }
        table.insert(itemList, item)
        TemptItemInfo[ID] = true
      end
    end
  end
  if InitInGameItems then
    local ItemTable = CDataTable.GetTable("Item")
    for ID, v in pairs(InitInGameItems) do
      if TemptItemInfo[ID] == nil and v.Count then
        local item = {
          ItemTableID = ID,
          Count = v.Count
        }
        local bNeedAdd = true
        local bIsGlider = IsGlide(ItemTable, ID)
        if bIsGlider then
          if not bHasFlyingState then
            bNeedAdd = false
          end
          local DefaultKnapsackExt = PlayerInfo.use_rolewear and PlayerInfo.all_knapsack_ext_info and PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear]
          if DefaultKnapsackExt and DefaultKnapsackExt.gliding ~= ID and DefaultKnapsackExt.aircraft_put_id ~= ID then
            bNeedAdd = false
          end
        end
        if bNeedAdd then
          table.insert(itemList, item)
        end
      end
    end
  end
end
function CommerAvatarDataUtil:_FillWeaponShowList(PlayerInfo, uPlayerController)
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local WeaponShowEmoteList = self:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.WeaponShowEmote)
  if WeaponShowEmoteList then
    uPlayerController.CommerFeature.  end
end
function CommerAvatarDataUtil:_FillMileStoneList(PlayerInfo, uPlayerController)
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local _MileStoneDataNew = self:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.MileStoneDataNew)
  if not _MileStoneDataNew then
    print(bWriteLog and "CommerAvatarDataUtil:_FillMileStoneList not _MileStoneDataNew")
    return
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  local MaxStoneNum = logic_emote.MileStoneMaxNum
  local Datas = {}
  for Type, _Data in pairs(_MileStoneDataNew) do
    for _, EmoteID in pairs(_Data.expression_list) do
      table.insert(Datas, EmoteID)
      break
    end
    for i = 1, MaxStoneNum do
      table.insert(Datas, _Data.stone_data[i] or 0)
    end
  end
  local LogStr = "CommerAvatarDataUtil:_FillMileStoneList Datas: "
  for _, v in pairs(Datas) do
    LogStr = LogStr .. tostring(v) .. " "
  end
  print(bWriteLog and LogStr)
  uPlayerController.CommerFeature.MileStoneData = Datas
end
function CommerAvatarDataUtil:ContructMileStoneData(MileStoneData)
  log_tree("CommerAvatarDataUtil:ContructMileStoneData", MileStoneData)
  if not MileStoneData or MileStoneData:Num() == 0 then
    return {}
  end
  local reuslt = {}
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  local OneGroupLength = logic_emote.MileStoneMaxNum + 1
  local ListNum = MileStoneData:Num()
  if ListNum % OneGroupLength ~= 0 then
    log_error("CommerAvatarDataUtil:ContructMileStoneData ListNum % OneGroupLength ~= 0" .. tostring(ListNum) .. "" .. tostring(OneGroupLength))
    return {}
  end
  local GroupNum = ListNum / OneGroupLength
  for i = 0, GroupNum - 1 do
    local EmoteID = MileStoneData:Get(i * OneGroupLength)
    reuslt[EmoteID] = {}
    for j = 1, OneGroupLength - 1 do
      table.insert(reuslt[EmoteID], MileStoneData:Get(i * OneGroupLength + j))
    end
  end
  local LogStr = "CommerAvatarDataUtil:ContructMileStoneData reuslt: "
  for _, v in pairs(reuslt) do
    LogStr = LogStr .. tostring(v) .. " "
  end
  print(bWriteLog and LogStr)
  return reuslt
end
function CommerAvatarDataUtil:_UpdateDragonSource(PlayerInfo, uPlayerController)
  local DragonSuit = {}
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local DragonSuitFeature = self:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.DragonSuitState)
  if DragonSuitFeature and DragonSuitFeature.has_item_list then
    for _, v in pairs(DragonSuitFeature.has_item_list) do
      DragonSuit[v] = true
    end
  end
  local InheritData = self:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.InheritData)
  if InheritData and InheritData.dragon_ball_item_info and InheritData.dragon_ball_item_info.has_item_list then
    for _, v in pairs(InheritData.dragon_ball_item_info.has_item_list) do
      DragonSuit[v] = true
    end
  end
  if PlayerInfo.wear_ext then
    for _, v in pairs(PlayerInfo.wear_ext) do
      if DragonSuit[v[ENUM_AVATAR_DATA_TYPE.ItemID]] then
        v[ENUM_AVATAR_DATA_TYPE.ColorID] = v[ENUM_AVATAR_DATA_TYPE.Source] or 0
      end
    end
  end
  if PlayerInfo.all_wear_ext then
    for i = 1, 4 do
      local wear = PlayerInfo.all_wear_ext[i]
      if wear ~= nil then
        for _, v in pairs(wear) do
          if DragonSuit[v[ENUM_AVATAR_DATA_TYPE.ItemID]] then
            v[ENUM_AVATAR_DATA_TYPE.ColorID] = v[ENUM_AVATAR_DATA_TYPE.Source] or 0
          end
        end
      end
    end
    local wear = PlayerInfo.all_wear_ext[6]
    if wear ~= nil then
      for _, v in pairs(wear) do
        if DragonSuit[v[ENUM_AVATAR_DATA_TYPE.ItemID]] then
          v[ENUM_AVATAR_DATA_TYPE.ColorID] = v[ENUM_AVATAR_DATA_TYPE.Source] or 0
        end
      end
    end
  end
end
function CommerAvatarDataUtil:_FillDragonList(PlayerInfo, uPlayerController)
  print(bWriteLog and "CommerAvatarDataUtil:_FillDragonList ")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local DragonSuitFeature = self:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.DragonSuitState)
  if DragonSuitFeature and next(DragonSuitFeature) then
    uPlayerController.CommerFeature.DragonSuitList = DragonSuitFeature.has_item_list or {}
    uPlayerController.CommerFeature.bLock = DragonSuitFeature.unlock_state or false
  end
  local InheritData = self:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.InheritData)
  if InheritData and InheritData.dragon_ball_item_info then
    uPlayerController.CommerFeature.InheritDragonSuitList = InheritData.dragon_ball_item_info.has_item_list or {}
    uPlayerController.CommerFeature.bInheritDragonSuitLock = InheritData.dragon_ball_item_info.unlock_state or false
  end
end
function CommerAvatarDataUtil:_FillOtherItemList(PlayerInfo, itemList)
  print(bWriteLog and "CommerAvatarDataUtil:_FillOtherItemList ")
  if not PlayerInfo.is_robot and PlayerInfo.expression then
    for i, v in pairs(PlayerInfo.expression) do
      local item = {ItemTableID = v, Count = 1}
      table.insert(itemList, item)
    end
  end
  if PlayerInfo.fireworks_info then
    for i, v in pairs(PlayerInfo.fireworks_info) do
      local item = {
        ItemTableID = v.item_id,
        Count = v.cur_count
      }
      table.insert(itemList, item)
    end
  end
  if IsEditor and PlayerInfo.ingame_use_item_info then
    for i, v in pairs(PlayerInfo.ingame_use_item_info) do
      local item = {
        ItemTableID = i,
        Count = v.count
      }
      table.insert(itemList, item)
    end
  end
end
function CommerAvatarDataUtil:_FillUpgradeVehicleMusicFeature(uPlayerController)
  print(bWriteLog and "CommerAvatarDataUtil:_FillUpgradeVehicleMusicFeature")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local UpgradeVehicleData = self:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.UpgradeVehicleData)
  if not UpgradeVehicleData or not next(UpgradeVehicleData) then
    print(bWriteLog and "CommerAvatarDataUtil:_FillUpgradeVehicleMusicFeature UpgradeVehicleData is nil")
    return
  end
  local bUpgradeCarUseMusicList = false
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  local musicFeatureId = VehiclePlateLicenseUtil.GetUpgradeVehicleMusicFeatureId()
  for _, itemId in ipairs(UpgradeVehicleData) do
    if itemId == musicFeatureId then
      bUpgradeCarUseMusicList = true
      print(bWriteLog and "CommerAvatarDataUtil:_FillUpgradeVehicleMusicFeature bUpgradeCarUseMusicList = true")
      break
    end
  end
  uPlayerController.CommerFeature.end
return CommerAvatarDataUtil