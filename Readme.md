
# Wrap_libgit2 
`Wrap_libgit2` is an Eiffel binding of [libgit2](https://libgit2.org/) C library
using [WrapC](https://github.com/eiffel-wrap-c/WrapC) tool.

`libgit2` is a portable, pure C implementation of the Git core methods provided as a re-entrant linkable library with a solid API, 
allowing you to write native speed custom Git applications in any language which supports C bindings.

## Requirements 

*  [WrapC](https://github.com/eiffel-wrap-c/WrapC) tool.
*  [Libgit2 v0.28.3](https://github.com/libgit2/libgit2/releases).

== Status ==
The binding is work in progress.
Tested on Linux and Windows 64 bits.

## Examples 

* Git Init: 		`shows how to initialize a new repo`
* Git Status:		`shows how to use the status APIs` 

[Guide to linking libgit2](https://libgit2.org/docs/guides/build-and-link/) on various platforms

Optionally you can use [vckpg](https://github.com/Microsoft/vcpkg), a C++ Library Manager for Windows, Linux, and MacOS.

Windows example
```
	vcpkg install libgit2:x64-windows
```
or
Linux example
```
	./vcpkg install libgit2:x64-linux
```








