# =================== ILS.jl ===================

function ILS(dados::Data, maxIter::Int, maxIterILS::Int)

    bestOfAll = Solution(Inf)

    constr = Construction(dados)
    busca  = LocalSearch(dados)
    pert   = Perturbation(dados)

    for it in 1:maxIter

        s = solucaoInicial(constr)

        best = copy(s)

        iterILS = 0

        while iterILS <= maxIterILS

            RVND!(busca, s)

            if s.cost < best.cost
                best = copy(s)
                iterILS = 0
            end

            s = mecanismoPert!(pert, best)

            iterILS += 1
        end

        if best.cost < bestOfAll.cost
            bestOfAll = copy(best)
        end
    end

    return bestOfAll
end
