
local jobCible = 17

local vestiaire = {x=-540.219, y=-1638.04 , z=19.8927}
local garage = {x=-586.768, y=-1638.46 , z=19.793}
local recolte = {x= -801.323, y= 5403.05, z= 34.0766}
local traitement = {x=-555.881, y=5319.96 , z=73.5997}
local vente = {x=-473.50, y=-985.04 , z=23.5456}

local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local lang = 'fr'

local txt = {
  ['fr'] = {
        ['getService'] = 'Appuyez sur ~g~E~s~ pour enfiler votre tenue.',
        ['dropService'] = 'Appuyez sur ~g~E~s~ pour terminer votre journée',
        ['getAmbulance'] = 'Appuyez sur ~g~E~s~ pour obtenir un véhicule',
        ['callTaken'] = 'L\'appel a été pris par ~b~',
        ['emergency'] = '<b>~r~URGENCE~s~ <br><br>~b~Raison~s~: </b>',
        ['takeCall'] = '<b>Appuyez sur ~g~Y~s~ pour prendre l\'appel</b>',
        ['callExpires'] = '<b>~r~URGENCE~s~ <br><br>Attention, l\'appel précèdent a expiré !</b>',
        ['gps'] = 'Un point a été placé sur votre GPS là où se trouve la victime en détresse',
        ['res'] = 'Appuyez sur ~g~E~s~ pour réanimer le joueur',
        ['notDoc'] = 'Vous n\'êtes pas bucheron',
        ['stopService'] = 'Vous n\'êtes plus en service',
        ['startService'] = 'Début du service, vous êtes prêt à détruire la nature'
  }
}

local isInService = false
local jobId = -1
local notificationInProgress = false


--[[
################################
            THREADS
################################
--]]


-- PRISE DE SERVICE
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)

            local playerPos = GetEntityCoords(GetPlayerPed(-1), true)

            if (Vdist(playerPos.x, playerPos.y, playerPos.z, vestiaire.x, vestiaire.y, vestiaire.z) < 100.0) then
                -- Service
                DrawMarker(1, vestiaire.x, vestiaire.y, vestiaire.z - 1, 0, 0, 0, 0, 0, 0, 3.0001, 3.0001, 1.5001, 255, 165, 0,165, 0, 0, 0,0)

                if (Vdist(playerPos.x, playerPos.y, playerPos.z, vestiaire.x, vestiaire.y, vestiaire.z) < 2.0) then 
					if isInService and jobId == jobCible then
					    DisplayHelpText(txt[lang]['dropService'])
					else
					    DisplayHelpText(txt[lang]['getService'])
					end

					if (IsControlJustReleased(1, 51)) then
					    TriggerServerEvent('bucheroncompany:sv_getJobId')
					end 
                end
            end
        end

end)



-- GARAGE
Citizen.CreateThread(
    function()
        local blip = true
        if blip == true then
           setBlip(vestiaire, "Entreprise Woodstock", 478, 21)
           setBlip(garage, "Garage Entreprise Woodstock", 369, 21)
           setBlip(recolte, "Coupe du bois", 434, 21)
           setBlip(traitement, "Scierie", 473, 21)
           setBlip(vente, "Vente du bois", 434, 21)
           blip = false
        end 

        while true do
            Citizen.Wait(1)
            local playerPos = GetEntityCoords(GetPlayerPed(-1), true)
            if (jobId == jobCible) then
            	if (Vdist(playerPos.x, playerPos.y, playerPos.z, garage.x, garage.y, garage.z) < 100.0) and isInService and jobId == jobCible then
            	    -- Service car
            	    DrawMarker(1, garage.x, garage.y, garage.z - 1, 0, 0, 0, 0, 0, 0, 3.0001, 3.0001, 1.5001, 255, 165, 0,165, 0, 0, 0,0)
            	    if (Vdist(playerPos.x, playerPos.y, playerPos.z, garage.x, garage.y, garage.z) < 2.0) then
            	        DisplayHelpText(txt[lang]['getAmbulance'])
            	        if (IsControlJustReleased(1, 51)) then
            	            SpawnVehicle()
            	        end
            	    end
            	end
            end
        end
end)



--[[
################################
            EVENTS
################################
--]]



RegisterNetEvent('bucheroncompany:cl_setJobId')
AddEventHandler('bucheroncompany:cl_setJobId',
    function(p_jobId)
        jobId = p_jobId
        GetService()
    end
)

--[[
################################
        BUSINESS METHODS
################################
--]]


function setBlip(coord, name, blipId, color)
    local loc = pos
    local blip = AddBlipForCoord(coord.x, coord.y, coord.z)
    SetBlipSprite(blip, blipId)
    SetBlipColour(blip, color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip,true)
    SetBlipAsMissionCreatorBlip(blip,true)
end

function SpawnVehicle()
    Citizen.Wait(0)
    local myPed = GetPlayerPed(-1)
    local player = PlayerId()
    local vehicle = GetHashKey('flatbed')

    RequestModel(vehicle)

    while not HasModelLoaded(vehicle) do
        Citizen.Wait(1)
    end

    local plate = math.random(100, 900)
    local coords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0, 5.0, 0)
    local spawned_car = CreateVehicle(vehicle, coords, garage.x, garage.y, garage.z, true, false)

    SetVehicleOnGroundProperly(spawned_car)
    SetVehicleNumberPlateText(spawned_car, "WOOD")
    SetPedIntoVehicle(myPed, spawned_car, - 1)
    SetModelAsNoLongerNeeded(vehicle)
    Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
end



-- Get job form server
function GetService()
    local playerPed = GetPlayerPed(-1)
    if (jobId ~= jobCible) then
            SendNotification(txt[lang]['notDoc'])
            return
    else
    	if isInService then
    	    SendNotification(txt[lang]['stopService'])
    	    TriggerServerEvent("skin_customization:SpawnPlayer")
    	    TriggerServerEvent('bucheroncompany:sv_setService', 0)
    	else
    	    SendNotification(txt[lang]['startService'])
    	    TriggerServerEvent('bucheroncompany:sv_setService', 1)
    	    SetPedComponentVariation(GetPlayerPed(-1), 8, 59, 0, 2) --Enfiler un gilet-fluo
    	end
	
    	isInService = not isInService
    end
end

--[[
################################
        USEFUL METHODS
################################
--]]

function DisplayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function SendNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end

