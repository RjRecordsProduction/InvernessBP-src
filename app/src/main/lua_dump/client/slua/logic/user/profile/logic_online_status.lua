local logic_online_status = {}
function logic_online_status:DefineAndResetData()
  self.dicOnlionStatus = {}
end
function logic_online_status:ClearItemByUid(uid)
  self.dicOnlionStatus[uid] = nil
end
function logic_online_status:GetItemByUid(uid)
  return self.dicOnlionStatus[uid]
end
function logic_online_status:proc_batch_get_group_and_online_rsp(listType, res, info)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile_config = require("client.slua.logic.user.profile.profile_config")
  for k, v in pairs(info) do
    local profile = logic_profile:GetLocalProfile(k) or {
      uid = tostring(k)
    }
    for kk, vv in pairs(profile_config.Online2ProfileKey) do
      local realValue = vv.key and v[vv.key] or v[kk]
      if vv.func then
        realValue = vv.func(realValue)
      end
      profile[kk] = realValue
    end
    self.dicOnlionStatus[k] = profile
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_online_status)