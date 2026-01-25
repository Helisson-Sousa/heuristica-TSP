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
    best_i = -1
    best_j = -1
    bestCost = s.cost

    seq = s.sequence
    n = length(seq)

    for i in 2:n-2
        vi = seq[i]
        vi_prev = seq[i-1]

        for j in i+2:n-1
            vj = seq[j]
            vj_next = seq[j+1]

            custoRetirada =
                ls.data.distMatrix[vi_prev, vi] +
                ls.data.distMatrix[vj, vj_next]

            custoInsercao =
                ls.data.distMatrix[vi_prev, vj] +
                ls.data.distMatrix[vi, vj_next]

            for k in i:j-1
                custoRetirada += ls.data.distMatrix[seq[k], seq[k+1]]
                custoInsercao += ls.data.distMatrix[seq[k+1], seq[k]]
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
        reverse!(seq[best_i:best_j])
        s.cost = bestCost
        return true
    end

    return false
end

# RVND

function RVND!(ls::LocalSearch, s::Solution)
    movimentos = [1, 2, 3, 4, 5]

    while !isempty(movimentos)
        n = rand(1:length(movimentos))
        
        improved = false

        if movimentos[n] == 1
            improved = bestImprovementSwap!(ls, s)
        elseif movimentos[n] == 2
            improved = bestImprovement2Opt!(ls, s)
        elseif movimentos[n] == 3
            improved = bestImprovementReInsertion!(ls, s)
        elseif movimentos[n] == 4
            improved = bestImprovementOrOpt!(ls, s, 2)
        elseif movimentos[n] == 5
            improved = bestImprovementOrOpt!(ls, s, 3)
        end
        println(" Aplicando movimento $(movimentos[n]) / $n / $improved")
        sleep(1.0)
        if improved
            movimentos = [1, 2, 3, 4, 5]
        else
            deleteat!(movimentos, n)
        end
    end
end
