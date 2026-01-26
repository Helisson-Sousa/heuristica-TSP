# =================== LocalSearch.jl ===================

mutable struct LocalSearch
    data::Data
end

# Swap (Best Improvement)

function bestImprovementSwap!(ls::LocalSearch, s::Solution)::Bool
    best_i = -1
    best_j = -1
    bestCost = s.cost

    seq = s.sequence
    n = length(seq)

    for i in 2:n-1
        vi = seq[i]
        vi_prev = seq[i-1]
        vi_next = seq[i+1]

        for j in i+1:n-1
            vj = seq[j]
            vj_prev = seq[j-1]
            vj_next = seq[j+1]

            if j - i == 1
                custoRetirada =
                    ls.data.distMatrix[vi_prev, vi] +
                    ls.data.distMatrix[vi, vj] +
                    ls.data.distMatrix[vj, vj_next]

                custoInsercao =
                    ls.data.distMatrix[vi_prev, vj] +
                    ls.data.distMatrix[vj, vi] +
                    ls.data.distMatrix[vi, vj_next]
            else
                custoRetirada =
                    ls.data.distMatrix[vi_prev, vi] +
                    ls.data.distMatrix[vi, vi_next] +
                    ls.data.distMatrix[vj_prev, vj] +
                    ls.data.distMatrix[vj, vj_next]

                custoInsercao =
                    ls.data.distMatrix[vi_prev, vj] +
                    ls.data.distMatrix[vj, vi_next] +
                    ls.data.distMatrix[vj_prev, vi] +
                    ls.data.distMatrix[vi, vj_next]
            end

            cost = s.cost - custoRetirada + custoInsercao

            if cost < bestCost
                bestCost = cost
                best_i = i
                best_j = j
            end
        end
    end

    if best_i != -1
        seq[best_i], seq[best_j] = seq[best_j], seq[best_i]
        s.cost = bestCost
        return true
    end

    return false
end

# Reinsertion (Best Improvement)

function bestImprovementReInsertion!(ls::LocalSearch, s::Solution)::Bool
    best_i = -1
    best_j = -1
    bestCost = s.cost

    seq = s.sequence
    n = length(seq)

    for i in 2:n-1
        vi = seq[i]
        vi_prev = seq[i-1]
        vi_next = seq[i+1]

        for j in 2:n-1
            if j == i || abs(j - i) == 1
                continue
            end

            vj = seq[j]
            vj_prev = seq[j-1]

            custoRetirada =
                ls.data.distMatrix[vi_prev, vi] +
                ls.data.distMatrix[vi, vi_next] +
                ls.data.distMatrix[vj_prev, vj]

            custoInsercao =
                ls.data.distMatrix[vi_prev, vi_next] +
                ls.data.distMatrix[vj_prev, vi] +
                ls.data.distMatrix[vi, vj]

            cost = s.cost - custoRetirada + custoInsercao

            if cost < bestCost
                bestCost = cost
                best_i = i
                best_j = j
            end
        end
    end

    if best_i != -1
        city = seq[best_i]
        deleteat!(seq, best_i)

        if best_j > best_i
            best_j -= 1
        end

        insert!(seq, best_j, city)
        s.cost = bestCost
        return true
    end

    return false
end

# Or-Opt (tamBloco = 2 ou 3)

function bestImprovementOrOpt!(ls::LocalSearch, s::Solution, tamBloco::Int)::Bool
    best_i1 = -1
    best_i2 = -1
    best_j = -1
    bestCost = s.cost

    seq = s.sequence
    n = length(seq)

    for i in 2:n-tamBloco
        vi1 = seq[i]
        vi1_prev = seq[i-1]
        vi2 = seq[i+tamBloco-1]
        vi2_next = seq[i+tamBloco]

        for j in 2:n
            if j >= i && j <= i + tamBloco
                continue
            end

            vj = seq[j]
            vj_prev = seq[j-1]

            custoRetirada =
                ls.data.distMatrix[vi1_prev, vi1] +
                ls.data.distMatrix[vi2, vi2_next] +
                ls.data.distMatrix[vj_prev, vj]

            custoInsercao =
                ls.data.distMatrix[vi1_prev, vi2_next] +
                ls.data.distMatrix[vj_prev, vi1] +
                ls.data.distMatrix[vi2, vj]

            cost = s.cost - custoRetirada + custoInsercao

            if cost < bestCost
                bestCost = cost
                best_i1 = i
                best_i2 = i + tamBloco - 1
                best_j = j
            end
        end
    end

    if best_i1 != -1
        bloco = seq[best_i1:best_i2]
        deleteat!(seq, best_i1:best_i2)

        if best_j > best_i1
            best_j -= tamBloco
        end

        for (k, v) in enumerate(bloco)
            insert!(seq, best_j + k - 1, v)
        end

        s.cost = bestCost
        return true
    end

    return false
end

# 2-Opt (Best Improvement)

function bestImprovement2Opt!(ls::LocalSearch, s::Solution)::Bool
    seq = s.sequence
    n = length(seq) - 1

    bestDelta = 0
    best_i = 0
    best_j = 0

    for i in 2:n-2
        for j in i+2:n
            delta = -ls.data.distMatrix[seq[i-1], seq[i]] -
                     ls.data.distMatrix[seq[j], seq[j+1]] +
                     ls.data.distMatrix[seq[i-1], seq[j]] +
                     ls.data.distMatrix[seq[i], seq[j+1]]

            if delta < bestDelta
                bestDelta = delta
                best_i = i
                best_j = j
            end
        end
    end

    if bestDelta < 0
        seq[best_i:best_j] = reverse(seq[best_i:best_j])
        s.cost += bestDelta
        return true
    end

    return false
end

# RVND

function RVND!(ls::LocalSearch, s::Solution)
    movimentos = [1, 2, 3, 4, 5]

    while !isempty(movimentos)
        n = rand(1:length(movimentos))
        mov = movimentos[n]
        improved = false

        if mov == 1
            improved = bestImprovementSwap!(ls, s)
        elseif mov == 2
            improved = bestImprovement2Opt!(ls, s)
        elseif mov == 3
            improved = bestImprovementReInsertion!(ls, s)
        elseif mov == 4
            improved = bestImprovementOrOpt!(ls, s, 2)
        elseif mov == 5
            improved = bestImprovementOrOpt!(ls, s, 3)
        end

        if improved
            movimentos = [1, 2, 3, 4, 5]
        else
            deleteat!(movimentos, n)
        end
    end
end
