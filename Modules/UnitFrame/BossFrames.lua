local addonName = ...
local moduleName = "BossFrames"
local displayName = moduleName
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local UnitFrames = addon:GetModule("UnitFrames")
local module = UnitFrames:NewModule(moduleName)
local unit = "boss"

module.defaults = {
	enabled = true,
	formats = {
		name = "[$level] $name",
	},
	
	frames = {
		[unit.."1"] = {
			["x"] = 0,
			["y"] = 158,
			["point"] = "RIGHT",
			["scale"] = 1,
		},
		[unit.."2"] = {
			["x"] = 0,
			["y"] = 93,
			["point"] = "RIGHT",
			["scale"] = 1,
		},
		[unit.."3"] = {
			["x"] = 0,
			["y"] = 28,
			["point"] = "RIGHT",
			["scale"] = 1,
		},
		[unit.."4"] = {
			["x"] = 0,
			["y"] = -37,
			["point"] = "RIGHT",
			["scale"] = 1,
		},
		[unit.."5"] = {
			["x"] = 0,
			["y"] = -102,
			["point"] = "RIGHT",
			["scale"] = 1,
		},
	},
}

module.options = {
	type = "group",
	name = displayName,
	-- desc = "",
	-- icon = "Interface\\GossipFrame\\FooIconThatDoesntExist",
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = "Enabled",
			-- desc = "",
			get = function() return module.db.enabled end,
			set = function() if UnitFrames:IsEnabled() then if module.db.enabled then module:Disable() else module:Enable() end end; if module.db.enabled then module.db.enabled = false else module.db.enabled = true end end,
		},
		formats = {
			order = 2,
			type = "group",
			width = "full",
			name = "Text formats",
			guiInline = true,
			args = {
				name = {
					order = 1,
					type = "input",
					name = "Name",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("name", nil, moduleName) end,
					set = function(info, value) module.db.formats.name = value;if module.frames then for _,v in pairs(module.frames) do UnitFrames:UpdateInfo(v) end end end,
				},
				health = {
					order = 2,
					type = "input",
					name = "Health",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("health", nil, moduleName) end,
					set = function(info, value) module.db.formats.health = value end,
				},
				power = {
					order = 3,
					type = "input",
					name = "Power",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("power", nil, moduleName) end,
					set = function(info, value) module.db.formats.power = value end,
				},
			},
		},
	},
}

module.frames = {}

local events = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_TARGET_CHANGED",
	"INSTANCE_ENCOUNTER_ENGAGE_UNIT",
	"DISPLAY_SIZE_CHANGED",
	"UNIT_CLASSIFICATION_CHANGED",
	"RAID_TARGET_UPDATE",
	"UNIT_MODEL_CHANGED",
	"UNIT_TARGETABLE_CHANGED",
	"UNIT_FACTION",
	"UNIT_LEVEL",
	"UNIT_NAME_UPDATE",
	"UI_SCALE_CHANGED",
}



local function Update(frame)
	UnitFrames:PowerBar_Update(frame.powerBar, frame.unit)
	UnitFrames:HealthBar_Update(frame.health)
	if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
	if UnitExists(frame.unit) then
		UnitFrames:UpdateInfo(frame)
		UnitFrames:UpdateRaidIcon(frame)
	end
end

