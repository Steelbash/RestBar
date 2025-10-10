local frame = CreateFrame('FRAME', 'RestBarFrame');

local rbUpdatePeriod = 0.1      -- update bar period
local rbLastUpdateTime = 0.0

local uiStatusBar = nil
local lastRestValue = 0

local isStartResting = false
local tickRestStartTime = 0
local amountRestOverTime = 0

local tickRestCalcTime = 5       -- calc rest period


function frame:CreateStatusBar()
    if uiStatusBar ~= nil then
		uiStatusBar:Hide()
    end
    
	uiStatusBar = CreateFrame("StatusBar", nil, PlayerFrame, "TextStatusBar")
	uiStatusBar:SetWidth(100)
	uiStatusBar:SetHeight(12)
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

	uiStatusBar:ClearAllPoints()
	
	if RT_STATUS_BAR_POS == nil then	
		RT_STATUS_BAR_POS = "top"
	end

	if RT_STATUS_BAR_POS == "top" then
		uiStatusBar:SetPoint("TOPLEFT", 114, -10)
		uiStatusBar.bd:SetPoint("TOPLEFT", -10, 4)
		uiStatusBar.bd:SetTexCoord(0.0234375, 0.6875, 0.0, 1.0)
	end
	
	if RT_STATUS_BAR_POS == "bottom" then
		uiStatusBar:SetPoint("BOTTOMLEFT", 114, 23)
		uiStatusBar.bd:SetPoint("TOPLEFT", -12, 0)
		uiStatusBar.bd:SetTexCoord(0.0234375, 0.6875, 1.0, 0.0)
	end
	
	uiStatusBar:SetValue(0)
	uiStatusBar:Show()
end

function frame:UpdateRestBar()
	local x = UnitXP("player")
	local r = GetXPExhaustion()
	local maxRestValue = UnitXPMax("player") * 1.5
	local tentsCount = 0
	local timeForFullRest = 0
	
	if (UnitLevel("player") == 60) then
		if uiStatusBar:IsVisible() then
			uiStatusBar:Hide()
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

