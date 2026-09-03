local collect_guide_module = {}
function collect_guide_module:DefineAndResetData()
  self.bShowGuide = false
end
function collect_guide_module:ShowLevelGuide(callback)
  log_warning(bWriteLog and "  collect_module:ShowLevelGuide.  " .. tostring(self.bShowGuide))
  if self.bShowGuide then
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and string.format("collect_guide_module:ShowLevelGuide current is new guide."))
    return
  end
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if tonumber(DataMgr.roleData.uid) ~= tonumber(RoleInfoSystem.CurShowPlayerInfoUid) then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local show = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectLevelUp)
  log_warning(bWriteLog and "  collect_module:ShowLevelGuide. : show" .. tostring(show))
  if not show or show == 0 then
    local common_config = require("client.slua.common.common_config")
    if not common_config:IsBlockingPopupTip() then
      self.bShowGuide = true
      UIManager.ShowUI(UIManager.UI_Config.Collect_Guide_UIBP, callback)
    end
    PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eCollectLevelUp)
    return true
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_guide_module)
return CModuleTemplate