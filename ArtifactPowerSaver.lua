local _G = _G

local function IsItemArtifactPower(itemLink)
    local result = false
    for i = 2, 3 do -- only check the 2nd or 3rd lines.. maybe check all just in case other addon does funny stuff?
        result = _G[GameTooltip:GetName()..'TextLeft'..i]:GetText() == "|cFFE6CC80"..ARTIFACT_POWER.."|r"
        if result then break end
    end
    return result
end

local function attachItemTooltip(self)
    local _,link = self:GetItem()
    if IsItemArtifactPower(link) then
        if ArtifactPowerSaver_PreferredSpec ~= GetSpecialization() then
            self:AddLine("!!! WARNING: YOU ARE NOT IN YOUR PREFERRED SPEC !!!",255,0,0,true)
        else 
            self:AddLine("You are in your preferred spec!",0,255,0,true)
        end
    end
end

local f = CreateFrame('frame')
f:SetScript('OnEvent', function(self, event, ...)
    if event == 'PLAYER_LOGIN' then
        ArtifactPowerSaver_PreferredSpec = ArtifactPowerSaver_PreferredSpec or GetSpecialization()

        ArtifactPowerSaver = {}

        ArtifactPowerSaver.panel = CreateFrame("Frame", "ArtifactPowerSaverPanel", UIParent)
        ArtifactPowerSaver.panel.name = "ArtifactPowerSaver"



          -- Create the dropdown, and configure its appearance
        local dropDown = CreateFrame("FRAME", "APSDropDown", ArtifactPowerSaver.panel, "UIDropDownMenuTemplate")
        dropDown:SetPoint("TOPLEFT",0,-20)
        UIDropDownMenu_SetWidth(dropDown, 250)
        UIDropDownMenu_SetText(dropDown, select(2,GetSpecializationInfo(ArtifactPowerSaver_PreferredSpec))) -- current spec

        function dropDown:SetValue(newValue)
         ArtifactPowerSaver_PreferredSpec = newValue
         UIDropDownMenu_SetText(dropDown, select(2,GetSpecializationInfo(newValue)))
        end

        UIDropDownMenu_Initialize(dropDown, function(self, menuList)
          local info = UIDropDownMenu_CreateInfo()
          info.func = self.SetValue
          for i = 1,GetNumSpecializations() do
           info.text, info.arg1, info.checked = select(2,GetSpecializationInfo(i)), i, i == ArtifactPowerSaver_PreferredSpec
           UIDropDownMenu_AddButton(info)
          end
        end)

        InterfaceOptions_AddCategory(ArtifactPowerSaver.panel)
    end
end)
f:RegisterEvent('PLAYER_LOGIN')

GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)