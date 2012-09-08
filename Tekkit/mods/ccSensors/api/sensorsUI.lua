--[[
	ccSensors UI API
	Author:  yoskaz01
	Version: 2.0

-]]--

-- configurable settings

-- local directory on each computer to be used to store temp data
local datadir="/localdata/ccSensors"

-- graph fill char for a full block
local graphChar="#"

-- graph fill char for a half block
local graphHalfChar="."





 -- API functions
local sizeX, sizeY = term.getSize()
function pause(str)
	term.write(str)
	return os.pullEvent()
end
function printPaged(str)
	print(str);
	pausePaged("'SPACEBAR' - scroll page  'ENTER' - scroll line.")

end

function pausePaged(str)
	x,y = term.getCursorPos();
	if y>=sizeY-1 then 
		local waitkey=true
		while waitkey do
			term.setCursorPos(1,sizeY);
			evt,k = pause(str);
			term.setCursorPos(1,sizeY);			
			term.clearLine();		
			if evt=="key" and  k== 57 then
				term.clear();
				term.setCursorPos(1,1);
				waitkey=false
			elseif evt=="key" and  k== 28 then
				term.scroll(0);
				waitkey=false
			end
		end
	end
end
	
	
function selectOpt(opts,title)
	local icur=1
	local idone=false
	while idone == false do
		--term.clear()
		term.setCursorPos(sizeX/2-14,5)
		print("MENU:"..title)
		for ii=1,#opts do
			term.setCursorPos(sizeX/2-10,7+ii);
			if ii==icur then
				term.write("<- "..opts[ii].." ->")
			else
				term.write("   "..opts[ii].."   ")
			end
		end
		evt,k = os.pullEvent()
		if evt=="key" then
			if k == 200	then	--up
				icur= icur-1
				if icur<1 then icur=#opts end
			elseif k== 208 then		--down
				icur = icur+1
				if icur > #opts then icur=1 end
			elseif k == 28 or k ==57 then	-- selection made
				idone=true
			end	
		end
	end
	return opts[icur],icur

end

function printm(monitor,text)
	if (monitor =="none") then
		print(text)
	else
		term.redirect(monitor)
		print(text)
		term.restore()
	end

end


function writeMid(s,yPos)
	term.setCursorPos(1,sizeX/2 - string.len(s)/2  )
	term.write(s)
end

function getMonitor()
	local monitor="none"
	local side="none"
	local sides={"left","right","back","front","bottom","top"}
	for i=1,#sides do
--		print ("check side: "..sides[i])
		if peripheral.isPresent( sides[i] ) then
	--		print("Found peripheral on side: "..sides[i])
			if peripheral.getType( sides[i])  == "monitor" then
				side=sides[i]
				monitor = peripheral.wrap( side )
			end
		end
	end
	return side,monitor
end

function writeTop(s,pos)
	if pos==1 or pos==nil then
		term.setCursorPos(1,1)
	elseif pos==2 then
		term.setCursorPos(sizeX/2 - string.len(s)/2,1  )
	elseif pos==3 then
		term.setCursorPos(sizeX - string.len(s),1)
	end
	term.write(s)
end

function writeBottom(s,pos)
	if pos==1 or pos==nil then
		term.setCursorPos(1,sizeY)
	elseif pos==2 then
		term.setCursorPos(sizeX/2 - string.len(s)/2 ,sizeY )
	elseif pos==3 then
		term.setCursorPos(sizeX - string.len(s),sizeY)
	end
	term.write(s)
end

