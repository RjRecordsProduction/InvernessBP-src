local Collect_Room_UIBP = {}
local NCol = 5
local CNoLike = 3
local MyLike = 1
local CollectHandler = require("client.network.Protocol.CollectHandler")
local Trait = require("common.trait")
local ui_base = require("GameLua.Mod.Lobby.Split.Collect.umg.Road.Collect_JumpBase")
local Traits = {
  require("client.slua.umg.common.share.share_use_trait")
}
local CCollect_Room_UIBP = Trait.TraitClass(ui_base, nil, Collect_Room_UIBP, Traits)
function Collect_Room_UIBP:ctor()
  self.gridData = nil
  self.nLikeNum = 0
  self.bEquipped = nil
  self.voteData = {}
  self.votedData = {}
  self._bIsSharing = false
  self._cObj_captureUI = nil
  self.milestoneGuideTimer = nil
end
function Collect_Room_UIBP:OnInitialize()
  Collect_Room_UIBP.__super.OnInitialize(self)
  self.LoopScrollGrid_0 = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_0, "GameLua.Mod.Lobby.Split.Collect.umg.Room.Item.Collect_Room_Item01_UIBP")
  self.LoopScrollGrid_Milestone = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Milestone, "GameLua.Mod.Lobby.Split.Collect.umg.Room.Item.Collect_Room_Milestone_Item_UIBP")
end
function Collect_Room_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Share, self.OnClickButton_Share, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Like, self.OnClickButton_Like, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_DressUp, self.OnClickButton_DressUp, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Entrance, self.OnClickButton_Entrance, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_SEND_GIFT_RSP, self.RequireUpvoteInfo, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_MAIN_DATA, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_DETAIL_DATA, self.OnDetailDataReq, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_UPVOTE_INFO, self.UpdateUpvoteInfo, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_CANCEL_UPVOTE, self.OnCancelUpvote, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_PASTE_COLLECT_BADGE, self.OnPasteCollectBadge, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_CHANGE_BG, self.OnChangeBgResponse, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_CHANGE_FRAME, self.OnChangeFrameResponse, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_REFRESH_MILESTONE_SLOTS, self.OnSetMilestoneList, self)
  self:AddOnAnimationFinishedEvent("Fadein", self.ShowGuide1, self)
end
function Collect_Room_UIBP:OnPostInitialize()
  local widget = self.UIRoot
  widget.TextBlock_Entrance:SetText(LocUtil.GetLocalizeResStr(880060104))
  self:PlayWidgetAnimation(widget, widget.FadeIn, 0, 1, 0, 1)
  local Logic_SC_DownloadTools = require("client.slua.logic.lobby.Left.SocialLobby.Logic_SC_DownloadTools")
  local bIsSysOpen = Logic_SC_DownloadTools.GetPlanCHIsOpen()
  self:SetWidgetVisible(widget.Button_Entrance, bIsSysOpen, true)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  self.nUid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
  self.bIsSelf = self.nUid == tonumber(DataMgr.roleData.uid)
  log_warning(bWriteLog and "  Collect_Room_UIBP:OnPostInitialize. self.bIsSelf: " .. tostring(self.bIsSelf))
  self:SetWidgetVisible(self.UIRoot.Button_Share, self.bIsSelf, true)
  self:SetWidgetVisible(self.UIRoot.Button_DressUp, self.bIsSelf, true)
  CollectHandler.send_get_collect_detail_req(self.nUid, 1)
  log_warning(bWriteLog and "  Collect_Room_UIBP:OnPostInitialize. self.nUid: " .. tostring(self.nUid))
  self:RequireUpvoteInfo()
  self:ShowMilestoneGuide()
  self:SetDefaultCountBoard()
  self:ShowSpecialNum()
end
function Collect_Room_UIBP:OnClose()
  if UIManager.GetUI(UIManager.UI_Config.NewbieGuide_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
  end
  Collect_Room_UIBP.__super.OnClose(self)
end
function Collect_Room_UIBP:ShowGuide()
  if not self.UIRoot then
    return
  end
  if self.bEquipped then
    log_warning(bWriteLog and "  Collect_Room_UIBP:ShowGuide.  self.bEquipped")
    return
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local TableUtil = require("common.table_util")
  local list = TableUtil.GetTableValue(collect_module.collect_data, "badge_list")
  if not list or not next(list) then
    log_warning(bWriteLog and "  Collect_Room_UIBP:ShowGuide.  no badge_list")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local show = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectRoom)
  log_warning(bWriteLog and "  Collect_Room_UIBP:ShowGuide. show: " .. tostring(show))
  if not show or show == 0 then
    local callBack = function()
      PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eCollectRoom)
    end
    local word = LocUtil.GetLocalizeResStr(77551)
    UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 1, word, self.UIRoot.CanvasPanel_guide1, callBack, true, 1, nil, nil)
  end
