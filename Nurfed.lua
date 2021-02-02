local addonName = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
addon:SetDefaultModuleLibraries("AceEvent-3.0", "AceHook-3.0")
addon:SetDefaultModuleState(false)
-- _G[addonName] = addon -- uncomment for debugging purposes

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

local defaults = {
	profile = {
		minimapIcon = {},
	}
}

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(addonName.."DB", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateConfigs")
		
	for name, mod in self:IterateModules() do
		if mod.options then
			if not self.options.args[name] then
				self.options.args.modules.args[name] = mod.options
			end
		end
	end
	
	if LDB then
		self.LDBObj = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
			type = "launcher",
			OnClick = function(frame, msg)
				if msg == "RightButton" then
					if LibStub("AceConfigDialog-3.0").OpenFrames[addonName] then
						-- PlaySound("GAMEGENERICBUTTONPRESS")
						PlaySound(624)
						LibStub("AceConfigDialog-3.0"):Close(addonName)
					else
						-- PlaySound("GAMEDIALOGOPEN")
						PlaySound(88)
						LibStub("AceConfigDialog-3.0"):Open(addonName)
					end
				end
			end,
			icon = "Interface\\AddOns\\"..addonName.."\\Images\\locked",
			OnTooltipShow = function(tooltip)
				if not tooltip or not tooltip.AddLine then return end
				tooltip:ClearLines() 
				tooltip:AddLine(addonName, 0, 0.75, 1)
				tooltip:AddLine("Right Click - Toggle Options", 0.75, 0.75, 0.75)				
			end,
		})

		if LDBIcon then
			LDBIcon:Register(addonName, self.LDBObj, self.db.profile.minimapIcon)
		end
	end
	
	self:SetupOptions()
end

function addon:OnEnable()
	if LDB and LDBIcon then
		LDBIcon:Refresh(addonName, addon.db.profile.minimapIcon)
	end
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function addon:UpdateConfigs()
	if LDB and LDBIcon then
		LDBIcon:Refresh(addonName, addon.db.profile.minimapIcon)
	end
	LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end

function addon:SetupOptions()
	self.options.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) }
	self.options.name = addonName
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(addonName, self.options)
	-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
end

addon.options = {
	childGroups = "tree",
	type = "group",
	plugins = {},
	args = {
		minimapIcon = {
			order = 1,
			type = "toggle",
			name = "Minimap Icon",
			desc = "Show a Icon to open the config at the Minimap",
			get = function() return not addon.db.profile.minimapIcon.hide end,
			set = function(info, value) addon.db.profile.minimapIcon.hide = not value; LDBIcon[value and "Show" or "Hide"](LDBIcon, addonName) end,
			-- disabled = function() return not LDBIcon end,
			disabled = function() return not LDBTitan end,
		},
		general = {
			order = 2,
			type = "group",
			name = "General",
			args = {},
		},
		modules = {
			order = 2,
			type = "group",
			name = "Modules",
			-- cmdInline = true,
			args = {},
		},
	},
}

function addon:Transliterate(str, mark)
	return LibStub("LibTranslit-1.0"):Transliterate(str, mark)
end

function addon:rgbhex(r, g, b)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	return string.format("|cff%02x%02x%02x", (r or 1) * 255, (g or 1) * 255, (b or 1) * 255)
end

function addon:CommaNumber(n)
	n = ("%.0f"):format(n)
   	local left,num,right = string.match(n,'^([^%d]*%d)(%d+)(.-)$')
   	return left and left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse()) or n --..right
end

function addon:FormatNumber(n)
	local number = math.abs(n)
	local text
	if number >= 1000000000 then
		text = format("%.3fG", number/1000000000)
	elseif number >= 1000000 then
		text = format("%.2fM", number/1000000)
	elseif number >= 10000 then
		text = format("%.1fk", number/1000)
	else text = self:CommaNumber(number)
	end
	if n < 0 then
		text = "-"..text
	end	
	return text
end

function addon:print(msg, out, r, g, b, ...)
	if type(out) == "string" then
		msg = msg:format(out, r, g, b, ...)
	end
	out	= _G["ChatFrame"..(type(out) == "number" and out or 1)]
	out:AddMessage(msg, (type(r) == "number" and r or 1), (type(g) == "number" and g or 1), (type(b) == "number" and b or 1))
end

