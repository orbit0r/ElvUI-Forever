local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, next = unpack, next
local hooksecurefunc = hooksecurefunc
local CreateColor = CreateColor

local FLYOUT_LOCATIONS = {
	[0xFFFFFFFF] = 'PLACEINBAGS',
	[0xFFFFFFFE] = 'IGNORESLOT',
	[0xFFFFFFFD] = 'UNIGNORESLOT'
}

local showInsetBackdrop = {
	ReputationFrame = true,
	TokenFrame = true
}

local oldAtlas = {
	Options_ListExpand_Right = 1,
	Options_ListExpand_Right_Expanded = 1
}

local function UpdateCollapse(texture, atlas)
	if not atlas or oldAtlas[atlas] then
		local parent = texture:GetParent()
		if parent:IsCollapsed() then
			texture:SetAtlas('Soulbinds_Collection_CategoryHeader_Expand')
		else
			texture:SetAtlas('Soulbinds_Collection_CategoryHeader_Collapse')
		end
	end
end

local function UpdateToggleCollapseButton(button)
	local header = button.GetHeader and button:GetHeader()
	if not header then return end

	local tex = header:IsCollapsed() and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton
	button:SetNormalTexture(tex)
	button:SetPushedTexture(tex)
end

local function UpdateTokenSkinsChild(child)
	if not child.IsSkinned then
		if child.Right then
			child:StripTextures()
			child:CreateBackdrop('Transparent')
			child.backdrop:SetInside(child)

			UpdateCollapse(child.Right)
			UpdateCollapse(child.HighlightRight)

			hooksecurefunc(child.Right, 'SetAtlas', UpdateCollapse)
			hooksecurefunc(child.HighlightRight, 'SetAtlas', UpdateCollapse)
		end

		local icon = child.Content and child.Content.CurrencyIcon
		if icon then
			S:HandleIcon(icon)
		end

		local ToggleCollapseButton = child.ToggleCollapseButton
		if ToggleCollapseButton and ToggleCollapseButton.RefreshIcon then
			hooksecurefunc(ToggleCollapseButton, 'RefreshIcon', UpdateToggleCollapseButton)

			UpdateToggleCollapseButton(ToggleCollapseButton)
		end

		child.IsSkinned = true
	end

end

local function UpdateTokenSkins(frame)
	frame:ForEachFrame(UpdateTokenSkinsChild)
end

local function EquipmentManagerPane_UpdateChild(child)
	if child.icon and not child.IsSkinned then
		child.BgTop:SetTexture(E.ClearTexture)
		child.BgMiddle:SetTexture(E.ClearTexture)
		child.BgBottom:SetTexture(E.ClearTexture)
		S:HandleIcon(child.icon)
		child.HighlightBar:SetColorTexture(1, 1, 1, .25)
		child.HighlightBar:SetDrawLayer('BACKGROUND')
		child.SelectedBar:SetColorTexture(0.8, 0.8, 0.8, .25)
		child.SelectedBar:SetDrawLayer('BACKGROUND')

		child.IsSkinned = true
	end
end

local function EquipmentManagerPane_Update(frame)
	frame:ForEachFrame(EquipmentManagerPane_UpdateChild)
end

local function TitleManagerPane_UpdateChild(child)
	if not child.IsSkinned then
		child:DisableDrawLayer('BACKGROUND')
		child.IsSkinned = true
	end
end

local function TitleManagerPane_Update(frame)
	frame:ForEachFrame(TitleManagerPane_UpdateChild)
end

local function PaperDollItemSlotButtonUpdate(slot)
	local highlight = slot:GetHighlightTexture()
	highlight:SetTexture(E.Media.Textures.White8x8)
	highlight:SetVertexColor(1, 1, 1, .25)
	highlight:SetInside()
end

local function UpdateCharacterInset(name)
	_G.CharacterFrameInset.backdrop:SetShown(showInsetBackdrop[name])
