# Deploy in production

## build production containers

```bash
$docker build --target server-production -t atmmotors/server:1.0.0 .
$docker build --target api-reference -t atmmotors/api-reference:1.0.0 .
```

<entry key='web.path'>./web</entry>

