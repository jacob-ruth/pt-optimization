addprocs(4)
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

dims = 20
start_x = 1000*randn(dims)
reps = 5
temps = 128*(0.5.^(0:19));
#val, x = POPT.pSimAnneal(16, start_x, f, temps, widescaleRandomNoiseTL, fill(reps, length(temps)))
@time val_gt, x_gt, p_val_gt = PTChain.greedyTempering(start_x, f, [32, 16, 8, 0], widescaleRandomNoiseTL, 100, reps)
@time val_bg, x_bg, p_val_bg = POPT.blockingGreedy(start_x, f, [32, 16, 8, 0], widescaleRandomNoiseTL, 100, reps)
@time val_ep, x_ep, p_val_ep = POPT.epchains(start_x, f, [32, 16, 8, 0], widescaleRandomNoiseTL, 100, reps)
println(val)
