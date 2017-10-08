module PTChain

using MHChain

export sampleTempering, simulatedAnnealing


function simulatedAnnealing(start_x, optimFunction, temps, proposalFunction, itersAtTemp)
    assert(length(temps) == length(itersAtTemp))
    x = start_x
    min_x = copy(x)
    min_val = optimFunction(min_x)
    for i = 1:length(temps)
        val, x, best_val, best_x = runChain(x, optimFunction, temps[i], proposalFunction, itersAtTemp[i])
        if best_val < min_val
            min_val = copy(best_val)
            min_x = copy(best_x)
        end
    end
    min_val, min_x
end

function sampleTempering(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps)
    num_temps = length(temps)
    out = repmat(start_x, 1, num_temps)
    func_values = zeros(num_temps)
    func_values[:] = optimFunction(start_x)
    min_val =  optimFunction(start_x)
    min_x = copy(start_x)
    #TODO: parallelize
    c = 0
    while min_val > 0
        for j = 1:num_temps
            func_values[j], out[:, j], best_val, best_x = runChain(out[:,j], optimFunction, temps[j], proposalFunction, iterBetweenSwaps)
            if best_val < min_val
                min_val = copy(best_val)
                min_x = copy(best_x)
            end
        end
        c = c + 1
        insSwap!(func_values, temps)
    end

    return c, min_x
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
