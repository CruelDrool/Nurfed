local addonName = ...
local moduleName = "AutoSell"
local displayName = "Auto sell"
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
	desc = "Automatically sell your scrap to vendors.",
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
	local soldNum, soldItems, sold, startMoney = 0, "", nil, GetMoney()
	local soldLst = {}
	for bag=0,4,1 do
		for slot=1, GetContainerNumSlots(bag), 1 do
			if GetContainerItemLink(bag, slot) then
				local name, link, rarity = GetItemInfo(GetContainerItemLink(bag, slot))
				if name and not dnsLst[link:find("Hitem:(%d+)")] and rarity == 0 then
					if not soldLst[name] then
						if GetItemCount(link) ~= 1 then
							soldNum = soldNum + GetItemCount(link)
							soldItems = soldItems == "" and link or soldItems..", "..link.."x"..GetItemCount(link)
						else
							soldNum = soldNum + 1
							soldItems = soldItems == "" and link or soldItems..", "..link
						end
						soldLst[name] = true
					else
						soldItems = soldItems:gsub(link, link.."x"..GetItemCount(link))
					end
					UseContainerItem(bag, slot)
					sold = true
				end
			end
		end
	end
	if sold then
		if soldNum == 1 then
			addon:print("|cffffffffSold |r"..soldNum.." |cffffffffItem: |r"..soldItems)
		else
			addon:print("|cffffffffSold |r"..soldNum.." |cffffffffItems: |r"..soldItems)
		end
		local timer = 1
		-- self.sellFrame:Show()
		self.sellFrame:SetScript("OnUpdate", function()
			timer=timer+1
			if timer >= 15 then
				local money = GetMoney() - startMoney
				if money == 0 then 
					timer = 0
					return
				end

				local gold = math.floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
				local silver = math.floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
				local copper = math.fmod(money, COPPER_PER_SILVER)
				addon:print("|cffffffffReceived|r |c00ffff66"..gold.."g|r |c00c0c0c0"..silver.."s|r |c00cc9900"..copper.."c|r |cfffffffffrom selling trash loot.|r")
				self.sellFrame:SetScript("OnUpdate", nil)
			end
		end)
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
	if not self.sellFrame then
		self.sellFrame = CreateFrame("Frame")
	end
	self:RegisterEvent("MERCHANT_SHOW")
end

function module:OnDisable()
	self.db.profile.enabled = false
	self:UnregisterEvent("MERCHANT_SHOW")
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