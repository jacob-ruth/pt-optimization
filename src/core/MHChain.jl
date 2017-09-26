module MHChain

export runChain

function runChain(start_x, optimFunction, temp, proposalFunction, iterations, burnInPeriod)
     x_out = Array{typeof(start_x)}(iterations)
     for i in 1:burnInPeriod
          start_x = updateChain(start_x, optimFunction, temp, proposalFunction)
     end
     x_out[1] = start_x
     for i in 2:iterations
          x_out[i] = updateChain(x_out[i - 1], optimFunction, temp, proposalFunction)
     end
     return x_out
end


function updateChain(x, optimFunction, temp, proposalFunction)
     current_value = optimFunction(x);
     new_x = proposalFunction(x);
     proposal_value = optimFunction(new_x);
     if (log(rand()) < (current_value - proposal_value) / temp)
          return new_x;
     else
          return x;
     end
end

end
