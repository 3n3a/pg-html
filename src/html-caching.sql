drop table if exists html_cache;
create table html_cache (
	hash text NOT NULL,
	content text NOT NULL,
    created_at timestamp NOT NULL,
	primary key (hash)
);

drop function if exists add_to_html_cache;
create or replace function add_to_html_cache(_q text, _content text) returns bool as
$$
declare
	_hash text;
begin
	-- how do i know when result-set is new??
	_hash := md5( _q )::text;
	insert into html_cache (hash, content, created_at) values (_hash, _content, NOW()) ON CONFLICT (hash) DO UPDATE 
    SET created_at = NOW(),
        content = EXCLUDED.content;
	return true;
end
$$ language plpgsql;


-- gets the html for a table from cache || create it
-- cache is stale after 1 hour
drop function if exists get_from_cache_or_compute;
create or replace function get_from_cache_or_compute(_q text, _name text) returns text as
$$
declare
	_content text;
	_exists bool;
    _is_recent bool;
	_hash text;
begin
	_hash := md5( _q )::text;
	select exists(select 1 from html_cache where hash = _hash) into _exists;

    if _exists then
        -- test if was created less than one hour ago
        select age(now(), created_at) < age(now() + interval '1 hours', now()) from html_cache where hash = _hash into _is_recent;
    else
        _is_recent := false;
    end if;

	if _exists and _is_recent then
		select content from html_cache where hash = _hash into _content;
	else
		select table_to_html(_q, _name) into _content;
		perform add_to_html_cache(_q, _content);
	end if;
	return _content;
end
$$ language plpgsql;