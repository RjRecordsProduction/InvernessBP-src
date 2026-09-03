local Expression_Util = {
  FlauntType = {
    Pet = 1,
    MiliStone = 2,
    WolfTheme = 3,
    Popularity = 4,
    CardCollection = 5
  }
}
function Expression_Util.GetMotionGridMax()
  return DataMgr.MotionSlotMax or 10
end
function Expression_Util.GetMotionDataList()
  local expressionList = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local showingAvatar = TeamAvatarManager.GetMainAvatar()
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local isInXMission = XMissionSystem.IsInXMission()
  if isInXMission then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    showingAvatar = XMissionAvatarMgr.GetMainAvatar()
  end
  if showingAvatar then
    local CurWeaponID = showingAvatar:GetCurHoldingWeaponSkinID()
    local Cfg = CDataTable.GetTableData("WeaponAvatarBattleEffect", CurWeaponID)
    if Cfg then
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      if ItemUpgradeMgr:IsWeaponEmoteUnlockedWithOutCheckWeapon(Cfg.WeaponEmoteID) then
        table.insert(expressionList, {
          itemId = Cfg.WeaponEmoteID,
          bWeaponBindEmote = true
        })
      end
    end
  end
  if showingAvatar then
    local GloveID = showingAvatar:GetEquipedGloveID()
    local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
    local Cfg = CDataTable.GetTableData("CustomWeaponShow", GloveID)
    local ShowingModel = showingAvatar:GetModel()
    if ShowingModel then
      local CurGun = ShowingModel:GetCurUsingWeapon()
      if Cfg and not slua.isValid(CurGun) then
        table.insert(expressionList, {
          itemId = Cfg.WeaponShowEmoteID,
          bGloveBindEmote = true
        })
      end
    end
  end
  for i, v in ipairs(DataMgr.MotionSlotList) do
    local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(v)
    if itemData then
      local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
      if LogicXSuit.IsBattleEmotion(itemData.resID) then
        table.insert(expressionList, {itemId = 0})
      else
        table.insert(expressionList, {
          itemId = itemData.resID
        })
      end
    end
  end
  local logic_lobby_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_souvenirs)
  local lobbySouvenirsData = logic_lobby_souvenirs:GetMySouvenirsData()
  if lobbySouvenirsData and lobbySouvenirsData.motions then
    for index, emotionID in pairs(lobbySouvenirsData.motions) do
      local lobby_souvenirs_tool = require("client.slua.logic.souvenirs.lobby_souvenirs_tool")
      for k, v in pairs(lobbySouvenirsData.collection_set) do
        local giftItemInfoMap = lobby_souvenirs_tool.GetGiftItemInfoMapbyCollectionID(k)
        if giftItemInfoMap and giftItemInfoMap[emotionID] then
          table.insert(expressionList, {itemId = emotionID})
        end
      end
    end
  end
  local maxNum = Expression_Util.GetMotionGridMax()
  while maxNum > #expressionList do
    table.insert(expressionList, {itemId = 0})
  end
  return expressionList
end
function Expression_Util.GetPetActionList()
  local ArrayActionList = {}
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if logic_pet.MyPetInfo == nil then
    log(bWriteLog and "UI_Pet_Lobby_Action:InitActionList logic_pet.MyPetInfo == nil")
    return
  end
  local CurPetInsID = logic_pet.MyPetInfo.equip_pet_ins_id
  if CurPetInsID == 0 then
    log(bWriteLog and "UI_Pet_Lobby_Action:InitActionList equip_pet_ins_id = 0")
    return
  end
  local curPetID = logic_pet:ConvertToPetID(CurPetInsID)
  local PetActionCfg = logic_pet:GetPetActionCfg()
  local ActionDressMap = logic_pet:GetActionDressMap()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  for i, v in pairs(PetActionCfg) do
    if curPetID == v.PetID then
      local actionItemData = {}
      actionItemData.PetID = v.PetID
      actionItemData.ins_id = CurPetInsID
      actionItemData.PetActionID = v.PetActionID
      actionItemData.NeedLevel = logic_pet:GetUnlockActionNeedLevel(v.PetID, v.PetActionID)
      actionItemData.PetActionIcon = v.PetActionIcon
      if v.ShowInLobby == 1 then
        if ActionDressMap and ActionDressMap[v.PetActionID] ~= nil then
          local dressItemIDList = ActionDressMap[actionItemData.PetActionID]
          for _, dressItemID in ipairs(dressItemIDList) do
            if logic_pet:HasPetDress(CurPetInsID, dressItemID) and logic_pet:IsInDress(CurPetInsID, dressItemID) then
              actionItemData.NeedLevel = 0
              table.insert(ArrayActionList, 1, actionItemData)
              break
            end
          end
        else
          table.insert(ArrayActionList, actionItemData)
        end
      end
    end
  end
  return ArrayActionList
