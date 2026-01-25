# =================== Solution.jl ===================

mutable struct Solution
    sequence::Vector{Int}
    cost::Float64
end

function Solution()
    return Solution(Int[], Inf)
end

function Solution(valor::Real)
    return Solution(Int[], Float64(valor))
end

function Solution(seq::Vector{Int}, valor::Real)
    return Solution(seq, Float64(valor))
end

import Base: copy

function copy(s::Solution)
    return Solution(copy(s.sequence), s.cost)
end
