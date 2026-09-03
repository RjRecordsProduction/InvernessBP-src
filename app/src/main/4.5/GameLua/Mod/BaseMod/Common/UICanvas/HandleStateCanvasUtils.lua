local HandleStateCanvasUtils = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function HandleStateCanvasUtils.RegisterCanvasVisibleEvent(uCanvasPanel, uCanvasUIRoot, sCanvasName)
  local CanvasPanelConfig = HandleStateCanvasUtils.GetCanvasPanelConfig(sCanvasName)
  if CanvasPanelConfig == nil then
    return
  end
  local HandleStateCanvasSubsystem = SubsystemMgr:Get("HandleStateCanvasSubsystem")
  if HandleStateCanvasSubsystem then
    HandleStateCanvasSubsystem:RegisterCanvasVisibleEvent(uCanvasPanel, uCanvasUIRoot, CanvasPanelConfig)
  end
end
function HandleStateCanvasUtils.GetCanvasPanelConfig(sCanvasName)
  if Client and Client.IsWindowOB() then
    local CanvasVisibleConfig_OB = GamePlayTools.GetCurrentConfig("CanvasVisibleConfig_OB")
    if CanvasVisibleConfig_OB and CanvasVisibleConfig_OB[sCanvasName] then
      return CanvasVisibleConfig_OB[sCanvasName]
    end
  end
  local CanvasVisibleConfig = GamePlayTools.GetCurrentConfig("CanvasVisibleConfig")
  if CanvasVisibleConfig and CanvasVisibleConfig[sCanvasName] then
    return CanvasVisibleConfig[sCanvasName]
  end
  return nil
end
function HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(uCanvasPanel)
  local HandleStateCanvasSubsystem = SubsystemMgr:Get("HandleStateCanvasSubsystem")
  if HandleStateCanvasSubsystem then
    HandleStateCanvasSubsystem:UnRegisterCanvasVisibleEvent(uCanvasPanel)
  end
end
return HandleStateCanvasUtils