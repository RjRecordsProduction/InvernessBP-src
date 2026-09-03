local FeatureCartoonStyle = {}
local Trait = require("common.trait")
local TFeatureCartoonStyle = Trait(Trait.TraitPrototype, nil, FeatureCartoonStyle)
function FeatureCartoonStyle:ChangeCartoonStyle(data)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.StopAction()
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local Cfg = LogicMultiItemModule:GetCartoonStyleCfg(self.curFeaturesItemID)
  if not Cfg then
    return
  end
  local displayItem
  if ModelDisplayer.HasEquiped(Cfg.BaseID) then
    displayItem = Cfg.CartoonStyleID
  else
    displayItem = Cfg.BaseID
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {displayItem})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    if state == PufferConst.ENUM_DownloadState.Not then
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {displayItem})
    end
    ShowNotice(511044)
    return
  end
  ModelDisplayer.Display(displayItem, true)
end
return TFeatureCartoonStyle