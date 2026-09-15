// Whitebox tests for cookie_parser

///|
test "parse_set_cookie_basic" {
  let result = parse_set_cookie("sid=abc123")
  match result {
    Some(c) => {
      assert_eq(c.name, "sid")
      assert_eq(c.value, "abc123")
      assert_false(c.secure)
      assert_false(c.http_only)
    }
    None => assert_true(false)
  }
}

///|
test "parse_set_cookie_full" {
  let result = parse_set_cookie(
    "sid=abc123; Domain=example.com; Path=/; Secure; HttpOnly; SameSite=Strict",
  )
  match result {
    Some(c) => {
      assert_eq(c.name, "sid")
      assert_eq(c.value, "abc123")
      assert_eq(c.domain, Some("example.com"))
      assert_eq(c.path, Some("/"))
      assert_true(c.secure)
      assert_true(c.http_only)
      assert_true(c.same_site is Some(Strict))
    }
    None => assert_true(false)
  }
}

///|
test "parse_set_cookie_with_max_age" {
  let result = parse_set_cookie("token=xyz; Max-Age=3600")
  match result {
    Some(c) => {
      assert_eq(c.name, "token")
      assert_eq(c.value, "xyz")
      assert_eq(c.max_age, Some(3600))
    }
    None => assert_true(false)
  }
}

///|
test "parse_set_cookie_with_expires" {
  let result = parse_set_cookie(
    "session=abc; Expires=Wed, 21 Oct 2026 07:28:00 GMT",
  )
  match result {
    Some(c) => {
      assert_eq(c.name, "session")
      assert_eq(c.expires, Some("Wed, 21 Oct 2026 07:28:00 GMT"))
    }
    None => assert_true(false)
  }
}

///|
test "parse_set_cookie_samesite_lax" {
  let result = parse_set_cookie("x=1; SameSite=Lax")
  match result {
    Some(c) => assert_true(c.same_site is Some(Lax))
    None => assert_true(false)
  }
}

///|
test "parse_set_cookie_samesite_none" {
  let result = parse_set_cookie("x=1; SameSite=None")
  match result {
    Some(c) => assert_true(c.same_site is Some(None))
    None => assert_true(false)
  }
}

///|
test "parse_set_cookie_no_equals" {
  let result = parse_set_cookie("invalid")
  assert_true(result is None)
}

///|
test "parse_cookie_basic" {
  let cookies = parse_cookie("name=value; foo=bar")
  assert_eq(cookies.get("name"), Some("value"))
  assert_eq(cookies.get("foo"), Some("bar"))
}

///|
test "parse_cookie_single" {
  let cookies = parse_cookie("session=abc123")
  assert_eq(cookies.get("session"), Some("abc123"))
}

///|
test "parse_cookie_with_spaces" {
  let cookies = parse_cookie("  name = value ;  foo = bar  ")
  assert_eq(cookies.get("name"), Some("value"))
  assert_eq(cookies.get("foo"), Some("bar"))
}

///|
test "parse_cookie_empty" {
  let cookies = parse_cookie("")
  assert_eq(cookies.length(), 0)
}

///|
test "serialize_set_cookie_basic" {
  let c = SetCookie::new("sid", "abc123")
  assert_eq(serialize_set_cookie(c), "sid=abc123")
}

///|
test "serialize_set_cookie_full" {
  let c = SetCookie::new("sid", "abc123")
  c.domain = Some("example.com")
  c.path = Some("/")
  c.secure = true
  c.http_only = true
  c.same_site = Some(Strict)
  let result = serialize_set_cookie(c)
  assert_eq(
    result, "sid=abc123; Domain=example.com; Path=/; SameSite=Strict; Secure; HttpOnly",
  )
}

///|
test "serialize_set_cookie_with_max_age" {
  let c = SetCookie::new("token", "xyz")
  c.max_age = Some(3600)
  assert_eq(serialize_set_cookie(c), "token=xyz; Max-Age=3600")
}

///|
test "serialize_cookie_basic" {
  let cookies : Map[String, String] = Map([])
  cookies["name"] = "value"
  cookies["foo"] = "bar"
  let result = serialize_cookie(cookies)
  // Map iteration order may vary, so just check length and content
  assert_true(result.contains("name=value"))
  assert_true(result.contains("foo=bar"))
  assert_true(result.contains("; "))
}

///|
test "parse_cookies_from_headers" {
  let headers : Array[(String, String)] = [
    ("Content-Type", "text/html"),
    ("Cookie", "a=1; b=2"),
    ("Cookie", "c=3"),
  ]
  let cookies = parse_cookies_from_headers(headers)
  assert_eq(cookies.get("a"), Some("1"))
  assert_eq(cookies.get("b"), Some("2"))
  assert_eq(cookies.get("c"), Some("3"))
}

///|
test "parse_set_cookie_case_insensitive_attrs" {
  let result = parse_set_cookie("x=1; DOMAIN=example.com; PATH=/")
  match result {
    Some(c) => {
      assert_eq(c.domain, Some("example.com"))
      assert_eq(c.path, Some("/"))
    }
    None => assert_true(false)
  }
}

///|
test "roundtrip_set_cookie" {
  let original = "sid=abc123; Domain=example.com; Path=/; SameSite=Lax; Secure; HttpOnly"
  let parsed = parse_set_cookie(original)
  match parsed {
    Some(c) => {
      let serialized = serialize_set_cookie(c)
      let reparsed = parse_set_cookie(serialized)
      match reparsed {
        Some(c2) => {
          assert_eq(c2.name, c.name)
          assert_eq(c2.value, c.value)
          assert_eq(c2.domain, c.domain)
          assert_eq(c2.path, c.path)
          assert_eq(c2.secure, c.secure)
          assert_eq(c2.http_only, c.http_only)
        }
        None => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}
