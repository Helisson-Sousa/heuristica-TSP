# =========================================================
# Construction.jl
# Heurística construtiva para o TSP (GRASP-like insertion)
# =========================================================

using Random

# ---------------------------------------------------------
# Estrutura auxiliar para custo de inserção
# ---------------------------------------------------------
mutable struct InsertionInfo
    node::Int
    edgePos::Int
    cost::Float64
end

# ---------------------------------------------------------
# Estrutura Construction
# ---------------------------------------------------------
mutable struct Construction
    data::Data
    remaining::Vector{Int}
    insertionCost::Vector{InsertionInfo}

    function Construction(data::Data)
        new(data, Int[], InsertionInfo[])
    end
end

# ---------------------------------------------------------
# Solução inicial (in-place)
# Equivalente ao Construcao::solucaoInicial(Solucao& s) em C++
# ---------------------------------------------------------
function solucaoInicial!(constr::Construction, s::Solution)

    # Inicializa lista de cidades não visitadas (2 até n)
    constr.remaining = collect(2:constr.data.dimension)
    empty!(constr.insertionCost)

    # Solução começa e termina na cidade 1
    s.sequence = [1, 1]
    s.cost = 0.0

    dist = constr.data.distMatrix

    # ------------------ Inserção aleatória inicial (3 cidades) ------------------
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

    # ------------------ Inserções guiadas por custo (GRASP) ------------------
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

# ---------------------------------------------------------
# Wrapper: cria e retorna uma Solution
# Necessário para o ILS
# ---------------------------------------------------------
function solucaoInicial(constr::Construction)
    s = Solution()
    solucaoInicial!(constr, s)
    return s
end

# ---------------------------------------------------------
# Cálculo dos custos de inserção
# ---------------------------------------------------------
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

# ---------------------------------------------------------
# Inserção efetiva na solução
# ---------------------------------------------------------
function inserirNaSolucao!(constr::Construction, s::Solution, info::InsertionInfo)

    insert!(s.sequence, info.edgePos + 1, info.node)

    empty!(constr.insertionCost)

    idx = findfirst(==(info.node), constr.remaining)
    if idx !== nothing
        deleteat!(constr.remaining, idx)
    end
end
