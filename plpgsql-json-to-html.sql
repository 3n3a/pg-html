
---
--- IMPLEMENTATION
---

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
        -- todo: direct child --> as text
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
        -- todo: void_elements
        html := html || '>';
    end if;

--    raise notice 'tag html: %', html;

    return html;
end;
$$ language plpgsql;


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

---
--- EXAMPLES
---
select json_to_html_pg(
    json_build_array(
        json_build_object(
            't', '!doctype',
            'a', json_build_object('html', ''),
            'c', json_build_array()
        ),
        json_build_object(
           't', 'body',
           'a', json_build_object(),
           'c', json_build_array(
                json_build_object(
                    't', 'h1',
                    'a', json_build_object(),
                    'c', json_build_array('test')
                )
           )
        )
    )
);

select json_to_html_pg('[{"t":"!doctype","a":{"html":""},"c":[]},{"t":"html","a":{"lang":"en"},"c":[{"t":"head","a":{},"c":[{"t":"meta","a":{"charset":"UTF-8"},"c":[]},{"t":"meta","a":{"http-equiv":"X-UA-Compatible","content":"IE=edge"},"c":[]},{"t":"meta","a":{"name":"viewport","content":"width=device-width, initial-scale=1.0"},"c":[]},{"t":"title","a":{},"c":["Document"]}]},{"t":"body","a":{},"c": [{"t":"h1", "a": {}, "c": ["Document"]}]}]}]'::json)
