function init_random(m, n)
    A = rand(0:1, m, n)
    A[:]
end

function fancy_score(mat_m, i, j)
    m, n = size(mat_m)
    score = 0
    if mat_m[i,j] == 0
        return score
    end
    for l = 1:m
        for k = 1:m
            score += (2*mat_m[i, j] - 1)*(2*mat_m[l,k] - 1) * cos((i - l)^2 + (j - k)^2)
        end
    end
    score
end

function zero_score(mat_m, i, j)
    m, n = size(mat_m)
    score = 0
    if mat_m[i,j] == 0
        return score
    end
    for l = 1:m
        for k = 1:m
            score += mat_m[i, j]*mat_m[l,k]
        end
    end
    score
end

function score_matrix(f, vec_m, m, n)
    mat_m = reshape(vec_m, m, n)
    score = 0
    for i = 1:m
        for j = 1:n
            score += f(mat_m, i, j)
        end
    end
    score
end

function update_one(vec_m)
    new_prop = copy(vec_m)
    i = rand(1:length(new_prop))
    new_prop[i] = (new_prop[i] + 1) % 2
    new_prop
end

function swap_two(vec_m, m, n)
    mat_prop = reshape(vec_m, m, n)
    row = rand(1:m)
    col = rand(1:n)
    swap_vert = rand(-1:1)
    swap_horz = rand(-1:1)
    mat_prop[row, col], mat_prop[row + swap_horz][col + swap_vert] = mat_prop[row + swap_horz, col + swap_vert], mat_prop[row, col]
    vec_m[:]
end
