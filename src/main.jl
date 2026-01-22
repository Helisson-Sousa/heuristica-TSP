# =================== main.jl ===================

# ---- Includes dos módulos ----
include(joinpath(@__DIR__, "Data.jl"))
include(joinpath(@__DIR__, "Solution.jl"))
include(joinpath(@__DIR__, "Construction.jl"))
include(joinpath(@__DIR__, "LocalSearch.jl"))
include(joinpath(@__DIR__, "Perturbation.jl"))
include(joinpath(@__DIR__, "ILS.jl"))

# Leitor TSPLIB
include("../tspreader.jl")

using Printf
using Random

function main()
    if length(ARGS) < 1
        println("Uso: julia main.jl <caminho_para_instancia.tsp>")
        return
    end

    # -----------------------------
    # Leitura da instância
    # -----------------------------
    instancia_path = ARGS[1]
    instance_name = splitext(basename(instancia_path))[1]

    data = Data(2, instancia_path)
    read!(data)

    @printf("Instância: %s\n", instance_name)
    @printf("Dimensão: %d\n", data.dimension)

    # -----------------------------
    # Parâmetros do ILS
    # -----------------------------
    maxIter = 50
    maxIterILS = data.dimension >= 150 ? div(data.dimension, 2) : data.dimension

    # Seed opcional (reprodutibilidade)
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
    @printf("Custo da melhor solução: %.2f\n", bestSol.cost)
    @printf("Sequência final (%d cidades)\n", length(bestSol.sequence) - 1)

    # Opcional: imprimir rota
    # println(bestSol.sequence)
end

main()
