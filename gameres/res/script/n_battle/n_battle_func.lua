--------------------------------------------------------------
-- FileName:    n_battle_func.lua
-- author:      hst, 2013��12��13��
-- purpose:     ��ս��������
--------------------------------------------------------------

--ͨ��BUFF TYPE ��ȡANI
function GetBuffAniByType( buffType )
    if buffType == nil then
    	return nil;
    end
    return "n_battle_buff.buff_type_"..buffType;
    --[[
    if buffType == N_BUFF_TYPE_1 then --��ѣ����
    elseif buffType == N_BUFF_TYPE_2 then--����
    elseif buffType == N_BUFF_TYPE_3 then--����
    elseif buffType == N_BUFF_TYPE_4 then--�ж�
    elseif buffType == N_BUFF_TYPE_5 then--ȼ��
    elseif buffType == N_BUFF_TYPE_9 then--�ָ�
    elseif buffType == N_BUFF_TYPE_101 then--������ǿ
    elseif buffType == N_BUFF_TYPE_102 then--������ǿ
    elseif buffType == N_BUFF_TYPE_103 then--������ǿ
    elseif buffType == N_BUFF_TYPE_201 then--��������
    elseif buffType == N_BUFF_TYPE_202 then--��������
    elseif buffType == N_BUFF_TYPE_203 then--��������
    end
    --]]
end

-------------------------------------
--�Ƿ�Ϊȫ�幥�� 
--�жϱ�׼��Ŀ������Ϊ���з�Ⱥ�壬�з�ֱ�ߣ�����Ⱥ��   ��Ϊȫ�幥��������Ϊ���幥��
-------------------------------------
function IsAoeSkillByType( targetType )
    if targetType == nil then
    	return false;
    elseif targetType == N_SKILL_TARGET_TYPE_2 or targetType == N_SKILL_TARGET_TYPE_3 or targetType == N_SKILL_TARGET_TYPE_12 then	
        return true;
    else
        return false;   
    end
end

--սʿ��һ������Ծ����һ����
function JumpMoveTo(atkFighter, fPos, tPos, pJumpSeq)
    local fx = "lancer_cmb.begin_battle_jump";
    
    local atkPos = fPos;
    
    local x = tPos.x - atkPos.x;
    local y = tPos.y - atkPos.y;
    local distance = (x ^ 2 + y ^ 2) ^ 0.75;
    
    -- calc start offset
    local startOffset = 0;
    local offsetX = x * startOffset / distance;
    local offsetY = y * startOffset / distance;
    --local pPos = CCPointMake(atkPos.x + offsetX, atkPos.y + offsetY );

    --self.pOriginPos = CCPointMake(targetPos.x,targetPos.y);

    local pCmd = battle_show.AddActionEffect_ToSequence( 0, atkFighter:GetPlayerNode(), fx,pJumpSeq);
    
    local varEnv = pCmd:GetVarEnv();
    varEnv:SetFloat( "$1", x );
    varEnv:SetFloat( "$2", y );
    varEnv:SetFloat( "$3", 75 );
    
    return pCmd;
end

--��ȡλ��ֵ��С��սʿǰ�������
function GetBestTargetPos( Hero, TCamp, Targets )
	if Targets == nil or Hero == nil or TCamp == nil then
		return nil;
	end
	local tempPosId;
	local figther;
	for key, var in ipairs(Targets) do
		local pos = tonumber( var.TPos );
		if tempPosId == nil then
		  tempPosId = pos;
		elseif tempPosId > pos then
		  tempPosId = pos;
		end
	end
	if tempPosId ~= nil then
		if TCamp == E_CARD_CAMP_HERO then
            figther = n_battle_mgr.heroCamp:FindFighter( tempPosId );
        elseif TCamp == E_CARD_CAMP_ENEMY then
            figther = n_battle_mgr.enemyCamp:FindFighter( tempPosId + N_BATTLE_CAMP_CARD_NUM );
        end
	end
	return figther:GetFrontPos( Hero:GetPlayerNode() );
end

--�ܻ����������������վ������
function HurtResultAni( targetFighter, seqTarget )
    if targetFighter:CheckTmpLife() then
        --local cmdA = createCommandPlayer():Standby( 0, targetFighter:GetNode(), "" );
        --seqTarget:AddCommand( cmdA );
    else
        --local cmdB = createCommandPlayer():Dead( 0, targetFighter:GetNode(), "" );
        --seqTarget:AddCommand( cmdB );   
        
        local cmdC = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer_cmb.die_v2" );
        seqTarget:AddCommand( cmdC );
    end
end

function IsSkillTargetSelfCamp( targetType )
	if targetType == nil then
		return false;
	end
	if targetType == N_SKILL_TARGET_TYPE_11 or targetType == N_SKILL_TARGET_TYPE_12 or targetType == N_SKILL_TARGET_TYPE_13 then
		return true;
	else
	   return false;	
	end
end

function AddBuffIcon( target, buffType )
    if target == nil or buffType == nil then
    	return false;
    end
	local ln = #target.buffList;
	local isIn = false;
	for i=1, ln do
		local v = target.buffList[i];
		if tonumber( v ) == tonumber( buffType ) then
			isIn = true;
		end
	end
	if not isIn then
		target.buffList[ #target.buffList + 1 ] = buffType;
	end
end

function DelBuffIcon( target, buffType )
    if target == nil or buffType == nil then
        return false;
    end
    for key, var in ipairs(target.buffList) do
        if tonumber( var ) == tonumber( buffType ) then
            table.remove( target.buffList, key);
        end
    end
end





