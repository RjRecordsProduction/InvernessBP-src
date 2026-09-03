local gamelet_define = require("client.slua.logic.gamelet.gamelet_define")
local GameletApp = gamelet_define.GameletApp
local HostedProxyConfig = {
  Pandora = {
    logicName = "client.slua.logic.Pandora.pandora_v2_adapter",
    sendFunc = "PandoraSendCmd",
    toSelf = true
  },
  [GameletApp.WOW_BBS] = {
    modulePath = "JumpModuleConfig",
    moduleName = "WowBBSJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.WOW_Center_Video] = {
    modulePath = "JumpModuleConfig",
    moduleName = "WowBBSJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.WOW_Center_Activity] = {
    modulePath = "JumpModuleConfig",
    moduleName = "WowBBSJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.SafetyCenter] = {
    modulePath = "JumpModuleConfig",
    moduleName = "SafetyCenterJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.Wiki] = {
    modulePath = "JumpModuleConfig",
    moduleName = "WikiJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.GameletAct] = {
    modulePath = "JumpModuleConfig",
    moduleName = "GameletActJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.creatorBase] = {
    modulePath = "JumpModuleConfig",
    moduleName = "CreatorBaseJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.WOW_Center_BenchmarkAuthor] = {
    modulePath = "JumpModuleConfig",
    moduleName = "WowBBSJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.WOW_Center_OfficialStory] = {
    modulePath = "JumpModuleConfig",
    moduleName = "WowBBSJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.NationalEsports_Official] = {
    modulePath = "JumpModuleConfig",
    moduleName = "NationalEsportsOfficialJumpModule",
    sendFunc = "SendCmd"
  },
  [GameletApp.NationalEsports_Entertainment] = {
    modulePath = "JumpModuleConfig",
    moduleName = "NationalEsportsEntertainmentJumpModule",
    sendFunc = "SendCmd"
  }
}
return HostedProxyConfig