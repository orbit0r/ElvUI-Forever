local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function Skin_SendMail()
	for i = 1, _G.ATTACHMENTS_MAX_SEND do
		local btn = _G['SendMailAttachment'..i]
		if not btn.template then
			btn:StripTextures()
			btn:SetTemplate()
			btn:StyleButton()

			S:HandleIconBorder(btn.IconBorder)
		end

		local icon = btn:GetNormalTexture()
		if icon then
			icon:SetTexCoords()
			icon:SetInside()
		end
	end
end

local function Skin_OpenMail()
	for i = 1, _G.ATTACHMENTS_MAX_RECEIVE do
		local btn = _G['OpenMailAttachmentButton'..i]
		if not btn.template then
			btn:StripTextures()
			btn:SetTemplate(nil, true)
			btn:StyleButton()

			S:HandleIconBorder(btn.IconBorder)
		end

		local icon = btn.icon or btn.Icon
		if icon then
			icon:SetTexCoords()
			icon:SetInside()
		end
	end
end

local function Skin_InboxItems()
	for i = 1, _G.INBOXITEMS_TO_DISPLAY do
		local item = _G['MailItem'..i]
		item:StripTextures() -- background

		local btn = item.Button
		if not btn.template then
			btn:StripTextures()
			btn:SetTemplate(nil, true)
			btn:StyleButton()

			S:HandleIconBorder(btn.IconBorder)
		end

		local icon = btn.icon or btn.Icon
		if icon then
			icon:SetTexCoords()
			icon:SetInside()
		end
	end
end

