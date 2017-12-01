addprocs(3)
import POPT

@everywhere function widescaleRandomNoiseTL(x::Vector{Float64})
    n = length(x)
    expon = rand()*6 - 4
    displacement = randn(n)
    new_x = x + displacement*10^expon
end

@everywhere function f(x)
	sum(abs.(x))
end

#rosenbrock
@everywhere function g(x)
	score = 0
	for i = 1:(length(x) - 1)
		val = (100*(x[i + 1] - x[i]^2)^2 + (x[i] - 1)^2)
		score = score + val
	end
	score
end

#rastrigin function
@everywhere function r(x)
	A = 10
	return A*length(x) + sum(map(y -> y^2 - A*cos(2*pi*y), x))

end
dims = 50
start_x = 1000*randn(dims)
micro_steps = 100
macro_steps = 10000
temps = [60, 40];
println("---Priming")
val_ep, x_ep, p_val_ep = POPT.epchains(start_x, r, temps, widescaleRandomNoiseTL, 2, 2)
val_bg, x_bg, p_val_bg = POPT.blockingGreedy(start_x, r, temps, widescaleRandomNoiseTL, 2, 2)
(m_1, m_2, b_1, b_2) = POPT.runblock(start_x, r, temps, widescaleRandomNoiseTL, 2, 2)
(m_1, m_2, b_1, b_2) = POPT.runnonblock(start_x, r, temps, widescaleRandomNoiseTL, 2, 2)

#start_x = 1000*randn(dims)
#swap_scheme = [[[1, 2]]]
#@time val_pins1, x_pins1, p_val_pins1 = PTChain.partialGreedyTempering(start_x, f, temps, widescaleRandomNoiseTL, iters, reps, swap_scheme)
#println("partial swapping 1: $(val_pins1)")

#start_x = 1000*randn(dims)
#@time val_p1, x_p1, p_val_p1 = POPT.pINSChain(start_x, f, temps, widescaleRandomNoiseTL, iters, reps, swap_scheme)
#println("partial swapping 1 parallel: $(minimum(val_p1))")

#start_x = 1000*randn(dims)
#@time val_p2, x_p2, p_val_p2 = POPT.pINSChain(start_x, f, temps, widescaleRandomNoiseTL, iters, reps, swap_scheme2)
#println("partial swapping 2 parallel: $(minimum(val_p2))")



println("---Running sequential")
start_x = 1000*randn(dims)
@time val_gt, x_gt, p_val_gt, swaps_made = PTChain.greedyTempering(start_x, r, temps, widescaleRandomNoiseTL, micro_steps, macro_steps)
println("\t Sequential best was: $(val_gt)")
println("\t made $(swaps_made) swaps")

println("---Running blocking greedy")
start_x = 1000*randn(dims)
@time val_bg, x_bg, p_val_bg = POPT.blockingGreedy(start_x, r, temps, widescaleRandomNoiseTL, micro_steps, macro_steps)
println("\t Blocking best was: $(minimum(val_bg))")

println("---Running totally parallel")
start_x = 1000*randn(dims)
@time val_ep, x_ep, p_val_ep = POPT.epchains(start_x, r, temps, widescaleRandomNoiseTL, micro_steps, macro_steps)
println("\t Totally parallel was: $(minimum(val_ep))")

println("---Running non-blocking decentralized")
start_x = 1000*randn(dims)
@time (m_1, m_2, b_1, b_2, s_1, s_2) = POPT.runnonblock(start_x, r, temps, widescaleRandomNoiseTL, micro_steps, macro_steps)
println("\t non-blocking was: $(min(m_1, m_2))")
println("\t made $(s_1) swaps on 1 and $(s_2) swaps on 2")

println("---Running blocking decentralized")
start_x = 1000*randn(dims)
@time (m_1, m_2, b_1, b_2, s_1, s_2) = POPT.runblock(start_x, r, temps, widescaleRandomNoiseTL, micro_steps, macro_steps)
println("\t non-blocking was: $(min(m_1, m_2))")
println("\t made $(s_1) swaps on 1 and $(s_2) swaps on 2")
