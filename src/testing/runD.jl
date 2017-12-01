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

dims = 50
start_x = 1000*randn(dims)
micro_steps = 100
macro_steps = 10
temps = [16, 4]

(m_12, m_22, b_12, b_22, s_12, s_22) = POPT.runblock(start_x, f, temps, widescaleRandomNoiseTL, micro_steps, macro_steps)
(m_1, m_2, b_1, b_2, s_1, s_2) = POPT.runnonblock(start_x, f, temps, widescaleRandomNoiseTL, micro_steps, macro_steps)
val_gt, x_gt, p_val_gt, swaps_made = PTChain.greedyTempering(start_x, f, temps, widescaleRandomNoiseTL, micro_steps, macro_steps)

println("---Blocking")

println("\t m_1: $(m_12) (actual value: $(f(b_12))")
println("\t m_2: $(m_22) (actual value: $(f(b_22))")
println("\t made $(s_12) swaps on 1 and $(s_22) swaps on 2")

println("---Non Blocking")
println("\t m_1: $(m_1) (actual value: $(f(b_1))")
println("\t m_2: $(m_2) (actual value: $(f(b_2))")
println("\t made $(s_1) swaps on 1 and $(s_2) swaps on 2")

println("---Running sequential")
start_x = 1000*randn(dims)
println("\t Sequential best was: $(val_gt)")
println("\t made $(swaps_made) swaps")