-- run a 2nd function on the big screen
-- written by cloudy
function dualRun(f1, f2, side1, side2)
    if type(f1) ~= "function" or type(f2) ~= "function" then error("Type isn't function. Aborted") end
    co1 = coroutine.create(f1)
    co2 = coroutine.create(f2)
    local monitor, monitor2
    if side1 then
        if peripheral.getType(side1) ~= "monitor" then error("Peripheral at side "..side1.." isn't a monitor.") end
        monitor = peripheral.wrap(side1)
    end
    if side2 then
        if peripheral.getType(side2) ~= "monitor" then error("Peripheral at side "..side2.." isn't a monitor.") end
        monitor2 = peripheral.wrap(side2)
    end
    
    local event, p1, p2, p3, p4, p5
    
    while true do
        if co1 ~= nil and coroutine.status(co1) ~= "dead" then
            if monitor2 then
                term.redirect(monitor2)
                coroutine.resume(co1, event, p1, p2, p3, p4, p5)
                term.restore()
            else
                coroutine.resume(co1, event, p1, p2, p3, p4, p5)
            end
        end
        if co2 ~= nil and coroutine.status(co2) ~= "dead" then
            if monitor then
                term.redirect(monitor)
                coroutine.resume(co2, event, p1, p2, p3, p4, p5)
                term.restore()
            else
                coroutine.resume(co2, event, p1, p2, p3, p4, p5)
            end
        end
        
        if (co1 == nil or coroutine.status(co1) == "dead") and (co2 == nil or coroutine.status(co2) == "dead") then
            break
        end
        
        event, p1, p2, p3, p4, p5 = coroutine.yield()

    end
end

function dashboard()
	local sSensor,sTarget,sReading= sensorsUI.loadDashboard()
	local side = sensors.getController()
	--for i=1,20,1 do
	
	while isLock("dash") do
		term.clear()
		term.setCursorPos(1,1)
		--[[
		if isLock("/ccSensors/dash") then
			print ("still locked")
		end
		print("bla")
		print("line:"..i)
		]]--
		result = sensors.getSensorReadingAsTable(side,sSensor,sTarget,sReading)
		textutils.tabulate(result)
		
		sleep(1)
	end
	term.clear()
	term.setCursorPos(1,1)
end

function isLock(sName)
	if (fs.exists(datadir.."/"..sName..".lock")) then
		return true
	else
		return false
	end
end

function unsetLock(sName)
	if (fs.exists(datadir.."/"..sName..".lock")) then
		fs.delete(datadir.."/"..sName..".lock")
	end

end
function setLock(sName)
	if (not fs.exists(datadir.."/"..sName..".lock")) then
		local file = assert(fs.open(datadir.."/"..sName..".lock","w"))
		file.write("1")
		file.close()
	end
end

function loadDashboard()
	local sDashboard = datadir.."/dash.state"
	local sensor,target,probe ="Sensor","none","none"
	if (fs.exists(sDashboard)) then
		local file = assert(fs.open(sDashboard,"r"))
		sensor = file.readLine()
		probe = file.readLine()
		target = file.readLine()
		file.close()
	end
	return sensor or "none",probe or "none",target or "none"
end
function mkDataDir()
	if not fs.exists(datadir) then 
		fs.makeDir(datadir)
	end
end
function saveDashboard(sensor,probe,target)
	mkDataDir()
	local sDashboard = datadir.."/dash.state"
	file = fs.open(sDashboard,"w")
	file.writeLine(sensor)
	file.writeLine(probe)	
	file.writeLine(target)
	file.close()
end


--- utility functions
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end
function writeAt(x,y,str)
	term.setCursorPos(x ,y);
	term.write(str);
end

------------------------ textual graphing functions ------------------------

function hBar(x,y,size,label,val,maxval)
	if val<0 then val=0 end
	local pct = round(val*100/maxval,1);
	local scale=100/size;
	local fill=pct/scale;
	

	writeAt(x,y,label)
	--local label =  label.."("..val.."/"..maxval..")";
	
	--term.setCursorPos(sizeX - (size+9),y);
	writeAt(17,y,"[");
	local spos=math.floor(fill)
	for i=1,spos do
		term.write(graphChar)
	end
	
	if fill % math.floor(fill) >0 then 
		term.write(graphHalfChar);
		spos = spos+1;
	end
	
	for i=spos+1,size do
		term.write(" ")
	end
	term.write("]"..string.rep(" ",5-string.len(pct))..pct.."%");