end
function Collect_Room_UIBP:ShowGuide1()
  local collect_guide_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_guide_module)
  if not collect_guide_module:ShowLevelGuide(function()
    self:ShowGuide()
  end) then
    self:ShowGuide()
  end
end
function Collect_Room_UIBP:ShowMilestoneGuide()
  if self.milestoneGuideTimer then
    self:RemoveTimer(self.milestoneGuideTimer)
    self.milestoneGuideTimer = nil
  end
  self.milestoneGuideTimer = self:AddTimerOnce(1.6, function()
    self.milestoneGuideTimer = nil
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local milestoneGuide = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectRoom_Milestone)
    log(bWriteLog and string.format("Collect_Room_UIBP:ShowMilestoneGuide milestoneGuide:" .. tostring(milestoneGuide)))
    if milestoneGuide and milestoneGuide == 1 then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 1, LocUtil.GetLocalizeResStr(77733), self.UIRoot.LoopScrollBox_Milestone, nil, false, 1)
    PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eCollectRoom_Milestone)
  end)
end
function Collect_Room_UIBP:RequireUpvoteInfo()
  local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
  ModCollectHandler.send_get_collect_sys_upvote_info_req(self.nUid)
end
function Collect_Room_UIBP:UpdateUpvoteInfo(_, __, other_uid, upvote_count, upvote_record, upvoted_record)
  self.voteData = upvote_record or {}
  self.votedData = upvoted_record or {}
  if other_uid == self.nUid then
    self:OnGetVoteData(upvote_count)
  end
  self:RefreshGuest()
end
local state2LikeIcon = {
  "/Game/UMG/Texture_200/Atlas/RoleInfo/Frames/Collect_Room_Good01_png.Collect_Room_Good01_png",
  "/Game/UMG/Texture_200/Atlas/RoleInfo/Frames/Collect_Room_Good03_png.Collect_Room_Good03_png",
  "/Game/UMG/Texture_200/Atlas/RoleInfo/Frames/Collect_Room_Good02_png.Collect_Room_Good02_png"
}
function Collect_Room_UIBP:SetLikeIcon(state)
  log_warning(bWriteLog and "  Collect_Room_UIBP:SetLikeIcon. state: " .. tostring(state))
  self:SetTexture(self.UIRoot.Image_Icon, state2LikeIcon[state])
end
function Collect_Room_UIBP:RefreshGuest()
  if self.bIsSelf then
    self:SetLikeIcon(MyLike)
    return
  end
  local state = 3
  for _, uid in ipairs(self.voteData) do
    if uid == self.nUid then
      state = 2
      break
    end
  end
  self:SetLikeIcon(state)
end
function Collect_Room_UIBP:OnGetData()
  local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
  self:ShowOrHideJump()
  if self.bIsSelf then
    CollectHandler.send_get_collect_sys_main_data_req()
  else
    self:OnChangeBadgeData(collect_room_module:GetBadgeData())
    local _, sLevel = self:ShowCollect()
    self:UpdateBackGround(sLevel)
  end
end
function Collect_Room_UIBP:UpdateUI()
  if self.UIRoot then
    if not self.bIsSelf then
      return
    end
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    local collect_data = collect_module.collect_data
    local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
    self:OnPopupDetectionPrompt()
    self:OnChangeBadgeData(collect_room_module:GetBadgeData())
    self:OnChangeBg(collect_data.cur_sticker_bg)
    self:OnChangeFrame(collect_data.cur_sticker_frame)
    local _, sLevel = self:ShowCollect()
    self:UpdateBackGround(sLevel)
  end
end
function Collect_Room_UIBP:OnDetailDataReq(_, _, data, other_uid)
  if tostring(self.nUid) ~= tostring(other_uid) then
    log(bWriteLog and string.format("Collect_Room_UIBP:OnDetailDataReq uid mismatch, selfUid=%s other_uid=%s", tostring(self.nUid), tostring(other_uid)))
    return
  end
  self:ShowSpecialNum(_, _, data, other_uid)
  self:OnGetData()
  if not data then
    log(bWriteLog and string.format("Collect_Room_UIBP:OnDetailDataReq data is nil."))
    return
  end
  self:OnChangeBg(data.cur_sticker_bg)
  self:OnChangeFrame(data.cur_sticker_frame)
  self:OnSetMilestoneList()
