CreateThread(function()
	Startup()
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Restaurant", _RESTAURANT)
end)

function Startup()
	local config = load(LoadResourceFile(GetCurrentResourceName(), "config/shared.lua"))()

	for job, zones in pairs(config.ClockInZones) do
		for _, zone in ipairs(zones) do
			local options = {
				{
					icon = "clipboard-list",
					text = "Clock In",
					event = "Restaurant:Client:ClockIn",
					data = { job = job },
					jobPerms = {
						{
							job = job,
							reqOffDuty = true,
						},
					},
				},
				{
					icon = "clipboard",
					text = "Clock Out",
					event = "Restaurant:Client:ClockOut",
					data = { job = job },
					jobPerms = {
						{
							job = job,
							reqDuty = true,
						},
					},
				},
			}

			if zone.extra == "tv" then
				table.insert(options, {
					icon = "tv",
					text = "Set TV Link",
					event = "Billboards:Client:SetLink",
					data = { job = job },
					jobPerms = {
						{
							job = job,
							reqDuty = true,
						},
					},
				})
			elseif zone.extra == "bowling" then
				table.insert(options, {
					icon = "tv",
					text = "Set TV Link",
					event = "Bowling:Client:SetTV",
					jobPerms = {
						{
							job = job,
							reqDuty = true,
						},
					},
				})
				table.insert(options, {
					icon = "bowling-ball",
					text = "Reset All Lanes",
					event = "Bowling:Client:ResetAll",
					data = { job = job },
					jobPerms = {
						{
							job = job,
							reqDuty = true,
						},
					},
				})
				table.insert(options, {
					icon = "bowling-ball",
					text = "Clear Pins",
					event = "Bowling:Client:ClearPins",
					jobPerms = {
						{
							job = job,
							reqDuty = true,
						},
					},
				})
			end

			plsr.Targeting.Zones:AddBox(zone.id, zone.icon or "clock", zone.coords, zone.width, zone.length, {
				heading = zone.heading,
				minZ = zone.minZ,
				maxZ = zone.maxZ,
			}, options, 3.0, true)
		end
	end
end

_RESTAURANT = {}

RegisterNetEvent("Restaurant:Client:CreatePoly", function(pickups, warmersList, onSpawn)
	for k, v in ipairs(pickups) do
		local data = GlobalState[string.format("Restaurant:Pickup:%s", v)]
		if data ~= nil then
			plsr.Targeting.Zones:AddBox(data.id, "fork-knife", data.coords, data.width, data.length, data.options, {
				{
					icon = "fork-knife",
					text = string.format("Pickup Order (#%s)", data.num),
					event = "Restaurant:Client:Pickup",
					data = data.data,
					allowFromVehicle = data.driveThru,
				},
				{
					icon = "sack-dollar",
					text = "Set Contactless Payment",
					event = "Businesses:Client:CreateContactlessPayment",
					isEnabled = function(data)
						return not GlobalState[string.format("PendingContactless:%s", data.id)]
					end,
					data = data,
					jobPerms = {
						{
							job = data.job,
							reqDuty = true,
						},
					},
				},
				{
					icon = "sack-dollar",
					text = "Clear Contactless Payment",
					event = "Businesses:Client:ClearContactlessPayment",
					isEnabled = function(data)
						return GlobalState[string.format("PendingContactless:%s", data.id)]
					end,
					data = data,
					jobPerms = {
						{
							job = data.job,
							reqDuty = true,
						},
					},
				},
				{
					icon = "money-check-dollar",
					isEnabled = function(data)
						return GlobalState[string.format("PendingContactless:%s", data.id)]
							and GlobalState[string.format("PendingContactless:%s", data.id)] > 0
					end,
					textFunc = function(data)
						if
							GlobalState[string.format("PendingContactless:%s", data.id)]
							and GlobalState[string.format("PendingContactless:%s", data.id)] > 0
						then
							return string.format(
								"Pay Contactless ($%s)",
								GlobalState[string.format("PendingContactless:%s", data.id)]
							)
						end
					end,
					event = "Businesses:Client:PayContactlessPayment",
					data = data,
					item = "phone",
					allowFromVehicle = data.driveThru,
				},
			}, data.driveThru and 5.0 or 2.0, true)
		end
	end

	for k, v in ipairs(warmersList) do
		for k2, v2 in ipairs(v) do
			local data = GlobalState[string.format("Restaurant:Warmers:%s", v2)]
			if data ~= nil then
				local icon = data.fridge and "dolly" or "temperature-high"
				plsr.Targeting.Zones:AddBox(data.id, icon, data.coords, data.width, data.length, data.options, {
					{
						icon = icon,
						text = data.fridge and "Open Fridge" or "Open Warmer",
						event = "Restaurant:Client:Pickup",
						jobDuty = true,
						data = data.data,
					},
				}, 2.0, true)
			end
		end
	end

	if not onSpawn then
		plsr.Targeting.Zones:Refresh()
	end
end)

AddEventHandler("Restaurant:Client:Pickup", function(entity, data)
	plsr.Inventory.Secondary:Open(data.inventory)
end)

AddEventHandler("Restaurant:Client:ClockIn", function(_, data)
	if data and data.job then
		plsr.Jobs.Duty:On(data.job)
	end
end)

AddEventHandler("Restaurant:Client:ClockOut", function(_, data)
	if data and data.job then
		plsr.Jobs.Duty:Off(data.job)
	end
end)
