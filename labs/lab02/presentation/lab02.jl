using DrWatson
@quickactivate "project" 

using DifferentialEquations
using Plots

s = 20.5          # Начальное расстояние по варианту 61
n = 5.5           # Во сколько раз скорость катера больше
fi = 3*pi/4       

r0_1 = s / (n + 1) # Случай 1: 20.5 / 6.5 ≈ 3.154
r0_2 = s / (n - 1) # Случай 2: 20.5 / 4.5 ≈ 4.556

# t - угол θ, а u — радиус r
function pursuit_ode(u, p, t)
    return u / sqrt(29.25) # n^2 - 1 = 5.5^2 - 1 = 29.25
end

# случай 1
tspan1 = (0.0, 2*pi)
prob1 = ODEProblem(pursuit_ode, r0_1, tspan1)
sol1 = solve(prob1, abstol=1e-8, reltol=1e-8)

# случай 2
tspan2 = (-pi, pi)
prob2 = ODEProblem(pursuit_ode, r0_2, tspan2)
sol2 = solve(prob2, abstol=1e-8, reltol=1e-8)


# движение лодки
boat_x(t) = t * tan(0) # Лодка просто движется по лучу

# график 1
p1 = plot(sol1, proj=:polar, label="Катер", title="Случай 1 (s/(n+1))", c=:red, lw=2)
plot!(p1, [0.0, 0.0], [0.0, maximum(sol1.u)], label="Лодка", c=:green, lw=2)


# график 2
p2 = plot(sol2, proj=:polar, label="Катер", title="Случай 2 (s/(n-1))", c=:blue, lw=2)
plot!(p2, [0.0, 0.0], [0.0, maximum(sol2.u)], label="Лодка", c=:green, lw=2)

plot(p1, p2, layout=(2, 1), size=(800, 800))
savefig("plots/lab02_results.png")
println("Графики сохранены в файл plots/lab02_results.png")
