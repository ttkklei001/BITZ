#!/bin/bash

# 作者：K2 节点教程分享 推特 https://x.com/BtcK241918
# $BITZ ePOW (Eclipse $BITZ) 一键挖矿脚本（菜单版）

GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
RED="\e[1;31m"
NC="\e[0m"

KEYPAIR_PATH="$HOME/eclipse-keypair.json"
SCREEN_NAME="eclipse_mining"  # 用于 挖矿界面 和 守护挖矿
THREADS=0  # 用来保存核心数
RPC_URL="https://mainnetbeta-rpc.eclipse.xyz/"  # 默认 RPC 地址

function show_logo() {
  echo -e "${BLUE}"
  echo "=============================="
  echo "      $BITZ ePOW 挖矿工具"
  echo -e "      By K2 节点教程分享"
  echo "=============================="
  echo -e "${NC}"
}

function install_all() {
  echo -e "${GREEN}开始安装 screen...${NC}"
  sudo apt update && sudo apt install -y screen
  echo -e "${GREEN}screen 安装完成。${NC}"

  echo -e "${GREEN}开始安装 Rust...${NC}"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env

  echo -e "${GREEN}安装 Solana CLI...${NC}"
  curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash -s -- -y
  export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

  echo -e "${GREEN}创建 Solana 钱包...${NC}"
  solana-keygen new --no-passphrase --outfile $KEYPAIR_PATH

  echo -e "${GREEN}安装 Bitz CLI...${NC}"
  cargo install bitz

  echo -e "${GREEN}配置 RPC...${NC}"
  solana config set --url $RPC_URL
  solana config set --keypair $KEYPAIR_PATH

  echo -e "${GREEN}安装完成！${NC}"
  read -n 1 -s -r -p "操作完成，按任意键返回菜单..."
  show_menu  # 确保返回主菜单
}

function uninstall_all() {
  echo -e "${RED}开始卸载相关软件...${NC}"

  echo -e "${RED}卸载 screen...${NC}"
  sudo apt remove --purge -y screen

  echo -e "${RED}卸载 Rust...${NC}"
  rustup self uninstall -y

  echo -e "${RED}卸载 Solana CLI...${NC}"
  rm -rf $HOME/.local/share/solana

  echo -e "${RED}卸载 Bitz CLI...${NC}"
  cargo uninstall bitz

  echo -e "${RED}删除钱包文件...${NC}"
  rm -f $KEYPAIR_PATH

  echo -e "${RED}所有相关软件已卸载，钱包已删除。${NC}"
  read -n 1 -s -r -p "操作完成，按任意键返回菜单..."
  show_menu  # 确保返回主菜单
}

function start_mining() {
  echo -e "${YELLOW}请输入你想要使用的 CPU 核心数（建议不超过 $(nproc)）：${NC}"
  read -p "核心数: " user_cores
  THREADS=$user_cores  # 保存用户输入的核心数到全局变量 THREADS
  echo -e "${GREEN}开始使用 $THREADS 核心启动挖矿...${NC}"
  screen -S $SCREEN_NAME -dm bash -c "bitz collect --cores $THREADS"
  echo -e "${GREEN}eMining 已在后台运行。${NC}"
  echo -e "${YELLOW}请确保钱包有至少 0.005 \$ETH：${NC}"
  solana address
  read -n 1 -s -r -p "操作完成，按任意键返回菜单..."
  show_menu  # 确保返回主菜单
}

function check_balance() {
  echo -e "${GREEN}当前账户余额：${NC}"
  bitz account
  read -n 1 -s -r -p "操作完成，按任意键返回菜单..."
  show_menu  # 确保返回主菜单
}

function import_backpack() {
  echo -e "${BLUE}导入 Backpack 钱包：${NC}"
  echo "1. 运行：solana config get"
  echo "2. 查看你的 keypair 路径（默认是 $KEYPAIR_PATH）"
  echo "3. 然后运行：cat $KEYPAIR_PATH"
  echo "4. 复制该 JSON 数组并粘贴到 Backpack 的私钥导入界面"
  read -n 1 -s -r -p "操作完成，按任意键返回菜单..."
  show_menu  # 确保返回主菜单
}