end
function Expression_Util.GetSouvenirsData()
  local souvenirsExpress = {}
  local souvenirsConfig = CDataTable.GetTable("SouvenirsTable")
  if not souvenirsConfig then
    return
  end
  local TableUtil = require("common.table_util")
  local logic_lobby_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_souvenirs)
  local lobbySouvenirsData = logic_lobby_souvenirs:GetMySouvenirsData()
  if not lobbySouvenirsData or not lobbySouvenirsData.motions then
    return souvenirsExpress
  end
  for index, emotionID in pairs(lobbySouvenirsData.motions) do
    local lobby_souvenirs_tool = require("client.slua.logic.souvenirs.lobby_souvenirs_tool")
    for k, v in pairs(lobbySouvenirsData.collection_set) do
      local giftItemInfoMap = lobby_souvenirs_tool.GetGiftItemInfoMapbyCollectionID(k)
      if giftItemInfoMap and not giftItemInfoMap[emotionID] then
        local souvenirsExpressionData = {emotionId = emotionID}
        table.insert(souvenirsExpress, souvenirsExpressionData)
      end
    end
  end
  Expression_Util.SortSouvenirsFunc(souvenirsExpress)
  return souvenirsExpress
end
function Expression_Util.SortSouvenirsFunc(souvenirsExpress)
  if not next(souvenirsExpress) then
    return
  end
  table.sort(souvenirsExpress, function(a, b)
    return a.emotionId < b.emotionId
  end)
end
function Expression_Util.PlayReviewExpression(actionID, bGot)
  local motionId = actionID
  local realMotionID = 0
  local itemCfg = CDataTable.GetTableData("Item", motionId)
  if itemCfg == nil then
    return
  end
  if GlobalData.IsJapanOrKorea() and 0 < itemCfg.JKBPID then
    realMotionID = itemCfg.JKBPID
  else
    realMotionID = itemCfg.BPID
  end
  local CoopEmoteUtil = require("GameLua.Activity.Commercialize.GamePlay.CoopEmote.CoopEmoteUtil")
  if not CoopEmoteUtil.CanShowInLobby(realMotionID) then
    ShowNotice(44712)
    return
  end
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local isInXMission = XMissionSystem.IsInXMission()
  local showingAvatar
  if isInXMission then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    showingAvatar = XMissionAvatarMgr.GetMainAvatar()
  else
    showingAvatar = TeamAvatarManager.GetMainAvatar()
  end
  local pet = showingAvatar and showingAvatar:GetPet()
  if pet ~= nil and pet:IsPlayingAction() then
    pet:StopAction()
  end
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if DataMgr.show_effect and LogicParticleEmote:HasUnlockParticle(realMotionID) then
    realMotionID = LogicParticleEmote:GetParticleEmoteID(realMotionID)
    log(bWriteLog and "[ParticleEmote]  ExpressionPopUIBP:OnClickLoopScrollGrid_0Item realMotionID:" .. tostring(realMotionID))
  end
  local myUid = DataMgr.roleData.uid
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local sex = logic_profile:GetRoleSexByUid(myUid, true)
  local LogicLobbyExpression = require("client.slua.logic.lobby.logic_lobby_expression")
  local randSoundId = LogicLobbyExpression.GetTauntRandSoundID(realMotionID, sex)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  if isInXMission then
    XMissionAvatarMgr.PlayAction(DataMgr.roleData.uid, realMotionID)
    LobbyAvatarManager.PlayEmotionSound(realMotionID, sex, randSoundId, DataMgr.roleData.uid)
  else
    LobbyAvatarManager.PlayEmoteAction(DataMgr.roleData.uid, realMotionID, sex, randSoundId)
  end
  if bGot then
    Expression_Util.OpenExpressionPopUI()
  end
