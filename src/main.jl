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

    # -----------------------------
    # Definir caminho da instância
    # -----------------------------
    instancia_path = ""
    if length(ARGS) >= 1
        instancia_path = ARGS[1]
    else
        # Valor padrão: sempre burma14.tsp
        instancia_path = joinpath(@__DIR__, "../instances/burma14.tsp")
        println("Nenhum argumento passado, usando instância padrão burma14.tsp:")
        println(instancia_path)
    end

    # -----------------------------
    # Cria estrutura Data e lê arquivo
    # -----------------------------
    data = Data(2, instancia_path)
    read!(data)

    @printf("\nInstância: %s\n", getInstanceName(data))
    @printf("Dimensão: %d\n", data.dimension)

    # -----------------------------
    # Parâmetros do ILS
    # -----------------------------
    maxIter = 50
    maxIterILS = data.dimension >= 150 ? div(data.dimension, 2) : data.dimension

    Random.seed!(time_ns())

    # -----------------------------
    # Execução do ILS
    # -----------------------------
    start_time = time()
    bestSol = ILS(data, maxIter, maxIterILS)
    elapsed = time() - start_time

    # -----------------------------
    # Resultados
    # -----------------------------
    @printf("\nTempo de execução: %.4f segundos\n", elapsed)
    @printf("Custo da melhor solução: %.2f\n", bestSol.valorObj)
    @printf("Sequência final (%d cidades)\n", length(bestSol.sequence) - 1)

    # Uncomment para imprimir a sequência completa
    # println(bestSol.sequence)
end

main()
