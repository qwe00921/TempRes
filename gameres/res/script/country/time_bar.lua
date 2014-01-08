time_bar = {}
local p = time_bar;
local moveTimer = nil;

p.node = uiNode;
p.leastTime = leastTime;
p.maxTime = maxTime;
p.nowTime = nowTime;


function p.ShowTimeBar(uiNode,leastTime,maxTime,nowTime) 
	p.node = uiNode;
	p.leastTime = leastTime;
	p.maxTime = maxTime;
	p.nowTime = nowTime;

	p.timeMoveInit()
	moveTimer = SetTimer( p.showMoveTime, 1 );
end

function p.timeMoveInit()
	p.node:SetValue( p.leastTime,p.maxTime,p.nowTime);
end
 
function p.showMoveTime()
	p.nowTime = p.nowTime - 1;
	p.node:SetValue( p.leastTime,p.maxTime,p.nowTime);
	if p.nowTime == 0 then
		p.ClearData()
	end

end

function p.ClearData()
	KillTimer( moveTimer );
	p.node = nil;
	p.leastTime = nil;
	p.maxTime = nil;
	p.nowTime = nil;
end
