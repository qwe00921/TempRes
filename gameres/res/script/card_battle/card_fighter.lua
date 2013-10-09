--------------------------------------------------------------
-- FileName: 	card_fighter.lua
-- BaseClass:   fighter
-- author:		zhangwq, 2013/08/14
-- purpose:		卡牌战斗：战士类（多实例）
--------------------------------------------------------------

card_fighter = fighter:new();
local p = card_fighter;
local super = fighter;

--创建新实例
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
    super.ctor(self);
	self.skillbar = nil;
	self.skillnum = nil;
	self.UseConfig = nil;
end

--初始化（重载）
function p:Init( idFighter, node, camp )
	super.Init( self, idFighter, node, camp );
	--self.hpbar:GetNode():SetVisible( false );
	self.tmplife = self.life;
	self:CreateSkillBar();
end

function p:CreateSkillBar()
	if self.skillbar == nil then
	    self.skillnum = math.random( 1, 4 );
        local skillbar = createNDUIImage();
        skillbar:Init();
        
        local pic = GetPictureByAni("card_battle.skill_num", self.skillnum - 1); 
        skillbar:SetPicture( pic );
        
        local pos = self.hpbar.node:GetFramePos();
        skillbar:SetFramePosXY(pos.x + UIOffsetX(13), pos.y + UIOffsetY(8));
        skillbar:ResizeToFitPicture();
        self.node:AddChildZ( skillbar, 2 );
        self.skillbar = skillbar;
    end 
end

--创建血条
function p:CreateHpBar()
	if self.hpbar == nil then
		self.hpbar = card_hp_bar:new();
		self.hpbar:CreateExpNode();
		self.node:AddChildZ( self.hpbar:GetNode(), -1 );
		self.hpbar:Init( self.node, self.life, self.lifeMax );
	end	
end

--临时生命值
function p:SetTmpLife()         self.tmplife = self.life; end
function p:CheckTmpLife() 		return self.tmplife > 0; end
function p:SubTmpLife( val ) 	self.tmplife = self.tmplife - val; end

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

--获取战士前方坐标
function p:GetFrontPos(targetNode)
	local frontPos = self:GetNode():GetCenterPos();
	local halfWidthSum = self:GetNode():GetCurAnimRealSize().w/2 + targetNode:GetCurAnimRealSize().w/2;
	
	if self.camp == E_CARD_CAMP_HERO then
		frontPos.x = frontPos.x + halfWidthSum;
	else
		frontPos.x = frontPos.x - halfWidthSum;
	end
	return frontPos;
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

--添加lua命令
function p:cmdLua( cmdtype, num, str, seq )
	--暂时临时扣血保存到tmplife
	if cmdtype == "fighter_damage" then
		self:SubTmpLife( num );	
	end
	return super.cmdLua( self, cmdtype, num, str, seq );
end


