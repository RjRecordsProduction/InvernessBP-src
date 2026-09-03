local TableUtil = require("common.table_util")
local EPawnState = import("EPawnState")
local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
local FlyingWingConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.FlyingWing.FlyingWingConfig")
local BaseCanvasVisibleConfig = require("GameLua.Mod.BaseMod.Client.Config.CanvasVisibleConfig")
local CanvasVisibleConfig = TableUtil.CopyTable(BaseCanvasVisibleConfig)
local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
CanvasVisibleConfig.ShootingUIPanel_CanvasPanel_Root.ShowHideUIWithFlag = {
  Hide = {
    [ShowHideUIFlag.bInFootballTrial] = true
  }
}
CanvasVisibleConfig.MainControlBaseUI_CanvasPanel_QuickSign.ShowHideUIWithFlag = {
  Hide = {
    [ShowHideUIFlag.bInFootballTrial] = true
  }
}
CanvasVisibleConfig.MainControlBaseUI_CanvasPanel_FreeCamera.ShowHideUIWithFlag = {
  Hide = {
    [ShowHideUIFlag.bInFootballTrial] = true
  }
}
CanvasVisibleConfig.MainControlBaseUI_CanvasPanel_MiniMapAndSetting.ShowHideUIWithFlag.Hide[ShowHideUIFlag.bInFootballTrial] = true
CanvasVisibleConfig.CanvasPanelBackpackPanel.ShowHideUIWithFlag = {
  Hide = {
    [ShowHideUIFlag.bInFootballTrial] = true
  }
}
CanvasVisibleConfig.PickUpListPanel_BP_Root.ShowHideUIWithFlag = {
  Hide = {
    [ShowHideUIFlag.bInFootballTrial] = true
  }
}
CanvasVisibleConfig.NavigatorPanel_CanvasPanelRoot.ShowHideUIWithFlag = {
  Hide = {
    [ShowHideUIFlag.bInFootballTrial] = true
  }
}
CanvasVisibleConfig.QuickExpressionDecalUI_CanvasPanelRoot.ShowHideUIWithFlag = {
  Hide = {
    [ShowHideUIFlag.bInFootballTrial] = true
  }
}
CanvasVisibleConfig.BasicSkillsMenu_BP.ShowHideUIWithFlag.Hide[ShowHideUIFlag.bInFootballTrial] = true
CanvasVisibleConfig.GodTrialHonorPanel_CanvasPanel_Root = {
  PhotoGrapherState = {Hide = true},
  SpectatorReplay = {
    Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Global | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay | ESpectatorReplayFlag.ESpectatorReplayFlag_Pure
  }
}
CanvasVisibleConfig.BasicSkillsMenu_BP.Skill = {
  Hide = {
    FlyingWingConfig.SkillID
  }
}
CanvasVisibleConfig.PickUpListPanel_BP_Root.Skill = {
  Hide = {
    1014711,
    FlyingWingConfig.SkillID
  }
}
CanvasVisibleConfig.ShootingUIPanel_SkillLayer.Skill = {
  Hide = {
    FlyingWingConfig.SkillID
  }
}
return CanvasVisibleConfig