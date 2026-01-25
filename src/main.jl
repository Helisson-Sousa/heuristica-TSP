# =========================================================
# main.jl
# Execução do ILS para o TSP usando Data do tspreader.jl
# =========================================================

# -----------------------------
# Includes dos módulos
# -----------------------------
include(joinpath(@__DIR__, "tspreader.jl"))
include(joinpath(@__DIR__, "Solution.jl"))
include(joinpath(@__DIR__, "Construction.jl"))
include(joinpath(@__DIR__, "LocalSearch.jl"))
include(joinpath(@__DIR__, "Perturbation.jl"))
include(joinpath(@__DIR__, "ILS.jl"))

using Printf
using Random

function main()

    instancia_path = joinpath(@__DIR__, "../instances/burma14.tsp")

    data = Data(2, instancia_path)
    read!(data)

    @printf("\nInstância: %s\n", getInstanceName(data))
    @printf("Dimensão: %d\n", data.dimension)

    maxIter = 50
    maxIterILS = data.dimension >= 150 ? div(data.dimension, 2) : data.dimension

    Random.seed!(time_ns())

    start_time = time()
    bestSol = ILS(data, maxIter, maxIterILS)
    elapsed = time() - start_time

    @printf("\nTempo de execução: %.4f segundos\n", elapsed)
    @printf("Custo da melhor solução: %.2f\n", bestSol.cost)
    @printf("Sequência final (%d cidades)\n", length(bestSol.sequence) - 1)

end

main()
