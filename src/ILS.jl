# =================== ILS.jl ===================

function ILS(dados::Data, maxIter::Int, maxIterILS::Int)

    # Melhor solução global
    bestOfAll = Solution(Int[], Inf)

    constr = Construction(dados)
    busca  = LocalSearch(dados)
    pert   = Perturbation(dados)

    for _ in 1:maxIter

        # ---------- Construção + Busca Local ----------
        solAtual = solucaoInicial(constr)
        RVND!(busca, solAtual)

        # Melhor solução da iteração
        best = Solution(copy(solAtual.sequence), solAtual.cost)
        iterILS = 0

        # ---------- Loop ILS ----------
        while iterILS < maxIterILS

            # Perturba a melhor solução atual
            solAtual = mecanismoPert!(pert, best)
            RVND!(busca, solAtual)

            # Critério de aceitação
            if solAtual.cost < best.cost
                best = Solution(copy(solAtual.sequence), solAtual.cost)
                iterILS = 0
            else
                iterILS += 1
            end
        end

        # Atualiza melhor global
        if best.cost < bestOfAll.cost
            bestOfAll = Solution(copy(best.sequence), best.cost)
        end
    end

    return bestOfAll
end
