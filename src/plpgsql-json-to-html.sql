
---
--- IMPLEMENTATION
---

drop function if exists html_tag;
create or replace function html_tag (name text, attr json, children json) returns text as
$$
DECLARE
    html text;
    _tag_name text;
    _k text;
    _v text;
    _child json;
    _child_text text;
    _void_elements text[] = ARRAY['!doctype', 'meta', 'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'param', 'source', 'track', 'wbr'];
begin
    _tag_name := lower(trim('"' FROM name::text));
    html := '<' || _tag_name;
    for _k, _v in
        select * from json_each_text(attr)
    loop
        _k := lower(trim('"' FROM _k::text));
        _v := lower(trim('"' FROM _v::text));
        if length(_v) > 0 then
            html := html || ' ' || _k || '="' || _v || '"';
        else
            html := html || ' ' || _k;
        end if;
        -- raise notice 'tag attr: k %, v %', _k, _v;
    end loop;

    if json_array_length(children) > 0 or
       array_length(array_positions(_void_elements, _tag_name), 1) IS NULL -- test if _tag_name is NOT contained in
    then
        html := html || '>';
        for _child in
            select * from json_array_elements(children)
        loop
            if json_typeof(_child) = 'object' then
                html := html || (select html_tag(cast(_child->'t' as text), _child->'a', _child->'c'));
            elseif json_typeof(_child) = 'string' then
                _child_text := trim('"' FROM _child::text);
                html := html || _child_text;
            end if;
        end loop;
        html := html || '</' || _tag_name || '>';
    else
        html := html || '>';
    end if;

--    raise notice 'tag html: %', html;

    return html;
end;
$$ language plpgsql;

drop function if exists json_to_html_pg;
create or replace function json_to_html_pg (a json) returns text as
$$
declare
    html text;
    tag_json json;
begin
    for tag_json in
        select * from json_array_elements(a)
    loop
        html := coalesce(html, '') || (select html_tag(cast(tag_json->'t' as text), tag_json->'a', tag_json->'c'));
    end loop;

    raise notice 'html: %', html;

    return html;
end;
$$ language plpgsql;