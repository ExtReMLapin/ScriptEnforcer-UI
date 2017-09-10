if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("LapinFailAuth")
	util.AddNetworkString("LapinGetInfo")
	hook.Add("LapinFailAuth","broadcast",function(id, scriptname, steamid64, reason)
		net.Start("LapinFailAuth")
			net.WriteUInt(id,13)
			net.WriteString(scriptname)
			net.WriteString(steamid64)

			net.WriteString(reason)
		net.Broadcast()

		net.Receive("LapinGetInfo",function(len,ply)
			net.Start("LapinFailAuth")
				net.WriteUInt(id,13)
				net.WriteString(scriptname)
				net.WriteString(steamid64)

				net.WriteString(reason)
			net.Send(ply)
		end)
	end)
	hook.Run("LapinFailAuth", 2019, "Permanent Properties", "76561198001451981", "Only dedicated server is supported.")
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
	local timeshow = 7
	local timemove = 0.3
	local function semessage(scriptid, scname, id64, reason)
		local w = 650
		local h = 205
		local tm = CurTime()
		local scrw = ScrW()
		local scname2 = Format("[%s]",  id64)
		scname = Format("%s [%s]", scname, scriptid)
		local targettime = tm+timeshow-timemove
		surface.SetFont( "SeTitle" )
		local tbl = { surface.GetTextSize("Script name :  " .. scname ),
		surface.GetTextSize("Script Owner :  " .. scname2),
		surface.GetTextSize("Reason :  " .. reason)}

		for k, v in pairs(tbl) do
			print(v)
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

			draw.SimpleText(  "Could not execute addon !" ,"SeTitle",mid+15,ypos+70,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  "Script name : " ,"SeTitle",mid+15,ypos+105,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  scname ,"SeTitle",mid+160,ypos+105,cg,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  "Script Owner :" ,"SeTitle",mid+15,ypos+140,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  scname2 ,"SeTitle",mid+162,ypos+140,cg,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  "Reason :" ,"SeTitle",mid+15,ypos+175,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  reason ,"SeTitle",mid+110,ypos+175,cr,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
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
		local scriptid = net.ReadUInt(13)
		local scriptname = net.ReadString()
		local steamid64 = net.ReadString()
		local steamname = net.ReadString()
		local reason = net.ReadString()
		semessage(scriptid, scriptname, steamid64, steamname, reason)
	end)



end