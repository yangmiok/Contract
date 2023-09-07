## 开发环境准备
- 操作系统: windows 10 x64
- Chrome浏览器
- metaMask小狐狸拓展钱包 ( 在Chrome浏览器中的谷歌应用商店下载 )
- 安装好Nodejs服务 ( 直接百度搜索安装即可 )
## 合约代码下载

- gitlab: 

下载之后放在`dappName/contracts`目录下
## 设置本地工作空间

- 下载`remixd`进入系统终端 ( 运行 cmd )
- 执行`npm install -g @remix-project/remixd` 如果npm语法报错, 则检查Nodejs服务
- 检查`remixd`是否安装成功 `remixd -v`当看到输出版本号时, 则安装成功
- 设置工作空间, 执行 `remixd -s "dappName/contracts" -u https://remix.ethereum.org`
- 但看到控制台输出监听`remixd is listening on 127.0.0.1:xxxx`则设置成功
## 进入remix开发工具

- 使用`Chrome浏览器`进入: `https://remix.ethereum.org`
- 选择`WORKSPACES`-> `connect to localhost`
- 连接之后就可以看到本地的合约代码
## 部署合约

- 选择`Solidity compile`模块, 将编译版本设置成`0.8.6`
- 选择`Deploy & run transactions`
- 设置`ENVRONMENT`-> `Injected Provider - MetaMask`连接`metaMask`钱包
- 选择好将要部署的合约, 点击`Deploy`按钮部署即可
## 合约说明

- contracts  - 合约文件夹
   - interfaces  - 接口文件夹
      - `IAsgProfessionalManagers.sol`- 所有周边合约的接口调用入口
      - `IASG.sol`-ASG代币合约接口
      - `ITRC20.sol`- ERC20标准接口
   - `ASG.sol`-ASG代币合约
   - `AsgHelper.sol`-ASG助手合约, 用来给各个资金池转账的合约
   - `AsgProfessionalManagers.sol`- 周边合约控制器合约
   - `Community.sol`- 社区奖励合约
   - `LPMining.sol`- LP挖矿合约
   - `MerchantRewards.sol`- 商家入驻奖励合约
   - `Pensions.sol`- 养老金合约
   - `PowerMining.sol`- 算力挖矿合约
   - `Revenue.sol`- 算力挖矿收益合约
   - `StarAwards.sol`- 星级奖励合约
   - `UUU.sol`- 测试USDT
   - `VerifySig.sol`- 身份签名验证
   - `Available.sol`- 可用ASG合约

以上合约之间的关系, 需要了解产品的业务需求.
## 部署流程

1. `ASG.sol`, `VerifySig.sol`, 将代币参数设置成项目方提供参数, 部署身份验证合约
2. `AsgProfessionalManagers.sol`, 部署ASG周边合约控制器, 需要确定项目方的脚本验签地址, 以及ASG代币合约地址
3. `Revenue.sol`, `Pensions.sol`部署收益, 以及养老金合约, 需要确定控制器地址
4. `PowerMining.sol`部署算力挖矿合约, 需要确定控制器地址, 收益合约, 养老金合约地址, 已经项目方提供的3个外部钱包地址
5. `StrAwards.sol`, `Community.sol`, `LPMining.sol`, `MerchantRewards.sol`, `Available.sol`部署星级奖励, 社区奖励, LP挖矿, 商家入驻奖励合约, 可用ASG合约
## 交互权限

- `PowerMining.sol`算力挖矿合约需要给指定触发者设置`isManager`权限
- 其他提现接口需要服务器对应的私钥签名, 与`AsgProfessionalManagers.sol`控制器合约中的`address`验证
- `Available合约`需要先对Sunswap的Router合约进行授权操作
