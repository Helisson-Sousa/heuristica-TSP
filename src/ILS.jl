# =================== ILS.jl ===================

function ILS(dados::Data, maxIter::Int, maxIterILS::Int)

    bestOfAll = Solution(Inf)

    constr = Construction(dados)
    busca  = LocalSearch(dados)
    pert   = Perturbation(dados)

    for _ in 1:maxIter

        solAtual = solucaoInicial(constr)
        RVND!(busca, solAtual)

        best = copy(solAtual)
        iterILS = 0

        while iterILS < maxIterILS

            solAtual = mecanismoPert(pert, best)
            RVND!(busca, solAtual)

            if solAtual.cost < best.cost
                best = copy(solAtual)
                iterILS = 0
            else
                iterILS += 1
            end
        end

        if best.cost < bestOfAll.cost
            bestOfAll = copy(best)
        end
    end

    return bestOfAll
end
