BattleResultVehicleUI = BattleResultVehicleUI or {battle_id = "", isVehicleUIBP_active = false}
function bp_battleresult_vehicle_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_battleresult_vehicle, {
    {
      Path = "/Game/Mod/VehicleWar/BluePrints/UI/MainPanel/BattleResultVehicle_UIBP.BattleResultVehicle_UIBP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    }
  }, {"Fighting"}, false, false, true)
end
function BattleResultVehicleUI.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "bp_battleresult_vehicle_OnModeSwitched:" .. tostring(nextState))
  if nextState == GameStatus.Fighting and false then
    log(bWriteLog and "BattleResultVehicleUI.OnTestResultData")
    BattleResultVehicleUI.OnTestResultData()
  end
end
BP_STRUCT_Vehicle_GOLD_DETAIL = {up_limit = 0}
BP_STRUCT_BattleResultVehicleInfo = {
  add_exp = 0,
  add_gold = 0,
  timestamp = 0,
  duration = 0,
  Rank = 0,
  TeamId = 0,
  Score = 0,
  KillNum = 0,
  BeKillNum = 0,
  CauseDamage = 0,
  VehicleShapeType = 0,
  VehicleID = 0,
  GemStoneCount = 0,
  uid = "",
  PlayerName = "",
  get_gold_today = 0,
  BP_STRUCT_Vehicle_GOLD_DETAIL = _G.BP_STRUCT_Vehicle_GOLD_DETAIL,
  char_id = 0,
  char_add_exp = 0,
  char_daily_exp = 0,
  char_daily_exp_max = 0,
  mvp1 = "",
  mvp2 = "",
  BP_ARRAY_BattleResultVehiclePlayerList = {
    tmp_UseExist_BP_STRUCT_BattleResultVehiclePlayerInfo = {}
  },
  BP_ARRAY_BattleResultVehiclePlayerList_Sorted = {
    tmp_UseExist_BP_STRUCT_BattleResultVehiclePlayerInfo = {}
  },
  BP_ARRAY_BattleResultVehiclePlayerListCampFirst = {
    tmp_UseExist_BP_STRUCT_BattleResultVehiclePlayerInfo = {}
  },
  BP_ARRAY_BattleResultVehiclePlayerListCampSecond = {
    tmp_UseExist_BP_STRUCT_BattleResultVehiclePlayerInfo = {}
  }
}
BP_STRUCT_BattleResultVehiclePlayerInfo = {
  UID = "",
  PlayerName = "",
  Score = 0,
  TeamId = 0,
  CampId = 0,
  KillNum = 0,
  BeKillNum = 0,
  CauseDamage = 0,
  GemStoneCount = 0,
  CampGemStoneNum = 0,
  CampKillNum = 0,
  AssistKillNum = 0,
  Rank = 0,
  Rank2 = 0,
  nation = "",
  rela_sex = 0,
  pic_url = "",
  cur_avatar_box_id = 0
}
BP_STRUCT_Vehicle_AvatarEquipInfo = {
  ItemID = 401999,
  ColorID = 0,
  PatternID = 0
}
BP_ARRAY_Vehicle_AvatarEquipList = {
  BP_STRUCT_Vehicle_AvatarEquipInfo = _G.BP_STRUCT_Vehicle_AvatarEquipInfo
}
BP_STRUCT_Vehicle_AvatarRoleInfo = {
  playername = "",
  gid = "",
  uid = "",
  sex = 1,
  headId = 401999,
  weaponId = 0,
  weaponSkinId = 0,
  weaponSkinDIYPlanId = 0,
  resultAvatarPose = 0,
  PetId = 0,
  PetLevel = 0,
  BP_ARRAY_Vehicle_AvatarEquipList = _G.BP_ARRAY_Vehicle_AvatarEquipList
}
BP_ARRAY_Vehicle_RoleInfo_Array = {
  BP_STRUCT_Vehicle_AvatarRoleInfo = _G.BP_STRUCT_Vehicle_AvatarRoleInfo
}
BP_ComplaintPlayerIndex = -1
BP_ComplaintPlayerName = ""
BP_IsWin = false
BP_OurGemStone = 0
BP_EnemyGemStone = 0
BP_OurKillNum = 0
BP_EnemyKillNum = 0
BP_IsGemStoneMode = true
BP_SendAddFriendUID = ""
BP_VehicleAvatarID = 0
BP_HaveAdvanceAvatar = false
BP_STRUCT_Vehicle_Advance_Avatar = {
  ItemId = 0,
  ColorId = 0,
  PatternId = 0,
  ParticleId = 0
}
BP_ARRAY_Vehicle_Advance_Avatar_Array = {
  BP_STRUCT_Vehicle_Advance_Avatar = _G.BP_STRUCT_Vehicle_Advance_Avatar
}
local VehicleAvatarMap = {
  [10001] = 903,
  [10002] = 910,
  [10003] = 907
}
function BattleResultVehicleUI.OnBattleResult(result)
  BattleResultVehicleUI.isVehicleUIBP_active = true
  BP_STRUCT_BattleResultVehicleInfo.uid = result.my_result.UID
  BP_STRUCT_BattleResultVehicleInfo.add_exp = result.my_result.add_exp
  BP_STRUCT_BattleResultVehicleInfo.add_gold = result.my_result.add_gold
  BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerList = result.PlayerList
  BP_STRUCT_BattleResultVehicleInfo.PlayerName = result.my_result.PlayerName
  BP_STRUCT_BattleResultVehicleInfo.get_gold_today = result.my_result.get_gold_today or 0
  BP_STRUCT_BattleResultVehicleInfo.char_id = result.my_result.char_id or 0
  BP_STRUCT_BattleResultVehicleInfo.char_add_exp = result.my_result.char_add_exp or 0
  BP_STRUCT_BattleResultVehicleInfo.char_daily_exp = result.my_result.char_daily_exp or 0
  BP_STRUCT_BattleResultVehicleInfo.char_daily_exp_max = result.my_result.char_daily_exp_max or 0
  BP_STRUCT_BattleResultVehicleInfo.BP_STRUCT_Vehicle_GOLD_DETAIL = {}
  BP_STRUCT_BattleResultVehicleInfo.BP_STRUCT_Vehicle_GOLD_DETAIL.up_limit = result.my_result.gold_detail.up_limit or 0
  BP_STRUCT_BattleResultVehicleInfo.mvp1 = result.my_result.mvp1
  BP_STRUCT_BattleResultVehicleInfo.mvp2 = result.my_result.mvp2
  BP_STRUCT_BattleResultVehicleInfo.VehicleID = result.my_result.VehicleID
  BP_STRUCT_BattleResultVehicleInfo.VehicleShapeType = result.my_result.VehicleShapeType
  BP_STRUCT_BattleResultVehicleInfo.TeamId = result.my_result.TeamId
  BP_STRUCT_BattleResultVehicleInfo.Rank = result.my_result.Rank
  if result.my_result.vehicle_mode_type == 1 then
    BP_IsGemStoneMode = false
  else
    BP_IsGemStoneMode = true
  end
  local logic_friend_apply_battle = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply_battle)
  logic_friend_apply_battle:ResetResultAddFriendReq(result.battle_id, result.PlayerList)
  for idx, val in ipairs(BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerList) do
    val.rela_sex = result.PlayerList[idx].gamegender + 1
  end
  local inputList = {}
  for k, v in pairs(BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerList) do
    table.insert(inputList, v)
  end
  table.sort(inputList, function(a, b)
    if a.CampId ~= b.CampId then
      return tonumber(a.CampId) < tonumber(b.CampId)
    elseif a.TeamId ~= b.TeamId then
      return tonumber(a.TeamId) < tonumber(b.TeamId)
    else
      return tonumber(a.KillNum) > tonumber(b.KillNum)
    end
  end)
  BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerList_Sorted = inputList
  for k, v in pairs(BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerList_Sorted) do
    v.Rank2 = v.Rank
  end
  local firstCampList = {}
  local secondCampList = {}
  local OurCampId = 0
  local OurTeamId = 0
  for k, v in pairs(BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerList_Sorted) do
    if v.UID == BP_STRUCT_BattleResultVehicleInfo.uid then
      OurCampId = v.CampId
      OurTeamId = v.TeamId
    end
  end
  for k, v in pairs(BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerList_Sorted) do
    if v.CampId == OurCampId then
      table.insert(firstCampList, v)
      BP_OurGemStone = v.CampGemStoneNum
      BP_OurKillNum = v.CampKillNum
    else
      table.insert(secondCampList, v)
      BP_EnemyGemStone = v.CampGemStoneNum
      BP_EnemyKillNum = v.CampKillNum
    end
  end
  if result.WinCampID == OurCampId or result.WinCampID == 0 then
    BP_IsWin = true
  else
    BP_IsWin = false
  end
  BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerListCampFirst = firstCampList
  BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerListCampSecond = secondCampList
  log_tree("logg BP_ARRAY_BattleResultVehiclePlayerListCampFirst", BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerListCampFirst)
  log_tree("logg BP_ARRAY_BattleResultVehiclePlayerListCampSecond", BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerListCampSecond)
  BP_ARRAY_Vehicle_RoleInfo_Array = {}
  for k, v in pairs(BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerList_Sorted) do
    local playerinfo = v
    if playerinfo ~= nil and playerinfo.TeamId == OurTeamId then
      local rolewear = {}
      local wear_ext = playerinfo.wear_ext or {}
      for k, v in pairs(wear_ext) do
        if k ~= 11 and k ~= 13 and k ~= 14 and k ~= 15 then
          table.insert(rolewear, AvatarData.ConvertToAvatarCustom(v))
        end
      end
      local pet_id = 0
      local pet_level = 0
      if playerinfo.pet_id ~= nil and playerinfo.pet_id ~= -1 then
        pet_id = playerinfo.pet_id
      end
      _resultAvatarPose = 0
      if playerinfo.PlayerName == BP_STRUCT_BattleResultVehicleInfo.PlayerName then
        _resultAvatarPose = BattleResult.resultAvatarPoseNormal
      else
        _resultAvatarPose = BattleResult.resultAvatarPoseAim
      end
      table.insert(BP_ARRAY_Vehicle_RoleInfo_Array, {
        playername = playerinfo.PlayerName,
        uid = playerinfo.UID,
        sex = playerinfo.rela_sex,
        headId = wear_ext[9] and wear_ext[9][1] or 0,
        weaponId = wear_ext[13] and wear_ext[13][1] or 0,
        weaponSkinId = wear_ext[14] and wear_ext[14][1] or 0,
        weaponSkinDIYPlanId = wear_ext[14] and wear_ext[14][4] or 0,
        weaponPendantID = wear_ext[14] and wear_ext[14][6] and wear_ext[14][6][1] or 0,
        resultAvatarPose = _resultAvatarPose,
        PetId = pet_id,
        PetLevel = pet_level,
        BP_ARRAY_Vehicle_AvatarEquipList = rolewear
      })
    end
  end
  log_tree("BP_ARRAY_Vehicle_RoleInfo_Array", BP_ARRAY_Vehicle_RoleInfo_Array)
  local tempVehicleAvatarList = result.my_result.vehicle_avatar_list or {}
  local tempVehicleAdvanceAvatarList = result.my_result.vehicle_advance_avatar_list or {}
  for k, v in pairs(tempVehicleAvatarList) do
    if VehicleAvatarMap[result.my_result.VehicleID] ~= nil and VehicleAvatarMap[result.my_result.VehicleID] == k then
      BP_VehicleAvatarID = v
    end
  end
  for k, v in pairs(tempVehicleAdvanceAvatarList) do
    if BP_VehicleAvatarID == k then
      local advanceAvatarList = {}
      for k2, v2 in pairs(v) do
        local advanceAvatarCell = {}
        for k3, v3 in pairs(v2) do
          if k3 == 1 then
            BP_HaveAdvanceAvatar = true
            advanceAvatarCell.ItemId = v3
          elseif k3 == 2 then
            BP_HaveAdvanceAvatar = true
            advanceAvatarCell.ColorId = v3
          elseif k3 == 3 then
            BP_HaveAdvanceAvatar = true
            advanceAvatarCell.PatternId = v3
          elseif k3 == 4 then
            BP_HaveAdvanceAvatar = true
            advanceAvatarCell.ParticleId = v3
          end
        end
        table.insert(advanceAvatarList, advanceAvatarCell)
      end
      BP_ARRAY_Vehicle_Advance_Avatar_Array = advanceAvatarList
    end
  end
  log_tree("BP_VehicleAvatarID", BP_VehicleAvatarID)
  log_tree("BP_ARRAY_Vehicle_Advance_Avatar_Array", BP_ARRAY_Vehicle_Advance_Avatar_Array)
  log_tree("BattleResultVehicleUI.OnBattleResult(result) result", result)
  log_tree("BP_STRUCT_BattleResultVehicleInfo", BP_STRUCT_BattleResultVehicleInfo)
  LuaClassObj.HandleUIMessage(bp_battleresult, "HideSpectatingUI")
  Client.OnBattleResult(GameFrontendHUD, BP_STRUCT_BattleResultVehicleInfo)
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  if LoadingSystem.IsShowing() then
    log(bWriteLog and "Dont show vehicle result when loading!")
  else
    log(bWriteLog and "LuaClassObj.HandleDynamicCreation(bp_battleresult_vehicle);")
    LuaClassObj.HandleDynamicCreation(bp_battleresult_vehicle)
    LuaClassObj.HandleUIMessage(bp_battleresult_vehicle, "ShowWidget_VehicleMode")
  end
  if LuaClassObj.GetGameStatus(bp_global) ~= GameStatus.Fighting then
    BattleResult.IgnoreDSError = false
  else
    BattleResult.IgnoreDSError = true
    NetUtil.StopCheckDSActive()
  end
