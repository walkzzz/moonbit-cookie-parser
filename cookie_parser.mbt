///|
pub enum SameSite {
  Strict
  Lax
  None
}

///|
pub struct SetCookie {
  name : String
  value : String
  mut domain : String?
  mut path : String?
  mut expires : String?
  mut max_age : Int?
  mut secure : Bool
  mut http_only : Bool
  mut same_site : SameSite?
}

///|
pub fn SetCookie::new(name : String, value : String) -> SetCookie {
  SetCookie::{
    name,
    value,
    domain: None,
    path: None,
    expires: None,
    max_age: None,
    secure: false,
    http_only: false,
    same_site: None,
  }
}

///|
fn trim(s : String) -> String {
  let mut start = 0
  let mut end = s.length()
  while start < end && (s[start] == 32 || s[start] == 9) {
    start = start + 1
  }
  while end > start && (s[end - 1] == 32 || s[end - 1] == 9) {
    end = end - 1
  }
  s.substring(start~, end~)
}

///|
fn split(s : String, delim : Int) -> Array[String] {
  let result : Array[String] = []
  let mut start = 0
  for i = 0; i < s.length(); i = i + 1 {
    if s[i].to_int() == delim {
      result.push(s.substring(start~, end=i))
      start = i + 1
    }
  }
  result.push(s.substring(start~, end=s.length()))
  result
}

///|
fn index_of(s : String, ch : Int) -> Int {
  for i = 0; i < s.length(); i = i + 1 {
    if s[i].to_int() == ch {
      return i
    }
  }
  -1
}

///|
fn parse_int(s : String) -> Int? {
  let s = trim(s)
  if s.length() == 0 {
    return None
  }
  let mut result = 0
  let mut neg = false
  let mut i = 0
  if s[0].to_int() == 45 {
    neg = true
    i = 1
  }
  if i >= s.length() {
    return None
  }
  while i < s.length() {
    let c = s[i].to_int()
    if c < 48 || c > 57 {
      return None
    }
    result = result * 10 + (c - 48)
    i = i + 1
  }
  if neg {
    Some(-result)
  } else {
    Some(result)
  }
}

///|
pub fn parse_set_cookie(header : String) -> SetCookie? {
  let parts = split(header, 59)
  if parts.length() == 0 {
    return None
  }
  let first = trim(parts[0])
  let eq_idx = index_of(first, 61)
  if eq_idx < 0 {
    return None
  }
  let name = trim(first.substring(start=0, end=eq_idx))
  let value = trim(first.substring(start=eq_idx + 1, end=first.length()))
  let cookie = SetCookie::new(name, value)
  for i = 1; i < parts.length(); i = i + 1 {
    let part = trim(parts[i])
    let lower = part.to_lower()
    if lower == "secure" {
      cookie.secure = true
    } else if lower == "httponly" {
      cookie.http_only = true
    } else {
      let attr_eq = index_of(part, 61)
      if attr_eq >= 0 {
        let attr_name = lower.substring(start=0, end=attr_eq)
        let attr_value = part.substring(start=attr_eq + 1, end=part.length())
        match attr_name {
          "domain" => cookie.domain = Some(attr_value)
          "path" => cookie.path = Some(attr_value)
          "expires" => cookie.expires = Some(attr_value)
          "max-age" =>
            match parse_int(attr_value) {
              Some(v) => cookie.max_age = Some(v)
              None => ()
            }
          "samesite" =>
            match attr_value.to_lower() {
              "strict" => cookie.same_site = Some(Strict)
              "lax" => cookie.same_site = Some(Lax)
              "none" => cookie.same_site = Some(None)
              _ => ()
            }
          _ => ()
        }
      }
    }
  }
  Some(cookie)
}

///|
pub fn parse_cookie(header : String) -> Map[String, String] {
  let result : Map[String, String] = Map([])
  let parts = split(header, 59)
  for part in parts {
    let trimmed = trim(part)
    let eq_idx = index_of(trimmed, 61)
    if eq_idx >= 0 {
      let name = trim(trimmed.substring(start=0, end=eq_idx))
      let value = trim(
        trimmed.substring(start=eq_idx + 1, end=trimmed.length()),
      )
      result[name] = value
    }
  }
  result
}

///|
pub fn serialize_set_cookie(cookie : SetCookie) -> String {
  let mut result = cookie.name + "=" + cookie.value
  match cookie.domain {
    Some(d) => result = result + "; Domain=" + d
    None => ()
  }
  match cookie.path {
    Some(p) => result = result + "; Path=" + p
    None => ()
  }
  match cookie.expires {
    Some(e) => result = result + "; Expires=" + e
    None => ()
  }
  match cookie.max_age {
    Some(a) => result = result + "; Max-Age=" + a.to_string()
    None => ()
  }
  match cookie.same_site {
    Some(Strict) => result = result + "; SameSite=Strict"
    Some(Lax) => result = result + "; SameSite=Lax"
    Some(None) => result = result + "; SameSite=None"
    None => ()
  }
  if cookie.secure {
    result = result + "; Secure"
  }
  if cookie.http_only {
    result = result + "; HttpOnly"
  }
  result
}

///|
pub fn serialize_cookie(cookies : Map[String, String]) -> String {
  let mut result = ""
  let mut first = true
  for entry in cookies {
    if !first {
      result = result + "; "
    }
    first = false
    result = result + entry.0 + "=" + entry.1
  }
  result
}

///|
pub fn parse_cookies_from_headers(
  headers : Array[(String, String)],
) -> Map[String, String] {
  let result : Map[String, String] = Map([])
  for header in headers {
    if header.0.to_lower() == "cookie" {
      let cookies = parse_cookie(header.1)
      for entry in cookies {
        result[entry.0] = entry.1
      }
    }
  }
  result
}
