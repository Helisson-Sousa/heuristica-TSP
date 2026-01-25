# =================== Construction.jl ===================

using Random

mutable struct InsertionInfo
    node::Int
    edgePos::Int
    cost::Float64
end

mutable struct Construction
    data::Data
    remaining::Vector{Int}
    insertionCost::Vector{InsertionInfo}

    function Construction(data::Data)
        new(data, Int[], InsertionInfo[])
    end
end

function solucaoInicial!(constr::Construction, s::Solution)

    constr.remaining = collect(2:constr.data.dimension)
    empty!(constr.insertionCost)

    s.sequence = [1, 1]
    s.cost = 0.0

    dist = constr.data.distMatrix

    for _ in 1:3
        idx = rand(1:length(constr.remaining))
        city = constr.remaining[idx]

        prevCity = s.sequence[end - 1]
        nextCity = s.sequence[end]

        insert!(s.sequence, length(s.sequence), city)

        s.cost += dist[prevCity, city] +
                  dist[city, nextCity] -
                  dist[prevCity, nextCity]

        deleteat!(constr.remaining, idx)
    end

    while !isempty(constr.remaining)

        calcularCustoInsercao!(constr, s)

        sort!(constr.insertionCost, by = x -> x.cost)

        α = rand()
        limite = max(1, ceil(Int, α * length(constr.insertionCost)))
        escolhido = rand(1:limite)

        info = constr.insertionCost[escolhido]

        inserirNaSolucao!(constr, s, info)
        s.cost += info.cost
    end
end

function solucaoInicial(constr::Construction)
    s = Solution()
    solucaoInicial!(constr, s)
    return s
end

function calcularCustoInsercao!(constr::Construction, s::Solution)

    empty!(constr.insertionCost)
    dist = constr.data.distMatrix

    for pos in 1:(length(s.sequence) - 1)

        i = s.sequence[pos]
        j = s.sequence[pos + 1]

        for city in constr.remaining
            cost = dist[i, city] +
                   dist[city, j] -
                   dist[i, j]

            push!(constr.insertionCost,
                  InsertionInfo(city, pos, cost))
        end
    end
end

function inserirNaSolucao!(constr::Construction, s::Solution, info::InsertionInfo)

    insert!(s.sequence, info.edgePos + 1, info.node)

    empty!(constr.insertionCost)

    idx = findfirst(==(info.node), constr.remaining)
    if idx !== nothing
        deleteat!(constr.remaining, idx)
    end
end