end
function Collect_Room_UIBP:UpdateBackGround(level)
  local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
  local path = "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Bg01.Collect_Bg01"
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(self.nUid)
  local collect_data = profile and profile.collect_data
  local collect_badge_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_badge_module)
  if collect_room_module:OtherIsLight(level, self.nUid) and collect_badge_module:CheckCanLightBadge(self.nUid, collect_data) then
    path = "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Bg02.Collect_Bg02"
  end
  self:SetTexture(self.UIRoot.Image_Bg, path)
end
function Collect_Room_UIBP:ShowCollect()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_data = collect_module.collect_data
  local score, seasonScore = 0, 0
  local TableUtil = require("common.table_util")
  local season = collect_module:GetSeasonId()
  if not self.bIsSelf then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(self.nUid)
    collect_data = profile and profile.collect_data
    score, seasonScore = collect_module:GetCollectScoreByCollectData(collect_data)
  else
    score = collect_data.total_score
    seasonScore = TableUtil.GetTableValue(collect_module.collect_data.season_score, season) or 0
  end
  local CollectLevelCfg = collect_module:GetSplitTable("CollectLevel", collect_module.E_ColCfgMode.JK)
  local preScore, nextScore, l = 0, 0, 1
  local curLevel, nextLevel, levelName = 1, 1, ""
  for level, v in pairs(CollectLevelCfg) do
    nextScore = v.Score
    nextLevel = tonumber(level)
    l = v.Dan
    if score >= nextScore then
      preScore = nextScore
    else
      curLevel = nextLevel
      levelName = v.DanDesc
      break
    end
  end
  local maxLevel = 1
  for level, _ in pairs(CollectLevelCfg) do
    maxLevel = tonumber(level)
  end
  local root = self.UIRoot
  local index = 1
  local originalScore = score
  if score >= nextScore then
    curLevel = nextLevel
  end
  if curLevel == maxLevel then
    curLevel = nextLevel
    levelName = collect_module:GetSplitTableData("CollectLevel", collect_module.E_ColCfgMode.JK, curLevel).DanDesc
    root.Process_Score:SetPercent(100)
  else
    root.Process_Score:SetPercent((score - preScore) / (nextScore - preScore))
  end
  local levelWord = LocUtil.LocalizeResFormat(77535, curLevel, levelName)
  if self.bIsSelf then
    index = 0
    root.TextBlock_1:SetText(levelWord)
    local tScore
    if curLevel == maxLevel then
      tScore = tostring(originalScore)
    else
      tScore = LocUtil.LocalizeResFormat(6830, originalScore, nextScore)
    end
    root.Text_Score:SetText(tScore)
  else
    root.TextBlock_NameOther:SetText(levelWord)
    root.Text_ScoreOhter:SetText(tostring(originalScore))
  end
  root.WidgetSwitcher_2:SetActiveWidgetIndex(index)
  local sLevel = collect_module:GetSeasonLevelByScore(seasonScore)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  self.UIRoot.Common_Exquisite_Collect_Level_DynamicLoading_UIBP:InitExquisiteCollectBadge(self.nUid, {
    seasonLevel = sLevel,
    rank = l,
    totalLevel = curLevel,
    animationType = collect_cfg.E_CollectBadge_AnimaType.None
  })
  return curLevel, sLevel
end
function Collect_Room_UIBP:OnGetVoteData(num, cancel)
  if cancel then
    self:SetLikeIcon(CNoLike)
  end
  log_warning(bWriteLog and "  Collect_Room_UIBP:OnGetVoteData. num: " .. tostring(num))
  local StringUtil = require("common.string_util")
  local hotValue = StringUtil.FormatNum_KMB(num or 0)
  self.nLikeNum = num
  self.UIRoot.TextBlock_12:SetText(hotValue)
  local newNum = 0
  if self.bIsSelf then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local lastNum = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectLike)
    lastNum = lastNum or 0
    newNum = num - lastNum
  end
  log_warning(bWriteLog and "  Collect_Room_UIBP:OnGetVoteData. newNum: " .. tostring(newNum))
  self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item02, 0 < newNum)
  if 0 < newNum then
    if 99 < newNum then
      newNum = "99+"
    else
      newNum = tostring(newNum)
    end
    self.UIRoot.Reddot_Anchor_Item02.TextBlock_Num:SetText(newNum)
  end
