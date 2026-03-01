using DrWatson
@quickactivate "project" 

using DifferentialEquations
using Plots

x0 = 66000.0 # Начальная численность армии X
y0 = 77000.0 # Начальная численность армии Y
u0 = [x0, y0] # Вектор начальных условий
tspan = (0.0, 5.0) # Временной интервал

# СЛУЧАЙ 1: Регулярные войска

# Коэффициенты для случая 1
a1 = 0.35
b1 = 0.79
c1 = 0.49
h1 = 0.14

# Функции подкрепления для случая 1
function P1(t)
    return sin(t + 1) + 2
end

function Q1(t)
    return cos(t + 2) + 1
end

# Система дифференциальных уравнений (Случай 1)
function regular_battle!(du, u, p, t)
    x = u[1]
    y = u[2]
    
    # dx/dt = -a*x - b*y + P(t)
    du[1] = -a1*x - b1*y + P1(t)
    
    # dy/dt = -c*x - h*y + Q(t)
    du[2] = -c1*x - h1*y + Q1(t)
end

# Решение
prob1 = ODEProblem(regular_battle!, u0, tspan)
sol1 = solve(prob1, Tsit5(), dtmax=0.01) # dtmax для более плавного графика

# Графики для Случая 1
p1 = plot(sol1, vars=(0, 1), label="Армия X", title="Случай 1: Регулярные войска", 
          xlabel="Время", ylabel="Численность", color=:blue, lw=2)
plot!(p1, sol1, vars=(0, 2), label="Армия Y", color=:red, lw=2)


# СЛУЧАЙ 2: Регулярные войска и партизаны

# Коэффициенты для случая 2
a2 = 0.258
b2 = 0.67
c2 = 0.46
h2 = 0.31

# Функции подкрепления для случая 2
function P2(t)
    return sin(2*t) + 1
end

function Q2(t)
    return cos(t) + 1
end

# Система дифференциальных уравнений (Случай 2)
function guerrilla_battle!(du, u, p, t)
    x = u[1]
    y = u[2]
    
    # dx/dt = -a*x - b*y + P(t)
    du[1] = -a2*x - b2*y + P2(t)
    
    # dy/dt = -c*x*y - h*y + Q(t)
    du[2] = -c2*x*y - h2*y + Q2(t)
end

# Решение
prob2 = ODEProblem(guerrilla_battle!, u0, tspan)
sol2 = solve(prob2, Tsit5(), dtmax=0.01)

# Графики для Случая 2
p2 = plot(sol2, vars=(0, 1), label="Армия X (Рег.)", title="Случай 2: С партизанами", 
          xlabel="Время", ylabel="Численность", color=:blue, lw=2)
plot!(p2, sol2, vars=(0, 2), label="Армия Y (Парт.)", color=:red, lw=2)

# Сохранение и отображение
plot(p1, p2, layout=(2, 1), size=(800, 800))
savefig("plot/lab03_results.png")
println("Графики сохранены в файл plots/lab03_results.png")
