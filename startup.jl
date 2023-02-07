using Revise
using Pkg, Downloads, Test, TOML, Base.Threads, Dates # LinearAlgebra
using BenchmarkTools, CodeTracking
using TimerOutputs, OhMyREPL
using SaveREPL
using MyExportAll
# using Debugger, Cthulhu
# using JSON3, CSV, DataFrames
using InvertedIndices
# using AbstractTrees

OhMyREPL.enable_autocomplete_brackets(false)

ENV["PATH"] = "/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Users/anand/.juliaup/bin"
# ENV["JULIA_PKG_SERVER"] = "https://internal.juliahub.com"

# Base.eval(Module(), quote
#     using PkgAuthentication
#     PkgAuthentication.install()
# end)

function vi(io=IOBuffer())
    versioninfo(io)
    String(take!(io))
end

"copies versioninfo() and Pkg.status() to clipboard"
function mwe(; clip=true, verbose=false)
    io = IOBuffer()
    s = vi(io)
    Pkg.status(; io, mode=PKGMODE_MANIFEST)
    s2 = String(take!(io))
    str = """
    mwe:
    ```julia

    ```
    trace:
    ```julia

    ```

    versioninfo():
    ```julia
    $(s)

    ```
    <details>
    <summary>Manifest</summary>
    
    ```julia
    $(s2)
    ```
  </details>
    """
    clip && clipboard(str)
    verbose && print(str)
    verbose && return str
    nothing
end

function ytdl(id)
    cd(joinpath(homedir(), "Music/ytdl/"))
    if startswith(id, "https")
        run(`yt-dlp -f140 -x "$id"`)
    else
        run(`yt-dlp -f140 -x "https://www.youtube.com/watch?v=$id"`)
    end
end

get_site(url) = take!(Downloads.download(url, IOBuffer()))
get_json(url) = JSON3.read(get_site(url))


function goodbad(f, xs; verbose=false)
    good = []
    bad = []
    for (i, x) in enumerate(xs)
        verbose && @info x
        try
            y = f(x)
            push!(good, (i, x) => y)
        catch e
            push!(bad, (i, x) => e)
        end
    end
    good, bad
end

"when switching versions its annoying to have to readd everything, this generates the command to paste into a new version"
function startup_pkgs()
    deps = Pkg.dependencies()
    xs = map(x -> deps[x], values(Pkg.project().dependencies))
    locals = findall(x -> x.is_tracking_path, xs)
    repos = findall(x -> x.is_tracking_repo, xs)
    ls = map(x->x.source, xs[locals])
    rs = map(x->x.git_source, xs[repos])
    ns = map(x -> x.name, xs[Not(union(locals, repos))])
    s = "pkg\"add " * join(ns, " ") * "\"; pkg\"dev " * join([ls;rs], " ") * '"'
    clipboard(s)
    print(s)
    s
end

# for fname in [:clipboard, :size, :typeof]
#     c = Symbol(first(string(fname)))
#     ex = :(
#         begin
#             macro ($c)(ex0)
#                 $(fname)(ex0)
#             end

#             macro ($c)()
#                 $(fname)($ans)
#             end
#         end
#     )
#     @eval($ex)
# end

############ MACROS 
macro c(ex)
    :(clipboard($(ex)))
end

macro c()
    :(clipboard($(ans)))
end

macro cr()
    :(copyREPL(1))
end

macro cc()
    :(copyREPL(1))
end

macro t(ex)
    :(typeof($(ex)))
end

macro t()
    :(typeof($(ans)))
end

macro s(ex)
    :(size($(ex)))
end

macro s()
    :(size($(ans)))
end

macro d(ex)
    :(Docs.doc($(ex)))
end

macro d()
    :(Docs.doc($(ans)))
end

# macro da(ex)
#     p = joinpath(Pkg.devdir(), $ex)

# end
# macro w(ex)
#     @which ex
# end

# macro w()
#     @which $ans
# end

to_df(fn; kwargs...) = CSV.read(fn, DataFrame; kwargs...)

WL_REPLACE_PAIRS = [
    "~" => "==",
    "&" => "&&",
    "|" => "||"
]
WL_REPLACE_PAIRS_ = [
    "{" => "[",
    "}" => "]",
    "->" => "=>",
    "→" => "=>"
    # "~" => "==",
    # "&" => "&&",
    # "|" => "||"
]

function eq_str_to_wl(str)
    str = replace(str, WL_REPLACE_PAIRS...)
    # str = replace(str, "&" => "&&")
    # str = replace(str, "|" => "||")
