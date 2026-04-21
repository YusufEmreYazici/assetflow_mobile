// Mock data for AssetFlow — gerçekçi Türkçe isimler + GÜVENOK lokasyonları

const LOCATIONS = [
  "Mersin Limanı", "İzmit Terminal", "Aliağa Rafineri", "Ankara Genel Müdürlük",
  "İstanbul Kartal Ofis", "Samsun Depo", "Adana Terminal", "Kocaeli Körfez",
  "Batman Şube", "Kırıkkale İkmal", "İzmir Alsancak", "Mersin Ofis",
];

const DEPARTMENTS = ["IT", "Operasyon", "Lojistik", "Muhasebe", "İK", "Satın Alma", "Filo", "Güvenlik"];

const PEOPLE = [
  { id: "P-0142", sicil: "14023", name: "Mehmet Yılmaz",   title: "Operasyon Uzmanı",  dept: "Operasyon", loc: "Mersin Limanı" },
  { id: "P-0208", sicil: "20845", name: "Ayşe Demir",       title: "Muhasebe Uzmanı",   dept: "Muhasebe",  loc: "Ankara Genel Müdürlük" },
  { id: "P-0311", sicil: "31104", name: "Hüseyin Kaya",     title: "Terminal Şefi",     dept: "Operasyon", loc: "İzmit Terminal" },
  { id: "P-0456", sicil: "45612", name: "Elif Şahin",       title: "İK Uzmanı",         dept: "İK",        loc: "Ankara Genel Müdürlük" },
  { id: "P-0523", sicil: "52301", name: "Burak Öztürk",     title: "Filo Koordinatörü", dept: "Filo",      loc: "Aliağa Rafineri" },
  { id: "P-0689", sicil: "68970", name: "Zeynep Aksoy",     title: "IT Specialist",     dept: "IT",        loc: "Ankara Genel Müdürlük" },
  { id: "P-0712", sicil: "71205", name: "Oğuzhan Çelik",    title: "Depo Sorumlusu",    dept: "Lojistik",  loc: "Samsun Depo" },
  { id: "P-0834", sicil: "83412", name: "Seda Arslan",      title: "Satın Alma Uzmanı", dept: "Satın Alma",loc: "İstanbul Kartal Ofis" },
];

const DEVICES = [
  { id: "D-0001", code: "GVN-LPT-0142", name: "Dell Latitude 5540",   type: "Laptop",  status: "Zimmetli", assignee: "Mehmet Yılmaz",    loc: "Mersin Limanı",        serial: "CN-0RJ2H4-74180", tag: "ASSET-2024-0142" },
  { id: "D-0002", code: "GVN-LPT-0208", name: "Lenovo ThinkPad T14",  type: "Laptop",  status: "Zimmetli", assignee: "Ayşe Demir",       loc: "Ankara Genel Müdürlük",serial: "PF3KQ921",        tag: "ASSET-2024-0208" },
  { id: "D-0003", code: "GVN-MON-0045", name: "LG 27UK850 UltraFine", type: "Monitor", status: "Depoda",   assignee: null,               loc: "Ankara Depo",          serial: "907NTPL3AJ21",    tag: "ASSET-2024-0045" },
  { id: "D-0004", code: "GVN-LPT-0311", name: "HP EliteBook 840 G10", type: "Laptop",  status: "Zimmetli", assignee: "Hüseyin Kaya",     loc: "İzmit Terminal",       serial: "5CG3214XPL",      tag: "ASSET-2024-0311" },
  { id: "D-0005", code: "GVN-PRT-0012", name: "HP LaserJet Pro M404", type: "Yazıcı",  status: "Bakımda",  assignee: null,               loc: "Aliağa Rafineri",      serial: "VNC3K45821",      tag: "ASSET-2024-0012" },
  { id: "D-0006", code: "GVN-PHN-0089", name: "Samsung Galaxy A54",   type: "Telefon", status: "Zimmetli", assignee: "Burak Öztürk",     loc: "Aliağa Rafineri",      serial: "R58T3019ABC",     tag: "ASSET-2024-0089" },
  { id: "D-0007", code: "GVN-DSK-0034", name: "Dell OptiPlex 7010",   type: "Masaüstü",status: "Zimmetli", assignee: "Elif Şahin",       loc: "Ankara Genel Müdürlük",serial: "BQXR7N3",         tag: "ASSET-2024-0034" },
  { id: "D-0008", code: "GVN-TBL-0018", name: "Apple iPad 10th Gen",  type: "Tablet",  status: "Depoda",   assignee: null,               loc: "Ankara Depo",          serial: "DMPQW5K1P78",     tag: "ASSET-2024-0018" },
  { id: "D-0009", code: "GVN-LPT-0297", name: "Lenovo ThinkPad X1",   type: "Laptop",  status: "Emekli",   assignee: null,               loc: "Ankara Depo",          serial: "PF0MHZ91",        tag: "ASSET-2024-0297" },
  { id: "D-0010", code: "GVN-NET-0003", name: "Cisco Catalyst 2960",  type: "Ağ Cihazı",status:"Zimmetli",assignee: "Hüseyin Kaya",      loc: "İzmit Terminal",       serial: "FDO241630AB",     tag: "ASSET-2024-0003" },
  { id: "D-0011", code: "GVN-LPT-0421", name: "Dell Precision 5680",  type: "Laptop",  status: "Zimmetli", assignee: "Zeynep Aksoy",     loc: "Ankara Genel Müdürlük",serial: "8KLM39XP2",       tag: "ASSET-2024-0421" },
  { id: "D-0012", code: "GVN-MON-0067", name: "Dell U2723QE 27\"",    type: "Monitor", status: "Zimmetli", assignee: "Seda Arslan",      loc: "İstanbul Kartal Ofis", serial: "CN027XQK",        tag: "ASSET-2024-0067" },
];

