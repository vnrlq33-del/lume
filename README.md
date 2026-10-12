# Lume

Aplicativo de compartilhamento de tela para Windows 10/11 de 64 bits. Interface simples em português, inspirada na organização do Discord, com salas por convite, transmissão ao vivo e áudio individual.

## Abrir o aplicativo

Abra `Lume-1.0.0-Windows-x64.exe`. É um aplicativo portátil: não exige Node.js nem instalação para funcionar. Compartilhe o mesmo aplicativo com os convidados.

1. Clique em **Criar uma sala** e digite seu nome.
2. Clique em **Convidar**, copie o convite e envie para os participantes.
3. No outro computador, abra o Lume, clique em **Tenho um convite** e cole o convite.
4. Na sala, clique em **Compartilhar tela**, escolha uma tela ou janela e confirme.
5. Para compartilhar o som, marque **Compartilhar áudio do computador** antes de começar.
6. Quem estiver assistindo pode clicar em **Som da transmissão** ou ajustar o volume. Esse controle afeta apenas aquela pessoa.

O aplicativo não cria um servidor público automaticamente. O modo inicial funciona na mesma rede local ou em uma rede privada/VPN com comunicação entre os computadores. Para usar entre redes diferentes, veja a configuração de internet abaixo.

## O que está incluído

- Salas privadas por convite com até 5 pessoas, incluindo quem transmite.
- Uma pessoa compartilhando por vez. Qualquer participante pode transmitir quando a transmissão anterior terminar.
- Seleção de tela inteira ou janela com prévias reais.
- Perfil padrão desejado de 1920×1080, 60 fps e até 10 Mb/s por espectador; também existem 1080p/30 e 720p/60.
- Áudio do computador capturado por loopback no Windows, quando a opção está ligada.
- Silêncio e volume locais para cada espectador, sem desativar as faixas enviadas ou recebidas.
- Prévia de quem compartilha sempre silenciada, para evitar tocar o áudio capturado duas vezes.
- Chat, lista de participantes, tela cheia e botão de encerrar a transmissão.
- Medições de resolução, fps, uso de rede e tempo de ida e volta. Sem números simulados.
- Captura encerrada quando a pessoa sai da sala ou perde a conexão com o servidor.

## Qualidade e áudio

**1080p a 60 fps é a configuração solicitada, não uma garantia constante.** A tela de origem precisa ter resolução e frequência suficientes. O computador, o codificador e a conexão podem reduzir a qualidade. Uma janela menor não é artificialmente ampliada. Em cenas paradas, o capturador pode enviar menos quadros.

A faixa de áudio inclui **todos os sons do computador**, mesmo se apenas uma janela estiver compartilhada. Não existe isolamento do áudio de um aplicativo externo nesta versão. O aplicativo não captura o microfone e não inclui chamada de voz ou câmera.

O botão de silenciar do espectador modifica apenas a reprodução local. A opção de áudio de quem compartilha determina se a faixa será enviada para a sala. Use fones para evitar reprodução por alto-falantes em ambientes compartilhados.

O envio é direto para cada espectador. Com o teto padrão de 10 Mb/s por espectador, quatro espectadores podem exigir até 40 Mb/s de upload do remetente. O uso real varia e aparece no painel de conexão. Para salas maiores, será necessário adicionar um servidor de mídia/SFU.

## Usar na mesma rede

O computador que cria a sala inicia o servidor de conexão embutido em uma porta TCP livre. O convite contém o IP local e essa porta. Mantenha o aplicativo de quem criou a sala aberto.

Se o Windows perguntar sobre o firewall, permita o aplicativo na rede privada usada pelos participantes. Redes de convidados, Wi-Fi com isolamento de clientes e firewalls podem impedir a conexão. A transmissão de mídia usa WebRTC e pode usar portas UDP dinâmicas.

Se o computador tiver Wi-Fi, cabo e adaptadores de VPN, escolha o endereço acessível pelos convidados na janela de convite. Um convite para `127.0.0.1` só serve no mesmo computador. Não compartilhe esse endereço com pessoas em outros aparelhos.

## Usar pela internet

O projeto inclui um servidor de sinalização em `server/`. Ele coordena salas e conexões; o vídeo e o áudio não passam por ele. Não há um serviço público hospedado incluído neste pacote.

### 1. Publicar o servidor de sinalização

Em um servidor com Node.js 24 ou superior:

```bash
npm ci --omit=dev
npm run server
```

O padrão é TCP 4588. Variáveis de ambiente disponíveis:

| Variável | Uso |
| --- | --- |
| `PORT` | Porta HTTP/WebSocket, padrão `4588` |
| `HOST` | Interface de escuta, padrão `0.0.0.0` |
| `TLS_CERT` | Caminho do certificado HTTPS, opcional |
| `TLS_KEY` | Caminho da chave TLS, opcional |
| `ALLOWED_ORIGINS` | Origens permitidas separadas por vírgula, opcional |