end
function BattleResultVehicleUI:GetIsUIBP_Active()
  return BattleResultVehicleUI.isVehicleUIBP_active
end
function Event_Vehicle_BackToLobby()
  log(bWriteLog and "Event_Vehicle_BackToLobby")
  BattleResult.IgnoreDSError = true
  BattleResultVehicleUI.isVehicleUIBP_active = false
end
function BattleResultVehicleUI.EnableTickSwitch()
  LuaClassObj.HandleDynamicCreation(bp_battleresult_vehicle)
  LuaClassObj.HandleUIMessage(bp_battleresult_vehicle, "EnableResultsTick")
end
function Event_SendComplaint_Push()
  BP_ComplaintPlayerIndex = BP_ComplaintPlayerIndex + 1
  if BP_ComplaintPlayerIndex > 0 then
  end
end
function BattleResultVehicleUI.GetVehicleComplaintData()
  local ComplaintData = {}
  for idx, val in pairs(BP_STRUCT_BattleResultVehicleInfo.BP_ARRAY_BattleResultVehiclePlayerList) do
    if val.PlayerName ~= BP_STRUCT_BattleResultVehicleInfo.PlayerName then
      local playerselectinfo = {}
      playerselectinfo.name = val.PlayerName
      playerselectinfo.UID = val.UID
      table.insert(ComplaintData, playerselectinfo)
    end
  end
  log_tree("GetVehicleComplaintData", ComplaintData)
  return ComplaintData
