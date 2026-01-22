# =================== Perturbation.jl ===================

mutable struct Perturbation
    data::Data
end

# ---------------------------------------------------
# Double-Bridge / Block Swap Perturbation
# ---------------------------------------------------
function mecanismoPert!(p::Perturbation, best::Solution)::Solution
    # cópia da solução
    s = Solution(copy(best.sequence), best.cost)

    n = p.data.dimension

    # tamanhos dos blocos
    tamPrimBloco = 2 + rand(0:div(n, 10))
    i = 2 + rand(0:(n - tamPrimBloco - 2))

    tamSegBloco = 2 + rand(0:div(n, 10))
    j = 0

    # garante que os blocos não se sobrepõem
    while true
        j = 2 + rand(0:(n - tamSegBloco - 2))
        if !((j >= i && j < i + tamPrimBloco) || (i >= j && i < j + tamSegBloco))
            break
        end
    end

    seq = s.sequence

    # ----------------- Blocos -----------------
    bloco_i = seq[i:(i + tamPrimBloco - 1)]
    bloco_j = seq[j:(j + tamSegBloco - 1)]

    # ----------------- Vértices de referência -----------------
    vi = seq[i]
    vi_prev = seq[i - 1]
    vi2 = seq[i + tamPrimBloco - 1]
    vi2_next = seq[i + tamPrimBloco]

    vj = seq[j]
    vj_prev = seq[j - 1]
    vj2 = seq[j + tamSegBloco - 1]
    vj2_next = seq[j + tamSegBloco]

    custoRetirada = 0.0
    custoInsercao = 0.0

    # ----------------- Cálculo incremental -----------------
    if j == i + tamPrimBloco
        # j > i (blocos adjacentes)
        custoRetirada =
            p.data.dist[vi_prev, vi] +
            p.data.dist[vi2, vj] +
            p.data.dist[vj2, vj2_next]

        custoInsercao =
            p.data.dist[vi_prev, vj] +
            p.data.dist[vj2, vi] +
            p.data.dist[vi2, vj2_next]

    elseif i == j + tamSegBloco
        # j < i (blocos adjacentes)
        custoRetirada =
            p.data.dist[vi_prev, vi] +
            p.data.dist[vi2, vi2_next] +
            p.data.dist[vj_prev, vj]

        custoInsercao =
            p.data.dist[vj_prev, vi] +
            p.data.dist[vi2, vj] +
            p.data.dist[vj2, vi2_next]

    else
        # blocos separados
        custoRetirada =
            p.data.dist[vi_prev, vi] +
            p.data.dist[vi2, vi2_next] +
            p.data.dist[vj_prev, vj] +
            p.data.dist[vj2, vj2_next]

        custoInsercao =
            p.data.dist[vi_prev, vj] +
            p.data.dist[vj2, vi2_next] +
            p.data.dist[vj_prev, vi] +
            p.data.dist[vi2, vj2_next]
    end

    s.cost = s.cost - custoRetirada + custoInsercao

    # ----------------- Troca dos blocos -----------------
    if j > i
        deleteat!(seq, j:(j + tamSegBloco - 1))
        deleteat!(seq, i:(i + tamPrimBloco - 1))

        insert!(seq, i, bloco_j...)
        novaPosicao_j = j - tamPrimBloco + tamSegBloco
        insert!(seq, novaPosicao_j, bloco_i...)
    else
        deleteat!(seq, i:(i + tamPrimBloco - 1))
        deleteat!(seq, j:(j + tamSegBloco - 1))

        insert!(seq, j, bloco_i...)
        novaPosicao_i = i - tamSegBloco + tamPrimBloco
        insert!(seq, novaPosicao_i, bloco_j...)
    end

    return s
end
