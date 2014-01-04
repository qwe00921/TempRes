w_battle_PVEStaMachMgr = {}
local p = w_battle_PVEStaMachMgr;

p.StateMachineLst = {};
p.id = 0;

function p.init()
	p.StateMachineLst = {};
	p.id = 0;
end;


function p.addStateMachine(pStateMachine)
	p.id = p.id + 1;	
	p.StateMachineLst[p.id] = pStateMachine;


	return p.id;
	
end


function p.delStateMachine(id)
	p.StateMachineLst[id] = nil;
end

function p.getStateMachine(id)
	return p.StateMachineLst[id]
	
end

