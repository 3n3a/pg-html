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