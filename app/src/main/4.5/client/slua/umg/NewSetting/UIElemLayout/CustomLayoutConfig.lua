local CustomLayoutType = require("client.logic.setting.CustomLayoutType")
local CustomType = require("client.logic.setting.CustomType")
local SaveDomain = require("client.logic.setting.CustomLayoutSaveDomain")
local CustomDisplayFlag = require("client.logic.setting.CustomDisplayFlag")
local LayerTag = {Parachuting = 1}
local CustomLayoutConfig = {
  SlotRegistry = {
    [CustomType._0_Default] = {
      Name = "Default",
      SaveDomain = SaveDomain.None,
      ShowFlag = CustomDisplayFlag.None,
      HideWhenSetting = nil,
      SpecificLayer = nil,
      OptionalWidget = nil,
      CustomRefreshFunc = nil
    },
    [CustomType._1_BackPack] = {
      Name = "BackPack",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._2_Joystick] = {
      Name = "Joystick",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OnDragFunc = function(_self, JoystickPanel)
        local RushTriggerPanel = _self.CustomPanelMap_Active[CustomType._30_RushTrigger]
        if slua.isValid(RushTriggerPanel) then
          if RushTriggerPanel.RushTriggerLength == 0 then
            RushTriggerPanel.RushTriggerLength = JoystickPanel:GetPosition().Y - RushTriggerPanel:GetPosition().Y
          end
          RushTriggerPanel:SetDesirePosition(JoystickPanel:GetPosition() - FVector2D(0, RushTriggerPanel.RushTriggerLength))
          JoystickPanel:SetDesirePosition(RushTriggerPanel:GetPosition() + FVector2D(0, RushTriggerPanel.RushTriggerLength))
        end
      end
    },
    [CustomType._3_FirstAid] = {
      Name = "FirstAid",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._4_Weapon1] = {
      Name = "Weapon1",
      SaveDomain = SaveDomain.Character,
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
      Name = "Weapon2",
      SaveDomain = SaveDomain.Character,
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
      Name = "Door",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._7_Rescue] = {
      Name = "Rescue",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._8_ElerDriver] = {
      Name = "ElerDriver",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._9_Projectile] = {
      Name = "Projectile",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._10_LookAround] = {
      Name = "LookAround",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._11_Rush] = {
      Name = "Rush",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._12_Map] = {
      Name = "Map",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._13_Reload] = {
      Name = "Reload",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._14_Chat] = {
      Name = "Chat",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OnDragFunc = function(_self, InCustomPanel)
        local ExpandWidget = InCustomPanel:GetExpandWidget()
        local UIUtil = require("client.common.ui_util")
        if UIUtil.IsWidgetVisible(ExpandWidget) then
          UIUtil.SetAdaptiveLayout(ExpandWidget, UEnums.EAdaptiveLayout.Outside, nil, -5)
        end
      end
    },
    [CustomType._15_AimMode] = {
      Name = "AimMode",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._16_FireRight] = {
      Name = "FireRight",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._17_Jump] = {
      Name = "Jump",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._18_Crawl] = {
      Name = "Crawl",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "OneKeyProneAndCrouchSwitch",
        Value = true
      }
    },
    [CustomType._19_Crouch] = {
      Name = "Crouch",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._20_FireLeft] = {
      Name = "FireLeft",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "LeftHandFire",
        Value = 0
      }
    },
    [CustomType._21_LeanLeft] = {
      Name = "LeanLeft",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "LeftRightShoot",
        Value = false
      }
    },
    [CustomType._22_LeanRight] = {
      Name = "LeanRight",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "LeftRightShoot",
        Value = false
      }
    },
    [CustomType._23_LeanOutVehicle] = {
      Name = "LeanOutVehicle",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._24_Getoff_Vehicle] = {
      Name = "Getoff_Vehicle",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering | CustomDisplayFlag.SpecialObject
    },
    [CustomType._25_TeammateList] = {
      Name = "TeammateList",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OptionalWidget = {
        [1] = {
          LayoutType = CustomLayoutType.TD
        }
      }
    },
    [CustomType._26_FPS_TPS_Switch] = {
      Name = "FPS_TPS_Switch",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "FpViewSwitch",
        Value = false
      }
    },
    [CustomType._27_Pistol] = {
      Name = "Pistol",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._28_Scope] = {
      Name = "Scope",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._29_Pickup_Box] = {
      Name = "Pickup_Box",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._30_RushTrigger] = {
      Name = "RushTrigger",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      CustomRefreshFunc = function(_, RushTriggerPanel)
        RushTriggerPanel.RushTriggerLength = 0
      end,
      OnDragFunc = function(_self, RushTriggerPanel)
        local JoystickPanel = _self.CustomPanelMap_Active[CustomType._2_Joystick]
        if slua.isValid(JoystickPanel) then
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
      Name = "Pickup",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._32_ModItemSelector] = {
      Name = "ModItemSelector",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.ThemeBR
    },
    [CustomType._33_Scope_Switch] = {
      Name = "Scope_Switch",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "QuasiMirrorSwitch",
        Value = false
      }
    },
    [CustomType._34_CancelThrow] = {
      Name = "CancelThrow",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._35_Vault] = {
      Name = "Vault",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "VaultBtnSwitch",
        Value = false
      }
    },
    [CustomType._36_Weapon_Aircraft] = {
      Name = "Weapon_Aircraft",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._37_FireL_Aircraft] = {
      Name = "FireL_Aircraft",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._38_FireR_Aircraft] = {
      Name = "FireR_Aircraft",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._39_Accelerate_Aircraft] = {
      Name = "Accelerate_Aircraft",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._40_Decelerate_Aircraft] = {
      Name = "Decelerate_Aircraft",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._41_Aim_Aircraft] = {
      Name = "Aim_Aircraft",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._42_ScopeSide] = {
      Name = "ScopeSide",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._43_Painting] = {
      Name = "Painting",
      SaveDomain = SaveDomain.Character,
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
      Name = "Flare_Aircraft",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._45_ShootingWeaponMelee] = {
      Name = "ShootingWeaponMelee",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._50_Weapon1_MSwitch] = {
      Name = "Weapon1_MSwitch",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "bSeperateShootMBtn",
        Value = false
      }
    },
    [CustomType._51_Weapon2_MSwitch] = {
      Name = "Weapon2_MSwitch",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "bSeperateShootMBtn",
        Value = false
      }
    },
    [CustomType._59_CommandTrigger] = {
      Name = "CommandTrigger",
      SaveDomain = SaveDomain.Character,
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
      Name = "IslandSelfie",
      SaveDomain = SaveDomain.Character,
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
      Name = "KillInfo",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [75] = {
      Name = "Ninjutsu",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [76] = {
      Name = "NinjaRun",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [77] = {
      Name = "NinjaRun_Follow",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [78] = {
      Name = "Bijuu",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [79] = {
      Name = "NinjutsuByVoice",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [80] = {
      Name = "TeleportToDecoy",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [81] = {
      Name = "Swing",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._89_UniversalSign] = {
      Name = "UniversalSign",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "UniversalSignSwitch",
        Value = false
      }
    },
    [CustomType._90_VH_BC_L_Left] = {
      Name = "VH_BC_L_Left",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._91_VH_BC_L_Right] = {
      Name = "VH_BC_L_Right",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._92_VH_BC_L_Forward] = {
      Name = "VH_BC_L_Forward",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._93_VH_BC_L_Backward] = {
      Name = "VH_BC_L_Backward",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._94_VH_BC_L_SpeedUp] = {
      Name = "VH_BC_L_SpeedUp",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._95_VH_BC_R_Left] = {
      Name = "VH_BC_R_Left",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._96_VH_BC_R_Right] = {
      Name = "VH_BC_R_Right",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._97_VH_BC_R_Forward] = {
      Name = "VH_BC_R_Forward",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._98_VH_BC_R_Backward] = {
      Name = "VH_BC_R_Backward",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._99_VH_BC_R_SpeedUp] = {
      Name = "VH_BC_R_SpeedUp",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._100_VH_Seat] = {
      Name = "VH_Seat",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._101_VH_BC_L_Brake] = {
      Name = "VH_BC_L_Brake",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._102_VH_BC_R_Brake] = {
      Name = "VH_BC_R_Brake",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._103_VH_SW_L_Wheel] = {
      Name = "VH_SW_L_Wheel",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._104_VH_SW_L_Brake] = {
      Name = "VH_SW_L_Brake",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._105_VH_SW_L_SpeedUp] = {
      Name = "VH_SW_L_SpeedUp",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._106_VH_SW_L_BackUp] = {
      Name = "VH_SW_L_BackUp",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._107_VH_SW_R_Wheel] = {
      Name = "VH_SW_R_Wheel",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._108_VH_SW_R_Brake] = {
      Name = "VH_SW_R_Brake",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._109_VH_SW_R_SpeedUp] = {
      Name = "VH_SW_R_SpeedUp",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._110_VH_SW_R_BackUp] = {
      Name = "VH_SW_R_BackUp",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._111_VH_SW_L_Accelerator] = {
      Name = "VH_SW_L_Accelerator",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._112_VH_SW_R_Accelerator] = {
      Name = "VH_SW_R_Accelerator",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._113_VH_Horn] = {
      Name = "VH_Horn",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._115_VH_JC_SpeedUp] = {
      Name = "VH_JC_SpeedUp",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._116_VH_JC_Brake] = {
      Name = "VH_JC_Brake",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._120_VH_Dashboard] = {
      Name = "VH_Dashboard",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._121_VH_JC_PushDown] = {
      Name = "VH_JC_PushDown",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._122_VH_JC_LiftUp] = {
      Name = "VH_JC_LiftUp",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._123_VH_BC_L_LiftUp] = {
      Name = "VH_BC_L_LiftUp",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._124_VH_BC_L_PushDown] = {
      Name = "VH_BC_L_PushDown",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._125_VH_BC_R_LiftUp] = {
      Name = "VH_BC_R_LiftUp",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._126_VH_BC_R_PushDown] = {
      Name = "VH_BC_R_PushDown",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._127_VH_SW_R_LiftUp] = {
      Name = "VH_SW_R_LiftUp",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._128_VH_SW_R_PushDown] = {
      Name = "VH_SW_R_PushDown",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._129_VH_SW_L_PushDown] = {
      Name = "VH_SW_L_PushDown",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._130_VH_SW_L_LiftUp] = {
      Name = "VH_SW_L_LiftUp",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._140_MusicFestival_SKill] = {
      Name = "MusicFestival_SKill",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.TD
    },
    [CustomType._141_Ingame_Like] = {
      Name = "Ingame_Like",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "UseIngameLike",
        Value = false
      }
    },
    [CustomType._142_Shoulder_Button] = {
      Name = "Shoulder_Button",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      HideWhenSetting = {
        Key = "ShoulderEnable",
        Value = false
      }
    },
    [CustomType._143_Vehicle_Interact] = {
      Name = "Vehicle_Interact",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._144_CarryBack_Button] = {
      Name = "CarryBack_Button",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._147_Dynahex_Supply] = {
      Name = "Dynahex_Supply",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.TD
    },
    [CustomType._150_BuffList_H] = {
      Name = "BuffList_H",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.None
    },
    [CustomType._151_BuffList_V] = {
      Name = "BuffList_V",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._152_Tweak_Report] = {
      Name = "Tweak_Report",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._153_Tweak_Setting] = {
      Name = "Tweak_Setting",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._154_Tweak_Speaker] = {
      Name = "Tweak_Speaker",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OnDragFunc = function(_self, InCustomPanel)
        local ExpandWidget = InCustomPanel:GetExpandWidget()
        local UIUtil = require("client.common.ui_util")
        if UIUtil.IsWidgetVisible(ExpandWidget) then
          UIUtil.SetAdaptiveLayout(ExpandWidget, UEnums.EAdaptiveLayout.Outside, nil, 0)
        end
      end
    },
    [CustomType._155_Tweak_Micphone] = {
      Name = "Tweak_Micphone",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC,
      OnDragFunc = function(_self, InCustomPanel)
        local ExpandWidget = InCustomPanel:GetExpandWidget()
        local UIUtil = require("client.common.ui_util")
        if UIUtil.IsWidgetVisible(ExpandWidget) then
          UIUtil.SetAdaptiveLayout(ExpandWidget, UEnums.EAdaptiveLayout.Outside, nil, 0)
        end
      end
    },
    [CustomType._162_VH_BC_L_Jump] = {
      Name = "VH_BC_L_Jump",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._163_VH_BC_R_Jump] = {
      Name = "VH_BC_R_Jump",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._164_VH_SW_L_Jump] = {
      Name = "VH_SW_L_Jump",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._165_VH_SW_R_Jump] = {
      Name = "VH_SW_R_Jump",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._166_VH_JC_Jump] = {
      Name = "VH_JC_Jump",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._167_VH_MusicList] = {
      Name = "VH_MusicList",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._169_OBTeammateList] = {
      Name = "OBTeammateList",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._170_OBMiniMap] = {
      Name = "OBMiniMap",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._171_OBPlayerInfo] = {
      Name = "OBPlayerInfo",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._172_OBSettingUI] = {
      Name = "OBSettingUI",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._173_OBKillTips] = {
      Name = "OBKillTips",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.OB
    },
    [CustomType._174_TankAtk_Left] = {
      Name = "TankAtk_Left",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._175_TankAtk_Right] = {
      Name = "TankAtk_Right",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._176_TankAim] = {
      Name = "TankAim",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._177_TankOnGunner] = {
      Name = "TankOnGunner",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._180_Skill_Cancel] = {
      Name = "Skill_Cancel",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.ThemeBR
    },
    [CustomType._186_GiantButton_A] = {
      Name = "GiantButton_A",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._187_GiantButton_B] = {
      Name = "GiantButton_B",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._188_GiantButton_C] = {
      Name = "GiantButton_C",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._189_GiantButton_D] = {
      Name = "GiantButton_D",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._190_DragonDance_BreakOut] = {
      Name = "DragonDance_BreakOut",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._191_DragonDance_Jump] = {
      Name = "DragonDance_Jump",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._192_IngameSocial] = {
      Name = "IngameSocial",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._193_Creative_PropShopEntry] = {
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._194_CreativeBase_Skill1] = {
      Name = "CreativeBase_Skill1",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._195_CreativeBase_Skill2] = {
      Name = "CreativeBase_Skill2",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._196_CreativeBase_Skill3] = {
      Name = "CreativeBase_Skill3",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._197_CreativeBase_Skill4] = {
      Name = "CreativeBase_Skill4",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._198_BoomThrottle] = {
      Name = "BoomThrottle",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      CustomRefreshFunc = function(_self)
        return _self.CheckBoomThrottleBtnCustmize()
      end
    },
    [CustomType._199_RaptorJump] = {
      Name = "RaptorJump",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._202_FlyingVehicle_A] = {
      Name = "FlyingVehicle_A",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._204_VTOL_Up] = {
      Name = "VTOL_Up",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._205_VTOL_Down] = {
      Name = "VTOL_Down",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._206_Escape_Skill1] = {
      Name = "Escape_Skill1",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._207_Escape_Skill2] = {
      Name = "Escape_Skill2",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._208_Escape_Skill3] = {
      Name = "Escape_Skill3",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._210_Horse_Follow] = {
      Name = "Horse_Follow",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._211_Horse_Back] = {
      Name = "Horse_Back",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._218_CabrioletUI] = {
      Name = "CabrioletUI",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      CustomRefreshFunc = function(_self, ...)
        return _self.CheckCabrioletUICustmize()
      end
    },
    [CustomType._219_HybridUI] = {
      Name = "HybridUI",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      CustomRefreshFunc = function(_self, ...)
        return _self.CheckHybridtUICustmize()
      end
    },
    [CustomType._220_C4Bomb] = {
      Name = "C4Bomb",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._221_LeavePlan] = {
      Name = "LeavePlan",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      SpecificLayer = LayerTag.Parachuting
    },
    [CustomType._222_Parachute] = {
      Name = "Parachute",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      SpecificLayer = LayerTag.Parachuting
    },
    [CustomType._223_AutoParachute] = {
      Name = "AutoParachute",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC,
      SpecificLayer = LayerTag.Parachuting,
      HideWhenSetting = {
        Key = "AutoParachute",
        Value = false
      }
    },
    [CustomType._225_ReindeerJump] = {
      Name = "ReindeerJump",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._226_ReindeerLink] = {
      Name = "ReindeerLink",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._227_FlyingVehicle_B] = {
      Name = "FlyingVehicle_B",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._230_SplineSprintMove] = {
      Name = "SplineSprintMove",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._231_SplineSprintLeave] = {
      Name = "SplineSprintLeave",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._232_VehiclePhoto] = {
      Name = "VehiclePhoto",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering
    },
    [CustomType._233_UGC_Interact_But1] = {
      Name = "UGC_Interact_But1",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._234_UGC_Interact_But2] = {
      Name = "UGC_Interact_But2",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._235_UGC_Interact_But3] = {
      Name = "UGC_Interact_But3",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._236_UGC_Interact_But4] = {
      Name = "UGC_Interact_But4",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._237_UGC_TaskDetail] = {
      Name = "UGC_TaskDetail",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._265_SaveWonderfulPeriod] = {
      Name = "SaveWonderfulPeriod",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.UGC
    },
    [CustomType._238_FlauntBtn] = {
      Name = "FlauntBtn",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._239_FillGasWeapon] = {
      Name = "FillGasWeapon",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.None
    },
    [CustomType._240_MotorGlider_Accelerate] = {
      Name = "MotorGlider_Accelerate",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._241_MotorGlider_Decelerate] = {
      Name = "MotorGlider_Decelerate",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._244_InteractibleObjectButton] = {
      Name = "InteractibleObjectButton",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._245_MechaFireButtonL] = {
      Name = "MechaFireButtonL",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._246_MechaFireButtonR] = {
      Name = "MechaFireButtonR",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._247_MechaLinkButton] = {
      Name = "MechaLinkButton",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._248_MechaWeapon] = {
      Name = "MechaWeapon",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._249_MechaJumpButton] = {
      Name = "MechaJumpButton",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._250_MechaParachuteOpenButton] = {
      Name = "MechaParachuteOpenButton",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._252_KillCounter] = {
      Name = "KillCounter",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._258_SpecialCharacterSkill1] = {
      Name = "SpecialCharacterSkill1",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.None
    },
    [CustomType._259_SpecialCharacterSkill2] = {
      Name = "SpecialCharacterSkill2",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._260_SpecialDash] = {
      Name = "SpecialDash",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._261_SpecialFlyUp] = {
      Name = "SpecialFlyUp",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._262_SpecialFlyDown] = {
      Name = "SpecialFlyDown",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._263_SpecialMoveLeft] = {
      Name = "SpecialMoveLeft",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._264_SpecialMoveRight] = {
      Name = "SpecialMoveRight",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._266_TigerDrift] = {
      Name = "TigerDrift",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._267_VehicleAutoMove] = {
      Name = "VehicleAutoMove",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.SpecialObject,
      CustomRefreshFunc = function(_self, ...)
        if _self.VehicleMode == 2 then
          local ESCPDisplayState = import("ESCPDisplayState")
          return ESCPDisplayState.Hidden
        end
      end
    },
    [CustomType._268_LandVehicle_G] = {
      Name = "LandVehicle_G",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._269_LandVehicle_H] = {
      Name = "LandVehicle_H",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._270_DriftVehicleAutoMove] = {
      Name = "DriftVehicleAutoMove",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = true
      }
    },
    [CustomType._271_DriftVehicleAutoMove] = {
      Name = "DriftVehicleAutoMove_BC_R",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl,
      HideWhenSetting = {
        Key = "ButtonLRSwitcher",
        Value = false
      }
    },
    [CustomType._272_DriftVehicleAutoMove] = {
      Name = "DriftVehicleAutoMove_JC",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.VehicleJoystickCtrl
    },
    [CustomType._273_DriftVehicleAutoMove] = {
      Name = "DriftVehicleAutoMove_SW_L",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = true
      }
    },
    [CustomType._274_DriftVehicleAutoMove] = {
      Name = "DriftVehicleAutoMove_SW_R",
      SaveDomain = SaveDomain.VH_SW,
      ShowFlag = CustomDisplayFlag.VehicleSteering,
      HideWhenSetting = {
        Key = "JoystickLRSwitcher",
        Value = false
      }
    },
    [CustomType._275_LandVehicle_J] = {
      Name = "LandVehicle_J",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._276_LandVehicle_K] = {
      Name = "LandVehicle_K",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._277_BackToDriverButton] = {
      Name = "BackToDriverButton",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._278_TransformerHealth] = {
      Name = "TransformerHealth",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._279_TransformerSwitchForm] = {
      Name = "TransformerSwitchForm",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._280_TransformerAttackL] = {
      Name = "TransformerAttackL",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._281_TransformerAttackR] = {
      Name = "TransformerAttackR",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._282_TransformerSkill] = {
      Name = "TransformerSkill",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._283_TransformerJump] = {
      Name = "TransformerJump",
      SaveDomain = SaveDomain.VH_JC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._284_Escape_Behavior] = {
      Name = "Escape_Behavior",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._285_PenguinCartSnowBall] = {
      Name = "PenguinCartSnowBall",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._286_PenguinCartHelpPushOn] = {
      Name = "PenguinCartHelpPushOn",
      SaveDomain = SaveDomain.VH_BC,
      ShowFlag = CustomDisplayFlag.SpecialObject
    },
    [CustomType._287_WeaponFlauntBtn] = {
      Name = "WeaponFlauntBtn",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.UGC
    },
    [CustomType._288_CooperationVault] = {
      Name = "CooperationVault",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._289_PickupTombBox] = {
      Name = "PickupTombBox",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic
    },
    [CustomType._290_HistoricalNews] = {
      Name = "HistoricalNews",
      SaveDomain = SaveDomain.Character,
      ShowFlag = CustomDisplayFlag.Classic | CustomDisplayFlag.TD | CustomDisplayFlag.UGC
    },
    [CustomType._291_VehicleSunroof] = {
      Name = "VehicleSunroof",
      SaveDomain = SaveDomain.VH_General,
      ShowFlag = CustomDisplayFlag.VehicleBtnCtrl | CustomDisplayFlag.VehicleJoystickCtrl | CustomDisplayFlag.VehicleSteering,
      CustomRefreshFunc = function(_self, ...)
        return _self.CheckSunroofUICustomize()
      end
    }
  },
  StatConfig = {RecordCountMin = 50, RecordCountMax = 100}
}
return CustomLayoutConfig