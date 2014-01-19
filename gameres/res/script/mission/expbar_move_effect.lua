expbar_move_effect = {}
local p = expbar_move_effect;
local moveEffect = nil;
local intervalTime = 0.1;	--多久移动一次
local moveTime = 1;	--多久移动完

p.node = nil;
p.leastNum = nil;
p.maxNum = nil;
p.startNum = nil;
p.nowLevel = nil;

p.getNum = nil;
p.lastGetNum = nil;

p.nowNum = nil;
p.endNum = nil;
p.addNum = nil;
p.NextLevel = nil;

p.isUpLevel = false;
function p.showEffect(expBar,leastNum,maxNum,startNum,getExp,nowLevel)
	p.node = expBar;
	p.leastNum = leastNum
	p.maxNum = maxNum;
	p.startNum = startNum;
	p.nowLevel = nowLevel;

	p.endNum = startNum + getExp
	if p.endNum >= p.maxNum then
		p.getNum = maxNum - startNum;
		p.lastGetNum = getExp - p.getNum
		p.endNum = maxNum
		p.isUpLevel = true;
	else
		p.getNum = getExp
		p.endNum = startNum + getExp 
	end
	
	
	p.addNum = p.getAddNum(p.getNum)
	p.nowNum = p.startNum;

	p.moveEffectInit()
	--SetTimerOnce(p.effect,0.5)
	p.effect()
end

function p.getAddNum(Num)
	local addNum = math.floor(Num/(moveTime/intervalTime)) 
	return addNum
end

function p.moveEffectInit()
	p.node:SetValue( p.leastNum,p.endNum,p.nowNum);
end

function p.effect()
	WriteCon("p.maxNum == "..(p.maxNum));
	WriteCon("p.nowNum == "..(p.nowNum));
	WriteCon("p.endNum == "..(p.endNum));
	WriteCon("p.addNum == "..(p.addNum));
	
	
	moveEffect = SetTimer( p.showMoveEffect, intervalTime );
end

function p.showMoveEffect()
	if p.nowNum == nil or p.endNum == nil then
		if moveEffect then
			KillTimer( moveEffect );
		end		
		WriteCon("p============");
		return
	end
	
	if p.nowNum <= p.endNum then
		p.node:SetValue( p.leastNum,p.maxNum,p.nowNum);
		quest_reward.setExpUpNeed(p.maxNum-p.nowNum);
		
		if p.nowNum == p.endNum then
			p.overEffect()
		elseif p.nowNum < p.endNum then
			p.nowNum = p.nowNum + p.addNum;
			if p.nowNum >= p.endNum then
				p.nowNum = p.endNum
			end
		end
	else
		p.overEffect()
	end
end

function p.overEffect()
	KillTimer( moveEffect );
	moveEffect = nil;
	if p.isUpLevel then
		p.nowNum = 0;
		p.nowLevel = p.nowLevel + 1;
		local useExpT = SelectRowInner(T_PLAYER_LEVEL,"level",p.nowLevel);
		if useExpT == nil then
			WriteConErr("T_PLAYER_LEVEL Error ");
		end
		p.maxNum = tonumber(useExpT.exp);

		if p.lastGetNum >= p.maxNum then
			p.lastGetNum = p.lastGetNum - p.maxNum
			p.endNum = p.maxNum
			p.getNum = p.maxNum
			p.addNum = p.getAddNum(p.getNum)
			p.effect()
		else
			p.isUpLevel = false
			p.endNum = p.lastGetNum
			p.getNum = p.lastGetNum
			p.addNum = p.getAddNum(p.getNum)
			p.effect()
		end
	else
		p.ClearData()
	end
end


function p.ClearData()
	if moveEffect then
		KillTimer( moveEffect );
	end
	p.node = nil;
	p.leastNum = nil;
	p.maxNum = nil;
	p.startNum = nil;
	p.nowLevel = nil;

	p.getNum = nil;
	p.lastGetNum = nil;

	p.nowNum = nil;
	p.endNum = nil;
	p.addNum = nil;
	p.NextLevel = nil;

end
