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
	self.beHitTimes	= {}  --受击次数
	self.beTarTimes = {}  --成为目标未攻击的队列
    self.IsHurt = false;	
	self.JoinAtkTime = nil;
	self.HitTime = 0;
	self.tmplife = self.life;
    self.atkType = 0;
	self.selIndex = 0;  --目标选择顺序
	self.pPrePos = nil;
	self.pOriginPos = nil;
	self.m_kShadow = nil;
	self.m_kCurrentBatch = nil;
	self.flynumGreen = nil;
	self.damage = 0;
	self.Buff = 1;
	
	self.nowlife = 0; --当前实际血量
	self.IsTurnEnd = false;
	self.firstID = nil; --合击判定的第一下
	self.SkillBuff = {}  --中的BUFF列表
	self.canRevive = false;
	self.BuffNode = nil;
	self.BuffIndex = 1;
end

--初始化（重载）
function p:Init( idFighter, node, camp )
	super.Init( self, idFighter, node, camp, true );
	--self.hpbar:GetNode():SetVisible( false );
	self.tmplife = self.life;
	self:SetSelIndex(idFighter);  --按2,1,3,5,4,6顺序选择

	self.damage = self.Attack;
	self.Buff = 1;
	
	self.nowlife = self.life; --当前实际血量
	self.Hp = self.life;
	self.maxHp = self.life;        
    self.HasTurn = true;  --没有中其它BUFF
	self:InitBuffNode();
	--self:CreateHpBar();
	--self:CreateFlyNumGreen();	
end


--初始化被选择顺序
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

--创建飘血数字
function p:CreateFlyNum(nType)
    local flynum = w_fly_num:new();
    flynum:SetOwnerNode( self.node );
    flynum:Init(nType);
    flynum:SetOffset(30,-20);
    
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
    flynum:SetOffset(30,-20);
    self.node:AddChildZ( flynum:GetNode(), 3 );
    self.flynumGreen = flynum;
end

--暴击/合击文字
function p:CreateLab(fx)
	local flyLab = w_flyLab:new();
    flyLab:SetOwnerNode( self.node );
    flyLab:Init();
    flyLab:SetOffset(fx,-20);
    self.node:AddChildZ( flyLab:GetNode(), 3 );
	return flyLab;
    --self.flynumGreen = flynum;
end;


function p:ShowCrit()
	local lab = self:CreateLab(0)
	lab:PlayLab(1);
end;

function p:ShowSpeak()
	local lab = self:CreateLab(30)
	lab:PlayLab(2);
end;

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
    self:CreateFlyNumGreen( num );
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
	if self.camp == E_CARD_CAMP_HERO then
		local str = string.format("id=%d nowlife=%d val=%d", self:GetId(),self.nowlife,val);
		WriteCon(str);
	end

end;

function p:AddLife(val)
	self.nowlife = self.nowlife + val;
	if self.nowlife > self.maxHp then
		self.nowlife = self.maxHp;
	end
	
	if self.camp == E_CARD_CAMP_HERO then
		local str = string.format("id=%d nowlife=%d addval=%d", self:GetId(),self.nowlife,val);
		WriteCon(str);
	end
end;

