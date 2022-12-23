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

function module:SecondsToTimeAbbrev(seconds)
	local t
	if seconds > 86400 then
		local day = floor(seconds / 86400)
		local hour = floor((seconds % 86400) / 3600)
		t = format(DAY_ONELETTER_ABBR.." "..HOUR_ONELETTER_ABBR, day, hour)
		-- t = format(DAY_ONELETTER_ABBR, ceil(seconds / 86400))
	elseif seconds > 3600 then
		local hour = floor(seconds / 3600)
		local min = floor((seconds % 3600) / 60)
		local sec = (seconds % 3600) % 60
		-- t = format("%1d:%02d:%04.1f", hour, min, sec)
		t = format("%1d:%02d:%02d", hour, min, sec)
	elseif seconds > 60 then
		local min = floor(seconds / 60)
		local sec = seconds % 60
		t = format("%02d:%02d", min, sec)
	elseif seconds > 1 then
		t = format("%1d", seconds)
	else
		-- t = format("%.1f", seconds), (seconds * 100 - floor(seconds * 100))/100
		t = format("%.1f", seconds)
	end
	return t
end

if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
	local updateAura = function(aura, timeleft)
		if timeleft and module.db.profile.enabled then
			aura.duration:SetText(module:SecondsToTimeAbbrev(timeleft))
		end
	end
	hooksecurefunc(BuffButtonMixin, "UpdateDuration", updateAura)
	hooksecurefunc(DebuffButtonMixin, "UpdateDuration", updateAura)
else
	local updateAura = function(aura, timeleft)
		if timeleft and module.db.profile.enabled then
			local duration = _G[aura:GetName().."Duration"]
			duration:SetText(module:SecondsToTimeAbbrev(timeleft))
		end
	end
	hooksecurefunc("AuraButton_UpdateDuration", updateAura)
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
