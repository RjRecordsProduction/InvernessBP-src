BattleResultInfectionUI = BattleResultInfectionUI or {battle_id = "", isInfectionUIBP_active = false}
function bp_battleresult_infection_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_battleresult_infection, {
    {
      Path = "/Game/Mod/Infection/BluePrints/ControlInput/InfectionMode/BattleResultInfection_UIBP.BattleResultInfection_UIBP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    }
  }, {"Fighting"}, false, false, true)
end
function BattleResultInfectionUI.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "bp_battleresult_infection_OnModeSwitched:" .. tostring(nextState))
  if nextState == GameStatus.Fighting and false then
    log(bWriteLog and "BattleResultInfectionUI.OnTestResultData")
    BattleResultInfectionUI.OnTestResultData()
  end
end
BP_STRUCT_Infection_GOLD_DETAIL = {up_limit = 0}
BP_STRUCT_BattleResultInfectionInfo = {
  add_exp = 0,
  add_gold = 0,
  timestamp = 0,
  duration = 0,
  uid = "",
  PlayerName = "",
  get_gold_today = 0,
  BP_STRUCT_Infection_GOLD_DETAIL = _G.BP_STRUCT_Infection_GOLD_DETAIL,
  char_id = 0,
  char_add_exp = 0,
  char_daily_exp = 0,
  char_daily_exp_max = 0,
  BP_ARRAY_BattleResultInfectionPlayerList = {
    tmp_UseExist_BP_STRUCT_BattleResultInfectionPlayerInfo = {}
  },
  BP_ARRAY_BattleResultInfectionPlayerList_Sorted = {
    tmp_UseExist_BP_STRUCT_BattleResultInfectionPlayerInfo = {}
  }
}
BP_STRUCT_BattleResultInfectionPlayerInfo = {
  UID = "",
  PlayerName = "",
  PlayerScore = 0,
  Rank = 0,
  DamageAmount = 0,
  Kills = 0,
  Infections = 0,
  rela_sex = 0,
  pic_url = "",
  cur_avatar_box_id = 0
}
BP_STRUCT_Infection_AvatarEquipInfo = {
  ItemID = 401999,
  ColorID = 0,
  PatternID = 0
}
BP_ARRAY_Infection_AvatarEquipList = {
  BP_STRUCT_Infection_AvatarEquipInfo = _G.BP_STRUCT_Infection_AvatarEquipInfo
}
BP_STRUCT_Infection_AvatarRoleInfo = {
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
  BP_ARRAY_Infection_AvatarEquipList = _G.BP_ARRAY_Infection_AvatarEquipList
}
BP_ARRAY_Infection_RoleInfo_Array = {
  BP_STRUCT_Infection_AvatarRoleInfo = _G.BP_STRUCT_Infection_AvatarRoleInfo
}
BP_RecordAddFriendIndex = -1
BP_ComplaintPlayerIndex = -1
BP_ComplaintPlayerName = ""
function BattleResultInfectionUI.OnBattleResult(result)
  BattleResultInfectionUI.isInfectionUIBP_active = true
  BP_STRUCT_BattleResultInfectionInfo.uid = result.my_result.UID
  BP_STRUCT_BattleResultInfectionInfo.add_exp = result.my_result.add_exp
  BP_STRUCT_BattleResultInfectionInfo.add_gold = result.my_result.add_gold
  BP_STRUCT_BattleResultInfectionInfo.BP_ARRAY_BattleResultInfectionPlayerList = result.PlayerList
  BP_STRUCT_BattleResultInfectionInfo.PlayerName = result.my_result.PlayerName
  BP_STRUCT_BattleResultInfectionInfo.get_gold_today = result.my_result.get_gold_today or 0
  BP_STRUCT_BattleResultInfectionInfo.char_id = result.my_result.char_id or 0
  BP_STRUCT_BattleResultInfectionInfo.char_add_exp = result.my_result.char_add_exp or 0
  BP_STRUCT_BattleResultInfectionInfo.char_daily_exp = result.my_result.char_daily_exp or 0
  BP_STRUCT_BattleResultInfectionInfo.char_daily_exp_max = result.my_result.char_daily_exp_max or 0
  BP_STRUCT_BattleResultInfectionInfo.BP_STRUCT_Infection_GOLD_DETAIL = {}
  BP_STRUCT_BattleResultInfectionInfo.BP_STRUCT_Infection_GOLD_DETAIL.up_limit = result.my_result.gold_detail.up_limit or 0
  local logic_friend_apply_battle = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply_battle)
  logic_friend_apply_battle:ResetResultAddFriendReq(0, result.PlayerList)
  for idx, val in ipairs(BP_STRUCT_BattleResultInfectionInfo.BP_ARRAY_BattleResultInfectionPlayerList) do
    val.rela_sex = result.PlayerList[idx].gamegender + 1
  end
  local inputList = {}
  for k, v in pairs(BP_STRUCT_BattleResultInfectionInfo.BP_ARRAY_BattleResultInfectionPlayerList) do
    table.insert(inputList, v)
  end
  table.sort(inputList, function(a, b)
    return tonumber(a.Rank) < tonumber(b.Rank)
  end)
  BP_STRUCT_BattleResultInfectionInfo.BP_ARRAY_BattleResultInfectionPlayerList_Sorted = inputList
  BP_ARRAY_Infection_RoleInfo_Array = {}
  for i = 1, 3 do
    local playerinfo = BP_STRUCT_BattleResultInfectionInfo.BP_ARRAY_BattleResultInfectionPlayerList_Sorted[i]
    if playerinfo ~= nil then
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
      if i == 1 then
        _resultAvatarPose = BattleResult.resultAvatarPoseNormal
      else
        _resultAvatarPose = BattleResult.resultAvatarPoseAim
      end
      table.insert(BP_ARRAY_Infection_RoleInfo_Array, {
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
        BP_ARRAY_Infection_AvatarEquipList = rolewear
      })
    end
  end
  log_tree("BP_ARRAY_Infection_RoleInfo_Array", BP_ARRAY_Infection_RoleInfo_Array)
  log_tree("BattleResultInfectionUI.OnBattleResult(result) result", result)
  WatchGameUI:HideSpectatingUI()
  Client.OnBattleResult(GameFrontendHUD, BP_STRUCT_BattleResultInfectionInfo)
  LuaClassObj.HandleDynamicCreation(bp_battleresult_infection)
  LuaClassObj.HandleUIMessage(bp_battleresult_infection, "Show")
  LuaClassObj.HandleUIMessage(bp_battleresult_infection, "UpdateData")
  if LuaClassObj.GetGameStatus(bp_global) ~= GameStatus.Fighting then
    BattleResult.IgnoreDSError = false
  else
    BattleResult.IgnoreDSError = true
    NetUtil.StopCheckDSActive()
  end
