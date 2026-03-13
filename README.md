# Terraform + LocalStack Labs

Bu repo, AWS altyapisini Terraform ile ogrenmek icin hazirlanmis bir lab ortami.
Amac, gercek AWS maliyeti olmadan LocalStack uzerinde VPC/EC2 gibi kaynaklari ayağa kaldirip tekrar edilebilir bir akisla calismak.

## Mevcut Durum

- Dockerize LocalStack ortami
- Terraform komutlari container icinden calisiyor
- `vpc` lab'i aktif:
  - VPC
  - Public/Private subnet
  - Internet Gateway
  - Public route table + association
  - Ornek EC2 instance

## Proje Yapisi

```text
terraform/
  vpc/
    provider.tf
    vpc.tf
    .terraform.lock.hcl
    terraform.tfstate
    vpc_artitecture_v1.png
  scripts/
    tf-docker.sh
  docker-compose.yml
  .env.example
  .gitignore
  README.md
```

## Gereksinimler

- Docker
- Docker Compose

Not: Terraform'u bilgisayara kurman gerekmiyor.

## Hizli Baslangic

1. Ortam dosyasini hazirla.

```bash
cp .env.example .env
```

2. LocalStack'i baslat.

```bash
./scripts/tf-docker.sh up
```

3. VPC lab'i icin init/validate/plan.

```bash
./scripts/tf-docker.sh -d vpc init
./scripts/tf-docker.sh -d vpc validate
./scripts/tf-docker.sh -d vpc plan
```

4. Uygula.

```bash
./scripts/tf-docker.sh -d vpc apply -auto-approve
```

5. Temizlik.

```bash
./scripts/tf-docker.sh -d vpc destroy -auto-approve
./scripts/tf-docker.sh down
```

## Port Cakismasi

4566 doluysa farkli host portu kullan:

```bash
LOCALSTACK_HOST_PORT=4567 ./scripts/tf-docker.sh up
LOCALSTACK_HOST_PORT=4567 ./scripts/tf-docker.sh -d vpc plan
```

## Yeni Ozellik Eklerken (S3, Lambda, vb.)

Yeni bir AWS servisi eklediginde genelde 2 dosya guncellenir:

1. `docker-compose.yml`
   - `SERVICES` listesine ilgili servisi ekle.
   - Ornek: Lambda icin `lambda`, cogu senaryoda `logs` ve `s3` de gerekir.

2. `vpc/provider.tf` (veya ilgili lab'in provider dosyasi)
   - `endpoints` bloguna yeni servis endpoint'ini ekle.
   - Ornek: `lambda = var.localstack_endpoints`

Script (`scripts/tf-docker.sh`) normalde degismez.

Degisiklikten sonra su sirayi uygula:

```bash
./scripts/tf-docker.sh down
./scripts/tf-docker.sh up
./scripts/tf-docker.sh -d vpc init
./scripts/tf-docker.sh -d vpc plan
./scripts/tf-docker.sh -d vpc apply -auto-approve
```

## Coklu Lab Kullanimi

Her klasor ayri root module gibi davranir.

```bash
./scripts/tf-docker.sh -d s3 plan
./scripts/tf-docker.sh -d ec2 plan
```

## Guvenlik Notlari

- Gercek secret degerlerini repoya koyma.
- `.env` dosyasini repoya ekleme.
- Terraform cache/state artefaktlari `.gitignore` ile disarida tutulur.
- `.terraform.lock.hcl` repoda kalir.

## Kisa Not

Bu repo bir production blueprint degil; ogrenme odakli ve adim adim buyuyen bir lab ortamidir.
