--------------------------------------------------------------
-- FileName: 	w_fighter.lua
-- BaseClass:   fighter
-- author:		zhangwq, 2013/06/20
-- purpose:		սʿ�ࣨ��ʵ����
--------------------------------------------------------------

w_fighter = fighter:new();
local p = w_fighter;
local super = fighter;

--������ʵ��
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	o.m_kShadow = {};
	return o;
end

--���캯��
function p:ctor()
    super.ctor(self);
	self.beHitTimes	= {}  --�ܻ�����
	self.beTarTimes = {}  --��ΪĿ��δ�����Ķ���
    self.IsHurt = false;	
	self.JoinAtkTime = nil;
	self.HitTime = 0;
	self.tmplife = self.life;
    self.atkType = 0;
	self.selIndex = 0;  --Ŀ��ѡ��˳��
	self.pPrePos = nil;
	self.pOriginPos = nil;
	self.m_kShadow = nil;
	self.m_kCurrentBatch = nil;
	self.flynumGreen = nil;
	self.damage = 0;
	self.Buff = 1;
	
	self.nowlife = 0; --��ǰʵ��Ѫ��
	self.IsTurnEnd = false;
	self.firstID = nil; --�ϻ��ж��ĵ�һ��
	self.SkillBuff = {}  --�е�BUFF�б�
end

--��ʼ�������أ�
function p:Init( idFighter, node, camp )
	super.Init( self, idFighter, node, camp, true );
	--self.hpbar:GetNode():SetVisible( false );
	self.tmplife = self.life;
	self:SetSelIndex(idFighter);  --��2,1,3,5,4,6˳��ѡ��

	self.damage = self.Attack;
	self.Buff = 1;
	
	self.nowlife = self.life; --��ǰʵ��Ѫ��
	self.Hp = self.life;
	self.maxHp = self.life;        

	--self:CreateHpBar();
	--self:CreateFlyNumGreen();	
end


--��ʼ����ѡ��˳��
function p:SetSelIndex(pId)
    if self.Position == W_BATTLE_POS_TAG_2 then
       self.selIndex = 1 
    elseif self.Position == W_BATTLE_POS_TAG_1 then
	   self.selIndex = 2
    elseif self.Position == W_BATTLE_POS_TAG_3 then
	   self.selIndex = 3
    elseif self.Position == W_BATTLE_POS_TAG_5 then
	   self.selIndex = 4
    elseif self.Position == W_BATTLE_POS_TAG_4 then
	   self.selIndex = 5
    elseif self.Position == W_BATTLE_POS_TAG_6 then
	   self.selIndex = 6
	end;
end

--����ƮѪ����
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

--����ƮѪ����
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

--����Ѫ��
function p:CreateHpBar()
	if self.hpbar == nil or self.m_kShadow == nil then
		self.hpbar = w_hp_bar:new();
		self.hpbar:CreateExpNode();
		self.node:AddChildZ( self.hpbar:GetNode(), 1 );
		self.hpbar:Init( self.node, self.life, self.lifeMax );
		--self.hpbar:HideBar();
	end	
end

--��������
function p:SetLifeAdd( num )
    self.life = self.life + num;
    if self.life > self.lifeMax then
        self.life = self.lifeMax;
    end
    self:SetLife( self.life );
    --self.tmplife = self.life;
    self.flynumGreen:PlayNum( num );
end

--��ʱ����ֵ
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

function p:SubLife(val)  --��ǰʵ��Ѫ��
	self.nowlife = self.nowlife - val;
	if self.nowlife < 0 then
		self.nowlife = 0;
	end
end;

function p:AddLife(val)
	self.nowlife = self.nowlife + val;
	if self.nowlife > self.maxHp then
		self.nowlife = self.maxHp;
	end
end;

