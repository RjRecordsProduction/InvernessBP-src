local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local SkyTransitionUtil = {}
function SkyTransitionUtil.ParseSkyTransitionConfig()
  local Result = {
    States = {},
    InitStateId = 1,
    CheckLocal = false
  }
  local SkyTransitionConfig = GamePlayTools.GetCurrentConfig("SkyTransitionConfig")
  if not SkyTransitionConfig or SkyTransitionConfig.Enable == false then
    return nil
  end
  for Id, StateConfig in pairs(SkyTransitionConfig) do
    if type(StateConfig) == "table" then
      local Config = {
        Id = Id,
        Name = StateConfig.Name,
        IsDefault = false,
        OriginSkyTransitionConfig = StateConfig
      }
      if StateConfig.IsDefault then
        Config.IsDefault = true
        Result.InitState      end
      table.insert(Result.States, Config)
    end
  end
  return Result
end
return SkyTransitionUtil