// Benchmarks for cookie_parser

///|
test "bench_parse_set_cookie_simple" {
  for _ in 0..<1000 {
    let _ = parse_set_cookie("sid=abc123; Path=/; HttpOnly")
  }
}

///|
test "bench_parse_set_cookie_complex" {
  let header = "session=xyz789; Domain=example.com; Path=/api; Expires=Wed, 21 Oct 2026 07:28:00 GMT; Max-Age=3600; Secure; HttpOnly; SameSite=Strict"
  for _ in 0..<1000 {
    let _ = parse_set_cookie(header)
  }
}

///|
test "bench_parse_cookie_10_pairs" {
  let header = "a=1; b=2; c=3; d=4; e=5; f=6; g=7; h=8; i=9; j=10"
  for _ in 0..<1000 {
    let _ = parse_cookie(header)
  }
}

///|
test "bench_parse_cookie_50_pairs" {
  let mut header = ""
  for i = 0; i < 50; i = i + 1 {
    if i > 0 {
      header = header + "; "
    }
    header = header + "key_" + i.to_string() + "=val_" + i.to_string()
  }
  for _ in 0..<100 {
    let _ = parse_cookie(header)
  }
}

///|
test "bench_serialize_set_cookie" {
  let c = SetCookie::new("session", "xyz789")
  c.domain = Some("example.com")
  c.path = Some("/api")
  c.max_age = Some(3600)
  c.secure = true
  c.http_only = true
  c.same_site = Some(Strict)
  for _ in 0..<1000 {
    let _ = serialize_set_cookie(c)
  }
}

///|
test "bench_parse_cookies_from_headers" {
  let headers : Array[(String, String)] = [
    ("Cookie", "a=1; b=2; c=3"),
    ("Cookie", "d=4; e=5"),
    ("Content-Type", "text/html"),
    ("Cookie", "f=6; g=7; h=8"),
  ]
  for _ in 0..<1000 {
    let _ = parse_cookies_from_headers(headers)
  }
}
