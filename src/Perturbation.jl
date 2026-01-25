# =================== Perturbation.jl ===================

mutable struct Perturbation
    data::Data
end

# Double-Bridge / Block Swap Perturbation

function mecanismoPert!(p::Perturbation, best::Solution)::Solution

    s = copy(best)
    seq = s.sequence
    n = length(seq) - 1 

    maxTam = max(2, div(n, 10))

    tam1 = rand(2:maxTam)
    tam2 = rand(2:maxTam)

    i = rand(2:(n - tam1 - 1))

    j = rand(2:(n - tam2 - 1))
    while (j >= i && j <= i + tam1) || (i >= j && i <= j + tam2)
        j = rand(2:(n - tam2 - 1))
    end

    bloco1 = seq[i:(i + tam1 - 1)]
    bloco2 = seq[j:(j + tam2 - 1)]

    if j > i
        deleteat!(seq, j:(j + tam2 - 1))
        deleteat!(seq, i:(i + tam1 - 1))

        for v in reverse(bloco2)
            insert!(seq, i, v)
        end
        
        for v in reverse(bloco1)
            insert!(seq, j - tam1 + tam2, v)
        end
        
    else
        deleteat!(seq, i:(i + tam1 - 1))
        deleteat!(seq, j:(j + tam2 - 1))

        for v in reverse(bloco1)
            insert!(seq, j, v)
        end
        
        for v in reverse(bloco2)
            insert!(seq, i - tam2 + tam1, v)
        end
    end

    seq[end] = seq[1]

    dist = p.data.distMatrix
    s.cost = 0.0
    for k in 1:length(seq)-1
        s.cost += dist[seq[k], seq[k+1]]
    end

    return s
end
