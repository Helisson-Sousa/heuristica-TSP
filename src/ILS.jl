# =================== ILS.jl ===================

function solution_ILS(dados::Data, maxIter::Int, maxIterILS::Int)

    # Melhor solução global
    bestOfAll = Solution(typemax(Int))

    # Estruturas
    constr = Construction(dados)
    busca  = LocalSearch(dados)
    pert   = Perturbation(dados)

    for _ in 1:maxIter

        # -------- Construção + Busca Local --------
        solAtual = solucaoInicial(constr)
        RVND!(busca, solAtual)

        # Melhor da iteração
        best = copy(solAtual)
        iterILS = 0

        # -------- Loop ILS --------
        while iterILS < maxIterILS

            solAtual = mecanismoPert(pert, best)
            RVND!(busca, solAtual)

            if solAtual.valorObj < best.valorObj
                best = copy(solAtual)
                iterILS = 0
            else
                iterILS += 1
            end
        end

        # -------- Atualiza melhor global --------
        if best.valorObj < bestOfAll.valorObj
            bestOfAll = copy(best)
        end
    end

    return bestOfAll
end
