--
-- JSON_DYN  (Package Body) 
--
CREATE OR REPLACE package body      json_dyn as
/*
  -- 11gR2 
  function executeList(stmt in out sys_refcursor) return json_list as
    l_cur number;
  begin
    l_cur := dbms_sql.to_cursor_number(stmt);
    return json_dyn.executeList(null, null, l_cur);
  end;

  -- 11gR2 
  function executeObject(stmt in out sys_refcursor) return json as
    l_cur number;
  begin
    l_cur := dbms_sql.to_cursor_number(stmt);
    return json_dyn.executeObject(null, null, l_cur);
  end;
*/

 FUNCTION escapestring_clob (p_clob CLOB)
      RETURN CLOB
   AS
      sb               CLOB := '';
      buf              VARCHAR2 (40);
      ascii_output     BOOLEAN := TRUE;
      escape_solidus   BOOLEAN := FALSE;
   BEGIN
      DBMS_LOB.createtemporary (sb, TRUE);

      IF (p_clob IS NULL)
      THEN
         RETURN '';
      END IF;

      FOR i IN 1 .. LENGTH (p_clob)
      LOOP
         /*buf   :=  SUBSTR (str
                  , i
                  , 1);*/

         buf         := DBMS_LOB.SUBSTR (p_clob, 1, i);

         --backspace b = U+0008
         --formfeed  f = U+000C
         --newline   n = U+000A
         --carret    r = U+000D
         --tabulator t = U+0009
         CASE buf
            WHEN CHR (8)
            THEN
               buf         := '\b';
            WHEN CHR (9)
            THEN
               buf         := '\t';
            WHEN CHR (10)
            THEN
               buf         := '\n';
            WHEN CHR (13)
            THEN
               buf         := '\f';
            WHEN CHR (14)
            THEN
               buf         := '\r';
           /* Quotes are escaped by xml convert  
           WHEN CHR (34)
            THEN
               buf         := '\"';*/
            WHEN CHR (47)
            THEN
               IF (escape_solidus)
               THEN
                  buf         := '\/';
               END IF;
            WHEN CHR (92)
            THEN
               buf         := '\\';
            ELSE
               IF (ASCII (buf) < 32)
               THEN
                  buf         :=
                     '\u' || REPLACE (SUBSTR (TO_CHAR (ASCII (buf), 'XXXX'), 2, 4), ' ', '0');
               ELSIF (ascii_output)
               THEN
                  buf         := REPLACE (ASCIISTR (buf), '\', '\u');
               END IF;
         END CASE;

         DBMS_LOB.append (sb, buf);
      END LOOP;
      
      --Scape XML content
      sb := DBMS_XMLGEN.CONVERT (sb, 0);
      
      RETURN sb;
   END escapestring_clob;

  procedure bind_json(l_cur number, bindvar json) as
    keylist json_list := bindvar.get_keys();
  begin
    for i in 1 .. keylist.count loop
      if(bindvar.get(i).get_type = 'number') then
        dbms_sql.bind_variable(l_cur, ':'||keylist.get(i).get_string, bindvar.get(i).get_number);
      elsif(bindvar.get(i).get_type = 'array') then
        declare
          v_bind dbms_sql.varchar2_table;
          v_arr  json_list := json_list(bindvar.get(i));
        begin
          for j in 1 .. v_arr.count loop
            v_bind(j) := v_arr.get(j).value_of;
          end loop;
          dbms_sql.bind_array(l_cur, ':'||keylist.get(i).get_string, v_bind);
        end;
      else
        dbms_sql.bind_variable(l_cur, ':'||keylist.get(i).get_string, bindvar.get(i).value_of());
      end if;
    end loop;
  end bind_json;

  /* list with objects */
  function executeList(stmt varchar2, bindvar json, cur_num number) return json_list as
    l_cur number;
    l_dtbl dbms_sql.desc_tab;
    l_cnt number;
    l_status number;
    l_val varchar2(32767);
    outer_list json_list := json_list();
    inner_obj json;
    conv number;
    read_date date;
    read_clob clob;
    read_blob blob;
    col_type number;
  begin
    if(cur_num is not null) then 
      l_cur := cur_num; 
    else
      l_cur := dbms_sql.open_cursor;
      dbms_sql.parse(l_cur, stmt, dbms_sql.native);
      if(bindvar is not null) then bind_json(l_cur, bindvar); end if;
    end if;
    dbms_sql.describe_columns(l_cur, l_cnt, l_dtbl);
    for i in 1..l_cnt loop
      col_type := l_dtbl(i).col_type;
      --dbms_output.put_line(col_type);
      if(col_type = 12) then
        dbms_sql.define_column(l_cur,i,read_date);
      elsif(col_type = 112) then
        dbms_sql.define_column(l_cur,i,read_clob);
      elsif(col_type = 113) then
        dbms_sql.define_column(l_cur,i,read_blob);
      elsif(col_type in (1,2,96)) then
        dbms_sql.define_column(l_cur,i,l_val,4000);
      end if;
    end loop;
    
    if(cur_num is null) then l_status := dbms_sql.execute(l_cur); end if;
    
    --loop through rows 
    while ( dbms_sql.fetch_rows(l_cur) > 0 ) loop
      inner_obj := json(); --init for each row
      --loop through columns
      for i in 1..l_cnt loop
        case true
        --handling string types
        when l_dtbl(i).col_type in (1,96) then -- varchar2
          dbms_sql.column_value(l_cur,i,l_val);
          if(l_val is null) then
            if(null_as_empty_string) then 
              inner_obj.put(l_dtbl(i).col_name, ''); --treatet as emptystring?
            else 
              inner_obj.put(l_dtbl(i).col_name, json_value.makenull); --null
            end if;
          else
            inner_obj.put(l_dtbl(i).col_name, json_value(l_val)); --null
          end if;
          --dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'varchar2' ||l_dtbl(i).col_type);
        --handling number types
        when l_dtbl(i).col_type = 2 then -- number
          dbms_sql.column_value(l_cur,i,l_val);
          conv := l_val;
          inner_obj.put(l_dtbl(i).col_name, conv);
          -- dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'number ' ||l_dtbl(i).col_type);
        when l_dtbl(i).col_type = 12 then -- date
          if(include_dates) then
            dbms_sql.column_value(l_cur,i,read_date);
            inner_obj.put(l_dtbl(i).col_name, json_ext.to_json_value(read_date));
          end if;
          --dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'date ' ||l_dtbl(i).col_type);
        when l_dtbl(i).col_type = 112 then --clob
          if(include_clobs) then
            dbms_sql.column_value(l_cur,i,read_clob);
            inner_obj.put(l_dtbl(i).col_name, json_value(read_clob));
          end if;
        when l_dtbl(i).col_type = 113 then --blob
          if(include_blobs) then
            dbms_sql.column_value(l_cur,i,read_blob);
            if(dbms_lob.getlength(read_blob) > 0) then
              inner_obj.put(l_dtbl(i).col_name, json_ext.encode(read_blob));
            else
              inner_obj.put(l_dtbl(i).col_name, json_value.makenull);
            end if;
          end if;
        
        else null; --discard other types
        end case;
      end loop;
      outer_list.append(inner_obj.to_json_value);
    end loop;
    dbms_sql.close_cursor(l_cur);
    return outer_list;
  end executeList;

  /* object with lists */
  function executeObject(stmt varchar2, bindvar json, cur_num number) return json as
    l_cur number;
    l_dtbl dbms_sql.desc_tab;
    l_cnt number;
    l_status number;
    l_val varchar2(4000);
    inner_list_names json_list := json_list();
    inner_list_data json_list := json_list();
    data_list json_list;
    outer_obj json := json();
    conv number;
    read_date date;
    read_clob clob;
    read_blob blob;
    col_type number;
  begin
    if(cur_num is not null) then 
      l_cur := cur_num; 
    else
      l_cur := dbms_sql.open_cursor;
      dbms_sql.parse(l_cur, stmt, dbms_sql.native);
      if(bindvar is not null) then bind_json(l_cur, bindvar); end if;
    end if;
    dbms_sql.describe_columns(l_cur, l_cnt, l_dtbl);
    for i in 1..l_cnt loop
      col_type := l_dtbl(i).col_type;
      if(col_type = 12) then
        dbms_sql.define_column(l_cur,i,read_date);
      elsif(col_type = 112) then
        dbms_sql.define_column(l_cur,i,read_clob);
      elsif(col_type = 113) then
        dbms_sql.define_column(l_cur,i,read_blob);
      elsif(col_type in (1,2,96)) then
        dbms_sql.define_column(l_cur,i,l_val,4000);
      else
        dbms_sql.define_column(l_cur,i,l_val,4000);
      end if;
    end loop;
    if(cur_num is null) then l_status := dbms_sql.execute(l_cur); end if;
    
    --build up name_list
    for i in 1..l_cnt loop
      case l_dtbl(i).col_type
        when 1 then inner_list_names.append(l_dtbl(i).col_name);
        when 96 then inner_list_names.append(l_dtbl(i).col_name);
        when 2 then inner_list_names.append(l_dtbl(i).col_name);
        when 12 then if(include_dates) then inner_list_names.append(l_dtbl(i).col_name); end if;
        when 112 then if(include_clobs) then inner_list_names.append(l_dtbl(i).col_name); end if;
        when 113 then if(include_blobs) then inner_list_names.append(l_dtbl(i).col_name); end if;
        else null;
      end case;
    end loop;

    --loop through rows 
    while ( dbms_sql.fetch_rows(l_cur) > 0 ) loop
      data_list := json_list();
      --loop through columns
      for i in 1..l_cnt loop
        case true 
        --handling string types
        when l_dtbl(i).col_type in (1,96) then -- varchar2
          dbms_sql.column_value(l_cur,i,l_val);
          if(l_val is null) then
            if(null_as_empty_string) then 
              data_list.append(''); --treatet as emptystring?
            else 
              data_list.append(json_value.makenull); --null
            end if;
          else
            data_list.append(json_value(l_val)); --null
          end if;
          --dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'varchar2' ||l_dtbl(i).col_type);
        --handling number types
        when l_dtbl(i).col_type = 2 then -- number
          dbms_sql.column_value(l_cur,i,l_val);
          conv := l_val;
          data_list.append(conv);
          -- dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'number ' ||l_dtbl(i).col_type);
        when l_dtbl(i).col_type = 12 then -- date
          if(include_dates) then
            dbms_sql.column_value(l_cur,i,read_date);
            data_list.append(json_ext.to_json_value(read_date));
          end if;
          --dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'date ' ||l_dtbl(i).col_type);
        when l_dtbl(i).col_type = 112 then --clob
          if(include_clobs) then
            dbms_sql.column_value(l_cur,i,read_clob);
             if(dbms_lob.getlength(read_clob) > 0) then
              if (dbms_lob.getlength(read_clob) > 32730) --Tunc CLOB to 32730 chars
              then 
                data_list.append(dbms_lob.substr(read_clob,32730,1) || '...<b>The text has been truncated</b>' );
              else
                data_list.append(read_clob );
              end if;
            else 
              data_list.append(json_value.makenull);
            end if;
          end if;
        when l_dtbl(i).col_type = 113 then --blob
          if(include_blobs) then
            dbms_sql.column_value(l_cur,i,read_blob);
            if(dbms_lob.getlength(read_blob) > 0) then
              data_list.append(json_ext.encode(read_blob));
            else 
              data_list.append(json_value.makenull);
            end if; 
          end if;
        
        --else null; --discard other types
        else --all other types as string
        dbms_sql.column_value(l_cur,i,l_val);
          if(l_val is null) then
            if(null_as_empty_string) then 
              data_list.append(''); --treatet as emptystring?
            else 
              data_list.append(json_value.makenull); --null
            end if;
          else
            data_list.append(json_value(l_val)); --null
          end if;
          
        end case;
      end loop;
      inner_list_data.append(data_list);
    end loop;
    
    outer_obj.put('names', inner_list_names.to_json_value);
    outer_obj.put('data', inner_list_data.to_json_value);
    dbms_sql.close_cursor(l_cur);
    return outer_obj;
  end executeObject;


    /* Dynamic SQL Statement DBMS_SQL*/
    FUNCTION executedynsql (stmt CLOB, bindvar json DEFAULT NULL )
       RETURN NUMBER
    AS
       l_cur            INTEGER;
       rows_processed   INTEGER;
    BEGIN
       l_cur       := DBMS_SQL.open_cursor;
       DBMS_SQL.parse (l_cur, stmt, DBMS_SQL.native);

       IF (bindvar IS NOT NULL)
       THEN
          bind_json (l_cur, bindvar);
       END IF;

       rows_processed := DBMS_SQL.execute (l_cur);
       DBMS_SQL.close_cursor (l_cur);

       RETURN rows_processed;
    END;

end json_dyn;
/