end
local posPad = {
  nil,
  {1, 0},
  {0, 1},
  {1, 1}
}
function Collect_Room_UIBP:IsEquipError(index, itemId, removeId)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local CollectBadge = collect_module:GetSplitTableData("CollectBadge", collect_module.E_ColCfgMode.Def, itemId)
  local _type = CollectBadge.ShowType
  if _type == 1 then
    return false
  end
  local x, y = (index - 1) % NCol + 1, (index - 1) // NCol + 1
  log_warning(bWriteLog and "  Collect_Room_UIBP:IsEquipError. x: " .. tostring(x))
  log_warning(bWriteLog and "  Collect_Room_UIBP:IsEquipError. y: " .. tostring(y))
  if (_type == 2 or _type == 4) and x == NCol then
    log_warning(bWriteLog and "  Collect_Room_UIBP:IsEquipError.  x is out of range")
    return true
  end
  local gridData = self.gridData
  local pad = posPad[_type]
  local skipPos = {
    nil,
    nil,
    nil,
    nil
  }
  if removeId then
    CollectBadge = collect_module:GetSplitTableData("CollectBadge", collect_module.E_ColCfgMode.Def, removeId)
    _type = CollectBadge.ShowType
    if _type == 4 then
      return false
    end
    log_warning(bWriteLog and "  Collect_Room_UIBP:IsEquipError. remove _type: " .. tostring(_type))
    skipPos[index] = 1
    if _type % 2 == 0 then
      skipPos[index + 1] = 1
    elseif 2 < _type then
      skipPos[y * NCol + x] = 1
    end
  end
  for i = x, x + pad[1] do
    for j = y, y + pad[2] do
      local curPos = (j - 1) * NCol + i
      local result = gridData[curPos]
      log_warning(bWriteLog and "  Collect_Room_UIBP:IsEquipError. result: " .. tostring(result))
      if not result or not skipPos[curPos] and result ~= 0 then
        log_warning(bWriteLog and "  Collect_Room_UIBP:IsEquipError. curPos error: " .. tostring(curPos))
        return true
      end
    end
  end
end
function Collect_Room_UIBP:EquipBadge(index, itemId, removeId)
  log_warning(bWriteLog and "  Collect_Room_UIBP:EquipBadge. index: " .. tostring(index))
  log_warning(bWriteLog and "  Collect_Room_UIBP:EquipBadge. itemId: " .. tostring(itemId))
  if self:IsEquipError(index, itemId, removeId) then
    ShowNotice(LocUtil.GetLocalizeResStr(77533))
    return false
  end
  local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
  ModCollectHandler.send_paste_collect_sys_show_info_req(itemId, index)
  return true
end
function Collect_Room_UIBP:OnPasteCollectBadge(_, __, badge_list)
  local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
  collect_room_module:OnChangeBadgeData(badge_list)
  self:OnChangeBadgeData(badge_list)
end
function Collect_Room_UIBP:RemoveBadge(itemId)
  log_warning(bWriteLog and "  Collect_Room_UIBP:RemoveBadge. itemId: " .. tostring(itemId))
  local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
  ModCollectHandler.send_cancel_collect_sys_show_info_req(itemId)
end
function Collect_Room_UIBP:Replace(removeId, index, equipId)
  local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
  ModCollectHandler.send_cancel_collect_sys_show_info_req(removeId, 1)
  self:EquipBadge(index, equipId, removeId)
end
function Collect_Room_UIBP:OnPopupDetectionPrompt()
  local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
  if collect_room_module:CheckStickerDetectionFlag() then
    ShowNotice(LocUtil.GetLocalizeResStr(77738))
    local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
    ModCollectHandler.send_clear_sticker_security_detection_flag_req()
  end
