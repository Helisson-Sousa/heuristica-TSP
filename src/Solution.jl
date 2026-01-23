# =================== Solution.jl ===================

mutable struct Solution
    sequence::Vector{Int}
    cost::Float64
end

# ---------------------------------------------------
# Construtor padrão (solução vazia)
# ---------------------------------------------------
function Solution()
    return Solution(Int[], Inf)
end

# ---------------------------------------------------
# Construtor com custo inicial (usado no ILS)
# Ex: Solution(typemax(Int))
# ---------------------------------------------------
function Solution(valor::Real)
    return Solution(Int[], Float64(valor))
end

# ---------------------------------------------------
# Construtor completo
# ---------------------------------------------------
function Solution(seq::Vector{Int}, valor::Real)
    return Solution(seq, Float64(valor))
end

# ---------------------------------------------------
# CÓPIA PROFUNDA (OBRIGATÓRIA PARA O ILS)
# ---------------------------------------------------
import Base: copy

function copy(s::Solution)
    return Solution(copy(s.sequence), s.cost)
end