end
function BattleResultVehicleUI.OnTestResultData()
  local result = {
    WinCampID = 0,
    my_result = {
      UID = 510000323,
      PlayerName = "player0",
      pic_url = "10001",
      TeamId = 0,
      Rank = 1,
      distance = 1000,
      vehicle_mode_type = 1,
      add_exp = 200,
      add_gold = 300,
      get_gold_today = 50,
      char_id = 15000001,
      char_add_exp = 60,
      char_daily_exp = 50,
      char_daily_exp_max = 100,
      VehicleShapeType = 1,
      VehicleID = 0,
      mvp1 = "510000323",
      mvp2 = "510100324",
      gold_detail = {up_limit = 100},
      vehicle_avatar_list = {
        [903] = 1903046,
        [910] = 1910002,
        [907] = 1907014
      },
      vehicle_advance_avatar_list = {
        [1903046] = {
          [1] = {
            [1] = 30101000,
            [2] = 21
          },
          [2] = {
            [1] = 30102000,
            [2] = 21
          },
          [3] = {
            [1] = 30103004
          },
          [4] = {
            [1] = 30104001,
            [2] = 16
          },
          [5] = {
            [1] = 30105001,
            [2] = 21
          },
          [6] = {
            [1] = 30106004,
            [2] = 14
          },
          [8] = {
            [1] = 30108010
          }
        }
      }
    },
    PlayerList = {
      {
        UID = 510000323,
        PlayerName = "player0",
        pic_url = "10001",
        TeamId = 0,
        Rank = 1,
        KillNum = 2,
        BeKillNum = 3,
        CauseDamage = 60.4,
        CampId = 1,
        GemStoneCount = 5,
        CampGemStoneNum = 50,
        CampKillNum = 20,
        AssistKillNum = 5,
        nation = "CA",
        wear_ext = {
          [3] = {
            15000101,
            0,
            0
          },
          [9] = {
            401987,
            0,
            0
          },
          [10] = {
            406004,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          },
          [13] = {
            101003,
            0,
            0
          },
          [14] = {
            1101001042,
            0,
            0
          }
        },
        rela_sex = 1,
        gamegender = 0,
        AddFriendBtnState = 1,
        cur_avatar_box_id = 2001001
      },
      {
        UID = 520100326,
        PlayerName = "player1-5",
        pic_url = "10001",
        TeamId = 1,
        Rank = 2,
        KillNum = 12,
        BeKillNum = 13,
        CauseDamage = 160.4,
        CampId = 1,
        GemStoneCount = 15,
        CampGemStoneNum = 50,
        CampKillNum = 20,
        AssistKillNum = 5,
        nation = "CA",
        wear_ext = {
          [9] = {
            401999,
            0,
            0
          },
          [10] = {
            40601001,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          },
          [13] = {
            101004,
            0,
            0
          },
          [14] = {
            1101001042,
            0,
            0
          }
        },
        rela_sex = 2,
        gamegender = 0,
        AddFriendBtnState = 1,
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000326,
        PlayerName = "player2",
        pic_url = "10001",
        TeamId = 2,
        Rank = 2,
        KillNum = 12,
        BeKillNum = 13,
        CauseDamage = 160.4,
        CampId = 1,
        GemStoneCount = 15,
        CampGemStoneNum = 50,
        CampKillNum = 20,
        AssistKillNum = 5,
        nation = "CA",
        wear_ext = {
          [9] = {
            401999,
            0,
            0
          },
          [10] = {
            40601001,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          },
          [13] = {
            101004,
            0,
            0
          },
          [14] = {
            1101001042,
            0,
            0
          }
        },
        rela_sex = 2,
        gamegender = 0,
        AddFriendBtnState = 1,
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000327,
        PlayerName = "player4",
        pic_url = "10001",
        isfinished = false,
        finishedTime = 1000,
        TeamId = 3,
        Rank = 3,
        KillNum = 2,
        BeKillNum = 3,
        CauseDamage = 60.4,
        CampId = 2,
        GemStoneCount = 0,
        CampGemStoneNum = 40,
        CampKillNum = 10,
        AssistKillNum = 5,
        nation = "CA",
        wear_ext = {
          [9] = {
            401999,
            0,
            0
          },
          [10] = {
            40601001,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          },
          [13] = {
            101004,
            0,
            0
          },
          [14] = {
            1101001042,
            0,
            0
          }
        },
        rela_sex = 2,
        gamegender = 0,
        AddFriendBtnState = 1,
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510020324,
        PlayerName = "player5",
        pic_url = "10001",
        TeamId = 3,
        Rank = 3,
        KillNum = 2,
        BeKillNum = 3,
        CauseDamage = 60.4,
        CampId = 2,
        GemStoneCount = 0,
        CampGemStoneNum = 40,
        CampKillNum = 10,
        AssistKillNum = 5,
        nation = "CA",
        wear_ext = {
          [1] = {1400556},
          [2] = {1402050},
          [3] = {403071},
          [4] = {1400121},
          [5] = {405018},
          [9] = {
            401993,
            0,
            0
          },
          [10] = {
            40601001,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          },
          [13] = {
            101003,
            0,
            0
          },
          [14] = {1101007003}
        },
        rela_sex = 2,
        gamegender = 1,
        AddFriendBtnState = 1,
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510100324,
        PlayerName = "player6",
        pic_url = "10001",
        TeamId = 4,
        Rank = 3,
        KillNum = 2,
        BeKillNum = 3,
        CauseDamage = 60.4,
        CampId = 2,
        GemStoneCount = 0,
        CampGemStoneNum = 40,
        CampKillNum = 10,
        AssistKillNum = 5,
        nation = "CA",
        wear_ext = {
          [3] = {403193},
          [4] = {404072},
          [9] = {
            401987,
            0,
            0
          },
          [10] = {
            406004,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          },
          [13] = {
            101003,
            0,
            0
          },
          [1] = {1406001}
        },
        rela_sex = 1,
        gamegender = 0,
        AddFriendBtnState = 1,
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510101324,
        PlayerName = "player7",
        pic_url = "10001",
        TeamId = 4,
        Rank = 3,
        KillNum = 2,
        BeKillNum = 3,
        CauseDamage = 60.4,
        CampId = 2,
        GemStoneCount = 0,
        CampGemStoneNum = 40,
        CampKillNum = 10,
        AssistKillNum = 5,
        nation = "CA",
        wear_ext = {
          [3] = {403193},
          [4] = {404072},
          [9] = {
            401987,
            0,
            0
          },
          [10] = {
            406004,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          },
          [13] = {
            101003,
            0,
            0
          },
          [1] = {1406001}
        },
        rela_sex = 1,
        gamegender = 0,
        AddFriendBtnState = 1,
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510110324,
        PlayerName = "player8",
        pic_url = "10001",
        TeamId = 5,
        Rank = 3,
        KillNum = 2,
        BeKillNum = 3,
        CauseDamage = 60.4,
        CampId = 2,
        GemStoneCount = 0,
        CampGemStoneNum = 40,
        CampKillNum = 10,
        AssistKillNum = 5,
        nation = "CA",
        wear_ext = {
          [3] = {403193},
          [4] = {404072},
          [9] = {
            401987,
            0,
            0
          },
          [10] = {
            406004,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          },
          [13] = {
            101003,
            0,
            0
          },
          [1] = {1406001}
        },
        rela_sex = 1,
        gamegender = 0,
        AddFriendBtnState = 1,
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510121324,
        PlayerName = "player9",
        pic_url = "10001",
        TeamId = 5,
        Rank = 3,
        KillNum = 2,
        BeKillNum = 3,
        CauseDamage = 60.4,
        CampId = 2,
        GemStoneCount = 0,
        CampGemStoneNum = 40,
        CampKillNum = 10,
        AssistKillNum = 5,
        nation = "CA",
        wear_ext = {
          [3] = {403193},
          [4] = {404072},
          [9] = {
            401987,
            0,
            0
          },
          [10] = {
            406004,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          },
          [13] = {
            101003,
            0,
            0
          },
          [1] = {1406001}
        },
        rela_sex = 1,
        gamegender = 0,
        AddFriendBtnState = 1,
        cur_avatar_box_id = 2001001
      }
    }
  }
  BattleResultVehicleUI.OnBattleResult(result)
end