end

function checkbox(x,y,label,val)
	term.setCursorPos(x ,y);
	term.write("[");
	if val then term.write("x") else term.write(" ") end;
	term.write("] "..label);
end

function hRadio(x,y,label,val,info)
	term.setCursorPos(x ,y);
	term.write(label.." : ")
	for i,s in ipairs(info) do
		if val == s then
			term.write("["..s.."] ");
		else
			term.write(s.." ");
		end
	end
end

function vr(x,y,size)
	if size>=sizeX then size=sizeX-1 end
	for i=y,y+size do
		term.setCursorPos(x,i);
		term.write("|");
	end
end
function hr(y)
	for x=1,sizeX do
		term.setCursorPos(x,y);
		term.write("-");
	end
end
function vBar(x,y,size,label,val,maxval)
	if size+3>y then size=y-3 end
	local pct = round(val*100/maxval,1);
	local scale=100/size;
	local fill=round(pct/scale,1);
	--local label =  label.."("..val.."/"..maxval..")";
	writeAt(x,y,string.format("%6s",label))
	writeAt(x,y-1,"----");
	writeAt(x+1,y-2-size,"__");
	for i=1,size do
		term.setCursorPos(x+1,y-1-i);
		if (i==math.floor(fill)) then
			term.write("== "..pct.."%"..string.rep(" ",4-string.len(pct)));
		else
			term.write("||      ");
		end
	end
end
function vRadio(x,y,label,val,info)
	writeAt(x,y,label)
	writeAt(x ,y-1,string.rep("-",string.len(label)));
	local sel=y-2;
	local length=1;
	for i,s in ipairs(info) do
		if val == s then
			sel = sel-i;
		end
		length = math.max(string.len(s),length);
		writeAt(x,y-1-i,s)
	end
	writeAt(x-1 ,sel,"[");
	writeAt(x+length ,sel,"]");
end


--[[	term functions										]]--
function clearArea(x1,y1,x2,y2)
	for y=y1,y2 do
		term.setCursorPos(x1,y)
		term.write(string.rep(" ",x2-x1+1));
		--[[
		for x=x1,x2 do
			term.setCursorPos(x,y)
			term.write(" ");
		end
		]]--
	end
end


--[[     Utility functions                                	]]--
function split(str,sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end



--[[
function hBar(x,y,size,id,graph,obj)
	local val=obj[graph[id].val];
	local maxval=obj[graph[id].maxval];
	local pct = val*100/maxval;
	local scale=100/size;
	local fill=pct/scale;

	term.setCursorPos(x,y)
	local label =  graph[id].label.."("..val.."/"..maxval..")";
	term.write(label);
	
	--term.setCursorPos(x + string.len(label),y);
	term.setCursorPos(x + 25,y);
	term.write("[0%:")
	for i=1,fill do
		term.write("=")
	end
	
	if fill<=0 then fill=1 elseif fill==1 then fill=2  end
	for i=fill,size do
		term.write(" ")
	end
	
	term.write(":100%]")
end
function checkbox(x,y,id,objdef,obj)
	local val=obj[objdef[id].val];
	term.setCursorPos(x ,y);
	term.write("[");
	if obj[objdef[id].val] then term.write("x") else term.write(" ") end;
	term.write("] "..objdef[id].label);
end

function hRadio(x,y,id,objdef,obj)
	term.setCursorPos(x ,y);
	term.write(objdef[id].label.." : ")
	for i,s in ipairs(objdef[id].info) do
		if obj[objdef[id].val] == s then
			term.write("["..s.."] ");
		else
			term.write(s.." ");
		end
	end
end


function hr(y)
	for x=1,sizeX do
		term.setCursorPos(x,y);
		term.write("-");
	end
end


]]--