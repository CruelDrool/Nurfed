---@diagnostic disable: undefined-global

local addonName = ...
local moduleName = "BossFrames"
local displayName = moduleName

---@class Addon
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)

---@class UnitFrames
local UnitFrames = addon:GetModule("UnitFrames")

---@class BossFrames: UnitFramesModule
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
			set = function(info, value) if UnitFrames:IsEnabled() then if module.db.enabled then module:Disable() else module:Enable() end end; module.db.enabled = value end,
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
	UnitFrames:PowerBar_Update(frame.powerBar)
	UnitFrames:HealthBar_Update(frame.health)
	UnitFrames:UpdateModel(frame)
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
			UnitFrames:UpdateModel(frame)
		end
	elseif event == "UI_SCALE_CHANGED" then
		UnitFrames:UpdateModel(frame)
	end
end

function module:DisableBlizz()

	if BossTargetFrameContainer then
		BossTargetFrameContainer:SetParent(UnitFrames.UIhider)

		self:SecureHook(BossTargetFrameContainer, "ApplySystemAnchor", function(frame)
			if frame:IsVisible() then
				addon:DebugLog("UI~6~WARN~BossTargetFrameContainer.ApplySystemAnchor: frame is visible.")
				UnitFrames:SetParent(frame, UnitFrames.UIhider)
			end
		end)

		self:SecureHook(BossTargetFrameContainer, "UpdateShownState", function(frame)
			if frame:IsVisible() then
				addon:DebugLog("UI~6~WARN~BossTargetFrameContainer.UpdateShownState: frame is visible.")
				UnitFrames:SetParent(frame, UnitFrames.UIhider)
			end
		end)

		BossTargetFrameContainer:SetParent(UnitFrames.UIhider)
	else
		for i = 1, MAX_BOSS_FRAMES do
			local frame = _G["Boss"..i.."TargetFrame"]
			if not frame then return end
			frame:SetParent(UnitFrames.UIhider)
		end
	end
end

function module:EnableBlizz()
	if BossTargetFrameContainer then
		self:Unhook(PartyFrame, "ApplySystemAnchor")
		self:Unhook(PartyFrame, "UpdateShownState")
		BossTargetFrameContainer:SetParent(UIParentRightManagedFrameContainer)
	else
		for i = 1, MAX_BOSS_FRAMES do
			local frame = _G["Boss"..i.."TargetFrame"]
			if not frame then return end
			frame:SetParent(UIParent)
		end
	end
end

function module:OnInitialize()
	-- Enable if we're supposed to be enabled
	if self.db and self.db.enabled and UnitFrames:IsEnabled() then
		self:Enable()
		if #self.frames > 0 then
			UnitFrames:RunOnPlayerEnteringWorld("DisableBlizz", self)
		end
	end
end

function module:OnEnable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnEnable", self)
		addon:InfoMessage(string.format(addon.infoMessages.enableModuleInCombat, addon:WrapTextInColorCode(displayName, addon.colors.moduleName)))
		return
	end

	if #self.frames == 0 then
		for i=1,MAX_BOSS_FRAMES do
			local frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, true, i)
			table.insert(self.frames, frame)
		end
	end

	if #self.frames > 0 then
		for _, frame in ipairs(self.frames) do
			UnitFrames:EnableFrame(frame)
			Update(frame)
		end

		if UnitFrames:IsPlayerInWorld() then
			self:DisableBlizz()
		end
	end
end

function module:OnDisable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnDisable", self)
		addon:InfoMessage(string.format(addon.infoMessages.disableModuleInCombat, addon:WrapTextInColorCode(displayName, addon.colors.moduleName)))
		return
	end

	self:EnableBlizz()
	for _, frame in ipairs(self.frames) do
		UnitFrames:DisableFrame(frame)
	end
end
