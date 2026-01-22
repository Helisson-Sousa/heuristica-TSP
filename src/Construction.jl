# =========================================================
# Construction.jl
# Heurística construtiva para o TSP (GRASP-like insertion)
# =========================================================

using Random

# ---------------------------------------------------------
# Estrutura auxiliar para custo de inserção
# ---------------------------------------------------------
mutable struct InsertionInfo
    noInserido::Int
    arestaRemovida::Int
    custo::Float64
end

# ---------------------------------------------------------
# Estrutura Construction
# ---------------------------------------------------------
mutable struct Construction
    dados::TSPData
    cidades::Vector{Int}
    custoInsercao::Vector{InsertionInfo}

    function Construction(dados::TSPData)
        new(dados, Int[], InsertionInfo[])
    end
end

# ---------------------------------------------------------
# Solução inicial
# ---------------------------------------------------------
function solucaoInicial!(constr::Construction, s::Solution)

    # Inicializa lista de cidades (2 até n)
    constr.cidades = collect(2:constr.dados.dimension)
    constr.custoInsercao = InsertionInfo[]

    # Solução começa e termina em 1
    s.sequencia = [1, 1]
    s.valorObj = 0.0

    # ------------------ Inserção aleatória inicial (3 cidades) ------------------
    for _ in 1:3
        idx = rand(1:length(constr.cidades))
        cidadeSelecionada = constr.cidades[idx]

        cidadeAnterior = s.sequencia[end-1]
        ultimaCidade   = s.sequencia[end]

        insert!(s.sequencia, length(s.sequencia), cidadeSelecionada)

        s.valorObj += constr.dados.dist[cidadeAnterior, cidadeSelecionada] +
                      constr.dados.dist[cidadeSelecionada, ultimaCidade] -
                      constr.dados.dist[cidadeAnterior, ultimaCidade]

        deleteat!(constr.cidades, idx)
    end

    # ------------------ Inserções guiadas por custo ------------------
    while !isempty(constr.cidades)

        calcularCustoInsercao!(constr, s)

        sort!(constr.custoInsercao, by = x -> x.custo)

        alpha = rand()
        limite = max(1, ceil(Int, alpha * length(constr.custoInsercao)))
        selecionado = rand(1:limite)

        info = constr.custoInsercao[selecionado]

        inserirNaSolucao!(constr, s, info)
        s.valorObj += info.custo
    end
end

# ---------------------------------------------------------
# Cálculo dos custos de inserção
# ---------------------------------------------------------
function calcularCustoInsercao!(constr::Construction, s::Solution)

    empty!(constr.custoInsercao)

    for a in 1:(length(s.sequencia) - 1)

        i = s.sequencia[a]
        j = s.sequencia[a + 1]

        for cid in constr.cidades
            custo = constr.dados.dist[i, cid] +
                    constr.dados.dist[cid, j] -
                    constr.dados.dist[i, j]

            push!(constr.custoInsercao,
                  InsertionInfo(cid, a, custo))
        end
    end
end

# ---------------------------------------------------------
# Inserção efetiva na solução
# ---------------------------------------------------------
function inserirNaSolucao!(constr::Construction, s::Solution, info::InsertionInfo)

    pos = info.arestaRemovida
    cidade = info.noInserido

    insert!(s.sequencia, pos + 1, cidade)

    empty!(constr.custoInsercao)

    idx = findfirst(==(cidade), constr.cidades)
    if idx !== nothing
        deleteat!(constr.cidades, idx)
    end
end
