# =================== ILS.jl ===================

function ILS(dados::Data, maxIter::Int, maxIterILS::Int)

    println(">> ILS iniciado")

    bestOfAll = Solution(Inf)

    constr = Construction(dados)
    busca  = LocalSearch(dados)
    pert   = Perturbation(dados)

    for it in 1:maxIter
        solAtual = solucaoInicial(constr)

        RVND!(busca, solAtual)

        best = copy(solAtual)
        iterILS = 0

        maxPerturb = 200
        contPerturb = 0

        while iterILS < maxIterILS && contPerturb < maxPerturb
            contPerturb += 1

            solAtual = mecanismoPert!(pert, best)
            println("        Perturbação aplicada")

            RVND!(busca, solAtual)

            if solAtual.cost < best.cost
                println("        Melhora encontrada")
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

    println(">> ILS terminou")
    return bestOfAll
end
