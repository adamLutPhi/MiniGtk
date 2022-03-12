
#= Dispatch on tuples of types 
dcjones commented on Apr 22, 2015

https://github.com/JuliaLang/julia/issues/10947 =# #status closed (with errors) [& multiple open issues]

#=buggyline type A end; # since 0.3! =#

 isa(A, Type{A}); #true

 isa((A,), Tuple{Type{A}}); #false

 isa(convert(Tuple{Type{A}}, (A,)), Tuple{Type{A}}); #false

#=Buggylinetype A end  #UncommentMe  =#

isa(A, Type{A}) #= true #A is not defined =#

isa((A,), (Type{A},)) # true ERROR A is not defined =#
 
#=To overcome the breaking change of (Normal,Normal) needing to be Tuple{Normal,Normal} I'll try to add another method that dispatches one to the other. =#
Tuple{Normal,Normal} #= ERROR: UndefVarError: Normal not defined

now known as:=#
Tuple{Number,Number} #ok
#= 
ERROR: UndefVarError: Normal not defined
Stacktrace:
 [1] top-level scope
   @ REPL[30]:1=#

# Tuple{Normal,Normal} #Error # was working on  commented by @sebastiang , on Apr 22, 2015 # UndefVarError: Normal not defined
Tuple{Number,Number} #ok Tuple{Number, Number} # working!  (Q. but how to ensure they've meant the same thing ?)

#=(JeffBezanson commented on Apr 22, 2015)  Yes, it should work to add a method to convert (Normal,Normal) to Tuple{Normal,Normal}, although the resulting dispatch will probably be slow.
here's nothing wrong with using tuples. In fact now using them is a great idea, since they perform well and don't require declarations
One huge benefit is that if everybody who needs "two integers" uses Tuple{Int,Int}, then [they can share lots of code]. Declaring new types every time can be highly redundant.

[JeffBezanson closed this on Apr 24, 2015]

    toivoh commented on Apr 24, 2015
So if isa shouldn't be used to check the applicability of a method signature to an argument tuple, what should? Isn't this an inconsistency in the type system? (Making tuples not completely covariant?) I can understand if it's tricky to do something about it, but it would be good to get some more perspective about how it could be allowed to behave in the long run(?)

    JeffBezanson commented on Apr 24, 2015
                [**`Tuples are still covariant`**] =#

Tuple{Type{Int}} <: Tuple{DataType} #True  # but of course not the other way around. It's just that you can't construct a value of the left-hand type(!)
#One thing worth considering is making  typeof(T) always return Type{T} for types,
typeof(T)  # Type{T} #returns: typeof(ones)
DataType{T} #  LoadError: TypeError: in Type{...} expression, expected UnionAll, got Type{DataType}
#=ERROR: TypeError: in Type{...} expression, expected UnionAll, got Type{DataType}=#

#@toivoh commented on Apr 24, 2015: and doing reflection some other way. We could maybe even have DataType{T}. There's an awful lot of 
isa(T, Type) ? Type{T} : typeof(T) #ok # typeof(ones)
#But if tuples are covariant, then:=# 

isa(A, Type{A}) # true 

isa((A,), Tuple{Type{A}})  # ERROR: TypeError: in Type, in parameter, expected  Type, got a value of type Matrix{Float64} ##  LoadError: TypeError: in Type, in parameter, expected Type, got a value of type Matrix{Float64} #OPEN! (since 0.4!)
#(right?) which is clearly not the case currently in 0.4, according to @dcjones original example above. =#

#= sebastiang commented on Apr 24, 2015 #  LoadError: TypeError: in Type, in parameter, expected Type, got a value of type Matrix{Float64}#I suspect this is perhaps only tangentially related, but it seems a reasonable place to ask. I'm trying to update https://github.com/timholy/HDF5.jl to use the new syntax and am running into problems I can summarize here. Given
=#
struct Y{T<:Tuple{Vararg{AbstractVector}}} end #ok now 
#  Why can I not construct the type as I expect here
Y{(Vector{Int},)}() # ERROR: TypeError: in Type, in parameter, expected Type, got a value of type Tuple{DataType}