end

local function UpdateAzeriteItem(item)
	if not item.IsSkinned then
		item.IsSkinned = true

		item.AzeriteTexture:SetAlpha(0)
		item.RankFrame.Texture:SetTexture()
		item.RankFrame.Label:FontTemplate(nil, nil, 'OUTLINE')
	end
end

local function UpdateAzeriteEmpoweredItem(item)
	item.AzeriteTexture:SetAtlas('AzeriteIconFrame')
	item.AzeriteTexture:SetInside()
	item.AzeriteTexture:SetTexCoords()
	item.AzeriteTexture:SetDrawLayer('BORDER', 1)
end

local function ColorizeStatPane(frame)
	frame.Background:SetAlpha(0)

	local r, g, b = 0.8, 0.8, 0.8
	local gradientFrom, gradientTo = CreateColor(r, g, b, 0.25), CreateColor(r, g, b, 0)

	frame.leftGrad = frame:CreateTexture(nil, 'BORDER')
	frame.leftGrad:Size(80, frame:GetHeight())
	frame.leftGrad:Point('LEFT', frame, 'CENTER')
	frame.leftGrad:SetTexture(E.Media.Textures.White8x8)
	frame.leftGrad:SetGradient('Horizontal', gradientFrom, gradientTo)

	frame.rightGrad = frame:CreateTexture(nil, 'BORDER')
	frame.rightGrad:Size(80, frame:GetHeight())
	frame.rightGrad:Point('RIGHT', frame, 'CENTER')
	frame.rightGrad:SetTexture(E.Media.Textures.White8x8)
	frame.rightGrad:SetGradient('Horizontal', gradientTo, gradientFrom)
end

local function StatsPane(which)
	local CharacterStatsPane = _G.CharacterStatsPane
	CharacterStatsPane[which]:StripTextures()
	CharacterStatsPane[which]:CreateBackdrop('Transparent')
	CharacterStatsPane[which].backdrop:ClearAllPoints()
	CharacterStatsPane[which].backdrop:Point('CENTER')
	CharacterStatsPane[which].backdrop:Size(150, 18)
end

local function EquipmentDisplayButton(button)
	if not button.isHooked then
		button:SetNormalTexture(E.ClearTexture)
		button:SetPushedTexture(E.ClearTexture)
		button:SetTemplate()
		button:StyleButton()

		button.icon:SetInside()
		button.icon:SetTexCoords()

		S:HandleIconBorder(button.IconBorder)

		button.isHooked = true
	end

	if FLYOUT_LOCATIONS[button.location] then -- special slots
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function EquipmentUpdateItems()
	local frame = _G.EquipmentFlyoutFrame.buttonFrame
	if not frame.template then
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end

	local width, height = frame:GetSize()
	frame:Size(width+3, height)

	for _, button in next, _G.EquipmentFlyoutFrame.buttons do
		EquipmentDisplayButton(button)
	end
end

local function EquipmentUpdateNavigation()
	local navi = _G.EquipmentFlyoutFrame.NavigationFrame
	if not navi then return end

	navi:ClearAllPoints()
	navi:Point('TOPLEFT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMLEFT', 0, -E.Border - E.Spacing)
	navi:Point('TOPRIGHT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMRIGHT', 0, -E.Border - E.Spacing)

	navi:StripTextures()
	navi:SetTemplate('Transparent')
end

local function TabTextureCoords(tex, x1)
	if x1 ~= 0.16001 then
		tex:SetTexCoord(0.16001, 0.86, 0.16, 0.86)
	end
end