// Hardware details for one device (D-0001)
const HARDWARE = {
  "D-0001": {
    cpu:          "Intel Core i7-1365U (10 çekirdek, 5.2 GHz)",
    ram:          "32 GB DDR5-5200",
    storage:      "1 TB NVMe SSD (Samsung PM9A1)",
    gpu:          "Intel Iris Xe Graphics (entegre)",
    hostname:     "GVN-LPT-0142",
    os:           "Windows 11 Pro 23H2",
    mac:          "A4:BB:6D:2F:91:0C",
    ip:           "10.14.22.47",
    bios:         "Dell 1.12.3 — 14.03.2024",
    motherboard:  "Dell 0X2TPW Rev.A00",
  },
};

const ACTIVITY = [
  { t: "ZIMMET",   main: "Mehmet Yılmaz → Dell Latitude 5540",  detail: "ZMT-20260421-0142 • Mersin Limanı",        when: "12 dk önce",  kind: "success" },
  { t: "GÜNCELLEME",main: "Cihaz güncellendi — GVN-LPT-0208",     detail: "Zeynep Aksoy • Durum: Zimmetli",            when: "1 saat önce", kind: "info" },
  { t: "FORM",     main: "Zimmet formu üretildi",                 detail: "ZF-2026-0097 • Ayşe Demir",                 when: "2 saat önce", kind: "warning" },
  { t: "İADE",     main: "HP LaserJet Pro M404 iade edildi",      detail: "Durum: Bakımda • Aliağa Rafineri",          when: "Dün, 16:42",  kind: "error" },
  { t: "ZIMMET",   main: "Burak Öztürk → Samsung Galaxy A54",     detail: "ZMT-20260420-0141",                         when: "Dün, 11:08",  kind: "success" },
  { t: "GÜNCELLEME",main: "Personel güncellendi — Seda Arslan",   detail: "Lokasyon: İstanbul Kartal Ofis",            when: "2 gün önce",  kind: "info" },
];

const AUDIT_LOG = [
  {
    id: 1, action: "Cihaz güncellendi", entity: "GVN-LPT-0142", user: "Zeynep Aksoy",
    when: "21.04.2026 09:14", kind: "update",
    changes: [
      { field: "Durum",   before: "Depoda",          after: "Zimmetli" },
      { field: "Zimmetli",before: "—",                after: "Mehmet Yılmaz" },
      { field: "Lokasyon",before: "Ankara Depo",      after: "Mersin Limanı" },
    ],
  },
  { id: 2, action: "Zimmet oluşturuldu", entity: "ZMT-20260421-0142", user: "Zeynep Aksoy", when: "21.04.2026 09:14", kind: "create", changes: null },
  {
    id: 3, action: "Cihaz güncellendi", entity: "GVN-LPT-0142", user: "Ersin Kurt",
    when: "18.03.2026 14:22", kind: "update",
    changes: [
      { field: "RAM",  before: "16 GB DDR5",          after: "32 GB DDR5-5200" },
      { field: "SSD",  before: "512 GB NVMe",         after: "1 TB NVMe SSD" },
    ],
  },
  { id: 4, action: "Cihaz oluşturuldu", entity: "GVN-LPT-0142", user: "Ersin Kurt", when: "14.03.2024 10:03", kind: "create", changes: null },
];

Object.assign(window, { LOCATIONS, DEPARTMENTS, PEOPLE, DEVICES, HARDWARE, ACTIVITY, AUDIT_LOG });
