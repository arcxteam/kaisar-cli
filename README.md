# Guide Running Operating as Kaisar Network Provider: Empowering a Distributed Cloud Network

<img width="1600" height="900" alt="Your paragraph text" src="https://github.com/user-attachments/assets/52261063-9aa9-4c35-b070-6f488f9f04c2" />

Running a Kaisar Provider offers a unique opportunity to contribute to a state-of-the-art distributed cloud network that powers artificial intelligence (AI) and advanced computational workloads. Below are the key benefits of becoming a Kaisar Provider (Worker Node Operator):

---
## Here We Go...Gas!!!
`Is there incentivized?` ![Confirm](https://img.shields.io/badge/Confirm-yes-brightgreen)

The Kaisar network uses a reward system to encourage participation and maintain efficient network operations. `This like a tiers provider for scoring`
- Bandwidth scoring system = `coefisient max 0.8`
- CPU scoring system = `coefisient max 0.8`
- Disk scoring system = `coefisient max 0.8`
- Memory scoring system = `coefisient max 0.8`
- GPU scoring system = `coefisient max 10.0`

[Read detail Rewards for Kaisar Providers](https://greyscope.xyz/x/docskaisar)

## 1. Preparation Kaisar CLI Node
**1. Hardware requirements** 

`In order to ran Kaisar providers node as CLI, need a Linux server (VPS) with the minimum recommended hardware`
| Requirement                       | Details                         |
|-----------------------------------|---------------------------------|
| RAM                               | 4 GB - up                       |
| CPU/vCPU                          | 2 Core - up                     |
| Storage Space                     | 50-100 GB                       |
| Supported OS                      | Ubuntu 20.04, 22.04, 24.04 LTS  |
| Internet/Processor                | 100Mbps - 64-bit w/ virtualization |

## 2. Dashboard Run & Uptime

1. Go to dashboard connect account or wait until generate new wallet CLI [Kaisar Provider](https://greyscope.xyz/x/dashboard)
2. Need email for binding
3. Running Kaisar Extention? its different but you can run at now..is late not yet [sign up here](https://greyscope.xyz/x/kaisaridlv)

## 3. Installation & Run Kaisar Provider

### a. Clone Repository
```
git clone https://github.com/arcxteam/kaisar-cli.git
cd kaisar-cli
```
### b. Run Install & Follow Instructions
```
chmod +x setup-provider.sh && sudo ./setup-provider.sh
```
### c. After installation, verify status & version
```
kaisar
```
- If you see a welcome message like pict below, the installation was successful!
- Save wallet address + private key above
- Import wallet to Metamask, Okx, Talisman, Rabby or other Web3 wallet
- Go to dashboard to connect

### d. Run Executable - You can now join the network
```
kaisar start
```
<img width="877" height="549" alt="image" src="https://github.com/user-attachments/assets/f0466ed5-ea0c-4b2b-8496-8e9b70001aea" />

## 4. Update Usefull Command Logs

```diff
> this command go to help

- kaisar start
- kaisar stop
- kaisar create-wallet -e your@email
- kaisar import-wallet -e your@email -k private-key
- kaisar status
- kaisar log
- pm2 logs kaisar-provider # optional check logs

+ Wallet private key & configuration data are stored in this folder

- sudo ls -la /var/lib/kaisar-provider-cli
- cd /var/lib/kaisar-provider-cli
```
