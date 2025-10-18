local frame = CreateFrame('FRAME', 'RestBarFrame');

local rbUpdatePeriod = 0.1      -- update bar period
local rbLastUpdateTime = 0.0

local mainFrame = nil
local uiStatusBar = nil
local lastRestValue = 0

local isStartResting = false
local tickRestStartTime = 0
local amountRestOverTime = 0

local tickRestCalcTime = 5       -- calc rest period


function frame:CreateXPerlStatusBar()
	mainFrame = CreateFrame("Frame", nil, XPerl_Player_PortraitFrame)
	mainFrame:SetWidth(160)
	mainFrame:SetHeight(22)

	mainFrame:SetBackdrop({
		bgFile = "Interface\\Addons\\XPerl\\Images\\XPerl_FrameBack",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 16,
		insets = {
			left = 5,
			right = 5,
			top = 5,
			bottom = 5
		}
	})

	mainFrame:SetBackdropColor(0, 0, 0, 1)
	mainFrame:SetBackdropBorderColor(1, 1, 1, 1)
	
	
	uiStatusBar = CreateFrame("StatusBar", nil, mainFrame, "TextStatusBar")
	uiStatusBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 6, -6)
	uiStatusBar:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -6, 6)
	
	uiStatusBar:SetStatusBarTexture(XPerl_GetBarTexture())
	uiStatusBar:SetStatusBarColor(255, 0, 255)
	
	local text = uiStatusBar:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER", 0, 0)
	text:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE")
	uiStatusBar.text = text
	
	local bg = uiStatusBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(uiStatusBar)
	bg:SetTexture(TEXTURE)
	bg:SetVertexColor(0, 0, 0, 0.5)
	uiStatusBar.bg = bg
	
	local tents = uiStatusBar:CreateFontString(nil, "OVERLAY", "GameFontGreen")
	tents:SetPoint("LEFT", 153, 0)
	tents:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	uiStatusBar.tents = tents
	
	
	local timeLeft = uiStatusBar:CreateFontString(nil, "OVERLAY")
	timeLeft:SetPoint("RIGHT", uiStatusBar, "RIGHT", -5, 0)
	timeLeft:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE")
	uiStatusBar.timeLeft = timeLeft
	
	if RT_STATUS_BAR_POS == nil then	
		RT_STATUS_BAR_POS = "top"
	end

	if RT_STATUS_BAR_POS == "top" then
		mainFrame:SetPoint("BOTTOMLEFT", XPerl_Player_PortraitFrame, "TOPRIGHT", -3, -3)
	end
	
	if RT_STATUS_BAR_POS == "bottom" then
		mainFrame:SetPoint("TOPLEFT", XPerl_Player_StatsFrame, "BOTTOMLEFT", 0, 2)
	end
	
	uiStatusBar:SetValue(0)
end	


function frame:CreateClassicStatusBar()
	mainFrame = CreateFrame("Frame", nil, PlayerFrame)
	mainFrame:SetWidth(100)
	mainFrame:SetHeight(12)

	uiStatusBar = CreateFrame("StatusBar", nil, mainFrame, "TextStatusBar")
	uiStatusBar:SetAllPoints()
	uiStatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	uiStatusBar:SetStatusBarColor(255, 0, 255)

	local bg = uiStatusBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(uiStatusBar)
	bg:SetTexture(TEXTURE)
	bg:SetVertexColor(0, 0, 0, 0.5)
	uiStatusBar.bg = bg

	local bd = uiStatusBar:CreateTexture(nil, "OVERLAY")
	bd:SetWidth(120)
	bd:SetHeight(18)
	bd:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
	uiStatusBar.bd = bd

	local text = uiStatusBar:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER", 0, 0)
	text:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE")
	uiStatusBar.text = text
	
	local tents = uiStatusBar:CreateFontString(nil, "OVERLAY", "GameFontGreen")
	tents:SetPoint("LEFT", 105, 0)
	tents:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	uiStatusBar.tents = tents
	
	
	local timeLeft = uiStatusBar:CreateFontString(nil, "OVERLAY")
	timeLeft:SetPoint("RIGHT", uiStatusBar, "RIGHT", -5, 0)
	timeLeft:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE")
	uiStatusBar.timeLeft = timeLeft

	mainFrame:ClearAllPoints()
	
	if RT_STATUS_BAR_POS == nil then	
		RT_STATUS_BAR_POS = "top"
	end

	if RT_STATUS_BAR_POS == "top" then
		mainFrame:SetPoint("TOPLEFT", 114, -10)
		uiStatusBar.bd:SetPoint("TOPLEFT", -10, 4)
		uiStatusBar.bd:SetTexCoord(0.0234375, 0.6875, 0.0, 1.0)
	end
	
	if RT_STATUS_BAR_POS == "bottom" then
		mainFrame:SetPoint("BOTTOMLEFT", 114, 23)
		uiStatusBar.bd:SetPoint("TOPLEFT", -12, 0)
		uiStatusBar.bd:SetTexCoord(0.0234375, 0.6875, 1.0, 0.0)
	end
	
	uiStatusBar:SetValue(0)