#ERROR: TypeError: apply_type: in Y, expected Type{T}, got Tuple{DataType}
Y{(Vector{Int}, Vector{String})}()

#ERROR: TypeError: apply_type: in Y, expected Type{T}, got Tuple{DataType,DataType}
#I'm hoping this is just a syntax confusion on my part.

#Same Return:
Y{Tuple{Vector{Int}}}() # Y{Tuple{Vector{Int64}}}()
Y{Tuple{Array{Int64,1}}}() # Y{Tuple{Vector{Int64}}}() # same RETURN 
# But the distinction in this case between the type of the tuple and the tuple itself is confusing for me. I've done one or the other wrong.

#----------
#= sebastiang commented on Apr 24, 2015
# Tim has code which returns a tuple of dimensions. e.g. (10,5,2) for describing fixed-size arrays. Ideally, we'd want to be able to parameterize a type with a tuple of ints, e.g. FixedArray{(10,5,2)}. I can do this in v0.4 by just declaring immutable FixedArray{T}, but I don't know how to restrict the type. This is an error: =#
struct FixedArray{T<:Tuple{Vararg{Int}}} end #ok 
FixedArray{(1, 2, 3)} # ERROR: TypeError: FixedArray: in T, expected T<:Tuple{Vararg{Int64}}, got Tuple{Int64,Int64,Int64}

Vararg{Int64} #} # , got Tuple{Int64,Int64,Int64} #Vararg{Int64, N} where N #now 
#--
#carnaval commented on Apr 24, 2015 #What you would want is something like immutable A{T::Tuple{Vararg{Int}}} not <:. It does not work (syntax error) but probably could without too much effort. Jeff ?
#--- (JeffBezanson commented on Apr 24, 2015)

#@toivoh No, that's not what covariance means.
#@sebastiang ( ) 
#is now never syntax for a type. If you're writing a type, use 

Tuple{}:Y{Tuple{Vector{Int},}} #ERROR: LoadError: MethodError: no method matching  -(::Type{Y{Tuple{Vector{Int64}}}}, ::Type{Tuple{}}) #OPEN! 
#---
#JeffBezanson commented on Apr 24, 2015 #  `isa` -restrictions on type parameters are not implemented yet, but have come up from time to time. I was pretty sure there was an issue about it, but I can't find it. (me:lol!)

#= sebastiang commented on Apr 24, 2015 But how do I parameterize a type with a vararg tuple then?
=#
struct A{T<:Tuple{Vararg{Int}}} end #ok
#----
# This is conceptually what I want, but I see why it doesn't work: (1,2,3) is a tuple of ints, not a type which describes a tuple of ints.
A{(1, 2, 3)}()  #ERROR: LoadError: TypeError: in A, in T, expected T<:Tuple{Vararg{Int64, N} where N}, got a value of type Tuple{Int64, Int64, Int64} #OPEN!
#---

#And this works, but doesn't help me in the least. Where did my (1,2,3) go?
A{Tuple{Int}}()  #ok #(was # ERROR: TypeError: in Type{...} expression, expected UnionAll, got a value of type Matrix{Float64} )
A{Tuple{Int64}}() #ok #(was # LoadError: TypeError: in Type{...} expression, expected UnionAll, got a value of type Matrix{Float64})

#So I'm still confused as to how I can retain the parameterization by a value 
(1, 2, 3)  #and restrict that value to be the right kind of Tuple, i.e. such that 
isa((1, 2, 3), Tuple{Vararg{Int}}) #ok 
#----Killer ERROR DETECTED 
#sebastiang commented on Apr 24, 2015 @JeffBezanson, [I guess this is what your isa-restriction comment meant]; perhaps it's not possible to describe this restriction in v0.4 and it worked 'by accident' in v0.3 because tuples of types were also types? My head spins; thanks for your patience.
#Really all we want is FixedArray{T::Int...}
FixedArray{T::Int...}; #=ERROR: LoadError: UndefVarError: FixedArray not defined #solved (below): 
# JeffBezanson commented on Apr 24, 2015) #That's right; we've never had isa restrictions. This doesn't work in 0.3 either:
#solution: =# #omment (for not ) #UncommentMe

