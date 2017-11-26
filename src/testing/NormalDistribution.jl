import PTChain
import ProposalFunctions

f(x) = sum(x.^2)

@timev x = PTChain.sampleTempering(randn(3), f, [0.1, 1], ProposalFunctions.widescaleRandomNoise, 5, 10000)
