# SNU Bus Stop Simulation

Simulation to propose the optimized shuttle bus waiting line based on pedestrians stress level using Processing and the autonomous agent that interpreting environments.

## What is the problem?

SNU students go their class by bus but due to its ambiguous waiting line and long average waiting time, they are struggling everyday morning. I want to solve this problem by using autonomous agent from "Nature of code" written by Daniel Shiffman.

### Autonomous agent?

> The term **autonomous agent** generally refers to an entity that makes its own choices about how to act in its environment without any influence from a leader or global plan. — Nature of code, Daniel Shiffman

From above, I implemented human-like perspective(fov), attractor(bus stop) and environment factor which acts as key role — stress level. Stress level and cases are like below.

- Physical contacts with others on a way to bus stop: 9.8
- Realizing confused with their bus waiting line: 8.9
- Annoying with one's own way to road(not bus stop): 11.2
- Too close to other lines: 6.8
- Confused with which line should I choose: 8.3



### How to implement?

Basically, I implemented from [this](https://natureofcode.com/book/chapter-6-autonomous-agents/) but especially there were 2 issues. 

- Group behavior: solved by "Nature of code"
- Lining: Use our own algorithm
- Environment variables

To solve second issue, we assume three things like below.

1. Every person intends to take own bus knows their bus stop position **almost precisely**.
2. People are capable to figure out the shape of lines and choose one of them.
3. The shape of lines can be distorted only with the condition that every person can move as little as much they can. Also, after someone went in line, condition (2) should be guaranteed.



## How to execute

Install processing and launch this repository with directory name "SNUSimulation.pde".



## Demo

![Demo](https://i.imgur.com/jNTit7w.png])(https://youtu.be/jh6ArPE7XMU)



## Built With

- [Processing](https://processing.org/) - Main framework

  ​

## Authors

- **Hyuntak Cha** - *Maintainer* - [website](https://hyuntak.com)
- **Seungyoun Lee** - Co-developer - [sylee421](https://github.com/sylee421)



## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

- https://natureofcode.com/book/chapter-6-autonomous-agents/
