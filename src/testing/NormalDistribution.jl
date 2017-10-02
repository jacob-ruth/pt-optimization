using PTChain
using ProposalFunctions

f(x) = x[1]^2 + x[2]^2
@timev x = sampleTempering(randn(2), f, [0.1, 1], widescaleRandomNoise, 5, 10000)

function g(x)
    i = 0
    while i < x
        i = i + 1
        k = rand()
    end
    i
end
