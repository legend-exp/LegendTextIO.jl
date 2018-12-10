# This file is a part of LegendDataTypes.jl, licensed under the MIT License (MIT).


function _match_or_throw(expr::Regex, s::AbstractString)
    m = match(expr, s)
    m != nothing || throw(ErrorException("Invalid input, line didnt match $expr"))
    m
end