end
function Expression_Util.OpenExpressionPopUI(actionID)
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission() then
    UIManager.ShowUI(UIManager.UI_Config.TExpressionPop_New_UIBP, actionID)
  else
    UIManager.ShowUI(UIManager.UI_Config.ExpressionPop_New_UIBP, actionID)
  end
end
function Expression_Util.GetExpressionPopUI()
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission() then
    return UIManager.GetUI(UIManager.UI_Config.TExpressionPop_New_UIBP)
  else
    return UIManager.GetUI(UIManager.UI_Config.ExpressionPop_New_UIBP)
  end
end
function Expression_Util.CloseExpressionPopUI()
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission() then
    UIManager.CloseUI(UIManager.UI_Config.TExpressionPop_New_UIBP)
  else
    UIManager.CloseUI(UIManager.UI_Config.ExpressionPop_New_UIBP)
  end
end
function Expression_Util.OpenFunPropListUI()
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission() then
    UIManager.ShowUI(UIManager.UI_Config.TLobby_Main_FunProp_List_UIBP)
  else
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Main_FunProp_List_UIBP)
  end
end
function Expression_Util.CloseFunPropListUI()
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission() then
    UIManager.CloseUI(UIManager.UI_Config.TLobby_Main_FunProp_List_UIBP)
  else
    UIManager.CloseUI(UIManager.UI_Config.Lobby_Main_FunProp_List_UIBP)
  end
end
function Expression_Util.PlayExpression(actionID)
  log(bWriteLog and "Expression_Util.PlayExpression actionID=" .. tostring(actionID))
  local motionId = actionID
  local realMotionID = 0
  local itemCfg = CDataTable.GetTableData("Item", motionId)
  if itemCfg == nil then
    return
  end
  if GlobalData.IsJapanOrKorea() and 0 < itemCfg.JKBPID then
    realMotionID = itemCfg.JKBPID
  else
    realMotionID = itemCfg.BPID
  end
  local CoopEmoteUtil = require("GameLua.Activity.Commercialize.GamePlay.CoopEmote.CoopEmoteUtil")
  if not CoopEmoteUtil.CanShowInLobby(realMotionID) then
    ShowNotice(44712)
    return
  end
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local isInXMission = XMissionSystem.IsInXMission()
  local showingAvatar
  if isInXMission then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    showingAvatar = XMissionAvatarMgr.GetMainAvatar()
  else
    showingAvatar = TeamAvatarManager.GetMainAvatar()
  end
  local pet = showingAvatar and showingAvatar:GetPet()
  if pet ~= nil and pet:IsPlayingAction() then
    pet:StopAction()
  end
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if DataMgr.show_effect and LogicParticleEmote:HasUnlockParticle(realMotionID) then
    realMotionID = LogicParticleEmote:GetParticleEmoteID(realMotionID)
    log(bWriteLog and "[ParticleEmote]  ExpressionPopUIBP:OnClickLoopScrollGrid_0Item realMotionID:" .. tostring(realMotionID))
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local sex = AvatarData.GetGameGender()
  local LogicLobbyExpression = require("client.slua.logic.lobby.logic_lobby_expression")
  local randSoundId = LogicLobbyExpression.GetTauntRandSoundID(realMotionID, sex)
  local extraInfo = LogicLobbyExpression.GetExtraInfo(realMotionID)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local bCanPlay = true
  if isInXMission then
    bCanPlay = XMissionAvatarMgr.PlayAction(DataMgr.roleData.uid, realMotionID, extraInfo)
    LobbyAvatarManager.PlayEmotionSound(realMotionID, sex, randSoundId, DataMgr.roleData.uid)
  else
    bCanPlay = LobbyAvatarManager.PlayEmoteAction(DataMgr.roleData.uid, realMotionID, sex, randSoundId, nil, extraInfo)
  end
  local extraParam
  if extraInfo then
    extraParam = {extraInfo = extraInfo}
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and bCanPlay then
    TeamUpNewSystem.team_player_action(motionId, randSoundId, extraParam)
    if TeamUpNewSystem.IsTeamLeader() and TeamUpNewSystem.CheckEmoteCanFollow(realMotionID) then
      local FollowerUIDS = TeamUpNewSystem.GetEmoteFollowersUID()
      for _, uid in pairs(FollowerUIDS) do
        local EmoteID = TeamUpNewSystem.GetFollowPlayEmoteID(uid, realMotionID)
        if isInXMission then
          XMissionAvatarMgr.PlayAction(uid, EmoteID, extraInfo)
          LobbyAvatarManager.PlayEmotionSound(EmoteID, logic_profile:GetRoleSexByUid(uid, true), randSoundId, uid)
        else
          LobbyAvatarManager.PlayEmoteAction(uid, EmoteID, logic_profile:GetRoleSexByUid(uid, true), nil, nil, extraInfo)
        end
      end
    end
  end
