if SERVER then
	AddCSLuaFile()

	local addontable = {}

	function errorReporter_registerAddon(id, name, ownerSid)
		if (name == nil) then return end
		addontable[id] = { name, ownerSid};
	end

	util.AddNetworkString("LapinFailAuth")
	util.AddNetworkString("LapinGetInfo")
	hook.Add("LapinFailAuth","broadcast",function(scriptname, steamid64, reason, reason2)
		net.Start("LapinFailAuth")
			net.WriteString(scriptname)
			net.WriteString(steamid64)
			net.WriteString(reason)
			net.WriteString(reason2 or "")
		net.Broadcast()

		net.Receive("LapinGetInfo",function(len,ply)
			net.Start("LapinFailAuth")
				net.WriteString(scriptname)
				net.WriteString(steamid64)
				net.WriteString(reason)
				net.WriteString(reason2 or "")
			net.Send(ply)
		end)
	end)

	hook.Add("SecureGMod_Fail","lapin's error reporter",function (scriptid)
		local addonName;
		local owner;
		if addontable[scriptid] then
			addonName = addontable[scriptid][1];
			owner = addontable[scriptid][2];
		else
			addonName = "SecureGmod addon #" .. tostring(scriptid);
			owner =  "Unknown Script Owner";
		end
		hook.Run("LapinFailAuth", addonName, owner, "Only dedicated server is supported; Don't forget to redownload", "the addon each time you install it on a new server")
	end)


else


	surface.CreateFont( "SeTitle", {
				font = "Roboto Thin",
				extended = false,
				size = 30,
				weight = 00,
				blursize = 0,
				scanlines = 0,
				antialias = true,
				underline = false,
				italic = false,
				strikeout = false,
				symbol = false,
				rotary = false,
				shadow = false,
				additive = false,
				outline = false,
		} )

	local cb = Color(48,55,55)
	local ccb = Color(70,70,70)
	local cc = Color(48,151,209)
	local cg = Color(50,255,50)
	local cr = Color(255,50,50)
	local main = Color(80,80,80)
	local sublogobar = Color(85,85,85)
	local timeshow = 12
	local timemove = 0.3
	local function semessage(scriptid, scname, id64, reason, reason2)
		local w = 650
		local h = 205
		if (reason2 != "") then h = h+35 end 

		local tm = CurTime()
		local scrw = ScrW()
		local scname2 = Format("[%s]",  id64)
		local targettime = tm+timeshow-timemove
		surface.SetFont( "SeTitle" )
		local tbl = { surface.GetTextSize("Script name :  " .. scname ),
		surface.GetTextSize("Script Owner :  " .. scname2),
		surface.GetTextSize("Reason :  " .. reason)}

		for k, v in pairs(tbl) do
			if v > w then w = v+50 end 
		end

		hook.Add("HUDPaint", "LapinPopup", function()

			local ypos = 150

			local mid = scrw/2-(w/2)
			if (tm+timemove > CurTime()) then
				mid = math.Remap(CurTime()-tm,0,timemove,0,scrw/2-(w/2))
			else
				mid = scrw/2-(w/2)
			end
			if CurTime() > targettime then
				mid = math.Remap(CurTime()-targettime,0,timemove,scrw/2-(w/2),scrw)
			end

			surface.SetDrawColor(cb )
			surface.DrawRect( mid, ypos+20, w, h-20 )
			surface.SetDrawColor(ccb )
			surface.DrawRect( mid, ypos+h, w, 4 )
			surface.SetDrawColor(cc )
			local time = math.Remap(CurTime()-tm,0,timeshow,w,0)
			surface.DrawRect( mid, ypos+h, time, 4 )

			/*surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( logo	)
			surface.DrawTexturedRect( mid+5, ypos+10, 250, 38 )*/
			//draw.SimpleText(  "Lapin's errors center" ,"SeHeader",mid+15, ypos+25,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

	

			surface.SetDrawColor(main )
			surface.DrawRect( mid, ypos+54, w, h-54 )
			
			surface.SetDrawColor(sublogobar )
			surface.DrawRect( mid, ypos+50, w, 4 )

			draw.SimpleText(  "Problem with a GmodStore Addon !" ,"SeTitle",mid+15,ypos+70,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  "Script name : " ,"SeTitle",mid+15,ypos+105,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  scname ,"SeTitle",mid+160,ypos+105,cg,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  "Script Owner :" ,"SeTitle",mid+15,ypos+140,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  scname2 ,"SeTitle",mid+162,ypos+140,cg,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  "Reason :" ,"SeTitle",mid+15,ypos+175,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  reason ,"SeTitle",mid+110,ypos+175,cr,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			if (reason2 != "") then draw.SimpleText(  reason2 ,"SeTitle",mid+110,ypos+210,cr,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER) end
		end)

		if CurTime() > (tm +timeshow) then
			hook.Remove("HUDPaint", "LapinPopup")
		end

	end

	hook.Add("HUDPaint", "LapinINIT", function() -- read server last error only after spawning
		hook.Remove("HUDPaint", "LapinINIT")
		net.Start("LapinGetInfo")
		net.SendToServer()
	end)

	net.Receive("LapinFailAuth",function(len,ply)
		local scriptname = net.ReadString()
		local steamid64 = net.ReadString()
		local steamname = net.ReadString()
		local reason = net.ReadString()
		local reason2 = net.ReadString()
		semessage(scriptid, scriptname, steamid64, steamname, reason, reason2)
	end)



end