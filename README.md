# Infraestrutura de Hardware - Projeto RISC-V Pipeline 🚀

Este repositório contém os arquivos base para o projeto da disciplina Infraestrutura de Hardware (IF674) no CIn-UFPE. O objetivo do projeto é implementar instruções em um processador RISC-V usando SystemVerilog.

---

## 📝 Instruções

As instruções a serem implementadas são as do conjunto RV32I, que é parte oficial do conjunto de instruções RISC-V. A tabela abaixo mostra o status de implementação das instruções no projeto atual:


| Instrução | Implementada | Testada  | 
|-----------|:------------:|:--------:|
| **Instruções da ALU**               |
| `ADD`     |     ✅     |     ✅    |
| `ADDI`    |     ❌     |     ❌    |
| `SUB`     |     ✅     |     ✅    |
| `AND`     |     ✅     |     ✅    |
| `OR`      |     ✅     |     ✅    |
| `XOR`     |     ✅     |     ✅    |
| `SLLI`    |     ❌     |     ❌    |
| `SRLI`    |     ❌     |     ❌    |
| `SRAI`    |     ❌     |     ❌    |
| `SLT`     |     ❌     |     ❌    |
| `SLTI`    |     ❌     |     ❌    |
| `BEQ`     |     ✅     |     ✅    |
| `BNE`     |     ✅     |     ✅    |
| `BLT`     |     ✅     |     ✅    |
| `BGE`     |     ✅     |     ✅    |
| **Load/Store**                      |
| `LW`      |     ✅     |     ✅    |
| `LH`      |     ❌     |     ❌    |
| `LB`      |     ❌     |     ❌    |
| `LBU`     |     ❌     |     ❌    |
| `LUI`     |     ❌     |     ❌    |
| `SW`      |     ✅     |     ❌    |
| `SH`      |     ❌     |     ❌    |
| `SB`      |     ❌     |     ❌    |
| **Saltos Incondicionais**           |
| `JAL`     |     ✅     |     ✅    |
| `JALR`    |     ✅     |     ✅    |
| `HALT`    |     ✅     |     ✅    |

Você tem permissão para modificar a implementação do processador como desejar (por exemplo, incluir fios, alterar tamanhos, modificar sinais, remover ou adicionar módulos, etc.), desde que o resultado final continue funcionando como um pipeline e produza os resultados corretos.

## 📁 Estrutura do repositório
O repositório está organizado da seguinte forma:
- [`design`](/design): Contém o código-fonte do projeto do processador RISC-V.
- [`doc`](/doc): Contém mais explicações sobre a implementação do pipeline.
- [`sim`](/sim): Contém exemplos de arquivos de simulação e seus resultados esperados.
- [`verif`](/verif): Contém os arquivos de testbench e as instruções de como testar o projeto.

## 📚 Recursos
- Para iniciar o estudo do conjunto de instruções RISC-V, consulte:
  - [Manual de Conjunto de Instruções RISC-V Volume I: ISA de Nível de Usuário - Documento Versão 2.2](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)
  - [risc-v isa pages, by msyksphinz](https://msyksphinz-self.github.io/riscv-isadoc/html/rvi.html#)

- Para simular e testar o projeto do processador RISC-V, utilize:
  - [ModelSim-Intel® FPGAs Standard Edition Software Version 20.1.1](https://www.intel.com/content/www/us/en/software-kit/750666/modelsim-intel-fpgas-standard-edition-software-version-20-1-1.html)

- Para verificar os resultados:
  - Compare seus resultados com os exemplos fornecidos em [`sim`](/sim)
  - Utilize o simulador CompSim
  - Utilize o [RISC-V Interpreter, by Cornell University](https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/)

## 📦 Entrega

A data de entrega do projeto será especificada no Classroom, assim como a quantidade de pessoas por grupo.

### Modelo de entrega

A entrega consiste em um relatório seguindo o modelo disponível [aqui](https://docs.google.com/document/d/116sukTXOizb0bplubUOHhdNBqpwtk3cR4Dwaqg-TO7I/edit?usp=sharing). Não deve ser extenso, mas precisa conter todas as informações descritas para a avaliação do projeto.

### Avaliação

A avaliação do projeto será baseada na implementação correta das instruções, nos testes realizados e no funcionamento adequado do processador.

## 🐛 Encontrou um bug ou pensou numa melhoria?

Encorajamos os alunos a procurarem por bugs e sugerirem melhorias para o projeto, visando aperfeiçoá-lo para as próximas edições da disciplina. Se você identificou algum bug ou possui uma ideia para melhorar o projeto, ficaremos felizes em receber sua contribuição!

Existem duas maneiras de nos enviar suas sugestões:

1. **Issue**: Abra uma issue detalhando o problema ou a melhoria proposta. Certifique-se de fornecer informações claras e específicas para facilitar a compreensão do que precisa ser corrigido ou aprimorado.

2. **Pull Request**: Se você é familiarizado com o processo de pull requests, sinta-se à vontade para enviar suas alterações diretamente por meio de um pull request. Certifique-se de descrever claramente as alterações realizadas e o motivo por trás delas.
