local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function AbilitiesList_Layout(list)
	if not list.abilityPool then return end

	for frame in list.abilityPool:EnumerateActive() do
		if not frame.IsSkinned then
			S:HandleIcon(frame.Icon)
			frame.IsSkinned = true
		end
	end
end

function S:Blizzard_StableUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.stable) then return end

	local StableFrame = _G.StableFrame
	if not StableFrame then return end
	S:HandlePortraitFrame(StableFrame)
	if StableFrame.MainHelpButton then
		StableFrame.MainHelpButton:Hide()
	end
	S:HandleButton(StableFrame.StableTogglePetButton)
	S:HandleButton(StableFrame.ReleasePetButton)

	local StabledPetList = StableFrame.StabledPetList
	if not StabledPetList then return end
	StabledPetList:StripTextures()
	if StabledPetList.ListName then
		StabledPetList.ListName:FontTemplate(nil, 32)
	end
	if StabledPetList.ListCounter then
		StabledPetList.ListCounter:StripTextures()
		StabledPetList.ListCounter:CreateBackdrop('Transparent')
	end

	if StabledPetList.FilterBar then
		S:HandleEditBox(StabledPetList.FilterBar.SearchBox)
		if StabledPetList.FilterBar.FilterDropdown then
			S:HandleButton(StabledPetList.FilterBar.FilterDropdown)
			if StabledPetList.FilterBar.FilterDropdown.ResetButton then
				S:HandleCloseButton(StabledPetList.FilterBar.FilterDropdown.ResetButton)
			end
		end
	end

	S:HandleTrimScrollBar(StabledPetList.ScrollBar)

	local modelScene = StableFrame.PetModelScene
	if modelScene then
		local sceneShadow = modelScene.PetModelSceneShadow
		if sceneShadow then
			sceneShadow:SetInside()
		end

		local inset = modelScene.Inset
		if inset then
			inset.NineSlice:SetTemplate()
			inset.Bg:Hide()
		end

		local abilitiesList = modelScene.AbilitiesList
		if abilitiesList then
			hooksecurefunc(abilitiesList, 'Layout', AbilitiesList_Layout)
		end

		local petInfo = modelScene.PetInfo
		if petInfo then
			if petInfo.Type then
				hooksecurefunc(petInfo.Type, 'SetText', S.ReplaceIconString)
			end

			if petInfo.Specialization then
				S:HandleDropDownBox(petInfo.Specialization)
			end
		end
	end

	S:HandleModelSceneControlButtons(modelScene.ControlFrame)
end

S:AddCallbackForAddon('Blizzard_StableUI')
