import PTChain
import PlotChain

function score_convex(vec)
    return sum(abs.(vec))
end

function min_convex()
    dims = 100
    start = randn(dims)*100
    reps = 12
    temps = [128, 64, 32, 16, 8, 4, 2, 1, 0.5, 0.25, 0.125, 0]
    min_val, x = PTChain.sampleTempering(start, score_convex, temps, widescaleRandomNoiseTL, reps, 20000)
    return min_val, x
end

function min_convex_SA()
    dims = 100
    start = randn(dims)*100
    reps = 20000
    temps = [128, 64, 32, 16, 8, 4, 2, 1, 0.5, 0.25, 0.125, 0]
    min_val = score_vec(start)
    min_x = copy(start)
    for i = 1
        val, x = PTChain.simulatedAnnealing(start, score_convex, temps, widescaleRandomNoiseTL, fill(reps, length(temps)))
        if min_val > val
            min_val = copy(val)
            min_x = copy(x)
        end
    end
    min_val, min_x
end


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

function random_walk(x::Vector)
    n = length(x)
    direction = rand(1:n)
    y = copy(x)
    y[direction] = y[direction] + rand(-1:2:1)
    return y
end

function widescaleRandomNoiseTL(x::Vector{Float64})
    n = length(x)
    expon = rand()*12.0 - 4.0
    displacement = randn(n)
    new_x = x + displacement*2^expon
end

function annealSolverTL(dims)
    start = rand(-10:10, dims)
    reps = 100
    temps = 7*(0.975.^(0:99))
    min_val = score_vec(start)
    min_x = copy(start)
    for i = 1
        val, x = PTChain.simulatedAnnealing(start, score_vec, temps, random_walk, fill(reps, length(temps)))
        if min_val > val
            min_val = copy(val)
            min_x = copy(x)
        end
    end
    min_val, min_x
end

function insSolver(dims)
    start = rand(-10:10, dims)
    reps = 100
    temps = 7*(0.975.^(0:99))
    min_val, x = PTChain.sampleTempering(start, score_vec, [0, 0.5, 0.8, 5, 7], random_walk, reps, 100)
    return min_val, x
end

function comparison(dims, n)
    ins_score = zeros(n)
    anneal_score = zeros(n)
    for i = 1:n
        ins_score[i], _ = insSolver(dims)
        anneal_score[i], _ = annealSolverTL(dims)
    end
    return ins_score, anneal_score
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