#struct FixedArray{T<:(Int...)} end; #OPEN! # ERROR: LoadError: MethodError: no method matching iterate(::Type{Int64})#Reason:cannot declare constant (#reason redefinition, if not try removing constant ) #potential_ERROR

#iterate( ::T) where T <:Union{(Int..)) end; #Union 
iterate(::Type{Int64}) # ::Type 
#= Closest candidates are: [Julia provides solutions ]
 ``` 
 iterate(::Union{LinRange, StepRangeLen}) #at range.jl:664  
  iterate(::Union{LinRange, StepRangeLen}, ::Int64) #at range.jl:664
  iterate(::T) where T<:Union{Base.KeySet{var"#s77", var"#s76"} ##where {var"#s77", var"#s76"<:Dict}, Base.ValueIterator{var"#s75"} where var"#s75"<:Dict} at dict.jl:693
iterate(::Type{Int64})
```
#  ERROR: syntax: invalid "::" syntax around REPL[38]:1
FixedArray{(1, 2, 3)}
#= ERROR: LoadError: TypeError: in FixedArray, in T,  expected T<:Tuple{Vararg{Int64, N} where N}, got a value of type Tuple{Int64, Int64, Int64}= #
@simonbyrne simonbyrne mentioned this issue on Dec 1, 2020
Can't dispatch on Type{} simonbyrne/KeywordDispatch.jl#10 
# Open ! 
#----
(sebastiang commented on Apr 24, 2015)
@JeffBezanson, I guess this is what your isa-restriction comment meant; perhaps it's not possible to describe this restriction in v0.4 and it worked 'by accident' in v0.3 because tuples of types were also types? My head spins; thanks for your patience.
Really all we want is FixedArray{T::Int...}

(JeffBezanson commented on Apr 24, 2015)
That's right; we've never had isa restrictions. This doesn't work in 0.3 either:
=# 
# 
FixedArray{T<:(Int...)} #} #end # ERROR: UndefVarError: T not defined #Open(???)

#= sebastiang commented on Apr 24, 2015
# This is why in HDF5, the wily Tim created a sentinel type DimSize{N} to hold those integers:

# Stub types to encode fixed-size arrays for H5T_ARRAY
=#

#Buggy(keep commented): #struct  DimSize{N}; end  # Int-wrapper (can't use tuple of Int as param) 
#

#struct  FixedArray{T,D<:(DimSize...)}; end =#
dimsize{N}(::Type{DimSize{N}}) = N ;
# = ERROR: LoadError: syntax: missing comma or } in argument list #readble error! =#


size{T,D}(::Type{FixedArray{T,D}}) = map(dimsize, D)::(Int...) #= ERROR: LoadError: syntax: missing comma or } in argument list =# 

eltype{T,D}(::Type{FixedArray{T,D}}) = T; #= undefined T (# requires more checking )

#= toivoh commented on Apr 26, 2015
@JeffBezanson: You're right, that's not what covariance means. Thinking about it some more, I thought that was what tuple (actually 1-tuple) types mean.
Anyway, making  =# =#
typeof(T); ## = always return Type{T} for types definitely has some appeal. It would make things more consistent, e.g. since it would make

isa(x, T) isa typeof(x) <: T;

#=typeof(x) <: T =#
#=equivalent. I have no idea about the implications when it comes to performance, breakage, etc though=# 


#=@JeffBezanson JeffBezanson mentioned this issue on Jun 2, 2015
Dispatch on tuples with a type #11535  #Closed ! 

# @cstjean cstjean mentioned this issue on Apr 4, 2017
 Segfault on tuple-type return type declaration #21271 #Closed
=#
 #still Open : (& related):
#=redesign=#

 typeof(::Type); #OPEN! 29368  StephenVavasis mentioned this issue on Oct 5, 2018
#https://github.com/JuliaLang/julia/issues/29368

#=
Can't dispatch on Type{} 
https://github.com/simonbyrne/KeywordDispatch.jl/issues/10
=#
#Corrected & closed by  Simon Byrne simonbyrne #Software developer @CliMA  Pasadena, CA

(Float64,) isa Tuple{Type{Float64}}  #false

