local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
local FuncLib = require("client.logic.NewSetting.Stack.FuncLib")
local SEQ012 = {
  0,
  1,
  2
}
local Spacer = {
  UI = AliasMap.Spacer
}
local Stack_Game_Advanced = {
  {
    Key = "TitleFeature",
    UI = AliasMap.Title,
    Text = 25251
  },
  {
    Key = "UniversalSignSwitch",
    UI = AliasMap.Switcher,
    Text = 33169,
    Help = 8726
  },
  {
    Key = "bCanIntelligentSign",
    UI = AliasMap.Switcher,
    Text = 67368,
    Help = 67369
  },
  {
    Key = "bCloseHitHeadAudio",
    UI = AliasMap.Switcher,
    Text = 33170,
    SwitcherValue = FuncLib.BOOL_FT
  },
  {
    Key = "HitBodyAudio",
    UI = AliasMap.Switcher,
    Text = 612401075
  },
  {
    Key = "KnockOutAudio",
    UI = AliasMap.Switcher,
    Text = 612401076
  },
  {
    Key = "bSeperateShootMBtn",
    UI = AliasMap.ImageSwitcher,
    Text = 83251,
    SwitcherText = {37267, 37266},
    SwitcherValue = FuncLib.BOOL_FT,
    SwitcherImage = {
      "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Operate/Setting_Image_Operate_01.Setting_Image_Operate_01",
      "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Operate/Setting_Image_Operate_02.Setting_Image_Operate_02"
    },
    Help = 83252
  },
  {
    Key = "VaultBtnSwitch",
    UI = AliasMap.Switcher,
    Text = 33171,
    SwitcherText = {37267, 37266},
    SwitcherValue = FuncLib.BOOL_FT
  },
  {
    Key = "OneKeyProneAndCrouchSwitch",
    UI = AliasMap.Switcher,
    Text = 33172,
    Help = 24946
  },
  {
    Key = "RingThrowSwitch",
    UI = AliasMap.Switcher,
    Text = 33173,
    Help = function()
      UIManager.ShowUI(UIManager.UI_Config.Throw_Tips_UIBP, 1)
    end
  },
  {
    Key = "RingThrowPressSwitch",
    UI = AliasMap.Switcher,
    Text = 33174,
    SwitcherText = {9834, 18373},
    SwitcherValue = FuncLib.BOOL_FT,
    Help = function()
      UIManager.ShowUI(UIManager.UI_Config.Throw_Tips_UIBP, 2)
    end
  },
  {
    Key = "bConsumeThrow",
    UI = AliasMap.Switcher,
    Text = 33177,
    Help = function()
      UIManager.ShowUI(UIManager.UI_Config.Throw_Tips_UIBP, 4)
    end
  },
  {
    Key = "bHideIngameUIAvailable",
    UI = AliasMap.Switcher,
    Text = 33178,
    Help = function()
      UIManager.ShowUI(UIManager.UI_Config.Throw_Tips_UIBP, 3)
    end
  },
  {
    Key = "ShovelSwitch",
    UI = AliasMap.Switcher,
    Text = 8700099
  },
  {
    Key = "FpViewSwitch",
    UI = AliasMap.Switcher,
    Text = 33180,
    Help = 10270
  },
  {
    Key = "DynamicHoldGun",
    UI = AliasMap.Switcher,
    Text = 33181,
    Help = 116036
  },
  {
    Key = "TpViewValue",
    UI = AliasMap.Slider,
    Text = 33182,
    Max = 90,
    Min = 80,
    IsPercent = false
  },
  {
    Key = "FpViewValue",
    UI = AliasMap.Slider,
    Text = 33184,
    Max = 103,
    Min = 80,
    IsPercent = false
  },
  {
    Key = "JoystickSprintSensitity",
    UI = AliasMap.Slider,
    Text = 33183,
    Max = 100,
    Min = 0,
    Help = 25239
  },
  {
    Key = "OldMarkStyle",
    UI = AliasMap.ImageSwitcher,
    Text = 32994,
    SwitcherText = {32995, 32996},
    SwitcherImage = {
      "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Operate/Setting_Image_Operate_07.Setting_Image_Operate_07",
      "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Operate/Setting_Image_Operate_08.Setting_Image_Operate_08"
    },
    Help = function()
      UIManager.ShowUI(UIManager.UI_Config.Seeting_TwoPicturesPopup_UIBP, "MarkStyle")
    end,
    RecommendedIndex = 1
  },
  {
    Key = "bQuickSignDoubleRing",
    UI = AliasMap.Switcher,
    SwitcherText = {32995, 32996},
    SwitcherValue = FuncLib.BOOL_FT,
    Text = 87971,
    Help = function()
      UIManager.ShowUI(UIManager.UI_Config.Seeting_TwoPicturesPopup_UIBP, "DoubleRing")
    end,
    RecommendedIndex = 1
  },
  {
    Key = "PeekToSprintSwitch",
    UI = AliasMap.Switcher,
    Text = 77836,
    Help = 77837
  },
  Spacer,
  {
    Key = "TitleAimAssist",
    UI = AliasMap.Title,
    Text = 25254
  },
  {
    Key = "AimAssist",
    UI = AliasMap.Switcher,
    Text = 33185
  },
  {
    Key = "SoundVisualizationType",
    UI = AliasMap.Switcher,
    Text = 33186,
    SwitcherText = {
      46208,
      46209,
      100048
    },
    Help = function()
      UIManager.ShowUI(UIManager.UI_Config.Seeting_TwoPicturesPopup_UIBP, "SoundVisualizationType")
    end
  },
  {
    Key = "AutoHitMark",
    UI = AliasMap.Switcher,
    Text = 33187,
    Help = 29410,
    RecommendedIndex = 0
  },
  {
    Key = "Weapon_LowAmmo",
    UI = AliasMap.Switcher,
    Text = 86798,
    Help = 86799,
    RecommendedIndex = 0
  },
  {
    Key = "IntelligentDrugs",
    UI = AliasMap.Switcher,
    Text = 33188
  },
  {
    Key = "AutoContinueHeal",
    UI = AliasMap.Switcher,
    Text = 33189
  },
  {
    Key = "AutoOpenDoor",
    UI = AliasMap.Switcher,
    Text = 33190
  },
  {
    Key = "WallFeedBack",
    UI = AliasMap.ImageSwitcher,
    Text = 33191,
    SwitcherImage = {
      "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Operate/Setting_Image_Operate_03.Setting_Image_Operate_03",
      "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Operate/Setting_Image_Operate_04.Setting_Image_Operate_04"
    }
  },
  {
    Key = "UseDisOrSpeedMove",
    UI = AliasMap.Switcher,
    Text = 32732,
    Help = 32733
  },
  {
    Key = "OpenSilentChat",
    UI = AliasMap.Switcher,
    Text = 43352,
    Help = 44440
  },
  {
    Key = "bCanMapLongPress",
    UI = AliasMap.Switcher,
    Text = 44588
  },
  {
    Key = "GrenadeSettingPredictLine",
    UI = AliasMap.Switcher,
    Text = 48375,
    Help = 48376
  },
  {
    Key = "AutoEquipMelleeWeapon",
    UI = AliasMap.Switcher,
    Text = 48661,
    Help = 48662
  },
  {
    Key = "DefaultMeleeWeaponType",
    UI = AliasMap.Switcher,
    Text = 64650,
    SwitcherText = {18734, 64649},
    SwitcherValue = {1, 2},
    Help = 64651,
    GetFunc = FuncLib.GetValue,
    SetFunc = function(k, Value)
      local WeaponID = 108005
      if Value == 1 then
        WeaponID = 108001
      elseif Value == 2 then
        WeaponID = 108005
      end
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_save_player_custom_data_to_battle_req({BirthIslandMeleeItem = WeaponID})
      return FuncLib.SetValue(k, Value)
    end
  },
  {
    Key = "InterruptReloadType",
    UI = AliasMap.Switcher,
    Text = 62936,
    SwitcherText = {
      62937,
      62938,
      62939
    },
    SwitcherValue = SEQ012,
    Help = 62940
  },
  {
    Key = "BattleNewSwitch",
    UI = AliasMap.Switcher,
    Text = 25398,
    Help = 25156,
    VisibilityFunc = function()
      local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
      return logic_newbie_assist.CheckIsNewBie() and logic_newbie_assist.IsBattleSwtichMenuOpen()
    end
  },
  {
    Key = "AutoParachute",
    UI = AliasMap.Switcher,
    Text = 33175
  },
  {
    Key = "MapMarkEnable",
    UI = AliasMap.Switcher,
    Text = 33176,
    Help = 65040
  },
  {
    Key = "AutoFollowJump",
    UI = AliasMap.Switcher,
    Text = 30172,
    Help = 30178,
    GetFunc = function(key)
      if DataMgr and RoleSettingType then
        local ForbidFollowJump = DataMgr.GetRoleSetting(RoleSettingType.ForbidParachuteFollow) ~= 0
        return not ForbidFollowJump
      end
      return false
    end,
    SetFunc = function(key, index)
      local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
      if RoleInfoSystem and RoleSettingType then
        RoleInfoSystem.SetRoleInfoSettingSwitch(RoleSettingType.ForbidParachuteFollow)
      end
      return true
    end
  },
  Spacer,
  {
    Key = "TitleGyroscope",
    UI = AliasMap.Title,
    Text = 10971,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "Gyroscope",
    UI = AliasMap.Switcher,
    Text = 10971,
    Help = 87586,
    SwitcherText = {
      33210,
      33223,
      39267
    },
    SwitcherValue = FuncLib.SEQ120,
    ExpandIndex = {0, 1},
    SuggestionText = 66315,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor,
    FixedFunc = function(key)
      if not Client.IsDeviceSupportGyrSensor() then
        FuncLib.SetValue("Gyroscope", 0)
        return 0, LocUtil.GetLocalizeResStr(12030002)
      else
        return nil
      end
    end
  },
  {
    Key = "GyroReverse",
    UI = AliasMap.Switcher,
    Text = 21108,
    Help = 21109,
    ExpandHandle = "Gyroscope",
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "HoldGrenadeStateEnableGyro",
    UI = AliasMap.Switcher,
    Text = 612401099,
    Help = 612401100,
    ExpandHandle = "Gyroscope",
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "GyroscopeSpace",
    UI = AliasMap.Spacer,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor
  },
  {
    Key = "TitleShoulder",
    UI = AliasMap.Title,
    Text = 210041
  },
  {
    Key = "ShoulderEnable",
    UI = AliasMap.Switcher,
    Text = 210042,
    ExpandIndex = 0,
    Help = 49236
  },
  {
    Key = "ShoulderMode",
    UI = AliasMap.Switcher,
    Text = 210041,
    SwitcherText = {
      33215,
      33216,
      33217
    },
    Help = 210046,
    ExpandHandle = "ShoulderEnable"
  },
  {
    Key = "RotateViewWithShoulderSwitch",
    UI = AliasMap.Switcher,
    Text = 210043,
    Help = 210047,
    ExpandHandle = "ShoulderEnable"
  },
  Spacer,
  {
    Key = "TitleRecording",
    UI = AliasMap.Title,
    Text = 27730,
    VisibilityFunc = FuncLib.BShow_InLobby
  },
  {
    Key = "bRecordWonderfulReplayOpen",
    UI = AliasMap.Switcher,
    Text = 24503,
    Help = 24659,
    VisibilityFunc = FuncLib.BShow_bRecordWonderfulReplayOpen
  },
  {
    Key = "DeathPlaybackSwitch",
    UI = AliasMap.Switcher,
    Text = 9173,
    Help = 9122,
    VisibilityFunc = function()
      if IsWoWEditor then
        return false
      end
      local UIUtil = require("client.common.ui_util")
      if not GameStatus then
        return true
      end
      local isLobby = GameStatus.IsInLobbyOrMainCity()
      local show = false
      local GameInstance = UIUtil.GetGameInstance()
      if slua.isValid(GameInstance) and GameInstance.GetDeathPlayback ~= nil then
        local playBack = GameInstance:GetDeathPlayback()
        if slua.isValid(playBack) then
          show = not playBack:IsSwitchedOffByDevice()
        end
      end
      return isLobby and show
    end
  },
  {
    Key = "bUserSaveWonderfulReplaySwitch",
    UI = AliasMap.Switcher,
    Text = 8700085,
    Help = 8700086,
    VisibilityFunc = FuncLib.BShow_bRecordWonderfulReplayOpen
  },
  {
    Key = "LowTickRateInSpectating",
    UI = AliasMap.Switcher,
    Text = 1050301,
    Help = 1050302,
    VisibilityFunc = FuncLib.BShow_InLobby
  },
  {
    UI = AliasMap.Spacer,
    VisibilityFunc = FuncLib.BShow_InLobby
  },
  {
    UI = AliasMap.Title,
    Text = 774823,
    VisibilityFunc = FuncLib.BShow_InLobby
  },
  {
    Key = "MetroFashionLobbySwitcher",
    UI = AliasMap.Switcher,
    VisibilityFunc = FuncLib.BShow_InLobby,
    Text = 774824,
    Help = 774826
  },
  {
    Key = "MetroFashionGameSwitcher",
    UI = AliasMap.Switcher,
    VisibilityFunc = FuncLib.BShow_InLobby,
    Text = 774825,
    Help = 774826
  }
}
return Stack_Game_Advanced