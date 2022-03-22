local addonName = ...
local moduleName = "AutoSell"
local displayName = "Auto sell"
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local module = addon:NewModule(moduleName)

local defaults = {
	profile = {
		enabled = true,
		summaries = {
			itemsSold = true,
			moneyReceived = true,
		},
	}
}

module.options = {
	type = "group",
	name = displayName,
	desc = "Automatically sell your trash loot to vendors.",
	icon = "Interface\\GossipFrame\\VendorGossipIcon",
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = "Enabled",
			-- desc = "",
			get = function() return module:IsEnabled() end,
			set = function() if module:IsEnabled() then module:Disable() else module:Enable() end end,
		},
		summaries = {
			order = 2,
			type = "group",
			width = "full",
			name = "Summaries",
			guiInline = true,
			args = {
				itemssold = {
					order = 2,
					type = "toggle",
					name = "Items sold",
					width = "full",
					get = function() return module.db.profile.summaries.itemsSold end,
					set = function(info, value) module.db.profile.summaries.itemsSold = value end,
				},
				moneyreceived = {
					order = 2,
					type = "toggle",
					name = "Money received",
					width = "full",
					get = function() return module.db.profile.summaries.moneyReceived end,
					set = function(info, value) module.db.profile.summaries.moneyReceived = value end,
				},
			},
		},
	},
}

local dnsLst = {
		[20558] = true,
		[20559] = true,
		[20560] = true,
		[29024] = true,
		[32823] = true,
}
function module:MERCHANT_SHOW()
	-- local soldNum, soldItems, sold, startMoney = 0, "", nil, GetMoney()
	local soldNum, soldItems, sold = 0, "", false
	local soldLst = {}
	local earned = 0
	for bag=0,4,1 do
		for slot=1, GetContainerNumSlots(bag), 1 do
			if GetContainerItemLink(bag, slot) then
				local name, link, rarity,_,_,_,_,_,_, _, sellPrice = GetItemInfo(GetContainerItemLink(bag, slot))
				if name and not dnsLst[link:find("Hitem:(%d+)")] and rarity == 0 then
					local itemCount = GetItemCount(link)
					if not soldLst[name] then
						if itemCount > 1 then
							soldNum = soldNum + itemCount
							earned = earned + sellPrice * itemCount
							soldItems = soldItems == "" and link.."x"..itemCount or soldItems..", "..link.."x"..itemCount
						else
							soldNum = soldNum + 1
							earned = earned + sellPrice
							soldItems = soldItems == "" and link or soldItems..", "..link
						end
						soldLst[name] = true
					else
						soldItems = soldItems:gsub(link, link.."x"..itemCount)
					end
					UseContainerItem(bag, slot)
					sold = true
				end
			end
		end
	end
	if sold then
		if self.db.profile.summaries.itemsSold then
			ChatFrame_DisplaySystemMessageInPrimary(string.format("Sold %d |4item:items;: %s", soldNum, soldItems))
		end

		if self.db.profile.summaries.moneyReceived then
			earned = GetMoneyString(earned, true)
			ChatFrame_DisplaySystemMessageInPrimary(string.format("Received %s from selling trash loot.", addon:WrapTextInColorCode(earned, {1,1,1})))
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