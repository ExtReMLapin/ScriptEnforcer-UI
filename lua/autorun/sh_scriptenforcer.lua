if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("SEFailAuth")
	util.AddNetworkString("SEGetInfo")
	hook.Add("SEFailAuth","broadcast",function(id, scriptname, steamid64, steamname, reason)
		net.Start("SEFailAuth")
			net.WriteUInt(id,13)
			net.WriteString(scriptname)
			net.WriteString(steamid64)
			net.WriteString(steamname)
			net.WriteString(reason)
		net.Broadcast()

		net.Receive("SEGetInfo",function(len,ply)
			net.Start("SEFailAuth")
				net.WriteUInt(id,13)
				net.WriteString(scriptname)
				net.WriteString(steamid64)
				net.WriteString(steamname)
				net.WriteString(reason)
			net.Send(ply)
		end)
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

	local cb = Color(55,55,55)
	local wc = Color(255,255,255)
	local ccb = Color(70,70,70)
	local cc = Color(234,141,37)
	local cg = Color(50,255,50)
	local cr = Color(255,50,50)
	local main = Color(80,80,80)
	local sublogobar = Color(85,85,85)
	local timeshow = 7
	local timemove = 0.3
	local logo = Material("se_logo.png")
	local function semessage(scriptid, scname, id64, stname, reason)
		local tm = CurTime()
		local scrw = ScrW()
		local scrh = ScrH()
		local scname2 = Format("%s [%s]", stname, id64)
		local targettime = tm+timeshow-timemove
		hook.Add("HUDPaint", "SEPopup", function()

			local ypos = 150
			local w = 600
			local h = 200
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
			surface.DrawRect( mid, ypos, w, h )
			surface.SetDrawColor(ccb )
			surface.DrawRect( mid, ypos+h-4, w, 10 )
			surface.SetDrawColor(cc )
			local time = math.Remap(CurTime()-tm,0,timeshow,w,0)
			surface.DrawRect( mid, ypos+h-4, time, 10 )

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( logo	)
			surface.DrawTexturedRect( mid+5, ypos+10, 250, 38 )

	

			surface.SetDrawColor(main )
			surface.DrawRect( mid, ypos+54, w, h-54 )
			
			surface.SetDrawColor(sublogobar )
			surface.DrawRect( mid, ypos+50, w, 4 )

			draw.SimpleText(  "Could not load ScriptEnforcer addon !" ,"SeTitle",mid+15,ypos+70,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  "Script name : " ,"SeTitle",mid+15,ypos+105,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  scname ,"SeTitle",mid+160,ypos+105,cg,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  "Script Owner :" ,"SeTitle",mid+15,ypos+140,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  scname2 ,"SeTitle",mid+162,ypos+140,cg,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  "Reason :" ,"SeTitle",mid+15,ypos+175,cw,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(  reason ,"SeTitle",mid+115,ypos+175,cr,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end)

		if CurTime() > (tm +timeshow) then
			hook.Remove("HUDPaint", "SEPopup")
		end

	end

	hook.Add("HUDPaint", "SEINIT", function() -- read server last error only after spawning
		hook.Remove("HUDPaint", "SEINIT")
		net.Start("SEGetInfo")
		net.SendToServer()
	end)
	net.Receive("SEFailAuth",function(len,ply)
		local scriptid = net.ReadUInt(13)
		local scriptname = net.ReadString()
		local steamid64 = net.ReadString()
		local steamname = net.ReadString()
		local reason = net.ReadString()
		semessage(scriptid, scriptname, steamid64, steamname, reason)
	end)



end