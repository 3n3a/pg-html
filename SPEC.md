# Specification of JSON-HTML-Tree

To give a possible user the full control over their generated HTML tree, 
I have come up with the following json spec that the `json_to_html` function
will accept.

## Root

The root is the same as `children`, meaning it accepts multiple
tags.

```
[]
```

## Tag

The tag is an object, consisting of a name, attributes (key, value) and
children.

```
{
  "t": "h1",
  "a": {},
  "c": [],
}
```

* `t`: Tag Name (String)
* `a`: Attribute (Object)
* `c`: Children (Array of Tags|Strings)

## Examples

### VSCodes Standard HTML Template

Wnen you press `!!` the following template appears:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    
</body>
</html>
```

The same but in pg-html-json looks as follows:

```json
[
  {
    "t": "!doctype",
    "a": {
      "html": ""
    },
    "c": []
  },
  {
    "t": "html",
    "a": {
      "lang": "en"
    },
    "c": [
        {
          "t": "head",
          "a": {},
          "c": [
              {
                "t": "meta",
                "a": {
                  "charset": "UTF-8"
                },
                "c": []
              },
              {
                "t": "meta",
                "a": {
                  "http-equiv": "X-UA-Compatible",
                  "content": "IE=edge"
                },
                "c": []
              },
              {
                "t": "meta",
                "a": {
                  "name": "viewport",
                  "content": "width=device-width, initial-scale=1.0"
                },
                "c": []
              },
               {
                "t": "title",
                "a": {},
                "c": ["Document"]
              },
          ]
        },
        {
          "t": "body",
          "a": {},
          "c": []
        }
    ]
  },
]
```

You could then execute the function as follows:

```sql
select json_to_html ('<above-as-string'::json)
```
