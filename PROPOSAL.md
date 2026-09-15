# HTTP Cookie Parser (RFC 6265) - Project Proposal

## Hackathon Direction

Web 与网络基础设施

## Problem Statement

HTTP Cookie 的解析和序列化需要严格遵循 RFC 6265 规范，处理各种属性（Domain、Path、Secure、HttpOnly、SameSite、Expires、Max-Age）和边缘情况。手写解析容易出错。

## Solution

实现 RFC 6265 严格兼容的 Cookie 解析器和序列化器。支持 Set-Cookie 和 Cookie 头的解析/生成，正确处理所有标准属性和边缘情况。

## Scope (In)

- Set-Cookie 头解析和序列化
- Cookie 头解析和序列化
- 所有 RFC 6265 属性支持
- SameSite 属性（Strict/Lax/None）
- Expires 日期解析（HTTP-date 格式）
- 完整的 RFC 合规测试

## Scope (Out)

- Cookie Jar 状态管理（存储/过期/匹配）
- 网络请求/响应处理
- Cookie 安全策略执行

## Differentiation from Existing Ecosystem

mooncakes.io 上有 crater-browser-http（1个，浏览器端），本项目专注服务端 RFC 6265 严格解析/序列化，边界更窄更清晰。

## Milestones

- M1: Cookie 属性数据结构定义
- M2: Set-Cookie 解析器
- M3: Cookie 头解析器
- M4: 序列化器
- M5: RFC 6265 合规测试套件

## API Preview

```moonbit
let set_cookie = @cookie_parser.parse_set_cookie(
  "sid=abc123; Domain=example.com; Path=/; Secure; HttpOnly; SameSite=Strict"
)
assert_eq(set_cookie.name, "sid")
assert_eq(set_cookie.secure, true)
assert_eq(set_cookie.same_site, Some(@cookie_parser.SameSite::Strict))

let header = @cookie_parser.serialize_set_cookie(set_cookie)
```

## Testing Plan

- Unit tests for all public API functions
- Edge case tests (empty input, single element, maximum size)
- Property-based tests where applicable
- Performance benchmarks for key operations

## License

Apache-2.0
