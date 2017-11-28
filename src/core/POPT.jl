module POPT

import PTChain
@everywhere import PTChain

function minTuple(a, b)
	a[1] < b[1] ? a : b
end

function pSimAnneal(runs, start_x, optimFunction, temps, proposalFunction, itersAtTemp)
	@sync @parallel (minTuple) for i = 1:runs
		PTChain.simulatedAnnealing(start_x, optimFunction, temps, proposalFunction, itersAtTemp)
	end
end

function blockingGreedy(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, num_swaps)
	sort!(temps)
	num_temps = length(temps)
	out = SharedArray(repmat(start_x, 1, num_temps))
	func_values = SharedArray(zeros(num_temps))
	func_values[:] = optimFunction(start_x)
	min_val = SharedArray(zeros(num_temps))
	min_val[:] = optimFunction(start_x)
	plot_vals = zeros(num_temps, num_swaps)
	min_x = copy(out)
	for i = 1:num_swaps
	    @sync @parallel for j = 1:num_temps
	        fv, out[:, j], best_val, best_x = PTChain.runChain(out[:,j], optimFunction, temps[j], proposalFunction, iterBetweenSwaps)
			func_values[j] = fv
			println("fv: $(fv)" )
			println(typeof(func_values))
			if best_val < min_val[j]
	            min_val[j] = copy(best_val)
	            min_x[:,j] = copy(best_x)
	        end
			println(j)
	    end
	    plot_vals[:, i] = func_values
		println(func_values)
	    (func_values, out) = PTChain.greedyswap(func_values, out)
		println(func_values)
		println(".............")
	end

	return min_val, min_x, plot_vals
end

function epchains(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, num_swaps)
	sort!(temps)
	num_temps = length(temps)
	out = SharedArray(repmat(start_x, 1, num_temps))
	func_values = SharedArray(zeros(num_temps))
	func_values[:] = optimFunction(start_x)
	min_val = SharedArray(zeros(num_temps))
	min_val[:] = optimFunction(start_x)
	plot_vals = zeros(num_temps, num_swaps)
	min_x = copy(out)
	@sync @parallel for j = 1:num_temps
		for i = 1:num_swaps
	        func_values[j], out[:, j], best_val, best_x = PTChain.runChain(out[:,j], optimFunction, temps[j], proposalFunction, iterBetweenSwaps)
	        if best_val < min_val[j]
	            min_val[j] = copy(best_val)
	            min_x[:,j] = copy(best_x)
	        end
	    end
	end

	return min_val, min_x, plot_vals
end



#goal is to make a non-blocking decentralized implementation
function pGreedy(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, num_swaps)

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
