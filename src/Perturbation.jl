# =================== Perturbation.jl ===================

mutable struct Perturbation
    data::Data
end

# ---------------------------------------------------
# Double-Bridge / Block Swap Perturbation
# Retorna uma NOVA solução
# ---------------------------------------------------
function mecanismoPert!(p::Perturbation, best::Solution)::Solution

    # cópia da solução
    s = Solution(copy(best.sequence), best.cost)

    n = length(s.sequence) - 1  # ignora o último 1 repetido

    # tamanhos dos blocos
    tamPrimBloco = 2 + rand(0:div(n, 10))
    i = 2 + rand(0:(n - tamPrimBloco - 2))

    tamSegBloco = 2 + rand(0:div(n, 10))
    j = 0

    # garante que os blocos não se sobrepõem
    while true
        j = 2 + rand(0:(n - tamSegBloco - 2))
        if !((j >= i && j < i + tamPrimBloco) ||
             (i >= j && i < j + tamSegBloco))
            break
        end
    end

    seq = s.sequence
    dist = p.data.distMatrix

    # ----------------- Blocos -----------------
    bloco_i = seq[i:(i + tamPrimBloco - 1)]
    bloco_j = seq[j:(j + tamSegBloco - 1)]

    # ----------------- Vértices de referência -----------------
    vi       = seq[i]
    vi_prev  = seq[i - 1]
    vi2      = seq[i + tamPrimBloco - 1]
    vi2_next = seq[i + tamPrimBloco]

    vj       = seq[j]
    vj_prev  = seq[j - 1]
    vj2      = seq[j + tamSegBloco - 1]
    vj2_next = seq[j + tamSegBloco]

    custoRetirada = 0.0
    custoInsercao = 0.0

    # ----------------- Cálculo incremental -----------------
    if j == i + tamPrimBloco
        # blocos adjacentes (j > i)
        custoRetirada =
            dist[vi_prev, vi] +
            dist[vi2, vj] +
            dist[vj2, vj2_next]

        custoInsercao =
            dist[vi_prev, vj] +
            dist[vj2, vi] +
            dist[vi2, vj2_next]

    elseif i == j + tamSegBloco
        # blocos adjacentes (j < i)
        custoRetirada =
            dist[vi_prev, vi] +
            dist[vi2, vi2_next] +
            dist[vj_prev, vj]

        custoInsercao =
            dist[vj_prev, vi] +
            dist[vi2, vj] +
            dist[vj2, vi2_next]

    else
        # blocos separados
        custoRetirada =
            dist[vi_prev, vi] +
            dist[vi2, vi2_next] +
            dist[vj_prev, vj] +
            dist[vj2, vj2_next]

        custoInsercao =
            dist[vi_prev, vj] +
            dist[vj2, vi2_next] +
            dist[vj_prev, vi] +
            dist[vi2, vj2_next]
    end

    # atualiza custo
    s.cost = s.cost - custoRetirada + custoInsercao

    # ----------------- Troca dos blocos -----------------
    # ----------------- Troca dos blocos -----------------
    if j > i
        # remove primeiro o bloco mais à direita
        deleteat!(seq, j:(j + tamSegBloco - 1))
        deleteat!(seq, i:(i + tamPrimBloco - 1))

        # insere bloco_j em i
        for (k, v) in enumerate(bloco_j)
            insert!(seq, i + k - 1, v)
        end

        novaPos_j = j - tamPrimBloco + tamSegBloco

        # insere bloco_i na nova posição
        for (k, v) in enumerate(bloco_i)
            insert!(seq, novaPos_j + k - 1, v)
        end

    else
        # remove primeiro o bloco mais à direita
        deleteat!(seq, i:(i + tamPrimBloco - 1))
        deleteat!(seq, j:(j + tamSegBloco - 1))

        # insere bloco_i em j
        for (k, v) in enumerate(bloco_i)
            insert!(seq, j + k - 1, v)
        end

        novaPos_i = i - tamSegBloco + tamPrimBloco

        # insere bloco_j na nova posição
        for (k, v) in enumerate(bloco_j)
            insert!(seq, novaPos_i + k - 1, v)
        end
    end

    seq[end] = seq[1]

    return s
end
