module NamasteJL

#
# TODO: 
# + _get_namaste, _make_namaste, _set_namaste might be interesting as macros
# + Get should support taking an option arg to return specific value (e.g. type, who, what, where when
# + _make_namaste should probably be encode namaste, and we need an decode namaste
# 


#
# Namaste.jl is a port of github.com/mjgiarlo/namaste from Python
# to Julia.
#

export Encode, Decode, GetType, GetTypes, DirType, Who, What, When, Where


function normalizeTagName(tag::AbstractString)
    formalNames = Dict(
        "type" => "0",
        "who" => "1",
        "what" => "2",
        "when" => "3",
        "where" => "4"
    )
    return get(formalNames(lowercase(tag)), tag)
end

function charEncode(value::AbstractString)
    #FIXME: Decide on encoding/decoding scheme, probably use the one
    # from Pairtree spec.
    value
end

function charDecode(value::AbstractString)
    #FIXME: Decide on encoding/decoding scheme, probably use the one
    # from Pairtree spec.
    value
end

function Encode(tag::AbstractString, value::AbstractString)
    if tag == ""
        return f"$(charEncode(value))"
    end
    f"$(normalizeTag(tag))=$(charEncode(value))"
end

function Decode(value::AbstractString)
    if startswith(value, "0=") == true or startswith(value, "1=") == true or startswith("2=") == true or startswith(value, "3=") == true or startswith(value, "4=") == true
        return f"$(value[0:2])$(charDecode(value[2:end]))"
    end
    f"$(charDecode(value))"  
end

function _make_namaste(tag::Int, value::AbstractString)
    Encode("$tag", value)
end

function _get_namaste(d::AbstractString, tag::Int)
    tags = String[]
	d_info = readdir(d)
	namaste = String[]
	for f in filter(x -> startswith(x, "$tag="), readdir(d))
		push!(namaste, f)
	end
    if length(namaste) == 0
        return "", "namaste missing"
    end
    "namaste: $(join(namaste, ", "))", ""
end

function _set_namaste(d::AbstractString, tag::Int, value::AbstractString)
	if value == ""
		return "", "$value is empty"
    end
    if isdir(d) == false
		return "", "$d is not a directory"
	end
    namaste = joinpath(d, _make_namaste(tag, value))
    open(namaste, "w") do f
        write(f, "$value\n")
    end
    namaste, ""
end

function DirType(d::AbstractString, value::AbstractString; verbose::Bool = true)
    (namaste, err) = _set_namaste(d, 0, value)
    if err != ""
        return "", err
    end
    if verbose
        println(namaste)
    end
    namaste, ""
end

function Who(d::AbstractString, value::AbstractString; verbose::Bool = true)
    (namaste, err) = _set_namaste(d, 1, value)
    if err != ""
        return "", err
    end
    if verbose
        println(namaste)
    end
    namater, ""
end

function What(d::AbstractString, value::AbstractString; verbose::Bool = true)
    (namaste, err) = _set_namaste(d, 2, value)
    if err != ""
        return "", err
    end
    if verbose
        println(namaste)
    end
    namaste, ""
end

function When(d::AbstractString, value::AbstractString; verbose::Bool = true)
    (namaste, err) = _set_namaste(d, 3, value)
    if err != ""
        return "", err
    end
    if verbose
        println(namaste)
    end
    namaste, ""
end

function Where(d::AbstractString, value::AbstractString; verbose::Bool = true)
    (namaste, err) = _set_namaste(d, 4, value)
    if err != ""
        return "", err
    end
    if verbose
        println(namaste)
    end
    namaste, ""
end

function GetType(d::AbstractString; verbose::Bool = true)
    tags = String[]
    if d == "" 
        d = "."
    end
    if isdir(d) == false
        return "", "$d is not a directory"
    end
    for t in [0,1,2,3,4]
        tags = vcat(tags, _get_namaste(d, t))
    end
    if verbose
        println("namastes: $(join(tags, ", "))")
    end
    tags, ""
end

function GetTypes(d::AbstractString; verbose::Bool = true)
    if d == ""
        d = "."
    end
    if isdir(d) == false
        return "", "$d is not a directory"
    end
    types = Dict()
    (tags, err) = _get_namaste(d, 0)
    if err != ""
        return "", err
    end
    if length(tags) > 0
        for tag in tags
            (name, major, minor) = ("", "", "")
            if contains(tag, "_")
                (name, version) = split(tag, "_", limit = 2)
                (major, minor) = split(version, ".", limit = 2)
                types[name] = Dict("name" => name, "major" => major, "minor" => minor)
                if verbose
                    println("namaste - directory type $name - version $major $minor")
                end
            end
        end
    end
    types, ""
end

end # module
