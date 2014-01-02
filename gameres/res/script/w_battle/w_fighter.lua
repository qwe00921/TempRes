--------------------------------------------------------------
-- FileName: 	w_fighter.lua
-- BaseClass:   fighter
-- author:		zhangwq, 2013/06/20
-- purpose:		战士类（多实例）
--------------------------------------------------------------

w_fighter = fighter:new();
local p = w_fighter;
local super = fighter;

--创建新实例
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	o.m_kShadow = {};
	return o;
end

--构造函数
function p:ctor()
    super.ctor(self);
	
	self.tmplife = self.life;
    
	self.selIndex = 0;  --目标选择顺序
	self.pPrePos = nil;
	self.pOriginPos = nil;
	self.m_kShadow = nil;
	self.m_kCurrentBatch = nil;
	self.flynumGreen = nil;
end

--初始化（重载）
function p:Init( idFighter, node, camp )
	super.Init( self, idFighter, node, camp );
	--self.hpbar:GetNode():SetVisible( false );
	self.tmplife = self.life;
	self:SetSelIndex(idFighter);  --按2,1,3,5,4,6顺序选择
	self:CreateHpBar();
	self:CreateFlyNumGreen();
	
	self.showlife = self.life;  --用来显示的血量
	self.maxlife = self.life;  --最大血量
	self.nowlife = self.life; --当前实际血量
	self.beHitTimes = 0;  --受击次数
    self.IsHurt = false;	
	
end

--初始化被选择顺序
function p:SetSelIndex(pId)
    if self.pId == W_BATTLE_POS_TAG_2 then
       self.selIndex = 1 
    elseif self.pId == W_BATTLE_POS_TAG_1 then
	   self.selIndex = 2
    elseif self.pId == W_BATTLE_POS_TAG_3 then
	   self.selIndex = 3
    elseif self.pId == W_BATTLE_POS_TAG_5 then
	   self.selIndex = 4
    elseif self.pId == W_BATTLE_POS_TAG_4 then
	   self.selIndex = 5
    elseif self.pId == W_BATTLE_POS_TAG_6 then
	   self.selIndex = 6
	end;
end

