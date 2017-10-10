module MHChain

export runChain

function runChain(start_x, optimFunction, temp, proposalFunction, iterations)
     statsDict = Dict()
     statsDict["changed-value"] = []
     statsDict["new-min"] = []
     x = start_x
     min_x = copy(start_x)
     best_val = optimFunction(min_x)
     val = copy(best_val)
     for i in 1:iterations
          new_x = proposalFunction(x)
          proposal_value = optimFunction(new_x)
          if (log(rand()) < (val - proposal_value) / temp)
               x = new_x
               val = proposal_value
               # record an update
               push!(statsDict["changed-value"], [i, proposal_value])
          end
          if val < best_val
               #record a new min found
               push!(statsDict["new-min"], [i, val])
               best_val = copy(val)
               min_x = copy(x)
          end
     end
     val, x, best_val, min_x, statsDict
end

end
