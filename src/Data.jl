# =========================================================
# Data.jl
# Wrapper leve sobre tspreader.jl
# =========================================================

mutable struct TSPData
    dimension::Int
    dist::Matrix{Float64}
    instanceName::String
end

"""
    TSPData(instancePath::String)

Cria a estrutura de dados do TSP a partir de um arquivo TSPLIB
usando tspreader.jl
"""
function TSPData(instancePath::String)

    data = Data(2, instancePath)
    read!(data)

    return TSPData(
        data.dimension,
        data.distMatrix,
        getInstanceName(data)
    )
end