local function FixSidebarTabCoords()
	local hasDejaCharacterStats = E.OtherAddons.DejaCharacterStats

	local index = 1
	local tab = _G['PaperDollSidebarTab'..index]
	while tab do
		if not tab.backdrop then
			tab:CreateBackdrop()
			if tab.Icon then
				tab.Icon:SetAllPoints()
			end

			-- Forever/Camelot sidebar tabs can omit Highlight/Hider/TabBg
			if tab.Highlight then
				tab.Highlight:SetColorTexture(1, 1, 1, 0.3)
				tab.Highlight:SetAllPoints()
			end

			if tab.Hider then
				if hasDejaCharacterStats then
					tab.Hider:SetTexture()
				else
					tab.Hider:SetColorTexture(0, 0, 0, 0.8)
				end
				tab.Hider:SetAllPoints(tab.backdrop)
			end

			if tab.TabBg then
				tab.TabBg:Kill()
			end

			if index == 1 then
				for _, region in next, { tab:GetRegions() } do
					if region.SetTexCoord then
						region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
						hooksecurefunc(region, 'SetTexCoord', TabTextureCoords)
					end
				end
			end
		end

		index = index + 1
		tab = _G['PaperDollSidebarTab'..index]
	end
end

local function UpdateFactionSkinsChild(child)
	if not child.IsSkinned then
		if child.Right then
			child:StripTextures()
			child:CreateBackdrop('Transparent')
			child.backdrop:SetInside(child)

			UpdateCollapse(child.Right)
			UpdateCollapse(child.HighlightRight)

			hooksecurefunc(child.Right, 'SetAtlas', UpdateCollapse)
			hooksecurefunc(child.HighlightRight, 'SetAtlas', UpdateCollapse)
		end

		local ReputationBar = child.Content and child.Content.ReputationBar
		if ReputationBar then
			ReputationBar:StripTextures()
			ReputationBar:SetStatusBarTexture(E.media.normTex)

			if not ReputationBar.backdrop then
				ReputationBar:CreateBackdrop()
				E:RegisterStatusBar(ReputationBar)
			end
		end

		local ToggleCollapseButton = child.ToggleCollapseButton
		if ToggleCollapseButton and ToggleCollapseButton.RefreshIcon then
			hooksecurefunc(ToggleCollapseButton, 'RefreshIcon', UpdateToggleCollapseButton)

			UpdateToggleCollapseButton(ToggleCollapseButton)
		end

		child.IsSkinned = true
	end
end

local function UpdateFactionSkins(frame)
	frame:ForEachFrame(UpdateFactionSkinsChild)
end

local function PaperDollUpdateStats()
	for frame in _G.CharacterStatsPane.statsFramePool:EnumerateActive() do
		if not frame.leftGrad then
			ColorizeStatPane(frame)
		end

		local shown = frame.Background:IsShown()
		frame.leftGrad:SetShown(shown)
		frame.rightGrad:SetShown(shown)
	end
end

local function BackdropDesaturated(background, value)
	if value and background.ignoreDesaturated then
		background:SetDesaturated(false)
	end
end

local function UpdateCurrencyTransferLogLine(frame)
	if frame.IsSkinned then return end

	local CurrencyIcon = frame.CurrencyIcon
	if CurrencyIcon then
		S:HandleIcon(CurrencyIcon)
		CurrencyIcon:Size(16)
	end

	frame.IsSkinned = true
end

local function UpdateCurrencyTransferLogLines(frame)
	frame:ForEachFrame(UpdateCurrencyTransferLogLine)
end

local function GearManagerPopupFrame_OnShow(frame)
	if not frame.IsSkinned then -- set by HandleIconSelectionFrame
		S:HandleIconSelectionFrame(frame, nil, nil, 'GearManagerPopupFrame')
	end
end