function addon:Binding(bind)
	local bind = bind or ""
	bind = bind:upper(bind)
	bind = bind:gsub("CTRL%-", "C-")
	bind = bind:gsub("ALT%-", "A-")
	bind = bind:gsub("SHIFT%-", "S-")
	bind = bind:gsub("NUM PAD", "NP")
	bind = bind:gsub("NUMPAD", "NP")
	bind = bind:gsub("BACKSPACE", "Bksp")
	bind = bind:gsub("SPACEBAR", "Space")
	bind = bind:gsub("PAGE", "Pg")
	bind = bind:gsub("DOWN", "Dn")
	bind = bind:gsub("ARROW", "")
	bind = bind:gsub("INSERT", "Ins")
	bind = bind:gsub("DELETE", "Del")
	bind = bind:gsub("ESCAPE", "Esc")
	bind = bind:gsub("BUTTON(%d)", "B%1")
	bind = bind:gsub("CAPSLOCK", "Cps Lck")
	bind = bind:gsub("%s$", "")
	return bind
end

----------------------------------------------------------------------
-- This should eventually be moved over to the individual unitframe and create enable/disable-functions. This is not the place for this.
function addon:PLAYER_ENTERING_WORLD()
	CompactRaidFrameManager:SetFrameLevel(4)
	UIErrorsFrame:SetPoint("TOP", UIParent,0,-140)
	-- CameraPanelOptions.cameraDistanceMaxFactor.maxValue = 4
	ConsoleExec("cameraDistanceMaxFactor 2.6")
	ConsoleExec("cameraDistanceMax 50")
	
	TargetFrame:UnregisterAllEvents()
	TargetFrame:SetScript("OnEvent", nil)
	UnregisterUnitWatch(TargetFrame)
	TargetFrame:Hide()
	function TargetFrame_Update() end
	function TargetFrame_OnEvent() end
	
	TargetFrameNumericalThreat:UnregisterAllEvents()
	TargetFrameNumericalThreat:SetScript("OnShow", nil)
	TargetFrameNumericalThreat:SetScript("OnHide", nil)
	TargetFrameNumericalThreat:SetScript("OnEvent", nil)
	TargetFrameNumericalThreat:Hide()
	function UnitFrameThreatIndicator_Initialize() end
	function UnitFrameThreatIndicator_OnEvent() end
	
	ComboFrame:UnregisterAllEvents()
	ComboFrame:SetScript("OnEvent", nil)
	ComboFrame:Hide()
	function ComboFrame_Update() end
	function ComboFrame_OnEvent() end
	
	PetFrame:UnregisterAllEvents()
	PetFrame:SetScript("OnEvent", nil)
	PetFrame:Hide()
	function PetFrame_Update() end
	function PetFrame_OnEvent() end
	
	PlayerFrame:UnregisterAllEvents()
	UnregisterUnitWatch(PlayerFrame)
	PlayerFrame:Hide()
	function PlayerFrame_Update() end
	function PlayerFrame_OnEvent() end
	
	for i = 1, MAX_PARTY_MEMBERS do
		local party = _G["PartyMemberFrame"..i]
		party:UnregisterAllEvents()
		party:SetScript("OnEnter", nil)
		party:SetScript("OnEvent", nil)
		party:SetScript("OnUpdate", nil)
		party:ClearAllPoints()
		party:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", -400, 500)
		UnregisterUnitWatch(party)
		party:Hide()
	end
	
	function PartyMemberFrame_OnEvent() end
	function PartyMemberFrame_OnUpdate() end
	function PartyMemberFrame_UpdateMemberHealth() end
	
	for i = 1, MAX_BOSS_FRAMES do 
		local bossframe = _G["Boss"..i.."TargetFrame"]
		bossframe:UnregisterAllEvents()
		bossframe:SetScript("OnEvent", nil)
		bossframe:SetScript("OnUpdate", nil)
		UnregisterUnitWatch(bossframe)
		bossframe:Hide()
	end
	
	UnregisterUnitWatch(FocusFrame)
	FocusFrame:UnregisterAllEvents()
	FocusFrame:SetScript("OnEvent", nil)
	FocusFrame:Hide()
	function FocusFrame_Update() end
	function FocusFrame_OnEvent() end
	
	CastingBarFrame:UnregisterAllEvents()
	CastingBarFrame:SetScript("OnLoad", nil)
	CastingBarFrame:SetScript("OnEvent", nil)
	CastingBarFrame:SetScript("OnUpdate", nil)
	CastingBarFrame:SetScript("OnShow", nil)
	CastingBarFrame:Hide()
	-- function CastingBarFrame_OnShow() end
	-- function CastingBarFrame_OnEvent() end
	-- function CastingBarFrame_OnUpdate() end
	
end