end
function Expression_Util.StopExpression()
  log(bWriteLog and "Expression_Util.StopExpression")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local currentActionID = TeamAvatarManager.GetCurrentAction(DataMgr.roleData.uid)
  log(bWriteLog and "Expression_Util.StopExpression currentActionID:" .. tostring(currentActionID))
  if not currentActionID or currentActionID <= 0 then
    log(bWriteLog and "Expression_Util.StopExpression not play expression")
    return
  end
  log(bWriteLog and "Expression_Util.StopExpression stop my action")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.StopPlayerAction(DataMgr.roleData.uid)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    local extraParam = {stopAction = true}
    TeamUpNewSystem.team_player_action(currentActionID, 0, extraParam)
  end
end
function Expression_Util.GetFlauntData()
  local Data = {}
  Expression_Util.AddFlauntPetData(Data)
  Expression_Util.AddFlauntMileStoneData(Data)
  Expression_Util.AddFlauntWolfThemeData(Data)
  Expression_Util.AddFlauntPopularAwardData(Data)
  Expression_Util.AddCardCollectionActionData(Data)
  return Data
end
function Expression_Util.AddFlauntPetData(Data)
  local PetExhibitConfig = require("client.lobby_ue_object.Actor.PetExhibit.PetExhibitConfig")
  local _petData = {
    Type = Expression_Util.FlauntType.Pet,
    ItemID = PetExhibitConfig.PlayerActionID
  }
  table.insert(Data, _petData)
end
function Expression_Util.AddFlauntMileStoneData(Data)
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  local emoMark = LobbyEmoteManager:GetMilestoneEmotionMark()
  local TableUtil = require("common.table_util")
  if TableUtil.CountTable(emoMark) < 1 then
    log(bWriteLog and "Expression_Util.AddFlauntMileStoneData not MileList")
    return
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local List = WardrobeData:GetMileStoneEmoteList()
  for key, _ItemID in pairs(List) do
    if emoMark[_ItemID] then
      table.insert(Data, {
        Type = Expression_Util.FlauntType.MiliStone,
        ItemID = _ItemID
      })
    end
  end
end
function Expression_Util.AddFlauntWolfThemeData(Data)
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  table.insert(Data, {
    Type = Expression_Util.FlauntType.WolfTheme,
    ItemID = ShowBrandConst.GeneralEmoteId
  })
end
function Expression_Util.AddFlauntPopularAwardData(Data)
  local cfg = CDataTable.GetTable("PopularityCeremonyActionCfg")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for k, v in pairs(cfg) do
    if wardrobe_data:HasValidItem(v.ActionID) then
      table.insert(Data, {
        Type = Expression_Util.FlauntType.Popularity,
        ItemID = v.ActionID
      })
    end
  end
end
function Expression_Util.AddCardCollectionActionData(Data)
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  local actionID = logic_card_collection:GetActionItemID()
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  if logic_card_collection:HasUnlockAction() or StoreUtils.HasItem(actionID) then
    table.insert(Data, {
      Type = Expression_Util.FlauntType.CardCollection,
      ItemID = actionID
    })
  end
end
return Expression_Util