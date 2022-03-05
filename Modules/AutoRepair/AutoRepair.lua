local addonName = ...
local moduleName = "AutoRepair"
local displayName = "Auto repair"
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local module = addon:NewModule(moduleName)

local defaults = {
	profile = {
		enabled = false,
		limit = {
			enabled = false,
			gold = 0,
			silver = 0,
			copper = 0,
		},
		guildBank = WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC,
		summary = true,
	}
}

module.options = {
	type = "group",
	name = displayName,
	desc = "Automatically repair your gear.",
	icon = "Interface\\MINIMAP\\TRACKING\\Repair",
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = "Enabled",
			-- desc = "",
			width = "full",
			get = function() return module:IsEnabled() end,
			set = function() if module:IsEnabled() then module:Disable() else module:Enable() end end,
		},
		limit = {
			order = 2,
			type = "group",
			width = "full",
			name = "Limit",
			guiInline = true,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = "Enabled",
					-- desc = "",
					width = "full",
					get = function() return module.db.profile.limit.enabled end,
					set = function(info, value) module.db.profile.limit.enabled = value end,
				},
				intro = {
					order = 2,
					type = "description",
					name = "Amount of money allowed to use each time. When no limit is set, your maximum money is used instead. If the amount of money required to repair exceeds the limit, then no repair will be done.",
				},
				gold = {
					order = 3,
					type = "input",
					width = "half",
					name = "",
					get = function() return tostring(module.db.profile.limit.gold) end,
					set = function(info, value) value = tonumber(value) or 0; module.db.profile.limit.gold = (value < 0 and 0) or value end,
				},
				goldicon = {
					order = 4,
					type = "description",
					width = 0.1,
					name = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t",
				},
				silver = {
					order = 5,
					type = "input",
					width = "half",
					name = "",
					get = function() return tostring(module.db.profile.limit.silver) end,
					set = function(info, value) value = tonumber(value) or 0; module.db.profile.limit.silver = (value < 0 and 0) or (value > 99 and 99) or value end,
				},
				silvericon = {
					order = 6,
					type = "description",
					width = 0.1,
					name = "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t",
				},
				copper = {
					order = 7,
					type = "input",
					width = "half",
					name = "",
					get = function() return tostring(module.db.profile.limit.copper) end,
					set = function(info, value) value = tonumber(value) or 0; module.db.profile.limit.copper = (value < 0 and 0) or (value > 99 and 99) or value end,
				},
				coppericon = {
					order = 8,
					type = "description",
					width = 0.1,
					name = "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t",
				},
			},
		},
		guildbank = {
			order = 3,
			type = "toggle",
			name = "Use guild bank when possible.",
			width = "full",
			hidden =  WOW_PROJECT_ID == WOW_PROJECT_CLASSIC,
			get = function() return module.db.profile.guildBank end,
			set = function(info, value) module.db.profile.guildBank = value end,
		},
		summary = {
			order = 4,
			type = "toggle",
			name = "Output amount spent on repairs.",
			width = "full",
			get = function() return module.db.profile.summary end,
			set = function(info, value) module.db.profile.summary = value end,
		},
	},
}

function module:MERCHANT_SHOW()
	local limit = GetMoney()
	if module.db.profile.limit.enabled then
		local gold = module.db.profile.limit.gold
		local silver = module.db.profile.limit.silver
		local copper = module.db.profile.limit.copper
		local l = gold * COPPER_PER_GOLD + silver * COPPER_PER_SILVER + copper
		limit = (l <= limit and l) or limit
	end

	local repairAllCost, canRepair = GetRepairAllCost()
	if canRepair and repairAllCost <= limit then
		local cost = GetMoneyString(repairAllCost, true)
		local message
		if module.db.profile.guildBank and IsInGuild() and CanGuildBankRepair() and min(GetGuildBankWithdrawMoney(), GetGuildBankMoney()) > repairAllCost then
			RepairAllItems(1)
			message = string.format("Spent %s on repairs (guild).", addon:WrapTextInColorCode(cost, {1,1,1}))
		else
			RepairAllItems()
			message = string.format("Spent %s on repairs.", addon:WrapTextInColorCode(cost, {1,1,1}))
			
		end
		if module.db.profile.summary then
			ChatFrame_DisplaySystemMessageInPrimary(message)
		end
	end
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
