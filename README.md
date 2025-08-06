# Guide Running Operating as a Kaisar Network Provider: Empowering a Distributed Cloud Network

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

[Read detail Rewards for Kaisar Providers](https://greyscope.xyz/x/docs-kaisar)

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
2. 

## 3. Installation & Run Kaisar Provider

### a. Clone Repository
```
git clone https://github.com/arcxteam/kaisar-cli).git
cd kaisar-cli
```
### b. Run Script Install
```
chmod +x setup-provider.sh && sudo ./setup-provider.sh
```
### c. After installation, verify by running
```
$HOME cd && kaisar
```
- If you see a welcome message like pict below, the installation was successful!
- Save wallet address + private key
- Import wallet to Metamask, Okx, Talisman, Rabby or other Web3 wallet
- Go to dashboard to connect

### d. Run Executable - You can now join the network
```
kaisar start
```

## 4. Update Usefull Command Logs

```diff
> this command go to help

- kaisar start                                    # Start the Provider App
- kaisar stop                                     # Stop the Provider App
- kaisar create-wallet -e <your email>            # Create Wallet
- kaisar import-wallet -e <your email> -k <your private key>      # Import your existed wallet
- kaisar status                                   # Check node status
- kaisar log                                      # Check details log of Provider App
- pm2 logs kaisar-provider                        # Other logs on pm2 background

+ Wallet private key & configuration data are stored in this folder

- sudo ls -la /var/lib/kaisar-provider-cli
- cd /var/lib/kaisar-provider-cli
```
