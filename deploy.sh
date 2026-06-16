#!/bin/bash
set -e

# ── Cores ──
GREEN='\033[0;32m'
GOLD='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${GOLD}══════════════════════════════════════════${NC}"
echo -e "${GOLD}   RUMOSEG — Deploy Automático             ${NC}"
echo -e "${GOLD}══════════════════════════════════════════${NC}"
echo ""

# ── 1. Verificar / instalar Git ──
echo -e "${GREEN}[1/5] Verificando Git...${NC}"
if ! command -v git &> /dev/null; then
  echo "Git não encontrado. Instalando..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    xcode-select --install 2>/dev/null || true
    echo "→ Instale o Git via https://git-scm.com/download/mac e rode este script novamente."
    exit 1
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "→ Baixe e instale o Git em: https://git-scm.com/download/win"
    echo "  Depois rode este script novamente no Git Bash."
    exit 1
  fi
else
  echo "  ✓ Git $(git --version | awk '{print $3}')"
fi

# ── 2. Verificar / instalar Node + Vercel CLI ──
echo ""
echo -e "${GREEN}[2/5] Verificando Node.js e Vercel CLI...${NC}"
if ! command -v node &> /dev/null; then
  echo -e "${RED}Node.js não encontrado.${NC}"
  echo "  → Baixe em: https://nodejs.org (versão LTS)"
  echo "  Depois rode este script novamente."
  exit 1
else
  echo "  ✓ Node $(node --version)"
fi

if ! command -v vercel &> /dev/null; then
  echo "  Instalando Vercel CLI..."
  npm install -g vercel
  echo "  ✓ Vercel CLI instalado"
else
  echo "  ✓ Vercel CLI $(vercel --version)"
fi

# ── 3. Configurar Git e criar repositório ──
echo ""
echo -e "${GREEN}[3/5] Configurando repositório Git...${NC}"

# Confirmar usuário GitHub
echo ""
read -p "  Seu usuário do GitHub (ex: sarah): " GH_USER
read -p "  Nome para o repositório (ex: rumoseg): " REPO_NAME
REPO_NAME=${REPO_NAME:-rumoseg}

# Inicializar git se ainda não for um repo
if [ ! -d ".git" ]; then
  git init
  echo "  ✓ Repositório git inicializado"
fi

# Configurar identidade se não tiver
GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)
if [ -z "$GIT_EMAIL" ]; then
  read -p "  Seu email do GitHub: " GH_EMAIL
  git config --global user.email "$GH_EMAIL"
  git config --global user.name "$GH_USER"
fi

# Criar .gitignore se não existir
if [ ! -f ".gitignore" ]; then
  echo ".DS_Store" > .gitignore
  echo "Thumbs.db" >> .gitignore
fi

# Adicionar e commitar
git add .
git commit -m "Site RUMOSEG — versão inicial" 2>/dev/null || git commit --allow-empty -m "Site RUMOSEG — versão inicial"
git branch -M main

echo ""
echo -e "${GOLD}  Agora vamos criar o repositório no GitHub.${NC}"
echo "  Abra este link no navegador e crie o repositório '${REPO_NAME}' como Public:"
echo ""
echo -e "  → ${GREEN}https://github.com/new${NC}"
echo ""
echo "  ⚠️  NÃO marque 'Add README', 'Add .gitignore' ou 'Add license'"
echo ""
read -p "  Pressione ENTER quando o repositório estiver criado..."

# Adicionar remote e push
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${GH_USER}/${REPO_NAME}.git"

echo ""
echo "  Fazendo push para o GitHub..."
echo "  (O GitHub pode pedir seu usuário e senha/token)"
echo ""
git push -u origin main

echo "  ✓ Código enviado para o GitHub"

# ── 4. Deploy no Vercel ──
echo ""
echo -e "${GREEN}[4/5] Fazendo deploy no Vercel...${NC}"
echo ""
echo "  O Vercel vai pedir login na primeira vez."
echo "  Escolha 'Continue with GitHub' para conectar sua conta."
echo ""

vercel --yes --name "$REPO_NAME"

echo ""
echo -e "${GREEN}[5/5] Configurando deploy de produção...${NC}"
vercel --prod --yes

# ── 5. Resultado ──
echo ""
echo -e "${GOLD}══════════════════════════════════════════${NC}"
echo -e "${GOLD}   ✅ Deploy concluído com sucesso!        ${NC}"
echo -e "${GOLD}══════════════════════════════════════════${NC}"
echo ""
echo "  Seu site está no ar em:"
echo -e "  → ${GREEN}https://${REPO_NAME}.vercel.app${NC}"
echo ""
echo "  Para atualizações futuras, rode:"
echo "    git add ."
echo '    git commit -m "atualização"'
echo "    git push"
echo ""
echo "  O Vercel fará o redeploy automaticamente."
echo ""
