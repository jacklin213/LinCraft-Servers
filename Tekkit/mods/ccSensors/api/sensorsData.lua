local eedata={
	--Collector
	collector={
		woft={label="WatchOfFlowingTime Bonus",val="woftFactor"},
		sun={label="sun",val="collectorSunTime",info="currentSunStatus"},
		accumulate={label="accumulate",val="accumulate"},
		power={label="Power",using="isUsingPower",pulling="pullingPower"},
		owner={label="Owner",val="player"},
		progress={label="currentFuelProgress",val="currentFuelProgress"},
		klein={label="klein",progress="kleinProgressScaled",val="kleinPoints"},
		
	},
	furnace={
		woft={label="WatchOfFlowingTime Bonus",val="woftFactor"},
		owner={label="Owner",val="player"},
		power={label="Pulling power",val="pullingPower"},
		burn={label="",val="furnaceBurnTime",maxval="currentItemBurnTime",info="furnaceCookTime"},
		
	},
	--AntiMatterRelay
	relay={
		woft={label="WatchOfFlowingTime Bonus",val="woftFactor"},
		power={label="Pulling power",pulling="pullingPower",sending="isSending"},
		owner={label="Owner",val="player"},
		klein={label="klein",val="klein"},
		energy={label="energy",val="relayEnergyScaled",info="in"},
		accumulate={label="accumulate",val="accumulate"},
		burn={label="burn",val="burnTimeRemainingScaled",val2="cookProgressScaled"},
		
	},
	condenser={
		energy={label="energy",val="scaledEnergy",display="displayEnergy"},
		power={label="power",pulling="pullingPower"},
		owner={label="Owner",val="player"},
		progress={label="ItemProgress",val="currentItemProgress"},
		eternalDensity={label="eternalDensity",val="eternalDensity"},
		condenseOn={label="condenseOn",val="condenseOn"},
		initialized={label="initialized",val="initialized"},
		attractionOn={label="attractionOn",val="attractionOn"},
	},



};

local bcdata={ 
-- engines
	CombustionEngine={
		active={label="Active",val="isRedstonePowered"},
		startdelay={label="Cooling",val="engine.penatlyCooling"},
		stage={label="Status",val="engine.energyStage",info={"Blue","Green","Yellow","Red"}},
		coolant={label="Cooling threshold",val="COOLANT_THRESHOLD"},
		burn={label="Burn Progress",val="engine.burnTime",maxval="totalBurnTime"},
		energy={label="Energy",val="engine.energy",maxval="engine.maxEnergy",info="engine.maxEnergyExtracted"},
		heat={label="Heat",val="engine.heat",maxval="engine.MAX_HEAT",info="engine.energyStage"},
		fuel={label="Fuel",val="engine.liquidQty",maxval="engine.MAX_LIQUID",info="engine.liquidId"},
		coolant={label="Coolant",val="engine.coolantQty",maxval="engine.MAX_LIQUID",info="engine.coolantId"},
		burn={label="Burn Progress",val="engine.burnTime",maxval="totalBurnTime"},
		},
	SteamEngine={
		active={label="Active",val="isRedstonePowered"},
		stage={label="Status",val="engine.energyStage",info={"Blue","Green","Yellow","Red"}},
		energy={label="Energy",val="engine.energy",maxval="engine.maxEnergy",info="engine.maxEnergyExtracted"},
		burn={label="Burn Progress",val="engine.burnTime",maxval="engine.totalBurnTime"},
	},
	RedstoneEngine={
		active={label="Active",val="isRedstonePowered"},
		stage={label="Status",val="engine.energyStage",info={"Blue","Green","Yellow","Red"}},
		energy={label="Energy",val="engine.energy",maxval="engine.maxEnergy",info="engine.maxEnergyExtracted"},
	
	},
		
}

local ic2data={
	--reactor
	reactor={
		heat={label="Hull Temperature",val="heat",maxval="maxheat"},
		energy={label="EU output",val="output"},
		connected={label="Connected?",val="addedToEnergyNet"},
		size={label="Reactor Size",val="size",maxval="6"},
		-- Reactor Content
		content=getContent,
	},
	--EU Storage - MFSU/MFE/BatBox
	--tier,maxStorage,energy,output,redstoneMode,addedToEnergyNet
	eustorage={
		storage={label="stored EU",val="energy",maxval="maxStorage",info="output"},
		energy={label="mode",val="redstoneMode"},
		connected={label="Connected?",val="addedToEnergyNet"},
	},
};

local rp2data={
	--BT Storage
	batterybox={
		energy={label="Energy",val="Charge",val2="Storage"},
		isPowered={label="Powered?",val="Powered"},
	},
	--ConMask
	--Furnace
	furnace={
		burn={label="burn",val="burntime",maxval="totalburn",info="cooktime"},
		active={label="isActive?",val="Active"},
	},

};

local forestrydata={
		engineCopper={
			fuel={label="Fuel",val="engine.burnTime",info="engine.fuelItemId"},
			ash={label="Ash",val="engine.ashProduction",maxval="engine.ashForItem"},

		},
		engineTin={
			isConnected={label="Connected?",val="engine.isAddedToEnergyNet"},
			EUenergy={label="energyStored",val="engine.energyStored"},
		},
		engineBronze={
			burn={label="Burn",val="engine.burnTime",maxval="engine.totalTime"},
			isShutdown={"Shutdown",val="engine.shutdown"},
			fuel={label="Fuel",val="engine.fuelTank.quantity",maxval="engine.fuelTank.capacity",info="engine.fuelTank.liquidId"},
			heating={label="Heating",val="engine.heatingTank.quantity",maxval="engine.heatingTank.capacity",info="engine.heatingTank.liquidId"},
		},
		engine={
			energy={label="Energy",val="engine.storedEnergy",maxval="engine.maxEnergy",info="engine.maxEnergyExtracted"},
			progress={label="Progress",val="engine.progress"},
			heat={label="heat",val="engine.heat",maxval="engine.maxHeat"},
		},

};



function getProbe(module,probe)
	if module=="bc" then
		return bcdata[probe];
	elseif module=="rp2" then
		return rp2data[probe];
	elseif module=="forestry" then
		return forestrydata[probe];
	elseif module=="ic2" then
		return ic2data[probe];
		
	end
end

function bc(probe,reading)
	return bcdata[probe][reading];
end


function get(module)
	if module=="bc" then
		return bcdata;
	end
end