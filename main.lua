local event = "tpmenu:open" 
-- local time_day = 12 -- เวลาในเกม
-- local time_weather = "EXTRASUNNY" -- สภาพอากาศ

local d_delay = 0 -- delay ในการกดเปิดเมนูวาป gate
local delay = 1500 -- ดีเลย์ loop ของ  gate


ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- RegisterCommand(Config["คำสั่งวาป"], function(src, arg)
-- 	TriggerEvent(event)
-- end)


RegisterNetEvent(event)
AddEventHandler(event, function()
	
	OpenMenu()
	
end)

RegisterNetEvent("thuglyk_teleport:TimeSetting")
AddEventHandler("thuglyk_teleport:TimeSetting", function(src)
	
	local playerPed = GetPlayerPed(-1)
	local player = PlayerPedId()
	
	exports['mythic_progbar']:Progress(
		{
			name = "unique_action_name",
			duration = 5000,
			label = 'กำลังทำการวาป',
			useWhileDead = false,
			canCancel = false,
			controlDisables = {
				disableMovement = false,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true
			},
			
			}, function(status)
			
			if not status and not IsDead then
				
				SetPedCoordsKeepVehicle(playerPed, src)
				time_day = 21
				FreezeEntityPosition(playerPed, true)	
				
				DoScreenFadeIn(500)
				Freeze(playerPed)
				
			end
			
		end)
		
end)

function OpenMenu()
	
	if not Config["Menu"]["enable"] then return end 
    
	local elements = {}
	local warps = Config["Warp"] -- อิงจาก config
	
	for name,warp in pairs(warps) do 
		
		if warp.enable then
			table.insert(elements, {label = warp.name, name = name}) -- insert เป็น table มีหัวสองหัวข้อ label กับ name หลังจาก = คือ value ที่อิงมาจาก for k,v แต่อันนี้ใช้เป็น name,warp
		end
		
	end
	
	-- table.sort(elements, function(a, b)
	-- return string.len(a.label) < string.len(b.label)
	-- end)
	
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open(
		"default", GetCurrentResourceName(), "tpmenu",
		
		{
			title    = Config["Text"]["menu_tittle"],
			align    = Config["Menu"]["position"],
			elements = elements
		},
		
		function(data, menu)
			
			local map_name = data.current.name
			
			menu.close()
			OpenMap(map_name)
			
			
		end,
		
		function(data, menu)
			menu.close()
		end)	
end

function OpenMap(name)
	
	local elements = {}
	
	
	local warp = Config["Warp"][name]["List"]
	
	for topic,map in pairs(warp) do
		
		if map.enable then
			
			table.insert(elements, {label = map.name, map = map}) -- insert เป็น table มีหัวสองหัวข้อ label กับ name หลังจาก = คือ value ที่อิงมาจาก for k,v แต่อันนี้ใช้เป็น name,warp
			
		end
		
	end
	
	-- table.sort(elements, function(a, b)
	-- return string.len(a.label) < string.len(b.label)
	-- end)
	
	ESX.UI.Menu.CloseAll()				    
	ESX.UI.Menu.Open(
		"default", GetCurrentResourceName(), "tpmenu",
		
		{
			title    = Config["Text"]["menu_tittle"],
			align    = Config["Menu"]["position"],
            elements = elements
		},
		
        function(data, menu)
			
			local map_data = data.current.map
			
			menu.close()
			Teleport(map_data)
			
		end,
		
		function(data, menu)
            menu.close()
		end)	
end



function Teleport(map)
	
	local x,y,z = map.position.x,map.position.y,map.position.z
	local ped = GetPlayerPed(-1)
	local player = PlayerPedId()
	local ent_target = player
	
	if Config["Setting"]["allowed_vehicle"] then
		
		local is_in_vehicle = IsPedInAnyVehicle(ped, true)
		
		if is_in_vehicle then
			ent_target = GetVehiclePedIsUsing(player)
		end
		
	end
	
	RequestCollisionAtCoord(x,y,z)
	DoScreenFadeOut(1000)
	Citizen.Wait(1000)
	
	-- time_weather = map.weather or "EXTRASUNNY"
	-- time_day = map.time or 12
	
	SetEntityCoords(ent_target, x,y,z)
	SetEntityHeading(ent_target, map.position.h or 0)
	
	Wait(100)
	
	FreezeEntityPosition(ent_target,true)	
	
	DoScreenFadeIn(500)
	Freeze(ent_target)
	
end


