# pg-html
HTML from your Database

>
> **Disclaimer**: all the content in this repository is for research purposes only. I wouldn't recommend running this in production, well not yet.
> 

The Idea being, that you can generate HTML from within the SQL, as like a function. Because wouldn't it be cool, if I could say like "render me this table as a literal html table", right?

## usage

because i needed python in the postgresql enabled. I forked the standard docker-postrgres image and commented out the line that removes these features.

you can build the image for yourself like so:

```bash
git clone https://github.com/3n3a/postgres-plpython3u
cd postgres-plpython3u
docker build -t postgres:14-alpine-py3 ./14/alpine/
```

for version 14 you could also pull it from here:

```bash
docker pull 3n3a/postgres:14-alpine-py3
```

### running the db

the image wasn't modified apart from the addition of the plpython3u library.
so it supports all the attributes and variables that the standard `postgres` one does too.

## exampl

The [countries.html](./countries.html) is an example output of `table_to_html` function.
