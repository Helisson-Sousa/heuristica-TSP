# ---------------------------------------------------------
# Data.jl
# Wrapper leve sobre tspreader.jl
# ---------------------------------------------------------

include(joinpath(@__DIR__, "tspreader.jl"))

mutable struct TSPData
    dimension::Int
    dist::Matrix{Float64}
    instanceName::String
end

"""
    TSPData(instancePath::String)

Cria a estrutura de dados do TSP a partir de um arquivo TSPLIB.
"""
function TSPData(instancePath::String)

    # reaproveita exatamente o que você já implementou
    data = Data(2, instancePath)
    read!(data)

    return TSPData(
        data.dimension,
        data.distMatrix,
        getInstanceName(data)
    )
end
