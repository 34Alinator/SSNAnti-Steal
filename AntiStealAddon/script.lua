-- g_savedata table that persists between game sessions
g_savedata = {}
vehicle_list = {}

function indexOf(array, value)
	for i, v in ipairs(array) do
		if v == value then
			return i
		end
	end
	return nil
end

function isVehicleOwnedByPlayer(player_name, vehicle_id)
    if not vehicle_list[player_name] then
		return false
	end
    for _, vid in ipairs(vehicle_list[player_name].vehicles) do
        if vid == vehicle_id then
            return true
        end
    end
    return false
end

function removeVehicleID(vehicle_id)
	for _, data in pairs (vehicle_list) do
		for i =#data.vehicles, 1, -1 do
			if data.vehicles[i] == vehicle_id then
				table.remove(data.vehicles, i)
			end
		end
	end
end

-- Tick function that will be executed every logic tick
function onTick(game_ticks)

end

function onPlayerJoin(steam_id, name, peer_id, admin, auth)
	one = name
	server.announce("[Server]", name .. " joined the game")
    vehicle_list[one] = {vehicles = {}}
end

function onPlayerLeave(steam_id, name, peer_id, admin, auth)
	one = name
	server.announce("[Server]", name .. " left the game")
    vehicle_list[one] = nil
	
end

function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
		one = server.getPlayerName(peer_id)
		two = vehicle_id
        if vehicle_list[one] then
            table.insert(vehicle_list[one].vehicles, two)
        end
end

function onVehicleDespawn(vehicle_id, peer_id)
		removeVehicleID(vehicle_id)
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four, five)

	if (command == "?hello") then
		server.announce("[Server]", "world")
	end
	
	if (command == "?c") then
		local player = server.getPlayerName(user_peer_id)
		numone = tonumber(one)
		if is_admin then
			is_success = server.despawnVehicle(one, true)
			if is_success then
				removeVehicleID(one)
				message = "Vehicle " .. one .. " despawned."
				server.notify(user_peer_id, "Cleared", message, 8)
			end
		else
			if one == nil then
				for _, vid in ipairs(vehicle_list[player].vehicles) do
					is_success = server.despawnVehicle(vid, true)
					if is_success then
						removeVehicleID(vid)
					end
				end				
				server.notify(user_peer_id, "Cleared", "Cleared all vehicles", 8)
			elseif isVehicleOwnedByPlayer(player, numone) then
				is_success = server.despawnVehicle(one, true)
				if is_success then
					removeVehicleID(one)
					message = "Vehicle " .. one .. " despawned."
					server.notify(user_peer_id, "Cleared", message, 8)
				end
			else
				server.notify(user_peer_id, "Error", "Vehicle not owned by you", 8)				
			end
		end
	end
	
	if (command == "?vehicles") and not is_admin then
		message = ""
		name = server.getPlayerName(user_peer_id)
		for _, vehicle_id in ipairs(vehicle_list[name].vehicles) do
			message = message .. vehicle_id .. ", "
		end
        message = message:sub(1, -3) .. "\n"
		server.notify(user_peer_id, "Vehicles", message, 8)
	end

	if command == "?vehicles" and is_admin then
    	message = ""
    	for name, data in pairs(vehicle_list) do
    	    message = message .. name .. ": "
        	for _, vehicle_id in ipairs(data.vehicles) do
        	    message = message .. vehicle_id .. ", "
        	end
        	message = message:sub(1, -3) .. "\n"
    	end
    	server.notify(user_peer_id, "Players", message, 8)
	end
	
	-- DEV COMMANDS DO NOT USE IN PRODUCTION
    if command == "?add_player" and is_admin then
		one = one:gsub("/&&", " ")
        vehicle_list[one] = {vehicles = {}}
        server.notify(user_peer_id, "Player added", one .. " added", 8)
	end
    if command == "?remove_player" and is_admin then
		one = one:gsub("/&&", " ")
        vehicle_list[one] = nil
        server.notify(user_peer_id, "Player removed", one .. " removed", 8)
	end
    if command == "?add_vehicle" and is_admin then
		one = one:gsub("/&&", " ")
        if vehicle_list[one] then
            table.insert(vehicle_list[one].vehicles, two)
            server.notify(user_peer_id, "Vehicle added", two .. " added to " .. one, 8)
        end
    end
	
    if command == "?remove_vehicle" and is_admin then
		one = one:gsub("/&&", " ")
        if vehicle_list[one] and vehicle_list[one].vehicles then
        	for i, vid in ipairs(vehicle_list[one].vehicles) do
            	if vid == two then
                	table.remove(vehicle_list[one].vehicles, i)
                	server.notify(user_peer_id, "Vehicle removed", one .. " removed from " .. two, 8)
					break
				end
			end
        end
    end
end