function Freeze(ent)
	
	Citizen.CreateThread(function()
		while notfreeze do
			Citizen.Wait(0)
			if not CheckStep then
				local OpenText    = ''
				local Ped = PlayerPedId()
				local nearbyPlayer = GetEntityCoords(Ped)
				
				OpenText = "~w~กด ~w~[~y~Enter~w~] หากแมพโหลดเสร็จแล้ว"
				DrawText3D(nearbyPlayer.x, nearbyPlayer.y, nearbyPlayer.z + 1.0, OpenText, 0.5)
				
				if IsControlJustReleased(0, 201) then
					notfreeze = false
					FreezeEntityPosition(Ped, false)
					break
				end
			end
		end
	end)
end


-- Citizen.CreateThread(function()
--     while true do
-- 		NetworkOverrideClockTime(time_day, 0, 0)
--         SetWeatherTypePersist(time_weather)
--         SetWeatherTypeNowPersist(time_weather)
--         SetWeatherTypeNow(time_weather)
--         SetOverrideWeather(time_weather)
        
		
-- 		if world_weather == "XMAS" then
			
-- 			SetForceVehicleTrails(true)
-- 			SetForcePedFootstepsTracks(true)
			
-- 			else
			
-- 			SetForceVehicleTrails(false)
-- 			SetForcePedFootstepsTracks(false)
-- 		end
-- 		Citizen.Wait(300)
-- 	end
-- end)

----------------------------------------------------------------------------------------------------------

--[[
	
	GATE WARP
	
--]]

local font = nil

Citizen.CreateThread(function()
	
	local for_font = Config["Gate"]["Setting"]["font"]
	
	RegisterFontFile(for_font)
	RegisterFontFile(for_font)
	font = RegisterFontId(for_font) 
end)


function DrawText3D(x,y,z, text, size)
	
	local coords = vector3(x, y, z)
	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)
	
	if not size then size = 0.7 end
	
	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov
	
	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(font)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)
	
	SetDrawOrigin(coords, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end




if Config["Gate"]["Setting"]["enable"] then
	
	Citizen.CreateThread(function()
		
		local temp_text = "ประตูวาป"
		local gates = Config["Gate"]["List"]
		local draw_dist = Config["Gate"]["Setting"]["draw_dist_text"]
		local draw_press = Config["Gate"]["Setting"]["draw_dist_press"]
		
		while true do
			
			Citizen.Wait(delay)
			
			for _,gate in pairs(gates) do
				
				local player = GetPlayerPed(-1)
				local pos = GetEntityCoords(player, true)
				local x,y,z = gate.position.x, gate.position.y, gate.position.z
				local distance = Vdist(pos.x, pos.y, pos.z, x, y, z) 
				local txt = gate.text
				
				if distance < draw_dist * 10 then
					DrawMarker(21, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 0, 102, 204, 100, false, true, 2, false, false, false, false)
				end

				if distance < draw_dist then
					
					delay = 1
					
					if IsControlJustPressed(0,38) and distance < draw_press then
						
						if d_delay > GetGameTimer() then return end
						
						local target = Config["Warp"][gate.catalog]["List"][gate.name]
						
						Confirm(gate,target)
						
					end
					
					if txt.enable then
						
						if txt.text then
							
							temp_text = txt.text
							
							else
							
							temp_text = "ประตูวาป"
							
						end
						
						DrawText3D(x,y,z, temp_text, txt.size)
					end
				end
			end	
		end
	end)
end

function Confirm(gate,map)
	
	if gate.confirm.enable then 
		
		local resource = GetCurrentResourceName()
		local txt = gate.confirm.text
		local elements = {}
		
		
		table.insert(elements, {label = "ยืนยัน", value = "yes"})
		table.insert(elements, {label = "ยกเลิก", value = "no"})
		
		ESX.UI.Menu.CloseAll()				    
		ESX.UI.Menu.Open(
			'default', resource, 'confirm',
			{
				title = txt,
				align = "center",
				elements = elements
			},
			function(data, menu)		
				
				if data.current.value == "yes" then
					
					menu.close()
					GateAnim(gate,map)
					
					elseif data.current.value == "no" then
					
					menu.close()
					
				end
				
				
			end,
			function(data, menu)
				menu.close()
			end
		)
		
		
		else
		
		GateAnim(gate,map)
		
	end
end

function GateAnim(gate,map)
	
	local player = GetPlayerPed(-1)
	
	if gate.anim.enable then
		
		local anim = gate.anim
		local name = anim.name
		local dict = anim.dict
		
		TriggerEvent("mythic_progbar:client:progress", {
			name = gate.progressbar.tittle,
			duration = gate.progressbar.time,
			label = gate.progressbar.text,
			useWhileDead = false,
			canCancel = false,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			
			animation = {
				animDict = dict,
				anim = name,
			}
			
			}, function()
			
			Teleport(map)
			
		end)
		
		else
		
		Teleport(map)
		
	end
	
end
