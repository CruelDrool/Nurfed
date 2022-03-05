local addonName = ...
local moduleName = "ShamanClassColor"
local displayName = "%s class color"
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local module = addon:NewModule(moduleName)

local defaults = {
	profile = {
		enabled = true,
	}
}

module.ShamanClassColorBlue = {
	r = 0,
	g = 0.44,
	b = 0.87,
	colorStr = "ff0070de"
}

module.options = {
	type = "group",
	name = string.format(displayName, addon:WrapTextInColorCode("Shaman", module.ShamanClassColorBlue)),
	desc = "Sets the Shaman class color to blue, like in TBC and later.",
	icon = "Interface\\ICONS\\ClassIcon_Shaman",
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = "Enabled",
			-- desc = "",
			get = function() return module:IsEnabled() end,
			set = function() if module:IsEnabled() then module:Disable() else module:Enable() end end,
		},
		intro = {
			order = 2,
			type = "description",
			name = "Any changes need a reload of the UI to take full effect.",
		},
		reloadui = {
			order = 3,
			type = "execute",
			name = "Reload UI",
			width = "normal",
			func = function() ReloadUI() end,
		},
	},
}

module.ShamanClassColorCopy = {
	r = RAID_CLASS_COLORS["SHAMAN"].r,
	g = RAID_CLASS_COLORS["SHAMAN"].g,
	b = RAID_CLASS_COLORS["SHAMAN"].b,
	colorStr = RAID_CLASS_COLORS["SHAMAN"].colorStr,
}

function module:SetShamanBlueClassColor()
	RAID_CLASS_COLORS["SHAMAN"].r = module.ShamanClassColorBlue.r
	RAID_CLASS_COLORS["SHAMAN"].g = module.ShamanClassColorBlue.g
	RAID_CLASS_COLORS["SHAMAN"].b = module.ShamanClassColorBlue.b
	RAID_CLASS_COLORS["SHAMAN"].colorStr = module.ShamanClassColorBlue.colorStr
end

function module:UnsetShamanBlueClassColor()
	RAID_CLASS_COLORS["SHAMAN"].r = module.ShamanClassColorCopy.r
	RAID_CLASS_COLORS["SHAMAN"].g = module.ShamanClassColorCopy.g
	RAID_CLASS_COLORS["SHAMAN"].b = module.ShamanClassColorCopy.b
	RAID_CLASS_COLORS["SHAMAN"].colorStr = module.ShamanClassColorCopy.colorStr
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
	self:SetShamanBlueClassColor()
end

function module:OnDisable()
	self.db.profile.enabled = false
	self:UnsetShamanBlueClassColor()
	self:UnregisterAllEvents()
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