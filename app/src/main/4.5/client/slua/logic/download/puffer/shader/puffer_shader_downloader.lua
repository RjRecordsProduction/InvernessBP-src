local puffer_shader_downloader = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
function puffer_shader_downloader:OnDownloadFinish(task, outterTaskID, isSuccess, errorCode)
  log(bWriteLog and string.format("puffer_shader_downloader:OnDownloadFinish task:%s, outterTaskID:%s, isSuccess:%s, errorCode:%s", task, outterTaskID, isSuccess, errorCode))
  local PufferShaderManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_shader_manager)
  local shaderName = task.pakName
  if isSuccess then
    PufferShaderManager.ShaderPaks[shaderName].state = PufferConst.ENUM_DownloadState.Done
    Client.OpenShaderCodeLibrary(Client.ProjectSavedDir() .. "Paks/", shaderName)
  else
    PufferShaderManager.ShaderPaks[shaderName].state = PufferConst.ENUM_DownloadState.Error
  end
  PufferManager.Download(PufferConst.ENUM_DownloadType.RES, {
    PufferConst.PUFFERPATCH
  })
  puffer_shader_downloader.__super:OnDownloadFinish(task, errorCode)
end
function puffer_shader_downloader:DownloadByKeyList(downloadType, keyList, from, callback, extraData)
  for _, mapKey in pairs(keyList) do
    self:DownloadByMapKey(mapKey)
  end
end
function puffer_shader_downloader:DownloadByMapKey(mapKey)
  local PufferShaderManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_shader_manager)
  for i, v in pairs(PufferShaderManager.MapToShaders) do
    if string.find(i, mapKey) then
      for _, shaderName in pairs(v) do
        if PufferShaderManager:GetState(shaderName) ~= PufferConst.ENUM_DownloadState.Done then
          self:Download(shaderName, mapKey)
        end
      end
      return
    end
  end
end
function puffer_shader_downloader:Download(shaderName, mapKey)
  local task = {}
  task.  task.pakName = shaderName
  task.downloadType = PufferConst.ENUM_DownloadType.SHADER
  puffer_shader_downloader.__super:Download(task)
  local PufferShaderManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_shader_manager)
  PufferShaderManager.ShaderPaks[shaderName].state = PufferConst.ENUM_DownloadState.Download
end
local class = require("class")
local CPufferBase = require("client.slua.logic.download.puffer.puffer_base_downloader")
local CPufferRes = class(CPufferBase, nil, puffer_shader_downloader)
return CPufferRes