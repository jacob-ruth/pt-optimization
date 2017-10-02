module MHChain

export runChain

function runChain(start_x, optimFunction, temp, proposalFunction, iterations)
     x = start_x
     for i in 1:iterations
          updateChain!(x, optimFunction, temp, proposalFunction)
     end
     optimFunction(x), x
end


function updateChain!(x, optimFunction, temp, proposalFunction)
     current_value = optimFunction(x)
     new_x = proposalFunction(x)
     proposal_value = optimFunction(new_x)
     if (log(rand()) < (current_value - proposal_value) / temp)
          x = new_x;
     end
end

end
