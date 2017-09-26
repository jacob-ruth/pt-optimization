using MHChain
using ProposalFunctions

f(x) = tanh(sin(x^2))

samples = runChain(100*randn(), f, 1, widescaleRandomNoise, 1000, 100)

using Plots
gr()
