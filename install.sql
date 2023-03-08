---
--- GENERATED BY SQL-BUILDER
--- PLEASE DO NOT EDIT DIRECTLY
--- CREATED AT Wed, 08 Mar 2023 18:09:52 +0100
---




---
--- FROM: plpgsql-json-to-html.sql ---
---


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

---
--- FROM: python3u-json-to-html.sql ---
---

create extension plpython3u;

drop function if exists json_to_html;
create or replace function json_to_html (a json)
    returns text
as $$
    void_elements = ["!doctype", "meta", "area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "param", "source", "track", "wbr"]

    def parse_attr(attr):
        import json
        return json.loads(attr)

    def tag(__name, *args, **kwargs):
        g = "<"
        g += __name.lower()

        #plpy.info(__name.lower())

        for k, v in kwargs.items():
            if len(v) > 0:
                g += " {}=\"{}\"".format(k.lower(), v.lower())
            else:
                g += " {}".format(k.lower())

        g += ">"
        if len(args) > 0 or __name not in void_elements:
            for el in args:
                if type(el) is dict:
                    g += tag(el['t'], *el['c'], **el['a'])
                else:
                    g += el
            g += "</{}>".format(__name.lower())
        return g

    attr = parse_attr(a)
    #plpy.info(attr, type(attr))

    r = ""
    for el in attr:
        r += tag(el['t'], *el['c'], **el['a'])

    return r
$$ language plpython3u;


---
--- FROM: table-to-html.sql ---
---

drop function if exists table_to_html;
create or replace function table_to_html(statement text, title text, standalone bool default true, stylesheet text default 'https://unpkg.com/@picocss/pico@1.*/css/pico.classless.min.css') returns text as
$$
DECLARE
    _table_json   json;
    _table_output json;
    _table_head   json;
    _table_body   json;
    _table_el     json;
    _table_el_k   text;
    _table_el_v   text;
    _table_tr     json;
begin
    execute 'select json_agg(t) from (' || statement || ') t'
        into _table_json;

    _table_body := json_build_array();
    _table_head := json_build_array();

    -- thead
    for _table_el_k, _table_el_v in select *
                                    from json_each_text(
                                            json_array_element(_table_json, 0)
                                        )
        loop
            _table_head := _table_head::jsonb || json_build_array(
                    json_build_object(
                            't', 'th',
                            'a', json_build_object(),
                            'c', json_build_array(_table_el_k)
                        )
                )::jsonb;
        end loop;

    -- tbody
    for _table_el in select * from json_array_elements(_table_json)
        loop
            _table_tr := json_build_array();
            -- reset

            -- loop through k,v pairs
            for _table_el_k, _table_el_v in select * from json_each_text(_table_el)
                loop
                    _table_tr := _table_tr::jsonb || json_build_array(
                            json_build_object(
                                    't', 'td',
                                    'a', json_build_object(),
                                    'c', json_build_array(_table_el_v)
                                )
                        )::jsonb;
                end loop;

            -- raise notice 'tr %', _table_tr::text;

            -- create table bodyj
            _table_body := _table_body::jsonb || json_build_array(json_build_object(
                    't', 'tr',
                    'a', json_build_object(),
                    'c', _table_tr
                ))::jsonb;
        end loop;

    _table_output := json_build_array(
            json_build_object(
                    't', 'table',
                    'a', json_build_object(),
                    'c', json_build_array(
                            json_build_object(
                                    't', 'thead',
                                    'a', json_build_object(),
                                    'c', json_build_array(
                                            json_build_object(
                                                    't', 'tr',
                                                    'a', json_build_object(),
                                                    'c', _table_head
                                                )
                                        )
                                ),
                            json_build_object(
                                    't', 'tbody',
                                    'a', json_build_object(),
                                    'c', _table_body
                                )
                        )
                )
        );

    if standalone then
        -- put table into fully compliant html file (vscode template)
        _table_output := json_build_array(
                json_build_object('t', '!doctype', 'a', json_build_object('html', ''), 'c', json_build_array()),
                json_build_object('t', 'html', 'a', json_build_object('lang', 'en'), 'c',
                                  json_build_array(json_build_object('t', 'head', 'a', json_build_object(), 'c',
                                                                     json_build_array(json_build_object('t', 'meta',
                                                                                                        'a',
                                                                                                        json_build_object('charset', 'UTF-8'),
                                                                                                        'c',
                                                                                                        json_build_array()),
                                                                                      json_build_object('t', 'meta',
                                                                                                        'a',
                                                                                                        json_build_object(
                                                                                                                'http-equiv',
                                                                                                                'X-UA-Compatible',
                                                                                                                'content',
                                                                                                                'IE=edge'),
                                                                                                        'c',
                                                                                                        json_build_array()),
                                                                                      json_build_object(
                                                                                          't', 'link',
                                                                                          'a', json_build_object(
                                                                                              'rel', 'stylesheet',
                                                                                              'href', stylesheet
                                                                                              ),
                                                                                          'c', json_build_array()
                                                                                          ),
                                                                                      json_build_object('t', 'meta',
                                                                                                        'a',
                                                                                                        json_build_object(
                                                                                                                'name',
                                                                                                                'viewport',
                                                                                                                'content',
                                                                                                                'width=device-width, initial-scale=1.0'),
                                                                                                        'c',
                                                                                                        json_build_array()),
                                                                                      json_build_object('t', 'title',
                                                                                                        'a',
                                                                                                        json_build_object(),
                                                                                                        'c',
                                                                                                        json_build_array(title)))),
                                                   json_build_object('t', 'body', 'a', json_build_object(), 'c',
                                                                     json_build_array(
                                                                         json_build_object(
                                                                             't', 'main',
                                                                             'a', json_build_object(
                                                                                'style', 'overflow: auto;'
                                                                             ),
                                                                             'c', json_build_array(
                                                                                 json_build_object('t', 'h1', 'a',
                                                                                                        json_build_object(),
                                                                                                        'c',
                                                                                                        json_build_array(title))
                                                                         , json_build_object(
                                                                             't', 'div',
                                                                             'a', json_build_object(),
                                                                             'c', _table_output
                                                                                          )
                                                                                 )
                                                                             )
                                                                         )))));
    end if;

    return json_to_html(_table_output);
end;
$$ language plpgsql;

---
--- FROM: table-to-html-pg.sql ---
---

drop function if exists table_to_html_pg;
create or replace function table_to_html_pg(statement text, title text, standalone bool default true, stylesheet text default 'https://unpkg.com/@picocss/pico@1.*/css/pico.classless.min.css') returns text as
$$
DECLARE
    _table_json   json;
    _table_output json;
    _table_head   json;
    _table_body   json;
    _table_el     json;
    _table_el_k   text;
    _table_el_v   text;
    _table_tr     json;
begin
    execute 'select json_agg(t) from (' || statement || ') t'
        into _table_json;

    _table_body := json_build_array();
    _table_head := json_build_array();

    -- thead
    for _table_el_k, _table_el_v in select *
                                    from json_each_text(
                                            json_array_element(_table_json, 0)
                                        )
        loop
            _table_head := _table_head::jsonb || json_build_array(
                    json_build_object(
                            't', 'th',
                            'a', json_build_object(),
                            'c', json_build_array(_table_el_k)
                        )
                )::jsonb;
        end loop;

    -- tbody
    for _table_el in select * from json_array_elements(_table_json)
        loop
            _table_tr := json_build_array();
            -- reset

            -- loop through k,v pairs
            for _table_el_k, _table_el_v in select * from json_each_text(_table_el)
                loop
                    _table_tr := _table_tr::jsonb || json_build_array(
                            json_build_object(
                                    't', 'td',
                                    'a', json_build_object(),
                                    'c', json_build_array(_table_el_v)
                                )
                        )::jsonb;
                end loop;

            -- raise notice 'tr %', _table_tr::text;

            -- create table bodyj
            _table_body := _table_body::jsonb || json_build_array(json_build_object(
                    't', 'tr',
                    'a', json_build_object(),
                    'c', _table_tr
                ))::jsonb;
        end loop;

    _table_output := json_build_array(
            json_build_object(
                    't', 'table',
                    'a', json_build_object(),
                    'c', json_build_array(
                            json_build_object(
                                    't', 'thead',
                                    'a', json_build_object(),
                                    'c', json_build_array(
                                            json_build_object(
                                                    't', 'tr',
                                                    'a', json_build_object(),
                                                    'c', _table_head
                                                )
                                        )
                                ),
                            json_build_object(
                                    't', 'tbody',
                                    'a', json_build_object(),
                                    'c', _table_body
                                )
                        )
                )
        );

    if standalone then
        -- put table into fully compliant html file (vscode template)
        _table_output := json_build_array(
                json_build_object('t', '!doctype', 'a', json_build_object('html', ''), 'c', json_build_array()),
                json_build_object('t', 'html', 'a', json_build_object('lang', 'en'), 'c',
                                  json_build_array(json_build_object('t', 'head', 'a', json_build_object(), 'c',
                                                                     json_build_array(json_build_object('t', 'meta',
                                                                                                        'a',
                                                                                                        json_build_object('charset', 'UTF-8'),
                                                                                                        'c',
                                                                                                        json_build_array()),
                                                                                      json_build_object('t', 'meta',
                                                                                                        'a',
                                                                                                        json_build_object(
                                                                                                                'http-equiv',
                                                                                                                'X-UA-Compatible',
                                                                                                                'content',
                                                                                                                'IE=edge'),
                                                                                                        'c',
                                                                                                        json_build_array()),
                                                                                      json_build_object(
                                                                                          't', 'link',
                                                                                          'a', json_build_object(
                                                                                              'rel', 'stylesheet',
                                                                                              'href', stylesheet
                                                                                              ),
                                                                                          'c', json_build_array()
                                                                                          ),
                                                                                      json_build_object('t', 'meta',
                                                                                                        'a',
                                                                                                        json_build_object(
                                                                                                                'name',
                                                                                                                'viewport',
                                                                                                                'content',
                                                                                                                'width=device-width, initial-scale=1.0'),
                                                                                                        'c',
                                                                                                        json_build_array()),
                                                                                      json_build_object('t', 'title',
                                                                                                        'a',
                                                                                                        json_build_object(),
                                                                                                        'c',
                                                                                                        json_build_array(title)))),
                                                   json_build_object('t', 'body', 'a', json_build_object(), 'c',
                                                                     json_build_array(
                                                                         json_build_object(
                                                                             't', 'main',
                                                                             'a', json_build_object(
                                                                                'style', 'overflow: auto;'
                                                                             ),
                                                                             'c', json_build_array(
                                                                                 json_build_object('t', 'h1', 'a',
                                                                                                        json_build_object(),
                                                                                                        'c',
                                                                                                        json_build_array(title))
                                                                         , json_build_object(
                                                                             't', 'div',
                                                                             'a', json_build_object(),
                                                                             'c', _table_output
                                                                                          )
                                                                                 )
                                                                             )
                                                                         )))));
    end if;

    return json_to_html_pg(_table_output);
end;
$$ language plpgsql;