end

function frame:CreateStatusBar()
    if mainFrame ~= nil then
		mainFrame:Hide()
    end
    
    if XPerl_Player then 
		frame:CreateXPerlStatusBar()
	else
		frame:CreateClassicStatusBar()
	end
end

function frame:UpdateRestBar()
	local x = UnitXP("player")
	local r = GetXPExhaustion()
	local maxRestValue = UnitXPMax("player") * 1.5
	local tentsCount = 0
	local timeForFullRest = 0
	
	if (UnitLevel("player") == 60) then
		if mainFrame:IsVisible() then
			mainFrame:Hide()
		end
		return
    end
		
	if r == nil then 
		r = 0
    end
    
    if lastRestValue == 0 then
		lastRestValue = r
    end
    
    local diffValue = r - lastRestValue
	lastRestValue = r

	
	if IsResting() == nil and isStartResting then
		isStartResting = false
		uiStatusBar.tents:Hide()
	end
	
	if IsResting() ~= nil then
		if not isStartResting then
			isStartResting = true
			tickRestStartTime = GetTime()
			amountRestOverTime = 0
		end
	
		amountRestOverTime = amountRestOverTime + diffValue

		if (GetTime() - tickRestStartTime > tickRestCalcTime) then
			tickRestStartTime = GetTime()
			
			if (amountRestOverTime > 0) then
				local restInSecond = amountRestOverTime/tickRestCalcTime
				tentsCount = math.floor(restInSecond/(maxRestValue*0.001) + 0.5)
				timeForFullRest = (maxRestValue - r) / (tentsCount * (maxRestValue*0.001))

				if tentsCount > 0 then
					uiStatusBar.tents:SetText("x"..tostring(tentsCount))
					uiStatusBar.tents:Show()
					
					uiStatusBar.timeLeft:SetText(format("%dm",floor(timeForFullRest/60)))
					uiStatusBar.timeLeft:Show()
				end

				amountRestOverTime = 0
			end
			
			if tentsCount == 0 then
				uiStatusBar.tents:Hide()
				uiStatusBar.timeLeft:Hide()
			end
		end
	else
		uiStatusBar.tents:Hide()
		uiStatusBar.timeLeft:Hide()
	end


	uiStatusBar:SetMinMaxValues(0, maxRestValue)
	uiStatusBar:SetValue(r)

	if MouseIsOver(uiStatusBar) then
		uiStatusBar.text:SetText(r)
    else
		uiStatusBar.text:SetText(math.floor(r/maxRestValue*100).."%")
    end
end


frame:SetScript("OnUpdate", function()
	if GetTime() - rbLastUpdateTime > rbUpdatePeriod then
        rbLastUpdateTime = GetTime()
        frame:UpdateRestBar()
	end
end)

function frame:VARIABLES_LOADED()
	frame:CreateStatusBar()
end


frame:SetScript('OnEvent', function()
	this[event]()
end)

function RB_SetPosition(msg)
	if msg == "top" then
		RT_STATUS_BAR_POS = "top"
		frame:CreateStatusBar()
		frame:UpdateRestBar()
	end
	
	if msg == "bottom" then
		RT_STATUS_BAR_POS = "bottom"
		frame:CreateStatusBar()
		frame:UpdateRestBar()
	end
end

frame:RegisterEvent("VARIABLES_LOADED")

SLASH_RESTBAR1 = "/restbar"
SlashCmdList["RESTBAR"] = RB_SetPosition

