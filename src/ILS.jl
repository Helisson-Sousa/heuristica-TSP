# =================== ILS.jl ===================

function ILS(dados::Data, maxIter::Int, maxIterILS::Int)

    bestOfAll = Solution(Inf)

    constr = Construction(dados)
    busca  = LocalSearch(dados)
    pert   = Perturbation(dados)

    for it in 1:maxIter
        println("===== ILS externo: iteração $it / $maxIter =====")

        s = solucaoInicial(constr)

        best = copy(s)

        iterILS = 0
        a = 0
        b = 0

        while iterILS <= maxIterILS
            a = s.cost
            b = best.cost

            println("===== ILS interno: iteração $iterILS / $maxIterILS / $a / $b =====")

            RVND!(busca, s)

            println(" Custo após RVND: $(s.cost)")

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
