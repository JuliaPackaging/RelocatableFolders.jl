# RelocatableFolders.jl

An alternative to the `@__DIR__` macro. Packages that wish to reference folders
in their project directory run into issues with relocatability when used in
conjunction with `PackageCompiler`. The `@folder_str` provided by this package
overcomes this limitation. See [here][pkgcompiler] and [here][julia-issue] for
further details.

[pkgcompiler]: https://julialang.github.io/PackageCompiler.jl/dev/devdocs/relocatable_part_3/#Relocatability-of-Julia-packages-1
[julia-issue]: https://github.com/JuliaLang/julia/issues/38696

## Usage

The package provides one export, the `@folder_str` macro. It can be used to replace
`@__DIR__` in the following way:

```julia
module MyPackage

using RelocatableFolders

# const ASSETS = joinpath(@__DIR__, "../assets")
const ASSETS = folder"../assets"

end
```

At *runtime* the path stored in `ASSETS` will get resolved to either the
original path, if it still exists, or to an automatically generated
scratchspace containing the same folder and file structure as the original.

## Limitations

This macro should only be used for reasonably small folder sizes. If there are
very large files then it is better to make use of Julia's `Artifact` system
instead.

Building new paths from, for example, `ASSETS` in the above example will return
a `String` containing the resolved path rather than a `Folder` object. Doing this
at the module-level will result in hardcoded paths that will run into
relocatability issues as discussed above. Always create a new `@folder_str` for
each resource you wish to reference rather than building them in parts.

## Internals

At compile-time the `@folder_str` will read in all the files contained in the
referenced folder and store them and their paths. The returned object is a
`Folder <: AbstractString`. Whenever a `Folder` is passed to a function
expecting an `AbstractString` (such as `readdir`) it will be converted to a
`String` by looking up the stored path and returning that. When no path exists
(the source tree no longer exists) then the contents of the files that were
read at compile-time are written to a `Scratch` scratchspace and that path is
returned instead.

## Alternatives

The alternative approach is to use the `Artifacts` system to distribute the
required files, which is a reasonably heavyweight solution for a simple
collection of source-controlled files. It is recommended that users look to use
artifacts when that file sizes are reasonably large and only use this package
when the distributed files are small.