end
function Collect_Room_UIBP:OnChangeBadgeData(badge_list)
  local num = 25
  local data = prealloctable(25, 0)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local initState = collect_cfg.dataInOther
  if self.bIsSelf then
    initState = 0
  end
  for i = 1, num do
    data[i] = initState
  end
  badge_list = badge_list or {}
  local equipped
  for itemId, v in pairs(badge_list) do
    local slot_ids = v.slot_ids
    if slot_ids then
      local min = math.huge
      for i, _ in pairs(slot_ids) do
        if i < min then
          min = i
        end
      end
      for i, _ in pairs(slot_ids) do
        data[i] = min
      end
      data[min] = itemId
      if not equipped then
        equipped = true
        self.bEquipped = true
      end
    end
  end
  self.gridData = data
  log_tree("  Collect_Room_UIBP:OnChangeBadgeData. data ", data)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local tab = RoleInfoMainSystem.CollectRoom
  local roleinfo_main = self:GetParentUI()
  if not roleinfo_main:GetLoopAnimFlag(tab) then
    roleinfo_main:SetLoopAnimFlag(tab)
  else
    log_warning(bWriteLog and "  Collect_Room_UIBP:OnChangeBadgeData.  false")
  end
  self.LoopScrollGrid_0:SetData(data)
end
function Collect_Room_UIBP:OnClickButton_DressUp()
  self:PlayAudio(sound_config.click_v1)
  local cb = function(select, itemId, dressIndex)
    self:OnSelectDress(select, itemId, dressIndex)
  end
  UIManager.ShowUI(UIManager.UI_Config.Collect_Room_DressUp_UIBP, cb)
end
function Collect_Room_UIBP:OnClickButton_Like()
  self:PlayAudio(sound_config.click_v1)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not self.bIsSelf then
    local hasVote
    for _, uid in ipairs(self.voteData) do
      if uid == self.nUid then
        hasVote = true
        break
      end
    end
    if hasVote then
      local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
      ModCollectHandler.send_cancel_collect_sys_upvote_req(self.nUid)
    else
      local gift_const = require("client.slua.logic.gift.gift_const")
      local Enum_GiftSourceType = gift_const.GiftSourceType
      local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
      logic_send_gift.pspace_send_gift_req(self.nUid, collect_module.collect_cfg.voteId, 1, "", "", Enum_GiftSourceType.CollectRoomLike)
    end
  else
    UIManager.ShowUI(UIManager.UI_Config.Collect_Popup_LikeRecord_UIBP, self.voteData, self.votedData)
    self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item02, false)
  end
end
function Collect_Room_UIBP:OnCancelUpvote(_, __, uid, num)
  for i, _uid in ipairs(self.voteData) do
    if _uid == uid then
      table.remove(self.voteData, i)
      break
    end
  end
  if self.nUid == uid then
    self:OnGetVoteData(num, true)
  end
end
function Collect_Room_UIBP:OnClickButton_Share()
  self:PlayAudio(sound_config.click_v1)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local tCollectData = collect_module:GetCollectData()
  if not tCollectData then
    log(bWriteLog and " Collect_Room_UIBP:OnClickButton_Share() tCollectData is nil")
    return
  end
  local Logic_ShareToFriendConst = require("client.logic.share.Logic_ShareToFriendConst")
  local logic_community = require("client.slua.logic.community.logic_community")
  local Enum_ShareContentType = Logic_ShareToFriendConst.Enum_ShareContentType
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local sJumpUrl = string.format("game://?module=1002300&index=%s&UID=%s", RoleInfoMainSystem.CollectRoom, DataMgr.roleData.uid)
  local tShareCfg = {
    campaign = "Collect_Room",
    bUseScreenSizeRatio = true,
    share_type = ShareBtnTLogShareTypeDefine.CollectRoom,
    shareContent = LocUtil.GetLocalizeResStr(77071),
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid
    }),
    clubShareParams = {
      bShowShareClub = true,
      publishFeedType = logic_community.PublishFeedType.CollectionShare,
      gameScene = logic_community.GameScene.CollectionShare
    },
    tFriendShareData = {
      nContentShareType = Enum_ShareContentType.CS_ExhibitionHall,
      sSendChatJumpUrl = sJumpUrl
    }
  }
  self:OnClickShareFriendImplement(tShareCfg, self.UIRoot.CanvasPanel_ShareCapture)
end
function Collect_Room_UIBP:OnClickButton_Entrance()
  self:PlayAudio(sound_config.click)
  if self.milestoneGuideTimer then
    self:RemoveTimer(self.milestoneGuideTimer)
    self.milestoneGuideTimer = nil
  end
  local LogicCollectionHallEntry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicCollectionHallEntry)
  local Enum_EnterPlanCHSource = LogicCollectionHallEntry.Enum_EnterPlanCHSource
  LogicCollectionHallEntry:EntryVisitCollectionHall(self.nUid, Enum_EnterPlanCHSource.CollectSysRoom, true)
