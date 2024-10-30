local InFlight = CreateFrame("Frame", "InFlight")  -- no parent is intentional
local self = InFlight
InFlight:SetScript("OnEvent", function(this, event, ...) this[event](this, ...) end)
InFlight:RegisterEvent("ADDON_LOADED")

local gl = GetLocale()
local HandyNotes, Cartographer_Notes = HandyNotes, Cartographer_Notes
local UpdateTaxiIcons

local function LoadInFlight()
	if not InFlight.ShowOptions then
		LoadAddOn("InFlight")
	end
	return (InFlight.ShowOptions and true) or nil
end
----------------------------------
function InFlight:ADDON_LOADED(a1)
----------------------------------
	if a1 == "InFlight_Load" then
		self:RegisterEvent("TAXIMAP_OPENED")
		if self.SetupInFlight then
			self:SetupInFlight()
		else
			self:UnregisterEvent("ADDON_LOADED")
		end
		if UpdateTaxiIcons then
			if IsLoggedIn() then
				self:PLAYER_LOGIN()
			else
				self:RegisterEvent("PLAYER_LOGIN")
			end
		end
	elseif a1 == "InFlight" then
		self:UnregisterEvent("ADDON_LOADED")
		self:LoadBulk()
	end
end
-----------------------------------------
function InFlight:TAXIMAP_OPENED(_, misc)
-----------------------------------------
	if LoadInFlight() and not misc then
		self:InitSource()
	end
	if UpdateTaxiIcons then  -- add notes if not present
		UpdateTaxiIcons(misc)
	end
end


