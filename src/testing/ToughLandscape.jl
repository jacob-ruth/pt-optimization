using PTChain

function score_vec(vec)
    score = 0
    for i = 1:length(vec)
        if abs(vec[i]) <= 4
            score += abs(vec[i])
        elseif abs(vec[i]) <= 6
            score += 8 - abs(vec[i])
        else
            score += abs(vec[i]) - 4
        end
    end
    score
end

function random_walk(x::Vector{Float64})
    n = length(x)
    direction = rand(1:n)
    y = copy(x)
    y[direction] = y[direction] + rand(-1:2:1)
    return y
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
    sampleTempering(start, score_vec, [0, 4, 10], random_walk, reps, 50)
end

#calculates the expected number of steps from a position on the function to a max
#steps up the recurrance that F(x) = p*(F(x+1) + 1) + (1 - p)*(F(x - 1) + 1)
function rand_walk_solver(steps, temp, ΔF=1)
    p = exp(-ΔF/temp)/2
    vec = ones(steps)
    vec[end] = 0
    mat = zeros(steps, steps)
    mat[1, 1] = p
    mat[1, 2] = -p
    for  i = 2:(steps - 1)
        mat[i, i - 1] = -(1 - p)
        mat[i, i] = 1
        mat[i, i + 1] = -p
    end
    mat[steps, steps] = 1
    return inv(mat)*vec
end
