local ShaderPreCompileSystem = {
  ShaderCompile = false,
  TotalTimer = 0.0,
  Timeout = 120
}
function ShaderPreCompileSystem.HandleTimer(DeltaTime)
  if ShaderPreCompileSystem.ShaderCompile == true then
    ShaderPreCompileSystem.TotalTimer = ShaderPreCompileSystem.TotalTimer + DeltaTime
    local progress = Client.GetShaderPrecompileProgress()
    log(bWriteLog and "Client.GetShaderPrecompileProgress() = " .. tostring(progress) .. ", TotalTimer = " .. tostring(ShaderPreCompileSystem.TotalTimer))
    if 100 <= progress then
      log(bWriteLog and "ShaderPreCompileSystem.ShaderCompile end")
      local param = {result = "Success", reason = "Success"}
      Client.GEMReportEvent(GameFrontendHUD, "ShaderPrecompileEvent", param)
      ShaderPreCompileSystem.OnShaderPrecompileFinish()
    elseif ShaderPreCompileSystem.TotalTimer > ShaderPreCompileSystem.Timeout then
      log(bWriteLog and "ShaderPreCompileSystem.ShaderCompile timeout !!!")
      Client.StopShaderPrecompile()
      local param = {result = "Failed", reason = "Timeout"}
      Client.GEMReportEvent(GameFrontendHUD, "ShaderPrecompileEvent", param)
      ShaderPreCompileSystem.OnShaderPrecompileFinish()
    else
      local displayProgress = math.max(progress, ShaderPreCompileSystem.TotalTimer / ShaderPreCompileSystem.Timeout * 100)
      local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
      version_up_module:UpdateProgressBar(displayProgress, true)
    end
  end
end
function ShaderPreCompileSystem.StartShaderPrecompile()
  log(bWriteLog and "ShaderPreCompileSystem.StartShaderPrecompile()")
  ShaderPreCompileSystem.ShaderCompile = true
  ShaderPreCompileSystem.TotalTimer = 0
  local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
  version_up_module:StartShaderPreCompile()
end
function ShaderPreCompileSystem.OnShaderPrecompileFinish()
  local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
  if ShaderPreCompileSystem.ShaderCompile == true then
    ShaderPreCompileSystem.ShaderCompile = false
    version_up_module:StopShaderPreCompile()
  end
  ShaderPreCompileSystem.ShaderCompile = false
  ShaderPreCompileSystem.TotalTimer = 0
  version_up_module:OnFinishedShaderPreCompile()
end
function ShaderPreCompileSystem.OnFinishUpdate()
  local progress = Client.GetShaderPrecompileProgress()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsFITVersion() == true then
    progress = 100
  end
  if progress == 100 then
    log(bWriteLog and "progress == 100 before StartShaderPrecompile")
    local param = {
      result = "Success",
      reason = "HaveCompiled"
    }
    Client.GEMReportEvent(GameFrontendHUD, "ShaderPrecompileEvent", param)
    ShaderPreCompileSystem.OnShaderPrecompileFinish()
    return
  end
  local start = Client.StartShaderPrecompile()
  if start == true then
    progress = Client.GetShaderPrecompileProgress()
    if progress == 100 then
      log(bWriteLog and "progress == 100 after StartShaderPrecompile")
      local param = {
        result = "Success",
        reason = "HaveCompiled"
      }
      Client.GEMReportEvent(GameFrontendHUD, "ShaderPrecompileEvent", param)
      ShaderPreCompileSystem.OnShaderPrecompileFinish()
    else
      ShaderPreCompileSystem.StartShaderPrecompile()
    end
  else
    local param = {
      result = "Failed",
      reason = "StartFailed"
    }
    Client.GEMReportEvent(GameFrontendHUD, "ShaderPrecompileEvent", param)
    ShaderPreCompileSystem.OnShaderPrecompileFinish()
  end
end
return ShaderPreCompileSystem