function S:Blizzard_UIPanels_Game()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	-- General
	local CharacterFrame = _G.CharacterFrame
	if not CharacterFrame then return end
	S:HandlePortraitFrame(CharacterFrame)

	if _G.ReputationFrame then S:HandleTrimScrollBar(_G.ReputationFrame.ScrollBar) end
	if _G.TokenFrame then S:HandleTrimScrollBar(_G.TokenFrame.ScrollBar, true) end -- updates to this can taint transferring currencies

	if _G.PaperDollItemsFrame then
	for _, Slot in next, { _G.PaperDollItemsFrame:GetChildren() } do
		if Slot:IsObjectType('Button') or Slot:IsObjectType('ItemButton') then
			S:HandleIcon(Slot.icon)
			Slot:StripTextures()
			Slot:SetTemplate()
			Slot:StyleButton(Slot)
			Slot.icon:SetInside()
			if Slot.ignoreTexture then
				Slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
			end

			S:HandleIconBorder(Slot.IconBorder)

			if Slot.popoutButton then
				if Slot.popoutButton:GetPoint() == 'TOP' then
					Slot.popoutButton:Point('TOP', Slot, 'BOTTOM', 0, 2)
				else
					Slot.popoutButton:Point('LEFT', Slot, 'RIGHT', -2, 0)
				end
			end

			E:RegisterCooldown(_G[Slot:GetName()..'Cooldown'])
			if Slot.DisplayAsAzeriteItem then
				hooksecurefunc(Slot, 'DisplayAsAzeriteItem', UpdateAzeriteItem)
			end
			if Slot.DisplayAsAzeriteEmpoweredItem then
				hooksecurefunc(Slot, 'DisplayAsAzeriteEmpoweredItem', UpdateAzeriteEmpoweredItem)
			end
		end
	end
	end

	--Give character frame model backdrop it's color back
	for _, corner in next, { 'TopLeft', 'TopRight', 'BotLeft', 'BotRight' } do
		local bg = _G['CharacterModelFrameBackground'..corner]
		if bg then
			bg:SetDesaturated(false)
			bg.ignoreDesaturated = true -- so plugins can prevent this if they want.

			hooksecurefunc(bg, 'SetDesaturated', BackdropDesaturated)
		end
	end

	if _G.CharacterLevelText then
		_G.CharacterLevelText:FontTemplate()
	end
	if _G.CharacterStatsPane and _G.CharacterStatsPane.ItemLevelFrame and _G.CharacterStatsPane.ItemLevelFrame.Value then
		_G.CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)
		ColorizeStatPane(_G.CharacterStatsPane.ItemLevelFrame)
	end

	if not E.OtherAddons.DejaCharacterStats then
		if type(_G.PaperDollFrame_UpdateStats) == 'function' then
			hooksecurefunc('PaperDollFrame_UpdateStats', PaperDollUpdateStats)
		end

		StatsPane('EnhancementsCategory')
		StatsPane('ItemLevelCategory')
		StatsPane('AttributesCategory')
	end

	--Strip Textures
	local charframe = {
		'CharacterModelScene',
		'CharacterStatsPane',
		'CharacterFrameInset',
		'CharacterFrameInsetRight',
		'PaperDollSidebarTabs',
	}

	if _G.EquipmentFlyoutFrameHighlight then
		_G.EquipmentFlyoutFrameHighlight:StripTextures()
	end
	if _G.EquipmentFlyoutFrameButtons then
		if _G.EquipmentFlyoutFrameButtons.bg1 then
			_G.EquipmentFlyoutFrameButtons.bg1:SetAlpha(0)
		end
		_G.EquipmentFlyoutFrameButtons:DisableDrawLayer('ARTWORK')
	end

	if _G.EquipmentFlyoutFrame and _G.EquipmentFlyoutFrame.NavigationFrame then
		S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.PrevButton)
		S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.NextButton)
	end

	if type(_G.EquipmentFlyout_SetBackgroundTexture) == 'function' then
		hooksecurefunc('EquipmentFlyout_SetBackgroundTexture', EquipmentUpdateNavigation)
	end
	if type(_G.EquipmentFlyout_UpdateItems) == 'function' then
		hooksecurefunc('EquipmentFlyout_UpdateItems', EquipmentUpdateItems) -- Swap item flyout frame (shown when holding alt over a slot)
	end

	-- Icon in upper right corner of character frame
	if _G.CharacterFramePortrait then
		_G.CharacterFramePortrait:Kill()
	end

	if _G.PaperDollFrame then
		for _, scrollbar in next, {
			_G.PaperDollFrame.EquipmentManagerPane and _G.PaperDollFrame.EquipmentManagerPane.ScrollBar,
			_G.PaperDollFrame.TitleManagerPane and _G.PaperDollFrame.TitleManagerPane.ScrollBar
		} do
			S:HandleTrimScrollBar(scrollbar)
		end
	end

	for _, object in next, charframe do
		local frame = _G[object]
		if frame and frame.StripTextures then
			frame:StripTextures()
		end
	end

	--Re-add the overlay texture which was removed right above via StripTextures
	if _G.CharacterModelFrameBackgroundOverlay then
		_G.CharacterModelFrameBackgroundOverlay:SetColorTexture(0, 0, 0)
	end
	if _G.CharacterModelScene then
		_G.CharacterModelScene:CreateBackdrop()
		if _G.CharacterModelScene.backdrop then
			_G.CharacterModelScene.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
			_G.CharacterModelScene.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)
		end
		S:HandleModelSceneControlButtons(_G.CharacterModelScene.ControlFrame)
	end

	--Titles / Equipment Manager (Forever may omit panes)
	if _G.PaperDollFrame and _G.PaperDollFrame.TitleManagerPane and _G.PaperDollFrame.TitleManagerPane.ScrollBox then
		hooksecurefunc(_G.PaperDollFrame.TitleManagerPane.ScrollBox, 'Update', TitleManagerPane_Update)
	end
	if _G.PaperDollFrame and _G.PaperDollFrame.EquipmentManagerPane and _G.PaperDollFrame.EquipmentManagerPane.ScrollBox then
		hooksecurefunc(_G.PaperDollFrame.EquipmentManagerPane.ScrollBox, 'Update', EquipmentManagerPane_Update)
	end
	if _G.PaperDollFrameEquipSet then
		S:HandleButton(_G.PaperDollFrameEquipSet)
	end
	if _G.PaperDollFrameSaveSet then
		S:HandleButton(_G.PaperDollFrameSaveSet)
	end

	if _G.GearManagerPopupFrame then -- New icon selection
		_G.GearManagerPopupFrame:HookScript('OnShow', GearManagerPopupFrame_OnShow)
	end

	do --Handle Tabs at bottom of character frame
		local i = 1
		local tab, prev = _G['CharacterFrameTab'..i]
		while tab do
			S:HandleTab(tab)

			tab:ClearAllPoints()

			if prev then -- Reposition Tabs
				tab:Point('TOPLEFT', prev, 'TOPRIGHT', -5, 0)
			else
				tab:Point('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', -3, 0)
			end

			prev = tab

			i = i + 1
			tab = _G['CharacterFrameTab'..i]
		end
	end

	-- Reputation Frame
	local ReputationFrame = _G.ReputationFrame
	if ReputationFrame then
		ReputationFrame:StripTextures()
		if ReputationFrame.filterDropdown then
			S:HandleDropDownBox(ReputationFrame.filterDropdown)
		end

		local DetailFrame = ReputationFrame.ReputationDetailFrame
		if DetailFrame then
			DetailFrame:StripTextures()
			DetailFrame:SetTemplate('Transparent')
			if DetailFrame.CloseButton then
				DetailFrame.CloseButton:StripTextures()
				S:HandleCloseButton(DetailFrame.CloseButton)
			end
			S:HandleCheckBox(DetailFrame.AtWarCheckbox)
			S:HandleCheckBox(DetailFrame.MakeInactiveCheckbox)
			S:HandleCheckBox(DetailFrame.WatchFactionCheckbox)
			S:HandleButton(DetailFrame.ViewRenownButton, nil, nil, nil, true)
			S:HandleTrimScrollBar(DetailFrame.ScrollingDescriptionScrollBar)
		end
	end

	-- Currency Frame
	if _G.TokenFramePopup then
		_G.TokenFramePopup:StripTextures()
		_G.TokenFramePopup:SetTemplate('Transparent')
		if _G.TokenFrame then
			_G.TokenFramePopup:Point('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 3, -28)
		end
	end

	if _G.TokenFrame then
		if _G.TokenFrame.filterDropdown then
			S:HandleDropDownBox(_G.TokenFrame.filterDropdown)
		end
		--S:HandleButton(_G.TokenFrame.CurrencyTransferLogToggleButton) -- No no no, this taints

		local transferLogBtn = _G.TokenFrame.CurrencyTransferLogToggleButton
		if transferLogBtn and transferLogBtn.NormalTexture then
			transferLogBtn.NormalTexture:SetTexture(E.Media.Textures.Copy)
			if transferLogBtn.PushedTexture then
				transferLogBtn.PushedTexture:SetTexture(E.Media.Textures.Copy)
				transferLogBtn.PushedTexture:SetVertexColor(unpack(E.media.rgbvaluecolor))
			end
		end
	end

	if _G.CurrencyTransferLog then
		S:HandlePortraitFrame(_G.CurrencyTransferLog)
		S:HandleTrimScrollBar(_G.CurrencyTransferLog.ScrollBar)
		if _G.CurrencyTransferLog.ScrollBox then
			hooksecurefunc(_G.CurrencyTransferLog.ScrollBox, 'Update', UpdateCurrencyTransferLogLines)
		end
	end

	if _G.TokenFramePopup then
		S:HandleCheckBox(_G.TokenFramePopup.InactiveCheckbox)
		S:HandleCheckBox(_G.TokenFramePopup.BackpackCheckbox)
		S:HandleButton(_G.TokenFramePopup.CurrencyTransferToggleButton)

		local TokenPopupClose = _G.TokenFramePopup['$parent.CloseButton']
		if TokenPopupClose then
			S:HandleCloseButton(TokenPopupClose)
		end
	end

	-- Currency Transfer (new in 11.0)
	local currencyTransfer = _G.CurrencyTransferMenu
	if currencyTransfer then
		currencyTransfer:StripTextures()
		currencyTransfer:SetTemplate('Transparent')

		S:HandleCloseButton(currencyTransfer.CloseButton)
		S:HandleDropDownBox(currencyTransfer.Content.SourceSelector.Dropdown)
		S:HandleButton(currencyTransfer.Content.AmountSelector.MaxQuantityButton)
		S:HandleButton(currencyTransfer.Content.ConfirmButton)
		S:HandleButton(currencyTransfer.Content.CancelButton)
		S:HandleIcon(currencyTransfer.Content.SourceBalancePreview.BalanceInfo.CurrencyIcon)
		S:HandleIcon(currencyTransfer.Content.PlayerBalancePreview.BalanceInfo.CurrencyIcon)

		local transferInputBox = currencyTransfer.Content.AmountSelector.InputBox
		if transferInputBox then
			S:HandleEditBox(transferInputBox)
			transferInputBox.backdrop:ClearAllPoints()
			transferInputBox.backdrop:Point('TOPLEFT', 0, -3)
			transferInputBox.backdrop:Point('BOTTOMRIGHT', -1, 8)
		end
	end

	hooksecurefunc(_G.ReputationFrame.ScrollBox, 'Update', UpdateFactionSkins)
	hooksecurefunc(_G.TokenFrame.ScrollBox, 'Update', UpdateTokenSkins)
	hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', FixSidebarTabCoords)
	hooksecurefunc('PaperDollItemSlotButton_Update', PaperDollItemSlotButtonUpdate)
	hooksecurefunc(_G.CharacterFrameMixin, 'ShowSubFrame', UpdateCharacterInset)
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game')
