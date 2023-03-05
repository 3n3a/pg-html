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

        if len(args) > 0 or __name not in void_elements:
            g += ">"

            # use parallel map, should speed up processing
            # https://superfastpython.com/multiprocessing-pool-map/
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
    #plpy.info(attr, type(attr))

    r = ""
    for el in attr:
        r += tag(el['t'], *el['c'], **el['a'])

    return r
$$ language plpython3u;