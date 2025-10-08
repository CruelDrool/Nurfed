---@diagnostic disable: undefined-global

local addonName = ...
local moduleName = "Chat"
local displayName = moduleName

---@class Addon
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)

---@class Chat: AddonModule
local module = addon:NewModule(moduleName)

local defaults = {
	profile = {
		enabled = true,
		scrolling = true,
		timestamp = true,
		timestampformats = {
			selected = "2",
			keys = {
				["1"] = "HH:MM (24h)",
				["2"] = "HH:MM:SS (24h)",
				["3"] = "HH:MM:SS.sss (24h)",
				["4"] = "HH:MM (12h)",
				["5"] = "HH:MM:SS (12h)",
				["6"] = "HH:MM:SS.sss (12h)",
			},
			["1"] = "%%H:%%M",
			["2"] = "%%H:%%M:%%S",
			["3"] = "%%H:%%M:%%S.%.3i",
			["4"] = "%%I:%%M %%p",
			["5"] = "%%I:%%M:%%S %%p",
			["6"] = "%%I:%%M:%%S.%.3i %%p",

		},
		outputformats = {
			selected = "2",
			keys = {
				["1"] = "None",
				["2"] = "[ ]",
				["3"] = "< >",
				["4"] = "- -",
				["5"] = "| |",

			},
			["1"] = "%s",
			["2"] = "[%s]",
			["3"] = "<%s>",
			["4"] = "-%s-",
			["5"] = "|%s|",
		}
	}
}

module.options = {
	type = "group",
	name = displayName,
	-- desc = "",
	icon = "Interface\\GossipFrame\\ChatBubbleGossipIcon",
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = "Enabled",
			-- desc = "",
			get = function() return module:IsEnabled() end,
			set = function() if module:IsEnabled() then module:Disable() else module:Enable() end end,
		},
		scrolling = {
			type = "group",
			name = "Scrolling",
			guiInline = true,
			disabled = function() return not module:IsEnabled() end,
			args = {
				enabled = {
					type = "toggle",
					name = "Enabled",
					-- desc = "",
					get = function() return module.db.profile.scrolling end,
					set = function(info, value) module.db.profile.scrolling = value; module:Scrolling() end,
				},
			},
		},
		timestamp = {
			type = "group",
			name = "Timestamp",
			guiInline = true,
			disabled = function() return not module:IsEnabled() end,
			args = {
				enable = {
					type = "toggle",
					name = "Enabled",
					order = 1,
					width = "full",
					-- desc = "",
					get = function() return module.db.profile.timestamp end,
					set = function(info, value) module.db.profile.timestamp = value; module:TimeStamp() end,
				},
				timestampformat = {
					type = "select",
					name = "Format",
					order = 2,
					values = function() return module.db.profile.timestampformats.keys end,
					get = function() return module.db.profile.timestampformats.selected end,
					set = function(info, value)	module.db.profile.timestampformats.selected = tostring(value) end,
				},
				spacer1 = {
					order = 3,
					width = "full",
					type = "description",
					name = "",
				},
				enclosure = {
					type = "select",
					name = "Output format",
					order = 4,
					values = function() return module.db.profile.outputformats.keys end,
					get = function() return module.db.profile.outputformats.selected end,
					set = function(info, value)	module.db.profile.outputformats.selected = tostring(value) end,
				},
			},
		},
	},
}

local function ScrollingHook(frame, delta)
	if IsShiftKeyDown() then
		if delta > 0 then frame:PageUp()
		elseif delta < 0 then frame:PageDown()
		end
	elseif IsControlKeyDown() then
		if delta > 0 then frame:ScrollToTop()
		elseif delta < 0 then frame:ScrollToBottom()
		end
	end
end

function module:Scrolling()
	local enabled = self.db.profile.scrolling

	if not self.db.profile.enabled then
		enabled = false
	end

	if enabled then
		SetCVar("chatMouseScroll","1")
		if addon.WOW_PROJECT_ID ~= addon.WOW_PROJECT_ID_MAINLINE then
			self:SecureHook("FloatingChatFrame_OnMouseScroll", ScrollingHook)
		end
	end

	if not enabled then
		SetCVar("chatMouseScroll","0")
		if addon.WOW_PROJECT_ID ~= addon.WOW_PROJECT_ID_MAINLINE then
			self:Unhook("FloatingChatFrame_OnMouseScroll")
		end
	end
end

-- local currentTime
-- local function TimeKeepingOnUpdate(self, elapsed)
-- 	currentTime = GetTime()
-- end

local function AddMessage(self, msg, ...)
	if msg and type(msg) == "string" then
		-- local ms = (currentTime-math.floor(currentTime))*1000

		if GetCVar("showTimestamps") ~= "none" then
			local blizzStamp = date( GetCVar("showTimestamps") )
			blizzStamp = blizzStamp:gsub("%[", "%%[")
			blizzStamp = blizzStamp:gsub("%]", "%%]")
			msg = msg:gsub("^" .. blizzStamp, "")
		end

		local currentTime = GetTimePreciseSec()
		local timestampformat = tostring(module.db.profile.timestampformats[module.db.profile.timestampformats.selected])
		local outputFormat = tostring(module.db.profile.outputformats[module.db.profile.outputformats.selected])
		local timestamp = outputFormat:format( date( timestampformat:format( ( currentTime - math.floor(currentTime) ) * 1000) )  )
		msg = timestamp .. " " .. msg
		return self:O_AddMessage(msg, ...)
	end
end

function module:TimeStamp()
	local enabled = self.db.profile.timestamp

	if not self.db.profile.enabled then
		enabled = false
	end

	if enabled then
		-- if not self.timekeeping then
			-- self.timekeeping = CreateFrame("Frame")
			-- currentTime = GetTime()
			-- self.timekeeping:SetScript("OnUpdate", TimeKeepingOnUpdate)
		-- end

		local skip = {
			[2] = true, -- Combat Log
			[3] = true, -- Voice
		}

		for i = 1, NUM_CHAT_WINDOWS do
			if not skip[i] then
				local chatframe = _G["ChatFrame"..i]
				if not chatframe.O_AddMessage then
					chatframe.O_AddMessage = chatframe.AddMessage
				end
				chatframe.AddMessage = AddMessage
			end
		end
	end

	if not enabled then
		for i = 1, NUM_CHAT_WINDOWS, 1 do
			local chatframe = _G["ChatFrame"..i]
			if chatframe.O_AddMessage then
				chatframe.AddMessage = chatframe.O_AddMessage
				chatframe.O_AddMessage = nil
			end
			if self.timekeeping then
				self.timekeeping:SetScript("OnUpdate", nil)
			end
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
	self:Scrolling()
	self:TimeStamp()
end

function module:OnDisable()
	self.db.profile.enabled = false
	self:Scrolling()
	self:TimeStamp()
end

function module:UpdateConfigs()
	if self.db.profile.enabled then
		if not self:IsEnabled() then
			self:Enable()
		end
	else
		if self:IsEnabled() then
			self:Disable()
		end
	end
end
