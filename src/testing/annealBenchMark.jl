addprocs(2)
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
dims = 4
start_x = 1000*randn(dims)
reps = 50000
temps = [64, 16, 4, 0];

val_ep, x_ep, p_val_ep = POPT.epchains(start_x, f, temps, widescaleRandomNoiseTL, 2, 2)
val_bg, x_bg, p_val_bg = POPT.blockingGreedy(start_x, f, temps, widescaleRandomNoiseTL, 2, 2)


@time val_gt, x_gt, p_val_gt = PTChain.greedyTempering(start_x, r, temps, widescaleRandomNoiseTL, 500, reps)
println("greedy seq: $(val_gt)")
@time val_ep, x_ep, p_val_ep = POPT.epchains(start_x, r, temps, widescaleRandomNoiseTL, 500, reps)
println("eps chain: $(minimum(val_ep))")
@time val_bg, x_bg, p_val_bg = POPT.blockingGreedy(start_x, r, temps, widescaleRandomNoiseTL, 500, reps)
println("bg chain: $(minimum(val_bg))")