--创建飘血数字
function p:CreateFlyNum(nType)
    local flynum = w_fly_num:new();
    flynum:SetOwnerNode( self.node );
    flynum:Init(nType);
    flynum:SetOffset(30,-50);
    
    self.node:AddChildZ( flynum:GetNode(), 2 );
    self.flynum_mgr[#self.flynum_mgr + 1] = flynum;
    
    if #self.flynum_mgr > 3 then
        WriteConErr( string.format("too many flynum: %s", #self.flynum_mgr));
    end
    return flynum;
end

--创建飘血数字
function p:CreateFlyNumGreen()
    if self.flynumGreen ~= nil then
        return self.flynumGreen;
    end
    local flynum = w_fly_num_green:new();
    flynum:SetOwnerNode( self.node );
    flynum:Init();
    flynum:SetOffset(30,-50);
    self.node:AddChildZ( flynum:GetNode(), 3 );
    self.flynumGreen = flynum;
end

--创建血条
function p:CreateHpBar()
	if self.hpbar == nil or self.m_kShadow == nil then
		self.hpbar = w_hp_bar:new();
		self.hpbar:CreateExpNode();
		self.node:AddChildZ( self.hpbar:GetNode(), 1 );
		self.hpbar:Init( self.node, self.life, self.lifeMax );
		--self.hpbar:HideBar();
	end	
end

--增加生命
function p:SetLifeAdd( num )
    self.life = self.life + num;
    if self.life > self.lifeMax then
        self.life = self.lifeMax;
    end
    self:SetLife( self.life );
    --self.tmplife = self.life;
    self.flynumGreen:PlayNum( num );
end

--临时生命值
function p:SetTmpLife()
	self.tmplife = self.life;
end

function p:CheckTmpLife()
	return self.tmplife > 0;
end

function p:SetPosition(x,y)
	self.node:SetFramePosXY(x,y)
end

function p:SubTmpLife( val )
	self.tmplife = self.tmplife - val;
	
	if self.tmplife < 0 then
        self.tmplife = 0;
    end
end

function p:SubLife(val)  --当前实际血量
	self.nowlife = self.nowlife - val;
	if self.nowlife < 0 then
		self.nowlife = 0;
	end
end;

function p:AddLife(val)
	self.nowlife = self.nowlife + val;
	if self.nowlife > self.maxlife then
		self.nowlife = self.maxlife;
	end
end;

function p:SubShowLife(val) --需展现的血量
	self.showlife = self.showlife - val;
	if self.showlife < 0 then
		self.showlife = 0;
	end
	
    --判断并显示当前血量    
	if self:GetId() == w_battle_mgr.PVEShowEnemyID then 
		--设置UI界面的血量
	end;
end;

function p:AddShowLife(val) --需展现的血量
	self.showlife = self.showlife + val;
	if self.showlife > self.maxlife then
		self.showlife =  self.maxlife;
	end
	
end;


function p:SubTmpLifeHeal( val )
	self.tmplife = self.tmplife + val;
	
	if self.tmplife > self.lifeMax then
		self.tmplife = self.lifeMax;
	end
end

--加载配置
function p:UseConfig( config )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:UseConfig( config );
    end	
end

--战备
function p:standby()
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:Standby("");
    end
end

--设置朝向
function p:SetLookAt( lookat )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:SetLookAt( lookat );
    end
end

--获取朝向
function p:GetLookAt()
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        return playerNode:GetLookAt();
	else
		return E_PLAYER_LOOKAT_RIGHT;
    end
end

--取player节点
function p:GetPlayerNode()
    return ConverToPlayer(self:GetNode());
end

--获取两个战士之间的角度
function p:GetAngleByFighter( targetFighter )
	local selfPos = self:GetNode():GetCenterPos();
	local targetPos = targetFighter:GetNode():GetCenterPos();
	
	local tang = (selfPos.y - targetPos.y) / (targetPos.x - selfPos.x);
	local radians = math.atan(tang);
	
	local degree = radians * 180 / math.pi;
	return degree;
end

function p:JumpToPosition(batch,pTargetPos,bParallelSequence)
    local pJumpSeq = batch:AddParallelSequence();
    local fx = "lancer_cmb.begin_battle_jump";
    
    local atkPos = self:GetPlayerNode():GetCenterPos();
    local targetPos = pTargetPos;
    
    local x = targetPos.x - atkPos.x;
    local y = targetPos.y - atkPos.y;
    local distance = (x ^ 2 + y ^ 2) ^ 0.5;
    
    -- calc start offset
    local startOffset = 0;
    local offsetX = x * startOffset / distance;
    local offsetY = y * startOffset / distance;
    local pPos = CCPointMake(atkPos.x + offsetX, atkPos.y + offsetY );
    self:GetNode():SetCenterPos( pPos);
    
    local pCmd = nil;
    --self.m_kShadow:MoveTo(pPos,targetPos);
    if false == bParallelSequence then
        pCmd = battle_show.AddActionEffect_ToSequence( 0, self:GetPlayerNode(), fx);
    else
        pCmd = battle_show.AddActionEffect_ToParallelSequence( 0, self:GetPlayerNode(), fx);
    end
    
    local varEnv = pCmd:GetVarEnv();

    varEnv:SetFloat( "$1", x );
    varEnv:SetFloat( "$2", y );
    varEnv:SetFloat( "$3", 50 );
    
    return pCmd;
end

--获取战士前方坐标
function p:GetFrontPos(targetNode)
	local frontPos = self:GetNode():GetCenterPos();
    local halfWidthSum = self:GetNode():GetCurAnimRealSize().w/4 + targetNode:GetCurAnimRealSize().w/4;
    
    if self.camp == E_CARD_CAMP_HERO then
        frontPos.x = frontPos.x + halfWidthSum;
    else
        frontPos.x = frontPos.x - halfWidthSum;
    end
    return frontPos;
end

function p:SetShadow(kShadow)
	self.m_kShadow = kShadow;
	self.node:SetShadow(kShadow);
end

--获取战士前方坐标
function p:GetFrontFarPos(targetNode)
	local farPos = self:GetFrontPos(targetNode);
	if self.camp == E_CARD_CAMP_HERO then
		farPos.x = farPos.x + 100;
	else
		farPos.x = farPos.x - 100;
	end
	return farPos;
end

function p:ShowHpBarMoment()
	self.hpbar:ShowBarMoment();
end

function p:SetLife(nowHp,maxHp)
	
end

--去血
function p:SetLifeDamage(num)   
    self.life = self.life - num;
    --WriteCon( string.format("%f", self.life ));
    if self.life <= 0 then
        self.life = 0;
        self:SetLife( 0 );
       -- self:Die();
        
        --死亡不显示血条
        --self.hpbar:GetNode():SetVisible( false );
    else
        self:SetLife(self.life);
    end
    
    --表现飘血
    local flynum = self:GetFreeFlyNum(0);
    if flynum ~= nil then
        flynum:PlayNum( num );
    end
end

--添加lua命令
function p:cmdLua( cmdtype, num, str, seq )
	--暂时临时扣血保存到tmplife
    if cmdtype == "fighter_damage" then
        self:SubTmpLife( num ); 
    elseif cmdtype == "fighter_addHp" or cmdtype == "fighter_revive" then  
        self:SubTmpLifeHeal( num );  
    end
	
    return super.cmdLua( self, cmdtype, num, str, seq );
    
end

function p:BeHitAdd(pAtkId)
	self.beHitTimes[#self.beHitTimes + 1] = pAtkId;
end

function p:BeHitDec(pAtkId)
	for k,v in pairs(self.beHitTimes) do
		if v == pId then
			table.remove(self.beHitTimes,k);
			break;
		end;
	end;
end