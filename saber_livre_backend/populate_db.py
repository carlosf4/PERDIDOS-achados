from app.database import SessionLocal
from app.models import user, book, summary, group, achievement, reputation
from app.auth import gerar_hash_senha

db = SessionLocal()

def criar_usuario(nome, email, senha, tipo):
    if not db.query(user.User).filter_by(email=email).first():
        u = user.User(
            nome=nome,
            email=email,
            senha=gerar_hash_senha(senha),
            tipo=tipo
        )
        db.add(u)
        db.commit()
        db.refresh(u)
        return u
    return db.query(user.User).filter_by(email=email).first()

print("🔧 Criando usuários...")
aluno = criar_usuario("João Aluno", "aluno@teste.com", "123456", "aluno")
prof = criar_usuario("Maria Professora", "prof@teste.com", "123456", "professor")

print("📚 Criando livro...")
livro = book.Book(
    titulo="A República",
    autor="Platão",
    arquivo_url="/arquivos/exemplo.pdf",
    usuario_id=prof.id,
    nivel_educacional="ensino_medio"
)
db.add(livro)
db.commit()

print("📝 Criando resumo...")
resumo = summary.Summary(
    titulo="Resumo de A República",
    conteudo="A República é um diálogo sobre justiça...",
    autor_id=aluno.id,
    livro_id=livro.id
)
db.add(resumo)
db.commit()

print("👥 Criando grupo...")
grupo = group.Group(
    nome="Filosofia Moderna",
    descricao="Grupo de estudos filosóficos",
    nivel_educacional="ensino_medio",
    criador_id=prof.id
)
db.add(grupo)
db.commit()

print("🏆 Conquistas e reputação...")
rep = reputation.Reputation(usuario_id=aluno.id, pontos=20)
db.add(rep)
conq = achievement.Achievement(
    usuario_id=aluno.id,
    titulo="Primeiro Resumo",
    descricao="Parabéns por criar seu primeiro resumo!"
)
db.add(conq)
db.commit()

print("✅ Banco populado com sucesso.")
