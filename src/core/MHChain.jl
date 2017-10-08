module MHChain

export runChain

function runChain(start_x, optimFunction, temp, proposalFunction, iterations)
     x = start_x
     min_x = copy(start_x)
     best_val = optimFunction(min_x)
     val = best_val
     for i in 1:iterations
          val = updateChain!(x, optimFunction, temp, proposalFunction)
          if val < best_val
               best_val = copy(val)
               min_x = copy(x)
          end
     end
     val, x, best_val, min_x
end


function updateChain!(x, optimFunction, temp, proposalFunction)
     current_value = optimFunction(x)
     new_x = proposalFunction(x)
     proposal_value = optimFunction(new_x)
     if (log(rand()) < (current_value - proposal_value) / temp)
          x = new_x;
          return proposal_value
     end
     return current_value
end

end
