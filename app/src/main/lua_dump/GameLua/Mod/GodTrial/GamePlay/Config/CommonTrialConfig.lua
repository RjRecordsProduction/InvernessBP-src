local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
local ECommonTrialTipsType = Enum.ECommonTrialTipsType
local ETrialType = Enum.ETrialType
local CommonTrialConfig = {
  TrialDeadlineAfterFighting = {
    Baltic = 1300,
    Livik = 600,
    Neon = 1300
  },
  TrialDeadlineCommonTipsId = 4404049,
  CommonTips = {
    [ETrialType.TowerDefense] = {
      [ECommonTrialTipsType.EnterArea] = {PrimaryTextId = 4404002, SecondaryTextId = 4402028},
      [ECommonTrialTipsType.Success] = {
        PrimaryTextId = function(Params)
          local TextId = Params.IsPerfect == true and 4402040 or 4404009
          return TextId, LocUtil.LocalizeResFormat(TextId)
        end,
        SecondaryTextId = function(Params)
          local HonorScore = Params.HonorScore or 0
          local TextId = 0 < HonorScore and 4404012 or 4404009
          return TextId, LocUtil.LocalizeResFormat(TextId, HonorScore)
        end
      },
      [ECommonTrialTipsType.Failed] = {
        PrimaryTextId = 4404010,
        SecondaryTextId = function(Params)
          local TextId = Params.FailedReason == Enum.ETDFailedReason.LeaveArea and 4402039 or 4402037
          return TextId, LocUtil.LocalizeResFormat(TextId)
        end
      },
      [ECommonTrialTipsType.Ready] = {PrimaryTextId = 4402029},
      [ECommonTrialTipsType.LeaveAreaWarning] = {
        PrimaryTextId = 4404014,
        SecondaryTextId = 4404001,
        ShowExitButton = false
      }
    },
    [ETrialType.EatPoint] = {
      [ECommonTrialTipsType.EnterArea] = {PrimaryTextId = 4404002, SecondaryTextId = 4402042},
      [ECommonTrialTipsType.Success] = {
        PrimaryTextId = function(Params)
          local TextId = Params.IsPerfect == true and 4404015 or 4402050
          return TextId, LocUtil.LocalizeResFormat(TextId)
        end,
        SecondaryTextId = function(Params)
          local Score = Params.Score or 0
          local MaxScore = Params.MaxScore or 0
          if Params.IsPerfect and Params.PerfectMaxScore then
            MaxScore = Params.PerfectMaxScore
          end
          local TextId = 4402057
          return TextId, LocUtil.LocalizeResFormat(TextId, Score, MaxScore)
        end
      },
      [ECommonTrialTipsType.Failed] = {
        PrimaryTextId = 4404010,
        SecondaryTextId = function(Params)
          local Score = Params.Score or 0
          local MaxScore = Params.MaxScore or 0
          local TextId = 4402057
          return TextId, LocUtil.LocalizeResFormat(TextId, Score, MaxScore)
        end
      },
      [ECommonTrialTipsType.Ready] = {PrimaryTextId = 4402043},
      [ECommonTrialTipsType.Start] = {PrimaryTextId = 4402043, SecondaryTextId = 4402044},
      [ECommonTrialTipsType.LeaveAreaWarning] = {PrimaryTextId = 4402051, SecondaryTextId = 4404001}
    },
    [ETrialType.Parkour] = {
      [ECommonTrialTipsType.EnterArea] = {PrimaryTextId = 4404002, SecondaryTextId = 4402014},
      [ECommonTrialTipsType.Success] = {
        PrimaryTextId = 4404009,
        SecondaryTextId = function(Params)
          local HonorScore = Params.HonorScore or 0
          local TextId = 0 < HonorScore and 4404012 or 4404009
          return TextId, LocUtil.LocalizeResFormat(TextId, HonorScore)
        end
      },
      [ECommonTrialTipsType.Failed] = {PrimaryTextId = 4404010, SecondaryTextId = 4402019},
      [ECommonTrialTipsType.Ready] = {PrimaryTextId = 4402015}
    },
    [ETrialType.Football] = {
      [ECommonTrialTipsType.EnterArea] = {PrimaryTextId = 4404002, SecondaryTextId = 4402023},
      [ECommonTrialTipsType.Success] = {
        PrimaryTextId = 4404009,
        SecondaryTextId = function(Params)
          local HonorScore = Params.HonorScore or 0
          local TextId = 0 < HonorScore and 4404012 or 4404009
          return TextId, LocUtil.LocalizeResFormat(TextId, HonorScore)
        end
      },
      [ECommonTrialTipsType.Failed] = {
        PrimaryTextId = 4404010,
        SecondaryTextId = function(Params)
          local TextId = Params.FailedReason == Enum.EFBFailedReason.TakeDamage and 4402027 or 4402026
          return TextId, LocUtil.LocalizeResFormat(TextId)
        end
      },
      [ECommonTrialTipsType.Ready] = {PrimaryTextId = 4402024}
    },
    [ETrialType.FramePlatform] = {
      [ECommonTrialTipsType.EnterArea] = {PrimaryTextId = 4404002, SecondaryTextId = 4402001},
      [ECommonTrialTipsType.Success] = {
        PrimaryTextId = 4404009,
        SecondaryTextId = function(Params)
          local HonorScore = Params.HonorScore or 0
          local TextId = 0 < HonorScore and 4404012 or 4404009
          return TextId, LocUtil.LocalizeResFormat(TextId, HonorScore)
        end
      },
      [ECommonTrialTipsType.Failed] = {PrimaryTextId = 4404010, SecondaryTextId = 4402105},
      [ECommonTrialTipsType.Ready] = {PrimaryTextId = 4402001}
    },
    [ETrialType.ArenaArea] = {
      [ECommonTrialTipsType.EnterArea] = {PrimaryTextId = 4404002, SecondaryTextId = 4401006}
    },
    [ETrialType.BossArea] = {
      [ECommonTrialTipsType.Success] = {PrimaryTextId = 4404009, SecondaryTextId = 4401092},
      [ECommonTrialTipsType.Failed] = {PrimaryTextId = 4404010, SecondaryTextId = 4401014}
    }
  },
  DefaultStyle = {
    [ECommonTrialTipsType.EnterArea] = {
      PrimaryFontSize = 18,
      SecondaryFontSize = 18,
      PrimaryColor = FLinearColor(1.0, 1.0, 1.0, 0.7),
      SecondaryColor = FLinearColor(1.0, 1.0, 1.0, 1.0),
      DisplayDuration = 3.0,
      BehaviorMode = "Normal"
    },
    [ECommonTrialTipsType.Success] = {
      PrimaryFontSize = 18,
      SecondaryFontSize = 16,
      PrimaryColor = FLinearColor(1.0, 1.0, 1.0, 1.0),
      SecondaryColor = FLinearColor(1.0, 1.0, 1.0, 1.0),
      DisplayDuration = 5.0,
      BehaviorMode = "Normal"
    },
    [ECommonTrialTipsType.Failed] = {
      PrimaryFontSize = 18,
      SecondaryFontSize = 13,
      PrimaryColor = FLinearColor(1.0, 1.0, 1.0, 0.7),
      SecondaryColor = FLinearColor(1.0, 1.0, 1.0, 0.7),
      DisplayDuration = 5.0,
      BehaviorMode = "Normal"
    },
    [ECommonTrialTipsType.Ready] = {
      PrimaryFontSize = 18,
      SecondaryFontSize = 16,
      PrimaryColor = FLinearColor(1.0, 1.0, 1.0, 1.0),
      SecondaryColor = FLinearColor(1.0, 1.0, 0.0, 1.0),
      DisplayDuration = 5.0,
      BehaviorMode = "Countdown",
      CountdownTextMap = {
        Ready = 4404004,
        ["3"] = 4404005,
        ["2"] = 4404006,
        ["1"] = 4404007,
        Start = 4404008
      }
    },
    [ECommonTrialTipsType.Start] = {
      PrimaryFontSize = 18,
      SecondaryFontSize = 16,
      PrimaryColor = FLinearColor(1.0, 1.0, 1.0, 1.0),
      SecondaryColor = FLinearColor(1.0, 1.0, 1.0, 1.0),
      DisplayDuration = 3.0,
      BehaviorMode = "Normal"
    },
    [ECommonTrialTipsType.LeaveAreaWarning] = {
      PrimaryFontSize = 17,
      SecondaryFontSize = 13,
      PrimaryColor = FLinearColor(0.822786, 0.028426, 0.082283, 1),
      SecondaryColor = FLinearColor(1.0, 1.0, 1.0, 0.7),
      DisplayDuration = 0,
      BehaviorMode = "LeaveWarning",
      ShowExitButton = true
    }
  },
  WidgetSwitcherBg = {
    [ETrialType.TowerDefense] = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Image_SpartaTipsBg_png.ZD_Image_SpartaTipsBg_png",
    [ETrialType.EatPoint] = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Image_LightningRushTipsBg01_png.ZD_Image_LightningRushTipsBg01_png",
    [ETrialType.Parkour] = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Image_FlyingWingTipsBg_png.ZD_Image_FlyingWingTipsBg_png",
    [ETrialType.Football] = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Image_GriffinTipsBg_png.ZD_Image_GriffinTipsBg_png",
    [ETrialType.FramePlatform] = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Image_SHTTipsBg_png.ZD_Image_SHTTipsBg_png"
  }
}
return CommonTrialConfig