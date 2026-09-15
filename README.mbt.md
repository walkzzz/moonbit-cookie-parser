# HTTP Cookie Parser (RFC 6265)

HTTP Cookie 的解析和序列化需要严格遵循 RFC 6265 规范，处理各种属性（Domain、Path、Secure、HttpOnly、SameSite、Expires、Max-Age）和边缘情况。手写解析容易出错。

## Features

- Set-Cookie 头解析和序列化
- Cookie 头解析和序列化
- 所有 RFC 6265 属性支持
- SameSite 属性（Strict/Lax/None）
- Expires 日期解析（HTTP-date 格式）
- 完整的 RFC 合规测试

## Installation

```bash
moon add hackathon/cookie_parser
```

## Quick Start

```moonbit nocheck
let set_cookie = @cookie_parser.parse_set_cookie(
  "sid=abc123; Domain=example.com; Path=/; Secure; HttpOnly; SameSite=Strict"
)
assert_eq(set_cookie.name, "sid")
assert_eq(set_cookie.secure, true)
assert_eq(set_cookie.same_site, Some(@cookie_parser.SameSite::Strict))

let header = @cookie_parser.serialize_set_cookie(set_cookie)
```

## Testing

```bash
moon test
```

## License

Apache-2.0