function export_wallet() {
  if [ -f "$KEYPAIR_PATH" ]; then
    echo -e "${GREEN}你的钱包地址：$(solana address)${NC}"
    echo -e "${YELLOW}你的私钥 JSON 数组如下（请妥善保存）：${NC}"
    cat "$KEYPAIR_PATH"
  else
    echo -e "${RED}未找到钱包文件，请先执行安装创建钱包。${NC}"
  fi
  read -n 1 -s -r -p "操作完成，按任意键返回菜单..."
  show_menu  # 确保返回主菜单
}

function change_rpc() {
  echo -e "${YELLOW}请输入新的 RPC 地址：${NC}"
  read -p "RPC 地址: " new_rpc
  RPC_URL=$new_rpc
  solana config set --url $RPC_URL
  echo -e "${GREEN}RPC 地址已更改为 $RPC_URL。${NC}"
  
  # 确保返回菜单
  read -n 1 -s -r -p "操作完成，按任意键返回菜单..."
  show_menu  # 调用主菜单
}

function claim_bitz() {
  echo -e "${GREEN}开始领取 Bitz 奖励...${NC}"
  bitz claim
  echo -e "${GREEN}Bitz 奖励领取成功！${NC}"
  read -n 1 -s -r -p "操作完成，按任意键返回菜单..."
  show_menu  # 确保返回主菜单
}

function view_mining_screen() {
  echo -e "${YELLOW}正在尝试进入挖矿 screen 界面...${NC}"
  echo -e "${YELLOW}退出 screen 请按 Ctrl+A 然后 D${NC}"
  sleep 1
  screen -r $SCREEN_NAME
  echo -e "${GREEN}已退出 screen，会话已结束。返回主菜单...${NC}"
  sleep 1
  show_menu  # 确保返回主菜单
}

function daemon_mining() {
  echo -e "${GREEN}守护挖矿进程启动中（使用 $THREADS 核心）...${NC}"
  while true; do
    if ! screen -list | grep -q "$SCREEN_NAME"; then
      echo "$(date) 未检测到 screen 会话，创建并启动 bitz collect..."
      screen -dmS $SCREEN_NAME bash -c "bitz collect --cores $THREADS"
    else
      if ! pgrep -f "bitz collect" > /dev/null; then
        echo "$(date) bitz collect 进程不存在，重启中..."
        screen -S $SCREEN_NAME -X stuff $"bitz collect --cores $THREADS\n"
      else
        echo "$(date) bitz collect 正在运行中，无需处理。"
      fi
    fi
    sleep 300
  done
}

function show_menu() {
  clear
  show_logo
  echo -e "${YELLOW}请选择要执行的操作：${NC}"
  echo "1. 安装环境并创建钱包"
  echo "2. 启动挖矿"
  echo "3. 查看余额"
  echo "4. 导入 Backpack 钱包"
  echo "5. 导出钱包（私钥）"
  echo "6. 查看挖矿界面（进入 screen）"
  echo "7. 守护挖矿"
  echo "8. 更改 RPC 地址"
  echo "9. 领取 Bitz 奖励"
  echo "10. 卸载所有软件"
  echo "0. 退出"
  echo
  read -p "请输入数字选项: " choice

  case $choice in
    1) install_all ;;
    2) start_mining ;;
    3) check_balance ;;
    4) import_backpack ;;
    5) export_wallet ;;
    6) view_mining_screen ;;
    7) daemon_mining & ;;  # 以后台进程启动守护挖矿
    8) change_rpc ;;
    9) claim_bitz ;;
    10) uninstall_all ;;
    0) echo -e "${RED}退出脚本...${NC}" && exit 0 ;;
    *) echo -e "${RED}无效选项，请重新输入。${NC}" && sleep 1 ;;
  esac
}

# 主程序循环
show_menu
