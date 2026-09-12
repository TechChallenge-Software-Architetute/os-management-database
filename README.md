# os-management-database

## Estado do Terraform

O deploy executado pelo GitHub Actions utiliza um backend S3 com bloqueio nativo do estado.

Antes do primeiro deploy:

1. Crie um bucket S3 na região `us-east-1`.
2. Configure o segredo `TF_STATE_BUCKET` no repositório com o nome do bucket.
3. Garanta que as credenciais da AWS tenham permissão para acessar o bucket e criar ou atualizar os recursos RDS e EC2.

Recursos criados por execuções anteriores são importados automaticamente quando existem na AWS, mas ainda não estão registrados no estado remoto do Terraform.

## Credenciais do banco

Configure os secrets `DB_USERNAME` e `DB_PASSWORD` no GitHub Actions. O usuário não pode ser `postgres`, pois esse nome é reservado pelo RDS PostgreSQL. Use, por exemplo, `dbadmin`.