--创建飘血数字
function p:CreateFlyNum(nType)
	local flynum = fly_num:new();
	flynum:SetOwnerNode( self.node );
	flynum:Init(nType);
	flynum:SetOffset(30,-30);
	
	self.node:AddChildZ( flynum:GetNode(), 2 );
	self.flynum_mgr[#self.flynum_mgr + 1] = flynum;
	
	return flynum;
end
	
function p:SubShowLife(val) --需展现的血量
	self.Hp = self.Hp - val;
	if self.Hp < 0 then
		self.Hp = 0;
	end
	
	--掉血动画, 可以支持掉多个
	local flynum = self:CreateFlyNum(2);
    if flynum ~= nil then
        flynum:PlayNum( val );
    end	
	
	if self.camp == E_CARD_CAMP_HERO then
		local str = string.format("id=%d Hp=%d val=%d", self:GetId(),self.Hp,val);
		WriteCon(str);
	end	
	
    
end;

function p:AddShowLife(val) --需展现的血量
	self.Hp = self.Hp + val;
	if self.Hp > self.maxHp then
		self.Hp =  self.maxHp;
	end
	
	--掉血动画, 可以支持掉多个
	local flynum = self:CreateFlyNum(1);
    if flynum ~= nil then
        flynum:PlayNum( val );
    end	
	
	if self.camp == E_CARD_CAMP_HERO then
		local str = string.format("id=%d Hp=%d addval=%d", self:GetId(),self.Hp,val);
		WriteCon(str);
	end
end;

function p:AddSkillBuff(pSkillID)
	local lwork_time = tonumber(SelectCell(T_SKILL,pSkillID,"buff_time"))
	local lbuff_param = tonumber(SelectCell(T_SKILL,pSkillID,"buff_param"))
	local lbuff_type = tonumber(SelectCell(T_SKILL,pSkillID,"buff_type"))
	local lRecord = {buff_type = lbuff_type, buff_time = lwork_time, buff_param=lbuff_param}
	table.insert(self.SkillBuff, lRecord);
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
        frontPos.x = frontPos.x - halfWidthSum;
    else
        frontPos.x = frontPos.x + halfWidthSum;
    end
    return frontPos;
end

--近战攻击特效
function p:GetAtkImageNode(atkNode,ani)

	local imageNode = createNDRole();
	imageNode:Init();
	             
	local cSize = self:GetNode():GetFrameSize();					
	local y = cSize.h / 2;
	if self.camp == E_CARD_CAMP_HERO then	
		x = 0
	else
		x = cSize.w;
	end
	
	local lnewPos = CCPointMake(x,y)
    --播放动画
    imageNode:SetVisible( true );
	
	self.node:AddChildZ( imageNode, 3 );
	imageNode:SetFramePos(lnewPos);	
	if self.camp == E_CARD_CAMP_HERO then	
		imageNode:SetLookAt( E_LOOKAT_RIGHT );
	else
		imageNode:SetLookAt( E_LOOKAT_LEFT );
	end
	return imageNode;
end;

--BUFF状态
function p:InitBuffNode()
	local imageNode = createNDRole();
	imageNode:Init();
	             
	local cSize = self:GetNode():GetFrameSize();					
	local y = 0;
	local x = cSize.w/2;		
	
	local lnewPos = CCPointMake(x,y)
    --播放动画
    imageNode:SetVisible( false );
	
	self.node:AddChildZ( imageNode, E_BATTLE_Z_NORMAL );
	imageNode:SetFramePos(lnewPos);	
    if self.camp == E_CARD_CAMP_HERO then	
		imageNode:SetLookAt( E_LOOKAT_LEFT );
	else
		imageNode:SetLookAt( E_LOOKAT_RIGHT );
	end
	self.BuffNode = imageNode;
end;

function p:SetBuffNode(lBuffType)
	if lBuffType == 0 then
		self.BuffNode:SetVisible(false)
		return ;
	else
		self.BuffNode:SetVisible(true);
	end
	
	local lBuffAni = "n_battle_buff.buff_type_"..tostring(lBuffType); 

--	self.BuffNode:SetPicture(GetPictureByAni(lBuffAni,0));
	local cmdBuff = createCommandEffect():AddFgEffect( 0, self.BuffNode, lBuffAni );
	local batch = w_battle_mgr.GetBattleBatch(); 
	local seqBuff = batch:AddSerialSequence();
	seqBuff:AddCommand(cmdBuff);
	
end;

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

function p:GetAtkType()
	return self.atkType;
end;

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
--被攻击的次数
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

--成为目标的次数
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
	local lResult = true;
	local subtype = tonumber(SelectCell( T_MATERIAL, pId, "sub_type" ));
	local effect_type = tonumber(SelectCell( T_MATERIAL, pId, "effect_type" ));
	local effect_value = tonumber(SelectCell( T_MATERIAL, pId, "effect_value" ));

	if subtype == W_MATERIAL_SUBTYPE1 then  --HP>0的
		if self:IsAlive() == true then
			local lval = 0
			if effect_type == 1 then
				lval = math.modf(self.maxHp * effect_value / 100);
			elseif effect_type == 2 then
				lval = effect_value;
			end;
			
			self:AddLife(lval);
			self:AddShowLife(lval);
		else
			lResult = false;
		end
	elseif subtype == W_MATERIAL_SUBTYPE2 then --中相应状态的才可用
		if effect_type == W_BATTLE_REVIVAL then --复活物品
			if(self:IsDead() == true) then
				self.isDead = false;
				self.nowlife = math.mod(self.maxHp * effect_value / 100);
				self.Hp = self.nowlife;
			end
		else  --解状态的BUFF
			self:RemoveBuff(effect_type);
		end;
	elseif subtype == W_MATERIAL_SUBTYPE3 then --所有未死亡的,均可用
		self:AddBuff(effect_type,effect_value) --上BUFF状态及回合数
	end
	
	return lResult;
end

function p:HasBuff(buff)
	local lRes = false;
	for k,v in ipairs(self.SkillBuff) do
		if (v.buff_type == buff) then
			lRes = true;
			break;
		end
	end
	
	return lRes;
end;

--BUFF类型,参数
function p:AddBuff(buff, work,param)
	--local skillRecord = {effecttype = effect_type, effectval = effect_value};
	if param == nil then
		param = 0;
	end
	local skillRecord = {buff_type = tonumber(effect_type), buff_time = tonumber(work), buff_param = tonumber(param)};
	table.insert(self.SkillBuff, skillRecord);
end;

function p:RemoveBuff(val)
	for i= #self.SkillBuff,1, -1 do
		local skillRecord = self.SkillBuff[i];
		if skillRecord.buff_type == val then
			table.remove(self.SkillBuff, i);
			if val == W_BUFF_TYPE_301 then  --死亡只扣一次BUFF
				break;
			end
		end
	end
end;

function p:UseHpBall(pVal)
	local addHp = math.modf(self.maxHp * pVal / 100);
	self.Hp = self.Hp +addHp;
	if self.Hp > self.maxHp then
		self.Hp = self.maxHp;
	end
	
	self.nowlife = self.nowlife + addHp;
	if self.nowlife > self.maxHp then
		self.nowlife = self.maxHp 
	end 
	w_battle_mgr.HpBallNum = w_battle_mgr.HpBallNum - 1
	if w_battle_mgr.HpBallNum < 0 then
		WriteCon("Error HpBallNum < 0");
	else
		WriteCon("HpBallNum ="..tostring(w_battle_mgr.HpBallNum));
	end
	w_battle_mgr.checkPickEnd();
end;

function p:UseSpBall(pVal)
	self.Sp = self.Sp + pVal;
	if self.Sp > self.maxSp then
		self.Sp = self.maxSp;
	end
	w_battle_mgr.SpBallNum = w_battle_mgr.SpBallNum - 1
	if w_battle_mgr.SpBallNum < 0 then
		WriteCon("Error SpBallNum < 0");
	else
		WriteCon("SpBallNum ="..tostring(w_battle_mgr.SpBallNum));
	end
	w_battle_mgr.checkPickEnd();
end;

function p:SetOldPos()
	if self.oldPos ~= nil then
		local lNode = self:GetPlayerNode();
		lNode:SetCenterPos( self.oldPos);
	end;
end

function p:SaveOldPos(pos)
	self.oldPos = pos;
end