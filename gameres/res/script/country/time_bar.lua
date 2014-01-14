time_bar = {}
local p = time_bar;
local moveTimer = nil;

p.leastTime = nil;
p.maxTime = nil;
p.upbulidTime = nil;
p.node = nil;
p.TextNode = nil;
--p.lastTime = nil;

function p.ShowTimeBar(leastTime,maxTime,upbulidTime,uiNode,timeTextNode) 
	p.node = uiNode;
	p.leastTime = leastTime;
	p.maxTime = maxTime;
	p.upbulidTime = upbulidTime;
	p.TextNode = timeTextNode;
		--WriteCon("rewardTable hour"..hour);

	p.timeMoveInit()
	moveTimer = SetTimer( p.showMoveTime, 0.1 );
end

function p.timeMoveInit()
	
	local nowTime = os.time();
	local lastTime = p.upbulidTime - nowTime;

	p.node:SetValue( p.leastTime,p.maxTime,lastTime);
	p.setTimeText(lastTime)
end
 
function p.showMoveTime()
	local nowTime = os.time();
	local lastTime = p.upbulidTime - nowTime;
	p.node:SetValue( p.leastTime,p.maxTime,lastTime);
	if lastTime <= 0 then
		p.TextNode:SetText("升级完成！");
		p.ClearData()
	else
		p.setTimeText(lastTime)
	end

end

function p.setTimeText(lastTime)
	local hour = math.floor(lastTime/3600)
	local minute = math.floor(lastTime/60)
	local seconds = math.mod(lastTime,60)
	local hourText = hour;
	local minuteText = minute;
	local secondsText = seconds;
	if hour < 10 then
		hourText = "0"..hour;
	end
	if minute < 10 then
		minuteText = "0"..minute;
	end
	if seconds < 10 then
		secondsText = "0"..seconds;
	end
	
	local timeText = hourText..":"..minuteText..":"..secondsText
	p.TextNode:SetText(timeText);
end


function p.ClearData()
	if moveTimer then
		KillTimer( moveTimer );
	end
	p.leastTime = nil;
	p.maxTime = nil;
	p.upbulidTime = nil;
	p.node = nil;
	p.TextNode = nil;
end
