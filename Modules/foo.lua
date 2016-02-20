local addonName = ...
local moduleName = "foo"
local displayName = "Foo Bar"
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
	desc = "This is a foo bar module that does nothing",
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
	--[[
	-- Do stuff that enables the module below here. Stuff like:
	if not self.frame then
		self.frame = CreateFrame("Frame")
	end
	self.frame:SetScript("OnUpdate", FooBar_OnUpdate)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- self::SecureHook([object], method, [handler]) -- http://www.wowace.com/addons/ace3/pages/api/ace-hook-3-0/
	self:SecureHook(addon.LDBObj,"OnTooltipShow", function(tooltip) tooltip:AddLine("Text", 0.75, 0.75, 0.75) end)
	self:SecureHook("FloatingChatFrame_OnMouseScroll", FooHook)
	
	-- ]]
end

function module:OnDisable()
	self.db.profile.enabled = false
	--[[
	-- Do stuff that disables the module below here. Stuff like:
	self.frame:SetScript("OnUpdate", nil)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnhookAll()
	-- ]]
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