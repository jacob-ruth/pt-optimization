import PTChain
using PlotChain

function load_sample()
    filename = "si1032.tsp"
    f = open(filename)
    s = readstring(f)
    numbers = map(x -> parse(Int, x), split(s))
    a = 1032
    b = 1
    out = zeros(a, a)
    for i = 1:a
        out[1:i - 1] = zeros(i - 1)
        for j = i:a
            out[i, j] = numbers[b]
            b = b + 1
        end
    end
    close(f)
    return out + out'
end


function score_tour(graph, tour)
    val = 0
    assert(size(graph, 1) == length(tour))
    for i = 1:(length(tour) - 1)
        val = graph[tour[i], tour[i + 1]] + val
    end
    return val
end

function swap_two(tour, mat)
    new_tour = copy(tour)
    randone = rand(1:length(tour))
    randtwo = rand(1:length(tour))
    new_tour[randone] = tour[randtwo]
    new_tour[randtwo] = tour[randone]
    diff = 0
    if randone != 1
        diff += mat[new_tour[randone - 1], new_tour[randone]] - mat[tour[randone - 1], tour[randone]]
    end
    if randone != size(mat, 1)
        diff += mat[new_tour[randone], new_tour[randone + 1]] - mat[tour[randone], tour[randone + 1]]
    end
    if randtwo != 1
        diff += mat[new_tour[randtwo - 1], new_tour[randtwo]] - mat[tour[randtwo - 1], tour[randtwo]]
    end
    if randtwo != size(mat, 1)
        diff += mat[new_tour[randtwo], new_tour[randtwo + 1]] - mat[tour[randtwo], tour[randtwo + 1]]
    end

    new_tour, diff
end

function reverse_section(tour, mat)
    new_tour = copy(tour)
    randone, randtwo = minmax(rand(1:length(tour)), rand(1:length(tour)))
    new_tour[randone:randtwo] = tour[randtwo:-1:randone]
    diff = 0
    if randone != 1
        diff += mat[new_tour[randone - 1], new_tour[randone]] - mat[tour[randone - 1], tour[randone]]
    end
    if randone != size(mat, 1)
        diff += mat[new_tour[randone], new_tour[randone + 1]] - mat[tour[randone], tour[randone + 1]]
    end
    if randtwo != 1
        diff += mat[new_tour[randtwo - 1], new_tour[randtwo]] - mat[tour[randtwo - 1], tour[randtwo]]
    end
    if randtwo != size(mat, 1)
        diff += mat[new_tour[randtwo], new_tour[randtwo + 1]] - mat[tour[randtwo], tour[randtwo + 1]]
    end
    new_tour, diff
end

function proposal_function(tour, mat)
    if rand() < 0.5
        return swap_two(tour, mat)
    else
       return reverse_section(tour, mat)
    end
end

function sim_tour()
    n = 1032
    start_x = randperm(n)
    mat = load_sample()
    reps = 1000
    temps = 100 * (0.95).^(0:0.5:200)
    f(x) = score_tour(mat, x)
    update(x) = proposal_function(x, mat)
    min_val, x, stats, results = PTChain.simulatedAnnealing(start_x, f, temps, update, fill(reps, length(temps)))
    return stats
end

function st_tour()
    n = 1032
    start_x = randperm(n)
    mat = load_sample()
    reps = 10
    temps = collect(0:2:100)
    f(x) = score_tour(mat, x)
    update(x) = proposal_function(x, mat)
    min_val, x = PTChain.sampleTempering(start_x, f, temps, update, reps, 5000000)
    return min_val, x
end

function diffs(N)
    x = randperm(1032)
    vals = Array{Float64}(N)
    mat = load_sample()
    for i = 1:N
        x = reverse_section(x)
        vals[i] = score_tour(mat, x)
    end
    histogram(diff(vals))
    gui()
    vals
end
