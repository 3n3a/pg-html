---
--- COMPARE THE FOLLOWING TWO FUNCTIONS FOR EQUALITY
--- the data input is equal!
---

------ when not receiving a response --> everything equal and ok
do $$
BEGIN
    assert (select json_to_html_pg('[{"t":"!doctype","a":{"html":""},"c":[]},{"t":"html","a":{"lang":"en"},"c":[{"t":"head","a":{},"c":[{"t":"meta","a":{"charset":"UTF-8"},"c":[]},{"t":"meta","a":{"http-equiv":"X-UA-Compatible","content":"IE=edge"},"c":[]},{"t":"meta","a":{"name":"viewport","content":"width=device-width, initial-scale=1.0"},"c":[]},{"t":"title","a":{},"c":["Document"]}]},{"t":"body","a":{},"c": [{"t":"h1", "a": {}, "c": ["Document"]}]}]}]'::json))
        =
    (select json_to_html('[{"t":"!doctype","a":{"html":""},"c":[]},{"t":"html","a":{"lang":"en"},"c":[{"t":"head","a":{},"c":[{"t":"meta","a":{"charset":"UTF-8"},"c":[]},{"t":"meta","a":{"http-equiv":"X-UA-Compatible","content":"IE=edge"},"c":[]},{"t":"meta","a":{"name":"viewport","content":"width=device-width, initial-scale=1.0"},"c":[]},{"t":"title","a":{},"c":["Document"]}]},{"t":"body","a":{},"c": [{"t":"h1", "a": {}, "c": ["Document"]}]}]}]'::json))
    , 'The generated html is not equal!';
end;
$$;

---
--- BENCHMARKING FUNCTIONS EXECUTION TIME
---

---- PGSQL
explain (analyze, costs off, timing on)
select json_to_html_pg('[{"t":"!doctype","a":{"html":""},"c":[]},{"t":"html","a":{"lang":"en"},"c":[{"t":"head","a":{},"c":[{"t":"meta","a":{"charset":"UTF-8"},"c":[]},{"t":"meta","a":{"http-equiv":"X-UA-Compatible","content":"IE=edge"},"c":[]},{"t":"meta","a":{"name":"viewport","content":"width=device-width, initial-scale=1.0"},"c":[]},{"t":"title","a":{},"c":["Document"]}]},{"t":"body","a":{},"c": [{"t":"h1", "a": {}, "c": ["Document"]}]}]}]'::json)
;


---- PYTHON
explain (analyze, costs off, timing on)
select json_to_html('[{"t":"!doctype","a":{"html":""},"c":[]},{"t":"html","a":{"lang":"en"},"c":[{"t":"head","a":{},"c":[{"t":"meta","a":{"charset":"UTF-8"},"c":[]},{"t":"meta","a":{"http-equiv":"X-UA-Compatible","content":"IE=edge"},"c":[]},{"t":"meta","a":{"name":"viewport","content":"width=device-width, initial-scale=1.0"},"c":[]},{"t":"title","a":{},"c":["Document"]}]},{"t":"body","a":{},"c": [{"t":"h1", "a": {}, "c": ["Document"]}]}]}]'::json)
;

---
--- BENCHMARK RESULTS  ---
---
--- see the BENCH.md file
