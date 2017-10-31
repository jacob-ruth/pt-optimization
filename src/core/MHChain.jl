module MHChain

export runChain

function runChain(start_x, optimFunction, temp, proposalFunction, iterations)
     statsDict = Dict()
     statsDict["changed-value"] = []
     statsDict["new-min"] = []
     statsDict["reps"] = iterations
     statsDict["temp"] = temp
     x = start_x
     min_x = copy(start_x)
     best_val = optimFunction(min_x)
     val = copy(best_val)
     for i in 1:iterations
          new_x = proposalFunction(copy(x))
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