--����ƮѪ����
function p:CreateFlyNum(nType)
	local flynum = fly_num:new();
	flynum:SetOwnerNode( self.node );
	flynum:Init(nType);
	flynum:SetOffset(30,-30);
	
	self.node:AddChildZ( flynum:GetNode(), 2 );
	self.flynum_mgr[#self.flynum_mgr + 1] = flynum;
	
	return flynum;
end
	
function p:SubShowLife(val) --��չ�ֵ�Ѫ��
	self.Hp = self.Hp - val;
	if self.Hp < 0 then
		self.Hp = 0;
	end
	
	--��Ѫ����, ����֧�ֵ����
	local flynum = self:CreateFlyNum(2);
    if flynum ~= nil then
        flynum:PlayNum( val );
    end	
	
    --�жϲ���ʾ��ǰѪ��    
	if self:GetId() == w_battle_mgr.PVEShowEnemyID then 
		--����UI�����Ѫ��
	end;
end;

function p:AddShowLife(val) --��չ�ֵ�Ѫ��
	self.Hp = self.Hp + val;
	if self.Hp > self.maxHp then
		self.Hp =  self.maxHp;
	end
	
	--��Ѫ����, ����֧�ֵ����
	local flynum = self:CreateFlyNum(1);
    if flynum ~= nil then
        flynum:PlayNum( val );
    end	
	
    --�жϲ���ʾ��ǰѪ��    
	if self:GetId() == w_battle_mgr.PVEShowEnemyID then 
		--����UI�����Ѫ��
	end;
end;

function p:AddSkillBuff(skillID)
	local lRecord = {skillID = skillID, times = 10}
	table.insert(self.SkillBuff, lRecord);
end;



function p:SubTmpLifeHeal( val )
	self.tmplife = self.tmplife + val;
	
	if self.tmplife > self.lifeMax then
		self.tmplife = self.lifeMax;
	end
end

--��������
function p:UseConfig( config )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:UseConfig( config );
    end	
end

--ս��
function p:standby()
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:Standby("");
    end
end

--���ó���
function p:SetLookAt( lookat )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:SetLookAt( lookat );
    end
end

--��ȡ����
function p:GetLookAt()
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        return playerNode:GetLookAt();
	else
		return E_PLAYER_LOOKAT_RIGHT;
    end
end

--ȡplayer�ڵ�
function p:GetPlayerNode()
    return ConverToPlayer(self:GetNode());
end

--��ȡ����սʿ֮��ĽǶ�
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

--��ȡսʿǰ������
function p:GetFrontPos(targetNode)
	local frontPos = self:GetNode():GetCenterPos();
    local halfWidthSum = self:GetNode():GetCurAnimRealSize().w/4 + targetNode:GetCurAnimRealSize().w/4;
    
    if self.camp == E_CARD_CAMP_HERO then
        frontPos.x = frontPos.x - halfWidthSum;
    else
        frontPos.x = frontPos.x + halfWidthSum;
    end
    return frontPos;
end

function p:SetShadow(kShadow)
	self.m_kShadow = kShadow;
	self.node:SetShadow(kShadow);
end

--��ȡսʿǰ������
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

function p:GetAtkType()
	return self.atkType;
end;

--ȥѪ
function p:SetLifeDamage(num)   
    self.life = self.life - num;
    --WriteCon( string.format("%f", self.life ));
    if self.life <= 0 then
        self.life = 0;
        self:SetLife( 0 );
       -- self:Die();
        
        --��������ʾѪ��
        --self.hpbar:GetNode():SetVisible( false );
    else
        self:SetLife(self.life);
    end
    
    --����ƮѪ
    local flynum = self:GetFreeFlyNum(0);
    if flynum ~= nil then
        flynum:PlayNum( num );
    end
end

--���lua����
function p:cmdLua( cmdtype, num, str, seq )
	--��ʱ��ʱ��Ѫ���浽tmplife
    if cmdtype == "fighter_damage" then
        self:SubTmpLife( num ); 
    elseif cmdtype == "fighter_addHp" or cmdtype == "fighter_revive" then  
        self:SubTmpLifeHeal( num );  
    end
	
    return super.cmdLua( self, cmdtype, num, str, seq );
    
end
--�������Ĵ���
function p:GetHitTimes()
	local lCount = 0;
	if (self.beHitTimes ~= nil) or (self.beHitTimes ~= {}) then
		lCount = table.maxn(self.beHitTimes);
	end;
	return lCount;
end;

function p:BeHitAdd(pAtkId)
	self.beHitTimes[#self.beHitTimes + 1] = pAtkId;
end


function p:BeHitDec(pAtkId)
	for k,v in pairs(self.beHitTimes) do
		if v == pAtkId then
			table.remove(self.beHitTimes,k);
			break;
		end;
	end;
end

--��ΪĿ��Ĵ���
function p:GetTargerTimes()
	local lCount = 0;
	if (self.beTarTimes ~= nil) or (self.beTarTimes ~= {}) then
		lCount = table.maxn(self.beTarTimes);
	end;
	return lCount;
end;

function p:BeTarTimesAdd(pAtkId)
	self.beTarTimes[#self.beTarTimes + 1] = pAtkId;
end

function p:BeTarTimesDec(pAtkId)
	for k,v in pairs(self.beTarTimes) do
		if v == pAtkId then
			table.remove(self.beTarTimes,k);
			break;
		end;
	end;
end

function p:UseItem(pId)
	local subtype = tonumber(SelectCell( T_MATERIAL, pId, "subtype" ));
	local effect_type = tonumber(SelectCell( T_MATERIAL, pId, "effect_type" ));
	local effect_value = tonumber(SelectCell( T_MATERIAL, pId, "effect_value" ));

	if subtype == W_MATERIAL_SUBTYPE1 then  --HP>0��
		if self:IsAlive() == true then
			self.nowlife = self.nowlife + effect_value;
			if self.nowlife > self.maxHp then
				self.nowlife = self.maxHp;
			end		
			self.Hp = self.nowlife;
		end
	elseif subtype == W_MATERIAL_SUBTYPE2 then --����Ӧ״̬�Ĳſ���
		if effect_type == W_BATTLE_REVIVAL then --������Ʒ
			if(self:IsDead() == true) then
				self.isDead = false;
				self.nowlife = math.mod(self.maxHp * effect_value / 100);
				self.Hp = self.nowlife;
			end
		else  --��״̬��BUFF
			self:RemoveBuff(effect_type);
		end;
	elseif subtype == W_MATERIAL_SUBTYPE3 then --����δ������,������
		self:AddBuff(effect_type,effect_value) --��BUFF״̬���غ���
	end
	
end

function p:HasBuff(effect_type)
	local lRes = false;
	return lRes;
end;

function p:AddBuff(effect_type,effect_value)

end;

function p:RemoveBuff(effect_type)
	
end;

