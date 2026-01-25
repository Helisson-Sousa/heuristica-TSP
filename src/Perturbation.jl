# =================== Perturbation.jl ===================

mutable struct Perturbation
    data::Data
end

function mecanismoPert!(p::Perturbation, best::Solution)::Solution

    s   = copy(best)
    seq = s.sequence
    n   = p.data.dimension
    dist = p.data.distMatrix

    # Tamanhos dos blocos (igual ao C++)
    maxTam = div(n, 10)
    tam1 = 2 + rand(0:maxTam-1)
    tam2 = 2 + rand(0:maxTam-1)

    # Escolha da posição i
    i = 2 + rand(0:(n - tam1 - 2))

    # Escolha da posição j (sem sobreposição)
    j = 0
    while true
        j = 2 + rand(0:(n - tam2 - 2))
        if !((j >= i && j < i + tam1) || (i >= j && i < j + tam2))
            break
        end
    end

    # Blocos
    bloco_i = seq[i:(i + tam1 - 1)]
    bloco_j = seq[j:(j + tam2 - 1)]

    # Vértices auxiliares
    vi        = seq[i]
    vi_prev   = seq[i - 1]
    vi2       = seq[i + tam1 - 1]
    vi2_next  = seq[i + tam1]

    vj        = seq[j]
    vj_prev   = seq[j - 1]
    vj2       = seq[j + tam2 - 1]
    vj2_next  = seq[j + tam2]

    # Cálculo de custo (idêntico ao C++)
    custoRetirada = 0.0
    custoInsercao = 0.0

    if j == i + tam1
        custoRetirada =
            dist[vi_prev, vi] +
            dist[vi2, vj] +
            dist[vj2, vj2_next]

        custoInsercao =
            dist[vi_prev, vj] +
            dist[vj2, vi] +
            dist[vi2, vj2_next]

    elseif i == j + tam2
        custoRetirada =
            dist[vi_prev, vi] +
            dist[vi2, vi2_next] +
            dist[vj_prev, vj]

        custoInsercao =
            dist[vj_prev, vi] +
            dist[vi2, vj] +
            dist[vj2, vi2_next]

    else
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

    s.cost = s.cost - custoRetirada + custoInsercao

    # ================== REINSERÇÃO CORRETA ==================

    if j > i
        deleteat!(seq, j:(j + tam2 - 1))
        deleteat!(seq, i:(i + tam1 - 1))

        splice!(seq, i:i-1, bloco_j)

        novaPos_j = j - tam1 + tam2
        splice!(seq, novaPos_j:novaPos_j-1, bloco_i)

    else
        deleteat!(seq, i:(i + tam1 - 1))
        deleteat!(seq, j:(j + tam2 - 1))

        splice!(seq, j:j-1, bloco_i)

        novaPos_i = i - tam2 + tam1
        splice!(seq, novaPos_i:novaPos_i-1, bloco_j)
    end

    return s
end
