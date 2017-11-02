import PTChain

function load_sample()
    filename = "si1032.tsp"
    s = readstring(open(filename))
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

function swap_two(tour)
    new_tour = copy(tour)
    randone = rand(1:length(tour))
    randtwo = rand(1:length(tour))
    new_tour[randone] = tour[randtwo]
    new_tour[randtwo] = tour[randone]
    new_tour
end

function reverse_section(tour)
    new_tour = copy(tour)
    randone = rand(1:length(tour))
    randtwo = rand(1:length(tour))
    new_tour[min(randone, randtwo):max(randone,randtwo)] = tour[max(randone,randtwo):-1:min(randone, randtwo)]
    new_tour
end

function proposal_function(tour)
    if rand() < 0.5
        return swap_two(tour)
    else
        return reverse_section(tour)
    end
end

function sim_tour()
    n = 1032
    start_x = randperm(n)
    mat = load_sample()
end
