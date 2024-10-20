# Delphi-Tracing
Este projeto mapeia automaticamente os métodos de um arquivo `.pas` e insere um registrador de eventos para rastreamento de entrada e saída de cada método. O objetivo é fornecer uma ferramenta que facilite a análise de execução e a correção de bugs, permitindo o acompanhamento preciso do fluxo de chamadas.
### Funcionalidades:
- **Mapeamento Automático:** Identifica automaticamente todos os métodos no arquivo `.pas`.
- **Rastreamento de Eventos:** Insere um log de entrada e saída em cada método mapeado.
- **Análise de Execução:** Registra as informações necessárias para análise posterior do fluxo do programa, ajudando a identificar e corrigir bugs com maior facilidade.
- **Fácil Integração:** Simples de integrar em projetos Delphi já existentes.
- **Sem dependência:** Tudo que precisa para funcionar está no projeto.
#### Referências
- Inspirado nesse projeto [ase379/gpprofile2017](https://github.com/ase379/gpprofile2017) com foco em simplicidade.
- Utiliza [RomanYankovsky/DelphiAST](https://github.com/RomanYankovsky/DelphiAST) para identificar a posição do `uses` e a declaração `begin` e `end` de cada método.
