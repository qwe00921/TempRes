

w_drop = {};
local p = w_drop;

E_DROP_HPBALL = 1;
E_DROP_SPBALL = 2;
E_DROP_MONEY = 3;
E_DROP_BLUESOUL = 4;
E_DROP_MATERIAL = 5;
E_DROP_CARD = 6;
E_DROP_EQUIP = 7;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	return o;
end

function p:ctor()
	self.parentNode = nil;
	self.imageNode = nil;
	self.nType = 0;
	self.param = nil;--掉落的为道具、卡片、装备时，具体的类型
	self.isInited = false;
end

function p:Init(parentNode,nType,param)
	self.parentNode = parentNode;
	self.nType = nType;
	if param ~= nil then
		self.param = param;
	end
	
	if not self.isInited then
		self:InitImageNode();
	end
	
	self.isInited = true;
end

function p:GetImageNode()
	return self.imageNode;
end

function p:GetType()
	return self.nType;
end

function p:InitImageNode()
	if self.imageNode == nil then
		self.imageNode = createNDUIImage();
		self.imageNode:Init();
		self.imageNode:SetFramePosXY(0,0);
		self.imageNode:SetFrameSize(W_BATTLE_DROP_H,W_BATTLE_DROP_H);
		self.imageNode:SetVisible( false );
	end
end

function p:Drop(pTargetNode, param)
	if self.parentNode == nil or pTargetNode == nil then
		return;
	end
	
	local imageData = nil;
	local effectName = nil;
	if self.nType == E_DROP_MONEY then
		imageData = GetPictureByAni( "w_drop.money", 0 );
		effectName = "w_drop.money_effect";
	elseif self.nType == E_DROP_BLUESOUL then
		imageData = GetPictureByAni( "w_drop.bluesoul", 0 );
		effectName = "w_drop.bluesoul_effect";
	elseif self.nType == E_DROP_HPBALL then
		imageData = GetPictureByAni( "w_drop.hpball", 0 );
		effectName = "w_drop.hpball_effect";
	elseif self.nType == E_DROP_SPBALL then
		imageData = GetPictureByAni( "w_drop.spball", 0 );
		effectName = "w_drop.spball_effect";
	elseif self.nType == E_DROP_MATERIAL then--掉落的为材料
		imageData = GetItemPic( param, G_ITEMTYPE_MATERIAL );
	elseif self.nType == E_DROP_CARD then
		imageData = GetItemPic( param, G_ITEMTYPE_CARD );
	elseif self.nType == E_DROP_EQUIP then
		imageData = GetItemPic( param, G_ITEMTYPE_EQUIP );
	end
	
	if imageData == nil then
		return;
	end
	
	if self.imageNode:GetParent() == nil then
		self.parentNode:AddChild( self.imageNode );
	end
	
	self.imageNode:SetPicture( imageData );
	if effectName then
		self.imageNode:AddFgEffect( effectName );
	end
	
	local point = pTargetNode:GetFramePos();
	local size = pTargetNode:GetFrameSize();
	self.imageNode:SetFramePosXY(point.x+size.w/2, point.y+size.h-W_BATTLE_DROP_H);
	self.imageNode:SetScale( 1.0f );
	self.imageNode:SetVisible( true );
	--local zorder = self.imageNode:GetZOrder();
	self.imageNode:SetZOrder( E_BATTLE_Z_BULLET );

	local cmd = battle_show.AddActionEffect_ToParallelSequence( 0 , self.imageNode , "lancer_cmb.monster_drop" );
	local varEnv = cmd:GetVarEnv();
	varEnv:SetFloat( "$1", math.random(-30, 30) );
	varEnv:SetFloat( "$2", math.random( -5, 5 ) );
	varEnv:SetFloat( "$3", math.random( 30, 50) );
	
	return cmd;
end

--拾取
function p:Pick( pTargetNode, pos )
	if pTargetNode == nil then
		return;
	end
	--self.imageNode:SetZOrder( E_BATTLE_TAG_ENEMY_FIGHTER + 7 );
	
	--local effectName = "lancer_cmb.pick_effect";
	local targetPoint = pTargetNode:GetFramePos();
	local targetSize = pTargetNode:GetFrameSize();
	local orignPoint = self.imageNode:GetFramePos();
	--local lscale = GetUIScale();
	
	local x = targetPoint.x - orignPoint.x + targetSize.w/2;
	local y = targetPoint.y - orignPoint.y + targetSize.h/2;

	--local cmd = battle_show.AddActionEffect_ToParallelSequence( 0 , self.imageNode , "lancer_cmb.pick_effect" );
	local cmd = createCommandEffect():AddActionEffect( 0, self.imageNode, "lancer_cmb.pick_effect" );
	local batch = w_battle_mgr.GetBattleBatch(); 
	local seqTemp = batch:AddSerialSequence();
	seqTemp:AddCommand( cmd );
	
	local varEnv = cmd:GetVarEnv();
	varEnv:SetFloat( "$1", x );
	varEnv:SetFloat( "$2", y );
	
	if pos ~= nil then
		local seqLua = batch:AddSerialSequence();
		local cmdLua = createCommandLua():SetCmd( "PickEnd", pos, self.nType, "" );
		if cmdLua ~= nil then
			seqLua:AddCommand( cmdLua );
		end
		seqLua:SetWaitEnd( cmd );
		if self.nType == E_DROP_HPBALL then
			w_battle_mgr.dropHpBall = w_battle_mgr.dropHpBall + 1
			WriteCon("drop.lua HpBallNum="..tostring(w_battle_mgr.dropHpBall))
		elseif self.nType == E_DROP_SPBALL then
			w_battle_mgr.dropSpBall = w_battle_mgr.dropSpBall + 1
			WriteCon("drop.lua SpBallNum="..tostring(w_battle_mgr.dropSpBall))
		end
	end

	return cmd;
end

function p:Remove()
	if self.imageNode ~= nil and self.imageNode:GetParent() ~= nil then
		self.imageNode:RemoveFromParent( true );
	end
	
	self.parentNode = nil;
	self.imageNode = nil;
	self.nType = 0;
	self.param = nil;--掉落的为道具、卡片、装备时，具体的类型
	self.isInited = false;
end
