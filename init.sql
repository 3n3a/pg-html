-- the python extension for programming the conversion
create extension plpython3u;

-- the function that does the magic
drop function json_to_html;
create or replace function json_to_html (a json)
    returns text
as $$
    void_elements = ["!doctype", "meta"]
    non_void_elements = ["body", "head", "h1", "h2", "h3"] # expand list

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

        if len(args) > 0 or __name in non_void_elements:
            g += ">"
            for el in args:
                if type(el) is dict:
                    g += tag(el['t'], *el['c'], **el['a'])
                else:
                    g += el
            g += "</{}>".format(__name.lower())
        else:
            if __name in void_elements:
                g += ">"
            else:
                g += "/>"
        return g

    attr = parse_attr(a)
    plpy.info(attr, type(attr))

    r = ""
    for el in attr:
        r += tag(el['t'], *el['c'], **el['a'])

    return r
$$ language plpython3u;

-- usage example
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