end
function wl_str_to_eq(str)
    str = replace(str, WL_REPLACE_PAIRS_...)
    # str = replace(str, "&" => "&&")
    # str = replace(str, "|" => "||")
end

function eqs_to_mathematica(eqs)
    es = string.(eqs)
    eq_strs = map(eq_str_to_wl, es)
    join(["{", join(eq_strs, ", "), "}"])
end

function timerout_to_df(to)
    to = TimerOutputs.flatten(to)
    fnames = (:ncalls, :time, :allocs, :firstexec)
    df = DataFrame(name=String[], ncalls=Int[], time=Int[], allocs=Int[], firstexec=Int[])
    for (k, v) in to.inner_timers
        d = v.accumulated_data
        row = vcat(k, map(x -> getfield(d, x), fnames)...)
        push!(df, row)
    end
    is = tryparse.(Int, df.name)
    nothing ∉ is && (df[!, :name] = is)
    df
end

function plot_timerdf(df)
    sort!(df, :name)
    plt = plot(df.name, df.time / 10e9, label="time (s)")
    plot!(plt, df.name, df.allocs / 10e9, label="allocs")
    display(plt)
end

function time_scaling(f, xs) #; save=false)
    to = TimerOutput()
    # ys = []
    for (i, x) in enumerate(xs)
        y = @timeit to "$i" f(x)
    end
    timerout_to_df(to)
end

"Nest"
function nest_apply(f, x, n)
    for i in 1:n
        x = f(x)
    end
    x
end

"NestList"
function nest_apply_save(f, x, n)
    V = Vector{typeof(x)}(undef, n + 1)
    V[1] = x
    for i in 2:(n+1)
        x = f(x)
        V[i] = x
    end
    V
end

function jg(name=ARGS[1])
    cd(Pkg.devdir())
    Pkg.generate(name)
    cd(name)
    Pkg.activate(".")
    mkpath(".github/workflows/")
    mkpath("test")
    touch("test/runtests.jl")
    touch("README.md")
    touch(".gitignore")
    mkpath("data")
    ci_path = joinpath(homedir(), ".julia/jd/CI.yml")
    cp(ci_path, ".github/workflows/CI.yml")
    proj_file = Base.active_project()
    t = TOML.parsefile(proj_file)
    t["extras"] = Dict{String,Any}("Test" => "8dfed614-e22c-5e08-85e1-65c5234f0b40")
    t["targets"] = Dict{String,Any}("test" => ["Test"])
    open(proj_file, "w") do io
        TOML.print(io, t)
    end
end

function testdep(pkg_name; p=Base.current_project())
    isnothing(p) && error()
    Pkg.add(pkg_name)
    t = TOML.parsefile(p)

    _add_toml_field!(t, "extras"; T=Dict{String,Pair{String,String}}())
    _add_toml_field!(t, "targets"; T=Dict{String,Pair{String,Vector{String}}}())

    pkg_uuid = t["deps"][pkg_name]
    delete!(t["deps"], pkg_name)
    t["extras"][pkg_name] = pkg_uuid
    push!(t["targets"]["test"], pkg_name)
    open(p, "w") do io
        TOML.print(io, t; sorted=true)
    end
    Pkg.resolve()
    nothing
end

testdep(pkgs::AbstractArray; kws...) = map(testdep, pkgs; kws...)

_add_toml_field!(t, k; T=Dict{String,Any}) = haskey(t, k) || (t[k] = T())

allapprox(itr; kws...) = isempty(itr) ? true : all(isapprox(first(itr); kws...), itr)

supertypest(x) = supertypes(typeof(x))

struct_to_arr(x) = getfield.(Ref(x), fieldnames(typeof(x)))
proparr(x) = getproperty.((x,), propertynames(x))
function prop_pairs(x)
    ps = propertynames(x)
    ps .=> getproperty.((x,), ps)
end
to_nt(x) = NamedTuple(prop_pairs(x))

function dev_activate(pkg_name)
    p = joinpath(Pkg.devdir(), pkg_name)
    cd(p)
    # Pkg.develop(pkg_name)
    Pkg.activate(p)
end
function dev_find(pkg_name)
    p = joinpath(Pkg.devdir(), pkg_name)
    isdir(p) && return p
    p2 = p * ".jl"
    isdir(p2) && return p2
    nothing
end
function dev_open(pkg_name)
    p = dev_find(pkg_name)
    isnothing(p) && error("Package not found")
    run(`code $p`)
end

"""Get a dictionary of dependencies of a package and their UUIDs."""
function Pkg.dependencies(package::AbstractString)
    if package == Pkg.project().name
        return Pkg.project().dependencies
    end
    return Pkg.dependencies()[Pkg.project().dependencies[package]].dependencies
