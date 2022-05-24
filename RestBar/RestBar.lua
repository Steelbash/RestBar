local frame = CreateFrame('FRAME', 'RestBarFrame');

local mouseOverCheckPeriod = 0.1
local mouseOverLastCheckTime = 0.0

local uiStatusBar = nil
local lastRestValue = 0

local tickShowTime = 0
local tickLifeTime = 2


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
	
	local tick = uiStatusBar:CreateFontString(nil, "OVERLAY")
	tick:SetPoint("LEFT", 110, 0)
	tick:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	tick:SetTextColor(205, 0, 205, 1)
	uiStatusBar.tick = tick

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
	local p = "player"
	local x = UnitXP(p)
	local m = UnitXPMax(p)
	local r = GetXPExhaustion()
	
	if r == nil then 
		r = 0
    end
    
    if lastRestValue == nil or lastRestValue == 0 then
		lastRestValue = r
    end

	local maxValue = m * 1.5
	
	uiStatusBar:SetMinMaxValues(0, maxValue)
	uiStatusBar:SetValue(r)
	
	local diffValue = r - lastRestValue
	lastRestValue = r
	
	if diffValue ~= 0 then
		tickShowTime = GetTime()
		if diffValue > 0 then
		    uiStatusBar.tick:SetText("+"..diffValue.." rest")
		else
		    uiStatusBar.tick:SetText(diffValue.." rest")
		end
		uiStatusBar.tick:Show()
	end
	
	if mouseOverFlag then
		uiStatusBar.text:SetText(r)
    else
        uiStatusBar.text:SetText(math.floor(r/maxValue*100).."%")
    end
end

frame:SetScript("OnUpdate", function()
    if GetTime() - tickShowTime > tickLifeTime then
        uiStatusBar.tick:Hide()
    end
    
    if GetTime() - mouseOverLastCheckTime > mouseOverCheckPeriod then
        mouseOverLastCheckTime = GetTime()
        
        if mouseOverFlag ~= MouseIsOver(uiStatusBar) then
		    mouseOverFlag = MouseIsOver(uiStatusBar);
		    frame:UpdateRestBar()
		end
	end
end)

function frame:ADDON_LOADED()
end

function frame:UPDATE_EXHAUSTION()
	frame:UpdateRestBar()
end

function frame:PLAYER_UPDATE_RESTING()
    frame:UpdateRestBar()
end

function frame:PLAYER_ENTERING_WORLD()
	frame:CreateStatusBar()
    frame:UpdateRestBar()
end


------------------------------------------------------------------------

frame:SetScript('OnEvent', function()
	this[event]()
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UPDATE_EXHAUSTION")
frame:RegisterEvent("PLAYER_UPDATE_RESTING")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")


SLASH_RESTBAR1 = "/restbar"
SlashCmdList["RESTBAR"] = RB_SetPosition

