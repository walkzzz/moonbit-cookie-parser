// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "hackathon/cookie_parser"

version = "0.1.0"

readme = "README.mbt.md"

repository = ""

license = "Apache-2.0"

keywords = [ "cookie", "http", "rfc6265", "parser", "serializer" ]

preferred_target = "wasm"

description = "RFC 6265 HTTP cookie parser and serializer with domain/path/secure/httponly/samesite support."
