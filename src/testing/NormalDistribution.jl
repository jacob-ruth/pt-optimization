using MHChain
using ProposalFunctions
using PTChain
using Plots

f(x) = x[1]^2 + x[2]^2

@time samples = sampleTempering(randn(2), f, [1, 4], widescaleRandomNoise, 50, 10000)
plotly()
p1 = scatter(samples[1,1,:], samples[2,1,:])
p2 = scatter(samples[1,2,:], samples[2,2,:])
a = plot(p1, p2, layout=(2,1))
gui()
