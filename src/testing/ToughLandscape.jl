using PTChain

# Since the INSSwap algorithm is going to assign temperatures based on energy scores,
# it will do poorly when having a high barrier around the lowest point.
function score_vec(vec)
    score = 0
    for i = 1:length(vec)
        if abs(vec[i]) <= 0.25
            score += 0 #don't really need
        elseif abs(vec[i]) <= 0.5
            score += 4
        elseif abs(vec[i]) < 1
            score += 2
        elseif abs(vec[i]) < 1.25
            score += 4
        else
            score += 0.25*vec[i]^2
        end

    end
score
end

function widescaleRandomNoiseTL(x::Vector{Float64})
    n = length(x)
    expon = rand()*4.0 - 3.0
    displacement = randn(n)
    new_x = x + displacement*2^expon
end

function annealSolverTL(dims)
    start = randn(dims)
    reps = 15
    temps = 10 * (0.90).^(0:2:60)
    min_val = score_vec(start)
    min_x = copy(start)
    for i = 1:3
        val, x, stats, results = simulatedAnnealing(start, score_vec, temps, widescaleRandomNoiseTL, fill(reps, length(temps)))
        if min_val > val
            min_val = copy(val)
            min_x = copy(x)
        end
    end
    min_val, min_x
end
function insSolver(dims)
    start = randn(dims)
    reps = 30
    sampleTempering(start, score_vec, [0, 4, 10], widescaleRandomNoiseTL, reps, 50)
end
