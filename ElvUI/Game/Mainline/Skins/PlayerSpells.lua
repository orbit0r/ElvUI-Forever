local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local GetSpellTexture = C_Spell.GetSpellTexture

local function HandleTalentFrameDialog(dialog)
	if not dialog then return end

	dialog:StripTextures()
	dialog:CreateBackdrop('Transparent')

	if dialog.AcceptButton then S:HandleButton(dialog.AcceptButton) end
	if dialog.CancelButton then S:HandleButton(dialog.CancelButton) end
	if dialog.DeleteButton then S:HandleButton(dialog.DeleteButton) end

	local nameControl = dialog.NameControl
	local nameControlEditbox = nameControl and nameControl.EditBox
	if nameControlEditbox then
		S:HandleEditBox(nameControlEditbox)

		nameControlEditbox.backdrop:Point('TOPLEFT', -5, -10)
		nameControlEditbox.backdrop:Point('BOTTOMRIGHT', 5, 10)
	end
end

local function UpdateSpecFrame(frame)
	if not frame.SpecContentFramePool then return end

	for specContentFrame in frame.SpecContentFramePool:EnumerateActive() do
		if not specContentFrame.IsSkinned then
			S:HandleButton(specContentFrame.ActivateButton)

			if specContentFrame.SpellButtonPool then
				for button in specContentFrame.SpellButtonPool:EnumerateActive() do
					if button.Ring then
						button.Ring:Hide()
					end

					if button.CircleMask then
						button.CircleMask:Hide()
					end

					if button.spellID then
						local texture = GetSpellTexture(button.spellID)
						if texture then
							button.Icon:SetTexture(texture)
						end
					end

					S:HandleIcon(button.Icon, true)
				end
			end

			specContentFrame.IsSkinned = true
		end
	end
end

local function HandleHeroTalents(frame)
	if not frame then return end

	for specFrame in frame.SpecContentFramePool:EnumerateActive() do
		if specFrame and not specFrame.IsSkinned then
			if specFrame.SpecName then specFrame.SpecName:FontTemplate(nil, 18) end
			if specFrame.Description then specFrame.Description:FontTemplate(nil, 14) end
			if specFrame.CurrencyFrame then
				specFrame.CurrencyFrame.LabelText:FontTemplate()
				specFrame.CurrencyFrame.AmountText:FontTemplate(nil, 18)
			end

			S:HandleButton(specFrame.ActivateButton)
			S:HandleButton(specFrame.ApplyChangesButton)

			specFrame.IsSkinned = true
		end
	end
end