if select(4, GetAddOnInfo("InFlight")) then  -- maybe this stuff gets garbage collected if InFlight isn't loadable
	local t
	do
	-- LOCALIZATION
	local nighthaven = "Nighthaven"					--Nighthaven, Moonglade
	local druidgossip = "I'd like to fly to (.+)."	--Druid gossip option
	local plaguewood = "Plaguewood Tower"			--Plaguewood, Eastern Plaguelands
	local plaguegossip = "Take me to (.+)."			--EPL Plaguewood Tower flight
	local expedition = "Expedition Point"			--Expedition Point
	local hellfire = "Hellfire Peninsula"			--Another for Shatter Point (aka Honor Point)
	local shatter = "Shatter Point"
	local honorpoint = "Honor Point"
	local hellgossip = "Send me to (.+)!"			--Hellfire special flightpath gossip option (Alliance)
	local skyguard = "Skyguard Outpost"
	local blackwind = "Blackwind Landing"
	local sssa = "Shattered Sun Staging Area"		-- Shattered Sun Offensive bombing run
	local srharbor = "Sun's Reach Harbor"
	local sssagossip = "Speaking of action"			-- shattered sun gossip air strike gossip
	local sssagossip2 = "I need to intercept"		-- dawnblade reinforcements gossip
	local thesinloren = "The Sin'loren"				-- The Sin'loren dragonhawk
	local sinlorengossip = "<Ride the dragonhawk"	-- The Sin'loren gossip
	local swcity = "Stormwind City"
	local swharborscenic = "flight around Stormwind Harbor"  -- flight tour around Stormwind Harbor
	local cavernsoftime = "Caverns of Time"
	local cavernsentrance = "Please take me"		-- dragon flight at Caverns of Time entrance
	local oldhillsbrad = "Old Hillsbrad Foothills"
	local oldhillsbradgossip = "I'm ready to go"
	local durnholdekeep = "Durnholde Keep"
	local amberledge = "Amber Ledge"
	local transitusshield = "Transitus Shield (Scenic)"  -- gossip flightpath, long way
	local amberledgegossip = "I'd like passage"
	local valgarde = "Valgarde"								-- Valgarde to Explorer's League Outpost
	local explorersleague = "Explorers' League Outpost"
	local valgardegossip = "Take me to the Explorers"
	local argenttournament = "Argent Tournament Grounds"	-- "Get Kraken" daily quest
	local argenttournamentgossip = "Mount the Hippogryph"
	local fin = "Return"

	if gl == "koKR" then
		nighthaven = "나이트헤이븐"
		druidgossip = "(.+)|1으로;로; 가고 싶습니다."
		plaguewood = "역병의 숲"
		plaguegossip = "(.+)|1으로;로; 갑니다."
		expedition = "원정대 거점"
		hellfire = "지옥불 반도"
		shatter = "징검다리 거점"
		honorpoint = "명예 거점"
		hellgossip = "(.+)|1으로;로; 보내 주십시오!"
		skyguard = "하늘경비대 전초기지"
		blackwind = "검은바람 비행기지"
	elseif gl == "zhCN" then
		nighthaven = "永夜港"
		druidgossip = "我想飞往(.+)。"
		plaguewood = "病木林"
		plaguegossip = "带我去(.+)。"
		expedition = "远征军岗哨"
		hellfire = "地狱火半岛"
		shatter = "破碎岗哨"
		honorpoint = "荣耀岗哨"
		hellgossip = "送我到(.+)去！"
		skyguard = "天空卫队哨站"
		blackwind = "黑风码头"
		sssa = "破碎残阳基地"
		srharbor = "阳湾港口"
		sssagossip = "说到行动"
		sssagossip2 = "我必须阻止"
		thesinloren = "辛洛雷号"
		sinlorengossip = "<骑上龙鹰"
	elseif gl == "zhTW" then
		nighthaven = "永夜港"				--Nighthaven, Moonglade
		druidgossip = "我想飛往(.+)。"	--Druid gossip option
		plaguewood = "病木林"				--Plaguewood, Eastern Plaguelands
		plaguegossip = "帶我去(.+)。"			--EPL Plaguewood Tower flight
		expedition = "遠征隊哨塔"			--Expedition Point
		hellfire = "地獄火半島"			--Another for Shatter Point (aka Honor Point)
		shatter = "破碎崗哨"
		honorpoint = "榮譽崗哨"
		hellgossip = "送我去(.+)!"			--Hellfire special flightpath gossip option (Alliance)
		skyguard = "禦天者崗哨"
		blackwind = "黑風平臺"
	elseif gl == "deDE" then
		nighthaven = "Nachthafen"
		druidgossip = "Wollt Ihr jetzt nach %s? %s fliegen?"   --Druid gossip option
		plaguewood = "Pestwaldturm"
		plaguegossip = "Bringt mich zum (.+)."
		expedition = "Expeditionsr\195\188stlager"
		hellfire = "H\195\182llenfeuerhalbinsel"
		shatter = "Tr\195\188mmerposten"
		honorpoint = "Ehrenpunkt"
		hellgossip = "Bringt mich zum (.+)!"
		skyguard = "Au\195\159enposten der Himmelswache"
		blackwind = "Schattenwindlager"
	elseif gl == "esES" then
		nighthaven = "Asilo de la noche"		--Nighthaven, Moonglade
		druidgossip = "Me gustaría volar a (.+)."	--Druid gossip option
		plaguewood = "Bosque de la Plaga"		--Plaguewood, Eastern Plaguelands
		plaguegossip = "Llévame a (.+)."		--EPL Plaguewood Tower flight
		expedition = "Punto de Expedición"		--Expedition Point
		hellfire = "Península del Fuego Infernal"	--Another for Shatter Point (aka Honor Point)
		shatter = "Punto de Añicos"
		honorpoint = "Punto de Honor"
		hellgossip = "Envíame a (.+)!"			--Hellfire special flightpath gossip option (Alliance)
		skyguard = "Puesto avanzado del Protector del Cielo"
		blackwind = "Aterrizaje del VientoNegro"
		sssa = "Zona de Espera del Sol Roto"		-- Shattered Sun Offensive bombing run
		srharbor = "Puerto del Alcance del Sol"
		sssagossip = "Hablando de acción"		-- shattered sun gossip air strike gossip
		sssagossip2 = "Necesito interceptar"		-- dawnblade reinforcements gossip
		thesinloren = "El Sin'loren"			-- The Sin'loren dragonhawk
		sinlorengossip = "<Monte el HalcónDragón"	-- The Sin'loren gossip
	elseif gl == "ruRU" then
		nighthaven = "Ночная Гавань"					--Nighthaven, Moonglade
		druidgossip = "I'd like to fly to (.+)."	--Druid gossip option
		plaguewood = "Башня Проклятого леса"			--Plaguewood, Eastern Plaguelands
		plaguegossip = "Take me to (.+)."			--EPL Plaguewood Tower flight
		expedition = "Лагерь экспедиции"			--Expedition Point
		hellfire = "Полуостров Адского Пламени"			--Another for Shatter Point (aka Honor Point)
		shatter = "Парящая застава"
		honorpoint = "Honor Point" -- Оплот Чести
		hellgossip = "Send me to (.+)!"			--Hellfire special flightpath gossip option (Alliance)
		skyguard = "Застава Стражи Небес"
		blackwind = "Лагерь Черного Ветра"
		sssa = "П.П. Расколотого Солнца"		-- Shattered Sun Offensive bombing run
		srharbor = "Гавань Солнечного Края"
		sssagossip = "Speaking of action"			-- shattered sun gossip air strike gossip
		sssagossip2 = "I need to intercept"		-- dawnblade reinforcements gossip
		thesinloren = "Син'лорен"				-- The Sin'loren dragonhawk
		sinlorengossip = "<Ride the dragonhawk"	-- The Sin'loren gossip
		swcity = "Штормград"
		swharborscenic = "flight around Stormwind Harbor"  -- flight tour around Stormwind Harbor
		cavernsoftime = "Пещеры Времени"
		cavernsentrance = "Please take me"		-- dragon flight at Caverns of Time entrance
		oldhillsbrad = "Старые предгорья Хилсбрада"
		oldhillsbradgossip = "I'm ready to go"
		durnholdekeep = "Крепость Дарнхольд"
		amberledge = "Янтарная гряда"
		transitusshield = "Маскировочный щит"  -- gossip flightpath, long way
		amberledgegossip = "Мне хотелось бы"
		valgarde = "Валгард"								-- Valgarde to Explorer's League Outpost
		explorersleague = "Лагерь Лиги Исследователей"
		valgardegossip = "Take me to the Explorers"
		argenttournament = "Ристалище Серебряного турнира"	-- "Get Kraken" daily quest
		argenttournamentgossip = "Забраться на гиппогрифа"
		fin = "Return"
	end
	t = {
		[nighthaven] = { match = druidgossip, },
		[plaguewood] = { match = plaguegossip, },
		[expedition] = { match = hellgossip, },
		[hellfire] = { match = hellgossip, s = honorpoint },
		[shatter] = { match = hellgossip, },
		[skyguard] = { find = blackwind, d = blackwind, }, 
		[blackwind] = { find = skyguard, d = skyguard, },
		[sssa] = { find = sssagossip, find2 = sssagossip2, s = sssa, d = sssa, s2 = sssa, d2 = thesinloren, },
		[thesinloren] = { find = sinlorengossip, d = sssa, },
		[swcity] = { find = swharborscenic, },
		[cavernsoftime] = { find = cavernsentrance, },
		[oldhillsbrad] = { find = oldhillsbradgossip, d = durnholdekeep, },
		[amberledge] = { find = amberledgegossip, d = transitusshield, },
		[valgarde] = { find = valgardegossip, d = explorersleague, },
		[argenttournament] = { find = argenttournamentgossip, d = fin, },
	}
	t[srharbor] = t[sssa]
	end

	---------------------------------
	function InFlight:SetupInFlight()
	---------------------------------
	  	SlashCmdList.INFLIGHT = function()
	  		if LoadInFlight() then
	  			self:ShowOptions()
	  		end
	  	end
	   	SLASH_INFLIGHT1 = "/inflight"

		local panel = CreateFrame("Frame")
		panel.name = "InFlight"
		panel:SetScript("OnShow", function(this)
			if LoadInFlight() and InFlight.SetLayout then
				InFlight:SetLayout(this)
			end
		end)
		InterfaceOptions_AddCategory(panel)
		InFlight.SetupInFlight = nil
	end

	-- support for flightpaths that are started by gossip options
	local strmatch = strmatch
	hooksecurefunc("GossipTitleButton_OnClick", function(this, button)
		if this.type ~= "Gossip" then return end
		
		local subzone = GetMinimapZoneText()
		local tsz = t[subzone]
		if not tsz then return end
		
		local text = this:GetText()
		if not text or text == "" then return end
		
		local source, destination
		if tsz.match then  -- destination is in the text
			destination = strmatch(text, tsz.match)
			if not destination then return end
			source = tsz.s or subzone
		elseif tsz.find and strmatch(text, tsz.find) then  -- destination already known 1
			source = tsz.s or subzone
			destination = tsz.d or subzone
		elseif tsz.find2 and strmatch(text, tsz.find2) then  -- destination already known 2
			source = tsz.s2 or subzone
			destination = tsz.d2 or subzone
		end
		if source and LoadInFlight() then
			self:StartMiscFlight(source, destination)
		end
	end)
