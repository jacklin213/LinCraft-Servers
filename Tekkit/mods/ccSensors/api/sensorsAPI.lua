--[[
Sensors API


CHANGELOG

0.2
- added: comments for all functions
- added: 


]]--

-- sensorAPI version
function getVersion()
	return "0.2"
end

-- returns a dict of attached peripherals : SensorController,monitor,modem
function getPeripherals()
	local dict={sensor=nil,monitor=nil,modem=nil};
	local sides={"left","right","back","front","bottom","top"}
	for i=1,#sides do
	
		if peripheral.isPresent( sides[i] ) then
			if peripheral.getType( sides[i])  == "SensorController" then
				dict["sensor"]=sides[i];
			elseif peripheral.getType( sides[i])  == "mon" then
				dict["mon"]=sides[i];
				-- add any special handling here
			elseif peripheral.getType( sides[i])  == "modem" then
				dict["modem"]=sides[i];
				-- add any special handling required here - like turn it on when detected
			else
				dict[peripheral.getType( sides[i])] = sides[i];
			end
		end
	end
	return dict;
end

-- return the side the first controller is attached at
function getController()
	local side="none"
	local sides={"left","right","back","front","bottom","top"}
	for i=1,#sides do
--		print ("check side: "..sides[i])
		if peripheral.isPresent( sides[i] ) then
	--		print("Found peripheral on side: "..sides[i])
			if peripheral.getType( sides[i])  == "SensorController" then
				side=sides[i]
			end
		end
	end
	return side
end

function rIterator(t) local i = 1 return function() i=i+2 return t[i-2], t[i-1] end end
function tabtodict(t)
	local r = {}
	for k=1,#t,2 do 
		r[t[k]]=t[k+1] 
	end 
	return r 
end

-- return sensor reading as a table instead of a dict
function getReadingAsTable(side,sensor,...)
	result = {peripheral.call( side, "getSensorReading",sensor,...)}
	--for idx,val in ipairs(result) do
	--	print (idx.."] "..tostring(val))
	--end	
	return result

end

-- set the active target for a given sensor
function setTarget(side,sensor,target)
	return peripheral.call(side,"setTarget",sensor,target)
end

-- set the sensor range (as long is < max_sensor_range
function setSensorRange(side,sensor,range)
	return peripheral.call(side,"setSensorRange",sensor,range)

end

-- returns names of all readings available for a given sensor
function getAvailableReadings(side,sensor)
	result = {peripheral.call( side, "getAvailableReadings",sensor,"type")}
	return result
end 

-- set the active reading to be used when getReading is called
function setActiveReading(side,sensor,reading)
	return {peripheral.call( side, "setReading",sensor,reading)}
end

-- returns the available targets for a given sensor
function getAvailableTargets(side,sensor)
	result = {peripheral.call( side, "getAvailableTargets",sensor)}
	return result
end

function getAvailableTargetsforProbe(side,sensor,probe)
	result = {peripheral.call( side, "getAvailableTargets",sensor,probe)}
	--for i,v in ipairs(result) do
	--print(i..","..v)
	--end
	return result
end

function getAvailableTargetsforProbe2(side,sensor,probe)
	local result2 = {peripheral.call( side, "getAvailableTargets",sensor,probe)}
	local result={};
	for i,v in ipairs(result2) do
		
		result[i] =string.match(v,"%a+");
	end
	return result
end



function getProbes(side,sensor)
	local data = sensors.getSensorInfo(side,sensor,"probes");
	local r={};
	local i=1;
	if data.probes ~= nil then
		for p in string.gmatch(data.probes,"%a+") do
			r[i] = p;
			i =i+1;
		end
	end
	return r;
end

-- returns the following information for a given sensor:
-- cardType,name,activereading,activereadingid,distance,location,methods,SensorRange
function getSensorInfo(side,sensor,...)
	result = {peripheral.call( side, "getSensorInfo",sensor,...)}
	return tabtodict(result)
end
function getSensorInfoAsTable(side,sensor,...)
	result = {peripheral.call( side, "getSensorInfo",sensor,...)}
	return result
end


-- returns sensor reading in a dict of reading,value pairs
function getReading2(side,sensor,probe,target,...)
	result = {peripheral.call( side, "getSensorReading2",sensor,probe,target,...)}
	return tabtodict(result)
end

-- returns sensor reading in a dict of reading,value pairs
function getReading(side,sensor,...)
	result = {peripheral.call( side, "getSensorReading",sensor,...)}
	return tabtodict(result)
end

-- returns the names of all connected sensors 
function getSensors(side)
	return {peripheral.call( side, "getSensorNames" )}
end

--IC2 Reactor
--"heat","output","lastOutput","addedToEnergyNet","chambers","maxheat"


-- get a reading while setting the target and reading type for a given sensor
-- return a dictionary
function getSensorReadingAsDict(side,sensor,target,reading,...)
	setTarget(side,sensor,target)
	setActiveReading(side,sensor,reading)
	return getReading(side,sensor,...)
end
function getSensorReadingAsDict2(side,sensor,probe,target,...)
	return getReading2(side,sensor,probe,target,...)
end

-- get a reading while setting the target and reading type for a given sensor
-- returns a table
function getSensorReadingAsTable(side,sensor,target,reading,...)
	setTarget(side,sensor,target)
	setActiveReading(side,sensor,reading)
	result = {peripheral.call( side, "getSensorReading",sensor,...)}
	return result
	--return getReadingAsTable(side,sensor,...)
end

-- 1xUranium Cell@15
-- return item info from an inventory dictionary
function getItemInfo(name,content)
	local count=0;
	local totalDmg=0;
	
	for i,v in pairs(content) do
		--print(i.." - "..v)
		q,item,dmg= string.match(v,"(%d+)\*(.*)@(%d+)")
		if item==name then
		--print(tostring(item).." vs "..tostring(name));
			totalDmg = totalDmg + dmg;
			count=count+q;
		end
		
	end	

	--print ("Total:"..count..", dmg:"..totalDmg);
	return count,totalDmg;
end


local itemsDict={
itemCellCoolant="Coolant Cell",
itemReactorCooler="Integrated Heat Disperser",
itemReactorPlating="Integrated Reactor Plating",
itemCellUran="Uranium Cell",
ice="Ice",
bucketWater="Water Bucket",
bucket="Bucket",
};

-- returns a dict for each item in the given names table with .dmg and .qty
function getItemsInfo(names,content)
	local r={total=0,};
	for i,v in pairs(content) do
		q,item,dmg= string.match(v,"(%d+)\*(.*)@(%d+)")
		itb = string.sub(item,6)
		item = itemsDict[itb] or item;
		r.total = r.total+1;
		for idx,name in ipairs(names) do
			if item==name then
				local vl=0;
				local vq=0;
				if r[item] then vl =r[item].dmg end
				if r[item] then vq =r[item].qty end
				r[item] = {dmg=vl+dmg,qty=q+vq};
			end
		end
		
	end	
	for idx,name in ipairs(names) do
		if r[name] == nil then
			r[name] = {qty=0, dmg=0}
		end
	end	
	return r;
end
