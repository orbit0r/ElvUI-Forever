local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

function S:BattleNetFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	local skins = {
		_G.BNToastFrame,
		_G.TimeAlertFrame,
		_G.TicketStatusFrameButton and _G.TicketStatusFrameButton.NineSlice -- Ticket Frames (not GMTicketFrames)
	}

	for i = 1, #skins do
		if skins[i] then
			skins[i]:SetTemplate('Transparent')
		end
	end

	local ReportFrame = _G.ReportFrame
	if ReportFrame then
		ReportFrame:StripTextures()
		ReportFrame:SetTemplate('Transparent')
		S:HandleCloseButton(ReportFrame.CloseButton)
		S:HandleDropDownBox(ReportFrame.ReportingMajorCategoryDropdown)
		S:HandleButton(ReportFrame.ReportButton)
		S:HandleEditBox(ReportFrame.Comment)
	end

	-- Fill me with LOVE <3

	local ReportCheatingDialog = _G.ReportCheatingDialog
	if ReportCheatingDialog then
		ReportCheatingDialog:StripTextures()
		if _G.ReportCheatingDialogCommentFrame then
			_G.ReportCheatingDialogCommentFrame:StripTextures()
		end
		S:HandleButton(_G.ReportCheatingDialogReportButton)
		S:HandleButton(_G.ReportCheatingDialogCancelButton)
		ReportCheatingDialog:SetTemplate('Transparent')
		S:HandleEditBox(_G.ReportCheatingDialogCommentFrameEditBox)
	end

	local BattleTagInviteFrame = _G.BattleTagInviteFrame
	if not BattleTagInviteFrame then return end
	BattleTagInviteFrame:StripTextures()
	BattleTagInviteFrame:SetTemplate('Transparent')

	for _, child in next, { BattleTagInviteFrame:GetChildren() } do
		if child:IsObjectType('Button') then
			S:HandleButton(child)
		end
	end
end

S:AddCallback('BattleNetFrames')
