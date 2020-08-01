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
	},
}

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

local bossFrames = {}

local function Update(frame)
	UnitFrames:PowerBar_Update(frame.powerBar, frame.unit)
	UnitFrames:HealthBar_Update(frame.health)
	if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
	-- if UnitExists(frame.unit) then
		UnitFrames:UpdateInfo(frame)
		UnitFrames:UpdateRaidIcon(frame)
	-- end
end

local function OnEvent(frame, event, ...)
	
	if not frame.isEnabled then return end
	
	local arg1, arg2, arg3, arg4, arg5 = ...
		if event == "PLAYER_ENTERING_WORLD" or event == "DISPLAY_SIZE_CHANGED" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
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

local function DisableBlizz()

	for i = 1, MAX_BOSS_FRAMES do
		local frame = _G["Boss"..i.."TargetFrame"]
		blizzFrames[i] = {
			OnEnter = frame:GetScript("OnEnter"),
			OnEvent = frame:GetScript("OnEvent"),
			OnUpdate = frame:GetScript("OnUpdate"),
		}
		
		frame:SetScript("OnEvent", nil)
		frame:SetScript("OnUpdate", nil)
		
		UnregisterUnitWatch(frame)
		frame:Hide()
	end
end

local function EnableBlizz()
	for i = 1, MAX_BOSS_FRAMES do
		local frame = _G["Boss"..i.."TargetFrame"]
		
		frame:SetScript("OnEnter", blizzFrames[i].OnEnter)
		frame:SetScript("OnEvent", blizzFrames[i].OnEvent)
		frame:SetScript("OnUpdate", blizzFrames[i].OnUpdate)
		RegisterUnitWatch(frame)
	end
end


function module:OnInitialize()
	-- Enable if we're supposed to be enabled
	if self.db and self.db.enabled and UnitFrames:IsEnabled() then
		self:Enable()
	end
end

function module:OnEnable()
	DisableBlizz()
	if table.getn(bossFrames) == 0 then
		for i=1,5 do
			local frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, _G["Boss"..i.."TargetFrameDropDown"], true, i)
			table.insert(bossFrames, frame)
		end
	end
	
	if table.getn(bossFrames) > 0 then
		for _, frame in ipairs(bossFrames) do
			UnitFrames:EnableFrame(frame)
			Update(frame)
		end
	end
end

function module:OnDisable()
	EnableBlizz()
	for _, frame in ipairs(bossFrames) do
		UnitFrames:DisableFrame(frame)
	end
end
