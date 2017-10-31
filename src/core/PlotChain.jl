function plot_temps(stats_dict, filename="")
    temps = map(dict -> dict["temp"], stats_dict)
    x = map(d -> d[2]["reps"]*d[1], enumerate(stats_dict))
    plot(x, temps)
    if filename != ""
        savefig(filename)
    end
end

function plot_swaps(stats_dict, filename)
end

function plot_score(stats_dict, filename)
    x_values = vcat(map(dict -> map(values -> values[1] + (dict[1] - 1)*dict[2]["reps"], dict[2]["changed-value"]), enumerate(stats))...)
    func_values = vcat(map(dict -> map(values -> values[2], dict["new-min"]), stats_dict)...)
    plot(x_values, func_values)
end

function plot_min(stats_dict, filename)
    x_values = vcat(map(dict -> map(values -> values[1] + (dict[1] - 1)*dict[2]["reps"], dict[2]["new-min"]), enumerate(stats))...)
    func_values = vcat(map(dict -> map(values -> values[2], dict["new-min"]), stats_dict)...)
    plot(x_values, func_values)
end
