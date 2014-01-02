expbar_move_effect = {}
local p = expbar_move_effect;
local moveEffect = nil;
local nowLevel = nil;

p.node = nil;
p.leastNum = nil;
p.maxNum = nil;
p.startNum = nil;
p.endNum = nil;
p.moveTime = nil;
p.nowNum = nil;
local intervalTime = 0.1


function p.showEffect(uiNode,leastNum,maxNum,startNum,endNum,moveTime)
	if moveTime == nil or moveTime == 0 then
		p.moveTime = 1;
	end
	nowLevel = tonumber(msg_cache.msg_player.Level);
	WriteCon("nowLevel == "..nowLevel);
	
	if endNum > maxNum then
		p.endNum = maxNum
		p.startNum = startNum
	else
		p.endNum = endNum
		p.startNum = startNum
	end
	
	local getNum = p.endNum - p.startNum
	p.addNum = math.ceil(getNum/(p.moveTime/intervalTime))
	WriteCon("addNum == "..(p.addNum));

	p.node = uiNode
	p.leastNum = leastNum
	p.maxNum = maxNum
	p.nowNum = p.startNum
	
	p.moveEffectInit()
	SetTimerOnce(p.effect,0.5)
	
end 

function p.moveEffectInit()
	p.node:SetValue( p.leastNum,p.maxNum,p.nowNum);
end

function p.effect()
	moveEffect = SetTimer( p.showMoveEffect, intervalTime );
end

function p.showMoveEffect()
	if p.nowNum == nil or p.endNum == nil then
		return
	end
	
	if p.nowNum <= p.endNum then
		p.node:SetValue( p.leastNum,p.maxNum,p.nowNum);

		if p.nowNum == p.endNum then
			p.ClearData()
			return
		elseif p.nowNum < p.endNum then
			p.nowNum = p.nowNum + p.addNum;
			if p.nowNum > p.endNum then
				p.nowNum = p.endNum
			end
		end
	else
		p.ClearData()
	end
end

function p.setExpBar(leastNum,maxNum,nowNum)
	p.node:SetValue(leastNum,maxNum,nowNum);
end

function p.ClearData()
	KillTimer( moveEffect );
	p.node = nil;
	p.leastNum = nil;
	p.maxNum = nil;
	p.startNum = nil;
	p.endNum = nil;
	p.moveTime = nil;
	p.nowNum = nil;
end
