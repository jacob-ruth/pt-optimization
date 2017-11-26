module PTChain

export sampleTempering, simulatedAnnealing, greedyTempering

function runChain(start_x, optimFunction, temp, proposalFunction, iterations)
     #statsDict = Dict()
     #statsDict["changed-value"] = []
     #statsDict["new-min"] = []
     #statsDict["reps"] = iterations
     #statsDict["temp"] = temp
     x = start_x
     min_x = copy(start_x)
     best_val = optimFunction(min_x)
     val = copy(best_val)
     for i in 1:iterations
          new_x = proposalFunction(x)
          proposal_value = 0
           if length(new_x) == 2
                proposal_value = new_x[2] + val
                new_x = new_x[1]
                #assert(proposal_value == optimFunction(new_x))
           else
                proposal_value = optimFunction(new_x)
           end
          if ((temp == 0 && val > proposal_value) || (log(rand()) < (val - proposal_value) / temp))
               x = copy(new_x)
               val = proposal_value
               # record an update
               #push!(statsDict["changed-value"], [i, proposal_value])
          end
          if val < best_val
               #record a new min found
               #push!(statsDict["new-min"], [i, val])
               best_val = copy(val)
               min_x = copy(x)
          end
     end
     val, x, best_val, min_x#, statsDict
end



function simulatedAnnealing(start_x, optimFunction, temps, proposalFunction, itersAtTemp)
    assert(length(temps) == length(itersAtTemp))
    x = start_x
    min_x = copy(x)
    min_val = optimFunction(min_x)
    #statsDict = []
    #results = zeros(length(x), length(temps))
    for j = 1:length(temps)
        val, x, best_val, best_x = runChain(x, optimFunction, temps[j], proposalFunction, itersAtTemp[j])
        #push!(statsDict, stats)
        if best_val < min_val
            min_val = copy(best_val)
            min_x = copy(best_x)
        end
        #results[:, j] = x
	#println(val)
    end
    min_val, min_x#, results
end

function sampleTempering(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, num_swaps)
    num_temps = length(temps)
    x = repmat(start_x, 1, num_temps)
    func_values = zeros(num_temps)
    func_values[:] = optimFunction(start_x)
    min_val =  optimFunction(start_x)
    min_x = copy(start_x)
    plot_vals = zeros(num_temps, num_swaps)
    for i = 1:num_swaps
        for j = 1:num_temps
            func_values[j], x[:, j], best_val, best_x = runChain(x[:,j], optimFunction, temps[j], proposalFunction, iterBetweenSwaps)
            if best_val < min_val
                min_val = copy(best_val)
                min_x = copy(best_x)
            end
        end
        func_values, x = ptswap(func_values, temps, x)
        plot_vals[:, i] = func_values
    end
    return min_val, min_x, plot_vals
end

function greedyTempering(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, num_swaps)
    sort!(temps)
    num_temps = length(temps)
    out = SharedArray(repmat(start_x, 1, num_temps))
    func_values = zeros(num_temps)
    func_values[:] = optimFunction(start_x)
    min_val =  optimFunction(start_x)
    plot_vals = zeros(num_temps, num_swaps)
    min_x = copy(start_x)
    for i = 1:num_swaps
        for j = 1:num_temps
            func_values[j], out[:, j], best_val, best_x = runChain(out[:,j], optimFunction, temps[j], proposalFunction, iterBetweenSwaps)
            if best_val < min_val
                min_val = copy(best_val)
                min_x = copy(best_x)
            end
        end
        plot_vals[:, i] = func_values
        (func_values, out) = greedyswap(func_values, out)
    end

    return min_val, min_x, plot_vals
end


function greedyswap(values, x)
    ai = sortperm(values)
    out = x[:, ai]
    values[ai], out
end

function ptswap(values, temps, out)
    i = rand(1:(length(temps)  - 1))
    if log(rand()) < (values[i + 1] - values[i])*((1/temps[i + 1]) - (1/temps[i]))
        values[i], values[i + 1] = values[i + 1], values[i]
        out[:, i], out[:, i + 1] = out[:, i + 1], out[:, i]
    end
    values, out
end

end
