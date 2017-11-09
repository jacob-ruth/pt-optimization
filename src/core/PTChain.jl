module PTChain

using MHChain

export sampleTempering, simulatedAnnealing


function simulatedAnnealing(start_x, optimFunction, temps, proposalFunction, itersAtTemp)
    assert(length(temps) == length(itersAtTemp))
    x = start_x
    min_x = copy(x)
    min_val = optimFunction(min_x)
    statsDict = []
    results = zeros(length(x), length(temps))
    for j = 1:length(temps)
        val, x, best_val, best_x, stats = runChain(x, optimFunction, temps[j], proposalFunction, itersAtTemp[j])
        push!(statsDict, stats)
        if best_val < min_val
            min_val = copy(best_val)
            min_x = copy(best_x)
        end
        results[:, j] = x
        print(j)
    end
    min_val, min_x, statsDict, results
end

function sampleTempering(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, numSwaps)
    num_temps = length(temps)
    out = repmat(start_x, 1, num_temps)
    func_values = zeros(num_temps)
    func_values[:] = optimFunction(start_x)
    min_val =  optimFunction(start_x)
    statsDict = Array{Dict}(num_temps, numSwaps)
    min_x = copy(start_x)
    for i = 1:numSwaps
        for j = 1:num_temps
            func_values[j], out[:, j], best_val, best_x, stats = runChain(out[:,j], optimFunction, temps[j], proposalFunction, iterBetweenSwaps)
            statsDict[j, i] = stats
            if best_val < min_val
                min_val = copy(best_val)
                min_x = copy(best_x)
            end
        end
        temps = insSwap(func_values, temps)
    end

    return min_val, min_x, statsDict
end

function insSwap(values, temps)
    sort!(temps)
    ai = sortperm(values)
    temps[ai]
    #possibly record a swap update
end

end
