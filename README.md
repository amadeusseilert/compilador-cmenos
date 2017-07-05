# Estudo e Implementação de um Compilador Didático
Trabalho de conclusão de curso apresentado ao Instituto de Ciência e Tecnologia – UNIFESP, como parte das atividades para obtenção do título de Bacharel em Ciência da Computação.

Aluno: Amadeus Torezam Seilert

Orientador: Prof. Dr. Luiz Eduardo Galvão Martins
## Descrição

Projeto proposto pelo autor do livro Compiler Construction: Principles and Practice, [Kenneth C. Louden](http://www.cs.sjsu.edu/~louden/). Consiste na implementação de um compilador para a [Linguagem C-](http://www.sierranevada.edu/snow/ExamplesX/C-Syntax.pdf), a qual possui uma gramática simples, suas definições são subconjunto da linguagem C. Ela permite a utilização de funções, recursividade, vetores, laços e controle.

## Compilação

O compilador possui *flags* de configuração que vão estabelecer quais módulos vão ser levados em consideração. Essas configurações se encontram arquivo *main.c* como diretivas de pré-processamento.

```
#define NO_PARSE FALSE
#define NO_ANALYZE FALSE
#define NO_CODE FALSE
```

Para gerar um compilador que realiza apenas a análise léxica, basta atribuir `TRUE` para `NO_PARSE`. `TRUE` para `NO_ANALYSE` gera um compilador que realiza análise léxica e sintática. `TRUE` para `NO_CODE`, gera um compilador que realiza todas as análises mas não gera código.

Ainda é possível definir opções para depuração da execução. É recomendável atribuir `TRUE` para todas as opções listadas abaixo para obter informações relevantes das informações do processo de execução de cada etapada da compilação.

```
int TraceScan = FALSE;
int TraceParse = FALSE;
int DebugParse = FALSE;
int TraceAnalyze = FALSE;
int TraceCode = FALSE;
```

### Sistema Linux
Em qualquer distribuição, a compilação é mais simples, pois as ferramentas GCC, Bison, Flex e Makefile já estão pré instaladas. Portanto basta executar os seguintes comandos dentro da pasta do projeto:

Compilação do compilador:
```
make
```

Compilação da máquina TINY:
```
gcc machine/tm.c -o machine/tm
```

Alguns avisos de compilação são emitidos por conta da flag "-Wall" no arquivo *Makefile*. Eles podem ser ignorados.

### Sistema Windows
Para gerar os executáveis do projeto, é preciso obter o GCC, o Flex e o Bison. A forma mais rápida de se obter um ambiente compatível no sistema Windows é instalando o [MSYS2](http://www.msys2.org/). Este *software* oferece uma plataforma com *toolchains* MinGW e Cygwin. O mesmo oferece o instalador de pacotes Pacman, o qual será o responsável por baixar e instalar as dependências deste projeto. Após o guia de instalação do site do MSYS2, invoque os seguintes comandos no terminal do MSYS2:

Instalação do GCC pelo Pacman:
```
pacman -S gcc
```

Instalação do Flex pelo Pacman:
```
pacman -S flex
```

Instalação do Bison pelo Pacman:
```
pacman -S bison
```

Instalação do Makefile pelo Pacman:
```
pacman -S make
```

Após as instalações, já é possível executar o Makefile no diretório do projeto para realizar a compilação completa do projeto. Portando, com o terminal do MSYS2 no diretório do projeto, execute os seguintes comandos:

Compilação do compilador:
```
make
```

Compilação da máquina TINY:
```
gcc machine/tm.c -o machine/tm
```

O arquivo *Makefile* executa o Bison com a flag "-d" gerando um arquivo *parser.output*. Neste arquivo é possível visualizar todas as transições de estados do *parser* do compilador.

## Utilização

Uma vez compilado o compilador e máquina, executa-los nos arquivos teste é simples. Em ambos sistema Linux e Windows (com terminal MSYS2), usando como exemplo o código em C- da função fatorial *factorial.cm*:

Compilando o arquivo teste *factorial.cm*:
```
./c-compiler input/factorial.cm output/factorial.tm
```

Executando o arquivo compilado para a máquina TINY:
```
./machine/tm output/factorial.tm
```

Pressione G para iniciar a máquina ou H para mostrar outras opções.