Use um domínio com HTTPS/WSS, por TLS direto ou proxy reverso. O caminho WebSocket é `/signal`; a verificação de saúde é `/health`. O proxy precisa permitir o upgrade de WebSocket e conexões longas.

Exemplo de proxy Nginx dentro de um servidor TLS configurado:

```nginx
location = /signal {
    proxy_pass http://127.0.0.1:4588;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_read_timeout 90s;
}
location = /health {
    proxy_pass http://127.0.0.1:4588;
}
```

### 2. Configurar o aplicativo

Na engrenagem do Lume, preencha **Servidor para salas pela internet** com:

```text
wss://seu-servidor.com/signal
```

Salve e crie uma sala. O convite aponta para esse servidor, portanto os convidados não precisam preencher o endereço novamente.

### 3. Conectar em redes restritas

O aplicativo usa servidores STUN para tentar conexão direta. Alguns roteadores, CGNAT, redes empresariais e firewalls exigem TURN para retransmitir a mídia. A presença de STUN ou de um servidor de sinalização público não garante que todas as redes se conectem.

Configure **Conexão em redes restritas** com a URL, o usuário e a senha de um serviço TURN seu. Cada participante que precisar dele deve configurar suas próprias credenciais. Exemplos de URL:

```text
turn:seu-servidor.com:3478
turns:seu-servidor.com:5349
```

As credenciais TURN ficam no armazenamento da sessão e não são colocadas no convite. Hospedagem e tráfego de retransmissão são serviços externos e podem ter custos. O aplicativo não inclui chaves, assinaturas ou serviços pagos.

Se a conexão direta for bloqueada, marque **Usar apenas retransmissão**. Nesse modo, o servidor TURN precisa estar preenchido e toda a mídia passa por ele.

## Executar ou alterar o código

Instale Node.js 24 ou superior e, na pasta do projeto:

```bash
npm ci
npm start
```

No Windows, `INICIAR.cmd` executa esses passos. Para gerar o portátil:

```bash
npm run build:win
```

O resultado aparece em `release/Lume-1.0.0-Windows-x64.exe`. `GERAR-EXE.cmd` oferece o mesmo fluxo no Windows. Para gerar a pasta do aplicativo em ZIP, execute `npm run build:win:zip`.

O binário desta entrega não possui assinatura digital de editor. Um pacote para distribuição pública pode adicionar um certificado de assinatura de código na configuração do Electron Builder.

## Verificação

```bash
npm test
```

A suíte automatizada verifica convites, limite e isolamento de salas, mensagens, permissão exclusiva de compartilhar, saída do remetente, encerramento de salas e silêncio/volume locais. Testes de integração em Chromium exercitam três participantes com uma fonte de vídeo e áudio sintética sobre conexões WebRTC reais.

Para reproduzir os testes da interface:

```bash
npx playwright install chromium
npm run test:ui
```

Essa suíte cria três participantes e um servidor TURN temporário na própria máquina; verifica recepção de vídeo e áudio, chat, silêncio e volume individuais, troca de remetente, transmissão sem áudio e parada de captura ao sair. A captura nativa é substituída por uma fonte sintética apenas nos testes. O aplicativo distribuído não contém essas substituições.

O teste com fonte sintética não valida a captura nativa de áudio do Windows, desempenho do hardware do usuário ou conectividade entre redes externas. Faça um teste entre dois PCs antes de usar em uma sessão importante. O ambiente de desenvolvimento desta entrega é Linux e não executa o binário Windows.

## Estrutura

| Pasta | Conteúdo |
| --- | --- |
| `electron/` | Janela nativa, seleção de fontes, áudio loopback, IPC limitado e servidor embutido |
| `renderer/` | Interface, volume local, captura e conexões WebRTC |
| `server/` | Servidor de salas e sinalização WebSocket |
| `shared/` | Formato e validação dos convites |
| `tests/` | Testes automatizados |
| `build/` | Ícones do aplicativo |

Fontes de referência: [captura de desktop do Electron](https://www.electronjs.org/docs/latest/api/desktop-capturer), [sessão e seleção de mídia](https://www.electronjs.org/docs/latest/api/session), [especificação de captura de tela](https://www.w3.org/TR/screen-capture/).

## Privacidade

As salas são protegidas por uma chave aleatória no convite. As mensagens existem durante a sessão e não são gravadas em banco de dados. O vídeo e o áudio usam o transporte criptografado do WebRTC, direto ou via TURN. Use WSS para proteger convites e mensagens quando o servidor estiver na internet. O anfitrião de um servidor de sinalização pode observar os metadados da conexão e as mensagens do chat.

O aplicativo não oferece contas, moderação avançada, gravação de sessões, reconexão automática de sala, lista permanente de salas ou a infraestrutura do Discord. O servidor tem limites básicos de mensagens, conexões e tamanho de payload, mas uma implantação pública precisa da proteção e operação adequadas ao seu público.