local function OnEvent(frame, event, ...)
	
	if not frame.isEnabled then return end
	
	local arg1, arg2, arg3, arg4, arg5 = ...
		if event == "PLAYER_ENTERING_WORLD" then
			Update(frame)
			module:DisableBlizz()
		elseif event == "DISPLAY_SIZE_CHANGED" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
		Update(frame)
		if UnitExists("target") and UnitIsUnit("target", frame.unit) then
			frame:LockHighlight()
		else
			frame:UnlockHighlight()
		end
	elseif event == "UNIT_LEVEL" or event == "UNIT_FACTION" or event == "UNIT_NAME_UPDATE" or event == "UNIT_CLASSIFICATION_CHANGED" then
		if arg1 == frame.unit then
			UnitFrames:UpdateInfo(frame)
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		if UnitExists("target") and UnitIsUnit("target", frame.unit) then
			frame:LockHighlight()
		else
			frame:UnlockHighlight()
		end
	elseif event == "UNIT_TARGETABLE_CHANGED" then
		if arg1 == frame.unit then
			-- if UnitCanAttack("player", frame.unit) then
				-- frame:SetAlpha(1.0)
			-- else
				-- frame:SetAlpha(0.6)
			-- end
			Update(frame)
			CloseDropDownMenus()
		end
	elseif event == "RAID_TARGET_UPDATE" then
		UnitFrames:UpdateRaidIcon(frame)
	elseif event == "UNIT_MODEL_CHANGED" then
		if arg1 == frame.unit then
			if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
		end
	elseif event == "UI_SCALE_CHANGED" then
		if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit)end
	end
end


local blizzFrames = {}

function module:DisableBlizz()
	
	if #blizzFrames > 0 then return end
	
	for i = 1, MAX_BOSS_FRAMES do
		local frame = _G["Boss"..i.."TargetFrame"]
		if not frame then return end
		local spellBar = _G[frame:GetName().."SpellBar"]

		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()

		if not point then return end

		spellBar.showCastbar = false
		spellBar:SetScript("OnEvent", nil)
		
		blizzFrames[i] = {
				[1] = point,
				[2] = relativeTo:GetName(),
				[3] = relativePoint,
				[4] = xOfs,
				[5] = yOfs,
				[6] = frame:IsClampedToScreen(),
		}

		frame:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
		if i == 1 then
			frame:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		end

		frame:SetClampedToScreen(false)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", -500, 500)
		frame:Hide()
	end
end

function module:EnableBlizz()
	
	if #blizzFrames == 0 then return end

	for i = 1, #blizzFrames do
		local frame = _G["Boss"..i.."TargetFrame"]
		if not frame then return end
		local spellBar = _G[frame:GetName().."SpellBar"]
		local point, relativeTo, relativePoint, xOfs, yOfs, IsClampedToScreen = unpack(blizzFrames[i])

		spellBar.showCastbar = GetCVarBool("showTargetCastbar")
		spellBar:SetScript("OnEvent", Target_Spellbar_OnEvent)

		frame:RegisterEvent("UNIT_TARGETABLE_CHANGED")
		if i == 1 then
			frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		end

		frame:ClearAllPoints()
		frame:SetPoint(point, _G[relativeTo], relativePoint, xOfs, yOfs)
		frame:SetClampedToScreen(IsClampedToScreen)
	end

	blizzFrames = {}
end


function module:OnInitialize()
	-- Enable if we're supposed to be enabled
	if self.db and self.db.enabled and UnitFrames:IsEnabled() then
		self:Enable()
	end
end

function module:OnEnable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnEnable", module)
		addon:InfoMessage(string.format(addon.infoMessages.enableModuleInCombat, addon:WrapTextInColorCode(moduleName, addon.colors.moduleName)))
		return
	end
	self:DisableBlizz()
	if table.getn(self.frames) == 0 then
		for i=1,MAX_BOSS_FRAMES do
			local frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, _G["Boss"..i.."TargetFrameDropDown"] or "BOSS", true, i)
			table.insert(self.frames, frame)
		end
	end
	
	if table.getn(self.frames) > 0 then
		for _, frame in ipairs(self.frames) do
			UnitFrames:EnableFrame(frame)
			Update(frame)
		end
	end
end

function module:OnDisable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnDisable", module)
		addon:InfoMessage(string.format(addon.infoMessages.disableModuleInCombat, addon:WrapTextInColorCode(moduleName, addon.colors.moduleName)))
		return
	end
	self:EnableBlizz()
	for _, frame in ipairs(self.frames) do
		UnitFrames:DisableFrame(frame)
	end
end
