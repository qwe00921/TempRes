--------------------------------------------------------------
-- FileName:    db_func.lua
-- author:      hst, 2013��7��25��
-- purpose:     ���ݿ⸨������
--------------------------------------------------------------

-------------------------------------
--��ѯ���¼
--@param {number}    tid          [no null]
--@param {string}    id           [no null]
--@return {obj}
-------------------------------------
function SelectRow( tid, id )
    return SelectRowInner( tid, "id", id );
end

-------------------------------------
--��ѯ���¼,����ָ���ֶ���
--@param {number}    tid            [no null]
--@param {string}    id             [no null]
--@param {string}    field          [no null]
--@return {cellValue}
-------------------------------------
function SelectCell( tid, id, field )
    return SelectRowInner( tid, "id", id, field );
end

-------------------------------------
--��ѯ���¼
--@param {number} tid           [no null]
--@param {string} idName        [no null]
--@param {string} idValue       [no null]
--@return {obj}
-------------------------------------
function SelectRowMatch( tid, idName, idValue )
    return SelectRowInner( tid, idName, idValue );
end

-------------------------------------
--��ѯ���¼
--@param {number} tid           [no null]
--@param {string} idName        [no null]
--@param {string} idValue       [no null]
--@param {string} field         [no null]
--@return {fieldValue}
-------------------------------------
function SelectCellMatch( tid, idName, idValue, field )
    return SelectRowInner( tid, idName, idValue, field );
end

function SelectRowInner( tid, idName, idValue, targetField )
    local t = GetTable( tid );
    if t == nil then
        WriteConErr( "get table failed" );
        return ;
    end

    --������
    local rowIndex = t:FindRow( idName, tostring( idValue ) );
    if rowIndex == -1 then
        return nil;
    end

    --��ȡ��Ӧ��¼
    local row = t:GetRow( rowIndex );
    local result = nil;

    if targetField == nil then
        --��ʽ���ɶ���
        local colCount = t:GetColCount();
        result = {};
        for i=1,colCount do
            local field = t:GetFieldName( i-1 );
            local val = row:GetStr( i-1 );
            if field ~= "" then
                result[ field ] = val;
            end
        end
    else
        result = row:GetStrByName( targetField );
    end

    return result;
end

-------------------------------------
--��ѯ���¼
--@param {number}    tid          [no null]
--@param {string}    key
--@param {string}    val
--@return {dataList}
-------------------------------------
function SelectRowList( tid, key, val )
    local t = GetTable(tid);
    if t == nil then
        WriteCon( "get table failed" );
        return;
    end
    local getAll = true;
    if key ~= nil and val ~= nil then
        getAll = false;
    end
    local val = tostring( val );
    local rowCount = t:GetRowCount();
    local result = {};
    for i = 1, rowCount do
        local row = t:GetRow(i-1);
        if not getAll then
            if row:GetStrByName(key) == val then
                result[#result+1] = FormatToObj( t, row);
            end
        else
            result[#result+1] = FormatToObj( t, row);
        end
    end
    --dump_obj( result );
    return result;
end

--��ʽ���Զ��󷵻�
function FormatToObj( t, row )
    local result = {};
    local colCount = t:GetColCount();
    for i=1,colCount do
        local field = t:GetFieldName( i-1 );
        local val = row:GetStr( i-1 );
        if field ~= "" then
            result[ field ] = val;
        end
    end
    return result;
end