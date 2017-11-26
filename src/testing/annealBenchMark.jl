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

dims = 100
start_x = 1000*randn(dims)
reps = 200000
temps = 128*(0.5.^(0:19));
val, x = POPT.pSimAnneal(16, start_x, f, temps, widescaleRandomNoiseTL, fill(reps, length(temps)))
println(val)
