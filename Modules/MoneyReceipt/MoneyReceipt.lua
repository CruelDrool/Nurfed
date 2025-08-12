---@diagnostic disable: undefined-global

local addonName = ...
local moduleName = "MoneyReceipt"
local displayName = "Money receipt"

---@class Addon
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)

---@class MoneyReceipt: AddonModule
local module = addon:NewModule(moduleName)

local defaults = {
	profile = {
		enabled = true,
	}
}

module.options = {
	type = "group",
	name = displayName,
	desc = "Implements the money receipt feature that exists in Retail. Tells you how much you've gained at the vendor/mailbox.",
	icon = "Interface\\ICONS\\INV_Misc_Coin_02",
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

function module:BeginTracking()
	if not self.startMoney then
		self.startMoney = GetMoney()
	end
end

function module:EndTracking()
	self:Display()
	self:Clear()
end

function module:Display()
	if self.startMoney then
	local delta = GetMoney() - self.startMoney
		if delta > 0 then
			local gain = GetMoneyString(delta, true)
			local message = string.format("You gained: %s", addon:WrapTextInColorCode(gain, {1,1,1}))
			addon:SystemMessageInPrimary(message)
		end
	end
end

function module:Clear()
	module.startMoney = nil
end

function module:MERCHANT_SHOW()
	self:BeginTracking()
end

function module:MERCHANT_CLOSED()
	self:EndTracking()
end

function module:MAIL_SHOW()
	self:BeginTracking()
end

function module:MAIL_CLOSED()
	self:EndTracking()
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
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("MERCHANT_CLOSED")
	self:RegisterEvent("MAIL_SHOW")
	self:RegisterEvent("MAIL_CLOSED")
end

function module:OnDisable()
	self.db.profile.enabled = false
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
