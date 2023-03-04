---
--- PLPGSQL
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


---
--- PYTTHON
---

select json_to_html(
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
)

select json_to_html('[{"t":"!doctype","a":{"html":""},"c":[]},{"t":"html","a":{"lang":"en"},"c":[{"t":"head","a":{},"c":[{"t":"meta","a":{"charset":"UTF-8"},"c":[]},{"t":"meta","a":{"http-equiv":"X-UA-Compatible","content":"IE=edge"},"c":[]},{"t":"meta","a":{"name":"viewport","content":"width=device-width, initial-scale=1.0"},"c":[]},{"t":"title","a":{},"c":["Document"]}]},{"t":"body","a":{},"c": [{"t":"h1", "a": {}, "c": ["Document"]}]}]}]'::json)

---
--- TABLE TO HTML
---

explain (analyze, costs off, timing on)
select table_to_html('select id, name, capital, currency_name, region, subregion, latitude, longitude, created_at, updated_at from countries', 'Countries')