end
function Event_SendComplaint_Push()
  BP_ComplaintPlayerIndex = BP_ComplaintPlayerIndex + 1
  if BP_ComplaintPlayerIndex > 0 then
  end
end
function BattleResultInfectionUI.GetInfectionComplaintData()
  local ComplaintData = {}
  for idx, val in pairs(BP_STRUCT_BattleResultInfectionInfo.BP_ARRAY_BattleResultInfectionPlayerList) do
    if val.PlayerName ~= BP_STRUCT_BattleResultInfectionInfo.PlayerName then
      local playerselectinfo = {}
      playerselectinfo.name = val.PlayerName
      playerselectinfo.UID = val.UID
      table.insert(ComplaintData, playerselectinfo)
    end
  end
  log_tree("GetInfectionComplaintData", ComplaintData)
  return ComplaintData
end
function BattleResultInfectionUI:GetIsUIBP_Active()
  return BattleResultInfectionUI.isInfectionUIBP_active
end
function Event_Infection_BackToLobby()
  log(bWriteLog and "Event_Infection_BackToLobby")
  BattleResult.IgnoreDSError = true
  BattleResultInfectionUI.isInfectionUIBP_active = false
end
function BattleResultInfectionUI.EnableTickSwitch()
  LuaClassObj.HandleDynamicCreation(bp_battleresult_infection)
  LuaClassObj.HandleUIMessage(bp_battleresult_infection, "EnableResultsTick")
