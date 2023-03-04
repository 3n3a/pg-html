create extension plpython3u;

drop function json_to_html;
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

        plpy.info(__name.lower())

        for k, v in kwargs.items():
            if len(v) > 0:
                g += " {}=\"{}\"".format(k.lower(), v.lower())
            else:
                g += " {}".format(k.lower())

        if len(args) > 0 or __name not in void_elements:
            g += ">"
            for el in args:
                if type(el) is dict:
                    g += tag(el['t'], *el['c'], **el['a'])
                else:
                    g += el
            g += "</{}>".format(__name.lower())
        else:
    # self-closing tags don't exist
            g += ">"
        return g

    attr = parse_attr(a)
    plpy.info(attr, type(attr))

    r = ""
    for el in attr:
        r += tag(el['t'], *el['c'], **el['a'])

    return r
$$ language plpython3u;


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

