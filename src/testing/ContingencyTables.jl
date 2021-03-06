using PTChain
using MHChain

function init_table(col_sums)
    n = length(col_sums)
    out = zeros(n, n)
    for i in 1:n
        out[1:col_sums[i], i] = ones(col_sums[i])
    end
    out[:]
end

function score_table(table, target_vector)
    out = rearrange_vector(table)
    return sum(abs.(sum(out, 2) .- target_vector))
end

function rearrange_vector(table)
    n = Int(sqrt(length(table)))
    out = reshape(table, n, n)
    out
end

function swap_columns(table)
    out = rearrange_vector(table)
    n = size(out, 1)
    col_n = rand(1:n)
    one_indx = rand(find(!iszero, out[:, col_n]))
    zero_indx = rand(find(iszero, out[:, col_n]))
    out[one_indx, col_n], out[zero_indx, col_n] = out[zero_indx, col_n], out[one_indx, col_n]
    return out[:]
end

function testWorkers(iterations, matrix_size)
	target_vector = fill(2, matrix_size)
	start_x = init_table(target_vector)[:]
	temps = [0.01, 1, 2.5, 5]
	out = zeros(iterations)
	f(x) = score_table(x, target_vector)
	for i = 1:iterations
		out[i], x = sampleTempering(start_x, f, temps, swap_columns, 15)
	end
	out
end

function simAnneal(n, T0, reps)
    scores = [1, 2, 2, 2, 3, 4]
    temps = T0 * (0.90).^(0:5:75)
    f(x) = score_table(x, scores)
    min_val, x, stats = simulatedAnnealing(init_table(scores), f, temps, swap_columns, fill(reps, length(temps)))
end

function repSimAnneal(n, T0, reps)
    a = 100
    c = 0
    while a > 0
        val, x = simAnneal(n, T0, reps)
        if val < a
            a = val
        end
    c = c + 1
    end
    c
end

function gradDescend()
    scores = [1, 2, 2, 2, 3, 4]
    f(x) = score_table(x, scores)
    min_val, x, stats = runChain(init_table(scores), f, 0.0, swap_columns, 1000)
end

function testMany(largest_size)
	iterations = 5
	min_size = 2
	c = zeros(largest_size, iterations)
	for i = min_size:largest_size
		c[i, :] = testWorkers(iterations, i)
		print(i)
	end
	c
end
