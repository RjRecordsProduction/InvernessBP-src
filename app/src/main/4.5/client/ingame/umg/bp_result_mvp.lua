ResultMVPUI = ResultMVPUI or {isShowingDeathMatch = false}
function _ENV:bp_result_mvp_RegisterUI()
  print(bWriteLog and "bp_result_mvp_RegisterUI")
end
BP_STRUCT_MVP_AvatarInfo = {
  ItemID = 401999,
  ColorID = 0,
  PatternID = 0
}
BP_ARRAY_MVP_AvatarList = {
  BP_STRUCT_MVP_AvatarInfo = _G.BP_STRUCT_MVP_AvatarInfo
}
BP_STRUCT_MVP_AvatarProfile = {
  uid = "",
  picUrl = "",
  level = 0,
  cur_avatar_box_id = 0
}
BP_ARRAY_MVP_TeammateProfile = {
  BP_STRUCT_MVP_AvatarProfile = _G.BP_STRUCT_MVP_AvatarProfile
}
BP_STRUCT_MVP_SpawnPlayerRoleInfo = {
  uid = "",
  gid = "",
  sex = 1,
  headId = 401999,
  index = 1,
  weaponId = 0,
  weaponSkinId = 0,
  weaponSkinDIYPlanId = 0,
  playerName = "",
  resultAvatarPose = 0,
  PetId = 0,
  PetLevel = 0,
  PetAvatarID = 0,
  Kill = 0,
  DamageAmount = 0,
  surviveTime = 0,
  SupportScore = 0,
  Assists = 0,
  Deaths = 0,
  RescueTimes = 0,
  BP_ARRAY_MVP_AvatarList = _G.BP_ARRAY_MVP_AvatarList
}
BP_Result_MVP_ID = 4100000
BP_Result_Team_Rank = 1
BP_Result_MVP_Delay = 0
BP_Result_MVP_ResultType = 0
BP_Result_MVP_Signature = ""
BP_Result_Mvp_Area_Segment_Level = 0
BP_Result_MVP_SUB_MODE = 0
function ResultMVP_DynamicCreateUI(rank, delay, resultType, subMode)
  BP_Result_MVP_Signature = ""
  log(bWriteLog and "ResultMVP_DynamicCreateUI: rank: " .. rank .. " delay: " .. delay .. " resultType: " .. resultType .. " subMode: " .. subMode)
  BP_Result_Team_Rank = rank
  BP_Result_MVP_Delay = delay
  BP_Result_MVP_ResultType = resultType
  BP_Result_MVP_SUB_MODE = subMode
  ResultMVPUI.GetMvpSignatureProfile()
  LuaClassObj.HandleDynamicCreation(bp_result_mvp)
  LuaClassObj.HandleUIMessage(bp_result_mvp, "ShowBattleMVPUI")
end
function EventResultMVPEnd()
  if ResultMVPUI.isShowingDeathMatch == false then
    BattleResultUI.OnResultMVPShowEnd()
  else
    DeathMatchResultUI.OnResultMVPShowEnd()
  end
end
function ResultMVPUI.ImageCallBack(list)
  BP_ARRAY_MVP_TeammateProfile = {}
  for i = 1, #list do
    table.insert(BP_ARRAY_MVP_TeammateProfile, {
      uid = list[i].uid,
      picUrl = list[i].picUrl,
      level = list[i].level,
      cur_avatar_box_id = list[i].cur_avatar_box_id
    })
  end
  table.insert(BP_ARRAY_MVP_TeammateProfile, {
    uid = DataMgr.roleData.uid,
    picUrl = DataMgr.roleData.headIconUrl,
    level = DataMgr.roleData.level,
    cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
  })
  LuaClassObj.HandleUIMessage(bp_result_mvp, "ImageCallBack")
  local UIUtil = require("client.common.ui_util")
  local uiRoot = UIUtil.GetWidgetByName("bp_result_mvp", "Battle_Show_MVP_UIBP")
  if uiRoot then
    uiRoot.Common_Avatar_BP:SetButtonEnabled(false)
  end
