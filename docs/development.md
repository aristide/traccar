# Development mode

Inside client source code folder

```bash
$docker build --target client-development -t atmmotors/client-dev:1.0.0 .
```

Inside server source code folder

```bash
$docker build --target gradlew-development -t atmmotors/server-gradlew:1.0.0 .
$docker build --target server-development -t atmmotors/server-dev:1.0.0 .
$docker build --target api-reference -t atmmotors/api-reference:1.0.0 .
$docker build --target origin-api-reference -t atmmotors/origin-api-reference:1.0.0 .
```