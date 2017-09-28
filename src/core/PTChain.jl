module PTChain

using MHChain

export sampleTempering

function sampleTempering(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, swapIter)
    num_temps = length(temps)
    out = zeros(shape(start_x)..., num_temps, swapIter)
    out[:, :, 1] = repmat(start_x, 1, num_temps)
    #TODO: parallelize
    for i = 2:swapIter
        for j = 1:num_temps
            out[:, j, i], values = runChain(out[:,j, i - 1], optimFunction, temps[j], proposalFunction, iterBetweenSwaps, 1)
        end
    end
    return out
    #ptSwaps(x, values, temps)
end

# function ptSwaps!(x, values, temps)
#     for i = length(temps):-1:2
#         Δt = (temps[i] - temps[i-1])
#         Δe = (values[i] - values[i-1])
#         if (Δt/Δe > log(rand()))
#             x[:, i], x[:, i - 1] = x[:,i - 1], x[:,i]
#             values[i], values[i -1] = values[i - 1], values[i]
#         end
#     end
# end


end