end
function ResultMVPUI.GetMvpSignatureProfile()
  if BP_STRUCT_MVP_SpawnPlayerRoleInfo ~= nil then
    log(bWriteLog and "ResultMVPUI.GetMvpSignatureProfile uid: " .. tostring(BP_STRUCT_MVP_SpawnPlayerRoleInfo.uid))
    local idlist = {}
    table.insert(idlist, BP_STRUCT_MVP_SpawnPlayerRoleInfo.uid)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(idlist, ResultMVPUI.OnBatchGetProfileRsp, Enum_PROFILE_REPORT_CFG.RESULT_MVP)
  end
end
function ResultMVPUI.OnBatchGetProfileRsp(profileList)
  if profileList[1] ~= nil then
    log_tree("ResultMVPUI.OnBatchGetProfileRsp", profileList[1])
    BP_Result_MVP_Signature = profileList[1].signature or ""
    LuaClassObj.HandleDynamicCreation(bp_result_mvp)
    LuaClassObj.HandleUIMessage(bp_result_mvp, "UpdateSignature")
  end
end
function ResultMVPUI.SetAceImprintIcon(AceImprintShowID, AceImprintBaseID)
  local UIUtil = require("client.common.ui_util")
  local uiRoot = UIUtil.GetWidgetByName("bp_result_mvp", "Battle_Show_MVP_UIBP")
  local nAceImprintShowID = tonumber(AceImprintShowID)
  if uiRoot and nAceImprintShowID then
    local AceImprintIcon = uiRoot.Common_KingMark_UIBP
    if AceImprintIcon == nil then
      return
    end
    local nAceImprintBaseID = AceImprintBaseID and tonumber(AceImprintBaseID) or 0
    local AceImprintLogic = require("client.logic.season.AceImprintLogic")
    if AceImprintLogic then
      AceImprintLogic.SetAceImprintImage(AceImprintIcon, nAceImprintShowID, nAceImprintBaseID)
    end
  end
end
function ResultMVPUI.ShowShareUI()
  log(bWriteLog and "[v_ywuyuan] ResultMVPUI.ShowShareUI")
  local ShareDataList = require("client.logic.share.share_data")
  local MedalDataList = {}
  local teammateList = BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList
  log_tree("[chub] teammateList = ", teammateList)
  for _, info in pairs(teammateList or {}) do
    if BP_myname == info.Name and info.Achievements then
      for i = 1, 6 do
        if info.Achievements[i] then
          local data = {}
          data.Type = i
          data.bShow = true
          table.insert(MedalDataList, data)
        end
      end
    end
  end
  log_tree("[chub] MedalDataList = ", MedalDataList)
  local segmentLevel = 0
  local UIUtil = require("client.common.ui_util")
  local uiRoot = UIUtil.GetWidgetByName("bp_result_mvp", "Battle_Show_MVP_UIBP")
  if uiRoot then
    log(bWriteLog and "[v_ywuyuan] ResultMVPUI.ShowShareUI" .. ":" .. tostring(uiRoot.segmentLevel))
    segmentLevel = uiRoot.segmentLevel
  end
  local cfg = {
    isOld = true,
    shareData = ShareDataList.MEDIA_TAG_SHARE_RESULT,
    bShowPoseSelect = true,
    segmentLevel = segmentLevel,
    MedalDataList = MedalDataList,
    checkargs = {
      [1] = {
        name = LocUtil.GetLocalizeResStr(39150),
        bopen = true
      }
    },
    reasonStr = json.encode({buttonStr = "MVPBtn"})
  }
  log_tree("[v_ywuyuan] ResultMVPUI.ShowShareUI cfg", cfg)
  local MvpShareUIData = {
    BP_STRUCT_MVP_SpawnPlayerRoleInfo = BP_STRUCT_MVP_SpawnPlayerRoleInfo,
    TeamModeName = GetTeamModeName(),
      }
  local Util = require("client.slua_ui_framework.util")
  Util.ShowShare(cfg, UIManager.UI_Config.Battle_Show_MVP_New_UIBP, MvpShareUIData)
  ShareMgr.ReportClickShare("MVPBtn")
end