function S:Blizzard_PlayerSpells()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local PlayerSpellsFrame = _G.PlayerSpellsFrame
	S:HandlePortraitFrame(PlayerSpellsFrame)

	-- Specialisation (Forever/Camelot can omit UpdateSpecFrame)
	local SpecFrame = PlayerSpellsFrame.SpecFrame
	if SpecFrame and type(SpecFrame.UpdateSpecFrame) == 'function' then
		hooksecurefunc(SpecFrame, 'UpdateSpecFrame', UpdateSpecFrame)
	elseif SpecFrame and SpecFrame.HookScript then
		SpecFrame:HookScript('OnShow', UpdateSpecFrame)
	end

	-- TalentsFrame (Forever/Camelot omits several retail-only regions)
	local TalentsFrame = PlayerSpellsFrame.TalentsFrame
	if TalentsFrame then
		if TalentsFrame.BlackBG then TalentsFrame.BlackBG:SetAlpha(0) end
		if TalentsFrame.BottomBar then TalentsFrame.BottomBar:SetAlpha(0) end

		if TalentsFrame.ApplyButton then S:HandleButton(TalentsFrame.ApplyButton) end
		if TalentsFrame.LoadSystem and TalentsFrame.LoadSystem.Dropdown then
			S:HandleDropDownBox(TalentsFrame.LoadSystem.Dropdown)
		end

		if TalentsFrame.InspectCopyButton then S:HandleButton(TalentsFrame.InspectCopyButton) end

		local classCurrency = TalentsFrame.ClassCurrencyDisplay
		if classCurrency then
			if classCurrency.CurrencyLabel then classCurrency.CurrencyLabel:FontTemplate(nil, 18) end
			if classCurrency.CurrentAmountContainer and classCurrency.CurrentAmountContainer.CurrencyAmount then
				classCurrency.CurrentAmountContainer.CurrencyAmount:FontTemplate(nil, 26)
			end
		end

		local specCurrency = TalentsFrame.SpecCurrencyDisplay
		if specCurrency then
			if specCurrency.CurrencyLabel then specCurrency.CurrencyLabel:FontTemplate(nil, 18) end
			if specCurrency.CurrentAmountContainer and specCurrency.CurrentAmountContainer.CurrencyAmount then
				specCurrency.CurrentAmountContainer.CurrencyAmount:FontTemplate(nil, 26)
			end
		end

		if TalentsFrame.SearchBox then
			S:HandleEditBox(TalentsFrame.SearchBox)
			if TalentsFrame.SearchBox.backdrop then
				TalentsFrame.SearchBox.backdrop:Point('TOPLEFT', -4, -5)
				TalentsFrame.SearchBox.backdrop:Point('BOTTOMRIGHT', 0, 5)
			end
		end
		if TalentsFrame.SearchPreviewContainer then
			TalentsFrame.SearchPreviewContainer:StripTextures()
			TalentsFrame.SearchPreviewContainer:CreateBackdrop('Transparent')
		end

		if TalentsFrame.PvPTalentList then
			TalentsFrame.PvPTalentList:StripTextures()
			TalentsFrame.PvPTalentList:CreateBackdrop()
			if TalentsFrame.PvPTalentList.backdrop then
				TalentsFrame.PvPTalentList.backdrop:SetFrameStrata(TalentsFrame.PvPTalentList:GetFrameStrata())
				TalentsFrame.PvPTalentList.backdrop:SetFrameLevel(2000)
			end
		end

		-- Hero Talents
		local HeroTalentContainer = TalentsFrame.HeroTalentsContainer
		if HeroTalentContainer and HeroTalentContainer.HeroSpecLabel then
			HeroTalentContainer.HeroSpecLabel:FontTemplate(nil, 16)
		end
	end

	if PlayerSpellsFrame.TabSystem then
		for _, tab in next, { PlayerSpellsFrame.TabSystem:GetChildren() } do
			S:HandleTab(tab)
		end

		PlayerSpellsFrame.TabSystem:ClearAllPoints()
		PlayerSpellsFrame.TabSystem:Point('TOPLEFT', PlayerSpellsFrame, 'BOTTOMLEFT', -3, 2)
	end

	local ImportDialog = _G.ClassTalentLoadoutImportDialog
	if ImportDialog then
		HandleTalentFrameDialog(ImportDialog)
		if ImportDialog.ImportControl and ImportDialog.ImportControl.InputContainer then
			ImportDialog.ImportControl.InputContainer:StripTextures()
			ImportDialog.ImportControl.InputContainer:CreateBackdrop('Transparent')
		end
	end

	local CreateDialog = _G.ClassTalentLoadoutCreateDialog
	if CreateDialog then
		HandleTalentFrameDialog(CreateDialog)
	end

	local EditDialog = _G.ClassTalentLoadoutEditDialog
	if EditDialog then
		HandleTalentFrameDialog(EditDialog)

		local editbox = EditDialog.LoadoutName
		if editbox then
			S:HandleEditBox(editbox)
			if editbox.backdrop then
				editbox.backdrop:Point('TOPLEFT', -5, -5)
				editbox.backdrop:Point('BOTTOMRIGHT', 5, 5)
			end
		end

		local check = EditDialog.UsesSharedActionBars
		if check and check.CheckButton then
			S:HandleCheckBox(check.CheckButton)
			check.CheckButton:Size(20)
			if check.CheckButton.backdrop then
				check.CheckButton.backdrop:SetInside()
			end
		end
	end

	local TalentsSelect = _G.HeroTalentsSelectionDialog
	if TalentsSelect then
		TalentsSelect:StripTextures()
		TalentsSelect:SetTemplate()

		if TalentsSelect.CloseButton then
			S:HandleCloseButton(TalentsSelect.CloseButton)
		end

		if type(TalentsSelect.ShowDialog) == 'function' then
			hooksecurefunc(TalentsSelect, 'ShowDialog', HandleHeroTalents)
		end
	end

	-- SpellBook
	local SpellBookFrame = PlayerSpellsFrame.SpellBookFrame
	if SpellBookFrame then
		if PlayerSpellsFrame.MaxMinButtonFrame then
			S:HandleMaxMinFrame(PlayerSpellsFrame.MaxMinButtonFrame)
		end
		if SpellBookFrame.SearchBox then
			S:HandleEditBox(SpellBookFrame.SearchBox)
		end

		if SpellBookFrame.TopBar then
			SpellBookFrame.TopBar:Hide()
		end

		if SpellBookFrame.BookCornerFlipbook then
			SpellBookFrame.BookCornerFlipbook:Hide()
		end

		if SpellBookFrame.HelpPlateButton then
			if E.global.general.disableTutorialButtons then
				SpellBookFrame.HelpPlateButton:Kill()
			elseif SpellBookFrame.HelpPlateButton.Ring then
				SpellBookFrame.HelpPlateButton.Ring:Hide()
			end
		end

		-- Forever/Camelot category tabs are icon buttons; HandleTab strips them to empty squares
		-- Leave CategoryTabSystem unskinned so General / Spec icons stay visible

		local PagedSpellsFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
		if PagedSpellsFrame then
			if PagedSpellsFrame.View1 then
				PagedSpellsFrame.View1:DisableDrawLayer('OVERLAY')
			end

			local PagingControls = PagedSpellsFrame.PagingControls
			if PagingControls then
				PagingControls.PageText:SetTextColor(1, 1, 1)

				S:HandleNextPrevButton(PagingControls.PrevPageButton, nil, nil, true)
				S:HandleNextPrevButton(PagingControls.NextPageButton, nil, nil, true)
			end
		end

		local RotationSpellFrame = SpellBookFrame and SpellBookFrame.AssistedCombatRotationSpellFrame
		local RotationButton = RotationSpellFrame and RotationSpellFrame.Button
		if RotationButton then
			S:HandleIcon(RotationButton.Icon, true)

			if RotationButton.Border then
				RotationButton.Border:Hide()
			end

			RotationButton:SetHighlightTexture(E.media.blankTex)
			RotationButton:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
			RotationButton:SetPushedTexture(E.media.blankTex)
			RotationButton:GetPushedTexture():SetVertexColor(1, 0.82, 0, 0.4)
		end
	end
end

S:AddCallbackForAddon('Blizzard_PlayerSpells')
