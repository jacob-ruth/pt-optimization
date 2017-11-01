using PTChain

function init_random(m, n)
    A = rand(0:1, m, n)
    A[:]
end

function score_zero(mat_m, i, j, k, l)
    if mat_m[i, j] == 0 || ((i == k) && (j == l))
        return 0
    else
        return mat_m[k, l]
    end
end

function score_cos(mat_m, i, j, k, l)
    if ((i == k) && (j == l))
        return 0
    end
    if mat_m[i, j] == mat_m[k, l]
        return cos(((i - k)^2 + (j - l)^2))
    else
        return sin(((i - k)^2 + (j - l)^2))
    end

end

function score_near_far(mat_m, i, j, k, l)
    if ((i == k) && (j == l))
        return 0
    end
    if abs(i - k) + abs(j - l) < 3
        return (mat_m[i, j] == mat_m[k, l])? 0 : 1
    elseif abs(i - k) + abs(j - l) < 7
        return (mat_m[i, j] == mat_m[k, l])? 1 : 0
    else
        return 0
    end
end

function score_matrix(f, vec_m, m, n)
    mat_m = reshape(vec_m, m, n)
    score = 0
    for i = 1:m
        for j = 1:n
            for k = 1:m
                for l = 1:n
                    score += f(mat_m, i, j, k, l)
                end
            end
        end
    end
    score
end

function update_one(vec_m, f, m, n)
    mat_m = reshape(vec_m, m, n)
    row_change = rand(1:m)
    col_change = rand(1:n)
    old_values = 0
    for i = 1:m
        for j = 1:n
            old_values = old_values + f(mat_m, i, j, row_change, col_change) + f(mat_m, row_change, col_change, i, j)
        end
    end
    mat_m[row_change, col_change] = (mat_m[row_change, col_change] + 1) % 2
    diff = 0
    for i = 1:m
        for j = 1:n
            diff = diff + f(mat_m, i, j, row_change, col_change) + f(mat_m, row_change, col_change, i, j)
        end
    end
    mat_m[:], (diff - old_values)
end

function annealSolver()
    m = 50
    start = init_random(m, m)
    reps = 500
    temps = 50 * (0.9).^(0:1:70)
    f(x) = score_matrix(score_near_far, x, m, m)
    update(x) = update_one(x, score_near_far, m, m)
    min_val, x, stats, results = PTChain.simulatedAnnealing(start, f, temps, update, fill(reps, length(temps)))
    #make_gif(results, m, m, start)
    return stats
end

# function make_gif(results, m, n, start)
#     plt = heatmap(reshape(start, m, n))
#     iters = size(results, 2)
#     @gif for i=1:iters
#         heatmap(reshape(results[:, i], m, n))
#     end
# end
