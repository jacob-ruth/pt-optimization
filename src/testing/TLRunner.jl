module TLRunner

include("../core/PTChain.jl")

function score_vec(vec)
    score = 0
    for i = 1:length(vec)
        if vec[i] == 0
            score += 2
        elseif vec[i] == -1 
            score += 1
        elseif vec[i] == 1
            score += 0
        elseif abs(vec[i]) <= 4
            score += 2*abs(vec[i]) - 1
        elseif abs(vec[i]) <= 6
            score += 15 - 2*abs(vec[i])
        else
            score += abs(vec[i]) - 4
        end
    end
    score
end

function random_walk(x::Vector)
    n = length(x)
    direction = rand(1:n)
    y = copy(x)
    y[direction] = y[direction] + rand(-1:2:1)
    return y
end

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
	dims = 20
    start_x = rand(-20:20, dims)
    temps = [0, 1, 4, 7, 10, 15, 20]
    min_val, min_x, plot_vals = PTChain.greedyTempering(start_x, score_vec, temps, random_walk, 500, 500)
    println(min_val)
    return 0
end

end