end

_js() = run(`open "$(homedir())/.julia/config/startup.jl"`)
const LORENZ_EXPR = Base.remove_linenums!(
    :(
        # using DifferentialEquations, ModelingToolkit
        begin
            @parameters t sig = 10 rho = 28.0 beta = 8 / 3
            @variables x(t) = 100 y(t) = 1.0 z(t) = 1
            D = Differential(t)

            eqs = [D(x) ~ sig * (y - x),
                D(y) ~ x * (rho - z) - y,
                D(z) ~ x * y - beta * z]
            sys = ODESystem(eqs; tspan=(0, 100), name=:lorenz)
            # prob = ODEProblem(lorenz, [], (0, 10.0))

        end
    ))
const LORENZ_STR = """
@parameters t sig = 10 rho = 28.0 beta = 8 / 3
@variables x(t) = 100 y(t) = 1.0 z(t) = 1
D = Differential(t)

eqs = [D(x) ~ sig * (y - x),
    D(y) ~ x * (rho - z) - y,
    D(z) ~ x * y - beta * z]
sys = ODESystem(eqs; tspan=(0, 100), name=:lorenz)
"""

const SOLVE_LORENZ_STR = """
ssys = structural_simplify(sys)
prob = ODEProblem(ssys)
sol = solve(prob)
"""

_WL_LORENZ = """
eqs = {x'[t] == sig * (y[t] - x[t]),
    y'[t] == (rho - z[t]) * x[t] - y[t],
    z'[t] == x[t] * y[t] - beta * z[t]}

u0eqs = {
    x[0] == 100,
    y[0] == 1,
    z[0] == 1
    sig == 10,
    rho == 28.0,
    beta == 8 / 3
}
sol = NDSolve[Join[eqs, u0eqs], {x[t], y[t], z[t]}, {t, 0, 10}]
sol  /. t->5
sol  /. t->{0, 1, 2, 3, 4, 5}
"""

function lorenz()
    LORENZ_EXPR
end

function nt_to_pairs(nt)
    fieldnames(typeof(nt)) .=> collect(nt)
end

function eval_kwargs(nt)
    ps = nt_to_pairs(nt)
    for (k, v) in ps
        eval(:($k = $v))
    end
end

# AbstractTrees.children(x::DataType) = subtypes(x)


# fs = [:first, :only, :last]
# for f in fs
#     sym = Symbol(:try_, f)
#     @eval $sym(xs) = isempty(xs) ? nothing : Base.$f(xs)
# end

sortl(xs) = sort(xs; by=last, rev=true)
sortl!(xs) = sort!(xs; by=last, rev=true)
function tally(vec)
    sortl!(collect(countmap(vec)))
end

function calculate_minimum_rtol(x, y)
    d = norm(x - y)
    m = max(norm(x), norm(y))
    d / m
end

code(p) = run(`code $p`)

function time_imports_str_to_df(s)
    s = strip(s)
    ls = strip.(split(s, "\n"))
    cols = split.(ls, "  ")
    df = DataFrame(time=Float64[], unit=String[], pkg=String[], comp=Union{Missing,String}[])
    for (i, col) in enumerate(cols)
        time = first(col)
        time, unit = split(time, " ")
        time = parse(Float64, time)
        pkg_and_comp = last(col)
        foo = split(pkg_and_comp, " "; limit=2)
        length(foo) == 1 ? (pkg, comp) = (foo[1], missing) : (pkg, comp) = foo
        row = vec([time unit pkg comp])
        push!(df, row)
    end
    sort!(df, :time; rev=true)
    df
end

function precomp_time_str_to_df(s)
    s = strip(s)
    ss = strip.(split(s, "\n")[2:end-1])
    df = DataFrame(parse_precomp_time_row.(ss))
    sort!(df, :time;rev=true)
    df
end

function parse_precomp_time_row(l)
    ms = collect(eachmatch(Base.ansi_regex, l))
    j = join(filter(x -> length(x) == 1, map(x -> x.match, ms)))
    xs = split(j)
    time, check = xs[[1, 3]]
    time = parse(Float64, time)
    if length(xs) == 6
        name, extname = xs[[4, 6]]
    else
        name = xs[4]
        extname = missing
    end
    (; time, check, name, extname)
end


cv(x) = collect(values(x))
ck(x) = collect(keys(x))
getd(d, xs) = map(x->d[x], xs)
unzip(xs) = first.(xs), last.(xs)
function unzip(d::Dict)
    xs = collect(d)
    first.(xs), last.(xs)
end