end
function Collect_Room_UIBP:PreForScreenShot()
  self._bIsSharing = true
  local cObj_captureUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_ShareCapture, UIManager.UI_Config.Collect_ExhibitionHallShare_UIBP, self.gridData)
  cObj_captureUI:SetAutoSize(true)
  self._  self:SetWidgetVisible(self.UIRoot.Button_DressUp, false)
  self:SetWidgetVisible(self.UIRoot.Button_Like, false)
  self:SetWidgetVisible(self.UIRoot.Button_Share, false)
end
function Collect_Room_UIBP:ScreenShotDone()
  self._bIsSharing = false
  self._cObj_captureUI:CloseSelf()
  self._cObj_captureUI = nil
  self:SetWidgetVisible(self.UIRoot.Button_DressUp, true, true)
  self:SetWidgetVisible(self.UIRoot.Button_Like, true, true)
  self:SetWidgetVisible(self.UIRoot.Button_Share, true, true)
end
function Collect_Room_UIBP:OnSelectDress(_, itemId, dressIndex)
  if dressIndex == 1 then
    self:SendChangeBg(itemId)
  else
    self:SendChangeFrame(itemId)
  end
end
function Collect_Room_UIBP:SendChangeBg(itemId)
  local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
  ModCollectHandler.send_set_sticker_background_req(itemId)
end
function Collect_Room_UIBP:OnChangeBgResponse(_, _, bg_id)
  self:OnChangeBg(bg_id)
end
function Collect_Room_UIBP:SendChangeFrame(itemId)
  local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
  ModCollectHandler.send_set_sticker_frame_req(itemId)
end
function Collect_Room_UIBP:OnChangeFrameResponse(_, _, frame_id)
  self:OnChangeFrame(frame_id)
end
function Collect_Room_UIBP:OnChangeBg(bg_id)
  self:SetMilestoneBGPath(bg_id)
  log_warning(bWriteLog and "  Collect_Room_UIBP:OnChangeBg. bg_id: " .. tostring(bg_id))
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local tBGID2Config = collect_cfg.tBGID2Config
  local bgData = tBGID2Config[bg_id]
  if self.cardBg then
    self.cardBg:Close()
  end
  if not bgData then
    self.cardBg = self:CreateChildWindowWithBpPath("CardBgPanel", nil, collect_cfg.DefaultCardBG)
    return
  end
  local index = bgData.index
  local bpPath = bgData.bpPath
  self.cardBg = self:CreateChildWindowWithBpPath("CardBgPanel", nil, bpPath)
  local childRoot = self.cardBg.UIRoot
  if index == 2 then
    childRoot:PlayUserWidgetAnimation(childRoot.FadeIn, 0, 0, 0, 1)
  end
end
function Collect_Room_UIBP:SetMilestoneBGPath(bg_id)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local tBGID2Config = collect_cfg.tBGID2Config
  local bgData = tBGID2Config[bg_id]
  if not bgData or not bgData.milestoneBGPath then
    self:SetTexture(self.UIRoot.Image_MilestoneBG, collect_cfg.sDefMilestoneBGPath)
    return
  end
  self:SetTexture(self.UIRoot.Image_MilestoneBG, bgData.milestoneBGPath)
end
function Collect_Room_UIBP:OnChangeFrame(bg_id)
  log_warning(bWriteLog and "  Collect_Room_UIBP:OnChangeFrame. bg_id: " .. tostring(bg_id))
  local showBg = bg_id and bg_id ~= 0
  local UIRoot = self.UIRoot
  self:SetWidgetVisible(UIRoot.Image_19, showBg)
  self:SetWidgetVisible(UIRoot.Image_23, showBg)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local upFrames = collect_module.collect_cfg.upFrames
  local downFrames = collect_module.collect_cfg.downFrames
  if showBg then
    self:SetTexture(UIRoot.Image_19, upFrames[bg_id])
    self:SetTexture(UIRoot.Image_23, downFrames[bg_id])
  end
end
function Collect_Room_UIBP:OnSetMilestoneList()
  local collect_pavilions_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_pavilions_module)
  local slots = collect_pavilions_module:GetMilestoneSlotsData(self.bIsSelf)
  log(bWriteLog and string.format("Collect_Room_UIBP:OnSetMilestoneList"))
  self.LoopScrollGrid_Milestone:SetData(slots)
end
function Collect_Room_UIBP:GetIsSharing()
  return self._bIsSharing
end
return CCollect_Room_UIBP