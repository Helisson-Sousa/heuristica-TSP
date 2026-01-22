# ISL – Iterated Search in Julia

Este projeto implementa um algoritmo **ISL (Iterated Search / Iterated Local Search)** utilizando a linguagem **Julia**, com foco em problemas de otimização combinatória.

---

## 🎯 Objetivo acadêmico

Este projeto foi desenvolvido na linguagem **Julia** para a disciplina **Otimização Combinatória**, com o objetivo de fornecer uma estrutura modular e extensível, permitindo a fácil adaptação do algoritmo para diferentes problemas, funções objetivo e estruturas de vizinhança.

---

## 📌 Descrição do Algoritmo

O ISL é uma meta-heurística baseada em busca local que funciona a partir de três componentes principais:

1. **Solução Inicial**
2. **Busca Local**
3. **Perturbação (Diversificação)**

O algoritmo alterna entre intensificação (exploração local) e diversificação (escape de ótimos locais), buscando soluções de melhor qualidade ao longo das iterações.

---

## 🧠 Estrutura Geral do ISL

O fluxo básico do algoritmo é descrito a seguir:

1. Gerar uma solução inicial `s`
2. Aplicar busca local em `s`
3. Enquanto o critério de parada não for atingido:
   - Aplicar uma perturbação em `s`
   - Aplicar busca local na solução perturbada
   - Atualizar a melhor solução encontrada

---

## 📁 Estrutura do Projeto

```text
ISL/
├── src/
│   ├── solution.jl        # Estrutura da solução
│   ├── construction.jl   # Geração da solução inicial
│   ├── local_search.jl   # Busca local
│   ├── perturbation.jl   # Estratégias de perturbação
│   └── isl.jl             # Algoritmo principal ISL
├── instances/
│   └── example.dat        # Instâncias de teste
├── results/
│   └── outputs.txt       # Resultados experimentais
└── README.md
