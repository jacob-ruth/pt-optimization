module POPT

import PTChain

function minTuple(a, b)
	a[1] < b[1] ? a : b
end

function pSimAnneal(runs, start_x, optimFunction, temps, proposalFunction, itersAtTemp)
	@sync @parallel (minTuple) for i = 1:runs
		PTChain.simulatedAnnealing(start_x, optimFunction, temps, proposalFunction, itersAtTemp)
	end
end

#goal is to make a non-blocking decentralized implementation
function pGreedy(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, num_swaps)
	2
end

function greedyChain(start_x, optimFunction, temp, proposalFunction, iterBetweenSwaps, swappingScheme, total_steps)
	i = 0
	while i < total_steps
		for j = 1:iterBetweenSwaps
			#do the update
		end 
		#proposal- when done a loop, write your current position, value, and flag to the index corresponding to this temperature.
		#Can I just use remote calls to return/store the "local" variables?
		#set a flag on this processor that it can be swapped, and check to see if the other processors are done.  Potential Race condition? Expecting that the _last_ processor in this group is able to see that everyone is done.  maybe use a SharedArray?
	end
end
end
