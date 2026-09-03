local SKATE_BUILDING_ID = 56
local SKATE_ITEM_ID = 602128
local SkillActorInst = {
  Inst = {
    SkillData = {bAutoShowRegisteredSkillUI = true},
    [0] = {
      HandleBuildItemLimit01 = {BuildingID = SKATE_BUILDING_ID},
      OverrideBuildingConfiguration01 = {BuildingID = SKATE_BUILDING_ID},
      EnableBuildSystem01 = {BuildingID = SKATE_BUILDING_ID},
      HandleItemLimit01 = {ItemID = SKATE_ITEM_ID},
      PostOneLuaEvent01 = {
        ExecuteEventType = "EVENTTYPE_LIBRARY",
        ExecuteEventId = "EVENTID_LIBRARY_SHOW_CANCEL_BUILD_BTN",
        EndEventType = "EVENTTYPE_LIBRARY",
        EndEventId = "EVENTID_LIBRARY_HIDE_CANCEL_BUILD_BTN"
      }
    },
    [1] = {
      HandleBuildItemLimit01 = {BuildingID = SKATE_BUILDING_ID},
      EnableBuildSystem01 = {BuildingID = SKATE_BUILDING_ID},
      HandleItemLimit01 = {ItemID = SKATE_ITEM_ID}
    },
    [2] = {
      ActionWithConditions01 = {
        Action = {ShowPrompt = true, PromptID = 506087},
        FalseAction = {ShowPrompt = true, PromptID = 24402}
      }
    },
    [3] = {
      ConsumeHandleItem01 = {ItemID = SKATE_ITEM_ID}
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst