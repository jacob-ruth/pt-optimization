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
			if best_val < min_val[j]
	            min_val[j] = copy(best_val)
	            min_x[:,j] = copy(best_x)
	        end
	    end
	    plot_vals[:, i] = func_values
	    out = greedyswapShared(func_values, out)
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


function pINSChain(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, num_swaps, swap_schemes)
    sort!(temps)
    num_temps = length(temps)
    num_swap_schemes = length(swap_schemes)
    out = SharedArray(repmat(start_x, 1, num_temps))
	func_values = SharedArray(zeros(num_temps))
    func_values[:] = optimFunction(start_x)
	min_val = SharedArray(zeros(num_temps))
	min_val[:] = optimFunction(start_x)
    plot_vals = zeros(num_temps, num_swaps)
    min_x = copy(out)
    current_ss = 1
    for i = 1:num_swaps
    	swap_scheme = swap_schemes[current_ss]
    	num_interactions = length(swap_scheme)
    	@sync @parallel for j = 1:num_interactions
    		@sync @parallel for k = swap_scheme[j]
				func_values[k], out[:, k], best_val, best_x = PTChain.runChain(out[:,k], optimFunction, temps[k], proposalFunction, iterBetweenSwaps)
				if best_val < min_val[k]
					min_val[k] = copy(best_val)
					min_x[:,k] = copy(best_x)
				end
    		end
            func_values[swap_scheme[j]], out[:, swap_scheme[j]] = greedyswap(func_values[swap_scheme[j]], out[:, swap_scheme[j]])
    	end
        if current_ss == num_swap_schemes
            current_ss = 1
        else
            current_ss += 1
        end
    end
	return min_val, min_x, plot_vals
end

function runblock(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, num_swaps)
	c_1 = RemoteChannel(1)
	c_2 = RemoteChannel(2)
	res_1 = @spawn blockTwo(start_x, optimFunction, temps[1], proposalFunction, iterBetweenSwaps, num_swaps, c_1, c_2)
	res_2 = @spawn blockTwo(start_x, optimFunction, temps[2], proposalFunction, iterBetweenSwaps, num_swaps, c_2, c_1)
	m_1, b_1, s_1 = fetch(res_1)
	m_2, b_2, s_2 = fetch(res_2)
	return (m_1, m_2, b_1, b_2, s_1, s_2)
end

#goal is to make a non-blocking decentralized implementation
function runnonblock(start_x, optimFunction, temps, proposalFunction, iterBetweenSwaps, num_swaps)
	c_1 = RemoteChannel(1)
	c_2 = RemoteChannel(2)
	res_1 = @spawn nonBlockTwo(start_x, optimFunction, temps[1], proposalFunction, iterBetweenSwaps, num_swaps, c_1, c_2)
	res_2 = @spawn nonBlockTwo(start_x, optimFunction, temps[2], proposalFunction, iterBetweenSwaps, num_swaps, c_2, c_1)
	m_1, b_1, s_1 = fetch(res_1)
	m_2, b_2, s_2 = fetch(res_2)
	return (m_1, m_2, b_1, b_2, s_1, s_2)
end


function nonBlockTwo(start_x, optim, temp, propF, micro_steps, n_swaps, in_c, out_c)
	x = start_x
    min_x = copy(start_x)
    best_val = optim(min_x)
    curr_val = copy(best_val)
    update_pending = false
    out_val = 0
    i = 0
    num_swaps = 0
	while i < n_swaps
	    j = 0
		while j < micro_steps
			#proposal
        	new_x = propF(x)
        	proposal_value = optim(new_x)
			#accept based on temp
        	if ((temp == 0 && curr_val > proposal_value) || (log(rand()) < (curr_val - proposal_value) / temp))
               	x = copy(new_x)
               	curr_val = copy(proposal_value)
          	end
          	if curr_val < best_val
               	best_val = copy(curr_val)
            	min_x = copy(x)
          	end
          	j = j + 1
          	#if waiting for update and in_c has something new available
          	if update_pending && isready(in_c)
          		update_pending = false
          		(swap_temp, in_val, swap_x) = take!(in_c)
          		if (in_val < out_val) && (swap_temp > temp) || (in_val > out_val) && (swap_temp < temp)
          			#println("Swapping $(i): my temp is $(temp) and I'm going from $(out_val) to $(in_val)")
          			#println("throwing out $(j) steps")
          			curr_val = copy(in_val)
          			x = copy(swap_x)
          			j = 0
          			num_swaps = num_swaps + 1
          		end
          	end 
		end
		if update_pending
			#println("waiting")
			wait(in_c)
			update_pending = false
          	(swap_temp, in_val, swap_x) = take!(in_c)
          	if (in_val < out_val) && (swap_temp > temp) || (in_val > out_val) && (swap_temp < temp)
          	   	#println("Swapping $(i): my temp is $(temp) and I'm going from $(out_val) to $(in_val)")
          		curr_val = copy(in_val)
          		x = copy(swap_x)
				num_swaps = num_swaps + 1
          		continue
			end
		end
		i = i + 1
		#push current stats to out_c
		update_pending = true
		out_val = copy(curr_val)
		out_v = (temp, out_val, copy(x))
		#println("sending a value of $(out_val)")
		put!(out_c, out_v)
		if update_pending && isready(in_c)
          	update_pending = false
          	(swap_temp, in_val, swap_x) = take!(in_c)
          	if (in_val < out_val) && (swap_temp > temp) || (in_val > out_val) && (swap_temp < temp)
          		#println("Swapping $(i): my temp is $(temp) and I'm going from $(out_val) to $(in_val)")
          		num_swaps = num_swaps + 1
          		curr_val = copy(in_val)
          		x = copy(swap_x)
          		j = 0
          	end
        end 
	end
	return best_val, min_x, num_swaps
end

function blockTwo(start_x, optim, temp, propF, micro_steps, n_swaps, in_c, out_c)
	x = start_x
    min_x = copy(start_x)
    best_val = optim(min_x)
    curr_val = copy(best_val)
    out_val = 0
    i = 0
    num_swaps = 0
	while i < n_swaps
	    j = 0
		while j < micro_steps
			#proposal
        	new_x = propF(x)
        	proposal_value = optim(new_x)
			#accept based on temp
        	if (log(rand()) < (curr_val - proposal_value) / temp)
               	x = copy(new_x)
               	curr_val = copy(proposal_value)
          	end
          	if curr_val < best_val
               	best_val = copy(curr_val)
            	min_x = copy(x)
          	end
          	j = j + 1
		end
		i = i + 1
		out_val = copy(curr_val)
		out_v = (temp, out_val, copy(x))
		#println("sending a value of $(out_val)")
		put!(out_c, out_v)
		wait(in_c)
		(swap_temp, in_val, swap_x) = take!(in_c)
        if (in_val < out_val) && (swap_temp > temp) || (in_val > out_val) && (swap_temp < temp)
          	#println("Swapping $(i): my temp is $(temp) and I'm going from $(out_val) to $(in_val)")
          	num_swaps = num_swaps + 1
          	curr_val = copy(in_val)
          	x = copy(swap_x)
        end
	end
	return best_val, min_x, num_swaps
end

function greedyswap(values, x)
    ai = sortperm(values)
    out = x[:, ai]
    values[ai], out
end


function greedyswapShared(values, x)
    ai = sortperm(values)
    out = x[:, ai]
    permute!(values, ai)
    SharedArray(out)
end


end
