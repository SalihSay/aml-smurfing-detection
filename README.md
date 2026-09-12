# AML Smurfing Detection

Oracle 19c, Oracle Data Integrator 12c (ODI), Metabase OSS ve PaySim verisi kullanılarak geliştirilmiş uçtan uca bir AML / Smurfing Detection Data Warehouse ve BI projesidir.

Proje; şüpheli para transferlerinin kural tabanlı olarak tespit edilmesini, alarm verisinin analitik modele aktarılmasını, hesaplar arasındaki transfer ağının incelenmesini ve alarm → case → SAR akışının raporlanmasını amaçlamaktadır.

---

## 1. Business Problem

Finansal işlemler içerisinde AML açısından şüpheli davranışların tespit edilmesi, yalnızca tekil işlemlerin incelenmesinden ziyade işlem desenlerinin ve hesaplar arasındaki ilişkilerin birlikte değerlendirilmesini gerektirir.

Bu projede aşağıdaki AML tipolojileri modellenmiştir:

- Smurfing
- Structuring
- Layering
- Round Trip
- Dormant Account Reactivation
- Round Amount

Amaç; veri alımından başlayarak staging, kural motoru, data warehouse, network analizi, operasyonel case yönetimi ve BI raporlamasını tek bir analitik akışta birleştirmektir.

---

## 2. Architecture

