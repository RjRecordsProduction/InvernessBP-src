local CustomLayoutType = require("client.logic.setting.CustomLayoutType")
local CustomType = require("client.logic.setting.CustomType")
local CustomSaveFlag = require("client.logic.setting.CustomSaveFlag")
local CustomDisplayFlag = require("client.logic.setting.CustomDisplayFlag")
local ETouchEventType = import("ETouchEventType")
local LayerTag = {Parachuting = 1}
local GroupType = {
  Glider = 1000,
  Tank = 2000,
  LandVehicle = 3000,
  FlyVehicle = 4000,
  Mecha = 5000,
  Aircraft = 6000,
  Giant = 7000,
  Transformer = 8000,
  Special = 10000
}
local SettingUIElemLayoutConfig = {
  SlotRegistry = {
    [CustomType._0_Default] = {
      SaveFlag = CustomSaveFlag.None,
      ShowFlag = CustomDisplayFlag.None,
      TranslucentFlag = nil,
      HideOnSettingConfig = nil,
      SpecificLayer = nil,
      OptionalWidget = nil,
      CustomRefreshFunc = nil,
      Group = 0
    },
    [CustomType._1_BackPack] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject
    },
    [CustomType._2_Joystick] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.SpecialObject,
      OnDragFunc = function(_self, JoystickPanel)
        local RushTriggerPanel = _self.CustomPanelMap_Active[CustomType._30_RushTrigger]
        if slua.isValid(RushTriggerPanel) then
          RushTriggerPanel:SetDesirePosition(JoystickPanel:GetPosition() - FVector2D(0, RushTriggerPanel.RushTriggerLength))
          JoystickPanel:SetDesirePosition(RushTriggerPanel:GetPosition() + FVector2D(0, RushTriggerPanel.RushTriggerLength))
        end
      end
    },
    [CustomType._3_FirstAid] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject
    },
    [CustomType._4_Weapon1] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OptionalWidget = {
        [1] = {
          SettingConfig = {
            Key = "bSeperateShootMBtn",
            Value = true
          }
        }
      }
    },
    [CustomType._5_Weapon2] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OptionalWidget = {
        [1] = {
          SettingConfig = {
            Key = "bSeperateShootMBtn",
            Value = true
          }
        }
      }
    },
    [CustomType._6_Door] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OptionalWidget = {
        [1] = {
          LayoutType = CustomLayoutType.TD
        }
      }
    },
    [CustomType._7_Rescue] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._8_ElerDriver] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._9_Projectile] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._10_LookAround] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject
    },
    [CustomType._11_Rush] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._12_Map] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject
    },
    [CustomType._13_Reload] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._14_Chat] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      OnDragFunc = function(_self, InCustomPanel)
        local ExpandWidget = InCustomPanel:GetExpandWidget()
        local UIUtil = require("client.common.ui_util")
        if UIUtil.IsWidgetVisible(ExpandWidget) then
          UIUtil.SetAdaptiveLayout(ExpandWidget, UEnums.EAdaptiveLayout.Outside, nil, -5)
        end
      end
    },
    [CustomType._15_AimMode] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._16_FireRight] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._17_Jump] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._18_Crawl] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "OneKeyProneAndCrouchSwitch",
        Value = true
      }
    },
    [CustomType._19_Crouch] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._20_FireLeft] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "LeftHandFire",
        Value = 0
      }
    },
    [CustomType._21_LeanLeft] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "LeftRightShoot",
        Value = false
      }
    },
    [CustomType._22_LeanRight] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "LeftRightShoot",
        Value = false
      }
    },
    [CustomType._23_LeanOutVehicle] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._24_Getoff_Vehicle] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject
    },
    [CustomType._25_TeammateList] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      OptionalWidget = {
        [1] = {
          LayoutType = CustomLayoutType.TD
        }
      }
    },
    [CustomType._26_FPS_TPS_Switch] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "FpViewSwitch",
        Value = false
      }
    },
    [CustomType._27_Pistol] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._28_Scope] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._29_Pickup_Box] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._30_RushTrigger] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OnDragFunc = function(_self, RushTriggerPanel)
        local JoystickPanel = _self.CustomPanelMap_Active[CustomType._2_Joystick]
        if slua.isValid(JoystickPanel) then
          RushTriggerPanel:SetDesirePosition(FVector2D(JoystickPanel:GetPosition().X, RushTriggerPanel:GetPosition().Y))
          local RushTriggerLength = JoystickPanel:GetPosition().Y - RushTriggerPanel:GetPosition().Y
          local MinLength = RushTriggerPanel:UpdateMinLength(JoystickPanel)
          RushTriggerLength = RushTriggerLength < MinLength and MinLength or RushTriggerLength
          RushTriggerPanel:SetLength(RushTriggerLength)
          RushTriggerPanel:UpdateMaxScale(JoystickPanel)
          RushTriggerPanel:SetDesirePosition(JoystickPanel:GetPosition() - FVector2D(0, RushTriggerPanel.RushTriggerLength))
        end
      end
    },
    [CustomType._31_Pickup] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._32_ModItemSelector] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.ThemeBR
    },
    [CustomType._33_Scope_Switch] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "QuasiMirrorSwitch",
        Value = false
      }
    },
    [CustomType._34_CancelThrow] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._35_Vault] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "VaultBtnSwitch",
        Value = false
      }
    },
    [CustomType._36_Weapon_Aircraft] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Aircraft
    },
    [CustomType._37_FireL_Aircraft] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Aircraft
    },
    [CustomType._38_FireR_Aircraft] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Aircraft
    },
    [CustomType._39_Accelerate_Aircraft] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Aircraft
    },
    [CustomType._40_Decelerate_Aircraft] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Aircraft
    },
    [CustomType._41_Aim_Aircraft] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Aircraft
    },
    [CustomType._42_ScopeSide] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._43_Painting] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OnDragFunc = function(_self, InCustomPanel)
        local ExpandWidget = InCustomPanel:GetExpandWidget()
        local UIUtil = require("client.common.ui_util")
        if UIUtil.IsWidgetVisible(ExpandWidget) then
          UIUtil.SetAdaptiveLayout(ExpandWidget, UEnums.EAdaptiveLayout.Outside, nil, -10)
        end
      end
    },
    [CustomType._44_Flare_Aircraft] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Aircraft
    },
    [CustomType._45_ShootingWeaponMelee] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._50_Weapon1_MSwitch] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "bSeperateShootMBtn",
        Value = false
      }
    },
    [CustomType._51_Weapon2_MSwitch] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "bSeperateShootMBtn",
        Value = false
      }
    },
    [CustomType._59_CommandTrigger] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.ThemeBR,
      CustomRefreshFunc = function(...)
        local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
        local ModeType, _ = GameMainConfig.GetModType()
        if ModeType ~= "MysticPlant" then
          return 0
        end
        local ScriptHelperClient = import("/Script/Client.ScriptHelperClient")
        local Region = ScriptHelperClient.GetPublishRegion()
        local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
        if Region == PublishRegionMacros.JAPAN or Region == PublishRegionMacros.KOREA or Region == PublishRegionMacros.BLUEHOLE then
          return 0
        else
          return 1
        end
      end
    },
    [CustomType._60_IslandSelfie] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      CustomRefreshFunc = function(...)
        if LobbySystem.CheckOpen(BP_ENUM_MODULE_SELFIE_SWITCH) then
          return 0
        else
          return 1
        end
      end
    },
    [CustomType._61_KillInfo] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._75_TmpSkill_A] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._76_TmpSkill_B] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._77_TmpSkill_C] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._78_TmpSkill_D] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._79_TmpSkill_E] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._80_TmpSkill_F] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._81_SpSkill_A] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Special
    },
    [CustomType._82_SpSkill_B] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Special
    },
    [CustomType._83_SpSkill_C] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Special
    },
    [CustomType._84_SpSkill_D] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Special
    },
    [CustomType._85_SpSkill_E] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Special
    },
    [CustomType._86_SpSkill_F] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Special
    },
    [CustomType._87_SpSkill_G] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Special
    },
    [CustomType._88_SpSkill_H] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Special
    },
    [CustomType._89_UniversalSign] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "UniversalSignSwitch",
        Value = false
      }
    },
    [CustomType._90_VH_BC_L_Left] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._91_VH_BC_L_Right] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._92_VH_BC_L_Forward] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._93_VH_BC_L_Backward] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._94_VH_BC_L_SpeedUp] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._95_VH_BC_R_Left] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._96_VH_BC_R_Right] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._97_VH_BC_R_Forward] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._98_VH_BC_R_Backward] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._99_VH_BC_R_SpeedUp] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._100_VH_Seat] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.SpecialObject | CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._101_VH_BC_L_Brake] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._102_VH_BC_R_Brake] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._103_VH_SW_L_Wheel] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._104_VH_SW_L_Brake] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._105_VH_SW_L_SpeedUp] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._106_VH_SW_L_BackUp] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._107_VH_SW_R_Wheel] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._108_VH_SW_R_Brake] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._109_VH_SW_R_SpeedUp] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._110_VH_SW_R_BackUp] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._111_VH_SW_L_Accelerator] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._112_VH_SW_R_Accelerator] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._113_VH_Horn] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._115_VH_JC_SpeedUp] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._116_VH_JC_Brake] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._120_VH_Dashboard] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.SpecialObject | CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._121_VH_JC_PushDown] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._122_VH_JC_LiftUp] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._123_VH_BC_L_LiftUp] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._124_VH_BC_L_PushDown] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._125_VH_BC_R_LiftUp] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._126_VH_BC_R_PushDown] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._127_VH_SW_R_LiftUp] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._128_VH_SW_R_PushDown] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._129_VH_SW_L_PushDown] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._130_VH_SW_L_LiftUp] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._140_MusicFestival_SKill] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD,
      ShowFlag = CustomDisplayFlag.TD
    },
    [CustomType._141_Ingame_Like] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "UseIngameLike",
        Value = false
      }
    },
    [CustomType._142_Shoulder_Button] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideOnSettingConfig = {
        Key = "ShoulderEnable",
        Value = false
      }
    },
    [CustomType._143_Vehicle_Interact] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._144_CarryBack_Button] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._147_Dynahex_Supply] = {
      SaveFlag = CustomSaveFlag.TD,
      ShowFlag = CustomDisplayFlag.TD
    },
    [CustomType._150_BuffList_H] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.None
    },
    [CustomType._151_BuffList_V] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._152_Tweak_Report] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject
    },
    [CustomType._153_Tweak_Setting] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject
    },
    [CustomType._154_Tweak_Speaker] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      OnDragFunc = function(_self, InCustomPanel)
        local ExpandWidget = InCustomPanel:GetExpandWidget()
        local UIUtil = require("client.common.ui_util")
        if UIUtil.IsWidgetVisible(ExpandWidget) then
          UIUtil.SetAdaptiveLayout(ExpandWidget, UEnums.EAdaptiveLayout.Outside, nil, 0)
        end
      end
    },
    [CustomType._155_Tweak_Micphone] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject,
      OnDragFunc = function(_self, InCustomPanel)
        local ExpandWidget = InCustomPanel:GetExpandWidget()
        local UIUtil = require("client.common.ui_util")
        if UIUtil.IsWidgetVisible(ExpandWidget) then
          UIUtil.SetAdaptiveLayout(ExpandWidget, UEnums.EAdaptiveLayout.Outside, nil, 0)
        end
      end
    },
    [CustomType._162_VH_BC_L_Jump] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._163_VH_BC_R_Jump] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._164_VH_SW_L_Jump] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._165_VH_SW_R_Jump] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._166_VH_JC_Jump] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._167_VH_MusicList] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.SpecialObject | CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._169_OBTeammateList] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._170_OBMiniMap] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._171_OBPlayerInfo] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._172_OBSettingUI] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._173_OBKillTips] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._174_TankAtk_Left] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Tank
    },
    [CustomType._175_TankAtk_Right] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Tank
    },
    [CustomType._176_TankAim] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Tank
    },
    [CustomType._177_TankOnGunner] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Tank
    },
    [CustomType._180_Skill_Cancel] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.ThemeBR
    },
    [CustomType._186_GiantButton_A] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Giant
    },
    [CustomType._187_GiantButton_B] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Giant
    },
    [CustomType._188_GiantButton_C] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Giant
    },
    [CustomType._189_GiantButton_D] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Giant
    },
    [CustomType._190_DragonDance_BreakOut] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._191_DragonDance_Jump] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._192_IngameSocial] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._193_Creative_PropShopEntry] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._194_CreativeBase_Skill1] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._195_CreativeBase_Skill2] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._196_CreativeBase_Skill3] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._197_CreativeBase_Skill4] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._198_BoomThrottle] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      CustomRefreshFunc = function(_self)
        return _self.CheckBoomThrottleBtnCustmize()
      end
    },
    [CustomType._199_RaptorJump] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.FlyVehicle
    },
    [CustomType._202_FlyingVehicle_A] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.FlyVehicle
    },
    [CustomType._204_VTOL_Up] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.FlyVehicle
    },
    [CustomType._205_VTOL_Down] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.FlyVehicle
    },
    [CustomType._206_Escape_Skill1] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._207_Escape_Skill2] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._208_Escape_Skill3] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._210_Horse_Follow] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._210_Horse_Back] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._218_CabrioletUI] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      CustomRefreshFunc = function(_self, ...)
        return _self.CheckCabrioletUICustmize()
      end
    },
    [CustomType._220_C4Bomb] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._221_LeavePlan] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      SpecificLayer = LayerTag.Parachuting
    },
    [CustomType._222_Parachute] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      SpecificLayer = LayerTag.Parachuting
    },
    [CustomType._223_AutoParachute] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      SpecificLayer = LayerTag.Parachuting,
      HideOnSettingConfig = {
        Key = "AutoParachute",
        Value = false
      }
    },
    [CustomType._225_ReindeerJump] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._226_ReindeerLink] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._227_FlyingVehicle_B] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.FlyVehicle
    },
    [CustomType._230_SplineSprintMove] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._231_SplineSprintLeave] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._232_VehiclePhoto] = {
      SaveFlag = CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      TranslucentFlag = CustomDisplayFlag.SpecialObject | CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._233_UGC_Interact_But1] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._234_UGC_Interact_But2] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._235_UGC_Interact_But3] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._236_UGC_Interact_But4] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._237_UGC_TaskDetail] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._265_SaveWonderfulPeriod] = {
      SaveFlag = CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._238_FlauntBtn] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._239_FillGasWeapon] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.None
    },
    [CustomType._240_MotorGlider_Accelerate] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Glider
    },
    [CustomType._241_MotorGlider_Decelerate] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Glider
    },
    [CustomType._244_InteractibleObjectButton] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._245_MechaFireButtonL] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Mecha
    },
    [CustomType._246_MechaFireButtonR] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Mecha
    },
    [CustomType._247_MechaLinkButton] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Mecha
    },
    [CustomType._248_MechaWeapon] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Mecha
    },
    [CustomType._249_MechaJumpButton] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Mecha
    },
    [CustomType._250_MechaParachuteOpenButton] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._252_KillCounter] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._258_SpecialCharacterSkill1] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.None
    },
    [CustomType._259_SpecialCharacterSkill2] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._260_SpecialDash] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._261_SpecialFlyUp] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._262_SpecialFlyDown] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._263_SpecialMoveLeft] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._264_SpecialMoveRight] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._266_TigerDrift] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._267_VehicleAutoMove] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._268_LandVehicle_G] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._269_LandVehicle_H] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._270_DriftVehicleAutoMove] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._271_DriftVehicleAutoMove] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideOnSettingConfig = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._272_DriftVehicleAutoMove] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._273_DriftVehicleAutoMove] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._274_DriftVehicleAutoMove] = {
      SaveFlag = CustomSaveFlag.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideOnSettingConfig = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._275_LandVehicle_J] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._276_LandVehicle_K] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._277_BackToDriverButton] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      TranslucentFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._278_TransformerHealth] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Transformer
    },
    [CustomType._279_TransformerSwitchForm] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Transformer
    },
    [CustomType._280_TransformerAttackL] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Transformer
    },
    [CustomType._281_TransformerAttackR] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Transformer
    },
    [CustomType._282_TransformerSkill] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Transformer
    },
    [CustomType._283_TransformerJump] = {
      SaveFlag = CustomSaveFlag.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.Transformer
    },
    [CustomType._284_Escape_Behavior] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._285_PenguinCartSnowBall] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._286_PenguinCartHelpPushOn] = {
      SaveFlag = CustomSaveFlag.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      Group = GroupType.LandVehicle
    },
    [CustomType._287_WeaponFlauntBtn] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._288_CooperationVault] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._289_PickupTombBox] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._290_HistoricalNews] = {
      SaveFlag = CustomSaveFlag.Classic | CustomSaveFlag.TD | CustomSaveFlag.UGC,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    }
  },
  StatConfig = {RecordCountMin = 50, RecordCountMax = 100}
}
return SettingUIElemLayoutConfig