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

> [!CAUTION]
> Recomendo fazer um backup dos fontes antes de fazer o mapeamento.

> [!TIP]
> Abra uma [Issue](https://github.com/e-delphi/Delphi-Tracing/issues/new) se você encontrar algum bug ou sugestão de melhoria.

### Como usar
- Compile e execute o projeto `Mapper`
  - Ele analiza e insere o mapeamento no fonte `.\Logger\src\Logger.Test.pas` do projeto `Logger`
  - Verifique na pasta `bin`, deve ter gerado um arquivo `Mapper.json`
  - É possível remover o mapeamento usando o método `TMapper.Disable(Units);`
- Compile e execute o projeto `Logger`
  - Verifique na pasta `bin`, deve ter gerado um arquivo `Logger.log`
  - Esse projeto contem o fonte `Logger.Test.pas` que foi mapeado na etapa anterior pelo `Mapper`
- Compile e execute o projeto `Viewer`
  - Verifique na pasta `bin`, deve ter gerado um arquivo `Viewer.json`
  - Nesse arquivo vai estar a pilha das chamadas de todos os métodos executados com a data e hora de cada entrada e saída

[Demonstração de como usar](https://github.com/e-delphi/Delphi-Tracing/blob/main/demo.mp4)
