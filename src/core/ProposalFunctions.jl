module ProposalFunctions

export swapTwo, widescaleRandomNoise

function swapTwo(x)
    n = length(x)
    index1 = rand(1:n)
    index2 = rand(1:n)
    new_x = x
    new_x[index1], new_x[index2] = x[index2], x[index1]
    new_x
end

function widescaleRandomNoise(x::Vector{Float64})
    n = length(x)
    expon = rand()*5.0 - 2.0
    displacement = randn(n)
    new_x = x + displacement*2^expon
end

function widescaleRandomNoise(x::Float64)
    expon = rand()*5.0
    displacement = randn()
    new_x = x + displacement * 2^expon
end

end
