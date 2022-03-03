local addonName = ...
local moduleName = "CustomTimeAbbreviation"
local displayName = "Custom time abbreviation"
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local module = addon:NewModule(moduleName)

local defaults = {
	profile = {
		enabled = true,
	}
}

module.options = {
	type = "group",
	name = displayName,
	desc = "Custom function to convert seconds into days, hours and minutes.",
	-- icon = "Interface\\GossipFrame\\FooIconThatDoesntExist",
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = "Enabled",
			-- desc = "",
			get = function() return module:IsEnabled() end,
			set = function() if module:IsEnabled() then module:Disable() else module:Enable() end end,
		},
	},
}

module.SecondsToTimeAbbrevCopy = SecondsToTimeAbbrev

function SecondsToTimeAbbrev(seconds)
	if not module:IsEnabled() then return module.SecondsToTimeAbbrevCopy(seconds) end
	local time
	if seconds > 86400 then
		local day = floor(seconds / 86400)
		local hour = floor((seconds % 86400) / 3600)
		time = format(DAY_ONELETTER_ABBR.." "..HOUR_ONELETTER_ABBR, day, hour)
		-- time = format(DAY_ONELETTER_ABBR, ceil(seconds / 86400))
	elseif seconds > 3600 then
		local hour = floor(seconds / 3600)
		local min = floor((seconds % 3600) / 60)
		local sec = (seconds % 3600) % 60
		-- time = format("%1d:%02d:%04.1f", hour, min, sec)
		time = format("%1d:%02d:%02d", hour, min, sec)
	elseif seconds > 60 then
		local min = floor(seconds / 60)
		local sec = seconds % 60
		time = format("%02d:%02d", min, sec)
	elseif seconds > 1 then
		time = format("%1d", seconds)
	else
		-- time = format("%.1f", seconds), (seconds * 100 - floor(seconds * 100))/100
		time = format("%.1f", seconds)
	end
	return time
end

function module:OnInitialize()
	-- Register DB namespace
	self.db = addon.db:RegisterNamespace(moduleName, defaults)

	-- Register callbacks
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateConfigs")

	-- Enable if we're supposed to be enabled
	if self.db.profile.enabled then
		self:Enable()
	end
end

function module:OnEnable()
	self.db.profile.enabled = true
end

function module:OnDisable()
	self.db.profile.enabled = false
end

function module:UpdateConfigs()
	if self.db.profile.enabled then
		-- If profile says that the module is supposed to enabled, but it isn't already, then go ahead and enable it.
		if not self:IsEnabled() then
			self:Enable()
		end
	else
		-- If the module is currently enabled, but isn't supposed to, then disable it.
		if self:IsEnabled() then
			self:Disable()
		end
	end
end