```text
                         PaySim CSV
                             |
                             v
                    Oracle / STG_AML
                             |
                    +--------+--------+
                    |                 |
                ODI 12c          AML Rule Layer
                    |                 |
                    +--------+--------+
                             |
                             v
                         DWH_AML
                             |
          +------------------+------------------+
          |                  |                  |
      Dimensions          Facts          Graph Layer
          |                  |                  |
          |                  |          GRAPH_EDGE_LIST
          |                  |          GRAPH_METRICS
          |                  |
          |            FACT_CASE
          |            FACT_SAR_FILING
          |            FACT_MODEL_PERFORMANS
          |            FACT_PARA_TRANSFERLERI
          |
          +------------------+
                             |
                 DQ / Audit / Masking
                             |
                             v
                       Metabase OSS
                             |
             +---------------+---------------+
             |               |               |
          AML - Uyum     AML - Risk     AML - Şube
Teknoloji Stack
Oracle Database 19c
Oracle Data Integrator 12c
ODI CKM / IKM
PaySim
Metabase OSS
Docker
Oracle SQL
Git / GitHub

Gephi projeye dahil edilmemiştir. Network analizi Oracle tarafındaki graph tabloları ve Metabase raporlaması üzerinden yürütülmektedir.

3. Data Warehouse

DWH katmanında star-schema yaklaşımı kullanılmıştır.

Dimensions
DIM_CALISAN
DIM_CASE_DURUM
DIM_HESAP
DIM_MODEL_VERSIYON
DIM_MUSTERI
DIM_TARIH
DIM_ULKE

DIM_HESAP üzerinde SCD Type 2 uygulanmıştır.

Gerçek DWH kontrolünde:

9,073,900 aktif hesap
1 geçmiş/inaktif hesap kaydı
9,073,900 distinct aktif HESAP_ID

bulunmaktadır.

Facts

Projede kullanılan gerçek fact tabloları:

FACT_PARA_TRANSFERLERI
FACT_CASE
FACT_SAR_FILING
FACT_MODEL_PERFORMANS
4. Staging and ETL

PaySim işlemleri STG_AML.STG_PARA_TRANSFERLERI tablosuna alınmaktadır.

Staging tablosunda PaySim'in temel işlem alanlarının yanında proje kapsamında kullanılan CDC_ID alanı da bulunmaktadır.

E$ katmanı:

STG_AML.E$_PARA_TRANSFERLERI

üzerinden kural ihlalleri ve alarm metadata'sı takip edilmektedir.

ODI tarafında full-load, dimension lookup, SCD Type 2 ve CKM tabanlı kontrol yaklaşımı kullanılmıştır.

5. AML Rule Engine

Altı AML tipolojisi modellenmiştir.

Smurfing

Temel senaryo:

Aynı hedef hesaba
24 saat içerisinde
en az 5 farklı gönderenden
para gelmesi
ve kısa süre içerisinde çıkış gerçekleşmesi

şüpheli davranış olarak değerlendirilir.

Smurfing scoring sonucu:

STG_AML.SMURFING_SCORE_VW

üzerinden izlenmektedir.

Structuring

Aynı gönderici hesaptan 24 saat içerisinde:

10.000'in altında
en az 3 işlem

gerçekleşmesi izlenmektedir.

View:

STG_AML.STRUCTURING_SCORE_VW
Layering

Transferlerin birden fazla hop üzerinden zincir oluşturması ve kısa zaman penceresinde gerçekleşmesi incelenmektedir.

View:

STG_AML.LAYERING_SCORE_VW
Round Trip

Paranın:

A -> B -> ... -> A

şeklinde başlangıç hesabına geri dönmesi izlenmektedir.

View:

STG_AML.ROUNDTRIP_SCORE_VW
Dormant Account Reactivation

Uzun süre işlem yapmayan hesabın yüksek tutarlı işlem ile yeniden aktif hale gelmesi izlenmektedir.

View:

STG_AML.DORMANT_REACTIVATION_VW
Round Amount

10.000 ve üzerindeki, 1.000'in katı olan tutarlar risk sinyali olarak izlenmektedir.

View:

STG_AML.ROUND_AMOUNT_VW
6. Network Risk Analysis

Hesaplar arasındaki para transferleri graph yapısına dönüştürülmüştür.

GRAPH_EDGE_LIST

Her transfer ilişkisini:

source account
target account
amount
transaction date
transaction type
fraud flags

ile birlikte temsil eder.

GRAPH_METRICS

Aktif hesaplar için:

gelen bağlantı sayısı
giden bağlantı sayısı

hesaplanmaktadır.

Gerçek proje verisinde:

6,362,620 transfer edge
2,722,362 hesapta gelen bağlantı
6,353,307 hesapta giden bağlantı
toplam 6,362,620 incoming bağlantı
toplam 6,362,620 outgoing bağlantı

bulunmaktadır.

Network katmanı, yüksek riskli hesapların işlem ilişkileriyle birlikte incelenmesini sağlar.

7. Case -> SAR Workflow

AML alarmı operasyonel sürecin başlangıç noktasıdır.

Akış:

AML Rule
   |
   v
Alarm
   |
   v
FACT_CASE
   |
   +--> ACIK
   |
   +--> INCELEMEDE
   |
   +--> KAPALI
   |
   +--> SAR_GONDERILDI
             |
             v
      FACT_SAR_FILING

Gerçek DWH durum dağılımında:

ACIK: 2,283
INCELEMEDE: 700
KAPALI: 350
SAR_GONDERILDI: 175

case bulunmaktadır.

SAR katmanında:

175 SAR kaydı
175 distinct case
toplam 1,581,043,000 ilişkili SAR tutarı
0 orphan case
0 case/SAR mismatch

doğrulanmıştır.

8. Model Performance

Gerçek DWH sonucunda Smurfing model performansı:

Metric	Result
Model SK	21
Tarih SK	20260301
Toplam Alarm	3,508
Gerçek Pozitif	287
Yanlış Pozitif	3,221
Recall	3.49%
Precision	8.18%

Bu sonuçlar özellikle yüksek false-positive oranının AML rule tuning açısından önemli olduğunu göstermektedir.

Metrikler yapay olarak iyileştirilmemiş, gerçek proje çıktısı olduğu şekliyle raporlanmıştır.

9. Synthetic Validation

Rule engine kontrollü sentetik veri ile ayrıca test edilmiştir.

Test senaryosu:

6 farklı gönderici hesap
her göndericiden 5,000
aynı hedef hesap
24 saatlik pencere
kısa süre içerisinde çıkış işlemi

oluşturularak Smurfing paterni enjekte edilmiştir.

Kontrollü test sonucunda:

Smurfing alarmı: yakalandı
Precision: %100
False Positive: 0

olarak doğrulanmıştır.

Test tamamlandıktan sonra sentetik staging ve E$ kayıtları temizlenmiş ve baseline veri korunmuştur.

10. Data Quality & Audit

Data quality kontrolleri için:

DWH_AML.DQ_LOG

ETL audit takibi için:

DWH_AML.ETL_AUDIT_LOG

kullanılmaktadır.

Kontrol kapsamı:

orphan key
duplicate business key
null kontrolü
row count
fact/dimension referential integrity
graph referential integrity
case/SAR consistency
ETL status/audit

Proje doğrulamalarında 11 DQ kontrolü PASS, 0 FAIL olarak sonuçlanmıştır.

11. KVKK / PII Masking

BI katmanında ham hesap kimliklerinin doğrudan gösterilmesini azaltmak amacıyla:

DWH_AML.DIM_HESAP_MASKELI_VW

oluşturulmuştur.

Örnek:

C170123456379
        |
        v
C17*******379

Genel BI kullanıcılarının mümkün olduğunca masked view üzerinden çalışması hedeflenmiştir.

12. Technical Challenges
SCD Type 2

DIM_HESAP üzerinde hesap geçmişinin korunması için SCD Type 2 uygulanmıştır.

Surrogate key, başlangıç/bitiş tarihleri ve aktiflik flag'i kullanılarak hesap geçmişi korunmuştur.

Recursive Transfer Analysis

Layering analizi için transfer zincirlerinin birden fazla hop üzerinden takip edilmesi hedeflenmiştir.

Large-volume Testing

Yaklaşık 6.36 milyon staging transferi üzerinde scoring view performansı test edilmiştir.

Smurfing scoring sorgusu kontrollü performans testinde yaklaşık 0.215 saniyede sonuçlanmıştır.

Sentetik test sonrasında test verileri temizlenerek baseline veri korunmuştur.

ODI CDC / Journalizing

ODI Journalizing / CDC yaklaşımı staging tablosu üzerinde opsiyonel olarak denenmiştir.

PaySim statik dosya tabanlı olduğu için gerçek bir source CDC senaryosu bulunmamaktadır.

Bu nedenle CDC ana ETL akışına dahil edilmemiştir.

13. Repository Structure
aml-smurfing-detection/
│
├── README.md
├── .gitignore
│
├── docs/
│   ├── PORTFOLIO_CHECKLIST.md
│   ├── architecture/
│   │   └── architecture.mmd
│   └── screenshots/
│
├── metabase/
│   └── screenshots/
│
├── odi-exports/
│
└── sql/
    ├── dimensions/
    ├── facts/
    ├── rules/
    ├── graph/
    ├── dq/
    ├── masking/
    ├── monitoring/
    └── workflow/

SQL dosyaları konu bazında ayrılmıştır.

monitoring, dq, masking ve workflow klasörlerindeki dosyalar ağırlıklı olarak validation, reporting ve operational query amaçlıdır.

14. How to Run
Prerequisites
Oracle Database 19c
ODI 12c
PaySim dataset
Docker
Metabase OSS
Oracle JDBC driver
High-level execution flow
Oracle 19c instance ve listener'ı başlat.
STG_AML ve DWH_AML şemalarını hazırla.
PaySim verisini staging katmanına yükle.
ODI interface ve CKM akışlarını çalıştır.
Dimension tablolarını yükle.
FACT_PARA_TRANSFERLERI fact tablosunu oluştur/güncelle.
AML rule ve CKM sonuçlarını kontrol et.
Case ve SAR workflow'unu güncelle.
Graph edge ve graph metrics katmanını yenile.
DQ kontrollerini çalıştır.
Masked BI view'larını kullan.
Metabase OSS'u Docker ile başlat.
Oracle JDBC driver'ını Metabase plugins klasörüne koy.
Metabase'i DWH_AML kullanıcısına bağla.
Dashboard'ları oluştur/güncelle.
15. Limitations & Future Improvements
Ground-truth kalitesi artırılabilir.
AML threshold tuning yapılabilir.
False-positive azaltmak için feature engineering eklenebilir.
Gerçek müşteri/KYC kaynağı ile DIM_MUSTERI beslenebilir.
Gerçek zamanlı CDC kaynağı eklenebilir.
Oracle Graph üzerinde daha gelişmiş centrality ve community detection algoritmaları uygulanabilir.
Model drift monitoring genişletilebilir.
Rule ensemble / hybrid ML yaklaşımı eklenebilir.
Case prioritization için risk-based scoring geliştirilebilir.
16. Portfolio Evidence

Projeyi destekleyen kanıtlar:

ODI
odi-exports/

ODI Designer project export dosyaları burada tutulabilir.

Architecture
docs/architecture/
Metabase
metabase/screenshots/

Dashboard çıktıları burada tutulabilir.

SQL
sql/

SQL source, rule, fact, graph, DQ ve monitoring dosyaları burada bulunmaktadır.

Gerçek araç çıktısı olmayan örnek veya uydurma screenshot kullanılmamalıdır.

17. Project Outcome

Bu proje ile:

PaySim tabanlı AML staging pipeline
ODI tabanlı ETL
SCD Type 2 dimension
rule-based AML detection
graph/network risk analysis
case management
SAR filing workflow
model performance measurement
data quality monitoring
ETL audit
BI masking
Metabase dashboards

tek bir uçtan uca analitik mimari altında birleştirilmiştir.