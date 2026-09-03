local MainCityPlayerState_DNDAction = {}
function MainCityPlayerState_DNDAction:_PostConstruct()
  printf("MainCityPlayerState_DNDAction:_PostConstruct")
  self.DNDFriend = false
  self.DNDStranger = false
  self.DNDThisOnline = false
  self.SubStatusType = 0
end
function MainCityPlayerState_DNDAction:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "DNDFriend",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "DNDStranger",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "DNDThisOnline",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "SubStatusType",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function MainCityPlayerState_DNDAction:OnRep_DNDFriend()
  printf("MainCityPlayerState_DNDAction:OnRep_DNDFriend uid:%s, DNDFriend: %s", self.PlayerUID, self.DNDFriend)
end
function MainCityPlayerState_DNDAction:OnRep_DNDStranger()
  printf("MainCityPlayerState_DNDAction:OnRep_DNDStranger uid:%s, DNDStranger: %s", self.PlayerUID, self.DNDStranger)
end
function MainCityPlayerState_DNDAction:OnRep_DNDThisOnline()
  printf("MainCityPlayerState_DNDAction:OnRep_DNDThisOnline uid:%s, DNDThisOnline: %s", self.PlayerUID, self.DNDThisOnline)
end
function MainCityPlayerState_DNDAction:OnRep_SubStatusType()
  printf("MainCityPlayerState_DNDAction:OnRep_SubStatusType uid:%s, SubStatusType: %s", self.PlayerUID, self.SubStatusType)
  if not Client then
    return
  end
  self:HandlerOnCharmChanged_Client()
end
function MainCityPlayerState_DNDAction:GetSubStatusType()
  return self.SubStatusType
end
function MainCityPlayerState_DNDAction:GetAllowInteract(bFriend)
  if self.DNDThisOnline then
    printf("MainCityPlayerState_DNDAction:GetAllowInteract false by DNDThisOnline")
    return false
  end
  if bFriend then
    if self.DNDFriend then
      printf("MainCityPlayerState_DNDAction:GetAllowInteract false by DNDFriend")
      return false
    end
    if self.SubStatusType == 6 then
      printf("MainCityPlayerState_DNDAction:GetAllowInteract false by SubStatusType: %s", self.SubStatusType)
      return false
    end
  else
    if self.DNDStranger then
      printf("MainCityPlayerState_DNDAction:GetAllowInteract false by DNDStranger")
      return false
    end
    if self.SubStatusType == 8 or self.SubStatusType == 6 then
      printf("MainCityPlayerState_DNDAction:GetAllowInteract false by SubStatusType: %s", self.SubStatusType)
      return false
    end
  end
  printf("MainCityPlayerState_DNDAction:GetAllowInteract true")
  return true
end
return MainCityPlayerState_DNDAction