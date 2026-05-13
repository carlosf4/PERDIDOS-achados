# 📚 Saber Livre — Rede Social Educacional e Literária

Uma plataforma colaborativa para leitura, resumos, grupos de estudo e eventos acadêmicos online.

## ✨ Funcionalidades

- Cadastro e login com JWT
- Upload de livros e arquivos
- Criação e leitura de resumos
- Grupos de estudo com chat e eventos
- Sistema de reputação e conquistas
- Feed com destaques e conteúdo novo

## ⚙️ Tecnologias

- Backend: FastAPI + PostgreSQL
- Frontend: React (Vite) + Tailwind CSS
- Deploy: Railway (backend), Vercel (frontend)

## 🚀 Executar localmente

### Backend
cp .env.example .env
uvicorn app.main:app --reload

### Frontend
cp .env.local.example .env.local
npm install
npm run dev

## ☁️ Deploy

- Railway para backend (Docker)
- Vercel para frontend (Vite)

## 📬 Contato
Desenvolvido por Moises de Matos Figueiredo com suporte do ChatGPT.