function S:MailFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.mail) then return end

	local MailFrame = _G.MailFrame
	if not MailFrame then return end
	S:HandlePortraitFrame(MailFrame)

	if _G.InboxFrame and _G.MailItem1 and _G.MailItem7 then
		_G.InboxFrame:CreateBackdrop('Transparent')
		_G.InboxFrame.backdrop:Point('TOPLEFT', _G.MailItem1, 'TOPLEFT')
		_G.InboxFrame.backdrop:Point('BOTTOMRIGHT', _G.MailItem7, 'BOTTOMRIGHT')
	end

	if _G.InboxPrevPageButton then
		S:HandleNextPrevButton(_G.InboxPrevPageButton, nil, nil, true)
		_G.InboxPrevPageButton:StripTexts()
		_G.InboxPrevPageButton:Point('BOTTOMLEFT', 30, 100)
	end

	if _G.InboxNextPageButton then
		S:HandleNextPrevButton(_G.InboxNextPageButton, nil, nil, true)
		_G.InboxNextPageButton:StripTexts()
		_G.InboxNextPageButton:Point('BOTTOMRIGHT', -80, 100)
	end

	if _G.MailFrameTab1 and _G.MailFrameTab2 then
		_G.MailFrameTab1:StripTextures()
		_G.MailFrameTab2:StripTextures()
		S:HandleTab(_G.MailFrameTab1)
		S:HandleTab(_G.MailFrameTab2)

		-- Reposition Tabs
		_G.MailFrameTab1:ClearAllPoints()
		_G.MailFrameTab2:ClearAllPoints()
		_G.MailFrameTab1:Point('TOPLEFT', _G.MailFrame, 'BOTTOMLEFT', -3, 0)
		_G.MailFrameTab2:Point('TOPLEFT', _G.MailFrameTab1, 'TOPRIGHT', -5, 0)
	end

	-- send mail
	if not _G.SendMailScrollFrame then return end
	_G.SendMailScrollFrame:StripTextures(true)
	_G.SendMailScrollFrame:SetTemplate()

	S:HandleTrimScrollBar(_G.SendMailScrollFrame.ScrollBar)

	S:HandleEditBox(_G.SendMailNameEditBox)
	S:HandleEditBox(_G.SendMailSubjectEditBox)
	S:HandleEditBox(_G.SendMailMoneyGold)
	S:HandleEditBox(_G.SendMailMoneySilver)
	S:HandleEditBox(_G.SendMailMoneyCopper)
	if _G.SendMailMoneyBg then _G.SendMailMoneyBg:Kill() end
	if _G.SendMailMoneyInset then _G.SendMailMoneyInset:StripTextures() end

	if _G.SendMailNameEditBox and _G.SendMailFrame then
		_G.SendMailNameEditBox:ClearAllPoints()
		_G.SendMailNameEditBox:Point('TOPLEFT', _G.SendMailFrame, 'TOPLEFT', 90, -30)
		_G.SendMailNameEditBox:Width(109)
		_G.SendMailNameEditBox:Height(18)
	end

	if _G.SendMailSubjectEditBox and _G.SendMailNameEditBox then
		_G.SendMailSubjectEditBox:Point('TOPLEFT', _G.SendMailNameEditBox, 'BOTTOMLEFT', 0, -10)
		_G.SendMailSubjectEditBox:Width(214)
		_G.SendMailSubjectEditBox:Height(18)
	end

	if _G.SendMailFrame then
		_G.SendMailFrame:StripTextures()
	end

	Skin_SendMail()
	Skin_OpenMail()
	Skin_InboxItems()

	if type(_G.SendMailFrame_Update) == 'function' then
		hooksecurefunc('SendMailFrame_Update', Skin_SendMail)
	end
	if type(_G.OpenMail_Update) == 'function' then
		hooksecurefunc('OpenMail_Update', Skin_OpenMail)
	end
	if type(_G.InboxFrame_Update) == 'function' then
		hooksecurefunc('InboxFrame_Update', Skin_InboxItems)
	end

	S:HandleButton(_G.SendMailMailButton, true)
	S:HandleButton(_G.SendMailCancelButton, true)

	S:HandleRadioButton(_G.SendMailSendMoneyButton)
	S:HandleRadioButton(_G.SendMailCODButton)

	if _G.SendMailSendMoneyButton and _G.SendMailMoney then
		_G.SendMailSendMoneyButton:ClearAllPoints()
		_G.SendMailSendMoneyButton:Point('TOPRIGHT', _G.SendMailMoney, 'TOPRIGHT', 30, 8)
	end

	-- open mail (cod)
	if _G.OpenMailFrame then
		_G.OpenMailFrame:StripTextures(true)
		_G.OpenMailFrame:SetTemplate('Transparent')
		if _G.OpenMailFrameInset then _G.OpenMailFrameInset:Kill() end

		S:HandleCloseButton(_G.OpenMailFrameCloseButton)
		S:HandleButton(_G.OpenMailReportSpamButton, true)
		S:HandleButton(_G.OpenMailReplyButton, true)
		S:HandleButton(_G.OpenMailDeleteButton, true)
		S:HandleButton(_G.OpenMailCancelButton, true)
	end
	S:HandleButton(_G.OpenAllMail, true)

	_G.InboxFrame:StripTextures()
	_G.MailFrameInset:Kill()

	_G.OpenMailScrollFrame:StripTextures(true)
	_G.OpenMailScrollFrame:SetTemplate()

	S:HandleTrimScrollBar(_G.OpenMailScrollFrame.ScrollBar)

	_G.InvoiceTextFontNormal:FontTemplate(nil, 13)
	_G.MailTextFontNormal:FontTemplate(nil, 13)
	_G.InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	_G.MailTextFontNormal:SetTextColor(1, 1, 1)
	_G.OpenMailArithmeticLine:Kill()

	_G.OpenMailLetterButton:StripTextures()
	_G.OpenMailLetterButton:SetTemplate(nil, true)
	_G.OpenMailLetterButton:StyleButton()
	_G.OpenMailLetterButtonIconTexture:SetTexCoords()
	_G.OpenMailLetterButtonIconTexture:SetInside()

	_G.OpenMailMoneyButton:StripTextures()
	_G.OpenMailMoneyButton:SetTemplate(nil, true)
	_G.OpenMailMoneyButton:StyleButton()
	_G.OpenMailMoneyButtonIconTexture:SetTexCoords()
	_G.OpenMailMoneyButtonIconTexture:SetInside()

	_G.OpenMailReplyButton:Point('RIGHT', _G.OpenMailDeleteButton, 'LEFT', -2, 0)
	_G.OpenMailDeleteButton:Point('RIGHT', _G.OpenMailCancelButton, 'LEFT', -2, 0)
	_G.SendMailMailButton:Point('RIGHT', _G.SendMailCancelButton, 'LEFT', -2, 0)
end

S:AddCallback('MailFrame')
