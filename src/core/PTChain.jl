module PTChain

using MHChain

export sampleTempering

function sampleTempering(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps)
    num_temps = length(temps)
    out = repmat(start_x, 1, num_temps)
    func_values = zeros(num_temps)
    func_values[:] = optimFunction(start_x)
    #TODO: parallelize
    c = 0
    while minimum(func_values) > 0
         Threads.@threads for j = 1:num_temps
            func_values[j], out[:, j] = runChain(out[:,j], optimFunction, temps[j], proposalFunction, iterBetweenSwaps)
        end
        c = c + 1
        insSwap!(func_values, temps)
    end

    return c, out
end

function insSwap!(values, temps)
    sort!(temps)
    ai = sortperm(values)
    temps = temps[ai]
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
