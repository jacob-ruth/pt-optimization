module PlotChain
using Plots

function temp_at_index(stats_dict)
    temps = map(dict -> dict["temp"], stats_dict)
    reps = map(dict -> dict["reps"], stats_dict)
    temp_index = vcat(map(temprep -> fill(temprep[1], temprep[2]), zip(temps, reps))...)
    return temp_index
end

function plot_temps(stats_dict, filename="")
    temps = map(dict -> dict["temp"], stats_dict)
    x = map(d -> d[2]["reps"]*d[1], enumerate(stats_dict))
    plot(x, temps)
    if filename != ""
        savefig(filename)
    end
end

function plot_swaps(stats_dict, filename="")
    x_values = vcat(map(dict -> map(values -> values[1] + (dict[1] - 1)*dict[2]["reps"], dict[2]["changed-value"]), enumerate(stats))...)

    histogram(x_values, bins=length(stats_dict))
end

function plot_score(stats_dict, filename="")
    if ndims(stats_dict) == 1
        x_values = vcat(map(dict -> map(values -> Int(values[1] + (dict[1] - 1)*dict[2]["reps"]), dict[2]["changed-value"]), enumerate(stats_dict))...)
        func_values = vcat(map(dict -> map(values -> values[2], dict["changed-value"]), stats_dict)...)
        tempAtIndex = temp_at_index(stats_dict)[x_values]
        scatter(x_values, func_values, m = cgrad([:red, :black, :green, :white, :blue]), msw = 0, zcolor = tempAtIndex)
        gui()
        tempAtIndex
    else
        for i = 1:size(stats_dict, 1)
            x_values = vcat(map(dict -> map(values -> Int(values[1] + (dict[1] - 1)*dict[2]["reps"]), dict[2]["changed-value"]), enumerate(stats_dict[i,:]))...)
            func_values = vcat(map(dict -> map(values -> values[2], dict["changed-value"]), stats_dict[i,:])...)
            tempAtIndex = temp_at_index(stats_dict[i,:])[x_values]
            scatter!(x_values, func_values, m = cgrad([:red, :black, :green, :white, :blue]), msw = 0, zcolor = tempAtIndex)
            print(i)
        end
        gui()
    end
end

function plot_min(stats_dict, filename="")
    x_values = vcat(map(dict -> map(values -> values[1] + (dict[1] - 1)*dict[2]["reps"], dict[2]["new-min"]), enumerate(stats_dict))...)
    func_values = vcat(map(dict -> map(values -> values[2], dict["new-min"]), stats_dict)...)
    plot(x_values, func_values)
end

end