end


if Cartographer_Notes or (HandyNotes and not HandyNotes_FlightMasters) then
	local BZ, BZR
	-- Cartographer_Notes LOCALIZATION
	local itext = "Flight Master"
	local pvp = "PvP"
	local druid = "Druid"
	local thealdor = "The Aldor"
	local thescryers = "The Scryers"
	local special = "Special"
	if gl == "koKR" then
		itext = "와이번/그리폰 조련사"
	elseif gl == "zhCN" then -- by Isler
		itext = "飞行管理员"
		druid = "德鲁伊"
		thealdor = "奥尔多"
		thescryers = "占星者"
		special = "特殊"
	elseif gl == "zhTW" then
		itext = "飛行管理員"
		druid = "德魯伊"
		thealdor = "奧多爾"
		thescryers = "占卜者"
		special = "特殊"
	elseif gl == "deDE" then
		itext = "Flugmeister"
		druid = "Druide"
		thealdor = "Die Aldor"
		thescryers = "Die Seher"
	elseif gl == "esES" then
		itext = "Maestro de Vuelo"
		pvp = "JcJ"
		druid = "Druida"
		thealdor = "Los Aldor"
		thescryers = "Los Arúspices"
		special = "Especial"
	elseif gl == "ruRU" then
		itext = "Распорядитель полетов"
		pvp = "PvP"
		druid = "Друид"
		thealdor = "Алдоры"
		thescryers = "Провидцы"
		special = "Особые"
	end
	local UpdateMapMod
	local function GetTaxiID(misc)
		if misc then return end
		for i = 1, NumTaxiNodes(), 1 do
			if TaxiNodeGetType(i) == "CURRENT" then
				local c = GetCurrentMapContinent()
				local x, y = TaxiNodePosition(i)
				return format("%d:%d:%d", c, x * 1000, y * 1000)
			end
		end
	end
	UpdateTaxiIcons = function(misc)  -- attempts to convert gray icons to green for known flights
		if not dbfaction then return end
		SetMapToCurrentZone()
		local c = GetCurrentMapContinent()
		local x,y = GetPlayerMapPosition("player")
		local zone = BZR and BZR[GetRealZoneText()] or GetRealZoneText()
		
		UpdateMapMod(c, x, y, zone, misc)
		
		for i = 1, misc and 0 or NumTaxiNodes(), 1 do
			local ntype = TaxiNodeGetType(i)
			local found = false
			if ntype == "REACHABLE" or ntype == "CURRENT" then
				local x, y = TaxiNodePosition(i)
				local key = format("%d:%d:%d", c, x * 1000, y * 1000)
				for zone, zonet in pairs(dbfaction) do
					if type(zonet) == "table" then
						for source, sourcet in pairs(zonet) do
							if type(sourcet) == "table" and sourcet.tid == key then
								sourcet.icon = "Taxi1"
								found = true
								break
							end
						end
					end
					if found then break end
				end
			end
		end
		if HandyNotes then
			HandyNotes:UpdatePluginMap("HandyNotes_NotifyUpdate", "InFlight_POI")
		end
	end
	--------------------------------
	function InFlight:PLAYER_LOGIN()  -- Cartographer and HandyNotes: load POI data and register database
	--------------------------------
		if not InFlightCartoDB or InFlightCartoDB.profiles or InFlightCartoDB.ver ~= 3 then
			InFlightCartoDB = (self.LoadPOIData and self:LoadPOIData(InFlightCartoDB)) or {}
			InFlightCartoDB.ver = 3
		end
		self.LoadPOIData = nil

		local db = InFlightCartoDB
		local faction = UnitFactionGroup("player")
		db[faction] = db[faction] or {}
		dbfaction = db[faction]
		
		local Z = LibStub("LibBabble-Zone-3.0", true)
		BZ = Z and Z:GetLookupTable()
		BZR = Z and Z:GetReverseLookupTable()
		
		if Cartographer_Notes then
			UpdateMapMod = function(c, x, y, zone, misc)
				if not Cartographer_Notes:GetNearbyNote(zone, x, y, 15, "InFlight", true) then
					if Cartographer_Notes:SetNote(zone, x, y, (misc and "Taxi2") or "Taxi1", "InFlight") then
						local coord = floor(x*10000 + 0.5) + floor(y*10000 + 0.5)*10001
						local newentry = dbfaction[zone][coord]
						if type(newentry) == "string" then
							dbfaction[zone][coord] = { icon = newentry, tid = GetTaxiID(misc), }
						elseif type(newentry) == "table" then
							newentry.tid = GetTaxiID(misc)
						end
					end
				end
			end
			Cartographer_Notes:RegisterIcon("Taxi0", {
				text = "|cff888888"..itext.."|r",
				path = "Interface\\TaxiFrame\\UI-Taxi-Icon-White",
				width = 13, height = 13, alpha = 0.8,
			})
			Cartographer_Notes:RegisterIcon("Taxi1", {
				text = "|cff00ff00"..itext.."|r",
				path = "Interface\\TaxiFrame\\UI-Taxi-Icon-Green",
				width = 13, height = 13, alpha = 0.8,
			})
			Cartographer_Notes:RegisterIcon("Taxi2", {
				text = "|cffffbb00"..itext.."|r",
				path = "Interface\\TaxiFrame\\UI-Taxi-Icon-Yellow",
				width = 13, height = 13, alpha = 0.8,
			})
			Cartographer_Notes:RegisterNotesDatabase("InFlight", dbfaction, self)
			Cartographer_Notes:RefreshMap()
			
		elseif HandyNotes then
			UpdateMapMod = function(c, x, y, zone, misc)
				local dbfz = dbfaction[zone]
				if not dbfz then  -- adds new zone entry
					local coord = floor(x*10000 + 0.5) + floor(y*10000 + 0.5)*10001
					dbfaction[zone] = { 
						[coord] = { 
							icon = (misc and "Taxi2") or "Taxi1", 
							tid = GetTaxiID(misc), 
						}, 
					}
				else
					local found
					for key, keyt in pairs(dbfz) do  -- attempt a search to see if a nearby node already exists
						local kx, ky = (key % 10001)/10000, floor(key / 10001)/10000
						if abs(kx - x) < 0.015 and abs(ky - y) < 0.015 then
							found = true
							break
						end
					end
					if not found then  -- adds new entry
						local coord = floor(x*10000 + 0.5) + floor(y*10000 + 0.5)*10001
						dbfz[coord] = { 
							icon = (misc and "Taxi2") or "Taxi1", 
							tid = GetTaxiID(misc), 
						}
					end
				end
			end
			local HNIF = { }
			local icons = { 
				Taxi0 = "Interface\\TaxiFrame\\UI-Taxi-Icon-White",
				Taxi1 = "Interface\\TaxiFrame\\UI-Taxi-Icon-Green",
				Taxi2 = "Interface\\TaxiFrame\\UI-Taxi-Icon-Yellow",
			}
			local temp = { }
			local info = { notCheckable = 1, }
			local realstate, ddframe, createWaypoint, deleteNode, close, clickedmap, clickedcoord
			
			local function getEnglishZoneFromMapFile(mapFile)
				local c, z = HandyNotes:GetCZ(mapFile)
				local zone = HandyNotes:GetCZToZone(c, z)
				return (BZR and BZR[zone]) or zone or "blah"
			end
			local function iter(t, prestate)
				if not t then return end
				if realstate and not t[realstate] then return end
				local state, value = next(t, realstate)
				realstate = state
				if value then
					if type(value) == "table" then
						local tx, ty = (state % 10001)/10000, floor(state / 10001)/10000
						local coord = HandyNotes:getCoord(tx, ty)
						return coord, nil, icons[value.icon], 0.9, 0.8
					else
						local mapFile, coord = strmatch(state, "(.+)@(.+)")
						return tonumber(coord), mapFile, icons[value], 0.9, 0.8
					end
				end
			end
			function HNIF:GetNodes(mapFile, minimap)
				local cont, zid = HandyNotes:GetCZ(mapFile)
				if cont and zid == 0 then
					for k, v in pairs(temp) do
						temp[k] = nil
					end
					for zone, zonet in pairs(dbfaction) do
						local zonec, zonez = HandyNotes:GetZoneToCZ((BZ and zone ~= "version" and BZ[zone]) or zone)
						if zonec == cont then
							for key, keyt in pairs(zonet) do
								local tx, ty = (key % 10001)/10000, floor(key / 10001)/10000
								local coord = HandyNotes:getCoord(tx, ty)
								temp[format("%s@%s", HandyNotes:GetMapFile(zonec, zonez), coord)] = keyt.icon
							end
						end
					end
					return iter, temp
				end
				return iter, dbfaction[getEnglishZoneFromMapFile(mapFile)]
			end
			function HNIF:OnClick(button, down, mapFile, coord)
				if button == "RightButton" and not down then
					if not ddframe then
						ddframe = CreateFrame("Frame")
						ddframe.displayMode = "MENU"
						deleteNode = function()
							local cx, cy = HandyNotes:getXY(clickedcoord)
							if not cx then return end
							local dbcoord = floor(cx*10000 + 0.5) + floor(cy*10000 + 0.5)*10001
							local dbf = dbfaction[getEnglishZoneFromMapFile(mapFile)]
							if dbf then dbf[dbcoord] = nil end
							HandyNotes:UpdatePluginMap("HandyNotes_NotifyUpdate", "InFlight_POI")
						end
						close = function() CloseDropDownMenus() end
						ddframe.initialize = function(button, level)
							if level ~= 1 then return end
							if TomTom or Cartographer_Waypoints then
								createWaypoint = createWaypoint or function()
									local c, z = HandyNotes:GetCZ(clickedmap)
									local x, y = HandyNotes:getXY(clickedcoord)
									if TomTom then
										TomTom:AddZWaypoint(c, z, x*100, y*100, itext)
									elseif Cartographer_Waypoints then
										Cartographer_Waypoints:AddWaypoint(NotePoint:new(HandyNotes:GetCZToZone(c, z), x, y, itext))
									end
								end
								info.text = (TomTomLocals and TomTomLocals["Set as waypoint arrow"]) or "Set as waypoint arrow"
								info.func = createWaypoint
								UIDropDownMenu_AddButton(info, level)
							end
							info.text = DELETE
							info.func = deleteNode
							UIDropDownMenu_AddButton(info, level)
							info.text = CLOSE
							info.func = close
							UIDropDownMenu_AddButton(info, level)
						end
					end
					clickedmap, clickedcoord = mapFile, coord
					ToggleDropDownMenu(1, nil, ddframe, self, 0, 0)
				end
			end
			function HNIF:OnEnter(mapFile, coord)
				local tooltip = (self:GetParent() == WorldMapButton and WorldMapTooltip) or GameTooltip
				tooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				tooltip:SetText("|cff00ff00"..itext.."|r")
				local dbf = dbfaction[getEnglishZoneFromMapFile(mapFile)]
				if dbf then
					local cx, cy = HandyNotes:getXY(coord)
					if cx and cy then
						local dbcoord = floor(cx*10000 + 0.5) + floor(cy*10000 + 0.5)*10001
						local dbfc = dbf[dbcoord]
						if dbfc and dbfc.info then
							tooltip:AddLine(dbfc.info)
						end
					end
				end
				tooltip:Show()
			end
			function HNIF:OnLeave(mapFile, coord)
				(self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip):Hide()
			end

			HandyNotes:RegisterPluginDB("InFlight_POI", HNIF)
		end  -- end elseif HandyNotes

		self.PLAYER_LOGIN = nil
	end  -- InFlight:PLAYER_LOGIN()

	-----------------------------------
	function InFlight:LoadPOIData(prev)  -- Notes data, prev is the previous database to synchronize
	-----------------------------------
		local ti = "Taxi0"
		local data = {  -- most of the tid's are parsed from FlightMap, credit to the author
			["Horde"] = {
				["The Hinterlands"] = {
					[81816350] = { icon = ti, tid = "2:589:551", },
				},
				["Wintergrasp"] = {
					[34965660] = { icon = ti, tid = "4:313:566", },
				},
				["Moonglade"] = {
					[66309850] = { icon = ti, tid = "1:537:794", },
					[45008900] = { icon = "Taxi2", info = druid, },
				},
				["Thousand Needles"] = {
					[49209430] = { icon = ti, tid = "1:549:265", },
				},
				["Winterspring"] = {
					[36309680] = { icon = ti, tid = "1:640:767", },
				},
				["Hellfire Peninsula"] = {
					[36309260] = { icon = ti, tid = "3:655:496", },
					[81214280] = { icon = ti, tid = "3:677:370", },
					[60038789] = { icon = ti, tid = "3:535:430", },
					[48233559] = { icon = ti, tid = "3:786:463", },
				},
				["Arathi Highlands"] = {
					[32610570] = { icon = ti, tid = "2:547:542", },
				},
				["Eversong Woods"] = {
					[50740508] = { icon = ti, tid = "2:591:816", },
				},
				["Dustwallow Marsh"] = {
					[31806740] = { icon = ti, tid = "1:567:358", },
					[72451526] = { icon = ti, tid = "1:583:300", },
				},
				["Badlands"] = {
					[44904900] = { icon = ti, tid = "2:501:343", },
				},
				["Searing Gorge"] = {
					[30806560] = { icon = ti, tid = "2:464:346", },
				},
				["Orgrimmar"] = {
					[64010930] = { icon = ti, tid = "1:628:556", },
				},
				["Blade's Edge Mountains"] = {
					[39610130] = { icon = ti, tid = "3:421:720", },
					[51007900] = { icon = "Taxi2", info = special, },
					[65914230] = { icon = ti, tid = "3:486:643", },
					[54210630] = { icon = ti, tid = "3:378:677", },
				},
				["Undercity"] = {
					[48511190] = { icon = ti, tid = "2:416:628", },
				},
				["Desolace"] = {
					[74009560] = { icon = ti, tid = "1:316:415", },
				},
				["Zul'Drak"] = {
					[23169361] = { icon = ti, tid = "4:818:687", },
					[73598759] = { icon = ti, tid = "4:636:578", },
					[64440598] = { icon = ti, tid = "4:724:598", },
					[74460662] = { icon = ti, tid = "4:694:576", },
					[56721674] = { icon = ti, tid = "4:784:614", },
				},
				["Tanaris"] = {
					[25507710] = { icon = ti, tid = "1:606:198", },
					[49691570] = { info = special, icon = "Taxi2", },
				},
				["Borean Tundra"] = {
					[34486763] = { icon = ti, tid = "4:121:472", },
					[37691542] = { icon = ti, tid = "4:287:464", },
					[51492997] = { icon = ti, tid = "4:290:430", },
					[51459183] = { icon = ti, tid = "4:148:430", },
					[11016060] = { icon = ti, tid = "4:182:530", },
					[34347953] = { icon = ti, tid = "4:165:473", },
				},
				["Azshara"] = {
					[49707170] = { icon = ti, tid = "1:631:638", },
				},
				["Silithus"] = {
					[36708540] = { icon = ti, tid = "1:416:207", },
				},
				["Shattrath City"] = {
					[40980501] = { icon = ti, tid = "3:437:328", },
				},
				["Sholazar Basin"] = {
					[61341140] = { icon = ti, tid = "4:244:597", },
					[58008300] = { icon = ti, tid = "4:175:603", },
				},
				["Swamp of Sorrows"] = {
					[54710080] = { icon = ti, tid = "2:539:210", },
				},
				["Grizzly Hills"] = {
					[46881182] = { icon = ti, tid = "4:844:492", },
					[64518647] = { icon = ti, tid = "4:698:452", },
				},
				["Icecrown"] = {
					[47806721] = { icon = ti, tid = "4:278:721", },
					[78046582] = { icon = ti, tid = "4:555:639", },
					[24376808] = { icon = ti, tid = "4:377:785", },
					[72365170] = { icon = ti, tid = "4:521:655", },
					[22619520] = { icon = ti, tid = "4:494:789", },
				},
				["Stranglethorn Vale"] = {
					[29306180] = { icon = ti, tid = "2:420:142", },
					[77100395] = { icon = ti, tid = "2:408:72", },
				},
				["Eastern Plaguelands"] = {
					[50453432] = { icon = ti, tid = "2:622:655", },
					[51192568] = { icon = ti, tid = "2:609:654", },
					[26654554] = { info = pvp, icon = "Taxi2", },
				},
				["Ashenvale"] = {
					[33804600] = { icon = ti, tid = "1:409:626", },
					[61533472] = { icon = ti, tid = "1:554:582", },
				},
				["Ghostlands"] = {
					[30527594] = { icon = ti, tid = "2:578:754", },
					[67164191] = { icon = ti, tid = "2:611:726", },
				},
				["Zangarmarsh"] = {
					[51108411] = { icon = ti, tid = "3:232:496", },
					[55033976] = { icon = ti, tid = "3:444:485", },
				},
				["Un'Goro Crater"] = {
					[6005100] = { icon = ti, tid = "1:497:236", },
				},
				["Dragonblight"] = {
					[45708317] = { icon = ti, tid = "4:453:491", },
					[16896077] = { icon = ti, tid = "4:476:561", },
					[74422288] = { icon = ti, tid = "4:493:421", },
					[51401165] = { icon = ti, tid = "4:535:477", },
					[62243874] = { icon = ti, tid = "4:594:451", },
				},
				["Dalaran"] = {
					[44941680] = { icon = ti, tid = "4:522:617", },
				},
				["Stonetalon Mountains"] = {
					[59910500] = { icon = ti, tid = "1:407:527", },
				},
				["Burning Steppes"] = {
					[24108970] = { icon = ti, tid = "2:501:313", },
				},
				["Terokkar Forest"] = {
					[43469267] = { icon = ti, tid = "3:509:268", },
					[65012800] = { icon = "Taxi2", info = special, },
				},
				["The Storm Peaks"] = {
					[60962351] = { icon = ti, tid = "4:720:713", },
					[49388551] = { icon = ti, tid = "4:599:749", },
					[36396701] = { icon = ti, tid = "4:573:789", },
					[50711610] = { icon = ti, tid = "4:733:745", },
					[84502517] = { icon = ti, tid = "4:619:641", },
					[28127263] = { icon = ti, tid = "4:637:814", },
				},
				["Crystalsong Forest"] = {
					[50422896] = { icon = ti, tid = "4:596:602", },
				},
				["Isle of Quel'Danas"] = {
					[25137357] = { icon = ti, tid = "2:582:942", },
					[17316972] = { info = special, icon = "Taxi2", },
				},
				["Shadowmoon Valley"] = {
					[57831413] = { icon = "Taxi2", tid = "3:778:146", info = thescryers, },
					[29205950] = { icon = ti, tid = "3:661:232", },
					[30409373] = { icon = "Taxi2", tid = "3:808:228", info = thealdor, },
				},
				["Netherstorm"] = {
					[34908020] = { icon = ti, tid = "3:628:816", },
					[64009780] = { icon = ti, tid = "3:576:729", },
					[66713180] = { icon = ti, tid = "3:719:720", },
				},
				["Silverpine Forest"] = {
					[42508800] = { icon = ti, tid = "2:372:590", },
				},
				["The Barrens"] = {
					[30408190] = { icon = ti, tid = "1:557:469", },
					[59010300] = { icon = ti, tid = "1:528:389", },
					[37170024] = { icon = ti, tid = "1:605:450", },
				},
				["Feralas"] = {
					[44311970] = { icon = ti, tid = "1:442:306", },
				},
				["Felwood"] = {
					[53808820] = { icon = ti, tid = "1:464:695", },
					[82233375] = { icon = ti, tid = "1:504:651", },
				},
				["Thunder Bluff"] = {
					[50009690] = { icon = ti, tid = "1:449:438", },
				},
				["Howling Fjord"] = {
					[29730875] = { icon = ti, tid = "4:951:365", },
					[57838247] = { icon = ti, tid = "4:738:292", },
					[25025103] = { icon = ti, tid = "4:743:377", },
					[11506103] = { icon = ti, tid = "4:835:412", },
					[67371940] = { icon = ti, tid = "4:845:267", },
				},
				["Hillsbrad Foothills"] = {
					[18707890] = { icon = ti, tid = "2:455:573", },
				},
				["Nagrand"] = {
					[35309250] = { icon = ti, tid = "3:288:375", },
				},
				["Tirisfal Glades"] = {
					[69965352] = { icon = ti, tid = "2:451:633", },
				},
				["Western Plaguelands"] = {
					[49681893] = { icon = ti, tid = "2:514:641", },
				},
			},
			["Alliance"] = {
				["The Hinterlands"] = {
					[46105720] = { icon = ti, tid = "2:495:583", },
				},
				["Wintergrasp"] = {
					[31010300] = { icon = ti, tid = "4:410:571", },
				},
				["Moonglade"] = {
					[45008900] = { info = druid, icon = "Taxi2", },
					[67311530] = { icon = ti, tid = "1:552:794", },
				},
				["Dragonblight"] = {
					[25926544] = { icon = ti, tid = "4:460:539", },
					[49792679] = { icon = ti, tid = "4:596:481", },
					[74402291] = { icon = ti, tid = "4:493:421", },
					[51571188] = { icon = ti, tid = "4:535:477", },
					[55328450] = { icon = ti, tid = "4:423:467", },
				},
				["Winterspring"] = {
					[36609890] = { icon = ti, tid = "1:645:766", },
				},
				["Bloodmyst Isle"] = {
					[53881156] = { icon = ti, tid = "1:218:824", },
				},
				["Arathi Highlands"] = {
					[46109190] = { icon = ti, tid = "2:513:530", },
				},
				["Westfall"] = {
					[52710930] = { icon = ti, tid = "2:390:204", },
				},
				["Searing Gorge"] = {
					[30706860] = { icon = ti, tid = "2:466:346", },
				},
				["Loch Modan"] = {
					[50808470] = { icon = ti, tid = "2:527:385", },
				},
				["Blade's Edge Mountains"] = {
					[70403152] = { icon = ti, tid = "3:418:629", },
					[39620124] = { icon = ti, tid = "3:421:720", },
					[61389917] = { icon = ti, tid = "3:315:656", },
					[51007900] = { icon = "Taxi2", info = special, },
				},
				["Desolace"] = {
					[10407510] = { icon = ti, tid = "1:396:493", },
				},
				["Zul'Drak"] = {
					[23169361] = { icon = ti, tid = "4:818:687", },
					[73598759] = { icon = ti, tid = "4:636:578", },
					[64440598] = { icon = ti, tid = "4:724:598", },
					[74380655] = { icon = ti, tid = "4:694:576", },
					[56721674] = { icon = ti, tid = "4:784:614", },
				},
				["Tanaris"] = {
					[29308030] = { icon = ti, tid = "1:604:190", },
					[49691570] = { info = special, icon = "Taxi2", },
				},
				["Stormwind City"] = {
					[30166570] = { info = special, icon = "Taxi2", },
					[72544349] = { icon = ti, tid = "2:409:266", },
				},
				["Borean Tundra"] = {
					[34446756] = { icon = ti, tid = "4:121:472", },
					[34567987] = { icon = ti, tid = "4:165:473", },
					[20067664] = { icon = ti, tid = "4:208:508", },
					[68302725] = { icon = ti, tid = "4:217:388", },
					[51533006] = { icon = ti, tid = "4:290:430", },
				},
				["Azshara"] = {
					[77608950] = { icon = ti, tid = "1:610:599", },
				},
				["The Barrens"] = {
					[37170024] = { icon = ti, tid = "1:605:450", },
				},
				["Shattrath City"] = {
					[40980501] = { icon = ti, tid = "3:437:328", },
				},
				["Sholazar Basin"] = {
					[61371149] = { icon = ti, tid = "4:244:597", },
					[58478382] = { icon = ti, tid = "4:175:603", },
				},
				["Hillsbrad Foothills"] = {
					[52210160] = { icon = ti, tid = "2:443:549", },
				},
				["Grizzly Hills"] = {
					[26698659] = { icon = ti, tid = "4:826:537", },
					[59109041] = { icon = ti, tid = "4:729:464", },
				},
				["Howling Fjord"] = {
					[63242302] = { icon = ti, tid = "4:875:278", },
					[43987524] = { icon = ti, tid = "4:764:328", },
					[57878253] = { icon = ti, tid = "4:738:292", },
					[16117617] = { icon = ti, tid = "4:877:400", },
				},
				["Icecrown"] = {
					[47806721] = { icon = ti, tid = "4:278:721", },
					[78046582] = { icon = ti, tid = "4:555:639", },
					[24376808] = { icon = ti, tid = "4:377:785", },
					[72365170] = { icon = ti, tid = "4:521:655", },
					[22619520] = { icon = ti, tid = "4:494:789", },
				},
				["The Storm Peaks"] = {
					[60962351] = { icon = ti, tid = "4:720:713", },
					[84552529] = { icon = ti, tid = "4:619:641", },
					[36336697] = { icon = ti, tid = "4:573:789", },
					[28187267] = { icon = ti, tid = "4:637:814", },
					[74340383] = { icon = ti, tid = "4:568:672", },
				},
				["Stranglethorn Vale"] = {
					[77810530] = { icon = ti, tid = "2:409:71", },
					[4054228] = { icon = ti, tid = "2:433:180", },
				},
				["Eastern Plaguelands"] = {
					[53392924] = { icon = ti, tid = "2:611:652", },
					[26654554] = { info = pvp, icon = "Taxi2", },
					[50453432] = { icon = ti, tid = "2:622:655", },
				},
				["Duskwood"] = {
					[44312180] = { icon = ti, tid = "2:469:208", },
				},
				["Darkshore"] = {
					[45608200] = { icon = ti, tid = "1:427:748", },
				},
				["Redridge Mountains"] = {
					[59309000] = { icon = ti, tid = "2:503:246", },
				},
				["Ashenvale"] = {
					[48008240] = { icon = ti, tid = "1:462:603", },
					[43462854] = { icon = ti, tid = "1:582:610", },
				},
				["Blasted Lands"] = {
					[24408990] = { icon = ti, tid = "2:545:188", },
				},
				["Isle of Quel'Danas"] = {
					[25137357] = { icon = ti, tid = "2:582:942", },
					[17316972] = { info = special, icon = "Taxi2", },
				},
				["Un'Goro Crater"] = {
					[6005100] = { icon = ti, tid = "1:497:236", },
				},
				["Felwood"] = {
					[24208670] = { icon = ti, tid = "1:530:742", },
					[82233375] = { icon = ti, tid = "1:504:651", },
				},
				["Ironforge"] = {
					[47710340] = { icon = ti, tid = "2:466:406", },
				},
				["Dalaran"] = {
					[44941680] = { icon = ti, tid = "4:522:617", },
				},
				["Netherstorm"] = {
					[66803204] = { icon = ti, tid = "3:719:720", },
					[34858014] = { icon = ti, tid = "3:628:816", },
					[64039782] = { icon = ti, tid = "3:576:729", },
				},
				["Western Plaguelands"] = {
					[84912780] = { icon = ti, tid = "2:475:606", },
					[49681893] = { icon = ti, tid = "2:514:641", },
				},
				["Silithus"] = {
					[34408500] = { icon = ti, tid = "1:418:209", },
				},
				["Hellfire Peninsula"] = {
					[34431268] = { icon = "Taxi2", info = special, },
					[37226235] = { icon = ti, tid = "3:524:494", },
					[62563393] = { info = special, icon = "Taxi2", },
					[52413982] = { icon = ti, tid = "3:786:451", },
					[35001346] = { icon = ti, tid = "3:748:500", },
					[28239695] = { info = special, icon = "Taxi2", },
					[62461708] = { icon = ti, tid = "3:648:423", },
				},
				["The Exodar"] = {
					[63723216] = { icon = ti, tid = "1:212:737", },
				},
				["Wetlands"] = {
					[59706920] = { icon = ti, tid = "2:453:442", },
				},
				["Crystalsong Forest"] = {
					[80995316] = { icon = ti, tid = "4:585:566", },
				},
				["Shadowmoon Valley"] = {
					[55529315] = { icon = ti, tid = "3:694:153", },
					[30409373] = { icon = "Taxi2", tid = "3:808:228", info = thealdor, },
					[57831413] = { icon = "Taxi2", tid = "3:778:146", info = thescryers, },
				},
				["Zangarmarsh"] = {
					[51411926] = { icon = ti, tid = "3:375:495", },
					[28957018] = { icon = ti, tid = "3:266:556", },
				},
				["Burning Steppes"] = {
					[68315270] = { icon = ti, tid = "2:521:283", },
				},
				["Feralas"] = {
					[45913540] = { icon = ti, tid = "1:482:303", },
					[43257348] = { icon = ti, tid = "1:313:307", },
				},
				["Terokkar Forest"] = {
					[55371483] = { icon = ti, tid = "3:554:234", },
					[65012800] = { icon = "Taxi2", info = special, },
				},
				["Ghostlands"] = {
					[67164191] = { icon = ti, tid = "2:611:726", },
				},
				["Teldrassil"] = {
					[93915230] = { icon = ti, tid = "1:416:842", },
				},
				["Dustwallow Marsh"] = {
					[51211870] = { icon = ti, tid = "1:636:330", },
					[72451526] = { icon = ti, tid = "1:583:300", },
				},
				["Stonetalon Mountains"] = {
					[7204370] = { icon = ti, tid = "1:390:597", },
				},
				["Nagrand"] = {
					[75122929] = { icon = ti, tid = "3:274:255", },
				},
			},
		}
		for faction, ft in pairs(data) do
			if prev then
				for zone, zt in pairs(ft) do
					local prevzone = prev[faction] and prev[faction][zone]
					if prevzone then
						for key, keyt in pairs(zt) do
							for pkey, pkeyt in pairs(prevzone) do
								if keyt.tid == pkeyt.tid then
									keyt.icon = pkeyt.icon
									break
								end
							end
						end
					end
				end
			end
			ft.version = 3
		end
		return data
	end
end