end
function BattleResultInfectionUI.OnTestResultData()
  local result = {
    my_result = {
      UID = 510000324,
      PlayerName = "player1",
      pic_url = "10001",
      add_exp = 200,
      add_gold = 300,
      get_gold_today = 50,
      char_id = 15000001,
      char_add_exp = 50,
      char_daily_exp = 50,
      char_daily_exp_max = 100,
      gold_detail = {up_limit = 100}
    },
    PlayerList = {
      {
        UID = 510000324,
        PlayerName = "player1",
        Rank = 10,
        Kills = 1,
        PlayerScore = 400,
        DamageAmount = 1000,
        Infections = 3,
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
        pic_url = "10001",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000325,
        PlayerName = "player2",
        Rank = 9,
        Kills = 1,
        PlayerScore = 100,
        DamageAmount = 1000,
        Infections = 1,
        wear_ext = {
          [9] = {
            401987,
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
        rela_sex = 1,
        gamegender = 0,
        AddFriendBtnState = 1,
        pic_url = "",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000326,
        PlayerName = "player3",
        Rank = 8,
        Kills = 1,
        PlayerScore = 200,
        DamageAmount = 1000,
        Infections = 1,
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
        rela_sex = 1,
        gamegender = 0,
        AddFriendBtnState = 1,
        pic_url = "",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000327,
        PlayerName = "player4",
        Rank = 7,
        Kills = 1,
        PlayerScore = 300,
        DamageAmount = 1000,
        Infections = 1,
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
        pic_url = "",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000328,
        PlayerName = "player5",
        Rank = 6,
        Kills = 1,
        PlayerScore = 500,
        DamageAmount = 1000,
        Infections = 1,
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
        pic_url = "",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000329,
        PlayerName = "player6",
        Rank = 2,
        Kills = 1,
        PlayerScore = 600,
        DamageAmount = 1000,
        Infections = 1,
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
        pic_url = "10001",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000330,
        PlayerName = "player7",
        Rank = 1,
        Kills = 1,
        PlayerScore = 700,
        DamageAmount = 1000,
        Infections = 1,
        wear_ext = {
          [3] = {
            15000201,
            0,
            0
          },
          [9] = {
            401986,
            0,
            0
          },
          [10] = {
            406005,
            0,
            0
          },
          [11] = {
            703001,
            0,
            0
          }
        },
        rela_sex = 2,
        gamegender = 1,
        AddFriendBtnState = 1,
        pic_url = "",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000331,
        PlayerName = "player8",
        Rank = 3,
        Kills = 1,
        PlayerScore = 800,
        DamageAmount = 1000,
        Infections = 1,
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
        pic_url = "",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000332,
        PlayerName = "player9",
        Rank = 5,
        Kills = 1,
        PlayerScore = 50,
        DamageAmount = 1000,
        Infections = 1,
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
        pic_url = "",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000333,
        PlayerName = "player10",
        Rank = 4,
        Kills = 1,
        PlayerScore = 100,
        DamageAmount = 1000,
        Infections = 1,
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
        pic_url = "",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000334,
        PlayerName = "player11",
        Rank = 11,
        Kills = 1,
        PlayerScore = 100,
        DamageAmount = 1000,
        Infections = 1,
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
        pic_url = "",
        cur_avatar_box_id = 2001001
      },
      {
        UID = 510000335,
        PlayerName = "player12",
        Rank = 12,
        Kills = 1,
        PlayerScore = 100,
        DamageAmount = 1000,
        Infections = 1,
        wear_ext = {
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
          [5] = {
            405012,
            0,
            0
          },
          [13] = {
            103003,
            0,
            0
          }
        },
        rela_sex = 2,
        gamegender = 0,
        AddFriendBtnState = 1,
        pic_url = "",
        cur_avatar_box_id = 2001001
      }
    }
  }
  BattleResultInfectionUI.OnBattleResult(result)
end